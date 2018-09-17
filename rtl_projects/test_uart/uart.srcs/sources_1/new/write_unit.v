`timescale 1ns / 1ps

module write_unit(clk,
                  rf_data,
                  request_write,
                  make_write,
                  dout
                  );

input request_write;
input [31:0] rf_data;
input clk;
output reg [7:0] dout;
output reg make_write;

reg make_write_latency;
reg [1:0] byte_ptr;

always@(posedge clk) begin
    if(~request_write) begin
        byte_ptr <= {2'b11};
        make_write_latency <= 0;
        make_write <= 0;
        dout <= 0;
    end
    else begin
        byte_ptr <= byte_ptr + 1'b1;
        make_write_latency <= request_write;
        make_write <= make_write_latency;
        case (byte_ptr)
            2'b00:
                dout <= rf_data[7:0];
            2'b01:
                dout <= rf_data[15:8];
            2'b10:
                dout <= rf_data[23:16];
            2'b11:
                dout <= rf_data[31:24];
        endcase
    end
end

endmodule
