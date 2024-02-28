# "cd" to the directory where this script is located
cd [file dirname [info script]]

# set the name of the project directory. Change this to whatever you want... just make sure add this to the .gitignore file
set proj_dir prj

create_project prj_zcu_102 ../../$proj_dir -force

set_property board_part xilinx.com:zcu102:part0:3.4 [current_project]

# get constraints files from a directory
proc add_ip {dir} {
    # Get a list of files and directories in the specified directory
    set files [glob -nocomplain -directory $dir *]
    
    # Iterate through each file or directory
    foreach file $files {
        if {[file isdirectory $file]} {
            # If the current item is a directory, call this function recursively
            add_ip $file
        } elseif {[file isfile $file]} {
            # If the current item is a file, check if it's an XCI file
            if {[string match "*.xci" [file tail $file]]} {
                # Add the XCI file to the Vivado project
                read_ip [file normalize $file]
            }
        }
    }
}

# get HDL source files from a directory
proc add_src_files {dir} {
    # Get a list of .vhd and .vhdl files in the specified directory
    set file_list_vhd [glob -nocomplain -type f -directory $dir *.vhd]
    set file_list_vhdl [glob -nocomplain -type f -directory $dir *.vhdl]
    
    # Combine the lists of files
    set file_list [concat $file_list_vhd $file_list_vhdl]
    
    # Iterate over each file in the directory
    foreach file $file_list {
        # Add each file to the project
        add_files $file
    }
}

# get simulation source files from a directory
proc add_sim_files {dir} {
    # Get a list of .vhd and .vhdl files in the specified directory
    set file_list_vhd [glob -nocomplain -type f -directory $dir *.vhd]
    set file_list_vhdl [glob -nocomplain -type f -directory $dir *.vhdl]
    
    # Combine the lists of files
    set file_list [concat $file_list_vhd $file_list_vhdl]
    
    # Iterate over each file in the directory
    foreach file $file_list {
        # Add each file to the project
        add_files -fileset sim_1 $file
    }
}

# get constrain files from a directory
proc add_constrs_files {dir} {
    # Get a list of XDC files in the specified directory
    set file_list [glob -nocomplain -type f -directory $dir *.xdc]
    
    # Iterate over each file in the directory
    foreach file $file_list {
        # Add each file to the project
        add_files -fileset constrs_1 $file
    }
}

# add all IP cores
add_ip "../constraint_zcu"
# add all HDL source files
add_src_files "../../src/hdl/fpga_common"
add_src_files "../../src/hdl/fpga_zcu102"
# add all simulation files
add_sim_files "../../src/hdl/testbench"
add_sim_files "../../src/hdl/std_developerskit"
# add all constraint files needed by the board
add_constrs_files "../constraint_zcu"

generate_target all [get_ips -filter {SCOPE !~ "*.bd"}]

# Run the synthesis and generate the IP output products
launch_runs synth_1

# Wait for the synthesis to complete
wait_on_run synth_1

# Generate the simulation models
proc recursive_glob {dir} {
    set files [glob -nocomplain -type f -directory $dir *_sim_netlist.vhdl]
    foreach subdir [glob -nocomplain -type d -directory $dir *] {
        lappend files {*}[recursive_glob $subdir]
    }
    return $files
}

set src_dir ../../$proj_dir/ip/
set files [recursive_glob $src_dir]

foreach file $files {
    file copy -force $file ../sim_zcu
}

exit
