puts "FRESH_QUERY_START 04_DSP_config"
set_timing_model I3
puts "ACTUAL_TIMING_MODEL [get_timing_model]"
if {[get_timing_model] ne "I3"} {error "WRONG_TIMING_MODEL"}
puts "SELECTED_STA_V5_START"
puts "ACTUAL_TIMING_MODEL [get_timing_model]"
if {[get_timing_model] ne "I3"} {error "WRONG_TIMING_MODEL"}
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[5\]$}]
if {[llength $one]!=1} {error "V5_PIN_NOT_SINGLETON"}
set plain [join $one " "]
puts "V5_BEGIN B5 setup"
puts "FRESH_REPORT_BEGIN 04_DSP_config 1"
report_timing -setup -through $plain -npaths 200 -nworst 1 -detail full_path -file v5_B5_setup.rpt
puts "FRESH_REPORT_END 04_DSP_config 1"
puts "V5_END B5 setup"
puts "V5_BEGIN B5 hold"
puts "FRESH_REPORT_BEGIN 04_DSP_config 2"
report_timing -hold -through $plain -npaths 200 -nworst 1 -detail full_path -file v5_B5_hold.rpt
puts "FRESH_REPORT_END 04_DSP_config 2"
puts "V5_END B5 hold"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[6\]$}]
if {[llength $one]!=1} {error "V5_PIN_NOT_SINGLETON"}
set plain [join $one " "]
puts "V5_BEGIN B6 setup"
puts "FRESH_REPORT_BEGIN 04_DSP_config 3"
report_timing -setup -through $plain -npaths 200 -nworst 1 -detail full_path -file v5_B6_setup.rpt
puts "FRESH_REPORT_END 04_DSP_config 3"
puts "V5_END B6 setup"
puts "V5_BEGIN B6 hold"
puts "FRESH_REPORT_BEGIN 04_DSP_config 4"
report_timing -hold -through $plain -npaths 200 -nworst 1 -detail full_path -file v5_B6_hold.rpt
puts "FRESH_REPORT_END 04_DSP_config 4"
puts "V5_END B6 hold"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[7\]$}]
if {[llength $one]!=1} {error "V5_PIN_NOT_SINGLETON"}
set plain [join $one " "]
puts "V5_BEGIN B7 setup"
puts "FRESH_REPORT_BEGIN 04_DSP_config 5"
report_timing -setup -through $plain -npaths 200 -nworst 1 -detail full_path -file v5_B7_setup.rpt
puts "FRESH_REPORT_END 04_DSP_config 5"
puts "V5_END B7 setup"
puts "V5_BEGIN B7 hold"
puts "FRESH_REPORT_BEGIN 04_DSP_config 6"
report_timing -hold -through $plain -npaths 200 -nworst 1 -detail full_path -file v5_B7_hold.rpt
puts "FRESH_REPORT_END 04_DSP_config 6"
puts "V5_END B7 hold"
set one [get_pins -regexp {^u_m5b1/fusion/reader/mult_23\|B\[8\]$}]
if {[llength $one]!=1} {error "V5_PIN_NOT_SINGLETON"}
set plain [join $one " "]
puts "V5_BEGIN B8 setup"
puts "FRESH_REPORT_BEGIN 04_DSP_config 7"
report_timing -setup -through $plain -npaths 200 -nworst 1 -detail full_path -file v5_B8_setup.rpt
puts "FRESH_REPORT_END 04_DSP_config 7"
puts "V5_END B8 setup"
puts "V5_BEGIN B8 hold"
puts "FRESH_REPORT_BEGIN 04_DSP_config 8"
report_timing -hold -through $plain -npaths 200 -nworst 1 -detail full_path -file v5_B8_hold.rpt
puts "FRESH_REPORT_END 04_DSP_config 8"
puts "V5_END B8 hold"
puts "SELECTED_STA_V5_COMPLETE"
puts "FRESH_QUERY_COMPLETE 04_DSP_config"
