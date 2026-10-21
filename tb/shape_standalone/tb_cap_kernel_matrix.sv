`timescale 1ns/1ps
module tb_cap_kernel_matrix;
 reg clk=0;always #5 clk=~clk;
 reg rst_n=0,ce=1,sof=0,eof=0,active=0,support=1,edge_pixel=0,source_valid=1;
 reg [11:0] x=0,y=0;reg [63:0] fid=0,cfg=7;
 wire done,valid,dvalid,busy;wire[1:0] category,dc;wire[63:0] rid,rcfg,rep,rseq,did,dcfg,dep,dseq;
 shape_recognizer_epoch dut(.clk(clk),.rst_n(rst_n),.ce(ce),.sof(sof),.eof(eof),.active(active),.support(support),.edge_pixel(edge_pixel),.source_valid(source_valid),.x(x),.y(y),.frame_id(fid),.config_generation(cfg),.epoch(64'd77),.source_display_seq(fid+64'd99),.result_done(done),.result_valid(valid),.result_class(category),.result_frame_id(rid),.result_config_generation(rcfg),.result_epoch(rep),.result_source_display_seq(rseq),.display_class(dc),.display_valid(dvalid),.display_frame_id(did),.display_config_generation(dcfg),.display_epoch(dep),.display_source_display_seq(dseq),.busy(busy));
 reg[511:0] bitmap[0:383];reg[1:0] expected[0:355];reg expected_valid[0:355];reg[2:0] cap_count[0:355];reg circle_bad[0:355];
 reg[4095:0] root,path;reg[1023:0] fatal_tag="CAP_NATIVE_RESULT";reg[1023:0] held;
 integer first=0,count=356,c,i,j,n,completed=0,ce_checks=0,display_checks=0;reg[2:0] paused;reg previous_valid=0;reg[1:0] previous_class=0;reg[63:0] previous_fid=0;
 function[23:0] dec3(input integer a);reg[7:0] d0,d1,d2;begin d0=48+(a/100)%10;d1=48+(a/10)%10;d2=48+a%10;dec3={d0,d1,d2};end endfunction
 task require_file(input[4095:0] name);integer f;begin f=$fopen(name,"r");if(!f)$fatal(1,"CAP_INPUT_UNREADABLE %0s",name);$fclose(f);end endtask
 task tick;begin @(posedge clk);#1;@(negedge clk);end endtask
 task hold_ce;begin
  ce=0;held={dut.state,dut.cap_fragment_rows,dut.circle_segments_bad,dut.contour_bad,dut.scan,dut.bin,dut.remainder,dut.budget,dut.row_q,dut.pixels,dut.ex,dut.ey,dut.left_x,dut.right_x,dut.edge_count,dut.segments,dut.pending,done,valid,category,dc,dvalid,rid,rcfg,rep,rseq,did,dcfg,dep,dseq};
  repeat(7)begin tick;if(held!=={dut.state,dut.cap_fragment_rows,dut.circle_segments_bad,dut.contour_bad,dut.scan,dut.bin,dut.remainder,dut.budget,dut.row_q,dut.pixels,dut.ex,dut.ey,dut.left_x,dut.right_x,dut.edge_count,dut.segments,dut.pending,done,valid,category,dc,dvalid,rid,rcfg,rep,rseq,did,dcfg,dep,dseq})$fatal(1,"CAP_CE_STATE_CHANGED");end
  ce=1;ce_checks=ce_checks+1;
 end endtask
 task load_case(input integer index);begin path={root,"/data/edge_",dec3(index),".hex"};require_file(path);$readmemh(path,bitmap);end endtask
 task start_frame;begin
  fid=fid+1;sof=1;active=0;eof=0;tick;sof=0;
  if(dut.cap_fragment_rows!==0)$fatal(1,"CAP_SOF_COUNTER_LEAK");
  if(dvalid!==previous_valid || (previous_valid && (dc!==previous_class || did!==previous_fid || dcfg!==7 || dep!==77 || dseq!==previous_fid+99)))$fatal(1,"CAP_PREVIOUS_DISPLAY");
  display_checks=display_checks+1;
 end endtask
 task send_roi;begin
  for(j=0;j<384;j=j+1)for(i=0;i<512;i=i+1)begin active=1;x=384+i;y=168+j;edge_pixel=bitmap[j][i];if(j==190&&i==250)hold_ce;tick;end
  active=0;edge_pixel=0;
 end endtask
 task finish(input integer index);begin
  eof=1;tick;eof=0;n=0;paused=0;
  while(!done&&n<4096)begin
   if(dut.state==3&&!paused[0])begin paused[0]=1;hold_ce;end
   if(dut.state==5&&!paused[1])begin paused[1]=1;hold_ce;end
   if(dut.state==6&&!paused[2])begin paused[2]=1;hold_ce;end
   tick;n=n+1;
  end
  if(!done)$fatal(1,"CAP_ANALYSIS_DEADLINE");
  if(category!==expected[index]||valid!==expected_valid[index])$fatal(1,"%0s index=%0d actual=%0d/%0d expected=%0d/%0d",fatal_tag,index,category,valid,expected[index],expected_valid[index]);
  if(rid!==fid||rcfg!==7||rep!==77||rseq!==fid+99)$fatal(1,"CAP_RESULT_IDENTITY");
  if(index>=332 && (dut.cap_fragment_rows!==cap_count[index] || dut.circle_segments_bad!==circle_bad[index]))$fatal(1,"CAP_TARGET_FEATURE_NOT_ACTIVATED index=%0d count=%0d/%0d bad=%0d/%0d",index,dut.cap_fragment_rows,cap_count[index],dut.circle_segments_bad,circle_bad[index]);
  previous_valid=expected_valid[index];previous_class=expected[index];previous_fid=fid;completed=completed+1;
  $display("CAP_RESULT index=%0d class=%0d valid=%0d count=%0d bad=%0d analysis=%0d",index,category,valid,dut.cap_fragment_rows,dut.circle_segments_bad,n);tick;
 end endtask
 initial begin
  if(!$value$plusargs("ROOT=%s",root))$fatal(1,"CAP_ROOT_REQUIRED");
  if($value$plusargs("FIRST=%d",first))begin end
  if($value$plusargs("COUNT=%d",count))begin end
  if($value$plusargs("FATAL_TAG=%s",fatal_tag))begin end
  if(first<0||count<1||first+count>356)$fatal(1,"CAP_CASE_RANGE");
  path={root,"/data/expected.hex"};require_file(path);$readmemh(path,expected);
  path={root,"/data/expected_valid.hex"};require_file(path);$readmemh(path,expected_valid);
  path={root,"/data/cap_count.hex"};require_file(path);$readmemh(path,cap_count);
  path={root,"/data/circle_bad.hex"};require_file(path);$readmemh(path,circle_bad);
  repeat(4)tick;rst_n=1;repeat(4)tick;
  for(c=first;c<first+count;c=c+1)begin load_case(c);start_frame;send_roi;finish(c);end
  if(count==356)begin
   // Interrupt a real analysis after the new saturating counter reaches7.
   load_case(353);start_frame;send_roi;eof=1;tick;eof=0;n=0;
   while(dut.cap_fragment_rows!==7&&!done&&n<4096)begin tick;n=n+1;end
   if(dut.cap_fragment_rows!==7||done)$fatal(1,"CAP_INTERRUPT_PRECONDITION");hold_ce;
   fid=fid+1;sof=1;active=0;tick;sof=0;
   if(!done||valid||dut.cap_fragment_rows!==0||dut.state!==1)$fatal(1,"CAP_SOF_INTERRUPT_RETAINED_COUNTER");
   previous_valid=0;load_case(0);send_roi;finish(0);
   // Reset while CE is stopped; asynchronously clear the added state too.
   load_case(353);start_frame;send_roi;eof=1;tick;eof=0;n=0;
   while(dut.cap_fragment_rows!==7&&!done&&n<4096)begin tick;n=n+1;end
   if(dut.cap_fragment_rows!==7)$fatal(1,"CAP_RESET_PRECONDITION");ce=0;rst_n=0;#1;
   if(dut.cap_fragment_rows!==0||dut.state!==0||valid||dvalid)$fatal(1,"CAP_ASYNC_RESET_COUNTER_LEAK");
   tick;rst_n=1;ce=1;previous_valid=0;repeat(2)tick;load_case(0);start_frame;send_roi;finish(0);
   $display("PASS_CAP_ACTUAL_CE_SOF_EOF_COUNTER_LIFECYCLE completed=%0d CEchecks=%0d displays=%0d",completed,ce_checks,display_checks);
  end
  $display("PASS_CAP_NATIVE_KERNEL_MATRIX first=%0d count=%0d completed=%0d",first,count,completed);$finish;
 end
 initial begin #2000000000;$fatal(1,"CAP_KERNEL_SIM_TIMEOUT");end
endmodule
