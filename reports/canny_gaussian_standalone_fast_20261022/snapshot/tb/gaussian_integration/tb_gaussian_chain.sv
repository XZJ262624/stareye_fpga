`timescale 1ns/1ps
module tb_gaussian_chain;
 parameter W=64,H=48,HT=80,VT=66,HB=8,VB=8,VS=2,HS=3,FRAMES=11,STALL=1;
 localparam LAT=4*HT+25,BLAT=2*HT+17;
 reg clk=0;always #5 clk=~clk;
 reg rst=0,ce=1,de=0,hs=1,vs=1,sof=0;reg [7:0] gray=0,high=64;reg [2:0] mode=0;reg [1:0] filt=1;
 reg [63:0] fid=0,gen=0,seq=0,ticks=0;always @(posedge clk)if(rst)ticks<=ticks+1;
 wire [23:0] rgb;wire od,oh,ov;wire [7:0] raw,mag,ot,nms;wire [2:0] om;wire [1:0] of,tf,tc;wire bin,os,oe,nv,cv,ed,fault,tv,ftv,fq;wire [11:0] x,y,tx,ty;wire [63:0] tid,te,tg,ts,tt;wire [7:0] th,tl;
 m5a_stream_top #(.WIDTH(W),.HEIGHT(H),.H_TOTAL(HT)) dut(.clk(clk),.ce(ce),.arst_n(rst),.in_gray(gray),.in_de(de),.in_hs(hs),.in_vs(vs),.in_sof(sof),.filter_request(filt),.threshold(high),.mode(mode),
  .out_rgb(rgb),.out_de(od),.out_hs(oh),.out_vs(ov),.out_raw(raw),.out_legacy_mag(mag),.out_threshold(ot),.out_nms(nms),.out_legacy_bin(bin),.out_overlay_valid(os),.out_overlay_edge(oe),.out_nms_valid(nv),.out_canny_valid(cv),.out_canny_edge(ed),.out_mode(om),.out_filter_enable(of),.out_x(x),.out_y(y),.raster_fault(fault),
  .tap_input_frame_id(fid),.tap_input_epoch(64'd77),.tap_input_qualified(de),.source_pixel_tick(ticks),.source_display_seq(seq),.source_config_generation(gen),.tap_valid(tv),.tap_class(tc),.tap_x(tx),.tap_y(ty),.tap_high(th),.tap_low(tl),.tap_filter(tf),.tap_frame_id(tid),.tap_epoch(te),.tap_timestamp(tt),.tap_display_seq(ts),.tap_config_generation(tg),.fusion_tap_valid(ftv),.fusion_tap_qualified(fq),.fusion_tap_support());
 wire [23:0] rr;wire rd,rh,rv,rb,rs,re,rnv,rcv,red;wire [7:0] rraw,rmag,rnms;
 reference_m5a_stream_top #(.WIDTH(W),.HEIGHT(H),.H_TOTAL(HT)) baseline(.clk(clk),.ce(ce),.arst_n(rst),.in_gray(gray),.in_de(de),.in_hs(hs),.in_vs(vs),.in_sof(sof),.filter_request(filt!=0),.threshold(high),.mode(mode),
  .out_rgb(rr),.out_de(rd),.out_hs(rh),.out_vs(rv),.out_raw(rraw),.out_legacy_mag(rmag),.out_nms(rnms),.out_legacy_bin(rb),.out_overlay_valid(rs),.out_overlay_edge(re),.out_nms_valid(rnv),.out_canny_valid(rcv),.out_canny_edge(red),
  .tap_input_frame_id(fid),.tap_input_epoch(64'd77),.tap_input_qualified(de),.source_pixel_tick(ticks),.source_display_seq(seq),.source_config_generation(gen));
 reg [93:0] gold[0:W*H-1],q[0:LAT-1],bq[0:BLAT-1];reg [2:0] syncq[0:LAT-1];reg [1:0] fqexp[0:LAT-1];reg [2:0] mq[0:LAT-1];reg [7:0] hq[0:LAT-1];reg bdq[0:BLAT-1];
 reg [93:0] tap_gold[0:FRAMES*W*H-1];reg [1:0] fexp[0:FRAMES-1];reg [7:0] hexp[0:FRAMES-1];
 integer p=0,bp=0,cycles=0,pixels=0,taps=0,bases=0,stalls=0;integer i,f,v,h,ix,iy,pos,fd,m,ff,hi,k,scan;reg [2047:0] root,path;
 reg [127:0] held;
 task tick(input bit d,input bit hh,input bit vv,input [93:0] e);
 begin
  if(STALL&&cycles%71==23)begin
   @(negedge clk);ce=0;held={rgb,od,oh,ov,raw,mag,ot,nms,om,of,bin,os,oe,nv,cv,ed,x,y};
   repeat(3)begin @(posedge clk);#1;if(held!=={rgb,od,oh,ov,raw,mag,ot,nms,om,of,bin,os,oe,nv,cv,ed,x,y})$fatal(1,"GAUSS_CE_FREEZE");stalls=stalls+1;end
  end
  @(negedge clk);ce=1;de=d;hs=hh;vs=vv;sof=!vv;gray=d?e[7:0]:0;
  @(posedge clk);
  if(ftv)begin
   if(!tv||!fq||tx!==taps%(W*H)%W||ty!==taps%(W*H)/W)$fatal(1,"GAUSS_TAP_RASTER");
   if(tc!==tap_gold[taps][93:92])$fatal(1,"GAUSS_TAP_CLASS frame=%0d pos=%0d",taps/(W*H),taps%(W*H));
   if(tid!==taps/(W*H)/2||te!==77||tg!==taps/(W*H)+1||ts!==taps/(W*H)+100||tf!==fexp[taps/(W*H)]||th!==hexp[taps/(W*H)]||tl!==(hexp[taps/(W*H)]>>1))$fatal(1,"GAUSS_TAP_IDENTITY_FILTER");
   taps=taps+1;
  end
  #1;
  if({od,oh,ov}!==syncq[p])$fatal(1,"GAUSS_N_FINAL_SYNC cycle=%0d",cycles);
  if(rgb!==(syncq[p][2]?q[p][67:44]:24'd0))$fatal(1,"GAUSS_RGB x=%0d y=%0d got=%h exp=%h",x,y,rgb,q[p][67:44]);
  if(od)begin
   pos=pixels%(W*H);
   if(x!==pos%W||y!==pos/W||ot!==hq[p]||om!==mq[p]||of!==fqexp[p])$fatal(1,"GAUSS_FINAL_PACKET_FILTER");
   if({raw,mag,bin,os,oe,nms,nv,cv,ed}!=={q[p][7:0],q[p][15:8],q[p][16],q[p][17],q[p][18],q[p][26:19],q[p][27],q[p][28],q[p][29]})$fatal(1,"GAUSS_SPATIAL x=%0d y=%0d got=%h exp=%h",x,y,{raw,mag,bin,os,oe,nms,nv,cv,ed},{q[p][7:0],q[p][15:8],q[p][16],q[p][17],q[p][18],q[p][26:19],q[p][27],q[p][28],q[p][29]});
   if(of!=2&&{rgb,od,oh,ov,raw,mag,bin,os,oe,nms,nv,cv,ed}!=={rr,rd,rh,rv,rraw,rmag,rb,rs,re,rnms,rnv,rcv,red})$fatal(1,"GAUSS_MED_BASELINE_CHANGED");
   pixels=pixels+1;
  end
  if(bdq[bp])begin
   if({dut.u_base.center_support,dut.u_base.center_magnitude,dut.u_base.center_direction}!=={bq[bp][17],bq[bp][41:30],bq[bp][43:42]})$fatal(1,"GAUSS_CENTERED_SOBEL");bases=bases+1;
  end
  syncq[p]={d,hh,vv};q[p]=e;mq[p]=mode;hq[p]=high;fqexp[p]=filt;p=(p+1)%LAT;bq[bp]=e;bdq[bp]=d;bp=(bp+1)%BLAT;cycles=cycles+1;
 end endtask
 initial begin
  if(!$value$plusargs("ROOT=%s",root))$fatal(1,"ROOT");
  for(i=0;i<LAT;i=i+1)begin q[i]=0;syncq[i]=3'b011;mq[i]=0;hq[i]=0;fqexp[i]=0;end
  for(i=0;i<BLAT;i=i+1)begin bq[i]=0;bdq[i]=0;end
  $sformat(path,"%0s/cases.txt",root);fd=$fopen(path,"r");if(!fd)$fatal(1,"CASES");
  for(f=0;f<FRAMES;f=f+1)begin
   scan=$fscanf(fd,"%d %d %d %d\n",m,ff,hi,k);if(scan!=4)$fatal(1,"CASE_READ");fexp[f]=ff;hexp[f]=hi;
   $sformat(path,"%0s/frame_%0d.hex",root,f);$readmemh(path,gold);
   for(i=0;i<W*H;i=i+1)tap_gold[f*W*H+i]=gold[i];
  end
  $fclose(fd);repeat(5)@(negedge clk);rst=1;repeat(8)@(negedge clk);
  $sformat(path,"%0s/cases.txt",root);fd=$fopen(path,"r");
  for(f=0;f<FRAMES;f=f+1)begin
   scan=$fscanf(fd,"%d %d %d %d\n",m,ff,hi,k);mode=m;filt=ff;high=hi;gen=f+1;seq=f+99;
   $sformat(path,"%0s/frame_%0d.hex",root,f);$readmemh(path,gold);
   for(v=0;v<VT;v=v+1)for(h=0;h<HT;h=h+1)begin
    ix=h-HB;iy=v-VB;fid=(ix>=0&&ix<W&&iy>=0&&iy<H)?f/2:9999;
    if(ix>=0&&ix<W&&iy>=0&&iy<H)tick(1,h>=HS,v>=VS,gold[iy*W+ix]);else tick(0,h>=HS,v>=VS,0);
   end
  end
  for(i=0;i<LAT+10;i=i+1)tick(0,1,1,0);
  if(pixels!=FRAMES*W*H||taps!=pixels||bases!=pixels||fault||STALL&&stalls==0)$fatal(1,"GAUSS_COVERAGE pixels=%0d taps=%0d bases=%0d",pixels,taps,bases);
  $display("PASS_GAUSSIAN_CHAIN pixels=%0d taps=%0d gradient=%0d frames=%0d stalls=%0d latency=%0d",pixels,taps,bases,FRAMES,stalls,LAT);$finish;
 end
 initial begin #100000000;$fatal(1,"GAUSS_WATCHDOG");end
endmodule
