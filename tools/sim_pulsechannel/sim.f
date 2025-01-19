// --------------------------------------------------------------------
// Essential simulation arguments
// --------------------------------------------------------------------
// supporess certain warnings
-suppress vcom-1135
-coversub
// generate a log file
-l vcom.log
-source
// --------------------------------------------------------------------
// Files to compile
// --------------------------------------------------------------------
// compile Xilinx IPs
../sim_zcu/bram_pulseposition_sim_netlist.vhdl 
../sim_zcu/bram_pulse_definition_sim_netlist.vhdl 
../sim_zcu/bram_waveform_sim_netlist.vhdl 

// compile pachages
../../src/hdl/fpga_zcu102/qlaser_dacs_pulse_channel_pkg.vhd 
../../src/hdl/fpga_zcu102/qlaser_dac_dc_pkg.vhd 
../../src/hdl/fpga_zcu102/qlaser_pkg.vhd 
../../src/hdl/testbench/qlaser_pulse_channel_tasks.vhdl

// compile designs
../../src/hdl/fpga_zcu102/qlaser_dacs_pulse_channel.vhdl 
../../src/hdl/fpga_zcu102/qlaser_dacs_pulse_zcu.vhd

// // finally compile the testbench
../../src/hdl/testbench/tb_pulse_channel_random_polynomials.vhdl 
../../src/hdl/testbench/tb_cpubus_dacs_pulse_channel.vhdl 
