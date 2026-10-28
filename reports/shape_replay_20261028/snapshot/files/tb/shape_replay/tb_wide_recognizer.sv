`timescale 1ns/1ps
module tb_wide_recognizer;
 parameter CASES=41;
 reg clk=0;always #5 clk=~clk;
 reg rst=0,ce=1,sof=0,eof=0,active=0,support=1,edge_pixel=0,source_valid=1;
 reg[11:0] x=0,y=0;reg[63:0] fid=0,cfg=7,ep=3,seq=100;
 wire done,valid,dv,busy;wire[1:0] category,dc;wire[63:0] rid,rcfg,rep,rseq,did,dcfg,dep,dseq;
 shape_recognizer_epoch dut(.clk(clk),.rst_n(rst),.ce(ce),.sof(sof),.eof(eof),.active(active),.support(support),.edge_pixel(edge_pixel),.source_valid(source_valid),.x(x),.y(y),.frame_id(fid),.config_generation(cfg),.epoch(ep),.source_display_seq(seq),.result_done(done),.result_valid(valid),.result_class(category),.result_frame_id(rid),.result_config_generation(rcfg),.result_epoch(rep),.result_source_display_seq(rseq),.display_class(dc),.display_valid(dv),.display_frame_id(did),.display_config_generation(dcfg),.display_epoch(dep),.display_source_display_seq(dseq),.busy(busy));
 reg[959:0] bitmap[0:539];reg[1:0] expected[0:CASES-1];reg ev[0:CASES-1],last_check[0:CASES-1];reg[7:0] faults[0:CASES-1],caps[0:CASES-1];
 reg[4095:0] root,path;integer f,j,k,n,max_cycles=0;reg[511:0] held;reg[63:0] started_fid;
 reg previous_valid=0;reg[1:0] previous_class=0;reg[63:0] previous_id=0,previous_cfg=0,previous_ep=0,previous_seq=0;
 task tick;begin @(posedge clk);#1;@(negedge clk);end endtask
 task start_frame;begin
  fid=fid+1;seq=seq+1;started_fid=fid;sof=1;active=0;eof=0;tick;sof=0;
  if(previous_valid && previous_cfg==cfg && previous_ep==ep && source_valid)begin
   if(!dv||dc!==previous_class||did!==previous_id||dcfg!==cfg||dep!==ep||dseq!==previous_seq)$fatal(1,"PREV_IDENTITY");
  end else if(dv||dc)$fatal(1,"PREV_STALE");previous_valid=0;
 end endtask
 task send_roi(input integer fault);begin
  // Outside ROI samples must not affect the exact pixel counter or support gate.
  active=1;x=159;y=90;support=0;edge_pixel=1;tick;
  x=1120;y=629;tick;x=160;y=89;tick;x=1119;y=630;tick;
  for(j=0;j<540;j=j+1)for(k=0;k<960;k=k+1)begin
   active=1;x=k+160;y=j+90;support=1;edge_pixel=bitmap[j][k];
   if(fault==1 && j==539 && k==959)active=0;
   if(fault==11 && j==539 && k==959)x=1118;
   if(j==270&&k==480)begin
    if(fault==3)support=0;if(fault==4)cfg=8;if(fault==5)source_valid=0;if(fault==6)fid=fid+1;
    if(fault==7)begin ce=0;held={dut.state,dut.pixels,dut.ex,dut.ey,dut.left_x,dut.right_x,dut.seen,dut.edge_count};repeat(5)tick;if(held!=={dut.state,dut.pixels,dut.ex,dut.ey,dut.left_x,dut.right_x,dut.seen,dut.edge_count})$fatal(1,"CAPTURE_CE_HOLD");ce=1;end
   end
   tick;
  end
  if(fault==2)tick;
  active=0;edge_pixel=0;support=1;
  if(fault!=1 && fault!=2 && dut.pixels!==19'd518400)$fatal(1,"ROI_EXACT_COUNT %0d",dut.pixels);
 end endtask
 task finish_frame(input integer ec,input integer evalid,input integer fault);begin
  eof=1;active=fault==8;tick;eof=0;active=0;
  ce=0;held={dut.state,dut.scan,dut.budget,dut.row_q};repeat(3)tick;
  if(held!=={dut.state,dut.scan,dut.budget,dut.row_q})$fatal(1,"ANALYSIS_CE_HOLD");ce=1;
  n=0;while(!done&&n<32772)begin tick;n=n+1;end
  if(!done||n>2300)$fatal(1,"ANALYSIS_BUDGET cycles=%0d",n);if(n>max_cycles)max_cycles=n;
  if(category!==ec||valid!==evalid)$fatal(1,"CLASS case=%0d got=%0d/%0d expected=%0d/%0d",f,category,valid,ec,evalid);
  if(rid!==started_fid||rcfg!==7||rep!==3||rseq!==seq)$fatal(1,"RESULT_IDENTITY");
  previous_valid=valid;previous_class=category;previous_id=rid;previous_cfg=rcfg;previous_ep=rep;previous_seq=rseq;
  $display("WIDE_RESULT case=%0d class=%0d valid=%0d cycles=%0d pixels=%0d",f,category,valid,n,dut.pixels);tick;
 end endtask
 initial begin
  if(!$value$plusargs("ROOT=%s",root))$fatal(1,"ROOT_REQUIRED");
  $sformat(path,"%0s/expected.hex",root);$readmemh(path,expected);$sformat(path,"%0s/valid.hex",root);$readmemh(path,ev);$sformat(path,"%0s/fault.hex",root);$readmemh(path,faults);$sformat(path,"%0s/cap.hex",root);$readmemh(path,caps);$sformat(path,"%0s/last.hex",root);$readmemh(path,last_check);
  repeat(4)tick;rst=1;repeat(2)tick;
  for(f=0;f<CASES;f=f+1)begin
   cfg=7;ep=3;source_valid=1;$sformat(path,"%0s/edge_%03d.hex",root,f);$readmemh(path,bitmap);
   for(j=0;j<540;j=j+1)if(^bitmap[j]===1'bx)$fatal(1,"UNKNOWN_INPUT_ROW");
   start_frame;send_roi(faults[f]);
   if(last_check[f] && (dut.rows[539][25]!==1||dut.rows[539][19:10]!==959||dut.rows[539][9:0]!==959))$fatal(1,"LAST_PIXEL_ROW_26BIT");
   finish_frame(expected[f],ev[f],faults[f]);
   if(caps[f]!=255 && dut.cap_fragment_rows!==caps[f][3:0])$fatal(1,"CAP_COUNT case=%0d got=%0d expected=%0d",f,dut.cap_fragment_rows,caps[f]);
  end
  // Immediate config/source display invalidation; reset/new-SOF recovery.
  cfg=7;source_valid=1;start_frame;if(!dv||dc!=1)$fatal(1,"RECOVERY_PREV");
  cfg=8;tick;if(dv||dc)$fatal(1,"CONFIG_CLEAR");cfg=7;
  start_frame;if(!done||valid||category)$fatal(1,"SOF_PREEMPTS_CAPTURE");
  rst=0;tick;rst=1;tick;if(dv||dc||busy)$fatal(1,"RESET_CLEAR");previous_valid=0;
  f=CASES;start_frame;send_roi(0);eof=1;tick;eof=0;n=0;
  while(dut.state!=6 && n<2300)begin tick;n=n+1;end
  if(dut.state!=6)$fatal(1,"NO_FINISH");start_frame;
  if(!done||valid||category||dv)$fatal(1,"SOF_FINISH_PRIORITY");
  send_roi(0);finish_frame(1,1,0);start_frame;source_valid=0;tick;if(dv||dc)$fatal(1,"SOURCE_CLEAR");
  $display("PASS_WIDE_RECOGNIZER cases=%0d max_analysis=%0d",CASES,max_cycles);$finish;
 end
 initial begin #400000000;$fatal(1,"TB_WATCHDOG");end
endmodule
