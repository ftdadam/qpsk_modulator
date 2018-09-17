`timescale 1ns / 1ps

module mod_m_counter(clk,
                     rst,
                     max_tick,
                     q
                     );

parameter N=4;
parameter M = 10;

input clk;
input rst;
output wire max_tick;
output wire q;

reg [N-1 : 0] r_reg;
wire [N-1 : 0] r_next;

always@(posedge clk, posedge rst) begin
    if(rst) begin
        r_reg <= 0;
    end
    else begin
        r_reg <= r_next;
    end
end

assign r_next = (r_reg == (M-1))? 0 :  r_reg + 1;
assign q = r_reg;
assign max_tick = (r_reg == (M-1))? 1'b1 : 1'b0;

endmodule
