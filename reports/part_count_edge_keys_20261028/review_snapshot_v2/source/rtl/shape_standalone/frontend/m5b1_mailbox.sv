// Stable multi-bit mailbox. Source cannot overwrite data until acknowledged.
// Destination consumes only after toggle crosses two receiving clock edges.
module m5b1_mailbox #(parameter WIDTH=256)(
 input sclk,dclk,arst_n,input send,input [WIDTH-1:0] sdata,output busy,
 output reg valid,output reg [WIDTH-1:0] ddata,input take);
 (* async_reg="true" *) reg [1:0] srelease,drelease;
 always @(posedge sclk or negedge arst_n)if(!arst_n)srelease<=0;else srelease<={srelease[0],1'b1};
 always @(posedge dclk or negedge arst_n)if(!arst_n)drelease<=0;else drelease<={drelease[0],1'b1};
 wire srst_n=srelease[1],drst_n=drelease[1];
 reg [WIDTH-1:0] held;reg req,ack;
 (* async_reg="true" *) reg [1:0] req_sync,ack_sync;
 assign busy=!srst_n||req!=ack_sync[1];
 always @(posedge sclk or negedge srst_n)
  if(!srst_n)begin held<=0;req<=0;ack_sync<=0;end
  else begin ack_sync<={ack_sync[0],ack};if(send&&!busy)begin held<=sdata;req<=!req;end end
 always @(posedge dclk or negedge drst_n)
  if(!drst_n)begin ack<=0;req_sync<=0;valid<=0;ddata<=0;end
  else begin
   req_sync<={req_sync[0],req};
   if(!valid&&req_sync[1]!=ack)begin ddata<=held;valid<=1;end
   if(valid&&take)begin ack<=req_sync[1];valid<=0;end
  end
endmodule
