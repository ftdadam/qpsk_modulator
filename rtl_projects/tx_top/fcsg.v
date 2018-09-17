`timescale 1ns / 1ps

module fcsg(rst,
            enb,
            clk,
            o_valid,
            o_enb_filter
            );

parameter EXP_OS = 2;
localparam OS = 2**EXP_OS;

// ==== FCSG I/O and regs ====

input rst;
input enb;
input clk;

output wire o_enb_filter;
output wire o_valid;

// ==== Internal regs ====
reg [EXP_OS-1:0] valid_counter;
reg reg_enb_filter;
reg delay;
// ==== outputs ====

assign o_valid = (valid_counter == {EXP_OS {1'b0} })? 1'b1:1'b0;
assign o_enb_filter = reg_enb_filter;

// ==== FCSG ====

always@(posedge clk) begin
    if(rst) begin
        valid_counter <= {EXP_OS {1'b1}};
        reg_enb_filter <= 1'b0;
        delay <= 1'b0;
    end
    else if(enb) begin
        valid_counter <= valid_counter + { { EXP_OS-1 {1'b0} }, {1'b1} };
        delay <= 1'b1;
        if(valid_counter == {EXP_OS {1'b1}} && delay) begin
            reg_enb_filter <= 1'b1;
        end
    end
    else begin
        valid_counter <= {EXP_OS {1'b1}};
        delay <= delay;
        reg_enb_filter <= reg_enb_filter;
    end
end

endmodule
