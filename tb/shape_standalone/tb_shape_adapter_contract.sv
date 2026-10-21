`timescale 1ns/1ps
module tb_shape_adapter_contract;
 `include "shape_portable_io.svh"

 reg clk=0;always #5 clk=~clk;
 reg rst_n=0,ce=1,ss=0,sd=0,sq=1,fd=0,fs=1,fe=0,rf=0;
 reg [63:0] sid=0,sep=1,scfg=7,sseq=0;reg [11:0] x=0,y=0;
 wire [1:0] dc,rc;wire dv,done,rv,fault,cs,cf,aq;
 wire [63:0] did,dep,dcfg,dseq,rid,rep,rcfg,rseq,aid,aep,acfg,aseq;
 shape_stream_adapter_contract_v2 dut(.clk(clk),.rst_n(rst_n),.ce(ce),.source_sof(ss),.source_de(sd),.source_qualified(sq),.source_frame_id(sid),.source_epoch(sep),.source_config(scfg),.source_display_seq(sseq),.final_de(fd),.final_support(fs),.final_edge(fe),.final_raster_fault(rf),.final_x(x),.final_y(y),.display_class(dc),.display_valid(dv),.display_frame_id(did),.display_epoch(dep),.display_config(dcfg),.display_source_seq(dseq),.result_done(done),.result_valid(rv),.result_class(rc),.result_frame_id(rid),.result_epoch(rep),.result_config(rcfg),.result_source_seq(rseq),.adapter_fault(fault),.recognition_sof(cs),.recognition_eof(cf),.aligned_frame_id(aid),.aligned_epoch(aep),.aligned_config(acfg),.aligned_source_seq(aseq),.aligned_qualified(aq));
 reg [511:0] edges[0:383];reg [4095:0] root,path;
 integer portable_i;
 integer j,k,n,i;reg[511:0] held;reg[255:0] expected_tag;
 task tick;begin @(posedge clk);#1;@(negedge clk);end endtask
 task reset_all;begin rst_n=0;ss=0;sd=0;fd=0;sq=1;rf=0;ce=1;repeat(3)tick;rst_n=1;repeat(3)tick;end endtask
 task source(input [63:0] id,ep,cfg,seq,input good);begin
  sd=0;sid=id;sep=ep;scfg=cfg;sseq=seq;sq=good;ss=1;tick;ss=0;sd=1;tick;sd=0;expected_tag={id,ep,cfg,seq};
 end endtask
 task first;begin fd=1;x=0;y=0;fs=0;fe=0;tick;fd=0;fs=1;
  if({aid,aep,acfg,aseq}!==expected_tag)$fatal(1,"ADAPTER_FIRST_TAG");
 end endtask
 task roi(input integer inject);begin
  for(j=0;j<384;j=j+1)for(k=0;k<512;k=k+1)begin
   fd=1;x=k+384;y=j+168;fe=edges[j][k];fs=1;
   if(j==190&&k==200)begin
    if(inject==1)begin sd=1;sq=0;end
    if(inject==2)sep=sep+1;
    if(inject==3)scfg=scfg+1;
    if(inject==4)begin
     ce=0;held={dut.wr,dut.rd,dut.current_tag,dc,dv,dut.recognize.state,dut.recognize.pixels};repeat(5)tick;
     if(held!=={dut.wr,dut.rd,dut.current_tag,dc,dv,dut.recognize.state,dut.recognize.pixels})$fatal(1,"ADAPTER_CE");ce=1;
    end
   end
   if(j==191&&k==200&&inject==1)begin sq=1;sd=0;end
   tick;
  end
  fd=0;fe=0;
 end endtask
 task finish(input integer exp,input integer valid_expected);begin
  fd=1;x=1279;y=719;fs=0;tick;fd=0;fs=1;tick;
  n=0;while(!done&&n<4096)begin tick;n=n+1;end
  if(!done||rc!==exp||rv!==valid_expected)$fatal(1,"ADAPTER_RESULT expected=%0d/%0d actual=%0d/%0d",exp,valid_expected,rc,rv);
  if({rid,rep,rcfg,rseq}!==expected_tag)$fatal(1,"ADAPTER_RESULT_TAG");
  $display("ADAPTER_RESULT id=%0d epoch=%0d cfg=%0d seq=%0d class=%0d valid=%0d cycles=%0d",rid,rep,rcfg,rseq,rc,rv,n);
  tick;
 end endtask
 initial begin
  if(!$value$plusargs("ROOT=%s",root))$fatal(1,"ROOT");
  $sformat(path,"%0s/data/edge_030.hex",root);portable_require_file(path);
  for(portable_i=0;portable_i<384;portable_i=portable_i+1)edges[portable_i]='x;
  $readmemh(path,edges);
  for(portable_i=0;portable_i<384;portable_i=portable_i+1)if(^edges[portable_i]===1'bx)$fatal(1,"INPUT_DATA_UNKNOWN path=%0s index=%0d",path,portable_i);
  reset_all;source(10,1,7,100,1);first;roi(4);finish(2,1);
  source(10,1,7,101,1);first;if(!dv||dc!=2||did!=10||dep!=1||dseq!=100)$fatal(1,"ADAPTER_REPEAT_SOURCE_DISPLAY");roi(0);finish(2,1);
  source(999,1,7,102,1);first;if(!dv||dc!=2||did!=10||dseq!=101)$fatal(1,"ADAPTER_SKIP_SOURCE_DISPLAY");roi(0);finish(2,1);
  source(999,2,7,103,1);first;if(dv||dc!=0)$fatal(1,"EPOCH_PENDING_REUSED");roi(0);finish(2,1);
  source(999,2,8,104,1);first;if(dv||dc!=0)$fatal(1,"CONFIG_PENDING_REUSED");roi(0);finish(2,1);
  source(999,2,8,105,0);first;if(dv||dc!=0)$fatal(1,"INVALID_FRAME_DISPLAY");roi(0);finish(0,0);
  for(i=1;i<=3;i=i+1)begin source(1000+i,5,7,200+i,1);first;roi(i);finish(0,0);end
  source(2000,5,7,300,1);first;roi(0);sd=1;sq=0;finish(0,0);
  source(2001,5,7,301,1);first;roi(0);finish(2,1);
  // FIFO overflow poisons association, cannot silently relabel later frames.
  reset_all;source(1,1,7,1,1);source(2,1,7,2,1);source(3,1,7,3,1);
  if(!fault||aq)$fatal(1,"QUEUE_OVERFLOW_NOT_REJECTED");
  reset_all;source(1,1,7,1,1);first;finish(0,0);source(2,1,7,2,1);first;finish(0,0);
  source(3,1,7,3,1);source(4,1,7,4,1);source(5,1,7,5,1);
  if(!fault||aq)$fatal(1,"QUEUE_WRAP_OVERFLOW_NOT_REJECTED");
  reset_all;fd=1;x=0;y=0;tick;fd=0;if(fault||dv)$fatal(1,"STARTUP_DISCARD_NOT_ALLOWED");
  reset_all;source(9,1,7,9,1);first;finish(0,0);fd=1;x=0;y=0;tick;fd=0;if(!fault||dv)$fatal(1,"QUEUE_MISSING_NOT_REJECTED");
  // Immediate new first pixel on EOF control beat is malformed, rejected.
  reset_all;source(4,1,7,4,1);first;fd=1;x=1279;y=719;tick;x=0;y=0;tick;fd=0;
  if(!fault||dv)$fatal(1,"EOF_SOF_COLLISION");
  reset_all;source(5000,99,9,500,1);first;roi(0);finish(2,1);
  if(fault)$fatal(1,"RESET_RECOVERY_FAULT");
  $display("PASS_ADAPTER_LIFECYCLE");$finish;
 end
 initial begin #100000000;$fatal(1,"ADAPTER_WATCHDOG");end
endmodule
