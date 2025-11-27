# Creating a Proper .EXE Installer for LimitPass Browser

## Quick Setup (5 minutes)

### Step 1: Install Inno Setup

1. **Download Inno Setup**: https://jrsoftware.org/isdl.php
2. **Install**: Run the installer and click "Next" through the wizard (default settings are fine)
3. **Verify**: The installer will be in `C:\Program Files (x86)\Inno Setup 6\` or `C:\Program Files\Inno Setup 6\`

### Step 2: Build the Browser

If you haven't built the browser yet:

```powershell
pwsh build\master-build.ps1
```

Or if you already have Chromium downloaded:

```powershell
pwsh build\master-build.ps1 -SkipDownload
```

### Step 3: Create the .EXE Installer

**Option A: Automatic (Recommended)**
```powershell
pwsh create-exe-installer.ps1
```

**Option B: Manual Build**
```powershell
pwsh build\master-build.ps1
```

The build script will automatically detect Inno Setup and create `LimitPassBrowser_Setup.exe` in the `dist\` folder.

**Option C: Direct Compilation**
```powershell
# If Inno Setup is in PATH
ISCC.exe installer\LimitPassBrowser.iss

# Or with full path
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer\LimitPassBrowser.iss
```

## Result

You'll get: **`dist\LimitPassBrowser_Setup.exe`** (~250-300 MB)

### Benefits of .EXE Installer

✅ **Proper Windows installer** - Native Windows executable  
✅ **Smaller file size** - Better compression (LZMA2)  
✅ **No PowerShell issues** - No execution policy warnings  
✅ **Professional appearance** - Standard Windows installer UI  
✅ **Better user experience** - Familiar installer interface  

## Troubleshooting

### "Inno Setup not found"
- Make sure Inno Setup 6.2+ is installed
- Check it's in one of these locations:
  - `C:\Program Files (x86)\Inno Setup 6\ISCC.exe`
  - `C:\Program Files\Inno Setup 6\ISCC.exe`
- Or add it to your PATH environment variable

### "dist\LimitPassBrowser folder not found"
- Run the build script first: `pwsh build\master-build.ps1`
- Make sure the browser was built successfully

### "Icon file not found"
- Place your icon at: `assets\icons\mybrowser.ico`
- Or in the project root as: `mybrowser.ico`
- The installer will work without it (uses default icon)

### Installer is too large
Edit `installer\LimitPassBrowser.iss` and change compression:
```ini
Compression=lzma2/fast          ; Faster, slightly larger
; or
Compression=zip                 ; Much faster, larger file
```

## Silent Installation (Enterprise)

For automated deployment:

```cmd
LimitPassBrowser_Setup.exe /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
```

Options:
- `/VERYSILENT` - No UI at all
- `/SILENT` - Minimal UI (progress bar only)
- `/DIR="C:\CustomPath"` - Custom install location
- `/NOICONS` - Don't create shortcuts

## Comparison: .PS1 vs .EXE Installer

| Feature | .PS1 Installer | .EXE Installer |
|---------|----------------|-----------------|
| File Size | ~400 MB | ~250-300 MB |
| Compression | Base64 (no compression) | LZMA2 (excellent) |
| User Experience | PowerShell window | Professional UI |
| Execution Policy | May require bypass | No issues |
| Distribution | May look suspicious | Standard installer |
| **Recommendation** | Development/Testing | **Production** |

## Next Steps

After creating the .EXE installer:

1. **Test it** - Install on a clean system to verify
2. **Sign it** (Optional) - Use `signtool.exe` for code signing
3. **Distribute** - Share the single .EXE file with users

---

**Need help?** Check `installer\README.md` for more detailed instructions.

