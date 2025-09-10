@echo off
chcp 65001 >nul
title NanoAI - بناء أونلاين

echo ========================================
echo        NanoAI - حلول البناء الأونلاين
echo ========================================
echo.

echo إذا كانت السكريبتات لا تعمل، استخدم هذه الحلول:
echo.

echo 🌐 الحل الأول: FlutLab (مجاني)
echo --------------------------------
echo 1. اذهب إلى: https://flutlab.io
echo 2. أنشئ حساب مجاني
echo 3. ارفع مجلد المشروع (flutter_nanoai)
echo 4. اضغط Build APK
echo 5. حمّل APK جاهز للتثبيت
echo.

echo 🚀 الحل الثاني: Codemagic (مجاني)
echo ----------------------------------
echo 1. اذهب إلى: https://codemagic.io
echo 2. ربط مع GitHub
echo 3. ارفع المشروع
echo 4. بناء تلقائي مجاني
echo.

echo 📱 الحل الثالث: AppFlow (Ionic)
echo --------------------------------
echo 1. اذهب إلى: https://ionic.io/appflow
echo 2. ارفع المشروع
echo 3. بناء مجاني شهرياً
echo.

echo 🔧 الحل الرابع: GitHub Actions
echo -------------------------------
echo 1. ارفع المشروع إلى GitHub
echo 2. سيبني تلقائياً
echo 3. حمّل APK من Releases
echo.

echo 💻 الحل الخامس: Gitpod (أونلاين)
echo ---------------------------------
echo 1. اذهب إلى: https://gitpod.io
echo 2. افتح المشروع
echo 3. شغّل: flutter build apk
echo 4. حمّل APK
echo.

echo.
echo اختر أي حل يناسبك وستحصل على APK جاهز!
echo.

echo فتح المواقع...
start https://flutlab.io
timeout /t 2 >nul
start https://codemagic.io
timeout /t 2 >nul
start https://ionic.io/appflow

pause
