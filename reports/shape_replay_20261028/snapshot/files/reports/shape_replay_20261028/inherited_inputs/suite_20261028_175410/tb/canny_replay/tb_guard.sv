`timescale 1ns/1ps
module tb_guard;
 reg clk=0,rst=0,ack=0;always #5 clk=~clk;
 reg [31:0] wb=0,rb=0;reg active=0;reg [2:0] cv=0,ct=0;
 reg [95:0] addresses=0;reg [23:0] lengths={3{8'd127}},ids=24'h000201;
 wire [2:0] ready,rejected;wire av;wire [31:0] address;integer tests=0;
 replay_arbiter dut(.clk(clk),.rst_n(rst),.soft_reset(1'b0),.ddr_reset_ack(ack),.urgent(2'b0),.safe_window(1'b1),.emergency_stop(1'b0),.epoch(64'd1),.c_epoch({3{64'd1}}),
 .video_write_base(wb),.video_read_base(rb),.video_read_active(active),.bg_write_permission(7'd0),.bg_read_permission(7'd0),
 .c_avalid(cv),.c_aready(ready),.c_aaddr(addresses),.c_alen(lengths),.c_aid(ids),.c_atype(ct),.c_wvalid(3'd0),.c_wlast(3'd0),.c_wdata(384'd0),.c_wstrb(48'd0),.c_bready(3'b111),.c_rready(3'b111),
 .rejected(rejected),.aaddr(address),.avalid(av),.aready(1'b0),.wready(1'b0),.bid(8'd0),.bresp(2'd0),.bvalid(1'b0),.rid(8'd0),.rresp(2'd0),.rdata(128'd0),.rlast(1'b0),.rvalid(1'b0));
 task attempt(input integer client,input [31:0] a,input bit writing,input bit good);
 begin
  @(negedge clk);cv=1<<client;ct=writing<<client;addresses[client*32+:32]=a;
  wait(ready[client]);@(posedge clk);#1;cv=0;
  if(good)begin
   if(!av||address!=a||rejected)$fatal(1,"valid rejected %h",a);
   // Once accepted, changing permission base cannot retarget an in-flight A.
   wb=32'h00400000;rb=32'h00800000;
   repeat(4)begin @(posedge clk);#1;if(!av||address!=a)$fatal(1,"A retarget");end
  end else if(!rejected[client]||av)$fatal(1,"illegal accepted %h",a);
  @(negedge clk);ack=1;#1;if(av)$fatal(1,"ACK isolation");@(negedge clk);ack=0;tests=tests+1;
 end endtask
 initial begin
  #20;rst=1;
  wb=32'h03f00000;attempt(0,32'h03fe0800,1,1);
  wb=32'h03f00000;attempt(0,32'h03fe1000,1,0);
  wb=32'h04000000;attempt(0,32'h04000000,1,0);
  wb=32'h02000000;attempt(0,32'h02000c00,1,0);
  wb=32'h02000000;attempt(0,32'h02000010,1,1);
  wb=32'h02000000;attempt(0,32'h02000001,1,0);
  wb=32'h02000000;attempt(0,32'h02100000,1,0);
  wb=32'h02000000;attempt(0,32'h02000000,0,0);
  rb=32'h02000000;active=0;attempt(1,32'h02000000,0,0);
  rb=32'h02000000;active=1;attempt(1,32'h02000000,0,1);
  rb=32'h03f00000;active=1;attempt(1,32'h03fe0800,0,1);
  rb=32'h02000000;active=1;attempt(1,32'h02000000,1,0);
  wb=32'h01000000;attempt(0,32'h01000000,1,0);
  wb=0;attempt(0,32'h00000000,1,1);
  wb=32'h00400000;attempt(0,32'h004e0800,1,1);
  wb=32'h02000000;attempt(2,32'h02000000,1,0);
  $display("GUARD_PASS cases=%0d",tests);$finish;
 end
 initial begin #100000;$fatal(1,"timeout");end
endmodule
