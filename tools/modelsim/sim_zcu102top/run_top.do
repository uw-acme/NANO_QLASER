onerror {exit}

# vlib work

# vcom -f sim.f

vsim -voptargs="+acc" -lib work tb_qlaser_top

do pp_top_wavetables.do

log * -r

run -all

# exit
# End
