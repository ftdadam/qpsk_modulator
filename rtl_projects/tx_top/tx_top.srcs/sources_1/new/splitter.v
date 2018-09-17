`timescale 1ns / 1ps

module splitter(rst,
                enb,
                clk,
                i_valid,
                i_ram_data,
                o_bit_infase,
                o_bit_quadrature,
                o_fetch_byte
                );

parameter RAM_WIDTH = 8;
                
localparam NB_COUNTER = 2; // log_2(RAM_WIDTH)-1
localparam NB_BUFFER = 2*RAM_WIDTH;
                 
input rst;
input enb;
input clk;
input i_valid;
input [RAM_WIDTH-1:0] i_ram_data;
output wire o_bit_infase;
output wire o_bit_quadrature;
output wire o_fetch_byte;

reg bit_infase;
reg bit_quadrature;

reg [NB_COUNTER-1:0] bit_counter;
reg [NB_BUFFER-1:0] buffer;
reg fetch_reg;

assign o_bit_infase = bit_infase;
assign o_bit_quadrature = bit_quadrature;
assign o_fetch_byte = fetch_reg;

always@(posedge clk) begin
    if(rst) begin
        buffer <= {NB_BUFFER{1'b0}};
        bit_infase <= 1'b0;
        bit_quadrature <= 1'b0;
        bit_counter <= {RAM_WIDTH{1'b1}};
        fetch_reg <= 1'b0;
    end
    else if (enb) begin
        fetch_reg <= 1'b0;
        if(i_valid) begin
            bit_counter <= bit_counter + 1'b1;
            bit_infase = buffer [NB_BUFFER-1];
            bit_quadrature = buffer [NB_BUFFER-2];
            if(bit_counter == {NB_COUNTER{1'b1}}) begin
                buffer <= {{buffer[NB_BUFFER-3 -:RAM_WIDTH]},{i_ram_data}};
                fetch_reg <= 1'b1;
            end
            else
                buffer <= { {buffer[NB_BUFFER-1-2 -: NB_BUFFER-2]},{2{1'b0}} };
        end
    end
    else begin
        buffer <= buffer;
        bit_infase <= bit_infase;
        bit_quadrature <= bit_quadrature;
        bit_counter <= bit_counter;
        fetch_reg <= fetch_reg;
    end
end

endmodule
