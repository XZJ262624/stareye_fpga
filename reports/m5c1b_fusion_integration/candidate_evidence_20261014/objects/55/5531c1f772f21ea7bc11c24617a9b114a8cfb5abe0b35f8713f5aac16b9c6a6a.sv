`timescale 1ns/1ps
module tb_m5b1_arbiter;
 reg clk=0;always #5 clk=~clk;
 reg rst_n=0,soft_reset=0,ddr_reset_ack=0;
 reg [1:0] urgent=0;reg safe_window=1;
 reg [2:0] c_avalid=0,c_atype=0,c_wvalid=0,c_wlast=0,c_bready=0,c_rready=0;
 wire [2:0] c_aready,c_wready,c_bvalid,c_rvalid,c_rlast,rejected;
 reg [95:0] c_aaddr=0;reg [23:0] c_alen=0,c_aid=0;reg [383:0] c_wdata=0;reg [47:0] c_wstrb={48{1'b1}};
 wire [23:0] c_bid,c_rid;wire [5:0] c_bresp,c_rresp;wire [383:0] c_rdata;
 wire quarantine,reset_request,busy;wire [3:0] error_reason;
 wire [7:0] aid,alen,wid;wire [31:0] aaddr;wire [2:0] asize;wire [1:0] aburst,alock;
 wire avalid,atype,wlast,wvalid,bready,rready;wire [127:0] wdata;wire [15:0] wstrb;
 reg aready=0,wready=0,bvalid=0,rvalid=0,rlast=0;reg [7:0] bid=0,rid=0;
 reg [1:0] bresp=0,rresp=0;reg [127:0] rdata=0;
 reg emergency_stop=0;reg [63:0] epoch=1;reg [191:0] c_epoch={64'd1,64'd1,64'd1};
 reg [3:0] video_write_permission=15,video_read_permission=15;reg [6:0] bg_write_permission=127,bg_read_permission=127;
 wire [95:0] max_wait,max_service;wire [31:0] qos_exceeded,accepts,completes,rejects;wire [223:0] error_counts;
 m5b1_arbiter #(.TX_LIMIT(1024),.BG_REFILL(512),.BG_MAX_BEATS(32)) dut(.*);
 wire client_cancel=soft_reset||quarantine||reset_request;
 reg [2:0] cb_stall=0,cr_stall=0;
 reg [10:0] cb_held[0:2];reg [139:0] cr_held[0:2];
 integer seed=50708,rng,cycle=0,accepted=0,completed=0,cancelled=0,ddr_commands=0;
 integer phase[0:2],cb[0:2],waitage[0:2],maxwait[0:2],served[0:2];
 integer i,j,seq=0,ms=0,mb=0,ml=0,mo=0,stallage=0,err_count=0,reset_count=0;
 integer soft_stage=0,soft_count=0,hard_count=0,inject=0,case_id=0,malformed=0;
 integer prev_bg=-10000,bg_gaps=0,urgent_blocks=0,queue_full_cycles=0;
 reg [31:0] ma;reg [7:0] mid;reg [1:0] merr;
 reg astall=0,wstall=0,rstall=0,bstall=0;reg [52:0] aheld;reg [152:0] wheld;
 reg [138:0] rheld;reg [9:0] bheld;
 reg stop_new=0;reg directed=0;
 integer ack_overlap_cycles=0,ack_before=0,ack_done=0;
 reg hold_ack_requests=0;
 integer ack_edge_case=0;reg [3:0] ack_edge_seen=0;
 function automatic [127:0] token(input [31:0] a,input integer b,input integer own);
 begin token={a^32'hac1dface,32'hb5b00000|own,32'h76543210^b,a+b*16};end endfunction
 task automatic new_command(input integer n);
 integer length,slot;
 begin
  rng=$random(seed)&32'h7fffffff;length=n==2?(rng%32+1):(rng%128+1);
  if(seq%17==0)length=1;
  slot=(seq%(n==2?100:400))*2048;
  c_aaddr[n*32+:32]=(n==2?32'h01000000:32'h00000000)+slot;
  if(seq%17==0)c_aaddr[n*32+:32]=c_aaddr[n*32+:32]+2032;
  c_alen[n*8+:8]=length-1;c_aid[n*8+:8]=seq%256;
  c_atype[n]=n==0||(n==2&&(rng&1));phase[n]=1;cb[n]=0;waitage[n]=0;seq=seq+1;
 end endtask
 always @(negedge clk)begin
  if(rst_n)begin
   rng=$random(seed)&32'h7fffffff;stallage=stallage==3?0:stallage+1;
   // Long periods of camera / HDMI urgency and simultaneous persistent demand.
   if(!directed)begin
    urgent=cycle%5000<500?2'b11:(cycle%5000<1000?2'b01:(cycle%5000<1500?2'b10:2'b00));
    safe_window=cycle%6000>=400;
   end
   for(i=0;i<3;i=i+1)begin
    if(phase[i]==0&&!stop_new&&!quarantine&&!soft_reset)new_command(i);
    c_avalid[i]=phase[i]==1&&!soft_reset;
    if(!(c_wvalid[i]&&!c_wready[i]))c_wvalid[i]=phase[i]==2&&((rng>>(i+3))%4!=0||stallage==0);
    if(phase[i]==2)begin c_wdata[i*128+:128]=token(c_aaddr[i*32+:32],cb[i],i);c_wlast[i]=cb[i]==c_alen[i*8+:8];end
    else begin c_wvalid[i]=0;c_wlast[i]=0;end
    c_bready[i]=((rng>>(i+6))%4!=0)||stallage==0;c_rready[i]=((rng>>(i+9))%4!=0)||stallage==0;
   end
   if(inject==8)c_rready=0;
   if(inject==9)c_bready=0;
   aready=ms==0&&(rng%4!=0||stallage==0)&&inject!=1;
   wready=ms==1&&((rng>>2)%4!=0||stallage==0)&&inject!=2;
   if(ms==2&&!rvalid&&((rng>>4)%4!=0||stallage==0)&&inject!=3)begin
    rdata=token(ma,mb,mo);rid=mid^(inject==5?8'h40:8'h00);rresp=merr;
    rlast=mb==ml;if(inject==6)rlast=!rlast;rvalid=1;
   end
   if(ms==3&&!bvalid&&((rng>>6)%4!=0||stallage==0)&&inject!=4)begin
    bvalid=1;bid=mid^(inject==7?8'h40:8'h00);bresp=merr;
   end
  end
 end
 always @(posedge clk)begin
  cycle=cycle+1;
  // Independent of reset bookkeeping: never hide an ACK handshake.
  if(rst_n&&ddr_reset_ack)begin
   if(c_aready!==0)$fatal(1,"ACK accepted request");
   if(avalid&&aready)$fatal(1,"ACK DDR A handshake");
   if(wvalid&&wready)$fatal(1,"ACK DDR W handshake");
   if(bvalid&&bready)$fatal(1,"ACK DDR B handshake");
   if(rvalid&&rready)$fatal(1,"ACK DDR R handshake");
   if(c_wready!=0||c_bvalid!=0||c_rvalid!=0)$fatal(1,"ACK client data handshake exposure");
   if(ack_edge_case!=0)begin
    if(dut.state!=ack_edge_case)$fatal(1,"ACK directed state not reached");
    case(ack_edge_case)
     1:if(!aready)$fatal(1,"ACK A READY coverage");
     2:if(!wready||!c_wvalid[0])$fatal(1,"ACK W READY VALID coverage");
     3:if(!bvalid||!c_bready[0]||bid!=aid)$fatal(1,"ACK B VALID READY coverage");
     4:if(!rvalid||!c_rready[1]||rid!=aid)$fatal(1,"ACK R VALID READY coverage");
    endcase
    ack_edge_seen[ack_edge_case-1]=1;
   end
   if(c_avalid!=0)ack_overlap_cycles=ack_overlap_cycles+1;
  end
  if(!rst_n||ddr_reset_ack)begin
   ms=0;rvalid=0;bvalid=0;astall=0;wstall=0;rstall=0;bstall=0;cb_stall=0;cr_stall=0;
   for(j=0;j<3;j=j+1)begin if(phase[j]>=2)cancelled=cancelled+1;if(!hold_ack_requests||phase[j]!=1)phase[j]=0;c_wvalid[j]=0;end
  end else begin
   if(astall&&{aid,aaddr,alen,asize,atype,avalid}!==aheld)$fatal(1,"DDR A unstable");
   if(wstall&&{wid,wstrb,wlast,wvalid,wdata}!==wheld)$fatal(1,"DDR W unstable");
   if(rstall&&{rid,rresp,rlast,rdata}!==rheld)$fatal(1,"DDR R unstable");
   if(bstall&&{bid,bresp}!==bheld)$fatal(1,"DDR B unstable");
   astall=avalid&&!aready;aheld={aid,aaddr,alen,asize,atype,avalid};
   wstall=wvalid&&!wready;wheld={wid,wstrb,wlast,wvalid,wdata};
   rstall=rvalid&&!rready;rheld={rid,rresp,rlast,rdata};bstall=bvalid&&!bready;bheld={bid,bresp};
   if(busy&&c_aready!=0)$fatal(1,"owner slot overwritten");
   if(busy&&c_avalid!=0)queue_full_cycles=queue_full_cycles+1;
   if((c_aready&c_avalid)&((c_aready&c_avalid)-1))$fatal(1,"multiple accepts");
   if(urgent!=0&&c_aready[2])$fatal(1,"background entered urgent window");
   if(urgent!=0&&c_avalid[2])urgent_blocks=urgent_blocks+1;
   for(j=0;j<3;j=j+1)begin
    if(rejected[j])begin if(phase[j]<2)$fatal(1,"rejection without request");phase[j]=0;cancelled=cancelled+1;end
    if(cb_stall[j]&&!client_cancel&&{c_bvalid[j],c_bid[j*8+:8],c_bresp[j*2+:2]}!==cb_held[j])$fatal(1,"client B unstable before epoch cancel");
    if(cr_stall[j]&&!client_cancel&&{c_rvalid[j],c_rlast[j],c_rid[j*8+:8],c_rresp[j*2+:2],c_rdata[j*128+:128]}!==cr_held[j])$fatal(1,"client R unstable before epoch cancel");
    cb_stall[j]=c_bvalid[j]&&!c_bready[j]&&!client_cancel;
    cr_stall[j]=c_rvalid[j]&&!c_rready[j]&&!client_cancel;
    cb_held[j]={c_bvalid[j],c_bid[j*8+:8],c_bresp[j*2+:2]};
    cr_held[j]={c_rvalid[j],c_rlast[j],c_rid[j*8+:8],c_rresp[j*2+:2],c_rdata[j*128+:128]};
    if(c_avalid[j]&&!c_aready[j])begin waitage[j]=waitage[j]+1;if(waitage[j]>maxwait[j])maxwait[j]=waitage[j];end
    if(c_avalid[j]&&c_aready[j])begin
     if(phase[j]!=1)$fatal(1,"duplicate request");
     if(!directed&&j<2&&urgent[j]&&waitage[j]>2100)$fatal(1,"urgent wait exceeded environment bound");
     phase[j]=c_atype[j]?2:4;accepted=accepted+1;cb[j]=0;served[j]=served[j]+1;
     if(j==2)begin if(!directed&&cycle-prev_bg<512)$fatal(1,"BG credit exceeded");prev_bg=cycle;bg_gaps=bg_gaps+1;end
    end
    if(c_wvalid[j]&&c_wready[j])begin if(cb[j]==c_alen[j*8+:8])phase[j]=3;else cb[j]=cb[j]+1;end
    if(c_bvalid[j]&&c_bready[j])begin
     if(ms!=3||j!=mo||phase[j]!=3||c_bid[j*8+:8]!=c_aid[j*8+:8]||c_bresp[j*2+:2]!=merr)$fatal(1,"B misroute");
     if(merr!=0)err_count=err_count+1;phase[j]=0;completed=completed+1;
    end
    if(c_rvalid[j]&&c_rready[j])begin
     if(ms!=2||j!=mo||phase[j]!=4||c_rid[j*8+:8]!=c_aid[j*8+:8]||
        c_rdata[j*128+:128]!==token(c_aaddr[j*32+:32],cb[j],j)||c_rresp[j*2+:2]!=merr||c_rlast[j]!=(cb[j]==c_alen[j*8+:8]))$fatal(1,"R misroute or data/last mismatch");
     if(merr!=0)err_count=err_count+1;
     if(c_rlast[j])begin phase[j]=0;completed=completed+1;end else cb[j]=cb[j]+1;
    end
   end
   if(avalid&&aready)begin
    if(ms!=0||aid<1||aid>3||asize!=4||aburst!=1||alock!=0||(aaddr&4095)+(alen+1)*16>4096)$fatal(1,"A protocol");
    ma=aaddr;mid=aid;mo=aid-1;ml=alen;mb=0;
    if(aaddr!==c_aaddr[mo*32+:32]||alen!==c_alen[mo*8+:8])$fatal(1,"A misroute");
    merr=(inject==10||inject==11)?2'b10:0;ms=atype?1:2;ddr_commands=ddr_commands+1;
   end
   if(wvalid&&wready)begin
    if(ms!=1||wid!=mid||wdata!==token(ma,mb,mo)||wstrb!=16'hffff||wlast!=(mb==ml))$fatal(1,"W misroute");
    if(mb==ml)ms=3;else mb=mb+1;
   end
   if(bvalid&&bready)begin bvalid<=0;ms=0;end
   if(rvalid&&rready)begin rvalid<=0;if(mb==ml)ms=0;else mb=mb+1;end
   if(reset_request&&!directed)$fatal(1,"unexpected watchdog or framing error");
  end
 end
 task automatic hard_reset;
 begin
  @(negedge clk);ddr_reset_ack=1;soft_reset=0;inject=0;
  @(negedge clk);ddr_reset_ack=0;reset_count=reset_count+1;
 end endtask
 initial begin
  for(i=0;i<3;i=i+1)begin phase[i]=0;cb[i]=0;waitage[i]=0;maxwait[i]=0;served[i]=0;end
  if($value$plusargs("SEED=%d",seed))begin end
  repeat(5)@(negedge clk);rst_n=1;
  // 20k complete randomized transactions per seed, all three continually active.
  wait(completed>=20000);@(negedge clk);stop_new=1;
  wait(!busy);repeat(5)@(negedge clk);
  // Cancel any unaccepted requests before the directed reset epoch.
  directed=1;soft_reset=1;hard_reset();
  // Keep all three requests asserted through four ACK clocks and then recover.
  @(negedge clk);ddr_reset_ack=1;hold_ack_requests=1;
  urgent=0;safe_window=1;prev_bg=-10000;
  new_command(0);new_command(1);new_command(2);
  ack_before=accepted;ack_done=completed;
  repeat(5)@(negedge clk);
  if(accepted!=ack_before||ack_overlap_cycles<4)$fatal(1,"ACK overlap coverage");
  ddr_reset_ack=0;hold_ack_requests=0;
  wait(completed==ack_done+3);
  if(accepted!=ack_before+3||accepted!=completed+cancelled)$fatal(1,"ACK recovery accounting");
  // Pending A/W/B/R against a receptive peer at the ACK edge.
  // Offset from the negedge driver; observe before ACK clears the books.
  for(case_id=1;case_id<=4;case_id=case_id+1)begin
   @(negedge clk);#1;
   inject=case_id==1?1:(case_id==2?2:(case_id==3?9:8));
   if(case_id==4)new_command(1);else new_command(0);
   wait(dut.state==case_id);
   if(case_id==2)wait(c_wvalid[0]);
   if(case_id==3)wait(bvalid);
   if(case_id==4)wait(rvalid);
   @(negedge clk);#1;
   if(dut.state!=case_id)$fatal(1,"ACK preparation state escaped");
   aready=1;wready=1;c_bready=7;c_rready=7;
   ddr_reset_ack=1;ack_edge_case=case_id;
   @(posedge clk);#1;ack_edge_case=0;
   @(negedge clk);#1;ddr_reset_ack=0;inject=0;
   repeat(3)@(negedge clk);
   if(accepted!=completed+cancelled)$fatal(1,"ACK edge accounting");
  end
  if(ack_edge_seen!=4'b1111)$fatal(1,"ACK A W B R edge coverage");
  $display("ACK_EDGE_COVERAGE A W B R = %b",ack_edge_seen);
  // Reset in A/W/R/B, including DDR backpressure. Stalled buses remain stable.
  for(case_id=1;case_id<=11;case_id=case_id+1)begin
   inject=case_id;urgent=0;safe_window=1;
   if(case_id==3||case_id==5||case_id==6||case_id==8||case_id==11)new_command(1);else new_command(0);
   if(case_id<=4)begin
    wait((case_id==1&&avalid)||(case_id==2&&wvalid)||(case_id==3&&ms==2)||(case_id==4&&ms==3));
    @(negedge clk);soft_reset=1;soft_count=soft_count+1;
   end
   wait(reset_request);@(negedge clk);
   if(!quarantine||c_bvalid||c_rvalid||c_aready)$fatal(1,"quarantine leak");
   if((case_id<=4||case_id==8||case_id==9)&&error_reason!=1)$fatal(1,"timeout reason");
   if(case_id==5&&error_reason!=4)$fatal(1,"RID reason");
   if(case_id==6&&error_reason!=4)$fatal(1,"RLAST reason");
   if(case_id==7&&error_reason!=3)$fatal(1,"BID reason");
   repeat(5)@(negedge clk);hard_reset();
  end
  // Illegal descriptors terminate at rejected, never reach downstream A.
  for(case_id=0;case_id<12;case_id=case_id+1)begin
   @(negedge clk);#1;inject=0;prev_bg=-10000;urgent=0;safe_window=1;
   new_command(2);c_atype[2]=0;c_aaddr[95:64]=32'h01000000;c_alen[23:16]=0;
   case(case_id)
    0:c_aaddr[95:64]=32'h01000ff0; // 4KiB overrun
    1:c_aaddr[95:64]=32'h01038400; // class padding
    2:c_aaddr[95:64]=32'h010e7000; // forbidden upper region
    3:c_aaddr[95:64]=32'hfffffff0; // 33-bit wrap
    4:c_aaddr[95:64]=32'h01000001; // alignment
    5:c_epoch[191:128]=0;
    6:bg_read_permission=0;
    7:c_alen[23:16]=32;
    8:c_aaddr[95:64]=32'h010383f0; // class end overrun
    9:c_aaddr[95:64]=32'h010e6ff0; // metadata end
    10:c_aaddr[95:64]=32'h00000000; // C2 must not enter video
    11:begin c_atype[2]=1;bg_write_permission=0;end
   endcase
   if(case_id==0||case_id==3||case_id==8||case_id==9)c_alen[23:16]=1;
   ack_before=ddr_commands;
   fork begin wait(rejected[2]);end
    begin repeat(2048)@(posedge clk);$fatal(1,"illegal request rejection missing case=%0d",case_id);end
   join_any
   disable fork;
   repeat(3)@(negedge clk);
   if(ddr_commands!=ack_before||phase[2]!=0)$fatal(1,"invalid descriptor escaped/unterminated case=%0d",case_id);
   c_epoch[191:128]=1;bg_read_permission=127;bg_write_permission=127;
  end
  // Resume all clients after trusted controller/client reset acknowledgement.
  prev_bg=-10000;stop_new=0;directed=0;wait(completed>=20500);@(negedge clk);stop_new=1;
  wait(!busy);repeat(10)@(negedge clk);soft_reset=1;hard_reset();
  if(accepted!=completed+cancelled)$fatal(1,"lost/duplicate transaction accepted=%d completed=%d cancelled=%d",accepted,completed,cancelled);
  if(rejects!=12||error_counts[191:160]!=1||error_counts[159:128]!=11||error_counts[31:0]==0||error_counts[63:32]==0)$fatal(1,"error telemetry missing %h",error_counts);
  if(served[0]<1000||served[1]<1000||served[2]<100||err_count==0||queue_full_cycles==0||urgent_blocks==0)$fatal(1,"coverage shortfall");
  $display("M5B1_ARBITER_PASS cycles=%0d accepted=%0d completed=%0d cancelled=%0d DDR_commands=%0d services=%0d,%0d,%0d maxwait=%0d,%0d,%0d errors=%0d resets=%0d ACK_overlap_cycles=%0d queue_full_cycles=%0d urgent_blocks=%0d",cycle,accepted,completed,cancelled,ddr_commands,served[0],served[1],served[2],maxwait[0],maxwait[1],maxwait[2],err_count,reset_count,ack_overlap_cycles,queue_full_cycles,urgent_blocks);$finish;
 end
 initial begin repeat(20000000)@(posedge clk);$fatal(1,"arbiter test watchdog");end
endmodule
