`timescale 1ns / 1ps

module simple_adder(clk,
                    i_psk_infase,
                    i_psk_quadrature,
                    o_qpsk
                    );
     
parameter NB_IN = 8;
parameter NBF_IN = 6;
parameter NB_OUT = 8;
parameter NBF_OUT = 6;
localparam AD_LEN = 1;

input clk;
input signed [NB_IN-1:0] i_psk_infase;
input signed [NB_IN-1:0] i_psk_quadrature;
output wire signed [NB_OUT-1:0] o_qpsk;

wire sat_pos;
wire sat_neg;

wire signed [NB_IN + AD_LEN - 1 : 0] qpsk_signal;
reg signed [NB_OUT - 1 : 0] qpsk_out_reg;

assign qpsk_signal = i_psk_infase + i_psk_quadrature;
assign sat_pos      =   ((qpsk_signal[NB_OUT+AD_LEN-1])==0) && (|(qpsk_signal[NB_OUT+AD_LEN-2 -: AD_LEN]))  ;
assign sat_neg      =   (qpsk_signal[NB_OUT+AD_LEN-1]) && (&(qpsk_signal[NB_OUT+AD_LEN-2 -: AD_LEN ])==0)   ;

//assign sat_pos = 1'b0;
//assign sat_neg = 1'b0;


assign o_qpsk = qpsk_out_reg;

always@(posedge clk) begin
    qpsk_out_reg <= (sat_pos)? 
                    { {1'b0} , { NB_OUT-1 {1'b1} } }    :
                    (sat_neg)?
                    { {1'b1} , { NB_OUT-1 {1'b0} } }    :
                    { { qpsk_signal[NB_OUT-1 -: NB_OUT] } }; 
end // always
                    
endmodule
