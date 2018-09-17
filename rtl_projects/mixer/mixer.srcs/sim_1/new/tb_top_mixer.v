`timescale 1ns / 1ps

module tb_top_mixer();

parameter   NB_IN       =   8                       ;
parameter   NBF_IN      =   6                       ;
parameter   NB_OUT_MX   =   8                       ;
parameter   NBF_OUT_MX  =   6                       ;
parameter   NB_SIN      =   6                       ;
parameter   NBF_SIN     =   5                       ;
parameter   SIN_RAM_EXP =   5                       ;
localparam  NBI_IN      =   NB_IN - NBF_IN          ;
localparam  NBI_SIN     =   NB_SIN - NBF_SIN        ;
localparam  NB_COUNTER  =   SIN_RAM_EXP             ;
localparam  NB_PROD_FR    =   NB_IN + NB_SIN        ;
localparam  NBF_PROD_FR   =   NBF_IN + NBF_SIN      ;
localparam  NBI_PROD_FR   =   NB_PROD_FR - NBF_PROD_FR    ;

reg     clk                 ;
reg     rst                 ;
reg     enb                 ;
reg     signed  [NB_IN-1:0]     i_signal_infase     ;
reg     signed  [NB_IN-1:0]     i_signal_quadrature ;
wire    signed  [NB_OUT_MX-1:0]    o_psk_infase        ;
wire    signed  [NB_OUT_MX-1:0]    o_psk_quadrature    ;

// simulation regs
reg     signed  [NB_OUT_MX-1:0] o_mixer_infase_python;
reg     signed  [NB_OUT_MX-1:0] o_mixer_quadrature_python;
integer scan_error;

integer file_py_filter_infase;
reg     signed  [NB_IN-1 :0]     temporal_py_filter_infase;
reg     signed  [NB_IN-1 :0]     reg_py_filter_infase;

integer file_py_filter_quadrature;
reg     signed  [NB_IN-1 :0]     temporal_py_filter_quadrature;
reg     signed  [NB_IN-1 :0]     reg_py_filter_quadrature;

integer file_py_psk_infase;
reg     signed  [NB_IN-1 :0]     temporal_py_psk_infase;
reg     signed  [NB_IN-1 :0]     reg_py_psk_infase;

integer file_py_psk_quadrature;
reg     signed  [NB_IN-1 :0]     temporal_py_psk_quadrature;
reg     signed  [NB_IN-1 :0]     reg_py_psk_quadrature;

integer file_rtl_psk_infase;
integer file_rtl_psk_quadrature;

reg compare_psk_infase;
reg compare_psk_quadrature;

top_mixer# (.NB_IN      (NB_IN      ),
            .NBF_IN     (NBF_IN     ),
            .NB_OUT_MX  (NB_OUT_MX  ),
            .NBF_OUT_MX (NBF_OUT_MX ),
            .NB_SIN     (NB_SIN     ),
            .NBF_SIN    (NBF_SIN    ),
            .SIN_RAM_EXP(SIN_RAM_EXP)
            )
u_top_mixer (.clk                (clk                ),
             .rst                (rst                ),
             .enb                (enb                ),
             .i_signal_infase    (i_signal_infase    ),
             .i_signal_quadrature(i_signal_quadrature),
             .o_psk_infase       (o_psk_infase       ),
             .o_psk_quadrature   (o_psk_quadrature   )
             );

initial begin
    clk     = 1'b0  ;
    rst     = 1'b1  ;
    enb     = 1'b0  ;
    i_signal_infase     = 0 ;
    i_signal_quadrature = 0 ;
    assign compare_psk_infase = (o_psk_infase == o_mixer_infase_python)? 1'b0:1'b1;
    assign compare_psk_quadrature = (o_psk_quadrature == o_mixer_quadrature_python)? 1'b0:1'b1;
    #50
    rst     = 1'b0  ;
    #100
    enb     = 1'b1  ;
end

//  file read
initial begin
    file_py_filter_infase = $fopen("D:/proyecto_integrador/python/files/py_intv_out_filter_infase.txt","r");
    file_py_filter_quadrature = $fopen("D:/proyecto_integrador/python/files/py_intv_out_filter_quadrature.txt","r");
    file_py_psk_infase = $fopen("D:/proyecto_integrador/python/files/py_intv_out_infase_psk.txt","r");    
    file_py_psk_quadrature = $fopen("D:/proyecto_integrador/python/files/py_intv_out_quadrature_psk.txt","r");
    
    if(file_py_filter_infase == -1) $stop;
    if(file_py_filter_quadrature == -1) $stop;
    if(file_py_psk_infase == -1) $stop;
    if(file_py_psk_quadrature == -1) $stop;
    
    file_rtl_psk_infase = $fopen("D:/proyecto_integrador/rtl_projects/rtl_files/rtl_out_psk_infase.txt","w");
    file_rtl_psk_quadrature = $fopen("D:/proyecto_integrador/rtl_projects/rtl_files/rtl_out_psk_quadrature.txt","w");
end

always #5 begin
    clk = ~clk;
end

//lectura de la entrada infase
always@(posedge clk) begin
    if(enb) begin
        scan_error = $fscanf (file_py_filter_infase,"%d ",temporal_py_filter_infase);
        if(scan_error==0) begin  
            $fclose(file_py_filter_infase    );
            $fclose(file_py_filter_quadrature);
            $fclose(file_py_psk_infase         );
            $fclose(file_py_psk_quadrature     );
            $fclose(file_rtl_psk_infase     );
            $fclose(file_rtl_psk_quadrature );
            $stop;
        end
        reg_py_filter_infase = temporal_py_filter_infase;
        i_signal_infase = reg_py_filter_infase;
    end
end

//lectura de la entrada quadrature
always@(posedge clk) begin
    if(enb) begin
        scan_error = $fscanf (file_py_filter_quadrature,"%d ",temporal_py_filter_quadrature);
        if(scan_error==0) begin
            $fclose(file_py_filter_infase    );
            $fclose(file_py_filter_quadrature);
            $fclose(file_py_psk_infase         );
            $fclose(file_py_psk_quadrature     );
            $fclose(file_rtl_psk_infase     );
            $fclose(file_rtl_psk_quadrature );  
            $stop;
        end
        reg_py_filter_quadrature = temporal_py_filter_quadrature;
        i_signal_quadrature = reg_py_filter_quadrature;
    end
end

//lectura del psk infase
always@(posedge clk) begin
    if(enb & $time>=165) begin
        scan_error = $fscanf (file_py_psk_infase,"%d ",temporal_py_psk_infase);
        if(scan_error==0) begin
            $fclose(file_py_filter_infase    );
            $fclose(file_py_filter_quadrature);
            $fclose(file_py_psk_infase         );
            $fclose(file_py_psk_quadrature     );
            $fclose(file_rtl_psk_infase     );
            $fclose(file_rtl_psk_quadrature );  
            $stop;
        end
        reg_py_psk_infase = temporal_py_psk_infase;
        o_mixer_infase_python = reg_py_psk_infase;
    end
end

//lectura del psk quadrature
always@(posedge clk) begin
    if(enb & $time>=165) begin
        scan_error = $fscanf (file_py_psk_quadrature,"%d ",temporal_py_psk_quadrature);
        if(scan_error==0) begin
            $fclose(file_py_filter_infase    );
            $fclose(file_py_filter_quadrature);
            $fclose(file_py_psk_infase         );
            $fclose(file_py_psk_quadrature     );
            $fclose(file_rtl_psk_infase     );
            $fclose(file_rtl_psk_quadrature );
            $stop;
        end
        reg_py_psk_quadrature = temporal_py_psk_quadrature;
        o_mixer_quadrature_python = reg_py_psk_quadrature;
    end
end

//escritura de las salidas
always@(posedge clk) begin
   if(enb== 1'b1) begin
       $fwrite(file_rtl_psk_infase,"%d \n",o_psk_infase);    
       $fwrite(file_rtl_psk_quadrature,"%d \n",o_psk_quadrature);
   end
end

endmodule
