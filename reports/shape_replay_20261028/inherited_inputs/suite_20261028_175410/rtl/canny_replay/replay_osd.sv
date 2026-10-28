module replay_osd(input clk,rst_n,input [23:0] rgb,input de,hs,vs,
 input [11:0] x,y,input [2:0] mode,input [14:0] status,input fault,
 output reg [23:0] out_rgb,output reg out_de,out_hs,out_vs);
 reg [14:0] frame_status;wire [1:0] state=frame_status[1:0];
 wire [5:0] number=state==1?frame_status[13:8]:frame_status[7:2]+1'b1;
 wire [11:0] rx=x-16,ry=y-16;reg [7:0] symbol;reg [34:0] bitmap;reg ink;
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
 "S":font={5'b01111,5'b10000,5'b10000,5'b01110,5'b00001,5'b00001,5'b11110};
 "C":font={5'b01110,5'b10001,5'b10000,5'b10000,5'b10000,5'b10001,5'b01110};
 "Y":font={5'b10001,5'b10001,5'b01010,5'b00100,5'b00100,5'b00100,5'b00100};
 "H":font={5'b10001,5'b10001,5'b10001,5'b11111,5'b10001,5'b10001,5'b10001};
 "L":font={5'b10000,5'b10000,5'b10000,5'b10000,5'b10000,5'b10000,5'b11111};
 "F":font={5'b11111,5'b10000,5'b10000,5'b11110,5'b10000,5'b10000,5'b10000};
 "U":font={5'b10001,5'b10001,5'b10001,5'b10001,5'b10001,5'b10001,5'b01110};
 "P":font={5'b11110,5'b10001,5'b10001,5'b11110,5'b10000,5'b10000,5'b10000};
 "E":font={5'b11111,5'b10000,5'b10000,5'b11110,5'b10000,5'b10000,5'b11111};
 "K":font={5'b10001,5'b10010,5'b10100,5'b11000,5'b10100,5'b10010,5'b10001};
 "D":font={5'b11110,5'b10001,5'b10001,5'b10001,5'b10001,5'b10001,5'b11110};
 "-":font={5'b00000,5'b00000,5'b00000,5'b11111,5'b00000,5'b00000,5'b00000};
 "X":font={5'b10001,5'b10001,5'b01010,5'b00100,5'b01010,5'b10001,5'b10001};
 default:font=0;
 endcase end endfunction

 always @*begin
  symbol=" ";
  case(rx[9:4])
   0:symbol=fault?"E":state==0?"L":state==1?"R":"P";
   1:symbol=fault?"R":state==0?"I":state==1?"E":state==2?"L":"A";
   2:symbol=fault?"R":state==0?"V":state==1?"C":state==2?"A":"U";
   3:symbol=fault?"O":state==0?"E":state==1?" ":state==2?"Y":"S";
   4:symbol=fault?"R":state==3?"E":" ";
   6:symbol=state==0?" ":48+number/10;
   7:symbol=state==0?" ":48+number%10;
   8:symbol=state==0?" ":"-";
   9:symbol=state==0?" ":"3";10:symbol=state==0?" ":"2";
   13:symbol=mode==0?"R":"C";14:symbol=mode==0?"A":"N";15:symbol=mode==0?"W":"Y";
   18:symbol=frame_status[14]?"C":"N";19:symbol=frame_status[14]?"L":"O";
   20:symbol=frame_status[14]?"I":" ";21:symbol=frame_status[14]?"P":"C";
   22:symbol=frame_status[14]?" ":"L";23:symbol=frame_status[14]?" ":"I";24:symbol=frame_status[14]?" ":"P";
  endcase
  bitmap=font(symbol);ink=0;
  if(x>=16&&x<416&&y>=16&&y<44&&rx[3:0]<10&&ry<28)
   ink=bitmap[34-(ry>>2)*5-(rx[3:0]>>1)];
 end
 always @(posedge clk or negedge rst_n)
  if(!rst_n)begin frame_status<=0;out_rgb<=0;out_de<=0;out_hs<=1;out_vs<=1;end
  else begin
   if(de&&x==0&&y==0)frame_status<=status;
   out_de<=de;out_hs<=hs;out_vs<=vs;
   out_rgb<=!de?0:ink?(fault?24'hff3030:state==1?24'hff6060:state==3?24'hffff00:24'h00ff80):
    (x>=12&&x<420&&y>=12&&y<48)?24'h101018:rgb;
  end
endmodule
