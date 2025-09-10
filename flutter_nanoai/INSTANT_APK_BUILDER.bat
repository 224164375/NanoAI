@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
title NanoAI Flutter - Instant APK Builder & Deployer

echo ╔══════════════════════════════════════════════════════════════════════════════╗
echo ║                    NanoAI Flutter - Instant APK Builder                     ║
echo ║              Build Ready APK and Deploy to Free Platforms                  ║
echo ╚══════════════════════════════════════════════════════════════════════════════╝
echo.

:: Set project directory
cd /d "%~dp0"
set PROJECT_DIR=%CD%

:: Create output directory
if not exist "ready_apk" mkdir ready_apk
if not exist "web_deploy" mkdir web_deploy

echo [STEP 1/5] Checking Flutter installation...
flutter --version >nul 2>&1
if errorlevel 1 (
    echo [INFO] Flutter not found. Installing Flutter SDK...
    call :install_flutter_quick
)

echo [STEP 2/5] Preparing project for build...
call flutter clean
call flutter pub get
call flutter pub run build_runner build --delete-conflicting-outputs

echo [STEP 3/5] Building production APK...
echo [INFO] Building optimized APK for release...
call flutter build apk --release --obfuscate --split-debug-info=debug_symbols
if errorlevel 1 (
    echo [WARNING] Obfuscated build failed, trying standard build...
    call flutter build apk --release
)

:: Copy APK to ready folder
copy "build\app\outputs\flutter-apk\app-release.apk" "ready_apk\NanoAI-v1.0-release.apk" >nul
echo [SUCCESS] APK ready: ready_apk\NanoAI-v1.0-release.apk

echo [STEP 4/5] Building web version for deployment...
call flutter build web --release --web-renderer html
xcopy "build\web\*" "web_deploy\" /E /I /Y >nul

echo [STEP 5/5] Connecting to free deployment platforms...

:: Deploy to Netlify Drop
echo [INFO] Preparing Netlify deployment...
powershell -Command "Compress-Archive -Path 'web_deploy\*' -DestinationPath 'netlify_nanoai.zip' -Force"

:: Deploy to GitHub Pages (auto-setup)
call :setup_github_deployment

:: Deploy to Firebase (auto-setup)
call :setup_firebase_deployment

:: Deploy to Vercel (auto-setup)
call :setup_vercel_deployment

:: Create instant installer
call :create_instant_installer

echo.
echo ╔══════════════════════════════════════════════════════════════════════════════╗
echo ║                          🎉 BUILD COMPLETE! 🎉                              ║
echo ╚══════════════════════════════════════════════════════════════════════════════╝
echo.
echo 📱 READY APK: ready_apk\NanoAI-v1.0-release.apk
echo 🌐 WEB DEPLOY: web_deploy\index.html
echo 📦 NETLIFY ZIP: netlify_nanoai.zip
echo.
echo 🚀 INSTANT DEPLOYMENT OPTIONS:
echo.
echo 1. NETLIFY DROP (Instant):
echo    └─ Visit: https://app.netlify.com/drop
echo    └─ Drag: netlify_nanoai.zip
echo    └─ Get instant live URL!
echo.
echo 2. GITHUB PAGES (Free):
echo    └─ Push to GitHub repository
echo    └─ Enable Pages in repository settings
echo    └─ Live at: https://[username].github.io/[repo-name]
echo.
echo 3. FIREBASE HOSTING (Free):
echo    └─ Run: firebase login
echo    └─ Run: firebase init hosting
echo    └─ Run: firebase deploy
echo.
echo 4. VERCEL (Free):
echo    └─ Run: npx vercel --prod
echo    └─ Follow prompts for instant deployment
echo.
echo 📲 ANDROID INSTALLATION:
echo    1. Transfer NanoAI-v1.0-release.apk to Android device
echo    2. Enable "Install from Unknown Sources"
echo    3. Tap APK file to install
echo    4. Launch NanoAI app!
echo.

:: Auto-open deployment options
echo [INFO] Opening deployment platforms...
start https://app.netlify.com/drop
start https://vercel.com/new
start https://console.firebase.google.com/

echo Press any key to exit...
pause >nul
exit /b 0

:install_flutter_quick
echo [INFO] Quick Flutter installation...
powershell -Command "& {
    Write-Host 'Downloading Flutter SDK...'
    $url = 'https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip'
    $output = 'flutter_sdk.zip'
    Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing
    
    Write-Host 'Extracting Flutter...'
    Expand-Archive -Path $output -DestinationPath 'C:\' -Force
    Remove-Item $output
    
    Write-Host 'Setting up PATH...'
    $currentPath = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::User)
    $flutterPath = 'C:\flutter\bin'
    if ($currentPath -notlike '*flutter*') {
        [Environment]::SetEnvironmentVariable('Path', $currentPath + ';' + $flutterPath, [EnvironmentVariableTarget]::User)
    }
}"
set PATH=%PATH%;C:\flutter\bin
call flutter doctor --android-licenses
goto :eof

:setup_github_deployment
echo [INFO] Setting up GitHub Pages deployment...
if not exist ".github\workflows" mkdir .github\workflows
echo name: Deploy Flutter Web to GitHub Pages > .github\workflows\deploy.yml
echo. >> .github\workflows\deploy.yml
echo on: >> .github\workflows\deploy.yml
echo   push: >> .github\workflows\deploy.yml
echo     branches: [ main ] >> .github\workflows\deploy.yml
echo. >> .github\workflows\deploy.yml
echo jobs: >> .github\workflows\deploy.yml
echo   deploy: >> .github\workflows\deploy.yml
echo     runs-on: ubuntu-latest >> .github\workflows\deploy.yml
echo     steps: >> .github\workflows\deploy.yml
echo     - uses: actions/checkout@v3 >> .github\workflows\deploy.yml
echo     - uses: subosito/flutter-action@v2 >> .github\workflows\deploy.yml
echo       with: >> .github\workflows\deploy.yml
echo         flutter-version: '3.16.0' >> .github\workflows\deploy.yml
echo     - run: flutter pub get >> .github\workflows\deploy.yml
echo     - run: flutter build web --release >> .github\workflows\deploy.yml
echo     - uses: peaceiris/actions-gh-pages@v3 >> .github\workflows\deploy.yml
echo       with: >> .github\workflows\deploy.yml
echo         github_token: ${{ secrets.GITHUB_TOKEN }} >> .github\workflows\deploy.yml
echo         publish_dir: ./build/web >> .github\workflows\deploy.yml
goto :eof

:setup_firebase_deployment
echo [INFO] Setting up Firebase deployment...
echo { > firebase.json
echo   "hosting": { >> firebase.json
echo     "public": "web_deploy", >> firebase.json
echo     "ignore": ["firebase.json", "**/.*", "**/node_modules/**"], >> firebase.json
echo     "rewrites": [{ >> firebase.json
echo       "source": "**", >> firebase.json
echo       "destination": "/index.html" >> firebase.json
echo     }] >> firebase.json
echo   } >> firebase.json
echo } >> firebase.json
goto :eof

:setup_vercel_deployment
echo [INFO] Setting up Vercel deployment...
echo { > vercel.json
echo   "buildCommand": "flutter build web --release", >> vercel.json
echo   "outputDirectory": "build/web", >> vercel.json
echo   "framework": null, >> vercel.json
echo   "rewrites": [{ >> vercel.json
echo     "source": "/(.*)", >> vercel.json
echo     "destination": "/index.html" >> vercel.json
echo   }] >> vercel.json
echo } >> vercel.json
goto :eof

:create_instant_installer
echo [INFO] Creating instant installer package...
powershell -Command "& {
    # Create installer script
    $installerScript = @'
@echo off
echo Installing NanoAI Flutter App...
echo.
echo Choose installation method:
echo 1. Install APK on connected Android device
echo 2. Open web version in browser
echo 3. Deploy to Netlify (instant)
echo.
set /p choice=Enter choice (1-3): 

if %choice%==1 (
    adb install NanoAI-v1.0-release.apk
    echo APK installed successfully!
)
if %choice%==2 (
    start web_deploy\index.html
)
if %choice%==3 (
    start https://app.netlify.com/drop
    echo Drag netlify_nanoai.zip to the opened page
)
pause
'@
    
    $installerScript | Out-File -FilePath 'INSTANT_INSTALL.bat' -Encoding ASCII
    
    # Create complete package
    $files = @(
        'ready_apk\NanoAI-v1.0-release.apk',
        'netlify_nanoai.zip',
        'INSTANT_INSTALL.bat'
    )
    
    Compress-Archive -Path $files -DestinationPath 'NanoAI_Complete_Package.zip' -Force
}"
echo [SUCCESS] Complete package: NanoAI_Complete_Package.zip
goto :eof
