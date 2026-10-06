# ModelSim 10.1c can exit zero on $fatal; explicitly check the TB completion flag.
onerror {quit -f -code 1}
onbreak {if {[examine -radix decimal /tb_median_stream/test_pass] == 1} {quit -f -code 0} else {quit -f -code 1}}
run -all
if {[examine -radix decimal /tb_median_stream/test_pass] != 1} {quit -f -code 1}
quit -f -code 0
