`timescale 1ns / 1ps

module splitter_top(rst,
                    enb,
                    clk,
                    i_valid,
                    i_ram_data,
                    i_msg_long,
                    o_bit_infase,
                    o_bit_quadrature,
                    o_ram_addr_r
                    );

parameter RAM_WIDTH = 8;
parameter RAM_EXP = 8;
parameter EXP_BAUD = 3;
parameter EXP_OS = 2;
input rst;
input enb;
input clk;
input i_valid;
input [RAM_EXP-1:0] i_msg_long;
input [RAM_WIDTH-1:0] i_ram_data;
output wire o_bit_infase;
output wire o_bit_quadrature;
output wire [RAM_EXP-1:0] o_ram_addr_r;

wire connect_fetch;

splitter#(.RAM_WIDTH(RAM_WIDTH))
u_splitter(.rst(rst),
           .enb(enb),
           .clk(clk),
           .i_valid(i_valid),
           .i_ram_data(i_ram_data),
           .o_bit_infase(o_bit_infase),
           .o_bit_quadrature(o_bit_quadrature),
           .o_fetch_byte(connect_fetch)
           );

info_ram_addr_counter#(.EXP_BAUD(EXP_BAUD),
              .EXP_OS(EXP_OS),
              .RAM_EXP(RAM_EXP),
              .RAM_WIDTH(RAM_WIDTH)
              )
u_info_ram_addr_counter(.clk(clk),
               .rst(rst),
               .enb(enb),
               .i_fetch(connect_fetch),
               .i_msg_long(i_msg_long),
               .o_ram_addr(o_ram_addr_r)
               );

endmodule
