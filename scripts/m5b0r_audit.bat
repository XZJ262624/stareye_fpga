@echo off
call E:\Efinity\2025.1\bin\setup.bat
E:\Efinity\2025.1\python311\bin\python.exe -B F:\Projects\stareye_fpga\scripts\m5b0r_audit.py
exit /b %errorlevel%
