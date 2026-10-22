`timescale 1ns/1ps
module tb_canny_osd;
 reg clk=0;always #5 clk=~clk;reg rst=0,de=0,hs=1,vs=1;reg[23:0] rgb=0;
 wire[23:0] out,refout;wire od,oh,ov,rd,rh,rv;
 canny_osd dut(.clk(clk),.ce(1'b1),.arst_n(rst),.rgb(rgb),.de(de),.hs(hs),.vs(vs),.threshold(8'd64),.mode(3'd6),.filter_id(2'd2),.fusion_enable(1'b1),.fusion_active(1'b1),.fusion_age_valid(1'b1),.fusion_age(32'd3),.out_rgb(out),.out_de(od),.out_hs(oh),.out_vs(ov));
 reference_gaussian_osd refdut(.clk(clk),.ce(1'b1),.arst_n(rst),.rgb(rgb),.de(de),.hs(hs),.vs(vs),.threshold(8'd64),.mode(3'd6),.filter_id(2'd2),.shape_class(2'd2),.shape_valid(1'b1),.fusion_enable(1'b1),.fusion_active(1'b1),.fusion_age_valid(1'b1),.fusion_age(32'd3),.out_rgb(refout),.out_de(rd),.out_hs(rh),.out_vs(rv));
 integer v,h,checked=0,removed=0;reg oldarea;reg[23:0] original;
 initial begin
  repeat(5)@(negedge clk);rst=1;repeat(8)@(negedge clk);
  for(v=0;v<750;v=v+1)for(h=0;h<1650;h=h+1)begin
   @(negedge clk);vs=v>=5;hs=h>=40;de=v>=25&&v<745&&h>=260&&h<1540;rgb={h[7:0],v[7:0],8'h7b};
   @(posedge clk);oldarea=dut.x>=444&&dut.x<644&&dut.y>=12&&dut.y<34;original=rgb;#1;
   if({od,oh,ov}!=={rd,rh,rv})$fatal(1,"OSD_RASTER_CHANGED");
   if(oldarea)begin if(out!==original)$fatal(1,"OLD_PREV_REGION_NOT_REMOVED");removed=removed+1;end
   else if(out!==refout)$fatal(1,"OSD_FILTER_MODE_OR_FUSION_CHANGED");
   checked=checked+1;
  end
  if(removed==0)$fatal(1,"OSD_COVERAGE");
  $display("PASS_CANNY_OSD raster=%0d former_PREV_passthrough=%0d all_other_pixels_identical=1",checked,removed);$finish;
 end
endmodule
