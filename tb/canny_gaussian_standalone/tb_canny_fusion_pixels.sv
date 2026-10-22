`timescale 1ns/1ps
// Real unmodified M5B1 M5A instance. Hierarchical nms_good is explicitly a
// TEST-ONLY adapter; no new production port/DDR/cache is claimed.
module tb_canny_fusion_pixels;
 localparam W=1280,H=720,HT=1650,VT=750,LAT=4*HT+25,FRAMES=2;
 reg clk=0;always #6.7205 clk=~clk;
 reg rst_n=0,ce=1,de=0,hs=1,vs=1,sof_in=0;reg [7:0] gray=0;reg [2:0] mode=0;reg [63:0] tag=0;
 wire [23:0] rgb;wire od,oh,ov;wire [7:0] raw,mag,nms,threshold;wire [2:0] om;
 wire bin,ovs,ove,nv,cv,edge_local,fault;wire [1:0] filter;wire [11:0] ox,oy;
 wire tv;wire [1:0] tf;wire [1:0] tc;wire [11:0] tx,ty;wire [7:0] th,tl;wire [63:0] tid,te,tt;
 m5a_stream_top #(.WIDTH(W),.HEIGHT(H),.H_TOTAL(HT)) m5a(
  .clk(clk),.ce(ce),.arst_n(rst_n),.in_gray(gray),.in_de(de),.in_hs(hs),.in_vs(vs),.in_sof(sof_in),
  .filter_request(2'd2),.threshold(8'd64),.mode(mode),.out_rgb(rgb),.out_de(od),.out_hs(oh),.out_vs(ov),
  .out_raw(raw),.out_legacy_mag(mag),.out_threshold(threshold),.out_nms(nms),.out_legacy_bin(bin),
  .out_overlay_valid(ovs),.out_overlay_edge(ove),.out_nms_valid(nv),.out_canny_valid(cv),.out_canny_edge(edge_local),
  .out_mode(om),.out_filter_enable(filter),.out_x(ox),.out_y(oy),.raster_fault(fault),
  .source_pixel_tick(64'd0),.source_display_seq(tag),.source_config_generation(64'd1),.tap_display_seq(),.tap_config_generation(),.fusion_tap_valid(),.fusion_tap_qualified(),.fusion_tap_support(),
  .tap_input_frame_id(tag),.tap_input_epoch(64'd1),.tap_input_qualified(1'b1),
  .tap_valid(tv),.tap_class(tc),.tap_x(tx),.tap_y(ty),.tap_high(th),.tap_low(tl),.tap_filter(tf),
  .tap_frame_id(tid),.tap_epoch(te),.tap_timestamp(tt));
 reg [93:0] gold[0:W*H-1];reg bfs[0:W*H-1];reg [2047:0] file_name,bfs_name;
 localparam [319:0] IDENT={64'd1,64'd1,64'd0,64'd1,64'd1};
 wire row_sof=tv&&tx==0&&ty==0;
 wire row_invalid=1'b0;
 wire row_qualified=1'b1;
 wire reference_ready=1'b1;
 wire [319:0] reference_identity=(tv&&tid==1&&ty==200&&tx==0)?IDENT+1'b1:IDENT;
 wire [1:0] reference_class=gold[ty*W+tx][93:92];
 wire reference_global=bfs[ty*W+tx];
 wire fused,promote,frame_ok,retire;wire [11:0] ry;
 m5c_row_fusion #(.WIDTH(W),.HEIGHT(H),.H_TOTAL(HT),.REF_STAGE(0)) fusion(
  .context_block(1'b0),.context_quiet(),.context_tail_fault(),
  .clk(clk),.rst_n(m5a.rst_n),.ce(ce),.sof(row_sof),.admit(1'b1),.invalidate(row_invalid),.identity_in(IDENT),
  .tap_valid(tv),.tap_qualified(row_qualified),.tap_x(tx),.tap_y(ty),.current_class(tc),.current_support(m5a.nms_good),
  .ref_ready(reference_ready),.ref_class(reference_class),.ref_global(reference_global),.ref_identity(reference_identity),.ref_x(tx),.ref_y(ty),
  .support_radius(4'd3),.final_de(od),.final_x(ox),.final_y(oy),.local_edge(edge_local),
  .fused_edge(fused),.promoted(promote),.frame_ok(frame_ok),.row_retire(retire),.retired_y(ry));
 reg [2:0] syncq[0:LAT-1];integer rp=0,cycles=0,pixels=0,taps=0,stalls=0;
 integer mode_pixels[0:6],mode_promotions[0:6];
 integer frame_pixels[0:FRAMES-1],frame_promotions[0:FRAMES-1];
 integer f,v,h,i,pos,frameout;reg expected_frame=0,ep;reg [93:0] e;reg [23:0] expected_rgb;
 reg [29:0] held;
 task drive_tick;
 begin
  @(posedge clk);
  if(tv)begin
   if(tc!==gold[ty*W+tx][93:92])$fatal(1,"REAL_TAP_GOLD id=%0d x=%0d y=%0d",tid,tx,ty);
   taps=taps+1;
  end
  if(row_sof)expected_frame=1;
  if(row_invalid||(tv&&(!row_qualified||!reference_ready||reference_identity!=IDENT)))expected_frame=0;
  #1;
  if({od,oh,ov}!==syncq[rp])$fatal(1,"REAL_SYNC_LATENCY cycle=%0d got=%b%b%b expected=%b",cycles,od,oh,ov,syncq[rp]);
  syncq[rp]={de,hs,vs};rp=(rp+1)%LAT;cycles=cycles+1;
  if(od)begin
   frameout=pixels/(W*H);pos=pixels%(W*H);e=gold[pos];
   if(ox!==pos%W||oy!==pos/W||om!==6)$fatal(1,"REAL_FINAL_COORD_MODE pos=%0d xy=%0d,%0d mode=%0d frame=%0d",pos,ox,oy,om,frameout);
   if({raw,mag,bin,ovs,ove,nms,nv,cv,edge_local}!=={e[7:0],e[15:8],e[16],e[17],e[18],e[26:19],e[27],e[28],e[29]})$fatal(1,"REAL_M5A_SPATIAL_GOLD pos=%0d",pos);
   case(om)
    0:expected_rgb={3{e[7:0]}};1:expected_rgb={3{e[15:8]}};2:expected_rgb={24{e[16]}};
    3:expected_rgb=e[18]?24'hff0000:{3{e[7:0]}};4:expected_rgb={3{e[26:19]}};
    5:expected_rgb={24{e[29]}};6:expected_rgb=e[29]?24'hff0000:{3{e[7:0]}};
   endcase
   if(rgb!==expected_rgb)$fatal(1,"SEVEN_MODE_RGB mode=%0d pos=%0d",om,pos);
   ep=expected_frame&&!e[29]&&e[93:92]==1&&bfs[pos]&&e[27]&&ox>=3&&ox<W-3&&oy>=3&&oy<H-3;
   if(promote!==ep||fused!==(e[29]||ep))$fatal(1,"REAL_FUSION_GOLD mode=%0d x=%0d y=%0d expected=%b got=%b eligible=%b",om,ox,oy,ep,promote,frame_ok);
   if(frameout<7)begin mode_pixels[om]=mode_pixels[om]+1;if(promote&&!edge_local)mode_promotions[om]=mode_promotions[om]+1;end
   frame_pixels[frameout]=frame_pixels[frameout]+1;if(promote&&!edge_local)frame_promotions[frameout]=frame_promotions[frameout]+1;
   pixels=pixels+1;
   if(pos==W*H-1)$display("M5C_FRAME frame=%0d mode=%0d pixels=%0d additions=%0d",frameout,om,frame_pixels[frameout],frame_promotions[frameout]);
  end else if(rgb!=0)$fatal(1,"BLANK_RGB");
 end endtask
 initial begin
  if(!$value$plusargs("GOLD=%s",file_name))$fatal(1,"GOLD_ARG");$readmemh(file_name,gold);
  if(!$value$plusargs("BFS=%s",bfs_name))$fatal(1,"BFS_ARG");$readmemh(bfs_name,bfs);
  for(i=0;i<LAT;i=i+1)syncq[i]=3'b011;
  for(i=0;i<7;i=i+1)begin mode_pixels[i]=0;mode_promotions[i]=0;end
  for(i=0;i<FRAMES;i=i+1)begin frame_pixels[i]=0;frame_promotions[i]=0;end
  repeat(6)@(posedge clk);@(negedge clk);rst_n=1;
  // Allow internal reset release; these are not accepted image/raster ticks.
  repeat(4)@(posedge clk);
  for(f=0;f<FRAMES;f=f+1)begin
   for(v=0;v<VT;v=v+1)for(h=0;h<HT;h=h+1)begin
    @(negedge clk);ce=1;mode=6;tag=f;hs=h>=40;vs=v>=5;sof_in=!vs;
    de=(h>=260&&h<260+W&&v>=25&&v<25+H);
    gray=de?gold[(v-25)*W+h-260][7:0]:0;
    drive_tick;
    if(f==1&&cycles%5003==99)begin
     @(negedge clk);ce=0;held={rgb,od,oh,ov,fused,promote,frame_ok};
     repeat(3)begin @(posedge clk);#1;if({rgb,od,oh,ov,fused,promote,frame_ok}!==held)$fatal(1,"REAL_CE_FREEZE");stalls=stalls+1;end
    end
   end
  end
  for(i=0;i<LAT+10;i=i+1)begin @(negedge clk);ce=1;de=0;hs=1;vs=1;sof_in=0;gray=0;drive_tick;end
  if(pixels!=FRAMES*W*H||taps!=FRAMES*W*H||stalls==0||fault)$fatal(1,"REAL_COVERAGE pixels=%0d taps=%0d",pixels,taps);
  if(frame_promotions[0]!=1391||frame_promotions[1]!=0)$fatal(1,"PROMOTION_COVERAGE");
  for(i=0;i<FRAMES;i=i+1)if(frame_pixels[i]!=W*H)$fatal(1,"FAULT_FRAME_INCOMPLETE");
  $display("PASS_CANNY_FUSION_PIXELS pixels=%0d taps=%0d stalls=%0d positive_frame=1391 wrong_identity_frame=0 direct_reference_adapter=1",pixels,taps,stalls);$finish;
 end
 initial begin #300000000;$fatal(1,"WATCHDOG");end
endmodule
