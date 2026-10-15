// Single pixel clock core. Reference pixels are supplied by a locked-row
// adapter; this is NOT a DDR reader or asynchronous cache implementation.
module m5c_row_fusion #(parameter WIDTH=1280,HEIGHT=720,H_TOTAL=1650,REF_STAGE=1)(
 input context_block,output context_quiet,output reg context_tail_fault,
 input clk,rst_n,ce,sof,admit,invalidate,input [319:0] identity_in,
 input tap_valid,tap_qualified,input [11:0] tap_x,tap_y,
 input [1:0] current_class,input current_support,
 input ref_ready,input [1:0] ref_class,input ref_global,
 input [319:0] ref_identity,input [11:0] ref_x,ref_y,
 input [3:0] support_radius,
 input final_de,input [11:0] final_x,final_y,input local_edge,
 output diag_tag_good,diag_bounds,diag_weak,diag_support,diag_global,diag_row_complete,diag_row_equal,diag_row_tag,
 output fused_edge,promoted,output reg frame_ok,
 output reg row_retire,output reg [11:0] retired_y);
 reg [319:0] frame_identity;
 reg [63:0] frame_cookie;
 reg row_equal[0:3],row_complete[0:3];reg [11:0] row_y[0:3];reg [63:0] row_cookie[0:3];
 reg equal_so_far;reg [11:0] expect_x,expect_y;
 wire [1:0] bank=tap_y[1:0],obank=final_y[1:0];
 wire identity_good = ref_identity == frame_identity;
 wire reference_good=ref_ready&&ref_x==tap_x&&ref_y==tap_y&&
  (sof?ref_identity==identity_in:identity_good);
 wire pixel_equal=current_class==ref_class&&current_class!=3&&ref_class!=3;
 wire coords_good=sof?(tap_x==0&&tap_y==0):(tap_x==expect_x&&tap_y==expect_y);
 wire effective_ok=sof?admit:frame_ok;
 wire [63:0] input_cookie=sof?frame_cookie+1'b1:frame_cookie;
 wire [91:0] delayed;wire delay_ready;
 // Same accepted-CE delay primitive as the unchanged M5A final packet.
 m5a_packet_delay #(.BITS(92),.DELAY(H_TOTAL+3-REF_STAGE)) align(
  .clk(clk),.ce(ce),.rst_n(rst_n),
  .in_packet({input_cookie,tap_x,tap_y,(tap_valid&&!context_block&&!context_tail_fault),current_class==1,current_support,ref_global}),
  .out_packet(delayed),.out_ready(delay_ready));
 wire tag_good=delay_ready&&delayed[27:16]==final_x&&delayed[15:4]==final_y&&
  delayed[91:28]==frame_cookie&&delayed[3];
 wire bounds=final_x>=support_radius&&final_y>=support_radius&&
  final_x<WIDTH-support_radius&&final_y<HEIGHT-support_radius;
 // Count only new edges; weak pixels already in local Canny remain local.
 assign context_quiet=!frame_ok&&!row_complete[0]&&!row_complete[1]&&!row_complete[2]&&!row_complete[3]&&!row_retire;
 assign promoted=!context_block&&!context_tail_fault&&final_de&&!local_edge&&frame_ok&&!invalidate&&tag_good&&bounds&&
  row_complete[obank]&&row_equal[obank]&&row_y[obank]==final_y&&row_cookie[obank]==frame_cookie&&
  delayed[2] && delayed[1] && delayed[0];
 assign diag_tag_good=tag_good;assign diag_bounds=bounds;
 assign diag_weak=delayed[2];assign diag_support=delayed[1];assign diag_global=delayed[0];
 assign diag_row_complete=row_complete[obank];assign diag_row_equal=row_equal[obank];
 assign diag_row_tag=row_y[obank]==final_y&&row_cookie[obank]==frame_cookie;
 assign fused_edge=local_edge||promoted;
 integer k;
 always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
   context_tail_fault<=0;frame_ok<=0;frame_identity<=0;frame_cookie<=0;equal_so_far<=0;expect_x<=0;expect_y<=0;row_retire<=0;retired_y<=0;
   for(k=0;k<4;k=k+1)begin row_equal[k]<=0;row_complete[k]<=0;row_y[k]<=0;row_cookie[k]<=0;end
  end else if(context_block||context_tail_fault)begin
   frame_ok<=0;row_retire<=0;equal_so_far<=0;
   for(k=0;k<4;k=k+1)row_complete[k]<=0;
  end else if(ce&&sof&&frame_cookie==64'hffffffffffffffff)begin
   context_tail_fault<=1;frame_ok<=0;row_retire<=0;
   for(k=0;k<4;k=k+1)row_complete[k]<=0;
  end else begin
   row_retire<=0;
   // A wall-clock age/stop invalidation is sticky even while CE is paused.
   if(invalidate)frame_ok<=0;
   if(ce)begin
    if(sof)begin
     frame_ok<=admit&&!invalidate;frame_identity<=identity_in;frame_cookie<=frame_cookie+1'b1;
     expect_x<=0;expect_y<=0;
     for(k=0;k<4;k=k+1)row_complete[k]<=0;
    end else if(invalidate) frame_ok <= 0;
    if(tap_valid)begin
     if(!tap_qualified||!coords_good||!reference_good)frame_ok<=0;
     if(tap_x==0)begin
      row_complete[bank]<=0;row_y[bank]<=tap_y;row_cookie[bank]<=input_cookie;
      equal_so_far<=pixel_equal;
     end else equal_so_far<=equal_so_far&&pixel_equal;
     if(tap_x==WIDTH-1)begin
      row_equal[bank] <= equal_so_far && pixel_equal;
      row_complete[bank]<=1;expect_x<=0;expect_y<=tap_y+1'b1;
     end else begin expect_x<=tap_x+1'b1;expect_y<=tap_y;end
    end
    if(final_de&&final_x==WIDTH-1)begin
     row_retire<=1;retired_y<=final_y;
     // Four banks exceed the two concurrently live lines at this latency.
     if(row_y[obank]==final_y)row_complete[obank]<=0;
    end
    if(final_de&&!tag_good)frame_ok<=0;
   end
  end
 end
 // synthesis translate_off
 initial if(WIDTH<2||H_TOTAL<WIDTH||H_TOTAL+3<=WIDTH)$fatal(1,"M5C_ROW_WINDOW");
 // synthesis translate_on
endmodule
