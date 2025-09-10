@echo off
title NanoAI Flutter APK Builder

echo ========================================
echo NanoAI Flutter APK Builder
echo ========================================
echo.

cd /d "%~dp0"

:: Step 1: Install Flutter if not present
echo [1/3] Checking Flutter installation...
where flutter >nul 2>&1
if errorlevel 1 (
    echo Flutter not found. Installing...
    
    :: Create temp directory
    if not exist "temp" mkdir temp
    cd temp
    
    :: Download Flutter using PowerShell
    echo Downloading Flutter SDK...
    powershell -Command "Invoke-WebRequest -Uri 'https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip' -OutFile 'flutter.zip'"
    
    :: Extract Flutter
    echo Extracting Flutter...
    powershell -Command "Expand-Archive -Path 'flutter.zip' -DestinationPath 'C:\' -Force"
    
    :: Clean up
    del flutter.zip
    cd ..
    rmdir /s /q temp
    
    :: Add to PATH permanently
    setx PATH "%PATH%;C:\flutter\bin"
    
    :: Set for current session
    set PATH=%PATH%;C:\flutter\bin
    
    echo Flutter installed successfully.
) else (
    echo Flutter already installed.
)

:: Step 2: Build APK
echo.
echo [2/3] Building Android APK...

:: Use full path to flutter
set FLUTTER_CMD=C:\flutter\bin\flutter.bat
if not exist "%FLUTTER_CMD%" set FLUTTER_CMD=flutter

:: Clean and prepare
%FLUTTER_CMD% clean
%FLUTTER_CMD% pub get

:: Build APK
echo Building release APK...
%FLUTTER_CMD% build apk --release
if errorlevel 1 (
    echo Build failed. Trying alternative...
    %FLUTTER_CMD% build apk
)

:: Step 3: Create installation package
echo.
echo [3/3] Creating installation package...

:: Create output folder
if not exist "READY_APK" mkdir READY_APK

:: Copy APK
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy "build\app\outputs\flutter-apk\app-release.apk" "READY_APK\NanoAI.apk"
    echo APK copied successfully.
) else (
    echo ERROR: APK not found in build output.
    pause
    exit /b 1
)

:: Create installation guide
echo Creating installation guide...
(
echo NanoAI Android Installation Guide
echo =================================
echo.
echo INSTALLATION STEPS:
echo 1. Copy NanoAI.apk to your Android device
echo 2. On Android: Settings ^> Security ^> Enable "Unknown Sources"
echo 3. Use file manager to find NanoAI.apk
echo 4. Tap the APK file to install
echo 5. Launch NanoAI from app drawer
echo.
echo FEATURES:
echo - AI Chat with Nano and Naruto characters
echo - Voice interaction in Arabic and English
echo - Full Arabic RTL support
echo - Modern animated interface
echo.
echo REQUIREMENTS:
echo - Android 5.0+ (API 21+^)
echo - 50MB free space
echo - Microphone permission for voice features
echo.
echo TROUBLESHOOTING:
echo - If installation fails, enable "Install from Unknown Sources"
echo - Grant microphone permission for voice features
echo - Ensure stable internet for online AI mode
) > "READY_APK\INSTALL_GUIDE.txt"

:: Create quick installer
(
echo @echo off
echo echo Installing NanoAI on connected Android device...
echo adb install NanoAI.apk
echo if errorlevel 1 (
echo     echo ADB installation failed.
echo     echo Please install manually using INSTALL_GUIDE.txt
echo ^)
echo pause
) > "READY_APK\adb_install.bat"

echo.
echo ========================================
echo BUILD COMPLETE!
echo ========================================
echo.
echo Files created:
echo - READY_APK\NanoAI.apk (Android app)
echo - READY_APK\INSTALL_GUIDE.txt (Instructions)
echo - READY_APK\adb_install.bat (ADB installer)
echo.
echo To install on Android:
echo 1. Copy NanoAI.apk to your device
echo 2. Enable Unknown Sources in settings
echo 3. Install the APK
echo.

start READY_APK
pause
