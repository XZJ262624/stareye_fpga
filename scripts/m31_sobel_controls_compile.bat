@echo off
call E:\Efinity\2025.1\bin\setup.bat
cd /d F:\Projects\stareye_fpga\efinity\m31_sobel_controls_i3
call E:\Efinity\2025.1\bin\efx_run.bat Ti60_Demo.xml --flow compile
exit /b %errorlevel%
