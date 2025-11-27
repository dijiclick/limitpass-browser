# LimitPass Browser - Installer Creation Guide

## Quick Start (5 minutes)

### Step 1: Install Inno Setup
Download and install from: https://jrsoftware.org/isdl.php
(Choose "Inno Setup 6.x" - the free version)

### Step 2: Prepare Your Files
Make sure your folder structure looks like this:

```
limitpass-browser/
├── dist/
│   └── LimitPassBrowser/          ← Your built browser goes here
│       ├── chrome.exe             ← Chromium executable
│       ├── resources/
│       │   └── extension/
│       │       ├── secure/        ← Your first extension
│       │       └── seotech2v1/    ← Your second extension
│       ├── policy/
│       │   └── managed/
│       │       └── policy.json    ← Enterprise policies
│       ├── LimitPassBrowser.cmd   ← Launcher script
│       └── ... (other Chromium files)
├── assets/icons/
│   └── mybrowser.ico              ← Your browser icon
├── installer/
│   ├── LimitPassBrowser.iss       ← This installer script
│   ├── compile-installer.bat      ← Run this to compile
│   └── Build-Installer.ps1        ← Alternative PowerShell installer
└── build-installer.bat            ← One-click builder (tries Inno, falls back to PowerShell)
```

### Step 3: Compile the Installer

**Option A: One-Click Builder (Recommended)**
1. Run `installer\build-installer.bat` from project root
2. It will try Inno Setup first, then fall back to PowerShell method
3. Find your installer: `dist\LimitPassBrowser_Setup.exe` or `.ps1`

**Option B: Inno Setup Only**
1. Run `installer\compile-installer.bat`
2. Wait for compilation (takes 1-2 minutes)
3. Find your installer: `LimitPassBrowser_Setup.exe`

**Option C: PowerShell Only (No Inno Setup Required)**
1. Run: `powershell -ExecutionPolicy Bypass -File installer\Build-Installer.ps1`
2. Find your installer: `dist\LimitPassBrowser_Setup.ps1`

---

## Manual Compilation (Alternative)

If the batch script doesn't work, you can compile manually:

1. Open Inno Setup Compiler (from Start Menu)
2. File → Open → Select `installer\LimitPassBrowser.iss`
3. Build → Compile (or press F9)
4. The installer will be created in the same folder

---

## Customization Options

### Change Browser Name
Edit `config\branding.psd1`:
```powershell
BrowserName = 'LimitPass Browser'
InstallDirName = 'LimitPassBrowser'
```

### Change Publisher Info
```powershell
PublisherName = 'DijiClick'
Version = '1.0.0'
```

### Change Installation Folder
Edit `installer\LimitPassBrowser.iss`:
```ini
DefaultDirName={autopf}\LimitPassBrowser
```

### Change Source Folder Path
If your browser is in a different location, edit:
```ini
Source: "dist\LimitPassBrowser\*"; DestDir: "{app}"; ...
```

---

## Troubleshooting

### "ISCC.exe not found"
- Install Inno Setup from https://jrsoftware.org/isdl.php
- Or add Inno Setup to your PATH environment variable

### "dist\LimitPassBrowser folder not found"
- Run your build script first: `pwsh build\master-build.ps1`
- Check that the browser files exist in `dist\LimitPassBrowser\`

### "Icon file not found"
- Create or download a `.ico` file
- Name it `mybrowser.ico` and place in `assets\icons\`
- Or edit the .iss file to point to your icon

### Installer is too large / slow to compile
Edit `installer\LimitPassBrowser.iss` and change:
```ini
Compression=lzma2/fast          ; Faster, slightly larger
; or
Compression=zip                 ; Much faster, larger file
```

### Extensions not loading
1. Check that extensions are in `dist\LimitPassBrowser\resources\extension\`
2. Verify the launcher script has correct `--load-extension` paths
3. Check policy.json has correct extension IDs in allowlist

---

## What the Installer Does

1. **Copies files** to `C:\Program Files\LimitPassBrowser\`
2. **Creates shortcuts** on Desktop and Start Menu
3. **Locks down policies** - Sets ACLs so users can't modify policy files
4. **Registers uninstaller** in Windows "Apps & Features"

---

## Silent Installation (Enterprise Deployment)

For automated deployment:
```cmd
LimitPassBrowser_Setup.exe /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
```

Options:
- `/VERYSILENT` - No UI at all
- `/SILENT` - Minimal UI (progress bar only)
- `/DIR="C:\CustomPath"` - Custom install location
- `/NOICONS` - Don't create shortcuts

---

## Need Help?

If you're still stuck:
1. Make sure you have the portable browser working first (test `dist\LimitPassBrowser\LimitPassBrowser.cmd`)
2. Verify Inno Setup is installed correctly
3. Check that all paths in the .iss file match your actual folder structure

