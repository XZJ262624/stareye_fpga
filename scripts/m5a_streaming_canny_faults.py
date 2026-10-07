"""Real isolated RTL mutations: each must compile, execute HDL, then fail a check."""
from pathlib import Path
import hashlib,json,re,subprocess
R=Path(__file__).resolve().parents[1];O=R/'reports/m5a_streaming_canny_i3/negative_cases';O.mkdir(exist_ok=True)
T=R/'tb/m5a_streaming_canny';M=Path('E:/Modelsim_10.1c/win64')
def rec(p):return dict(path=p.relative_to(R).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
prod=[p for d in ('rtl/m5a_streaming_canny','rtl/m3_sobel_core','rtl/m32_median_integration','rtl/m4_color_overlay') for p in (R/d).glob('*.v')]+list(T.glob('*.sv'))+[R/'efinity/m5a_streaming_canny_i3/src/hdmi_ip'/n for n in ('rgb2dvi.v','tmds_channel.v')]
before=[rec(p) for p in prod];mutants=[]
def add(name,file,old,new,top='tb_m5a_stream',stall=False):mutants.append((name,file,[(old,new)],top,stall))
add('directions_45_135_swapped','m5a_direction.v',"(gx[10]==gy[10])?2'd1:2'd3","(gx[10]==gy[10])?2'd3:2'd1",'tb_m5a_units')
add('angle_equality_wrong','m5a_direction.v','y256<=x106','y256<x106','tb_m5a_units')
add('nms_wrong_neighbor','m5a_nms.v','negative_neighbor=p10[11:0]','negative_neighbor=p01[11:0]','tb_m5a_windows')
add('nms_direction_one_early','m5a_sobel_stream.v','out_direction<=direction_mag','out_direction<=direction_now')
mutants.append(('nms_direction_one_late','m5a_sobel_stream.v',[
 ('reg [1:0] direction_mag;','reg [1:0] direction_mag,direction_late;\n always @(posedge clk or negedge rst_n) if(!rst_n)direction_late<=0;else if(ce)direction_late<=direction_mag;'),
 ('out_direction<=direction_mag','out_direction<=direction_late')],'tb_m5a_stream',False))
add('high_low_threshold_swapped','m5a_dual_threshold.v','nms>={4\'b0,high_threshold}','nms>={4\'b0,low_threshold}','tb_m5a_units')
add('zero_magnitude_strong','m5a_dual_threshold.v','support && nms!=0 && nms>=','support && nms>=','tb_m5a_units')
add('unconnected_weak_kept','m5a_local_hysteresis.v','p11[0] && nearby','p11[0]','tb_m5a_windows')
add('four_neighbors_only','m5a_local_hysteresis.v','p00[1] || p01[1] || p02[1] || p10[1] || p12[1] || p20[1] || p21[1] || p22[1]','p01[1] || p10[1] || p12[1] || p21[1]','tb_m5a_windows')
add('previous_frame_strong_leak','m5a_local_hysteresis.v','wire nearby=',
 'reg old_strong,frame_strong,sof_previous;\n always @(posedge clk or negedge rst_n) if(!rst_n)begin old_strong<=0;frame_strong<=0;sof_previous<=0;end else if(ce)begin sof_previous<=in_sof;if(in_sof && !sof_previous)begin old_strong<=frame_strong;frame_strong<=0;end else if(strong_edge)frame_strong<=1;end\n wire nearby=old_strong || ','tb_m5a_windows')
mutants.append(('raw_background_one_late','m5a_stream_top.v',[
 ('wire rst_n=reset_release[1];','wire rst_n=reset_release[1];\n reg[7:0] raw_previous;always @(posedge clk or negedge rst_n)if(!rst_n)raw_previous<=0;else if(ce)raw_previous<=out_raw;'),
 ('.raw(out_raw)','.raw(raw_previous)')],'tb_m5a_stream',False))
add('rgb_channel_swap','m5a_colorize.v',"24'hff0000","24'h0000ff")
add('boundary_false_red','m5a_colorize.v',"6:rgb=(canny_valid && canny_edge)","6:rgb=(canny_edge || !canny_valid)")
add('midframe_mode_switch','m5a_controls.v','if(frame_start) begin threshold<=pending_threshold;mode<=pending_mode;end','begin threshold<=pending_threshold;mode<=pending_mode;end','tb_m5a_controls')
add('legacy_mag_changed','m5a_colorize.v','1:rgb={3{legacy_mag}}','1:rgb=0')
add('osd_priority_lost','m5a_osd.v',"ink?24'hffffff:24'h000000",'rgb')
add('nms_platform_both_inclusive','m5a_nms.v','p11[11:0]>negative_neighbor','p11[11:0]>=negative_neighbor','tb_m5a_windows')
add('packet_ram_ignores_ce','m5a_packet_delay.v','if(rst_n && ce) begin','if(rst_n) begin','tb_m5a_stream',True)
add('window_ram_ignores_ce','m5a_neighborhood.v','if(rst_n && ce && !in_sof)','if(rst_n && !in_sof)','tb_m5a_windows')
add('hdmi_wrong_red_lane','rgb2dvi.v','vid_pData[23:16]','vid_pData[7:0]','tb_m5a_hdmi_channels')
results=[]
for name,file,changes,top,stall in mutants:
 d=O/name;d.mkdir(exist_ok=True);src=d/'sources';src.mkdir(exist_ok=True);copied=[];found=0
 for p in prod:
  s=p.read_text()
  if p.name==file:
   found+=1
   for a,b in changes:assert a in s,(name,a);s=s.replace(a,b,1)
  q=src/p.name;q.write_text(s);copied.append(q)
 assert found==1,(name,found)
 def tool(cmd,filename):
  log=d/filename
  with log.open('wb') as f:r=subprocess.run(list(map(str,cmd)),cwd=d,stdout=f,stderr=subprocess.STDOUT,timeout=600)
  return r.returncode,log.read_text(errors='replace')
 if not(d/'work').exists():assert tool([M/'vlib.exe','work'],'vlib.log')[0]==0
 code,log=tool([M/'vlog.exe','-sv','-work','work',*copied],'compile.log');assert code==0 and '** Error:' not in log,(name,log[-2000:])
 cmd=[M/'vsim.exe','-c','-novopt','-onfinish','stop','work.'+top]
 if top=='tb_m5a_stream':cmd+=['-gFRAMES='+('4' if stall else '26'),'-gSTALL='+str(int(stall)),'+DIR='+str(R/'reports/m5a_streaming_canny_i3/sim/generated'/('stall' if stall else 'small'))]
 elif top=='tb_m5a_windows':cmd+=['+DIR='+str(R/'reports/m5a_streaming_canny_i3/sim/generated/windows')]
 cmd+=['-do',T/'run.do'];code,log=tool(cmd,'run.log')
 assert code!=0 and '** Fatal:' in log and 'Loading work.'+top in log,(name,code,log[-3000:])
 results.append(dict(name=name,rejected=True,exit_code=code,command=list(map(str,cmd)),mutation=dict(file=file,replacements=changes),sources=[rec(p) for p in copied],compile_log=rec(d/'compile.log'),log=rec(d/'run.log'),diagnostic=next(x for x in log.splitlines() if '** Fatal:' in x)))
 print('M5A_RTL_MUTANT_REJECTED',name,flush=True)
assert before==[rec(p) for p in prod]
(O.parent/'RTL_FAULT_RESULTS.json').write_text(json.dumps(dict(status='PASS',count=len(results),production_sources_before=before,production_sources_after=before,script=rec(Path(__file__)),cases=results),indent=2));print('M5A_FAULTS_PASS',len(results),flush=True)
