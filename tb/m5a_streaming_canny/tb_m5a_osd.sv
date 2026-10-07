`timescale 1ns/1ps
module tb_m5a_osd;
reg test_pass=0;
reg clk=0;always #5 clk=~clk;
reg rst=0,de=0,hs=1,vs=1;reg[23:0] rgb=0;reg[7:0] threshold=64;reg[2:0] mode=2;
wire[23:0] out_rgb;wire od,oh,ov;
m5a_osd dut(clk,1'b1,rst,rgb,de,hs,vs,threshold,mode,out_rgb,od,oh,ov);
integer f,x,y,t,m,expected_bcd,checks=0;
task cycle;input d,h,v;input[7:0] g;begin
 @(negedge clk);de=d;hs=h;vs=v;rgb=(mode==3)?24'hff0000:{3{g}};@(posedge clk);#1;
 if(od!==d || oh!==h || ov!==v)$fatal(1,"OSD_SYNC");
end endtask
initial begin
 repeat(3)@(posedge clk);rst=1;repeat(6)@(posedge clk);
 f=$fopen("m5a_osd_pixels.txt","w");
 for(t=0;t<256;t=t+1)begin
  threshold=t;mode=t%7;
  cycle(0,1,0,0);cycle(0,1,0,0);cycle(0,1,1,0);
  expected_bcd=((t/100)<<8)|(((t%100)/10)<<4)|(t%10);
  if(dut.bcd!==expected_bcd[11:0])$fatal(1,"BCD %0d",t);
  for(y=0;y<40;y=y+1)begin
   cycle(0,0,1,0);cycle(0,1,1,0);
   for(x=0;x<240;x=x+1)begin
    cycle(1,1,1,(x+3*y+t)%256);
    if(x>=12 && x<((mode<4)?148:228) && y>=12 && y<34)$fwrite(f,"%0d %0d %0d %0d\n",t,x,y,out_rgb);
    else if(out_rgb!==((mode==3)?24'hff0000:(((x+3*y+t)%256)*24'h010101)))$fatal(1,"OSD_BACKGROUND");
    checks=checks+1;
   end
   cycle(0,1,1,0);if(out_rgb!==0)$fatal(1,"OSD_BLANK");
  end
 end
 $fclose(f);test_pass=1;$display("M5A_OSD_PASS pixels=%0d thresholds=256",checks);$finish;
end
endmodule
