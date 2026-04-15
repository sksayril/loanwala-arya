# Generates a new JKS keystore and exports the public certificate as PEM (RFC 7468).
# Usage (from android folder):
#   .\generate_jks_and_pem.ps1 -StorePassword "YOUR_PASSWORD" -KeyPassword "YOUR_PASSWORD"
# Optional: -KeystoreFile, -Alias, -PemFile, -DName, -ValidityDays, -Force
#
# If you already publish on Google Play, uploads must be signed with the SAME key Play expects.
# Creating a new JKS produces a NEW certificate — use only for a new app or after Google upload-key reset.

param(
    [Parameter(Mandatory = $true)]
    [string] $StorePassword,
    [string] $KeyPassword = "",
    [string] $KeystoreFile = "release-signing.jks",
    [string] $Alias = "easyloan",
    [string] $PemFile = "",
    [string] $DName = "CN=EasyLoan, OU=Mobile, O=EasyLoan, L=City, ST=State, C=IN",
    [int] $ValidityDays = 10000,
    [switch] $Force
)

$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $here

if ([string]::IsNullOrEmpty($KeyPassword)) {
    $KeyPassword = $StorePassword
}

if ([string]::IsNullOrEmpty($PemFile)) {
    $base = [System.IO.Path]::GetFileNameWithoutExtension($KeystoreFile)
    $PemFile = "$base-cert.pem"
}

$ksPath = Join-Path $here $KeystoreFile
$pemPath = Join-Path $here $PemFile

if ((Test-Path $ksPath) -and -not $Force) {
    Write-Error "Keystore already exists: $ksPath`nUse -Force to overwrite (not recommended if this key is used in production)."
}

if ($Force -and (Test-Path $ksPath)) {
    Remove-Item $ksPath -Force
}

Write-Host "Creating keystore: $KeystoreFile" -ForegroundColor Green
& keytool -genkeypair -v `
    -keystore $KeystoreFile `
    -alias $Alias `
    -keyalg RSA `
    -keysize 2048 `
    -validity $ValidityDays `
    -storetype JKS `
    -storepass $StorePassword `
    -keypass $KeyPassword `
    -dname $DName

if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

Write-Host "Exporting certificate PEM: $PemFile" -ForegroundColor Green
& keytool -exportcert -rfc `
    -alias $Alias `
    -keystore $KeystoreFile `
    -storepass $StorePassword `
    -file $PemFile

if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

Write-Host "`nDone." -ForegroundColor Cyan
Write-Host "  JKS:  $ksPath"
Write-Host "  PEM:  $pemPath"
Write-Host "`nUpdate android/key.properties to point storeFile at this JKS and set passwords/alias."
Write-Host "PEM is public certificate only (safe to share with Play for upload-key registration)."
