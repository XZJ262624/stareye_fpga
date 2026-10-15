`timescale 1ns/1ps
module tb_diag_bridge;
 reg pix=0,ui=0,run_ui=1,arst=0;
 always #7 pix=~pix;
 always #5 if(run_ui)ui=~ui;else ui=0;
 reg ready=0,done=0,cancel=0;reg [8:0] index=0;
 wire take,cancel_pix,pr,ur,ui_ready,valid;wire [5:0] word;wire [7:0] byte_data;
 reg [63:0] memory[0:39],q;integer gen=0,takes=0,cancels=0,i,j;reg [7:0] expected;
 m5c_diag_record_bridge dut(.pix_clk(pix),.ui_clk(ui),.arst_n(arst),.pix_ready(ready),.pix_take(take),.pix_cancel(cancel_pix),.pix_rst_n(pr),.ui_rst_n(ur),.ui_ready(ui_ready),.ui_done(done),.ui_cancel(cancel),.byte_index(index),.read_word(word),.word_data(q),.byte_data(byte_data),.byte_valid(valid));
 always @(posedge ui)q<=memory[word];
 always @(posedge pix)if(pr&&take)begin
  takes=takes+1;if(cancel_pix)cancels=cancels+1;ready<=0;
 end
 task fill;begin
  gen=gen+1;for(i=0;i<40;i=i+1)for(j=0;j<8;j=j+1)memory[i][j*8+:8]=(gen*31+i*8+j)%256;
  @(negedge pix);ready=1;wait(ui_ready);
 end endtask
 task drain;begin
  wait(!ready);repeat(12)@(negedge ui);if(ui_ready||take||dut.ack||dut.cancel_held)$fatal(1,"BRIDGE_ACK_NOT_DRAINED");
 end endtask
 initial begin
  repeat(3)@(negedge pix);arst=1;wait(pr&&ur);
  fill;
  for(i=0;i<320;i=i+1)begin
   @(negedge ui);index=i;repeat(i%3+1)@(negedge ui);wait(valid);#1;
   expected=(gen*31+(i<64?256+i:i-64))%256;
   if(byte_data!==expected)$fatal(1,"BRIDGE_BYTE_BOUNDARY index=%0d got=%h exp=%h",i,byte_data,expected);
   if(takes!=0)$fatal(1,"BRIDGE_EARLY_ACK");
  end
  @(negedge ui);done=1;@(negedge ui);done=0;drain;
  if(takes!=1||cancels!=0)$fatal(1,"BRIDGE_SUCCESS_ACK_COUNT");
  fill;@(negedge ui);cancel=1;@(negedge ui);cancel=0;drain;
  if(takes!=2||cancels!=1)$fatal(1,"BRIDGE_CANCEL_ACK_COUNT");
  fill;@(negedge ui);run_ui=0;arst=0;ready=0;#80;
  if(pr!==0||ur!==0||take!==0||ui_ready!==0)$fatal(1,"BRIDGE_ASYNC_ASSERT");
  arst=1;repeat(5)@(negedge pix);if(ur!==0)$fatal(1,"BRIDGE_STOPPED_CLOCK_RELEASE");
  run_ui=1;wait(pr&&ur);fill;@(negedge ui);done=1;@(negedge ui);done=0;drain;
  if(takes!=3||cancels!=1)$fatal(1,"BRIDGE_RECOVERY_ACK_COUNT");
  $display("DIAG_BRIDGE_PASS bytes=320 success=2 cancel=1 reset_pending=1 stopped_ui=1");$finish;
 end
 initial begin #1000000;$fatal(1,"BRIDGE_WATCHDOG");end
endmodule
