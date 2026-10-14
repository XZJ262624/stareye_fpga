// Adapted read-only legacy M5B1 tap oracle; new source identity/CE checks.
`timescale 1ns/1ps
module tb_m5c1b_capture_identity;
 reg test_pass=0;
 parameter WIDTH=240,HEIGHT=48,H_TOTAL=280,V_TOTAL=62,H_BACK=12,V_BACK=6,VS_LINES=2,HS_CLOCKS=3,FRAMES=28,STALL=0,TAG_FAULT=0,TAG_DIRECT=0;
 localparam LAT=4*H_TOTAL+25,OLAT=LAT+1,BLAT=2*H_TOTAL+17,EXTRA=LAT-BLAT;
 reg clk=0;always #5 clk=~clk;
 reg rst=0,ce=1,de=0,hs=1,vs=1,sof=0,request=1;reg[7:0] gray=0,threshold=64;reg[2:0] mode=0;
 wire[23:0] rgb,osd;wire od,oh,ov,dd,dh,dv;wire[7:0] raw,mag,t,nms;wire[2:0] m;
 wire bin,ovvalid,ovedge,nvalid,cvalid,cedge,filter,fault;wire[11:0] x,y;
 reg [63:0] tag_in=0,source_ticks=0,source_seq=0,source_config=0;
 reg input_qualified=1;reg invalidated[0:FRAMES-1];
 wire fusion_tap_valid,fusion_tap_qualified;
 integer raw_frames=0,raw_position=0,invalid_pixels=0,raw_pixels=0,f;
 reg [63:0] expected_stamp[0:FRAMES-1];reg prev_sof=0;integer source_count=0;
 wire [63:0] tap_display_seq,tap_config_generation;
 always @(posedge clk)if(rst)begin source_ticks<=source_ticks+1; if(ce)begin if(sof&&!prev_sof)begin expected_stamp[source_count]=source_ticks;source_count=source_count+1;end prev_sof<=sof;end end
 wire tap_valid,tap_filter;wire [1:0] tap_class;wire [11:0] tap_x,tap_y;
 wire [7:0] tap_high,tap_low;wire [63:0] tap_frame_id,tap_epoch,tap_timestamp;
 reg [1:0] tap_gold[0:WIDTH*HEIGHT*FRAMES-1];
 reg [7:0] frame_high[0:FRAMES-1];reg frame_filter[0:FRAMES-1];
 reg [2047:0] tap_path;integer tap_pixels=0,tap_frames=0,tap_position=0;
 always @(posedge clk)if(rst&&ce&&!TAG_DIRECT)begin
  if(TAG_FAULT&&de&&!input_qualified&&f<FRAMES)invalidated[f]<=1;
  if(fusion_tap_valid)begin
   if(tap_x!=raw_position%WIDTH||tap_y!=raw_position/WIDTH)$fatal(1,"TAG_RAW_POSITION");
   if(tap_frame_id!=raw_frames/2||tap_display_seq!=raw_frames+100||tap_config_generation!=raw_frames+1||tap_timestamp!=expected_stamp[raw_frames])$fatal(1,"TAG_RAW_IDENTITY");
   if(fusion_tap_qualified!==!invalidated[raw_frames]||tap_valid!==fusion_tap_qualified)$fatal(1,"TAG_STICKY_QUALIFICATION frame=%0d pos=%0d",raw_frames,raw_position);
   raw_pixels=raw_pixels+1;if(!fusion_tap_qualified)invalid_pixels=invalid_pixels+1;
   if(raw_position==WIDTH*HEIGHT-1)begin raw_position=0;raw_frames=raw_frames+1;end else raw_position=raw_position+1;
  end
 end
 always @(posedge clk)if(rst&&tap_valid&&!TAG_FAULT&&!TAG_DIRECT)begin
  if(!ce||tap_x!=tap_position%WIDTH||tap_y!=tap_position/WIDTH)$fatal(1,"TAP coordinate/CE duplicate/missing");
  if(tap_frame_id!=tap_frames/2||tap_epoch!=77)$fatal(1,"TAP tag got=%0d expected=%0d",tap_frame_id,tap_frames);
  if(tap_display_seq!=tap_frames+100||tap_config_generation!=tap_frames+1||tap_timestamp!=expected_stamp[tap_frames])$fatal(1,"TAG_RAM_FULL_IDENTITY frame=%0d seq=%0d config=%0d timestamp=%0d expected=%0d",tap_frames,tap_display_seq,tap_config_generation,tap_timestamp,expected_stamp[tap_frames]);
  if(tap_high!=frame_high[tap_frames]||tap_low!=(frame_high[tap_frames]>>1)||tap_filter!=frame_filter[tap_frames])$fatal(1,"TAP configuration");
  if(tap_class!==tap_gold[tap_pixels])$fatal(1,"TAP gold frame=%0d pos=%0d got=%d expected=%d",tap_frames,tap_position,tap_class,tap_gold[tap_pixels]);
  tap_pixels=tap_pixels+1;
  if(tap_position==WIDTH*HEIGHT-1)begin tap_frames=tap_frames+1;tap_position=0;end else tap_position=tap_position+1;
 end
 m5a_stream_top #(.WIDTH(WIDTH),.HEIGHT(HEIGHT),.H_TOTAL(H_TOTAL)) dut(
  .source_pixel_tick(source_ticks),.source_display_seq(source_seq),.source_config_generation(source_config),
  .tap_display_seq(tap_display_seq),.tap_config_generation(tap_config_generation),
  .fusion_tap_valid(fusion_tap_valid),.fusion_tap_qualified(fusion_tap_qualified),
  .tap_input_frame_id(tag_in),.tap_input_epoch(64'd77),.tap_input_qualified(input_qualified),
  .tap_valid(tap_valid),.tap_class(tap_class),.tap_x(tap_x),.tap_y(tap_y),.tap_high(tap_high),.tap_low(tap_low),.tap_filter(tap_filter),
  .tap_frame_id(tap_frame_id),.tap_epoch(tap_epoch),.tap_timestamp(tap_timestamp),
  .clk(clk),.ce(ce),.arst_n(rst),.in_gray(gray),.in_de(de),.in_hs(hs),.in_vs(vs),.in_sof(sof),
  .filter_request(request),.threshold(threshold),.mode(mode),.out_rgb(rgb),.out_de(od),.out_hs(oh),.out_vs(ov),
  .out_raw(raw),.out_legacy_mag(mag),.out_legacy_bin(bin),.out_overlay_valid(ovvalid),.out_overlay_edge(ovedge),
  .out_threshold(t),.out_mode(m),.out_filter_enable(filter),.out_nms(nms),.out_nms_valid(nvalid),
  .out_canny_valid(cvalid),.out_canny_edge(cedge),.out_x(x),.out_y(y),.raster_fault(fault));
 m5a_osd display_osd(.clk(clk),.ce(ce),.arst_n(rst),.rgb(rgb),.de(od),.hs(oh),.vs(ov),.threshold(t),.mode(m),.fusion_enable(1'b0),.fusion_active(1'b0),.fusion_age_valid(1'b0),.fusion_age(32'd0),.out_rgb(osd),.out_de(dd),.out_hs(dh),.out_vs(dv));
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
  m5a_osd legacy_osd(.clk(clk),.ce(ce),.arst_n(rst),.rgb(new_image),.de(od),.hs(oh),.vs(ov),.threshold(t),.mode(g[2:0]),.fusion_enable(1'b0),.fusion_active(1'b0),.fusion_age_valid(1'b0),.fusion_age(32'd0),.out_rgb(new_osd[g]),.out_de(),.out_hs(),.out_vs());
 end endgenerate
 reg[91:0] golden[0:WIDTH*HEIGHT-1],q[0:LAT-1],oq[0:OLAT-1],bq[0:BLAT-1];
 reg[2:0] sq[0:LAT-1],osq[0:OLAT-1];reg[7:0] tq[0:LAT-1];reg[2:0] mq[0:LAT-1];reg fq[0:LAT-1];
 reg[11:0] xq[0:LAT-1],yq[0:LAT-1];reg bdq[0:BLAT-1];
 reg[23:0] oldq[0:3][0:EXTRA-1];reg[2:0] olds[0:EXTRA-1];
 reg[23:0] expected_old[0:3];reg[159:0] held;
 integer rp=0,op=0,bp=0,refp=0,cycles=0,pixels=0,basepixels=0,stalls=0,regression[0:3],cannypixels=0;
 integer i,j,h,v,ix,iy,fd,scan,cm,ct,en,pattern;
 reg[2047:0] dir,casepath,goldpath;
 task tick;
 input d,hh,vv;input[91:0] p;input integer xx,yy;
 begin
  if(STALL && cycles%17==7)begin
   @(negedge clk);ce=0;held={rgb,osd,od,oh,ov,dd,dh,dv,raw,mag,bin,ovvalid,ovedge,t,m,filter,nms,nvalid,cvalid,cedge,x,y};
   repeat(3)begin @(posedge clk);#1;if(held!=={rgb,osd,od,oh,ov,dd,dh,dv,raw,mag,bin,ovvalid,ovedge,t,m,filter,nms,nvalid,cvalid,cedge,x,y})$fatal(1,"CE_STALL_OUTPUT");stalls=stalls+1;end
  end
  @(negedge clk);ce=1;de=d;hs=hh;vs=vv;sof=!vv;gray=d?p[7:0]:0;
  // Frame1 invalidates while its five-word write is in progress; frame2
  // invalidates after head prefetch, then returns high: qualification stays low.
  input_qualified=!(TAG_FAULT&&d&&((f==1&&yy==0&&xx==2)||(f==2&&yy==HEIGHT/2&&xx==1)));
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
 initial begin if(!TAG_DIRECT)begin
  if(!$value$plusargs("TAP_FILE=%s",tap_path))$fatal(1,"TAP_FILE");$readmemh(tap_path,tap_gold);
  if(!$value$plusargs("DIR=%s",dir))$fatal(1,"DIR");
  for(i=0;i<LAT;i=i+1)begin q[i]=0;sq[i]=3'b011;tq[i]=0;mq[i]=0;fq[i]=0;xq[i]=0;yq[i]=0;end
  for(i=0;i<OLAT;i=i+1)begin oq[i]=0;osq[i]=3'b011;end
  for(i=0;i<BLAT;i=i+1)begin bq[i]=0;bdq[i]=0;end
  for(i=0;i<EXTRA;i=i+1)begin olds[i]=3'b011;for(j=0;j<4;j=j+1)oldq[j][i]=0;end
  for(i=0;i<4;i=i+1)regression[i]=0;
  for(i=0;i<FRAMES;i=i+1)invalidated[i]=0;
  repeat(4)@(negedge clk);rst=1;repeat(8)@(negedge clk);
  $sformat(casepath,"%0s/cases.txt",dir);fd=$fopen(casepath,"r");if(!fd)$fatal(1,"cases open");
  for(f=0;f<FRAMES;f=f+1)begin
   scan=$fscanf(fd,"%d %d %d %d\n",cm,ct,en,pattern);if(scan!=4)$fatal(1,"cases truncated");mode=cm;threshold=ct;request=en;tag_in=f/2;source_seq=f+99;source_config=f+1;frame_high[f]=ct;frame_filter[f]=en;
   $sformat(goldpath,"%0s/frame_%0d.hex",dir,f);$readmemh(goldpath,golden);
   for(v=0;v<V_TOTAL;v=v+1)for(h=0;h<H_TOTAL;h=h+1)begin
    ix=h-H_BACK;iy=v-V_BACK;
    if(ix>=0 && ix<WIDTH && iy>=0 && iy<HEIGHT)tick(1,h>=HS_CLOCKS,v>=VS_LINES,golden[iy*WIDTH+ix],ix,iy);
    else tick(0,h>=HS_CLOCKS,v>=VS_LINES,0,0,0);
   end
  end
  for(h=0;h<OLAT+8;h=h+1)tick(0,1,1,0,0,0);
  if(pixels!=FRAMES*WIDTH*HEIGHT || basepixels!=pixels || cannypixels==0)$fatal(1,"COVERAGE");
  if(!TAG_FAULT&&(tap_pixels!=WIDTH*HEIGHT*FRAMES||tap_frames!=FRAMES))$fatal(1,"TAP full-frame coverage");
  if(raw_pixels!=WIDTH*HEIGHT*FRAMES||raw_frames!=FRAMES||(TAG_FAULT&&invalid_pixels==0))$fatal(1,"TAG raw/invalid coverage");
  $display("SOURCE_TAG_RAW pixels=%0d invalid=%0d frames=%0d",raw_pixels,invalid_pixels,raw_frames);
  $display("M5C1B_PASS SOURCE_TAG_AND_M5A pixels=%0d frames=%0d stalls=%0d",tap_pixels,tap_frames,stalls);
  test_pass=1;$display("M5A_STREAM_PASS cycles=%0d frames=%0d pixels=%0d canny=%0d stalls=%0d regression=%0d,%0d,%0d,%0d latency=%0d",cycles,FRAMES,pixels,cannypixels,stalls,regression[0],regression[1],regression[2],regression[3],OLAT);$finish;
 end end
 // Directed queue-port stress supplements real-raster evidence. Only the
 // raw EOF/consume event is modeled here; RAM/serialization remain real RTL.
 reg direct_pop=0;reg [319:0] direct_expected[0:15];integer di;
 task direct_tick;begin @(posedge clk);#1;@(negedge clk);end endtask
 task direct_push(input integer n,input bit simultaneous_pop);
 begin
  de=0;sof=1;source_seq=n+99;source_config=n+1;tag_in=n/2;
  direct_tick();sof=0;de=1;direct_pop=simultaneous_pop;
  direct_expected[n]={dut.source_sof_seq,source_config,dut.source_sof_time,64'd77,tag_in};
  direct_tick();de=0;direct_pop=0;
 end endtask
 initial if(TAG_DIRECT)begin
  force dut.tap_raster_valid=direct_pop;force dut.tap_x=WIDTH-1;force dut.tap_y=HEIGHT-1;
  repeat(4)@(negedge clk);rst=1;repeat(8)@(negedge clk);
  for(di=0;di<8;di=di+1)begin direct_push(di,0);repeat(20)direct_tick();end
  if(!dut.tags_full||dut.tag_write!=8||dut.tag_head!==direct_expected[0])$fatal(1,"TAG_QUEUE_FULL_SETUP");
  direct_push(8,0);repeat(10)direct_tick();
  if(dut.tag_write!=8||dut.tag_head!==direct_expected[0])$fatal(1,"TAG_FULL_OVERWRITE");
  direct_pop=1;direct_tick();direct_pop=0;
  if(dut.tag_read!=1||dut.tag_head!==direct_expected[1])$fatal(1,"TAG_ATOMIC_NEXT_HEAD");
  repeat(12)direct_tick();direct_push(8,1);repeat(20)direct_tick();
  if(dut.tag_write!=9||dut.tag_read!=2||dut.tag_head!==direct_expected[2])$fatal(1,"TAG_SIMULTANEOUS_PUSH_POP");
  for(di=3;di<=8;di=di+1)begin direct_pop=1;direct_tick();direct_pop=0;repeat(14)direct_tick();
   if(dut.tag_head!==direct_expected[di])$fatal(1,"TAG_WRAP_ORDER index=%0d",di);
  end
  direct_pop=1;direct_tick();direct_pop=0;if(!dut.tags_empty)$fatal(1,"TAG_DRAIN_EMPTY");
  // Reset and deliberately coincide next-head final word with raw EOF.
  rst=0;repeat(4)direct_tick();rst=1;repeat(8)direct_tick();
  direct_push(0,0);repeat(20)direct_tick();direct_push(1,0);
  while(!(dut.tag_fetch_busy&&dut.tag_fetch_slot==1&&dut.tag_fetch_phase==5))direct_tick();
  direct_pop=1;direct_tick();direct_pop=0;
  if(dut.tag_head!==direct_expected[1]||!dut.tag_head_valid)$fatal(1,"TAG_FINAL_WORD_POP_BYPASS");
  $display("M5C1B_PASS SOURCE_TAG_DIRECT full/nooverwrite/wrap/sameedge/atomic/bypass");$finish;
 end
 initial begin #100000000;if(TAG_DIRECT)$fatal(1,"TAG_DIRECT_TIMEOUT");end
endmodule
