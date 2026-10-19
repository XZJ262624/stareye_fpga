// M5B1 common-clock-independent FIFO. Capacity is 2**AW * WIDTH bits.
// Both domains share asynchronous reset assertion; each releases locally.
// RAM read is synchronous and prefetches the next head on a successful pop.
module m5b1_async_fifo #(parameter WIDTH=128, AW=9)(
 input wclk,rclk,arst_n,input push,input [WIDTH-1:0] wdata,input pop,
 output [WIDTH-1:0] rdata,output full,empty,
 output [AW:0] wcount,rcount,output wreset_done,rreset_done,
 output reg overflow,underflow);
 reg [WIDTH-1:0] mem[0:(1<<AW)-1];
 reg [AW:0] wp,rp,wg,rg;
 (* async_reg="true" *) reg [AW:0] rgs1,rgs2,wgs1,wgs2;
 (* async_reg="true" *) reg [1:0] wrs,rrs;
 wire wrst_n=wrs[1],rrst_n=rrs[1];
 reg [WIDTH-1:0] head;
 function [AW:0] binary(input [AW:0] gray);
 integer i;begin binary[AW]=gray[AW];for(i=AW-1;i>=0;i=i-1)binary[i]=binary[i+1]^gray[i];end endfunction
 assign wreset_done=wrs[1];assign rreset_done=rrs[1];
 assign wcount=wp-binary(rgs2);assign rcount=binary(wgs2)-rp;
 assign full=!wrs[1] || wcount==(1<<AW);assign empty=!rrs[1] || rp==binary(wgs2);
 wire take_w=push&&!full;wire take_r=pop&&!empty;
 wire [AW:0] next_r=rp+take_r;
 assign rdata=head;
 always @(posedge wclk or negedge arst_n)
  if(!arst_n)wrs<=0;else wrs<={wrs[0],1'b1};
 always @(posedge rclk or negedge arst_n)
  if(!arst_n)rrs<=0;else rrs<={rrs[0],1'b1};
 always @(posedge wclk or negedge wrst_n)begin
  if(!wrst_n)begin wp<=0;wg<=0;rgs1<=0;rgs2<=0;overflow<=0;end
  else if(!wrs[1])begin wp<=0;wg<=0;rgs1<=0;rgs2<=0;overflow<=0;end
  else begin
   rgs1<=rg;rgs2<=rgs1;
   if(push&&full)overflow<=1;
   if(take_w)begin wp<=wp+1'b1;wg<=((wp+1'b1)>>1)^(wp+1'b1);end
  end
 end
 always @(posedge wclk)if(take_w)mem[wp[AW-1:0]]<=wdata;
 always @(posedge rclk)head<=mem[next_r[AW-1:0]];
 always @(posedge rclk or negedge rrst_n)begin
  if(!rrst_n)begin rp<=0;rg<=0;wgs1<=0;wgs2<=0;underflow<=0;end
  else if(!rrs[1])begin rp<=0;rg<=0;wgs1<=0;wgs2<=0;underflow<=0;end
  else begin
   wgs1<=wg;wgs2<=wgs1;
   if(pop&&empty)underflow<=1;
   if(take_r)begin rp<=next_r;rg<=(next_r>>1)^next_r;end
  end
 end
endmodule
