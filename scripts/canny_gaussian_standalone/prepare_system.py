from common import *
from gold import spatial
from collections import deque
D=O/'data';D.mkdir(exist_ok=True)
a=[192]*921600
for y in range(250,451):
 for x in range(200,901):a[y*1280+x]=102 if x<300 else 176
records=[]
for name,f,hi in [('med',1,64),('gau',2,64),('gau80',2,80)]:
 words,local=spatial(a,1280,720,f,hi,6);cl=[v>>92 for v in words];mask=bytearray(921600);q=deque()
 for i,c in enumerate(cl):
  if c==2:mask[i]=1;q.append(i)
 while q:
  i=q.popleft();y,x=divmod(i,1280)
  for dy in (-1,0,1):
   for dx in (-1,0,1):
    yy=y+dy;xx=x+dx
    if 0<=yy<720 and 0<=xx<1280:
     j=yy*1280+xx
     if cl[j] and not mask[j]:mask[j]=1;q.append(j)
 (D/(name+'.hex')).write_text(''.join(f'{v:024x}\n' for v in words));(D/(name+'_bfs.hex')).write_text(''.join(str(v)+'\n' for v in mask))
 r=dict(name=name,filter=f,high=hi,pixels=921600,local=sum(local),global_edges=sum(mask),global_added=sum(bool(mask[i] and not local[i]) for i in range(921600)))
 assert r['global_edges']>0
 records.append(r);print(r,flush=True)
save(O/'SYSTEM_GOLD.json',dict(cases=records,files=[rec(p) for p in D.iterdir()]))
s=(R/'tb/gaussian_integration/tb_gaussian_real.sv').read_text().replace('module tb_gaussian_real;','module tb_canny_system;')
a0=s.index(' initial begin wait(arst_n);');b=s.index('    wire shvalid',a0)
s=s[:a0]+''' integer med_healthy=0,gau_healthy=0,gau80_healthy=0,cov_healthy=0,off_frames=0,cyan=0,stage=0;
 task press(input [1:0] keys,input integer ticks);begin
  @(posedge pix_sof);repeat(100)@(negedge pix_clk);key_n=keys;repeat(ticks)@(negedge pix_clk);key_n=3;repeat(30)@(negedge pix_clk);
 end endtask
 initial begin
  wait(arst_n);repeat(80)@(negedge pix_clk);key_n=0;repeat(100)@(negedge pix_clk);key_n=3;
  wait(med_healthy>=1);stage=1;
  press(0,20);wait(selected_mode==3);wait(stable>med_healthy);
  press(0,20);wait(selected_mode==4);wait(gau_healthy>=1);stage=2;
  press(0,20);wait(selected_mode==5);press(0,20);wait(selected_mode==6);wait(cov_healthy>=1&&cyan>0);stage=3;
  press(2,20);wait(selected_threshold==80);wait(gau80_healthy>=1);stage=4;
  press(0,100);wait(!control_fusion);wait(off_frames>=1);stage=5;
  press(0,100);wait(control_fusion);wait(gau80_healthy>=2);stage=6;
 end
''' +s[b:]
a0=s.index('shape_pair_system_guard #');b=s.index('.ui_clk(ui_clk),.cam_clk(cam_clk)',a0)
s=s[:a0]+'canny_system dut('+s[b:]
a0=s.index('.diag_ready(diag_ui_ready)');b=s.index('  .aid(aid)',a0);s=s[:a0]+s[b:]
s=re.sub(r' defparam dut.background.packet.uart.CLOCK=[^\n]*\n','',s)
a0=s.index(' wire[1:0] shape_dc,shape_rc;');b=s.index(' wire[23:0] osd_rgb;',a0);s=s[:a0]+s[b:]
s=s.replace('shape_osd osd','canny_osd osd').replace('.shape_class(shape_dc),.shape_valid(visible),','')
s=re.sub(r' m5a_packet_delay #\(\.BITS\(2\),\.DELAY\(1652\)\) pair_class_delay[^\n]*\n','',s)
s=s.replace('reg source_good[0:31];','reg source_good[0:255];').replace('[0:31]','[0:255]')
s=s.replace('   if(visible)visible_pixels=visible_pixels+1;','')
a0=s.index('  if(shape_done)begin');b=s.index('  de_saved=out_de;',a0);s=s[:a0]+s[b:]
a0=s.index(' initial begin\n  wait(stable>=3)');s=s[:a0]+''' initial begin
  wait(stage==6);repeat(5000)@(negedge pix_clk);
  if(publications<3||med_healthy==0||gau_healthy==0||cov_healthy==0||gau80_healthy<2||off_frames==0||cyan==0||bs==0||rs==0)$fatal(1,"SYSTEM_COVERAGE");
  $display("PASS_CANNY_SYSTEM stable=%0d MEDhealthy=%0d GAUhealthy=%0d COVhealthy=%0d threshold80healthy=%0d off=%0d cyan=%0d publications=%0d B=%0d lastR=%0d pixel_gold=%0d",stable,med_healthy,gau_healthy,cov_healthy,gau80_healthy,off_frames,cyan,publications,bs,rs,final_pixels);$finish;
 end
 initial begin #4000000000;$fatal(1,"SYSTEM_WATCHDOG stage=%0d pubs=%0d med=%0d gau=%0d cov=%0d gau80=%0d",stage,publications,med_healthy,gau_healthy,cov_healthy,gau80_healthy);end
endmodule
`default_nettype wire
'''
s=s.replace('e=source_f[tap_frames]==2?gau_gold[tap_pos]:gold[tap_pos];','e=source_hi[tap_frames]==80?gau80_gold[tap_pos]:source_f[tap_frames]==2?gau_gold[tap_pos]:gold[tap_pos];')
s=s.replace('e=source_f[final_frames]==2?gau_gold[final_pos]:gold[final_pos];','e=source_hi[final_frames]==80?gau80_gold[final_pos]:source_f[final_frames]==2?gau_gold[final_pos]:gold[final_pos];')
s=s.replace('source_f[src_frames]=source_filter;','source_f[src_frames]=source_filter;source_hi[src_frames]=source_high;')
extra='''
 reg [7:0] source_hi[0:255];reg[93:0] gau80_gold[0:921599];reg[2047:0] path80,maskmed,maskgau,mask80;
 reg med_bfs[0:921599],gau_bfs[0:921599],gau80_bfs[0:921599];integer bs=0,rs=0,j,baseaddr;reg goldenbit;
 initial begin
  if(!$value$plusargs("GAU80=%s",path80)||!$value$plusargs("MED_BFS=%s",maskmed)||!$value$plusargs("GAU_BFS=%s",maskgau)||!$value$plusargs("GAU80_BFS=%s",mask80))$fatal(1,"BFS_ARGS");
  $readmemh(path80,gau80_gold);$readmemh(maskmed,med_bfs);$readmemh(maskgau,gau_bfs);$readmemh(mask80,gau80_bfs);
 end
 always @(posedge ui_clk)if(arst_n)begin
  if(bvalid&&bready)bs=bs+1;if(rvalid&&rready&&rlast)rs=rs+1;
  if(uart_tx!==1'b1)$fatal(1,"UNEXPECTED_UART_ACTIVITY");
  if(dut.background.publication_accept)begin
   baseaddr=dut.background.class_slot?32'h010c9000:32'h010ac000;
   for(j=0;j<921600;j=j+1)begin
    goldenbit=dut.background.frozen_extended[263:256]==80?gau80_bfs[j]:dut.background.frozen_extended[310:309]==2?gau_bfs[j]:med_bfs[j];
    if(memory.mem[(baseaddr>>4)+(j>>7)][j%128]!==goldenbit)$fatal(1,"REAL_PRODUCTION_BFS_MISMATCH pixel=%0d",j);
   end
   $display("REAL_PUBLICATION_BFS job=%0d filter=%0d high=%0d",dut.background.job_id,dut.background.frozen_extended[310:309],dut.background.frozen_extended[263:256]);
  end
 end
 integer framegood=0,framecyan=0,framered=0,old_config_reject=0;
 always @(posedge pix_clk)if(arst_n)begin
  if(out_de)begin
   if(out_x==0&&out_y==0)begin framegood=0;framecyan=0;framered=0;end
   if(fusion_frame_ok)framegood=framegood+1;
   if(fusion_eligible&&fusion_descriptor[735:576]!=fusion_config)$fatal(1,"OLD_CONFIG_ELIGIBLE");
   if(!control_fusion&&fusion_promoted)$fatal(1,"DISABLED_PROMOTED");
   if(out_mode==6&&final_fusion)begin
    if(out_ce)begin if(fused_rgb!==24'hff0000)$fatal(1,"LOCAL_RED_PRIORITY");framered=framered+1;end
    else if(fusion_promoted)begin if(fused_rgb!==24'h00ffff)$fatal(1,"PROMOTED_CYAN");framecyan=framecyan+1;cyan=cyan+1;end
    else if(fused_rgb!=={out_raw,out_raw,out_raw})$fatal(1,"FUSION_GRAY_ALIGNMENT");
   end
   if(out_x==1279&&out_y==719)begin
    if(framegood>900000&&source_good[final_frames-1])begin
     if(out_filter==1)med_healthy=med_healthy+1;
     if(out_filter==2&&out_threshold==64)gau_healthy=gau_healthy+1;
     if(out_mode==6&&framecyan>0&&framered>0)cov_healthy=cov_healthy+1;
     if(out_filter==2&&out_threshold==80)gau80_healthy=gau80_healthy+1;
     $display("REAL_HEALTHY filter=%0d high=%0d mode=%0d good=%0d cyan=%0d",out_filter,out_threshold,out_mode,framegood,framecyan);
    end
    if(!control_fusion&&!final_fusion&&framecyan==0)off_frames=off_frames+1;
   end
  end
 end
'''
s=s.replace(' initial begin\n  wait(stage==6)',extra+' initial begin\n  wait(stage==6)')
# Old ModelSim requires declarations before procedural references.
s=s.replace('module tb_canny_system;','module tb_canny_system;\n integer stable=0;\n reg [7:0] source_hi[0:255];reg[93:0] gau80_gold[0:921599];')
s=s.replace('final_pixels=0,stable=0,','final_pixels=0,')
s=s.replace(' reg [7:0] source_hi[0:255];reg[93:0] gau80_gold[0:921599];reg[2047:0] path80',' reg[2047:0] path80')
s=s.replace('cyan=0,stage=0;','cyan=0,stage=0,restore_target=0;')
s=s.replace('  press(0,100);wait(!control_fusion);','  off_frames=0;press(0,100);wait(!control_fusion);')
s=s.replace('  press(0,100);wait(control_fusion);wait(gau80_healthy>=2);','  restore_target=gau80_healthy+1;press(0,100);wait(control_fusion);wait(gau80_healthy>=restore_target);')
s=s.replace('framegood>900000&&source_good[final_frames-1]','framegood>900000')
(R/'tb/canny_gaussian_standalone/tb_canny_system.sv').write_text(s)
