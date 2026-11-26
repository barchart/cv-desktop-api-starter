@echo off
rem The cvdesk command on Windows (see cvdesk next to this file and scripts\cvdesk.ps1).
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\scripts\cvdesk.ps1" %* & exit /b
