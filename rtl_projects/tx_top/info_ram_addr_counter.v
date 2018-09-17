`timescale 1ns / 1ps

module info_ram_addr_counter(clk,
                             rst,
                             enb,
                             o_ram_addr,
                             i_fetch,
                             i_msg_long
                             );

parameter EXP_BAUD = 3;         // N_BAUD = 2**(EXP_BAUD)
parameter EXP_OS = 2;           // OS = 2**(EXP_OS)
parameter RAM_EXP = 15;
parameter RAM_WIDTH = 8;
localparam RAM_DEPTH = 2**RAM_EXP;
localparam OS = 2**EXP_OS;
localparam N_BAUD = 2**EXP_BAUD;
localparam N_COEF = OS*N_BAUD;
                   
input clk;
input rst;
input enb;
input i_fetch;
input [RAM_EXP-1:0] i_msg_long;
output wire [RAM_EXP-1 : 0] o_ram_addr;

reg [RAM_EXP-1 : 0] reg_ram_addr;
reg [RAM_EXP-1 : 0] msg_long;

localparam init_value = 0;

assign o_ram_addr = reg_ram_addr;

always@(posedge clk) begin
    if(rst) begin
        msg_long <= i_msg_long;
        reg_ram_addr <= init_value;
    end
    else if(enb) begin
        if(i_fetch) begin
            reg_ram_addr <= reg_ram_addr + 1'b1;
            if(reg_ram_addr < msg_long)
                reg_ram_addr <= reg_ram_addr + 1'b1;
            else
                reg_ram_addr <= init_value;
        end
    end
    else begin
        reg_ram_addr <= init_value;
        msg_long <= i_msg_long;
    end
end

endmodule
