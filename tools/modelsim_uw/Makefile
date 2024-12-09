# Define the seed to run the simulation with
TOP = tb_qlaser_top
# TOP = qlaser_top


all: compile sim

compile:
	@rm -rf work
	vlib work
	vcom -f sim.f

sim: 
	vsim -c -do "vsim -voptargs="+acc" -lib work $(TOP); log * -r; run -all; quit -f" -l vsim.log

clean-runs:
	rm -f *wlf* errors.txt debug.txt transcript *.wlf *.log

clean-builds: clean-runs
	rm -rf work

debug:
	vsim -view vsim.wlf

clean: clean-runs clean-builds
