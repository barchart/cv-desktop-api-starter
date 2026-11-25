@echo off
rem Gets the newest version of this project from GitHub (see scripts\update.ps1).
rem   .\update.bat                 the latest release
rem   .\update.bat --from FILE     a .zip or .tar.gz you downloaded yourself
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\update.ps1" %* & exit /b
