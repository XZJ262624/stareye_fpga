@echo off
call E:\Efinity\2025.1\bin\setup.bat
cd /d F:\Projects\stareye_fpga\efinity\m5b1_global_canny_i3
call E:\Efinity\2025.1\bin\efx_run.bat Ti60_Demo.xml --flow map
exit /b %errorlevel%
