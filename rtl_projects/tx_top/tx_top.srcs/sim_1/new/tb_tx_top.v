`timescale 1ns / 1ps

module tb_tx_top();

parameter RAM_EXP = 15;
parameter RAM_WIDTH = 8;
parameter EXP_OS = 2;
parameter EXP_BAUD = 3;
parameter NB_COEF     =   8   ;   // coeficients fixed point resolution S(NB,NBF)
parameter NBF_COEF    =   6   ;
parameter NB_OUT      =   8   ;   // tx_filter output fixed point resolution S(NB,NBF)
parameter NBF_OUT     =   6   ;

reg clk;
reg enb;
reg rst;
reg [RAM_EXP-1:0] i_ram_addr_w;
reg [RAM_WIDTH-1:0] i_ram_data_w;
reg [NB_COEF-1:0] prmt_coef;
reg [RAM_EXP-1:0] i_msg_long;
reg i_ram_w_enb;
reg filter_type;
wire [NB_OUT-1:0] o_filter_infase;
wire [NB_OUT-1:0] o_filter_quadrature;

integer scan_error;

integer file_py_coef_filter;
reg signed [NB_COEF-1:0] temporal_py_coef_filter;
reg signed [NB_COEF-1:0] reg_py_coef_filter;

integer file_py_out_filter_infase;
reg signed [NB_OUT-1 :0] temporal_py_out_filter_infase;
reg signed [NB_OUT-1 : 0] reg_py_out_filter_infase;

integer file_py_out_filter_quadrature;
reg signed [NB_OUT-1 :0] temporal_py_out_filter_quadrature;
reg signed [NB_OUT-1 : 0] reg_py_out_filter_quadrature;

integer file_prbs_msg_hex;
reg signed [RAM_WIDTH-1 :0] temporal_prbs_msg_hex;
reg signed [RAM_WIDTH-1 : 0] reg_prbs_msg_hex;

integer file_prbs_msg_addr;
reg signed [RAM_EXP-1 :0] temporal_prbs_msg_addr;
reg signed [RAM_EXP-1 : 0] reg_prbs_msg_addr;

reg compare_infase;
reg compare_quadrature;

tx_top#(.RAM_EXP(RAM_EXP),
        .RAM_WIDTH(RAM_WIDTH),
        .EXP_OS(EXP_OS),
        .EXP_BAUD(EXP_BAUD)
        )
u_tx_top(.rst(rst),
         .clk(clk),
         .enb(enb),
         .i_ram_addr_w(i_ram_addr_w),
         .i_ram_data_w(i_ram_data_w),
         .prmt_coef(prmt_coef),
         .o_filter_infase(o_filter_infase),
         .o_filter_quadrature(o_filter_quadrature),
         .i_msg_long(i_msg_long),
         .i_ram_w_enb(i_ram_w_enb),
         .filter_type(filter_type)
         );


initial begin
    rst = 1'b0;
    filter_type = 1'b1;
    i_msg_long = 249;
    compare_infase = 1'b1;
    compare_quadrature = 1'b1;
    i_ram_w_enb = 1'b0;
    clk = 1'b0;
    enb = 1'b0;
    i_ram_addr_w = 0;
    i_ram_data_w = 0;
    prmt_coef = 0;
    reg_py_out_filter_infase = 0;
    reg_py_out_filter_quadrature = 0;
    i_ram_w_enb = 1'b1;
    assign compare_infase = (reg_py_out_filter_infase == u_tx_top.u_tx_filter_infase.o_tx_filter)? 1'b0:1'b1;
    assign compare_quadrature = (reg_py_out_filter_quadrature == u_tx_top.u_tx_filter_quadrature.o_tx_filter)? 1'b0:1'b1;
    #1e6
    $finish;
end

// open files
initial begin
    file_py_coef_filter = $fopen("D:/proyecto_integrador/python/files/py_intv_coef_filter_doble.txt","r");
    file_py_out_filter_infase = $fopen("D:/proyecto_integrador/python/files/py_intv_out_filter_infase.txt","r");
    file_py_out_filter_quadrature = $fopen("D:/proyecto_integrador/python/files/py_intv_out_filter_quadrature.txt","r");
    file_prbs_msg_hex = $fopen("D:/proyecto_integrador/python/files/prbs_msg_hex.txt","r");
    file_prbs_msg_addr = $fopen("D:/proyecto_integrador/python/files/prbs_msg_addr.txt","r");
    if(file_py_coef_filter == -1) $stop;
end

reg rdy_ram = 1'b0;
//escritura de ram
always@(posedge clk) begin
    if(~rdy_ram) begin
        scan_error = $fscanf (file_prbs_msg_hex,"%x ",temporal_prbs_msg_hex);
            if(scan_error==0) begin
                i_ram_w_enb = 1'b0;
                rst = 1'b1;
                rdy_ram = 1'b1;
            end
        reg_prbs_msg_hex = temporal_prbs_msg_hex;
        i_ram_data_w = reg_prbs_msg_hex;
        scan_error = $fscanf (file_prbs_msg_addr,"%x ",temporal_prbs_msg_addr);
        reg_prbs_msg_addr = temporal_prbs_msg_addr;
        i_ram_addr_w = reg_prbs_msg_addr;
    end
end

//lectura de coeficientes
always@(posedge clk) begin
    if(rst) begin
    scan_error = $fscanf (file_py_coef_filter,"%d ",temporal_py_coef_filter);
        if(scan_error==0) begin
            rst = 1'b0;
            #200
            enb = 1'b1;
        end
    reg_py_coef_filter = temporal_py_coef_filter;
    prmt_coef = reg_py_coef_filter;
    end
end

//comienza a leer archivo de salida
always@(posedge clk) begin
    if($time >= 3590) begin  // es cuando le da el enb auxiliar
        scan_error = $fscanf (file_py_out_filter_infase,"%d ",temporal_py_out_filter_infase);
        if(scan_error==0) begin
            $fclose(file_py_coef_filter);
            $fclose(file_py_out_filter_infase);
            $fclose(file_py_out_filter_quadrature);
            $fclose(file_prbs_msg_hex);
            $fclose(file_prbs_msg_addr);
        $stop;
        end
        reg_py_out_filter_infase = temporal_py_out_filter_infase;
    end
end

//comienza a leer archivo de salida
always@(posedge clk) begin
    if($time >= 3590) begin  // es cuando le da el enb auxiliar
        scan_error = $fscanf (file_py_out_filter_quadrature,"%d ",temporal_py_out_filter_quadrature);
        if(scan_error==0) begin
            $fclose(file_py_coef_filter);
            $fclose(file_py_out_filter_infase);
            $fclose(file_py_out_filter_quadrature);
            $fclose(file_prbs_msg_hex);
            $fclose(file_prbs_msg_addr);
        $stop;
        end
        reg_py_out_filter_quadrature = temporal_py_out_filter_quadrature;
    end
end

always #5 begin
    clk = ~clk;
end

endmodule
