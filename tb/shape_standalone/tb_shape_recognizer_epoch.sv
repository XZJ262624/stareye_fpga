`timescale 1ns/1ps
module tb_shape_recognizer_epoch #(parameter LIMIT=32768);
 `include "shape_portable_io.svh"

 reg clk=0;always #5 clk=~clk;
 reg rst_n=0,ce=1,sof=0,eof=0,active=0,support=1,edge_pixel=0,source_valid=1;
 reg [11:0] x=0,y=0;reg [63:0] frame_id=0,config_generation=7;
 wire done,valid,dvalid,busy;wire [1:0] category,dc;
 wire [63:0] rid,rcfg,did,dcfg;
 shape_recognizer_epoch #(.ANALYSIS_LIMIT(LIMIT)) dut(.clk(clk),.rst_n(rst_n),.ce(ce),.sof(sof),.eof(eof),.active(active),.support(support),.edge_pixel(edge_pixel),.source_valid(source_valid),.x(x),.y(y),.frame_id(frame_id),.config_generation(config_generation),.epoch(64'd1),.source_display_seq(64'd1),.result_done(done),.result_valid(valid),.result_class(category),.result_frame_id(rid),.result_config_generation(rcfg),.display_class(dc),.display_valid(dvalid),.display_frame_id(did),.display_config_generation(dcfg),.busy(busy));
 reg [511:0] bitmap[0:383];reg [1:0] expected[0:103];reg expected_valid[0:103];
 integer portable_i;
 integer i,j,k,n,fd,which=0,limit=100;reg [4095:0] path,root;reg [255:0] saved;
 task tick;begin @(posedge clk);#1;@(negedge clk);end endtask
 task start_frame;begin frame_id=frame_id+1;sof=1;active=0;eof=0;tick;sof=0;end endtask
 task send_roi(input integer fault);begin
  for(j=0;j<384;j=j+1)for(k=0;k<512;k=k+1)begin
   active=1;x=k+384;y=j+168;edge_pixel=bitmap[j][k];support=1;
   if(fault==1 && j==383 && k==511)x=894;
   if(fault==2 && j==190 && k==250)support=0;
   if(fault==3 && j==190 && k==250)config_generation=8;
   if(fault==4 && j==190 && k==250)source_valid=0;
   if(fault==5 && j==190 && k==250)frame_id=frame_id+1;
   if(fault==6 && j==190 && k==250)begin ce=0;saved={dut.state,dut.pixels,dut.ex,dut.ey,dut.left_x,dut.right_x,dut.edge_count,dut.segments,dc,dvalid};repeat(7)tick;if(saved!={dut.state,dut.pixels,dut.ex,dut.ey,dut.left_x,dut.right_x,dut.edge_count,dut.segments,dc,dvalid})$fatal(1,"CE_STATE_CHANGED");ce=1;end
   tick;
  end
  active=0;edge_pixel=0;support=1;
 end endtask
 task finish_frame(input integer exp,input integer ev);begin
  eof=1;tick;eof=0;n=0;
  while(!done && n<33000)begin tick;n=n+1;end
  if(!done)$fatal(1,"DEADLINE_NO_DONE");
  if(n>4096)$fatal(1,"REALTIME_ANALYSIS_BUDGET");
  if(category!==exp || valid!==ev)$fatal(1,"RESULT_MISMATCH id=%0d expected=%0d/%0d actual=%0d/%0d",frame_id,exp,ev,category,valid);
  if(rcfg!==dut.cfg || rid!==dut.fid)$fatal(1,"RESULT_IDENTITY");
  $display("RESULT id=%0d class=%0d valid=%0d cycles=%0d",rid,category,valid,n);
  tick;
 end endtask
 initial begin
  if(!$value$plusargs("ROOT=%s",root))$fatal(1,"ROOT_REQUIRED");
  if($value$plusargs("WHICH=%d",which))begin end
  repeat(4)tick;rst_n=1;repeat(4)tick;
  path={root,"/data/expected.hex"};portable_require_file(path);
  for(portable_i=0;portable_i<104;portable_i=portable_i+1)expected[portable_i]='x;
  $readmemh(path,expected);
  for(portable_i=0;portable_i<104;portable_i=portable_i+1)if(^expected[portable_i]===1'bx)$fatal(1,"INPUT_DATA_UNKNOWN path=%0s index=%0d",path,portable_i);
  path={root,"/data/expected_valid.hex"};portable_require_file(path);
  for(portable_i=0;portable_i<104;portable_i=portable_i+1)expected_valid[portable_i]='x;
  $readmemh(path,expected_valid);
  for(portable_i=0;portable_i<104;portable_i=portable_i+1)if(^expected_valid[portable_i]===1'bx)$fatal(1,"INPUT_DATA_UNKNOWN path=%0s index=%0d",path,portable_i);
  if(which==0)begin
   for(i=0;i<104;i=i+1)begin
    $sformat(path,"%0s/data/edge_%0s.hex",root,portable_dec3(i));portable_require_file(path);
  for(portable_i=0;portable_i<384;portable_i=portable_i+1)bitmap[portable_i]='x;
  $readmemh(path,bitmap);
  for(portable_i=0;portable_i<384;portable_i=portable_i+1)if(^bitmap[portable_i]===1'bx)$fatal(1,"INPUT_DATA_UNKNOWN path=%0s index=%0d",path,portable_i);
    start_frame;send_roi(i==0?6:0);finish_frame(expected[i],expected_valid[i]);
   end
   $display("PASS_RTL_MODEL_104");
  end else if(which==3)begin
   for(i=0;i<3;i=i+1)begin
    // Exact bbox 80, 279, 280. Independent perimeter geometry, not class output.
    limit=(i==0)?80:(i==1)?279:280;
    for(j=0;j<384;j=j+1)begin
     bitmap[j]=0;
     if(j>=40 && j<40+limit)for(k=80;k<80+limit;k=k+1)
      if(j==40||j==39+limit||k==80||k==79+limit)bitmap[j][k]=1;
    end
    start_frame;send_roi(0);finish_frame(2,1);
   end
   $display("PASS_SIZE_DEADLINE_BOUNDARIES");
  end else if(which==2)begin
   $sformat(path,"%0s/data/edge_000.hex",root);portable_require_file(path);
  for(portable_i=0;portable_i<384;portable_i=portable_i+1)bitmap[portable_i]='x;
  $readmemh(path,bitmap);
  for(portable_i=0;portable_i<384;portable_i=portable_i+1)if(^bitmap[portable_i]===1'bx)$fatal(1,"INPUT_DATA_UNKNOWN path=%0s index=%0d",path,portable_i);
   start_frame;send_roi(0);finish_frame(0,0);
   if(n>LIMIT+2)$fatal(1,"BUDGET_EXCEEDED");
   start_frame;if(dvalid||dc)$fatal(1,"TIMEOUT_DISPLAY");
   $display("PASS_BUDGET_EXHAUSTION");
  end else begin
   $sformat(path,"%0s/data/edge_030.hex",root);portable_require_file(path);
  for(portable_i=0;portable_i<384;portable_i=portable_i+1)bitmap[portable_i]='x;
  $readmemh(path,bitmap);
  for(portable_i=0;portable_i<384;portable_i=portable_i+1)if(^bitmap[portable_i]===1'bx)$fatal(1,"INPUT_DATA_UNKNOWN path=%0s index=%0d",path,portable_i);
   start_frame;send_roi(0);finish_frame(2,1);
   start_frame;if(dc!==2 || !dvalid || did!==frame_id-1)$fatal(1,"NEXT_SOF_LATCH");
   // Missing completed result at subsequent SOF must clear the old class.
   start_frame;if(dc!==0 || dvalid)$fatal(1,"STALE_DISPLAY_REUSED");
   send_roi(1);finish_frame(0,0);
   for(i=2;i<=6;i=i+1)begin config_generation=7;source_valid=1;start_frame;send_roi(i);finish_frame(i==6?2:0,i==6?1:0);end
   // ROI last row/last pixel: must enter RAM even though touching ROI invalidates class.
   for(j=0;j<384;j=j+1)bitmap[j]=0;
   bitmap[383][511]=1;
   config_generation=7;source_valid=1;start_frame;send_roi(0);
   if(dut.rows[383][23]!==1 || dut.rows[383][17:9]!==511 || dut.rows[383][8:0]!==511)$fatal(1,"LAST_ROW_LAST_PIXEL_DROPPED");
   finish_frame(0,0);
   // Blank is a complete but unclassifiable frame, marked invalid (no contour).
   for(j=0;j<384;j=j+1)bitmap[j]=0;
   start_frame;send_roi(0);finish_frame(0,0);
   // Missing EOF and preemption: no stale result; recovery after reset.
   start_frame;repeat(5)tick;start_frame;if(!done || valid || category!=0)$fatal(1,"PREEMPT_CAPTURE");
   rst_n=0;tick;rst_n=1;tick;if(dc!=0||dvalid||busy)$fatal(1,"RESET_CLEAR");
   $sformat(path,"%0s/data/edge_000.hex",root);portable_require_file(path);
  for(portable_i=0;portable_i<384;portable_i=portable_i+1)bitmap[portable_i]='x;
  $readmemh(path,bitmap);
  for(portable_i=0;portable_i<384;portable_i=portable_i+1)if(^bitmap[portable_i]===1'bx)$fatal(1,"INPUT_DATA_UNKNOWN path=%0s index=%0d",path,portable_i);
   start_frame;send_roi(0);eof=1;tick;eof=0;
   ce=0;saved={dut.state,dut.budget,dut.scan,dut.remainder,dut.bin,done,category};repeat(5)tick;
   if(saved!={dut.state,dut.budget,dut.scan,dut.remainder,dut.bin,done,category})$fatal(1,"ANALYSIS_CE_CHANGED");ce=1;
   // Interrupt analysis on the exact FINISH beat: SOF priority discards it.
   n=0;while(dut.state!=6 && n<33000)begin tick;n=n+1;end
   start_frame;if(!done||valid||category!=0||dvalid)$fatal(1,"SOF_FINISH_PRIORITY");
   send_roi(0);finish_frame(1,1);
   // Source IDs may repeat or skip; consumption is the next display SOF.
   frame_id=frame_id-1;start_frame;if(dc!=1||!dvalid||did!=rid)$fatal(1,"REPEATED_SOURCE_ID");
   send_roi(0);finish_frame(1,1);
   frame_id=frame_id+99;start_frame;if(dc!=1||!dvalid||did!=rid)$fatal(1,"SKIPPED_SOURCE_ID");
   config_generation=8;tick;if(dc!=0||dvalid)$fatal(1,"CONFIG_DISPLAY_CLEAR");
   config_generation=7;start_frame;send_roi(0);
   active=1;x=895;y=551;tick;active=0;finish_frame(0,0);
   // More than two separated segments must reject without counter wrap.
   for(j=0;j<384;j=j+1)bitmap[j]=0;
   for(j=100;j<201;j=j+1)for(k=150;k<251;k=k+10)bitmap[j][k]=1;
   start_frame;send_roi(0);finish_frame(0,1);
   // Unsupported source borders are legitimate; only unsupported ROI rejects.
   $sformat(path,"%0s/data/edge_000.hex",root);portable_require_file(path);
  for(portable_i=0;portable_i<384;portable_i=portable_i+1)bitmap[portable_i]='x;
  $readmemh(path,bitmap);
  for(portable_i=0;portable_i<384;portable_i=portable_i+1)if(^bitmap[portable_i]===1'bx)$fatal(1,"INPUT_DATA_UNKNOWN path=%0s index=%0d",path,portable_i);
   start_frame;active=1;support=0;x=0;y=0;tick;active=0;support=1;
   send_roi(0);finish_frame(1,1);start_frame;if(!dvalid||dc!=1)$fatal(1,"OUTSIDE_ROI_SUPPORT");
   source_valid=0;tick;if(dvalid||dc!=0)$fatal(1,"SOURCE_DISPLAY_CLEAR");source_valid=1;
   start_frame;finish_frame(0,0);
   $display("PASS_LIFECYCLE");
  end
  $finish;
 end
 initial begin #500000000;$fatal(1,"TB_WATCHDOG");end
endmodule
