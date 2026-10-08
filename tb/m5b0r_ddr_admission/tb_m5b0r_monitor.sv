`timescale 1ns/1ps
module tb_m5b0r_monitor;
 reg refclk=0;always #20 refclk=~refclk;
 reg [5:0] locked=0,ui_heartbeat=0,cal_done=0,cal_pass=0,alias_pass=0,range_pass=0,controller_reset_request=0;
 reg [3:0] status[0:5];wire [5:0] reference_timeout;wire [5:0] leds[0:5];
 reg [31:0] cycle=0;integer i;
 localparam [363:0] PAYLOAD={32'h12345678,32'habcdef01,128'h0123456789abcdefdeadbeef76543210,128'hffeeddccbbaa99887766554433221100,32'h010e6ff0,4'h7,8'h05};
 genvar g;generate for(g=0;g<6;g=g+1)begin:mon
  m5b0r_monitor #(.WAIT_LIMIT(100),.DEAD_LIMIT(20),.TOTAL_LIMIT(1000),.LED_DIV(2)) dut(
   .refclk(refclk),.locked(locked[g]),.ui_heartbeat(ui_heartbeat[g]),.cal_done(cal_done[g]),.cal_pass(cal_pass[g]),
   .alias_pass(alias_pass[g]),.range_pass(range_pass[g]),.controller_reset_request(controller_reset_request[g]),.status(status[g]),
   .failure_stage(8'h05),.reason(4'h7),.failure_address(32'h010e6ff0),
   .expected(128'hffeeddccbbaa99887766554433221100),.actual(128'h0123456789abcdefdeadbeef76543210),
   .transaction_count(32'habcdef01),.beat_count(32'h12345678),.reference_timeout(reference_timeout[g]),.led_o(leds[g]));
 end endgenerate
 always @(negedge refclk)begin
  cycle=cycle+1;
  for(i=1;i<6;i=i+1)if(!(i==1&&cycle>15))ui_heartbeat[i]=~ui_heartbeat[i];
 end
 integer pos=0,decode=0;reg prior=0;reg [363:0] observed=0;reg [5:0] lights;
 always @(negedge refclk)begin
  lights=~leds[4];
  if(lights[0]&&!prior&&mon[4].dut.captured)begin
   if(lights[1]&&lights[5:2]==4'ha)begin decode=1;pos=0;end
   else if(decode==1&&lights[1]&&lights[5:2]==5)decode=2;
   else if(decode==2&&!lights[1])begin
    observed[pos*4+:4]=lights[5:2];pos=pos+1;
    if(pos==91)begin
     if(observed!==PAYLOAD)$fatal(1,"LED payload corruption");
     if(reference_timeout[4])$fatal(1,"monitor masked transaction fault");
     if(!reference_timeout[0]||!reference_timeout[1]||!reference_timeout[2]||!reference_timeout[3])$fatal(1,"missing oscillator timeout");
     if(mon[0].dut.monitor_reason!=3||mon[1].dut.monitor_reason!=4||mon[2].dut.monitor_reason!=3||mon[3].dut.monitor_reason!=1)$fatal(1,"wrong oscillator timeout reason");
     if(!mon[5].dut.captured||reference_timeout[5])$fatal(1,"calibration FAIL telemetry lost");
     $display("M5B0R_MONITOR_PASS cases=6 decoded_nibbles=91 cycles=%0d",cycle);$finish;
    end
   end
  end
  prior=lights[0];
 end
 initial begin
  for(i=0;i<6;i=i+1)status[i]=1;
  repeat(3)@(negedge refclk);locked=6'b111110;cal_done=6'b111010;cal_pass=6'b111010;
  status[3]=6;alias_pass[3]=1;range_pass[3]=1;
  repeat(10)@(negedge refclk);locked[3]=0;
  // Error event and calibration fall arrive together; stable payload wins.
  status[4]=7;controller_reset_request[4]=1;cal_done[4]=0;cal_pass[4]=0;
  status[5]=3;controller_reset_request[5]=1;cal_pass[5]=0;
  repeat(1100)@(negedge refclk);$fatal(1,"monitor test watchdog");
 end
endmodule
