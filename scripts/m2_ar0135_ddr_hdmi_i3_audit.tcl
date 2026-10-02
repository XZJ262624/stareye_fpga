set_timing_model I3
puts "ACTUAL_TIMING_MODEL [get_timing_model]"
report_timing -setup -npaths 100 -nworst 1 -detail full_path -file m2_setup.rpt
report_timing -hold -npaths 30 -nworst 1 -detail full_path -file m2_hold.rpt
check_timing -verbose -file m2_check_timing.rpt
report_clocks -file m2_clocks.rpt
foreach pair {{clk_sys tac_clk} {tac_clk clk_sys} {clk_sys twd_clk} {twd_clk clk_sys} {clk_sys core_clk} {core_clk clk_sys}} {
 lassign $pair a b
 report_timing -setup -from_clock $a -to_clock $b -npaths 100 -nworst 1 -detail full_path -file m2_${a}_${b}_setup.rpt
 report_timing -hold -from_clock $a -to_clock $b -npaths 100 -nworst 1 -detail full_path -file m2_${a}_${b}_hold.rpt
}
report_timing -setup -to [get_ports {hdmi_txd0_o* hdmi_txd1_o* hdmi_txd2_o*}] -npaths 40 -nworst 1 -detail full_path -file m2_hdmi_setup.rpt
report_timing -hold -to [get_ports {hdmi_txd0_o* hdmi_txd1_o* hdmi_txd2_o*}] -npaths 40 -nworst 1 -detail full_path -file m2_hdmi_hold.rpt
report_timing -setup -to [get_ports {addr* ba* ras cas we cke odt cs o_dq* o_dm* o_dqs*}] -npaths 200 -nworst 1 -detail full_path -file m2_ddr_output_setup.rpt
report_timing -hold -to [get_ports {addr* ba* ras cas we cke odt cs o_dq* o_dm* o_dqs*}] -npaths 200 -nworst 1 -detail full_path -file m2_ddr_output_hold.rpt
report_timing -setup -from [get_ports {i_dq* i_dqs*}] -npaths 200 -nworst 1 -detail full_path -file m2_ddr_input_setup.rpt
report_timing -hold -from [get_ports {i_dq* i_dqs*}] -npaths 200 -nworst 1 -detail full_path -file m2_ddr_input_hold.rpt
report_timing -setup -from [get_ports {cmos_data* cmos_vsync cmos_href}] -npaths 20 -nworst 1 -detail full_path -file m2_cmos_setup.rpt
report_timing -hold -from [get_ports {cmos_data* cmos_vsync cmos_href}] -npaths 20 -nworst 1 -detail full_path -file m2_cmos_hold.rpt
# Audit each DDR DQ sampling half separately; aggregate worst-per-end reports
# may select the same input repeatedly and omit other starting lanes.
foreach half {hi lo} {
 for {set lane 0} {$lane < 16} {incr lane} {
  set dq_port [format {i_dq_%s[%d]} $half $lane]
  foreach check {setup hold} {
   report_timing -$check -from [get_ports $dq_port] -npaths 1 -nworst 1 -detail full_path -file m2_ddr_lane_${half}_${lane}_${check}.rpt
  }
 }
}
puts "M2_AUDIT_COMPLETE"

