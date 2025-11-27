# Script to set up GitHub remote and push
# Run this after creating the repository on GitHub

$repoName = "limitpass-browser"
$githubUsername = "dijiclick"  # Update this if different

Write-Host "Setting up GitHub remote for: $repoName" -ForegroundColor Cyan
Write-Host ""

# Add remote
$remoteUrl = "https://github.com/$githubUsername/$repoName.git"
Write-Host "Adding remote: $remoteUrl" -ForegroundColor Yellow
git remote add origin $remoteUrl 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Remote might already exist, updating..." -ForegroundColor Yellow
    git remote set-url origin $remoteUrl
}

# Set default branch to main (GitHub's default)
Write-Host "Renaming branch to 'main'..." -ForegroundColor Yellow
git branch -M main 2>&1 | Out-Null

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Ready to push to GitHub!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Create the repository on GitHub:" -ForegroundColor White
Write-Host "   - Go to https://github.com/new" -ForegroundColor Gray
Write-Host "   - Repository name: $repoName" -ForegroundColor Gray
Write-Host "   - Set to Private (if desired)" -ForegroundColor Gray
Write-Host "   - DO NOT initialize with README, .gitignore, or license" -ForegroundColor Gray
Write-Host "   - Click 'Create repository'" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Push the code:" -ForegroundColor White
Write-Host "   git push -u origin main" -ForegroundColor Yellow
Write-Host ""
Write-Host "Or run this script again after creating the repo, then push." -ForegroundColor Gray

