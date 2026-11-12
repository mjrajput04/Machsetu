<#
  One-command deploy for MachSetu, run from this folder on Windows:

      powershell -ExecutionPolicy Bypass -File .\deploy.ps1

  What it does:
    1. Pushes your committed code on `main` to GitHub.
    2. If Machsetu_Admin\.env.update exists, uploads it to the server and
       deletes the local copy. Put settings in it as KEY=value lines, e.g.
           SMSINDORI_KEY=your-key-here
       The file is git-ignored, so secrets never reach GitHub.
    3. On the server: writes those settings into .env.local, deletes the
       uploaded file, pulls the code, builds and restarts (deploy/deploy.sh).

  SSH asks for the server password once or twice unless you have an SSH key.
#>

$ErrorActionPreference = "Stop"

$Server = "root@200.234.37.30"
$AppDir = "/var/www/machsetu/Machsetu_Admin"
$Root = $PSScriptRoot
$Update = Join-Path $Root "Machsetu_Admin\.env.update"

function Check([string]$step) {
  if ($LASTEXITCODE -ne 0) { throw "$step failed (exit code $LASTEXITCODE)." }
}

# 1. Code to GitHub ---------------------------------------------------------
$branch = (git -C $Root rev-parse --abbrev-ref HEAD).Trim()
if ($branch -ne "main") { throw "Switch to the main branch first (you are on '$branch')." }

$dirty = git -C $Root status --porcelain --untracked-files=no
if ($dirty) {
  Write-Host "Note: you have uncommitted changes. Only committed code is deployed." -ForegroundColor Yellow
}

Write-Host "==> Pushing main to GitHub" -ForegroundColor Cyan
git -C $Root push origin main
Check "git push"

# 2. Settings to the server -------------------------------------------------
if (Test-Path $Update) {
  Write-Host "==> Uploading .env.update" -ForegroundColor Cyan
  scp $Update "${Server}:${AppDir}/.env.update"
  Check "Uploading .env.update"
  Remove-Item $Update -Force
  Write-Host "    local .env.update deleted"
}

# 3. Update and restart on the server ----------------------------------------
# Pull first so the newest deploy.sh is the one that runs.
Write-Host "==> Deploying on the server" -ForegroundColor Cyan
ssh $Server "cd $AppDir && git pull --ff-only -q && bash deploy/deploy.sh"
Check "Server deploy"

Write-Host "==> All done. https://machsetu.com" -ForegroundColor Green
