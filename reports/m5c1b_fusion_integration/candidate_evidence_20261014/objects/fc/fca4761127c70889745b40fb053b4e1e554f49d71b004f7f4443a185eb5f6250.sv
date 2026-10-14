// RAM data remains immutable from READY publication through retirement ACK.
// A session's complete tuple is frozen by display_session until ui_empty.
module m5c_line_cache(
 input ui_clk,pix_clk,rst_n,
 input write_valid,write_mask,input [2:0] write_bank,input [4:0] write_beat,
 input [127:0] write_data,input commit,input [11:0] commit_row,input [63:0] commit_session,
 output [7:0] free_banks,output ui_empty,
 input context_block,input [63:0] context_sid,expected_sid,input context_confirmed,cancel_now,
 output response_quiet,
 input ce,read_valid,input [11:0] read_x,read_y,input [63:0] read_session,
 output reg ref_ready,output reg [1:0] ref_class,output reg ref_mask,
 output reg [11:0] ref_x,ref_y,output reg [63:0] ref_session,
 input retire,input [11:0] retire_row,input flush,
 output [7:0] pixel_ready,output prefilled,output reg cache_fault);
 (* async_reg="true", syn_srlstyle="registers", syn_keep="true" *) reg [1:0] pixel_release;
 always @(posedge pix_clk or negedge rst_n)
  if(!rst_n)pixel_release<=0;else pixel_release<={pixel_release[0],1'b1};
 wire pixel_rst_n=pixel_release[1];
 (* syn_ramstyle="block_ram" *) reg [127:0] classes[0:159];
 (* syn_ramstyle="block_ram" *) reg [127:0] masks[0:79];
 wire [7:0] busy,valid;wire [11:0] row_tag[0:7];wire [7:0] take,row_matches;
 genvar b;
 generate for(b=0;b<8;b=b+1)begin:bank
  m5b1_mailbox #(.WIDTH(12)) ready_box(
   .sclk(ui_clk),.dclk(pix_clk),.arst_n(rst_n),
   .send(commit&&context_confirmed&&!cancel_now&&commit_session==expected_sid&&commit_row[2:0]==b),.sdata(commit_row),
   .busy(busy[b]),.valid(valid[b]),.ddata(row_tag[b]),.take(take[b]));
  assign take[b]=valid[b]&&(context_block||flush||(retire&&retire_row==row_tag[b][11:0]));
  assign row_matches[b]=valid[b]&&!context_block&&context_sid==read_session&&(row_tag[b]==read_y);
 end endgenerate
 assign free_banks=~busy;assign ui_empty=!(|busy);assign pixel_ready=valid;
 assign prefilled=!context_block&&context_sid==read_session&&(&valid[3:0])&&row_tag[0]==12'd0&&
  row_tag[1]==12'd1&&row_tag[2]==12'd2&&row_tag[3]==12'd3;
 always @(posedge ui_clk)begin
  if(write_valid&&context_confirmed&&!cancel_now&&commit_session==expected_sid&&!busy[write_bank])begin
   if(write_mask&&write_beat<10)masks[write_bank*10+write_beat]<=write_data;
   if(!write_mask&&write_beat<20)classes[write_bank*20+write_beat]<=write_data;
  end
 end
 always @(posedge ui_clk or negedge rst_n)begin
  if(!rst_n)cache_fault<=0;
  else if((!cancel_now&&(write_valid||commit)&&(!context_confirmed||commit_session!=expected_sid))||
          (write_valid&&(busy[write_bank]||write_beat>=(write_mask?10:20)))||
          (commit&&busy[commit_row[2:0]]))cache_fault<=1;
 end
 reg [127:0] class_word,mask_word;
 reg selected_match;
 always @*begin
  case(read_y[2:0])
   0:selected_match=row_matches[0];1:selected_match=row_matches[1];
   2:selected_match=row_matches[2];3:selected_match=row_matches[3];
   4:selected_match=row_matches[4];5:selected_match=row_matches[5];
   6:selected_match=row_matches[6];7:selected_match=row_matches[7];
   default:selected_match=0;
  endcase
 end
 assign response_quiet=!ref_ready;
 wire response_good=read_valid&&read_x<1280&&read_y<720&&selected_match&&!flush&&!context_block;
 reg [5:0] class_offset;reg [6:0] mask_offset;
 // Block RAM read, selection from registered word and matching x offset.
 always @(posedge pix_clk)if(ce&&read_valid&&read_x<1280&&read_y<720)begin
  class_word<=classes[read_y[2:0]*20+read_x[11:6]];
  mask_word<=masks[read_y[2:0]*10+read_x[11:7]];
 end
 always @*begin
  ref_class=class_word[class_offset*2+:2];ref_mask=mask_word[mask_offset];
 end
 always @(posedge pix_clk or negedge pixel_rst_n)begin
  if(!pixel_rst_n)begin ref_ready<=0;ref_x<=0;ref_y<=0;ref_session<=0;class_offset<=0;mask_offset<=0;end
  else if(context_block||flush)ref_ready<=ref_ready;
  else if(ce)begin
   ref_ready<=response_good;
   // Valid response proves actual stored bank session == read_session in this
   // very CE. Register that proven value with RAM data/coordinates; never use
   // an unqualified current session to label stale data. Invalid identity is0.
   ref_x<=read_x;ref_y<=read_y;ref_session<=response_good?context_sid:64'd0;
   class_offset<=read_x[5:0];mask_offset<=read_x[6:0];
  end
 end
endmodule
