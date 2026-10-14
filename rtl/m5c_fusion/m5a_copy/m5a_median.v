// M5A-only CE adaptation of committed rtl/m32_median_integration/median_3x3.v.
`timescale 1ns/1ps
// Exact unsigned median: odd-even transposition sorts nine lanes in nine layers.
// Nine sampling stages: a window sampled at n appears after n+8 CE ticks.
module m5a_median (
    input clk,input ce, input rst_n, input in_valid,
    input [7:0] p00,p01,p02,p10,p11,p12,p20,p21,p22,
    output out_valid, output [7:0] median_gray
);
    wire [71:0] lane [0:9];
    reg [8:0] valid_pipe;
    assign lane[0] = {p22,p21,p20,p12,p11,p10,p02,p01,p00};
    genvar s,k;
    generate for (s=0;s<9;s=s+1) begin: layer
        for (k=0;k<9;k=k+1) begin: slot
            reg [7:0] value;
            // Even layers compare (0,1),(2,3)...; odd layers (1,2),(3,4)... .
            if ((k%2)==(s%2) && k<8) begin: lower
                wire [7:0] a=lane[s][k*8 +: 8];
                wire [7:0] b=lane[s][(k+1)*8 +: 8];
                always @(posedge clk or negedge rst_n)
                    if (!rst_n) value<=0;
                    else if (ce) value <= (a<=b) ? a : b;
            end else if (k>0 && ((k-1)%2)==(s%2)) begin: upper
                wire [7:0] a=lane[s][(k-1)*8 +: 8];
                wire [7:0] b=lane[s][k*8 +: 8];
                always @(posedge clk or negedge rst_n)
                    if (!rst_n) value<=0;
                    else if (ce) value <= (a<=b) ? b : a;
            end else begin: unpaired
                always @(posedge clk or negedge rst_n)
                    if (!rst_n) value<=0;
                    else if (ce) value<=lane[s][k*8 +: 8];
            end
            assign lane[s+1][k*8 +: 8]=value;
        end
    end endgenerate
    always @(posedge clk or negedge rst_n)
        if (!rst_n) valid_pipe<=0;
        else if (ce) valid_pipe<={valid_pipe[7:0],in_valid};
    assign out_valid=valid_pipe[8];
    // RAM can contain unknown data in incomplete windows; never expose it.
    assign median_gray=out_valid ? lane[9][4*8 +: 8] : 8'd0;
endmodule
