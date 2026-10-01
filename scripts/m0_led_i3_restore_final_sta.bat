@echo off
call E:\Efinity\2025.1\bin\setup.bat
cd /d F:\Projects\stareye_fpga\efinity\m0_led_i3
call E:\Efinity\2025.1\bin\efx_run.bat LED_8bit_Test.xml --flow pnr --timing_model I3
