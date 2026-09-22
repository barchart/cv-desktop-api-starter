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

powershell -NoProfile -ExecutionPolicy Bypass -File "..\setup-env.ps1"

echo.
echo Downloading dependencies...
call go mod download

echo.
echo Setup complete!
echo To run the starter guide, open a terminal in the go folder and run:
echo   go run ./cmd/start-guide
pause
