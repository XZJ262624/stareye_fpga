from common import *
s=(R/'tb/canny_replay/tb_replay.sv').read_text()
s=s.replace('module tb_replay;','module tb_shape_replay;').replace('parameter FB=8192,CF=32,ERROR_CASE=0;','parameter FB=921600,CF=3,ERROR_CASE=0;')
s=s.replace('reg sof=0,request=0;', 'wire sof=dut.source_sof,request=dut.lcd_request;')
a=s.index(' replay_frontend #');b=s.index(' reg [127:0] memory',a)
s=s[:a]+''' reg [1:0] keys=3;wire [23:0] out_rgb;wire out_de,out_hs,out_vs;
 shape_replay_system #(.DEBOUNCE_CYCLES(5),.LONG_CYCLES(60),.CLIP_FRAMES(CF)) dut(
 .ui_clk(ui),.cam_clk(cam),.pix_clk(pix),.rst_n(rst),.pix_rst_n(rst),.pll_locked(1'b1),.cal_done(1'b1),.cal_pass(1'b1),
 .key_n(keys),.cam_vs(cam_vs),.cam_valid(cam_valid),.cam_data(cam_data),.display_rgb_out(out_rgb),.display_de_out(out_de),.display_hs_out(out_hs),.display_vs_out(out_vs),.led(led),
 .aid(aid),.alen(alen),.wid(wid),.aaddr(addr),.asize(size),.aburst(burst),.alock(lock),.avalid(av),.atype(at),.aready(ar),
 .wdata(wd),.wstrb(strb),.wlast(wl),.wvalid(wv),.wready(wr),.bid(bid),.bresp(br),.bvalid(bv),.bready(bready),.rid(rid),.rresp(rr),.rdata(rd),.rlast(rl),.rvalid(rv),.rready(rready));
 assign pixel=dut.lcd_data;assign frame_id=dut.m5b1_frame_id;assign epoch=dut.m5b1_epoch;assign qualified=dut.m5b1_pix_qualified;
 assign state=dut.replay_state;assign recorded=dut.recorded;assign pindex=dut.play_index;assign clip=dut.clip_valid;assign status=dut.pixel_status;
 reg [35:0] gold[0:3*FB-1];integer camera_bank[0:511];reg [4095:0] root,path;
 initial begin
  if(!$value$plusargs("GOLDROOT=%s",root))$fatal;
  $sformat(path,"%0s/f2_0_64.hex",root);$readmemh(path,gold,0,FB-1);
  $sformat(path,"%0s/f2_1_64.hex",root);$readmemh(path,gold,FB,2*FB-1);
  $sformat(path,"%0s/f2_2_64.hex",root);$readmemh(path,gold,2*FB,3*FB-1);
 end
''' +s[b:]
s=s.replace('pattern=((f*37+p*13+(p/128)*7)^(p>>8));', 'pattern=gold[camera_bank[f]*FB+p][7:0];')
s=s.replace('dut.video','dut.u_m5b1.video').replace('dut.stop','dut.u_m5b1.stop').replace('dut.quarantine','dut.u_m5b1.quarantine')
s=s.replace('   cam_vs=0;', '   camera_bank[camera_frame]=(clip||phase==2)?2:camera_frame%3;cam_vs=0;')
a=s.index(' integer p;');b=s.index(' always @(posedge pix)',a);s=s[:a]+s[b:]
a=s.index(' task cmd(');b=s.index(' initial begin',a)
s=s[:a]+''' task press(input [1:0] key,input integer cycles);begin @(negedge ui);keys=key;repeat(cycles)@(negedge ui);keys=3;repeat(25)@(negedge ui);end endtask
 task cmd(input [1:0] c);begin case(c)0:press(2,20);1:press(2,100);2:press(1,100);endcase end endtask
 integer class_results=0,history_results=0,history_diff=0,pause_results=0,context_changes=0,view_bits=0,final_pixels=0,osd_pixels=0,roi_pixels=0;
 integer result_scene,final_scene,fp=0;reg [63:0] last_seq=0,previous_cfg=0;
 reg [63:0] final_id,final_cfg;reg final_good;reg [35:0] golden;reg [23:0] expected_rgb;
 reg compare_out;reg [23:0] expect_base;reg [2:0] expected_sync;
 reg border,header;integer ox,oy;reg [63:0] cfg_by_seq[0:511],id_by_seq[0:511];reg clip_by_seq[0:511];integer kseq;
 always @(posedge pix)if(rst)begin
  if(dut.first_source)begin
   kseq=dut.display_seq;cfg_by_seq[kseq]=dut.source_generation;id_by_seq[kseq]=dut.m5b1_lcd_frame_id;clip_by_seq[kseq]=status[1];
   if(dut.context_change)begin
    context_changes=context_changes+1;
    if(dut.source_generation!=dut.generation+1)$fatal(1,"firstDE effective generation");
    if(dut.shape_visible)$fatal(1,"stale PREV across context");
   end
  end
  if(dut.u_shape.result_done&&dut.u_shape.result_valid)begin
   kseq=dut.u_shape.result_source_seq;
   if(dut.u_shape.result_config!=cfg_by_seq[kseq]||dut.u_shape.result_frame_id!=id_by_seq[kseq]||kseq<=last_seq)$fatal(1,"result association");
   last_seq=kseq;result_scene=camera_bank[dut.u_shape.result_frame_id];
   if(dut.u_shape.result_class!=(result_scene==0?1:result_scene==1?2:0))$fatal(1,"historical classification scene=%0d class=%0d id=%0d",result_scene,dut.u_shape.result_class,dut.u_shape.result_frame_id);
   class_results=class_results+1;
   if(clip_by_seq[kseq])begin history_results=history_results+1;if(result_scene!=camera_bank[camera_frame])history_diff=history_diff+1;end
   if(state==3)pause_results=pause_results+1;
  end
  compare_out=dut.sobel_de;expected_sync={dut.sobel_de,dut.sobel_hs,dut.sobel_vs};ox=dut.final_x;oy=dut.final_y;expect_base=dut.display_rgb;
  border=((ox==160||ox==1119)&&oy>=90&&oy<=629)||((oy==90||oy==629)&&ox>=160&&ox<=1119);
  header=oy>=12&&oy<34&&((ox>=12&&ox<228)||(ox>=444&&ox<644)||(ox>=664&&ox<720));
  header=header||(ox>=12&&ox<340&&oy>=44&&oy<80);
  if(dut.sobel_de)begin
   if(ox!=fp%1280||oy!=fp/1280)$fatal(1,"final coordinates");
   if(fp==0)begin final_id=dut.u_shape.aligned_frame_id;final_cfg=dut.u_shape.aligned_config;final_good=dut.u_shape.aligned_qualified;end
   if(final_good)begin
    golden=gold[camera_bank[final_id]*FB+fp];
    if({dut.final_gray,dut.shape_support,dut.local_edge}!=={golden[7:0],golden[28],golden[29]})$fatal(1,"DDR-to-Canny pixel oracle id=%0d pos=%0d",final_id,fp);
    if(dut.u_shape.aligned_frame_id!=final_id||dut.u_shape.aligned_config!=final_cfg||!dut.u_shape.aligned_qualified)$fatal(1,"final tags drift");
    case(dut.display_mode)0:begin expected_rgb={3{golden[7:0]}};view_bits=view_bits|1;end 5:begin expected_rgb={24{golden[29]}};view_bits=view_bits|2;end 6:begin expected_rgb=golden[29]?24'hff0000:{3{golden[7:0]}};view_bits=view_bits|4;end default:$fatal(1,"view mode");endcase
    if(dut.display_rgb!==expected_rgb)$fatal(1,"view RGB");final_pixels=final_pixels+1;
   end
   fp=fp==FB-1?0:fp+1;
  end
  #1;
  if({out_de,out_hs,out_vs}!==expected_sync)$fatal(1,"OSD one-stage raster alignment");
  if(compare_out&&final_good)begin
   if(border)begin if(out_rgb!==24'h408040)$fatal(1,"ROI");roi_pixels=roi_pixels+1;end
   else if(!header&&out_rgb!==expect_base)$fatal(1,"OSD changed image outside headers");
   osd_pixels=osd_pixels+1;
  end
 end
''' +s[b:]
s=s.replace('  wait(loops>=1);phase=2;', '  wait(loops>=1);phase=2;')
s=s.replace('repeat(FB*9)@(negedge pix);','repeat(FB*4)@(negedge pix);')
s=s.replace('  repeat(FB*3)@(negedge pix);cmd(2);', '  press(1,20);repeat(FB*3)@(negedge pix);press(1,20);repeat(FB*3)@(negedge pix);cmd(2);')
s=s.replace('if(dut.u_m5b1.video_fault||dut.u_m5b1.quarantine||dut.u_m5b1.stop)', 'if(dut.u_m5b1.video_fault||dut.u_m5b1.quarantine||dut.u_m5b1.stop||dut.u_shape.adapter_fault||dut.shape_raster_fault)')
s=s.replace('  $display("REPLAY_PASS', '''  if(class_results<20||history_results<8||history_diff<4||pause_results<1||context_changes<4||view_bits!=7||roi_pixels<10000)$fatal(1,"merged coverage class=%0d history=%0d diff=%0d pause=%0d context=%0d views=%0d",class_results,history_results,history_diff,pause_results,context_changes,view_bits);
  $display("SHAPE_INTEGRATION_COUNTS class=%0d history=%0d different_from_camera=%0d pause=%0d contexts=%0d viewbits=%0d final_pixels=%0d OSD=%0d ROI=%0d",class_results,history_results,history_diff,pause_results,context_changes,view_bits,final_pixels,osd_pixels,roi_pixels);
  $display("SHAPE_REPLAY_PASS''')
s=s.replace('integer saved_index,record_start_id', 'integer saved_index,saved_context,record_start_id')
s=s.replace('    if(display_offset==0)begin', '''    if(display_offset==0)begin
     $display("DISPLAY_PROGRESS frame=%0d state=%0d recorded=%0d index=%0d phase=%0d loops=%0d",display_frames+1,state,recorded,pindex,phase,loops);''')
old='  press(1,20);repeat(FB*3)@(negedge pix);press(1,20);repeat(FB*3)@(negedge pix);cmd(2);wait(state==2);if(pindex!=0)$fatal(1,"replay restart");\n  cmd(1);wait(state==0);cmd(0);wait(state==1);if(clip)$fatal(1,"rerecord retained clip");'
new='''  press(1,20);repeat(FB*3)@(negedge pix);press(1,20);repeat(FB*3)@(negedge pix);
  saved_context=context_changes;cmd(2);wait(state==2);if(pindex!=0)$fatal(1,"replay restart");
  wait(context_changes>saved_context&&dut.source_clip);
  wait(dut.u_shape.result_done&&dut.u_shape.result_valid&&dut.u_shape.result_config==dut.generation);
  saved_context=context_changes;cmd(1);wait(state==0);
  wait(context_changes>saved_context&&!dut.source_clip);
  wait(dut.u_shape.result_done&&dut.u_shape.result_valid&&dut.u_shape.result_config==dut.generation);
  cmd(0);wait(state==1);if(clip)$fatal(1,"rerecord retained clip");'''
assert old in s;s=s.replace(old,new)
lines=s.splitlines();a=next(i for i,l in enumerate(lines) if l.startswith('  if(class_results<20'));lines[a],lines[a+1]=lines[a+1],lines[a];s='\n'.join(lines)+'\n'
put(R/'tb/shape_replay/tb_shape_replay.sv',s)
# Reuse all original41 recognition boundary vectors with identical RTL.
shutil_source=R/'tb/shape_wide_roi/tb_wide_recognizer.sv'
put(R/'tb/shape_replay/tb_wide_recognizer.sv',shutil_source.read_text())
s=(R/'tb/canny_replay/tb_controls.sv').read_text().replace('module tb_controls;','module tb_shape_controls;').replace('wire cv,edge_mode;','wire cv;wire [1:0] view_index;').replace('reg oldmode=0;','reg [1:0] oldmode=2;').replace('replay_controls #','shape_replay_controls #').replace('.edge_mode(edge_mode)', '.view_index(view_index)').replace('edge_mode','view_index')
s=s.replace('$display("CONTROLS_PASS', 'if(view_index!=0)$fatal(1,"view cycle from default COV");$display("SHAPE_CONTROLS_PASS')
put(R/'tb/shape_replay/tb_shape_controls.sv',s)
