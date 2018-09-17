`timescale 1ns / 1ps

`include "../../../../register_file/register_file.srcs/sources_1/new/register_file.v"
`include "../../../../register_file/block_ram.v"
`include "../../../../register_file/addr_counter.v"
`include "../../../../mixer/mixer.srcs/sources_1/new/mixer.v"
`include "../../../../mixer/mixer.srcs/sources_1/new/top_mixer.v"
`include "../../../../mixer/sin_ram.v"
`include "../../../../simple_adder/simple_adder.srcs/sources_1/new/simple_adder.v"
`include "../../../../tx_top/tx_top.srcs/sources_1/new/tx_top.v"
`include "../../../../tx_top/tx_top.srcs/sources_1/new/splitter_top.v"
`include "../../../../tx_top/tx_top.srcs/sources_1/new/splitter.v"
`include "../../../../tx_top/info_block_ram.v"
`include "../../../../tx_top/info_ram_addr_counter.v"
`include "../../../../tx_top/fcsg.v"
`include "../../../../tx_filter/tx_filter.srcs/sources_1/new/tx_filter.v"
`include "../../../../test_uart/uart.srcs/sources_1/new/uart_top.v"
`include "../../../../test_uart/uart.srcs/sources_1/new/uart_rx.v"
`include "../../../../test_uart/uart.srcs/sources_1/new/uart_tx.v"
`include "../../../../test_uart/uart.srcs/sources_1/new/fifo.v"
`include "../../../../test_uart/uart.srcs/sources_1/new/mod_m_counter.v"
`include "../../../../test_uart/uart.srcs/sources_1/new/read_unit.v"
`include "../../../../test_uart/uart.srcs/sources_1/new/write_unit.v"
//`include "../../../../prbs/prbs.srcs/sources_1/new/prbs.v"
`include "../../../clk_wiz_0.v"
`include "../../../clk_wiz_0_clk_wiz.v"

module top( CLK100MHZ,
            LED,
            SW,
            JA,
            UART_RXD_OUT,
            UART_TXD_IN
            );

parameter NB_MICRO_IN = 32;

input   CLK100MHZ;
input   UART_TXD_IN;
input   [0:0] SW;
output   [7:0] JA;
output  UART_RXD_OUT;
output  [5:0] LED;

parameter INFO_RAM_EXP = 15;
parameter INFO_RAM_WIDTH = 8;
parameter LOG_RAM_EXP = 15;
parameter LOG_RAM_WIDTH = 32;
parameter EXP_BAUD = 4;  
parameter EXP_OS = 4;

parameter NB_OUT_FILTER = 8;
parameter NBF_OUT_FILTER = 6;
parameter NB_OUT_MIXER = 8;
parameter NBF_OUT_MIXER = 6;
parameter NB_OUT_ADDER = 8;
parameter NBF_OUT_ADDER = 6;
parameter NB_COEF  = 8;
parameter NBF_COEF_SRRC = 6;
parameter NBF_COEF_RRC = 7;
parameter NB_SIN = 6;
parameter NBF_SIN = 5;

parameter SIN_RAM_EXP = 5;

parameter NB_CONTROL_SIGNALS = 2; 

wire [NB_CONTROL_SIGNALS-1:0] connect_control_signal_to_modules; //[rst,enb]
wire signed [NB_OUT_FILTER-1:0] connect_out_filter_infase;
wire signed [NB_OUT_FILTER-1:0] connect_out_filter_quadrature;
wire signed [NB_OUT_MIXER-1:0] connect_out_mixer_infase;
wire signed [NB_OUT_MIXER-1:0] connect_out_mixer_quadrature;
wire signed [NB_OUT_ADDER-1:0] connect_out_adder;
wire [INFO_RAM_EXP-1:0] connect_info_ram_addr;
wire [INFO_RAM_WIDTH-1:0] connect_info_ram_data;
wire connect_info_ram_enb_w;
wire [INFO_RAM_EXP-1:0] connect_msg_long;
wire [LOG_RAM_WIDTH-1:0] connect_o_RAM;
wire connect_led_coef_loaded;
wire connect_led_rdy_log;
wire connect_request_write;
wire [31:0] out_read_unit;
wire filter_type;
//reg [31:0] out_read_unit_for_sim;

wire master_clock;
wire sysclock;
wire dspclock;
wire rst_rf;
assign master_clock = CLK100MHZ;
assign rst_rf = SW[0];

clk_wiz_0
clk_wiz_0(
    // Clock in ports
    .clk_in1(master_clock),      // input clk_in1
    // Clock out ports
    .clk_out1(sysclock),     // output clk_out1
    .clk_out2(dspclock),     // output clk_out2
    // Status and control signals
    .reset(1'b0), // input reset
    .locked()   // output locked
);

register_file#(.NB_MICRO_IN       (NB_MICRO_IN       ),
               .INFO_RAM_EXP      (INFO_RAM_EXP      ),
               .INFO_RAM_WIDTH    (INFO_RAM_WIDTH    ),
               .LOG_RAM_EXP       (LOG_RAM_EXP       ),
               .LOG_RAM_WIDTH     (LOG_RAM_WIDTH     ),
               .EXP_BAUD          (EXP_BAUD          ),
               .EXP_OS            (EXP_OS            ),
               .NB_OUT_FILTER     (NB_OUT_FILTER     ),
               .NB_OUT_MIXER      (NB_OUT_MIXER      ),
               .NB_OUT_ADDER      (NB_OUT_ADDER      ),
               .NB_CONTROL_SIGNALS(NB_CONTROL_SIGNALS)
               )
u_register_file(//.i_micro            (out_read_unit_for_sim),
                .i_micro            (out_read_unit), 
                .i_filter_infase    (connect_out_filter_infase),
                .i_filter_quadrature(connect_out_filter_quadrature),
                .i_psk_infase       (connect_out_mixer_infase),
                .i_psk_quadrature   (connect_out_mixer_quadrature),
                .i_qpsk             (connect_out_adder),
                .rst                (rst_rf),
                .clk                (dspclock),
                .o_control_signals  (connect_control_signal_to_modules),
                .o_led_rdy_log      (connect_led_rdy_log),
                .o_led_coef_loaded  (connect_led_coef_loaded),
                .o_RAM              (connect_o_RAM),
                .o_info_ram_addr    (connect_info_ram_addr),
                .o_info_ram_data    (connect_info_ram_data),
                .o_info_ram_enb_w   (connect_info_ram_enb_w),
                .o_msg_long         (connect_msg_long),
                .o_request_write    (connect_request_write),
                .o_filter_type      (filter_type)
                );

tx_top#(.INFO_RAM_EXP  (INFO_RAM_EXP  ),
        .INFO_RAM_WIDTH(INFO_RAM_WIDTH),
        .EXP_OS        (EXP_OS        ),
        .EXP_BAUD      (EXP_BAUD      ),
        .NB_COEF       (NB_COEF       ),
        .NBF_COEF_SRRC      (NBF_COEF_SRRC      ),
        .NBF_COEF_RRC      (NBF_COEF_RRC      ),
        .NB_OUT        (NB_OUT_FILTER ),
        .NBF_OUT       (NBF_OUT_FILTER)
        )
u_tx_top(.rst(connect_control_signal_to_modules[1]),
         .clk(dspclock),
         .enb(connect_control_signal_to_modules[0]),
         .i_ram_addr_w(connect_info_ram_addr),
         .i_ram_data_w(connect_info_ram_data),
         .i_ram_w_enb(connect_info_ram_enb_w),
         .i_msg_long(connect_msg_long),
         .filter_type(filter_type),
         .prmt_coef(connect_o_RAM[NB_COEF-1:0]),
         .o_filter_infase(connect_out_filter_infase),
         .o_filter_quadrature(connect_out_filter_quadrature)
         );

top_mixer#(.NB_IN      (NB_OUT_FILTER ),
           .NBF_IN     (NBF_OUT_FILTER),
           .NB_OUT_MX  (NB_OUT_MIXER  ),
           .NBF_OUT_MX (NBF_OUT_MIXER ),
           .NB_SIN     (NB_SIN        ),
           .NBF_SIN    (NBF_SIN       ),
           .SIN_RAM_EXP(SIN_RAM_EXP   )
           )
u_top_mixer(.clk(dspclock),
            .rst(connect_control_signal_to_modules[1]),
            .enb(connect_control_signal_to_modules[0]),
            .i_signal_infase(connect_out_filter_infase),
            .i_signal_quadrature(connect_out_filter_quadrature),
            .o_psk_infase(connect_out_mixer_infase),
            .o_psk_quadrature(connect_out_mixer_quadrature)
            );

simple_adder#(.NB_IN  (NB_OUT_MIXER ),
              .NBF_IN (NBF_OUT_MIXER),
              .NB_OUT (NB_OUT_ADDER ),
              .NBF_OUT(NBF_OUT_ADDER)
              )

u_simple_adder(.clk(dspclock),
               .i_psk_infase(connect_out_mixer_infase),
               .i_psk_quadrature(connect_out_mixer_quadrature),
               .o_qpsk(connect_out_adder)
               );
               
parameter DBIT = 8;
parameter SB_TICK = 16;
parameter DVSR = 651;
parameter DVSR_BIT = 10;
parameter FIFO_W = 2;

wire uart_rx_empty;
wire uart_tx_full;
wire read_uart;
wire [7:0] uart_rx_data;
wire [7:0] uart_tx_data;               
                           
uart_top # (.DBIT    (DBIT    ),
            .SB_TICK (SB_TICK ),
            .DVSR    (DVSR    ),
            .DVSR_BIT(DVSR_BIT),
            .FIFO_W  (FIFO_W  )
            )
u_uart_top(.clk     (sysclock),
           .rst     (rst_rf),
           .rd_uart (read_uart),
           .wr_uart (write_uart),
           .rx      (UART_TXD_IN),
           .w_data  (uart_tx_data),
           .tx_full (uart_tx_full),
           .rx_empty(uart_rx_empty),
           .tx      (UART_RXD_OUT),
           .r_data  (uart_rx_data)
           );

read_unit
u_read_unit(.clk(sysclock),
            .rst(rst_rf),
            .enb(~uart_rx_empty),
            .make_read(read_uart),
            .uart_in(uart_rx_data),
            .dout(out_read_unit)
            );

write_unit
u_write_unit(.clk(sysclock),
             .rf_data(connect_o_RAM),
             .request_write(connect_request_write),
             .make_write(write_uart),
             .dout(uart_tx_data)
             );

/*
assign LED[7] = 1'b0;
assign LED[6] = 1'b0;
*/
assign LED[5] = connect_led_coef_loaded;
assign LED[4] = connect_led_rdy_log;
assign LED[3] = connect_control_signal_to_modules[1]; //rst
assign LED[2] = connect_control_signal_to_modules[0]; //enb
//assign LED[1] = out_read_unit_for_sim[23];
assign LED[1] = out_read_unit[23];
assign LED[0] = ~rst_rf;

assign JA = connect_out_adder;

endmodule  
