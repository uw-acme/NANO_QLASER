# do compile.do
onerror {exit}

# compile the testbench and the design one more time
vcom ../../src/hdl/fpga_zcu102/qlaser_dacs_pulse_channel.vhdl 
vcom ../../src/hdl/testbench/tb_cpubus_dacs_pulse_channel.vhdl 

vsim -voptargs="+acc" -lib work tb_cpubus_dacs_pulse_channel -g DEGREES=1 -g SEQ_LENGTH=1000

catch {do waves_do/sim2.do}

log * -r

run -all

exit
# End
