`timescale 1ns/1ps
// Parameterized M5A component frame, full fixed 512x384 recognizer ROI.
// Coordinate offset places the ROI at its production global location. This
// tests components, not the production-size DDR/adapter raster.
module tb_cap_components;
 parameter FRAMES=100;
 localparam W=544,H=416,HT=576,VT=442,HB=12,VB=10,LAT=4*HT+25,BLAT=2*HT+17,PLAT=HT+11,N=W*H;
 reg clk=0;always #5 clk=~clk;
 reg rst=0,ce=1,de=0,hs=1,vs=1,sof=0;reg[7:0] gray=0;reg[63:0] fid=0,current_fid=0,seq=0,ticks=0;
 always @(posedge clk)if(rst)ticks<=ticks+1;
 wire[23:0] rgb;wire od,oh,ov;wire[7:0] raw,mag,ot,nms;wire[2:0] om;wire[1:0] of,tf,tc;wire bin,os,oe,nv,cv,ed,fault,tv,ftv,fq;wire[11:0] x,y,tx,ty;wire[63:0] tid,te,tg,ts,tt;wire[7:0] th,tl;
 m5a_stream_top #(.WIDTH(W),.HEIGHT(H),.H_TOTAL(HT)) dut(.clk(clk),.ce(ce),.arst_n(rst),.in_gray(gray),.in_de(de),.in_hs(hs),.in_vs(vs),.in_sof(sof),.filter_request(2'd2),.threshold(8'd64),.mode(3'd6),
 .out_rgb(rgb),.out_de(od),.out_hs(oh),.out_vs(ov),.out_raw(raw),.out_legacy_mag(mag),.out_threshold(ot),.out_nms(nms),.out_legacy_bin(bin),.out_overlay_valid(os),.out_overlay_edge(oe),.out_nms_valid(nv),.out_canny_valid(cv),.out_canny_edge(ed),.out_mode(om),.out_filter_enable(of),.out_x(x),.out_y(y),.raster_fault(fault),
 .tap_input_frame_id(fid),.tap_input_epoch(64'd77),.tap_input_qualified(de),.source_pixel_tick(ticks),.source_display_seq(seq),.source_config_generation(64'd7),.tap_valid(tv),.tap_class(tc),.tap_x(tx),.tap_y(ty),.tap_high(th),.tap_low(tl),.tap_filter(tf),.tap_frame_id(tid),.tap_epoch(te),.tap_timestamp(tt),.tap_display_seq(ts),.tap_config_generation(tg),.fusion_tap_valid(ftv),.fusion_tap_qualified(fq),.fusion_tap_support());
 wire rec_sof=od&&x==0&&y==0;reg rec_eof=0;
 // The fixed recognizer requires EOF as a separate, inactive control beat.
 always @(posedge clk)if(!rst)rec_eof<=0;else if(ce)rec_eof<=od&&x==W-1&&y==H-1;
 wire[11:0] gx=x+12'd368,gy=y+12'd152;
 wire done,valid,dvalid,busy;wire[1:0] category,dc;wire[63:0] rid,rcfg,rep,rseq,did,dcfg,dep,dseq;
 shape_recognizer_epoch recognize(.clk(clk),.rst_n(rst),.ce(ce),.sof(rec_sof),.eof(rec_eof),.active(od&&!rec_sof),.support(cv),.edge_pixel(ed),.source_valid(1'b1),.x(gx),.y(gy),.frame_id(current_fid),.config_generation(64'd7),.epoch(64'd77),.source_display_seq(current_fid+64'd99),
 .result_done(done),.result_valid(valid),.result_class(category),.result_frame_id(rid),.result_config_generation(rcfg),.result_epoch(rep),.result_source_display_seq(rseq),.display_class(dc),.display_valid(dvalid),.display_frame_id(did),.display_config_generation(dcfg),.display_epoch(dep),.display_source_display_seq(dseq),.busy(busy));
 reg[1:0] expected[0:FRAMES-1];reg expected_valid[0:FRAMES-1];reg[101:0] gold[0:N-1],q[0:LAT-1],bq[0:BLAT-1],pq[0:PLAT-1];reg[2:0] syncq[0:LAT-1];reg bdq[0:BLAT-1],pdq[0:PLAT-1];
 integer p=0,bp=0,pp=0,cycles=0,pixels=0,taps=0,bases=0,filtered=0,results=0,displays=0,outframes=0,stalls=0,osd_pixels=0;
 integer i,f,v,h,ix,iy,pos,load;reg probe=0;reg[4095:0] root,path,goldroot;reg[127:0] held;
 function[23:0] dec3(input integer number);reg[7:0] a,b,c;begin a=48+(number/100)%10;b=48+(number/10)%10;c=48+number%10;dec3={a,b,c};end endfunction
 task require_file(input[4095:0] name);integer file;begin file=$fopen(name,"r");if(!file)$fatal(1,"COMPONENT_INPUT_UNREADABLE %0s",name);$fclose(file);end endtask
 always @(posedge clk)if(rst&&ce)begin
  if(done)begin
   if(rid!==results+1||rcfg!==7||rep!==77||rseq!==results+100||category!==expected[results]||valid!==expected_valid[results])$fatal(1,"COMPONENT_MODEL_RESULT sample=%0d actual=%0d/%0d expected=%0d/%0d",results,category,valid,expected[results],expected_valid[results]);
   $display("COMPONENT_RESULT sample=%0d frame=%0d class=%0d valid=%0d",results,rid,category,valid);results=results+1;
  end
  if(rec_sof)begin
   #0.1;
   if(outframes==0)begin if(dvalid||dc)$fatal(1,"COMPONENT_INITIAL_DISPLAY");end
   else begin
    if(dc!==expected[outframes-1]||dvalid!==expected_valid[outframes-1]||did!==(expected_valid[outframes-1]?outframes:0)||dcfg!==7||dep!==77||dseq!==(expected_valid[outframes-1]?outframes+99:0))$fatal(1,"COMPONENT_PREVIOUS_DISPLAY frame=%0d class=%0d valid=%0d",outframes,dc,dvalid);
    displays=displays+1;
   end
   outframes=outframes+1;
  end
 end
 task tick(input bit d,input bit hh,input bit vv,input[101:0] e);
 begin
  if(!probe&&cycles%127==37)begin
   @(negedge clk);ce=0;held={rgb,od,oh,ov,raw,mag,ot,nms,om,of,bin,os,oe,nv,cv,ed,x,y};
   repeat(2)begin @(posedge clk);#1;if(held!=={rgb,od,oh,ov,raw,mag,ot,nms,om,of,bin,os,oe,nv,cv,ed,x,y})$fatal(1,"COMPONENT_CE_FREEZE");stalls=stalls+1;end
  end
  @(negedge clk);ce=1;de=d;hs=hh;vs=vv;sof=!vv;gray=d?e[7:0]:0;
  @(posedge clk);
  if(!probe&&ftv)begin
   pos=taps%N;if(!tv||!fq||tx!==pos%W||ty!==pos/W||tc!==gold[pos][93:92]||tid!==f+1||te!==77||tg!==7||ts!==f+100||tf!==2||th!==64||tl!==32)$fatal(1,"COMPONENT_TAP_OR_IDENTITY sample=%0d pos=%0d",f,pos);taps=taps+1;
  end
  #1;
  if(!probe)begin
   if({od,oh,ov}!==syncq[p])$fatal(1,"COMPONENT_FINAL_SYNC");
   if(rgb!==(syncq[p][2]?q[p][67:44]:24'd0))$fatal(1,"COMPONENT_RGB");
   if(od)begin
    pos=pixels%N;if(x!==pos%W||y!==pos/W||ot!==64||om!==6||of!==2)$fatal(1,"COMPONENT_FINAL_PACKET");
    if({raw,mag,bin,os,oe,nms,nv,cv,ed}!=={q[p][7:0],q[p][15:8],q[p][16],q[p][17],q[p][18],q[p][26:19],q[p][27],q[p][28],q[p][29]})$fatal(1,"COMPONENT_PIXEL sample=%0d x=%0d y=%0d",f,x,y);pixels=pixels+1;
   end
   if(bdq[bp])begin if({dut.u_base.center_support,dut.u_base.center_magnitude,dut.u_base.center_direction}!=={bq[bp][17],bq[bp][41:30],bq[bp][43:42]})$fatal(1,"COMPONENT_GRADIENT");bases=bases+1;end
   if(pdq[pp])begin if(!dut.u_base.u_m32.aligned_de||dut.u_base.u_m32.processed_gray!==pq[pp][101:94])$fatal(1,"COMPONENT_FILTERED_GRAY expected=%0d got=%0d",pq[pp][101:94],dut.u_base.u_m32.processed_gray);filtered=filtered+1;end
  end
  syncq[p]={d,hh,vv};q[p]=e;p=(p+1)%LAT;bq[bp]=e;bdq[bp]=d;bp=(bp+1)%BLAT;pq[pp]=e;pdq[pp]=d;pp=(pp+1)%PLAT;cycles=cycles+1;
 end endtask
 // Independent renderer raster: fixed old font/reference is driven by expected
 // previous class, while new OSD is driven by actual recognizer display state.
 reg osd_de=0,osd_hs=1,osd_vs=1;reg[1:0] display_expected=0;reg display_valid_expected=0;wire[23:0] osd_rgb,reference_rgb;wire osd_od,osd_oh,osd_ov,ref_od,ref_oh,ref_ov;
 shape_osd osd(.clk(clk),.ce(1'b1),.arst_n(rst),.rgb(24'h123456),.de(osd_de),.hs(osd_hs),.vs(osd_vs),.threshold(8'd64),.mode(3'd6),.filter_id(2'd2),.shape_class(dc),.shape_valid(dvalid),.fusion_enable(1'b0),.fusion_active(1'b0),.fusion_age_valid(1'b0),.fusion_age(32'd0),.out_rgb(osd_rgb),.out_de(osd_od),.out_hs(osd_oh),.out_vs(osd_ov));
 reference_shape_osd refosd(.clk(clk),.ce(1'b1),.arst_n(rst),.rgb(24'h123456),.de(osd_de),.hs(osd_hs),.vs(osd_vs),.threshold(8'd64),.mode(3'd6),.shape_class(display_expected),.shape_valid(display_valid_expected),.fusion_enable(1'b0),.fusion_active(1'b0),.fusion_age_valid(1'b0),.fusion_age(32'd0),.out_rgb(reference_rgb),.out_de(ref_od),.out_hs(ref_oh),.out_vs(ref_ov));
 task render;integer xx,yy;begin
  @(negedge clk);ce=0;osd_de=0;osd_vs=0;repeat(5)@(negedge clk);osd_vs=1;
  for(yy=0;yy<34;yy=yy+1)begin
   for(xx=0;xx<1280;xx=xx+1)begin
    osd_de=1;@(posedge clk);#1;
    if({osd_od,osd_oh,osd_ov}!=={ref_od,ref_oh,ref_ov})$fatal(1,"COMPONENT_OSD_SYNC");
    if(!(xx>=664&&xx<720&&yy>=12&&yy<34)&&osd_rgb!==reference_rgb)$fatal(1,"COMPONENT_OSD_PREVIOUS_CLASS");
    osd_pixels=osd_pixels+1;@(negedge clk);
   end
   osd_de=0;repeat(32)@(negedge clk);
  end
 end endtask
 initial begin
  if(!$value$plusargs("ROOT=%s",root))$fatal(1,"ROOT");
  if(!$value$plusargs("GOLDROOT=%s",goldroot))goldroot=root;
  path={root,"/expected.hex"};require_file(path);for(i=0;i<FRAMES;i=i+1)expected[i]='x;$readmemh(path,expected);
  path={root,"/expected_valid.hex"};require_file(path);for(i=0;i<FRAMES;i=i+1)expected_valid[i]='x;$readmemh(path,expected_valid);
  for(i=0;i<FRAMES;i=i+1)if(^expected[i]===1'bx||expected_valid[i]===1'bx)$fatal(1,"COMPONENT_EXPECTED_UNKNOWN");
  for(i=0;i<LAT;i=i+1)begin q[i]=0;syncq[i]=3'b011;end
  for(i=0;i<BLAT;i=i+1)begin bq[i]=0;bdq[i]=0;end
  for(i=0;i<PLAT;i=i+1)begin pq[i]=0;pdq[i]=0;end
  repeat(5)@(negedge clk);rst=1;repeat(8)@(negedge clk);
  for(f=0;f<FRAMES;f=f+1)begin
   $sformat(path,"%0s/gray_gold_%0s.hex",goldroot,dec3(f));require_file(path);for(i=0;i<N;i=i+1)gold[i]='x;$readmemh(path,gold);for(i=0;i<N;i=i+1)if(^gold[i]===1'bx)$fatal(1,"COMPONENT_GOLD_UNKNOWN");current_fid=f+1;seq=f+99;
   for(v=0;v<VT;v=v+1)for(h=0;h<HT;h=h+1)begin ix=h-HB;iy=v-VB;fid=ix>=0&&ix<W&&iy>=0&&iy<H?f+1:9999;if(ix>=0&&ix<W&&iy>=0&&iy<H)tick(1,h>=3,v>=2,gold[iy*W+ix]);else tick(0,h>=3,v>=2,0);end
   if(results!=f+1||pixels!=(f+1)*N||taps!=pixels||bases!=pixels||filtered!=pixels||fault)$fatal(1,"COMPONENT_FRAME_CLOSURE sample=%0d results=%0d pixels=%0d taps=%0d grad=%0d filtered=%0d fault=%b",f,results,pixels,taps,bases,filtered,fault);
   display_expected=f==0?0:expected[f-1];display_valid_expected=f==0?0:expected_valid[f-1];render;
  end
  probe=1;current_fid=FRAMES+1;seq=FRAMES+99;
  for(v=0;v<20;v=v+1)for(h=0;h<HT;h=h+1)begin ix=h-HB;iy=v-VB;fid=FRAMES+1;tick(ix>=0&&ix<W&&iy>=0,h>=3,v>=2,102'd220);end
  if(displays!=FRAMES||results!=FRAMES)$fatal(1,"COMPONENT_LAST_DISPLAY_MISSING");
  display_expected=expected[FRAMES-1];display_valid_expected=expected_valid[FRAMES-1];render;
  $display("PASS_GAUSSIAN_COMPONENT_CHAIN_MODEL frames=%0d pixels=%0d taps=%0d gradient=%0d filtered=%0d results=%0d displays=%0d osd_pixels=%0d stalls=%0d latency=%0d",FRAMES,pixels,taps,bases,filtered,results,displays,osd_pixels,stalls,LAT);$finish;
 end
 initial begin #2000000000;$fatal(1,"COMPONENT_WATCHDOG");end
endmodule
