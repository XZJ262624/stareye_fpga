// Stage1 standalone observer. No output controls production valid/ready or pixels.
module m5c_diag_observer_v2 #(parameter SAMPLE_FRAMES=60)(
 input clk,rst_n,read_clk,record_cancel,
 input context_event,context_valid,input [63:0] context_session,context_token,current_epoch,
 input [767:0] source_descriptor,input context_slot,
 input frame_sof,frame_admit,input [63:0] frame_session,pixel_ticks,
 input kill,input [31:0] abort_reason,
 input final_de,frame_eof,input [11:0] final_x,final_y,
 input final_qualified,legal_bounds,tag_good,frame_ok,invalidate,
 input delayed_weak,delayed_support,delayed_global,local_edge,
 input row_complete,row_equal,row_tag_good,input promoted,
 input [2:0] mode,admit_mode,input enable,input [23:0] fused_rgb,osd_rgb,input osd_de,
 input compare_valid,current_qualified,reference_qualified,
 input [11:0] compare_x,compare_y,reference_x,reference_y,
 input [1:0] current_class,reference_class,input reference_mask,
 input [63:0] compare_session,reference_session,
 output reg record_ready,input record_take,input [5:0] read_word,output reg [63:0] word_data,
 output reg [63:0] dropped,output active);
 localparam IDLE=0,PREP=1,ARMED=2,CAPTURE=3,TAIL=4,SEAL=5,READY=6;
 reg [2:0] state;reg [4:0] prep;reg [5:0] seal;
 reg [15:0] phase;reg [63:0] sid,record_seq;
 reg [31:0] p0,p1,p2,p3,p4,reason;
 reg [63:0] first_sample;reg first_valid,aborted,saturated;
 reg osd_tag,osd_last;reg [2:0] admitted_mode;
 (* syn_ramstyle="block_ram" *) reg [63:0] memory[0:39];
 wire scheduled=phase==0;
 wire owner_good=context_valid&&context_session==sid;
 wire geometry=final_x<1280&&final_y<720;
 wire candidate=final_de&&geometry&&legal_bounds&&final_qualified&&tag_good&&frame_ok&&!invalidate&&delayed_weak&&delayed_support&&delayed_global&&!local_edge;
 wire row_candidate=candidate&&row_complete&&row_equal&&row_tag_good;
 wire cyan=final_de&&geometry&&mode==6&&enable&&fused_rgb==24'h00ffff;
 wire diff_good=compare_valid&&current_qualified&&reference_qualified&&compare_session==sid&&reference_session==sid&&compare_x==reference_x&&compare_y==reference_y&&compare_x<1280&&compare_y<720;
 assign active=state==CAPTURE||state==TAIL;
 function [31:0] inc(input [31:0] value);begin inc=(value==32'hffffffff) ? value : value+1'b1;end endfunction
 reg [5:0] prep_address;reg [63:0] prep_data,seal_data;
 always @*begin
  prep_address=0;prep_data=0;
  case(prep)
   0:begin prep_address=5;prep_data=current_epoch;end
   1:begin prep_address=6;prep_data=context_session;end
   2:begin prep_address=7;prep_data=context_token;end
   3:begin prep_address=8;prep_data=source_descriptor[63:0];end
   4:begin prep_address=9;prep_data=source_descriptor[191:128];end
   5:begin prep_address=10;prep_data=source_descriptor[127:64];end
   6:begin prep_address=11;prep_data=source_descriptor[383:320];end
   7:begin prep_address=12;prep_data=source_descriptor[575:512];end
   8:begin prep_address=13;prep_data=source_descriptor[511:448];end
   9:begin prep_address=14;prep_data=source_descriptor[639:576];end
   10:begin prep_address=15;prep_data=source_descriptor[703:640];end
   11:begin prep_address=16;prep_data={32'd74400000,source_descriptor[735:704]};end
   12:begin prep_address=17;prep_data={32'd96000000,31'd0,context_slot};end
   13:begin prep_address=32;prep_data=64'h0040050142354d53;end
   14:begin prep_address=33;prep_data=64'd256;end
   15,16,17,18,19:begin prep_address=prep+19;prep_data=source_descriptor[(prep-15)*64+:64];end
   20:begin prep_address=39;prep_data=0;end
  endcase
  seal_data=0;
  case(seal)
   0:seal_data={24'd0,admitted_mode,1'b0,saturated,first_valid,aborted,1'b1,32'd1};
   1:seal_data=record_seq;
   2:seal_data=sid;
   18:seal_data={p1,p0};19:seal_data={p3,p2};20:seal_data={32'd0,p4};
   21:seal_data=first_sample;
   22,23:seal_data=first_valid?sid:64'd0;
   24:seal_data=dropped;
   25:seal_data={32'd0,reason};
  endcase
 end
 always @(posedge read_clk) word_data<=memory[read_word];
 reg memory_we;reg [5:0] memory_wa;reg [63:0] memory_wd;
 always @*begin
  memory_we=0;memory_wa=0;memory_wd=0;
  if(rst_n)case(state)
   PREP:if(owner_good&&!kill)begin memory_we=1;memory_wa=prep_address;memory_wd=prep_data;end
   ARMED:if(frame_sof&&scheduled&&frame_admit&&owner_good&&frame_session==sid&&!kill)begin memory_we=1;memory_wa=3;memory_wd=pixel_ticks;end
   CAPTURE:if(kill||!owner_good||frame_eof)begin memory_we=1;memory_wa=4;memory_wd=pixel_ticks;end
   TAIL:if(kill)begin memory_we=1;memory_wa=4;memory_wd=pixel_ticks;end
   SEAL:if(seal<3||seal>=18)begin memory_we=1;memory_wa=seal;memory_wd=seal_data;end
   default:begin end
  endcase
 end
 always @(posedge clk)if(memory_we)memory[memory_wa]<=memory_wd;
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
   state<=IDLE;prep<=0;seal<=0;phase<=0;sid<=0;record_seq<=0;record_ready<=0;dropped<=0;
   p0<=0;p1<=0;p2<=0;p3<=0;p4<=0;reason<=0;first_sample<=0;first_valid<=0;aborted<=0;saturated<=0;osd_tag<=0;osd_last<=0;admitted_mode<=0;
  end else begin
   osd_tag<=state==CAPTURE&&final_de&&mode==6&&enable&&!kill;osd_last<=state==CAPTURE&&frame_eof&&!kill;
   if(frame_sof)begin
    if(phase==SAMPLE_FRAMES-1)phase<=0;else phase<=phase+1'b1;
    if(scheduled&&!(state==ARMED&&frame_admit&&owner_good&&frame_session==sid&&!kill)&&dropped!=64'hffffffffffffffff)dropped<=dropped+1'b1;
   end
   case(state)
    IDLE:if(context_event&&context_valid&&!kill)begin sid<=context_session;prep<=0;state<=PREP;end
    PREP:if(kill||!owner_good)state<=IDLE;else if(prep==20)state<=ARMED;else prep<=prep+1'b1;
    ARMED:begin
     if(kill||!owner_good)state<=IDLE;
     else if(frame_sof&&scheduled&&frame_admit&&frame_session==sid)begin
      state<=CAPTURE;record_seq<=record_seq+1'b1;p0<=0;p1<=0;p2<=0;p3<=0;p4<=0;reason<=0;first_sample<=0;first_valid<=0;aborted<=0;saturated<=0;admitted_mode<=admit_mode;
     end
    end
    CAPTURE:begin
     if(kill||!owner_good)begin aborted<=1;reason<=abort_reason|(!owner_good?32'h80000000:32'd0);osd_tag<=0;osd_last<=0;seal<=0;state<=SEAL;end
     else begin
      if(candidate)p0<=inc(p0);if(row_candidate)p1<=inc(p1);if(promoted)p2<=inc(p2);if(cyan)p3<=inc(p3);
      if(osd_tag&&osd_de&&osd_rgb==24'h00ffff)p4<=inc(p4);
      if((candidate&&p0==32'hffffffff)||(row_candidate&&p1==32'hffffffff)||(promoted&&p2==32'hffffffff)||(cyan&&p3==32'hffffffff)||(osd_tag&&osd_de&&osd_rgb==24'h00ffff&&p4==32'hffffffff))saturated<=1;
      if(!first_valid&&diff_good&&current_class!=reference_class)begin
       first_valid<=1;first_sample<={6'd0,mode,reference_qualified,current_qualified,reference_mask,reference_class,current_class,reference_y,reference_x,compare_y,compare_x};
      end
      if(frame_eof)state<=TAIL;
     end
    end
    TAIL:begin
     if(kill)begin aborted<=1;reason<=abort_reason;end
     else if(osd_tag&&osd_last&&osd_de&&osd_rgb==24'h00ffff)begin p4<=inc(p4);if(p4==32'hffffffff)saturated<=1;end
     osd_tag<=0;osd_last<=0;seal<=0;state<=SEAL;
    end
    SEAL:if(seal==31)begin record_ready<=1;state<=READY;end else seal<=seal+1'b1;
    READY:if(record_take)begin record_ready<=0;state<=IDLE;if(record_cancel&&dropped!=64'hffffffffffffffff)dropped<=dropped+1'b1;end
    default:state<=IDLE;
   endcase
  end
 end
 // synthesis translate_off
 initial if(SAMPLE_FRAMES<1||SAMPLE_FRAMES>65536)$fatal(1,"DIAG_PERIOD_RANGE");
 // synthesis translate_on
endmodule
