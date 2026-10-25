@echo off
powershell.exe -NoProfile -File "%~dp0admin\Start-Admin.ps1"
if errorlevel 1 pause
