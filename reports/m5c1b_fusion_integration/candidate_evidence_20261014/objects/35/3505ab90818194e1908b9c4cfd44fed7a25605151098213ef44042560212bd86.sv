`timescale 1ns/1ps
module tb_m5b1_cdc;
 reg wc=0,rc=0,halt_w=0,halt_r=0,rst_n=0;
 always #5 if(!halt_w)wc=~wc;
 initial begin #1.37;forever #6.72043 if(!halt_r)rc=~rc;end
 reg push=0,pop=0;reg [127:0] din=0;
 wire [127:0] dout;wire full,empty,wr,rr,over,under;wire [9:0] wcount,rcount;
 m5b1_async_fifo fifo(.wclk(wc),.rclk(rc),.arst_n(rst_n),.push(push),.wdata(din),.pop(pop),.rdata(dout),.full(full),.empty(empty),.wcount(wcount),.rcount(rcount),.wreset_done(wr),.rreset_done(rr),.overflow(over),.underflow(under));
 reg send=0,take=0;reg [127:0] mail=0;wire busy,valid;wire [127:0] received;
 m5b1_mailbox #(.WIDTH(128)) box(.sclk(wc),.dclk(rc),.arst_n(rst_n),.send(send),.sdata(mail),.busy(busy),.valid(valid),.ddata(received),.take(take));
 reg pll=0,cal=0,protocol=0;
 wire allow_a,stop_a,ack_a;wire [63:0] epoch_a;
 m5b1_failstop bridge(.ref_clk(wc),.pll_locked(pll),.cal_done(cal),.cal_pass(cal),.protocol_fault(protocol),.fifo_fault(1'b0),.domains_ready(1'b1),.allow_run(allow_a),.stop(stop_a),.ddr_reset_ack(ack_a),.epoch(epoch_a));
 task write_word(input [127:0] v);
 begin @(negedge wc);if(full)$fatal(1,"unexpected full");din=v;push=1;@(negedge wc);push=0;end endtask
 task read_word(input [127:0] v);
 begin wait(!empty);@(negedge rc);if(dout!==v)$fatal(1,"FIFO order/epoch got=%h want=%h",dout,v);pop=1;@(negedge rc);pop=0;end endtask
 task reset_both;
 begin #2.31;rst_n=0;push=0;pop=0;send=0;take=0;#19.87;rst_n=1;wait(wr&&rr);repeat(5)@(negedge wc);end endtask
 integer i,epoch,words=0;
 initial begin
  reset_both();pll=1;cal=1;
  // Fill to physical 8192B capacity; a rejected push must not overwrite head.
  for(i=0;i<512;i=i+1)write_word({64'd1,64'(i)});
  if(!full||wcount!=512)$fatal(1,"capacity/Gray pointer");
  @(negedge wc);push=1;din=128'hbad;@(negedge wc);push=0;
  if(!over)$fatal(1,"overflow not reported");
  for(i=0;i<512;i=i+1)begin read_word({64'd1,64'(i)});words=words+1;end
  repeat(4)@(negedge rc);if(!empty)$fatal(1,"drain count");
  pop=1;@(negedge rc);pop=0;if(!under)$fatal(1,"underflow not reported");
  // Destination stopped while a stable multi-bit mailbox is pending.
  @(negedge rc);halt_r=1;
  @(negedge wc);mail=128'h0123456789abcdef_fedcba9876543210;send=1;
  @(negedge wc);send=0;mail=0;
  repeat(15)@(negedge wc);if(!busy||valid)$fatal(1,"mailbox overwrote/early ack");
  halt_r=0;wait(valid);if(received!==128'h0123456789abcdef_fedcba9876543210)$fatal(1,"torn mailbox");
  repeat(5)@(negedge rc);if(!valid||!busy)$fatal(1,"mailbox lease");take=1;@(negedge rc);take=0;wait(!busy);
  // Reset assertion while destination clock is stopped: no stale epoch survives.
  for(epoch=2;epoch<10;epoch=epoch+1)begin
   write_word({64'(epoch-1),64'hbad});
   @(negedge rc);halt_r=1;#1.13;rst_n=0;#23.71;rst_n=1;
   repeat(6)@(negedge wc);if(rr||!empty||valid)$fatal(1,"stopped domain released reset");
   halt_r=0;wait(wr&&rr);repeat(4)@(negedge rc);
   if(!empty||wcount!=0||rcount!=0||over||under)$fatal(1,"epoch reset did not flush");
   for(i=0;i<17;i=i+1)write_word({64'(epoch),64'(i)});
   for(i=0;i<17;i=i+1)begin read_word({64'(epoch),64'(i)});words=words+1;end
  end
  // Actual fail-stop bridge never fabricates a warm ACK or recovers after loss.
  wait(allow_a);@(negedge wc);halt_w=1;#1.93;pll=0;#1;
  if(!stop_a||allow_a||ack_a)$fatal(1,"PLL stopped-clock failure not latched");
  pll=1;halt_w=0;repeat(400)@(negedge wc);
  if(!stop_a||allow_a||ack_a||epoch_a!=1)$fatal(1,"unproven warm recovery");
  $display("M5B1_CDC_PASS fifo_words=%0d reset_epochs=8 capacity=8192 mailbox_stopped_clock=1 failstop_no_ack=1",words);$finish;
 end
 initial begin #1000000;$fatal(1,"CDC watchdog");end
endmodule
