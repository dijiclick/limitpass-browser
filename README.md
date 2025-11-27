# MyBrowser Build System

This project produces a completely managed, Chromium-based browser called **MyBrowser**. The automation pipeline downloads the latest 64-bit portable Chromium snapshot, injects your unpacked extension, enforces enterprise policies that block every other extension (and the Chrome Web Store), and compiles a polished Inno Setup installer ready for distribution on Windows 10/11.

---

## 1. Repository Layout

| Path | Purpose |
| --- | --- |
| `build/master-build.ps1` | Single entry point that chains every build step. |
| `scripts/` | Modular PowerShell helpers (download, extract, copy extension, stage payload, compile installer). |
| `config/branding.psd1` | Central configuration for naming, versioning, installer output, policy toggles, and extension identifiers. |
| `config/policies/` | Managed and recommended Chromium policy JSON. `policy.template.json` is tokenised; `policy.json` is the current generated output. |
| `config/chromium-flags.txt` | Flags injected into the launcher (`--load-extension`, `--disable-extensions-except`, etc.). |
| `src/launcher/MyBrowser.cmd` | Portable launcher that maps Chromium flags and user data paths. |
| `my-extension/` | Drop your unpacked extension here (must contain `manifest.json`). |
| `assets/icons/` | Store `mybrowser.ico` for branding shortcuts and the installer. |
| `installer/MyBrowser.iss` | Parameterised Inno Setup definition with custom branding and ACL hardening. |
| `dist/` | Build output (portable tree under `dist/MyBrowser/` plus `MyBrowser_Setup.exe`). |
| `temp/` | Transient download/extraction cache. |
| `chromium/` | Working copy of the portable Chromium payload prior to staging. |

---

## 2. Prerequisites

1. **Windows 10/11 (64-bit)** with PowerShell 5.1+ (or PowerShell 7).
2. **Inno Setup 6.2+** – add `ISCC.exe` to `PATH` or point `IsccPath` inside `config/branding.psd1`.
3. **7-Zip** (optional) – PowerShell’s native `Expand-Archive` is used by default.
4. **HTTPS connectivity** to `storage.googleapis.com` for Chromium snapshot downloads.
5. **Administrator rights** when installing the final `.exe` (needed for Program Files + policy ACLs).

---

## 3. Step-by-Step Build

1. **Add your extension**
   - Copy every file for your unpacked extension into `my-extension/`.
   - Confirm `manifest.json` exists.
2. **Update branding**
   - Edit `config/branding.psd1`.
   - Provide `BrowserName`, `PublisherName`, desired `InstallDirName`, icon path, semantic `Version`, and the real `ExtensionId`.
   - Toggle `DisableDevTools`, `BlockChromeWebStore`, and other booleans as needed.
3. **(Optional) Chromium flags**
   - Modify `config/chromium-flags.txt` (the launcher replaces `{EXTENSION_PATH}` and `{USER_DATA_DIR}` at runtime).
4. **Run the pipeline**

   ```powershell
   pwsh -ExecutionPolicy Bypass -File build/master-build.ps1
   ```

   Add `-SkipDownload` to reuse an existing `temp/chromium.zip`, or `-SkipInstaller` to test the portable build without compiling the installer.
5. **Collect artifacts**
   - Portable tree: `dist/MyBrowser/`
   - Installer: `dist/MyBrowser_Setup.exe` (name is configurable via `OutputInstallerName`).

---

## 4. What the Scripts Do

| Script | Description |
| --- | --- |
| `scripts/setup-folders.ps1` | Ensures all expected directories exist. |
| `scripts/download-chromium.ps1` | Pulls the latest 64-bit snapshot (`chrome-win.zip`) from Google Cloud Storage. |
| `scripts/extract-chromium.ps1` | Extracts the archive into `chromium/`. |
| `scripts/copy-extension.ps1` | Copies `my-extension/` into `chromium/resources/extension`. |
| `scripts/apply-policies.ps1` | Copies policy files, renders `policy.template.json` using branding toggles, and places them under `chromium/policy/managed`. |
| `scripts/stage-distribution.ps1` | Builds the distributable tree (Chromium payload, launcher, flags, icon). |
| `scripts/package-installer.ps1` | Passes dynamic defines into `installer/MyBrowser.iss` and invokes `ISCC.exe`. |
| `build/master-build.ps1` | Calls each helper in order; serves as the master build script requested in the requirements. |

All scripts share helper functions from `scripts/common.psm1`.

---

## 5. Policy Hardening

The managed policy (`config/policies/managed/policy.json`) is applied verbatim inside `{app}\policy\managed\`. Highlights:

- Blocks every extension via `ExtensionSettings["*"].installation_mode = "blocked"` with the custom message **“Extensions are disabled in this browser.”**
- Adds your extension ID to both `ExtensionInstallAllowlist` and `ExtensionSettings[ID]` so the launcher can load it while all others are refused.
- Enables `ExtensionInstallBlocklist = ["*"]` and `ExtensionInstallSources = ["file:///*"]` to prevent sideloading.
- Disables Developer Tools when `DisableDevTools = $true` (policy `DeveloperToolsAvailability = 2`).
- Blocks `chrome://extensions`, `https://chrome.google.com/webstore/*`, and `https://chromewebstore.google.com/*`.
- Disables guest profiles, multiple profiles, password manager, promotional tabs, etc.

Policies live under Program Files after installation. The installer runs `icacls` to grant write access only to `Administrators` and `SYSTEM`, preventing standard users from tampering.

To regenerate the managed JSON from the template (for example, after changing `ExtensionId`), re-run the build script; it re-renders automatically. You can also edit `config/policies/managed/policy.template.json` to introduce additional controls (Safe Browsing, URL filtering, etc.).

---

## 6. Extension Loading Strategy

- The launcher (`{InstallDir}\MyBrowser.cmd`) injects flags `--disable-extensions-except="{app}\resources\extension"` and `--load-extension="{app}\resources\extension"`.
- Chromium user data lives under `{app}\user-data` by default, keeping the profile portable and separated from Chrome/Edge.
- Policies block every other extension, disable the Chrome Web Store, and show the custom block message.
- If you prefer `ExtensionInstallForcelist`, supply a CRX/update manifest and populate `ExtensionForcelist` in the template; the build system is ready to pass through whatever JSON you define.

---

## 7. Installer (Inno Setup)

Key behaviours:

- Targets `Program Files` (64-bit) using your custom folder name (`InstallDirName`).
- Ships shortcuts for Desktop and Start Menu, both pointing to `{app}\MyBrowser.cmd` and using your icon.
- Runs silently with `/VERYSILENT` should you embed it into an enterprise deployment.
- Invokes `icacls` post-install to lock down `{app}\policy`.
- Generates an uninstaller entry in “Apps & features”.

To customise UI strings, add wizard images, or include additional assets, edit `installer/MyBrowser.iss`. All top-level variables are supplied through `/D` defines from `scripts/package-installer.ps1`.

---

## 8. Custom Branding & Icons

`config/branding.psd1` centralises every brand-specific value:

- `BrowserName`, `PublisherName`, `CompanyName`, `InstallDirName`, `Version`
- `IconPath` (default `assets/icons/mybrowser.ico`)
- `ExtensionId` and `ExtensionUpdateUrl` (needed if you later distribute a signed CRX)
- `OutputInstallerName`, `IsccPath`
- Policy toggles: `DisableDevTools`, `BlockChromeWebStore`, `BlockExtensionsPage`, `ForcePortableUserData`

**Icon:** Place a valid `.ico` file under `assets/icons/` and update `IconPath` if the name differs. The staging script copies that icon into the final payload so shortcuts resolve even after installation.

---

## 9. Replacing the Extension

1. Drop your extension files into `my-extension/`.
2. Note the extension ID (load it once in Chromium with developer mode enabled to read the generated ID). Update `ExtensionId` in `config/branding.psd1`.
3. If your extension relies on external native messaging hosts, include them under `resources/` and update the installer script accordingly.
4. Rerun `build/master-build.ps1`.

Because the launcher uses `--load-extension`, the ID in policies is mainly used to ensure the allowlist recognises your extension and the block message doesn’t apply to it.

---

## 10. Security Considerations

- Policies live in Program Files with restricted ACLs; standard users cannot edit them.
- Extension system UI (`chrome://extensions`) and the Chrome Web Store are blocked at the URL level.
- Developer Tools are disabled by default (toggle via branding config).
- `--disable-component-update` prevents Chromium from pulling remote components that might re-enable features.
- All browsing data is scoped to `{app}\user-data`, making it easy to pre-provision or wipe profiles during upgrades.
- If you need to go further, consider enabling `SitePerProcess`, `SafeBrowsingProtectionLevel`, or `URLBlocklist` entries in `policy.template.json`.

---

## 11. Troubleshooting

| Issue | Fix |
| --- | --- |
| **Chromium download fails** | Check firewall/Proxy. The script prints the snapshot URL—verify it in a browser. You can also download manually, place it in `temp/chromium.zip`, and run `master-build.ps1 -SkipDownload`. |
| **Extension not loading** | Ensure `manifest.json` exists and `my-extension/` copied correctly. Review `%LOCALAPPDATA%\Temp\MyBrowser.log` (Chromium console) or launch from `MyBrowser.cmd` inside a console window to inspect output. |
| **“Extensions are disabled” message for my extension** | Update `ExtensionId` to the correct 32-character ID. Re-run the build to regenerate policies. |
| **Installer compilation error** | Confirm `ISCC.exe` path and that `assets/icons/mybrowser.ico` is a valid icon. The script stops if `ISCC.exe` is missing. |
| **Policies ignored after install** | Install as administrator so `policy` files land in Program Files with proper ACL. Verify `{app}\policy\managed\policy.json` exists and contains your settings. |
| **Need DevTools for debugging** | Set `DisableDevTools = $false` in `config/branding.psd1`, rerun the build, or temporarily launch Chromium directly (`chrome.exe`) without the enforced flags. |

---

## 12. Next Steps

- Integrate signing: once `dist/MyBrowser_Setup.exe` is generated, sign it with `signtool.exe`.
- Automate builds in CI by invoking `pwsh build/master-build.ps1` on a Windows build agent that has Inno Setup installed.
- Extend policies to manage homepage, proxies, or safe browsing per your organisation’s requirements.

Happy building!


