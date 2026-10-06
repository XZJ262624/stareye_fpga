onerror {quit -code 1 -force}
onbreak {
 set success 0
 foreach top {tb_m4_controls tb_m4_realtime tb_m4_colorize tb_m4_osd tb_m4_recovery tb_m4_stream tb_m4_hdmi_channels} {
  if {![catch {examine -radix unsigned sim:/$top/test_pass} value] && $value == 1} {set success 1}
 }
 if {$success == 1} {quit -code 0 -force} else {quit -code 1 -force}
}
run -all
quit -code 0 -force
