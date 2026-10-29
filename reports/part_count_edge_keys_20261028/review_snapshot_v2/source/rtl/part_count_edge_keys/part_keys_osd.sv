`timescale 1ns/1ps
module part_keys_osd(
 input clk,rst_n,ce,sof,input [7:0] gray,input mask,de,hs,vs,view,input [11:0] x,y,
 input [7:0] high_threshold,
 input count_valid,have_value,busy,input [3:0] count,error_code,input [1:0] confirmations,
 input [63:0] ticks,count_tick,input diag_held,diag_have,diag_armed,input [767:0] diag_record,
 output reg [23:0] out_rgb,output reg out_de,out_hs,out_vs
);
 `include "part_open_font.svh"
 reg [7:0] hi;wire [7:0] lo=hi>>1;
 reg vh,vld,hav,bsy,dh,dv,da;reg [3:0] cnt,err;reg [1:0] conf;reg [767:0] dr;
 wire left=x>=16&&x<412&&y>=16&&y<70;
 wire right=x>=624&&x<1200&&y>=16&&y<90;
 wire [11:0] rx=right?x-624:x-16;wire [6:0] slot=rx/12;wire [2:0] col=(rx%12)>>1;
 wire [3:0] row=(y-16)/20;wire [4:0] sy=(y-16)%20;
 reg [383:0] line;reg [7:0] symbol;reg [34:0] bitmap;reg ink;
 function [7:0] hexchar(input [3:0] n);begin hexchar=n<10?48+n:65+n-10;end endfunction
 always @*begin
  line="                                                ";symbol=" ";
  if(left)begin
   case(row)
    0:line="CURRENT --   LAST --                            ";
    1:line=vld?"READY   E0 C0                                   ":bsy?"SCAN    E0 C0                                   ":err!=0?"INVALID E0 C0                                   ":"WAIT    E0 C0                                   ";
    2:line=vh?"MSK H048 L024 CLOSE 3X3                         ":"RAW H048 L024 CLOSE 3X3                         ";
    default:begin end
   endcase
   symbol=line[(47-slot)*8+:8];
   if(row==0&&((vld&&(slot==8||slot==9))||(hav&&(slot==18||slot==19))))symbol=(slot==8||slot==18)?(cnt==10?"1":"0"):(cnt==10?"0":48+cnt);
   if(row==2)case(slot)
    5:symbol=48+hi/100;6:symbol=48+(hi/10)%10;7:symbol=48+hi%10;
    10:symbol=48+lo/100;11:symbol=48+(lo/10)%10;12:symbol=48+lo%10;
    default:begin end
   endcase
   if(row==1)case(slot)9:symbol=hexchar(err);12:symbol=48+conf;default:begin end endcase
  end
  if(right)begin
   case(row)
    0:line="EXPERIMENT E4E5 OFF                             ";
    1:line=dh?"HELD E0 F0000 RUN0000 HEX                       ":da?"ARM WAIT REJECT                                 ":"WAIT 5S HISTORY                                 ";
    2:if(dv)line="EDGE00000 MICRO00000 HEX                        ";
    3:if(dv)line=dr[9*32+16]?"AREA00000 W000 H000 HEX                         ":"AREA----- W--- H---                             ";
    default:begin end
   endcase
   symbol=line[(47-slot)*8+:8];
   if(dv)begin
    if(row==1&&slot==6)symbol=hexchar(dr[3:0]);
    if(row==1&&slot>=9&&slot<=12)symbol=hexchar(dr[10*32+(12-slot)*4+:4]);
    if(row==1&&slot>=17&&slot<=20)symbol=hexchar(dr[4*32+(20-slot)*4+:4]);
    if(row==2&&slot>=4&&slot<=8)symbol=hexchar(dr[3*32+(8-slot)*4+:4]);
    if(row==2&&slot>=15&&slot<=19)symbol=hexchar(dr[5*32+(19-slot)*4+:4]);
    if(row==3&&dr[9*32+16])begin
     if(slot>=4&&slot<=8)symbol=hexchar(dr[2*32+(8-slot)*4+:4]);
     if(slot>=11&&slot<=13)symbol=hexchar(dr[6*32+(13-slot)*4+:4]);
     if(slot>=16&&slot<=18)symbol=hexchar(dr[6*32+16+(18-slot)*4+:4]);
    end
   end
  end
  bitmap=font(symbol);ink=(left||right)&&col<5&&sy<14?bitmap[34-(sy>>1)*5-col]:0;
 end
 wire roi_border=((x==160||x==1119)&&y>=90&&y<=629)||((y==90||y==629)&&x>=160&&x<=1119);
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin hi<=48;vh<=0;vld<=0;hav<=0;bsy<=0;dh<=0;dv<=0;da<=0;cnt<=0;err<=0;conf<=0;dr<=0;out_rgb<=0;out_de<=0;out_hs<=1;out_vs<=1;end
  else if(ce)begin
   if(sof)begin hi<=high_threshold;vh<=view;vld<=count_valid;hav<=have_value;bsy<=busy;cnt<=count;err<=error_code;conf<=confirmations;dh<=diag_held;dv<=diag_have;da<=diag_armed;dr<=diag_have?diag_record:768'd0;end
   out_de<=de;out_hs<=hs;out_vs<=vs;
   if(!de)out_rgb<=0;
   else if(left||right)out_rgb<=ink?(right?24'hffff80:24'hffffff):24'h000000;
   else if(roi_border)out_rgb<=vld?24'h40c040:24'hd08020;
   else if(sof?view:vh)out_rgb<=mask?24'hffffff:24'h000000;
   else out_rgb<={gray,gray,gray};
  end
 end
endmodule
