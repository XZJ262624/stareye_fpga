`timescale 1ns/1ps
module tb_m4_colorize;
reg test_pass=0;
reg de,valid,bin;reg[1:0]mode;reg[7:0]raw,legacy;wire[23:0]rgb;
m4_colorize dut(de,mode,legacy,raw,valid,bin,rgb);
integer a,b,c,d,e,checks=0;reg[23:0]expected;
initial begin
 for(a=0;a<256;a=a+1)for(b=0;b<4;b=b+1)for(c=0;c<2;c=c+1)for(d=0;d<2;d=d+1)for(e=0;e<2;e=e+1)begin
  raw=a;legacy=255-a;mode=b;valid=c;bin=d;de=e;#1;
  if(!e)expected=0;else if(b<3)expected=(255-a)*24'h010101;
  else if(c && d)expected=24'hff0000;else expected=a*24'h010101;
  if(rgb!==expected)$fatal(1,"COLORIZE raw=%0d mode=%0d valid=%0d edge=%0d de=%0d actual=%h expected=%h",a,b,c,d,e,rgb,expected);
  checks=checks+1;
 end
 test_pass=1;$display("M4_COLORIZE_PASS checks=%0d",checks);$finish;
end
endmodule
