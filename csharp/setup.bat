@echo off
setlocal
cd /d "%~dp0"

echo === OpenFeed C# Starter Setup ===
echo.

where dotnet >nul 2>nul
if errorlevel 1 (
  echo ERROR: .NET SDK ^(10.0 or newer^) is not installed.
  echo Download it from: https://dotnet.microsoft.com/download
  echo Then re-run this script.
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
echo To run the starter guide, open a terminal in the csharp\OpenFeedStartGuide folder and run:
echo   dotnet run
pause
