"""Configure only the new M32 copies using the installed official project API."""
from pathlib import Path
import hashlib,json,shutil
from projectdb.db import EfxProjectDatabase
from projectdb.defines import DesignFile,Parameter
ROOT=Path(__file__).resolve().parents[1]
BASE=ROOT/'efinity/m32_median_integration_i3'
ENABLED=ROOT/'efinity/m32_median_integration_enabled_i3'
REPORT=ROOT/'reports/m32_median_integration_i3'
assert not ENABLED.exists(),'already configured: refusing any mutation'
assert b'm32_stream_top' not in (BASE/'example_top.v').read_bytes(),'base already configured: refusing any mutation'
REPORT.mkdir(parents=True,exist_ok=True)
NEW=ROOT/'rtl/m32_median_integration'
DELIVERY=ROOT/'handoff/review/m32_median_filter_delivery/task_workspace/rtl'
for name in ('median_3x3.v','median_stream_top.v'):
    shutil.copy2(DELIVERY/name,NEW/name)
top=BASE/'example_top.v'
text=top.read_bytes().decode('utf-8')
text=text.replace('module example_top \r\n','module example_top #(parameter M32_FILTER_ENABLE=0, parameter SIM_DATA=0)\r\n',1)
start=text.index('    wire [7:0] osd_gray;')
end=text.index('.out_x(),.out_y(),.center_x(),.center_y());',start)+len('.out_x(),.out_y(),.center_x(),.center_y());')
block='''    wire [7:0] osd_gray,display_threshold;
    wire [1:0] display_mode;
    wire osd_de,osd_hs,osd_vs;
    // M32: one-row/one-pixel center compensation precedes unchanged Sobel.
    // Compile parameter defaults to bypass; K1/K2 gestures are unchanged.
    m31_osd u_osd(.clk(clk_pixel),.arst_n(rstn_pixel),.gray(sobel_display_gray),
        .de(sobel_de),.hs(sobel_hs),.vs(sobel_vs),.threshold(display_threshold),
        .mode(display_mode),.out_gray(osd_gray),.out_de(osd_de),.out_hs(osd_hs),.out_vs(osd_vs));
    m32_stream_top #(.WIDTH(1280),.HEIGHT(720),.H_TOTAL(1650)) u_m32_stream (
        .clk(clk_pixel),.arst_n(rstn_pixel),.in_gray(lcd_gray),
        .in_de(lcd_de),.in_hs(lcd_hs),.in_vs(lcd_vs),.in_sof(~lcd_vs),
        .filter_request(M32_FILTER_ENABLE!=0),.threshold(control_threshold),.mode(control_mode),
        .out_de(sobel_de),.out_hs(sobel_hs),.out_vs(sobel_vs),
        .out_gray(sobel_display_gray),.raw_gray(),.edge_gray(),.edge_binary(),.out_valid(),
        .out_filter_enable(),.out_threshold(display_threshold),.out_mode(display_mode),
        .out_x(),.out_y(),.center_x(),.center_y());'''.replace('\n','\r\n')
text=text[:start]+block+text[end:]
assert 'module example_top #(parameter M32_FILTER_ENABLE=0, parameter SIM_DATA=0)' in text
text=text.replace('parameter \tSIM_DATA \t= 0;', '// SIM_DATA remains a top-level parameter with its verified default 0.')
top.write_bytes(text.encode('utf-8'))
p=EfxProjectDatabase();assert p.load(str(BASE/'Ti60_Demo.xml'))
assert (p.device_family,p.device_model,p.device_timing_model)==('Titanium','Ti60F225','I3')
p.design_file_list=list(p.design_file_list)+[DesignFile('../../rtl/m32_median_integration/'+f.name,'default','default') for f in sorted(NEW.glob('*.v'))]
p.project_attr_list=[('last_run_state',''),('last_run_flow',''),('design_ood','new'),('place_ood','new'),('route_ood','new')]
assert p.save(str(BASE/'Ti60_Demo.xml'))
assert not ENABLED.exists(),'enabled target must be new'
shutil.copytree(BASE,ENABLED)
q=EfxProjectDatabase();assert q.load(str(ENABLED/'Ti60_Demo.xml'))
q.synthesis_verilog_dyn_param_list=[Parameter('M32_FILTER_ENABLE','1',None)]
assert q.save(str(ENABLED/'Ti60_Demo.xml'))
records=[]
for work in (BASE,ENABLED):
    for f in sorted(work.rglob('*')):
        if f.is_file():records.append({'path':f.relative_to(ROOT).as_posix(),'bytes':f.stat().st_size,'sha256':hashlib.sha256(f.read_bytes()).hexdigest()})
(REPORT/'CONFIGURATION.json').write_text(json.dumps({'official_api':'projectdb.EfxProjectDatabase','default_filter':0,'enabled_variant_filter':1,'physical_configuration_regenerated':False,'files':records},indent=2)+'\n')
print('M32_CONFIGURE_PASS variants=2 physical_sources_preserved')
