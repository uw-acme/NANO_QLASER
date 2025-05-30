#*****************************************************************************************
# Vivado (TM) v2022.1.2 (64-bit)
# 
# @EYHC
#
# build_zcu.tcl: Tcl script for build the NanoQ ZCU102 project and attempt to create bitstream
# 
# Command line usage: vivado -mode batch -source build_zcu.tcl
#
# This script is broken into several sections:
# Section I: User file declarations
# Section II: Project-specific declarations and board setup
# Section III: Filesets setup
# Section IV: Additional TCL scripts and block design
#*****************************************************************************************

#*****************************************************************************************
# SECTION I: USER FILE DECLARATIONS
#*****************************************************************************************

# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Set HDL source files for the ZCU102 project. Modify this list to include all necessary files.
set hdl_src [list \
[file normalize "${origin_dir}/../../src/hdl/fpga_zcu102/qlaser_dacs_pulse_channel_pkg.vhd"] \
 [file normalize "${origin_dir}/../../src/hdl/fpga_zcu102/qlaser_dac_dc_pkg.vhd"] \
 [file normalize "${origin_dir}/../../src/hdl/fpga_zcu102/qlaser_pkg.vhd"] \
 [file normalize "${origin_dir}/../../src/hdl/fpga_zcu102/blink.vhd"] \
 [file normalize "${origin_dir}/../../src/hdl/fpga_zcu102/qlaser_dac_pulse_pkg.vhd"] \
 [file normalize "${origin_dir}/../../src/hdl/fpga_zcu102/qlaser_spi.vhd"] \
 [file normalize "${origin_dir}/../../src/hdl/fpga_zcu102/qlaser_cif.vhd"] \
 [file normalize "${origin_dir}/../../src/hdl/fpga_zcu102/qlaser_axis_cpu_sel.vhdl"] \
 [file normalize "${origin_dir}/../../src/hdl/fpga_zcu102/qlaser_dacs_dc_zcu.vhd"] \
 [file normalize "${origin_dir}/../../src/hdl/fpga_zcu102/qlaser_2pmods_pulse.vhd"] \
 [file normalize "${origin_dir}/../../src/hdl/fpga_zcu102/qlaser_dacs_pulse_zcu.vhd"] \
 [file normalize "${origin_dir}/../../src/hdl/fpga_zcu102/qlaser_version_pkg_zcu.vhd"] \
 [file normalize "${origin_dir}/../../src/hdl/fpga_zcu102/qlaser_misc.vhd"] \
 [file normalize "${origin_dir}/../../src/hdl/fpga_zcu102/qlaser_top_zcu.vhd"] \
 [file normalize "${origin_dir}/../../tools/xilinx/ip/bram_waveform/bram_waveform.xci"] \
 [file normalize "${origin_dir}/../../tools/xilinx/ip/bram_pulse_definition/bram_pulse_definition.xci"] \
 [file normalize "${origin_dir}/../../tools/xilinx/ip/axis_data_fifo_32Kx16b/axis_data_fifo_32Kx16b.xci"] \
 [file normalize "${origin_dir}/../../src/hdl/fpga_zcu102/qlaser_dacs_pulse_channel.vhdl"] \
]

# Set hardware constraints files (XDC) for the ZCU102 project. Modify this list to include all necessary files.
set constrs_src [list \
[file normalize "$origin_dir/../../tools/xilinx/constraints/pinout_zcu.xdc"] \
 [file normalize "$origin_dir/../../tools/xilinx/constraints/qlaser_timing_zcu.xdc"] \
 [file normalize "$origin_dir/../../tools/xilinx/constraints/set_usercode_zcu.xdc"] \
]

# DO NOT TOUCH BELOW THIS LINE unless you know what you are doing.

# File avaliability checker
proc checkReqFiles {files} {
  set status true
  foreach ifile $files {
    if { ![file isfile $ifile] } {
      puts " Could not find remote file $ifile "
      set status false
    }
  }
  return $status
}

if { [checkReqFiles $hdl_src] } {
  puts "All HDL source files are available. Proceeding..."
} else {
  puts "ERR: Missing HDL source files. Please check the paths and try again."
  return
}

if { [checkReqFiles $constrs_src] } {
  puts "All constrain source files are available. Proceeding..."
} else {
  puts "ERR: Missing constrain source files. Please check the paths and try again."
  return
}

#*****************************************************************************************
# SECTION II: PROJECT-SPECIFIC DECLARATIONS AND BOARD SETUP
#*****************************************************************************************

# Set the project name. DO NOT PUSH this directly to the repository, as it is very big.
set _xil_proj_name_ "prj"

# "cd" to the directory where this script is located if the origin_dir is current script directory
if { $origin_dir == "." } {
  set origin_dir [file dirname [info script]]
}

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
  set origin_dir $::origin_dir_loc
}

# Use project name variable, if specified in the tcl shell
if { [info exists ::user_project_name] } {
  set _xil_proj_name_ $::user_project_name
}

# Set the directory path for the original project from where this script was exported
set orig_proj_dir "[file normalize "$origin_dir/../../${_xil_proj_name_}"]"

# Create project
create_project ${_xil_proj_name_} ../../${_xil_proj_name_} -part xczu9eg-ffvb1156-2-e -force

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [current_project]

set_property -name "board_part" -value "xilinx.com:zcu102:part0:3.4" -objects $obj
set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
set_property -name "enable_resource_estimation" -value "0" -objects $obj
set_property -name "enable_vhdl_2008" -value "1" -objects $obj
set_property -name "ip_cache_permissions" -value "read write" -objects $obj
set_property -name "ip_output_repo" -value "$proj_dir/${_xil_proj_name_}.cache/ip" -objects $obj
set_property -name "mem.enable_memory_map_generation" -value "1" -objects $obj
set_property -name "platform.board_id" -value "zcu102" -objects $obj
set_property -name "revised_directory_structure" -value "1" -objects $obj
set_property -name "sim.central_dir" -value "$proj_dir/${_xil_proj_name_}.ip_user_files" -objects $obj
set_property -name "sim.ip.auto_export_scripts" -value "1" -objects $obj
set_property -name "simulator_language" -value "VHDL" -objects $obj
set_property -name "target_language" -value "VHDL" -objects $obj
set_property -name "webtalk.activehdl_export_sim" -value "1" -objects $obj
set_property -name "webtalk.modelsim_export_sim" -value "1" -objects $obj
set_property -name "webtalk.questa_export_sim" -value "1" -objects $obj
set_property -name "webtalk.riviera_export_sim" -value "1" -objects $obj
set_property -name "webtalk.vcs_export_sim" -value "1" -objects $obj
set_property -name "webtalk.xcelium_export_sim" -value "1" -objects $obj
set_property -name "webtalk.xsim_export_sim" -value "1" -objects $obj
set_property -name "xpm_libraries" -value "XPM_CDC" -objects $obj
# set IP repo
set_property  ip_repo_paths  "$origin_dir/../../tools/xilinx/ip/axi_cpubus" [current_project]
update_ip_catalog -rebuild

#*****************************************************************************************
# SECTION III: FILESETS SETUP
#*****************************************************************************************

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set 'sources_1' fileset object
set obj [get_filesets sources_1]
add_files -norecurse -fileset $obj $hdl_src

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]
add_files -norecurse -fileset $obj $constrs_src

#*****************************************************************************************
# SECTION IV: ADDITIONAL TCL SCRIPTS AND BLOCK DESIGN
#*****************************************************************************************

# Add Block Design
source "$origin_dir/../../tools/xilinx/ps1_zcu.tcl"
regenerate_bd_layout
make_wrapper -files [get_files "$proj_dir/${_xil_proj_name_}.srcs/sources_1/bd/ps1/ps1.bd"] -top
add_files -norecurse "$proj_dir/${_xil_proj_name_}.gen/sources_1/bd/ps1/hdl/ps1_wrapper.vhd"

puts "Attempt to build the project"
catch {source $origin_dir/../../tools/xilinx/compile.tcl}

exi