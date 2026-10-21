`timescale 1ns/1ps
module shape_standalone_system #(parameter DEBOUNCE_CYCLES=1488000,LONG_CYCLES=74400000)(
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
 wire sobel_hs,sobel_vs,sobel_de;
    wire [63:0] m5b1_frame_id,m5b1_epoch,pixel_ticks,display_seq,config_generation,source_generation;
    wire m5b1_pix_qualified;
    reg m5b1_lcd_qualified=0;reg [63:0] m5b1_lcd_frame_id=0,m5b1_lcd_epoch=0;
    always @(posedge pix_clk or negedge pix_rst_n)
      if(!pix_rst_n)begin m5b1_lcd_qualified<=0;m5b1_lcd_frame_id<=0;m5b1_lcd_epoch<=0;end
      else begin m5b1_lcd_qualified<=m5b1_pix_qualified;m5b1_lcd_frame_id<=m5b1_frame_id;m5b1_lcd_epoch<=m5b1_epoch;end
    reg control_vs_d=1'b1;always @(posedge pix_clk or negedge pix_rst_n)if(!pix_rst_n)control_vs_d<=1;else control_vs_d<=lcd_vs;
    wire source_sof=control_vs_d&&!lcd_vs;
    reg [63:0] standalone_ticks=0,standalone_sequence=0;reg standalone_time_fault=0;
    always @(posedge pix_clk or negedge pix_rst_n)
     if(!pix_rst_n)begin standalone_ticks<=0;standalone_sequence<=0;standalone_time_fault<=0;end
     else begin
      if(standalone_ticks==64'hffffffffffffffff)standalone_time_fault<=1;else standalone_ticks<=standalone_ticks+1'b1;
      if(source_sof)begin if(standalone_sequence==64'hffffffffffffffff)standalone_time_fault<=1;else standalone_sequence<=standalone_sequence+1'b1;end
     end
    assign pixel_ticks=standalone_ticks;assign display_seq=standalone_sequence;
    wire [7:0] control_threshold,source_threshold,display_threshold,final_gray;
    wire [2:0] control_mode,source_mode,display_mode;wire [1:0] final_filter;
    wire [11:0] final_x,final_y;wire local_edge,shape_support,shape_raster_fault;
    wire [1:0] shape_class;wire shape_valid;wire [63:0] shape_display_config,shape_display_epoch;
    wire shape_visible=shape_valid&&shape_display_config==config_generation&&shape_display_epoch==m5b1_lcd_epoch&&config_generation!=64'hffffffffffffffff&&!standalone_time_fault;
    wire [23:0] display_rgb,osd_rgb;wire osd_de,osd_hs,osd_vs;
    assign uart_tx=1'b1;
    shape_standalone_frontend u_m5b1(.ui_clk(ui_clk),.cam_clk(cam_clk),.pix_clk(pix_clk),.rst_n(rst_n),
      .pll_locked(pll_locked),.cal_done(cal_done),.cal_pass(cal_pass),
      .cam_vs(cam_vs),.cam_valid(cam_valid),.cam_data(cam_data),
      .pix_sof(source_sof),.pix_request(lcd_request),.pix_data(lcd_data),.frame_id(m5b1_frame_id),.epoch(m5b1_epoch),.pix_qualified(m5b1_pix_qualified),.led(led),
      .aid(aid),.alen(alen),.wid(wid),.aaddr(aaddr),.asize(asize),
      .aburst(aburst),.alock(alock),.avalid(avalid),.atype(atype),.aready(aready),
      .wdata(wdata),.wstrb(wstrb),.wlast(wlast),.wvalid(wvalid),.wready(wready),
      .bid(bid),.bresp(bresp),.bvalid(bvalid),.bready(bready),
      .rid(rid),.rresp(rresp),.rdata(rdata),.rlast(rlast),.rvalid(rvalid),.rready(rready));
	//  LCD Timing Driver
	
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
	
	
	
	////////////////////////////////////////////////////////////////
    // M3: pix_clk already owns the DDR FWFT read stream. The original
    // lcd_request and ~lcd_vs feedback remain untouched. Algorithm slot(x,y)
    // displays center(x-1,y-1); top two rows/left two columns are black.
    shape_standalone_controls #(.DEBOUNCE_CYCLES(DEBOUNCE_CYCLES),.LONG_CYCLES(LONG_CYCLES)) u_controls(.clk(pix_clk),.ce(1'b1),.arst_n(pix_rst_n),.key_n(key_n),.frame_start(source_sof),
      .threshold(control_threshold),.mode(control_mode),.pending_threshold(),.pending_mode(),.config_generation(config_generation),
      .effective_threshold(source_threshold),.effective_mode(source_mode),.effective_generation(source_generation));
    m5a_stream_top #(.WIDTH(1280),.HEIGHT(720),.H_TOTAL(1650)) u_m5a_stream(
      .clk(pix_clk),.ce(1'b1),.arst_n(pix_rst_n),.in_gray(lcd_gray),.in_de(lcd_de),.in_hs(lcd_hs),.in_vs(lcd_vs),.in_sof(~lcd_vs),
      .filter_request(2'd2),.threshold(source_threshold),.mode(source_mode),.out_rgb(display_rgb),.out_de(sobel_de),.out_hs(sobel_hs),.out_vs(sobel_vs),
      .out_raw(final_gray),.out_legacy_mag(),.out_legacy_bin(),.out_nms(),.out_threshold(display_threshold),.out_mode(display_mode),.out_filter_enable(final_filter),
      .out_overlay_valid(),.out_overlay_edge(),.out_nms_valid(),.out_canny_valid(shape_support),.out_canny_edge(local_edge),.out_x(final_x),.out_y(final_y),.raster_fault(shape_raster_fault),
      .tap_input_frame_id(m5b1_lcd_frame_id),.tap_input_epoch(m5b1_lcd_epoch),.tap_input_qualified(m5b1_lcd_qualified),
      .source_pixel_tick(pixel_ticks),.source_display_seq(display_seq),.source_config_generation(source_generation),
      .tap_valid(),.tap_class(),.tap_x(),.tap_y(),.tap_high(),.tap_low(),.tap_filter(),.tap_frame_id(),.tap_epoch(),.tap_timestamp(),.tap_display_seq(),.tap_config_generation(),
      .fusion_tap_valid(),.fusion_tap_qualified(),.fusion_tap_support());
    shape_stream_adapter_contract_v2 u_shape(.clk(pix_clk),.rst_n(pix_rst_n),.ce(1'b1),
      .source_sof(source_sof),.source_de(lcd_de),.source_qualified(m5b1_lcd_qualified&&source_generation!=64'hffffffffffffffff&&!standalone_time_fault),
      .source_frame_id(m5b1_lcd_frame_id),.source_epoch(m5b1_lcd_epoch),.source_config(source_generation),.source_display_seq(display_seq),
      .final_de(sobel_de),.final_support(shape_support),.final_edge(local_edge),.final_raster_fault(shape_raster_fault),.final_x(final_x),.final_y(final_y),
      .display_class(shape_class),.display_valid(shape_valid),.display_frame_id(),.display_epoch(shape_display_epoch),.display_config(shape_display_config),.display_source_seq(),
      .result_done(),.result_valid(),.result_class(),.result_frame_id(),.result_epoch(),.result_config(),.result_source_seq(),
      .adapter_fault(),.recognition_sof(),.recognition_eof(),.aligned_frame_id(),.aligned_epoch(),.aligned_config(),.aligned_source_seq(),.aligned_qualified());
    shape_osd u_osd(.clk(pix_clk),.ce(1'b1),.arst_n(pix_rst_n),.rgb(display_rgb),.de(sobel_de),.hs(sobel_hs),.vs(sobel_vs),
      .threshold(display_threshold),.mode(display_mode),.filter_id(final_filter),.shape_class(shape_class),.shape_valid(shape_visible),
      .fusion_enable(1'b0),.fusion_active(1'b0),.fusion_age_valid(1'b0),.fusion_age(32'd0),.out_rgb(osd_rgb),.out_de(osd_de),.out_hs(osd_hs),.out_vs(osd_vs));
    //
 assign display_rgb_out=osd_rgb;assign display_de_out=osd_de;assign display_hs_out=osd_hs;assign display_vs_out=osd_vs;
endmodule
