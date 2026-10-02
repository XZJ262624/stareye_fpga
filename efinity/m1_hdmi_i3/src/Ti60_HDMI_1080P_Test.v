

`timescale 1ns / 1ps
module Ti60_HDMI_1080P_Test (
  //    27MHz PLL
  input clk27m, 
  input pll_27m_LOCKED, 
  
  //    LVDS PLL
  output sys_pll_RSTN, 
  
  input         clk_pixel,
  input         sys_pll_LOCKED,
  
  output [5:0]  led_o, 
  

  output [9:0] 	tmds_lvds_tx_clk_o,
  output [9:0] 	tmds_lvds_tx_data0,
  output [9:0] 	tmds_lvds_tx_data1,
  output [9:0] 	tmds_lvds_tx_data2,
  output 		tmds_lvds_tx_clk_oe,
  output 		tmds_lvds_tx_data0_oe,
  output 		tmds_lvds_tx_data1_oe,
  output 		tmds_lvds_tx_data2_oe,
  output 		tmds_lvds_tx_clk_rst,
  output 		tmds_lvds_tx_data0_rst,
  output 		tmds_lvds_tx_data1_rst,
  output 		tmds_lvds_tx_data2_rst

);

assign sys_pll_RSTN = pll_27m_LOCKED; 

assign led_o[0] = pll_27m_LOCKED; 
assign led_o[1] = sys_pll_LOCKED; 


wire    rst_n = sys_pll_LOCKED;

//---------------------------------------------------------------------------
wire        lcd_hs;
wire        lcd_vs;
wire        lcd_de;
wire[7:0]   lcd_red;
wire[7:0]   lcd_green;
wire[7:0]   lcd_blue;
localparam  CLOCK_PIXEL = 148_500000;


//-------------------------------------
//LCD driver timing
wire	[11:0]	lcd_xpos;		//lcd horizontal coordinate
wire	[11:0]	lcd_ypos;		//lcd vertical coordinate
wire	[23:0]	lcd_data;		//lcd data

assign 		tmds_lvds_tx_clk_rst	= 'b0;
assign 		tmds_lvds_tx_data0_rst	= 'b0;
assign 		tmds_lvds_tx_data1_rst	= 'b0;
assign 		tmds_lvds_tx_data2_rst	= 'b0;
assign 		tmds_lvds_tx_clk_oe		= 'b1;
assign 		tmds_lvds_tx_data0_oe	= 'b1;
assign 		tmds_lvds_tx_data1_oe	= 'b1;
assign 		tmds_lvds_tx_data2_oe	= 'b1;



lcd_driver u_lcd_driver
(
	//global clock
	.clk			(clk_pixel),		
	.rst_n			(rst_n), 
	 
	 //lcd interface
	.lcd_dclk		(),//(lcd_dclk),
	.lcd_blank		(),//lcd_blank
	.lcd_sync		(),		    	
	.lcd_hs			(lcd_hs),		
	.lcd_vs			(lcd_vs),
	.lcd_en			(lcd_de),		
	.lcd_rgb		({lcd_red, lcd_green ,lcd_blue}),

	
	//user interface
	.lcd_request	(),
	.lcd_data		(lcd_data),	
	.lcd_xpos		(lcd_xpos),	
	.lcd_ypos		(lcd_ypos)
);


//-------------------------------------
//lcd data simulation
lcd_display	
//#(
//	.DELAY_TOP		(CLOCK_MAIN)
//)
u_lcd_display
(
	//global clock
	.clk			(clk_pixel),		
	.rst_n			(rst_n), 
	
	.lcd_xpos		(lcd_xpos),	
	.lcd_ypos		(lcd_ypos),
	.lcd_data		(lcd_data)
);


	
	//-------------------------------------
	//Digilent HDMI-TX IP Modified by CB elec.
	rgb2dvi #(.ENABLE_OSERDES(0)) u_rgb2dvi 
	(
		.oe_i 		(1), 			//	Always enable output
		.bitflip_i 		(4'b0000), 		//	Reverse clock & data lanes. 
		
		.aRst			(1'b0), 
		.aRst_n		(rst_n), 
		
		.PixelClk		(clk_pixel        ),//pixel clk = 74.25M
		.SerialClk		(     ),//pixel clk *5 = 371.25M
		
		.vid_pVSync		(lcd_vs), 
		.vid_pHSync		(lcd_hs), 
		.vid_pVDE		(lcd_de), 
		.vid_pData		({lcd_red, lcd_green, lcd_blue}), 
		
		.txc_o		(tmds_lvds_tx_clk_o), 
		.txd0_o		(tmds_lvds_tx_data0), 
		.txd1_o		(tmds_lvds_tx_data1), 
		.txd2_o		(tmds_lvds_tx_data2)
	); 
	
    
    assign led_o[5:2] = {1'b1, lcd_de, lcd_hs, lcd_vs}; 


endmodule
