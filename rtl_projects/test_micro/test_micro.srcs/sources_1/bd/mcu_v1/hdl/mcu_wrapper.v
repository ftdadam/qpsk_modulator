//Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2016.1 (win64) Build 1538259 Fri Apr  8 15:45:27 MDT 2016
//Date        : Tue Nov 07 14:02:55 2017
//Host        : DESKTOP-8T38IV2 running 64-bit major release  (build 9200)
//Command     : generate_target mcu_wrapper.bd
//Design      : mcu_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module mcu_wrapper
   (clk_mod,
    gpio_i_data_tri_i,
    gpio_o_data_tri_o,
    reset,
    sys_clock,
    uart_rtl_rxd,
    uart_rtl_txd);
  output clk_mod;
  input [31:0]gpio_i_data_tri_i;
  output [31:0]gpio_o_data_tri_o;
  input reset;
  input sys_clock;
  input uart_rtl_rxd;
  output uart_rtl_txd;

  wire clk_mod;
  wire [31:0]gpio_i_data_tri_i;
  wire [31:0]gpio_o_data_tri_o;
  wire reset;
  wire sys_clock;
  wire uart_rtl_rxd;
  wire uart_rtl_txd;

  mcu mcu_i
       (.clk_mod(clk_mod),
        .gpio_i_data_tri_i(gpio_i_data_tri_i),
        .gpio_o_data_tri_o(gpio_o_data_tri_o),
        .reset(reset),
        .sys_clock(sys_clock),
        .uart_rtl_rxd(uart_rtl_rxd),
        .uart_rtl_txd(uart_rtl_txd));
endmodule
