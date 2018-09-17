`timescale 1ns / 1ps

module register_file(i_micro,
                     i_filter_infase,
                     i_filter_quadrature,
                     i_psk_infase,
                     i_psk_quadrature,
                     i_qpsk,
                     rst,
                     clk,
                     o_control_signals,
                     o_led_rdy_log,
                     o_led_coef_loaded,
                     o_RAM,
                     o_info_ram_addr,
                     o_info_ram_data,
                     o_info_ram_enb_w,
                     o_msg_long,
                     o_request_write,
                     o_filter_type
                     );

// ===== RAM paramters =====

parameter NB_MICRO_IN       = 32;
parameter INFO_RAM_EXP      = 15;
parameter INFO_RAM_WIDTH    = 8;
parameter LOG_RAM_EXP       = 15;
parameter LOG_RAM_WIDTH     = 32;
parameter EXP_BAUD          = 4;  
parameter EXP_OS            = 4;
parameter NB_OUT_FILTER     = 8;
parameter NB_OUT_MIXER      = 8;
parameter NB_OUT_ADDER      = 8;
parameter NB_CONTROL_SIGNALS = 2;
localparam RAM_DEPTH = 2**LOG_RAM_EXP;

// ===== reg_file parameters =====                
localparam NB_MICRO_COMMAND = 8; 
localparam NB_MICRO_ADDR = LOG_RAM_EXP;
localparam NB_MICRO_DATA = 8;

// ===== register_file I/O =====
input [NB_MICRO_IN - 1 : 0] i_micro;
input rst;
input clk;
input signed [NB_OUT_FILTER-1 : 0] i_filter_infase;
input signed [NB_OUT_FILTER-1 : 0] i_filter_quadrature;
input signed [NB_OUT_MIXER-1 : 0] i_psk_infase;
input signed [NB_OUT_MIXER-1 : 0] i_psk_quadrature;
input signed [NB_OUT_ADDER-1 : 0] i_qpsk;
output wire [NB_CONTROL_SIGNALS-1 : 0] o_control_signals;
output wire [LOG_RAM_WIDTH-1 : 0] o_RAM;
output wire o_led_rdy_log;
output wire o_led_coef_loaded;
output wire [INFO_RAM_EXP-1:0] o_info_ram_addr;
output wire [INFO_RAM_WIDTH-1:0] o_info_ram_data;
output wire o_info_ram_enb_w;
output wire [INFO_RAM_EXP-1:0] o_msg_long;
output wire o_request_write;
output wire o_filter_type;
// ===== RF regs and wires ===== 

wire [NB_MICRO_COMMAND - 1 : 0] micro_com;
wire micro_enb;
wire [NB_MICRO_ADDR - 1 : 0] micro_addr;
wire [NB_MICRO_DATA - 1 : 0] micro_data;
wire rdy_log;
wire coef_loaded;

assign micro_com =  i_micro [NB_MICRO_IN - 1 -: NB_MICRO_COMMAND];
assign micro_enb =  i_micro [NB_MICRO_IN - 1 - NB_MICRO_COMMAND];
assign micro_addr = i_micro [(NB_MICRO_IN - 1 - NB_MICRO_COMMAND - 1) -: NB_MICRO_ADDR];
assign micro_data = i_micro [(NB_MICRO_IN - 1 - NB_MICRO_COMMAND - 1 - NB_MICRO_ADDR) -: NB_MICRO_DATA];

// ===== address counter regs and instance =====
reg  rst_addr_counter;
wire [LOG_RAM_EXP-1:0] addr_from_addr_counter;

addr_counter#(.EXP_BAUD(EXP_BAUD),.EXP_OS(EXP_OS), .LOG_RAM_EXP(LOG_RAM_EXP), .NB_MICRO_COMMAND(NB_MICRO_COMMAND) )
addr_counter(.rst(rst_addr_counter), 
            .clk(clk), 
            .i_micro_com(micro_com),
            .o_ram_addr(addr_from_addr_counter), 
            .o_coef_loaded(coef_loaded),
            .o_rdy_log(rdy_log)
            );

// ===== ram regs and instance ======

reg [LOG_RAM_EXP-1:0]   ram_addr_w; 
reg [LOG_RAM_EXP-1:0]   ram_addr_r; 
reg [LOG_RAM_WIDTH-1:0]   ram_data;      
reg                     ram_write_enb;                    
reg                     ram_read_enb;                          
reg                     ram_out_rst;
reg                     ram_out_enb;

block_ram#(.RAM_EXP(LOG_RAM_EXP ),.RAM_WIDTH(LOG_RAM_WIDTH) )
u_block_ram(.i_addr_w   (ram_addr_w)   ,    
            .i_addr_r   (ram_addr_r)   ,
            .i_data_ram (ram_data)     ,   
            .i_write_enb(ram_write_enb),
            .i_read_enb (ram_read_enb) , 
            .i_out_rst  (ram_out_rst)  ,
            .i_out_enb  (ram_out_enb)  ,
            .o_data_ram (o_RAM)     ,
            .clk(clk)
            );

reg [NB_CONTROL_SIGNALS-1 : 0] control_signals_reg;
reg [INFO_RAM_EXP-1:0] info_ram_addr_reg;
reg [INFO_RAM_WIDTH-1:0] info_ram_data_reg;
reg info_ram_enb_w_reg;
reg [INFO_RAM_EXP-1:0] msg_long;
reg [7:0] aux_counter;
reg request_write_reg;
reg filter_type_reg;
assign o_msg_long = msg_long;
assign o_info_ram_addr = info_ram_addr_reg;
assign o_info_ram_data = info_ram_data_reg;
assign o_info_ram_enb_w = info_ram_enb_w_reg;
assign o_control_signals = control_signals_reg;
assign o_led_rdy_log = rdy_log;
assign o_led_coef_loaded = coef_loaded;
assign o_request_write = request_write_reg;
assign o_filter_type = filter_type_reg;
// ===== always =====

always@(posedge clk) begin
    if(rst) begin
        // resetear la RAM
        ram_addr_w      <= { LOG_RAM_EXP {1'b0}};   // zeros for all inputs
        ram_addr_r      <= { LOG_RAM_EXP {1'b0}};
        ram_data        <= { LOG_RAM_WIDTH {1'b0}};
        ram_write_enb   <= {1'b0};                  // disable write
        ram_read_enb    <= {1'b1};                  // enable read
        ram_out_rst     <= {1'b0};                  // NO reset output
        ram_out_enb     <= {1'b1};                  // enable output                                                                   
        rst_addr_counter <= {1'b1};                 // disable addr counter
        control_signals_reg <= 0;
        info_ram_addr_reg <= 0;
        info_ram_data_reg <= 0;
        info_ram_enb_w_reg <= 0;
        msg_long <= 0;
        aux_counter <= 0;
        request_write_reg <= 0;
        filter_type_reg <= 0;
    end
    else if(micro_enb == {1'b1} ) begin
        case(micro_com)
            8'd0 :  ram_write_enb           <= {1'b0};  // write disable
            8'd1 :  ram_write_enb           <= {1'b1};  // write enable
            8'd2 :  ram_out_rst             <= {1'b1};  // reseted output
            8'd3 :  ram_out_rst             <= {1'b0};  // NO reset output
            8'd4 :  ram_out_enb             <= {1'b1};  // output enabled
            8'd5 :  ram_out_enb             <= {1'b0};  // output disabled 
            8'd6 :  ram_read_enb            <= {1'b1};  // read enabled
            8'd7 :  ram_read_enb            <= {1'b0};  // read disabled
            8'd16:  control_signals_reg     <= micro_data;  // establish control signals from PC
            8'd30:  begin   // rst aux_counter
                    aux_counter <= {8{1'b0}};
                    request_write_reg <= 1'b0;
                    end
            8'd31:  begin   // make_uart_write_request
                    if(aux_counter < {8{1'b1}}) begin
                        aux_counter <= aux_counter + 1'b1;
                        request_write_reg <= 1'b1;
                    end
                    else begin
                        aux_counter <= aux_counter;
                        request_write_reg <= 1'b0;
                    end
                    end
            8'd32:  begin   // write coefficients to RAM
                    ram_data                <= { {NB_MICRO_IN-NB_MICRO_DATA{1'b0}} ,{micro_data}};
                    ram_addr_w              <= micro_addr;
                    end
            8'd33:  begin   // write coefficients to shift registers
                    ram_addr_r                  <= addr_from_addr_counter;
                        if(coef_loaded == 1'b0) begin
                            control_signals_reg     <= {{1'b1}, {1'b0}}; // forced reset and disable of Tx 
                            rst_addr_counter        <= {1'b0};  // enable addr counter to work as pointer  
                        end
                        if(coef_loaded == 1'b1) begin
                            control_signals_reg     <= {{1'b0} , {1'b0} }; // forced no-reset and disable of Tx
                        end
                    end
            8'd34:  rst_addr_counter                <= {1'b1};  // disable addr counter
            8'd35:  begin   // write INFO ram (splitter)
                        info_ram_addr_reg <= micro_addr;
                        info_ram_data_reg <= micro_data; 
                    end
            8'd36:  info_ram_enb_w_reg <= 1'b1;   // INFO RAM write enable
            8'd37:  info_ram_enb_w_reg <= 1'b0;   // INFO RAM write disable
            8'd38:  msg_long <= micro_addr;       // set messege longitud
            8'd39:  filter_type_reg <= micro_data[0];
            8'd47:  begin   // write filter outputs to ram
                    ram_addr_w                      <= addr_from_addr_counter;
                    ram_data                        <= { {NB_OUT_FILTER{1'b0}}, {i_filter_quadrature} , {NB_OUT_FILTER{1'b0}} ,{i_filter_infase} };
                        if(rdy_log == 1'b0) begin
                            rst_addr_counter        <= {1'b0};  // enable addr counter
                        end
                        if(rdy_log == 1'b1) begin
                            ram_write_enb           <= {1'b0};  // write disable                             
                        end
                    end
            8'd48:  begin   // write psk outputs to ram
                    ram_addr_w                      <= addr_from_addr_counter;
                    ram_data                        <= { {NB_OUT_MIXER{1'b0}}, {i_psk_infase} , {NB_OUT_MIXER{1'b0}} ,{i_psk_quadrature} };
                        if(rdy_log == 1'b0) begin
                            rst_addr_counter        <= {1'b0};  // enable addr counter
                        end
                        if(rdy_log == 1'b1) begin
                            ram_write_enb           <= {1'b0};  // write disable                             
                        end
                    end
            8'd49:  begin   // write qpsk output to ram
                    ram_addr_w                      <= addr_from_addr_counter;
                    ram_data                        <= { {NB_OUT_ADDER{1'b0}} , {i_qpsk} , {NB_OUT_ADDER{1'b0}}, {i_qpsk} };
                        if(rdy_log == 1'b0) begin
                            rst_addr_counter        <= {1'b0};  // enable addr counter
                        end
                        if(rdy_log == 1'b1) begin
                            ram_write_enb           <= {1'b0};  // write disable                             
                        end
                    end
            8'd50:  ram_addr_r                      <= micro_addr;  // send an address to PC
            8'd60:  ram_data                        <= { {i_psk_infase}, {NB_OUT_MIXER{1'b0}}, {i_psk_quadrature} , {NB_OUT_MIXER{1'b0}} }; // to avoid warning
        endcase
    end
end
                 
endmodule