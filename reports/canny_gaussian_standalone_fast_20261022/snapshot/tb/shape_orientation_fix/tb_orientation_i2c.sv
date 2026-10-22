`timescale 1ns/1ps
module tb_orientation_i2c;
reg clk=0,rst_n=0;
always #5.208333 clk=~clk;
wire scl,sdo,oe;tri1 sda;reg slave_low=0;
assign sda=oe?sdo:1'bz;
assign sda=slave_low?1'b0:1'bz;
wire [7:0] idx,size;wire [31:0] data;wire done;wire [15:0] rdata;
I2C_AR0135_1280720_Config lut(idx,data,size);
i2c_timing_ctrl_reg16_dat16 #(.SIMU_EN(0),.I2C_READ_EN(1),.CLK_FREQ(96000000),.I2C_FREQ(50000)) dut
 (.clk(clk),.rst_n(rst_n),.i2c_sclk(scl),.i2c_sdat_o(sdo),.i2c_sdat_oe(oe),.i2c_sdat_i(sda),
  .i2c_config_size(size),.i2c_config_index(idx),.i2c_config_data({8'h20,data}),.i2c_config_done(done),.i2c_rdata(rdata));
reg [7:0] inspect_idx=0;wire [31:0] reference_data,inspect_data;wire [7:0] reference_size,inspect_size;
reference_lut reference_table(inspect_idx,reference_data,reference_size);
I2C_AR0135_1280720_Config inspect_table(inspect_idx,inspect_data,inspect_size);
reg [31:0] expected[0:255];integer i,changes=0,transactions=0,orientation_writes=0;
reg [7:0] b0,b1,b2,b3,b4;
task start_condition;begin @(negedge sda);while(scl!==1'b1) @(negedge sda);end endtask
task stop_condition;begin @(posedge sda);while(scl!==1'b1) @(posedge sda);end endtask
task receive_byte(output reg [7:0] b);integer j;begin
 for(j=7;j>=0;j=j-1)begin @(posedge scl);b[j]=sda;end
 @(negedge scl);slave_low=1;@(posedge scl);@(negedge scl);slave_low=0;
end endtask
task send_byte(input reg [7:0] b,input reg ack_expected);integer j;begin
 for(j=7;j>=0;j=j-1)begin slave_low=~b[j];@(posedge scl);@(negedge scl);end
 slave_low=0;@(posedge scl);if(sda!==ack_expected)$fatal(1,"READ_ACK_ERROR");@(negedge scl);
end endtask
initial begin
 for(i=0;i<256;i=i+1)begin
  inspect_idx=i;#20;expected[i]=reference_data;
  if(inspect_size!==24 || reference_size!==24)$fatal(1,"SIZE_CHANGED");
  if(inspect_data!==reference_data)begin changes=changes+1;
   if(i!=18 || reference_data!==32'h30408000 || inspect_data!==32'h3040C000)$fatal(1,"UNEXPECTED_LUT_CHANGE");
  end
 end
 if(changes!=1 && !$test$plusargs("SERIAL_NEGATIVE"))$fatal(1,"ORIENTATION_DELTA_MISSING count=%0d",changes);
 expected[18]=32'h3040C000;
 if(changes==1)$display("PASS_TABLE_ENUMERATION 256 entries, one XOR4000 at index18, size24");
 #50;rst_n=1;
end
initial begin
 wait(rst_n);
 start_condition;receive_byte(b0);receive_byte(b1);receive_byte(b2);
 if({b0,b1,b2}!==24'h203000)$fatal(1,"CHIP_READ_ADDRESS");stop_condition;
 start_condition;receive_byte(b0);if(b0!==8'h21)$fatal(1,"CHIP_READ_DEVICE");
 // ACK phase has ended at SCL falling edge; model only electrical ID reply,
 // not sensor orientation semantics or proof of the user's actual chip ID.
 send_byte(8'h07,0);send_byte(8'h54,1);stop_condition;
 for(i=1;i<24;i=i+1)begin
  start_condition;receive_byte(b0);receive_byte(b1);receive_byte(b2);receive_byte(b3);receive_byte(b4);
  if(b0!==8'h20 || {b1,b2,b3,b4}!==expected[i])$fatal(1,"SERIAL_WRITE_MISMATCH index=%0d got=%h expected=%h",i,{b0,b1,b2,b3,b4},{8'h20,expected[i]});
  if({b1,b2}==16'h3040)begin orientation_writes=orientation_writes+1;if({b3,b4}!==16'hC000)$fatal(1,"MIRROR_WRITE_MISSING");end
  $display("SERIAL_WRITE index=%0d address=%h data=%h",i,{b1,b2},{b3,b4});transactions=transactions+1;stop_condition;
 end
 wait(done);repeat(10000)@(posedge clk);
 if(transactions!=23 || orientation_writes!=1 || idx!==24 || rdata!==16'h0754)$fatal(1,"FINAL_COUNTS_OR_READBACK");
 $display("PASS_ORIENTATION_REAL_I2C writes=23 mirror_writes=1 SIMU_EN=0 divider=1920 readback_fixture=0754");$finish;
end
initial begin #40000000;$fatal(1,"TIMEOUT");end
endmodule
