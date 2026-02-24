# EasyLoan Keystore Information

## New Keystore Details

- **Keystore File**: `easyloan-release-key-new.jks`
- **Key Alias**: `easyloan`
- **Store Password**: `MAlbCngI4kKDf0tLmQSa`
- **Key Password**: `MAlbCngI4kKDf0tLmQSa`
- **Validity**: 10,000 days (~27 years)
- **Key Algorithm**: RSA 2048-bit

## Files Created/Updated

1. **key.properties** - Updated with new password and keystore filename
2. **easyloan-release-key-new.jks** - New keystore file created
3. **extract_pem.ps1** / **extract_pem.bat** - Scripts to extract PEM file from JKS
4. **build_aab.ps1** / **build_aab.bat** - Scripts to build Android App Bundle

## How to Extract PEM File

### Using PowerShell:
```powershell
cd android
.\extract_pem.ps1
```

### Using Batch:
```batch
cd android
extract_pem.bat
```

**Note**: You need OpenSSL installed to extract the PEM file. Download from: https://slproweb.com/products/Win32OpenSSL.html

The PEM file will be created as: `easyloan-release-key.pem`

## How to Build AAB (Android App Bundle)

### Using PowerShell:
```powershell
cd android
.\build_aab.ps1
```

### Using Batch:
```batch
cd android
build_aab.bat
```

The AAB file will be created at: `build\app\outputs\bundle\release\app-release.aab`

## Security Notes

⚠️ **IMPORTANT**: 
- Keep the keystore password secure and never commit it to version control
- The `key.properties` file is already in `.gitignore` but ensure the JKS file is also not committed
- Store the password in a secure password manager
- Keep backups of the keystore file in a secure location

## Manual Commands

If you prefer to run commands manually:

### Extract PEM:
```bash
# Convert JKS to PKCS12
keytool -importkeystore -srckeystore easyloan-release-key-new.jks -srcstorepass MAlbCngI4kKDf0tLmQSa -srcstoretype JKS -destkeystore easyloan-release-key.p12 -deststorepass MAlbCngI4kKDf0tLmQSa -deststoretype PKCS12 -srcalias easyloan -destalias easyloan -srckeypass MAlbCngI4kKDf0tLmQSa -destkeypass MAlbCngI4kKDf0tLmQSa -noprompt

# Extract PEM from PKCS12
openssl pkcs12 -in easyloan-release-key.p12 -out easyloan-release-key.pem -nodes -passin pass:MAlbCngI4kKDf0tLmQSa

# Clean up
del easyloan-release-key.p12
```

### Build AAB:
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```
