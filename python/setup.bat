@echo off
setlocal
cd /d "%~dp0"

echo === OpenFeed Python Starter Setup ===
echo.

where python >nul 2>nul
if errorlevel 1 (
  echo ERROR: Python is not installed.
  echo Download it from: https://www.python.org/downloads/
  echo IMPORTANT: During install, check "Add python.exe to PATH".
  echo Then re-run this script.
  pause
  exit /b 1
)
python --version

powershell -NoProfile -ExecutionPolicy Bypass -File "..\setup-env.ps1"

echo.
echo Creating virtual environment and installing dependencies...
python -m venv venv
call venv\Scripts\activate.bat
python -m pip install --upgrade pip >nul
pip install -q -r requirements.txt

echo.
echo Setup complete!
echo To run the starter guide, open a terminal in the python folder and run:
echo   venv\Scripts\activate.bat
echo   python src\start_guide.py
pause
