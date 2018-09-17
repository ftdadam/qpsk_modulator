`timescale 1ns / 1ps

module fifo(clk,
            rst,
            rd,
            wr,
            w_data,
            empty,
            full,
            r_data
            );
            
parameter B=8;  // numero de bits en una palabra
parameter W=4;   // numero de bits de address

input clk;
input rst;
input rd;
input wr;
input [B-1:0] w_data;
output wire empty;
output wire full;
output wire [B-1:0] r_data;


reg [B-1:0] array_reg [2**W-1:0];
reg [W-1:0] w_ptr_reg;
reg [W-1:0] w_ptr_next;
reg [W-1:0] w_ptr_succ;
reg [W-1:0] r_ptr_reg;
reg [W-1:0] r_ptr_next;
reg [W-1:0] r_ptr_succ;
reg full_reg;
reg empty_reg;
reg full_next;
reg empty_next;

wire wr_enb;

assign r_data = array_reg[r_ptr_reg]; //register file read operation
assign wr_enb = wr & ~full_reg; // wirte enb only when FIFO is not full

assign full = full_reg;
assign empty = empty_reg;

always@(posedge clk) begin
    if(wr_enb) begin
        array_reg[w_ptr_reg] <= w_data;
    end
end

always@(posedge clk, posedge rst) begin
    if(rst) begin
        w_ptr_reg <= 0;
        r_ptr_reg <= 0;
        full_reg <= 1'b0;
        empty_reg <= 1'b1;
    end
    else begin
        w_ptr_reg <= w_ptr_next;
        r_ptr_reg <= r_ptr_next;
        full_reg <= full_next;
        empty_reg <= empty_next;
    end
end

always@(*) begin
    w_ptr_succ = w_ptr_reg + 1;
    r_ptr_succ = r_ptr_reg + 1;
    w_ptr_next = w_ptr_reg;
    r_ptr_next = r_ptr_reg;
    full_next = full_reg;
    empty_next = empty_reg;
    case({wr,rd})
        //2'b00: //no operation   
        2'b01: begin // read
            if(~empty_reg) begin
                r_ptr_next = r_ptr_succ;
                full_next = 1'b0;
                if(r_ptr_succ == w_ptr_reg) begin
                    empty_next = 1'b1;
                end
            end
        end
        2'b10: begin // write
            if(~full_reg) begin
                w_ptr_next = w_ptr_succ;
                empty_next = 1'b0;
                if(w_ptr_succ == r_ptr_reg) begin
                    full_next = 1'b1;
                end
            end
        end
        2'b11: begin // write and read
            w_ptr_next = w_ptr_succ;
            r_ptr_next = r_ptr_succ;
        end
    endcase
end

endmodule
