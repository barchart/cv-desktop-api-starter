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
echo Checking for the latest @barchart/desktop-sdk-js...
set SDK=@barchart/desktop-sdk-js
for /f %%v in ('node -p "require('./node_modules/%SDK%/package.json').version"') do set CURRENT=%%v
set LATEST=
for /f %%v in ('call npm view %SDK% version 2^>nul') do set LATEST=%%v
if "%LATEST%"=="" (
  echo Could not reach the npm registry, keeping version %CURRENT%.
) else if "%CURRENT%"=="%LATEST%" (
  echo Up to date ^(%CURRENT%^).
) else (
  echo Updating %CURRENT% -^> %LATEST%...
  call npm install %SDK%@latest --no-fund --no-audit --loglevel=error
)

echo.
echo Adding the cvdesk command to your PATH...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\add-to-path.ps1"

echo.
echo Setup complete!
echo To run the starter guide, open a new PowerShell window and run:
echo   cvdesk start-guide
pause
