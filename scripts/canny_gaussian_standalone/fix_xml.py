from common import *
s=(R/'efinity/gaussian_shape_cap_i3/Ti60_Demo.xml').read_text()
s=re.sub(r'^\s*<efx:design_file[^\n]*\n','',s,flags=re.M)
entries=''.join('    <efx:design_file name="'+(R/f).as_posix()+'" version="'+('system_verilog' if f.endswith('.sv') else 'default')+'" library="default" />\n' for f in json.loads((O/'COMPILE_FILES.json').read_text()))
s=s.replace('    <efx:top_vhdl_arch',entries+'    <efx:top_vhdl_arch')
s=s.replace('F:/Projects/stareye_fpga/rtl/gaussian_integration/m5c',(R/'rtl/canny_gaussian_standalone/m5c').as_posix())
(P/'Ti60_Demo.xml').write_text(s,encoding='utf8')
