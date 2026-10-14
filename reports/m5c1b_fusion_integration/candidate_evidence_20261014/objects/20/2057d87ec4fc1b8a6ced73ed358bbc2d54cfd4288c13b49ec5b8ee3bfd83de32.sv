`timescale 1ns/1ps
module tb_continuous_reset;
 parameter RESET_STAGE=0;integer reset_epoch=0,decode_epoch;
 parameter ARRIVAL=0;
 parameter FAST=1;
 reg ui=0,pix=0,rst=0,frame_done=0;always #5 ui=~ui;always #7 pix=~pix;
 reg [479:0] pixels=480'h123456789abcdef00112233445566778876543210fedcba9876543210abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789;
 reg [767:0] desc=768'h123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0;
 reg [63:0] sid=9,token=31;reg slot=1;
 wire ready,pending,fault,take,tx;wire [319:0] header;wire [8:0] index;wire [7:0] data;
 m5c_telemetry dut(.pix_clk(pix),.ui_clk(ui),.rst_n(rst),.frame_done(frame_done),.pixel_snapshot(pixels),
 .active_descriptor(desc),.active_session(sid),.active_token(token),.active_slot(slot),.rejected_jobs(64'hfeed000000000003),.protocol_faults(64'hbeef000000000004),
 .payload_ready(ready),.header_descriptor(header),.payload_take(take),.byte_index(index),.payload_byte(data),.snapshot_pending(pending),.snapshot_fault(fault));
 m5b1_backend backend(.ui_clk(ui),
.pix_clk(pix),
.rst_n(rst),
.run('0),
.stop('0),
.epoch('0),
.tap_valid('0),
.tap_class('0),
.tap_x('0),
.tap_y('0),
.tap_high('0),
.tap_low('0),
.tap_filter('0),
.tap_frame_id('0),
.tap_epoch('0),
.tap_timestamp('0),
.tap_display_seq('0),
.tap_config_generation('0),
.fusion_acquire('0),
.fusion_slot('0),
.fusion_identity('0),
.fusion_token('0),
.fusion_release('0),
.fusion_retire('0),
.fusion_read_accept('0),
.fusion_read_done('0),
.fusion_ack(),
.fusion_denied(),
.pair_leased(),
.result_valid(),
.result_slot(),
.result_descriptor(),
.export_exclusive(),
.capture_priority(),
.lease_fault(),
.job_rejected_event(),
.telemetry_ready(ready),
.telemetry_descriptor(header),
.telemetry_byte(data),
.telemetry_index(index),
.telemetry_take(take),
.max_wait('0),
.max_service('0),
.camera_max('0),
.display_min('0),
.system_status('0),
.error_counts('0),
.video_fifo_faults('0),
.uart_tx(tx),
.job_busy(),
.publish_toggle(),
.bg_fault(),
.capture_reset_done(),
.avalid(),
.aready('0),
.aaddr(),
.alen(),
.aid(),
.atype(),
.wvalid(),
.wlast(),
.wdata(),
.wready('0),
.bvalid('0),
.bid('0),
.bresp('0),
.rvalid('0),
.rlast('0),
.rdata('0),
.rid('0),
.rresp('0),
.rready(),
.rejected('0),
.write_permission(),
.read_permission());
 defparam backend.packet.uart.CLOCK=FAST?100:96000000;
 defparam backend.packet.uart.BAUD=FAST?25:460800;
 localparam real BIT_NS=FAST?40.0:(10.0*96000000.0/460800.0);
 integer snapshots=0,starts=0,dones=0,takes=0,k,serial,meta,wire_bytes=0,payload_bytes=0,boundaries=0,cycles=0,changed_cycle=-100,minimum_setup=1000000,j,b;
 reg [8:0] old_index=0;reg [7:0] value;reg pre_done;reg [63:0] stored[0:31];reg captured=0;
 reg old_ready=0,old_take=0;reg [319:0] stored_header;
 reg [896:0] previous_tuple;reg previous_pending=0;
 always @(posedge ui)begin
  cycles=cycles+1;pre_done=backend.packet_done;
  if(rst)begin
   if(backend.packet_start)begin starts=starts+1;if(starts>snapshots||!ready||take)$fatal(1,"DUPLICATE_TELEMETRY_REARM");end
   if(backend.packet_done)dones=dones+1;
   if(take)begin takes=takes+1;captured=0;end
  end
  if(rst)begin
   if(old_ready&&!old_take&&!ready)$fatal(1,"PRODUCER_READY_DROPPED_BEFORE_ACK");old_ready=ready;old_take=take;
   if(previous_pending&&pending&&{desc,sid,token,slot}!==previous_tuple)$fatal(1,"PENDING_TUPLE_CHANGED");
   previous_tuple={desc,sid,token,slot};previous_pending=pending;
   if(ready&&!captured&&!take)begin for(j=0;j<32;j=j+1)stored[j]=dut.mem[j];stored_header=header;captured=1;end
   if(captured&&backend.packet_busy&&header!==stored_header)$fatal(1,"UART_HEADER_CHANGED");
   if(captured&&backend.packet_busy)for(j=0;j<32;j=j+1)if(dut.mem[j]!==stored[j])$fatal(1,"UART_STORAGE_CHANGED");
   if(backend.payload_ready&&backend.payload_valid)begin
    if(!ready||index!=payload_bytes%256)$fatal(1,"BACKEND_PAYLOAD_INDEX");
    if(cycles-changed_cycle<1)$fatal(1,"UART_BEFORE_SYNC_READ");
    if(index[2:0]==0)begin boundaries=boundaries+1;if(cycles-changed_cycle<minimum_setup)minimum_setup=cycles-changed_cycle;end
    $fdisplay(meta,"BYTE %0d %02h %0d",payload_bytes,data,cycles-changed_cycle);payload_bytes=payload_bytes+1;
   end
  end
  #0.001;if(rst&&take&&!pre_done)$fatal(1,"TAKE_BEFORE_PACKET_DONE");
 end
 always @(negedge ui)if(index!=old_index)begin old_index=index;changed_cycle=cycles;end
 always @(posedge pix)if(rst&&frame_done)begin
  snapshots=snapshots+1;$fdisplay(meta,"INPUT %0120h %0192h %016h %0d",pixels,desc,token,slot);
 end
 task new_snapshot(input integer n);begin
  pixels=480'h123456789abcdef00112233445566778876543210fedcba9876543210abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789+n;
  pixels[191:128]=9+n;desc=768'h123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0+n;
  sid=9+n;token=31+n;slot=n%2;
  frame_done=1;@(negedge pix);frame_done=0;
 end endtask
 initial begin
  serial=$fopen("serial.hex","w");meta=$fopen("uart_meta.txt","w");
  repeat(4)@(negedge pix);rst=1;repeat(8)@(negedge pix);
  new_snapshot(7);
  if(RESET_STAGE==0)wait(dut.building&&dut.word_index==10);else wait(wire_bytes>=5);
  @(negedge ui);reset_epoch=reset_epoch+1;rst=0;
  repeat(100)@(negedge ui);
  if(ready||pending===1'b1&&dut.mail_valid||backend.packet_busy||take)$fatal(1,"RESET_ABORT_NOT_QUIET");
  snapshots=0;starts=0;dones=0;takes=0;wire_bytes=0;payload_bytes=0;boundaries=0;captured=0;previous_pending=0;old_ready=0;old_take=0;old_index=0;
  $fclose(serial);$fclose(meta);serial=$fopen("serial.hex","w");meta=$fopen("uart_meta.txt","w");
  @(negedge pix);rst=1;repeat(8)@(negedge pix);
  $display("REAL_RESET_ABORT stage=%0d before_three_packets",RESET_STAGE);
  new_snapshot(0);wait(backend.packet_busy);wait(!pending);
  // Second source request is legitimately pending while first UART owns RAM.
  @(negedge pix);new_snapshot(1);
  wait(takes==2);if(ARRIVAL)@(negedge pix);@(negedge pix);new_snapshot(2);
  wait(takes==3);repeat(2000)@(negedge ui);
  if(snapshots!=3||starts!=3||dones!=3||takes!=3||wire_bytes!=972||payload_bytes!=768||boundaries!=96||ready||fault||pending)$fatal(1,"CONTINUOUS_UART_COUNTS snapshots=%0d starts=%0d dones=%0d takes=%0d wire=%0d payload=%0d",snapshots,starts,dones,takes,wire_bytes,payload_bytes);
  $display("BACKEND_UART_PASS continuous fast=%0d arrival=%0d snapshots=%0d starts=%0d dones=%0d takes=%0d wire=%0d stableCRC=1",FAST,ARRIVAL,snapshots,starts,dones,takes,wire_bytes);$fclose(serial);$fclose(meta);$finish;
 end
 initial forever begin
  @(negedge tx);decode_epoch=reset_epoch;#(BIT_NS*1.5);
  for(b=0;b<8;b=b+1)begin value[b]=tx;#(BIT_NS);end
  if(rst&&decode_epoch==reset_epoch)begin if(tx!==1)$fatal(1,"UART_STOP_BIT");$fdisplay(serial,"%02h",value);wire_bytes=wire_bytes+1;end
 end
 initial begin #40000000;$fatal(1,"UART_TIMEOUT");end
endmodule
