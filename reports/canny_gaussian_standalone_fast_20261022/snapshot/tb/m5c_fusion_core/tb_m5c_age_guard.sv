`timescale 1ns/1ps
module tb_m5c_age_guard;
 reg clk=0;always #5 clk=~clk;
 reg rst_n=0,ce=1,display_sof=0,stop=0,enable=0,descriptor_valid=0,age_valid=0;
 reg [63:0] current_epoch=1,descriptor_epoch=1,capture_seq=0,capture_tick=0;
 reg [159:0] current_config=160'h1000000000000000000000001,descriptor_config=160'h1000000000000000000000001;
 wire [63:0] pixel_ticks,display_seq;wire time_fault,eligible;wire [31:0] age_frames,age_ticks;
 m5c_age_guard dut(.*);
 integer checks=0,k;reg [63:0] before_tick;
 task check(input bit expected);begin #1;checks=checks+1;if(eligible!==expected)$fatal(1,"AGE_ELIGIBILITY check=%0d seq=%0d tick=%0d got=%b",checks,display_seq,pixel_ticks,eligible);end endtask
 initial begin
  #2;check(0);@(negedge clk);rst_n=1;enable=1;descriptor_valid=1;age_valid=1;check(1);
  for(k=119;k<=121;k=k+1)begin @(negedge clk);dut.display_seq=k;dut.pixel_ticks=100;check(k<=120);end
  for(k=0;k<3;k=k+1)begin @(negedge clk);dut.display_seq=1;dut.pixel_ticks=148499999+k;check(k<2);end
  @(negedge clk);dut.display_seq=0;dut.pixel_ticks=0;capture_seq=1;check(0);
  @(negedge clk);capture_seq=0;capture_tick=100;check(0);
  @(negedge clk);capture_tick=0;dut.pixel_ticks=500;descriptor_epoch=2;check(0);
  @(negedge clk);descriptor_epoch=1;current_config[159:96]=2;check(0);
  @(negedge clk);current_config[95:0]=descriptor_config[95:0];check(0); // A-B-A same H/L, newer generation
  @(negedge clk);current_config=descriptor_config;check(1);
  // Every config bit is significant: geometry/version/H/L/filter/support included.
  for(k=0;k<160;k=k+1)begin @(negedge clk);current_config=descriptor_config^(160'b1<<k);check(0);end
  @(negedge clk);current_config=descriptor_config;ce=0;before_tick=pixel_ticks;
  repeat(10)@(posedge clk);#1;if(pixel_ticks-before_tick!=10)$fatal(1,"CE_WALL_CLOCK");
  @(negedge clk);ce=1;dut.display_seq=120;display_sof=1;@(posedge clk);#1;check(0); // repeated source still expires
  repeat(4)@(posedge clk);#1;if(display_seq!=121)$fatal(1,"SOF_LEVEL_MULTIPLE_COUNT");
  @(negedge clk);display_sof=0;dut.display_seq=0;dut.pixel_ticks=1;stop=1;check(0);
  @(negedge clk);stop=0;age_valid=0;check(0);
  @(negedge clk);age_valid=1;dut.pixel_ticks=64'h100000001;#1;if(age_ticks!=32'hffffffff)$fatal(1,"AGE_SATURATION");
  @(negedge clk);dut.pixel_ticks=64'hffffffffffffffff;@(posedge clk);#1;if(!time_fault)$fatal(1,"CLOCK_WRAP_FAULT");check(0);
  $display("M5C_PASS age_guard checks=%0d inclusive_boundary=1 wall_clock=1",checks);$finish;
 end
 initial begin #100000;$fatal(1,"WATCHDOG");end
endmodule
