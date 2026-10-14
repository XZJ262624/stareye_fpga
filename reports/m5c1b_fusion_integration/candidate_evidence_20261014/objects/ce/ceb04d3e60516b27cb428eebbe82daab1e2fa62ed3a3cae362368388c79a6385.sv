`timescale 1ns/1ps
module guard_background;reg [31:0] tick=0;endmodule
module guard_dut;guard_background background();endmodule
module tb_guard_lifecycle;
 parameter CASE=0;localparam BG_REQUEST_CYCLES=96000000;
 reg [767:0] real_a1_descriptor=0;reg [63:0] epoch=1,display_seq=20,pixel_ticks=2000;integer aba_rejects=0;
 guard_dut dut();
 task aba_check_ttl;
 begin
  if(real_a1_descriptor[63:0]!=epoch||real_a1_descriptor[383:320]>display_seq||real_a1_descriptor[575:512]>pixel_ticks||display_seq-real_a1_descriptor[383:320]>120||pixel_ticks-real_a1_descriptor[575:512]>148500000)$fatal(1,"ABA_REAL_A1_TTL");
 end endtask
 task aba_check_initial_margin;
 begin
  if(dut.background.tick>BG_REQUEST_CYCLES-8000000)$fatal(1,"ABA_NATURAL_WINDOW_TOO_SHORT");
 end endtask
 task reject_old;
 begin
  aba_check_ttl;if(aba_rejects==0)aba_check_initial_margin;
  aba_rejects=aba_rejects+1;
  $display("GUARD_REJECTION case=%0d count=%0d tick=%0d frame_age=%0d",CASE,aba_rejects,dut.background.tick,display_seq-real_a1_descriptor[383:320]);
 end endtask
 initial begin
  real_a1_descriptor[63:0]=1;real_a1_descriptor[383:320]=10;real_a1_descriptor[575:512]=1000;
  dut.background.tick=40000000;
  // ARM/B2/A3 always retain both checks.
  repeat(3)begin aba_check_ttl;aba_check_initial_margin;end
  if(CASE==1)dut.background.tick=90000000;
  #1;reject_old;
  dut.background.tick=90000000;
  if(CASE==2)display_seq=131;
  #1;reject_old;
  if(CASE!=0||aba_rejects!=2)$fatal(1,"GUARD_EXPECTED_FAILURE_MISSING");
  $display("PASS_GUARD_LIFECYCLE_ONLY timelyfirst_laterrepeat_TTLretained");$finish;
 end
 initial begin #100;$fatal(1,"GUARD_PREFLIGHT_TIMEOUT");end
endmodule
