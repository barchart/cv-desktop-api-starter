@echo off
setlocal
cd /d "%~dp0"

echo === OpenFeed Go Starter Setup ===
echo.

where go >nul 2>nul
if errorlevel 1 (
  echo ERROR: Go is not installed.
  echo Download it from: https://go.dev/dl/
  echo Then re-run this script.
  pause
  exit /b 1
)
go version

echo.
echo Downloading dependencies...
if not exist my-scripts mkdir my-scripts
call go mod download

echo.
if exist "%~dp0..\bin\cvdesk.cmd" (
  echo Adding the cvdesk command to your PATH...
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\scripts\add-to-path.ps1"
) else (
  echo To get the cvdesk command, update the whole project once with ..\update.bat,
  echo then run this setup again.
)

echo.
echo Setup complete!
echo To run the starter guide, open a new PowerShell window and run:
echo   cvdesk start-guide.go
echo Put your own scripts in the my-scripts folder. To get the newest version
echo of this project later, run: cvdesk update
rem Run by the setup.bat at the top of the project, which pauses once at the end.
if not defined CVDESK_SETUP_FROM_TOP pause
exit /b 0
