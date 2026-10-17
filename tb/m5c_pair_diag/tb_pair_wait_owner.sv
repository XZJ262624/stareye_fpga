`timescale 1ns/1ps
module tb_pair_wait_owner;
parameter PHASE=0;
reg clk=0;always #5 clk=~clk;
reg rst=0,expired=0,reserve=0,bindv=0,publish=0,acquire=0,rel=0,ret=0;
wire ra,rd,slot,ba,aa,ad,lv,ls,fault,rejected;
wire [1:0] reserved,committed;wire [3:0] leased;
localparam [319:0] ID={64'h100000001,64'h200000002,64'h300000003,64'h400000004,64'h500000005};
localparam [63:0] TOKEN=64'h123456789abcdef0;
wire hold,retain,pr,pt;
wire outrel=retain?pr:rel;
wire outret=retain?pt:ret;
m5c_pair_lease lease(.clk(clk),.rst_n(rst),.stop(1'b0),.export_exclusive(1'b0),
.reserve_valid(reserve),.reserve_identity(ID),.reserve_ack(ra),.reserve_denied(rd),.reserve_slot(slot),
.bind_valid(bindv),.bind_slot(slot),.bind_identity(ID),.bind_ack(ba),
.publish_valid(publish),.publish_slot(slot),.metadata_b_done(1'b1),.publish_identity(ID),
.cancel_valid(1'b0),.cancel_slot(slot),.write_drained(1'b0),.cancel_identity(ID),
.acquire_valid(acquire),.acquire_slot(slot),.acquire_uart(1'b0),.acquire_identity(ID),.acquire_token(TOKEN),.acquire_ack(aa),.acquire_denied(ad),
.release_valid(outrel),.release_slot(slot),.release_uart(1'b0),.release_identity(ID),.release_token(TOKEN),
.retire_valid(outret),.retire_slot(slot),.retire_uart(1'b0),.retire_identity(ID),.retire_token(TOKEN),
.read_accept(1'b0),.read_slot(slot),.read_uart(1'b0),.read_identity(ID),.read_token(TOKEN),
.read_done(1'b0),.done_slot(slot),.done_uart(1'b0),.done_identity(ID),.done_token(TOKEN),
.latest_valid(lv),.latest_slot(ls),.reserved(reserved),.committed(committed),.leased(leased),.protocol_fault(fault),.event_rejected(rejected));
m5c_pair_controller controller(.clk(clk),.rst_n(rst),.stop(1'b0),.select(1'b0),.wait_expired(expired),.acquire_ack(1'b0),.acquire_denied(1'b0),
.descriptor(768'd0),.identity(ID),.session(64'd100),.token(TOKEN),.slot(slot),.fusion_release(rel),.fusion_retire(ret),.held(leased[0]),
.hold(hold),.retain_owner(retain),.release_owned(pr),.retire_owned(pt),
.cap_arm_busy(1'b0),.cap_done(1'b0),.cap_reason(32'd0),.cap_empty(1'b1),.cap_count(10'd0),.cap_data(128'd0),
.tx_busy(1'b0),.tx_done(1'b0),.tx_error(1'b0),.tx_read_beat(1'b0),.tx_write_beat(1'b0),.tx_beat(8'd0),.rdata(128'd0),
.buffer_read_data(128'd0),.payload_ready(1'b0),.packet_done(1'b0),.packet_busy(1'b1));
initial begin
repeat(3)@(negedge clk);rst=1;
@(negedge clk);reserve=1;@(negedge clk);reserve=0;if(!ra)$fatal(1,"SETUP_RESERVE");
bindv=1;@(negedge clk);bindv=0;if(!ba)$fatal(1,"SETUP_BIND");
publish=1;@(negedge clk);publish=0;acquire=1;@(negedge clk);acquire=0;
if(!aa||leased!==4'b0001)$fatal(1,"SETUP_REAL_OWNER");
if(PHASE==0)begin rel=1;ret=1;@(negedge clk);rel=0;ret=0;expired=1;end
else if(PHASE==1)begin expired=1;rel=1;ret=1;@(negedge clk);rel=0;ret=0;end
else begin expired=1;@(negedge clk);rel=1;ret=1;@(negedge clk);rel=0;ret=0;end
repeat(4)@(negedge clk);
if(!hold||retain!==0||leased!==0||fault||rejected)$fatal(1,"UNSELECTED_WAIT_TIMEOUT_LEASE_LEAK");
$display("PAIR_WAIT_OWNER_PASS phase=%0d full_identity=%h token=%h leased=%b hold=%b retain=%b",PHASE,ID,TOKEN,leased,hold,retain);$finish;
end
initial begin #10000;$fatal(1,"WAIT_OWNER_WATCHDOG");end
endmodule
