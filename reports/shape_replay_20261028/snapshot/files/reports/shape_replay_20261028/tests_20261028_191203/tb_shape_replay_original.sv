`timescale 1ns/1ps
module tb_shape_replay;
 parameter FB=921600,CF=3,ERROR_CASE=0;
 localparam CW=FB==921600?1280:128,HB=FB==921600?370:16,VB=FB==921600?44548:850;
 reg ui=0,cam=0,pix=0,rst=0;
 always #5 ui=~ui;always #7 cam=~cam;always #7 pix=~pix;
 reg cam_vs=1,cam_valid=0;reg [7:0] cam_data=0;
 wire sof=dut.source_sof,request=dut.lcd_request;wire [7:0] pixel;wire [63:0] frame_id,epoch;wire qualified;
 reg [1:0] command=0;reg command_valid=0;wire [1:0] state;wire [5:0] recorded,pindex;wire clip;
 wire [14:0] status;wire [5:0] led;
 wire [7:0] aid,alen,wid;wire [31:0] addr;wire [2:0] size;wire [1:0] burst,lock;
 wire av,at;reg ar=0;wire [127:0] wd;wire [15:0] strb;wire wl,wv;reg wr=0;
 reg [7:0] bid=0,rid=0;reg [1:0] br=0,rr=0;reg bv=0,rv=0,rl=0;reg [127:0] rd=0;wire bready,rready;
 reg [1:0] keys=3;wire [23:0] out_rgb;wire out_de,out_hs,out_vs;
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
 reg [127:0] memory[0:36*FB/16-1];integer slot_capture[0:35];
 integer tick=0,bus_state=0,base=0,bslot=0,off=0,beat=0,delay_count=0;
 integer write_frame=0,writes=0,reads=0,write_beats=0,read_beats=0,commits=0;
 integer camera_frame=0,camera_done=0,display_frames=0,pixel_checks=0,clip_displays=0;
 integer display_offset=0,last_clip_idx=-1,run_repeat=0,loops=0,phase=0;
 integer saved_index,record_start_id=-1,last_registered=-1;reg injected=0;
 reg [63:0] held_frame;integer active_clip_idx=-1;
 function [7:0] pattern(input integer f,input integer p);
  pattern=gold[camera_bank[f]*FB+p][7:0];
 endfunction
 function integer decode_slot(input [31:0] a);
  if(a<32'h01000000)decode_slot=a>>22;else decode_slot=4+((a-32'h02000000)>>20);
 endfunction
 function integer decode_offset(input [31:0] a);
  if(a<32'h01000000)decode_offset=a&32'h003fffff;else decode_offset=a&32'h000fffff;
 endfunction
 integer i,j;
 always @(negedge ui)begin
  tick=tick+1;ar=0;wr=0;
  if(rst)begin
   ar=bus_state==0&&(tick%7!=0);wr=bus_state==1&&(tick%5!=0);
   if(bus_state==3&&!rv&&tick%4!=0)begin
    rv=1;rd=memory[base+beat];rid=2;rr=0;rl=beat==127;
    if(ERROR_CASE>=2&&!injected&&clip)begin
     injected=1;
     if(ERROR_CASE==2)rr=2;
     if(ERROR_CASE==3)rid=9;
     if(ERROR_CASE==4)rl=!rl;
    end
   end
   if(bus_state==2&&!bv)begin
    if(delay_count==0)begin bv=1;bid=1;br=0;
     if(ERROR_CASE==1&&!injected&&bslot>=4)begin br=2;injected=1;end
     if(ERROR_CASE==6&&!injected&&bslot>=4)begin bid=7;injected=1;end
    end else delay_count=delay_count-1;
   end
  end
 end
 always @(posedge ui)if(rst)begin
  if(av&&ar)begin
   if(bus_state!=0)$fatal(1,"overlap");
   if(size!=4||alen!=127||burst!=1||lock!=0||addr[10:0]!=0)$fatal(1,"AXI shape");
   bslot=decode_slot(addr);off=decode_offset(addr);
   if(bslot<0||bslot>=36||off+2048>FB)$fatal(1,"range %h",addr);
   base=bslot*FB/16+off/16;beat=0;
   if(at)begin
    writes=writes+1;bus_state=1;if(aid!=1)$fatal;
    if(bslot>=4&&(state==2||state==3))$fatal(1,"clip write during playback");
    if(dut.u_m5b1.video.lease&&dut.u_m5b1.video.rslot==bslot)$fatal(1,"read/write collision");
    if(off==0)slot_capture[bslot]=write_frame;
   end else begin
    reads=reads+1;bus_state=3;if(aid!=2)$fatal;
    if(bslot>=4&&!clip)$fatal(1,"read invalid clip");
   end
  end
  if(wv&&wr)begin
   if(bus_state!=1||wl!=(beat==127)||strb!=16'hffff||wid!=1)$fatal(1,"W protocol");
   for(j=0;j<16;j=j+1)if(wd[j*8+:8]!==pattern(write_frame,off+beat*16+j))$fatal(1,"camera write mismatch frame %0d offset %0d",write_frame,off+beat*16+j);
   memory[base+beat]=wd;write_beats=write_beats+1;
   if(beat==127)begin bus_state=2;delay_count=11;end else beat=beat+1;
  end
  if(bv&&bready)begin
   if(bus_state!=2)$fatal;bv=0;bus_state=0;
   if(off==FB-2048)begin commits=commits+1;write_frame=write_frame+1;end
  end
  if(rv&&rready)begin
   if(bus_state!=3)$fatal;rv=0;read_beats=read_beats+1;
   if(beat==127)bus_state=0;else beat=beat+1;
  end
  // Registration must lag BOTH completed real B and independent camera EOF.
  if(dut.u_m5b1.video.capture_id>commits||dut.u_m5b1.video.capture_id>camera_done)$fatal(1,"premature frame registration");
  if(recorded>0&&state==1)begin
   if(last_registered!=recorded)begin
    if(slot_capture[4+recorded-1]>=commits||slot_capture[4+recorded-1]>=camera_done)$fatal(1,"premature clip registration");
    if(recorded==1)record_start_id=slot_capture[4];
    if(slot_capture[4+recorded-1]!=record_start_id+(recorded-1)*4)$fatal(1,"sample sequence");
    last_registered=recorded;
   end
  end
 end
 // Independent camera generator, including complete pixel patterns and blanking.
 initial begin
  wait(rst);repeat(1000)@(negedge cam);
  forever begin
   camera_bank[camera_frame]=(clip||phase==2)?2:camera_frame%3;cam_vs=0;
   if(camera_frame!=0)camera_done=camera_done+1;
   repeat(150)@(negedge cam);
   for(i=0;i<FB;i=i+1)begin
    cam_valid=!(ERROR_CASE==5&&camera_frame>=4&&i>=FB-16);cam_data=pattern(camera_frame,i);@(negedge cam);
    if(i%CW==CW-1)begin cam_valid=0;repeat(HB)@(negedge cam);end
   end
   cam_valid=0;cam_vs=1;camera_frame=camera_frame+1;
   repeat(VB-150)@(negedge cam);
  end
 end
 always @(posedge pix)if(rst)begin
  if(sof)begin display_offset=0;active_clip_idx=-1;end
  if(request)begin
   if(qualified)begin
    if(display_offset==0)begin
     $display("DISPLAY_PROGRESS frame=%0d state=%0d recorded=%0d index=%0d phase=%0d loops=%0d",display_frames+1,state,recorded,pindex,phase,loops);
     held_frame=frame_id;display_frames=display_frames+1;
     if(dut.u_m5b1.video.offer_payload[65:64]>=2)begin
      active_clip_idx=dut.u_m5b1.video.offer_payload[71:66];clip_displays=clip_displays+1;
      if(frame_id!=slot_capture[4+active_clip_idx])$fatal(1,"clip identity mismatch");
      if(phase==1)begin
       if(last_clip_idx<0)begin if(active_clip_idx!=0)$fatal(1,"first clip frame");run_repeat=1;end
       else if(active_clip_idx==last_clip_idx)run_repeat=run_repeat+1;
       else begin
        if(run_repeat!=4||active_clip_idx!=(last_clip_idx+1)%CF)$fatal(1,"play order index %0d prev %0d repeats %0d",active_clip_idx,last_clip_idx,run_repeat);
        if(active_clip_idx==0)loops=loops+1;run_repeat=1;
       end
       last_clip_idx=active_clip_idx;
      end
     end
    end else if(frame_id!=held_frame)$fatal(1,"midframe identity");
    if(pixel!==pattern(frame_id,display_offset))$fatal(1,"pixel mismatch id %0d at %0d actual %h expected %h",frame_id,display_offset,pixel,pattern(frame_id,display_offset));
    pixel_checks=pixel_checks+1;
   end else if(display_offset!=0&&dut.u_m5b1.video.frame_used&&!dut.u_m5b1.stop&&!dut.u_m5b1.video_fault&&!dut.u_m5b1.quarantine)$fatal(1,"partial display");
   display_offset=display_offset+1;
  end
 end
 task press(input [1:0] key,input integer cycles);begin @(negedge ui);keys=key;repeat(cycles)@(negedge ui);keys=3;repeat(25)@(negedge ui);end endtask
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
 initial begin
  for(j=0;j<36;j=j+1)slot_capture[j]=-1;
  #100;rst=1;
  wait(display_frames>=3);cmd(2);repeat(10)@(negedge ui);if(state!=0||clip)$fatal(1,"empty clip request");
  cmd(0);phase=1;
  if(ERROR_CASE!=0)begin
   wait(dut.u_m5b1.stop);repeat(30)@(negedge ui);
   if(ERROR_CASE==1||ERROR_CASE==6)if(clip||recorded!=0)$fatal(1,"B error published clip");
   if(av||wv||rready||bready)$fatal(1,"hard stop isolation");
   $display("REPLAY_FAULT_PASS case=%0d pixels=%0d",ERROR_CASE,pixel_checks);$finish;
  end
  wait(loops>=1);phase=2;cmd(0);wait(state==3);repeat(500)@(negedge ui);saved_index=pindex;
  repeat(FB*4)@(negedge pix);if(pindex!=saved_index||state!=3)$fatal(1,"pause advanced");
  cmd(0);wait(pindex!=saved_index);cmd(1);wait(state==0);if(!clip)$fatal(1,"return LIVE lost clip");
  press(1,20);repeat(FB*3)@(negedge pix);press(1,20);repeat(FB*3)@(negedge pix);cmd(2);wait(state==2);if(pindex!=0)$fatal(1,"replay restart");
  cmd(1);wait(state==0);cmd(0);wait(state==1);if(clip)$fatal(1,"rerecord retained clip");
  wait(recorded>=(CF==2?1:2));cmd(1);wait(state==0);if(clip)$fatal(1,"cancel resurrected clip");cmd(2);repeat(100)@(negedge ui);if(state!=0)$fatal;
  last_registered=-1;cmd(0);wait(clip);if(recorded!=CF)$fatal;
  repeat(FB*3)@(negedge pix);
  if(dut.u_m5b1.video_fault||dut.u_m5b1.quarantine||dut.u_m5b1.stop||dut.u_shape.adapter_fault||dut.shape_raster_fault)$fatal(1,"unexpected fault");
  $display("SHAPE_INTEGRATION_COUNTS class=%0d history=%0d different_from_camera=%0d pause=%0d contexts=%0d viewbits=%0d final_pixels=%0d OSD=%0d ROI=%0d",class_results,history_results,history_diff,pause_results,context_changes,view_bits,final_pixels,osd_pixels,roi_pixels);
  if(class_results<20||history_results<8||history_diff<4||pause_results<1||context_changes<4||view_bits!=7||roi_pixels<10000)$fatal(1,"merged coverage class=%0d history=%0d diff=%0d pause=%0d context=%0d views=%0d",class_results,history_results,history_diff,pause_results,context_changes,view_bits);
  $display("SHAPE_REPLAY_PASS FB=%0d CF=%0d pixels=%0d display=%0d clip_display=%0d loops=%0d commits=%0d writes=%0d reads=%0d",FB,CF,pixel_checks,display_frames,clip_displays,loops,commits,writes,reads);$finish;
 end
 initial begin #2000000000;#2000000000;#2000000000;$fatal(1,"timeout");end
endmodule
