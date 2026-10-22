`timescale 1ns/1ps
// Two CE-enabled synchronous RAM rows and a registered horizontal window.
// Input sample n -> complete window after n+1 accepted CE edges. The center
// is (latest_x-1,latest_y-1). Repeated SOF in blanking safely rearms the frame.
module reference_m5a_neighborhood #(parameter WIDTH=1280,HEIGHT=720,BITS=15)(
 input clk,ce,rst_n,in_sof,in_valid,input [BITS-1:0] in_data,
 output reg out_valid,output reg [11:0] center_x,center_y,
 output reg [BITS-1:0] p00,p01,p02,p10,p11,p12,p20,p21,p22);
 (* syn_ramstyle="block_ram" *) reg [BITS-1:0] row1[0:WIDTH-1],row2[0:WIDTH-1];
 reg [BITS-1:0] top_pixel,middle_pixel,bottom_pixel;
 reg [11:0] x,y,write_x,lb_x,lb_y;
 reg pending,armed,lb_valid;
 wire accept=in_valid && !in_sof && armed;
 always @(posedge clk) if(rst_n && ce && !in_sof) begin
  if(pending)begin row1[write_x]<=bottom_pixel;row2[write_x]<=middle_pixel;end
  if(accept)begin top_pixel<=row2[x];middle_pixel<=row1[x];bottom_pixel<=in_data;end
 end
 always @(posedge clk or negedge rst_n) begin
  if(!rst_n)begin x<=0;y<=0;write_x<=0;lb_x<=0;lb_y<=0;pending<=0;armed<=0;lb_valid<=0;
   out_valid<=0;center_x<=0;center_y<=0;p00<=0;p01<=0;p02<=0;p10<=0;p11<=0;p12<=0;p20<=0;p21<=0;p22<=0;end
  else if(ce)begin
   lb_valid<=accept;pending<=accept;
   if(in_sof)begin x<=0;y<=0;armed<=1;end
   else if(accept)begin
    lb_x<=x;lb_y<=y;write_x<=x;
    if(x==WIDTH-1)begin x<=0;if(y==HEIGHT-1)begin y<=0;armed<=0;end else y<=y+1'b1;end
    else x<=x+1'b1;
   end
   out_valid<=lb_valid && lb_x>=2 && lb_y>=2 && !in_sof;
   center_x<=(lb_x==0)?12'd0:lb_x-12'd1;center_y<=(lb_y==0)?12'd0:lb_y-12'd1;
   if(lb_valid)begin
    p00<=(lb_x==0)?{BITS{1'b0}}:p01;p01<=(lb_x==0)?{BITS{1'b0}}:p02;p02<=top_pixel;
    p10<=(lb_x==0)?{BITS{1'b0}}:p11;p11<=(lb_x==0)?{BITS{1'b0}}:p12;p12<=middle_pixel;
    p20<=(lb_x==0)?{BITS{1'b0}}:p21;p21<=(lb_x==0)?{BITS{1'b0}}:p22;p22<=bottom_pixel;
   end
  end
 end
endmodule
