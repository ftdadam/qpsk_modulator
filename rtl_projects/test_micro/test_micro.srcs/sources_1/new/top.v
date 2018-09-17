`timescale 1ns / 1ps

module top( CLK100MHZ,
            SW,
            LED,
            UART_RXD_OUT,
            UART_TXD_IN
            );

input   CLK100MHZ;
output  UART_RXD_OUT;
input   UART_TXD_IN;
input 	[3:0] SW;
output   [15:0] LED;
wire reset;
wire sys_clock;
wire uart_rtl_rxd;
wire uart_rtl_txd;
wire clk_mod;

parameter NB_MICRO_IN = 32;
wire [NB_MICRO_IN - 1 : 0] gpio_i_data_tri_i;
wire [NB_MICRO_IN - 1 : 0] gpio_o_data_tri_o;

assign  sys_clock = CLK100MHZ;
assign  reset           = SW[0];
assign  uart_rtl_rxd    = UART_TXD_IN;
assign  UART_RXD_OUT    = uart_rtl_txd;

mcu 
    mcu_i
    (
        .sys_clock(sys_clock),
        .reset(reset),
        .clk_mod(clk_mod),
        // Custom GPIO  -   input
        .gpio_i_data_tri_i(gpio_i_data_tri_i),
        // Custom GPIO  -   output
        .gpio_o_data_tri_o(gpio_o_data_tri_o),
        // USB - Serie   
        .uart_rtl_rxd(uart_rtl_rxd),
        .uart_rtl_txd(uart_rtl_txd)
    );
    
assign LED[14:0] = gpio_o_data_tri_o[14:0];
assign LED[15] = 1'b1; 


endmodule
