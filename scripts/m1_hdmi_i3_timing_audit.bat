@echo off
call E:\Efinity\2025.1\bin\setup.bat
python -B "%~dp0m1_hdmi_i3_isolated_audit.py"
exit /b %errorlevel%
