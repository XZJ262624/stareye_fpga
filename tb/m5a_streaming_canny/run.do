onerror {quit -code 1 -force}
onbreak {
 set success 0
 foreach top {tb_m5a_stream tb_m5a_units tb_m5a_windows tb_m5a_controls tb_m5a_osd tb_m5a_realtime tb_m5a_recovery tb_m5a_hdmi_channels} {
  if {![catch {examine -radix unsigned sim:/$top/test_pass} value] && $value == 1} {set success 1}
 }
 if {$success == 1} {quit -code 0 -force} else {quit -code 1 -force}
}
run -all
quit -code 1 -force
