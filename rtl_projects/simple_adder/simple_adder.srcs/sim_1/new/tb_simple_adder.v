`timescale 1ns / 1ps

module tb_simple_adder();

parameter NB_IN = 8;
parameter NBF_IN = 6;
parameter NB_OUT = 8;
parameter NBF_OUT = 6;
localparam AD_LEN = 1;

reg clk;
reg signed [NB_IN-1:0] i_psk_infase;
reg signed [NB_IN-1:0] i_psk_quadrature;
wire signed [NB_OUT-1:0] o_qpsk;

reg compare;

// file load
integer scan_error;

integer file_py_psk_infase;
reg signed [NB_IN-1:0] temporal_py_psk_infase;
reg signed [NB_IN-1:0] reg_py_psk_infase;

integer file_py_psk_quadrature;
reg signed [NB_IN-1:0] temporal_py_psk_quadrature;
reg signed [NB_IN-1:0] reg_py_psk_quadrature;

integer file_py_qpsk;
reg signed [NB_IN-1:0] temporal_py_qpsk;
reg signed [NB_IN-1:0] reg_py_qpsk;

integer file_rtl_qpsk;

simple_adder#  (.NB_IN(NB_IN),
                .NBF_IN(NBF_IN),
                .NB_OUT(NB_OUT),
                .NBF_OUT(NBF_OUT)
                )
u_simple_adder( .clk(clk),
                .i_psk_infase(i_psk_infase),
                .i_psk_quadrature(i_psk_quadrature),
                .o_qpsk(o_qpsk)
                );

initial begin // inicializacion de variables
    clk     = 1'b0  ;
    compare = 1'b0  ;
    reg_py_qpsk = { NB_OUT  {1'b0} };
    assign compare = (reg_py_qpsk == o_qpsk)? 1'b0:1'b1;
    #1e6 $finish;
end

// open files
initial begin
    file_py_psk_infase = $fopen("D:/proyecto_integrador/python/files/py_intv_out_infase_psk.txt","r");
    file_py_psk_quadrature = $fopen("D:/proyecto_integrador/python/files/py_intv_out_quadrature_psk.txt","r");
    file_py_qpsk = $fopen("D:/proyecto_integrador/python/files/py_intv_out_qpsk.txt","r");
    
    if(file_py_psk_infase == -1) $stop;
    if(file_py_psk_quadrature == -1) $stop;
    if(file_py_qpsk == -1) $stop;
    
    file_rtl_qpsk = $fopen("D:/proyecto_integrador/rtl_projects/rtl_files/rtl_out_qpsk.txt","w");
end

always #5 begin
clk = ~clk;
end

//lectura psk infase
always@(posedge clk) begin
    scan_error = $fscanf (file_py_psk_infase,"%d ",temporal_py_psk_infase);
        if(scan_error==0) begin
        $fclose(file_py_psk_infase);
        $fclose(file_py_psk_quadrature);
        $fclose(file_py_qpsk);
        $fclose(file_rtl_qpsk);
        $stop;
        end
    reg_py_psk_infase = temporal_py_psk_infase;
    i_psk_infase = reg_py_psk_infase;
end

//lectura psk quadrature
always@(posedge clk) begin
    scan_error = $fscanf (file_py_psk_quadrature,"%d ",temporal_py_psk_quadrature);
        if(scan_error==0) begin
        $fclose(file_py_psk_infase);
        $fclose(file_py_psk_quadrature);
        $fclose(file_py_qpsk);
        $fclose(file_rtl_qpsk);
        $stop;
        end
    reg_py_psk_quadrature = temporal_py_psk_quadrature;
    i_psk_quadrature = reg_py_psk_quadrature;
end

//lectura qpsk python
always@(posedge clk) begin
    if($time >= 15) begin
    scan_error = $fscanf (file_py_qpsk,"%d ",temporal_py_qpsk);
        if(scan_error==0) begin
        $fclose(file_py_psk_infase);
        $fclose(file_py_psk_quadrature);
        $fclose(file_py_qpsk);
        $fclose(file_rtl_qpsk);
        $stop;
        end
    end
    reg_py_qpsk = temporal_py_qpsk;
end


always@(posedge clk) begin
    if($time > 15) begin
        $fwrite(file_rtl_qpsk,"%d \n",o_qpsk);
    end
end

endmodule
