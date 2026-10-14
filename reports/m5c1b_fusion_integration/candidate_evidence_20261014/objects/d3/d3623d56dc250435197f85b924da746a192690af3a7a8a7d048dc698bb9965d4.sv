`timescale 1ns/1ps
// Independent single-outstanding physical DDR model. Real valid/ready events
// alone modify memory or complete transactions; no DUT completion sidebands.
module selected_nonzero_ddr_model #(
 parameter WORDS=1107712,SEED=50708,SERVICE_BOUND=384
)(input clk,rst_n,stall,
 input authorize_class_fault,input [63:0] fault_sid,input [767:0] fault_identity,
 output reg [31:0] injection_count,output reg [63:0] injected_sid,output reg [767:0] injected_identity,
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
 reg inject_transaction;reg changed_beat;reg [127:0] unchanged_word;
 reg held_valid;reg [49:0] held_a;
 initial begin injection_count=0;injected_sid=0;injected_identity=0;inject_transaction=0;changed_beat=0;unchanged_word=0;state=0;beat=0;len=0;base=0;age=0;seed=SEED;
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
     (rng%4!=0||(service_delay!=0&&age+len-beat+2>=service_delay))&&
     (service_delay==0||age+2*(len-beat+1)+16>=service_delay))begin
   rid=transaction_id;rresp=inject_r_error?2:0;rdata=mem[base+beat];
   if(inject_transaction&&beat==2)begin
    if(rdata[71:70]!==2'd1||injection_count!=0)$fatal(1,"REAL_CLASS_MISMATCH_BAD_QUALIFIER");
    unchanged_word=rdata;rdata[71:70]=2'd0;changed_beat=1;
    $display("NZ_REAL_R_CREATED sid=%0d address=%h beat=%0d id=%0d old=%032h new=%032h",injected_sid,(base+beat)*16,beat,transaction_id,unchanged_word,rdata);
   end
   rlast=beat==len;rvalid=1;
  end
  if(rst_n&&!stall&&state==3&&!bvalid&&
     (rng%4!=0||(service_delay!=0&&age+1>=service_delay))&&
     (service_delay==0||age+1>=service_delay))begin
   bid=transaction_id;bresp=inject_b_error?2:0;bvalid=1;
  end
 end
 task finish_transaction;
 begin
  if(age>max_service)max_service=age;
  if(!stall&&age>(service_delay==0?SERVICE_BOUND:service_delay))$fatal(1,"DDR_SERVICE_BOUND age=%0d bound=%0d",age,service_delay==0?SERVICE_BOUND:service_delay);
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
   transaction_id=aid;accepted=accepted+1;
   inject_transaction=authorize_class_fault&&injection_count==0;
   if(inject_transaction)begin
    if(atype||alen!=19||fault_sid==0)$fatal(1,"REAL_CLASS_MISMATCH_BAD_A");
    injected_sid=fault_sid;injected_identity=fault_identity;
    $display("NZ_REAL_A sid=%0d addr=%h id=%0d len=%0d identity=%0192h",fault_sid,aaddr,aid,alen,fault_identity);
   end
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
   if(inject_transaction&&beat==2)begin
    if(!changed_beat||injection_count!=0||rdata[71:70]!==0||(rdata^(128'd1<<70))!==unchanged_word)$fatal(1,"REAL_CLASS_MISMATCH_BAD_HANDSHAKE");
    injection_count=injection_count+1;
    $display("NZ_REAL_R_ACCEPT sid=%0d beat=%0d rresp=%0d rlast=%b old=%032h new=%032h",injected_sid,beat,rresp,rlast,unchanged_word,rdata);
   end
   if(state!=2)$fatal(1,"DDR_UNSOLICITED_R");
   rvalid<=0;if(beat==len)finish_transaction();else beat=beat+1;
  end
  if(accepted!=completed+(state!=0))$fatal(1,"DDR_CONSERVATION");
 end
endmodule
