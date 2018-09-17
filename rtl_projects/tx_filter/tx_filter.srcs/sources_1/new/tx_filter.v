// time scale for behavoral simulation (set low for comfortable viewing)
`timescale 1ns / 1ps

// module declaration, with its inputs and outputs
module tx_filter(prmt_coef  , 
                 rst        ,
                 enb        ,
                 filter_type,
                 i_valid    ,
                 o_tx_filter,
                 clk        ,
                 i_bit      ,
                 o_prmt_coef
                 );

// desing parameters, overwrited by top module if this module is instanced correctly
parameter   NB_COEF     =   8   ;   // coeficients fixed point resolution S(NB,NBF)
parameter   NBF_COEF_SRRC   =   6   ;
parameter   NBF_COEF_RRC    =   7   ;
parameter   NB_OUT      =   8   ;   // tx_filter output fixed point resolution S(NB,NBF)
parameter   NBF_OUT     =   6   ;
parameter   EXP_BAUD    =   4   ;   // N_BAUD = 2**(EXP_BAUD)
parameter   EXP_OS      =   4   ;   // OS = 2**(EXP_OS)
    
// local parameters, calculated inside the module
localparam AD_LEN = EXP_BAUD;           // aditional lenght in the addition 
localparam N_BAUD = 2**EXP_BAUD;        
localparam OS = 2**EXP_OS ;              
localparam N_COEF = OS*N_BAUD;          // tx_filter number of coefficients
localparam NBI_COEF_SRRC = NB_COEF-NBF_COEF_SRRC;
localparam NBI_COEF_RRC = NB_COEF-NBF_COEF_RRC;
localparam NBI_OUT = NB_OUT-NBF_OUT;    
    
// input declaration
input   [NB_COEF-1 : 0] prmt_coef   ;   // coeficients bus input
input                   rst         ; 
input                   enb         ;
input                   clk         ;   // 
input                   filter_type ;
input                   i_bit       ;   // bit stream input
input                   i_valid     ;   // timer control to insert a valid bit from the bitstream
                                        // it enable 1 bit entrance every OS clock cycles
                                        
// output declaration
output wire signed  [NB_OUT-1 : 0]  o_tx_filter ;   // module output
output wire         [NB_COEF-1 : 0] o_prmt_coef ;   // to connect the end of the coefficient shift register to other modules 
    
// register and wires declation
reg     signed  [NB_COEF*N_COEF-1 : 0]  coef_shift_reg              ;   // shift register with all the filter coefficients 
reg             [N_BAUD-1 : 0]          bits_reg                    ;   // 
wire            [N_BAUD-1 : 0]          bits_wire                   ;   // 
wire    signed  [NB_COEF-1 : 0]         adder_matrix [N_BAUD-1:0]   ;   // matrix to add the multiplications of bits and coefficients
reg     signed  [NB_COEF+AD_LEN-1 : 0]  adder_out                   ;
reg     signed  [NB_OUT-1 : 0]  o_tx_filter_reg             ;
wire                                    sat_pos                     ;
wire                                    sat_neg                     ;
    
// auxiliar registers, wires and other variables
integer adder_ptr;
reg [EXP_OS-1 : 0] fase_ptr;
    
// simple adder
always@(*) begin
    adder_out = adder_matrix[0];
    for (adder_ptr = 1 ;adder_ptr < N_BAUD ; adder_ptr = adder_ptr + 1) begin: adder_loop 
        adder_out = adder_out + adder_matrix[adder_ptr];
    end // for adder_loop
end

// adder matrix
generate 
    genvar ptr;
    for(ptr=0   ;   ptr<N_BAUD  ;   ptr=ptr+1) begin : adder_matrix_loop
        assign  adder_matrix[ptr]   =   (bits_wire[ N_BAUD-1-ptr ] == 0)?
                                        +coef_shift_reg [ (OS*ptr + fase_ptr)*NB_COEF +: NB_COEF]:      // 1.0*coefficient
                                        (coef_shift_reg [ (OS*ptr + fase_ptr)*NB_COEF +: NB_COEF] == {{1'b1},{ NB_COEF-1{1'b0} } } ) ?  
                                        // special case, is the coefficient the most negative number?
                                        {{1'b0},{ NB_COEF-1{1'b1} } }:                              // yes -> change it to most positive                  
                                        -coef_shift_reg [ (OS*ptr + fase_ptr)*NB_COEF +: NB_COEF];  // no -> -1.0*coefficient
    end //for adder_matrix_loop
endgenerate

// truncate and saturate
assign sat_pos      =   ((adder_out[NB_COEF+AD_LEN-1])==0) && (|(adder_out[NB_COEF+AD_LEN-2 -: AD_LEN-1]))  ;
assign sat_neg      =   (adder_out[NB_COEF+AD_LEN-1]) && (&(adder_out[NB_COEF+AD_LEN-2 -: AD_LEN-1 ])==0)   ;
assign o_tx_filter  =   o_tx_filter_reg                                                                     ;
assign o_prmt_coef  =   coef_shift_reg[NB_COEF - 1 : 0]                                                     ;
assign bits_wire    =   (i_valid)? { { i_bit } , { bits_reg[N_BAUD-1 -: N_BAUD-1] } } : bits_reg            ; 

// tristate logic
always@(posedge clk) begin
    if(rst) begin
        fase_ptr        <=  { EXP_OS {1'b0} }       ;
        bits_reg        <=  { N_BAUD {1'b0} }       ;
        o_tx_filter_reg <=  { NB_OUT{1'b0}} ;
        coef_shift_reg  <=  { {prmt_coef[NB_COEF-1 -: NB_COEF] }, {coef_shift_reg [NB_COEF*N_COEF-1 -: NB_COEF*N_COEF-NB_COEF] } }   ;
    end // if (rst)
    else if (enb) begin
        coef_shift_reg  <=  coef_shift_reg      ;
        fase_ptr        <=  fase_ptr + {1'b1}   ;
        bits_reg        <=  bits_wire           ;
        if(filter_type) begin // SRRC
        o_tx_filter_reg <=  (sat_pos)? 
                            { {1'b0} , { NB_OUT-1 {1'b1} } }    :
                            (sat_neg)?
                            { {1'b1} , { NB_OUT-1 {1'b0} } }    :
                            { { adder_out[NBF_COEF_SRRC-NBF_OUT +: NB_OUT] } };
        end
        else begin // RRC
        o_tx_filter_reg <=  (sat_pos)? 
                            { {1'b0} , { NB_OUT-1 {1'b1} } }    :
                            (sat_neg)?
                            { {1'b1} , { NB_OUT-1 {1'b0} } }    :
                            { { adder_out[NBF_COEF_RRC-NBF_OUT +: NB_OUT] } };          
        end
    end // else if (enb)
    else begin
        // to avoid latches 
        fase_ptr        <=  fase_ptr         ;
        bits_reg        <=  bits_reg         ;
        coef_shift_reg  <=  coef_shift_reg   ;
        o_tx_filter_reg <=  o_tx_filter_reg  ;
    end // else
end // always
    
endmodule
