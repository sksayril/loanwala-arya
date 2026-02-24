# Script to build Android App Bundle (AAB)
# Usage: .\build_aab.ps1

Write-Host "Building Android App Bundle (AAB)..." -ForegroundColor Green

# Navigate to project root
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

# Clean previous builds
Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
flutter clean

# Get dependencies
Write-Host "Getting Flutter dependencies..." -ForegroundColor Yellow
flutter pub get

# Build AAB
Write-Host "Building release AAB..." -ForegroundColor Yellow
flutter build appbundle --release

if ($LASTEXITCODE -eq 0) {
    $aabPath = Join-Path $projectRoot "build\app\outputs\bundle\release\app-release.aab"
    if (Test-Path $aabPath) {
        Write-Host "`nAAB built successfully!" -ForegroundColor Green
        Write-Host "Location: $aabPath" -ForegroundColor Cyan
        Write-Host "File size: $([math]::Round((Get-Item $aabPath).Length / 1MB, 2)) MB" -ForegroundColor Cyan
    } else {
        Write-Host "Warning: AAB file not found at expected location" -ForegroundColor Yellow
    }
} else {
    Write-Host "Error: Failed to build AAB" -ForegroundColor Red
    exit 1
}
