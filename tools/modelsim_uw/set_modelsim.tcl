# TODO: Update the path to the Xilinx libraries, the simulation duration, and the sequence length
set modelsim_lib E:/xilinx_libs
set sim_duration 131072
set seq_length 1872

set_property target_simulator ModelSim [current_project]
set_property compxlib.modelsim_compiled_library_dir $modelsim_lib [current_project]
# set the simulation duration in ns
set_property -name {modelsim.simulate.runtime} -value {1310720ns} -objects [get_filesets sim_1]
set_property -name {modelsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]
# Set sequence length and simulation duration as generics. SIM_DURATION should be runtime/10
set_property -name {modelsim.simulate.vsim.more_options} -value {-g SEQ_LENGTH=1872 -g SIM_DURATION=131072} -objects [get_filesets sim_1]
set_property -name {modelsim.compile.vcom.more_options} -value {-suppress vcom-1135} -objects [get_filesets sim_1]
set_property nl.process_corner fast [get_filesets sim_1]