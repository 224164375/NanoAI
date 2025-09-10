@echo off
setlocal enabledelayedexpansion
title NanoAI Flutter - APK Builder

echo ╔══════════════════════════════════════════════════════════════════════════════╗
echo ║                    NanoAI Flutter - APK Builder                             ║
echo ║           Auto-Install Flutter + Build APK + Installation Guide            ║
echo ╚══════════════════════════════════════════════════════════════════════════════╝
echo.

cd /d "%~dp0"
set PROJECT_DIR=%CD%

:: Step 1: Check and install Flutter SDK
echo [STEP 1/3] Checking Flutter SDK...
flutter --version >nul 2>&1
if errorlevel 1 (
    echo Flutter not found. Installing Flutter SDK...
    
    :: Download and install Flutter
    powershell -Command "& {
        Write-Host 'Downloading Flutter SDK 3.16.0...'
        $url = 'https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip'
        Invoke-WebRequest -Uri $url -OutFile 'flutter_sdk.zip' -UseBasicParsing
        
        Write-Host 'Installing Flutter to C:\flutter...'
        if (Test-Path 'C:\flutter') { Remove-Item 'C:\flutter' -Recurse -Force }
        Expand-Archive -Path 'flutter_sdk.zip' -DestinationPath 'C:\' -Force
        Remove-Item 'flutter_sdk.zip'
        
        Write-Host 'Adding Flutter to PATH...'
        $currentPath = [Environment]::GetEnvironmentVariable('Path', 'User')
        if ($currentPath -notlike '*C:\flutter\bin*') {
            [Environment]::SetEnvironmentVariable('Path', $currentPath + ';C:\flutter\bin', 'User')
        }
        
        Write-Host 'Flutter SDK installed successfully!'
    }"
    
    :: Set PATH for current session
    set PATH=%PATH%;C:\flutter\bin
    
    echo ✓ Flutter SDK installed to C:\flutter
) else (
    echo ✓ Flutter SDK already available
)

:: Step 2: Build production APK
echo.
echo [STEP 2/3] Building production APK for Android...

:: Clean and get dependencies
echo Cleaning project...
flutter clean >nul 2>&1
echo Getting dependencies...
flutter pub get >nul 2>&1

:: Build APK
echo Building release APK...
flutter build apk --release --target-platform android-arm64
if errorlevel 1 (
    echo Warning: Optimized build failed, trying standard build...
    flutter build apk --release
    if errorlevel 1 (
        echo Error: APK build failed completely
        pause
        exit /b 1
    )
)

:: Step 3: Create installation package and guides
echo.
echo [STEP 3/3] Creating installation package...

:: Create output directory
if not exist "APK_READY" mkdir APK_READY

:: Copy APK with proper naming
if exist "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" (
    copy "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" "APK_READY\NanoAI-Android.apk" >nul
    set APK_FILE=app-arm64-v8a-release.apk
) else if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy "build\app\outputs\flutter-apk\app-release.apk" "APK_READY\NanoAI-Android.apk" >nul
    set APK_FILE=app-release.apk
) else (
    echo Error: No APK file found in build output
    pause
    exit /b 1
)

:: Get APK size
for %%f in ("APK_READY\NanoAI-Android.apk") do set APK_SIZE=%%~zf

:: Create comprehensive installation guide
echo Creating installation guide...
(
echo # NanoAI Flutter - Android Installation Guide
echo.
echo ## What is NanoAI?
echo NanoAI is your intelligent AI assistant featuring:
echo - Interactive AI characters: Nano ^(anime girl^) and Naruto ^(anime boy^)
echo - Voice interaction in Arabic and English
echo - Complete Arabic RTL support
echo - Offline and online AI modes
echo - Modern animated interface
echo.
echo ## Android Installation Steps
echo.
echo ### Method 1: Direct Installation ^(Recommended^)
echo 1. Copy 'NanoAI-Android.apk' to your Android device
echo 2. On your Android device, go to Settings ^> Security
echo 3. Enable "Install from Unknown Sources" or "Allow from this source"
echo 4. Use a file manager to locate the APK file
echo 5. Tap on 'NanoAI-Android.apk' to install
echo 6. Follow the installation prompts
echo 7. Launch NanoAI from your app drawer
echo.
echo ### Method 2: ADB Installation ^(Advanced^)
echo 1. Enable Developer Options on your Android device
echo 2. Enable USB Debugging in Developer Options
echo 3. Connect device to computer via USB
echo 4. Open command prompt in this folder
echo 5. Run: adb install NanoAI-Android.apk
echo.
echo ## Troubleshooting
echo.
echo ### Installation Blocked
echo - Make sure "Install from Unknown Sources" is enabled
echo - Some devices require enabling this per-app ^(Chrome, File Manager, etc.^)
echo - Try installing through different file managers
echo.
echo ### App Won't Open
echo - Ensure your Android version is 5.0+ ^(API level 21+^)
echo - Clear cache and restart device if needed
echo - Grant microphone permission for voice features
echo.
echo ### Voice Features Not Working
echo - Grant microphone permission in app settings
echo - Check device volume and microphone functionality
echo - Ensure internet connection for online AI mode
echo.
echo ## App Features
echo.
echo ### Characters
echo - **Nano**: Friendly anime girl assistant with pink theme
echo - **Naruto**: Energetic anime boy assistant with orange theme
echo.
echo ### AI Modes
echo - **Local Mode**: Works offline with predefined responses
echo - **Connected Mode**: Uses Google Gemini API for advanced AI
echo - **Hybrid Mode**: Combines local and online capabilities
echo.
echo ### Languages
echo - Full Arabic support with RTL layout
echo - English interface and responses
echo - Voice interaction in both languages
echo.
echo ## Technical Information
echo - APK Size: %APK_SIZE% bytes
echo - Target Android: 5.0+ ^(API 21+^)
echo - Permissions: Microphone, Storage, Internet
echo - Architecture: ARM64 ^(most modern devices^)
echo.
echo ## Support
echo If you encounter any issues:
echo 1. Check the troubleshooting section above
echo 2. Ensure your device meets minimum requirements
echo 3. Try reinstalling the app
echo.
echo Enjoy using NanoAI - Your Intelligent Assistant!
) > "APK_READY\INSTALLATION_GUIDE.md"

:: Create quick install batch file
(
echo @echo off
echo title NanoAI - Quick Android Install
echo.
echo This will install NanoAI on your connected Android device
echo Make sure USB Debugging is enabled on your device
echo.
echo Press any key to install...
echo pause ^>nul
echo.
echo adb install NanoAI-Android.apk
echo if errorlevel 1 ^(
echo     echo Installation failed. Please install manually:
echo     echo 1. Copy NanoAI-Android.apk to your Android device
echo     echo 2. Enable Unknown Sources in Android settings
echo     echo 3. Tap the APK file to install
echo ^)
echo.
echo pause
) > "APK_READY\QUICK_INSTALL.bat"

:: Create README file
(
echo # NanoAI Flutter - Ready to Install
echo.
echo ## Files in this package:
echo - **NanoAI-Android.apk** - The Android app ^(%APK_SIZE% bytes^)
echo - **INSTALLATION_GUIDE.md** - Complete installation instructions
echo - **QUICK_INSTALL.bat** - Automated installer for connected devices
echo.
echo ## Quick Start:
echo 1. Read INSTALLATION_GUIDE.md for detailed instructions
echo 2. Copy NanoAI-Android.apk to your Android device
echo 3. Enable "Unknown Sources" in Android settings
echo 4. Install the APK and enjoy!
echo.
echo ## Features:
echo - AI chat with Nano and Naruto characters
echo - Voice interaction in Arabic and English
echo - Full Arabic RTL support
echo - Modern animated interface
echo - Works offline and online
) > "APK_READY\README.md"

echo.
echo ╔══════════════════════════════════════════════════════════════════════════════╗
echo ║                          ✅ APK BUILD COMPLETE! ✅                           ║
echo ╚══════════════════════════════════════════════════════════════════════════════╝
echo.
echo 📱 Android APK: APK_READY\NanoAI-Android.apk
echo 📄 Installation Guide: APK_READY\INSTALLATION_GUIDE.md
echo ⚡ Quick Installer: APK_READY\QUICK_INSTALL.bat
echo 📋 README: APK_READY\README.md
echo.
echo 📊 APK Size: %APK_SIZE% bytes
echo.
echo 🚀 INSTALLATION STEPS:
echo 1. Copy NanoAI-Android.apk to your Android device
echo 2. Enable "Install from Unknown Sources" in Android settings
echo 3. Tap the APK file to install
echo 4. Launch NanoAI and enjoy your AI assistant!
echo.

:: Open the output folder
start "" "APK_READY"

echo Press any key to exit...
pause >nul
exit /b 0
