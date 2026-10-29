`timescale 1ns/1ps
module tb_keys_video;
localparam W=1280,H=720,HT=1650;
reg clk=0;always #5 clk=~clk;reg rst_n=0,ce=1,ide=0,ihs=1,ivs=1,source_sof=0;reg [7:0] gray=0;reg [1:0] key_n=3;
reg [63:0] ticks=0,fid=64'h1000000000000001,seq=64'h3000000000000001;always @(posedge clk)ticks<=ticks+1;
wire ev,ef,view,config_fault;wire [2:0] code;wire [7:0] high;wire [63:0] gen;
part_keys_controls #(.DEBOUNCE_CYCLES(4),.LONG_CYCLES(10000)) controls(.clk(clk),.arst_n(rst_n),.ce(ce),.sof(source_sof),.key_n(key_n),.event_valid(ev),.event_code(code),.event_fault(ef));
part_keys_config config_control(.clk(clk),.rst_n(rst_n),.ce(ce),.source_sof(source_sof),.event_valid(ev),.event_code(code),.high_threshold(high),.generation(gen),.view(view),.config_fault(config_fault));
wire fde,fhs,fvs,fs,fe,ff;wire [7:0] fr,fh,th,tl;wire [11:0] fx,fy;wire tv;wire [63:0] tg;
wire de,hs,vs,ep,sp,rf;wire [7:0] raw;wire [11:0] x,y;
m5a_stream_top #(.WIDTH(W),.HEIGHT(H),.H_TOTAL(HT)) front(.clk(clk),.ce(ce),.arst_n(rst_n),.in_gray(gray),.in_de(ide),.in_hs(ihs),.in_vs(ivs),.in_sof(!ivs),.filter_request(2'd2),.threshold(high),.mode(3'd0),.out_de(fde),.out_hs(fhs),.out_vs(fvs),.out_raw(fr),.out_threshold(fh),.out_x(fx),.out_y(fy),.out_canny_valid(fs),.out_canny_edge(fe),.raster_fault(ff),.tap_input_frame_id(fid),.tap_input_epoch(64'h2000000000000001),.tap_input_qualified(1'b1),.source_pixel_tick(ticks),.source_display_seq(seq),.source_config_generation(gen),.tap_valid(tv),.tap_high(th),.tap_low(tl),.tap_config_generation(tg));
part_open_morph morph(.clk(clk),.rst_n(rst_n),.ce(ce),.in_raw(fr),.in_de(fde),.in_hs(fhs),.in_vs(fvs),.in_edge(fe),.in_support(fs),.in_fault(ff),.out_raw(raw),.out_de(de),.out_hs(hs),.out_vs(vs),.out_edge(ep),.out_support(sp),.out_fault(rf),.out_x(x),.out_y(y));
wire sof,eof,active,qualified,af,av;wire [7:0] ah;wire [63:0] frame_id,epoch,config_id,display_seq;
part_keys_adapter adapter(.clk(clk),.rst_n(rst_n),.ce(ce),.source_sof(source_sof),.source_de(ide),.source_qualified(1'b1),.source_frame_id(fid),.source_epoch(64'h2000000000000001),.source_config(gen),.source_display_seq(seq),.source_high(high),.source_view(view),.aligned_high(ah),.aligned_view(av),.final_de(de),.final_raster_fault(rf),.final_x(x),.final_y(y),.adapter_fault(af),.recognition_sof(sof),.recognition_eof(eof),.recognition_active(active),.aligned_frame_id(frame_id),.aligned_epoch(epoch),.aligned_config(config_id),.aligned_source_seq(display_seq),.aligned_qualified(qualified));
wire valid,have,busy,done,good;wire [3:0] count,err;wire [1:0] conf;wire [63:0] ct,cf;wire [20:0] service;
part_keys_core #(.INTERVAL_TICKS(0),.DIAG_ARM_TICKS(0)) core(.clk(clk),.rst_n(rst_n),.ce(ce),.source_sof(source_sof),.ticks(ticks),.live_epoch(64'h2000000000000001),.generation(gen),.event_valid(ev),.event_fault(af||ef||config_fault),.event_code(code),.sof(sof),.eof(eof),.active(active),.qualified(qualified),.x(x),.y(y),.edge_pixel(ep),.edge_support(sp),.frame_id(frame_id),.epoch(epoch),.config_id(config_id),.display_seq(display_seq),.count_valid(valid),.have_value(have),.busy(busy),.count(count),.error_code(err),.confirmations(conf),.count_frame(cf),.count_tick(ct),.job_done(done),.job_good(good),.service_cycles(service));
wire [23:0] rgb;wire ode,ohs,ovs;
part_keys_osd osd(.clk(clk),.rst_n(rst_n),.ce(ce),.sof(sof),.gray(raw),.mask(ep),.de(de),.hs(hs),.vs(vs),.x(x),.y(y),.view(av),.high_threshold(ah),.count_valid(valid),.have_value(have),.busy(busy),.count(count),.error_code(err),.confirmations(conf),.ticks(ticks),.count_tick(ct),.diag_held(1'b0),.diag_have(1'b0),.diag_armed(1'b0),.diag_record(768'd0),.out_rgb(rgb),.out_de(ode),.out_hs(ohs),.out_vs(ovs));
reg [10:0] vector[0:W*H-1];reg osd_gold[0:6*396*14-1];string path;
integer xx,yy,k,frames=0,pixels=0,checked=0,jobs=0,source_frames=0,baseframes=0,basechecked=0,osdchecked=0,events=0;
integer hiwant[1:8];integer genwant[1:8];integer vwant[1:8];integer idx,oidx;reg want_edge;reg [23:0] want_rgb;reg check_rgb;
always @(posedge clk)if(rst_n&&ce)begin
 if(af||ef||config_fault||(rf&&de))$fatal(1,"VIDEO_FAULT");
 if(ev)events=events+1;
 if(source_sof)begin source_frames=source_frames+1;if(high!=hiwant[source_frames]||gen!=genwant[source_frames]||view!=vwant[source_frames])$fatal(1,"SOURCE_ATOMIC f=%d h=%d gen=%d view=%d",source_frames,high,gen,view);end
 if(fde)begin if(fx==0&&fy==0)baseframes=baseframes+1;if(fh!=hiwant[baseframes])$fatal(1,"REAL_M5A_THRESHOLD");basechecked=basechecked+1;end
 if(tv&&(th!=(tg==1?48:tg==2?40:tg==3?32:40)||tl!=th/2))$fatal(1,"TAP_CONFIG_THRESHOLD");
 if(sof)begin frames=frames+1;pixels=0;end
 check_rgb=0;
 if(de)begin
  idx=hiwant[frames]==48?0:hiwant[frames]==40?1:2;want_edge=vector[y*W+x][8+idx];
  if(raw!==vector[y*W+x][7:0]||ep!==want_edge||sp!==(x>=6&&x<W-6&&y>=6&&y<H-6))$fatal(1,"VIDEO_PIXEL f=%d x=%d y=%d raw=%d edge=%b expected=%b",frames,x,y,raw,ep,want_edge);
  if(ah!=hiwant[frames]||av!=vwant[frames]||config_id!=genwant[frames]||!qualified)$fatal(1,"ALIGNED_FRAME_CONFIG");
  pixels=pixels+1;checked=checked+1;
  if(x>=16&&x<412&&y>=56&&y<70)begin oidx=(vwant[frames]*3+idx)*396*14+(y-56)*396+x-16;want_rgb=osd_gold[oidx]?24'hffffff:24'h0;check_rgb=1;end
  else if(y>=90&&!(((x==160||x==1119)&&y<=629)||((y==90||y==629)&&x>=160&&x<=1119)))begin want_rgb=vwant[frames]?(want_edge?24'hffffff:24'h0):{raw,raw,raw};check_rgb=1;end
 end
 if(eof&&pixels!=W*H)$fatal(1,"FRAME_LENGTH");
 if(done)begin jobs=jobs+1;if(!good||core.job_config!=gen)$fatal(1,"JOB_RESULT e=%d",err);$display("VIDEO_JOB frame=%h gen=%d count=%d",core.job_frame,core.job_config,core.job_count);end
 #1;if(check_rgb)begin if(rgb!==want_rgb)$fatal(1,"OSD_PIXEL f=%d x=%d y=%d got=%h want=%h",frames,x,y,rgb,want_rgb);osdchecked=osdchecked+1;end
end
task tick;begin @(posedge clk);#2;@(negedge clk);end endtask
task frame;begin
 source_sof=1;ivs=0;tick();source_sof=0;repeat(HT-1)tick();ivs=1;repeat(14*HT)tick();
 for(yy=0;yy<H;yy=yy+1)for(xx=0;xx<HT;xx=xx+1)begin
  if(xx==0&&yy==300)case(k)3,4:key_n=2;5:key_n=1;6:key_n=0;default:begin end endcase
  if(xx==0&&yy==301)key_n=3;
  ide=xx<W;ihs=xx<W;gray=xx<W?vector[yy*W+xx][7:0]:0;tick();
 end
 ide=0;ihs=1;gray=0;repeat(15*HT)tick();
end endtask
initial begin
 for(k=1;k<=8;k=k+1)begin hiwant[k]=k<=3?48:k==5?32:40;genwant[k]=k<=3?1:k==4?2:k==5?3:4;vwant[k]=k>=7;end
 if(!$value$plusargs("DATA=%s",path))$fatal(1,"DATA");$readmemh({path,"/video.hex"},vector);$readmemh({path,"/osd.hex"},osd_gold);
 repeat(5)tick();rst_n=1;repeat(20)tick();
 for(k=1;k<=8;k=k+1)begin
  if(k>1)begin fid=fid+1;seq=seq+1;end frame();
  // Allow the actual CCL to finish before the next source frame in this
  // functional fixture; real DDR service cadence is outside this test.
  repeat(750000)tick();
  if(k==3||k==8)begin if(!valid||!have||count!=5||conf!=3)$fatal(1,"CURRENT5 f=%d c=%d conf=%d",k,count,conf);end
  if(k>=4&&k<=6)begin if(valid||!have||count!=5||conf!=1)$fatal(1,"CONFIG_RECONFIRM f=%d conf=%d",k,conf);end
  if(k==7&&conf!=2)$fatal(1,"VIEW_INTERRUPTED_CONFIRM");
 end
 if(frames!=8||source_frames!=8||jobs!=8||checked!=8*W*H||basechecked!=checked||events!=4)$fatal(1,"COVERAGE f=%d jobs=%d pixels=%d",frames,jobs,checked);
 $display("PASS_KEYS_VIDEO frames=%0d pixels=%0d base_threshold_pixels=%0d OSD_pixels=%0d jobs=%0d real_keys=%0d H48_40_32_40 ABA view CURRENT_LAST",frames,checked,basechecked,osdchecked,jobs,events);$finish;
end
initial begin repeat(19000000)@(posedge clk);$fatal(1,"VIDEO_WATCHDOG");end
endmodule
