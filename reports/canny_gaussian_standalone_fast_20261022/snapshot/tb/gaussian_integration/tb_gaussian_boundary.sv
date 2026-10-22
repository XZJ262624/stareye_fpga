`timescale 1ns/1ps
module tb_gaussian_boundary;
 localparam H_TOTAL=40,LAT=H_TOTAL+16;
 reg clk=0;always #5 clk=~clk;reg rst=0,ce=1,sof=0;reg[1:0] f=0;reg[7:0] hi=64;
 wire[1:0] of;wire[7:0] oh;wire[2:0] om;
 m5a_m32_stream #(.WIDTH(32),.HEIGHT(24),.H_TOTAL(H_TOTAL)) dut(.clk(clk),.ce(ce),.arst_n(rst),.in_gray(8'd0),.in_de(1'b0),.in_hs(1'b1),.in_vs(1'b1),.in_sof(sof),.filter_request(f),.threshold(hi),.mode(3'd2),.out_filter_enable(of),.out_threshold(oh),.out_mode(om));
 reg[1:0] held_filter;reg[1:0] q[0:LAT-1];integer i,p=0,checks=0,stalls=0;
 initial begin
  for(i=0;i<LAT;i=i+1)q[i]=0;
  repeat(4)@(negedge clk);rst=1;repeat(8)@(negedge clk);
  for(i=0;i<500;i=i+1)begin
   @(negedge clk);ce=1;sof=(i==100||i==140||i==180||i==220);
   if(i==100)f=1;if(i==140)f=2;if(i==180)f=1;if(i==220)f=0;
   @(posedge clk);#1;if(of!==q[p])$fatal(1,"GAUSS_BOUNDARY_FILTER_ONE_TICK expected=%0d got=%0d cycle=%0d",q[p],of,i);
   q[p]=f;p=(p+1)%LAT;checks=checks+1;
   if(i%17==4)begin @(negedge clk);ce=0;held_filter=of;repeat(2)begin @(posedge clk);#1;if(of!==held_filter)$fatal(1,"GAUSS_BOUNDARY_CE_FREEZE");stalls=stalls+1;end end
  end
  $display("PASS_GAUSSIAN_BOUNDARY checks=%0d stalls=%0d label_latency=%0d old_tail_new_first=1",checks,stalls,LAT);$finish;
 end
endmodule
