@echo off
title NanoAI Manual Build

echo NanoAI Flutter - دليل البناء اليدوي
echo =====================================

echo.
echo الخطوة 1: تثبيت Flutter يدوياً
echo --------------------------------
echo 1. اذهب إلى: https://docs.flutter.dev/get-started/install/windows
echo 2. حمّل Flutter SDK
echo 3. استخرج إلى C:\flutter
echo 4. أضف C:\flutter\bin إلى PATH
echo.

echo الخطوة 2: بناء التطبيق
echo ----------------------
echo افتح Command Prompt في هذا المجلد وشغّل:
echo.
echo flutter clean
echo flutter pub get  
echo flutter build apk --release
echo.

echo الخطوة 3: العثور على APK
echo -------------------------
echo ستجد APK في:
echo build\app\outputs\flutter-apk\app-release.apk
echo.

echo الخطوة 4: التثبيت على الأندرويد
echo --------------------------------
echo 1. انسخ app-release.apk إلى جهازك
echo 2. فعّل "مصادر غير معروفة" في الإعدادات
echo 3. اضغط على APK للتثبيت
echo.

echo بديل سريع - استخدم الموقع:
echo https://flutlab.io
echo ارفع المشروع واحصل على APK مباشرة
echo.

pause
