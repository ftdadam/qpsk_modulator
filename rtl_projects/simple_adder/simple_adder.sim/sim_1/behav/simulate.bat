@echo off
set xv_path=C:\\Xilinx\\Vivado\\2016.1\\bin
call %xv_path%/xsim tb_simple_adder_behav -key {Behavioral:sim_1:Functional:tb_simple_adder} -tclbatch tb_simple_adder.tcl -view D:/proyecto_integrador/rtl_projects/simple_adder/tb_simple_adder_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
