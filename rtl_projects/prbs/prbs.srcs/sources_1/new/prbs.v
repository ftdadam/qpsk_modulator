`timescale 1ns / 1ps

module prbs(enb,
            rst,
            clk,
            i_valid,
            o_prbs      
            );
    
parameter PRBS_LEN = 7;
parameter TAP_0 = 6;
parameter TAP_1 = 5;
parameter SEED = 7'b1001110; 

input rst;
input enb;
input clk;
input i_valid;

output wire o_prbs;

reg [PRBS_LEN-1 : 0] shift_reg;

assign o_prbs = shift_reg [0];

always@(posedge clk) begin
    if(rst)
        shift_reg <= SEED;
    else if(enb) begin
        if(i_valid)
            shift_reg <= { { shift_reg[PRBS_LEN-2 -: PRBS_LEN-1] }, { shift_reg[TAP_0]^shift_reg[TAP_1] } };
    end
    else 
        shift_reg <= shift_reg;
end

endmodule


