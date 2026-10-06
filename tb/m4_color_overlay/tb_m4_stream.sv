`timescale 1ns/1ps
module tb_m4_stream;
reg test_pass=0;
 parameter WIDTH=160,HEIGHT=40,H_TOTAL=200,V_TOTAL=48,H_BACK=12,V_BACK=4,VS_LINES=2,HS_CLOCKS=3,FRAMES=24;
 localparam LAT=2*H_TOTAL+17,ODLAT=LAT+1,EXTRA=H_TOTAL+1;
 reg clk=0;always #5 clk=~clk;
 reg rst=0,de=0,hs=1,vs=1,sof=0,request=1;
 reg[7:0] gray=0,threshold=64;reg[1:0] mode=0;
 wire[23:0] rgb,osd;wire od,oh,ov,dd,dh,dv,valid,edgebit,fault,filter;
 wire[7:0] raw,legacy,t;wire[1:0] m;wire[11:0] x,y;
 m4_stream_top #(.WIDTH(WIDTH),.HEIGHT(HEIGHT),.H_TOTAL(H_TOTAL)) dut(
  .clk(clk),.arst_n(rst),.in_gray(gray),.in_de(de),.in_hs(hs),.in_vs(vs),.in_sof(sof),
  .filter_request(request),.threshold(threshold),.mode(mode),.out_rgb(rgb),.out_de(od),.out_hs(oh),.out_vs(ov),
  .out_raw(raw),.out_legacy(legacy),.out_threshold(t),.out_mode(m),.out_filter_enable(filter),
  .overlay_valid(valid),.overlay_edge(edgebit),.out_x(x),.out_y(y),.raster_fault(fault));
 m4_osd display_osd(clk,rst,rgb,od,oh,ov,t,m,osd,dd,dh,dv);
 wire[7:0] old_gray,old_t,old_osd;wire[1:0] old_m;wire old_de,old_hs,old_vs,old_od,old_oh,old_ov;
 m32_stream_top #(.WIDTH(WIDTH),.HEIGHT(HEIGHT),.H_TOTAL(H_TOTAL)) baseline(
  .clk(clk),.arst_n(rst),.in_gray(gray),.in_de(de),.in_hs(hs),.in_vs(vs),.in_sof(sof),
  .filter_request(request),.threshold(threshold),.mode(mode),.out_gray(old_gray),.raw_gray(),.edge_gray(),
  .edge_binary(),.out_valid(),.out_de(old_de),.out_hs(old_hs),.out_vs(old_vs),.out_filter_enable(),
  .out_threshold(old_t),.out_mode(old_m),.out_x(),.out_y(),.center_x(),.center_y());
 m31_osd baseline_osd(clk,rst,old_gray,old_de,old_hs,old_vs,old_t,old_m,old_osd,old_od,old_oh,old_ov);
 reg[57:0] golden[0:WIDTH*HEIGHT-1];
 reg[23:0] rgbq[0:LAT-1],osdq[0:ODLAT-1];
 reg[2:0] syncq[0:LAT-1],osyncq[0:ODLAT-1];
 reg[7:0] rawq[0:LAT-1],tq[0:LAT-1];reg[1:0] mq[0:LAT-1];
 reg[11:0] xq[0:LAT-1],yq[0:LAT-1];reg vq[0:LAT-1],eq[0:LAT-1],fq[0:LAT-1];
 reg[10:0] refq[0:EXTRA-1];
 integer rp=0,op=0,bp=0,cycles=0,pixels=0,regression[0:2],reds=0,checks=0;
 integer i,f,h,v,ix,iy,fd,scan,cm,ct,ce,pattern;
 reg[2047:0] dir,casepath,goldpath;reg[57:0] pixel;
 task clear_queues;
 begin
  for(i=0;i<LAT;i=i+1)begin rgbq[i]=0;syncq[i]=3'b011;rawq[i]=0;tq[i]=0;mq[i]=0;xq[i]=0;yq[i]=0;vq[i]=0;eq[i]=0;fq[i]=0;end
  for(i=0;i<ODLAT;i=i+1)begin osdq[i]=0;osyncq[i]=3'b011;end
  for(i=0;i<EXTRA;i=i+1)refq[i]=11'b00000000011;
  rp=0;op=0;bp=0;
 end endtask
 task tick;
 input d,hh,vv;input[57:0] p;input integer xx,yy;
 begin
  @(negedge clk);de=d;hs=hh;vs=vv;sof=!vv;gray=d?p[9:2]:0;
  @(posedge clk);#1;
  if({od,oh,ov}!==syncq[rp] || {dd,dh,dv}!==osyncq[op])$fatal(1,"SYNC cycle=%0d",cycles);
  if(rgb!==rgbq[rp] || osd!==osdq[op])$fatal(1,"RGB cycle=%0d x=%0d y=%0d got=%h/%h expected=%h/%h",cycles,x,y,rgb,osd,rgbq[rp],osdq[op]);
  if(od)begin
   if(raw!==rawq[rp] || x!==xq[rp] || y!==yq[rp] || m!==mq[rp] || t!==tq[rp] || filter!==fq[rp])$fatal(1,"PACKET cycle=%0d",cycles);
   if(valid!==vq[rp] || edgebit!==eq[rp])$fatal(1,"EDGE cycle=%0d x=%0d y=%0d got=%b%b expected=%b%b fault=%b",cycles,x,y,valid,edgebit,vq[rp],eq[rp],fault);
   pixels=pixels+1;if(edgebit)reds=reds+1;
  end
  if({dd,dh,dv}!==refq[bp][2:0])$fatal(1,"REGRESSION_SYNC");
  if(dd && mq[(rp+LAT-1)%LAT]<3)begin
   if(osd!=={3{refq[bp][10:3]}})$fatal(1,"REGRESSION_PIXEL cycle=%0d",cycles);
   regression[mq[(rp+LAT-1)%LAT]]=regression[mq[(rp+LAT-1)%LAT]]+1;
  end
  refq[bp]={old_osd,old_od,old_oh,old_ov};bp=(bp+1)%EXTRA;
  rgbq[rp]=d?p[33:10]:0;syncq[rp]={d,hh,vv};rawq[rp]=d?p[9:2]:0;
  xq[rp]=xx;yq[rp]=yy;vq[rp]=d && p[1];eq[rp]=d && p[0];tq[rp]=threshold;mq[rp]=mode;fq[rp]=ce;
  osdq[op]=d?p[57:34]:0;osyncq[op]={d,hh,vv};rp=(rp+1)%LAT;op=(op+1)%ODLAT;
  cycles=cycles+1;
 end endtask
 initial begin
  if(!$value$plusargs("DIR=%s",dir))$fatal(1,"DIR");
  clear_queues();for(i=0;i<3;i=i+1)regression[i]=0;
  repeat(4)@(negedge clk);rst=1;repeat(8)@(negedge clk);
  $sformat(casepath,"%0s/cases.txt",dir);fd=$fopen(casepath,"r");if(!fd)$fatal(1,"cases open");
  for(f=0;f<FRAMES;f=f+1)begin
   scan=$fscanf(fd,"%d %d %d %d\n",cm,ct,ce,pattern);if(scan!=4)$fatal(1,"cases truncated");
   mode=cm;threshold=ct;request=ce;
   $sformat(goldpath,"%0s/frame_%0d.hex",dir,f);$readmemh(goldpath,golden);
   for(v=0;v<V_TOTAL;v=v+1)for(h=0;h<H_TOTAL;h=h+1)begin
    ix=h-H_BACK;iy=v-V_BACK;
    if(ix>=0 && ix<WIDTH && iy>=0 && iy<HEIGHT)tick(1,h>=HS_CLOCKS,v>=VS_LINES,golden[iy*WIDTH+ix],ix,iy);
    else tick(0,h>=HS_CLOCKS,v>=VS_LINES,0,0,0);
   end
  end
  for(h=0;h<ODLAT+8;h=h+1)tick(0,1,1,0,0,0);
  if(pixels!=FRAMES*WIDTH*HEIGHT)$fatal(1,"PIXEL_COUNT");
  test_pass=1;$display("M4_STREAM_PASS cycles=%0d frames=%0d pixels=%0d red=%0d regression=%0d,%0d,%0d latency=%0d",cycles,FRAMES,pixels,reds,regression[0],regression[1],regression[2],ODLAT);
  $finish;
 end
endmodule
