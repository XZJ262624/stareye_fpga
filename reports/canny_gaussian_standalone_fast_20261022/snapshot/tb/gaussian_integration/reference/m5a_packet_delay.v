// M5A-only CE adaptation of committed rtl/m32_median_integration/raster_packet_delay.v.
`timescale 1ns/1ps
// CE-tick delay. Input sampled at n is returned immediately after n+DELAY CE ticks.
// DEPTH=DELAY+1 makes synchronous read and write addresses always different.
module reference_m5a_packet_delay #(parameter BITS=23, parameter DELAY=1661)(
    input clk,input ce, input rst_n, input [BITS-1:0] in_packet,
    output [BITS-1:0] out_packet, output reg out_ready
);
    localparam DEPTH=DELAY+1;
    localparam AW=$clog2(DEPTH);
    (* syn_ramstyle="block_ram" *) reg [BITS-1:0] storage[0:DEPTH-1];
    reg [BITS-1:0] read_data;
    reg [AW-1:0] write_address,fill_count;
    wire [AW:0] incremented_address={1'b0,write_address}+1'b1;
    wire [AW-1:0] read_address=(write_address==DEPTH-1)?{AW{1'b0}}:incremented_address[AW-1:0];
    // No memory/read-register reset: preserve synchronous BRAM inference.
    always @(posedge clk) if(rst_n && ce) begin
        storage[write_address]<=in_packet;
        read_data<=storage[read_address];
    end
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin write_address<=0;fill_count<=0;out_ready<=0;end
        else if (ce) begin
            write_address<=read_address;
            if(fill_count<DELAY) fill_count<=fill_count+1'b1;
            // Use the OLD count, matching this edge's registered RAM read.
            out_ready<=(fill_count==DELAY);
        end
    end
    assign out_packet=out_ready?read_data:{BITS{1'b0}};
    // synthesis translate_off
    initial if(DELAY<1) $fatal(1,"reference_m5a_packet_delay DELAY must be positive");
    always @(posedge clk) if(rst_n && write_address==read_address)
        $fatal(1,"M32_PACKET_RAM_COLLISION");
    // synthesis translate_on
endmodule
