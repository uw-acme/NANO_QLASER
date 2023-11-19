# NANO_QLASER

FPGA controller for trapped ion quantum device experiments.

## Build

To build the project, make sure command `vivado` is valid in your desired terminals run the following commands:

```bash
vivado -mode tcl -source build.tcl
```
in the `tools/xilinx` directory. After the build is finished, the project will be in the `prj` directory.

### Modelsim Simulation

To run any testbenches in Modelsim, make sure command `vsim` is valid in your desired terminals, go to the `tools/modelsim_uw` directory and run the following commands:

```bash
vsim -do <NAME_OF_YOUR_DO_FILE>.do
```
change "NAME_OF_YOUR_DO_FILE" to the name of the do file you want to run.

## Versions:

Initial design used a Digilent Eclypse FPGA board with two Digilent DA4 PMOD boards to provide a total of 16 'DC' outputs. The DA4 boards have a SPI interface and serial messages can be sent from a PC over a USB-to-serial cable to set the 12-bit DAC output levels.

The second design adds the capability of generating pulsed outputs. This design could be targeted at the Eclypse board, or the much larger ZCU102 board.
This design will add up to 16 'AC' outputs that switch between 0 and 3.3V at time steps with a 10 nsec resolution. Each output is driven by a RAM table which specifies an edge time and a level. A trigger starts a common counter which is used by each channel to compare with the RAM table to set its output. 

The third design will be similar to the second, except that the pulses will have 16-bit 'analog' levels instead of just 0 and 1. This will require the ZCU102 board together with 1 or 2 Abaco FMC216 high-speed DAC boards. Each board has 16 16-bit outputs that can be updated at up to 300Msps. The interface to this board will require JESD204B serial interfaces.

## Tasks.
[] Become familiar with the first, Eclypse, design.
   
[x] Migrate design to ZCU102 board. This will require modifying the pinout in the constraint file.
    
[] Create new Vivado 2022.1 project for ZCU102 that uses the FPGAs ARM CPU to read the board pushbuttons and control the board LEDs. This will help understanding of the Vivado and Vitis tool flow. ZCU102 board definition files are in a Xilinx repo on Github called 'XilinxBoardStore'.
   
[] Migrate the second design, with pulse outputs, to the ZCU102 board. Connect RAM tables to the CPU. Write a simple program to download RAM tables or generate test tables internally.

[] Read the JESD204B documentation and add JESD IP blocks to the CPU. Create pinout constraints for the JESD interface to the Abaco board(s). Write HDL blocks to generate AXI-stream test data to the JESD interfaces. Add CPU code to set up and control the JESD blocks. Documentation is in the repo at /documents/Hardware and /documents/JESD 