@echo off
rem Updates every language folder of this project to its newest version from
rem GitHub, downloading it once (see scripts\update.ps1).
rem   .\update.bat                 the latest release
rem   .\update.bat --from FILE     a .zip or .tar.gz you downloaded yourself
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\update.ps1" %* & exit /b
