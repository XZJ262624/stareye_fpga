puts "FRESH_QUERY_START 07_backend_connections"
set_timing_model I3
puts "ACTUAL_TIMING_MODEL [get_timing_model]"
if {[get_timing_model] ne "I3"} {error "WRONG_TIMING_MODEL"}
set f [open backend_pin_nets.txt w]
set one [get_pins -regexp {^u_m5b1/background/acquire_ack\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/acquire_denied\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/arm\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/bind_ack\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[100\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[101\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[102\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[103\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[104\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[105\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[106\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[107\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[108\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[109\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[110\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[111\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[112\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[113\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[114\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[115\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[116\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[117\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[118\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[119\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[120\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[121\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[122\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[123\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[124\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[125\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[126\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[127\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[128\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[129\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[130\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[131\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[132\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[133\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[134\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[135\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[136\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[137\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[138\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[139\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[140\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[141\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[142\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[143\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[144\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[145\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[146\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[147\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[148\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[149\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[150\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[151\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[152\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[153\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[154\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[155\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[156\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[157\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[158\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[159\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[160\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[161\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[162\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[163\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[164\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[165\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[166\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[167\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[168\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[169\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[170\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[171\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[172\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[173\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[174\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[175\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[176\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[177\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[178\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[179\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[180\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[181\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[182\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[183\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[184\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[185\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[186\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[187\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[188\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[189\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[190\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[191\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[308\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[320\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[321\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[322\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[323\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[324\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[325\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[326\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[327\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[328\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[329\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[330\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[331\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[332\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[333\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[334\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[335\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[336\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[337\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[338\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[339\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[340\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[341\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[342\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[343\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[344\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[345\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[346\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[347\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[348\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[349\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[350\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[351\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[352\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[353\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[354\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[355\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[356\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[357\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[358\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[359\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[360\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[361\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[362\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[363\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[364\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[365\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[366\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[367\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[368\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[369\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[370\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[371\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[372\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[373\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[374\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[375\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[376\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[377\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[378\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[379\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[380\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[381\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[382\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[383\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[384\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[385\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[386\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[387\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[388\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[389\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[390\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[391\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[392\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[393\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[394\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[395\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[396\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[397\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[398\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[399\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[400\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[401\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[402\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[403\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[404\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[405\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[406\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[407\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[408\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[409\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[410\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[411\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[412\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[413\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[414\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[415\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[416\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[417\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[418\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[419\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[420\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[421\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[422\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[423\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[424\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[425\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[426\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[427\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[428\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[429\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[430\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[431\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[432\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[433\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[434\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[435\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[436\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[437\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[438\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[439\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[440\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[441\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[442\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[443\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[444\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[445\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[446\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[447\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[512\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[513\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[514\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[515\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[516\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[517\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[518\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[519\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[520\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[521\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[522\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[523\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[524\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[525\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[526\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[527\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[528\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[529\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[530\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[531\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[532\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[533\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[534\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[535\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[536\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[537\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[538\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[539\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[540\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[541\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[542\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[543\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[544\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[545\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[546\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[547\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[548\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[549\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[550\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[551\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[552\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[553\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[554\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[555\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[556\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[557\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[558\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[559\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[560\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[561\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[562\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[563\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[564\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[565\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[566\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[567\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[568\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[569\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[570\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[571\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[572\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[573\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[574\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[575\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[615\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[624\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[625\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[626\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[627\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[628\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[629\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[630\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[631\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[64\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[65\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[664\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[66\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[67\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[68\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[69\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[70\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[71\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[72\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[73\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[74\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[75\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[76\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[77\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[78\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[79\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[80\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[81\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[82\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[83\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[84\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[85\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[86\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[87\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[88\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[89\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[90\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[91\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[92\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[93\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[94\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[95\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[96\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[97\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[98\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_descriptor\[99\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/cap_dropped\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_box/ack_sync\[0\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_box/ack_sync\[1\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_box/drelease\[0\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_box/drelease\[0\]\~FF\|SR$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_box/drelease\[1\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_box/drelease\[1\]\~FF\|SR$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_box/held\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_box/req_sync\[0\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_box/req_sync\[1\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_box/srelease\[0\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_box/srelease\[0\]\~FF\|SR$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_box/srelease\[1\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_box/srelease\[1\]\~FF\|SR$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[100\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[101\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[102\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[103\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[104\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[105\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[106\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[107\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[108\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[109\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[110\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[111\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[112\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[113\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[114\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[115\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[116\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[117\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[118\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[119\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[120\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[121\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[122\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[123\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[124\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[125\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[126\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[127\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[64\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[65\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[66\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[67\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[68\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[69\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[70\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[71\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[72\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[73\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[74\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[75\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[76\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[77\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[78\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[79\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[80\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[81\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[82\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[83\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[84\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[85\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[86\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[87\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[88\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[89\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[90\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[91\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[92\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[93\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[94\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[95\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[96\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[97\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[98\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_data\[99\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/arm_take\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/cancel_meta\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/cancel_meta\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/cancel_sync\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/descriptor_box/ack_sync\[0\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/descriptor_box/ack_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/descriptor_box/ack_sync\[1\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/descriptor_box/drelease\[0\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/descriptor_box/drelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/descriptor_box/drelease\[0\]\~FF\|SR$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/descriptor_box/drelease\[1\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/descriptor_box/drelease\[1\]\~FF\|SR$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/descriptor_box/req_sync\[0\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/descriptor_box/req_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/descriptor_box/req_sync\[1\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/descriptor_box/srelease\[0\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/descriptor_box/srelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/descriptor_box/srelease\[0\]\~FF\|SR$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/descriptor_box/srelease\[1\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/descriptor_box/srelease\[1\]\~FF\|SR$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/rgs1\[0\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/rgs1\[1\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/rgs1\[2\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/rgs1\[3\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/rgs1\[4\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/rgs1\[5\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/rgs1\[6\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/rgs1\[7\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/rgs1\[8\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/rgs1\[9\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/rgs2\[0\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/rgs2\[1\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/rgs2\[2\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/rgs2\[3\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/rgs2\[4\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/rgs2\[5\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/rgs2\[6\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/rgs2\[7\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/rgs2\[8\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/rgs2\[9\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/rrs\[0\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/rrs\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/rrs\[0\]\~FF\|SR$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/wgs1\[0\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/wgs1\[1\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/wgs1\[2\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/wgs1\[3\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/wgs1\[4\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/wgs1\[5\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/wgs1\[6\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/wgs1\[7\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/wgs1\[8\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/wgs1\[9\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/wgs2\[0\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/wgs2\[1\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/wgs2\[2\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/wgs2\[3\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/wgs2\[4\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/wgs2\[5\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/wgs2\[6\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/wgs2\[7\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/wgs2\[8\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/wgs2\[9\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/wrs\[0\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/wrs\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/fifo/wrs\[0\]\~FF\|SR$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/over_sync\[0\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/over_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/prelease\[0\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/prelease\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/prelease\[0\]\~FF\|SR$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/prelease\[1\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/prelease\[1\]\~FF\|SR$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/push\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture/send\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/capture_fifo_faults\[0\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/descriptor_take\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/dropped_sync\[0\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/dropped_sync\[0\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/dropped_sync\[1\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/eng_finished\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/eng_published\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/eng_tx_start\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/engine/classification\[24\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/engine/result_base\[15\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/event_rejected\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/ever_run\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/exported\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/fault_reported\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/job_failed\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/lease/halted\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/packet/header\[1\]\~FF\|D$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/packet_abort\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/packet_done\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/packet_start\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/reserve_ack\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/reserve_denied\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/state\[0\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/state\[1\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/state\[2\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/state\[3\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/state\[4\]\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/transfer/client_accepted\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/tx_cancelled\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/tx_done\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
set one [get_pins -regexp {^u_m5b1/background/uart_release\~FF\|CE$}]
if {[llength $one]!=1} {error "BACKEND_PIN_NOT_SINGLETON"}
puts $f "[lindex $one 0]\t[get_nets $one]"
close $f
puts "FRESH_QUERY_COMPLETE 07_backend_connections"
