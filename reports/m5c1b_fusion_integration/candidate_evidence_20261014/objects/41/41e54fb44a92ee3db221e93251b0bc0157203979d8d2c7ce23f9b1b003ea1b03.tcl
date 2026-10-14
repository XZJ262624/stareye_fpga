puts "FRESH_QUERY_START 05_clock_pairs"
set_timing_model I3
puts "ACTUAL_TIMING_MODEL [get_timing_model]"
if {[get_timing_model] ne "I3"} {error "WRONG_TIMING_MODEL"}
set ci 0
foreach a [get_clocks {*}] {foreach b [get_clocks {*}] {
puts "CLOCK_PAIR $ci $a $b"
puts "FRESH_REPORT_BEGIN 05_clock_pairs 1"
report_timing -setup -from_clock $a -to_clock $b -npaths 1 -nworst 1 -detail full_path -file clock_${ci}_setup.rpt
puts "FRESH_REPORT_END 05_clock_pairs 1"
puts "FRESH_REPORT_BEGIN 05_clock_pairs 2"
report_timing -hold -from_clock $a -to_clock $b -npaths 1 -nworst 1 -detail full_path -file clock_${ci}_hold.rpt
puts "FRESH_REPORT_END 05_clock_pairs 2"
incr ci
}}
puts "FRESH_QUERY_COMPLETE 05_clock_pairs"
