`timescale 1ns/1ps
// Real unmodified M5B1 M5A instance. Hierarchical nms_good is explicitly a
// TEST-ONLY adapter; no new production port/DDR/cache is claimed.
module tb_replay_pixels;
 localparam W=1280,H=720,HT=1650,VT=750,LAT=4*HT+25,FRAMES=4;
 reg clk=0;always #6.7205 clk=~clk;
 reg rst_n=0,ce=1,de=0,hs=1,vs=1,sof_in=0;reg [7:0] gray=0;reg [2:0] mode=0;reg [63:0] tag=0;
 wire [23:0] rgb;wire od,oh,ov;wire [7:0] raw,mag,nms,threshold;wire [2:0] om;
 wire bin,ovs,ove,nv,cv,edge_local,fault;wire [1:0] filter;wire [11:0] ox,oy;
 wire tv;wire [1:0] tf;wire [1:0] tc;wire [11:0] tx,ty;wire ls,ge,gv;wire [7:0] th,tl,lh,ghout;wire [63:0] tid,te,tt;
 m5a_stream_top #(.WIDTH(W),.HEIGHT(H),.H_TOTAL(HT)) m5a(
  .clk(clk),.ce(ce),.arst_n(rst_n),.in_gray(gray),.in_de(de),.in_hs(hs),.in_vs(vs),.in_sof(sof_in),
  .filter_request(2'd2),.threshold(8'd64),.global_threshold(8'd48),.mode(mode),.out_rgb(rgb),.out_de(od),.out_hs(oh),.out_vs(ov),
  .out_raw(raw),.out_legacy_mag(mag),.out_threshold(threshold),.out_global_threshold(ghout),.out_nms(nms),.out_legacy_bin(bin),
  .out_overlay_valid(ovs),.out_overlay_edge(ove),.out_nms_valid(nv),.out_canny_valid(cv),.out_canny_edge(edge_local),
  .out_mode(om),.out_filter_enable(filter),.out_x(ox),.out_y(oy),.raster_fault(fault),
  .source_pixel_tick(64'd0),.source_display_seq(tag),.source_config_generation(64'd1),.tap_display_seq(),.tap_config_generation(),.fusion_tap_valid(),.fusion_tap_qualified(),.fusion_tap_support(),
  .tap_input_frame_id(tag),.tap_input_epoch(64'd1),.tap_input_qualified(1'b1),
  .tap_valid(tv),.tap_class(tc),.tap_x(tx),.tap_y(ty),.tap_high(th),.tap_low(tl),.tap_local_high(lh),.tap_local_strong(ls),.tap_filter(tf),
  .tap_frame_id(tid),.tap_epoch(te),.tap_timestamp(tt));
 reg [23:0] gold[0:W*H-1];reg [2047:0] file_name,bfs_name;
 reg [2:0] syncq[0:LAT-1];integer rp=0,cycles=0,pixels=0,taps=0,stalls=0;
 integer mode_pixels[0:6],mode_promotions[0:6];
 integer frame_pixels[0:FRAMES-1],frame_promotions[0:FRAMES-1];
 integer f,v,h,i,pos,frameout;integer globals[0:3];reg eg;reg expected_frame=0,ep;reg [23:0] e;reg [23:0] expected_rgb;
 reg [31:0] held;
 task drive_tick;
 begin
  @(posedge clk);
  if(tv)begin
   if(tc!==gold[ty*W+tx][11:10]||ls!==gold[ty*W+tx][9]||th!=48||tl!=24||lh!=64)$fatal(1,"SPLIT_TAP_GOLD");
   taps=taps+1;
  end
  #1;
  if({od,oh,ov}!==syncq[rp])$fatal(1,"REAL_SYNC_LATENCY cycle=%0d got=%b%b%b expected=%b",cycles,od,oh,ov,syncq[rp]);
  syncq[rp]={de,hs,vs};rp=(rp+1)%LAT;cycles=cycles+1;
  if(od)begin
   frameout=pixels/(W*H);pos=pixels%(W*H);e=gold[pos];
   if(ox!==pos%W||oy!==pos/W||om!==(frameout%2==0?2:0))$fatal(1,"REAL_FINAL_COORD_MODE pos=%0d xy=%0d,%0d mode=%0d frame=%0d",pos,ox,oy,om,frameout);
   if(raw!==e[7:0]||edge_local!==e[8]||threshold!=64||ghout!=48)$fatal(1,"SPLIT_LOCAL_AND_GH_ALIGNMENT pos=%0d gh=%0d",pos,ghout);
   expected_rgb=om==2?{24{e[8]}}:{3{e[7:0]}};
   if(rgb!==expected_rgb)$fatal(1,"REPLAY_RAW_CNY_RGB");
   frame_pixels[frameout]=frame_pixels[frameout]+1;
   pixels=pixels+1;
   if(pos==W*H-1)$display("M5C_FRAME frame=%0d mode=%0d pixels=%0d additions=%0d",frameout,om,frame_pixels[frameout],frame_promotions[frameout]);
  end else if(rgb!=0)$fatal(1,"BLANK_RGB");
 end endtask
 initial begin
  if(!$value$plusargs("GOLD=%s",file_name))$fatal(1,"GOLD_ARG");$readmemh(file_name,gold);

  for(i=0;i<LAT;i=i+1)syncq[i]=3'b011;
  for(i=0;i<7;i=i+1)begin mode_pixels[i]=0;mode_promotions[i]=0;end
  for(i=0;i<FRAMES;i=i+1)begin frame_pixels[i]=0;frame_promotions[i]=0;globals[i]=0;end
  repeat(6)@(posedge clk);@(negedge clk);rst_n=1;
  // Allow internal reset release; these are not accepted image/raster ticks.
  repeat(4)@(posedge clk);
  for(f=0;f<FRAMES;f=f+1)begin
   for(v=0;v<VT;v=v+1)for(h=0;h<HT;h=h+1)begin
    @(negedge clk);ce=1;mode=f%2==0?2:0;tag=64'd7;hs=h>=40;vs=v>=5;sof_in=!vs;
    de=(h>=260&&h<260+W&&v>=25&&v<25+H);
    gray=de?gold[(v-25)*W+h-260][7:0]:0;
    drive_tick;
    if(f==2&&cycles%5003==99)begin
     @(negedge clk);ce=0;held={rgb,od,oh,ov};
     repeat(3)begin @(posedge clk);#1;if({rgb,od,oh,ov}!==held)$fatal(1,"REAL_CE_FREEZE");stalls=stalls+1;end
    end
   end
  end
  for(i=0;i<LAT+10;i=i+1)begin @(negedge clk);ce=1;de=0;hs=1;vs=1;sof_in=0;gray=0;drive_tick;end
  if(pixels!=FRAMES*W*H||taps!=FRAMES*W*H||stalls==0||fault)$fatal(1,"REAL_COVERAGE pixels=%0d taps=%0d",pixels,taps);
  for(i=0;i<FRAMES;i=i+1)if(frame_pixels[i]!=W*H)$fatal(1,"FAULT_FRAME_INCOMPLETE");
  $display("PASS_REPLAY_PIXELS pixels=%0d taps=%0d stalls=%0d four_full_frames=1 RAW_CNY=1 repeated_capture_identity=1 CE_pause=1",pixels,taps,stalls);$finish;
 end
 initial begin #300000000;$fatal(1,"WATCHDOG");end
endmodule
