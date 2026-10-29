`timescale 1ns/1ps
module part_keys_system #(parameter DEBOUNCE_CYCLES=1488000,LONG_CYCLES=148800000)(
 input ui_clk,cam_clk,pix_clk,rst_n,pix_rst_n,pll_locked,cal_done,cal_pass,
 input [1:0] key_n,input cam_vs,cam_valid,input [7:0] cam_data,
 output [23:0] display_rgb_out,output display_de_out,display_hs_out,display_vs_out,
 output uart_tx,output [5:0] led,
 output [7:0] aid,alen,wid,output [31:0] aaddr,output [2:0] asize,
 output [1:0] aburst,alock,output avalid,atype,input aready,
 output [127:0] wdata,output [15:0] wstrb,output wlast,wvalid,input wready,
 input [7:0] bid,input [1:0] bresp,input bvalid,output bready,
 input [7:0] rid,input [1:0] rresp,input [127:0] rdata,input rlast,rvalid,output rready);

 wire lcd_de,lcd_hs,lcd_vs,lcd_request;wire [7:0] lcd_gray,lcd_data;
 wire [63:0] m5b1_frame_id,m5b1_epoch;wire m5b1_pix_qualified;
 reg m5b1_lcd_qualified=0;reg [63:0] m5b1_lcd_frame_id=0,m5b1_lcd_epoch=0;
 always @(posedge pix_clk or negedge pix_rst_n)
  if(!pix_rst_n)begin m5b1_lcd_qualified<=0;m5b1_lcd_frame_id<=0;m5b1_lcd_epoch<=0;end
  else begin m5b1_lcd_qualified<=m5b1_pix_qualified;m5b1_lcd_frame_id<=m5b1_frame_id;m5b1_lcd_epoch<=m5b1_epoch;end
 reg control_vs_d=1;
 always @(posedge pix_clk or negedge pix_rst_n)if(!pix_rst_n)control_vs_d<=1;else control_vs_d<=lcd_vs;
 wire source_sof=control_vs_d&&!lcd_vs;
 reg [63:0] pixel_ticks=0,display_seq=0;reg time_fault=0;
 always @(posedge pix_clk or negedge pix_rst_n)
  if(!pix_rst_n)begin pixel_ticks<=0;display_seq<=0;time_fault<=0;end
  else begin
   if(pixel_ticks==64'hffffffffffffffff)time_fault<=1;else pixel_ticks<=pixel_ticks+1'b1;
   if(source_sof)begin if(display_seq==64'hffffffffffffffff)time_fault<=1;else display_seq<=display_seq+1'b1;end
  end
    shape_standalone_frontend u_m5b1(.ui_clk(ui_clk),.cam_clk(cam_clk),.pix_clk(pix_clk),.rst_n(rst_n),
      .pll_locked(pll_locked),.cal_done(cal_done),.cal_pass(cal_pass),
      .cam_vs(cam_vs),.cam_valid(cam_valid),.cam_data(cam_data),
      .pix_sof(source_sof),.pix_request(lcd_request),.pix_data(lcd_data),.frame_id(m5b1_frame_id),.epoch(m5b1_epoch),.pix_qualified(m5b1_pix_qualified),.led(led),
      .aid(aid),.alen(alen),.wid(wid),.aaddr(aaddr),.asize(asize),
      .aburst(aburst),.alock(alock),.avalid(avalid),.atype(atype),.aready(aready),
      .wdata(wdata),.wstrb(wstrb),.wlast(wlast),.wvalid(wvalid),.wready(wready),
      .bid(bid),.bresp(bresp),.bvalid(bvalid),.bready(bready),
      .rid(rid),.rresp(rresp),.rdata(rdata),.rlast(rlast),.rvalid(rvalid),.rready(rready));
	lcd_driver #(.DATA_WIDTH(8)) u_lcd_driver
	(
	    //  global clock
	    .clk        (pix_clk   ),
	    .rst_n      (pix_rst_n), 
	    
	    //  lcd interface
	    .lcd_dclk   (               ),
	    .lcd_blank  (               ),
	    .lcd_sync   (               ),
	    .lcd_request(lcd_request    ), 	//	Request data 1 cycle ahead. 
	    .lcd_hs     (lcd_hs         ),
	    .lcd_vs     (lcd_vs         ),
	    .lcd_en     (lcd_de         ),
	    .lcd_rgb    (lcd_gray),
	    
	    //  user interface
	    .lcd_data   (lcd_data)
	);
	
	
	

 wire event_valid,event_fault;wire [2:0] event_code;
 part_keys_controls #(.DEBOUNCE_CYCLES(DEBOUNCE_CYCLES),.LONG_CYCLES(LONG_CYCLES)) u_controls(
  .clk(pix_clk),.arst_n(pix_rst_n),.ce(1'b1),.sof(source_sof),.key_n(key_n),.event_valid(event_valid),.event_code(event_code),.event_fault(event_fault));
 wire final_de,final_hs,final_vs,raster_fault,base_fault;wire [11:0] final_x,final_y;wire [7:0] final_gray;
 wire base_de,base_hs,base_vs,base_edge,base_support;wire [7:0] base_gray;
 wire [63:0] generation,count_frame,count_seq,count_tick;
 wire [7:0] high_threshold,aligned_high;wire aligned_view,config_fault,view;
 part_keys_config config_control(.clk(pix_clk),.rst_n(pix_rst_n),.ce(1'b1),.source_sof(source_sof),.event_valid(event_valid),.event_code(event_code),.high_threshold(high_threshold),.generation(generation),.view(view),.changed(),.config_fault(config_fault));
 wire diag_held,diag_have,diag_armed;wire [767:0] diag_record;
 wire count_valid,have_value,busy,stale,edge_pixel,edge_support;
 wire [3:0] count,error_code;wire [1:0] confirmations;
 m5a_stream_top #(.WIDTH(1280),.HEIGHT(720),.H_TOTAL(1650)) u_m5a_stream(
  .clk(pix_clk),.ce(1'b1),.arst_n(pix_rst_n),.in_gray(lcd_gray),.in_de(lcd_de),.in_hs(lcd_hs),.in_vs(lcd_vs),.in_sof(~lcd_vs),
  .filter_request(2'd2),.threshold(high_threshold),.mode(3'd0),.out_rgb(),.out_de(base_de),.out_hs(base_hs),.out_vs(base_vs),
  .out_raw(base_gray),.out_legacy_mag(),.out_legacy_bin(),.out_nms(),.out_threshold(),.out_mode(),.out_filter_enable(),
  .out_overlay_valid(),.out_overlay_edge(),.out_nms_valid(),.out_canny_valid(base_support),.out_canny_edge(base_edge),.out_x(),.out_y(),.raster_fault(base_fault),
  .tap_input_frame_id(m5b1_lcd_frame_id),.tap_input_epoch(m5b1_lcd_epoch),.tap_input_qualified(m5b1_lcd_qualified),
  .source_pixel_tick(pixel_ticks),.source_display_seq(display_seq),.source_config_generation(generation),
  .tap_valid(),.tap_class(),.tap_x(),.tap_y(),.tap_high(),.tap_low(),.tap_filter(),.tap_frame_id(),.tap_epoch(),.tap_timestamp(),.tap_display_seq(),.tap_config_generation(),
  .fusion_tap_valid(),.fusion_tap_qualified(),.fusion_tap_support());
 part_open_morph closing(.clk(pix_clk),.rst_n(pix_rst_n),.ce(1'b1),.in_raw(base_gray),.in_de(base_de),.in_hs(base_hs),.in_vs(base_vs),.in_edge(base_edge),.in_support(base_support),.in_fault(base_fault),
  .out_raw(final_gray),.out_de(final_de),.out_hs(final_hs),.out_vs(final_vs),.out_edge(edge_pixel),.out_support(edge_support),.out_fault(raster_fault),.out_x(final_x),.out_y(final_y));
 wire rec_sof,rec_eof,rec_active,aligned_qualified,adapter_fault;
 wire [63:0] aligned_frame,aligned_epoch,aligned_config,aligned_seq;
 part_keys_adapter u_part_adapter(.clk(pix_clk),.rst_n(pix_rst_n),.ce(1'b1),
  .source_sof(source_sof),.source_de(lcd_de),.source_qualified(m5b1_lcd_qualified&&!time_fault),
  .source_frame_id(m5b1_lcd_frame_id),.source_epoch(m5b1_lcd_epoch),.source_config(generation),.source_display_seq(display_seq),.source_high(high_threshold),.source_view(view),.aligned_high(aligned_high),.aligned_view(aligned_view),
  .final_de(final_de),.final_raster_fault(raster_fault),.final_x(final_x),.final_y(final_y),.adapter_fault(adapter_fault),
  .recognition_sof(rec_sof),.recognition_eof(rec_eof),.recognition_active(rec_active),
  .aligned_frame_id(aligned_frame),.aligned_epoch(aligned_epoch),.aligned_config(aligned_config),.aligned_source_seq(aligned_seq),.aligned_qualified(aligned_qualified));
 part_keys_core u_part_core(.clk(pix_clk),.rst_n(pix_rst_n),.ce(1'b1),.source_sof(source_sof),.ticks(pixel_ticks),.live_epoch(m5b1_epoch),
  .event_valid(event_valid),.event_fault(event_fault||time_fault||adapter_fault||config_fault),.event_code(event_code),
  .sof(rec_sof),.eof(rec_eof),.active(rec_active),.qualified(aligned_qualified),.x(final_x),.y(final_y),.edge_pixel(edge_pixel),.edge_support(edge_support),
  .frame_id(aligned_frame),.epoch(aligned_epoch),.config_id(aligned_config),.display_seq(aligned_seq),.generation(generation),
  .count_valid(count_valid),.have_value(have_value),.busy(busy),.count(count),.error_code(error_code),.confirmations(confirmations),
  .count_frame(count_frame),.count_seq(count_seq),.count_tick(count_tick),.stale(stale),
  .diag_held(diag_held),.diag_have(diag_have),.diag_armed(diag_armed),.diag_record(diag_record),.job_done(),.job_good(),.service_cycles());
 assign uart_tx=1'b1;
 part_keys_osd u_osd(.clk(pix_clk),.rst_n(pix_rst_n),.ce(1'b1),.sof(rec_sof),.gray(final_gray),.mask(edge_pixel),
  .de(final_de),.hs(final_hs),.vs(final_vs),.x(final_x),.y(final_y),.view(aligned_view),.high_threshold(aligned_high),.count_valid(count_valid),.have_value(have_value),.busy(busy),
  .count(count),.error_code(error_code),.confirmations(confirmations),.ticks(pixel_ticks),.count_tick(count_tick),
  .diag_held(diag_held),.diag_have(diag_have),.diag_armed(diag_armed),.diag_record(diag_record),.out_rgb(display_rgb_out),.out_de(display_de_out),.out_hs(display_hs_out),.out_vs(display_vs_out));
endmodule
