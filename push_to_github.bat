@echo off
setlocal

set "GIT=C:\Users\faysal\.gemini\antigravity\scratch\mingit\cmd\git.exe"
set "GH=C:\Users\faysal\.gemini\antigravity\scratch\gh\bin\gh.exe"

cd /d "C:\Users\faysal\.gemini\antigravity\scratch\twenty_nine_card_game"

echo ==========================================================
echo         29 Card Game - Push to GitHub Helper
echo ==========================================================
echo.
echo Choose an option:
echo 1. I already created a repo on GitHub (e.g. https://github.com/user/repo.git)
echo 2. Login with GitHub CLI and create a new repository automatically
echo.

set /p CHOICE="Enter choice (1 or 2): "

if "%CHOICE%"=="1" (
    set /p REPO_URL="Enter your GitHub repository URL: "
    "%GIT%" remote remove origin 2>nul
    "%GIT%" remote add origin !REPO_URL!
    "%GIT%" branch -M main
    echo.
    echo Pushing code to GitHub...
    "%GIT%" push -u origin main
    echo.
    echo Done! Check GitHub Actions tab to download your APK!
) else if "%CHOICE%"=="2" (
    echo.
    echo Starting GitHub CLI login...
    "%GH%" auth login
    echo.
    echo Creating GitHub repository and pushing...
    "%GH%" repo create twenty-nine-card-game --public --source=. --remote=origin --push
    echo.
    echo Done! Your code is now live on GitHub with automatic APK building!
) else (
    echo Invalid choice.
)

pause
