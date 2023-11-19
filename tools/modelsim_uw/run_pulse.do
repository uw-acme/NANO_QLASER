vlib work

vcom ../sim_zcu/bram_pulseposition_sim_netlist.vhdl
vcom ../sim_zcu/bram_waveform_sim_netlist.vhdl
vcom ../sim_zcu/fifo_data_to_stream_sim_netlist.vhdl
vcom ../../src/hdl/fpga_zcu102/*pkg.vhd
vcom ../../src/hdl/std_developerskit/iopakp.vhd
vcom ../../src/hdl/std_developerskit/iopakb.vhd
vcom ../../src/hdl/fpga_zcu102/qlaser_dacs_pulse_channel.vhdl
vcom ../../src/hdl/testbench/tb_cpubus_dacs_pulse_channel.vhdl

vsim -voptargs="+acc" -lib work tb_cpubus_dacs_pulse_channel

do pulse.do

view wave
view structure
view signals

run -all

# End
