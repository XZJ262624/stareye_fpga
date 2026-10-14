puts "FRESH_QUERY_START 03_connections"
set_timing_model I3
puts "ACTUAL_TIMING_MODEL [get_timing_model]"
if {[get_timing_model] ne "I3"} {error "WRONG_TIMING_MODEL"}
set f [open v4_pin_nets.txt w]
set one [get_pins -regexp {^ddr3_ctl_axi/u_efx_ddr3_soft_controller/genblk1\.inst_ddr3_axi/inst_efx_ddr3/cal_wr_data\[34\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^ddr3_ctl_axi/u_efx_ddr3_soft_controller/genblk1\.inst_ddr3_axi/inst_efx_ddr3/rst_top0/genblk1\[0\]\.genblk1\.genblk1\.inst_sysclk_rstn/dffrs_29/i4_rst_0\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^ddr3_ctl_axi/u_efx_ddr3_soft_controller/genblk1\.inst_ddr3_axi/inst_efx_ddr3/rst_top0/genblk1\[1\]\.genblk1\.genblk1\.inst_sysclk_rstn/dffrs_29/i4_rst_0\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^ddr3_ctl_axi/u_efx_ddr3_soft_controller/genblk1\.inst_ddr3_axi/inst_efx_ddr3/top_mc/ac_push\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^ddr3_ctl_axi/u_efx_ddr3_soft_controller/genblk1\.inst_ddr3_axi/inst_efx_ddr3/top_mc/controller_main/dffrs_2532/i124_rst_0\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^ddr3_ctl_axi/u_efx_ddr3_soft_controller/genblk1\.inst_ddr3_axi/inst_efx_ddr3/top_mc/controller_main/ref_counter\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^ddr3_ctl_axi/u_efx_ddr3_soft_controller/genblk1\.inst_ddr3_axi/inst_efx_ddr3/top_mc/controller_main/us_start_count\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^ddr3_ctl_axi/u_efx_ddr3_soft_controller/genblk1\.inst_ddr3_axi/inst_efx_ddr3/top_mc/i_phy_ddrA_rstn\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^ddr3_ctl_axi/u_efx_ddr3_soft_controller/genblk1\.inst_ddr3_axi/inst_efx_ddr3/top_mc/rst_ctrl0/genblk1\[0\]\.genblk1\.genblk1\.inst_sysclk_rstn/r_srst_1P\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^ddr3_ctl_axi/u_efx_ddr3_soft_controller/genblk1\.inst_ddr3_axi/inst_efx_ddr3/top_mc/rst_ctrl0/genblk1\[1\]\.genblk1\.genblk1\.inst_sysclk_rstn/r_srst_1P\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^ddr3_ctl_axi/u_efx_ddr3_soft_controller/genblk1\.inst_ddr3_axi/inst_efx_ddr3/top_mc/rst_ctrl0/genblk1\[3\]\.genblk1\.genblk1\.inst_sysclk_rstn/r_srst_1P\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^ddr3_ctl_axi/u_efx_ddr3_soft_controller/genblk1\.inst_ddr3_axi/inst_efx_ddr3/top_mc/rst_ctrl1/genblk1\[0\]\.genblk1\.genblk1\.inst_sysclk_rstn/r_srst_1P\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^ddr3_ctl_axi/u_efx_ddr3_soft_controller/genblk1\.inst_ddr3_axi/inst_efx_ddr3/w_init_done\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^dsi_resetn_o\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_context_tail_fault\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_ddr_error_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[100\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[101\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[102\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[103\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[104\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[105\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[106\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[107\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[108\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[109\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[110\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[111\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[112\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[113\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[114\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[115\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[116\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[117\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[118\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[119\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[120\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[121\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[122\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[123\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[124\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[125\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[126\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[127\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[128\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[129\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[130\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[131\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[132\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[133\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[134\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[135\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[136\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[137\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[138\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[139\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[140\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[141\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[142\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[143\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[144\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[145\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[146\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[147\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[148\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[149\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[150\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[151\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[152\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[153\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[154\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[155\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[156\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[157\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[158\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[159\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[160\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[161\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[162\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[163\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[164\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[165\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[166\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[167\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[168\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[169\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[170\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[171\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[172\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[173\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[174\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[175\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[176\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[177\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[178\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[179\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[180\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[181\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[182\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[183\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[184\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[185\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[186\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[187\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[188\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[189\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[190\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[191\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[320\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[321\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[322\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[323\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[324\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[325\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[326\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[327\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[328\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[329\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[330\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[331\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[332\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[333\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[334\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[335\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[336\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[337\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[338\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[339\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[340\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[341\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[342\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[343\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[344\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[345\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[346\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[347\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[348\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[349\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[350\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[351\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[352\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[353\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[354\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[355\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[356\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[357\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[358\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[359\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[360\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[361\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[362\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[363\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[364\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[365\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[366\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[367\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[368\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[369\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[370\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[371\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[372\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[373\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[374\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[375\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[376\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[377\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[378\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[379\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[380\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[381\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[382\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[383\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[448\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[449\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[450\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[451\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[452\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[453\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[454\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[455\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[456\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[457\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[458\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[459\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[460\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[461\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[462\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[463\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[464\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[465\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[466\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[467\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[468\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[469\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[470\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[471\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[472\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[473\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[474\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[475\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[476\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[477\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[478\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[479\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[480\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[481\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[482\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[483\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[484\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[485\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[486\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[487\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[488\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[489\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[490\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[491\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[492\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[493\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[494\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[495\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[496\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[497\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[498\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[499\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[500\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[501\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[502\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[503\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[504\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[505\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[506\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[507\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[508\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[509\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[510\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[511\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[512\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[513\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[514\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[515\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[516\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[517\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[518\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[519\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[520\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[521\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[522\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[523\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[524\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[525\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[526\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[527\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[528\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[529\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[530\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[531\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[532\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[533\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[534\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[535\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[536\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[537\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[538\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[539\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[540\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[541\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[542\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[543\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[544\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[545\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[546\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[547\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[548\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[549\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[550\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[551\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[552\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[553\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[554\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[555\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[556\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[557\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[558\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[559\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[560\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[561\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[562\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[563\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[564\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[565\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[566\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[567\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[568\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[569\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[570\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[571\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[572\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[573\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[574\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[575\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[615\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[624\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[625\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[626\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[627\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[628\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[629\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[630\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[631\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[64\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[65\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[664\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[66\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[672\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[673\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[674\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[675\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[676\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[677\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[678\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[679\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[67\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[680\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[681\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[682\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[683\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[684\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[685\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[686\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[687\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[688\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[689\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[68\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[690\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[691\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[692\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[693\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[694\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[695\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[696\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[697\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[698\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[699\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[69\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[700\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[701\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[702\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[703\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[704\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[705\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[706\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[707\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[708\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[709\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[70\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[710\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[711\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[712\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[713\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[714\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[715\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[716\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[717\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[718\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[719\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[71\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[720\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[721\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[722\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[723\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[724\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[725\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[726\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[727\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[728\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[729\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[72\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[730\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[731\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[732\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[733\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[734\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[735\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[73\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[74\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[75\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[76\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[77\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[78\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[79\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[80\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[81\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[82\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[83\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[84\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[85\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[86\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[87\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[88\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[89\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[90\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[91\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[92\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[93\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[94\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[95\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[96\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[97\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[98\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_descriptor\[99\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_export_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_hardstop_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[10\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[11\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[12\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[13\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[14\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[15\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[16\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[17\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[18\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[19\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[1\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[20\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[21\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[22\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[23\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[24\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[25\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[26\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[27\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[28\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[29\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[2\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[30\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[31\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[32\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[33\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[34\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[35\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[36\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[37\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[38\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[39\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[3\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[40\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[41\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[42\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[43\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[44\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[45\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[46\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[47\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[48\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[49\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[4\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[50\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[51\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[52\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[53\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[54\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[55\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[56\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[57\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[58\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[59\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[5\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[60\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[61\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[62\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[63\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[6\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[7\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[8\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_session\[9\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^fusion_stop_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^m5b1_cam_reset\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^m5b1_lcd_epoch\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^rstn_pixel\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^rstn_sys\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_controls/armed\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_controls/key_meta\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_controls/key_meta\[1\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_controls/reset_release\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_controls/warmup\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$12\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$2\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$b12\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$c12\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$d12\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$e12\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$f12\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$g12\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$h12\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$i12\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$j12\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$k12\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$l12\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$m12\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$n12\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$o12\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$p12\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$q12\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|RADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|RADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WADDR\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WADDR\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/fusion/align/storage__D\$r1\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_fusion_display/time_fault\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5a_stream/reset_release\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5a_stream/u_base/reset_release\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5a_stream/u_base/u_m32/dff_37/i4_rst_0\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5a_stream/u_base/u_m32/frame_filter\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5a_stream/u_base/u_m32/reset_release\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5a_stream/u_base/u_m32/u_median/reset_release\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5a_stream/u_base/u_m32/u_median/u_median/dff_782/i7_rst_0\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5a_stream/u_base/u_m32/u_sobel/dff_30/i4_rst_0\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5a_stream/u_base/u_m32/u_sobel/reset_release\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_dropped\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_box/held\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/cancel_meta\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/descriptor_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/descriptor_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/descriptor_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/descriptor_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/rrs\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/wrs\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/over_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/prelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/dropped_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/engine/classification\[24\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/engine/result_base\[15\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/ever_run\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/exported\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/fault_reported\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/lease/halted\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/packet/header\[1\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/bridge/rs\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/bridge/started\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[0\]\.ready_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[0\]\.ready_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[0\]\.ready_box/drelease\[0\]\~FF\|SR$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[0\]\.ready_box/drelease\[1\]\~FF\|SR$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[0\]\.ready_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[0\]\.ready_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[1\]\.ready_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[1\]\.ready_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[1\]\.ready_box/drelease\[0\]\~FF\|SR$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[1\]\.ready_box/drelease\[1\]\~FF\|SR$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[1\]\.ready_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[1\]\.ready_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[2\]\.ready_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[2\]\.ready_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[2\]\.ready_box/drelease\[0\]\~FF\|SR$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[2\]\.ready_box/drelease\[1\]\~FF\|SR$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[2\]\.ready_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[2\]\.ready_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[3\]\.ready_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[3\]\.ready_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[3\]\.ready_box/drelease\[0\]\~FF\|SR$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[3\]\.ready_box/drelease\[1\]\~FF\|SR$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[3\]\.ready_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[3\]\.ready_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[4\]\.ready_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[4\]\.ready_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[4\]\.ready_box/drelease\[0\]\~FF\|SR$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[4\]\.ready_box/drelease\[1\]\~FF\|SR$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[4\]\.ready_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[4\]\.ready_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[5\]\.ready_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[5\]\.ready_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[5\]\.ready_box/drelease\[0\]\~FF\|SR$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[5\]\.ready_box/drelease\[1\]\~FF\|SR$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[5\]\.ready_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[5\]\.ready_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[6\]\.ready_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[6\]\.ready_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[6\]\.ready_box/drelease\[0\]\~FF\|SR$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[6\]\.ready_box/drelease\[1\]\~FF\|SR$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[6\]\.ready_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[6\]\.ready_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[7\]\.ready_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[7\]\.ready_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[7\]\.ready_box/drelease\[0\]\~FF\|SR$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[7\]\.ready_box/drelease\[1\]\~FF\|SR$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[7\]\.ready_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/bank\[7\]\.ready_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$12\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$2\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$b12\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[14\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[19\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WDATA\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$c12\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[14\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[19\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WDATA\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$d12\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[14\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[19\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WDATA\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$e12\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[14\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[19\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WDATA\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/classes__D\$f1\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$12\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$2\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$b12\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[14\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[19\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WDATA\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$c12\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[14\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[19\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WDATA\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$d12\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[14\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[19\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WDATA\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$e12\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[14\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[19\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WDATA\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/masks__D\$f1\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/pixel_release\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/pixel_release\[0\]\~FF\|SR$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/pixel_release\[1\]\~FF\|SR$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[0\]\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[0\]\[10\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[0\]\[11\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[0\]\[1\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[0\]\[2\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[0\]\[3\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[0\]\[4\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[0\]\[5\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[0\]\[6\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[0\]\[7\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[0\]\[8\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[0\]\[9\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[1\]\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[1\]\[10\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[1\]\[11\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[1\]\[1\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[1\]\[2\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[1\]\[3\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[1\]\[4\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[1\]\[5\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[1\]\[6\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[1\]\[7\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[1\]\[8\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[1\]\[9\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[2\]\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[2\]\[10\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[2\]\[11\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[2\]\[1\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[2\]\[2\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[2\]\[3\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[2\]\[4\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[2\]\[5\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[2\]\[6\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[2\]\[7\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[2\]\[8\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[2\]\[9\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[3\]\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[3\]\[10\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[3\]\[11\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[3\]\[1\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[3\]\[2\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[3\]\[3\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[3\]\[4\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[3\]\[5\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[3\]\[6\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[3\]\[7\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[3\]\[8\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[3\]\[9\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[4\]\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[4\]\[10\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[4\]\[11\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[4\]\[1\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[4\]\[2\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[4\]\[3\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[4\]\[4\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[4\]\[5\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[4\]\[6\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[4\]\[7\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[4\]\[8\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[4\]\[9\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[5\]\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[5\]\[10\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[5\]\[11\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[5\]\[1\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[5\]\[2\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[5\]\[3\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[5\]\[4\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[5\]\[5\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[5\]\[6\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[5\]\[7\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[5\]\[8\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[5\]\[9\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[6\]\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[6\]\[10\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[6\]\[11\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[6\]\[1\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[6\]\[2\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[6\]\[3\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[6\]\[4\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[6\]\[5\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[6\]\[6\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[6\]\[7\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[6\]\[8\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[6\]\[9\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[7\]\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[7\]\[10\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[7\]\[11\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[7\]\[1\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[7\]\[2\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[7\]\[3\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[7\]\[4\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[7\]\[5\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[7\]\[6\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[7\]\[7\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[7\]\[8\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache/row_tag\[7\]\[9\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cache_fault\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_drain_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[10\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[11\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[12\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[13\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[14\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[15\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[16\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[17\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[18\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[19\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[1\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[20\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[21\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[22\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[23\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[24\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[25\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[26\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[27\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[28\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[29\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[2\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[30\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[31\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[32\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[33\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[34\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[35\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[36\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[37\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[38\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[39\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[3\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[40\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[41\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[42\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[43\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[44\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[45\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[46\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[47\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[48\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[49\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[4\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[50\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[51\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[52\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[53\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[54\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[55\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[56\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[57\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[58\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[59\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[5\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[60\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[61\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[62\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[63\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[6\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[7\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[8\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/cap_sid\[9\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/context_fault_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/context_protocol_fault\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/context_ui_release\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/offer_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/offer_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/offer_box/drelease\[0\]\~FF\|SR$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/offer_box/drelease\[1\]\~FF\|SR$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/offer_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/offer_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/offer_release\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/offer_release\[0\]\~FF\|SR$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/offer_release\[1\]\~FF\|SR$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[10\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[11\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[13\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[14\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[15\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[16\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[17\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[18\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|A\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[10\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[11\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[13\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[14\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[15\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[16\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[17\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|CE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[10\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[11\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[13\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[14\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[15\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[16\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[17\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|C\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|OP\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|OP\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|SHIFT_ENA$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader/transfer/len\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/reader_fault\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[10\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[11\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[12\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[13\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[14\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[15\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[16\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[17\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[18\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[19\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[1\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[20\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[21\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[22\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[23\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[24\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[25\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[26\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[27\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[28\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[29\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[2\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[30\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[31\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[32\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[33\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[34\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[35\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[36\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[37\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[38\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[39\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[3\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[40\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[41\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[42\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[43\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[44\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[45\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[46\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[47\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[48\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[49\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[4\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[50\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[51\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[52\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[53\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[54\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[55\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[56\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[57\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[58\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[59\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[5\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[60\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[61\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[62\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[63\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[64\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[6\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[7\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[8\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/rel_data\[9\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/release_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/release_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/release_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/release_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/release_box/srelease\[0\]\~FF\|SR$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/release_box/srelease\[1\]\~FF\|SR$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[100\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[101\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[102\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[103\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[104\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[105\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[106\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[107\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[108\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[109\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[110\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[111\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[112\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[113\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[114\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[115\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[116\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[117\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[118\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[119\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[120\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[121\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[122\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[123\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[124\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[125\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[126\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[127\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[128\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[129\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[130\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[131\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[132\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[133\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[134\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[135\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[136\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[137\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[138\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[139\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[140\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[141\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[142\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[143\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[144\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[145\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[146\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[147\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[148\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[149\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[150\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[151\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[152\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[153\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[154\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[155\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[156\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[157\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[158\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[159\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[160\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[161\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[162\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[163\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[164\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[165\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[166\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[167\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[168\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[169\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[170\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[171\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[172\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[173\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[174\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[175\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[176\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[177\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[178\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[179\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[180\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[181\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[182\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[183\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[184\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[185\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[186\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[187\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[188\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[189\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[190\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[191\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[192\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[193\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[194\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[195\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[196\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[197\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[198\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[199\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[200\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[201\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[202\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[203\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[204\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[205\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[206\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[207\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[208\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[209\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[210\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[211\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[212\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[213\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[214\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[215\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[216\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[217\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[218\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[219\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[220\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[221\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[222\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[223\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[51\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[52\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[53\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[54\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[55\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[88\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[96\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[97\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[98\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/req_data\[99\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/request_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/request_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/request_box/held\[88\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/request_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/request_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/request_box/srelease\[0\]\~FF\|SR$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/request_box/srelease\[1\]\~FF\|SR$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/revoke_ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/fusion/revoke_req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/lease_fault\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/result_valid\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/session_fault\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/inflight_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$12\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$2\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$b12\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|RADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|RADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|RADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|RADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|RADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|RADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|RADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|RADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|RADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|RADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|RE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|RST$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WADDREN$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WADDR\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WADDR\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WADDR\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WADDR\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WADDR\[4\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WADDR\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WADDR\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WADDR\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WADDR\[9\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WCLKE$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[10\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[11\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[12\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[13\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[15\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[16\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[17\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[18\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[2\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[3\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[5\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[6\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[7\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WDATA\[8\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WE\[0\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/mem__D\$c1\|WE\[1\]$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/pixel_release\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/pixel_release\[0\]\~FF\|SR$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/pixel_release\[1\]\~FF\|SR$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/snapshot_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/snapshot_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/snapshot_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/snapshot_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/snapshot_box/srelease\[0\]\~FF\|SR$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/snapshot_box/srelease\[1\]\~FF\|SR$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[10\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[11\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[12\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[13\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[14\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[15\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[16\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[17\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[18\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[19\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[1\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[20\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[21\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[22\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[23\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[24\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[25\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[26\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[27\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[28\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[29\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[2\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[30\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[31\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[32\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[33\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[34\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[35\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[36\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[37\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[38\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[39\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[3\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[40\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[41\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[42\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[43\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[44\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[45\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[46\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[47\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[48\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[49\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[4\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[50\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[51\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[52\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[53\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[54\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[55\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[56\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[57\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[58\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[59\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[5\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[60\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[61\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[62\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[63\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[6\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[7\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[8\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry/source_guard\[9\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/telemetry_fault\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/cam_armed\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/cam_fault\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/cam_run\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/camera_fifo/rrs\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/camera_fifo/wrs\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/camera_over_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/cf\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/consumed_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/consumed_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/consumed_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/consumed_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/crelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/display_fifo/rrs\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/display_fifo/wrs\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/display_under_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/eof_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/eof_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/eof_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/eof_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/latest_valid\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/offer_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/offer_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/offer_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/offer_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/pf\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/pix_fault\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/pix_run\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/video/prelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_osd/reset_release\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "CURRENT_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
close $f
puts "FRESH_QUERY_COMPLETE 03_connections"
