`timescale 1ns / 1ps

module tb_prbs();
        
parameter PRBS_LEN = 7;
parameter TAP_0 = 6;
parameter TAP_1 = 5;
parameter SEED = 7'b1001110;

reg rst;
reg enb;
reg clk;
reg i_valid;

wire o_prbs;

parameter EXP_OS = 3;
parameter OS = 2**EXP_OS;


reg [EXP_OS-1:0] valid_counter;
reg [PRBS_LEN-1:0] prbs_counter;
reg period;

prbs#( .PRBS_LEN(PRBS_LEN), .TAP_0(TAP_0), .TAP_1(TAP_1), .SEED(SEED) )

u_prbs(.rst(rst),
       .enb(enb),
       .clk(clk),
       .i_valid(i_valid),
       .o_prbs(o_prbs)
       );
        
        
initial begin
    rst = 1'b1;
    enb = 1'b0;
    i_valid = 1'b0;
    clk = 1'b0;
    valid_counter = { OS {1'b0} };
    prbs_counter = { PRBS_LEN {1'b1} };
    #50 rst = 1'b0;
    #50 enb = 1'b1;
    assign period = (SEED == 7'b1001110 && prbs_counter == { PRBS_LEN {1'b1} })? 1'b1:1'b0;
    
    #1e6 $finish;
end

always #5 begin
    clk = ~clk;
end

always@(posedge clk) begin
    if(~rst && enb) begin
        valid_counter = valid_counter + { { OS-1 {1'b0} }, {1'b1} };
        if(valid_counter == {OS {1'b0} }) begin
            i_valid = 1'b1;
            prbs_counter = prbs_counter + { { PRBS_LEN-1 {1'b0} }, {1'b1} };
            if(prbs_counter == { PRBS_LEN {1'b0} })
                prbs_counter = { { PRBS_LEN-1 {1'b0} }, {1'b1} }; 
        end
        else if(valid_counter != {OS {1'b0} }) begin
            i_valid = 1'b0;
        end
    end
end

endmodule
