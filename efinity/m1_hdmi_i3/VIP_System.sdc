
# Efinity Interface Designer SDC
# Version: 2022.2.322.1.8
# Date: 2023-02-03 17:00

# Copyright (C) 2017 - 2022 Efinix Inc. All rights reserved.

# Device: Ti60F225
# Project: Ti60_HDMI_1080P_Test
# Timing Model: C4 (final)

# PLL Constraints
#################
create_clock -period 40.0000 clk_ref
create_clock -period 6.6667 clk_pixel
create_clock -waveform {0.3333 1.0000} -period 1.3333 clk_pixel_5x

# GPIO Constraints
####################
# set_input_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -max <MAX CALCULATION> [get_ports {clk_25M}]
# set_input_delay -clock <CLOCK> [-reference_pin <clkout_pad>] -min <MIN CALCULATION> [get_ports {clk_25M}]

# LVDS Tx Constraints
#######################
set_output_delay -clock clk_pixel -reference_pin [get_ports {clk_pixel~CLKOUT~63~322}] -max 0.378 [get_ports {tmds_lvds_tx_clk_o[*]}]
set_output_delay -clock clk_pixel -reference_pin [get_ports {clk_pixel~CLKOUT~63~322}] -min -0.140 [get_ports {tmds_lvds_tx_clk_o[*]}]
set_output_delay -clock clk_pixel -reference_pin [get_ports {clk_pixel~CLKOUT~63~322}] -max 0.378 [get_ports {tmds_lvds_tx_clk_oe}]
set_output_delay -clock clk_pixel -reference_pin [get_ports {clk_pixel~CLKOUT~63~322}] -min -0.140 [get_ports {tmds_lvds_tx_clk_oe}]
set_output_delay -clock clk_pixel -reference_pin [get_ports {clk_pixel~CLKOUT~195~322}] -max 0.378 [get_ports {tmds_lvds_tx_data0[*]}]
set_output_delay -clock clk_pixel -reference_pin [get_ports {clk_pixel~CLKOUT~195~322}] -min -0.140 [get_ports {tmds_lvds_tx_data0[*]}]
set_output_delay -clock clk_pixel -reference_pin [get_ports {clk_pixel~CLKOUT~195~322}] -max 0.378 [get_ports {tmds_lvds_tx_data0_oe}]
set_output_delay -clock clk_pixel -reference_pin [get_ports {clk_pixel~CLKOUT~195~322}] -min -0.140 [get_ports {tmds_lvds_tx_data0_oe}]
set_output_delay -clock clk_pixel -reference_pin [get_ports {clk_pixel~CLKOUT~31~322}] -max 0.378 [get_ports {tmds_lvds_tx_data1[*]}]
set_output_delay -clock clk_pixel -reference_pin [get_ports {clk_pixel~CLKOUT~31~322}] -min -0.140 [get_ports {tmds_lvds_tx_data1[*]}]
set_output_delay -clock clk_pixel -reference_pin [get_ports {clk_pixel~CLKOUT~31~322}] -max 0.378 [get_ports {tmds_lvds_tx_data1_oe}]
set_output_delay -clock clk_pixel -reference_pin [get_ports {clk_pixel~CLKOUT~31~322}] -min -0.140 [get_ports {tmds_lvds_tx_data1_oe}]
set_output_delay -clock clk_pixel -reference_pin [get_ports {clk_pixel~CLKOUT~55~322}] -max 0.378 [get_ports {tmds_lvds_tx_data2[*]}]
set_output_delay -clock clk_pixel -reference_pin [get_ports {clk_pixel~CLKOUT~55~322}] -min -0.140 [get_ports {tmds_lvds_tx_data2[*]}]
set_output_delay -clock clk_pixel -reference_pin [get_ports {clk_pixel~CLKOUT~55~322}] -max 0.378 [get_ports {tmds_lvds_tx_data2_oe}]
set_output_delay -clock clk_pixel -reference_pin [get_ports {clk_pixel~CLKOUT~55~322}] -min -0.140 [get_ports {tmds_lvds_tx_data2_oe}]
set_output_delay -clock clk_pixel -reference_pin [get_ports {clk_pixel~CLKOUT~63~322}] -max 0.420 [get_ports {tmds_lvds_tx_clk_rst}]
set_output_delay -clock clk_pixel -reference_pin [get_ports {clk_pixel~CLKOUT~63~322}] -min -0.175 [get_ports {tmds_lvds_tx_clk_rst}]
set_output_delay -clock clk_pixel -reference_pin [get_ports {clk_pixel~CLKOUT~195~322}] -max 0.420 [get_ports {tmds_lvds_tx_data0_rst}]
set_output_delay -clock clk_pixel -reference_pin [get_ports {clk_pixel~CLKOUT~195~322}] -min -0.175 [get_ports {tmds_lvds_tx_data0_rst}]
set_output_delay -clock clk_pixel -reference_pin [get_ports {clk_pixel~CLKOUT~31~322}] -max 0.420 [get_ports {tmds_lvds_tx_data1_rst}]
set_output_delay -clock clk_pixel -reference_pin [get_ports {clk_pixel~CLKOUT~31~322}] -min -0.175 [get_ports {tmds_lvds_tx_data1_rst}]
set_output_delay -clock clk_pixel -reference_pin [get_ports {clk_pixel~CLKOUT~55~322}] -max 0.420 [get_ports {tmds_lvds_tx_data2_rst}]
set_output_delay -clock clk_pixel -reference_pin [get_ports {clk_pixel~CLKOUT~55~322}] -min -0.175 [get_ports {tmds_lvds_tx_data2_rst}]

# Clockout Interface
######################
# tmds_lvds_tx_clk -clock clk_pixel -reference_pin [get_ports {clk_pixel~CLKOUT~63~322}]
# tmds_lvds_tx_data0 -clock clk_pixel -reference_pin [get_ports {clk_pixel~CLKOUT~195~322}]
# tmds_lvds_tx_data1 -clock clk_pixel -reference_pin [get_ports {clk_pixel~CLKOUT~31~322}]
# tmds_lvds_tx_data2 -clock clk_pixel -reference_pin [get_ports {clk_pixel~CLKOUT~55~322}]
