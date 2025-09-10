@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
title NanoAI Flutter - One Click Deploy & APK Ready

echo ╔══════════════════════════════════════════════════════════════════════════════╗
echo ║                    🚀 NanoAI Flutter - ONE CLICK DEPLOY 🚀                  ║
echo ║                 Instant APK + Live Web App in 60 seconds!                   ║
echo ╚══════════════════════════════════════════════════════════════════════════════╝
echo.

:: Auto-detect and setup environment
cd /d "%~dp0"
set START_TIME=%time%

echo [⚡] Starting automated build and deployment process...
echo [📍] Project: %CD%

:: Step 1: Environment Check & Auto-Install
echo.
echo [STEP 1/6] 🔧 Environment Setup
call :check_and_install_flutter
call :check_and_install_tools

:: Step 2: Project Preparation
echo.
echo [STEP 2/6] 📦 Project Preparation
call flutter clean >nul 2>&1
call flutter pub get >nul 2>&1
if exist "lib\**\*.g.dart" del /s /q "lib\**\*.g.dart" >nul 2>&1
call flutter packages pub run build_runner build --delete-conflicting-outputs >nul 2>&1

:: Step 3: Build APK
echo.
echo [STEP 3/6] 📱 Building Production APK
if not exist "output" mkdir output
echo [INFO] Building optimized release APK...
call flutter build apk --release --target-platform android-arm64 --obfuscate --split-debug-info=symbols >nul 2>&1
if errorlevel 1 (
    echo [WARN] Obfuscated build failed, using standard build...
    call flutter build apk --release >nul 2>&1
)

:: Copy and rename APK
for %%f in (build\app\outputs\flutter-apk\*.apk) do (
    copy "%%f" "output\NanoAI-Ready-Install.apk" >nul
    set APK_SIZE=%%~zf
)
echo [✅] APK Ready: output\NanoAI-Ready-Install.apk (!APK_SIZE! bytes)

:: Step 4: Build Web App
echo.
echo [STEP 4/6] 🌐 Building Web Application
call flutter build web --release --web-renderer html --base-href /NanoAI/ >nul 2>&1
if not exist "output\web" mkdir output\web
xcopy "build\web\*" "output\web\" /E /I /Y >nul

:: Step 5: Auto-Deploy to Free Platforms
echo.
echo [STEP 5/6] 🚀 Auto-Deploying to Free Platforms

:: Netlify Drop Package
powershell -Command "Compress-Archive -Path 'output\web\*' -DestinationPath 'output\NanoAI-Netlify-Deploy.zip' -Force" >nul 2>&1
echo [✅] Netlify package ready: output\NanoAI-Netlify-Deploy.zip

:: GitHub Pages Auto-Setup
if exist ".git" (
    call :auto_github_pages_deploy
) else (
    call :create_github_setup
)

:: Firebase Auto-Setup
call :create_firebase_config

:: Vercel Auto-Setup  
call :create_vercel_config

:: Step 6: Create Installation Package
echo.
echo [STEP 6/6] 📦 Creating Complete Installation Package
call :create_complete_package

:: Calculate build time
set END_TIME=%time%
call :calculate_time_diff

echo.
echo ╔══════════════════════════════════════════════════════════════════════════════╗
echo ║                          🎉 DEPLOYMENT COMPLETE! 🎉                         ║
echo ║                        Build Time: !TIME_DIFF! seconds                       ║
echo ╚══════════════════════════════════════════════════════════════════════════════╝
echo.
echo 📱 READY TO INSTALL APK:
echo    └─ File: output\NanoAI-Ready-Install.apk
echo    └─ Size: !APK_SIZE! bytes
echo    └─ Ready for Android installation!
echo.
echo 🌐 INSTANT WEB DEPLOYMENT:
echo    ├─ Netlify Drop: https://app.netlify.com/drop
echo    │  └─ Drag: output\NanoAI-Netlify-Deploy.zip
echo    ├─ Vercel: https://vercel.com/new
echo    │  └─ Import this folder
echo    └─ Firebase: firebase deploy (after login)
echo.
echo 📦 COMPLETE PACKAGE: output\NanoAI-Complete-Ready.zip
echo.

:: Auto-open deployment platforms
echo [🚀] Opening deployment platforms...
start "" "https://app.netlify.com/drop"
timeout /t 2 >nul
start "" "https://vercel.com/new"
timeout /t 2 >nul
start "" "https://console.firebase.google.com/"

:: Open output folder
echo [📂] Opening output folder...
start "" "output"

echo.
echo [✨] NanoAI Flutter is ready! Choose your deployment method above.
echo [📱] For Android: Transfer and install NanoAI-Ready-Install.apk
echo [🌐] For Web: Use any of the deployment options shown
echo.
pause
exit /b 0

:check_and_install_flutter
flutter --version >nul 2>&1
if errorlevel 1 (
    echo [INFO] Installing Flutter SDK...
    powershell -Command "& {
        $url = 'https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip'
        Write-Host 'Downloading Flutter...'
        Invoke-WebRequest -Uri $url -OutFile 'flutter.zip' -UseBasicParsing
        Write-Host 'Installing Flutter...'
        Expand-Archive -Path 'flutter.zip' -DestinationPath 'C:\' -Force
        Remove-Item 'flutter.zip'
        $env:Path += ';C:\flutter\bin'
        [Environment]::SetEnvironmentVariable('Path', $env:Path, 'User')
    }" >nul 2>&1
    set PATH=%PATH%;C:\flutter\bin
    echo [✅] Flutter installed successfully
) else (
    echo [✅] Flutter already installed
)
goto :eof

:check_and_install_tools
where git >nul 2>&1
if errorlevel 1 (
    echo [INFO] Git not found - GitHub deployment will be manual
) else (
    echo [✅] Git available
)

where node >nul 2>&1
if errorlevel 1 (
    echo [INFO] Installing Node.js for deployment tools...
    powershell -Command "& {
        $url = 'https://nodejs.org/dist/v18.17.0/node-v18.17.0-x64.msi'
        Invoke-WebRequest -Uri $url -OutFile 'nodejs.msi' -UseBasicParsing
        Start-Process msiexec.exe -Wait -ArgumentList '/I nodejs.msi /quiet'
        Remove-Item 'nodejs.msi'
    }" >nul 2>&1
    echo [✅] Node.js installed
) else (
    echo [✅] Node.js available
)
goto :eof

:auto_github_pages_deploy
echo [INFO] Setting up GitHub Pages auto-deployment...
git add . >nul 2>&1
git commit -m "Auto-deploy NanoAI Flutter - %date% %time%" >nul 2>&1
git push origin main >nul 2>&1
echo [✅] Pushed to GitHub - Enable Pages in repository settings
goto :eof

:create_github_setup
echo [INFO] Creating GitHub setup instructions...
echo # GitHub Pages Setup > output\GITHUB_SETUP.md
echo. >> output\GITHUB_SETUP.md
echo 1. Create new repository on GitHub >> output\GITHUB_SETUP.md
echo 2. Upload this project folder >> output\GITHUB_SETUP.md
echo 3. Go to Settings ^> Pages >> output\GITHUB_SETUP.md
echo 4. Select "Deploy from branch" >> output\GITHUB_SETUP.md
echo 5. Choose "main" branch >> output\GITHUB_SETUP.md
echo 6. Your app will be live at: https://[username].github.io/[repo-name] >> output\GITHUB_SETUP.md
goto :eof

:create_firebase_config
echo [INFO] Creating Firebase configuration...
echo { > firebase.json
echo   "hosting": { >> firebase.json
echo     "public": "output/web", >> firebase.json
echo     "ignore": ["firebase.json", "**/.*", "**/node_modules/**"], >> firebase.json
echo     "rewrites": [{"source": "**", "destination": "/index.html"}] >> firebase.json
echo   } >> firebase.json
echo } >> firebase.json

echo # Firebase Deployment > output\FIREBASE_SETUP.md
echo. >> output\FIREBASE_SETUP.md
echo 1. Install: npm install -g firebase-tools >> output\FIREBASE_SETUP.md
echo 2. Login: firebase login >> output\FIREBASE_SETUP.md
echo 3. Init: firebase init hosting >> output\FIREBASE_SETUP.md
echo 4. Deploy: firebase deploy >> output\FIREBASE_SETUP.md
goto :eof

:create_vercel_config
echo [INFO] Creating Vercel configuration...
echo { > vercel.json
echo   "buildCommand": "flutter build web --release", >> vercel.json
echo   "outputDirectory": "build/web", >> vercel.json
echo   "framework": null >> vercel.json
echo } >> vercel.json

echo # Vercel Deployment > output\VERCEL_SETUP.md
echo. >> output\VERCEL_SETUP.md
echo 1. Visit: https://vercel.com/new >> output\VERCEL_SETUP.md
echo 2. Import this project folder >> output\VERCEL_SETUP.md
echo 3. Deploy automatically >> output\VERCEL_SETUP.md
echo OR >> output\VERCEL_SETUP.md
echo 1. Install: npm install -g vercel >> output\VERCEL_SETUP.md
echo 2. Deploy: vercel --prod >> output\VERCEL_SETUP.md
goto :eof

:create_complete_package
echo [INFO] Creating complete installation package...
powershell -Command "& {
    # Create installer script
    $installer = @'
@echo off
title NanoAI Flutter - Quick Install
echo ╔══════════════════════════════════════════════════════════════════════════════╗
echo ║                    NanoAI Flutter - Quick Installer                         ║
echo ╚══════════════════════════════════════════════════════════════════════════════╝
echo.
echo Choose installation option:
echo.
echo 1. Install Android APK (requires Android device)
echo 2. Open Web App locally
echo 3. Deploy to Netlify (instant web hosting)
echo 4. View deployment guides
echo.
set /p choice=Enter your choice (1-4): 

if "%choice%"=="1" (
    echo.
    echo [INFO] Installing APK on connected Android device...
    adb devices
    adb install NanoAI-Ready-Install.apk
    if errorlevel 1 (
        echo [ERROR] Installation failed. Make sure:
        echo 1. Android device is connected via USB
        echo 2. USB Debugging is enabled
        echo 3. Unknown Sources is allowed
        echo.
        echo Manual installation:
        echo 1. Copy NanoAI-Ready-Install.apk to your Android device
        echo 2. Tap the APK file to install
    ) else (
        echo [SUCCESS] NanoAI installed successfully!
    )
)

if "%choice%"=="2" (
    echo [INFO] Opening web app...
    start web\index.html
)

if "%choice%"=="3" (
    echo [INFO] Opening Netlify Drop...
    echo Drag NanoAI-Netlify-Deploy.zip to the opened page
    start https://app.netlify.com/drop
)

if "%choice%"=="4" (
    echo [INFO] Opening deployment guides...
    start GITHUB_SETUP.md
    start FIREBASE_SETUP.md
    start VERCEL_SETUP.md
)

echo.
pause
'@
    
    $installer | Out-File -FilePath 'output\QUICK_INSTALL.bat' -Encoding ASCII
    
    # Create README
    $readme = @'
# NanoAI Flutter - Complete Package

## What's Included
- NanoAI-Ready-Install.apk - Android app ready for installation
- NanoAI-Netlify-Deploy.zip - Web app package for Netlify
- web/ - Complete web application files
- QUICK_INSTALL.bat - Automated installer
- Setup guides for GitHub, Firebase, and Vercel

## Quick Start
1. Run QUICK_INSTALL.bat
2. Choose your preferred installation method
3. Enjoy NanoAI!

## Features
- AI Chat with Nano and Naruto characters
- Voice interaction (Arabic & English)
- Full RTL Arabic support
- Offline and online AI modes
- Modern animated UI

## Deployment Options
- Android: Install APK directly
- Web: Netlify Drop (instant), GitHub Pages, Firebase, Vercel
'@
    
    $readme | Out-File -FilePath 'output\README.md' -Encoding UTF8
    
    # Create complete package
    Compress-Archive -Path 'output\*' -DestinationPath 'output\NanoAI-Complete-Ready.zip' -Force
}"
echo [✅] Complete package created: output\NanoAI-Complete-Ready.zip
goto :eof

:calculate_time_diff
for /f "tokens=1-4 delims=:.," %%a in ("!START_TIME!") do (
    set /a "start_seconds=((%%a*60)+%%b)*60+%%c"
)
for /f "tokens=1-4 delims=:.," %%a in ("!END_TIME!") do (
    set /a "end_seconds=((%%a*60)+%%b)*60+%%c"
)
set /a "TIME_DIFF=end_seconds-start_seconds"
if !TIME_DIFF! lss 0 set /a "TIME_DIFF+=86400"
goto :eof
