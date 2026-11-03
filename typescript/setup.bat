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

echo.
echo Installing dependencies...
call npm install --no-fund --no-audit --loglevel=error

echo.
echo Creating a command for each script in src/...
call npm run --silent install-commands

echo.
echo Setup complete!
echo To run the starter guide, open a new PowerShell window and run:
echo   start-guide-run
pause
