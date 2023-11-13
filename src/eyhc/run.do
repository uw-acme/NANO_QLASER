vlib work

vcom *.vhdl
vcom *pkg.vhd
vcom iopakp.vhd
vcom iopakb.vhd
vcom *.vhd

vsim -voptargs="+acc" -lib work tb_cpubus_dacs_pulse_channel

do wave.do

view wave
view structure
view signals

run -all

# End
