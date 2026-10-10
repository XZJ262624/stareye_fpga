`timescale 1ns/1ps
module tb_m5b1_tap;
 reg test_pass=0;
 parameter WIDTH=240,HEIGHT=48,H_TOTAL=280,V_TOTAL=62,H_BACK=12,V_BACK=6,VS_LINES=2,HS_CLOCKS=3,FRAMES=28,STALL=0;
 localparam LAT=4*H_TOTAL+25,OLAT=LAT+1,BLAT=2*H_TOTAL+17,EXTRA=LAT-BLAT;
 reg clk=0;always #5 clk=~clk;
 reg rst=0,ce=1,de=0,hs=1,vs=1,sof=0,request=1;reg[7:0] gray=0,threshold=64;reg[2:0] mode=0;
 wire[23:0] rgb,osd;wire od,oh,ov,dd,dh,dv;wire[7:0] raw,mag,t,nms;wire[2:0] m;
 wire bin,ovvalid,ovedge,nvalid,cvalid,cedge,filter,fault;wire[11:0] x,y;
 reg [63:0] tag_in=0;
 wire tap_valid,tap_filter;wire [1:0] tap_class;wire [11:0] tap_x,tap_y;
 wire [7:0] tap_high,tap_low;wire [63:0] tap_frame_id,tap_epoch,tap_timestamp;
 reg [1:0] tap_gold[0:WIDTH*HEIGHT*FRAMES-1];
 reg [7:0] frame_high[0:FRAMES-1];reg frame_filter[0:FRAMES-1];
 reg [2047:0] tap_path;integer tap_pixels=0,tap_frames=0,tap_position=0;
 always @(posedge clk)if(rst&&tap_valid)begin
  if(!ce||tap_x!=tap_position%WIDTH||tap_y!=tap_position/WIDTH)$fatal(1,"TAP coordinate/CE duplicate/missing");
  if(tap_frame_id!=tap_frames||tap_epoch!=77)$fatal(1,"TAP tag got=%0d expected=%0d",tap_frame_id,tap_frames);
  if(tap_high!=frame_high[tap_frames]||tap_low!=(frame_high[tap_frames]>>1)||tap_filter!=frame_filter[tap_frames])$fatal(1,"TAP configuration");
  if(tap_class!==tap_gold[tap_pixels])$fatal(1,"TAP gold frame=%0d pos=%0d got=%d expected=%d",tap_frames,tap_position,tap_class,tap_gold[tap_pixels]);
  tap_pixels=tap_pixels+1;
  if(tap_position==WIDTH*HEIGHT-1)begin tap_frames=tap_frames+1;tap_position=0;end else tap_position=tap_position+1;
 end
 m5a_stream_top #(.WIDTH(WIDTH),.HEIGHT(HEIGHT),.H_TOTAL(H_TOTAL)) dut(
  .tap_input_frame_id(tag_in),.tap_input_epoch(64'd77),
  .tap_valid(tap_valid),.tap_class(tap_class),.tap_x(tap_x),.tap_y(tap_y),.tap_high(tap_high),.tap_low(tap_low),.tap_filter(tap_filter),
  .tap_frame_id(tap_frame_id),.tap_epoch(tap_epoch),.tap_timestamp(tap_timestamp),
  .clk(clk),.ce(ce),.arst_n(rst),.in_gray(gray),.in_de(de),.in_hs(hs),.in_vs(vs),.in_sof(sof),
  .filter_request(request),.threshold(threshold),.mode(mode),.out_rgb(rgb),.out_de(od),.out_hs(oh),.out_vs(ov),
  .out_raw(raw),.out_legacy_mag(mag),.out_legacy_bin(bin),.out_overlay_valid(ovvalid),.out_overlay_edge(ovedge),
  .out_threshold(t),.out_mode(m),.out_filter_enable(filter),.out_nms(nms),.out_nms_valid(nvalid),
  .out_canny_valid(cvalid),.out_canny_edge(cedge),.out_x(x),.out_y(y),.raster_fault(fault));
 m5a_osd display_osd(clk,ce,rst,rgb,od,oh,ov,t,m,osd,dd,dh,dv);
 wire[23:0] ref_rgb[0:3],ref_osd[0:3],new_osd[0:3];wire[2:0] ref_sync[0:3];wire[7:0] ref_t[0:3];wire[1:0] ref_m[0:3];
 genvar g;
 generate for(g=0;g<4;g=g+1)begin:refs
  wire rd,rh,rv;
  m4_stream_top #(.WIDTH(WIDTH),.HEIGHT(HEIGHT),.H_TOTAL(H_TOTAL)) baseline(
   .clk(clk),.arst_n(rst),.in_gray(gray),.in_de(de),.in_hs(hs),.in_vs(vs),.in_sof(sof),.filter_request(request),
   .threshold(threshold),.mode(g[1:0]),.out_rgb(ref_rgb[g]),.out_de(rd),.out_hs(rh),.out_vs(rv),
   .out_threshold(ref_t[g]),.out_mode(ref_m[g]),.out_raw(),.out_legacy(),.out_filter_enable(),.overlay_valid(),.overlay_edge(),.out_x(),.out_y(),.raster_fault());
  m4_osd baseline_osd(clk,rst,ref_rgb[g],rd,rh,rv,ref_t[g],ref_m[g],ref_osd[g],ref_sync[g][2],ref_sync[g][1],ref_sync[g][0]);
  wire[23:0] new_image;
  m5a_colorize legacy_image(.de(od),.mode(g[2:0]),.raw(raw),.legacy_mag(mag),.nms_gray(nms),.legacy_bin(bin),.overlay_valid(ovvalid),.overlay_edge(ovedge),.canny_valid(cvalid),.canny_edge(cedge),.rgb(new_image));
  m5a_osd legacy_osd(.clk(clk),.ce(ce),.arst_n(rst),.rgb(new_image),.de(od),.hs(oh),.vs(ov),.threshold(t),.mode(g[2:0]),.out_rgb(new_osd[g]),.out_de(),.out_hs(),.out_vs());
 end endgenerate
 reg[91:0] golden[0:WIDTH*HEIGHT-1],q[0:LAT-1],oq[0:OLAT-1],bq[0:BLAT-1];
 reg[2:0] sq[0:LAT-1],osq[0:OLAT-1];reg[7:0] tq[0:LAT-1];reg[2:0] mq[0:LAT-1];reg fq[0:LAT-1];
 reg[11:0] xq[0:LAT-1],yq[0:LAT-1];reg bdq[0:BLAT-1];
 reg[23:0] oldq[0:3][0:EXTRA-1];reg[2:0] olds[0:EXTRA-1];
 reg[23:0] expected_old[0:3];reg[159:0] held;
 integer rp=0,op=0,bp=0,refp=0,cycles=0,pixels=0,basepixels=0,stalls=0,regression[0:3],cannypixels=0;
 integer i,j,f,h,v,ix,iy,fd,scan,cm,ct,en,pattern;
 reg[2047:0] dir,casepath,goldpath;
 task tick;
 input d,hh,vv;input[91:0] p;input integer xx,yy;
 begin
  if(STALL && cycles%17==7)begin
   @(negedge clk);ce=0;held={rgb,osd,od,oh,ov,dd,dh,dv,raw,mag,bin,ovvalid,ovedge,t,m,filter,nms,nvalid,cvalid,cedge,x,y};
   repeat(3)begin @(posedge clk);#1;if(held!=={rgb,osd,od,oh,ov,dd,dh,dv,raw,mag,bin,ovvalid,ovedge,t,m,filter,nms,nvalid,cvalid,cedge,x,y})$fatal(1,"CE_STALL_OUTPUT");stalls=stalls+1;end
  end
  @(negedge clk);ce=1;de=d;hs=hh;vs=vv;sof=!vv;gray=d?p[7:0]:0;
  @(posedge clk);#1;
  if({od,oh,ov}!==sq[rp] || {dd,dh,dv}!==osq[op])$fatal(1,"SYNC cycle=%0d got=%b%b%b exp=%b",cycles,od,oh,ov,sq[rp]);
  if(rgb!==(sq[rp][2]?q[rp][67:44]:24'd0) || osd!==(osq[op][2]?oq[op][91:68]:24'd0))$fatal(1,"RGB cycle=%0d x=%0d y=%0d got=%h/%h exp=%h/%h",cycles,x,y,rgb,osd,q[rp][67:44],oq[op][91:68]);
  if(od)begin
   if({raw,mag,bin,ovvalid,ovedge,nms,nvalid,cvalid,cedge}!=={q[rp][7:0],q[rp][15:8],q[rp][16],q[rp][17],q[rp][18],q[rp][26:19],q[rp][27],q[rp][28],q[rp][29]})
    $fatal(1,"ALGORITHM x=%0d y=%0d raw=%d mag=%d bin=%b ov=%b%b nms=%d nv=%b cv=%b ce=%b gold=%h",x,y,raw,mag,bin,ovvalid,ovedge,nms,nvalid,cvalid,cedge,q[rp]);
   if(x!==xq[rp] || y!==yq[rp] || t!==tq[rp] || m!==mq[rp] || filter!==fq[rp])$fatal(1,"PACKET");
   pixels=pixels+1;if(cedge)cannypixels=cannypixels+1;
  end
  if(bdq[bp])begin
   if({dut.u_base.center_support,dut.u_base.center_magnitude,dut.u_base.center_direction}!=={bq[bp][17],bq[bp][41:30],bq[bp][43:42]})$fatal(1,"GRADIENT_DIRECTION_ALIGNMENT cycle=%0d got=%h/%d expected=%h/%d",cycles,dut.u_base.center_magnitude,dut.u_base.center_direction,bq[bp][41:30],bq[bp][43:42]);
   basepixels=basepixels+1;
  end
  if(!STALL)begin
   if({dd,dh,dv}!==olds[refp])$fatal(1,"M4_REGRESSION_SYNC");
   if(dd)begin
    // Four dedicated legacy colorize+OSD instances compare every active pixel,
    // including the complete OSD rectangle, regardless of selected new mode.
    for(j=0;j<4;j=j+1)begin
     if(new_osd[j]!==oldq[j][refp])$fatal(1,"M4_LEGACY_OSD mode=%0d",j);
     regression[j]=regression[j]+1;
    end
   end
   for(j=0;j<4;j=j+1)oldq[j][refp]=ref_osd[j];olds[refp]=ref_sync[0];refp=(refp+1)%EXTRA;
  end
  q[rp]=p;sq[rp]={d,hh,vv};tq[rp]=threshold;mq[rp]=mode;fq[rp]=en;xq[rp]=xx;yq[rp]=yy;rp=(rp+1)%LAT;
  oq[op]=p;osq[op]={d,hh,vv};op=(op+1)%OLAT;bq[bp]=p;bdq[bp]=d;bp=(bp+1)%BLAT;cycles=cycles+1;
 end endtask
 initial begin
  if(!$value$plusargs("TAP_FILE=%s",tap_path))$fatal(1,"TAP_FILE");$readmemh(tap_path,tap_gold);
  if(!$value$plusargs("DIR=%s",dir))$fatal(1,"DIR");
  for(i=0;i<LAT;i=i+1)begin q[i]=0;sq[i]=3'b011;tq[i]=0;mq[i]=0;fq[i]=0;xq[i]=0;yq[i]=0;end
  for(i=0;i<OLAT;i=i+1)begin oq[i]=0;osq[i]=3'b011;end
  for(i=0;i<BLAT;i=i+1)begin bq[i]=0;bdq[i]=0;end
  for(i=0;i<EXTRA;i=i+1)begin olds[i]=3'b011;for(j=0;j<4;j=j+1)oldq[j][i]=0;end
  for(i=0;i<4;i=i+1)regression[i]=0;
  repeat(4)@(negedge clk);rst=1;repeat(8)@(negedge clk);
  $sformat(casepath,"%0s/cases.txt",dir);fd=$fopen(casepath,"r");if(!fd)$fatal(1,"cases open");
  for(f=0;f<FRAMES;f=f+1)begin
   scan=$fscanf(fd,"%d %d %d %d\n",cm,ct,en,pattern);if(scan!=4)$fatal(1,"cases truncated");mode=cm;threshold=ct;request=en;tag_in=f;frame_high[f]=ct;frame_filter[f]=en;
   $sformat(goldpath,"%0s/frame_%0d.hex",dir,f);$readmemh(goldpath,golden);
   for(v=0;v<V_TOTAL;v=v+1)for(h=0;h<H_TOTAL;h=h+1)begin
    ix=h-H_BACK;iy=v-V_BACK;
    if(ix>=0 && ix<WIDTH && iy>=0 && iy<HEIGHT)tick(1,h>=HS_CLOCKS,v>=VS_LINES,golden[iy*WIDTH+ix],ix,iy);
    else tick(0,h>=HS_CLOCKS,v>=VS_LINES,0,0,0);
   end
  end
  for(h=0;h<OLAT+8;h=h+1)tick(0,1,1,0,0,0);
  if(pixels!=FRAMES*WIDTH*HEIGHT || basepixels!=pixels || cannypixels==0)$fatal(1,"COVERAGE");
  if(tap_pixels!=WIDTH*HEIGHT*FRAMES||tap_frames!=FRAMES)$fatal(1,"TAP full-frame coverage");
  $display("M5B1_TAP_PASS pixels=%0d frames=%0d stalls=%0d",tap_pixels,tap_frames,stalls);
  test_pass=1;$display("M5A_STREAM_PASS cycles=%0d frames=%0d pixels=%0d canny=%0d stalls=%0d regression=%0d,%0d,%0d,%0d latency=%0d",cycles,FRAMES,pixels,cannypixels,stalls,regression[0],regression[1],regression[2],regression[3],OLAT);$finish;
 end
endmodule
