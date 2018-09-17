`timescale 1ns / 1ps

module top( CLK100MHZ,
            SW,
            LED,
            UART_RXD_OUT,
            UART_TXD_IN
            );

input   CLK100MHZ;
input   UART_TXD_IN;
input 	[2:0] SW;
output  UART_RXD_OUT;
output  [15:0] LED;

wire sw_reset;
wire master_clock;
assign master_clock = CLK100MHZ;
assign sw_reset = SW [0];

parameter DBIT = 8;
parameter SB_TICK = 16;
parameter DVSR = 651;
parameter DVSR_BIT = 10;
parameter FIFO_W = 2;

wire [31:0] out_read_unit;
wire uart_rx_empty;
wire read_uart;
wire [7:0] uart_rx_data;

wire uart_tx_full;
wire write_uart;
wire [7:0] uart_tx_data;

wire sysclock;
wire dspclock;
clk_wiz_0
clk_wiz_0(
    // Clock in ports
    .clk_in1(master_clock),      // input clk_in1
    // Clock out ports
    .clk_out1(sysclock),     // output clk_out1
    .clk_out2(dspclock),     // output clk_out2
    // Status and control signals
    .reset(1'b0), // input reset
    .locked()   // output locked
);      


uart_top # (.DBIT    (DBIT    ),
        .SB_TICK (SB_TICK ),
        .DVSR    (DVSR    ),
        .DVSR_BIT(DVSR_BIT),
        .FIFO_W  (FIFO_W  )
        )
u_uart_top( 
        .clk     (sysclock),
        .rst     (sw_reset),
        .rd_uart (read_uart),
        .wr_uart (write_uart),
        .rx      (UART_TXD_IN),
        .w_data  (uart_tx_data),
        .tx_full (uart_tx_full),
        .rx_empty(uart_rx_empty),
        .tx      (UART_RXD_OUT),
        .r_data  (uart_rx_data)
        );



read_unit
u_read_unit( .clk(sysclock),
             .rst(sw_reset),
             .enb(~uart_rx_empty),
             .make_read(read_uart),
             .uart_in(uart_rx_data),
             .dout(out_read_unit)
            );

wire request_write;
wire [31:0] rf_data_simulada_wire;
write_unit
u_write_unit(.clk(sysclock),
             .rf_data(rf_data_simulada_wire),
             .request_write(request_write),
             .make_write(write_uart),
             .dout(uart_tx_data)
            );
 
assign LED [15:0] = SW[1]? out_read_unit[15:0] : out_read_unit[31:16];
reg [31:0] rf_data_simulada;
assign rf_data_simulada_wire = rf_data_simulada;

reg request_write_reg;
assign request_write = request_write_reg;
reg [7:0] aux_counter;

always@(posedge dspclock) begin
    rf_data_simulada <= out_read_unit;
    if(~out_read_unit[31]) begin
        aux_counter <= {8{1'b0}};
        request_write_reg <= 1'b0;  
    end
    else begin
        if(aux_counter < {8{1'b1}}) begin
            aux_counter <= aux_counter + 1'b1;
            request_write_reg <= 1'b1;
        end
        else begin
            aux_counter <= aux_counter;
            request_write_reg <= 1'b0;
        end
        
    end
end

endmodule