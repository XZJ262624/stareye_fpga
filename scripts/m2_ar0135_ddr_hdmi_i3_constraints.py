from pathlib import Path
from projectdb.db import EfxProjectDatabase
from projectdb.defines import IPSrcFile
w=Path('F:/Projects/stareye_fpga/efinity/m2_ar0135_ddr_hdmi_i3')
p=EfxProjectDatabase(); assert p.load(str(w/'Ti60_Demo.xml')); ips=p.ip_instance_list
for ip in ips:
 if ip.instance_name in ['DdrCtrl','W0_FIFO_8']: ip.src_files=[IPSrcFile(ip.instance_name+'.sv')]
p.ip_instance_list=ips; assert p.save(str(w/'Ti60_Demo.xml'))
s=(w/'outflow/Ti60_Demo.pt.sdc').read_text().replace('create_clock -period <USER_PERIOD> -name cmos_pclk','create_clock -period 10.000 -name cmos_pclk')
s+='\n# M2 clock-domain budgets. CMOS 100 MHz is inherited timing budget, not measured PCLK.\n'
s+='set_max_delay -from [get_clocks {core_clk}] -to [get_clocks {clk_sys}] 4.5\nset_max_delay -from [get_clocks {clk_sys}] -to [get_clocks {core_clk}] 4.5\n'
# Initial build retains only video asynchronous boundaries. No DDR clock-group blanket cut.
for a,b in [('clk_sys','clk_pixel'),('clk_sys','cmos_pclk')]:
 s+=f'set_false_path -from [get_clocks {{{a}}}] -to [get_clocks {{{b}}}]\nset_false_path -from [get_clocks {{{b}}}] -to [get_clocks {{{a}}}]\n'
s=s.replace('create_clock -period 10.417 -name clk_sys','create_clock -period 10.416 -name clk_sys')
line='create_clock -period 10.000 -name cmos_pclk [get_ports {cmos_pclk}]'
s=s.replace(line,'# CMOS clock definition moved before its input delays.')
s=s.replace('# GPIO Constraints',line+'\n# GPIO Constraints')
s+='\n# sys/core/DDR share PLL reference: 10.416=2*5.208=4*2.604 ns.\n# Conservative common precision avoids false 1 ps relationships from independent rounding.\n'
(w/'Ti60_Demo_I3.sdc').write_text(s)
print('PREBUILD_READY')
