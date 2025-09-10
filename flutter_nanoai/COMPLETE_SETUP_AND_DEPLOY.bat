@echo off
setlocal enabledelayedexpansion
title NanoAI Flutter - Complete Setup and Deploy

echo ╔══════════════════════════════════════════════════════════════════════════════╗
echo ║                    NanoAI Flutter - Complete Setup & Deploy                 ║
echo ║                   Auto-Install Flutter + Build + Deploy                     ║
echo ╚══════════════════════════════════════════════════════════════════════════════╝
echo.

cd /d "%~dp0"
set PROJECT_DIR=%CD%

:: Step 1: Install Flutter SDK
echo [STEP 1/6] Installing Flutter SDK...
if not exist "C:\flutter" (
    echo Downloading Flutter SDK...
    powershell -Command "& {
        $ProgressPreference = 'SilentlyContinue'
        Write-Host 'Downloading Flutter 3.16.0...'
        Invoke-WebRequest -Uri 'https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip' -OutFile 'flutter.zip'
        Write-Host 'Extracting Flutter...'
        Expand-Archive -Path 'flutter.zip' -DestinationPath 'C:\' -Force
        Remove-Item 'flutter.zip'
        Write-Host 'Flutter installed to C:\flutter'
    }"
    
    :: Add Flutter to PATH for this session
    set PATH=%PATH%;C:\flutter\bin
    
    :: Add Flutter to permanent PATH
    powershell -Command "[Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path', 'User') + ';C:\flutter\bin', 'User')"
    
    echo Flutter SDK installed successfully!
) else (
    echo Flutter SDK already exists
    set PATH=%PATH%;C:\flutter\bin
)

:: Step 2: Verify Flutter installation
echo.
echo [STEP 2/6] Verifying Flutter installation...
C:\flutter\bin\flutter.bat --version
if errorlevel 1 (
    echo ERROR: Flutter installation failed
    pause
    exit /b 1
)

:: Step 3: Setup project
echo.
echo [STEP 3/6] Setting up Flutter project...
C:\flutter\bin\flutter.bat clean
C:\flutter\bin\flutter.bat pub get

:: Step 4: Build APK
echo.
echo [STEP 4/6] Building Android APK...
C:\flutter\bin\flutter.bat build apk --release
if errorlevel 1 (
    echo WARNING: APK build failed, trying without optimization...
    C:\flutter\bin\flutter.bat build apk
)

:: Step 5: Build Web
echo.
echo [STEP 5/6] Building Web application...
C:\flutter\bin\flutter.bat build web --release --web-renderer html

:: Step 6: Package for deployment
echo.
echo [STEP 6/6] Creating deployment packages...

:: Create output directories
if not exist "READY_TO_DEPLOY" mkdir READY_TO_DEPLOY
if not exist "READY_TO_DEPLOY\android" mkdir READY_TO_DEPLOY\android
if not exist "READY_TO_DEPLOY\web" mkdir READY_TO_DEPLOY\web

:: Copy APK
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy "build\app\outputs\flutter-apk\app-release.apk" "READY_TO_DEPLOY\android\NanoAI-v1.0.apk"
    echo ✓ APK ready: READY_TO_DEPLOY\android\NanoAI-v1.0.apk
) else (
    echo ✗ APK build failed
)

:: Copy Web files
if exist "build\web" (
    xcopy "build\web\*" "READY_TO_DEPLOY\web\" /E /I /Y >nul
    echo ✓ Web app ready: READY_TO_DEPLOY\web\
) else (
    echo ✗ Web build failed
)

:: Create Netlify deployment package
if exist "READY_TO_DEPLOY\web" (
    powershell -Command "Compress-Archive -Path 'READY_TO_DEPLOY\web\*' -DestinationPath 'READY_TO_DEPLOY\NanoAI-Netlify.zip' -Force"
    echo ✓ Netlify package: READY_TO_DEPLOY\NanoAI-Netlify.zip
)

:: Create installation instructions
echo Creating installation instructions...
echo # NanoAI Flutter - Installation Guide > READY_TO_DEPLOY\INSTALL_GUIDE.txt
echo. >> READY_TO_DEPLOY\INSTALL_GUIDE.txt
echo ANDROID INSTALLATION: >> READY_TO_DEPLOY\INSTALL_GUIDE.txt
echo 1. Copy NanoAI-v1.0.apk to your Android device >> READY_TO_DEPLOY\INSTALL_GUIDE.txt
echo 2. Enable "Install from Unknown Sources" in Android settings >> READY_TO_DEPLOY\INSTALL_GUIDE.txt
echo 3. Tap the APK file to install >> READY_TO_DEPLOY\INSTALL_GUIDE.txt
echo 4. Launch NanoAI app >> READY_TO_DEPLOY\INSTALL_GUIDE.txt
echo. >> READY_TO_DEPLOY\INSTALL_GUIDE.txt
echo WEB DEPLOYMENT: >> READY_TO_DEPLOY\INSTALL_GUIDE.txt
echo 1. Visit https://app.netlify.com/drop >> READY_TO_DEPLOY\INSTALL_GUIDE.txt
echo 2. Drag NanoAI-Netlify.zip to the page >> READY_TO_DEPLOY\INSTALL_GUIDE.txt
echo 3. Get instant live URL >> READY_TO_DEPLOY\INSTALL_GUIDE.txt
echo. >> READY_TO_DEPLOY\INSTALL_GUIDE.txt
echo FEATURES: >> READY_TO_DEPLOY\INSTALL_GUIDE.txt
echo - AI Chat with Nano and Naruto characters >> READY_TO_DEPLOY\INSTALL_GUIDE.txt
echo - Voice interaction in Arabic and English >> READY_TO_DEPLOY\INSTALL_GUIDE.txt
echo - Full RTL Arabic support >> READY_TO_DEPLOY\INSTALL_GUIDE.txt
echo - Offline and online AI modes >> READY_TO_DEPLOY\INSTALL_GUIDE.txt

echo.
echo ╔══════════════════════════════════════════════════════════════════════════════╗
echo ║                          🎉 DEPLOYMENT READY! 🎉                            ║
echo ╚══════════════════════════════════════════════════════════════════════════════╝
echo.
echo 📱 ANDROID APK: READY_TO_DEPLOY\android\NanoAI-v1.0.apk
echo 🌐 WEB PACKAGE: READY_TO_DEPLOY\NanoAI-Netlify.zip
echo 📋 GUIDE: READY_TO_DEPLOY\INSTALL_GUIDE.txt
echo.
echo 🚀 INSTANT DEPLOYMENT:
echo 1. For Web: Visit https://app.netlify.com/drop
echo    └─ Drag NanoAI-Netlify.zip for instant hosting
echo.
echo 2. For Android: Transfer NanoAI-v1.0.apk to device
echo    └─ Enable Unknown Sources and install
echo.

:: Open deployment folder and Netlify
start "" "READY_TO_DEPLOY"
start "" "https://app.netlify.com/drop"

echo Press any key to exit...
pause >nul
exit /b 0
