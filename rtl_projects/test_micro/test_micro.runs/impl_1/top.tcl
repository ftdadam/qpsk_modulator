proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
set_msg_config  -ruleid {1}  -id {Board 49-26}  -suppress 

start_step init_design
set rc [catch {
  create_msg_db init_design.pb
  create_project -in_memory -part xc7a100tcsg324-1
  set_property board_part digilentinc.com:nexys4_ddr:part0:1.1 [current_project]
  set_property design_mode GateLvl [current_fileset]
  set_param project.singleFileAddWarning.threshold 0
  set_property webtalk.parent_dir D:/proyecto_integrador/rtl_projects/test_micro/test_micro.cache/wt [current_project]
  set_property parent.project_path D:/proyecto_integrador/rtl_projects/test_micro/test_micro.xpr [current_project]
  set_property ip_repo_paths d:/proyecto_integrador/rtl_projects/test_micro/test_micro.cache/ip [current_project]
  set_property ip_output_repo d:/proyecto_integrador/rtl_projects/test_micro/test_micro.cache/ip [current_project]
  set_property XPM_LIBRARIES {XPM_CDC XPM_MEMORY} [current_project]
  add_files -quiet D:/proyecto_integrador/rtl_projects/test_micro/test_micro.runs/synth_1/top.dcp
  add_files D:/proyecto_integrador/rtl_projects/test_micro/test_micro.srcs/sources_1/bd/mcu_v1/mcu.bmm
  set_property SCOPED_TO_REF mcu [get_files -all D:/proyecto_integrador/rtl_projects/test_micro/test_micro.srcs/sources_1/bd/mcu_v1/mcu.bmm]
  add_files d:/proyecto_integrador/rtl_projects/test_micro/test_micro.srcs/sources_1/bd/mcu_v1/ip/mcu_microblaze_0_0/data/mb_bootloop_le.elf
  set_property SCOPED_TO_REF mcu [get_files -all d:/proyecto_integrador/rtl_projects/test_micro/test_micro.srcs/sources_1/bd/mcu_v1/ip/mcu_microblaze_0_0/data/mb_bootloop_le.elf]
  set_property SCOPED_TO_CELLS microblaze_0 [get_files -all d:/proyecto_integrador/rtl_projects/test_micro/test_micro.srcs/sources_1/bd/mcu_v1/ip/mcu_microblaze_0_0/data/mb_bootloop_le.elf]
  read_xdc -ref mcu_microblaze_0_0 -cells U0 d:/proyecto_integrador/rtl_projects/test_micro/test_micro.srcs/sources_1/bd/mcu_v1/ip/mcu_microblaze_0_0/mcu_microblaze_0_0.xdc
  set_property processing_order EARLY [get_files d:/proyecto_integrador/rtl_projects/test_micro/test_micro.srcs/sources_1/bd/mcu_v1/ip/mcu_microblaze_0_0/mcu_microblaze_0_0.xdc]
  read_xdc -ref mcu_dlmb_v10_0 -cells U0 d:/proyecto_integrador/rtl_projects/test_micro/test_micro.srcs/sources_1/bd/mcu_v1/ip/mcu_dlmb_v10_0/mcu_dlmb_v10_0.xdc
  set_property processing_order EARLY [get_files d:/proyecto_integrador/rtl_projects/test_micro/test_micro.srcs/sources_1/bd/mcu_v1/ip/mcu_dlmb_v10_0/mcu_dlmb_v10_0.xdc]
  read_xdc -ref mcu_ilmb_v10_0 -cells U0 d:/proyecto_integrador/rtl_projects/test_micro/test_micro.srcs/sources_1/bd/mcu_v1/ip/mcu_ilmb_v10_0/mcu_ilmb_v10_0.xdc
  set_property processing_order EARLY [get_files d:/proyecto_integrador/rtl_projects/test_micro/test_micro.srcs/sources_1/bd/mcu_v1/ip/mcu_ilmb_v10_0/mcu_ilmb_v10_0.xdc]
  read_xdc -ref mcu_mdm_1_0 -cells U0 d:/proyecto_integrador/rtl_projects/test_micro/test_micro.srcs/sources_1/bd/mcu_v1/ip/mcu_mdm_1_0/mcu_mdm_1_0.xdc
  set_property processing_order EARLY [get_files d:/proyecto_integrador/rtl_projects/test_micro/test_micro.srcs/sources_1/bd/mcu_v1/ip/mcu_mdm_1_0/mcu_mdm_1_0.xdc]
  read_xdc -prop_thru_buffers -ref mcu_clk_wiz_1_0 -cells inst d:/proyecto_integrador/rtl_projects/test_micro/test_micro.srcs/sources_1/bd/mcu_v1/ip/mcu_clk_wiz_1_0/mcu_clk_wiz_1_0_board.xdc
  set_property processing_order EARLY [get_files d:/proyecto_integrador/rtl_projects/test_micro/test_micro.srcs/sources_1/bd/mcu_v1/ip/mcu_clk_wiz_1_0/mcu_clk_wiz_1_0_board.xdc]
  read_xdc -ref mcu_clk_wiz_1_0 -cells inst d:/proyecto_integrador/rtl_projects/test_micro/test_micro.srcs/sources_1/bd/mcu_v1/ip/mcu_clk_wiz_1_0/mcu_clk_wiz_1_0.xdc
  set_property processing_order EARLY [get_files d:/proyecto_integrador/rtl_projects/test_micro/test_micro.srcs/sources_1/bd/mcu_v1/ip/mcu_clk_wiz_1_0/mcu_clk_wiz_1_0.xdc]
  read_xdc -prop_thru_buffers -ref mcu_rst_clk_wiz_1_100M_0 -cells U0 d:/proyecto_integrador/rtl_projects/test_micro/test_micro.srcs/sources_1/bd/mcu_v1/ip/mcu_rst_clk_wiz_1_100M_0/mcu_rst_clk_wiz_1_100M_0_board.xdc
  set_property processing_order EARLY [get_files d:/proyecto_integrador/rtl_projects/test_micro/test_micro.srcs/sources_1/bd/mcu_v1/ip/mcu_rst_clk_wiz_1_100M_0/mcu_rst_clk_wiz_1_100M_0_board.xdc]
  read_xdc -ref mcu_rst_clk_wiz_1_100M_0 -cells U0 d:/proyecto_integrador/rtl_projects/test_micro/test_micro.srcs/sources_1/bd/mcu_v1/ip/mcu_rst_clk_wiz_1_100M_0/mcu_rst_clk_wiz_1_100M_0.xdc
  set_property processing_order EARLY [get_files d:/proyecto_integrador/rtl_projects/test_micro/test_micro.srcs/sources_1/bd/mcu_v1/ip/mcu_rst_clk_wiz_1_100M_0/mcu_rst_clk_wiz_1_100M_0.xdc]
  read_xdc -prop_thru_buffers -ref mcu_axi_gpio_0_0 -cells U0 d:/proyecto_integrador/rtl_projects/test_micro/test_micro.srcs/sources_1/bd/mcu_v1/ip/mcu_axi_gpio_0_0/mcu_axi_gpio_0_0_board.xdc
  set_property processing_order EARLY [get_files d:/proyecto_integrador/rtl_projects/test_micro/test_micro.srcs/sources_1/bd/mcu_v1/ip/mcu_axi_gpio_0_0/mcu_axi_gpio_0_0_board.xdc]
  read_xdc -ref mcu_axi_gpio_0_0 -cells U0 d:/proyecto_integrador/rtl_projects/test_micro/test_micro.srcs/sources_1/bd/mcu_v1/ip/mcu_axi_gpio_0_0/mcu_axi_gpio_0_0.xdc
  set_property processing_order EARLY [get_files d:/proyecto_integrador/rtl_projects/test_micro/test_micro.srcs/sources_1/bd/mcu_v1/ip/mcu_axi_gpio_0_0/mcu_axi_gpio_0_0.xdc]
  read_xdc -prop_thru_buffers -ref mcu_axi_uartlite_0_0 -cells U0 d:/proyecto_integrador/rtl_projects/test_micro/test_micro.srcs/sources_1/bd/mcu_v1/ip/mcu_axi_uartlite_0_0/mcu_axi_uartlite_0_0_board.xdc
  set_property processing_order EARLY [get_files d:/proyecto_integrador/rtl_projects/test_micro/test_micro.srcs/sources_1/bd/mcu_v1/ip/mcu_axi_uartlite_0_0/mcu_axi_uartlite_0_0_board.xdc]
  read_xdc -ref mcu_axi_uartlite_0_0 -cells U0 d:/proyecto_integrador/rtl_projects/test_micro/test_micro.srcs/sources_1/bd/mcu_v1/ip/mcu_axi_uartlite_0_0/mcu_axi_uartlite_0_0.xdc
  set_property processing_order EARLY [get_files d:/proyecto_integrador/rtl_projects/test_micro/test_micro.srcs/sources_1/bd/mcu_v1/ip/mcu_axi_uartlite_0_0/mcu_axi_uartlite_0_0.xdc]
  read_xdc D:/proyecto_integrador/rtl_projects/digilent-xdc-master/Nexys-4-DDR-Master.xdc
  link_design -top top -part xc7a100tcsg324-1
  write_hwdef -file top.hwdef
  close_msg_db -file init_design.pb
} RESULT]
if {$rc} {
  step_failed init_design
  return -code error $RESULT
} else {
  end_step init_design
}

start_step opt_design
set rc [catch {
  create_msg_db opt_design.pb
  opt_design 
  write_checkpoint -force top_opt.dcp
  report_drc -file top_drc_opted.rpt
  close_msg_db -file opt_design.pb
} RESULT]
if {$rc} {
  step_failed opt_design
  return -code error $RESULT
} else {
  end_step opt_design
}

start_step place_design
set rc [catch {
  create_msg_db place_design.pb
  implement_debug_core 
  place_design 
  write_checkpoint -force top_placed.dcp
  report_io -file top_io_placed.rpt
  report_utilization -file top_utilization_placed.rpt -pb top_utilization_placed.pb
  report_control_sets -verbose -file top_control_sets_placed.rpt
  close_msg_db -file place_design.pb
} RESULT]
if {$rc} {
  step_failed place_design
  return -code error $RESULT
} else {
  end_step place_design
}

start_step route_design
set rc [catch {
  create_msg_db route_design.pb
  route_design 
  write_checkpoint -force top_routed.dcp
  report_drc -file top_drc_routed.rpt -pb top_drc_routed.pb
  report_timing_summary -warn_on_violation -max_paths 10 -file top_timing_summary_routed.rpt -rpx top_timing_summary_routed.rpx
  report_power -file top_power_routed.rpt -pb top_power_summary_routed.pb -rpx top_power_routed.rpx
  report_route_status -file top_route_status.rpt -pb top_route_status.pb
  report_clock_utilization -file top_clock_utilization_routed.rpt
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
}

start_step write_bitstream
set rc [catch {
  create_msg_db write_bitstream.pb
  catch { write_mem_info -force top.mmi }
  catch { write_bmm -force top_bd.bmm }
  write_bitstream -force top.bit 
  catch { write_sysdef -hwdef top.hwdef -bitfile top.bit -meminfo top.mmi -file top.sysdef }
  catch {write_debug_probes -quiet -force debug_nets}
  close_msg_db -file write_bitstream.pb
} RESULT]
if {$rc} {
  step_failed write_bitstream
  return -code error $RESULT
} else {
  end_step write_bitstream
}

