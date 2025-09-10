@echo off
chcp 65001 >nul
title NanoAI - بناء التطبيق

echo ========================================
echo           NanoAI Flutter Builder
echo ========================================
echo.

cd /d "%~dp0"

:: تحقق من وجود Flutter
if exist "C:\flutter\bin\flutter.bat" (
    echo ✓ Flutter موجود
    goto :build
)

echo تثبيت Flutter...
echo يرجى الانتظار...

:: إنشاء مجلد مؤقت
mkdir temp 2>nul
cd temp

:: تحميل Flutter
echo تحميل Flutter SDK...
powershell -Command "Invoke-WebRequest -Uri 'https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip' -OutFile 'flutter.zip'"

:: استخراج Flutter
echo استخراج الملفات...
powershell -Command "Expand-Archive -Path 'flutter.zip' -DestinationPath 'C:\' -Force"

:: تنظيف
del flutter.zip
cd ..
rmdir /s /q temp

echo ✓ تم تثبيت Flutter بنجاح

:build
cd /d "%~dp0"

:: استخدام Flutter
set FLUTTER_PATH=C:\flutter\bin\flutter.bat

echo بناء التطبيق...
%FLUTTER_PATH% clean
%FLUTTER_PATH% pub get
%FLUTTER_PATH% build apk --release

:: إنشاء مجلد الإخراج
mkdir OUTPUT 2>nul

:: نسخ APK
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy "build\app\outputs\flutter-apk\app-release.apk" "OUTPUT\NanoAI.apk"
    echo.
    echo ========================================
    echo ✓ تم بناء التطبيق بنجاح!
    echo ========================================
    echo.
    echo ملف APK: OUTPUT\NanoAI.apk
    echo.
    echo خطوات التثبيت:
    echo 1. انسخ NanoAI.apk إلى جهاز الأندرويد
    echo 2. فعّل "مصادر غير معروفة" في الإعدادات
    echo 3. اضغط على ملف APK للتثبيت
    echo.
    start OUTPUT
) else (
    echo ✗ فشل في بناء APK
    echo تحقق من الأخطاء أعلاه
)

pause
