`timescale 1ns/1ps
// One matched sampling stage for pixel and all raster signals.
module m4_osd(input clk,input arst_n,input [23:0] rgb,input de,hs,vs,
 input [7:0] threshold,input [1:0] mode,
 output reg [23:0] out_rgb,output reg out_de,out_hs,out_vs);
 (* async_reg="true" *) reg [1:0] reset_release;
 always @(posedge clk or negedge arst_n)
  if(!arst_n) reset_release<=0;else reset_release<={reset_release[0],1'b1};
 wire rst_n=reset_release[1];
 reg de_d,vs_d;reg [11:0] x,y;
 reg [7:0] symbol;reg [34:0] bitmap;reg ink;
 reg [11:0] bcd,bcd_next;
 integer digit_bit;
 wire [11:0] rel_x=x-12'd16,rel_y=y-12'd16;
 reg [2:0] col,row,slot;
 function [34:0] font;
 input [7:0] c;
 begin case(c)
 "0":font={5'b01110,5'b10001,5'b10011,5'b10101,5'b11001,5'b10001,5'b01110};
 "1":font={5'b00100,5'b01100,5'b00100,5'b00100,5'b00100,5'b00100,5'b01110};
 "2":font={5'b01110,5'b10001,5'b00001,5'b00010,5'b00100,5'b01000,5'b11111};
 "3":font={5'b11110,5'b00001,5'b00001,5'b01110,5'b00001,5'b00001,5'b11110};
 "4":font={5'b00010,5'b00110,5'b01010,5'b10010,5'b11111,5'b00010,5'b00010};
 "5":font={5'b11111,5'b10000,5'b10000,5'b11110,5'b00001,5'b00001,5'b11110};
 "6":font={5'b01110,5'b10000,5'b10000,5'b11110,5'b10001,5'b10001,5'b01110};
 "7":font={5'b11111,5'b00001,5'b00010,5'b00100,5'b01000,5'b01000,5'b01000};
 "8":font={5'b01110,5'b10001,5'b10001,5'b01110,5'b10001,5'b10001,5'b01110};
 "9":font={5'b01110,5'b10001,5'b10001,5'b01111,5'b00001,5'b00001,5'b01110};
 "R":font={5'b11110,5'b10001,5'b10001,5'b11110,5'b10100,5'b10010,5'b10001};
 "A":font={5'b01110,5'b10001,5'b10001,5'b11111,5'b10001,5'b10001,5'b10001};
 "W":font={5'b10001,5'b10001,5'b10001,5'b10101,5'b10101,5'b10101,5'b01010};
 "M":font={5'b10001,5'b11011,5'b10101,5'b10101,5'b10001,5'b10001,5'b10001};
 "G":font={5'b01110,5'b10001,5'b10000,5'b10111,5'b10001,5'b10001,5'b01110};
 "B":font={5'b11110,5'b10001,5'b10001,5'b11110,5'b10001,5'b10001,5'b11110};
 "I":font={5'b01110,5'b00100,5'b00100,5'b00100,5'b00100,5'b00100,5'b01110};
 "N":font={5'b10001,5'b11001,5'b11001,5'b10101,5'b10011,5'b10011,5'b10001};
 "T":font={5'b11111,5'b00100,5'b00100,5'b00100,5'b00100,5'b00100,5'b00100};
 "O":font={5'b01110,5'b10001,5'b10001,5'b10001,5'b10001,5'b10001,5'b01110};
 "V":font={5'b10001,5'b10001,5'b10001,5'b10001,5'b10001,5'b01010,5'b00100};
 default:font=0;
 endcase end endfunction
 always @* begin
  bcd_next=0;
  for(digit_bit=7;digit_bit>=0;digit_bit=digit_bit-1) begin
   if(bcd_next[3:0]>=5)bcd_next[3:0]=bcd_next[3:0]+4'd3;
   if(bcd_next[7:4]>=5)bcd_next[7:4]=bcd_next[7:4]+4'd3;
   if(bcd_next[11:8]>=5)bcd_next[11:8]=bcd_next[11:8]+4'd3;
   bcd_next={bcd_next[10:0],threshold[digit_bit]};
  end
  slot=rel_x[6:4];col=rel_x[3:1];row=rel_y[3:1];
  symbol=" ";
  case(slot)
   0:symbol=(mode==0)?"R":(mode==1)?"M":(mode==2)?"B":"O";
   1:symbol=(mode==0)?"A":(mode==1)?"A":(mode==2)?"I":"V";
   2:symbol=(mode==0)?"W":(mode==1)?"G":(mode==2)?"N":"R";
   4:symbol="T";
   5:symbol=8'd48+{4'b0,bcd[11:8]};
   6:symbol=8'd48+{4'b0,bcd[7:4]};
   7:symbol=8'd48+{4'b0,bcd[3:0]};
  endcase
  bitmap=font(symbol);ink=0;
  if(x>=16 && x<144 && y>=16 && y<30 && col<5)
   ink=bitmap[34-row*5-col];
 end
 always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin x<=0;y<=0;de_d<=0;vs_d<=1;bcd<=12'h064;out_rgb<=0;out_de<=0;out_hs<=1;out_vs<=1;end
  else begin
   de_d<=de;vs_d<=vs;
   if(!vs)bcd<=bcd_next;
   if(vs_d && !vs) begin x<=0;y<=0;end
   else begin
    if(de) x<=x+1'b1;else x<=0;
    if(de_d && !de) y<=y+1'b1;
   end
   out_de<=de;out_hs<=hs;out_vs<=vs;
   if(!de) out_rgb<=0;
   else if(x>=12 && x<148 && y>=12 && y<34) out_rgb<=ink?24'hffffff:24'h000000;
   else out_rgb<=rgb;
  end
 end
endmodule
