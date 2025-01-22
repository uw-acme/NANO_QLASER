## Define the seed to run the simulation with
TOP = tb_qlaser_top
# TOP = qlaser_top

## Simulation constants
# Length of one sequence
SEQ_LENGTH = 1872
# Duration of the simulation in clock cycles. 131072 for ILA depth
SIM_DURATION = 131072

all: compile sim

compile:
	@rm -rf work
	vlib work
	vcom -f sim.f

sim: 
	vsim -c -do "vsim -voptargs="+acc" -lib work $(TOP) -g SEQ_LENGTH=$(SEQ_LENGTH) -g SIM_DURATION=$(SIM_DURATION); log * -r; run -all; quit -f" -l vsim.log

clean-runs:
	rm -f *wlf* errors.txt debug.txt transcript *.wlf *.log

clean-builds: clean-runs
	rm -rf work

debug:
	vsim -view vsim.wlf

clean: clean-runs clean-builds
