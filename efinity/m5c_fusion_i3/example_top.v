`timescale 1ns/1ps

//`include "ddr3_controller.vh"


module example_top #(parameter M5A_FILTER_ENABLE=1, parameter SIM_DATA=0)
(
    input [1:0] key_n, // K1=N2, K2=M2; active-low, 1.8V

	////////////////////////////////////////////////////////////////
	//	External Clock & Reset
	//input 			nrst, 			//	Button K2
	input 			clk_24m,			//	24MHz Crystal
	input 			clk_25m,			//	25MHz Crystal 
	
	
	////////////////////////////////////////////////////////////////
	//	System Clock
	output 			sys_pll_rstn_o, 		
	
	input 			clk_sys,			//	Sys PLL 96MHz 
	input 			clk_pixel,			//	Sys PLL 74.25MHz
	input 			clk_pixel_2x,		//	Sys PLL 148.5MHz
	input 			clk_pixel_10x,		//	Sys PLL 742.5MHz
	
	input 			sys_pll_lock,		//	Sys PLL Lock
	
	////////////////////////////////////////////////////////////////
	//	MIPI-DSI Clock & Reset
	output 			dsi_pll_rstn_o,
	
	input 			dsi_refclk_i,		//	48MHz Reference Clock (for DSI PLL)
	input 			dsi_byteclk_i,		//	DSI Byte Clock (1X)
	input 			dsi_serclk_i,		//	DSI Serial Clock (4X 45)
	input 			dsi_txcclk_i,		//	DSI Serial Clock (4X 135)
	
	input 			dsi_pll_lock,
	
	////////////////////////////////////////////////////////////////
	//	DDR Clock
	output 			ddr_pll_rstn_o, 
	
	input 			tdqss_clk,			
	input 			core_clk,			//	DDR PLL 200MHz
	input 			tac_clk,			
	input 			twd_clk,			
	
	input 			ddr_pll_lock,		//	DDR PLL Lock
	
	////////////////////////////////////////////////////////////////
	//	DDR PLL Phase Shift Interface
	output 	[2:0] 	shift,
	output 	[4:0] 	shift_sel,
	output 			shift_ena,
	
	
	
	////////////////////////////////////////////////////////////////
	//	LVDS Clock
	output 			lvds_pll_rstn_o, 
	
	input 			clk_lvds_1x, 
	input 			clk_lvds_7x, 
	input 			clk_27m, 			//	RGB 1X Clock (16MHz)
	input 			clk_54m, 			//	RGB 2X Clock (32MHz, for export control)
	
	input 			lvds_pll_lock, 
	
	
	
	////////////////////////////////////////////////////////////////
	//	DDR Interface Ports
	output 	[15:0] 	addr,
	output 	[2:0] 	ba,
	output 			we,
	output 			reset,
	output 			ras,
	output 			cas,
	output 			odt,
	output 			cke,
	output 			cs,
	
	//	DQ I/O
	input 	[15:0] 	i_dq_hi,
	input 	[15:0] 	i_dq_lo,
	
	output 	[15:0] 	o_dq_hi,
	output 	[15:0] 	o_dq_lo,
	output 	[15:0] 	o_dq_oe,
	
	//	DM O
	output 	[1:0] 	o_dm_hi,
	output 	[1:0] 	o_dm_lo,
	
	//	DQS I/O
	input 	[1:0] 	i_dqs_hi,
	input 	[1:0] 	i_dqs_lo,
	
	input 	[1:0] 	i_dqs_n_hi,
	input 	[1:0] 	i_dqs_n_lo,
	
	output 	[1:0] 	o_dqs_hi,
	output 	[1:0] 	o_dqs_lo,
	
	output 	[1:0] 	o_dqs_n_hi,
	output 	[1:0] 	o_dqs_n_lo,
	
	output 	[1:0] 	o_dqs_oe,
	output 	[1:0] 	o_dqs_n_oe,
	
	//	CK
	output 			clk_p_hi, 
	output 			clk_p_lo, 
	output 			clk_n_hi, 
	output 			clk_n_lo, 
	
	
	
	////////////////////////////////////////////////////////////////
	//	MIPI-CSI Ctl / I2C
	output 			csi_ctl0_o,
	output 			csi_ctl0_oe,
	input 			csi_ctl0_i,
	
	output 			csi_ctl1_o,
	output 			csi_ctl1_oe,
	input 			csi_ctl1_i,
	
	output 			csi_scl_o,
	output 			csi_scl_oe,
	input 			csi_scl_i,
	
	output 			csi_sda_o,
	output 			csi_sda_oe,
	input 			csi_sda_i,
	
	//	MIPI-CSI RXC 
	input 			csi_rxc_lp_p_i,
	input 			csi_rxc_lp_n_i,
	output 			csi_rxc_hs_en_o,
	output 			csi_rxc_hs_term_en_o,
	input 			csi_rxc_i,
	
	//	MIPI-CSI RXD0
	output 			csi_rxd0_rst_o,
	output 			csi_rxd0_hs_en_o,
	output 			csi_rxd0_hs_term_en_o,
	
	input 			csi_rxd0_lp_p_i,
	input 			csi_rxd0_lp_n_i,
	input 	[7:0] 	csi_rxd0_hs_i,
	
	//	MIPI-CSI RXD1
	output 			csi_rxd1_rst_o,
	output 			csi_rxd1_hs_en_o,
	output 			csi_rxd1_hs_term_en_o,
	
	input 			csi_rxd1_lp_n_i,
	input 			csi_rxd1_lp_p_i,
	input 	[7:0] 	csi_rxd1_hs_i,
	
	//	MIPI-CSI RXD2
	output 			csi_rxd2_rst_o,
	output 			csi_rxd2_hs_en_o,
	output 			csi_rxd2_hs_term_en_o,
	
	input 			csi_rxd2_lp_p_i,
	input 			csi_rxd2_lp_n_i,
	input 	[7:0] 	csi_rxd2_hs_i,
	
	//	MIPI-CSI RXD3
	output 			csi_rxd3_rst_o,
	output 			csi_rxd3_hs_en_o,
	output 			csi_rxd3_hs_term_en_o,
	
	input 			csi_rxd3_lp_p_i,
	input 			csi_rxd3_lp_n_i,
	input 	[7:0] 	csi_rxd3_hs_i,
	
	//output 			csi_rxd0_fifo_rd_o, 
	//input 			csi_rxd0_fifo_empty_i, 
	//output 			csi_rxd1_fifo_rd_o, 
	//input 			csi_rxd1_fifo_empty_i, 
	//output 			csi_rxd2_fifo_rd_o, 
	//input 			csi_rxd2_fifo_empty_i, 
	//output 			csi_rxd3_fifo_rd_o, 
	//input 			csi_rxd3_fifo_empty_i, 
	
	
	
	////////////////////////////////////////////////////////////////
	//	DSI PWM & Reset Control 
	output 			dsi_pwm_o,			//	MIPI-DSI LCD PWM
	output 			dsi_resetn_o,		//	MIPI-DSI LCD Reset
	
	//	MIPI-DSI TXC / TXD
	output 			dsi_txc_rst_o,
	output 			dsi_txc_lp_p_oe,
	output 			dsi_txc_lp_p_o,
	output 			dsi_txc_lp_n_oe,
	output 			dsi_txc_lp_n_o,
	output 			dsi_txc_hs_oe,
	output 	[7:0] 	dsi_txc_hs_o,
	
	output 			dsi_txd0_rst_o,
	output 			dsi_txd0_hs_oe,
	output 	[7:0] 	dsi_txd0_hs_o,
	output 			dsi_txd0_lp_p_oe,
	output 			dsi_txd0_lp_p_o,
	output 			dsi_txd0_lp_n_oe,
	output 			dsi_txd0_lp_n_o,
	
	output 			dsi_txd1_rst_o,
	output 			dsi_txd1_lp_p_oe,
	output 			dsi_txd1_lp_p_o,
	output 			dsi_txd1_lp_n_oe,
	output 			dsi_txd1_lp_n_o,
	output 			dsi_txd1_hs_oe,
	output 	[7:0] 	dsi_txd1_hs_o,
	
	output 			dsi_txd2_rst_o,
	output 			dsi_txd2_lp_p_oe,
	output 			dsi_txd2_lp_p_o,
	output 			dsi_txd2_lp_n_oe,
	output 			dsi_txd2_lp_n_o,
	output 			dsi_txd2_hs_oe,
	output 	[7:0] 	dsi_txd2_hs_o,
	
	output 			dsi_txd3_rst_o,
	output 			dsi_txd3_lp_p_oe,
	output 			dsi_txd3_lp_p_o,
	output 			dsi_txd3_lp_n_oe,
	output 			dsi_txd3_lp_n_o,
	output 			dsi_txd3_hs_oe,
	output 	[7:0] 	dsi_txd3_hs_o,
	
	input 			dsi_txd0_lp_p_i,
	input 			dsi_txd0_lp_n_i,
	input 			dsi_txd1_lp_p_i,
	input 			dsi_txd1_lp_n_i,
	input 			dsi_txd2_lp_p_i,
	input 			dsi_txd2_lp_n_i,
	input 			dsi_txd3_lp_p_i,
	input 			dsi_txd3_lp_n_i,
	
	
	////////////////////////////////////////////////////////////////
	//	UART Interface
	input 		 	uart_rx_i,			//	Support 460800-8-N-1. 
	output 		 	uart_tx_o, 
	
	
	output 	[5:0] 	led_o,			//	
	
	
	////////////////////////////////////////////////////////////////
	//	CMOS Sensor
	output 			cmos_sclk,
	input 			cmos_sdat_IN,
	output 			cmos_sdat_OUT,
	output 			cmos_sdat_OE,
	
	//	CMOS Interface
	input 			cmos_pclk,
	input 			cmos_vsync,
	input 			cmos_href,
	input 	[7:0] 	cmos_data,
	input 			cmos_ctl1,
	output 			cmos_ctl2,
	output 			cmos_ctl3,
	
	
	////////////////////////////////////////////////////////////////
	//	HDMI Interface
	output 			hdmi_txc_oe,
	output 			hdmi_txd0_oe,
	output 			hdmi_txd1_oe,
	output 			hdmi_txd2_oe,
	
	output 			hdmi_txc_rst_o,
	output 			hdmi_txd0_rst_o,
	output 			hdmi_txd1_rst_o,
	output 			hdmi_txd2_rst_o,
	
	output 	[9:0] 	hdmi_txc_o,
	output 	[9:0] 	hdmi_txd0_o,
	output 	[9:0] 	hdmi_txd1_o,
	output 	[9:0] 	hdmi_txd2_o,
	
	
	////////////////////////////////////////////////////////////////
	//	LVDS Interface
	output 			lvds_txc_oe,
	output 	[6:0] 	lvds_txc_o,
	output 			lvds_txc_rst_o,
	
	output 			lvds_txd0_oe,
	output 	[6:0] 	lvds_txd0_o,
	output 			lvds_txd0_rst_o,
	
	output 			lvds_txd1_oe,
	output 	[6:0] 	lvds_txd1_o,
	output 			lvds_txd1_rst_o,
	
	output 			lvds_txd2_oe,
	output 	[6:0] 	lvds_txd2_o,
	output 			lvds_txd2_rst_o,
	
	output 			lvds_txd3_oe,
	output 	[6:0] 	lvds_txd3_o,
	output 			lvds_txd3_rst_o,
	
	
	////////////////////////////////////////////////////////////////
	//	RGB LCD 5Inch 800x480
	output 			lcd_tp_sda_o,		//	TP SDA
	output 			lcd_tp_sda_oe,
	input 			lcd_tp_sda_i,
	
	output 			lcd_tp_scl_o,		//	TP SCL
	output 			lcd_tp_scl_oe,
	input 			lcd_tp_scl_i,
	
	output 			lcd_tp_int_o,		//	TP INT
	output 			lcd_tp_int_oe,
	input 			lcd_tp_int_i,
	
	output 			lcd_tp_rst_o,		//	TP RST
	
	output 			lcd_pwm_o,			//	Backlight
	output 			lcd_blen_o,
	
	//output 			lcd_pclk_o,			//	PCLK & SCK Mux
	output 			lcd_vs_o,			//	VS & SSN Mux. Fixed to 1. Use DE-Only mode. 
	output 			lcd_hs_o,			//	HS. Fixed to 1. Use DE-Only mode. 
	//output 			lcd_de_o,			//	DE. 

	output 	[7:0] 	lcd_b7_0_o,			//	B7:B0. 
	output 	[7:0] 	lcd_g7_0_o,			//	G7:G0. Must output 8'hFF when access SPI. 
	output 	[7:0] 	lcd_r7_0_o,			//	R7:R0. 
	
	output 	[7:0] 	lcd_b7_0_oe,		//	B7:B0. 
	output 	[7:0] 	lcd_g7_0_oe,		//	G7:G0. Must output 8'hFF when access SPI. 
	output 	[7:0] 	lcd_r7_0_oe,		//	R7:R0. 

	input 	[7:0] 	lcd_b7_0_i,			//	B7:B0. 
	input 	[7:0] 	lcd_g7_0_i,			//	G7:G0. Must output 8'hFF when access SPI. 
	input 	[7:0] 	lcd_r7_0_i,			//	R7:R0. 
	
	//	SPI Pins
	output 			spi_sck_o, 
	output 			spi_ssn_o 			
);
	
	wire 			csi_rxd0_fifo_rd_o; 
	wire 			csi_rxd0_fifo_empty_i = 0;  
	wire 			csi_rxd1_fifo_rd_o;  
	wire 			csi_rxd1_fifo_empty_i = 0;  
	wire 			csi_rxd2_fifo_rd_o;  
	wire 			csi_rxd2_fifo_empty_i = 0;  
	wire 			csi_rxd3_fifo_rd_o;  
	wire 			csi_rxd3_fifo_empty_i = 0;  
	
	
	// SIM_DATA remains a top-level parameter with its verified default 0. 
	
	//	Hardware Configuration
	assign clk_p_hi = 1'b0;	//	DDR3 Clock requires 180 degree shifted. 
	assign clk_p_lo = 1'b1;
	assign clk_n_hi = 1'b1;
	assign clk_n_lo = 1'b0; 
	
	//	System Clock Tree Control
	assign sys_pll_rstn_o = 1'b1; 	//	nrst; 	//	Reset whole system when nrst (K2) is pressed. 
	
	assign dsi_pll_rstn_o = sys_pll_lock; 
	assign ddr_pll_rstn_o = sys_pll_lock; 
	assign lvds_pll_rstn_o = sys_pll_lock; 
	
	wire 			w_pll_lock = sys_pll_lock && dsi_pll_lock && ddr_pll_lock && lvds_pll_lock; 
	
	//	Synchronize System Resets. 
	reg 			rstn_sys = 0, rstn_pixel = 0; 
	// Local camera reset: asynchronous assertion, two camera-clock release edges.
	(* async_reg="true", syn_srlstyle="registers" *) reg [1:0] m5b1_cam_reset = 0;
	always @(posedge cmos_pclk or negedge rstn_sys)
		if (!rstn_sys) m5b1_cam_reset <= 0;
		else m5b1_cam_reset <= {m5b1_cam_reset[0], 1'b1};
	wire 			rst_sys = ~rstn_sys, rst_pixel = ~rstn_pixel; 
	
	reg 			rstn_dsi_refclk = 0, rstn_dsi_byteclk = 0; 
	wire 			rst_dsi_refclk = ~rstn_dsi_refclk, rst_dsi_byteclk = ~rstn_dsi_byteclk; 
	
	reg 			rstn_lvds_1x = 0; 
	wire 			rst_lvds_1x = ~rstn_lvds_1x; 
	
	reg 			rstn_27m = 0, rstn_54m = 0; 
	wire 			rst_27m = ~rstn_27m, rst_54m = ~rstn_54m; 
	
	//	Clock Gen
	always @(posedge clk_27m or negedge w_pll_lock) begin if(~w_pll_lock) rstn_27m <= 0; else rstn_27m <= 1; end
	always @(posedge clk_54m or negedge w_pll_lock) begin if(~w_pll_lock) rstn_54m <= 0; else rstn_54m <= 1; end
	always @(posedge clk_sys or negedge w_pll_lock) begin if(~w_pll_lock) rstn_sys <= 0; else rstn_sys <= 1; end
	always @(posedge clk_pixel or negedge w_pll_lock) begin if(~w_pll_lock) rstn_pixel <= 0; else rstn_pixel <= 1; end
	always @(posedge dsi_refclk_i or negedge w_pll_lock) begin if(~w_pll_lock) rstn_dsi_refclk <= 0; else rstn_dsi_refclk <= 1; end
	always @(posedge dsi_byteclk_i or negedge w_pll_lock) begin if(~w_pll_lock) rstn_dsi_byteclk <= 0; else rstn_dsi_byteclk <= 1; end
	always @(posedge clk_lvds_1x or negedge w_pll_lock) begin if(~w_pll_lock) rstn_lvds_1x <= 0; else rstn_lvds_1x <= 1; end
	
	
	localparam 	CLOCK_MAIN 	= 96000000; 	//	System clock using 96MHz. 
	
	
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	Flash Burner Control
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	wire 			w_ustick, w_mstick; 
	
	wire  [7:0] 	w_dev_index_o;  
	wire  [7:0] 	w_dev_cmd_o;  
	wire  [31:0] 	w_dev_wdata_o;  
	wire  		w_dev_wvalid_o;  
	wire  		w_dev_rvalid_o;  
	wire 	[31:0] 	w_dev_rdata_i;  
	
	wire 			w_spi_ssn_o, w_spi_sck_o; 
	wire 	[3:0] 	w_spi_data_o, w_spi_data_oe; 
	wire 	[3:0] 	w_spi_data_i; 
	
	//	Flash Control
	reg 			r_flash_en = 0; 		//	0x00:0x00 Enable Flash
	
	always @(posedge clk_sys) begin
		r_flash_en <= (w_dev_wvalid_o && (w_dev_index_o == 8'h00) && (w_dev_cmd_o == 8'h00)) ? w_dev_wdata_o : r_flash_en; 
	end
	
	
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	LCD Data Mux
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	wire 	[7:0] 	w_lcd_b_o, w_lcd_g_o, w_lcd_r_o; 
	
	assign lcd_b7_0_o = r_flash_en ? {4'b0, w_spi_data_o[3:2], 2'b0} : w_lcd_b_o; 
	assign lcd_g7_0_o = r_flash_en ? {6'h0, w_spi_data_o[1:0]} : w_lcd_g_o; 
	assign lcd_r7_0_o = r_flash_en ? {8'h00} : w_lcd_r_o; 
	
	assign lcd_b7_0_oe = r_flash_en ? {4'b0, w_spi_data_oe[3:2], 2'b0} : 8'hFF; 
	assign lcd_g7_0_oe = r_flash_en ? {6'h0, w_spi_data_oe[1:0]} : 8'hFF; 
	assign lcd_r7_0_oe = r_flash_en ? {8'h00} : 8'hFF; 
	
	assign spi_sck_o = w_spi_sck_o; 
	assign spi_ssn_o = w_spi_ssn_o; 
	assign w_spi_data_i = {lcd_b7_0_i[3:2], lcd_g7_0_i[1:0]}; 
	
	
	
	
	
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	DDR3 Controller
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	wire			w_ddr3_ui_clk = clk_sys;
	wire			w_ddr3_ui_rst = rst_sys;
	wire			w_ddr3_ui_areset = rst_sys;
	wire			w_ddr3_ui_aresetn = rstn_sys;
	

	//	General AXI Interface 
	wire	[3:0] 	w_ddr3_awid;
	wire	[31:0]	w_ddr3_awaddr;
	wire	[7:0]		w_ddr3_awlen;
	wire			w_ddr3_awvalid;
	wire			w_ddr3_awready;
	
	wire 	[7:0]  	w_ddr3_wid;
	wire 	[127:0] 	w_ddr3_wdata;
	wire 	[15:0]	w_ddr3_wstrb;
	wire			w_ddr3_wlast;
	wire			w_ddr3_wvalid;
	wire			w_ddr3_wready;
	
	wire 	[7:0] 	w_ddr3_bid;
	wire 	[1:0] 	w_ddr3_bresp;
	wire			w_ddr3_bvalid;
	wire			w_ddr3_bready;
	
	wire	[3:0] 	w_ddr3_arid;
	wire	[31:0]	w_ddr3_araddr;
	wire	[7:0]		w_ddr3_arlen;
	wire			w_ddr3_arvalid;
	wire			w_ddr3_arready;
	
	wire 	[7:0] 	w_ddr3_rid;
	wire 	[127:0] 	w_ddr3_rdata;
	wire			w_ddr3_rlast;
	wire			w_ddr3_rvalid;
	wire			w_ddr3_rready;
	wire 	[1:0] 	w_ddr3_rresp;
	
	
	//	AXI Interface Request
	wire 	[7:0] 	w_ddr3_aid;
	wire 	[31:0] 	w_ddr3_aaddr;
	wire 	[7:0]  	w_ddr3_alen;
	wire 	[2:0]  	w_ddr3_asize;
	wire 	[1:0]  	w_ddr3_aburst;
	wire 	[1:0]  	w_ddr3_alock;
	wire			w_ddr3_avalid;
	wire			w_ddr3_aready;
	wire			w_ddr3_atype;
	
	wire 			w_ddr3_cal_done, w_ddr3_cal_pass; 
	
	//	Do not issue DDR read / write when ~cal_done. 
	reg 			r_ddr_unlock = 0; 
	always @(posedge w_ddr3_ui_clk or negedge w_ddr3_ui_aresetn) begin
		if(~w_ddr3_ui_aresetn)
			r_ddr_unlock <= 0; 
		else
			r_ddr_unlock <= w_ddr3_cal_done; 
	end
	
	DdrCtrl ddr3_ctl_axi (	
		.core_clk		(core_clk),
		.tac_clk		(tac_clk),
		.twd_clk		(twd_clk),	
		.tdqss_clk		(tdqss_clk),
		
		.reset		(reset),
		.cs			(cs),
		.ras			(ras),
		.cas			(cas),
		.we			(we),
		.cke			(cke),    
		.addr			(addr),
		.ba			(ba),
		.odt			(odt),
		
		.o_dm_hi		(o_dm_hi),
		.o_dm_lo		(o_dm_lo),
		
		.i_dq_hi		(i_dq_hi),
		.i_dq_lo		(i_dq_lo),
		.o_dq_hi		(o_dq_hi),
		.o_dq_lo		(o_dq_lo),
		.o_dq_oe		(o_dq_oe),
		
		.i_dqs_hi		(i_dqs_hi),
		.i_dqs_lo		(i_dqs_lo),
		.i_dqs_n_hi		(i_dqs_n_hi),
		.i_dqs_n_lo		(i_dqs_n_lo),
		.o_dqs_hi		(o_dqs_hi),
		.o_dqs_lo		(o_dqs_lo),
		.o_dqs_n_hi		(o_dqs_n_hi),
		.o_dqs_n_lo		(o_dqs_n_lo),
		.o_dqs_oe		(o_dqs_oe),
		.o_dqs_n_oe		(o_dqs_n_oe),
		
		.clk			(w_ddr3_ui_clk),
		.reset_n		(w_ddr3_ui_aresetn),
		
		.axi_avalid		(w_ddr3_avalid),	//	Enable command only when unlocked. 
		.axi_aready		(w_ddr3_aready),
		.axi_aaddr		(w_ddr3_aaddr),
		.axi_aid		(w_ddr3_aid),
		.axi_alen		(w_ddr3_alen),
		.axi_asize		(w_ddr3_asize),
		.axi_aburst		(w_ddr3_aburst),
		.axi_alock		(w_ddr3_alock),
		.axi_atype		(w_ddr3_atype),
		
		.axi_wid		(w_ddr3_wid),
		.axi_wvalid		(w_ddr3_wvalid),
		.axi_wready		(w_ddr3_wready),
		.axi_wdata		(w_ddr3_wdata),
		.axi_wstrb		(w_ddr3_wstrb),
		.axi_wlast		(w_ddr3_wlast),
		
		.axi_bvalid		(w_ddr3_bvalid),
		.axi_bready		(w_ddr3_bready),
		.axi_bid		(w_ddr3_bid),
		.axi_bresp		(w_ddr3_bresp),
		
		.axi_rvalid		(w_ddr3_rvalid),
		.axi_rready		(w_ddr3_rready),
		.axi_rdata		(w_ddr3_rdata),
		.axi_rid		(w_ddr3_rid),
		.axi_rresp		(w_ddr3_rresp),
		.axi_rlast		(w_ddr3_rlast),
		
		.shift		(shift),
		.shift_sel		(),
		.shift_ena		(shift_ena),
		
		.cal_ena		(1'b1),
		.cal_done		(w_ddr3_cal_done),
		.cal_pass		(w_ddr3_cal_pass)
	);
	
	// BREADY is owned by the M5B1 arbiter. 
	assign shift_sel = 5'b00100; 		//	ddr_tac_clk always use PLLOUT[2]. 
	
	
	//assign led_o[1:0] = {w_ddr3_cal_pass, w_ddr3_cal_done}; 
	
	
	
	
	
	
	
	
	
	////////////////////////////////////////////////////////////////
	//	I2C Config (SC130GS)
	
	//  i2c timing controller module of 16Bit
	wire            [ 7:0]          sc130_i2c_config_index;
	wire            [23:0]          sc130_i2c_config_data;
	wire            [ 7:0]          sc130_i2c_config_size;
	wire                            sc130_i2c_config_done;
	
	i2c_timing_ctrl_16bit
	#(
	    .CLK_FREQ           (CLOCK_MAIN),                              //  100 MHz
	    .I2C_FREQ           (50_000    )                               //  10 KHz(<= 400KHz)
	) u_i2c_timing_ctrl_16bit (
	    //  global clock
	    .clk                (clk_sys                 ),                          //  96MHz
	    .rst_n              (rstn_sys                ),                          //  system reset

	    //  i2c interface
	    .i2c_sclk           (csi_scl_o               ),                          //  i2c clock
	    .i2c_sdat_IN        (csi_sda_i               ),
	    .i2c_sdat_OUT       (csi_sda_o               ),
	    .i2c_sdat_OE        (csi_sda_oe              ),

	    //  i2c config data
	    .i2c_config_index   (sc130_i2c_config_index        ),                          //  i2c config reg index, read 2 reg and write xx reg
	    .i2c_config_data    ({8'h60, sc130_i2c_config_data}),                     //  i2c config data
	    .i2c_config_size    (sc130_i2c_config_size         ),                          //  i2c config data counte
	    .i2c_config_done    (sc130_i2c_config_done         )                          //  i2c config timing complete
	);
	assign csi_scl_oe = 1; 

	//  I2C Configure Data of SC130GS
	I2C_SC130GS_12801024_4Lanes_Config u_I2C_SC130GS_12801024_4Lanes_Config 
	(
	    .LUT_INDEX  (sc130_i2c_config_index   ),
	    .LUT_DATA   (sc130_i2c_config_data    ),
	    .LUT_SIZE   (sc130_i2c_config_size    )
	);
	

	////////////////////////////////////////////////////////////////
	//	I2C Config (AR0135)
	
	//  i2c timing controller module of 16Bit
	wire            [ 7:0]          ar0135_i2c_config_index;
	wire            [31:0]          ar0135_i2c_config_data;
	wire            [ 7:0]          ar0135_i2c_config_size;
	wire                            ar0135_i2c_config_done;
	wire            [15:0]          ar0135_i2c_rdata;                              //  i2c register data

	i2c_timing_ctrl_reg16_dat16
	#(
	    .SIMU_EN            (0              ),
	    .I2C_READ_EN        (1              ),                              //  Enable I2C Register read
	    .CLK_FREQ           (CLOCK_MAIN     ),                              //  120 MHz
	    .I2C_FREQ           (50_000         )                               //  10 KHz(<= 400KHz)
	)
	u_i2c_timing_ctrl_16reg_16bit
	(
	    //global clock
	    .clk                (clk_sys                 ),                          //  96MHz
	    .rst_n              (rstn_sys                ),                          //  system reset

	    //i2c interface
	    .i2c_sclk           (cmos_sclk                  ),                  //  i2c clock
		.i2c_sdat_o 	(cmos_sdat_OUT), 
		.i2c_sdat_oe	(cmos_sdat_OE), 
		.i2c_sdat_i 	(cmos_sdat_IN), 
		
	    //i2c config data
	    .i2c_config_index   (ar0135_i2c_config_index           ),                  //  i2c config reg index, read 2 reg and write xx reg
	    .i2c_config_data    ({8'h20, ar0135_i2c_config_data}   ),                  //  i2c config data
	    .i2c_config_size    (ar0135_i2c_config_size            ),                  //  i2c config data counte
	    .i2c_config_done    (ar0135_i2c_config_done            ),                  //  i2c config timing complete
	    .i2c_rdata          (ar0135_i2c_rdata                  )                   //  i2c register data while read i2c slave
	);
	
	//----------------------------------------------------------------------
	//  I2C Configure Data of AR0135
	I2C_AR0135_1280720_Config u_I2C_AR0135_1280720_Config
	(
	    .LUT_INDEX  (ar0135_i2c_config_index   ),
	    .LUT_DATA   (ar0135_i2c_config_data    ),
	    .LUT_SIZE   (ar0135_i2c_config_size    )
	);
	
	
		
	//	CMOS Interface
	//input 			cmos_pclk,
	//input 			cmos_vsync,
	//input 			cmos_href,
	//input 	[7:0] 	cmos_data,
	//input 			cmos_ctl1,
	//output 			cmos_ctl2,
	//output 			cmos_ctl3,

	
	//	Output LED
	reg 	[3:0]		r_cmos_fv_o = 0; 
	reg 	[1:0] 	r_cmos_rx_vsync0_in = 0; 
	always @(posedge cmos_pclk) begin
		r_cmos_rx_vsync0_in <= {r_cmos_rx_vsync0_in, cmos_vsync}; 
		r_cmos_fv_o <= r_cmos_fv_o + ((r_cmos_rx_vsync0_in == 2'b01) ? 1 : 0); 
	end
	// Camera status moved to UART. 
	
	
	
	
	
	
	
	
	////////////////////////////////////////////////////////////////
	//	System Control. Can be removed for public. 
	
	localparam 	CLK_FREQ 	= 96_000_000; 	//	clk_sys is 96MHz. 
	localparam 	BAUD_RATE 	= 460_800; 		//	Use 460800-8-N-1. 
	
	
	//	SFR I/O Interface
	wire 	[7:0] 	w_sfr_addr_o; 	//	SFR Address (0xFF00 ~ 0xFFFF). 00:Power; 40~5F:Stream0; 60~7F:Stream1. 
	wire 	[7:0] 	w_sfr_wdata_o; 	//	SFR Write Data. 
	wire 			w_sfr_we_o; 		//	SFR WE. 
	reg 	[7:0] 	w_sfr_rdata_i; 	//	Must be valid after sfr_rd_o. 
	wire 			w_sfr_rd_o; 		//	SFR RD. 
	
	
	//	System Control Registers
	reg 			r_dsi_tx_rstn = 0; 	//	DSI TX Reset
	reg 	[7:0] 	r_dsi_pwm = 64; 		//	[6:0]PWM, [7]Pol
	reg 			r_dsi_resetn_o = 0; 	//	DSI Panel Reset
	reg 			r_dsi_data_rstn = 0; 	//	DSI TX Reset
	
	reg 	[3:0] 	r_dsi_lp_p_ovr = 0; 	
	reg 	[3:0] 	r_dsi_lp_n_ovr = 0; 	
	
	
	
	//	AXI-Lite Interface Bridge
	localparam 	CSI_AXILITE_ID 	= 0; 				//	Select DSI_TX when r_axi_sel = DSI_AXILITE_ID. 
	localparam 	DSI_AXILITE_ID 	= 1; 				//	Select DSI_TX when r_axi_sel = DSI_AXILITE_ID. 
	
	reg 	[7:0] 	r_axi_addr = 8'h18; 		//	0xE0 (RW)
	reg 	[31:0] 	r_axi_wdata = 32'h0000000A; 	//	0xE1~0xE4 (RW)
	wire 	[31:0] 	w_axi_rdata; 			//	0xE5~0xE8 (RO)
	reg 	[0:0] 	r_axi_sel = 1; 			//	0xE9[7:2] (RW)
	reg 			r_axi_r1w0 = 0; 			//	0xE9[1] (RW)
	reg 			r_axi_req = 0; 			//	0xE9[0] (WO, Single Cycle)
	reg 			r_axi_req_o = 0; 			//	Delayed of r_axi_req. 
	
	
	//	Buffered AXI Read Data
	reg 	[31:0] 	r_axi_rdata = 0; 		//	Use state machine
	reg 			r_axi_idle = 0; 		//	AXI Idle 
	
	reg 	[3:0] 	rs_axilite = 0; 		//	AXI Access
	wire 	[3:0] 	ws_axilite_idle = 0; 		
	wire 	[3:0] 	ws_axilite_write = 1; 
	wire 	[3:0] 	ws_axilite_read = 2; 
	wire 	[3:0] 	ws_axilite_endread = 3; 
	
	reg 			r_axi_awvalid = 0, r_axi_wvalid = 0, r_axi_arvalid = 0; 
	wire 			w_axi_awready, w_axi_wready, w_axi_arready, w_axi_rvalid; 
	
	
	reg 	[3:0] 	rc_axi_init = 0; 

	always @(posedge clk_sys or posedge rst_sys) begin
		if(rst_sys) begin
			r_dsi_tx_rstn <= 0; 
			r_dsi_pwm <= 64; 
			r_axi_req <= 0; 
			r_dsi_resetn_o <= 0; 
			r_dsi_data_rstn <= 0; 
			
			rs_axilite <= 0; 
			r_axi_awvalid <= 0; 
			r_axi_wvalid <= 0;
			r_axi_arvalid <= 0; 
			
			r_dsi_lp_p_ovr <= 0; 
			r_dsi_lp_n_ovr <= 0; 
			
			rc_axi_init <= 0; 
			r_axi_idle <= 0; 
			
		end else begin
			r_dsi_tx_rstn <= 1; 
			r_dsi_resetn_o <= 1; 
			r_dsi_data_rstn <= 1; 
			
		end
	end
	
	assign dsi_resetn_o = r_dsi_resetn_o; 
	
	assign csi_ctl0_oe = 0; 
	assign csi_ctl1_oe = 0; 
	
	
	PWMLite dsi_pwm (		//	#(.ENABLE_TICK(0), .PWM_BITS(7)) 
		.clk_i			(clk_sys),
		.rst_i			(rst_sys),
		.pwm_i			(r_dsi_pwm[6:0]),
		.pol_i			(r_dsi_pwm[7]), 
		.pwm_o			(dsi_pwm_o)
	);






	////////////////////////////////////////////////////////////////
	//	MIPI CSI RX
	
	//	The CSI RXC shall not be inverted. Data can be inverted with swapped LP data and flipped HS data. 
	localparam 	CSI_RXD_INV 	= 4'b1111; 
	localparam 	CSI_DATA_WIDTH 	= 8; 			
	localparam 	CSI_STRB_WIDTH 	= CSI_DATA_WIDTH / 8; 

	
	////////////////////////////////////////////////////////////////
	//	MIPI-CSI Crop
	
	wire			XYCrop_frame_vsync; 
	wire			XYCrop_frame_href;
	wire			XYCrop_frame_de;
	wire	[63:0]	XYCrop_frame_Gray;

	Sensor_Image_XYCrop
	#(
		.IMAGE_HSIZE_SOURCE (1280 / CSI_STRB_WIDTH),
		.IMAGE_VSIZE_SOURCE (720	 ),
		.IMAGE_HSIZE_TARGET (1280 / CSI_STRB_WIDTH),
		.IMAGE_YSIZE_TARGET (720 	 ),
		.PIXEL_DATA_WIDTH	(CSI_DATA_WIDTH) 		//	32		 )
	)
	u_Sensor_Image_XYCrop
	(
		//	globel clock
		.clk			(cmos_pclk),			//	image pixel clock
		.rst_n		(m5b1_cam_reset[1]),	// camera-domain reset release
		
		//CMOS Sensor interface
		.image_in_vsync (cmos_vsync		),			//H : Data Valid; L : Frame Sync(Set it by register)
		.image_in_href	(cmos_href		),			//H : Data vaild, L : Line Sync
		.image_in_de	(cmos_href		), 			//H : Data Enable, L : Line Sync
		.image_in_data	(cmos_data),			//8 bits cmos data input
		
		.image_out_vsync(XYCrop_frame_vsync ),			//H : Data Valid; L : Frame Sync(Set it by register)
		.image_out_href (XYCrop_frame_href	),			//H : Data vaild, L : Line Sync
		.image_out_de	(XYCrop_frame_de	), 			//H : Data Enable, L : Line Sync
		.image_out_data (XYCrop_frame_Gray	)			//8 bits cmos data input	
	);

	reg			r_XYCrop_frame_vsync = 0; 
	reg			r_XYCrop_frame_href = 0;
	reg			r_XYCrop_frame_de = 0;
	reg	[63:0]	r_XYCrop_frame_Gray = 0;
	
	always @(posedge cmos_pclk) begin
		r_XYCrop_frame_vsync <= XYCrop_frame_vsync; 
		r_XYCrop_frame_href <= XYCrop_frame_href;
		r_XYCrop_frame_de <= XYCrop_frame_de;
		r_XYCrop_frame_Gray <= XYCrop_frame_Gray;
	end
	
	//	Data Write Assignment
	wire			cmos_frame_vsync = r_XYCrop_frame_vsync;                     //  cmos frame data vsync valid signal
	wire			cmos_frame_href = r_XYCrop_frame_href && r_XYCrop_frame_de;	 //  cmos frame data href vaild  signal
	wire	[63:0]	cmos_frame_Gray = r_XYCrop_frame_Gray; 
	wire 			cmos_vsync_end;

	












	////////////////////////////////////////////////////////////////
	//	DDR R/W Control
	

	wire                            lcd_de;
	wire                            lcd_hs;      
	wire                            lcd_vs;
	wire 					  lcd_request; 
	wire            [7:0]           lcd_red, lcd_red2;
	wire            [7:0]           lcd_green, lcd_green2;
	wire            [7:0]           lcd_blue, lcd_blue2;
	wire            [7:0]           lcd_data;
	wire [7:0] lcd_gray, sobel_display_gray;
	wire sobel_hs, sobel_vs, sobel_de;


    wire [63:0] m5b1_frame_id,m5b1_epoch,tap_frame_id,tap_epoch,tap_timestamp;
    wire m5b1_pix_qualified;
    reg m5b1_lcd_qualified;
    reg [63:0] m5b1_lcd_frame_id,m5b1_lcd_epoch;
    // Match the existing lcd_driver data register, including the last pixel.
    always @(posedge clk_pixel or negedge rstn_pixel)
      if(!rstn_pixel)begin m5b1_lcd_qualified<=0;m5b1_lcd_frame_id<=0;m5b1_lcd_epoch<=0;end
      else begin m5b1_lcd_qualified<=m5b1_pix_qualified;m5b1_lcd_frame_id<=m5b1_frame_id;m5b1_lcd_epoch<=m5b1_epoch;end
    wire tap_valid,tap_filter;wire [1:0] tap_class;wire [11:0] tap_x,tap_y;wire [7:0] tap_high,tap_low;
    wire [63:0] tap_display_seq,tap_config_generation,pixel_ticks,display_seq,config_generation;
    wire fusion_enable,fusion_request,fusion_release,fusion_offer_valid,fusion_offer_take;
    wire fusion_context_block,fusion_context_quiet,fusion_context_tail_fault;
    wire fusion_ref_ready,fusion_ref_mask,fusion_retire,fusion_flush,fusion_prefilled,fusion_stop_ui;
    wire [63:0] fusion_request_seq,fusion_release_session,fusion_session,fusion_read_session;
    wire [63:0] fusion_ref_session;
    wire [159:0] fusion_config;wire [767:0] fusion_descriptor;
    wire [1:0] fusion_ref_class;wire [11:0] fusion_ref_x,fusion_ref_y,fusion_retire_row;
    wire fusion_tap_valid,fusion_tap_qualified,fusion_tap_support;
    wire [11:0] final_x,final_y;wire local_edge;wire [7:0] final_gray;
    wire [23:0] fused_rgb;wire fusion_eligible,fusion_promoted,fusion_frame_ok;
    wire [31:0] fusion_age_frames,fusion_age_ticks;
    wire fusion_release_ready,fusion_release_final;wire fusion_frame_done;wire [479:0] fusion_telemetry_snapshot;
    // Diagnostics is observation-only; record transport has no DDR client.
    wire diag_ctx,diag_sof,diag_admit,diag_kill,diag_cv,diag_cq,diag_rq;
    wire [63:0] diag_sid,diag_csid,diag_token,diag_word;
    wire diag_source_slot,diag_tag,diag_bounds,diag_weak,diag_support,diag_global,diag_rc,diag_re,diag_rt;
    wire [1:0] diag_class;wire [11:0] diag_x,diag_y;
    wire diag_pix_ready,diag_take,diag_pix_cancel,diag_ui_ready,diag_done,diag_cancel,diag_valid,diag_window;
    wire diag_prst,diag_urst;wire [5:0] diag_read_word;wire [8:0] diag_index;wire [7:0] diag_byte;
    wire fusion_export_ui,fusion_ddr_error_ui,fusion_hardstop_ui;
    (* async_reg="true", syn_srlstyle="registers", syn_keep="true" *) reg [1:0] fusion_export_sync,fusion_ddr_error_sync,fusion_hardstop_sync;
    always @(posedge clk_pixel or negedge rstn_pixel)
      if(!rstn_pixel)begin fusion_export_sync<=0;fusion_ddr_error_sync<=0;fusion_hardstop_sync<=0;end
      else begin fusion_export_sync<={fusion_export_sync[0],fusion_export_ui};
       fusion_ddr_error_sync<={fusion_ddr_error_sync[0],fusion_ddr_error_ui};
       fusion_hardstop_sync<={fusion_hardstop_sync[0],fusion_hardstop_ui};end
    (* async_reg="true", syn_srlstyle="registers", syn_keep="true" *) reg [1:0] fusion_stop_sync;
    always @(posedge clk_pixel or negedge rstn_pixel)
      if(!rstn_pixel)fusion_stop_sync<=3;else fusion_stop_sync<={fusion_stop_sync[0],fusion_stop_ui};
    reg m5b1_vs_d=1'b1;
    always @(posedge clk_pixel or negedge rstn_pixel)if(!rstn_pixel)m5b1_vs_d<=1'b1;else m5b1_vs_d<=lcd_vs;
    m5b1_system #(.DIAGNOSTICS(1)) u_m5b1(.ui_clk(w_ddr3_ui_clk),.cam_clk(cmos_pclk),.pix_clk(clk_pixel),.rst_n(rstn_sys),
      .pll_locked(w_pll_lock),.cal_done(w_ddr3_cal_done),.cal_pass(w_ddr3_cal_pass),
      .cam_vs(cmos_frame_vsync),.cam_valid(cmos_frame_href),.cam_data(cmos_frame_Gray[7:0]),
      .pix_sof(m5b1_vs_d&&!lcd_vs),.pix_request(lcd_request),.pix_data(lcd_data),.frame_id(m5b1_frame_id),.epoch(m5b1_epoch),.pix_qualified(m5b1_pix_qualified),
      .tap_valid(tap_valid),.tap_class(tap_class),.tap_x(tap_x),.tap_y(tap_y),.tap_high(tap_high),.tap_low(tap_low),.tap_filter(tap_filter),
      .tap_frame_id(tap_frame_id),.tap_epoch(tap_epoch),.tap_timestamp(tap_timestamp),.tap_display_seq(tap_display_seq),.tap_config_generation(tap_config_generation),.uart_tx(uart_tx_o),.led(led_o),
      .fusion_request(fusion_request),.fusion_request_seq(fusion_request_seq),.fusion_config(fusion_config),
      .fusion_release(fusion_release),.fusion_release_final(fusion_release_final),.fusion_release_session(fusion_release_session),.fusion_release_ready(fusion_release_ready),
      .fusion_offer_valid(fusion_offer_valid),.fusion_offer_take(fusion_offer_take),.fusion_descriptor(fusion_descriptor),.fusion_session(fusion_session),
      .fusion_context_block(fusion_context_block),.fusion_context_quiet(fusion_context_quiet),.fusion_context_tail_fault(fusion_context_tail_fault),
      .fusion_ce(1'b1),.fusion_read(fusion_tap_valid),.fusion_x(tap_x),.fusion_y(tap_y),.fusion_read_session(fusion_read_session),
      .fusion_ref_ready(fusion_ref_ready),.fusion_ref_class(fusion_ref_class),.fusion_ref_mask(fusion_ref_mask),.fusion_ref_x(fusion_ref_x),.fusion_ref_y(fusion_ref_y),.fusion_ref_session(fusion_ref_session),
      .fusion_retire(fusion_retire),.fusion_retire_row(fusion_retire_row),.fusion_flush(fusion_flush),.fusion_prefilled(fusion_prefilled),.fusion_stop(fusion_stop_ui),
      .fusion_export_status(fusion_export_ui),.fusion_ddr_error_status(fusion_ddr_error_ui),.fusion_hardstop_status(fusion_hardstop_ui),
      .diag_ready(diag_ui_ready),.diag_window(diag_window),.diag_byte(diag_byte),.diag_byte_valid(diag_valid),.diag_index(diag_index),.diag_done(diag_done),.diag_cancel(diag_cancel),.diag_token(diag_token),.diag_slot(diag_source_slot),
      .fusion_frame_done(fusion_frame_done),.fusion_telemetry_snapshot(fusion_telemetry_snapshot),
      .aid(w_ddr3_aid),.alen(w_ddr3_alen),.wid(w_ddr3_wid),.aaddr(w_ddr3_aaddr),.asize(w_ddr3_asize),
      .aburst(w_ddr3_aburst),.alock(w_ddr3_alock),.avalid(w_ddr3_avalid),.atype(w_ddr3_atype),.aready(w_ddr3_aready),
      .wdata(w_ddr3_wdata),.wstrb(w_ddr3_wstrb),.wlast(w_ddr3_wlast),.wvalid(w_ddr3_wvalid),.wready(w_ddr3_wready),
      .bid(w_ddr3_bid),.bresp(w_ddr3_bresp),.bvalid(w_ddr3_bvalid),.bready(w_ddr3_bready),
      .rid(w_ddr3_rid),.rresp(w_ddr3_rresp),.rdata(w_ddr3_rdata),.rlast(w_ddr3_rlast),.rvalid(w_ddr3_rvalid),.rready(w_ddr3_rready));
 
	
	
	
	
	////////////////////////////////////////////////////////////////
	//  LCD Timing Driver
	
	lcd_driver #(.DATA_WIDTH(8)) u_lcd_driver
	(
	    //  global clock
	    .clk        (clk_pixel   ),
	    .rst_n      (rstn_pixel), 
	    
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
    // M3: clk_pixel already owns the DDR FWFT read stream. The original
    // lcd_request and ~lcd_vs feedback remain untouched. Algorithm slot(x,y)
    // displays center(x-1,y-1); top two rows/left two columns are black.
    wire [7:0] control_threshold;
    wire [2:0] control_mode;
    reg control_vs_d=1'b1;
    always @(posedge clk_pixel or negedge rstn_pixel)
        if(!rstn_pixel) control_vs_d<=1'b1; else control_vs_d<=lcd_vs;
    m5a_controls u_controls(.clk(clk_pixel),.ce(1'b1),.arst_n(rstn_pixel),.key_n(key_n),
        .frame_start(control_vs_d && !lcd_vs),.threshold(control_threshold),
        .mode(control_mode),.pending_threshold(),.pending_mode(),.fusion_enable(fusion_enable),.config_generation(config_generation));
    wire [23:0] display_rgb,osd_rgb;
    wire [7:0] display_threshold;
    wire [2:0] display_mode;
    wire osd_de,osd_hs,osd_vs;
    // One common delayed raster; OVR edges are centered on original RAW.
    m5a_osd u_osd(.clk(clk_pixel),.ce(1'b1),.arst_n(rstn_pixel),.rgb(fused_rgb),
        .fusion_enable(fusion_enable),.fusion_active(fusion_frame_ok),.fusion_age(fusion_age_frames),.fusion_age_valid(fusion_eligible),
        .de(sobel_de),.hs(sobel_hs),.vs(sobel_vs),.threshold(display_threshold),
        .mode(display_mode),.out_rgb(osd_rgb),.out_de(osd_de),.out_hs(osd_hs),.out_vs(osd_vs));
    m5a_stream_top #(.WIDTH(1280),.HEIGHT(720),.H_TOTAL(1650)) u_m5a_stream (
        .clk(clk_pixel),.ce(1'b1),.arst_n(rstn_pixel),.in_gray(lcd_gray),
        .in_de(lcd_de),.in_hs(lcd_hs),.in_vs(lcd_vs),.in_sof(~lcd_vs),
        .filter_request(M5A_FILTER_ENABLE!=0),.threshold(control_threshold),.mode(control_mode),
        .out_de(sobel_de),.out_hs(sobel_hs),.out_vs(sobel_vs),.out_rgb(display_rgb),
        .out_raw(final_gray),.out_legacy_mag(),.out_legacy_bin(),.out_nms(),.out_filter_enable(),.out_threshold(display_threshold),.out_mode(display_mode),
        .tap_input_frame_id(m5b1_lcd_frame_id),.tap_input_epoch(m5b1_lcd_epoch),.tap_input_qualified(m5b1_lcd_qualified),
        .tap_valid(tap_valid),.tap_class(tap_class),.tap_x(tap_x),.tap_y(tap_y),.tap_high(tap_high),.tap_low(tap_low),.tap_filter(tap_filter),
        .source_pixel_tick(pixel_ticks),.source_display_seq(display_seq),.source_config_generation(config_generation),
        .tap_frame_id(tap_frame_id),.tap_epoch(tap_epoch),.tap_timestamp(tap_timestamp),.tap_display_seq(tap_display_seq),.tap_config_generation(tap_config_generation),
        .fusion_tap_valid(fusion_tap_valid),.fusion_tap_qualified(fusion_tap_qualified),.fusion_tap_support(fusion_tap_support),
        .out_x(final_x),.out_y(final_y),.out_overlay_valid(),.out_overlay_edge(),.out_nms_valid(),.out_canny_valid(),.out_canny_edge(local_edge),.raster_fault());
    m5c_fusion_display u_fusion_display(.context_block(fusion_context_block),.context_quiet(fusion_context_quiet),.context_tail_fault(fusion_context_tail_fault),.clk(clk_pixel),.rst_n(rstn_pixel),.ce(1'b1),.raw_sof(control_vs_d&&!lcd_vs),
        .stop(fusion_stop_sync[1]),.enable(fusion_enable),.export_status(fusion_export_sync[1]),.ddr_error_status(fusion_ddr_error_sync[1]),.hardstop_status(fusion_hardstop_sync[1]),.epoch(m5b1_epoch),.config_generation(config_generation),
        .high_threshold(control_threshold),.filter_enable(M5A_FILTER_ENABLE!=0),
        .tap_valid(fusion_tap_valid),.tap_qualified(fusion_tap_qualified),.tap_support(fusion_tap_support),.tap_class(tap_class),.tap_x(tap_x),.tap_y(tap_y),
        .final_de(sobel_de),.final_x(final_x),.final_y(final_y),.local_edge(local_edge),.raw_gray(final_gray),.mode(display_mode),.base_rgb(display_rgb),.fused_rgb(fused_rgb),
        .pixel_ticks(pixel_ticks),.display_seq(display_seq),.config_signature(fusion_config),.request_frame(fusion_request),.request_seq(fusion_request_seq),
        .offer_valid(fusion_offer_valid),.offer_take(fusion_offer_take),.offer_descriptor(fusion_descriptor),.offer_session(fusion_session),
        .pixel_release(fusion_release),.release_final(fusion_release_final),.release_session(fusion_release_session),.release_ready(fusion_release_ready),.read_session(fusion_read_session),
        .prefilled(fusion_prefilled),.ref_ready(fusion_ref_ready),.ref_class(fusion_ref_class),.ref_mask(fusion_ref_mask),.ref_x(fusion_ref_x),.ref_y(fusion_ref_y),.ref_session(fusion_ref_session),
        .retire(fusion_retire),.retire_row(fusion_retire_row),.flush(fusion_flush),.eligible(fusion_eligible),.age_frames(fusion_age_frames),.age_ticks(fusion_age_ticks),
        .diag_context_valid(diag_ctx),.diag_sof(diag_sof),.diag_admit(diag_admit),.diag_kill(diag_kill),.diag_session(diag_sid),.diag_compare_session(diag_csid),
        .diag_compare_valid(diag_cv),.diag_current_qualified(diag_cq),.diag_reference_qualified(diag_rq),.diag_current_class(diag_class),.diag_compare_x(diag_x),.diag_compare_y(diag_y),
        .diag_tag_good(diag_tag),.diag_bounds(diag_bounds),.diag_weak(diag_weak),.diag_support(diag_support),.diag_global(diag_global),.diag_row_complete(diag_rc),.diag_row_equal(diag_re),.diag_row_tag(diag_rt),
        .promoted(fusion_promoted),.frame_ok(fusion_frame_ok),.frame_done(fusion_frame_done),.telemetry_snapshot(fusion_telemetry_snapshot));

    m5c_diag_observer_v2 u_diag_observer(.clk(clk_pixel),.rst_n(diag_prst),.read_clk(w_ddr3_ui_clk),.record_cancel(diag_pix_cancel),
        .context_event(diag_ctx),.context_valid(diag_ctx),.context_session(diag_sid),.context_token(diag_token),.current_epoch(m5b1_epoch),
        .source_descriptor(fusion_descriptor),.context_slot(diag_source_slot),.frame_sof(diag_sof),.frame_admit(diag_admit),.frame_session(display_seq),.pixel_ticks(pixel_ticks),
        .kill(diag_kill),.abort_reason({31'd0,diag_kill}),.final_de(sobel_de),.frame_eof(fusion_frame_done),.final_x(final_x),.final_y(final_y),
        .final_qualified(!fusion_context_block&&!fusion_context_tail_fault),.legal_bounds(diag_bounds),.tag_good(diag_tag),.frame_ok(fusion_frame_ok),.invalidate(!fusion_eligible),
        .delayed_weak(diag_weak),.delayed_support(diag_support),.delayed_global(diag_global),.local_edge(local_edge),.row_complete(diag_rc),.row_equal(diag_re),.row_tag_good(diag_rt),.promoted(fusion_promoted),
        .mode(display_mode),.admit_mode(control_mode),.enable(fusion_enable),.fused_rgb(fused_rgb),.osd_rgb(osd_rgb),.osd_de(osd_de),
        .compare_valid(diag_cv),.current_qualified(diag_cq),.reference_qualified(diag_rq),.compare_x(diag_x),.compare_y(diag_y),.reference_x(fusion_ref_x),.reference_y(fusion_ref_y),
        .current_class(diag_class),.reference_class(fusion_ref_class),.reference_mask(fusion_ref_mask),.compare_session(diag_csid),.reference_session(fusion_ref_session),
        .record_ready(diag_pix_ready),.record_take(diag_take),.read_word(diag_read_word),.word_data(diag_word),.dropped(),.active());
    m5c_diag_record_bridge u_diag_bridge(.pix_clk(clk_pixel),.ui_clk(w_ddr3_ui_clk),.arst_n(rstn_sys&&rstn_pixel),
        .pix_ready(diag_pix_ready),.pix_take(diag_take),.pix_cancel(diag_pix_cancel),.pix_rst_n(diag_prst),.ui_rst_n(diag_urst),
        .ui_ready(diag_ui_ready),.ui_done(diag_done),.ui_cancel(diag_cancel),.byte_index(diag_index),.read_word(diag_read_word),.word_data(diag_word),.byte_data(diag_byte),.byte_valid(diag_valid));
    m5c_diag_slot_guard u_diag_slot(.pix_clk(clk_pixel),.ui_clk(w_ddr3_ui_clk),.pix_rst_n(diag_prst),.ui_rst_n(diag_urst),.frame_done(fusion_frame_done),.window_open(diag_window));

	//	HDMI Interface. 
	
	//	HDMI requires specific timing, thus is not compatible with LCD & LVDS & DSI. Must implement standalone. 
	
	assign hdmi_txd0_rst_o = rst_pixel; 
	assign hdmi_txd1_rst_o = rst_pixel; 
	assign hdmi_txd2_rst_o = rst_pixel; 
	assign hdmi_txc_rst_o = rst_pixel; 
	
	assign hdmi_txd0_oe = 1'b1; 
	assign hdmi_txd1_oe = 1'b1; 
	assign hdmi_txd2_oe = 1'b1; 
	assign hdmi_txc_oe = 1'b1; 
	
	//-------------------------------------
	//Digilent HDMI-TX IP Modified by CB elec.
	rgb2dvi #(.ENABLE_OSERDES(0)) u_rgb2dvi 
	(
		//.TMDS_Clk_p		(hdmio_txc_p_o), 	//	w_hdmio_txc), 
		//.TMDS_Clk_n		(hdmio_txc_n_o), 
		//.TMDS_Data_p	(hdmio_txd_p_o), 	//	w_hdmio_txd), 
		//.TMDS_Data_n 	(hdmio_txd_n_o), 
		
		.oe_i 		(1), 			//	Always enable output
		.bitflip_i 		(4'b0000), 		//	Reverse clock & data lanes. 
		
		.aRst			(1'b0), 
		.aRst_n		(1'b1), 
		
		.PixelClk		(clk_pixel        ),//pixel clk = 74.25M
		.SerialClk		(     ),//pixel clk *5 = 371.25M
		
		.vid_pVSync		(osd_vs), 
		.vid_pHSync		(osd_hs), 
		.vid_pVDE		(osd_de), 
		.vid_pData		(osd_rgb), 
		
		.txc_o			(hdmi_txc_o), 
		.txd0_o			(hdmi_txd0_o), 
		.txd1_o			(hdmi_txd1_o), 
		.txd2_o			(hdmi_txd2_o)
	); 
		
	






	
	
endmodule


