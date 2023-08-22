# NANO_QLASER

FPGA controller for trapped ion quantum device experiments.

Initial design used a Digilent Eclypse FPGA board with two Digilent DA4 PMOD boards to provide a total of 16 'DC' outputs. The DA4 boards have a SPI interface and serial messages can be sent from a PC over a USB-to-serial cable to set the 12-bit DAC output levels.

The second design adds the capability of generating pulsed outputs. This design could be targeted at the Eclypse board, or the much larger ZCU102 board.
This design will add up to 16 'AC' outputs that switch between 0 and 3.3V at time steps with a 10 nsec resolution. Each output is driven by a RAM table which specifies an edge time and a level. A trigger starts a common counter which is used by each channel to compare with the RAM table to set its output. 

The third design will be similar to the second, except that the pulses will have 16-bit 'analog' levels instead of just 0 and 1. This will require the ZCU102 board together with 1 or 2 Abaco FMC216 high-speed DAC boards. Each board has 16 16-bit outputs that can be updated at up to 300Msps. The interface to this board will require JESD204B serial interfaces.

Tasks.
1. Become familiar with the first, Eclypse, design.
   
2. Migrate design to ZCU102 board. This will require modifying the pinout in the constraint file.
    
3. Create new Vivado 2022.1 project for ZCU102 that uses the FPGAs ARM CPU to read the board pushbuttons and control the board LEDs. This will help understanding of the Vivado and Vitis tool flow.
   
5. Migrate the second design, with pulse outputs, to the ZCU102 board. Connect RAM tables to the CPU. Write a simple program to download RAM tables or generate test tables internally.

6. Read the JESD204B documentation and add JESD IP blocks to the CPU. Create pinout constraints for the JESD interface to the Abaco board(s). Write HDL blocks to generate AXI-stream test data to the JESD interfaces. Add CPU code to set up and control the JESD blocks.  
