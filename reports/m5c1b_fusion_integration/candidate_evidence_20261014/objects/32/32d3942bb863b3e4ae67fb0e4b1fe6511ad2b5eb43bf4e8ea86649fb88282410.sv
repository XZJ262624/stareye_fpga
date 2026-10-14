`timescale 1ns/1ps
module descriptor_packet_sink #(parameter ID=0,FAST=1)(input ui,pix,rst,frame_done,input [479:0] pixels,input [767:0] desc,input [63:0] sid,token,input slot,output pending);
 integer packets=0;
 wire ready,fault,take,tx;wire [319:0] header;wire [8:0] index;wire [7:0] data;
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
 integer serial,meta,wire_bytes=0,payload_bytes=0,boundaries=0,cycles=0,changed_cycle=-100,minimum_setup=1000000,j,b;
 reg [8:0] old_index=0;reg [7:0] value;reg pre_done;reg [63:0] stored[0:31];reg captured=0;
 reg [896:0] previous_tuple;reg previous_pending=0;
 always @(posedge ui)begin
  if(rst&&payload_bytes>=255&&(backend.packet_done||take||backend.packet_start||backend.state<3))$display("PACKET_REARM side=%0d t=%0t state=%0d ready=%0d take=%0d done=%0d busy=%0d start=%0d count=%0d index=%0d",ID,$time,backend.state,ready,take,backend.packet_done,backend.packet_busy,backend.packet_start,payload_bytes,index);
  cycles=cycles+1;pre_done=backend.packet_done;if(take)begin captured=0;packets=packets+1;end
  if(rst)begin
   if(previous_pending&&pending&&{desc,sid,token,slot}!==previous_tuple)$fatal(1,"PENDING_TUPLE_CHANGED");
   previous_tuple={desc,sid,token,slot};previous_pending=pending;
   if(ready&&!captured)begin for(j=0;j<32;j=j+1)stored[j]=dut.mem[j];captured=1;end
   if(captured&&backend.packet_busy)for(j=0;j<32;j=j+1)if(dut.mem[j]!==stored[j])$fatal(1,"UART_STORAGE_CHANGED");
   if(backend.payload_ready&&backend.payload_valid)begin
    if(!ready||index!=payload_bytes%256)$fatal(1,"BACKEND_PAYLOAD_INDEX time=%0t count=%0d index=%0d ready=%0d take=%0d state=%0d packetbusy=%0d packetdone=%0d start=%0d",$time,payload_bytes,index,ready,take,backend.state,backend.packet_busy,backend.packet_done,backend.packet_start);
    if(cycles-changed_cycle<1)$fatal(1,"UART_BEFORE_SYNC_READ");
    if(index[2:0]==0)begin boundaries=boundaries+1;if(cycles-changed_cycle<minimum_setup)minimum_setup=cycles-changed_cycle;end
    $fdisplay(meta,"BYTE %0d %02h %0d",payload_bytes,data,cycles-changed_cycle);payload_bytes=payload_bytes+1;
   end
  end
  #0.001;if(rst&&take&&!pre_done)$fatal(1,"TAKE_BEFORE_PACKET_DONE");
 end
 always @(negedge ui)if(index!=old_index)begin old_index=index;changed_cycle=cycles;end

 initial begin serial=$fopen($sformatf("serial_%0d.hex",ID),"w");meta=$fopen($sformatf("uart_meta_%0d.txt",ID),"w");end
 always @(posedge pix)if(rst&&frame_done)$fdisplay(meta,"INPUT %0120h %0192h %016h %0d",pixels,desc,token,slot);
 initial forever begin
  @(negedge tx);#(BIT_NS*1.5);for(b=0;b<8;b=b+1)begin value[b]=tx;#(BIT_NS);end
  if(tx!==1)$fatal(1,"UART_STOP_BIT");$fdisplay(serial,"%02h",value);wire_bytes=wire_bytes+1;
 end
endmodule
