`timescale 1ns/1ps
module tb_standalone_system720p_v3;
 parameter CAMERA_FRAMES=72;
 reg ui_clk=0,cam_clk=0,pix_clk=0,rst_n=0;always #5.208333 ui_clk=~ui_clk;always #5 cam_clk=~cam_clk;always #6.720430 pix_clk=~pix_clk;
 reg[1:0]key_n=3;reg cam_vs=1,cam_valid=0;reg[7:0]cam_data=0;reg inject_b_error=0;
 wire[23:0]rgb;wire de,hs,vs,uart;wire[5:0]led;
 wire[7:0]aid,alen,wid,bid,rid;wire[31:0]aaddr;wire[2:0]asize;wire[1:0]aburst,alock,bresp,rresp;
 wire avalid,atype,aready,wlast,wvalid,wready,bvalid,bready,rlast,rvalid,rready;wire[127:0]wdata,rdata;wire[15:0]wstrb;wire[31:0]accepted,completed,max_service;
 shape_standalone_system #(.DEBOUNCE_CYCLES(4),.LONG_CYCLES(64)) dut(.ui_clk(ui_clk),.cam_clk(cam_clk),.pix_clk(pix_clk),.rst_n(rst_n),.pix_rst_n(rst_n),.pll_locked(rst_n),.cal_done(rst_n),.cal_pass(rst_n),.key_n(key_n),.cam_vs(cam_vs),.cam_valid(cam_valid),.cam_data(cam_data),.display_rgb_out(rgb),.display_de_out(de),.display_hs_out(hs),.display_vs_out(vs),.uart_tx(uart),.led(led),.aid(aid),.alen(alen),.wid(wid),.aaddr(aaddr),.asize(asize),.aburst(aburst),.alock(alock),.avalid(avalid),.atype(atype),.aready(aready),.wdata(wdata),.wstrb(wstrb),.wlast(wlast),.wvalid(wvalid),.wready(wready),.bid(bid),.bresp(bresp),.bvalid(bvalid),.bready(bready),.rid(rid),.rresp(rresp),.rdata(rdata),.rlast(rlast),.rvalid(rvalid),.rready(rready));
 m5c1b_ddr_service_model memory(.clk(ui_clk),.rst_n(rst_n),.stall(1'b0),.service_delay(32'd0),.inject_b_error(inject_b_error),.inject_r_error(1'b0),.accepted(accepted),.completed(completed),.max_service(max_service),.aid(aid),.alen(alen),.wid(wid),.aaddr(aaddr),.asize(asize),.aburst(aburst),.alock(alock),.avalid(avalid),.atype(atype),.aready(aready),.wdata(wdata),.wstrb(wstrb),.wlast(wlast),.wvalid(wvalid),.wready(wready),.bid(bid),.bresp(bresp),.bvalid(bvalid),.bready(bready),.rid(rid),.rresp(rresp),.rdata(rdata),.rlast(rlast),.rvalid(rvalid),.rready(rready));

 localparam N=921600;reg[35:0] gold[0:16*N-1];reg[1:0] expected[0:15];reg expected_valid[0:15];reg[4095:0]root,expectroot,path;
 integer init_i,bank,idx,hi,file,f,y,x;integer source_pos=0,out_pos=0,source_frames=0,out_frames=0,healthy=0,result_count=0,prev_count=0,lcd_checked=0,final_checked=0,osd_checked=0,roi_checked=0,mode_bits=0,threshold_changes=0;
 reg[15:0]coverage=0;reg[63:0]source_ids[0:255],source_cfg[0:255];reg[7:0]source_hi[0:255];reg[2:0]source_mode[0:255];reg source_good[0:255],source_seen[0:255];
 integer seq,b,case_index;reg output_good;reg[63:0]output_id,output_config,output_seq;reg[7:0]output_high;reg[2:0]output_mode;reg[35:0]e;reg[23:0]exp_rgb;
 reg last_valid=0;reg[1:0]last_class=0;reg[63:0]last_id=0,last_cfg=0,last_seq=0;reg[1:0]expected_display_class=0;reg expected_display_valid=0;reg[63:0]expected_display_id=0,expected_display_seq=0;reg[63:0]expected_display_cfg=0;
 wire[23:0]reference_rgb;wire reference_de,reference_hs,reference_vs;
 reference_shape_osd reference(.clk(pix_clk),.ce(1'b1),.arst_n(rst_n),.rgb(dut.display_rgb),.de(dut.sobel_de),.hs(dut.sobel_hs),.vs(dut.sobel_vs),.threshold(dut.display_threshold),.mode(dut.display_mode),.shape_class(expected_display_class),.shape_valid(expected_display_valid&&expected_display_cfg==dut.config_generation&&!dut.standalone_time_fault),.fusion_enable(1'b0),.fusion_active(1'b0),.fusion_age_valid(1'b0),.fusion_age(32'd0),.out_rgb(reference_rgb),.out_de(reference_de),.out_hs(reference_hs),.out_vs(reference_vs));
 reg compare_osd,roi_now,skip_filter;reg[23:0]roi_or_rgb;reg[11:0]px,py;
 task require_file(input[4095:0]p);integer h;begin h=$fopen(p,"r");if(!h)$fatal(1,"MISSING_INPUT %0s",p);$fclose(h);end endtask
 initial begin
  if(!$value$plusargs("GOLDROOT=%s",root)||!$value$plusargs("EXPECTEDROOT=%s",expectroot))$fatal(1,"ORACLE_ROOT_REQUIRED");
  $sformat(path,"%0s/expected.hex",expectroot);require_file(path);$readmemh(path,expected);
  $sformat(path,"%0s/expected_valid.hex",expectroot);require_file(path);$readmemh(path,expected_valid);
  for(bank=0;bank<16;bank=bank+1)begin idx=bank%8;hi=bank<8?64:80;$sformat(path,"%0s/f2_%0d_%0d.hex",root,idx,hi);require_file(path);$readmemh(path,gold,bank*N,(bank+1)*N-1);end
  for(init_i=0;init_i<16*N;init_i=init_i+1)if(^gold[init_i]===1'bx)$fatal(1,"GOLD_UNKNOWN %0d",init_i);
  for(init_i=0;init_i<256;init_i=init_i+1)begin source_seen[init_i]=0;source_good[init_i]=0;end
  #1000;rst_n=1;wait(dut.u_m5b1.run);repeat(1500000)@(negedge cam_clk);cam_vs=0;repeat(20)@(negedge cam_clk);
  for(f=0;f<CAMERA_FRAMES;f=f+1)begin
   cam_vs=1;
   for(y=0;y<720;y=y+1)for(x=0;x<1650;x=x+1)begin @(negedge cam_clk);cam_valid=x<1280;if(x<1280)cam_data=gold[((f/4)%8)*N+y*1280+x][7:0];end
   @(negedge cam_clk);cam_valid=0;cam_vs=0;repeat(478667)@(negedge cam_clk);
  end
  wait(out_frames>=CAMERA_FRAMES+3);repeat(6000)@(negedge pix_clk);
  if(healthy<CAMERA_FRAMES-3||result_count<healthy||lcd_checked<healthy*N||final_checked!=healthy*N||roi_checked<healthy*1788||osd_checked<healthy*N||dut.u_shape.adapter_fault||dut.shape_raster_fault||accepted!=completed+(memory.state!=0))$fatal(1,"SYSTEM_CLOSURE healthy=%0d results=%0d lcd=%0d final=%0d osd=%0d roi=%0d A=%0d done=%0d",healthy,result_count,lcd_checked,final_checked,osd_checked,roi_checked,accepted,completed);
  if(CAMERA_FRAMES>=72&&(coverage!==16'hffff||mode_bits!=7||threshold_changes<1))$fatal(1,"SYSTEM_COVERAGE cov=%h modes=%b changes=%0d",coverage,mode_bits,threshold_changes);
  $display("PASS_STANDALONE_SYSTEM720P camera_frames=%0d output_frames=%0d healthy=%0d results=%0d prev=%0d lcd_pixels=%0d final_pixels=%0d osd_pixels=%0d roi_pixels=%0d coverage=%h modebits=%b changes=%0d A=%0d done=%0d",CAMERA_FRAMES,out_frames,healthy,result_count,prev_count,lcd_checked,final_checked,osd_checked,roi_checked,coverage,mode_bits,threshold_changes,accepted,completed);$finish;
 end
 integer control_sofs=0;
 initial begin wait(rst_n);forever begin @(negedge pix_clk);if(dut.source_sof)begin
   control_sofs=control_sofs+1;
   if(CAMERA_FRAMES>=72&&(control_sofs%8==0||control_sofs==38))begin
    repeat(100)@(negedge pix_clk);key_n=control_sofs==38?2'b10:2'b00;repeat(20)@(negedge pix_clk);key_n=3;
    repeat(14)@(negedge pix_clk);
    if(control_sofs==38&&dut.u_controls.pending_threshold!==8'd80)$fatal(1,"REAL_INCREASE_KEY_NOT80 got=%0d",dut.u_controls.pending_threshold);
    $display("STANDALONE_CONTROL_EVENT source_sof=%0d threshold_event=%b pendingH=%0d pendingMode=%0d",control_sofs,control_sofs==38,dut.u_controls.pending_threshold,dut.u_controls.pending_mode);

   end
  end end end
 always @(posedge ui_clk)if(rst_n)begin
  if(dut.u_m5b1.bridge.started&&(dut.u_m5b1.stop||dut.u_m5b1.video_fault||dut.u_m5b1.quarantine||dut.u_m5b1.ca[2]||dut.u_m5b1.ack))$fatal(1,"SYSTEM_DDR_OR_UNUSED_FAULT stop=%b video=%b q=%b reason=%0d",dut.u_m5b1.stop,dut.u_m5b1.video_fault,dut.u_m5b1.quarantine,dut.u_m5b1.error_reason);
 end
 always @(posedge pix_clk)if(rst_n)begin
  if(dut.lcd_de)begin
   seq=dut.display_seq;if(seq<0||seq>255)$fatal(1,"SOURCE_SEQ_RANGE");
   if(source_pos==0)begin
    source_seen[seq]=1;source_good[seq]=dut.m5b1_lcd_qualified;source_ids[seq]=dut.m5b1_lcd_frame_id;source_cfg[seq]=dut.source_generation;source_hi[seq]=dut.source_threshold;source_mode[seq]=dut.source_mode;
    if(dut.source_threshold!==(CAMERA_FRAMES>=72&&seq>=39?8'd80:8'd64)||dut.source_generation!==(CAMERA_FRAMES>=72&&seq>=39?64'd1:64'd0))$fatal(1,"SOURCE_REAL_EVENT_THRESHOLD_CONFIG seq=%0d H=%0d generation=%0d",seq,dut.source_threshold,dut.source_generation);

    if(dut.source_threshold==80)threshold_changes=threshold_changes+1;
   end
   if(dut.m5b1_lcd_qualified)begin
    if(!source_good[seq]||source_ids[seq]!==dut.m5b1_lcd_frame_id||source_cfg[seq]!==dut.source_generation||source_hi[seq]!==dut.source_threshold||source_mode[seq]!==dut.source_mode)$fatal(1,"SOURCE_IDENTITY_CHANGED");
    case_index=(dut.m5b1_lcd_frame_id/4)%8;
    if(dut.lcd_gray!==gold[case_index*N+source_pos][7:0])$fatal(1,"CAMERA_DDR_LCD_ORACLE seq=%0d fid=%0d pos=%0d got=%0d expected=%0d",seq,dut.m5b1_lcd_frame_id,source_pos,dut.lcd_gray,gold[case_index*N+source_pos][7:0]);lcd_checked=lcd_checked+1;
   end else if(source_good[seq])$fatal(1,"QUALIFIED_FRAME_BROKEN_MIDFRAME");
   if(source_pos==N-1)begin source_pos=0;source_frames=source_frames+1;end else source_pos=source_pos+1;
  end
  if(dut.u_shape.recognition_sof)begin
   expected_display_class<=last_valid&&last_cfg==dut.u_shape.aligned_config&&dut.u_shape.aligned_qualified?last_class:0;
   expected_display_valid<=last_valid&&last_cfg==dut.u_shape.aligned_config&&dut.u_shape.aligned_qualified;
   expected_display_id<=last_valid&&last_cfg==dut.u_shape.aligned_config&&dut.u_shape.aligned_qualified?last_id:0;
   expected_display_seq<=last_valid&&last_cfg==dut.u_shape.aligned_config&&dut.u_shape.aligned_qualified?last_seq:0;
   expected_display_cfg<=dut.u_shape.aligned_config;prev_count=prev_count+1;
  end else if(!dut.u_shape.aligned_qualified||dut.u_shape.aligned_config!=expected_display_cfg)begin expected_display_class<=0;expected_display_valid<=0;expected_display_id<=0;expected_display_seq<=0;end
  if(dut.u_shape.result_done)begin
   seq=dut.u_shape.result_source_seq;if(!source_seen[seq]||dut.u_shape.result_frame_id!==source_ids[seq]||dut.u_shape.result_config!==source_cfg[seq]||dut.u_shape.result_epoch!==1)$fatal(1,"RESULT_SOURCE_IDENTITY");
   b=(source_hi[seq]==64?0:source_hi[seq]==80?8:-100)+(source_ids[seq]/4)%8;
   if(b<0||b>15)$fatal(1,"UNSUPPORTED_REAL_THRESHOLD");
   if(source_good[seq])begin
    if(dut.u_shape.result_class!==expected[b]||dut.u_shape.result_valid!==expected_valid[b])$fatal(1,"SYSTEM_CLASS_MODEL seq=%0d fid=%0d bank=%0d got=%0d/%0d expected=%0d/%0d",seq,source_ids[seq],b,dut.u_shape.result_class,dut.u_shape.result_valid,expected[b],expected_valid[b]);result_count=result_count+1;
   end else if(dut.u_shape.result_valid||dut.u_shape.result_class)$fatal(1,"INVALID_FRAME_CLASS_NOT_UNKNOWN");
   last_valid=dut.u_shape.result_valid;last_class=dut.u_shape.result_class;last_id=dut.u_shape.result_frame_id;last_cfg=dut.u_shape.result_config;last_seq=dut.u_shape.result_source_seq;
  end
  compare_osd=dut.sobel_de;px=dut.final_x;py=dut.final_y;roi_now=compare_osd&&(((px==384||px==895)&&py>=168&&py<=551)||((py==168||py==551)&&px>=384&&px<=895));skip_filter=compare_osd&&px>=664&&px<720&&py>=12&&py<34;
  if(dut.sobel_de)begin
   if(dut.final_x!==out_pos%1280||dut.final_y!==out_pos/1280)$fatal(1,"FINAL_RASTER");
   if(out_pos==0)begin
    output_seq=dut.u_shape.aligned_source_seq;seq=output_seq;output_good=dut.u_shape.aligned_qualified;
    if(!source_seen[seq]||dut.u_shape.aligned_frame_id!==source_ids[seq]||dut.u_shape.aligned_config!==source_cfg[seq]||output_good!==source_good[seq])$fatal(1,"ALIGNED_REAL_SOURCE_TAG seq=%0d",seq);
    output_id=source_ids[seq];output_config=source_cfg[seq];output_high=source_hi[seq];output_mode=source_mode[seq];
   end
   if(output_good)begin
    if(output_high!=64&&output_high!=80)$fatal(1,"FINAL_UNSUPPORTED_REAL_THRESHOLD H=%0d",output_high);b=(output_high==64?0:8)+(output_id/4)%8;e=gold[b*N+out_pos];
    if({dut.final_gray,dut.shape_support,dut.local_edge}!=={e[7:0],e[28],e[29]}||dut.final_filter!==2||dut.display_threshold!==output_high||dut.display_mode!==output_mode||!dut.u_shape.aligned_qualified)$fatal(1,"FINAL_PIXEL_OR_TAG seq=%0d fid=%0d bank=%0d pos=%0d raw=%0d/%0d edge=%b/%b support=%b/%b H=%0d/%0d mode=%0d/%0d",output_seq,output_id,b,out_pos,dut.final_gray,e[7:0],dut.local_edge,e[29],dut.shape_support,e[28],dut.display_threshold,output_high,dut.display_mode,output_mode);
    case(output_mode)0:begin exp_rgb={3{e[7:0]}};mode_bits=mode_bits|1;end 5:begin exp_rgb={24{e[29]}};mode_bits=mode_bits|2;end 6:begin exp_rgb=e[29]?24'hff0000:{3{e[7:0]}};mode_bits=mode_bits|4;end default:$fatal(1,"UNSUPPORTED_PROFILE_MODE");endcase
    if(dut.display_rgb!==exp_rgb)$fatal(1,"FINAL_RGB");final_checked=final_checked+1;
   end
   if(out_pos==N-1)begin
    if(output_good)begin healthy=healthy+1;coverage[b]=1;$display("STANDALONE_FRAME output=%0d source_seq=%0d fid=%0d H=%0d mode=%0d healthy=%0d bank=%0d",out_frames,output_seq,output_id,output_high,output_mode,healthy,b);end
    out_pos=0;out_frames=out_frames+1;
   end else out_pos=out_pos+1;
  end
  #0.2;
  if(dut.shape_valid!==expected_display_valid||dut.shape_class!==expected_display_class||dut.u_shape.display_frame_id!==expected_display_id||dut.u_shape.display_source_seq!==expected_display_seq)$fatal(1,"PREVIOUS_CLASS_IDENTITY seq=%0d class=%0d/%0d valid=%b/%b",dut.u_shape.aligned_source_seq,dut.shape_class,expected_display_class,dut.shape_valid,expected_display_valid);
  if({de,hs,vs}!=={reference_de,reference_hs,reference_vs})$fatal(1,"OSD_SYNC");
  if(compare_osd&&output_good)begin
   if(roi_now)begin if(rgb!==24'h408040)$fatal(1,"ROI_GUIDE");roi_checked=roi_checked+1;end
   else if(!skip_filter&&rgb!==reference_rgb)$fatal(1,"REAL_OSD_MODEL x=%0d y=%0d rgb=%h/%h",px,py,rgb,reference_rgb);
   osd_checked=osd_checked+1;
  end
 end
 initial begin #1500000000;$fatal(1,"SYSTEM720P_WATCHDOG");end
endmodule
