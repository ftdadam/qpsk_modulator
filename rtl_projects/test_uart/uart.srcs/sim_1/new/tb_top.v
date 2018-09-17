`timescale 1ns / 1ps

module tb_top();

parameter DBIT = 8;
parameter SB_TICK = 16;
parameter DVSR = 651;
parameter DVSR_BIT = 10;
parameter FIFO_W = 2;

reg   CLK100MHZ;
reg   UART_TXD_IN;
reg   [2:0] SW;
//reg   [31:0] rf_data_simulada;
wire  UART_RXD_OUT;
wire  [15:0] LED;


top # ( .DBIT(DBIT), 
        .SB_TICK(SB_TICK), 
        .DVSR(DVSR), 
        .DVSR_BIT(DVSR_BIT), 
        .FIFO_W(FIFO_W)
        )
u_top(  .CLK100MHZ(CLK100MHZ),
        .SW(SW),
        .LED(LED),
        .UART_RXD_OUT(UART_RXD_OUT),
        .UART_TXD_IN(UART_TXD_IN)
        //,.rf_data_simulada(rf_data_simulada)
        );
        
initial begin
    SW[0] = 1'b1;
    SW[1] = 1'b0;
    SW[2] = 1'b0;
    CLK100MHZ = 1'b0;
    UART_TXD_IN = 1'b1;
    /*
    rf_data_simulada = 32'h00000000;
    #265
    #50
    SW[0] = 1'b0;
    #100
    rf_data_simulada = 32'hA1B2C3D4;
    #100
    SW[2] = 1'b1;
    #5000000
    */
    
    /*
    // FPGA a PC
    rf_data_simulada = 32'h00000000;
    rf_control_simulada = 1'b1;
    #265 // clk_wiz pll
    #50
    SW[0] = 1'b0;
    #100
    rf_data_simulada = 32'hA1B2C3D4;
    #100
    rf_control_simulada = 1'b0;
    #1000
    rf_control_simulada = 1'b1;
    #5000000
    
    rf_data_simulada = 32'h01020304;
    #100
    rf_control_simulada = 1'b0;
    #1000
    rf_control_simulada = 1'b1;
    #5000000
    */
    
    /*
    // PC a FPGA
    #200000UART_TXD_IN = 1'b0; // start
    #104190 UART_TXD_IN = 1'b1;   // 1
    #104190 UART_TXD_IN = 1'b1;
    #104190 UART_TXD_IN = 1'b1;
    #104190 UART_TXD_IN = 1'b1;
    #104190 UART_TXD_IN = 1'b0;
    #104190 UART_TXD_IN = 1'b0;
    #104190 UART_TXD_IN = 1'b0;
    #104190 UART_TXD_IN = 1'b0;   // 8
    #104190 UART_TXD_IN = 1'b1;    // stop
    #200000 UART_TXD_IN = 1'b0; // start
    #104190 UART_TXD_IN = 1'b1;      
    #104190 UART_TXD_IN = 1'b0;   
    #104190 UART_TXD_IN = 1'b0;   
    #104190 UART_TXD_IN = 1'b1;   
    #104190 UART_TXD_IN = 1'b0;   
    #104190 UART_TXD_IN = 1'b0;   
    #104190 UART_TXD_IN = 1'b1;   
    #104190 UART_TXD_IN = 1'b1;   //16
    #104190 UART_TXD_IN = 1'b1;    // stop
    #200000 UART_TXD_IN = 1'b0; // start
    #104190 UART_TXD_IN = 1'b1;      
    #104190 UART_TXD_IN = 1'b0;   
    #104190 UART_TXD_IN = 1'b1;   
    #104190 UART_TXD_IN = 1'b1;   
    #104190 UART_TXD_IN = 1'b0;   
    #104190 UART_TXD_IN = 1'b0;   
    #104190 UART_TXD_IN = 1'b0;   
    #104190 UART_TXD_IN = 1'b1;   //24
    #104190 UART_TXD_IN = 1'b1;    // stop
    #200000 UART_TXD_IN = 1'b0; // start
    #104190 UART_TXD_IN = 1'b1;      
    #104190 UART_TXD_IN = 1'b0;   
    #104190 UART_TXD_IN = 1'b0;   
    #104190 UART_TXD_IN = 1'b1;   
    #104190 UART_TXD_IN = 1'b0;   
    #104190 UART_TXD_IN = 1'b0;   
    #104190 UART_TXD_IN = 1'b1;   
    #104190 UART_TXD_IN = 1'b1;   //32
    #104190 UART_TXD_IN = 1'b1;    // stop
    #200000 UART_TXD_IN = 1'b0; // start
    #104190 UART_TXD_IN = 1'b0;   // 1
    #104190 UART_TXD_IN = 1'b0;
    #104190 UART_TXD_IN = 1'b0;
    #104190 UART_TXD_IN = 1'b0;
    #104190 UART_TXD_IN = 1'b1;
    #104190 UART_TXD_IN = 1'b1;
    #104190 UART_TXD_IN = 1'b1;
    #104190 UART_TXD_IN = 1'b1;   // 8
    #104190 UART_TXD_IN = 1'b1;    // stop
    #200000 UART_TXD_IN = 1'b0; // start
    #104190 UART_TXD_IN = 1'b1;      
    #104190 UART_TXD_IN = 1'b1;   
    #104190 UART_TXD_IN = 1'b0;   
    #104190 UART_TXD_IN = 1'b0;   
    #104190 UART_TXD_IN = 1'b0;   
    #104190 UART_TXD_IN = 1'b1;   
    #104190 UART_TXD_IN = 1'b1;   
    #104190 UART_TXD_IN = 1'b0;   //16
    #104190 UART_TXD_IN = 1'b1;    // stop
    #200000 UART_TXD_IN = 1'b0; // start
    #104190 UART_TXD_IN = 1'b0;      
    #104190 UART_TXD_IN = 1'b0;   
    #104190 UART_TXD_IN = 1'b1;   
    #104190 UART_TXD_IN = 1'b1;   
    #104190 UART_TXD_IN = 1'b1;   
    #104190 UART_TXD_IN = 1'b0;   
    #104190 UART_TXD_IN = 1'b1;   
    #104190 UART_TXD_IN = 1'b1;   //24
    #104190 UART_TXD_IN = 1'b1;    // stop
    #200000 UART_TXD_IN = 1'b0; // start
    #104190 UART_TXD_IN = 1'b1;      
    #104190 UART_TXD_IN = 1'b1;   
    #104190 UART_TXD_IN = 1'b1;   
    #104190 UART_TXD_IN = 1'b1;   
    #104190 UART_TXD_IN = 1'b0;   
    #104190 UART_TXD_IN = 1'b1;   
    #104190 UART_TXD_IN = 1'b1;   
    #104190 UART_TXD_IN = 1'b0;   //32
    #104190 UART_TXD_IN = 1'b1;    // stop
    */
    $finish;
    //#1e7 $finish;
    
end

always #5 begin
    CLK100MHZ = ~CLK100MHZ;
end


endmodule
