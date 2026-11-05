@echo off
setlocal enabledelayedexpansion

echo ========================================================
echo     29 Card Game - Automatic Android APK Builder
echo ========================================================
echo.

where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Flutter SDK is not detected in your system PATH.
    echo.
    echo To build the Android APK on your machine:
    echo 1. Download Flutter SDK from https://docs.flutter.dev/get-started/install/windows
    echo 2. Extract to C:\flutter and add C:\flutter\bin to your Environment PATH.
    echo 3. Make sure Android Studio / Android Command Line Tools are installed.
    echo 4. Run this script again!
    echo.
    echo TIP: You can also push this project to GitHub! The included GitHub Actions
    echo workflow (.github/workflows/build_apk.yml) will build the APK automatically in 2 minutes.
    echo.
    pause
    exit /b 1
)

echo [1/3] Fetching Flutter dependencies...
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] flutter pub get failed.
    pause
    exit /b 1
)

echo.
echo [2/3] Compiling Release APK...
call flutter build apk --release
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] flutter build apk failed.
    pause
    exit /b 1
)

echo.
echo [3/3] Success! APK built at:
echo build\app\outputs\flutter-apk\app-release.apk
echo.
explorer build\app\outputs\flutter-apk\
pause
