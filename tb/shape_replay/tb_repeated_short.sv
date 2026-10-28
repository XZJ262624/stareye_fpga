`timescale 1ns/1ps
module tb_repeated_short;
 reg clk=0,rst=0;always #5 clk=~clk;reg [1:0] keys=3;
 wire cv;wire [1:0] command,view_index;integer shorts=0,longs=0,j;reg boundary_seen=0;
 shape_replay_controls #(.DEBOUNCE(5),.LONG_PRESS(60)) dut(.clk(clk),.rst_n(rst),.key_n(keys),.command_valid(cv),.command(command),.view_index(view_index));
 always @(posedge clk)if(cv)begin
  $display("COMMAND value=%0d held=%0d time=%0t",command,dut.held[0],$time);
  if(command==0)shorts=shorts+1;else longs=longs+1;
 end
 always @(posedge clk)if(rst&&dut.key_sync[0]&&!dut.stable[0]&&dut.debounce[0]==4&&dut.held[0]==59)boundary_seen=1;
 task waitn(input integer c);repeat(c)@(negedge clk);endtask
 initial begin
  waitn(4);rst=1;waitn(30);
  for(j=0;j<5;j=j+1)begin keys=2;waitn(20);keys=3;waitn(25);$display("SHORT_STEP n=%0d held=%0d short=%0d long=%0d",j+1,dut.held[0],shorts,longs);end
  if(shorts!=5||longs!=0)$fatal(1,"consecutive short presses accumulated held time");
  for(j=0;j<5;j=j+1)begin keys=1;waitn(20);keys=3;waitn(25);if(view_index!=j%3||longs!=0||shorts!=5)$fatal(1,"view short sequence");end
  if(view_index!=1||longs!=0)$fatal(1,"view shorts accumulated held time");
  keys=2;waitn(100);keys=3;waitn(25);if(longs!=1||shorts!=5)$fatal;
  keys=2;waitn(20);keys=3;waitn(25);if(longs!=1||shorts!=6)$fatal;
  keys=2;waitn(20);keys=3;waitn(25);if(longs!=1||shorts!=7)$fatal;
  keys=2;waitn(100);keys=3;waitn(25);if(longs!=2||shorts!=7)$fatal;
  keys=2;waitn(20);keys=3;waitn(25);if(longs!=2||shorts!=8)$fatal;
  keys=2;wait(dut.held[0]==53);@(negedge clk);keys=3;waitn(25);
  if(!boundary_seen||longs!=2||shorts!=9||dut.held[0]!=0)$fatal(1,"accepted release lost priority at long threshold");
  $display("REPEATED_SHORT_PASS k1short=9 k2short=5 long=2 release_threshold_priority=1");$finish;
 end
endmodule
