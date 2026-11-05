@echo off
setlocal enabledelayedexpansion

set "PATH=C:\Users\faysal\.gemini\antigravity\scratch\mingit\ucrt64\bin;C:\Users\faysal\.gemini\antigravity\scratch\mingit\cmd;C:\Users\faysal\.gemini\antigravity\scratch\gh\bin;%PATH%"

cd /d "C:\Users\faysal\.gemini\antigravity\scratch\twenty_nine_card_game"

echo ==========================================================
echo       29 Card Game - Push to github.com/zodf3/Game
echo ==========================================================
echo.
echo Your repository remote is set to:
echo   https://github.com/zodf3/Game.git
echo.
echo Choose authentication method:
echo   [1] Enter GitHub Personal Access Token (Fastest, 1-step push)
echo   [2] Login via Browser using GitHub CLI
echo.
set /p AUTH_CHOICE="Enter 1 or 2 (default is 1): "

if "%AUTH_CHOICE%"=="2" (
    echo.
    echo Logging in with GitHub CLI...
    gh auth login -h github.com -p https -w
    echo.
    echo Pushing code to main branch...
    git push -u origin main
) else (
    echo.
    echo If you don't have a token, generate one at:
    echo   https://github.com/settings/tokens/new?scopes=repo
    echo.
    set /p GH_TOKEN="Paste your GitHub Token here: "
    if "!GH_TOKEN!"=="" (
        echo No token entered. Exiting.
        pause
        exit /b 1
    )
    echo.
    echo Pushing to https://github.com/zodf3/Game.git...
    git push -u https://!GH_TOKEN!@github.com/zodf3/Game.git main
)

echo.
if %ERRORLEVEL% EQU 0 (
    echo ==========================================================
    echo [SUCCESS] Code successfully pushed to GitHub!
    echo.
    echo GitHub Actions will now automatically compile your APK:
    echo Check progress at: https://github.com/zodf3/Game/actions
    echo ==========================================================
) else (
    echo [ERROR] Push failed. Please check your credentials or permissions.
)

pause
