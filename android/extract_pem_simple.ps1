# Simple script to extract certificate from JKS using keytool (works without OpenSSL)
# Note: This extracts the certificate only. For full PEM with private key, you need OpenSSL.

$keystoreFile = "easyloan-release-key-new.jks"
$alias = "easyloan"
$storePassword = "MAlbCngI4kKDf0tLmQSa"
$certFile = "easyloan-release-cert.pem"

Write-Host "Extracting certificate from JKS keystore..." -ForegroundColor Green

# Export certificate using keytool
Write-Host "Exporting certificate..." -ForegroundColor Yellow
keytool -exportcert -alias $alias -keystore $keystoreFile -storepass $storePassword -file "$certFile.tmp" -rfc

if ($LASTEXITCODE -eq 0) {
    # Rename to .pem
    if (Test-Path "$certFile.tmp") {
        Move-Item "$certFile.tmp" $certFile -Force
        Write-Host "`nCertificate extracted successfully: $certFile" -ForegroundColor Green
        Write-Host "Location: $(Resolve-Path $certFile)" -ForegroundColor Cyan
        Write-Host "`nNote: This is the certificate only. For private key + certificate PEM," -ForegroundColor Yellow
        Write-Host "you need OpenSSL. The PKCS12 file is available for conversion." -ForegroundColor Yellow
    }
} else {
    Write-Host "Error: Failed to export certificate" -ForegroundColor Red
    exit 1
}
