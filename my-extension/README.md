Place your unpacked Chrome/Chromium extension files in this folder before running `build/master-build.ps1`.

Requirements:

- The folder must include a valid `manifest.json`.
- The manifest version should be 2 or 3 (Chromium supports both).
- If you need to reference external resources, ensure paths are relative so the extension works after installation.

During the build, this directory is copied to the final application path and loaded via the launcher’s `--load-extension` flag.



