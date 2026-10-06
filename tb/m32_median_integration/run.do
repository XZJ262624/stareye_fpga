onerror {quit -code 1}
onbreak {if {[examine -radix decimal sim:/tb_m32_stream/pass] != 1} {quit -code 1}; quit -code 0}
run -all
quit -code 1
