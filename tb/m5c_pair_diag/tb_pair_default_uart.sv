`timescale 1ns/1ps
module tb_pair_default_uart;
 reg clk=0,rst=0,start=0;always #5 clk=~clk;
 wire ready,busy,done,tx;integer pos=0,received=0,accepted=0,fd,fa,i;
 reg [7:0] got;reg [1023:0] outpath,acceptpath;
 wire [7:0] payload=pos[7:0]^8'h5a;
 m5b1_packet_tx packet(.clk(clk),.rst_n(rst),.abort(1'b0),.start(start),.packet_type(8'd10),.length(32'd256),.descriptor(320'h123456789abcdef),.payload(payload),.payload_valid(1'b1),.payload_ready(ready),.diag_grant(1'b0),.diag_byte(8'd0),.diag_byte_valid(1'b0),.diag_index(),.diag_busy(),.diag_done(),.diag_cancel(),.busy(busy),.done(done),.uart_tx(tx));
 always @(posedge clk)if(rst)begin
  if(ready)pos<=pos+1;
  if(packet.uart.valid&&packet.uart.ready)begin $fdisplay(fa,"%02h",packet.uart.data);accepted=accepted+1;end
 end
 // Independent pin receiver: 96M/460800=208+1/3 UI clocks per bit.
 // UI model period is 10ns; this is divider/ordering proof, not physical baud measurement.
 initial begin
  if(!$value$plusargs("OUT=%s",outpath)||!$value$plusargs("ACCEPT=%s",acceptpath))$fatal(1,"UART_OUTPUT_REQUIRED");
  fd=$fopen(outpath,"w");fa=$fopen(acceptpath,"w");
  forever begin
   @(negedge tx);#1041.666667;if(tx!==0)$fatal(1,"UART_START_BIT");
   for(i=0;i<8;i=i+1)begin #2083.333333;got[i]=tx;end
   #2083.333333;if(tx!==1)$fatal(1,"UART_STOP_BIT");
   $fdisplay(fd,"%02h",got);received=received+1;
  end
 end
 initial begin
  repeat(6)@(negedge clk);rst=1;repeat(4)@(negedge clk);start=1;@(negedge clk);start=0;
  wait(done);repeat(4)@(negedge clk);
  if(received!=324||accepted!=324||pos!=256)$fatal(1,"UART_FULL_PACKET_COVERAGE");
  if(packet.uart.CLOCK!=96000000||packet.uart.BAUD!=460800)$fatal(1,"UART_DEFAULT_PARAMETERS");
  $fclose(fd);$fclose(fa);$display("PAIR_DEFAULT_PIN_UART_PASS bytes=%0d CLOCK=%0d BAUD=%0d",received,packet.uart.CLOCK,packet.uart.BAUD);$finish;
 end
 initial begin #10000000;$fatal(1,"UART_DEFAULT_WATCHDOG");end
endmodule
