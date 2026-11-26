@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo === OpenFeed C# Starter Setup ===
echo.

where dotnet >nul 2>nul
if errorlevel 1 (
  echo ERROR: .NET SDK ^(10 or newer^) is not installed.
  echo Download it from: https://dotnet.microsoft.com/download
  echo Then re-run this script.
  pause
  exit /b 1
)
for /f "delims=." %%v in ('dotnet --version') do set DOTNET_MAJOR=%%v
if !DOTNET_MAJOR! lss 10 (
  echo ERROR: .NET SDK found, but 10 or newer is required.
  echo Download the latest from: https://dotnet.microsoft.com/download
  pause
  exit /b 1
)
dotnet --version

echo.
echo Downloading dependencies and building the starter guide...
if not exist my-scripts mkdir my-scripts
dotnet build examples\start-guide.cs --verbosity quiet --nologo
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
echo   cvdesk start-guide.cs
echo Put your own scripts in the my-scripts folder. To get the newest version
echo of this project later, run: cvdesk update
rem Run by the setup.bat at the top of the project, which pauses once at the end.
if not defined CVDESK_SETUP_FROM_TOP pause
exit /b 0
