# Scipt to setup the PS firmware development environment
# if the program stucks, please exit/kill the process. Then run this script in the the Vitis GUI
# make sure you have the right file paths and names before running this script
set ws ../../qlaser_ws
set xsa ../../prj/qlaser_top.xsa
set src_path ../../src/c

# Set the application name and main arc
set app_name_apu app_qlaser
# Set the main file name
set main_arc helloworld.c
# Set the domain name
set domain_name_apu ql_standalone
# set the platform name
set plat_name pl_qlaser

# DO Not modify below this line unless you know what you are doing
catch {setws [file normalize $ws]}
app create -name  $app_name_apu -hw [file normalize $xsa] -os standalone -proc psu_cortexa53_0 -template {Hello World}
app config -name $app_name_apu -add include-path [file normalize ${ws}/${app_name_apu}/src]

importsource -name $app_name_apu -path [file normalize ${src_path}/qlaser_fpga.c] -soft-link
importsource -name $app_name_apu -path [file normalize ${src_path}/qlaser_fpga.h] -soft-link

file delete -force [file normalize ${ws}/${app_name_apu}/src/helloworld.c]
importsource -name $app_name_apu -path [file normalize ${src_path}/${main_arc}] -soft-link

catch {sysproj build ${app_name_apu}_system}

exit