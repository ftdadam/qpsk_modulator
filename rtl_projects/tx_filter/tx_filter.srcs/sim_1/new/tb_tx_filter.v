`timescale 1ns / 1ps

module tb_tx_filter();

// === user parameters === 
parameter   NB_COEF     =   8   ;   // coeficients fixed point resolution S(NB,NBF)
parameter   NBF_COEF_SRRC   =   6   ;
parameter   NBF_COEF_RRC    =   7   ;
parameter   NB_OUT      =   8   ;   // tx_filter output fixed point resolution S(NB,NBF)
parameter   NBF_OUT     =   6   ;
parameter   EXP_BAUD    =   4   ;   // N_BAUD = 2**(EXP_BAUD)
parameter   EXP_OS      =   4   ;   // OS = 2**(EXP_OS)

// === local parameters ===
localparam AD_LEN = EXP_BAUD;           // aditional lenght in the addition 
localparam N_BAUD = 2**EXP_BAUD;        
localparam OS = 2**EXP_OS ;              
localparam N_COEF = OS*N_BAUD;          // tx_filter number of coefficients
localparam NBI_COEF_SRRC = NB_COEF-NBF_COEF_SRRC;
localparam NBI_COEF_RRC = NB_COEF-NBF_COEF_RRC;
localparam NBI_OUT = NB_OUT-NBF_OUT;  

// === inputs ===
reg     [NB_COEF-1 : 0]     prmt_coef   ;
reg     rst                             ;
reg     enb                             ;
reg     i_valid                         ;
reg     clk                             ;
reg     i_bit                           ;
reg     filter_type;

// === outputs ===
wire    signed  [NB_OUT-1 : 0]  o_tx_filter ;
wire            [NB_COEF-1 : 0] o_prmt_coef ;

// === simulation regs ===
reg     [EXP_OS-1:0]    valid_counter   ;
reg     enb_aux                         ;

// file load
integer scan_error;
integer ptr_load_prmt_coef;

integer file_py_coef_filter;
reg signed [NB_COEF-1:0] temporal_py_coef_filter;
reg signed [NB_COEF-1:0] reg_py_coef_filter;

integer file_py_symb;
reg temporal_py_symb;
reg reg_py_symb;

integer file_py_out_filter;
reg signed [NB_OUT-1 :0] temporal_py_out_filter;
reg signed [NB_OUT-1 : 0] reg_py_out_filter;

integer file_out_tx_filter_rtl;

reg compare;

tx_filter#( .NB_COEF    (NB_COEF    ), 
            .NBF_COEF_SRRC   (NBF_COEF_SRRC),
            .NBF_COEF_RRC(NBF_COEF_RRC), 
            .EXP_BAUD   (EXP_BAUD   ), 
            .EXP_OS     (EXP_OS     ), 
            .NB_OUT     (NB_OUT     ), 
            .NBF_OUT    (NBF_OUT    )  
            )   
u_tx_filter(.prmt_coef  (prmt_coef  ),
            .rst        (rst        ),                            
            .enb        (enb        ),                    
            .i_valid    (i_valid    ),                        
            .clk        (clk        ),                        
            .i_bit      (i_bit      ),
            .filter_type(filter_type),
            .o_tx_filter     (o_tx_filter)
            );                          

initial begin // inicializacion de variables
    filter_type = 1'b1;
    rst     = 1'b0  ;
    enb     = 1'b0  ;
    enb_aux = 1'b0  ;
    clk     = 1'b0  ;
    i_valid = 1'b0  ;
    i_bit   = 1'b0  ;
    compare = 1'b0  ;
    
    reg_py_coef_filter   = { NB_COEF  {1'b0} };
    reg_py_out_filter = { NB_COEF  {1'b0} };
    prmt_coef       = { N_COEF   {1'b0} };
    valid_counter = {EXP_OS {1'b1}};
    ptr_load_prmt_coef = 0;
    assign compare = (reg_py_out_filter == o_tx_filter)? 1'b0:1'b1;
    #50 rst = 1'b1;
    #1e6 $finish;
end

parameter filter = 1; // 0 = infase; 1 = quadrature
// open files
initial begin
    file_py_coef_filter = $fopen("D:/proyecto_integrador/python/files/py_intv_coef_filter.txt","r");
    if(filter == 0) begin
    file_py_symb = $fopen("D:/proyecto_integrador/python/files/py_intv_symb_infase.txt","r");
    file_out_tx_filter_rtl = $fopen("D:/proyecto_integrador/rtl_projects/rtl_files/rtl_out_filter_infase.txt","w");
    file_py_out_filter = $fopen("D:/proyecto_integrador/python/files/py_intv_out_filter_infase.txt","r");
    end
    else begin
    file_py_symb = $fopen("D:/proyecto_integrador/python/files/py_intv_symb_quadrature.txt","r");    
    file_py_out_filter = $fopen("D:/proyecto_integrador/python/files/py_intv_out_filter_quadrature.txt","r");
    file_out_tx_filter_rtl = $fopen("D:/proyecto_integrador/rtl_projects/rtl_files/rtl_out_filter_quadrature.txt","w");
    end
    
    if(file_py_symb == -1) $stop;
    if(file_py_coef_filter == -1) $stop;
    if(file_py_out_filter == -1) $stop;
    if(file_out_tx_filter_rtl == -1) $stop;
end

always #5 begin
clk = ~clk;
end

// generacion del valid
always@(posedge clk) begin
    if(~rst && enb_aux) begin
        valid_counter = valid_counter + { { OS-1 {1'b0} }, {1'b1} };
        if(valid_counter == {OS {1'b0} })
            i_valid = 1'b1;
        else if(valid_counter != {OS {1'b0} }) begin
            i_valid = 1'b0;
            enb = enb_aux;  // para empezar en fase
        end
    end
end

//lectura de coeficientes
always@(posedge clk) begin
    if(rst) begin
    scan_error = $fscanf (file_py_coef_filter,"%d ",temporal_py_coef_filter);
        if(scan_error==0) begin
            rst = 1'b0;
            #50 enb_aux <= 1'b1;
        end
    reg_py_coef_filter = temporal_py_coef_filter;
    ptr_load_prmt_coef = ptr_load_prmt_coef + 1;
    prmt_coef = reg_py_coef_filter;
    end
end

//comienza a leer archivo de salida
always@(posedge clk) begin
    if($time >= 2685) begin  // es cuando le da el enb auxiliar
        scan_error = $fscanf (file_py_out_filter,"%d ",temporal_py_out_filter);
        if(scan_error==0) begin
        $fclose(file_py_symb);
        $fclose(file_py_coef_filter);
        $fclose(file_py_out_filter);
        $fclose(file_out_tx_filter_rtl);
        $stop;
        end
        reg_py_out_filter = temporal_py_out_filter;
    end
end

always@(posedge clk) begin
   if($time >= 2685) begin
       $fwrite(file_out_tx_filter_rtl,"%d \n",o_tx_filter);    
   end
end

//lectura del bitsream
always@(posedge i_valid) begin
    scan_error = $fscanf (file_py_symb,"%d ",temporal_py_symb);
    if(scan_error==0) begin
    $fclose(file_py_symb);
    $fclose(file_py_coef_filter);
    $fclose(file_py_out_filter);
    $fclose(file_out_tx_filter_rtl);
    $stop;
    end
    reg_py_symb = temporal_py_symb;
    i_bit = reg_py_symb;
end

endmodule