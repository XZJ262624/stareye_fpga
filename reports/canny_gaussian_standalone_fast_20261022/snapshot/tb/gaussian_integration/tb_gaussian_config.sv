`timescale 1ns/1ps
module tb_gaussian_config;
 `include "gaussian_contract_functions.vh"
 reg clk=0,ui=0;always #5 clk=~clk;always #7 ui=~ui;
 reg rst=0,arm=0;reg[63:0] job=1,ep=77;wire arm_busy;
 reg tv=0;reg[1:0] cls=0,filter=1;reg[11:0] x=0,y=0;reg[7:0] hi=64,lo=32;reg[63:0] gen=1;
 wire empty,dv;wire[127:0] data;wire[767:0] desc;reg take=0;wire[9:0] count;
 m5b1_capture #(.WIDTH(64),.HEIGHT(8)) cap(.ui_clk(ui),.pix_clk(clk),.arst_n(rst),.cancel(1'b0),.arm(arm),.job(job),.epoch(ep),.arm_busy(arm_busy),
  .tap_valid(tv),.tap_class(cls),.tap_x(x),.tap_y(y),.tap_high(hi),.tap_low(lo),.tap_filter(filter),.tap_frame_id(64'd123),.tap_epoch(ep),.tap_timestamp(64'd100),.tap_display_seq(64'd7),.tap_config_generation(gen),
  .data(data),.empty(empty),.pop(!empty),.count(count),.descriptor_valid(dv),.descriptor(desc),.descriptor_take(take),.reset_done(),.dropped(),.fifo_min_bytes(),.fifo_max_bytes(),.fifo_faults());
 reg req=0;reg[63:0] reqseq=1;reg[159:0] reqcfg=0;reg[767:0] resultdesc=0;wire acq;integer acquires=0;
 always @(posedge ui)if(acq)acquires=acquires+1;
 m5c_display_session session(.ui_clk(ui),.pix_clk(clk),.rst_n(rst),.stop(1'b0),.request_frame(req),.request_seq(reqseq),.request_config(reqcfg),
  .pixel_release(1'b0),.pixel_release_final(1'b0),.pixel_release_session(64'd0),.pixel_release_ready(),
  .result_valid(1'b1),.result_slot(1'b0),.result_descriptor(resultdesc),.export_exclusive(1'b0),.acquire(acq),.lease_slot(),.lease_identity(),.lease_token(),.acquire_ack(1'b0),.acquire_denied(acq),.pair_leased(4'd0),.lease_release(),.lease_retire(),.read_accept(),.read_done(),.session_fault(),
  .telemetry_pending(1'b0),.telemetry_descriptor(),.telemetry_session(),.offer_valid(),.offer_take(1'b1),.offer_descriptor(),.offer_session(),.context_block(),.context_quiet(1'b1),.context_tail_fault(1'b0),.ce(1'b1),.read_valid(1'b0),.read_x(12'd0),.read_y(12'd0),.read_session(64'd0),.ref_ready(),.ref_class(),.ref_mask(),.ref_x(),.ref_y(),.ref_session(),.retire(1'b0),.retire_row(12'd0),.flush(1'b1),.prefilled(),
  .avalid(),.aready(1'b0),.aaddr(),.alen(),.aid(),.atype(),.rvalid(1'b0),.rlast(1'b0),.rdata(128'd0),.rid(8'd0),.rresp(2'd0),.rready(),.rejected(1'b0),.read_permission());
 reg[159:0] cfg,c;reg[767:0] d;reg[2047:0] path;reg[159:0] expected[0:8];integer i,j,k,checks=0,before_acq;
 task pix;begin @(posedge clk);#1;@(negedge clk);end endtask
 task uit;begin @(posedge ui);#1;@(negedge ui);end endtask
 task request(input[159:0] c0,input[767:0] d0,input integer yes);
 begin
  reqcfg=c0;resultdesc=d0;reqseq=reqseq+1;before_acq=acquires;req=1;pix;req=0;repeat(25)uit;
  if(acquires-before_acq!=yes)$fatal(1,"GAUSS_SESSION_REJECT_OLD_SCHEMA_OR_FILTER got=%0d expected=%0d",acquires-before_acq,yes);checks=checks+1;
 end endtask
 initial begin
  if(!$value$plusargs("VECTORS=%s",path))$fatal(1,"GAUSS_VECTOR_PATH");$readmemh(path,expected);
  for(i=0;i<3;i=i+1)for(j=0;j<3;j=j+1)begin
   c=gauss_config(64'd9,12'd1280,12'd720,(j==0?8'd0:j==1?8'd64:8'd255),(j==0?8'd0:j==1?8'd32:8'd127),i[1:0]);
   if(c!==expected[i*3+j]||!gauss_config_valid(c))$fatal(1,"GAUSS_CONFIG_INDEPENDENT_VECTOR");checks=checks+1;
  end
  c=gauss_config(9,1280,720,64,32,2);c[95:88]=1;if(gauss_config_valid(c))$fatal(1,"GAUSS_SCHEMA1_ACCEPTED");
  for(i=0;i<26;i=i+1)begin c=gauss_config(9,1280,720,64,32,2);c[i]=1;if(gauss_config_valid(c))$fatal(1,"GAUSS_RESERVED_ACCEPTED");end
  c=gauss_config(9,1280,720,64,32,3);if(gauss_config_valid(c))$fatal(1,"GAUSS_FILTER3_ACCEPTED");
  c=gauss_config(64'hffffffffffffffff,1280,720,64,32,1);if(gauss_config_valid(c))$fatal(1,"GAUSS_MAX_ACCEPTED");
  repeat(4)pix;rst=1;repeat(12)pix;
  for(k=0;k<6;k=k+1)begin
   filter=k==0?1:k==1?2:k==2?0:k==4?3:1;gen=k==5?64'hffffffffffffffff:1;hi=64;lo=32;job=job+1;
   @(negedge ui);arm=1;uit;arm=0;wait(cap.arm_valid);@(negedge clk);
   for(i=0;i<512;i=i+1)begin tv=1;x=i%64;y=i/64;cls=i%3;hi=k==3&&i==10?80:64;pix;end
   tv=0;wait(dv);#1;
   if(desc[308]!== (k<3))$fatal(1,"GAUSS_CAPTURE_METADATA_STABILITY case=%0d",k);
   if(k<3&&!gauss_descriptor_valid(desc,64,8))$fatal(1,"GAUSS_CAPTURE_CANONICAL_DESCRIPTOR");
   $display("CAPTURE_CASE case=%0d success=%b filter=%0d",k,desc[308],desc[310:309]);
   take=1;uit;take=0;repeat(12)pix;
  end
  d=0;d[63:0]=77;d[127:64]=123;d[255:192]=100;d[263:256]=64;d[271:264]=32;d[272]=1;d[275:273]=3;d[283:276]=2;d[295:284]=1280;d[307:296]=720;d[308]=1;d[310:309]=1;d[447:384]=9;d[575:512]=100;d[735:576]=gauss_config(9,1280,720,64,32,1);d[743:736]=2;d[751:744]=1;
  cfg=d[735:576];if(!gauss_descriptor_valid(d,1280,720))$fatal(1,"GAUSS_DESC_SETUP");
  request(gauss_config(9,1280,720,64,32,2),d,0);request(gauss_config(10,1280,720,64,32,1),d,0);
  d[743:736]=1;request(cfg,d,0);d[743:736]=2;d[310:309]=2;request(cfg,d,0);d[310:309]=1;
  request(cfg,d,1);
  $display("PASS_GAUSSIAN_CONFIG checks=%0d captures=6 reserved_rejected=26 actual_session_acquires=%0d",checks,acquires);$finish;
 end
 initial begin #200000;$fatal(1,"GAUSS_CONFIG_WATCHDOG");end
endmodule
