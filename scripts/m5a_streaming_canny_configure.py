"""Official projectdb configuration; physical M4 input files stay byte-identical."""
from pathlib import Path
import json,hashlib
from projectdb.db import EfxProjectDatabase
from projectdb.defines import DesignFile,Parameter
R=Path(__file__).resolve().parents[1];W=R/'efinity/m5a_streaming_canny_i3';N=R/'rtl/m5a_streaming_canny'
assert not (W/'outflow').exists(),'Do not reconfigure an implemented project'
p=W/'example_top.v';s=p.read_bytes().decode('utf-8')
s=s.replace('M4_FILTER_ENABLE','M5A_FILTER_ENABLE').replace('m4_controls u_controls','m5a_controls u_controls')
s=s.replace('wire [1:0] control_mode','wire [2:0] control_mode')
s=s.replace('wire [1:0] display_mode','wire [2:0] display_mode')
s=s.replace('m4_osd u_osd(.clk(clk_pixel),','m5a_osd u_osd(.clk(clk_pixel),.ce(1\'b1),')
s=s.replace('m5a_controls u_controls(.clk(clk_pixel),','m5a_controls u_controls(.clk(clk_pixel),.ce(1\'b1),')
s=s.replace('m4_stream_top #','m5a_stream_top #').replace('u_m4_stream (','u_m5a_stream (')
s=s.replace('u_m5a_stream (\r\n        .clk(clk_pixel),','u_m5a_stream (\r\n        .clk(clk_pixel),.ce(1\'b1),')
s=s.replace('.out_raw(),.out_legacy(),','.out_raw(),.out_legacy_mag(),.out_legacy_bin(),.out_nms(),')
s=s.replace('.overlay_valid(),.overlay_edge(),','.out_overlay_valid(),.out_overlay_edge(),.out_nms_valid(),.out_canny_valid(),.out_canny_edge(),')
assert 'm4_' not in s and s.count(".ce(1'b1)")==3,(s.count(".ce(1'b1)"))
p.write_bytes(s.encode())
db=EfxProjectDatabase();assert db.load(str(W/'Ti60_Demo.xml'))
assert (db.device_family,db.device_model,db.device_timing_model)==('Titanium','Ti60F225','I3')
db.design_file_list=[x for x in db.design_file_list if not x.filepath.startswith('../../rtl/')]+[DesignFile('../../rtl/m5a_streaming_canny/'+x.name,'default','default') for x in sorted(N.glob('*.v'))]
db.synthesis_verilog_dyn_param_list=[Parameter('M5A_FILTER_ENABLE','1',None)]
db.project_attr_list=[('last_run_state',''),('last_run_flow',''),('design_ood','new'),('place_ood','new'),('route_ood','new')]
assert db.save(str(W/'Ti60_Demo.xml'))
copied=json.loads((R/'reports/m5a_streaming_canny_i3/M4_COMMITTED_COPY.json').read_text())
for a in copied['files']:
 if Path(a['path']).name in ('example_top.v','Ti60_Demo.xml'):continue
 q=R/a['path'];assert hashlib.sha256(q.read_bytes()).hexdigest()==a['sha256']
(R/'reports/m5a_streaming_canny_i3/CONFIGURATION.json').write_text(json.dumps(dict(official_api='projectdb.EfxProjectDatabase',baseline=copied['commit'],default_median=1,physical_inputs_unchanged=67,top='example_top',device='Titanium/Ti60F225/FBGA225/I3',ce_hardware=1),indent=2))
print('M5A_CONFIGURE_PASS physical_inputs=67')
