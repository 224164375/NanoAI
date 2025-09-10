@echo off
title NanoAI Flutter - Simple Deploy

echo ========================================
echo NanoAI Flutter - Simple Deploy Script
echo ========================================
echo.

cd /d "%~dp0"
echo Current directory: %CD%

echo [1/4] Checking Flutter...
flutter --version
if errorlevel 1 (
    echo ERROR: Flutter not found. Please install Flutter first.
    pause
    exit /b 1
)

echo.
echo [2/4] Cleaning and getting dependencies...
call flutter clean
call flutter pub get

echo.
echo [3/4] Building APK...
call flutter build apk --release
if errorlevel 1 (
    echo ERROR: APK build failed
    pause
    exit /b 1
)

echo.
echo [4/4] Building Web...
call flutter build web --release
if errorlevel 1 (
    echo ERROR: Web build failed
    pause
    exit /b 1
)

echo.
echo Creating output directory...
if not exist "ready" mkdir ready
if not exist "ready\android" mkdir ready\android
if not exist "ready\web" mkdir ready\web

echo.
echo Copying built files...
copy "build\app\outputs\flutter-apk\app-release.apk" "ready\android\NanoAI.apk"
xcopy "build\web\*" "ready\web\" /E /I /Y

echo.
echo ========================================
echo BUILD COMPLETE!
echo ========================================
echo.
echo Android APK: ready\android\NanoAI.apk
echo Web App: ready\web\index.html
echo.
echo To deploy web app:
echo 1. Visit https://app.netlify.com/drop
echo 2. Drag the ready\web folder to deploy
echo.
echo To install Android APK:
echo 1. Copy NanoAI.apk to your Android device
echo 2. Enable Unknown Sources in settings
echo 3. Tap the APK to install
echo.

start ready
pause
