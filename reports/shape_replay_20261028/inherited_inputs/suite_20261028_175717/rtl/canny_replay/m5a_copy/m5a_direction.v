`timescale 1ns/1ps
// Gx points right, Gy points UP. No division, atan, or multipliers.
// Codes 0=E/W, 1=NE/SW, 2=N/S, 3=NW/SE. Ties belong to axes.
module m5a_direction(input signed [10:0] gx,gy,output [1:0] direction);
 wire [10:0] ax=gx[10]?$unsigned(-gx):$unsigned(gx);
 wire [10:0] ay=gy[10]?$unsigned(-gy):$unsigned(gy);
 wire [18:0] x256={ax,8'b0},y256={ay,8'b0};
 wire [18:0] x106=({8'b0,ax}<<6)+({8'b0,ax}<<5)+({8'b0,ax}<<3)+({8'b0,ax}<<1);
 wire [18:0] y106=({8'b0,ay}<<6)+({8'b0,ay}<<5)+({8'b0,ay}<<3)+({8'b0,ay}<<1);
 assign direction=(y256<=x106)?2'd0:(x256<=y106)?2'd2:
                  (gx[10]==gy[10])?2'd1:2'd3;
endmodule
