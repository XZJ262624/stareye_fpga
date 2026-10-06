`timescale 1ns/1ps
module tb_controls;
reg clk=0;always #5 clk=~clk;
reg rst=0;reg[1:0] keys=3;reg sof=0;
wire[7:0] threshold,pending;wire[1:0] mode,pm;
m31_controls #(.DEBOUNCE_CYCLES(4)) dut(clk,rst,keys,sof,threshold,mode,pending,pm);
integer checks=0,i;
task tick;input integer n;begin repeat(n)begin @(posedge clk);#1;end end endtask
task ck;input bit ok;input[511:0] msg;begin checks=checks+1;if(!ok)$fatal(1,"CONTROL_FAIL %s",msg);end endtask
task key;input[1:0] k;input integer n;begin @(negedge clk);keys=k;tick(n);end endtask
task frame;begin @(negedge clk);sof=1;tick(1);@(negedge clk);sof=0;tick(1);end endtask
task gesture;input[1:0] k;begin key(k,12);key(3,12);end endtask
initial begin
 tick(3);rst=1;tick(20);ck(threshold==64 && mode==2 && pending==64,"defaults");
 key(2,3);key(3,15);ck(pending==64,"short pulse rejected");
 key(2,2);key(3,2);key(2,2);key(3,12);ck(pending==64,"bounce rejected");
 key(2,30);ck(pending==64,"press and long hold no event");key(3,12);ck(pending==80 && threshold==64,"release pending only");
 tick(50);ck(pending==80,"no repeat");frame();ck(threshold==80,"SOF commit");
 gesture(2);gesture(2);ck(pending==112 && threshold==80,"multiple events pending");frame();ck(threshold==112,"latest pending");
 gesture(1);ck(pending==96,"decrement");
 for(i=0;i<20;i=i+1)gesture(2);ck(pending==255,"upper saturation");gesture(2);ck(pending==255,"no wrap up");
 for(i=0;i<20;i=i+1)gesture(1);ck(pending==0,"lower saturation");gesture(1);ck(pending==0,"no wrap down");
 gesture(2);ck(pending==16,"leave zero");
 gesture(0);ck(pm==0 && pending==16,"dual raw");gesture(0);ck(pm==1,"dual magnitude");gesture(0);ck(pm==2,"dual binary");
 key(2,12);key(0,12);key(1,12);key(3,12);ck(pm==0 && pending==16,"overlap release order");
 key(1,12);key(0,12);key(2,12);key(3,12);ck(pm==1 && pending==16,"reverse overlap");
 // SOF exactly on release-event edge must capture old pending.
 key(2,12);@(negedge clk);keys=3;
 wait(dut.stable_n==3);@(negedge clk);sof=1;tick(1);
 ck(pending==32 && threshold==16,"same-edge event deferred");@(negedge clk);sof=0;frame();ck(threshold==32,"deferred event next SOF");
 // Reset while held: ignore startup press until complete release qualification.
 @(negedge clk);rst=0;keys=0;tick(3);rst=1;tick(30);key(3,20);
 ck(pending==64 && pm==2,"startup held ignored");gesture(2);ck(pending==80,"armed after release");
 @(negedge clk);rst=0;tick(2);rst=1;tick(20);ck(threshold==64 && mode==2,"reset restores defaults");
 $display("M31_CONTROLS_PASS checks=%0d",checks);$finish;
end
initial begin #2000000;$fatal(1,"TIMEOUT");end
endmodule
