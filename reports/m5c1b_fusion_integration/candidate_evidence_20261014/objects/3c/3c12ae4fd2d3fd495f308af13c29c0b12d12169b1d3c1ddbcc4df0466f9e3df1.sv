// Two transaction owners inside C2. Outer RT admission is unchanged.
module m5c_bg_mux(
 input clk,rst_n,stop,capture_priority,
 input [1:0] s_avalid,output reg [1:0] s_aready,
 input [63:0] s_aaddr,input [15:0] s_alen,s_aid,input [1:0] s_atype,
 input [1:0] s_wvalid,s_wlast,input [255:0] s_wdata,output reg [1:0] s_wready,
 output reg [1:0] s_bvalid,output [7:0] s_bid,output [1:0] s_bresp,
 output reg [1:0] s_rvalid,output s_rlast,output [127:0] s_rdata,
 output [7:0] s_rid,output [1:0] s_rresp,input [1:0] s_rready,
 output reg [1:0] s_rejected,output reg busy,output reg owner,
 output avalid,input aready,output [31:0] aaddr,output [7:0] alen,aid,output atype,
 output wvalid,wlast,output [127:0] wdata,input wready,
 input bvalid,input [7:0] bid,input [1:0] bresp,
 input rvalid,rlast,input [127:0] rdata,input [7:0] rid,input [1:0] rresp,
 output rready,input rejected);
 reg turn,pending,pending_owner;
 wire choice_now=capture_priority&&s_avalid[0]?1'b0:s_avalid[turn]?turn:!turn;
 wire choose=pending?pending_owner:choice_now;
 assign avalid=!busy&&!stop&&s_avalid[choose];
 assign aaddr=s_aaddr[choose*32+:32];assign alen=s_alen[choose*8+:8];
 assign aid=s_aid[choose*8+:8];assign atype=s_atype[choose];
 assign wvalid=busy&&!stop&&s_wvalid[owner];assign wlast=s_wlast[owner];
 assign wdata=s_wdata[owner*128+:128];
 assign rready=busy&&!stop&&s_rready[owner];
 assign s_bid=bid;assign s_bresp=bresp;assign s_rid=rid;assign s_rresp=rresp;
 assign s_rlast=rlast;assign s_rdata=rdata;
 always @*begin
  s_aready=0;s_wready=0;s_bvalid=0;s_rvalid=0;s_rejected=0;
  if(!busy&&!stop)s_aready[choose]=aready;
  if(busy)begin
   s_wready[owner]=wready&&!stop;s_bvalid[owner]=bvalid&&!stop;
   s_rvalid[owner]=rvalid&&!stop;s_rejected[owner]=rejected;
  end
 end
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin busy<=0;owner<=0;turn<=0;pending<=0;pending_owner<=0;end
  else if(!stop)begin
   if(!busy&&avalid&&!aready&&!pending)begin pending<=1;pending_owner<=choose;end
   if(pending&&!s_avalid[pending_owner])pending<=0;
   if(avalid&&aready)begin busy<=1;owner<=choose;pending<=0;end
   if(busy&&(rejected||bvalid||(rvalid&&rready&&rlast)))begin busy<=0;turn<=!owner;end
  end
 end
endmodule
