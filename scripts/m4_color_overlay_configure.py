"""Create the M4 input-only copy, using frozen M32 enabled source hashes."""
from pathlib import Path
import hashlib,json,shutil,sys
from projectdb.db import EfxProjectDatabase
from projectdb.defines import DesignFile,Parameter
R=Path(__file__).resolve().parents[1]
W=R/'efinity/m4_color_overlay_i3';O=R/'reports/m4_color_overlay_i3'
resume=W.exists()
assert not resume or sys.argv[1:]==['--finish-new-copy'],'Refuse to overwrite a pre-existing M4 project'
assert not (W/'outflow').exists(),'Refuse to reconfigure a built project'
rows=json.loads((R/'reports/m32_median_integration_i3/m32_median_integration_enabled_i3/build/input_after.json').read_text())
prefix='efinity/m32_median_integration_enabled_i3/'
source=[x for x in rows if x['path'].startswith(prefix)]
assert len(source)==69
for x in source:
 p=R/x['path'];assert p.stat().st_size==x['bytes'] and hashlib.sha256(p.read_bytes()).hexdigest()==x['sha256']
 q=W/x['path'][len(prefix):]
 if not resume:q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
 elif q.name not in ('example_top.v','Ti60_Demo.xml'):assert q.read_bytes()==p.read_bytes()
# Dedicated minimal copies keep M31/M32 original source untouched.
N=R/'rtl/m4_color_overlay';N.mkdir(parents=True,exist_ok=True)
s=(R/'rtl/m31_sobel_controls/m31_controls.v').read_text().replace('module m31_controls','module m4_controls').replace('(pending_mode==2)?2\'d0','(pending_mode==3)?2\'d0')
(N/'m4_controls.v').write_text(s)
s=(R/'rtl/m31_sobel_controls/m31_osd.v').read_text().replace('module m31_osd','module m4_osd').replace('input [7:0] gray','input [23:0] rgb').replace('output reg [7:0] out_gray','output reg [23:0] out_rgb')
s=s.replace(' default:font=0;', ' "O":font={5\'b01110,5\'b10001,5\'b10001,5\'b10001,5\'b10001,5\'b10001,5\'b01110};\n "V":font={5\'b10001,5\'b10001,5\'b10001,5\'b10001,5\'b10001,5\'b01010,5\'b00100};\n default:font=0;')
s=s.replace('(mode==1)?"M":"B"','(mode==1)?"M":(mode==2)?"B":"O"').replace('(mode==1)?"A":"I"','(mode==1)?"A":(mode==2)?"I":"V"').replace('(mode==1)?"G":"N"','(mode==1)?"G":(mode==2)?"N":"R"')
s=s.replace('out_gray','out_rgb').replace('ink?8\'hff:8\'h00','ink?24\'hffffff:24\'h000000').replace('out_rgb<=gray','out_rgb<=rgb')
(N/'m4_osd.v').write_text(s)
p=W/'example_top.v';s=(R/prefix/'example_top.v').read_bytes().decode('utf-8')
s=s.replace('M32_FILTER_ENABLE=0','M4_FILTER_ENABLE=1').replace('m31_controls u_controls','m4_controls u_controls')
a=s.index('    wire [7:0] osd_gray,display_threshold;');b=s.index('\n\t//\tHDMI Interface.',a)
block='''    wire [23:0] display_rgb,osd_rgb;
    wire [7:0] display_threshold;
    wire [1:0] display_mode;
    wire osd_de,osd_hs,osd_vs;
    // One common delayed raster; OVR edges are centered on original RAW.
    m4_osd u_osd(.clk(clk_pixel),.arst_n(rstn_pixel),.rgb(display_rgb),
        .de(sobel_de),.hs(sobel_hs),.vs(sobel_vs),.threshold(display_threshold),
        .mode(display_mode),.out_rgb(osd_rgb),.out_de(osd_de),.out_hs(osd_hs),.out_vs(osd_vs));
    m4_stream_top #(.WIDTH(1280),.HEIGHT(720),.H_TOTAL(1650)) u_m4_stream (
        .clk(clk_pixel),.arst_n(rstn_pixel),.in_gray(lcd_gray),
        .in_de(lcd_de),.in_hs(lcd_hs),.in_vs(lcd_vs),.in_sof(~lcd_vs),
        .filter_request(M4_FILTER_ENABLE!=0),.threshold(control_threshold),.mode(control_mode),
        .out_de(sobel_de),.out_hs(sobel_hs),.out_vs(sobel_vs),.out_rgb(display_rgb),
        .out_raw(),.out_legacy(),.out_filter_enable(),.out_threshold(display_threshold),.out_mode(display_mode),
        .out_x(),.out_y(),.overlay_valid(),.overlay_edge(),.raster_fault());
'''.replace('\n','\r\n')
s=s[:a]+block+s[b:];s=s.replace('{3{osd_gray}}','osd_rgb')
p.write_bytes(s.encode('utf-8'))
db=EfxProjectDatabase();assert db.load(str(W/'Ti60_Demo.xml'))
assert (db.device_family,db.device_model,db.device_timing_model)==('Titanium','Ti60F225','I3')
db.design_file_list=[x for x in db.design_file_list if 'm31_sobel_controls' not in x.filepath]+[DesignFile('../../rtl/m4_color_overlay/'+x.name,'default','default') for x in sorted(N.glob('*.v'))]
db.synthesis_verilog_dyn_param_list=[Parameter('M4_FILTER_ENABLE','1',None)]
db.project_attr_list=[('last_run_state',''),('last_run_flow',''),('design_ood','new'),('place_ood','new'),('route_ood','new')]
assert db.save(str(W/'Ti60_Demo.xml'))
O.mkdir(parents=True,exist_ok=True)
(O/'CONFIGURATION.json').write_text(json.dumps(dict(official_api='projectdb.EfxProjectDatabase',base_project=prefix,source_inputs=source,default_median=1,physical_sources_preserved=True),indent=2))
print('M4_CONFIGURE_PASS copied_inputs=69')
