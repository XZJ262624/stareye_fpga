puts "FRESH_QUERY_START 03_connections"
set_timing_model I3
puts "ACTUAL_TIMING_MODEL [get_timing_model]"
if {[get_timing_model] ne "I3"} {error "WRONG_TIMING_MODEL"}
puts "SELECTED_STA_V4_START"
puts "ACTUAL_TIMING_MODEL [get_timing_model]"
set f [open v4_pin_nets.txt w]
set one [get_pins -regexp {^ddr3_ctl_axi/u_efx_ddr3_soft_controller/genblk1\.inst_ddr3_axi/inst_efx_ddr3/cal_wr_data\[21\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^ddr3_ctl_axi/u_efx_ddr3_soft_controller/genblk1\.inst_ddr3_axi/inst_efx_ddr3/rst_top0/genblk1\[0\]\.genblk1\.genblk1\.inst_sysclk_rstn/dffrs_29/i4_rst_0\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^ddr3_ctl_axi/u_efx_ddr3_soft_controller/genblk1\.inst_ddr3_axi/inst_efx_ddr3/rst_top0/genblk1\[1\]\.genblk1\.genblk1\.inst_sysclk_rstn/dffrs_29/i4_rst_0\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^ddr3_ctl_axi/u_efx_ddr3_soft_controller/genblk1\.inst_ddr3_axi/inst_efx_ddr3/top_mc/ac_push\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^ddr3_ctl_axi/u_efx_ddr3_soft_controller/genblk1\.inst_ddr3_axi/inst_efx_ddr3/top_mc/controller_main/dffrs_2532/i15_rst_0\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^ddr3_ctl_axi/u_efx_ddr3_soft_controller/genblk1\.inst_ddr3_axi/inst_efx_ddr3/top_mc/controller_main/ref_counter\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^ddr3_ctl_axi/u_efx_ddr3_soft_controller/genblk1\.inst_ddr3_axi/inst_efx_ddr3/top_mc/controller_main/us_start_count\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^ddr3_ctl_axi/u_efx_ddr3_soft_controller/genblk1\.inst_ddr3_axi/inst_efx_ddr3/top_mc/i_phy_ddrA_rstn\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^ddr3_ctl_axi/u_efx_ddr3_soft_controller/genblk1\.inst_ddr3_axi/inst_efx_ddr3/top_mc/rst_ctrl0/genblk1\[0\]\.genblk1\.genblk1\.inst_sysclk_rstn/r_srst_1P\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^ddr3_ctl_axi/u_efx_ddr3_soft_controller/genblk1\.inst_ddr3_axi/inst_efx_ddr3/top_mc/rst_ctrl0/genblk1\[1\]\.genblk1\.genblk1\.inst_sysclk_rstn/r_srst_1P\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^ddr3_ctl_axi/u_efx_ddr3_soft_controller/genblk1\.inst_ddr3_axi/inst_efx_ddr3/top_mc/rst_ctrl0/genblk1\[3\]\.genblk1\.genblk1\.inst_sysclk_rstn/r_srst_1P\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^ddr3_ctl_axi/u_efx_ddr3_soft_controller/genblk1\.inst_ddr3_axi/inst_efx_ddr3/top_mc/rst_ctrl1/genblk1\[0\]\.genblk1\.genblk1\.inst_sysclk_rstn/r_srst_1P\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^ddr3_ctl_axi/u_efx_ddr3_soft_controller/genblk1\.inst_ddr3_axi/inst_efx_ddr3/w_init_done\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^dsi_resetn_o\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_context_tail_fault\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_ddr_error_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_export_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_hardstop_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_stop_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^m5b1_cam_reset\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^m5b1_lcd_epoch\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^rstn_pixel\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^rstn_sys\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_controls/armed\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_controls/key_meta\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_controls/key_meta\[1\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_controls/reset_release\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_controls/warmup\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/time_fault\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5a_stream/reset_release\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5a_stream/u_base/reset_release\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5a_stream/u_base/u_m32/dff_37/i4_rst_0\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5a_stream/u_base/u_m32/frame_filter\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5a_stream/u_base/u_m32/reset_release\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5a_stream/u_base/u_m32/u_median/reset_release\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5a_stream/u_base/u_m32/u_median/u_median/dff_782/i7_rst_0\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5a_stream/u_base/u_m32/u_sobel/dff_30/i4_rst_0\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5a_stream/u_base/u_m32/u_sobel/reset_release\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_dropped\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_box/held\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/cancel_meta\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/descriptor_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/descriptor_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/descriptor_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/descriptor_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/rrs\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/wrs\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/over_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/prelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/dropped_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/engine/classification\[24\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/engine/result_base\[15\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/ever_run\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/fault_reported\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/lease/halted\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/packet/header\[1\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/bridge/rs\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/bridge/started\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[0\]\.ready_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[0\]\.ready_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[0\]\.ready_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[0\]\.ready_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[1\]\.ready_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[1\]\.ready_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[1\]\.ready_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[1\]\.ready_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[2\]\.ready_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[2\]\.ready_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[2\]\.ready_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[2\]\.ready_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[3\]\.ready_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[3\]\.ready_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[3\]\.ready_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[3\]\.ready_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[4\]\.ready_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[4\]\.ready_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[4\]\.ready_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[4\]\.ready_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[5\]\.ready_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[5\]\.ready_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[5\]\.ready_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[5\]\.ready_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[6\]\.ready_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[6\]\.ready_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[6\]\.ready_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[6\]\.ready_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[7\]\.ready_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[7\]\.ready_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[7\]\.ready_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[7\]\.ready_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[14\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[19\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[14\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[19\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[14\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[19\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[14\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[19\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[14\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[19\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[14\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[19\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[14\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[19\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[14\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[19\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/pixel_release\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache_fault\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_drain_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/context_fault_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/context_protocol_fault\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/context_ui_release\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/offer_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/offer_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/offer_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/offer_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/offer_release\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[10\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[11\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[13\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[14\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[15\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[16\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[17\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[18\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[10\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[11\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[13\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[14\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[15\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[16\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[17\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|CE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[10\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[11\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[13\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[14\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[15\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[16\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[17\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|OP\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|OP\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|SHIFT_ENA$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/transfer/len\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader_fault\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/release_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/release_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/release_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/release_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/request_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/request_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/request_box/held\[88\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/request_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/request_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/revoke_ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/revoke_req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/lease_fault\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/result_valid\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/inflight_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|RADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|RE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|RST$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WADDREN$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WCLKE$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WE\[0\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WE\[1\]$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/pixel_release\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/snapshot_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/snapshot_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/snapshot_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/snapshot_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry_fault\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/cam_armed\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/cam_fault\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/cam_run\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/camera_fifo/rrs\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/camera_fifo/wrs\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/camera_over_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/cf\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/consumed_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/consumed_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/consumed_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/consumed_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/crelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/display_fifo/rrs\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/display_fifo/wrs\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/display_under_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/eof_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/eof_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/eof_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/eof_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/latest_valid\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/offer_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/offer_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/offer_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/offer_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/pf\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/pix_fault\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/pix_run\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/prelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_osd/reset_release\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "V4_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
close $f
puts "SELECTED_STA_V4_COMPLETE"
puts "FRESH_QUERY_COMPLETE 03_connections"
