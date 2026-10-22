`timescale 1ns/1ps
module tb_gaussian_controls;
 reg clk=0;always #5 clk=~clk;reg rst=0,ce=1,sof=0;reg[1:0] key=3;
 wire[7:0] t,pt,et;wire[2:0] m,pm,em;wire en,een;wire[63:0] g,eg;wire[1:0] ef;
 m5a_controls #(.DEBOUNCE_CYCLES(2),.LONG_CYCLES(20)) dut(.clk(clk),.ce(ce),.arst_n(rst),.key_n(key),.frame_start(sof),.threshold(t),.mode(m),.pending_threshold(pt),.pending_mode(pm),.fusion_enable(en),.config_generation(g),.effective_threshold(et),.effective_mode(em),.effective_fusion_enable(een),.effective_generation(eg),.effective_filter(ef));
 integer checks=0;
 task tick;begin @(posedge clk);#1;@(negedge clk);end endtask
 task commit(input[2:0] nm,input[7:0] nt,input bit nf,input[63:0] expectg,input[1:0] expectf);
 begin
  // Directed pending injection tests the SOF contract independently of debounce.
  dut.pending_mode=nm;dut.pending_threshold=nt;dut.pending_fusion=nf;sof=1;#1;
  if(em!==nm||et!==nt||een!==nf||eg!==expectg||ef!==expectf)$fatal(1,"GAUSS_EFFECTIVE_SOF_OLD_MODE");
  tick;sof=0;if(m!==nm||t!==nt||en!==nf||g!==expectg||ef!==expectf)$fatal(1,"GAUSS_ATOMIC_COMMIT");tick;checks=checks+1;
 end endtask
 initial begin
  repeat(4)tick;rst=1;repeat(15)tick;
  commit(3,64,0,0,1);commit(4,64,0,1,2);commit(5,64,1,1,2);commit(6,64,0,1,2);
  commit(0,64,0,2,1);commit(4,80,1,3,2);commit(3,96,0,4,1);
  // Paused CE cannot commit even with frame_start asserted.
  dut.pending_mode=4;dut.pending_threshold=64;sof=1;ce=0;repeat(3)tick;
  if(g!=4||m!=3||ef!=1)$fatal(1,"GAUSS_CE_COMMIT");ce=1;#1;if(eg!=5||ef!=2)$fatal(1,"GAUSS_RESUME_EFFECTIVE");tick;sof=0;tick;
  // Actual qualified release coincident with SOF: pre-edge pending wins.
  key=0;repeat(12)tick;key=3;
  wait(dut.stable_n==3&&dut.seen==3);@(negedge clk);sof=1;
  if(pm!=4||em!=4)$fatal(1,"GAUSS_RELEASE_SETUP");tick;sof=0;
  if(m!=4||pm!=5||g!=5)$fatal(1,"GAUSS_RELEASE_ONE_FRAME_DEFER");
  tick;sof=1;tick;sof=0;if(m!=5||g!=5)$fatal(1,"GAUSS_RELEASE_NEXT_FRAME");tick;
  // Controlled hierarchical injection, not 2^64 physically simulated frames.
  dut.config_generation=64'hfffffffffffffffe;
  commit(0,64,0,64'hffffffffffffffff,1);commit(4,80,1,64'hffffffffffffffff,2);commit(0,64,0,64'hffffffffffffffff,1);
  $display("PASS_GAUSSIAN_CONTROLS checks=%0d release_NBA=1 paused_CE=1 saturation_hierarchical_injection=1",checks);$finish;
 end
 initial begin #100000;$fatal(1,"GAUSS_CONTROL_WATCHDOG");end
endmodule
