# NANO_QLASER

FPGA controller for trapped ion quantum device experiments. Detailed diagram [here](https://github.com/uw-acme/NANO_QLASER/blob/eric_zcu_102/documents/Project-overview.pdf)

Use this branch to generate a bitfile for vitis. 

Note that commit 6e0c007 https://github.com/uw-acme/NANO_QLASER/commit/6e0c0073caa1b71f062d0908fe019ad17d27f89e changed ps_enable_dacs_pulse to enable whenever the misc_trigger is high, so you'll need to trigger twice - first trigger enables, second actually triggers. This should be fixed, I did not have time for this. 

If vitis is cokmplaining about file not found with custom ip, set the following makefiles to be 
a.	/{vitis platform project name}/hw/drivers/axi_cpuint_v1_0/src/Makefile
b.	/{vitis platform project name}/psu_cortexa53_0/standalone_domain/bsp/psu_cortexa53_0/libsrc/axi_cpuint_v1_0/src/Makefile
c.	/{vitis platform project name}/zynqmp_fsbl/zynqmp_fsbl_bsp/psu_cortexa53_0/libsrc/axi_cpuint_v1_0/src/Makefile
d.	/{vitis platform project name}/zynqmp_pmufw/zynqmp_pmufw_bsp/psu_pmu_0/libsrc/axi_cpuint_v1_0/src/Makefile

## Build
1.	close, checkout eric_zcu_102, `cd tools/xilinx && vivado -mode tcl -source build_zcu.tcl`. The Vivado project will be in the `prj` directory.
2.	Create block diagram, add zynq block, run connection automation, add gpio, set to leds and switches, run connection automations, in sources right click and add wrapper to design, instantiate design inside of qlaser_top. 
    a.	Add ip source as D:\Research\AXI_IF_CPU_IP\axi_cpuint_1.0
    b.	Add axi_cpuint to block diagram, run connection automation, on unconnected ports right click and do connect to external. Rename all external ports to not have _0 ending. 
3.	Manually add as src (Should have been fix/automated 11/9/24)
    a.	<path_to_this_repo>\src\hdl\fpga_zcu102\pulse2pmod.vhd
    b.	<path_to_this_repo>\src\hdl\fpga_zcu102\qlaser_cif.vhd
    c.	<path_to_this_repo>\tools\xilinx\axis_data_fifo_32Kx16b
    d.	<path_to_this_repo>\src\hdl\fpga_zcu102\qlaser_pmod_pulse.vhd
    e.	<path_to_this_repo>\tools\constraint_zcu\bram_pulse_definition\bram_pulse_definition.xci"
4.	In Vivado, generate bitstream, file export export hardware with bitstream, open vitis. Then open Vitis and create new platform project from the generated xsa, new application project off of that platform, build and run as hardware
    a.	Write bitstream error – check that no double use of ports in DRC output (delete p_leds_0 through 5)
5.	If Vitis doesn’t recognize .h files (file not found) with custom ip (Should have been fix 11/9/24)
    a.	<path_to_your_vitis_project>/hw/drivers/axi_cpuint_v1_0/src/Makefile
    b.	<path_to_your_vitis_project>/psu_cortexa53_0/standalone_domain/bsp/psu_cortexa53_0/libsrc/axi_cpuint_v1_0/src/Makefile
    c.	<path_to_your_vitis_project>/zynqmp_fsbl/zynqmp_fsbl_bsp/psu_cortexa53_0/libsrc/axi_cpuint_v1_0/src/Makefile
    d.	<path_to_your_vitis_project>/zynqmp_pmufw/zynqmp_pmufw_bsp/psu_pmu_0/libsrc/axi_cpuint_v1_0/src/Makefile
    e.	All set to MakefileHERE below
    f.	https://support.xilinx.com/s/question/0D52E00006hpOx5SAE/drivers-and-makefiles-problems-in-vitis-20202?language=en_US set LIBSOURCES=$(wildcard *.c)
    g.	https://support.xilinx.com/s/article/75527?language=en_US official response
    h.	https://support.xilinx.com/s/question/0D52E00006hpOx5SAE/drivers-and-makefiles-problems-in-vitis-20202?language=en_US vras top answer used as makefile template, changed libsources as above
6.	Use tera term to read board stuff 
    a.	Setup, serial port, port whichever one in device_manager is interface 0 under ports (currently com7), speed 115200, data 8 bit, parity none, stop bits 1 bit, flow control none, 0 0 transmit delay
7.	Load onto sd card 
    a.	Create boot.bin:
    b.	Boot image for SD card – vitis, Xilinx menu, create boot image 
    c.	change to zynq mp 
    d.	Output format BIN
    e.	First add Fsbl.elf from platform as bootloader 
    f.	Add application_empty\_ide\bitstream\design_1_wrapper5_01.bit datafile 
    g.	Add application_empty\Debug\application_empty.elf datafile
    h.	Versioning: 
        i.	<path_to_this_repo>/src/hdl/fpga_zcu102/qlaser_version_pkg_zcu.vhd – has version number which can be read by CPU
        ii.	<path_to_this_repo>/tools/constraint_zcu/set_usercode_zcu.xdc – has version number set in bitfile.
### MakefileHERE
```makefile
COMPILER=
ARCHIVER=
CP=cp
COMPILER_FLAGS=
EXTRA_COMPILER_FLAGS=
LIB=libxil.a

RELEASEDIR=../../../lib
INCLUDEDIR=../../../include
INCLUDES=-I./. -I${INCLUDEDIR}

INCLUDEFILES=*.h
LIBSOURCES=$(wildcard *.c)
OBJECTS = $(addsuffix .o, $(basename $(wildcard *.c)))
ASSEMBLY_OBJECTS = $(addsuffix .o, $(basename $(wildcard *.S)))

libs:
	echo "axi_cpuint_v1_0..."
	$(COMPILER) $(COMPILER_FLAGS) $(EXTRA_COMPILER_FLAGS) $(INCLUDES) $(LIBSOURCES)
	$(ARCHIVER) -r ${RELEASEDIR}/${LIB} ${OBJECTS} ${ASSEMBLY_OBJECTS}
	make clean

include:
	${CP} $(INCLUDEFILES) $(INCLUDEDIR)

clean:
	rm -rf ${OBJECTS} ${ASSEMBLY_OBJECTS}
```

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

    1.	32'h3AC00008 – take_6_vhdl_controlling block design 2 removed leds from block design connected leds in qlaser_top removed all pmod stuff
    2.	32'h3AC00009 - take_7 removed leds from block design connected leds in qlaser_top added axi_cpu block, adding pmod connection

## Tasks.
[] Become familiar with the first, Eclypse, design.
   
[x] Migrate design to ZCU102 board. This will require modifying the pinout in the constraint file.
    
[] Create new Vivado 2022.1 project for ZCU102 that uses the FPGAs ARM CPU to read the board pushbuttons and control the board LEDs. This will help understanding of the Vivado and Vitis tool flow. ZCU102 board definition files are in a Xilinx repo on Github called 'XilinxBoardStore'.
   
[] Migrate the second design, with pulse outputs, to the ZCU102 board. Connect RAM tables to the CPU. Write a simple program to download RAM tables or generate test tables internally.

[] Read the JESD204B documentation and add JESD IP blocks to the CPU. Create pinout constraints for the JESD interface to the Abaco board(s). Write HDL blocks to generate AXI-stream test data to the JESD interfaces. Add CPU code to set up and control the JESD blocks. Documentation is in the repo at /documents/Hardware and /documents/JESD 
