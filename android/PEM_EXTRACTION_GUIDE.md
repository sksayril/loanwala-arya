# PEM File Extraction Guide

## Current Status

✅ **Certificate extracted**: `easyloan-release-cert.pem` (certificate only)
✅ **PKCS12 file created**: `easyloan-release-key.p12` (contains both certificate and private key)

## The Issue

OpenSSL is not installed on your system, which is needed to extract the complete PEM file (certificate + private key) from the PKCS12 file.

## Solutions

### Option 1: Install OpenSSL (Recommended)

1. **Download OpenSSL for Windows:**
   - Visit: https://slproweb.com/products/Win32OpenSSL.html
   - Download the latest Win64 OpenSSL installer
   - Install it and add it to your system PATH

2. **After installation, run:**
   ```powershell
   cd android
   .\extract_pem.ps1
   ```

   Or manually:
   ```powershell
   openssl pkcs12 -in easyloan-release-key.p12 -out easyloan-release-key.pem -nodes -passin pass:MAlbCngI4kKDf0tLmQSa
   ```

### Option 2: Use Online Converter (Quick but less secure)

1. **Upload the PKCS12 file** (`easyloan-release-key.p12`) to an online converter:
   - https://www.sslshopper.com/ssl-converter.html
   - https://www.keystore-explorer.org/ (download the tool)

2. **Password**: `MAlbCngI4kKDf0tLmQSa`

3. **Download the PEM file**

⚠️ **Security Warning**: Only use trusted online tools and delete the files after conversion.

### Option 3: Use Certificate Only (If you only need the certificate)

The certificate has already been extracted:
- **File**: `easyloan-release-cert.pem`
- **Contains**: Certificate only (no private key)

This is sufficient for some use cases like:
- Verifying the certificate
- Sharing the public certificate
- Certificate chain validation

### Option 4: Use Keystore Explorer (GUI Tool)

1. Download Keystore Explorer: https://www.keystore-explorer.org/
2. Open `easyloan-release-key.p12` with password: `MAlbCngI4kKDf0tLmQSa`
3. Export as PEM format

## Files Available

1. **easyloan-release-key-new.jks** - Original JKS keystore
2. **easyloan-release-key.p12** - PKCS12 format (ready for PEM conversion)
3. **easyloan-release-cert.pem** - Certificate only (already extracted)

## Complete PEM File Structure

A complete PEM file should contain:
```
-----BEGIN PRIVATE KEY-----
[Private key data]
-----END PRIVATE KEY-----

-----BEGIN CERTIFICATE-----
[Certificate data]
-----END CERTIFICATE-----
```

The current `easyloan-release-cert.pem` only has the certificate part.

## Quick Commands

### Extract certificate only (already done):
```powershell
keytool -exportcert -alias easyloan -keystore easyloan-release-key-new.jks -storepass MAlbCngI4kKDf0tLmQSa -file easyloan-release-cert.pem -rfc
```

### Extract complete PEM (requires OpenSSL):
```powershell
openssl pkcs12 -in easyloan-release-key.p12 -out easyloan-release-key.pem -nodes -passin pass:MAlbCngI4kKDf0tLmQSa
```

## Next Steps

1. **For AAB build**: You can proceed with building the AAB - the JKS file is ready
2. **For PEM file**: Choose one of the options above to get the complete PEM file
3. **Security**: Keep all keystore files and passwords secure
