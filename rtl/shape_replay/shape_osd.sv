// M5A-only CE adaptation of committed rtl/m4_color_overlay/m4_osd.v.
`timescale 1ns/1ps
// One matched sampling stage for pixel and all raster signals.
module shape_osd(input [14:0] replay_status,input replay_fault,input clk,input ce,input arst_n,input [23:0] rgb,input de,hs,vs,
 input [7:0] threshold,input [2:0] mode,input [1:0] filter_id,
 input [1:0] shape_class,input shape_valid,
 input fusion_enable,fusion_active,fusion_age_valid,input [31:0] fusion_age,
 output reg [23:0] out_rgb,output reg out_de,out_hs,out_vs);
 (* async_reg="true" *) reg [1:0] reset_release;
 always @(posedge clk or negedge arst_n)
  if(!arst_n) reset_release<=0;else reset_release<={reset_release[0],1'b1};
 wire rst_n=reset_release[1];
 reg de_d,vs_d;reg [11:0] x,y;
 reg [7:0] gsymbol;reg [34:0] gbitmap;reg gink;wire [11:0] gx=x-12'd668;
 reg [7:0] ssymbol;reg [34:0] sbitmap;reg sink;wire [11:0] sx=x-12'd448;
 reg [7:0] symbol;reg [34:0] bitmap;reg ink;
 reg [11:0] bcd,bcd_next,bcd_low,bcd_low_next;
 wire [7:0] low_threshold={1'b0,threshold[7:1]};
 integer digit_bit;
 wire [11:0] rel_x=x-12'd16,rel_y=y-12'd16;
 reg [2:0] col,row;reg [3:0] slot;
 reg [7:0] fsymbol;reg [34:0] fbitmap;reg fink;reg [11:0] fbcd;reg [9:0] age_clamped;
 wire [11:0] fx=x-12'd248;
 integer fbit;
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
 default:font=0;
 endcase end endfunction
 always @* begin
  bcd_next=0;bcd_low_next=0;
  for(digit_bit=7;digit_bit>=0;digit_bit=digit_bit-1) begin
   if(bcd_next[3:0]>=5)bcd_next[3:0]=bcd_next[3:0]+4'd3;
   if(bcd_next[7:4]>=5)bcd_next[7:4]=bcd_next[7:4]+4'd3;
   if(bcd_next[11:8]>=5)bcd_next[11:8]=bcd_next[11:8]+4'd3;
   bcd_next={bcd_next[10:0],threshold[digit_bit]};
   if(bcd_low_next[3:0]>=5)bcd_low_next[3:0]=bcd_low_next[3:0]+4'd3;
   if(bcd_low_next[7:4]>=5)bcd_low_next[7:4]=bcd_low_next[7:4]+4'd3;
   if(bcd_low_next[11:8]>=5)bcd_low_next[11:8]=bcd_low_next[11:8]+4'd3;
   bcd_low_next={bcd_low_next[10:0],low_threshold[digit_bit]};
  end
  slot=rel_x[7:4];col=rel_x[3:1];row=rel_y[3:1];
  symbol=" ";
  case(slot)
   0:symbol=(mode==0)?"R":(mode==1)?"M":(mode==2)?"B":(mode==3)?"O":(mode==4)?"N":"C";
   1:symbol=(mode==0)?"A":(mode==1)?"A":(mode==2)?"I":(mode==3)?"V":(mode==4)?"M":(mode==5)?"N":"O";
   2:symbol=(mode==0)?"W":(mode==1)?"G":(mode==2)?"N":(mode==3)?"R":(mode==4)?"S":(mode==5)?"Y":"V";
   4:symbol=(mode<4)?"T":"H";
   5:symbol=8'd48+{4'b0,bcd[11:8]};
   6:symbol=8'd48+{4'b0,bcd[7:4]};
   7:symbol=8'd48+{4'b0,bcd[3:0]};
   9:symbol="L";
   10:symbol=8'd48+{4'b0,bcd_low[11:8]};
   11:symbol=8'd48+{4'b0,bcd_low[7:4]};
   12:symbol=8'd48+{4'b0,bcd_low[3:0]};
  endcase
  bitmap=font(symbol);ink=0;
  if(x>=16 && x<((mode<4)?144:224) && y>=16 && y<30 && col<5)
   ink=bitmap[34-row*5-col];
  age_clamped=fusion_age>999?10'd999:fusion_age[9:0];fbcd=0;
  for(fbit=9;fbit>=0;fbit=fbit-1)begin
   if(fbcd[3:0]>=5)fbcd[3:0]=fbcd[3:0]+3;
   if(fbcd[7:4]>=5)fbcd[7:4]=fbcd[7:4]+3;
   if(fbcd[11:8]>=5)fbcd[11:8]=fbcd[11:8]+3;
   fbcd={fbcd[10:0],age_clamped[fbit]};
  end
  fsymbol=" ";
  case(fx[7:4])
   0:fsymbol=fusion_active?"F":"L";
   1:fsymbol=fusion_active?"U":"O";
   2:fsymbol=fusion_active?"S":"C";
   3:fsymbol=fusion_active?" ":"A";
   4:fsymbol=fusion_active?" ":"L";
   6:fsymbol="A";
   7:fsymbol=fusion_age_valid?48+fbcd[11:8]:"-";
   8:fsymbol=fusion_age_valid?48+fbcd[7:4]:"-";
   9:fsymbol=fusion_age_valid?48+fbcd[3:0]:"-";
  endcase

  // Previous display-frame result. Fixed new rectangle x444..644, y12..33.
  ssymbol=" ";
  case(sx[7:4])
   0:ssymbol="P";1:ssymbol="R";2:ssymbol="E";3:ssymbol="V";
   5:ssymbol=shape_valid&&shape_class==1?"C":shape_valid&&shape_class==2?"R":"U";
   6:ssymbol=shape_valid&&shape_class==1?"I":shape_valid&&shape_class==2?"E":"N";
   7:ssymbol=shape_valid&&shape_class==1?"R":shape_valid&&shape_class==2?"C":"K";
   8:ssymbol=shape_valid&&shape_class==1?"C":shape_valid&&shape_class==2?"T":"N";
   9:ssymbol=shape_valid&&shape_class==1?"L":shape_valid&&shape_class==2?" ":"O";
   10:ssymbol=shape_valid&&shape_class==1?"E":shape_valid&&shape_class==2?" ":"W";
   11:ssymbol=shape_valid&&(shape_class==1||shape_class==2)?" ":"N";
  endcase
  gsymbol=" ";
  case(gx[5:4])
   0:gsymbol=filter_id==0?"N":filter_id==1?"M":filter_id==2?"G":"E";
   1:gsymbol=filter_id==0?"O":filter_id==1?"E":filter_id==2?"A":"R";
   2:gsymbol=filter_id==0?"N":filter_id==1?"D":filter_id==2?"U":"R";
  endcase
  gbitmap=font(gsymbol);gink=0;
  if(x>=668&&x<716&&y>=16&&y<30&&gx[3:1]<5)gink=gbitmap[34-row*5-gx[3:1]];
  sbitmap=font(ssymbol);sink=0;
  if(x>=448&&x<640&&y>=16&&y<30&&sx[3:1]<5)sink=sbitmap[34-row*5-sx[3:1]];
  fbitmap=font(fsymbol);fink=0;
  if(x>=248&&x<408&&y>=16&&y<30&&fx[3:1]<5)fink=fbitmap[34-row*5-fx[3:1]];
 end
 reg [14:0] replay_frame_status;wire [1:0] replay_state=replay_frame_status[1:0];
 wire [5:0] replay_number=replay_state==1?replay_frame_status[13:8]:replay_frame_status[7:2]+1'b1;
 wire [11:0] rx=x-16,ry=y-48;reg [7:0] replay_symbol;reg [34:0] replay_bitmap;reg replay_ink;
 always @*begin
  replay_symbol=" ";
  case(rx[9:4])
   0:replay_symbol=replay_fault?"E":replay_state==0?"L":replay_state==1?"R":"P";
   1:replay_symbol=replay_fault?"R":replay_state==0?"I":replay_state==1?"E":replay_state==2?"L":"A";
   2:replay_symbol=replay_fault?"R":replay_state==0?"V":replay_state==1?"C":replay_state==2?"A":"U";
   3:replay_symbol=replay_fault?"O":replay_state==0?"E":replay_state==1?" ":replay_state==2?"Y":"S";
   4:replay_symbol=replay_fault?"R":replay_state==3?"E":" ";
   6:replay_symbol=replay_state==0?" ":48+replay_number/10;7:replay_symbol=replay_state==0?" ":48+replay_number%10;
   8:replay_symbol=replay_state==0?" ":"-";9:replay_symbol=replay_state==0?" ":"3";10:replay_symbol=replay_state==0?" ":"2";
   13:replay_symbol=replay_frame_status[14]?"C":"N";14:replay_symbol=replay_frame_status[14]?"L":"O";
   15:replay_symbol=replay_frame_status[14]?"I":" ";16:replay_symbol=replay_frame_status[14]?"P":"C";
   17:replay_symbol=replay_frame_status[14]?" ":"L";18:replay_symbol=replay_frame_status[14]?" ":"I";19:replay_symbol=replay_frame_status[14]?" ":"P";
  endcase
  replay_bitmap=font(replay_symbol);replay_ink=0;
  if(x>=16&&x<336&&y>=48&&y<76&&rx[3:0]<10)replay_ink=replay_bitmap[34-(ry>>2)*5-(rx[3:0]>>1)];
 end
 always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin replay_frame_status<=0;x<=0;y<=0;de_d<=0;vs_d<=1;bcd<=12'h064;bcd_low<=12'h032;out_rgb<=0;out_de<=0;out_hs<=1;out_vs<=1;end
  else if (ce) begin
   de_d<=de;vs_d<=vs;if(de&&x==0&&y==0)replay_frame_status<=replay_status;
   if(!vs)begin bcd<=bcd_next;bcd_low<=bcd_low_next;end
   if(vs_d && !vs) begin x<=0;y<=0;end
   else if (ce) begin
    if(de) x<=x+1'b1;else x<=0;
    if(de_d && !de) y<=y+1'b1;
   end
   out_de<=de;out_hs<=hs;out_vs<=vs;
   if(!de) out_rgb<=0;
   else if(x>=12 && x<((mode<4)?148:228) && y>=12 && y<34) out_rgb<=ink?24'hffffff:24'h000000;
   else if(mode==6&&fusion_enable&&x>=244&&x<412&&y>=12&&y<34)out_rgb<=fink?24'hffffff:24'h000000;
   else if(x>=444&&x<644&&y>=12&&y<34)out_rgb<=sink?24'hffff00:24'h000000;
   else if(x>=664&&x<720&&y>=12&&y<34)out_rgb<=gink?24'h00ff00:24'h000000;
   else if(x>=12&&x<340&&y>=44&&y<80)out_rgb<=replay_ink?(replay_fault?24'hff3030:24'h00ff80):24'h101018;
   else if(((x==160||x==1119)&&y>=90&&y<=629)||((y==90||y==629)&&x>=160&&x<=1119))out_rgb<=24'h408040;
   else out_rgb<=rgb;
  end
 end
endmodule
