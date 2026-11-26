@echo off
rem Hands over to the cvdesk command for every language when the project has it (see cvdesk next to this file).
if exist "%~dp0..\..\bin\cvdesk.cmd" "%~dp0..\..\bin\cvdesk.cmd" %* & exit /b
node "%~dp0cvdesk" %* & exit /b
