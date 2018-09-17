`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Universidad Nacional de Córdoba 
// Facultad de Ciencias Exactas, Físicas y Naturales
// Proyecto Integrador de Ingenería Electrónica
// Autor: Federico Tomás Dadam
// Proyecto: Modulador QPSK
// Modulo: sin_ram
// Fecha de creación: 04.09.2017 12:50:21  
// Descripcion: 
//  
// Revisiones:
//
// Revision 0.01
// Realializada por: 
// Comentarios:
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module sin_ram  (i_addr_w,
                 i_addr_r,
                 i_data_ram,
                 clk,
                 i_write_enb,
                 i_read_enb,
                 //i_out_rst,
                 //i_out_enb,
                 o_data_ram
                 );

  //  Xilinx Simple Dual Port Single Clock RAM
  //  This code implements a parameterizable SDP single clock memory.
  //  If a reset or enable is not necessary, it may be tied off or removed from the code.
  parameter RAM_EXP = 5;
  parameter RAM_WIDTH = 8;                          // Specify RAM data width
  parameter INIT_FILE = "";                         // Specify name/location of RAM initialization file if using one (leave blank if not)
  localparam RAM_PERFORMANCE = "HIGH_PERFORMANCE";  // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
  localparam RAM_DEPTH = 2**RAM_EXP;                // Specify RAM depth (number of entries)
  
  input [RAM_EXP-1:0] i_addr_w;                 // Write address bus, width determined from RAM_DEPTH
  input [RAM_EXP-1:0] i_addr_r;                 // Read address bus, width determined from RAM_DEPTH
  input [RAM_WIDTH-1:0] i_data_ram;             // RAM input data
  input clk;                                    // Clock
  input i_write_enb;                            // Write enable
  input i_read_enb;                             // Read Enable, for additional power savings, disable when not in use
  //input i_out_rst;                            // Output reset (does not affect memory contents)
  //input i_out_enb;                            // Output register enable
  output wire signed [RAM_WIDTH-1:0] o_data_ram;       // RAM output data
  
  reg [RAM_WIDTH-1:0] ram_0 [RAM_DEPTH-1:0];
  reg [RAM_WIDTH-1:0] reg_out_ram = {RAM_WIDTH{1'b0}};

  // The following code either initializes the memory values to a specified file or to all zeros to match hardware
  generate
    if (INIT_FILE != "") begin: use_init_file
      initial
        $readmemh(INIT_FILE, ram_0, 0, RAM_DEPTH-1);
    end else begin: init_bram_to_zero
      integer ram_index;
      initial
        for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
          ram_0[ram_index] = {RAM_WIDTH{1'b0}};
    end
  endgenerate

  always @(posedge clk) begin
    if (i_write_enb)
      ram_0[i_addr_w] <=  i_data_ram;
    if (i_read_enb)
      reg_out_ram <= ram_0[i_addr_r];
  end

  //  The following code generates HIGH_PERFORMANCE (use output register) or LOW_LATENCY (no output register)
  generate
    if (RAM_PERFORMANCE == "LOW_LATENCY") begin: no_output_register

      // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
       assign o_data_ram = reg_out_ram;

    end else begin: output_register

      // The following is a 2 clock cycle read latency with improve clock-to-out timing

      reg [RAM_WIDTH-1:0] doutb_reg = {RAM_WIDTH{1'b0}};

      always @(posedge clk)
        //if (i_out_rst)
        //  doutb_reg <= {RAM_WIDTH{1'b0}};
        //else if (i_out_enb)
          doutb_reg <= reg_out_ram;

      assign o_data_ram = doutb_reg;

    end
  endgenerate
  
endmodule
