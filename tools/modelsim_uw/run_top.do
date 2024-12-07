onerror {exit}

vlib work

vcom -f sim.f

vsim -voptargs="+acc" -lib work qlaser_top

# do pp_top_wavetables.do

log * -r

run -all

# End
