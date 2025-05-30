# Small tcl script to build the bitstream in vivado
# Note that this scripts is dependent on the project being declared in the tcl shell
# Not suppose to be run directly/independently


# set the project directory. Normally this shouldn't be changed
set proj_dir [get_property DIRECTORY [current_project]]
# optional: set the directory of XSA file will be generated
set xsa_dir $proj_dir/qlaser_top.xsa

reset_runs synth_1
reset_runs impl_1

launch_runs synth_1 -jobs 16
wait_on_run synth_1 -verbose
launch_runs impl_1 -to_step write_bitstream -jobs 16
wait_on_run impl_1 -verbose
puts "Done building bitstream... exporting hardware"
catch {write_hw_platform -fixed -include_bit -force -file $xsa_dir}
