# NANO_QLASER

FPGA controller for trapped ion quantum device experiments.

Initial design used a Digilent Eclypse FPGA board with two Digilent DA4 PMOD boards to provide a total of 16 'DC' outputs. The DA4 boards have a SPI interface and serial messages can be sent from a PC over a USB-to-serial cable to set the 12-bit DAC output levels.

The second design adds the capability of generating pulsed outputs. This design could be targeted at the Eclypse board, or the much larger ZCU102 board.
This design will add up to 16 'AC' outputs that switch between 0 and 3.3V at time steps with a 10 nsec resolution. Each output is driven by a RAM table which specifies an edge time and a level. A trigger starts a common counter which is used by each channel to compare with the RAM table to set its output. 

The third design will be similar to the second, except that the pulses will have 16-bit 'analog' levels instead of just 0 and 1. This will require the ZCU102 board together with 1 or 2 Abaco FMC216 high-speed DAC boards. Each board has 16 16-bit outputs that can be updated at up to 300Msps. The interface to this board will require JESD204B serial interfaces.

## Versions:

Initial design used a Digilent Eclypse FPGA board with two Digilent DA4 PMOD boards to provide a total of 16 'DC' outputs. The DA4 boards have a SPI interface and serial messages can be sent from a PC over a USB-to-serial cable to set the 12-bit DAC output levels.

The second design adds the capability of generating pulsed outputs. This design could be targeted at the Eclypse board, or the much larger ZCU102 board.
This design will add up to 16 'AC' outputs that switch between 0 and 3.3V at time steps with a 10 nsec resolution. Each output is driven by a RAM table which specifies an edge time and a level. A trigger starts a common counter which is used by each channel to compare with the RAM table to set its output. 

The third design will be similar to the second, except that the pulses will have 16-bit 'analog' levels instead of just 0 and 1. This will require the ZCU102 board together with 1 or 2 Abaco FMC216 high-speed DAC boards. Each board has 16 16-bit outputs that can be updated at up to 300Msps. The interface to this board will require JESD204B serial interfaces.

    1.	32'h3AC00008 – take_6_vhdl_controlling block design 2 removed leds from block design connected leds in qlaser_top removed all pmod stuff
    2.	32'h3AC00009 - take_7 removed leds from block design connected leds in qlaser_top added axi_cpu block, adding pmod connection

## Tasks.
- [ ] Become familiar with the first, Eclypse, design.
   
- [x] Migrate design to ZCU102 board. This will require modifying the pinout in the constraint file.
    
- [x] Create new Vivado 2022.1 project for ZCU102 that uses the FPGAs ARM CPU to read the board pushbuttons and control the board LEDs. This will help understanding of the Vivado and Vitis tool flow. ZCU102 board definition files are in a Xilinx repo on Github called 'XilinxBoardStore'.
   
- [x] Migrate the second design, with pulse outputs, to the ZCU102 board. Connect RAM tables to the CPU. Write a simple program to download RAM tables or generate test tables internally.

- [ ] Read the JESD204B documentation and add JESD IP blocks to the CPU. Create pinout constraints for the JESD interface to the Abaco board(s). Write HDL blocks to generate AXI-stream test data to the JESD interfaces. Add CPU code to set up and control the JESD blocks. Documentation is in the repo at /documents/Hardware and /documents/JESD 

## Build, Compile, and Develop

#### Build Vivado project:
Make sure you have Vivado 2022.1 installed and `vivado` is in the `PATH`. You can build the Vivado project using the following command from `tools\xilinx` directory:
```bash
vivado -mode batch -source build_vivado.tcl
```
Or you can open the Vivado GUI and run the script from there. This will build an XSA file in `prj` directory for building the software application with Vitis.
#### Build Vitis project:
Make sure you have Vitis 2022.1 installed and `xsct` is in the `PATH`. You can build the Vitis project using the following command from `tools\xilinx` directory:
```bash
xsct -eval "source vitis_setup.tcl"
```
Or you can open the Vitis GUI and run the script from there. Note Vitis is badly optimized for command line use, so it is better to use the GUI for Vitis.
#### Simulate the design:
[Get Modelsim](https://class.ece.uw.edu/271/hauck2/software/ModelSimSetup-17.0.0.595-windows.exe) and install it. Make sure you have it in your `PATH`. There are two parts of the simulation currently, both are in the `tools\modelsim` directory.

##### Top level simulation:
This simulates the top level of the design, including the CPU and the peripherals. It is in `tools\modelsim\sim_zcu102top` directory. You can compile with `make compile` and run simulation with ` make sim`. You may open the simulated waveform in Modelsim GUI to see the results with `make debug`. Finally, you can clean the simulation with `make clean`.

##### Pulse Channel simulation:
This simulates the pulse channels, including the RAM tables and the pulse generation logic. It is in `tools\modelsim\sim_pulse_channels` directory. All make commands are the same as above, just run them in the `sim_pulse_channels` directory. There is optional argument `SEED=` to set the random seed for the simulation. You can also use the `autorun.py` script to run a series of simulations with different seeds. Just run `python autorun.py` in the `sim_pulse_channels` directory.