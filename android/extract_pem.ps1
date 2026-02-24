# Script to extract PEM file from JKS keystore
# Usage: .\extract_pem.ps1

$keystoreFile = "easyloan-release-key-new.jks"
$alias = "easyloan"
$storePassword = "MAlbCngI4kKDf0tLmQSa"
$keyPassword = "MAlbCngI4kKDf0tLmQSa"
$pemFile = "easyloan-release-key.pem"
$p12File = "easyloan-release-key.p12"

Write-Host "Extracting PEM file from JKS keystore..." -ForegroundColor Green

# Step 1: Convert JKS to PKCS12 format
Write-Host "Step 1: Converting JKS to PKCS12 format..." -ForegroundColor Yellow
keytool -importkeystore -srckeystore $keystoreFile -srcstorepass $storePassword -srcstoretype JKS -destkeystore $p12File -deststorepass $storePassword -deststoretype PKCS12 -srcalias $alias -destalias $alias -srckeypass $keyPassword -destkeypass $keyPassword -noprompt

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to convert JKS to PKCS12" -ForegroundColor Red
    exit 1
}

# Step 2: Extract PEM from PKCS12
Write-Host "Step 2: Extracting PEM file from PKCS12..." -ForegroundColor Yellow

# Try OpenSSL first
$opensslFound = $false
try {
    $null = Get-Command openssl -ErrorAction Stop
    $opensslFound = $true
} catch {
    $opensslFound = $false
}

if ($opensslFound) {
    openssl pkcs12 -in $p12File -out $pemFile -nodes -passin pass:$storePassword
    if ($LASTEXITCODE -ne 0) {
        Write-Host "OpenSSL failed, trying Java alternative..." -ForegroundColor Yellow
        $opensslFound = $false
    }
}

# If OpenSSL not available or failed, use Java alternative
if (-not $opensslFound) {
    Write-Host "Using Java-based extraction (OpenSSL not found)..." -ForegroundColor Yellow
    
    # Compile Java extractor if needed
    $javaFile = "ExtractPem.java"
    $javaClass = "ExtractPem"
    
    if (Test-Path $javaFile) {
        Write-Host "Compiling Java extractor..." -ForegroundColor Yellow
        javac $javaFile
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Running Java extractor..." -ForegroundColor Yellow
            java $javaClass $p12File $storePassword $pemFile
            
            if ($LASTEXITCODE -ne 0) {
                Write-Host "Error: Java extraction failed." -ForegroundColor Red
                Write-Host "Alternative: Install OpenSSL from https://slproweb.com/products/Win32OpenSSL.html" -ForegroundColor Yellow
                Write-Host "Or use online tools to convert PKCS12 to PEM" -ForegroundColor Yellow
                Remove-Item $p12File -ErrorAction SilentlyContinue
                exit 1
            }
        } else {
            Write-Host "Error: Failed to compile Java extractor." -ForegroundColor Red
            Write-Host "Please install OpenSSL from: https://slproweb.com/products/Win32OpenSSL.html" -ForegroundColor Yellow
            Remove-Item $p12File -ErrorAction SilentlyContinue
            exit 1
        }
    } else {
        Write-Host "Error: OpenSSL not found and Java extractor not available." -ForegroundColor Red
        Write-Host "Please install OpenSSL from: https://slproweb.com/products/Win32OpenSSL.html" -ForegroundColor Yellow
        Write-Host "Or manually convert the PKCS12 file: $p12File" -ForegroundColor Yellow
        exit 1
    }
}

# Clean up temporary PKCS12 file
Remove-Item $p12File -ErrorAction SilentlyContinue

# Verify PEM file was created
if (Test-Path $pemFile) {
    Write-Host "`nPEM file extracted successfully: $pemFile" -ForegroundColor Green
    Write-Host "Location: $(Resolve-Path $pemFile)" -ForegroundColor Cyan
} else {
    Write-Host "`nWarning: PEM file was not created. PKCS12 file is available at: $p12File" -ForegroundColor Yellow
    Write-Host "You can manually convert it using OpenSSL or online tools." -ForegroundColor Yellow
}
