from pathlib import Path
import re,json,hashlib
R=Path(__file__).resolve().parents[1];B=R/'reports/m5c_shadow_stats_20261016/differential_fixture';B.mkdir()
base=json.loads((B.parent/'BASELINE.json').read_text());records=[]
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
for name in ['m5c_row_fusion','m5c_fusion_display']:
 x=next(x for x in base['technical'] if x['path'].endswith('/'+name+'.sv'));p=R/x['snapshot'];assert rec(p)['sha256']==x['sha256'];s=p.read_text()
 for n in ['m5c_row_fusion','m5c_fusion_display']:s=re.sub(r'\b'+n+r'\b','baseline178_'+n,s)
 out=B/('baseline178_'+name+'.sv');out.write_text(s);records.append(dict(original=x,derived=rec(out),scope='Module/type symbol rename only'))
tb=R/'tb/m5c_diagnostics/tb_shadow_coupled.sv';s=tb.read_text().replace('tb_shadow_coupled','tb_shadow_differential')
instance=re.search(r' m5c_fusion_display display\((.*?)\);',s,re.S)[1]
header=(B/'baseline178_m5c_fusion_display.sv').read_text().split(');',1)[0]
# Each original output gets separate wires on both sides; inputs share exact stimulus.
outputs={}
for line in header.splitlines():
 for m in re.finditer(r'output\s+(?:wire\s+|reg\s+)?(\[[^]]+\])?\s*([^;]*?)(?=,\s*(?:input|output)|$)',line):
  width=m[1] or '';names=m[2].rstrip(',').split(',')
  for n in names:
   n=n.strip();assert re.fullmatch(r'\w+',n),(line,n);outputs[n]=width
assert len(outputs)>25,outputs
ports=dict(re.findall(r'\.(\w+)\((.*?)\)',instance,re.S));decl=[];inst=[];comparisons=[]
for mode in range(7):
 for enabled in (0,1):
  tag=f'm{mode}e{enabled}'
  for side,mod in [('old','baseline178_m5c_fusion_display'),('new','m5c_fusion_display')]:
   args=[]
   for port,value in ports.items():
    if port.startswith('diag_shadow') or port in ('diag_strong_loss','diag_illegal'):continue
    if port in outputs:
     value=f'{tag}_{side}_{port}';decl.append(f'wire {outputs[port]} {value};')
    elif port=='mode':value=f"3'd{mode}"
    elif port=='enable':value=f"1'b{enabled}"
    args.append('.'+port+'('+value+')')
   inst.append(mod+' '+tag+'_'+side+'('+','.join(args)+');')
  for port in outputs:comparisons.append(f'if({tag}_old_{port} !== {tag}_new_{port}) $fatal(1,"BASELINE178_DIFFERENTIAL {tag} {port}");')
  for side in ('old','new'):
   decl.append(f'wire [23:0] {tag}_{side}_osd_rgb; wire {tag}_{side}_osd_de;')
   inst.append(f"m5a_osd {tag}_{side}_osd(.clk(pix_clk),.ce(ce),.arst_n(rst_n),.rgb({tag}_{side}_fused_rgb),.de(final_de),.hs(1'b1),.vs(!raw_sof),.threshold(8'd64),.mode(3'd{mode}),.fusion_enable(1'b{enabled}),.fusion_active({tag}_{side}_frame_ok),.fusion_age_valid({tag}_{side}_eligible),.fusion_age(32'd1),.out_rgb({tag}_{side}_osd_rgb),.out_de({tag}_{side}_osd_de),.out_hs(),.out_vs());")
  comparisons.append(f'if({tag}_old_osd_rgb !== {tag}_new_osd_rgb || {tag}_old_osd_de !== {tag}_new_osd_de) $fatal(1,"BASELINE178_OSD {tag}");')
extra='\n'.join(decl+inst)+'''\ninteger differential_pixels=0;
always @(posedge pix_clk) begin
 if(rst_n&&ce&&final_de)differential_pixels=differential_pixels+1;
 #2;if(rst_n)begin
'''+ '\n'.join(comparisons)+'\nend end\n'
s=s.replace(' $display("CACHE_CONTEXT_PASS', ' $display("CACHE_CONTEXT_PASS')
s=s.replace('$finish;', '$display("BASELINE178_DIFF_PASS pixels=%0d modes=7 enable_states=2",differential_pixels); if(differential_pixels!=921600)$fatal(1,"DIFFERENTIAL_PIXEL_COVERAGE"); $finish;')
s=s.replace('endmodule',extra+'endmodule');out=B/'tb_shadow_differential.sv';out.write_text(s)
runner=(R/'scripts/m5c_shadow_run_coupled.py').read_text().replace("('coupled_'+","('differential_'+").replace("R/'tb/m5c_diagnostics/tb_shadow_coupled.sv'","R/'reports/m5c_shadow_stats_20261016/differential_fixture/tb_shadow_differential.sv',R/'reports/m5c_shadow_stats_20261016/differential_fixture/baseline178_m5c_fusion_display.sv',R/'reports/m5c_shadow_stats_20261016/differential_fixture/baseline178_m5c_row_fusion.sv'").replace("'tb_shadow_coupled'","'tb_shadow_differential'").replace('timeout=180','timeout=600')
(R/'scripts/m5c_shadow_run_differential.py').write_text(runner)
(B/'DERIVATION.json').write_text(json.dumps(dict(baseline_modules=records,parent_tb=rec(tb),derived_tb=rec(out),outputs=outputs,scope='14 simultaneous baseline/current display pairs, same physical accepted reference stimulus; all original outputs and separately instantiated OSD compared each edge; seven modes and enable0/1. Original coupled720p/UART checks retained. Does not claim separate backend instance equivalence.'),indent=2));print('PREPARED',len(outputs))
