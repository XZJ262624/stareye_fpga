`timescale 1ns/1ps
module edge_threshold (
    input clk, input rst_n, input in_valid,
    input [7:0] in_gray, threshold,
    output reg out_valid, output reg [7:0] edge_gray,
    output reg edge_binary
);
    // Inclusive comparison: threshold 0 includes valid flat windows.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin out_valid<=0; edge_gray<=0; edge_binary<=0; end
        else begin
            out_valid <= in_valid;
            edge_gray <= in_valid ? in_gray : 8'd0;
            edge_binary <= in_valid && (in_gray >= threshold);
        end
    end
endmodule
