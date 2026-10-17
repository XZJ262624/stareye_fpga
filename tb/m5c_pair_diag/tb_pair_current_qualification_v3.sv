`timescale 1ns/1ps
module tb_pair_current_qualification_v3;
 parameter CASE=0;
 reg ui=0,pix=0,rst=0,arm=0,sof=0,valid=0,qualified=1,de=0;always #5 ui=~ui;always #7 pix=~pix;
 reg [11:0] x=0,y=0;reg [63:0] tick=0;
 wire busy,dv,empty;wire [31:0] reason;wire [127:0] data;wire [9:0] count;wire [1:0] rd,ff;
 integer i,words=0,pixels=0;reg done_seen=0;reg [31:0] saved_reason=0;
 always @(posedge ui)if(rst&&dv)begin done_seen<=1;saved_reason<=reason;end
 m5c_pair_capture #(.WIDTH(32),.HEIGHT(4)) dut(.ui_clk(ui),.pix_clk(pix),.arst_n(rst),.arm(arm),.arm_session(64'h111100000007),.cancel(1'b0),.arm_busy(busy),.done_valid(dv),.done_reason(reason),.done_take(dv),
 .source_tap_valid(valid),.source_tap_qualified(qualified),.ce(1'b1),.frame_sof(sof),.frame_admit(1'b1),.mode_cov(1'b1),.fusion_enabled(1'b1),.kill(1'b0),.identity_ok(1'b1),
 .session(64'h111100000007),.current_source_frame(64'd9),.display_seq(64'h111100000007),.pixel_ticks(tick),.final_de(de),.final_x(x),.final_y(y),.final_class(2'd0),.support(1'b0),.local_edge(1'b0),.accepted_domain(1'b0),.row_complete(1'b1),.row_tag(1'b1),.data(data),.empty(empty),.pop(!empty),.count(count),.reset_done(rd),.fifo_faults(ff));
 always @(posedge pix)if(rst)tick<=tick+1;
 always @(posedge ui)if(rst&&!empty)begin
  if(CASE==0||CASE==4||CASE==5)begin
   if(words<8&&data!==0)$fatal(1,"QUALIFIED_BLACK_PIXEL_CHANGED");
   if(words==8&&data!=={64'h111100000007,64'd9})$fatal(1,"QUALIFIED_BLACK_IDENTITY");
   if(words==9&&data[127:64]<=data[63:0])$fatal(1,"QUALIFIED_BLACK_TICKS");
   if(words>=10)$fatal(1,"QUALIFIED_EXTRA_WORD");
  end
  words=words+1;
 end
 initial begin
  repeat(5)@(negedge ui);rst=1;repeat(12)@(negedge ui);arm=1;@(negedge ui);arm=0;
  wait(dut.state==dut.WAIT);@(negedge pix);sof=1;valid=1;qualified=CASE!=1;
  @(negedge pix);sof=0;
  for(i=0;i<144;i=i+1)begin
   valid=i<128;qualified=1;
   if(CASE==5&&i<128&&i%7==3)begin valid=0;qualified=0;end
   if(CASE==2&&i>=40&&i<128)qualified=0;
   if(CASE==3&&i==127)qualified=0;
   if(CASE==4&&i>=128)qualified=0;
   if(CASE==6&&i==130)begin sof=1;valid=1;end else sof=0;
   de=i>=16;if(de)begin x=(i-16)%32;y=(i-16)/32;end
   @(negedge pix);
  end
  de=0;valid=0;sof=0;qualified=CASE!=4;
  wait(done_seen);if(CASE==1)begin if(saved_reason!=2)$fatal(1,"FIRST_UNQUALIFIED_NOT_REJECTED");end
  else if(CASE==2||CASE==3||CASE==6)begin if(saved_reason!=3)$fatal(1,"STICKY_SOURCE_LOSS_NOT_REJECTED");end
  else if(saved_reason!=0)$fatal(1,"LEGAL_BLACK_OR_TAIL_REJECTED");
  repeat(30)@(negedge ui);
  if((CASE==0||CASE==4||CASE==5)&&words!=10)$fatal(1,"LEGAL_BLACK_WORD_COVERAGE");
  if(ff)$fatal(1,"QUALIFICATION_FIFO_FAULT");
  $display("PAIR_CURRENT_QUALIFICATION_PASS case=%0d words=%0d",CASE,words);$finish;
 end
 initial begin #100000;$fatal(1,"QUALIFICATION_WATCHDOG");end
endmodule
