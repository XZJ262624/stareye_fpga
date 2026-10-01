puts "AVAILABLE_TIMING_MODELS [get_available_timing_model]"
set_timing_model I3
puts "ACTUAL_TIMING_MODEL [get_timing_model]"
check_timing -verbose -file m0_led_i3_check_timing.rpt
report_clocks -file m0_led_i3_clocks.rpt

