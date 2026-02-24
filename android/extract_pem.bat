@echo off
REM Script to extract PEM file from JKS keystore
REM Usage: extract_pem.bat

set KEYSTORE_FILE=easyloan-release-key-new.jks
set ALIAS=easyloan
set STORE_PASSWORD=MAlbCngI4kKDf0tLmQSa
set KEY_PASSWORD=MAlbCngI4kKDf0tLmQSa
set PEM_FILE=easyloan-release-key.pem
set P12_FILE=easyloan-release-key.p12

echo Extracting PEM file from JKS keystore...

REM Step 1: Convert JKS to PKCS12 format
echo Step 1: Converting JKS to PKCS12 format...
keytool -importkeystore -srckeystore %KEYSTORE_FILE% -srcstorepass %STORE_PASSWORD% -srcstoretype JKS -destkeystore %P12_FILE% -deststorepass %STORE_PASSWORD% -deststoretype PKCS12 -srcalias %ALIAS% -destalias %ALIAS% -srckeypass %KEY_PASSWORD% -destkeypass %KEY_PASSWORD% -noprompt

if errorlevel 1 (
    echo Error: Failed to convert JKS to PKCS12
    exit /b 1
)

REM Step 2: Extract PEM from PKCS12
echo Step 2: Extracting PEM file from PKCS12...

REM Check if OpenSSL is available
where openssl >nul 2>&1
if %errorlevel% equ 0 (
    openssl pkcs12 -in %P12_FILE% -out %PEM_FILE% -nodes -passin pass:%STORE_PASSWORD%
    if errorlevel 1 (
        echo OpenSSL failed, trying Java alternative...
        goto :java_extract
    )
) else (
    echo OpenSSL not found, using Java alternative...
    goto :java_extract
)

goto :extract_done

:java_extract
echo Using Java-based extraction...
if exist ExtractPem.java (
    echo Compiling Java extractor...
    javac ExtractPem.java
    if errorlevel 1 (
        echo Error: Failed to compile Java extractor.
        echo Please install OpenSSL from: https://slproweb.com/products/Win32OpenSSL.html
        del %P12_FILE% 2>nul
        exit /b 1
    )
    echo Running Java extractor...
    java ExtractPem %P12_FILE% %STORE_PASSWORD% %PEM_FILE%
    if errorlevel 1 (
        echo Error: Java extraction failed.
        echo Alternative: Install OpenSSL from https://slproweb.com/products/Win32OpenSSL.html
        echo Or use online tools to convert PKCS12 to PEM
        del %P12_FILE% 2>nul
        exit /b 1
    )
) else (
    echo Error: OpenSSL not found and Java extractor not available.
    echo Please install OpenSSL from: https://slproweb.com/products/Win32OpenSSL.html
    echo Or manually convert the PKCS12 file: %P12_FILE%
    exit /b 1
)

:extract_done

REM Clean up temporary PKCS12 file
del %P12_FILE% 2>nul

echo.
if exist "%PEM_FILE%" (
    echo PEM file extracted successfully: %PEM_FILE%
    echo Location: %CD%\%PEM_FILE%
) else (
    echo Warning: PEM file was not created. PKCS12 file is available at: %P12_FILE%
    echo You can manually convert it using OpenSSL or online tools.
)
