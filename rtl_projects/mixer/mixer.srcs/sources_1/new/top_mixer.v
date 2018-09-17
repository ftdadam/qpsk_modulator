`timescale 1ns / 1ps

module top_mixer(clk,
                 rst,
                 enb,
                 i_signal_infase,
                 i_signal_quadrature,
                 o_psk_infase,
                 o_psk_quadrature
                 );

parameter   NB_IN       =   8                       ;
parameter   NBF_IN      =   6                       ;
parameter   NB_OUT_MX   =   8                       ;
parameter   NBF_OUT_MX  =   6                       ;
parameter   NB_SIN      =   6                       ;
parameter   NBF_SIN     =   5                       ;
parameter   SIN_RAM_EXP =   5                       ;

localparam  NBI_IN      =   NB_IN - NBF_IN          ;
localparam  NBI_SIN     =   NB_SIN - NBF_SIN        ;
localparam  NB_COUNTER  =   SIN_RAM_EXP             ;
localparam  NB_PROD_FR    =   NB_IN + NB_SIN        ;
localparam  NBF_PROD_FR   =   NBF_IN + NBF_SIN      ;
localparam  NBI_PROD_FR   =   NB_PROD_FR - NBF_PROD_FR    ;

localparam  INIT_FILE_SIN   =   "D:/proyecto_integrador/python/files/py_intv_sin_RAM.txt";
localparam  INIT_FILE_COS   =   "D:/proyecto_integrador/python/files/py_intv_cos_RAM.txt";

input                           clk         ;
input                           rst         ;
input                           enb         ;
input   signed  [NB_IN-1 : 0]   i_signal_infase      ;
input   signed  [NB_IN-1 : 0]   i_signal_quadrature  ;

wire    signed  [NB_SIN-1 : 0]  connect_cos_ram_data_to_mixer_infase            ;
wire    signed  [NB_SIN-1 : 0]  connect_sin_ram_data_to_mixer_quadrature        ;
wire            [SIN_RAM_EXP-1 : 0]  connect_cos_ram_addr_to_mixer_infase       ;
wire            [SIN_RAM_EXP-1 : 0]  connect_sin_ram_addr_to_mixer_quadrature   ;
output  signed  [NB_OUT_MX-1:0] o_psk_infase                             ;
output  signed  [NB_OUT_MX-1:0] o_psk_quadrature                         ;

mixer#          (
                .NB_IN       (NB_IN      ),
                .NBF_IN      (NBF_IN     ),
                .NB_OUT      (NB_OUT_MX  ),
                .NBF_OUT     (NBF_OUT_MX ),
                .NB_SIN      (NB_SIN     ),
                .NBF_SIN     (NBF_SIN    ),
                .SIN_RAM_EXP (SIN_RAM_EXP)
                )
u_mixer_infase  (
                .clk       (clk),
                .rst       (rst),
                .enb       (enb),
                .i_signal  (i_signal_infase),
                .i_ram_data(connect_cos_ram_data_to_mixer_infase),
                .o_ram_addr(connect_cos_ram_addr_to_mixer_infase),
                .o_signal  (o_psk_infase)
                );

sin_ram#    (
            .RAM_EXP(SIN_RAM_EXP),
            .RAM_WIDTH(NB_SIN),
            .INIT_FILE(INIT_FILE_COS) )
u_cos_ram   (
            .i_addr_w   ({SIN_RAM_EXP{1'b0}})              ,    
            .i_addr_r   (connect_cos_ram_addr_to_mixer_infase)    ,
            .i_data_ram ({NB_SIN{1'b0}})              ,   
            .i_write_enb(1'b0)          ,
            .i_read_enb (1'b1)          ,
            .o_data_ram (connect_cos_ram_data_to_mixer_infase)     ,
            .clk(clk)
            );


mixer#              (
                    .NB_IN       (NB_IN      ),
                    .NBF_IN      (NBF_IN     ),
                    .NB_OUT      (NB_OUT_MX  ),
                    .NBF_OUT     (NBF_OUT_MX ),
                    .NB_SIN      (NB_SIN     ),
                    .NBF_SIN     (NBF_SIN    ),
                    .SIN_RAM_EXP (SIN_RAM_EXP)
                    )
u_mixer_quadrature  (
                    .clk       (clk),
                    .rst       (rst),
                    .enb       (enb),
                    .i_signal  (i_signal_quadrature),
                    .i_ram_data(connect_sin_ram_data_to_mixer_quadrature),
                    .o_ram_addr(connect_sin_ram_addr_to_mixer_quadrature),
                    .o_signal  (o_psk_quadrature)
                    );

sin_ram#    (
            .RAM_EXP(SIN_RAM_EXP),
            .RAM_WIDTH(NB_SIN),
            .INIT_FILE(INIT_FILE_SIN) )
u_sin_ram   (
            .i_addr_w   ({SIN_RAM_EXP{1'b0}})              ,    
            .i_addr_r   (connect_sin_ram_addr_to_mixer_quadrature)    ,
            .i_data_ram ({NB_SIN{1'b0}})              ,   
            .i_write_enb(1'b0)          ,
            .i_read_enb (1'b1)          ,
            .o_data_ram (connect_sin_ram_data_to_mixer_quadrature)     ,
            .clk(clk)
            );

           
endmodule
