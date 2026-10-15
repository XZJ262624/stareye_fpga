module baseline_m5b1_uart #(parameter CLOCK=96000000,BAUD=460800)(
 input clk,rst_n,abort,input valid,input [7:0] data,output ready,output tx);
 reg busy;reg [9:0] bits;reg [3:0] index;reg [31:0] phase;
 assign ready=!busy;assign tx=busy?bits[0]:1'b1;
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin busy<=0;bits<=10'h3ff;index<=0;phase<=0;end
  else if(abort)begin busy<=0;bits<=10'h3ff;index<=0;phase<=0;end
  else if(!busy)begin
   if(valid)begin bits<={1'b1,data,1'b0};index<=0;phase<=0;busy<=1;end
  end else if(phase+BAUD>=CLOCK)begin
   phase<=phase+BAUD-CLOCK;bits<={1'b1,bits[9:1]};
   if(index==9)busy<=0;else index<=index+1'b1;
  end else phase<=phase+BAUD;
 end
endmodule
module baseline_m5b1_packet_tx(input clk,rst_n,abort,input start,input [7:0] packet_type,
 input [31:0] length,input [319:0] descriptor,
 input [7:0] payload,input payload_valid,output payload_ready,
 output busy,output reg done,output uart_tx);
 reg [2:0] state;reg [511:0] header;reg [31:0] size,position,crc;reg [1:0] crc_pos;
 wire ready;wire valid=state==1||(state==2&&payload_valid)||state==3;
 wire [7:0] byte_data=state==1?header[position*8+:8]:state==2?payload:(~crc>>(crc_pos*8));
 assign payload_ready=state==2&&ready;assign busy=state!=0;
 baseline_m5b1_uart uart(.clk(clk),.rst_n(rst_n),.abort(abort),.valid(valid),.data(byte_data),.ready(ready),.tx(uart_tx));
 function [31:0] crc_byte(input [31:0] c,input [7:0] b);
 reg [31:0] v;integer i;begin v=c^b;for(i=0;i<8;i=i+1)v=v[0]?(v>>1)^32'hedb88320:v>>1;crc_byte=v;end endfunction
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin state<=0;header<=0;size<=0;position<=0;crc<=32'hffffffff;crc_pos<=0;done<=0;end
  else if(abort)begin state<=0;done<=0;position<=0;crc<=32'hffffffff;end
  else begin
   done<=0;
   case(state)
    0:if(start)begin header<={64'b0,descriptor,32'b0,length,16'd64,packet_type,8'd1,32'h42354d53};size<=length;position<=0;crc<=32'hffffffff;state<=1;end
    1:if(ready)begin crc<=crc_byte(crc,byte_data);if(position==63)begin position<=0;state<=size==0?3:2;crc_pos<=0;end else position<=position+1'b1;end
    2:if(payload_ready&&payload_valid)begin crc<=crc_byte(crc,payload);if(position==size-1)begin crc_pos<=0;state<=3;end else position<=position+1'b1;end
    3:if(ready)begin if(crc_pos==3)state<=4;else crc_pos<=crc_pos+1'b1;end
    4:if(ready)begin done<=1;state<=0;end
   endcase
  end
 end
endmodule
