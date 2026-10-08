`timescale 1ns/1ps
module tb_m5b0r_diagnostic;
 reg clk=0;always #5 clk=~clk;
 reg rst_n=0,cal_done=0,cal_pass=0;
 wire [3:0] status,reason;wire alias_pass,range_pass,controller_reset_request;
 wire [31:0] failure_address,transaction_count,beat_count;wire [127:0] expected,actual;
 wire [7:0] failure_stage,aid,alen,wid,bid,rid;
 wire [31:0] aaddr;wire [2:0] asize;wire [1:0] aburst,alock,bresp,rresp;
 wire avalid,atype,wlast,wvalid,bready,rready;reg aready=0,wready=0,bvalid=0,rvalid=0,rlast=0;
 wire [127:0] wdata;reg [127:0] rdata=0;wire [15:0] wstrb;
 reg [7:0] response_id=0;reg [1:0] response_code=0;
 assign bid=response_id;assign rid=response_id;assign bresp=response_code;assign rresp=response_code;
 m5b0r_diagnostic #(.CAL_TIMEOUT(1000),.TOTAL_TIMEOUT(8000000),.TX_TIMEOUT(2048)) dut(.*);
 reg [127:0] memory[int unsigned];
 integer fault=0,ignored_bit=24,seed=50708,rng,cycles=0,commands=0,wbeats=0,rbeats=0;
 integer state=0,index=0,beats=0,waits=0,stalls=0,expect_reason=0,expect_status=0;
 reg [31:0] base;reg [7:0] owner;reg [127:0] oldw,oldr;reg [49:0] olda;
 reg astall=0,wstall=0,rstall=0;
 function automatic [31:0] mapped(input [31:0] a,input bit reading);
 reg [31:0] x;
 begin
  x=a;
  case(fault)
   1:x=a&32'h00ffffff;
   2:x=a&~(32'b1<<ignored_bit);
   3:x=(a<<1)&32'h1fffffff;
   4:x=(a<<4)&32'h1fffffff;
   5:x=(a>>1)&32'h1ffffff0;
   6:x=a%32'h01000000;
   11:if(reading)x=a+16;
   13:if(reading)x=(a<<1)&32'h1fffffff;
   14:if(!reading)x=(a<<1)&32'h1fffffff;
   15:if(index==beats-1&&beats>1)x=base; // erroneous burst wrap
  endcase
  mapped=x>>4;
 end endfunction
 always @(negedge clk) begin
  rng=$random(seed)&32'h7fffffff;
  aready=rst_n&&state==0&&(rng%4!=0)&&fault!=16;
  wready=rst_n&&state==1&&(rng%4!=0)&&fault!=17;
  if(rst_n&&state==2&&!rvalid&&(rng%4!=0)&&fault!=18) begin
   rdata=memory.exists(mapped(base+index*16,1))?memory[mapped(base+index*16,1)]:128'b0;
   if(fault==10)rdata={rdata[119:0],rdata[127:120]};
   rlast=index==beats-1;
   if(fault==12)rlast=!rlast;
   if(fault==24&&beats>1&&index==0)rlast=1;
   response_id=owner^(fault==9?8'h01:8'h00);response_code=fault==8?2'b10:0;
   rvalid=1;
  end
  if(rst_n&&state==3&&!bvalid&&(rng%4!=0)&&fault!=19) begin
   bvalid=1;response_id=owner^(fault==20?8'h01:8'h00);response_code=fault==7?2'b10:0;
  end
  if(fault==23&&state==1&&wvalid&&wready&&wlast)begin
   bvalid=1;response_id=owner;response_code=0;
  end
 end
 always @(posedge clk) begin
  cycles=cycles+1;
  if(!rst_n||controller_reset_request)begin state=0;aready=0;wready=0;rvalid=0;bvalid=0;astall=0;wstall=0;rstall=0;end
  else begin
   if(astall&&{aid,aaddr,alen,atype,avalid}!==olda)$fatal(1,"A changed under stall");
   if(wstall&&(wdata!==oldw||!wvalid))$fatal(1,"W changed under stall");
   if(rstall&&(rdata!==oldr||!rvalid))$fatal(1,"R changed under stall");
   astall=avalid&&!aready;olda={aid,aaddr,alen,atype,avalid};
   wstall=wvalid&&!wready;oldw=wdata;rstall=rvalid&&!rready;oldr=rdata;
   if(avalid&&aready)begin
    if(asize!=4||aburst!=1||alock!=0||aaddr[3:0]!=0||alen>127||
       aaddr>=32'h20000000||(aaddr&4095)+(alen+1)*16>4096)$fatal(1,"illegal command");
    if(state!=0)$fatal(1,"multiple outstanding");
    base=aaddr;owner=aid;beats=alen+1;index=0;state=atype?1:2;commands=commands+1;
   end
   if(wvalid&&wready)begin
    if(state!=1||wid!=owner||wstrb!=16'hffff||wlast!=(index==beats-1))$fatal(1,"write protocol");
    memory[mapped(base+index*16,0)]=wdata;wbeats=wbeats+1;
    if(index==beats-1)state=3;else index=index+1;
   end
   if(bvalid&&bready)begin bvalid=0;state=0;end
   if(rvalid&&rready)begin
    rvalid<=0;rbeats=rbeats+1;
    if(index==beats-1)state=0;else index=index+1;
   end
   if(!aready||!wready)stalls=stalls+1;
  end
 end
 initial begin
  if($value$plusargs("FAULT=%d",fault))begin end
  if($value$plusargs("BIT=%d",ignored_bit))begin end
  if($value$plusargs("SEED=%d",seed))begin end
  repeat(5)@(negedge clk);rst_n=1;
  repeat(10)@(negedge clk);
  if(fault!=21)begin cal_done=1;cal_pass=fault!=22;end
  wait(status==6||status==7||status==8||status==3);
  @(negedge clk);
  if(fault==0||fault==23||fault==26)begin
   if(status!=6||!alias_pass||!range_pass||commands!=transaction_count||wbeats+rbeats!=beat_count)
    $fatal(1,"healthy diagnostic failed status=%d reason=%d addr=%h stage=%d commands=%d tx=%d beats=%d/%d",status,reason,failure_address,failure_stage,commands,transaction_count,wbeats+rbeats,beat_count);
   // A successful test is invalidated by a subsequent loss of calibration.
   cal_pass=0;repeat(3)@(negedge clk);if(status!=3||range_pass||alias_pass)$fatal(1,"stale PASS");
  end else begin
   expect_status=7;expect_reason=7;
   if(fault==7||fault==20)expect_reason=4;
   if(fault==8||fault==9)expect_reason=5;
   if(fault==12||fault==24)expect_reason=6;
   if(fault>=16&&fault<=19)begin expect_status=8;expect_reason=3;end
   if(fault==21)begin expect_status=8;expect_reason=0;end
   if(fault==22)begin expect_status=3;expect_reason=0;end
   if(fault==25)begin expect_status=3;expect_reason=2;end
   if(fault==27)begin expect_status=8;expect_reason=2;end
   if(fault==21&&failure_stage!=8'hf2)$fatal(1,"CAL timeout stage");
   if(fault==22&&failure_stage!=8'hf1)$fatal(1,"CAL fail stage");
   if(fault==25&&failure_stage!=8'h40)$fatal(1,"CAL lost stage");
   if(fault==27&&failure_stage!=8'h80)$fatal(1,"TOTAL timeout stage");
   if(fault==27)begin repeat(3)@(negedge clk);
    if(status!=8||failure_stage!=8'h80||reason!=2||failure_address!=32'h80)$fatal(1,"TOTAL first error");end
   if(status!=expect_status||reason!=expect_reason)
    $fatal(1,"wrong detection fault=%d status=%d reason=%d expected=%d/%d",fault,status,reason,expect_status,expect_reason);
   if(expect_reason==7&&actual===expected)$fatal(1,"missing first mismatch data");
   if(reason!=0&&failure_address[3:0]!=0)$fatal(1,"misaligned failure address");
   if(reason==4&&failure_address!=0)$fatal(1,"first write response address");
   if(fault==16&&failure_address!=0)$fatal(1,"first A timeout address");
  end
  $display("M5B0R_DIAGNOSTIC_PASS fault=%0d bit=%0d cycles=%0d commands=%0d write_beats=%0d read_beats=%0d status=%0d reason=%0d first=%h stage=%0d",fault,ignored_bit,cycles,commands,wbeats,rbeats,status,reason,failure_address,failure_stage);
  $finish;
 end
 initial begin
  wait(fault==25||fault==26);
  wait(commands==5&&wvalid);
  @(negedge clk);
  if(fault==25)cal_pass=0;
  else begin
   rst_n=0;cal_done=0;cal_pass=0;commands=0;wbeats=0;rbeats=0;
   repeat(5)@(negedge clk);rst_n=1;
   repeat(10)@(negedge clk);cal_done=1;cal_pass=1;
  end
 end
 initial begin
  wait(fault==27);wait(commands==5&&wvalid);@(negedge clk);
  force dut.ticks=32'd7999999;repeat(2)@(negedge clk);release dut.ticks;
 end
 initial begin repeat(8500000)@(posedge clk);$fatal(1,"testbench watchdog");end
endmodule
