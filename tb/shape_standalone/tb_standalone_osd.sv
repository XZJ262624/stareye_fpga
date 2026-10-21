`timescale 1ns/1ps
module tb_standalone_osd;
 reg clk=0,rst=0,ce=1,de=0,hs=1,vs=1;always #5 clk=~clk;
 reg[1:0] shape=0;reg valid=0;reg[2:0] mode=6;
 wire[23:0] rgb,reference_rgb;wire od,oh,ov,rd,rh,rv;
 shape_osd dut(.clk(clk),.ce(ce),.arst_n(rst),.rgb(24'h123456),.de(de),.hs(hs),.vs(vs),.threshold(8'd64),.mode(mode),.filter_id(2'd2),.shape_class(shape),.shape_valid(valid),.fusion_enable(1'b0),.fusion_active(1'b0),.fusion_age_valid(1'b0),.fusion_age(32'd0),.out_rgb(rgb),.out_de(od),.out_hs(oh),.out_vs(ov));
 reference_shape_osd refosd(.clk(clk),.ce(ce),.arst_n(rst),.rgb(24'h123456),.de(de),.hs(hs),.vs(vs),.threshold(8'd64),.mode(mode),.shape_class(shape),.shape_valid(valid),.fusion_enable(1'b0),.fusion_active(1'b0),.fusion_age_valid(1'b0),.fusion_age(32'd0),.out_rgb(reference_rgb),.out_de(rd),.out_hs(rh),.out_vs(rv));
 integer f,x,y,pixels=0,roi_pixels=0,filter_ink=0,holds=0;reg[23:0] expected;reg[26:0] held;integer slot,col,row;reg[34:0] font;reg ink;
 initial begin
  repeat(5)@(negedge clk);rst=1;repeat(8)@(negedge clk);
  for(f=0;f<3;f=f+1)begin
   shape=f==0?1:2;valid=f<2;mode=f==0?6:f==1?5:0;
   vs=0;repeat(4)@(negedge clk);vs=1;
   for(y=0;y<720;y=y+1)begin
    for(x=0;x<1280;x=x+1)begin
     de=1;
     if((pixels%211)==19)begin ce=0;held={rgb,od,oh,ov};repeat(2)begin @(posedge clk);#1;if({rgb,od,oh,ov}!==held)$fatal(1,"OSD_CE_FREEZE");@(negedge clk);end ce=1;holds=holds+1;end
     @(posedge clk);#1;expected=reference_rgb;
     if(x>=664&&x<720&&y>=12&&y<34)begin
      expected=0;slot=(x-668)/16;col=((x-668)%16)/2;row=(y-16)/2;ink=0;font=0;
      if(slot==0)font=35'b01110_10001_10000_10111_10001_10001_01110;
      if(slot==1)font=35'b01110_10001_10001_11111_10001_10001_10001;
      if(slot==2)font=35'b10001_10001_10001_10001_10001_10001_01110;
      if(x>=668&&x<716&&y>=16&&y<30&&col<5)ink=font[34-row*5-col];
      if(ink)begin expected=24'h00ff00;filter_ink=filter_ink+1;end
     end
     if(((x==384||x==895)&&y>=168&&y<=551)||((y==168||y==551)&&x>=384&&x<=895))begin expected=24'h408040;roi_pixels=roi_pixels+1;end
     if({od,oh,ov}!=={rd,rh,rv}||rgb!==expected)$fatal(1,"OSD_REAL_PIXEL_OR_ROI frame=%0d x=%0d y=%0d got=%h want=%h",f,x,y,rgb,expected);
     pixels=pixels+1;@(negedge clk);
    end
    de=0;repeat(12)@(negedge clk);
   end
  end
  if(pixels!=2764800||roi_pixels!=5364||filter_ink==0||holds==0)$fatal(1,"OSD_COVERAGE");
  $display("PASS_STANDALONE_OSD pixels=%0d ROI=%0d GAUink=%0d CEholds=%0d classes=CIRCLE/RECT/UNKNOWN FUSregionUnmodified=1",pixels,roi_pixels,filter_ink,holds);$finish;
 end
 initial begin #50000000;$fatal(1,"OSD_WATCHDOG");end
endmodule
