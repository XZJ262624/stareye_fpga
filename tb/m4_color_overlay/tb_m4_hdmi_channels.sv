`timescale 1ns/1ps
module tb_m4_hdmi_channels;
reg test_pass=0;reg clk=0;always #5 clk=~clk;
reg[23:0]rgb=0;reg de=0,hs=1,vs=1;wire[9:0]b,g,r,c,refb,refg,refr;
rgb2dvi #(.ENABLE_OSERDES(0)) dut(.PixelClk(clk),.aRst(0),.aRst_n(1),.bitflip_i(0),.oe_i(1),
 .vid_pVSync(vs),.vid_pHSync(hs),.vid_pVDE(de),.vid_pData(rgb),.SerialClk(0),
 .txc_o(c),.txd0_o(b),.txd1_o(g),.txd2_o(r));
tmds_channel blue_ref(clk,rgb[7:0],4'd0,{vs,hs},{2'd0,de},refb);
tmds_channel green_ref(clk,rgb[15:8],4'd0,2'd0,{2'd0,de},refg);
tmds_channel red_ref(clk,rgb[23:16],4'd0,2'd0,{2'd0,de},refr);
integer n,checks=0;
initial begin
 for(n=0;n<1024;n=n+1)begin
  @(negedge clk);de=(n%17)!=0;hs=n%2;vs=(n%3)==0;
  case(n%4)
   0:rgb=24'hff0000;
   1:rgb=24'h00ff00;
   2:rgb=24'h0000ff;
   3:rgb={8'(n),8'(n*3),8'(n*7)};
  endcase
  #1;if(dut.enc_0.video_data!==rgb[7:0] || dut.enc_1.video_data!==rgb[15:8] || dut.enc_2.video_data!==rgb[23:16])$fatal(1,"HDMI_CHANNEL_ORDER");
  @(posedge clk);#1;
  if(b!==refb || g!==refg || r!==refr || c!==10'b1111100000)$fatal(1,"HDMI_TMDS_LANE");checks=checks+1;
 end
 test_pass=1;$display("M4_HDMI_CHANNELS_PASS checks=%0d order=B,G,R",checks);$finish;
end
endmodule
