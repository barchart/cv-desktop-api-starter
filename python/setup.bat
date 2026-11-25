@echo off
setlocal
cd /d "%~dp0"

echo === OpenFeed Python Starter Setup ===
echo.

rem The py launcher (installed with Python from python.org) picks the newest Python 3.
rem Running it, not just finding it, also skips the Microsoft Store placeholder "python".
set "PYTHON="
py -3 -c "import sys; sys.exit(sys.version_info < (3, 11))" >nul 2>nul && set "PYTHON=py -3"
if defined PYTHON goto :found
python -c "import sys; sys.exit(sys.version_info < (3, 11))" >nul 2>nul && set "PYTHON=python"
if defined PYTHON goto :found
call :python_from_uv
if defined PYTHON goto :found

echo This project needs Python 3.11 or newer.
py -3 --version 2>nul || python --version 2>nul
echo.
echo Setup can install it for you with uv ^(https://docs.astral.sh/uv/^), which installs
echo Python into your user folder without admin rights. This downloads and runs uv's installer.
set "ANSWER="
set /p "ANSWER=Install uv and Python now? [y/N] "
if /i not "%ANSWER%"=="y" if /i not "%ANSWER%"=="yes" goto :install_help

call :find_uv
if defined UV goto :install_python
echo.
echo Installing uv...
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://astral.sh/uv/install.ps1 | iex"
call :find_uv
if defined UV goto :install_python
echo Installing uv failed.
goto :install_help

:install_python
echo.
echo Installing Python...
rem Without a version, uv installs the one in .python-version.
"%UV%" python install
if errorlevel 1 (
  echo Installing Python with uv failed.
  goto :install_help
)
call :python_from_uv
if defined PYTHON (
  echo.
  goto :found
)
echo uv installed Python, but setup could not find it.

:install_help
echo.
echo Download Python from: https://www.python.org/downloads/
echo IMPORTANT: During install, check "Add python.exe to PATH".
echo Then re-run this script.
pause
exit /b 1

:found
%PYTHON% --version

%PYTHON% "%~dp0scripts\project_setup.py"
if errorlevel 1 (
  pause
  exit /b 1
)

echo.
echo Adding the cvdesk-py command to your PATH...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\add-to-path.ps1"

echo.
echo Setup complete!
echo To run the starter guide, open a new PowerShell window and run:
echo   cvdesk-py start-guide
echo Put your own scripts in the my-scripts folder. To get the newest version
echo of this project later, run: cvdesk-py update
pause
exit /b 0

rem uv (https://docs.astral.sh/uv/) installs Python without admin rights. Its installer puts it in
rem %USERPROFILE%\.local\bin (.cargo\bin in older versions), which may not be on PATH yet.
:find_uv
set "UV="
for /f "delims=" %%u in ('where uv 2^>nul') do if not defined UV set "UV=%%u"
if not defined UV if exist "%USERPROFILE%\.local\bin\uv.exe" set "UV=%USERPROFILE%\.local\bin\uv.exe"
if not defined UV if exist "%USERPROFILE%\.cargo\bin\uv.exe" set "UV=%USERPROFILE%\.cargo\bin\uv.exe"
exit /b 0

rem A Python 3.11+ that uv installed, which isn't always on PATH.
rem --system skips virtual environments, such as this project's own venv.
rem "call" keeps cmd from stripping the quotes around the uv path.
:python_from_uv
call :find_uv
if not defined UV exit /b 0
for /f "delims=" %%p in ('call "%UV%" python find --system ">=3.11" 2^>nul') do set PYTHON="%%p"
exit /b 0
