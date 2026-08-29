# PiBox runtime (Node.js) updater
# Usage: .\update-runtime.ps1 [-Version v24.20.0] [-Force]
# By default fetches the latest LTS from the mirror and replaces the bundled runtime.
# IMPORTANT: run this from an external terminal (cmd/PowerShell window), NOT from
# inside a PiBox session — it stops running PiBox processes. Restart with start.bat after.

param(
    [string]$Version = "",
    [switch]$Force
)
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$app     = Split-Path -Parent $MyInvocation.MyCommand.Path
$runtime = Join-Path $app "runtime"
$backup  = Join-Path $app "runtime.bak"

function Write-Step($msg) { Write-Host "`n=== $msg ===" -ForegroundColor Cyan }

# ---- 1) Current & target version ----
Write-Step "Current runtime version"
$cur = & "$runtime\node.exe" -v 2>$null
Write-Host "  current: $cur"

if (-not $Version) {
    Write-Host "  fetching latest LTS from mirror..."
    $ij = Invoke-RestMethod -Uri "https://npmmirror.com/mirrors/node/index.json" -TimeoutSec 30
    $lts = $ij | Where-Object { $_.lts } | Select-Object -First 1
    $Version = $lts.version
    Write-Host "  latest LTS: $Version ($($lts.lts))"
}
if (-not $Version.StartsWith("v")) { $Version = "v$Version" }
if ($Version -notmatch '^v\d+\.\d+\.\d+$') { Write-Error "Invalid version: $Version"; exit 1 }
if ($cur -eq $Version) { Write-Host "Already at $Version, nothing to do." -ForegroundColor Green; exit 0 }
Write-Host "  target: $Version" -ForegroundColor Yellow

# ---- 2) Stop running PiBox runtime processes ----
Write-Step "Stopping running PiBox processes (if any)"
$running = Get-CimInstance Win32_Process -Filter "Name='node.exe'" -ErrorAction SilentlyContinue |
    Where-Object { $_.ExecutablePath -like ($runtime + '\node.exe') }
if ($running) {
    $ids = $running.ProcessId -join ", "
    Write-Warning "Running PiBox runtime processes found (PID: $ids). They will be stopped."
    if (-not $Force) {
        $ans = Read-Host "Type Y to continue, anything else to abort"
        if ($ans -ne "Y") { Write-Host "Aborted."; exit 1 }
    }
    $running | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
    Start-Sleep -Seconds 2
} else {
    Write-Host "  none running, safe to replace."
}

# ---- 3) Download ----
Write-Step "Downloading node $Version (mirror first, then official)"
$zip = Join-Path $env:TEMP "node-$Version-win-x64.zip"
$urls = @(
    "https://npmmirror.com/mirrors/node/$Version/node-$Version-win-x64.zip",
    "https://nodejs.org/dist/$Version/node-$Version-win-x64.zip"
)
$ok = $false
foreach ($u in $urls) {
    Write-Host "  trying: $u"
    try {
        curl.exe -L --fail --silent --show-error --connect-timeout 15 --max-time 600 -o $zip $u
        if ((Test-Path $zip) -and (Get-Item $zip).Length -gt 10MB) { $ok = $true; Write-Host ("  downloaded: {0:N1} MB" -f ((Get-Item $zip).Length / 1MB)); break }
    } catch { Write-Host "  failed: $_" }
}
if (-not $ok) { Write-Error "Download failed for $Version"; exit 1 }

# ---- 4) Extract & verify ----
Write-Step "Extracting and verifying"
$dir = Join-Path $env:TEMP "node-$Version-win-x64"
if (Test-Path $dir) { Remove-Item $dir -Recurse -Force }
Expand-Archive -Path $zip -DestinationPath $dir -Force
Remove-Item $zip -Force -ErrorAction SilentlyContinue
$newExe = Join-Path $dir "node-$Version-win-x64\node.exe"
if (-not (Test-Path $newExe)) { Write-Error "Extracted node.exe not found — corrupt zip?"; exit 1 }
$newVer = & $newExe -v
Write-Host "  extracted version: $newVer"
if ($newVer -ne $Version) { Write-Error "Version mismatch ($newVer != $Version) — aborting, nothing changed."; exit 1 }

# ---- 5) Backup & replace ----
Write-Step "Backup and replace"
if (Test-Path $backup) { Remove-Item $backup -Recurse -Force }
Rename-Item $runtime $backup
Write-Host "  old runtime backed up to: $backup"
Move-Item $newExe.Substring(0, $newExe.LastIndexOf("\")) $runtime -Force
Write-Host "  replaced."

# ---- 6) Verify ----
Write-Step "Verifying new runtime"
$v = & "$runtime\node.exe" -v
$npmV = & "$runtime\node.exe" "$runtime\node_modules\npm\bin\npm-cli.js" -v
Write-Host "  node: $v"
Write-Host "  npm:  $npmV"
if ($v -ne $Version) { Write-Error "Verify failed!"; exit 1 }

Write-Host "`nDone. Restart PiBox with start.bat." -ForegroundColor Green
Remove-Item $dir -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Rollback: delete $runtime, rename $backup back to runtime." -ForegroundColor Yellow
