// Fixed production clocks only: 74.4MHz PIX, 96MHz UI, 1650x750 raster.
// A 700000-cycle UART budget fits before the next real frame EOF.
module m5c_diag_slot_guard(input pix_clk,ui_clk,pix_rst_n,ui_rst_n,
 input frame_done,output window_open);
 reg frame_toggle;
 always @(posedge pix_clk or negedge pix_rst_n)
  if(!pix_rst_n)frame_toggle<=0;else if(frame_done)frame_toggle<=!frame_toggle;
 (* async_reg="true" *) reg [1:0] frame_sync;
 reg seen;
 reg [19:0] age;
 always @(posedge ui_clk or negedge ui_rst_n)begin
  if(!ui_rst_n)begin frame_sync<=0;seen<=0;age<=20'd900000;end
  else begin
   frame_sync<={frame_sync[0],frame_toggle};
   if(frame_sync[1]!=seen)begin seen<=frame_sync[1];age<=0;end
   else if(age<900000)age<=age+1'b1;
  end
 end
 assign window_open=age<896000;
endmodule
