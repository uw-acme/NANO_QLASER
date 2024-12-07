# Small tcl script to build the bitstream in vivado.. without the GUI

# Set the project name... change this to your project name if is build differently
set proj_name "prj"

set origin_dir "."
open_project "$origin_dir/../../${proj_name}/${proj_name}.xpr"

set proj_dir [get_property DIRECTORY [current_project]]
reset_runs impl_1
launch_runs impl_1 -to_step write_bitstream -jobs 16
wait_on_run impl_1
puts "Done building bitstream... exporting hardware"
write_hw_platform -fixed -include_bit -force -file $proj_dir/qlaser_top.xsa
# exi