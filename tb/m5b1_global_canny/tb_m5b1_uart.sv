`timescale 1ns/1ps
module tb_m5b1_uart;
 reg clk=0;always #5.208333 clk=~clk;reg rst_n=0,start=0;reg [8:0] index=0;
 wire ready,busy,done,tx;wire [7:0] payload=index[7:0]^8'ha5;
 localparam [319:0] DESC=(320'd128<<284)|(320'd16<<296)|(320'd1<<308)|(320'd1<<276)|320'd1;
 m5b1_packet_tx dut(.clk(clk),.rst_n(rst_n),.abort(1'b0),.start(start),.packet_type(8'd2),.length(32'd512),.descriptor(DESC),
  .payload(payload),.payload_valid(1'b1),.payload_ready(ready),.busy(busy),.done(done),.uart_tx(tx));
 // Production 96 MHz / 460800 fractional divider, independent ideal receiver.
 always @(posedge clk)if(ready)index<=index+1'b1;
 integer fd,b,i,count=0;reg [7:0] octet;
 initial begin
  fd=$fopen("uart_packet.hex","w");if(!fd)$fatal(1,"output open");
  forever begin
   @(negedge tx);#1085.069444;if(tx!==0)$fatal(1,"start bit");
   for(i=0;i<8;i=i+1)begin #2170.138889;octet[i]=tx;end
   #2170.138889;if(tx!==1)$fatal(1,"stop bit");
   $fdisplay(fd,"%02x",octet);count=count+1;
  end
 end
 initial begin repeat(5)@(negedge clk);rst_n=1;repeat(3)@(negedge clk);start=1;@(negedge clk);start=0;
  wait(done);#100;if(count!=580)$fatal(1,"byte count %0d",count);$fclose(fd);$display("M5B1_UART_BITS_PASS bytes=%0d",count);$finish;
 end
 initial begin #20000000;$fatal(1,"UART watchdog");end
endmodule
