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

powershell -NoProfile -ExecutionPolicy Bypass -File "..\setup-env.ps1"

echo.
echo Downloading dependencies and compiling the project (this may take a minute)...
call mvnw.cmd -q compile

echo.
echo Setup complete!
echo To run the starter guide, open a terminal in the java folder and run:
echo   mvnw.cmd -q compile exec:java
pause
