from pathlib import Path
import subprocess,json,re,hashlib
ROOT=Path(__file__).resolve().parents[1];TB=ROOT/'tb/m31_sobel_controls';R=ROOT/'reports/m31_sobel_controls_i3/sim';R.mkdir(parents=True,exist_ok=True)
M=Path('E:/Modelsim_10.1c/win64');cmds=[]
def rec(p):return {'path':p.relative_to(ROOT).as_posix(),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
def run(args,name):
 with (R/name).open('wb') as f:p=subprocess.run([str(v) for v in args],cwd=TB,stdout=f,stderr=subprocess.STDOUT)
 text=(R/name).read_text(errors='replace');cmds.append({'command':[str(v) for v in args],'exit_code':p.returncode})
 assert p.returncode==0 and not re.search(r'\*\* (Fatal|Error):',text),text[-4000:]
 return text
top=(ROOT/'efinity/m31_sobel_controls_i3/example_top.v').read_text()
start=top.index('    wire [7:0] control_threshold;');end=top.index('.out_x(),.out_y(),.center_x(),.center_y());',start)+len('.out_x(),.out_y(),.center_x(),.center_y());')
block=top[start:end].replace('m31_controls u_controls','m31_controls #(.DEBOUNCE_CYCLES(4)) u_controls').replace('.WIDTH(1280),.HEIGHT(720)','.WIDTH(160),.HEIGHT(40)')
(TB/'generated_link.v').write_text('module m31_link(input clk_pixel,rstn_pixel,input[1:0] key_n,input[7:0] lcd_gray,input lcd_de,lcd_hs,lcd_vs,output[7:0] result,output rd,rh,rv);\nwire[7:0] sobel_display_gray;wire sobel_de,sobel_hs,sobel_vs;\n'+block+'\nassign result=osd_gray;assign rd=osd_de;assign rh=osd_hs;assign rv=osd_vs;\nendmodule\n')
sources=sorted((ROOT/'rtl/m31_sobel_controls').glob('*.v'))+sorted((ROOT/'rtl/m3_sobel_core').glob('*.v'))+sorted(TB.glob('*.sv'))+[TB/'generated_link.v'];before=[rec(p) for p in sources]+[rec(ROOT/'efinity/m31_sobel_controls_i3/example_top.v'),rec(Path(__file__))]
if not (TB/'work').exists():run([M/'vlib.exe','work'],'vlib.log')
run([M/'vlog.exe','-sv','-work','work',*sources],'vlog.log')
for name in ['controls','osd','link','realtime']:
 text=run([M/'vsim.exe','-c','-novopt','work.tb_'+name,'-do','onerror {quit -code 1}; run -all; quit -code 0'],'%s.log'%name)
 assert 'M31_'+name.upper()+'_PASS' in text
# Independent compact font oracle expressed as hexadecimal rows.
font={
'0':'0e 11 13 15 19 11 0e','1':'04 0c 04 04 04 04 0e','2':'0e 11 01 02 04 08 1f','3':'1e 01 01 0e 01 01 1e',
'4':'02 06 0a 12 1f 02 02','5':'1f 10 10 1e 01 01 1e','6':'0e 10 10 1e 11 11 0e','7':'1f 01 02 04 08 08 08',
'8':'0e 11 11 0e 11 11 0e','9':'0e 11 11 0f 01 01 0e','R':'1e 11 11 1e 14 12 11','A':'0e 11 11 1f 11 11 11',
'W':'11 11 11 15 15 15 0a','M':'11 1b 15 15 11 11 11','G':'0e 11 10 17 11 11 0e','B':'1e 11 11 1e 11 11 1e',
'I':'0e 04 04 04 04 04 0e','N':'11 19 19 15 13 13 11','T':'1f 04 04 04 04 04 04',' ':'00 00 00 00 00 00 00'}
font={k:[int(v,16) for v in s.split()] for k,s in font.items()}
count=0
for line in (TB/'osd_pixels.txt').open():
 t,x,y,value=map(int,line.split());expected=0
 if 16<=x<144 and 16<=y<30:
  col=(x-16)%16//2;slot=(x-16)//16;row=(y-16)//2
  label=['RAW','MAG','BIN'][t%3]+' T'+f'{t:03d}'
  if col<5:expected=255*((font[label[slot]][row]>>(4-col))&1)
 assert value==expected,(t,x,y,value,expected)
 count+=1
assert count==256*136*22
# End-to-end spatial Sobel oracle plus exact six sampling-stage raster delay.
from collections import deque
q=deque([(0,0,1,1)]*5);pixels=[];x=y=0;last_vs=1;last_de=0;link_count=0
for line in (TB/'link_pixels.txt').open():
 g,d,h,v,m,t,actual,od,oh,ov=map(int,line.split())
 if last_vs and not v:pixels=[];x=y=0
 if last_de and not d:x=0;y+=1
 value=0
 if d:
  pixels.append(g);edge=0
  if x>=2 and y>=2:
   p=[[pixels[(y-2+dy)*160+x-2+dx] for dx in range(3)] for dy in range(3)]
   gx=-p[0][0]+p[0][2]-2*p[1][0]+2*p[1][2]-p[2][0]+p[2][2]
   gy=p[0][0]+2*p[0][1]+p[0][2]-p[2][0]-2*p[2][1]-p[2][2]
   edge=min(255,abs(gx)+abs(gy))
  value=g if m==0 else edge if m==1 else (255 if x>=2 and y>=2 and edge>=t else 0)
  if 12<=x<148 and 12<=y<34:
   value=0
   if 16<=x<144 and 16<=y<30:
    col=(x-16)%16//2;slot=(x-16)//16;row=(y-16)//2;label=['RAW','MAG','BIN'][m]+' T'+f'{t:03d}'
    if col<5:value=255*((font[label[slot]][row]>>(4-col))&1)
  x+=1
 q.append((value,d,h,v));expected=q.popleft()
 assert (actual,od,oh,ov)==expected,('LINK',link_count,(actual,od,oh,ov),expected,x,y)
 last_vs=v;last_de=d;link_count+=1
out={'commands':cmds,'source_before':before,'source_after':[rec(p) for p in sources]+[rec(ROOT/'efinity/m31_sobel_controls_i3/example_top.v'),rec(Path(__file__))],'artifacts':[rec(p) for p in sorted(R.glob('*.log'))]+[rec(TB/'osd_pixels.txt'),rec(TB/'link_pixels.txt')],'link_checked_cycles':link_count,'link_frames':9,'osd_checked_pixels':count,'all_raster_pixels':256*160*40}
assert out['source_before']==out['source_after']
(R/'binding.json').write_text(json.dumps(out,indent=2));print('M31_SIM_PASS',count)
