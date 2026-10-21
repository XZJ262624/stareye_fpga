// Cold-configuration-only recovery. No unproven DDR reset ACK is fabricated.
// 'started' is configuration initialized and deliberately has no PLL reset.
// PLL loss asynchronously sets the sticky failure latch even if UI stops.
// The only clearing interval is cold startup before the first calibration.
module m5b1_failstop(input ref_clk,input pll_locked,input cal_done,cal_pass,
 input protocol_fault,input fifo_fault,input domains_ready,
 output allow_run,output stop,output ddr_reset_ack,output [63:0] epoch);
 // Synchronizers must remain distinct FFs, never Titanium SRL8 resources.
 (* async_reg="true", syn_srlstyle="registers", syn_keep="true" *) reg [1:0] ds=0,ps=0,fs=0,rs=0;
 reg started=0,failed=0;reg [7:0] stable=0;
 always @(posedge ref_clk)begin
  ds<={ds[0],cal_done};ps<={ps[0],cal_pass};
  fs<={fs[0],protocol_fault||fifo_fault};rs<={rs[0],domains_ready};
  if(!started)begin
   if(pll_locked&&ds[1]&&ps[1]&&rs[1])begin
    if(stable==255)started<=1;else stable<=stable+1'b1;
   end else stable<=0;
  end
 end
 always @(posedge ref_clk or negedge pll_locked)begin
  if(!pll_locked)failed<=1;
  else if(!started)failed<=0;
  else if(fs[1]||!ds[1]||!ps[1]||!rs[1])failed<=1;
 end
 assign stop=failed || (started&&(!pll_locked||!cal_done||!cal_pass));
 assign allow_run=started&&!stop;
 assign ddr_reset_ack=1'b0;assign epoch=64'd1;
endmodule
