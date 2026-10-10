// Byte camera -> 128-bit DDR, 128-bit DDR -> byte display. Full RT bursts.
// A frame becomes COMPLETE only after its last real B and camera EOF validation.
// Display holds READ_LEASE until the last pixel consumed and every R has drained.
module m5b1_video_dma #(parameter FRAME_BYTES=921600)(
 input ui_clk,cam_clk,pix_clk,arst_n,run,stop,input [63:0] epoch,
 input cam_vs,cam_valid,input [7:0] cam_data,input pix_sof,pix_request,
 output reg [7:0] pix_data,output reg [63:0] replay_frame_id,
 output reg display_valid,output reg fault,
 output [1:0] avalid,input [1:0] aready,output [63:0] aaddr,
 output [15:0] alen,aid,output [1:0] atype,
 output wvalid,wlast,output [127:0] wdata,input wready,
 input bvalid,input [1:0] bresp,input [7:0] bid,
 input rvalid,rlast,input [127:0] rdata,input [1:0] rresp,input [7:0] rid,
 output rready,input [1:0] rejected,
 output [3:0] write_permission,read_permission,
 output [13:0] camera_bytes,display_bytes,output [1:0] urgent,
 output safe_window,output [3:0] fifo_ready,
 output reg [13:0] camera_max,display_min,output [3:0] fifo_faults);
 (* async_reg="true" *) reg [1:0] crelease,prelease;
 always @(posedge cam_clk or negedge arst_n)if(!arst_n)crelease<=0;else crelease<={crelease[0],1'b1};
 always @(posedge pix_clk or negedge arst_n)if(!arst_n)prelease<=0;else prelease<={prelease[0],1'b1};
 wire crst_n=crelease[1],prst_n=prelease[1];
 // run crosses as a stable status; it never causes a local independent reset.
 (* async_reg="true" *) reg [1:0] cam_run,pix_run;
 reg cam_vs_d,cam_armed;reg [19:0] cam_count;reg [3:0] pack_pos;
 reg [127:0] pack;wire [127:0] pack_next={cam_data,pack[127:8]};
 reg cam_fault;wire camera_full,camera_empty;wire [9:0] camera_wc,camera_rc;
 wire camera_over,camera_under;wire [127:0] camera_head;
 wire camera_push=cam_armed&&cam_run[1]&&cam_valid&&pack_pos==15;
 wire camera_pop=wvalid&&wready;
 reg eof_send;wire eof_busy,eof_valid;reg eof_take;
 reg [19:0] eof_held; wire [19:0] eof_count; m5b1_mailbox #(.WIDTH(20)) eof_box(.sclk(cam_clk),.dclk(ui_clk),.arst_n(arst_n),
  .send(eof_send),.sdata(eof_held),.busy(eof_busy),.valid(eof_valid),.ddata(eof_count),.take(eof_take));
 // EOF data is held separately because the source counter starts the next frame.
 // This instance is deliberately driven by the held EOF count below.
 always @(posedge cam_clk or negedge crst_n)begin
  if(!crst_n)begin cam_run<=0;cam_vs_d<=0;cam_armed<=0;cam_count<=0;pack_pos<=0;pack<=0;cam_fault<=0;eof_send<=0;eof_held<=0;end
  else begin
   cam_run<={cam_run[0],run&&!stop};cam_vs_d<=cam_vs;eof_send<=0;
   if(cam_vs_d&&!cam_vs&&cam_run[1])begin
    if(cam_armed)begin
     if(cam_count!=FRAME_BYTES||eof_busy)cam_fault<=1;
     else begin eof_send<=1;eof_held<=cam_count;end
    end
    cam_armed<=1;cam_count<=0;pack_pos<=0;
   end
   if(cam_armed&&cam_run[1]&&cam_valid)begin
    pack<=pack_next;pack_pos<=pack_pos+1'b1;cam_count<=cam_count+1'b1;
    if(cam_count>=FRAME_BYTES||(camera_push&&camera_full))cam_fault<=1;
   end
  end
 end
 m5b1_async_fifo camera_fifo(.wclk(cam_clk),.rclk(ui_clk),.arst_n(arst_n),
  .push(camera_push),.wdata(pack_next),.pop(camera_pop),.rdata(camera_head),
  .full(camera_full),.empty(camera_empty),.wcount(camera_wc),.rcount(camera_rc),
  .wreset_done(fifo_ready[0]),.rreset_done(fifo_ready[1]),.overflow(camera_over),.underflow(camera_under));
 // UI: camera writer. Permissions name exactly one WRITING slot.
 localparam W_IDLE=0,W_A=1,W_DATA=2,W_B=3,W_EOF=4;
 reg [2:0] ws;reg [1:0] wslot;reg [19:0] woffset;reg [7:0] wbeat;
 reg [3:0] complete;reg [63:0] capture_id;reg [63:0] slot_id[0:3];
 reg [1:0] latest;reg latest_valid;reg [1:0] rslot;reg lease;
 reg [2:0] rs;reg [19:0] roffset;reg [7:0] rbeat;
 wire display_full,display_empty;wire [9:0] display_wc,display_rc;
 wire display_over,display_under;wire [127:0] display_head;
 reg [3:0] unpack_pos;wire display_pop=display_valid&&pix_request&&unpack_pos==15;
 reg frame_used;reg consume_send;wire consume_busy,consume_valid;wire [0:0] consume_data;
 m5b1_mailbox #(.WIDTH(1)) consumed_box(.sclk(pix_clk),.dclk(ui_clk),.arst_n(arst_n),
  .send(consume_send),.sdata(1'b1),.busy(consume_busy),.valid(consume_valid),.ddata(consume_data),.take(rs==4));
 reg offer_send;wire offer_busy,offer_valid;wire [63:0] offer_id;reg offer_take;
 m5b1_mailbox #(.WIDTH(64)) offer_box(.sclk(ui_clk),.dclk(pix_clk),.arst_n(arst_n),
  .send(offer_send),.sdata(slot_id[rslot]),.busy(offer_busy),.valid(offer_valid),.ddata(offer_id),.take(offer_take));
 reg [19:0] display_count;reg first_pixel;reg pix_fault;
 always @(posedge pix_clk or negedge prst_n)begin
  if(!prst_n)begin pix_run<=0;unpack_pos<=0;pix_data<=0;display_valid<=0;replay_frame_id<=0;display_count<=0;consume_send<=0;offer_take<=0;first_pixel<=1;pix_fault<=0;frame_used<=0;end
  else begin
   pix_run<={pix_run[0],run&&!stop};consume_send<=0;offer_take<=0;
   if(pix_sof)begin first_pixel<=1;display_count<=0;display_valid<=0;unpack_pos<=0;frame_used<=0;end
   if(first_pixel&&pix_request)begin
    first_pixel<=0;
    if(offer_valid&&pix_run[1]&&display_rc>=256)begin
     offer_take<=1;replay_frame_id<=offer_id;display_valid<=1;frame_used<=1;
     pix_data<=display_head[7:0];unpack_pos<=1;display_count<=1;
    end else pix_data<=0;
   end else if(pix_request)begin
    if(display_valid&&pix_run[1])begin
     pix_data<=display_head[unpack_pos*8+:8];unpack_pos<=unpack_pos+1'b1;display_count<=display_count+1'b1;
     if(display_empty)pix_fault<=1;
     if(display_count==FRAME_BYTES-1)begin
      display_valid<=0;consume_send<=1;if(consume_busy)pix_fault<=1;
     end
    end else pix_data<=0;
   end
  end
 end
 m5b1_async_fifo display_fifo(.wclk(ui_clk),.rclk(pix_clk),.arst_n(arst_n),
  .push(rvalid&&rready),.wdata(rdata),.pop(display_pop),.rdata(display_head),
  .full(display_full),.empty(display_empty),.wcount(display_wc),.rcount(display_rc),
  .wreset_done(fifo_ready[2]),.rreset_done(fifo_ready[3]),.overflow(display_over),.underflow(display_under));
 assign camera_bytes={camera_rc,4'b0};assign display_bytes={display_wc,4'b0};
 assign urgent={display_wc<=64,camera_rc>=432};
 assign safe_window=display_wc>=128&&camera_rc<=256&&run&&!stop&&!fault;
 assign write_permission=4'b0001<<wslot;assign read_permission=lease?(4'b0001<<rslot):4'b0;
 assign avalid={rs==1,ws==W_A}&{2{run&&!stop&&!fault}};
 assign aaddr={{8'b0,rslot,22'b0}+roffset,{8'b0,wslot,22'b0}+woffset};
 assign alen=16'h7f7f;assign aid=16'h1101;assign atype=2'b01;
 assign wvalid=ws==W_DATA&&!camera_empty&&!stop;
 assign wdata=camera_head;assign wlast=wbeat==127;
 assign rready=rs==2&&!display_full&&!stop;
 (* async_reg="true" *) reg [1:0] cf,pf,co;
 (* async_reg="true" *) reg [1:0] camera_over_sync,display_under_sync;
 always @(posedge ui_clk or negedge arst_n)begin
  if(!arst_n)begin camera_over_sync<=0;display_under_sync<=0;end
  else begin camera_over_sync<={camera_over_sync[0],camera_over};display_under_sync<={display_under_sync[0],display_under};end
 end
 assign fifo_faults={display_under_sync[1],display_over,camera_under,camera_over_sync[1]};
 integer k;reg [1:0] next_slot;
 always @*begin
  next_slot=wslot+1'b1;
  if(lease&&next_slot==rslot)next_slot=wslot+2'd2;
 end
 always @(posedge ui_clk or negedge arst_n)begin
  if(!arst_n)begin
   ws<=W_IDLE;wslot<=0;woffset<=0;wbeat<=0;complete<=0;capture_id<=0;latest<=0;latest_valid<=0;
   rs<=0;rslot<=0;lease<=0;roffset<=0;rbeat<=0;offer_send<=0;eof_take<=0;fault<=0;
   cf<=0;pf<=0;co<=0;camera_max<=0;display_min<=8192;
   for(k=0;k<4;k=k+1)slot_id[k]<=0;
  end else begin
   cf<={cf[0],cam_fault||camera_over};pf<={pf[0],pix_fault||display_under};
   eof_take<=0;offer_send<=0;
   if(cf[1]||pf[1]||camera_under||display_over||(|rejected))fault<=1;
   if(camera_bytes>camera_max)camera_max<=camera_bytes;
   if(lease&&display_bytes<display_min)display_min<=display_bytes;
   if(run&&!stop&&!fault)begin
    case(ws)
     W_IDLE:if(camera_rc>=128)begin ws<=W_A;wbeat<=0;end
     W_A:if(aready[0])ws<=W_DATA;
     W_DATA:if(wvalid&&wready)begin if(wbeat==127)ws<=W_B;else wbeat<=wbeat+1'b1;end
     W_B:if(bvalid)begin
      if(bresp!=0||bid!=8'h01)fault<=1;
      else if(woffset==FRAME_BYTES-2048)ws<=W_EOF;
      else begin woffset<=woffset+2048;ws<=W_IDLE;end
     end
     W_EOF:if(eof_valid)begin
      eof_take<=1;
      if(eof_count!=FRAME_BYTES)fault<=1;
      else begin
       complete[wslot]<=1;slot_id[wslot]<=capture_id;capture_id<=capture_id+1'b1;latest<=wslot;latest_valid<=1;
       wslot<=next_slot;complete[next_slot]<=0;woffset<=0;ws<=W_IDLE;
      end
     end
    endcase
    case(rs)
     0:if(latest_valid&&complete[latest]&&latest!=wslot&&!offer_busy)begin
      rslot<=latest;lease<=1;roffset<=0;rs<=3;
     end
     1:if(aready[1])begin rs<=2;rbeat<=0;end
     2:if(rvalid&&rready)begin
      if(rresp!=0||rid!=8'h11||rlast!=(rbeat==127))fault<=1;
      if(rbeat==127)begin
       if(roffset==FRAME_BYTES-2048)rs<=4;
       else begin roffset<=roffset+2048;rs<=3;end
      end else rbeat<=rbeat+1'b1;
     end
     3:if(display_wc<=384)rs<=1;
     4:if(consume_valid)begin lease<=0;rs<=0;end
    endcase
    if(lease&&roffset==4096&&rs==3&&!offer_busy)offer_send<=1;
   end
  end
 end
endmodule



