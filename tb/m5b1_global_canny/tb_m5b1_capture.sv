`timescale 1ns/1ps
module tb_m5b1_capture;
 reg ui=0,pix=0,rst=0,arm=0,cancel=0,tap_valid=0,take=0;
 always #5.20833 ui=~ui;initial begin #2.43;forever #6.72043 pix=~pix;end
 reg [63:0] epoch=1,job=0,tap_epoch=1;reg [11:0] x=0,y=0;reg [1:0] cls=0;
 wire arm_busy,empty,dvalid,dropped;wire [127:0] data;wire [9:0] count;wire [319:0] desc;
 wire [1:0] ready,faults;wire [13:0] lo,hi;wire pop=!empty;
 m5b1_capture #(.WIDTH(128),.HEIGHT(32)) dut(.ui_clk(ui),.pix_clk(pix),.arst_n(rst),.cancel(cancel),.arm(arm),.job(job),.epoch(epoch),.arm_busy(arm_busy),
 .tap_valid(tap_valid),.tap_class(cls),.tap_x(x),.tap_y(y),.tap_high(8'd64),.tap_low(8'd32),.tap_filter(1'b1),.tap_frame_id(64'd77),.tap_epoch(tap_epoch),.tap_timestamp(64'd12345),
 .data(data),.empty(empty),.pop(pop),.count(count),.descriptor_valid(dvalid),.descriptor(desc),.descriptor_take(take),.reset_done(ready),.dropped(dropped),.fifo_min_bytes(lo),.fifo_max_bytes(hi),.fifo_faults(faults));
 integer records=0,mode=0,i,j;reg [127:0] want;
 function [1:0] golden(input integer p);begin golden=(p%17==0)?2:((p%7<3)?1:0);end endfunction
 always @(posedge ui)if(rst&&pop)begin
  if(records==0)begin if(data!=={job,epoch})$fatal(1,"capture epoch header");end
  else if(mode==0)begin
   for(j=0;j<64;j=j+1)want[j*2+:2]=golden((records-1)*64+j);
   if(data!==want)$fatal(1,"capture packed ordering record=%0d",records);
  end
  records=records+1;
 end
 task begin_job;
 begin wait(!arm_busy&&!dvalid&&empty);@(negedge ui);records=0;job=job+1;arm=1;@(negedge ui);arm=0;wait(dut.arm_valid);end endtask
 task sample(input integer p);
 begin @(negedge pix);tap_valid=1;x=p%128;y=p/128;cls=golden(p);tap_epoch=epoch;
  if(mode==1&&p==100)tap_epoch=epoch-1;
  if(mode==2&&p==100)x=x+1;
  if(mode==3&&p==100)cls=3;
 end endtask
 task finish_job(input success);
 begin
  @(negedge pix);tap_valid=0;wait(dvalid);repeat(10)@(negedge ui);
  if(desc[308]!==success||desc[63:0]!=epoch||desc[191:128]!=job)$fatal(1,"capture descriptor identity/status mode=%0d",mode);
  if(success&&(records!=65||desc[127:64]!=77||desc[295:284]!=128||desc[307:296]!=32))$fatal(1,"capture complete coverage");
  take=1;@(negedge ui);take=0;cancel=0;repeat(10)@(negedge ui);
 end endtask
 initial begin
  #21.29;rst=1;wait(&ready);
  for(mode=0;mode<4;mode=mode+1)begin begin_job();for(i=0;i<4096;i=i+1)sample(i);finish_job(mode==0);end
  mode=4;begin_job();cancel=1;finish_job(0); // cancel pending arm before SOF
  mode=5;begin_job();for(i=0;i<130;i=i+1)sample(i);cancel=1;finish_job(0);
  // A cold reset cancels an active epoch without letting its records escape.
  mode=6;begin_job();for(i=0;i<30;i=i+1)sample(i);
  #1.17;rst=0;tap_valid=0;#31.51;epoch=2;records=0;rst=1;wait(&ready);repeat(12)@(negedge ui);
  if(!empty||dvalid)$fatal(1,"old epoch survived capture reset");
  mode=0;begin_job();for(i=0;i<4096;i=i+1)sample(i);finish_job(1);
  if(faults)$fatal(1,"capture FIFO fault");
  $display("M5B1_CAPTURE_PASS healthy_frames=2 failures=5 cold_epoch_flush=1");$finish;
 end
 initial begin #1000000;$fatal(1,"capture watchdog");end
endmodule
