`timescale 1ns/1ps
// Exact5120 logical entries. Five1024 banks avoid the8192x1 inference mode.
// Each bank read and its selector register advance on the same CE edge.
// The output mux adds no register. Nonblocking writes preserve old-value collision semantics.
module part_open_bank_ram #(parameter WIDTH=32,DEPTH=5120)(
 input clk,ce,input [12:0] read_address,write_address,input write_enable,
 input [WIDTH-1:0] write_data,output [WIDTH-1:0] read_data
);
 wire [WIDTH-1:0] bank_q[0:4];reg [2:0] selected_bank;
 always @(posedge clk)if(ce)selected_bank<=read_address[12:10];
 genvar b;
 generate for(b=0;b<5;b=b+1)begin:bank
  (* syn_ramstyle="block_ram" *) reg [WIDTH-1:0] memory[0:1023];reg [WIDTH-1:0] q;
  always @(posedge clk)if(ce)begin
   q<=memory[read_address[9:0]];
   if(write_enable&&write_address[12:10]==b)memory[write_address[9:0]]<=write_data;
  end
  assign bank_q[b]=q;
 end endgenerate
 // Invalid banks never alias bank0. All-one parent IDs are out of the valid root range.
 assign read_data=selected_bank<5?bank_q[selected_bank]:{WIDTH{1'b1}};
 // synthesis translate_off
 initial if(DEPTH!=5120)$fatal(1,"EDGE_BANK_DEPTH_CONTRACT");
 always @(posedge clk)if(ce)begin
  if(read_address>=DEPTH)$fatal(1,"EDGE_BANK_READ_ADDRESS");
  if(write_enable&&write_address>=DEPTH)$fatal(1,"EDGE_BANK_WRITE_ADDRESS");
 end
 function [WIDTH-1:0] peek(input [12:0] a);begin
  case(a[12:10])0:peek=bank[0].memory[a[9:0]];1:peek=bank[1].memory[a[9:0]];2:peek=bank[2].memory[a[9:0]];3:peek=bank[3].memory[a[9:0]];4:peek=bank[4].memory[a[9:0]];default:peek={WIDTH{1'b1}};endcase
 end endfunction
 // synthesis translate_on
endmodule
