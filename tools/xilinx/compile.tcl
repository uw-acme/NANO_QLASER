# Small tcl script to build the bitstream in vivado.. without the GUI

# Set the project name... change this to your project name if is build differently
set _xil_proj_name_ "prj"

set origin_dir "."
open_project "$origin_dir/../../${_xil_proj_name_}/${_xil_proj_name_}.xpr"
launch_runs impl_1 -to_step write_bitstream

puts "Done building bitstream"
exi