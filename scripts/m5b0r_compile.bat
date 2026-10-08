@echo off
call E:\Efinity\2025.1\bin\setup.bat
cd /d F:\Projects\stareye_fpga\efinity\m5b0r_ddr_address_diag_i3
call E:\Efinity\2025.1\bin\efx_run.bat M5B0R_DdrDiag.xml --flow compile
exit /b %errorlevel%
