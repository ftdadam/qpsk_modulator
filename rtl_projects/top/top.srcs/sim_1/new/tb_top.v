`timescale 1ns / 1ps

module tb_top();

reg   CLK100MHZ;
reg   UART_TXD_IN;
reg   [0:0] SW;
wire  UART_RXD_OUT;
wire  [5:0] LED;

integer scan_error;
integer file_sim_command;
reg [31:0] temporal_sim_command;
reg [31:0] reg_sim_command;

integer file_out_tx_filter_infase_from_top_rtl;
integer file_out_tx_filter_quadrature_from_top_rtl;
integer file_out_psk_infase_from_top_rtl;
integer file_out_psk_quadrature_from_top_rtl;
integer file_out_qpsk_from_top_rtl;
top
u_top(.CLK100MHZ(CLK100MHZ),
      .UART_TXD_IN(UART_TXD_IN),
      .SW(SW),
      .UART_RXD_OUT(UART_RXD_OUT),
      .LED(LED)
      );

initial begin
    CLK100MHZ = 1'b0;
    UART_TXD_IN = 1'b0;
    SW[0] = 1'b1;
    file_sim_command = $fopen("D:/proyecto_integrador/python/files/sim_command.txt","r");
    if(file_sim_command == -1) $stop;
    file_out_tx_filter_infase_from_top_rtl = $fopen("D:/proyecto_integrador/rtl_projects/rtl_files/file_out_tx_filter_infase_from_top_rtl.txt","w");
    file_out_tx_filter_quadrature_from_top_rtl = $fopen("D:/proyecto_integrador/rtl_projects/rtl_files/file_out_tx_filter_quadrature_from_top_rtl.txt","w");
    file_out_psk_infase_from_top_rtl = $fopen("D:/proyecto_integrador/rtl_projects/rtl_files/file_out_psk_infase_from_top_rtl.txt","w");
    file_out_psk_quadrature_from_top_rtl = $fopen("D:/proyecto_integrador/rtl_projects/rtl_files/file_out_psk_quadrature_from_top_rtl.txt","w");
    file_out_qpsk_from_top_rtl = $fopen("D:/proyecto_integrador/rtl_projects/rtl_files/file_out_qpsk_from_top_rtl.txt","w");
    #20
    SW[0] = 1'b0;
end

always #5 begin
    CLK100MHZ = ~CLK100MHZ;
end

always #300 begin
    if($time>1000) begin
    scan_error = $fscanf (file_sim_command,"%d ",temporal_sim_command);
    if(scan_error==0) begin
        $fclose(file_sim_command);
        $fclose(file_out_tx_filter_infase_from_top_rtl);
        $fclose(file_out_tx_filter_quadrature_from_top_rtl);
        $fclose(file_out_psk_infase_from_top_rtl);
        $fclose(file_out_psk_quadrature_from_top_rtl);
        $fclose(file_out_qpsk_from_top_rtl);
        $stop;
    end
    reg_sim_command = temporal_sim_command;
    u_top.out_read_unit_for_sim = reg_sim_command;
    end
end

always@(posedge u_top.u_tx_top.clk) begin
    if($time>=232765 && $time<1500000) begin
        $fwrite(file_out_tx_filter_infase_from_top_rtl,"%d \n",u_top.u_register_file.i_filter_infase);
        $fwrite(file_out_tx_filter_quadrature_from_top_rtl,"%d \n",u_top.u_register_file.i_filter_quadrature);
        $fwrite(file_out_psk_quadrature_from_top_rtl,"%d \n",u_top.u_top_mixer.o_psk_infase);
        $fwrite(file_out_psk_infase_from_top_rtl,"%d \n",u_top.u_top_mixer.o_psk_quadrature);
        $fwrite(file_out_qpsk_from_top_rtl,"%d \n",u_top.u_simple_adder.o_qpsk);
    end
end

endmodule