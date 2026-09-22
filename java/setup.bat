@echo off
setlocal
cd /d "%~dp0"

echo === OpenFeed Java Starter Setup ===
echo.

where java >nul 2>nul
if errorlevel 1 (
  echo ERROR: Java ^(JDK 17 or newer^) is not installed.
  echo Download it from: https://adoptium.net/
  echo Then re-run this script.
  pause
  exit /b 1
)
java -version

powershell -NoProfile -ExecutionPolicy Bypass -File "..\setup-env.ps1"

echo.
echo Downloading dependencies and building the project (this may take a minute)...
call mvnw.cmd -q package

echo.
echo Setup complete!
echo To run the starter guide, open a terminal in the java folder and run:
echo   java -jar target\openfeed-client-1.0.0-jar-with-dependencies.jar
pause
