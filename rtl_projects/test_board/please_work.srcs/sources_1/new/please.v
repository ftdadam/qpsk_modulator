`timescale 1ns / 1ps

module please   (SW,
                LED
                );
                
input [15:0] SW;
output [15:0] LED;

assign LED = SW;
                
endmodule
