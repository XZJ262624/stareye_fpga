from pathlib import Path
import json,hashlib,re
from m3_sobel_core_sim import ROOT,REPORT,TB,MODELSIM,run
netlist=ROOT/'efinity/m3_sobel_core_i3/outflow/Ti60_Demo.map.v'
models=Path('E:/Efinity/2025.1/sim_models/verilog')
primitive_files=[models/('efx_'+n+'.v') for n in ('ff','lut4','add','srl8','ram10')]
# The tail contains unused encrypted IP declarations. The fully mapped first
# module uses only the five official primitives listed above. Extract it byte
# for byte without interpreting, replacing, or decrypting the protected tail.
generated=TB/'generated';generated.mkdir(exist_ok=True)
mapped_module=generated/'mapped_top.v'
data=netlist.read_bytes();end=re.search(rb'^endmodule\s*$',data,re.M)
assert end
module=data[:end.end()]
# The protected DDR cell is outside the forced LCD/reset boundary. Remove only
# its instance in the simulation copy, leaving its nets undriven. This is a
# RAM-path gate simulation, not a DDR or complete-board gate simulation.
module,count=re.subn(rb'    protected_cell protected_inst \(.*?\);',b'    // Unrelated encrypted DDR instance isolated for RAM-path test.',module,flags=re.S)
assert count==1
mapped_module.write_bytes(module+b'\n')
run([MODELSIM/'vlog.exe','-sv','-timescale','1ns/1ps','-work','work',*primitive_files,mapped_module,TB/'tb_mapped_ram.sv'],REPORT/'mapped_vlog.log')
run([MODELSIM/'vsim.exe','-c','-novopt','work.tb_mapped_ram','-do','run -all; quit -f -code 0'],REPORT/'mapped.log')
text=(REPORT/'mapped.log').read_text(errors='replace')
m=re.search(r'HDL_MAPPED_RAM_PASS pixels=(\d+) top_row_checks=(\d+) cycles=(\d+)',text)
assert m and int(m[1])==26882 and int(m[2])==16642,text[-4000:]
def rec(p):return {'path':str(p),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
instances=re.findall(rb'EFX_RAM10 (\\u_sobel_stream/u_lines/row[12]__D\$[12])\s+\(',data)
assert len(instances)==4
configuration=[]
for inst in instances:
    params={}
    for key in ('READ_WIDTH','WRITE_WIDTH','OUTPUT_REG','WRITE_MODE'):
        found=re.search(rb'defparam '+re.escape(inst)+rb' \.'+key.encode()+rb' = ([^;]+);',data)
        assert found
        params[key]=found[1].decode()
    assert params=={'READ_WIDTH':'4','WRITE_WIDTH':'4','OUTPUT_REG':"1'b0",'WRITE_MODE':'"READ_FIRST"'}
    configuration.append({'instance':inst.decode(),'parameters':params})
result={'pass':True,'scope':'actual mapped line-buffer path; unrelated protected DDR instance isolated in simulation copy','pixels':int(m[1]),'top_row_checks':int(m[2]),'cycles':int(m[3]),'final_mapped_netlist':rec(netlist),'simulation_copy':rec(mapped_module),'official_simulation_models':[rec(p) for p in primitive_files],'logical_line_buffers':2,'physical_ram_blocks':len(instances),'actual_ram_configuration':configuration,'testbench':rec(TB/'tb_mapped_ram.sv')}
(REPORT/'mapped_summary.json').write_text(json.dumps(result,indent=2));print('M3_MAPPED_RAM_PASS',m.group(0))
