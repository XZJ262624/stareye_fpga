`timescale 1ns/1ps
// Independent single-outstanding physical DDR model. Real valid/ready events
// alone modify memory or complete transactions; no DUT completion sidebands.
module selected_fault_ddr_model_v9 #(
 parameter WORDS=1107712,SEED=50708,SERVICE_BOUND=384
)(input clk,rst_n,stall,
 input [7:0] aid,alen,wid,input [31:0] aaddr,input [2:0] asize,
 input [1:0] aburst,alock,input avalid,atype,output reg aready,
 input [127:0] wdata,input [15:0] wstrb,input wlast,wvalid,output reg wready,
 output reg [7:0] bid,output reg [1:0] bresp,output reg bvalid,input bready,
 output reg [7:0] rid,output reg [1:0] rresp,output reg [127:0] rdata,
 output reg rlast,rvalid,input rready,
 input [31:0] service_delay,input inject_b_error,inject_r_error,
 output reg [31:0] accepted,completed,max_service);
 reg [127:0] mem[0:WORDS-1];
 integer state,beat,len,base,age,seed,rng;reg [7:0] transaction_id;
 reg [31:0] transaction_limit=SERVICE_BOUND;integer max_by_id[1:3];integer id_init;
 initial for(id_init=1;id_init<=3;id_init=id_init+1)max_by_id[id_init]=0;
 reg held_valid;reg [49:0] held_a;
 initial begin state=0;beat=0;len=0;base=0;age=0;seed=SEED;
  aready=0;wready=0;bvalid=0;rvalid=0;rlast=0;bid=0;rid=0;bresp=0;rresp=0;rdata=0;
  accepted=0;completed=0;max_service=0;held_valid=0;held_a=0;
 end
 always @(negedge clk)begin
  rng=$random(seed)&32'h7fffffff;
  aready=rst_n&&!stall&&state==0&&rng%4!=0;
  wready=rst_n&&!stall&&state==1&&rng%4!=0;
  // Delay toward the selected wall-service bound, then reserve one clock per
  // remaining R beat. Near the deadline randomness cannot extend the bound.
  if(rst_n&&!stall&&state==2&&!rvalid&&
     (rng%4!=0||(transaction_limit!=0&&age+len-beat+2>=transaction_limit))&&
     (transaction_limit==0||age+2*(len-beat+1)+16>=transaction_limit))begin
   rid=transaction_id;rresp=inject_r_error?2:0;rdata=mem[base+beat];
   rlast=beat==len;rvalid=1;
  end
  if(rst_n&&!stall&&state==3&&!bvalid&&
     (rng%4!=0||(transaction_limit!=0&&age+1>=transaction_limit))&&
     (transaction_limit==0||age+1>=transaction_limit))begin
   bid=transaction_id;bresp=inject_b_error?2:0;bvalid=1;
  end
 end
 task finish_transaction;
 begin
  if(age>max_service)max_service=age;
  if(age>max_by_id[transaction_id])max_by_id[transaction_id]=age;
  if(!stall&&age>(transaction_limit==0?SERVICE_BOUND:transaction_limit))$fatal(1,"DDR_SERVICE_BOUND age=%0d bound=%0d",age,transaction_limit==0?SERVICE_BOUND:transaction_limit);
  state=0;completed=completed+1;
 end endtask
 always @(posedge clk)if(rst_n)begin
  if(state!=0)age=age+1;
  if(held_valid&&{aaddr,aid,alen,atype,avalid}!==held_a)$fatal(1,"DDR_UNSTABLE_A");
  held_valid=avalid&&!aready;held_a={aaddr,aid,alen,atype,avalid};
  if(avalid&&aready)begin
   if(state!=0||asize!=4||aburst!=1||alock!=0||aaddr[3:0]!=0||
      (aaddr[11:0]+(alen+1)*16)>4096||(aaddr>>4)+alen>=WORDS)
    $fatal(1,"DDR_BAD_COMMAND addr=%h len=%0d",aaddr,alen);
   state=atype?1:2;beat=0;len=alen;base=aaddr>>4;age=0;
   if(aid<1||aid>3)$fatal(1,"DDR_UNKNOWN_CLIENT_ID");
   transaction_id=aid;transaction_limit=aid==3?service_delay:SERVICE_BOUND;accepted=accepted+1;
  end
  if(wvalid&&wready)begin
   if(state!=1||wid!=transaction_id||wlast!=(beat==len)||wstrb!=16'hffff)$fatal(1,"DDR_BAD_W");
   mem[base+beat]=wdata;if(beat==len)state=3;else beat=beat+1;
  end
  if(bvalid&&bready)begin
   if(state!=3)$fatal(1,"DDR_UNSOLICITED_B");
   bvalid<=0;finish_transaction();
  end
  if(rvalid&&rready)begin
   if(state!=2)$fatal(1,"DDR_UNSOLICITED_R");
   rvalid<=0;if(beat==len)finish_transaction();else beat=beat+1;
  end
  if(accepted!=completed+(state!=0))$fatal(1,"DDR_CONSERVATION");
 end
endmodule
