@echo off
setlocal
cd /d "%~dp0"

echo === OpenFeed TypeScript Starter Setup ===
echo.

where node >nul 2>nul
if errorlevel 1 (
  echo ERROR: Node.js is not installed.
  echo Download it from: https://nodejs.org/ ^(LTS version^)
  echo Then re-run this script.
  pause
  exit /b 1
)
node --version

powershell -NoProfile -ExecutionPolicy Bypass -File "..\setup-env.ps1"

echo.
echo Installing dependencies...
call npm install --no-fund --no-audit --loglevel=error

echo.
echo Setup complete!
echo To run the starter guide, open a terminal in the typescript folder and run:
echo   npm start
pause
