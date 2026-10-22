`timescale 1ns/1ps
module tb_wide_adapter_osd;
 reg clk=0;always #5 clk=~clk;
 reg rst=0,ce=1,ss=0,de=0,vs=0,hs=1;reg[11:0] x=0,y=0;reg[63:0] fid=1,seq=101;reg edge_pixel=0;
 wire af,done,valid,dv;wire[1:0] category,dc;wire[63:0] rid,rcfg,rep,rseq,did,dcfg,dep,dseq;
 shape_stream_adapter_contract_v2 adapter(.clk(clk),.rst_n(rst),.ce(ce),.source_sof(ss),.source_de(de),.source_qualified(de),.source_frame_id(fid),.source_epoch(64'd3),.source_config(64'd7),.source_display_seq(seq),.final_de(de),.final_support(1'b1),.final_edge(edge_pixel),.final_raster_fault(1'b0),.final_x(x),.final_y(y),.display_class(dc),.display_valid(dv),.display_frame_id(did),.display_epoch(dep),.display_config(dcfg),.display_source_seq(dseq),.result_done(done),.result_valid(valid),.result_class(category),.result_frame_id(rid),.result_epoch(rep),.result_config(rcfg),.result_source_seq(rseq),.adapter_fault(af));
 reg[23:0] rgb=24'h123456;wire[23:0] out_rgb,ref_rgb;wire od,oh,ov,rd,rh,rv;
 shape_osd osd(.clk(clk),.ce(ce),.arst_n(rst),.rgb(rgb),.de(de),.hs(hs),.vs(vs),.threshold(8'd64),.mode(3'd6),.filter_id(2'd2),.shape_class(dc),.shape_valid(dv),.fusion_enable(1'b0),.fusion_active(1'b0),.fusion_age_valid(1'b0),.fusion_age(32'd0),.out_rgb(out_rgb),.out_de(od),.out_hs(oh),.out_vs(ov));
 reference_wide_parent_osd refosd(.clk(clk),.ce(ce),.arst_n(rst),.rgb(rgb),.de(de),.hs(hs),.vs(vs),.threshold(8'd64),.mode(3'd6),.filter_id(2'd2),.shape_class(dc),.shape_valid(dv),.fusion_enable(1'b0),.fusion_active(1'b0),.fusion_age_valid(1'b0),.fusion_age(32'd0),.out_rgb(ref_rgb),.out_de(rd),.out_hs(rh),.out_vs(rv));
 integer f,xx,yy,b,n=0,results=0,pixels=0,green=0;reg new_border,old_border,checking=0;reg[26:0] held;
 reg[959:0] bitmap[0:539];reg[4095:0] root,path;
 task tick;begin
  @(posedge clk);#1;
  if(ce&&checking)begin
   if({od,oh,ov}!=={de,hs,vs}||{od,oh,ov}!=={rd,rh,rv})$fatal(1,"OSD_CONTROL_ALIGNMENT");
   new_border=((x==160||x==1119)&&y>=90&&y<=629)||((y==90||y==629)&&x>=160&&x<=1119);
   old_border=((x==384||x==895)&&y>=168&&y<=551)||((y==168||y==551)&&x>=384&&x<=895);
   if(de)begin
    pixels=pixels+1;
    if(new_border)begin if(out_rgb!==24'h408040)$fatal(1,"NEW_GUIDE x=%0d y=%0d",x,y);green=green+1;end
    else if(old_border)begin if(out_rgb!==rgb)$fatal(1,"OLD_GUIDE_NOT_REMOVED");end
    else if(out_rgb!==ref_rgb)$fatal(1,"OTHER_OSD_OR_PIXEL_CHANGED x=%0d y=%0d",x,y);
   end else if(out_rgb!==0)$fatal(1,"BLANK_RGB");
   if(done)begin
    if(!valid||category!==(results==0?2:1)||rid!==results+1||rcfg!==7||rep!==3||rseq!==results+101)$fatal(1,"720P_RESULT");
    results=results+1;
   end
   if(af)$fatal(1,"ADAPTER_FAULT");
  end
  @(negedge clk);
 end endtask
 initial begin
  if(!$value$plusargs("ROOT=%s",root))$fatal(1,"ROOT");repeat(4)tick;rst=1;repeat(5)tick;checking=1;
  for(f=0;f<2;f=f+1)begin
   $sformat(path,"%0s/edge_%03d.hex",root,f==0?7:11);$readmemh(path,bitmap);
   fid=f+1;seq=f+101;vs=0;de=0;repeat(3)tick;vs=1;ss=1;tick;ss=0;
   for(yy=0;yy<720;yy=yy+1)begin
    for(xx=0;xx<1280;xx=xx+1)begin
     x=xx;y=yy;de=1;edge_pixel=(xx>=160&&xx<=1119&&yy>=90&&yy<=629)?bitmap[yy-90][xx-160]:0;
     if(xx==200&&yy==100)begin ce=0;held={out_rgb,od,oh,ov};repeat(5)tick;if({out_rgb,od,oh,ov}!==held)$fatal(1,"OSD_CE_HOLD");ce=1;end
     tick;
     if(xx==0&&yy==0)begin
      if(f==0)begin if(dv||dc)$fatal(1,"INITIAL_UNKNOWN");end
      else if(!dv||dc!==2||did!==1||dseq!==101)$fatal(1,"720P_PREV");
     end
    end
    de=0;edge_pixel=0;repeat(370)tick;
   end
   repeat(49500)tick;
   if(results!=f+1)$fatal(1,"NO_RESULT_BEFORE_NEXT_SOF");
  end
  fid=3;seq=103;vs=0;repeat(3)tick;vs=1;ss=1;tick;ss=0;de=1;x=0;y=0;tick;
  if(!dv||dc!==1||did!==2||dseq!==102)$fatal(1,"SECOND_PREV");
  if(pixels!=1843201||green!=5992)$fatal(1,"FRAME_COUNTS pixels=%0d green=%0d",pixels,green);
  $display("PASS_WIDE_ADAPTER_OSD full720p_frames=2 active_pixels=%0d guide_pixels=%0d",pixels,green);$finish;
 end
 initial begin #40000000;$fatal(1,"WATCHDOG");end
endmodule
