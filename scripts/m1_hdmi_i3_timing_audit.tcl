set_timing_model I3
puts "ACTUAL_TIMING_MODEL [get_timing_model]"
if {[get_timing_model] ne "I3"} {error "I3 timing model required"}
report_timing -setup -npaths 10 -nworst 1 -detail full_path -file m1_hdmi_i3_internal_setup.rpt
report_timing -hold -npaths 10 -nworst 1 -detail full_path -file m1_hdmi_i3_internal_hold.rpt
check_timing -verbose -file m1_hdmi_i3_check_timing.rpt
report_clocks -file m1_hdmi_i3_clocks.rpt
report_timing -setup -to [get_ports {tmds_lvds_tx_data*}] -npaths 30 -nworst 1 -detail full_path -file m1_hdmi_i3_serializer_setup.rpt
report_timing -hold -to [get_ports {tmds_lvds_tx_data*}] -npaths 30 -nworst 1 -detail full_path -file m1_hdmi_i3_serializer_hold.rpt
puts "M1_I3_AUDIT_COMPLETE"
