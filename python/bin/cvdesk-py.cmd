@echo off
if not exist "%~dp0..\venv\Scripts\python.exe" (
  echo This project has no venv yet. Run its setup again: %~dp0..\setup.bat 1>&2
  exit /b 1
)
"%~dp0..\venv\Scripts\python.exe" "%~dp0..\scripts\run.py" %* & exit /b
