@echo off
call E:\Efinity\2025.1\bin\setup.bat
cd /d F:\Projects\stareye_fpga\efinity\m1_hdmi_i3
call E:\Efinity\2025.1\bin\efx_run.bat Ti60_HDMI_1080P_Test.xml --flow compile
