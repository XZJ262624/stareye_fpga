`timescale 1ns/1ps
module tb_m5a_realtime;
reg test_pass=0;
reg clk=0;always #6.720430108 clk=~clk;
reg rst=0;reg[1:0] keys=3;reg sof=0;wire[7:0] t,p;wire[2:0] m,pm;
m5a_controls dut(clk,1'b1,rst,keys,sof,t,m,p,pm);
integer n;
initial begin
 repeat(3)@(negedge clk);rst=1;
 wait(dut.armed);@(negedge clk);keys=2;
 wait(dut.key_sync==2);
 for(n=1;n<1488000;n=n+1)begin @(posedge clk);#1;if(dut.stable_n!==3)$fatal(1,"EARLY_DEBOUNCE %0d",n);end
 @(posedge clk);#1;if(dut.stable_n!==2)$fatal(1,"LATE_DEBOUNCE");
 repeat(50)@(negedge clk);if(p!==64)$fatal(1,"HOLD_EVENT");keys=3;
 wait(dut.stable_n==3);@(posedge clk);#1;if(p!==80 || t!==64)$fatal(1,"REALTIME_RELEASE");
 test_pass=1;$display("M5A_REALTIME_PASS debounce_cycles=1488000 pixel_hz=74400000");$finish;
end
initial begin #100000000;$fatal(1,"REALTIME_TIMEOUT");end
endmodule
