@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo === OpenFeed C# Starter Setup ===
echo.

where dotnet >nul 2>nul
if errorlevel 1 (
  echo ERROR: .NET SDK ^(8.0 or newer^) is not installed.
  echo Download it from: https://dotnet.microsoft.com/download
  echo Then re-run this script.
  pause
  exit /b 1
)
for /f "delims=." %%v in ('dotnet --version') do set DOTNET_MAJOR=%%v
if !DOTNET_MAJOR! lss 8 (
  echo ERROR: .NET SDK found, but 8.0 or newer is required.
  echo Download the latest from: https://dotnet.microsoft.com/download
  pause
  exit /b 1
)
dotnet --version

powershell -NoProfile -ExecutionPolicy Bypass -File "..\setup-env.ps1"

echo.
echo Restoring dependencies...
dotnet restore OpenFeedStartGuide\OpenFeedStartGuide.csproj

echo.
echo Setup complete!
echo To run the starter guide, open a terminal in the csharp folder and run:
echo   dotnet run --project OpenFeedStartGuide
pause
