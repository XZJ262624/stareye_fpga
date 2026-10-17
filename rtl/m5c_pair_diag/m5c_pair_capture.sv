// Independent pair diagnostic capture. All pixels are captured, never P0-only.
module m5c_pair_capture #(parameter WIDTH=1280,HEIGHT=720,SEPARATE_ELIGIBILITY=0)(
 input ui_clk,pix_clk,arst_n,input arm,input [63:0] arm_session,input cancel,
 output arm_busy,output done_valid,output [31:0] done_reason,input done_take,
 input source_tap_valid,source_tap_qualified,
 input ce,frame_sof,frame_admit,mode_cov,fusion_enabled,kill,identity_ok,capture_eligible,
 input [63:0] session,current_source_frame,display_seq,pixel_ticks,
 input final_de,input [11:0] final_x,final_y,input [1:0] final_class,
 input support,local_edge,accepted_domain,row_complete,row_tag,
 output [127:0] data,output empty,input pop,output [9:0] count,
 output [1:0] reset_done,output [1:0] fifo_faults);
 wire av;wire [63:0] asid;reg atake;
 m5b1_mailbox #(.WIDTH(64)) arm_box(.sclk(ui_clk),.dclk(pix_clk),.arst_n(arst_n),.send(arm),.sdata(arm_session),.busy(arm_busy),.valid(av),.ddata(asid),.take(atake));
 (* async_reg="true" *)reg [1:0] release_pix,cancel_sync;
 always @(posedge pix_clk or negedge arst_n)
  if(!arst_n)begin release_pix<=0;cancel_sync<=0;end
  else begin release_pix<={release_pix[0],1'b1};cancel_sync<={cancel_sync[0],cancel};end
 wire prst=release_pix[1];
 // Raw tap qualification is frame-sticky and retained through the delayed final tail.
 reg source_frame_qualified;
 always @(posedge pix_clk or negedge prst)
  if(!prst)source_frame_qualified<=0;
  else if(ce&&frame_sof)source_frame_qualified<=source_tap_valid&&source_tap_qualified;
  else if(ce&&source_tap_valid&&!source_tap_qualified)source_frame_qualified<=0;
 wire live_capture_eligible=SEPARATE_ELIGIBILITY?capture_eligible:1'b1;
 wire current_source_qualified=frame_sof?(source_tap_valid&&source_tap_qualified):source_frame_qualified;

 initial begin if(WIDTH<=0||HEIGHT<=0||(WIDTH*HEIGHT)%800!=0)$fatal(1,"PAIR_PACK5_GEOMETRY");end
 localparam IDLE=0,WAIT=1,CAPTURE=2,TAIL0=3,TAIL1=4,FINISH=5;
 reg [2:0] state;reg [63:0] sid,source_id,seq,sof_tick,eof_tick;
 wire stable_tail_identity=identity_ok&&session==sid&&current_source_frame==source_id&&display_seq==seq;
 reg [4:0] sample_lane;
 reg [19:0] position;reg [11:0] ex,ey;reg [127:0] pack;reg push;
 wire full,over,under;wire [9:0] wc;reg send;reg [31:0] reason;wire send_busy;
 wire [7:0] sample={3'b0,accepted_domain,local_edge,support,final_class};
 wire can_push=!full&&!(push&&wc==511);
 wire sample_bad=final_x!=ex||final_y!=ey||final_class==3||!row_complete||!row_tag;
 m5b1_async_fifo fifo(.wclk(pix_clk),.rclk(ui_clk),.arst_n(arst_n),.push(push),.wdata(pack),.pop(pop),.rdata(data),.full(full),.empty(empty),.wcount(wc),.rcount(count),.wreset_done(reset_done[0]),.rreset_done(reset_done[1]),.overflow(over),.underflow(under));
 (* async_reg="true" *)reg [1:0] over_ui;
 always @(posedge ui_clk or negedge arst_n)if(!arst_n)over_ui<=0;else over_ui<={over_ui[0],over};
 assign fifo_faults={under,over_ui[1]};
 m5b1_mailbox #(.WIDTH(32)) result_box(.sclk(pix_clk),.dclk(ui_clk),.arst_n(arst_n),.send(send),.sdata(reason),.busy(send_busy),.valid(done_valid),.ddata(done_reason),.take(done_take));
 always @(posedge pix_clk or negedge prst)begin
  if(!prst)begin state<=IDLE;atake<=0;sid<=0;source_id<=0;seq<=0;sof_tick<=0;eof_tick<=0;position<=0;sample_lane<=0;ex<=0;ey<=0;pack<=0;push<=0;send<=0;reason<=0;end
  else begin
   atake<=0;push<=0;send<=0;
   case(state)
    IDLE:if(av&&!send_busy)begin atake<=1;sid<=asid;reason<=0;position<=0;sample_lane<=0;ex<=0;ey<=0;state<=WAIT;end
    WAIT:if(cancel_sync[1])begin reason<=1;state<=FINISH;end
     else if(ce&&frame_sof)begin
      if(frame_admit&&mode_cov&&fusion_enabled&&!kill&&identity_ok&&live_capture_eligible&&current_source_qualified&&session==sid&&display_seq==sid)begin source_id<=current_source_frame;seq<=display_seq;sof_tick<=pixel_ticks;state<=CAPTURE;end
      else begin reason<=2;state<=FINISH;end
     end
    CAPTURE:begin
     if(frame_sof||!current_source_qualified||cancel_sync[1]||kill||!identity_ok||!live_capture_eligible||!ce||session!=sid||current_source_frame!=source_id||display_seq!=seq)begin reason<=3;state<=FINISH;end
     else if(final_de)begin
      if(sample_bad)begin reason<=4;state<=FINISH;end
      else begin
       pack[sample_lane*5+:5]<=sample[4:0];pack[127:125]<=0;position<=position+1'b1;sample_lane<=sample_lane==24?0:sample_lane+1'b1;
       if(sample_lane==24)begin
        if(!can_push)begin reason<=5;state<=FINISH;end
        else begin push<=1;end
       end
       if(ex==WIDTH-1)begin ex<=0;ey<=ey+1'b1;end else ex<=ex+1'b1;
       if(position==WIDTH*HEIGHT-1)begin eof_tick<=pixel_ticks;if(can_push)state<=TAIL0;end
      end
     end
    end
    TAIL0:if(frame_sof||!current_source_qualified||cancel_sync[1]||kill||!stable_tail_identity)begin reason<=6;state<=FINISH;end
     else if(can_push)begin push<=1;pack<={seq,source_id};state<=TAIL1;end
    TAIL1:if(frame_sof||!current_source_qualified||cancel_sync[1]||kill||!stable_tail_identity)begin reason<=6;state<=FINISH;end
     else if(can_push)begin push<=1;pack<={eof_tick,sof_tick};state<=FINISH;end
    FINISH:if(!send_busy)begin send<=1;state<=IDLE;end
    default:state<=IDLE;
   endcase
  end
 end
endmodule


