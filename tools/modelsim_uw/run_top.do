vlib work

vcom ../sim_zcu/bram_pulseposition_sim_netlist.vhdl
vcom ../sim_zcu/bram_waveform_sim_netlist.vhdl
vcom ../sim_zcu/fifo_data_to_stream_sim_netlist.vhdl
vcom ../sim_zcu/*.vhdl
vcom ../../src/hdl/fpga_zcu102/*pkg.vhd
vcom ../../src/hdl/std_developerskit/iopakp.vhd
vcom ../../src/hdl/std_developerskit/iopakb.vhd
vcom ../../src/hdl/fpga_zcu102/qlaser_dacs_pulse_channel.vhdl
vcom ../../src/hdl/fpga_zcu102/qlaser_dacs_pulse_zcu.vhd
vcom ../../src/hdl/fpga_zcu102/qlaser_cif.vhd
vcom ../../src/hdl/fpga_zcu102/qlaser_spi.vhd
vcom ../../src/hdl/fpga_zcu102/qlaser_dacs_dc_zcu.vhd

vcom ../../src/hdl/testbench/axis_data_fifo_32Kx16b_sim_netlist.vhdl
vcom ../../src/hdl/fpga_zcu102/qlaser_pmod_pulse.vhd
vcom ../../src/hdl/fpga_zcu102/pulse2pmod.vhd
vcom ../../src/hdl/fpga_zcu102/qlaser_version_pkg_zcu.vhd
vcom ../../src/hdl/fpga_zcu102/blink.vhd
vcom ../../src/hdl/fpga_zcu102/qlaser_misc.vhd

vcom ../../src/hdl/testbench/tb_zcu102_ps_cpu_pkg.vhdl
vcom ../../src/hdl/testbench/qlaser_addr_zcu102_pkg.vhdl
vcom ../../src/hdl/testbench/ps1_wrapper_zcu102_sim.vhdl
vcom ../../src/hdl/fpga_zcu102/qlaser_top_zcu.vhd


vcom ../../src/hdl/testbench/model_ad5628.vhdl

vcom ../../src/hdl/testbench/tb_cpubus_dacs_pulse_channel.vhdl
vcom ../../src/hdl/testbench/tb_qlaser_top_zcu.vhd


vsim -voptargs="+acc" -lib work tb_qlaser_top

do pp_top_wavetables.do

view wave
view structure
view signals

run -all

# End
