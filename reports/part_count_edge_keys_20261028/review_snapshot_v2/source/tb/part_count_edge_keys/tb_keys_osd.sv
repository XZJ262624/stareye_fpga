`timescale 1ns/1ps
module tb_keys_osd;
reg clk=0;always #5 clk=~clk;reg rst_n=0,ce=1,sof=0,de=0,view=0;reg [7:0] hi=48;reg [11:0] x=0,y=0;
wire [23:0] rgb;wire od,oh,ov;
part_keys_osd dut(.clk(clk),.rst_n(rst_n),.ce(ce),.sof(sof),.gray(8'h63),.mask(1'b1),.de(de),.hs(1'b1),.vs(1'b1),.view(view),.high_threshold(hi),.x(x),.y(y),.count_valid(1'b0),.have_value(1'b0),.busy(1'b0),.count(4'd0),.error_code(4'd0),.confirmations(2'd0),.ticks(64'd0),.count_tick(64'd0),.diag_held(1'b0),.diag_have(1'b0),.diag_armed(1'b0),.diag_record(768'd0),.out_rgb(rgb),.out_de(od),.out_hs(oh),.out_vs(ov));
reg gold[0:4*396*14-1];string path;integer f,xx,yy,n=0,index;reg [23:0] saved;
task tick;begin @(posedge clk);#2;@(negedge clk);end endtask
initial begin
 if(!$value$plusargs("DATA=%s",path))$fatal(1,"OSD_DATA");$readmemh({path,"/osd_ext.mem"},gold);
 repeat(4)tick();rst_n=1;repeat(4)tick();
 for(f=0;f<4;f=f+1)begin
  hi=f%2==0?8:128;view=f>=2;sof=1;tick();sof=0;
  // A subsequent uncommitted live input must never change this display frame.
  hi=72;view=!view;
  for(yy=0;yy<14;yy=yy+1)for(xx=0;xx<396;xx=xx+1)begin
   x=16+xx;y=56+yy;de=1;index=f*396*14+yy*396+xx;tick();
   if(rgb!==(gold[index]?24'hffffff:24'h0)||!od)$fatal(1,"OSD_EXT f=%d x=%d y=%d",f,xx,yy);n=n+1;
  end
  x=100;y=200;tick();if(rgb!==(f>=2?24'hffffff:24'h636363))$fatal(1,"OSD_VIEW_LATCH");
  ce=0;saved=rgb;x=16;y=56;sof=1;repeat(7)tick();if(rgb!==saved)$fatal(1,"OSD_CE");ce=1;sof=0;de=0;tick();
 end
 $display("PASS_KEYS_OSD pixels=%0d H008_L004_H128_L064 RAW_MSK frame_latch CE",n);$finish;
end
endmodule
