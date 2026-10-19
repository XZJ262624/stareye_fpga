// Snapshot producer. Never backpressures M5A; any loss aborts this job.
// First FIFO record is {job,epoch}; following records pack 64 pixels, LSB first.
module m5b1_capture #(parameter WIDTH=1280,HEIGHT=720)(
 input ui_clk,pix_clk,arst_n,input cancel,input arm,input [63:0] job,epoch,output arm_busy,
 input tap_valid,input [1:0] tap_class,input [11:0] tap_x,tap_y,
 input [7:0] tap_high,tap_low,input tap_filter,
 input [63:0] tap_frame_id,tap_epoch,tap_timestamp,tap_display_seq,tap_config_generation,
 output [127:0] data,output empty,input pop,output [9:0] count,
 output descriptor_valid,output [767:0] descriptor,input descriptor_take,
 output [1:0] reset_done,output reg dropped,
 output reg [13:0] fifo_min_bytes,fifo_max_bytes,output [1:0] fifo_faults);
 (* async_reg="true" *) reg [1:0] prelease;
 always @(posedge pix_clk or negedge arst_n)if(!arst_n)prelease<=0;else prelease<={prelease[0],1'b1};
 wire prst_n=prelease[1];
 wire arm_valid;wire [127:0] arm_data;reg arm_take;
 m5b1_mailbox #(.WIDTH(128)) arm_box(.sclk(ui_clk),.dclk(pix_clk),.arst_n(arst_n),
  .send(arm),.sdata({job,epoch}),.busy(arm_busy),.valid(arm_valid),.ddata(arm_data),.take(arm_take));
 reg cancel_meta,cancel_sync;
 always @(posedge pix_clk or negedge prst_n)
  if(!prst_n)begin cancel_meta<=0;cancel_sync<=0;end
  else begin cancel_meta<=cancel;cancel_sync<=cancel_meta;end
 reg active,bad;reg [19:0] position;reg [127:0] pack_data;reg [767:0] desc;
 reg send;wire send_busy;reg push;reg [127:0] push_data;
 wire full,over,under;wire [9:0] wcount;
 (* async_reg="true" *) reg [1:0] over_sync;
 assign fifo_faults={under,over_sync[1]};
 always @(posedge ui_clk or negedge arst_n)begin
  if(!arst_n)begin fifo_min_bytes<=8192;fifo_max_bytes<=0;over_sync<=0;end
  else begin
   over_sync<={over_sync[0],over};
   if({count,4'b0}<fifo_min_bytes)fifo_min_bytes<={count,4'b0};
   if({count,4'b0}>fifo_max_bytes)fifo_max_bytes<={count,4'b0};
  end
 end
 wire start=!cancel_sync&&arm_valid&&!active&&tap_valid&&tap_x==0&&tap_y==0;
 m5b1_async_fifo fifo(.wclk(pix_clk),.rclk(ui_clk),.arst_n(arst_n),.push(push),.wdata(push_data),
  .pop(pop),.rdata(data),.full(full),.empty(empty),.wcount(wcount),.rcount(count),
  .wreset_done(reset_done[0]),.rreset_done(reset_done[1]),.overflow(over),.underflow(under));
 m5b1_mailbox #(.WIDTH(768)) descriptor_box(.sclk(pix_clk),.dclk(ui_clk),.arst_n(arst_n),
  .send(send),.sdata(desc),.busy(send_busy),.valid(descriptor_valid),.ddata(descriptor),.take(descriptor_take));
 reg [11:0] expect_x,expect_y;
 wire sample_bad=tap_class==3||tap_epoch!=desc[63:0]||tap_frame_id!=desc[127:64]||tap_x!=expect_x||tap_y!=expect_y;
 always @(posedge pix_clk or negedge prst_n)begin
  if(!prst_n)begin active<=0;bad<=0;position<=0;pack_data<=0;desc<=0;send<=0;push<=0;push_data<=0;arm_take<=0;dropped<=0;expect_x<=0;expect_y<=0;end
  else begin
   send<=0;push<=0;arm_take<=0;
   if(cancel_sync&&(active||arm_valid)&&!send_busy)begin
    active<=0;arm_take<=arm_valid;bad<=1;dropped<=1;send<=1;
    if(active)desc[308]<=0;
    else begin desc<=0;desc[63:0]<=arm_data[63:0];desc[191:128]<=arm_data[127:64];end
   end else if(start)begin
    arm_take<=1;active<=1;position<=1;bad<=tap_class==3||tap_epoch!=arm_data[63:0]||full||send_busy;
    pack_data<={126'b0,tap_class};push<=1;push_data<=arm_data;
    desc<=0;desc[63:0]<=arm_data[63:0];desc[127:64]<=tap_frame_id;desc[191:128]<=arm_data[127:64];
    desc[255:192]<=tap_timestamp;desc[263:256]<=tap_high;desc[271:264]<=tap_low;
    desc[272]<=tap_filter;desc[275:273]<=tap_filter?3'd3:3'd2;desc[283:276]<=8'd1;
    desc[295:284]<=WIDTH;desc[307:296]<=HEIGHT;expect_x<=1;expect_y<=0;
    desc[383:320]<=tap_display_seq;desc[447:384]<=tap_config_generation;
    desc[575:512]<=tap_timestamp;
    desc[735:576]<={tap_config_generation,8'd1,8'd1,12'd1280,12'd720,tap_high,tap_low,tap_filter,(tap_filter?3'd3:3'd2),8'd1,28'd0};
    desc[743:736]<=8'd1;desc[751:744]<=8'd1;
   end else if(active&&tap_valid)begin
    if(sample_bad)bad<=1;
    pack_data[position[5:0]*2+:2]<=tap_class;
    if(position[5:0]==63)begin
     if(full)bad<=1;
     else if(!bad&&!sample_bad)begin push<=1;push_data<={tap_class,pack_data[125:0]};end
    end
    if(expect_x==WIDTH-1)begin expect_x<=0;expect_y<=expect_y+1'b1;end
    else expect_x<=expect_x+1'b1;
    if(position==WIDTH*HEIGHT-1)begin
     active<=0;send<=1;desc[308]<=!bad&&!sample_bad&&!full;
     if(bad||sample_bad||full)dropped<=1;
    end else position<=position+1'b1;
   end
   if(over)dropped<=1; // sticky diagnostic must not poison later jobs
  end
 end
endmodule

