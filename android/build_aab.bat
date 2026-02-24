@echo off
REM Script to build Android App Bundle (AAB)
REM Usage: build_aab.bat

echo Building Android App Bundle (AAB)...

REM Navigate to project root
cd /d "%~dp0\.."

REM Clean previous builds
echo Cleaning previous builds...
call flutter clean

REM Get dependencies
echo Getting Flutter dependencies...
call flutter pub get

REM Build AAB
echo Building release AAB...
call flutter build appbundle --release

if errorlevel 1 (
    echo Error: Failed to build AAB
    exit /b 1
)

set AAB_PATH=build\app\outputs\bundle\release\app-release.aab
if exist "%AAB_PATH%" (
    echo.
    echo AAB built successfully!
    echo Location: %CD%\%AAB_PATH%
    for %%A in ("%AAB_PATH%") do echo File size: %%~zA bytes
) else (
    echo Warning: AAB file not found at expected location
)
