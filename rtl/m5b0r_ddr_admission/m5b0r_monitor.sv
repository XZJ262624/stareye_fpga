// Independent oscillator domain; continues diagnosing a stopped DDR/UI clock.
module m5b0r_monitor #(
 parameter integer WAIT_LIMIT=240000000,
 parameter integer DEAD_LIMIT=2400000,
 parameter integer TOTAL_LIMIT=720000000,
 parameter integer LED_DIV=6000000
)(input refclk,input locked,input ui_heartbeat,
 input cal_done,input cal_pass,input alias_pass,input range_pass,input controller_reset_request,
 input [3:0] status,input [7:0] failure_stage,input [3:0] reason,
 input [31:0] failure_address,input [127:0] expected,actual,
 input [31:0] transaction_count,beat_count,
 output reference_timeout,output [5:0] led_o);
 reg timeout_latched=0;
 assign reference_timeout=timeout_latched;
 (* async_reg="true" *)reg [1:0] lock_sync=0,hb_sync=0,done_sync=0,pass_sync=0,alias_sync=0,range_sync=0,good_sync=0,fail_sync=0;
 reg last_hb=0,seen_lock=0,seen_cal=0;
 reg [31:0] wait_count=0,dead_count=0,total_count=0,led_count=0;
 reg [3:0] monitor_reason=0;
 reg blink=0;reg [6:0] nibble=0;
 reg [2:0] capture_delay=0;
 reg captured=0;
 reg [363:0] telemetry=0;
 reg [5:0] lamps;
 // UI failure payload becomes immutable before fail_sync reaches this domain.
 // An additional three refclk periods precede one atomic capture of the bus.
 always @(posedge refclk) begin
  lock_sync<={lock_sync[0],locked};hb_sync<={hb_sync[0],ui_heartbeat};
  done_sync<={done_sync[0],cal_done};pass_sync<={pass_sync[0],cal_pass};
  alias_sync<={alias_sync[0],alias_pass};range_sync<={range_sync[0],range_pass};
  good_sync<={good_sync[0],status==6};fail_sync<={fail_sync[0],controller_reset_request};
  if(led_count==LED_DIV-1)begin
   led_count<=0;blink<=~blink;
   if(blink)nibble <= nibble==7'd92 ? 7'd0 : nibble+7'd1;
  end else led_count<=led_count+1'b1;
  if(!reference_timeout&&!captured)begin
   if(!good_sync[1])total_count<=total_count+1'b1;
   if(lock_sync[1])seen_lock<=1;
   if(done_sync[1]&&pass_sync[1])seen_cal<=1;
   if(!lock_sync[1]||hb_sync[1]!=last_hb)begin dead_count<=0;last_hb<=hb_sync[1];end
   else if(dead_count<DEAD_LIMIT)dead_count<=dead_count+1'b1;
   if(!lock_sync[1]||!done_sync[1])wait_count<=wait_count+1'b1;
   else wait_count<=0;
   if(seen_lock&&!lock_sync[1])begin timeout_latched<=1;monitor_reason<=1;end
   else if(seen_cal&&(!done_sync[1]||!pass_sync[1])&&!fail_sync[1])begin timeout_latched<=1;monitor_reason<=2;end
   else if(wait_count>=WAIT_LIMIT-1)begin timeout_latched<=1;monitor_reason<=3;end
   else if(seen_lock&&dead_count>=DEAD_LIMIT-1)begin timeout_latched<=1;monitor_reason<=4;end
   else if(!good_sync[1]&&total_count>=TOTAL_LIMIT-1)begin timeout_latched<=1;monitor_reason<=5;end
   if(fail_sync[1])begin
    if(capture_delay==3)begin
     telemetry<={beat_count,transaction_count,actual,expected,failure_address,reason,failure_stage};
     captured<=1;
    end else capture_delay<=capture_delay+1'b1;
   end else capture_delay<=0;
  end
 end
 always @* begin
  lamps={good_sync[1]&&lock_sync[1]&&done_sync[1]&&pass_sync[1],range_sync[1],alias_sync[1],pass_sync[1],done_sync[1],blink};
  if(reference_timeout)lamps={monitor_reason,1'b1,blink};
  else if(captured)begin
   if(nibble==0)lamps={4'ha,1'b1,blink};
   else if(nibble==1)lamps={4'h5,1'b1,blink};
   else lamps={telemetry[(nibble-2)*4+:4],1'b0,blink};
  end
 end
 assign led_o=~lamps; // M0-proven low-active LEDs 0..5 only.
endmodule
