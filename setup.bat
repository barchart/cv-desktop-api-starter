@echo off
rem Asks which languages to set up, then runs each ones own setup
rem (<language>\setup.bat, which also works on its own).
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo === cmdtyView Desktop API Starter Setup ===
echo.
echo Which language do you want to set up?
echo   1^) TypeScript
echo   2^) Python
echo   3^) Java
echo   4^) Go
echo   5^) C#
echo.
set "ANSWER="
set /p "ANSWER=Type a number (or several, like: 1 2) and press Enter: "

set "FOLDERS="
for %%c in (!ANSWER!) do (
  set "FOLDER="
  if /i "%%c"=="1" set "FOLDER=typescript"
  if /i "%%c"=="typescript" set "FOLDER=typescript"
  if /i "%%c"=="2" set "FOLDER=python"
  if /i "%%c"=="python" set "FOLDER=python"
  if /i "%%c"=="3" set "FOLDER=java"
  if /i "%%c"=="java" set "FOLDER=java"
  if /i "%%c"=="4" set "FOLDER=go"
  if /i "%%c"=="go" set "FOLDER=go"
  if /i "%%c"=="5" set "FOLDER=csharp"
  if /i "%%c"=="csharp" set "FOLDER=csharp"
  if not defined FOLDER (
    echo "%%c" isnt one of the choices. Run this again and type a number from 1 to 5.
    pause
    exit /b 1
  )
  rem Each language once, even if typed twice.
  if not defined PICKED_!FOLDER! (
    set "PICKED_!FOLDER!=1"
    set "FOLDERS=!FOLDERS! !FOLDER!"
  )
)
if not defined FOLDERS (
  echo Nothing chosen. Run this again and type a number from 1 to 5.
  pause
  exit /b 1
)

set "DONE="
set "FAILED="
set CVDESK_SETUP_FROM_TOP=1
for %%f in (!FOLDERS!) do (
  echo.
  call "%~dp0%%f\setup.bat"
  if errorlevel 1 (set "FAILED=!FAILED! %%f") else (set "DONE=!DONE! %%f")
  cd /d "%~dp0"
)
set "CVDESK_SETUP_FROM_TOP="

echo.
echo === Done ===
if defined DONE echo Set up:!DONE!
if defined FAILED echo Not set up:!FAILED! ^(see above, fix it, then run this again^)
pause
if defined FAILED exit /b 1
