`timescale 1ns/1ps
module tb_link;
reg clk=0;always #5 clk=~clk;
reg rst=0,de=0,hs=1,vs=1;reg[7:0] gray=0;reg[1:0] keys=3;
wire[7:0] out_gray;wire od,oh,ov;
m31_link dut(clk,rst,keys,gray,de,hs,vs,out_gray,od,oh,ov);
integer file,x,y,f,n;reg[7:0] want_t;reg[1:0] want_m;
task cycle;input d,h,v;input[7:0] g;begin
 @(negedge clk);de=d;hs=h;vs=v;gray=g;@(posedge clk);#1;
 $fwrite(file,"%0d %0d %0d %0d %0d %0d %0d %0d %0d %0d\n",g,d,h,v,dut.control_mode,dut.control_threshold,out_gray,od,oh,ov);
 if(d && (dut.control_mode!==want_m || dut.control_threshold!==want_t))$fatal(1,"FRAME_CONFIG f=%0d",f);
end endtask
task idle;input integer count;begin repeat(count)cycle(0,1,1,0);end endtask
task gesture;input[1:0] k;begin keys=k;idle(12);keys=3;idle(12);end endtask
initial begin
 repeat(3)@(posedge clk);rst=1;repeat(20)@(posedge clk);
 file=$fopen("link_pixels.txt","w");want_t=64;want_m=2;idle(10);
 for(f=0;f<9;f=f+1)begin
  if(f==1)want_t=80;
  if(f==2 || f==3 || f==4 || f==6 || f==7)begin gesture(0);want_m=(want_m==2)?0:want_m+1;end
  if(f==5)begin gesture(2);want_t=96;end
  if(f==8)begin gesture(2);gesture(2);want_t=128;end
  cycle(0,1,0,0);cycle(0,1,0,0);cycle(0,1,1,0);idle(6);
  for(y=0;y<40;y=y+1)begin
   cycle(0,0,1,0);cycle(0,0,1,0);cycle(0,1,1,0);
   for(x=0;x<160;x=x+1)begin
    if(f==0 && y==5 && x==0)keys=2;
    if(f==0 && y==6 && x==0)keys=3;
    cycle(1,1,1,((x*3+y*5+f*7)^(x<80?0:127))%256);
   end
   idle(4);
  end
  idle(10);
 end
 idle(10);$fclose(file);$display("M31_LINK_PASS frames=9 pixels=57600");$finish;
end
endmodule
