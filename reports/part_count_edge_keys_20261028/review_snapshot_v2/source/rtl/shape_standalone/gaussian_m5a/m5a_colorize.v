`timescale 1ns/1ps
module m5a_colorize(input de,input [2:0] mode,input [7:0] raw,legacy_mag,nms_gray,
 input legacy_bin,overlay_valid,overlay_edge,canny_valid,canny_edge,output reg [23:0] rgb);
 always @* begin
  rgb=0;
  if(de)case(mode)
   0:rgb={3{raw}};
   1:rgb={3{legacy_mag}};
   2:rgb={24{legacy_bin}};
   3:rgb=(overlay_valid && overlay_edge)?24'hff0000:{3{raw}};
   4:rgb={3{nms_gray}};
   5:rgb={24{canny_valid && canny_edge}};
   6:rgb=(canny_valid && canny_edge)?24'hff0000:{3{raw}};
   default:rgb={3{raw}};
  endcase
 end
endmodule
