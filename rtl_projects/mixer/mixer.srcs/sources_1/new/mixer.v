`timescale 1ns / 1ps

module mixer   (clk             ,
                rst             ,
                enb             ,
                i_signal        ,
                i_ram_data      ,
                o_ram_addr      ,
                o_signal        
                );
                    
// =========== parameters ===========
parameter   NB_IN       =   8                           ;
parameter   NBF_IN      =   6                           ;
parameter   NB_OUT      =   8                           ;
parameter   NBF_OUT     =   6                           ;
parameter   NB_SIN      =   6                           ;
parameter   NBF_SIN     =   5                           ;
parameter   SIN_RAM_EXP =   8                           ;
localparam  NBI_IN      =   NB_IN - NBF_IN              ;
localparam  NBI_OUT     =   NB_OUT - NBF_OUT            ;
localparam  NBI_SIN     =   NB_SIN - NBF_SIN            ;
localparam  NB_COUNTER  =   SIN_RAM_EXP                 ;
localparam  NB_PROD_FR    =   NB_IN + NB_SIN            ;
localparam  NBF_PROD_FR   =   NBF_IN + NBF_SIN          ;
localparam  NBI_PROD_FR   =   NB_PROD_FR - NBF_PROD_FR  ;
localparam  Nsamples_sin  = 20;

// =========== I/O ==========

input                           clk                 ;
input                           rst                 ;
input                           enb                 ;
input   signed  [NB_IN-1:0]     i_signal            ;
input   signed  [NB_SIN-1:0]    i_ram_data          ;


output  wire            [NB_COUNTER-1:0]    o_ram_addr      ;
output  wire    signed  [NB_OUT-1:0]        o_signal        ;
                    

// =========== assings ===========
wire    signed  [NB_PROD_FR-1 : 0]    prod_fr;

assign  prod_fr =  i_signal * i_ram_data;

wire    sat_pos ;
wire    sat_neg ;

assign sat_pos = ( ~prod_fr[NB_PROD_FR-1] &&  (|prod_fr[NB_PROD_FR-2 -: NBI_PROD_FR - NBI_IN] ) );
assign sat_neg = (  prod_fr[NB_PROD_FR-1] && ~(&prod_fr[NB_PROD_FR-2 -: NBI_PROD_FR - NBI_IN] ) );

reg     signed      [NB_OUT -1     : 0]     o_signal_reg;
reg                 [NB_COUNTER-1  : 0]     addr_counter;
assign o_signal  = o_signal_reg;
assign o_ram_addr = addr_counter;

always@(posedge clk) begin
    if(rst) begin 
        addr_counter <= { NB_COUNTER {1'b0} }+1;
        o_signal_reg <= {NB_OUT{1'b0}};
    end // if(rst)
    else if(enb) begin
        o_signal_reg    <=  (sat_pos)?
                            {{1'b0},{NB_OUT-1{1'b1}}}:
                            (sat_neg)?
                            {{1'b1},{NB_OUT-1{1'b0}}}:
                            prod_fr[NB_PROD_FR - 1 - NBI_PROD_FR + NBI_IN  -: NB_OUT];
        if(addr_counter < Nsamples_sin-1) begin
            addr_counter    <=  addr_counter + {1'b1};
        end
        else begin
            addr_counter <= { NB_COUNTER {1'b0} } ;
        end
    end // if(enb)
    else begin
        addr_counter <= { NB_COUNTER {1'b0} } +1;
        o_signal_reg <= {NB_OUT{1'b0}};
    end //else
end // always
endmodule
