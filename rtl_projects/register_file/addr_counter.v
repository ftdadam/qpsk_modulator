`timescale 1ns / 1ps

module addr_counter(clk,
                    rst,
                    o_ram_addr,
                    i_micro_com,
                    o_coef_loaded,
                    o_rdy_log
                    );

parameter EXP_BAUD = 4;         // N_BAUD = 2**(EXP_BAUD)
parameter EXP_OS = 4;           // OS = 2**(EXP_OS)
parameter LOG_RAM_EXP = 15;
parameter NB_MICRO_COMMAND = 8;

localparam RAM_DEPTH = 2**LOG_RAM_EXP;
localparam OS = 2**EXP_OS;
localparam N_BAUD = 2**EXP_BAUD;
localparam N_COEF = OS*N_BAUD;
                   
input clk;
input rst;
input [NB_MICRO_COMMAND-1 : 0] i_micro_com;
output wire [LOG_RAM_EXP-1 : 0] o_ram_addr;
output wire o_coef_loaded;
output wire o_rdy_log;

reg [LOG_RAM_EXP-1 : 0] reg_ram_addr;
reg coef_loaded;
reg rdy_log;

assign o_coef_loaded = coef_loaded;
assign o_rdy_log = rdy_log;
assign o_ram_addr = reg_ram_addr;

always@(posedge clk) begin
    if(rst) begin
        reg_ram_addr <= {LOG_RAM_EXP {1'b0} };
        coef_loaded     <= 1'b0;
        rdy_log      <= 1'b0;
    end
    else begin
        reg_ram_addr <= reg_ram_addr + {1'b1};
        if(reg_ram_addr == N_COEF*2-1 + 2 && i_micro_com == 8'd33) begin
            coef_loaded <= 1'b1;
        end
        if ( (reg_ram_addr == RAM_DEPTH-3 ) && (i_micro_com == 8'd47 || i_micro_com == 8'd48 || i_micro_com == 8'd49)) begin
            rdy_log <= 1'b1;
        end
    end
    
end

endmodule
