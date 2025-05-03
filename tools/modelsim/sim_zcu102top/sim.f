// --------------------------------------------------------------------
// Essential simulation arguments
// --------------------------------------------------------------------
-work work
// supporess certain warnings... kindaly review
-suppress vcom-1135
-coversub
// generate a log file
-l vcom.log
-source
// --------------------------------------------------------------------
// Files to compile
// --------------------------------------------------------------------
// compile Xilinx IPs
../../../qlaser_zcu102.gen/sources_1/ip/bram_pulse_definition/bram_pulse_definition_sim_netlist.vhdl 
../../../qlaser_zcu102.gen/sources_1/ip/bram_waveform/bram_waveform_sim_netlist.vhdl 
../../../qlaser_zcu102.gen/sources_1/ip/axis_data_fifo_32Kx16b/axis_data_fifo_32Kx16b_sim_netlist.vhdl

// std developerskit
../../../src/hdl/std_developerskit/iopakp.vhd
../../../src/hdl/std_developerskit/iopakb.vhd

// compile pachages
// idk which ones from fpga_zcu102 are needed ... so I'll just compile all of them
../../../src/hdl/fpga_zcu102/*pkg.vhd
../../../src/hdl/fpga_zcu102/qlaser_version_pkg_zcu.vhd

../../../src/hdl/testbench/qlaser_addr_zcu102_pkg.vhdl
../../../src/hdl/testbench/tb_zcu102_ps_cpu_pkg.vhdl
// ../../../src/hdl/testbench/qlaser_addr_zcu102_pkg.vhdl
// ../../../src/hdl/testbench/qlaser_pulse_channel_tasks.vhdl


// // compile designs
../../../src/hdl/fpga_zcu102/qlaser_dacs_pulse_channel.vhdl
../../../src/hdl/fpga_zcu102/qlaser_dacs_pulse_zcu.vhd
../../../src/hdl/fpga_zcu102/qlaser_cif.vhd
../../../src/hdl/fpga_zcu102/qlaser_spi.vhd
../../../src/hdl/fpga_zcu102/qlaser_dacs_dc_zcu.vhd

// ../../../src/hdl/fpga_zcu102/qlaser_pmod_pulse.vhd
// ../../../src/hdl/fpga_zcu102/pulse2pmod.vhd
../../../src/hdl/fpga_zcu102/blink.vhd
../../../src/hdl/fpga_zcu102/qlaser_misc.vhd

../../../src/hdl/fpga_zcu102/qlaser_axis_cpu_sel.vhdl
../../../src/hdl/fpga_zcu102/qlaser_2pmods_pulse.vhd


// Modify below line to for specific test case
../../../src/hdl/testbench/ps1_wrapper_zcu102_sim.vhdl
// ../../../src/hdl/testbench/tlv_cherros.vhdl

../../../src/hdl/fpga_zcu102/qlaser_top_zcu.vhd


// compile the DAC
../../../src/hdl/testbench/model_ad5628.vhdl

// ../../../src/hdl/testbench/tb_cpubus_dacs_pulse_channel.vhdl
../../../src/hdl/testbench/tb_qlaser_top_zcu.vhd
