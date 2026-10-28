`timescale 1ns/1ps
module tb_controls;
 reg clk=0,rst=0;always #5 clk=~clk;reg [1:0] keys=2;
 wire cv,edge_mode;wire [1:0] command;integer n=0,toggles=0;reg oldmode=0;
 replay_controls #(.DEBOUNCE(5),.LONG_PRESS(30)) dut(.clk(clk),.rst_n(rst),.key_n(keys),.command_valid(cv),.command(command),.edge_mode(edge_mode));
 integer commands[0:15];
 always @(posedge clk)begin if(cv)begin commands[n]=command;n=n+1;end if(edge_mode!=oldmode)begin toggles=toggles+1;oldmode=edge_mode;end end
 task waitn(input integer c);repeat(c)@(negedge clk);endtask
 initial begin
  waitn(4);rst=1;waitn(100);if(n||toggles)$fatal(1,"startup held key acted");
  keys=3;waitn(30);if(n)$fatal(1,"startup release acted");
  // Bounce shorter than debounce, followed by one clean short.
  keys=2;waitn(2);keys=3;waitn(2);keys=2;waitn(2);keys=3;waitn(12);if(n)$fatal;
  keys=2;waitn(16);keys=3;waitn(16);if(n!=1||commands[0]!=0)$fatal(1,"short");
  keys=2;waitn(80);keys=3;waitn(20);if(n!=2||commands[1]!=1)$fatal(1,"long emitted short or repeated");
  keys=1;waitn(16);keys=3;waitn(16);if(toggles!=1||n!=2)$fatal(1,"mode short");
  keys=1;waitn(80);keys=3;waitn(20);if(n!=3||commands[2]!=2||toggles!=1)$fatal(1,"mode long");
  keys=2;waitn(14);keys=0;waitn(40);keys=1;waitn(20);keys=3;waitn(20);
  if(n!=3||toggles!=1)$fatal(1,"chord leaked");
  keys=2;waitn(14);keys=3;waitn(20);if(n!=4)$fatal(1,"rearm after chord");
  $display("CONTROLS_PASS commands=%0d mode_toggles=%0d",n,toggles);$finish;
 end
endmodule
