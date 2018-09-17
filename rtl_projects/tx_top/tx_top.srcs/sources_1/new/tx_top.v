`timescale 1ns / 1ps

module tx_top(rst,
              clk,
              enb,
              i_ram_addr_w,
              i_ram_data_w,
              i_msg_long,
              i_ram_w_enb,
              filter_type,
              prmt_coef,
              o_filter_infase,
              o_filter_quadrature
              );

parameter INFO_RAM_EXP      = 15;
parameter INFO_RAM_WIDTH    = 8;
parameter EXP_OS            = 4;
parameter EXP_BAUD          = 4;
parameter NB_COEF           = 8;   // coeficients fixed point resolution S(NB,NBF)
parameter NBF_COEF_SRRC     = 6;
parameter NBF_COEF_RRC      = 7;
parameter NB_OUT            = 8;   // tx_filter output fixed point resolution S(NB,NBF)
parameter NBF_OUT           = 6;

input clk;
input enb;
input rst;
input filter_type;
input [INFO_RAM_EXP-1:0] i_ram_addr_w;
input [INFO_RAM_WIDTH-1:0] i_ram_data_w;
input [NB_COEF-1 : 0] prmt_coef;
input [INFO_RAM_EXP-1:0] i_msg_long;
input i_ram_w_enb;
output wire signed  [NB_OUT-1 : 0]  o_filter_infase;
output wire signed  [NB_OUT-1 : 0]  o_filter_quadrature;

wire connect_valid;
wire connect_enb_filter;
wire connect_bit_infase;
wire connect_bit_quadrature;
wire [NB_COEF-1 : 0] connect_prmt_coef_between_filters;


wire [INFO_RAM_EXP-1:0] connect_ram_addr_r_to_splitter;
wire [INFO_RAM_WIDTH-1:0] connect_ram_data_r_to_splitter;

info_block_ram#(.RAM_EXP(INFO_RAM_EXP),
                .RAM_WIDTH(INFO_RAM_WIDTH)
                )
u_info_block_ram (.i_addr_w   (i_ram_addr_w),
                 .i_addr_r   (connect_ram_addr_r_to_splitter),
                 .i_data_ram (i_ram_data_w),
                 .clk        (clk),
                 .i_write_enb(i_ram_w_enb),
                 .i_read_enb (1'b1),
                 .i_out_rst  (1'b0),
                 .i_out_enb  (1'b1),
                 .o_data_ram (connect_ram_data_r_to_splitter)
                 );

fcsg#(.EXP_OS(EXP_OS))
u_fcsg(.rst(rst),
       .enb(enb),
       .clk(clk),
       .o_valid(connect_valid),
       .o_enb_filter(connect_enb_filter)
       );

/*
parameter PRBS_LEN = 7;
parameter TAP_0 = 6;
parameter TAP_1 = 5;
parameter SEED = 7'b1001110;  
prbs#(.PRBS_LEN(PRBS_LEN),
      .TAP_0(TAP_0),
      .TAP_1(TAP_1),
      .SEED(SEED)
      )
u_prbs_i(.enb(enb),
         .rst(rst),
         .clk(clk),
         .i_valid(connect_valid),
         .o_prbs(connect_bit_infase)
         );
         
prbs#(.PRBS_LEN(PRBS_LEN),
      .TAP_0(TAP_0),
      .TAP_1(TAP_1),
      .SEED(SEED)
      )
u_prbs_q(.enb(enb),
         .rst(rst),
         .clk(clk),
         .i_valid(connect_valid),
         .o_prbs(connect_bit_quadrature)
          );
*/
splitter_top#(.RAM_WIDTH(INFO_RAM_WIDTH),
              .RAM_EXP  (INFO_RAM_EXP  ),
              .EXP_BAUD (EXP_BAUD ),
              .EXP_OS   (EXP_OS   )
              )
u_splitter_top(.rst(rst),
               .enb(enb),
               .clk(clk),
               .i_valid(connect_valid),
               .i_ram_data(connect_ram_data_r_to_splitter),
               .i_msg_long(i_msg_long),
               .o_bit_infase(connect_bit_infase),
               .o_bit_quadrature(connect_bit_quadrature),
               .o_ram_addr_r(connect_ram_addr_r_to_splitter)
               );

tx_filter#(.NB_COEF (NB_COEF),
           .NBF_COEF_SRRC(NBF_COEF_SRRC),
           .NBF_COEF_RRC(NBF_COEF_RRC),
           .NB_OUT  (NB_OUT),
           .NBF_OUT (NBF_OUT),
           .EXP_BAUD(EXP_BAUD),
           .EXP_OS  (EXP_OS)
           )

u_tx_filter_infase( .prmt_coef  (prmt_coef), 
                    .rst        (rst),
                    .enb        (connect_enb_filter),
                    .i_valid    (connect_valid),
                    .o_tx_filter(o_filter_infase),
                    .clk        (clk),
                    .i_bit      (connect_bit_infase),
                    .filter_type(filter_type),
                    .o_prmt_coef(connect_prmt_coef_between_filters)
                    );

tx_filter#(.NB_COEF (NB_COEF),
           .NBF_COEF_SRRC(NBF_COEF_SRRC),
           .NBF_COEF_RRC(NBF_COEF_RRC),
           .NB_OUT  (NB_OUT),
           .NBF_OUT (NBF_OUT),
           .EXP_BAUD(EXP_BAUD),
           .EXP_OS  (EXP_OS)
           )

u_tx_filter_quadrature( .prmt_coef  (connect_prmt_coef_between_filters), 
                        .rst        (rst),
                        .enb        (connect_enb_filter),
                        .i_valid    (connect_valid),
                        .o_tx_filter(o_filter_quadrature),
                        .clk        (clk),
                        .i_bit      (connect_bit_quadrature),
                        .filter_type(filter_type),
                        .o_prmt_coef()
                        );

endmodule
