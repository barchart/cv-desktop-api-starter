@echo off
setlocal enabledelayedexpansion
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
for /f "tokens=3" %%v in ('java -version 2^>^&1 ^| findstr /i "version"') do set JAVA_VER_RAW=%%v
set JAVA_VER_RAW=!JAVA_VER_RAW:"=!
for /f "delims=. tokens=1,2" %%a in ("!JAVA_VER_RAW!") do (
  set JAVA_MAJOR=%%a
  if "%%a"=="1" set JAVA_MAJOR=%%b
)
if !JAVA_MAJOR! lss 17 (
  echo ERROR: Java !JAVA_VER_RAW! found, but JDK 17 or newer is required.
  echo Download it from: https://adoptium.net/
  pause
  exit /b 1
)
java -version

echo.
if not exist my-scripts mkdir my-scripts
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\dependencies.ps1"
if errorlevel 1 (
  pause
  exit /b 1
)

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
echo   cvdesk StartGuide.java
echo Put your own scripts in the my-scripts folder. To get the newest version
echo of this project later, run: cvdesk update
rem Run by the setup.bat at the top of the project, which pauses once at the end.
if not defined CVDESK_SETUP_FROM_TOP pause
exit /b 0
