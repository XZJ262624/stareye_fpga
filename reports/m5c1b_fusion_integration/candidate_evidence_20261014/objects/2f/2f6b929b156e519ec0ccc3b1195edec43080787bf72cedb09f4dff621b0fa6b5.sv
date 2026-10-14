`timescale 1ns/1ps
module tb_controls_preflight;
 parameter WRONG_EDGE=0;
 reg clk=0,arst_n=0;always #5 clk=~clk;
 reg [1:0] key_n=3;reg [7:0] phase=0;integer cycles=0,sofs=0;
 wire sof=phase==255;wire ce=1'b1;wire fusion;wire [7:0] threshold,pending_threshold;wire [2:0] mode,pending_mode;wire [63:0] generation;
 reg [7:0] ext_high=64;reg [63:0] ext_gen=1;integer stage=0;reg wrong_applied=0;
 reg context_quiet=1,telemetry_busy=0;integer arms=0,b2=0,a3=0,b2_cycle=0,off_count=0,on_count=0;
 reg accepted_sof=0;reg [7:0] last_high=64;reg [63:0] last_gen=1;reg last_fusion=0;
 m5a_controls #(.DEBOUNCE_CYCLES(4),.LONG_CYCLES(64)) controls(.clk(clk),.ce(ce),.arst_n(arst_n),.key_n(key_n),.frame_start(sof),.threshold(threshold),.mode(mode),.pending_threshold(pending_threshold),.pending_mode(pending_mode),.fusion_enable(fusion),.config_generation(generation));
 always @(posedge clk)begin
  cycles<=cycles+1;phase<=phase+1;accepted_sof<=arst_n&&ce&&sof;
  if(arst_n&&ce&&sof)sofs<=sofs+1;
  if(arst_n&&stage==2&&WRONG_EDGE&&!wrong_applied&&!sof)begin ext_high<=80;ext_gen<=2;wrong_applied<=1;end
  if(arst_n&&ce&&sof)begin
   if(stage==2&&controls.pending_fusion)begin
    if(fusion||!context_quiet||!telemetry_busy)$fatal(1,"ABA_PREFLIGHT_B2_PRECONDITIONS");
    ext_high<=80;ext_gen<=2;stage<=3;b2_cycle<=cycles;b2<=b2+1;
   end else if(stage==3)begin
    if(!fusion||ext_high!=80||ext_gen!=2||cycles-b2_cycle!=256)$fatal(1,"ABA_PREFLIGHT_B2_NOT_FULL_FRAME");
    ext_high<=64;ext_gen<=3;stage<=4;a3<=a3+1;
   end
  end
 end
 always @(negedge clk)if(arst_n)begin
  if((ext_high!=last_high||ext_gen!=last_gen)&&!accepted_sof)$fatal(1,"ABA_PREFLIGHT_WRONG_CONFIG_EDGE");
  if(fusion!=last_fusion)begin
   if(!accepted_sof)$fatal(1,"ABA_PREFLIGHT_WRONG_ENABLE_EDGE");
   if(fusion)on_count=on_count+1;else off_count=off_count+1;
   $display("CONTROL_EDGE cycle=%0d sof=%b enable=%b H=%0d gen=%0d busy=%b quiet=%b",cycles,accepted_sof,fusion,ext_high,ext_gen,telemetry_busy,context_quiet);
  end
  if(stage==3&&(ext_high!=80||ext_gen!=2||!fusion||!telemetry_busy||!context_quiet))$fatal(1,"ABA_PREFLIGHT_B2_COHERENCE");
  if(stage==4&&(ext_high!=64||ext_gen!=3||!fusion))$fatal(1,"ABA_PREFLIGHT_A3_COHERENCE");
  last_high=ext_high;last_gen=ext_gen;last_fusion=fusion;
 end
 task long_release;
 begin @(negedge clk);key_n=0;repeat(100)@(negedge clk);key_n=3;repeat(20)@(negedge clk);end
 endtask
 initial begin
  repeat(4)@(negedge clk);arst_n=1;wait(controls.armed);long_release;wait(fusion);long_release;wait(!fusion);
  repeat(16)@(negedge clk);
  if(fusion||telemetry_busy||!context_quiet)$fatal(1,"ABA_PREFLIGHT_ARM_NOT_FULL_QUIET");
  arms=arms+1;stage=2;$display("ARM_FULL_QUIET cycle=%0d H=%0d gen=%0d",cycles,ext_high,ext_gen);
  @(negedge clk);telemetry_busy=1;long_release;wait(stage==4);repeat(2)@(negedge clk);
  if(arms!=1||off_count!=1||on_count!=2||b2!=1||a3!=1||!telemetry_busy||cycles>=20000)$fatal(1,"ABA_PREFLIGHT_EVENT_COUNTS");
  $display("PASS_CONTROLS_PREFLIGHT_ONLY cycles=%0d OFF=%0d ON=%0d ARM=%0d B2=%0d A3=%0d telemetry_BUSY_at_B2=1 context_QUIET=1",cycles,off_count,on_count,arms,b2,a3);$finish;
 end
 initial begin #200000;$fatal(1,"ABA_PREFLIGHT_BOUNDED_TIMEOUT");end
endmodule
