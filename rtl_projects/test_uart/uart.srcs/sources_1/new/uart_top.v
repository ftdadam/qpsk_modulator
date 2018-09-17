`timescale 1ns / 1ps

module uart_top(clk     ,
                rst     ,
                rd_uart ,
                wr_uart ,
                rx      ,
                w_data  ,
                tx_full ,
                rx_empty,
                tx      ,
                r_data
                );

input clk;
input rst;
input rd_uart;
input wr_uart;
input rx;
input [7:0] w_data;
output wire tx_full;
output wire rx_empty;
output wire tx;
output wire [7:0] r_data;

wire tick;
wire rx_done_tick;
wire tx_done_tick;
wire tx_empty;
wire tx_fifo_not_empty;
wire [7:0] rx_data_out;
wire [7:0] tx_fifo_out;

parameter DBIT = 8;
parameter SB_TICK = 16;
parameter DVSR = 651;
parameter DVSR_BIT = 10;
parameter FIFO_W = 2;

uart_rx # ( .DBIT(DBIT),
            .SB_TICK(SB_TICK)
            )
u_uart_rx ( .clk(clk),
            .rst(rst),
            .rx(rx),
            .s_tick(tick),
            .rx_done_tick(rx_done_tick),
            .dout(rx_data_out)
            );

uart_tx # ( .DBIT(DBIT),
            .SB_TICK(SB_TICK)
            )
u_uart_tx ( .clk(clk),
            .rst(rst),
            .tx_start(tx_fifo_not_empty),
            .s_tick(tick),
            .din(tx_fifo_out),
            .tx_done_tick(tx_done_tick),
            .tx(tx)
            );
            
fifo # (.B(DBIT),
        .W(FIFO_W)
        )
u_fifo_rx(  .clk(clk),
            .rst(rst),
            .rd(rd_uart),
            .wr(rx_done_tick),
            .w_data(rx_data_out),
            .empty(rx_empty),
            .full(),
            .r_data(r_data)
          );

fifo # (.B(DBIT),
        .W(FIFO_W)
        )
u_fifo_tx(  .clk(clk),
            .rst(rst),
            .rd(tx_done_tick),
            .wr(wr_uart),
            .w_data(w_data),
            .empty(tx_empty),
            .full(tx_full),
            .r_data(tx_fifo_out)
          );
          
            
mod_m_counter # (.M(DVSR),
                 .N(DVSR_BIT)
                 )
u_mod_m_counter(.clk(clk),
                .rst(rst),
                .q(),
                .max_tick(tick)
                );

assign tx_fifo_not_empty = ~tx_empty;

endmodule
