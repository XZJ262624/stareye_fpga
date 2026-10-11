`timescale 1ns/1ps
// Pixel-domain qualification/identity queue under CE stalls. The full-size
// connection test separately supplies actual DMA + LCD data and spatial gold.
module tb_m5b1_tag_qualification;
 localparam W=128,H=32,HT=160,VT=48,N=W*H;
 reg clk=0,rst=0,ce=1,de=0,vs=1,hs=1,qual=0;
 reg [63:0] fid=0,ep=0;always #5 clk=~clk;
 wire tv;wire [1:0] tc;wire [11:0] tx,ty;wire [63:0] tf,te,ts;
 wire od,oh,ov,rf;wire [23:0] rgb;
 m5a_stream_top #(.WIDTH(W),.HEIGHT(H),.H_TOTAL(HT)) dut(
 .clk(clk),.ce(ce),.arst_n(rst),.in_gray(8'b0),.in_de(de),.in_hs(hs),.in_vs(vs),.in_sof(!vs),
 .filter_request(1'b1),.threshold(8'd64),.mode(3'd6),.out_rgb(rgb),.out_de(od),.out_hs(oh),.out_vs(ov),
 .out_raw(),.out_legacy_mag(),.out_threshold(),.out_nms(),.out_legacy_bin(),.out_overlay_valid(),.out_overlay_edge(),
 .out_nms_valid(),.out_canny_valid(),.out_canny_edge(),.out_mode(),.out_filter_enable(),.out_x(),.out_y(),.raster_fault(rf),
 .tap_input_frame_id(fid),.tap_input_epoch(ep),.tap_input_qualified(qual),.tap_valid(tv),.tap_class(tc),.tap_x(tx),.tap_y(ty),
 .tap_high(),.tap_low(),.tap_filter(),.tap_frame_id(tf),.tap_epoch(te),.tap_timestamp(ts));
 reg qvalid[0:15];reg [63:0] qid[0:15],qep[0:15],qstamp[0:15];
 integer f,h,v,cycle=0,stalls=0,tap_frame=0,tap_pos=0,valid_pixels=0,invalid_pixels=0,source_pos=0,source_frame=0;
 integer before_valid,before_invalid;
 reg armed=1,prev_sof=0;reg [63:0] ticks=0,stamp=0;
 always @(posedge clk)if(dut.rst_n)begin
  if(ce)begin
   if(!vs&&!prev_sof)stamp=ticks;prev_sof=!vs;
   if(!vs)armed=1;
   if(de&&armed)begin qvalid[source_frame]=qual;qid[source_frame]=fid;qep[source_frame]=ep;qstamp[source_frame]=stamp;armed=0;source_pos=0;end
   if(dut.nms_ready&&dut.nms_packet[26])begin
    if(tx!=tap_pos%W||ty!=tap_pos/W)$fatal(1,"QUALIFICATION_RAW_COORDINATE");
    if(tv!==qvalid[tap_frame])$fatal(1,"QUALIFICATION_STICKY_OR_TAG_ADVANCE frame=%0d pos=%0d",tap_frame,tap_pos);
    if(tf!=qid[tap_frame]||te!=qep[tap_frame]||ts!=qstamp[tap_frame])$fatal(1,"QUALIFICATION_ID_EPOCH_TIMESTAMP");
    if(tv)begin if(tc!=0)$fatal(1,"QUALIFIED_ZERO_NOT_ZERO");valid_pixels=valid_pixels+1;end
    else invalid_pixels=invalid_pixels+1;
    tap_pos=tap_pos+1;if(tap_pos==N)begin tap_pos=0;tap_frame=tap_frame+1;end
   end
   // Mirror only the external qualification contract, not queue RTL indexing.
   // Sticky source invalidation takes effect after this sampling edge.
   if(de)begin
    if(!qual)qvalid[source_frame]=0;
    source_pos=source_pos+1;if(source_pos==N)source_frame=source_frame+1;
   end
  end else if(tv)$fatal(1,"QUALIFICATION_CE_DUPLICATE");
  ticks=ticks+1;
 end
 task tick(input dd,input hh,input vv,input qq);
 begin
  if(cycle%17==5)begin @(negedge clk);ce=0;repeat(3)begin @(posedge clk);#0.01;stalls=stalls+1;end end
  @(negedge clk);ce=1;de=dd;hs=hh;vs=vv;qual=qq;
  @(posedge clk);#0.01;cycle=cycle+1;
 end endtask
 initial begin
  repeat(5)@(negedge clk);rst=1;repeat(10)@(negedge clk);
  for(f=0;f<8;f=f+1)begin
   fid=64'h12340000+f;ep=90+f/4;
   for(v=0;v<VT;v=v+1)for(h=0;h<HT;h=h+1)
    tick(h>=12&&h<12+W&&v>=8&&v<8+H,h>=3,v>=2,(f!=0&&f!=3&&f!=6)&&!(f==4&&v==20&&h>=30&&h<40));
  end
  repeat(4*HT+40)tick(0,1,1,1);
  if(tap_frame!=8||dut.tag_read!=dut.tag_write||valid_pixels==0||invalid_pixels==0||stalls==0)$fatal(1,"QUALIFICATION_COVERAGE");
  before_valid=valid_pixels;before_invalid=invalid_pixels;
  // Reset a partial in-flight source raster with a live queued identity.
  fid=64'hdead0008;ep=91;
  for(v=0;v<13;v=v+1)for(h=0;h<HT;h=h+1)
   tick(h>=12&&h<12+W&&v>=8,h>=3,v>=2,1);
  if(dut.tag_read==dut.tag_write)$fatal(1,"RESET_LIVE_TAG_PRECONDITION");
  @(negedge clk);rst=0;de=0;vs=1;hs=1;qual=0;ce=1;
  repeat(5)@(negedge clk);
  tap_frame=0;tap_pos=0;source_frame=0;source_pos=0;valid_pixels=0;invalid_pixels=0;
  ticks=0;stamp=0;prev_sof=0;armed=1;rst=1;
  repeat(10)@(negedge clk);
  for(f=0;f<2;f=f+1)begin
   fid=64'habc00000+f;ep=999;
   for(v=0;v<VT;v=v+1)for(h=0;h<HT;h=h+1)
    tick(h>=12&&h<12+W&&v>=8&&v<8+H,h>=3,v>=2,f==1);
  end
  repeat(4*HT+40)tick(0,1,1,1);
  if(tap_frame!=2||dut.tag_read!=dut.tag_write||valid_pixels!=N||invalid_pixels!=N)$fatal(1,"RESET_EPOCH_TAG_COVERAGE");
  $display("REVIEW_PASS tag_qualification frames=10 discarded_partial=1 valid_zero_pixels=%0d rejected_pixels=%0d CE_stalls=%0d invalid_valid_transitions=1 midframe_sticky=1 epoch_identity=1 reset_live_tag=1 new_epoch=999",before_valid+valid_pixels,before_invalid+invalid_pixels,stalls);$finish;
 end
 initial begin #2000000;$fatal(1,"tag qualification watchdog");end
endmodule
