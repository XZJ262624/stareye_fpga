`timescale 1ns/1ps
module tb_diag_observer_v2_invalid;
 parameter CASE=0;
 reg clk=0;always #5 clk=~clk;
 reg rst=0,ctx_event=0,ctx_valid=0,sof=0,admit=0,kill=0,de=0,eof=0;
 reg [63:0] sid=64'h123456789abcdef0,token=64'h1122334455667788,epoch=64'h0102030405060708,ticks=0;
 reg [767:0] desc=0;
 reg [11:0] x=0,y=0;
 reg qual=1,bounds=1,tag=1,fok=1,inv=0,weak_bit=0,support=1,glob=0,local_edge=0,complete=1,equal_row=1,rtag=1;
 reg [2:0] mode=6;reg enable=1;
 wire promoted=de&&bounds&&qual&&tag&&fok&&!inv&&weak_bit&&support&&glob&&!local_edge&&complete&&equal_row&&rtag;
 wire [23:0] rgb=CASE==1?24'h00ffff:local_edge?24'hff0000:promoted?24'h00ffff:24'h222222;
 reg cv=0,cq=1,rq=1;reg [1:0] cc=0,rc=0;reg rm=0;
 wire ready,active;reg take=0;reg [5:0] ra=0;wire [63:0] data,drops;
 wire [23:0] orgb;wire ode,oh,ov;reg vs=1;
 m5a_osd osd(.clk(clk),.ce(1'b1),.arst_n(rst),.rgb(rgb),.de(de),.hs(1'b1),.vs(vs),.threshold(8'd64),.mode(mode),.fusion_enable(enable),.fusion_active(fok),.fusion_age_valid(1'b1),.fusion_age(32'd20),.out_rgb(orgb),.out_de(ode),.out_hs(oh),.out_vs(ov));
 m5c_diag_observer_v2 #(.SAMPLE_FRAMES(2)) dut(.clk(clk),.read_clk(clk),.record_cancel(1'b0),.admit_mode(mode),.rst_n(rst),.context_event(ctx_event),.context_valid(ctx_valid),.context_session(sid),.context_token(token),.current_epoch(epoch),.source_descriptor(desc),.context_slot(1'b1),.frame_sof(sof),.frame_admit(admit),.frame_session(sid),.pixel_ticks(ticks),.kill(kill),.abort_reason(32'h40),.final_de(de),.frame_eof(eof),.final_x(x),.final_y(y),.final_qualified(qual),.legal_bounds(bounds),.tag_good(tag),.frame_ok(fok),.invalidate(inv),.delayed_weak(weak_bit),.delayed_support(support),.delayed_global(glob),.local_edge(local_edge),.row_complete(complete),.row_equal(equal_row),.row_tag_good(rtag),.promoted(promoted),.mode(mode),.enable(enable),.fused_rgb(rgb),.osd_rgb(orgb),.osd_de(ode),.compare_valid(cv),.current_qualified(cq),.reference_qualified(rq),.compare_x(x),.compare_y(y),.reference_x(x),.reference_y(y),.current_class(cc),.reference_class(rc),.reference_mask(rm),.compare_session(sid),.reference_session(sid),.record_ready(ready),.record_take(take),.read_word(ra),.word_data(data),.dropped(drops),.active(active));
 always @(posedge clk)if(rst)ticks<=ticks+1;
 integer tracefile,outfile,k,px,py,recordno=0;reg [2047:0] outpath,expectpath;reg [511:0] fatalname;reg compare_expected=0;reg [63:0] expected_words[0:39];
 task step;begin
  @(posedge clk);
  $fwrite(tracefile,"%0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d\n",recordno,de,eof,kill,qual,bounds,tag,fok,inv,weak_bit,support,glob,local_edge,complete,equal_row,rtag,mode,enable,rgb,ode,orgb,cv,cq,rq,x,y,cc,rc,ticks);
  #1;@(negedge clk);
 end endtask
 task pulse_sof;begin
  @(negedge clk);sof=1;admit=1;vs=0;@(posedge clk);#1;@(negedge clk);sof=0;admit=0;vs=1;
 end endtask
 task prepare;begin
  @(negedge clk);ctx_valid=1;ctx_event=1;@(negedge clk);ctx_event=0;repeat(25)@(negedge clk);
 end endtask
 task render;begin:body
  if(CASE==4)begin
   force dut.p0=32'hfffffffe;force dut.p1=32'hfffffffe;force dut.p2=32'hfffffffe;force dut.p3=32'hfffffffe;force dut.p4=32'hfffffffe;
   @(posedge clk);#1;release dut.p0;release dut.p1;release dut.p2;release dut.p3;release dut.p4;@(negedge clk);
  end
  for(py=0;py<40;py=py+1)begin
   for(px=0;px<48;px=px+1)begin
    de=1;x=px;y=py;eof=px==47&&py==39;weak_bit=(px+3*py)%5==0;glob=(px+py)%3!=0;local_edge=(px+py)%11==0;equal_row=py%3!=0;
    qual=px%7!=0;bounds=px%11!=0;tag=px%13!=0;fok=py%9!=0;inv=px%17==0;support=px%19!=0;complete=py%5!=0;rtag=py%7!=0; cq=!(px==7&&py==2);rq=1;
    cv=1;cc=1;rc=(px==7&&py==2)||(px==9&&py==4)?2:1;rm=1;
    if(CASE==2)begin weak_bit=eof;glob=1;local_edge=0;equal_row=1;end
    if(CASE==7)begin weak_bit=0;glob=0;local_edge=0;cv=0;end
    if(CASE==3&&px==20&&py==5)kill=1;
    step;
    if(kill)begin de=0;cv=0;eof=0;kill=0;disable body;end
   end
   de=0;cv=0;eof=0;step;
  end
  de=0;cv=0;eof=0;step;
 end endtask
 task dump;begin
  wait(ready);repeat(3)@(negedge clk);
  // Poison all live inputs after completion: record must remain immutable.
  desc=~desc;token=~token;epoch=~epoch;
  for(k=0;k<40;k=k+1)begin ra=k;@(posedge clk);#1;$fwrite(outfile,"%016h\n",data);if(compare_expected&&data!==expected_words[k])$fatal(1,"%0s word=%0d",fatalname,k);@(negedge clk);end
  repeat(40)@(negedge clk);
  for(k=0;k<40;k=k+1)begin ra=k;@(posedge clk);#1;$fwrite(outfile,"%016h\n",data);@(negedge clk);end
 end endtask
 initial begin
  if(!$value$plusargs("OUT=%s",outpath))$fatal(1,"DIAG_OUT_REQUIRED");
  if($value$plusargs("EXPECT=%s",expectpath))begin compare_expected=1;$readmemh(expectpath,expected_words);end
  if(!$value$plusargs("FATAL_NAME=%s",fatalname))fatalname="DIAG_SOFTWARE_EXPECTATION";
  tracefile=$fopen({outpath,"/trace.txt"},"w");outfile=$fopen({outpath,"/records.hex"},"w");
  desc[63:0]=epoch;desc[127:64]=64'hfedcba9876543210;desc[191:128]=64'h1020304050607080;desc[255:192]=64'h12340000;
  desc[319:256]={11'd0,1'b1,12'd720,12'd1280,8'd1,3'd3,1'b1,8'd32,8'd64};
  desc[383:320]=64'h100;desc[447:384]=64'h55;desc[511:448]=64'h99;desc[575:512]=64'h12340000;
  desc[735:576]={64'h55,8'd1,8'd1,12'd1280,12'd720,8'd64,8'd32,1'b1,3'd3,8'd1,28'd0};desc[751:736]=16'h0101;
  mode=CASE==1?2:6;
  repeat(5)@(negedge clk);rst=1;repeat(5)@(negedge clk);
  if(CASE==5)pulse_sof;
  if(CASE==6)begin prepare;pulse_sof;de=1;repeat(3)@(negedge clk);rst=0;de=0;ctx_valid=0;repeat(4)@(negedge clk);rst=1;repeat(4)@(negedge clk);if(ready)$fatal(1,"DIAG_RESET_READY");end
  prepare;if(CASE==5)pulse_sof;pulse_sof;
  if(!active)$fatal(1,"DIAG_NOT_ADMITTED");render;dump;
  if(CASE==5)begin
   pulse_sof;pulse_sof;if(drops!=2)$fatal(1,"DIAG_PERIOD_DROP");
   take=1;@(negedge clk);take=0;recordno=1;sid=sid+1;desc=~desc;token=~token;epoch=~epoch;
   prepare;pulse_sof;pulse_sof;if(!active)$fatal(1,"DIAG_PERIOD_REARM");render;dump;
  end
  take=1;@(negedge clk);take=0;@(posedge clk);#1;if(ready)$fatal(1,"DIAG_ACK_CLEAR");
  $fclose(tracefile);$fclose(outfile);$display("DIAG_SIM_DONE case=%0d",CASE);$finish;
 end
 initial begin #2000000;$fatal(1,"DIAG_WATCHDOG");end
endmodule
