create_project zcu_pulse_channel ../../prj -force

set_property board_part xilinx.com:zcu102:part0:3.4 [current_project]

add_files {..\..\src\eyhc\qlaser_dacs_pulse_channel.vhd}
add_files {..\..\src\eyhc\qlaser_dac_dc_pkg.vhd}
add_files {..\..\src\eyhc\qlaser_pkg.vhd}
import_ip {..\xilinx-zcu\bram_pulseposition.xci}
import_ip {..\xilinx-zcu\bram_waveform.xci}
import_ip {..\xilinx-zcu\fifo_data_to_stream.xci}

upgrade_ip [get_ips -filter {SCOPE !~ "*.bd"}]
generate_target all [get_ips -filter {SCOPE !~ "*.bd"}]
exit
