`timescale 1ns/1ps
module tb_pair_capture_pressure;
 parameter CASE=0;
 reg ui=0,pix=0;always #5 ui=~ui;always #7 pix=~pix;
 reg rst=0,arm=0,cancel=0,ce=1,sof=0,admit=1,cov=1,en=1,kill=0,idok=1,de=0;
 reg [63:0] sid=64'h1234567800000035,frameid=7,seq=64'h1234567800000035,tick=0;
 reg [11:0] x=0,y=0;reg [1:0] cl=0;reg support=0,local_edge=0,domain=0,complete=1,tag=1;
 wire busy,dv,empty;wire [31:0] reason;wire [127:0] data;wire [9:0] count;wire [1:0] resetdone,fault;
 reg take=0;reg checking=0;reg drain=0;wire pop=!empty&&drain;
 integer words=0,pixels=0,j,n;reg [7:0] expected;
 m5c_pair_capture #(.WIDTH(1280),.HEIGHT(8)) dut(.ui_clk(ui),.pix_clk(pix),.arst_n(rst),.arm(arm),.arm_session(sid),.cancel(cancel),.arm_busy(busy),.done_valid(dv),.done_reason(reason),.done_take(take),.ce(ce),.frame_sof(sof),.frame_admit(admit),.mode_cov(cov),.fusion_enabled(en),.kill(kill),.identity_ok(idok),.session(sid),.current_source_frame(frameid),.display_seq(seq),.pixel_ticks(tick),.final_de(de),.final_x(x),.final_y(y),.final_class(cl),.support(support),.local_edge(local_edge),.accepted_domain(domain),.row_complete(complete),.row_tag(tag),.data(data),.empty(empty),.pop(pop),.count(count),.reset_done(resetdone),.fifo_faults(fault));
 always @(posedge pix)if(rst)tick<=tick+1;
 always @(posedge ui)if(rst&&pop)begin
  if(checking&&words<640)for(j=0;j<16;j=j+1)begin
   n=words*16+j;expected={3'd0,n[0],n[1],n[2],2'(n%3)};
   if(data[j*8+:8]!==expected)$fatal(1,"PAIR_PIXEL_MISMATCH n=%0d expected=%h actual=%h",n,expected,data[j*8+:8]);pixels=pixels+1;
  end else if(checking&&words==640)begin if(data!=={seq,64'd7})$fatal(1,"PAIR_TAIL_IDENTITY");end
  else if(checking&&words==641)begin if(data[127:64]<=data[63:0])$fatal(1,"PAIR_TAIL_TIME");end
  else if(checking)$fatal(1,"PAIR_EXTRA_WORD");
  words=words+1;
 end
 task frame_send(input bad);
 integer i;
 begin
  wait(dut.state==1);repeat(3)@(negedge pix);sof=1;@(negedge pix);sof=0;repeat(2)@(negedge pix);
  for(i=0;i<10240;i=i+1)begin
   @(negedge pix);de=1;x=i%1280;y=i/1280;cl=i%3;support=(i>>2)&1;local_edge=(i>>1)&1;domain=i&1;
   if(bad&&CASE==1&&i==2047)cancel=1;
  end
  @(negedge pix);de=0;
 end endtask
 initial begin
  repeat(8)@(negedge ui);rst=1;wait(&resetdone);repeat(8)@(negedge ui);arm=1;@(negedge ui);arm=0;
  frame_send(1);
  wait(dv);repeat(10)@(negedge ui);
  if(reason!==(CASE==0?32'd5:32'd3))$fatal(1,"PAIR_PRESSURE_REASON actual=%d",reason);
  if(CASE==0&&count!=512)$fatal(1,"PAIR_FIFO_CAPACITY_NOT_EXERCISED count=%d",count);
  $display("PAIR_PRESSURE_FAILURE reason=%d count=%d",reason,count);
  take=1;drain=1;@(negedge ui);take=0;wait(empty);wait(!dut.send_busy&&!busy);repeat(10)@(negedge ui);
  if(fault!=0)$fatal(1,"PAIR_FIFO_PHYSICAL_FAULT");
  cancel=0;sid=sid+1;seq=sid;words=0;pixels=0;checking=1;
  repeat(10)@(negedge ui);arm=1;@(negedge ui);arm=0;
  frame_send(0);wait(dv);repeat(15)@(negedge ui);
  if(reason!==0||words!=642||pixels!=10240||fault!=0)$fatal(1,"PAIR_RETRY_CORRUPTED words=%d pixels=%d reason=%d",words,pixels,reason);
  take=1;@(negedge ui);take=0;repeat(10)@(negedge ui);
  $display("PAIR_CAPTURE_PRESSURE_PASS case=%0d words=%0d pixels=%0d",CASE,words,pixels);$finish;
 end
 initial begin #2000000;$fatal(1,"PAIR_CAPTURE_WATCHDOG");end
endmodule

