@echo off
setlocal
cd /d "%~dp0"

echo === OpenFeed TypeScript Starter Setup ===
echo.

where node >nul 2>nul
if errorlevel 1 (
  echo ERROR: Node.js is not installed.
  echo Download it from: https://nodejs.org/ ^(LTS version^)
  echo Or install it with a version manager, e.g.:
  echo   fnm: https://github.com/Schniz/fnm  ^(then: fnm install --lts^)
  echo   nvm-windows: https://github.com/coreybutler/nvm-windows  ^(then: nvm install lts^)
  echo Then re-run this script.
  pause
  exit /b 1
)
for /f %%v in ('node -p "process.versions.node.split('.')[0]"') do set NODE_MAJOR=%%v
if %NODE_MAJOR% LSS 22 (
  echo ERROR: Node.js 22 or newer is required.
  node --version
  echo Download it from: https://nodejs.org/ ^(LTS version^)
  echo Or install it with a version manager, e.g.:
  echo   fnm: https://github.com/Schniz/fnm  ^(then: fnm install --lts^)
  echo   nvm-windows: https://github.com/coreybutler/nvm-windows  ^(then: nvm install lts^)
  echo Then re-run this script.
  pause
  exit /b 1
)
node --version

node "%~dp0scripts\project-setup.mjs"
if errorlevel 1 (
  pause
  exit /b 1
)

echo.
echo Adding the cvdesk command to your PATH...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\add-to-path.ps1"

echo.
echo Setup complete!
echo To run the starter guide, open a new PowerShell window and run:
echo   cvdesk start-guide
echo Put your own scripts in the my-scripts folder. To get the newest version
echo of this project later, run: cvdesk update
pause
