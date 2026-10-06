@echo off
call E:\Efinity\2025.1\bin\setup.bat
python F:\Projects\stareye_fpga\scripts\m32_median_integration_audit.py
exit /b %errorlevel%
