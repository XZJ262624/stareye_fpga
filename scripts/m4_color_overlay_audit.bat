@echo off
call E:\Efinity\2025.1\bin\setup.bat
"E:\Efinity\2025.1\python311\bin\python.exe" -B "%~dp0m4_color_overlay_audit.py"
exit /b %errorlevel%
