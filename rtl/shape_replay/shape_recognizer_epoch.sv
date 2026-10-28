`timescale 1ns/1ps
// Fixed 1280x720 source; ROI 160..1119 x 90..629. See IMPLEMENTATION.md.
module shape_recognizer_epoch #(parameter ANALYSIS_LIMIT=32768)(
 input wire clk,rst_n,ce,sof,eof,active,support,edge_pixel,source_valid,
 input wire [11:0] x,y,
 input wire [63:0] frame_id,config_generation,epoch,source_display_seq,
 output reg result_done,result_valid,
 output reg [1:0] result_class,
 output reg [63:0] result_frame_id,result_config_generation,result_epoch,result_source_display_seq,
 output reg [1:0] display_class,
 output reg display_valid,
 output reg [63:0] display_frame_id,display_config_generation,display_epoch,display_source_display_seq,
 output wire busy
);
 localparam IDLE=0,CAPTURE=1,READ=2,EVALUATE=3,NORMALIZE=4,SCORE=5,FINISH=6;
 reg [2:0] state;
 assign busy=state!=IDLE;
 // 26 bits: present[25], density[24:22], segments[21:20], right[19:10], left[9:0].
 (* syn_ramstyle="block_ram" *) reg [25:0] rows[0:539];
 reg [25:0] row_q;
 reg [9:0] scan;
 reg [9:0] ex;
 reg [9:0] ey;
 reg [18:0] pixels;
 reg bad,pending;
 reg [63:0] fid,cfg,ep,seq;
 reg [9:0] left_x,right_x;
 reg [9:0] edge_count;
 reg [2:0] segments;
 reg [2:0] gap;
 reg seen;
 reg [9:0] minx,maxx,miny,maxy;
 reg any_edge;
 reg [9:0] width,height,reference_width;
 reg reference_read;
 reg [15:0] budget;
 reg [15:0] remainder;
 reg [6:0] bin;
 reg [8:0] middle_rows,rect_good,circle_good;
 reg [18:0] circle_error;
 reg contour_bad,circle_segments_bad;
 reg [3:0] cap_fragment_rows;
 wire [10:0] cap_height_sum={1'b0,height}+11'd63;
 wire [4:0] cap_row_limit=cap_height_sum>>6;
 wire [9:0] cap_relative_row={1'b0,scan}-{1'b0,miny};
 wire [9:0] cap_from_bottom={1'b0,maxy}-{1'b0,scan};
 wire in_outer_cap=cap_relative_row<cap_row_limit || cap_from_bottom<cap_row_limit;
 reg [15:0] top_bar,bottom_bar;
 wire roi=active && x>=160 && x<=1119 && y>=90 && y<=629;
 wire [9:0] rx=x-160;
 wire [9:0] ry=y-90;
 wire [9:0] next_left=(!seen && edge_pixel)?rx:left_x;
 wire [9:0] next_right=edge_pixel?rx:right_x;
 wire [9:0] next_count=edge_count+(edge_pixel?10'd1:10'd0);
 wire new_segment=edge_pixel && (!seen || gap>=3);
 wire [2:0] next_segments=(new_segment && segments!=7)?segments+1'b1:segments;
 wire next_seen=seen||edge_pixel;
 wire [9:0] current_width=next_right-next_left+1'b1;
 wire [13:0] density_numerator=(next_count<<3)+(current_width>>1);
 reg [2:0] density;
 always @* begin
  if(density_numerator>=current_width*7)density=7;
  else if(density_numerator>=current_width*6)density=6;
  else if(density_numerator>=current_width*5)density=5;
  else if(density_numerator>=current_width*4)density=4;
  else if(density_numerator>=current_width*3)density=3;
  else if(density_numerator>=current_width*2)density=2;
  else if(density_numerator>=current_width)density=1;
  else density=0;
 end
 wire [9:0] row_width=row_q[19:10]-row_q[9:0]+1'b1;
 wire [10:0] center_sum={1'b0,row_q[19:10]}+{1'b0,row_q[9:0]};
 wire [10:0] bbox_center={1'b0,minx}+{1'b0,maxx};
 wire [10:0] center_error=(center_sum>bbox_center)?center_sum-bbox_center:bbox_center-center_sum;
 wire [9:0] rect_error=(row_width>reference_width)?row_width-reference_width:reference_width-row_width;
 wire [12:0] density_product=row_width*row_q[24:22];
 reg [8:0] chord;
 always @* begin
  case(bin)
   // LUT uses center of each 1/64-height band, round-to-nearest, scale 256.
   0,63:chord=45;1,62:chord=77;2,61:chord=99;3,60:chord=116;
   4,59:chord=131;5,58:chord=143;6,57:chord=155;7,56:chord=165;
   8,55:chord=174;9,54:chord=182;10,53:chord=190;11,52:chord=197;
   12,51:chord=203;13,50:chord=209;14,49:chord=214;15,48:chord=219;
   16,47:chord=224;17,46:chord=228;18,45:chord=232;19,44:chord=236;
   20,43:chord=239;21,42:chord=242;22,41:chord=244;23,40:chord=247;
   24,39:chord=249;25,38:chord=251;26,37:chord=252;27,36:chord=253;
   28,35:chord=254;29,34:chord=255;30,33:chord=256;31,32:chord=256;
   default:chord=0;
  endcase
 end
 wire [18:0] chord_product=width*chord;
 wire [9:0] expected_width=(chord_product+19'd128)>>8;
 wire [9:0] chord_error=row_width>expected_width?row_width-expected_width:expected_width-row_width;
 wire in_middle=(scan-miny)*10>=height && (scan-miny)*10<height*9;
 wire rect_match=middle_rows!=0 && rect_good*10>=middle_rows*9 && top_bar*4>=reference_width*3 && bottom_bar*4>=reference_width*3 && width*2>=height && height*2>=width;
 wire circle_match=!circle_segments_bad && cap_fragment_rows<=cap_row_limit && middle_rows!=0 && circle_good*10>=middle_rows*9 && circle_error*100<=middle_rows*width*6 && width*100>=height*90 && width*100<=height*110;
 // Synchronous one-write/one-read RAM; all 540 rows overwritten per qualified frame.
 always @(posedge clk) if(ce) begin
  if(state==CAPTURE && !sof && roi && x==1119)
   rows[ry]<={next_seen,density,(next_segments>2?2'd3:next_segments[1:0]),next_right,next_left};
  if(state==READ)row_q<=rows[scan];
 end
 always @(posedge clk or negedge rst_n) begin
  if(!rst_n)begin
   state<=IDLE;result_done<=0;result_valid<=0;result_class<=0;result_frame_id<=0;result_config_generation<=0;result_epoch<=0;result_source_display_seq<=0;
   display_class<=0;display_valid<=0;display_frame_id<=0;display_config_generation<=0;display_epoch<=0;display_source_display_seq<=0;
   bad<=0;pending<=0;fid<=0;cfg<=0;ep<=0;seq<=0;ex<=0;ey<=0;pixels<=0;left_x<=0;right_x<=0;edge_count<=0;segments<=0;gap<=7;seen<=0;
   minx<=959;maxx<=0;miny<=539;maxy<=0;any_edge<=0;width<=0;height<=0;reference_width<=0;reference_read<=0;budget<=0;scan<=0;remainder<=0;bin<=0;
   middle_rows<=0;rect_good<=0;circle_good<=0;circle_error<=0;contour_bad<=0;circle_segments_bad<=0;cap_fragment_rows<=0;top_bar<=0;bottom_bar<=0;
  end else if(ce)begin
   result_done<=0;
   // SOF has highest priority. No pixel/EOF may accompany SOF.
   if(sof)begin
    display_class<=0;display_valid<=0;display_frame_id<=0;display_config_generation<=config_generation;display_epoch<=epoch;display_source_display_seq<=0;
    if(pending && result_valid && result_config_generation==config_generation && result_epoch==epoch && source_valid)begin
     display_class<=result_class;display_valid<=1;display_frame_id<=result_frame_id;display_source_display_seq<=result_source_display_seq;
    end
    if(state!=IDLE)begin result_done<=1;result_valid<=0;result_class<=0;result_frame_id<=fid;result_config_generation<=cfg;result_epoch<=ep;result_source_display_seq<=seq;end
    pending<=0;state<=CAPTURE;cap_fragment_rows<=0;fid<=frame_id;cfg<=config_generation;ep<=epoch;seq<=source_display_seq;bad<=!source_valid||active||eof;
    ex<=0;ey<=0;pixels<=0;left_x<=0;right_x<=0;edge_count<=0;segments<=0;gap<=7;seen<=0;
    minx<=959;maxx<=0;miny<=539;maxy<=0;any_edge<=0;budget<=0;
   end else begin
    // Display invalidation is immediate on an accepted CE with changed qualification/config.
    if(!source_valid || (config_generation!=display_config_generation || epoch!=display_epoch))begin display_class<=0;display_valid<=0;end
    if(state!=IDLE && (!source_valid || frame_id!=fid || (config_generation!=cfg || epoch!=ep || source_display_seq!=seq)))bad<=1;
    if(state==CAPTURE)begin
     if(roi)begin
      if(rx!=ex || ry!=ey || !support || pixels>=518400)bad<=1;
      if(pixels<518401)pixels<=pixels+1'b1;
      if(edge_pixel)begin
       any_edge<=1;if(rx<minx)minx<=rx;if(rx>maxx)maxx<=rx;if(ry<miny)miny<=ry;if(ry>maxy)maxy<=ry;
      end
      if(x==1119)begin
       ex<=0;if(ey<539)ey<=ey+1'b1;
       left_x<=0;right_x<=0;edge_count<=0;segments<=0;gap<=7;seen<=0;
      end else begin
       ex<=ex+1'b1;left_x<=next_left;right_x<=next_right;edge_count<=next_count;segments<=next_segments;seen<=next_seen;
       if(edge_pixel)gap<=0;else if(gap!=7)gap<=gap+1'b1;
      end
     end
     if(eof)begin
      width<={1'b0,maxx}-{1'b0,minx}+1'b1;height<={1'b0,maxy}-{1'b0,miny}+1'b1;
      // EOF is a separate control beat after all active pixels.
      if(active || pixels!=518400 || !any_edge || minx<16 || maxx>943 || miny<16 || maxy>523)bad<=1;
      scan<=any_edge?miny+(maxy-miny+1)/2:539;reference_read<=1;
      remainder<=32;bin<=0;
      middle_rows<=0;rect_good<=0;circle_good<=0;circle_error<=0;contour_bad<=0;circle_segments_bad<=0;cap_fragment_rows<=0;top_bar<=0;bottom_bar<=0;
      state<=READ;budget<=0;
     end
    end else if(state!=IDLE)begin
     budget<=budget+1'b1;
     if(budget>=ANALYSIS_LIMIT-1)begin bad<=1;state<=FINISH;end
     else case(state)
      READ:state<=EVALUATE;
      EVALUATE:begin
       if(reference_read)begin reference_width<=row_width;reference_read<=0;scan<=miny;state<=READ;end
       else begin
        if(row_q[21:20]>2)begin
         if(!in_outer_cap || center_error>16)circle_segments_bad<=1;
         if(in_outer_cap && cap_fragment_rows!=15)cap_fragment_rows<=cap_fragment_rows+1'b1;
        end
        if(!row_q[25] || (in_middle && (row_q[21:20]>2 || center_error>16)))contour_bad<=1;
        if((scan-miny)*10<height)top_bar<=top_bar+(density_product>>3);
        if((maxy-scan)*10<height)bottom_bar<=bottom_bar+(density_product>>3);
        state<=NORMALIZE;
       end
      end
      NORMALIZE:begin
       if(height!=0 && remainder>=height && bin<63)begin remainder<=remainder-height;bin<=bin+1'b1;end
       else state<=SCORE;
      end
      SCORE:begin
       if(row_q[21:20]>2 && in_outer_cap && row_width>expected_width && chord_error*10>width)circle_segments_bad<=1;
       if(in_middle)begin
        middle_rows<=middle_rows+1'b1;
        if(rect_error*100<=reference_width*4 || rect_error<=3)rect_good<=rect_good+1'b1;
        if(chord_error*10<=width)circle_good<=circle_good+1'b1;
        circle_error<=circle_error+chord_error;
       end
       if(scan>=maxy)state<=FINISH;else begin scan<=scan+1'b1;remainder<=remainder+64;state<=READ;end
      end
      FINISH:begin
       result_done<=1;result_frame_id<=fid;result_config_generation<=cfg;result_epoch<=ep;result_source_display_seq<=seq;
       result_valid<=!bad && source_valid && frame_id==fid && config_generation==cfg && epoch==ep && source_display_seq==seq;
       result_class<=0;
       if(!bad && source_valid && frame_id==fid && config_generation==cfg && epoch==ep && source_display_seq==seq && !contour_bad && width>=80 && width<=440 && height>=80 && height<=440)
        if(rect_match!=circle_match)result_class<=rect_match?2'd2:2'd1;
       pending<=1;state<=IDLE;
      end
      default:state<=IDLE;
     endcase
     // Deadline must terminate even if limit is already exceeded in FINISH.
     if(state==FINISH && budget>=ANALYSIS_LIMIT-1)begin
      result_done<=1;result_valid<=0;result_class<=0;result_frame_id<=fid;result_config_generation<=cfg;result_epoch<=ep;result_source_display_seq<=seq;pending<=1;state<=IDLE;
     end
    end
   end
  end
 end
endmodule
