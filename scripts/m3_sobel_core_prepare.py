"""Create an independent M3 project from the exact compiled M2 snapshot."""
from pathlib import Path
import hashlib,json,shutil
ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/'reports/m2_ar0135_ddr_hdmi_i3/final_build/source_snapshot'
DST=ROOT/'efinity/m3_sobel_core_i3'
REPORT=ROOT/'reports/m3_sobel_core_i3'
def digest(p): return hashlib.sha256(p.read_bytes()).hexdigest()
assert not DST.exists(), 'Refuse to overwrite an existing project'
shutil.copytree(SRC,DST)
baseline=[{'path':p.relative_to(SRC).as_posix(),'bytes':p.stat().st_size,'sha256':digest(p)} for p in sorted(SRC.rglob('*')) if p.is_file()]
assert len(baseline)==69 and sum(x['bytes'] for x in baseline)==2689858
assert all(digest(DST/x['path'])==x['sha256'] for x in baseline)
(REPORT/'seed_manifest.json').write_text(json.dumps(baseline,indent=2))
top=DST/'example_top.v'
s=top.read_bytes().decode('utf-8-sig')
s=s.replace('wire            [15:0]          lcd_data;','wire            [7:0]           lcd_data;\n\twire [7:0] lcd_gray, sobel_display_gray;\n\twire sobel_hs, sobel_vs, sobel_de;')
assert 'wire [7:0] lcd_gray' in s
s=s.replace('lcd_driver u_lcd_driver','lcd_driver #(.DATA_WIDTH(8)) u_lcd_driver')
s=s.replace('.lcd_rgb    ({lcd_red2,lcd_green2,lcd_blue2, lcd_red,lcd_green,lcd_blue})','.lcd_rgb    (lcd_gray)')
s=s.replace('.lcd_data   ({{3{lcd_data[15:8]}}, {3{lcd_data[7:0]}}}  )','.lcd_data   (lcd_data)')
marker='\t//\tHDMI Interface.'
assert s.count(marker)==1
insert='''    // M3: clk_pixel already owns the DDR FWFT read stream. The original
    // lcd_request and ~lcd_vs feedback remain untouched. Algorithm slot(x,y)
    // displays center(x-1,y-1); top two rows/left two columns are black.
    localparam [7:0] SOBEL_THRESHOLD = 8'd64;
    localparam [1:0] SOBEL_DISPLAY_MODE = 2'd2; // 0 raw, 1 magnitude, 2 binary
    sobel_stream_top #(.WIDTH(1280),.HEIGHT(720)) u_sobel_stream (
        .clk(clk_pixel),.arst_n(rstn_pixel),.in_gray(lcd_gray),
        .in_valid(lcd_de),.in_de(lcd_de),.in_hs(lcd_hs),.in_vs(lcd_vs),
        .in_sof(~lcd_vs),.threshold(SOBEL_THRESHOLD),.mode(SOBEL_DISPLAY_MODE),
        .out_de(sobel_de),.out_hs(sobel_hs),.out_vs(sobel_vs),
        .out_gray(sobel_display_gray),.edge_gray(),.edge_binary(),.out_valid(),
        .out_x(),.out_y(),.center_x(),.center_y());

'''
s=s.replace(marker,insert+marker)
s=s.replace('.vid_pVSync\t\t(lcd_vs)', '.vid_pVSync\t\t(sobel_vs)')
s=s.replace('.vid_pHSync\t\t(lcd_hs)', '.vid_pHSync\t\t(sobel_hs)')
s=s.replace('.vid_pVDE\t\t(lcd_de)', '.vid_pVDE\t\t(sobel_de)')
s=s.replace('.vid_pData\t\t({lcd_red, lcd_green, lcd_blue})', '.vid_pData\t\t({3{sobel_display_gray}})')
assert '.vid_pVDE\t\t(sobel_de)' in s and '.rframe_vsync   (~lcd_vs' in s
top.write_text(s,encoding='utf-8',newline='\n')
print('M3_SEED_PASS',len(baseline))
