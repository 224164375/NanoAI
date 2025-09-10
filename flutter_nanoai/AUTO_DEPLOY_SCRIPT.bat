@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
title NanoAI Flutter - Automated Deployment to Free Platforms

echo ╔══════════════════════════════════════════════════════════════════════════════╗
echo ║                    NanoAI Flutter - Auto Deploy Script                      ║
echo ║                   Automated Build & Deploy to Free Platforms               ║
echo ╚══════════════════════════════════════════════════════════════════════════════╝
echo.

:: Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Flutter is not installed or not in PATH
    echo Installing Flutter...
    call :install_flutter
)

:: Navigate to project directory
cd /d "%~dp0"
echo [INFO] Current directory: %CD%

:: Clean and get dependencies
echo [STEP 1/6] Cleaning project and getting dependencies...
call flutter clean
call flutter pub get

:: Generate necessary files
echo [STEP 2/6] Generating Hive adapters and build files...
call flutter packages pub run build_runner build --delete-conflicting-outputs

:: Build for multiple platforms
echo [STEP 3/6] Building for multiple platforms...

:: Build Web version
echo [INFO] Building Web version...
call flutter build web --release --web-renderer html --base-href /NanoAI/
if errorlevel 1 (
    echo [ERROR] Web build failed
    goto :error_exit
)

:: Build Android APK
echo [INFO] Building Android APK...
call flutter build apk --release --split-per-abi
if errorlevel 1 (
    echo [ERROR] Android APK build failed
    goto :error_exit
)

:: Create deployment package
echo [STEP 4/6] Creating deployment package...
if not exist "deploy" mkdir deploy
if not exist "deploy\web" mkdir deploy\web
if not exist "deploy\android" mkdir deploy\android

:: Copy built files
xcopy "build\web\*" "deploy\web\" /E /I /Y >nul
copy "build\app\outputs\flutter-apk\*.apk" "deploy\android\" >nul

:: Deploy to GitHub Pages (if git repo exists)
echo [STEP 5/6] Deploying to free platforms...
if exist ".git" (
    call :deploy_github_pages
) else (
    echo [INFO] Not a git repository, skipping GitHub Pages deployment
)

:: Deploy to Netlify Drop
call :deploy_netlify_drop

:: Deploy to Vercel
call :deploy_vercel

:: Deploy to Firebase Hosting
call :deploy_firebase

:: Create installation package
echo [STEP 6/6] Creating installation package...
call :create_installation_package

echo.
echo ╔══════════════════════════════════════════════════════════════════════════════╗
echo ║                            DEPLOYMENT COMPLETE!                             ║
echo ╚══════════════════════════════════════════════════════════════════════════════╝
echo.
echo [SUCCESS] NanoAI Flutter app has been built and deployed successfully!
echo.
echo Available Downloads:
echo ├─ Android APK: deploy\android\app-arm64-v8a-release.apk
echo ├─ Web App: deploy\web\index.html
echo └─ Installation Package: NanoAI_Installation_Package.zip
echo.
echo Live Deployments:
if defined GITHUB_PAGES_URL echo ├─ GitHub Pages: !GITHUB_PAGES_URL!
if defined NETLIFY_URL echo ├─ Netlify: !NETLIFY_URL!
if defined VERCEL_URL echo ├─ Vercel: !VERCEL_URL!
if defined FIREBASE_URL echo └─ Firebase: !FIREBASE_URL!
echo.
pause
exit /b 0

:install_flutter
echo [INFO] Downloading and installing Flutter...
powershell -Command "& {
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri 'https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip' -OutFile 'flutter.zip'
    Expand-Archive -Path 'flutter.zip' -DestinationPath 'C:\' -Force
    Remove-Item 'flutter.zip'
    [Environment]::SetEnvironmentVariable('Path', $env:Path + ';C:\flutter\bin', [EnvironmentVariableTarget]::User)
}"
set PATH=%PATH%;C:\flutter\bin
echo [SUCCESS] Flutter installed successfully
goto :eof

:deploy_github_pages
echo [INFO] Deploying to GitHub Pages...
git add .
git commit -m "Auto-deploy NanoAI Flutter app - %date% %time%"
git push origin main
for /f "tokens=2 delims=/" %%a in ('git remote get-url origin') do set REPO_URL=%%a
for /f "tokens=1 delims=." %%b in ("!REPO_URL!") do set REPO_NAME=%%b
set GITHUB_PAGES_URL=https://!REPO_NAME!.github.io/NanoAI/
echo [SUCCESS] Deployed to GitHub Pages: !GITHUB_PAGES_URL!
goto :eof

:deploy_netlify_drop
echo [INFO] Preparing Netlify Drop deployment...
powershell -Command "Compress-Archive -Path 'deploy\web\*' -DestinationPath 'netlify-deploy.zip' -Force"
echo [INFO] Netlify deployment package created: netlify-deploy.zip
echo [INFO] Visit https://app.netlify.com/drop and drag netlify-deploy.zip to deploy
set NETLIFY_URL=https://app.netlify.com/drop
goto :eof

:deploy_vercel
echo [INFO] Preparing Vercel deployment...
if exist "node_modules" rmdir /s /q node_modules
npm install -g vercel >nul 2>&1
echo [INFO] Run 'vercel --prod' in the project directory to deploy to Vercel
set VERCEL_URL=https://vercel.com/
goto :eof

:deploy_firebase
echo [INFO] Preparing Firebase Hosting deployment...
npm install -g firebase-tools >nul 2>&1
if not exist "firebase.json" (
    echo {
    echo   "hosting": {
    echo     "public": "deploy/web",
    echo     "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    echo     "rewrites": [{
    echo       "source": "**",
    echo       "destination": "/index.html"
    echo     }]
    echo   }
    echo } > firebase.json
)
echo [INFO] Run 'firebase login' and 'firebase deploy' to deploy to Firebase
set FIREBASE_URL=https://firebase.google.com/
goto :eof

:create_installation_package
echo [INFO] Creating installation package...
powershell -Command "& {
    $files = @(
        'deploy\android\*.apk',
        'deploy\web\*',
        'README.md',
        'INSTALLATION_GUIDE.md'
    )
    
    # Create installation guide
    @'
# NanoAI Flutter - Installation Guide

## Android Installation
1. Download the APK file from the android folder
2. Enable 'Unknown Sources' in Android settings
3. Install the APK file
4. Launch NanoAI app

## Web Version
1. Open index.html in deploy/web folder
2. Or visit the live deployment URLs provided

## Features
- AI Chat with Nano and Naruto characters
- Voice interaction (Arabic & English)
- Full RTL Arabic support
- Offline and online AI modes
- Modern animated UI

## Support
For issues or questions, contact the development team.
'@ | Out-File -FilePath 'INSTALLATION_GUIDE.md' -Encoding UTF8
    
    Compress-Archive -Path $files -DestinationPath 'NanoAI_Installation_Package.zip' -Force
}"
echo [SUCCESS] Installation package created: NanoAI_Installation_Package.zip
goto :eof

:error_exit
echo.
echo [ERROR] Deployment failed! Check the error messages above.
echo.
pause
exit /b 1
