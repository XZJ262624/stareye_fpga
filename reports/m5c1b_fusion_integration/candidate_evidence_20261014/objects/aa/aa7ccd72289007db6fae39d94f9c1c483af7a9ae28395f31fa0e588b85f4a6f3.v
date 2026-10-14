`timescale 1ns/1ps
// Explicit sign extension happens BEFORE subtraction/shift. Gradient: 11 bits.
module sobel_3x3 (
    input clk, input rst_n, input in_valid,
    input [7:0] p00,p01,p02,p10,p11,p12,p20,p21,p22,
    output reg gradient_valid,
    output reg signed [10:0] gx, gy,
    output reg out_valid,
    output reg [10:0] abs_gx, abs_gy,
    output reg [11:0] magnitude,
    output reg [7:0] edge_gray
);
    wire signed [10:0] a00=$signed({3'b000,p00});
    wire signed [10:0] a01=$signed({3'b000,p01});
    wire signed [10:0] a02=$signed({3'b000,p02});
    wire signed [10:0] a10=$signed({3'b000,p10});
    wire signed [10:0] a12=$signed({3'b000,p12});
    wire signed [10:0] a20=$signed({3'b000,p20});
    wire signed [10:0] a21=$signed({3'b000,p21});
    wire signed [10:0] a22=$signed({3'b000,p22});
    wire [10:0] ax = gx[10] ? $unsigned(-gx) : $unsigned(gx);
    wire [10:0] ay = gy[10] ? $unsigned(-gy) : $unsigned(gy);
    wire [11:0] sum = {1'b0,ax} + {1'b0,ay};
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gradient_valid<=0; gx<=0; gy<=0; out_valid<=0;
            abs_gx<=0; abs_gy<=0; magnitude<=0; edge_gray<=0;
        end else begin
            gradient_valid <= in_valid;
            gx <= (a02-a00) + ((a12-a10) <<< 1) + (a22-a20);
            gy <= (a00-a20) + ((a01-a21) <<< 1) + (a02-a22);
            out_valid <= gradient_valid;
            abs_gx <= ax; abs_gy <= ay; magnitude <= sum;
            edge_gray <= (sum > 12'd255) ? 8'hff : sum[7:0];
        end
    end
endmodule
