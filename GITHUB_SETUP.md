# GitHub Repository Setup Instructions

## Quick Setup

Your code is ready to push! Follow these steps:

### Step 1: Create Repository on GitHub

1. Go to https://github.com/new
2. Repository name: `limitpass-browser`
3. Description: "Custom Chromium browser build system with extension management"
4. Choose **Private** or **Public** (your preference)
5. **IMPORTANT**: Do NOT check any boxes (no README, .gitignore, or license)
6. Click **"Create repository"**

### Step 2: Push Your Code

After creating the repository, run:

```powershell
# Add the remote (update username if different)
git remote add origin https://github.com/dijiclick/limitpass-browser.git

# Push to GitHub
git push -u origin main
```

If you get an authentication error, you may need to:
- Use a Personal Access Token instead of password
- Or use SSH: `git remote set-url origin git@github.com:dijiclick/limitpass-browser.git`

### Alternative: Use the Setup Script

Run the provided setup script:

```powershell
powershell -ExecutionPolicy Bypass -File setup-github.ps1
```

Then create the repo on GitHub and push:

```powershell
git push -u origin main
```

## Repository Contents

This repository contains:
- ✅ Complete build system for custom Chromium browser
- ✅ Extension management scripts
- ✅ Policy enforcement system
- ✅ Installer creation scripts
- ✅ Documentation (README.md)
- ✅ Two pre-configured extensions (secure & seotech2v1)

## What's Excluded (.gitignore)

- Build artifacts (`dist/`, `chromium/`, `temp/`)
- Compiled installers (`.exe`, `.bat`, `.vbs`)
- ZIP files
- Temporary files

Your source code, scripts, extensions, and configuration files are all included.

