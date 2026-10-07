"""Create an input-only M5A copy from the committed M4 tree; never overwrite."""
from pathlib import Path
import hashlib,json,re,subprocess
R=Path(__file__).resolve().parents[1]
BASE='95bf83f7172ecdf11ee9b8deb3e2c1bba535a56d'
W=R/'efinity/m5a_streaming_canny_i3';N=R/'rtl/m5a_streaming_canny'
G=['git','-c','safe.directory=F:/Projects/stareye_fpga']
def git(*a):return subprocess.check_output(G+list(a),cwd=R)
def blob(p):return git('show',BASE+':'+p)
def main():
 assert not W.exists() and not N.exists(),'Refuse to overwrite M5A'
 paths=git('ls-tree','-r','--name-only',BASE,'efinity/m4_color_overlay_i3').decode().splitlines()
 assert len(paths)==69,len(paths)
 records=[]
 for p in paths:
  b=blob(p);q=W/Path(p).relative_to('efinity/m4_color_overlay_i3');q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(b)
  records.append(dict(source=p,path=q.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest()))
 names={'line_buffer_3x3':'m5a_line_buffer','window_3x3':'m5a_window','sobel_3x3':'m5a_sobel','edge_threshold':'m5a_legacy_threshold','sobel_stream_top':'m5a_sobel_stream','median_3x3':'m5a_median','median_stream_top':'m5a_median_stream','raster_packet_delay':'m5a_packet_delay','m32_stream_top':'m5a_m32_stream','m4_controls':'m5a_controls','m4_osd':'m5a_osd'}
 N.mkdir(parents=True)
 for p in git('ls-tree','-r','--name-only',BASE,'rtl').decode().splitlines():
  old=Path(p).stem
  if old not in names:continue
  s=blob(p).decode().replace('\r\n','\n')
  for a,b in names.items():s=re.sub(r'\b'+a+r'\b',b,s)
  s=s.replace('input clk,','input clk,input ce,').replace('.clk(clk),','.clk(clk),.ce(ce),')
  # Only outer sequential branches are enabled. Nested data-path branches retain semantics.
  s=s.replace('end else begin','end else if (ce) begin').replace('else begin','else if (ce) begin')
  # Undo duplicated enable introduced by the second literal replacement.
  s=s.replace('end else if (ce) if (ce) begin','end else if (ce) begin')
  # Compact outer branches in several original modules.
  s=s.replace('else value <=','else if (ce) value <=').replace('else value<=','else if (ce) value<=').replace('else valid_pipe<=','else if (ce) valid_pipe<=')
  s=s.replace('end else if (ce) begin: unpaired','end else begin: unpaired')
  s=s.replace('No stall/CE.','All stages stall when CE=0.').replace('Fixed-clock delay.','CE-tick delay.')
  s=s.replace('if (rst_n && !in_sof)','if (rst_n && ce && !in_sof)').replace('if(rst_n) begin','if(rst_n && ce) begin')
  # All mode tags expand without changing the original 0..3 encoding.
  if old in ('sobel_stream_top','m32_stream_top','m4_controls','m4_osd'):
   s=re.sub(r'\[1:0\](\s+)(mode|out_mode|pending_mode|mode_pipe|aligned_mode)\b',r'[2:0]\1\2',s)
  if old=='m4_controls':s=s.replace("(pending_mode==3)?2'd0:pending_mode+2'd1","(pending_mode==6)?3'd0:pending_mode+3'd1")
  if old=='m32_stream_top':
   s=s.replace('wire [22:0] packet','wire [23:0] packet').replace('.BITS(23)','.BITS(24)').replace('packet[22:15]','packet[23:16]').replace('packet[14:7]','packet[15:8]').replace('packet[6:5]','packet[7:5]')
  s='// M5A-only CE adaptation of committed '+p+'.\n'+s
  (N/(names[old]+'.v')).write_text(s)
 O=R/'reports/m5a_streaming_canny_i3';O.mkdir(parents=True,exist_ok=True)
 (O/'M4_COMMITTED_COPY.json').write_text(json.dumps(dict(commit=BASE,files=records),indent=2))
 print('M5A_PREPARE_PASS committed_inputs',len(records))
if __name__=='__main__':main()
