# Scipt to setup the PS firmware development environment
# variables definition
set ws ../../qlaser_ws
set plat_name pl_qlaser
set xsa ../../prj/qlaser_top.xsa
set domain_name_apu ql_standalone
set app_name_apu app_qlaser
set src_path ../../src/c
# modify below line for main application source file
set main_arc helloworld.c

# DO Not modify below this line unless you know what you are doing
setws [file normalize $ws]
app create -name  $app_name_apu -hw [file normalize $xsa] -os standalone -proc psu_cortexa53_0 -template {Hello World}
app config -name $app_name_apu -add include-path [file normalize ${ws}/${app_name_apu}/src]

importsource -name $app_name_apu -path [file normalize ${src_path}/qlaser_fpga.c] -soft-link
importsource -name $app_name_apu -path [file normalize ${src_path}/qlaser_fpga.h] -soft-link

file delete -force [file normalize ${ws}/${app_name_apu}/src/helloworld.c]
importsource -name $app_name_apu -path [file normalize ${src_path}/${main_arc}] -soft-link

catch {sysproj build ${app_name_apu}_system}

exit