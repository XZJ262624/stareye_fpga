// Byte camera -> 128-bit DDR, 128-bit DDR -> byte display. Full RT bursts.
// A frame becomes COMPLETE only after its last real B and camera EOF validation.
// Display holds READ_LEASE until the last pixel consumed and every R has drained.
module replay_video_dma #(parameter FRAME_BYTES=921600,CLIP_FRAMES=32)(
 input [1:0] command,input command_valid,
 output reg [1:0] replay_state,output reg [5:0] recorded,play_index,output reg clip_valid,
 output reg [14:0] pixel_status,
 input ui_clk,cam_clk,pix_clk,arst_n,run,stop,input [63:0] epoch,
 input cam_vs,cam_valid,input [7:0] cam_data,input pix_sof,pix_request,
 output [7:0] pix_data,output [63:0] replay_frame_id,output pix_qualified,
 output reg display_valid,output reg fault,
 output [1:0] avalid,input [1:0] aready,output [63:0] aaddr,
 output [15:0] alen,aid,output [1:0] atype,
 output wvalid,wlast,output [127:0] wdata,input wready,
 input bvalid,input [1:0] bresp,input [7:0] bid,
 input rvalid,rlast,input [127:0] rdata,input [1:0] rresp,input [7:0] rid,
 output rready,input [1:0] rejected,
 output [31:0] write_base,read_base,output read_active,
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
 reg [2:0] ws;reg [5:0] wslot;reg [19:0] woffset;reg [7:0] wbeat;
 reg [35:0] complete;reg [63:0] capture_id;reg [63:0] slot_id[0:35];
 reg [5:0] latest;reg latest_valid;reg [5:0] rslot;reg lease;
 localparam LIVE=0,REC=1,PLAY=2,PAUSE=3;
 reg [1:0] live_cursor,sample_gap,repeat_count;
 reg [31:0] record_generation,write_generation;
 reg read_clip;reg [5:0] read_index;reg [14:0] read_status;
 function automatic [31:0] slot_base(input [5:0] slot);
  begin if(slot<4)slot_base={8'd0,slot[1:0],22'd0};
  else slot_base=32'h02000000+(({26'd0,slot}-4)<<20);end
 endfunction
 assign write_base=slot_base(wslot);assign read_base=slot_base(rslot);assign read_active=lease;
 wire clip_reader=(replay_state==PLAY||replay_state==PAUSE)&&clip_valid;
 wire [5:0] wanted_slot=clip_reader?(6'd4+play_index):latest;
 reg [2:0] rs;reg [19:0] roffset;reg [7:0] rbeat;
 wire display_full,display_empty;wire [9:0] display_wc,display_rc;
 wire display_over,display_under;wire [127:0] display_head;
 reg [3:0] unpack_pos;wire display_pop=display_valid&&pix_request&&unpack_pos==15;
 reg frame_used;reg consume_send;wire consume_busy,consume_valid;wire [0:0] consume_data;
 m5b1_mailbox #(.WIDTH(1)) consumed_box(.sclk(pix_clk),.dclk(ui_clk),.arst_n(arst_n),
  .send(consume_send),.sdata(1'b1),.busy(consume_busy),.valid(consume_valid),.ddata(consume_data),.take(rs==4));
 reg offer_send;wire offer_busy,offer_valid;wire [78:0] offer_payload;wire [63:0] offer_id=offer_payload[63:0];reg offer_take;
 m5b1_mailbox #(.WIDTH(79)) offer_box(.sclk(ui_clk),.dclk(pix_clk),.arst_n(arst_n),
  .send(offer_send),.sdata({read_status,slot_id[rslot]}),.busy(offer_busy),.valid(offer_valid),.ddata(offer_payload),.take(offer_take));
 reg [19:0] display_count;reg first_pixel;reg pix_fault;reg [63:0] replay_id_hold;
 // lcd_driver samples this FWFT byte on the request edge. Its RGB/DE
 // register is the one required data stage; another DMA register shifts rows.
 wire admit=offer_valid&&pix_run[1]&&display_rc>=256;
 assign pix_qualified=pix_request&&pix_run[1]&&!display_empty&&(first_pixel?admit:display_valid);
 assign pix_data=pix_qualified?display_head[unpack_pos*8+:8]:8'd0;
 assign replay_frame_id=first_pixel?offer_id:replay_id_hold;
 always @(posedge pix_clk or negedge prst_n)begin
  if(!prst_n)begin pixel_status<=0;pix_run<=0;unpack_pos<=0;display_valid<=0;replay_id_hold<=0;display_count<=0;consume_send<=0;offer_take<=0;first_pixel<=1;pix_fault<=0;frame_used<=0;end
  else begin
   pix_run<={pix_run[0],run&&!stop};consume_send<=0;offer_take<=0;
   if(pix_sof)begin if(frame_used&&display_count!=FRAME_BYTES)pix_fault<=1;first_pixel<=1;display_count<=0;display_valid<=0;unpack_pos<=0;frame_used<=0;end
   if(first_pixel&&pix_request)begin
    first_pixel<=0;
    if(admit)begin
     pixel_status<=offer_payload[78:64];offer_take<=1;replay_id_hold<=offer_id;display_valid<=1;frame_used<=1;
     unpack_pos<=1;display_count<=1;
    end
   end else if(pix_request)begin
    if(display_valid&&pix_run[1])begin
     unpack_pos<=unpack_pos+1'b1;display_count<=display_count+1'b1;
     if(display_empty)pix_fault<=1;
     if(display_count==FRAME_BYTES-1)begin
      display_valid<=0;consume_send<=1;if(consume_busy)pix_fault<=1;
     end
    end
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

 assign avalid={rs==1,ws==W_A}&{2{run&&!stop&&!fault}};
 assign aaddr={read_base+roffset,write_base+woffset};
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
 integer k;reg [1:0] next_live;reg [5:0] next_slot;
 always @*begin
  next_live=live_cursor+1'b1;
  if(lease&&rslot<4&&next_live==rslot[1:0])next_live=live_cursor+2'd2;
  next_slot={4'b0,next_live};
  // The prior reader lease must have left the clip before overwrite begins.
  // A command on this boundary defers a new selection until the next frame.
  if(replay_state==REC&&sample_gap==0&&recorded<CLIP_FRAMES&&
     !(lease&&rslot>=4)&&!command_valid)
   next_slot=6'd4+recorded;
 end
 always @(posedge ui_clk or negedge arst_n)begin
  if(!arst_n)begin
   replay_state<=LIVE;recorded<=0;play_index<=0;clip_valid<=0;live_cursor<=0;sample_gap<=0;repeat_count<=0;record_generation<=0;write_generation<=0;read_clip<=0;read_index<=0;read_status<=0;ws<=W_IDLE;wslot<=0;woffset<=0;wbeat<=0;complete<=0;capture_id<=0;latest<=0;latest_valid<=0;
   rs<=0;rslot<=0;lease<=0;roffset<=0;rbeat<=0;offer_send<=0;eof_take<=0;fault<=0;
   cf<=0;pf<=0;co<=0;camera_max<=0;display_min<=8192;
   for(k=0;k<36;k=k+1)slot_id[k]<=0;
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
       complete[wslot]<=1;slot_id[wslot]<=capture_id;capture_id<=capture_id+1'b1;
       // A sampled frame is not mislabelled as a freshly updated live slot.
       if(wslot<4)begin latest<=wslot;latest_valid<=1;end
       if(wslot>=4&&replay_state==REC&&write_generation==record_generation)begin
        if(wslot!=6'd4+recorded)fault<=1;
        else begin
         recorded<=recorded+1'b1;
         if(recorded==CLIP_FRAMES-1)begin clip_valid<=1;replay_state<=PLAY;play_index<=0;repeat_count<=0;end
        end
       end
       if(next_slot>=4)begin sample_gap<=3;write_generation<=record_generation;end
       else begin live_cursor<=next_live;if(sample_gap!=0)sample_gap<=sample_gap-1'b1;end
       wslot<=next_slot;complete[next_slot]<=0;woffset<=0;ws<=W_IDLE;
      end
     end
    endcase
    case(rs)
     0:if((clip_reader||latest_valid)&&complete[wanted_slot]&&wanted_slot!=wslot&&!offer_busy)begin
      rslot<=wanted_slot;lease<=1;roffset<=0;rs<=3;
      read_clip<=clip_reader;read_index<=play_index;
      read_status<={clip_valid,recorded,play_index,replay_state};
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
     4:if(consume_valid)begin
      lease<=0;rs<=0;
      // Advance only when all R beats AND the last actual display pixel finish.
      if(read_clip&&clip_valid&&replay_state==PLAY&&read_index==play_index)begin
       if(repeat_count==3)begin repeat_count<=0;play_index<=(play_index==CLIP_FRAMES-1)?0:play_index+1'b1;end
       else repeat_count<=repeat_count+1'b1;
      end
     end
    endcase
    if(lease&&roffset==4096&&rs==3&&!offer_busy)offer_send<=1;
    // Commands have priority over completion on the same clock. Record start
    // invalidates the prior clip immediately; a cancelled write generation can
    // never become part of the next recording. No local FIFO/DDR resets occur.
    if(command_valid)case(command)
     0:case(replay_state)
      LIVE:begin replay_state<=REC;clip_valid<=0;recorded<=0;sample_gap<=0;record_generation<=record_generation+1'b1;play_index<=0;repeat_count<=0;end
      PLAY:replay_state<=PAUSE;
      PAUSE:replay_state<=PLAY;
     endcase
     1:begin replay_state<=LIVE;if(replay_state==REC)clip_valid<=0;repeat_count<=0;end
     2:if(replay_state==LIVE&&clip_valid)begin replay_state<=PLAY;play_index<=0;repeat_count<=0;end
    endcase
   end
  end
 end
endmodule



