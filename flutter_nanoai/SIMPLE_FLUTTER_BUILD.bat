@echo off
title NanoAI APK Builder

echo NanoAI Flutter APK Builder
echo ===========================

cd /d "%~dp0"

:: Check if Flutter exists
if exist "C:\flutter\bin\flutter.bat" (
    echo Flutter found at C:\flutter
    set FLUTTER=C:\flutter\bin\flutter.bat
    goto build
)

:: Install Flutter
echo Installing Flutter...
mkdir C:\flutter 2>nul
cd /d C:\

powershell -Command "$ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri 'https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip' -OutFile 'flutter.zip'; Expand-Archive -Path 'flutter.zip' -DestinationPath '.' -Force; Remove-Item 'flutter.zip'"

echo Flutter installed.
set FLUTTER=C:\flutter\bin\flutter.bat

:build
cd /d "%~dp0"

echo Building APK...
%FLUTTER% clean
%FLUTTER% pub get
%FLUTTER% build apk --release

:: Create output
mkdir APK 2>nul
copy "build\app\outputs\flutter-apk\app-release.apk" "APK\NanoAI.apk"

echo.
echo APK ready: APK\NanoAI.apk
echo.
echo Installation:
echo 1. Copy NanoAI.apk to Android device
echo 2. Enable Unknown Sources in Android settings
echo 3. Install APK
echo.

start APK
pause
