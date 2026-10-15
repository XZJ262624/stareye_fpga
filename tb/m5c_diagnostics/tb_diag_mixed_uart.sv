`timescale 1ns/1ps
module tb_diag_mixed_uart;
 reg clk=0,rst=0,start=0,grant=0;always #5 clk=~clk;
 reg [7:0] typ=1;reg [31:0] pos=0;reg compare_original=1;
 wire ready,done,busy,tx,dbusy,ddone,dcancel;wire [8:0] di;
 wire cref,c_done,c_busy,c_tx;wire [7:0] payload=(pos*13+typ*17)&255;
 wire [7:0] dbyte=di==0?8'h53:di==1?8'h4d:di==2?8'h35:di==3?8'h42:di==4?1:di==5?5:di==6?64:di==9?1:di>=64?((di-64)*7+3)&255:0;
 m5b1_packet_tx #(.DIAGNOSTICS(1)) dut(.clk(clk),.rst_n(rst),.abort(1'b0),.start(start),.packet_type(typ),.length(32'd256),.descriptor(320'h123456789abcdef),.payload(payload),.payload_valid(1'b1),.payload_ready(ready),.diag_grant(grant),.diag_byte(dbyte),.diag_byte_valid(1'b1),.diag_index(di),.diag_busy(dbusy),.diag_done(ddone),.diag_cancel(dcancel),.busy(busy),.done(done),.uart_tx(tx));
 baseline_m5b1_packet_tx control(.clk(clk),.rst_n(rst),.abort(1'b0),.start(start),.packet_type(typ),.length(32'd256),.descriptor(320'h123456789abcdef),.payload(payload),.payload_valid(1'b1),.payload_ready(cref),.busy(c_busy),.done(c_done),.uart_tx(c_tx));
 integer count=0,f,k,b;reg [7:0] value;reg [2047:0] outpath;
 always @(posedge clk)if(rst)begin
  if(ready)pos<=pos+1;
  if(compare_original&&(tx!==c_tx||ready!==cref||done!==c_done||busy!==c_busy))$fatal(1,"DIAG_ORIGINAL_PACKET_CYCLE_CHANGED");
  if(dcancel)$fatal(1,"DIAG_MIXED_UNEXPECTED_CANCEL");
 end
 initial begin
  if(!$value$plusargs("OUT=%s",outpath))$fatal(1,"OUT_REQUIRED");f=$fopen({outpath,"/wire.hex"},"w");
  forever begin @(negedge tx);#3125;for(b=0;b<8;b=b+1)begin value[b]=tx;#2083.333333;end
   if(tx!==1)$fatal(1,"DIAG_MIXED_STOP_BIT");$fwrite(f,"%02h\n",value);count=count+1;
  end
 end
 task original_packet(input [7:0] t);begin
  @(negedge clk);typ=t;pos=0;start=1;@(negedge clk);start=0;wait(done);repeat(3)@(negedge clk);
 end endtask
 initial begin
  repeat(10)@(negedge clk);rst=1;original_packet(1);
  compare_original=0;grant=1;@(negedge clk);grant=0;wait(ddone);repeat(3)@(negedge clk);compare_original=1;
  original_packet(2);original_packet(3);original_packet(4);
  if(count!=1620)$fatal(1,"DIAG_MIXED_WIRE_COUNT count=%0d",count);
  $fclose(f);$display("DIAG_MIXED_UART_PASS bytes=1620 packets=5 original_cycle_exact=1");$finish;
 end
 initial begin #50000000;$fatal(1,"DIAG_MIXED_WATCHDOG");end
endmodule
