# Milestone-Dev Boilerplate Setup Script (Windows PowerShell)
# Replaces {{TOKEN}} placeholders with your project values

$ErrorActionPreference = "Stop"

Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Blue
Write-Host "║  Milestone-Dev Boilerplate Setup                 ║" -ForegroundColor Blue
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Blue
Write-Host ""

# Accept arguments or prompt interactively
if ($args.Count -ge 6) {
    $ProjectName = $args[0]
    $ProjectSlug = $args[1]
    $ProjectSlugHyphen = $args[2]
    $OwnerName = $args[3]
    $OwnerEmail = $args[4]
    $GithubOrgRepo = $args[5]
} else {
    Write-Host "Enter your project details:" -ForegroundColor Yellow
    Write-Host ""
    $ProjectName = Read-Host "Project name (human-readable, e.g., 'My Platform')"
    $ProjectSlug = Read-Host "Project slug (snake_case, e.g., 'my_platform')"
    $ProjectSlugHyphen = Read-Host "Project slug hyphen (kebab-case, e.g., 'my-platform')"
    $OwnerName = Read-Host "Owner name (git author, e.g., 'Blake')"
    $OwnerEmail = Read-Host "Owner email (git email, e.g., 'blake@example.com')"
    $GithubOrgRepo = Read-Host "GitHub org/repo (e.g., 'myorg/my-platform')"
}

Write-Host ""
Write-Host "Configuration:" -ForegroundColor Blue
Write-Host "  PROJECT_NAME:        $ProjectName"
Write-Host "  PROJECT_SLUG:        $ProjectSlug"
Write-Host "  PROJECT_SLUG_HYPHEN: $ProjectSlugHyphen"
Write-Host "  OWNER_NAME:          $OwnerName"
Write-Host "  OWNER_EMAIL:         $OwnerEmail"
Write-Host "  GITHUB_ORG_REPO:     $GithubOrgRepo"
Write-Host ""

$Confirm = Read-Host "Proceed with these values? (y/n)"
if ($Confirm -ne "y" -and $Confirm -ne "Y") {
    Write-Host "Aborted." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Replacing tokens..." -ForegroundColor Green

$Replaced = 0

# Find all files, excluding .git, node_modules, and setup scripts
$Files = Get-ChildItem -Path . -Recurse -File |
    Where-Object {
        $_.FullName -notmatch '[\\/]\.git[\\/]' -and
        $_.FullName -notmatch '[\\/]node_modules[\\/]' -and
        $_.Name -ne 'setup.sh' -and
        $_.Name -ne 'setup.ps1'
    }

foreach ($File in $Files) {
    try {
        $Content = Get-Content $File.FullName -Raw -ErrorAction SilentlyContinue
        if ($Content -and $Content -match '\{\{') {
            $NewContent = $Content `
                -replace '\{\{PROJECT_NAME\}\}', $ProjectName `
                -replace '\{\{PROJECT_SLUG\}\}', $ProjectSlug `
                -replace '\{\{PROJECT_SLUG_HYPHEN\}\}', $ProjectSlugHyphen `
                -replace '\{\{OWNER_NAME\}\}', $OwnerName `
                -replace '\{\{OWNER_EMAIL\}\}', $OwnerEmail `
                -replace '\{\{GITHUB_ORG_REPO\}\}', $GithubOrgRepo

            Set-Content -Path $File.FullName -Value $NewContent -NoNewline
            $RelativePath = $File.FullName.Substring((Get-Location).Path.Length + 1)
            Write-Host "  ✓ $RelativePath" -ForegroundColor Green
            $Replaced++
        }
    } catch {
        # Skip binary files or files that can't be read
    }
}

Write-Host ""
Write-Host "Replaced tokens in $Replaced file(s)." -ForegroundColor Green

# Self-delete setup scripts
Write-Host ""
Write-Host "Cleaning up setup scripts..." -ForegroundColor Yellow
Remove-Item -Path "setup.sh" -ErrorAction SilentlyContinue
Remove-Item -Path "setup.ps1" -ErrorAction SilentlyContinue
Write-Host "  ✓ Removed setup.sh" -ForegroundColor Green
Write-Host "  ✓ Removed setup.ps1" -ForegroundColor Green

# Configure git
Write-Host ""
Write-Host "Configuring git..." -ForegroundColor Yellow
git config user.name $OwnerName
git config user.email $OwnerEmail
Write-Host "  ✓ Set git user.name to $OwnerName" -ForegroundColor Green
Write-Host "  ✓ Set git user.email to $OwnerEmail" -ForegroundColor Green

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  Setup Complete!                                 ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Blue
Write-Host "  1. Review and customize CLAUDE.md (tech stack, patterns, commands)"
Write-Host "  2. Create your first milestone branch:"
Write-Host "     git checkout -b milestone/m0-project-bootstrap main"
Write-Host "  3. Run the example milestone:"
Write-Host "     /run-milestone m0"
Write-Host "  4. Or create a new milestone:"
Write-Host "     /create-milestone m1"
Write-Host ""
Write-Host "Available Claude Code skills:" -ForegroundColor Blue
Write-Host "  /interview           - Explore requirements and edge cases"
Write-Host "  /create-milestone    - Generate milestone documentation"
Write-Host "  /plan-review         - Review plans before execution"
Write-Host "  /run-milestone       - Automated milestone development"
Write-Host "  /pr-review           - Automated code review"
Write-Host ""
