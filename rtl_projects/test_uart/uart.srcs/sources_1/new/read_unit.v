`timescale 1ns / 1ps

module read_unit(clk,
                 rst,
                 enb,
                 make_read,
                 uart_in,
                 dout
                 );

input clk;
input rst;
input enb;
input [7:0] uart_in;
output reg [31:0] dout;
output wire make_read;
reg [31:0] dout_aux;
reg [1:0] byte_ptr;  

assign make_read = enb? 1'b1: 1'b0;

always@(posedge clk) begin
    if(rst) begin
        dout <= {32{1'b0}};
        dout_aux <= {32{1'b0}};
        byte_ptr <= 0;
    end
    else if(enb) begin
        byte_ptr <= byte_ptr + 1;
        dout_aux <= {{uart_in},{dout_aux[31:8]}};
    end
    else if(byte_ptr == 2'b00) begin
        dout <= dout_aux;
    end
end
                
endmodule
