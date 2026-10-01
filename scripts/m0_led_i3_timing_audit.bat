@echo off
call E:\Efinity\2025.1\bin\setup.bat
cd /d F:\Projects\stareye_fpga\efinity\m0_led_i3
call E:\Efinity\2025.1\bin\efx_run.bat LED_8bit_Test.xml --flow sta_tclsh --tcl_script F:\Projects\stareye_fpga\scripts\m0_led_i3_timing_audit.tcl

if errorlevel 1 exit /b 1
rem The STA Tcl entry defaults to C4 before the script selects I3.
rem Restore the standard I3 implementation report and its matching bitstream.
rem These are OFFLINE compiler flows; neither invokes hardware programming.
call E:\Efinity\2025.1\bin\efx_run.bat LED_8bit_Test.xml --flow pnr
if errorlevel 1 exit /b 1
call E:\Efinity\2025.1\bin\efx_run.bat LED_8bit_Test.xml --flow pgm
if errorlevel 1 exit /b 1
exit /b 0
