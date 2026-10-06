@echo off
call E:\Efinity\2025.1\bin\setup.bat
E:\Efinity\2025.1\python311\bin\python.exe -B F:\Projects\stareye_fpga\scripts\m4_color_overlay_configure.py %*
exit /b %errorlevel%
