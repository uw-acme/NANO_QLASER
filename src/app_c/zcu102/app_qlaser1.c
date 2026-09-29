//----------------------------------------------------------------------
// app_qlaser1.c — ZCU102 + FMC216 bring-up
//
// Operating point (UART 'B', Distribution Mode):
//   Fin = 200 MHz on CLKin1  ?  DACCLK = 200 MHz (bypass)
//   DCLKout10 = Fin/2 = 100 MHz GT refclk
//   SYSREF = Fin/32 = 6.25 MHz = LMFC
//   JESD204B: L=2, M=4, F=4, S=1, K=16, interp=2x, f_DATA=100 MSPS, 4.0 Gbps/lane
//
// UART 'F'/'X' still program the Dual-Loop table (100 MHz DACCLK, 3.125 MHz SYSREF).
// DAC + JESD software is sized for 'B', not for 'F'/'X'.
//----------------------------------------------------------------------
#include "xparameters.h"
#include <stdio.h>
#include <stdlib.h>
#include "sleep.h"
#include "stdbool.h"
#include "platform.h"
#include "xil_printf.h"
#include "xil_io.h"
#include "xuartps_hw.h"

#include "xiicps.h"
#define IIC_0_DEVICE_ID     XPAR_XIICPS_0_DEVICE_ID
#define IIC_1_DEVICE_ID     XPAR_XIICPS_1_DEVICE_ID


#include "qlaser_fpga.h"
#include "jesd204c_ip.h"
#include "regmap_dac39j84.h"
#include "regmap_lmk04828_pll.h"

//#include "qlaser_fpga_zc102.h"          // Constant definitions. Register addresses etc.

// Memory size on CPU bus
#define SIZERAM_PULSE_WAVE 2048         // Each memory address contains two waveform points
#define SIZERAM_PULSE_DEFN 1024         // Each entry consists of 4 32-bit words
#define PDEF_NUM_ENTRY     (SIZERAM_PULSE_DEFN/4)

#define ADR_BASE_GPIO_INT  XPAR_AXI_GPIO_INT_BASEADDR
#define ADR_GPIO_OUT       (ADR_BASE_GPIO_INT + 0x0)
#define ADR_GPIO_IN        (ADR_BASE_GPIO_INT + 0x8)


#define BIT_GPIO_PULSE_TRIGGER 	0
#define BIT_GPIO_PULSE_ENABLE 	1	// Enable the global pulse generator

// LED and Button
#define ADR_BASE_GPIO_LED_BTN   XPAR_AXI_GPIO_LED_BTN_BASEADDR
#define ADR_GPIO_LED       (ADR_BASE_GPIO_LED_BTN + 0x0)
#define ADR_GPIO_BTN       (ADR_BASE_GPIO_LED_BTN + 0x8)
//#define XGPIO_DATA_OFFSET     0x0   /**< Data register for 1st channel */
//#define XGPIO_TRI_OFFSET      0x4   /**< I/O direction reg for 1st channel */
//#define XGPIO_DATA2_OFFSET    0x8   /**< Data register for 2nd channel */
//#define XGPIO_TRI2_OFFSET     0xC   /**< I/O direction reg for 2nd channel */

// Addresses reached through CPUINT
#define ADR_BASE_CPUINT    XPAR_AXI_CPUINT_S00_AXI_BASEADDR    // from xparameters.h

// Main sub-block base addresses. ps_addr (17:16) are used to make four block selects.
#define ADR_BASE_DACS_DC    (ADR_BASE_CPUINT + 0x00000)
#define ADR_BASE_DACS_AC    (ADR_BASE_CPUINT + 0x10000)
#define ADR_BASE_MISC       (ADR_BASE_CPUINT + 0x20000)
#define ADR_BASE_SWITCH     (ADR_BASE_CPUINT + 0x30000)
//#define ADR_BASE_P2PMOD     (ADR_BASE_CPUINT + 0x30000)

// MISC block registers (32-bit word addresses)
#define ADR_MISC_VERSION    (ADR_BASE_MISC + 4*0x0000)
#define ADR_MISC_LEDS       (ADR_BASE_MISC + 4*0x0001)     // '1' sets LED on if corresponding bit in reg_leds_en is also set
#define ADR_MISC_LEDS_EN    (ADR_BASE_MISC + 4*0x0002)     // '1' allows CPU control of LEDs. '0' allows FPGA logic
#define ADR_MISC_DEBUG_CTRL (ADR_BASE_MISC + 4*0x0003)     // Select debug output from top level to pins
#define ADR_MISC_TRIGGER    (ADR_BASE_MISC + 4*0x0004)     // Generate trigger

// DAC DC block registers (32-bit word addresses)
#define C_ADDR_SPI0         (ADR_BASE_DACS_DC + 4*0x00000)
#define C_ADDR_SPI1         (ADR_BASE_DACS_DC + 4*0x00001)
#define C_ADDR_SPI2         (ADR_BASE_DACS_DC + 4*0x00002)
#define C_ADDR_SPI3         (ADR_BASE_DACS_DC + 4*0x00003)
#define C_ADDR_SPI_ALL      (ADR_BASE_DACS_DC + 4*0x00004)
#define C_ADDR_INTERNAL_REF (ADR_BASE_DACS_DC + 4*0x00005)
#define C_ADDR_POWER_ON     (ADR_BASE_DACS_DC + 4*0x00006)

// DAC DC block commands (sent to DAC)
#define C_CMD_DAC_DC_WR            0x3 
#define C_CMD_DAC_DC_INTERNAL_REF  0x8 
#define C_CMD_DAC_DC_POWER         0x4 

// DAC AC (Pulse) block sub-blocks.  
// Block contains 32 channels. Channels are accessed by first setting bit to '1' in the channel select reg. REG_CH_SEL)
#define ADR_BASE_PULSE_REGS     (ADR_BASE_DACS_AC + 0x4000)
#define ADR_PULSE_REG_SEQ_LEN   (ADR_BASE_PULSE_REGS + 4*0x00)
#define ADR_PULSE_REG_CHSEL     (ADR_BASE_PULSE_REGS + 4*0x01)    // Channel select for CPU writes. One bit per channel. Can have multiple bits set
#define ADR_PULSE_REG_CH_EN     (ADR_BASE_PULSE_REGS + 4*0x02)    // Channel enables. One bit per channel.
#define ADR_PULSE_REG_GSTATUS   (ADR_BASE_PULSE_REGS + 4*0x03)    // Global status bit-0 = busy, '1' if any ch running, bit-4 error set if any JESD channel is not sync'ed
#define ADR_PULSE_REG_CHSTATUS  (ADR_BASE_PULSE_REGS + 4*0x04)    // Channel JESD status. One bit per channel. Set if JESD not sync'ed.
#define ADR_PULSE_REG_TIMER     (ADR_BASE_PULSE_REGS + 4*0x05)    // Current timer count since trigger
// OLD ??
//#define ADR_PULSE_REG_GSTATUS   (ADR_BASE_PULSE_REGS + 4*0x02)    // Global status bit-0 = busy, '1' if any ch running, bit-4 error set if any JESD channel is not sync'ed
//#define ADR_PULSE_REG_CHSTATUS  (ADR_BASE_PULSE_REGS + 4*0x03)    // Channel JESD status. One bit per channel. Set if JESD not sync'ed.
//#define ADR_PULSE_REG_TIMER     (ADR_BASE_PULSE_REGS + 4*0x04)    // Current timer count since trigger

// RAM base address
#define ADR_BASE_PULSE_WAVE     (ADR_BASE_DACS_AC + 0x0800)     // Either (512 x 32) for 1K table, or (2K x 32) for 4K tables
#define ADR_BASE_PULSE_DEFN     (ADR_BASE_DACS_AC + 0x0000)

#define ADR_PULSE_RAMP_RATE     (ADR_BASE_DACS_AC + 4*0x00)     // The 'ramp' arch of the pulse generator channel has one register to set the ramp increment rate
#define ADR_PULSE_RAMP_1234     (ADR_BASE_DACS_AC + 4*0x01)     // Read back 0x00001234
#define ADR_PULSE_RAMP_UNDEF    (ADR_BASE_DACS_AC + 4*0x02)     // Read back 0xCCCCCCCC

// Registers in the AXI-Stream switch block.
// Enables any pulse output 0-15 to be sent to any FMC0 DAC
// Enables any pulse output 16-31 to be sent to any FMC1 DAC
#define ADR_SW_MUX7_0           (ADR_BASE_SWITCH + 4*0x00)      // 8, 4-bit mux selects 
#define ADR_SW_MUX15_8          (ADR_BASE_SWITCH + 4*0x01)
#define ADR_SW_MUX23_16         (ADR_BASE_SWITCH + 4*0x02)
#define ADR_SW_MUX31_24         (ADR_BASE_SWITCH + 4*0x03)
#define ADR_SW_INV              (ADR_BASE_SWITCH + 4*0x04)      // Invert chN if bit N is set
#define ADR_SW_ZERO             (ADR_BASE_SWITCH + 4*0x05)      // Zero chN if bit N is set

// Mode defines how subsequent characters are handled
#define C_MODE_CMD      0   // single char commands. 0-9 are characters are used to build a decimal value


//----------------------------------------------------------------------
// IIC device addresses
//----------------------------------------------------------------------
#define IIC_ADDR_ZCU_PORT_EXP_U61   0x0021
#define IIC_ADDR_ZCU_PORT_EXP_U97   0x0020
#define IIC_ADDR_ZCU_BUS_MUX        0x0075
// Device addresses on the Abaco FMC216 boards. Global address bits GA0 and GA1 are tied to '0' on ZCU102 board
#define IIC_ADDR_ABA_CPLD           0x001C
#define IIC_ADDR_ABA_EEPROM         0x0050
#define IIC_ADDR_ABA_VMON           0x002F

// IIC TCA6416A Port Expander register addresses
#define REG_PORT_EXP_IN0            0x0
#define REG_PORT_EXP_IN1            0x1
#define REG_PORT_EXP_OUT0           0x2
#define REG_PORT_EXP_OUT1           0x3
#define REG_PORT_EXP_POL0           0x4
#define REG_PORT_EXP_POL1           0x5
#define REG_PORT_EXP_CONFIG0        0x6
#define REG_PORT_EXP_CONFIG1        0x7

// Presence-detect bits in lower 2 bits of REG_PORT_EXP_CONFIG1
#define BIT_FMC_HPC0_PRSNT_M2C_B    0x01    // Bit 0 is presence detect for FMC0 (P10)
#define BIT_FMC_HPC1_PRSNT_M2C_B    0x02    // Bit 1 is presence detect for FMC1 (P11)

// IIC CPLD internal addresses
#define IIC_CPLD_REG_CMD        0x00    // Bits initiate SPI transfers to DACs and Clk (Write only)
#define     CPLD_CMD_WR_CLK         0x01    // Bit-0 triggers SPI xfer to LMK04828
#define     CPLD_CMD_WR_DAC0        0x02    // Bit-1 triggers SPI xfer to DAC0
#define     CPLD_CMD_WR_DAC1        0x04    // Bit-2 triggers SPI xfer to DAC1
#define     CPLD_CMD_WR_DAC2        0x08    // Bit-3 triggers SPI xfer to DAC2
#define     CPLD_CMD_WR_DAC3        0x10    // Bit-4 triggers SPI xfer to DAC3

#define IIC_CPLD_REG_CTRL       0x01    // Bit 5 -0 control various oscillator and DAC features, reset DACs and CLK
#define IIC_CPLD_REG_CTRL_DAC   0x02    // Bit 3-0 control DAC amp enables, 7-4 DAC sleep mode
#define IIC_CPLD_REG_EN_OUT     0x03    // Bit 3-0 DAC output enables, 5-4 SYNC controls
#define IIC_CPLD_REG_ALARM      0x04    // Bit 3-0 DAC alarms, 4 AD7291 alert, 6-5 GA[1:0] status
#define IIC_CPLD_REG_VERSION    0x05    // CPLD version (Read only)
#define IIC_CPLD_REG_SPI_0      0x06    // SPI byte 0 bits 7-0 last sent
#define IIC_CPLD_REG_SPI_1      0x07    // SPI byte 1
#define IIC_CPLD_REG_SPI_2      0x08    // SPI byte 2
#define IIC_CPLD_REG_SPI_3      0x09    // SPI byte 3 bits 31-24 first sent
#define IIC_CPLD_REG_SPI_RD_1   0x0E    // SPI byte readback upper bits 15-8 (Read only)
#define IIC_CPLD_REG_SPI_RD_0   0x0F    // SPI byte readback lower bits  7-0 (Read only)


//----------------------------------------------------------------------
// Global variables for I2C controller instances
//----------------------------------------------------------------------
XIicPs IicPs0;
XIicPs IicPs1;
XIicPs_Config *IicConfig0;
XIicPs_Config *IicConfig1;


//----------------------------------------------------------------
// 1.0.a Initial version.
// 1.0.b Test RAMs in pulse channel 0.
// 1.0.c Test RAMs in all pulse channels.
// 1.0.d Test all channel clear
// 1.0.e Start I2C dev
// 1.0.f More iic functions
// 1.0.g Set FMC216 board DACs and Clk to use 4-wire SPI so CPLD readback works
// 1.0.h Set LMK SPI output mux
// 1.0.i Add readout of JESD registers. Two JESD204c IP blocks added to PS
// 1.0.j Functions to set jesd_ip, pulse ramps and jesd axi switch
// 1.0.k Clock PLL Functions
// 1.0.l Bug fixes:
//         - hex2int(): correct lowercase 'a'-'f' conversion (was c-0x41, now c-0x61)
//         - set_jesd_ip_tx_gt(): add nLane*ADR_LANE_STEP to address in loop
//         - set_jesd_ip_8B10B_cfg(): populate FMC216 default JESD link parameters
//           (L=2, M=4, F=4, K=32, ILA=4, ILA enabled, no scrambling)
//         - set_jesd_ip_tx_ila_cfg1(): widen N and N' masks to 0x1F (5-bit fields)
//         - set_jesd_ip_tx_ila_cfg2(): correct S from 2 to 1 (FMC216 default S=1)
//         - set_jesd_ip_tx_ila_lid(): correct nLanesPerLink from 2 to 8 (L field
//           describes total lanes per JESD IP core link, not lanes per DAC chip);
//           lane IDs are now 0-7 per core (each core is an independent link)
//         - set_lmk_clk_src(): fix target registers (was writing PLL2_R, now writes
//           CLKin_SEL/POL reg) and implement the intended CLKin2 source selection
//         - fmc216_clks_spi_lock(): fix lock value (0x1FFF=0 unlocks, not locks;
//           use 1 to lock)
//         - fmc216_clks_init(): add mandatory LMK reset strobe and 0x171/0x172
//           fixed register writes per TI recommended programming sequence
//         - fmc216_dac_init(): implement mandatory DAC39J84 polarity inversion for
//           channels A and C (FMC216 UM s4.4.1 item 1: config1 bits 7,5 = 1)
//         - switch_jesd_set(): fix DAC 8-31 mux field: use nMuxInput not nDac
//         - iic_enable_fmc(): move unreachable xil_printf before return
//         - main(): initialise nSwPulseChannel/nSwDac/nSwInvert/nSwZero to 0
// 1.0.m Match qlaser_top_zcu102_fmc0_2links:
//         - LMK: table-only SPI writes (no 0x166..0x1FFF fill), TI §9.5.1 order
//         - DAC CPLD: proper RESET_DACS pulse and restore CTRL
//         - JESD: PS GPIO bit4 GT/PHY reset pulse + poll reset_done; FMC1 optional
// 1.0.n Clock plan locked to DACCLK = GT refclk = 100 MHz (LMK DCLKout ÷24), SYSREF ~LMFC:
//         - regmap comments + pinout create_clock; no change to SPI tables (already 0x18 ODL)
//         - GPIO matches clkdebug: gpin[0]/[1] reset_done, [4]/[5] gt_powergood; one PHY reset after all xil_jesd inits
// 1.0.o Bring-up plan is Distribution Mode 'B': external 200 MHz on CLKin1/Fin.
//         DACCLK = 200 MHz (bypass), DCLKout10 = Fin/2 = 100 MHz GT refclk,
//         SYSREF = Fin/32 = 6.25 MHz = LMFC at f_DATA=100 MSPS, K=16.
//         DAC interp=2x, L=2/M=4/F=4/S=1, 4.0 Gbps/lane. Dual-Loop 'F'/'X' still
//         program the 100 MHz / 3.125 MHz table and are not the matching path.
//         ILA LID = nLane/4 (0 or 1 per DAC), not 0-7. K=16, not the 1.0.l K=32.
//----------------------------------------------------------------
char    g_strVersion[]          = "1.0.o";
int     g_nStateButtons         = 0;
int     g_nStateSwitches        = 0;
int     g_nStateGpioOut         = 0;  // Global var since the GPIO output regs cannot be read
char    inbyte      (void);
void    outbyte     (char c);

// Function declarations
int     toggle_bit              (int nData, u8 nBit);
int     set_bit                 (int nData, u8 nBit);
int     clr_bit                 (int nData, u8 nBit);
u8      get_bit                 (int nData, u8 nBit);
u8      is_hex                  (char c);
u8      hex2int                 (char c);
void    pulse_chsel_set         (int nValue);
int     pulse_chsel_get         ();
int     pulse_rams_all_clear    ();
//int     pulse_channels_test     (int nChanValid);
int     is_present_fmc          (int nFMC);
int     iic_enable_fmc          (int nFMC0);
int		iic_enable_fmc_temp		();
int     iic_write_clk_reg       (int nReg, int nData);
int     iic_write_dac_reg       (int nDac, int nReg, int nData);
int     iic_read_reg_dac        (int nDac, int nReg);
int     iic_write_cpld_reg      (u8 nReg, u8 nData);
int     iic_read_cpld_reg       (int nReg);
int     iic_read_clk_reg        (int nReg);
void    debug_clocks_fmc        (int nFMC);
void    fmc216_clks_init        (int nFMC);
void    fmc216_boards_init      (void);
void    fmc216_boards_init_with_clkin_src (int src);
void    fmc216_boards_init_distribution_extref (void);
void    fmc216_outputs_enable   (int nFMC, int nEnable);
void    jesd_link_status        (int nFMC);
void    switch_one_hot          (int nChannel);
void    set_lmk_clk_src         (void);
void    fmc216_clks_spi_unlock  (void);
void    fmc216_clks_spi_lock    (void);
void    iic_set_fmc_spi4        (void);
int     iic_read_fmc_mux        (void);



//----------------------------------------------------------------
// Set a bit in a 32-bit value.
//----------------------------------------------------------------
int set_bit(int nData, u8 nBit)
{
    int nResult = 0;

    nResult = nData | (0x1 << nBit);
    return(nResult);
}

//----------------------------------------------------------------
// Clear a bit in a 32-bit value.
//----------------------------------------------------------------
int clr_bit(int nData, u8 nBit)
{
    int nResult = 0;

    nResult = nData & ~(0x1 << nBit);
    return(nResult);
}

//----------------------------------------------------------------
// Set a bit in the PS GPIO output.
//----------------------------------------------------------------
void ps_gpio_bit_set(int nBit)
{
	g_nStateGpioOut  = set_bit(g_nStateGpioOut, nBit);
	Xil_Out32(ADR_GPIO_OUT, g_nStateGpioOut);
}

//----------------------------------------------------------------
// Set a bit in the PS GPIO output.
//----------------------------------------------------------------
void ps_gpio_bit_clr(int nBit)
{
	g_nStateGpioOut  = clr_bit(g_nStateGpioOut, nBit);
	Xil_Out32(ADR_GPIO_OUT, g_nStateGpioOut);
}

//----------------------------------------------------------------
// Toggle a bit in a 32-bit value.
//----------------------------------------------------------------
int toggle_bit(int nData, u8 nBit)
{
    int nResult = 0;
    int nState  = get_bit(nData, nBit);

    if (nState == 0)
        nResult = nData | (0x1 << nBit);        // Set
    else
        nResult = nData & ~(0x1 << nBit);       // Clear

    return(nResult);
}

//----------------------------------------------------------------
// Return the value of a bit.
//----------------------------------------------------------------
u8 get_bit(int nData, u8 nBit)
{
    u8  nResult = 0;
    nResult = (u8)(nData >> nBit) & 0x1;
    return nResult;
}


//----------------------------------------------------------------
// Return 1 if character is a valid hex digit, else 0
//----------------------------------------------------------------
u8 is_hex(char c)
{
    u8 result = 0;
    if ((c >= 0x30) && (c <= 0x39))         // '0' to '9'
        result = 1;
    else if ((c >= 0x41) && (c <= 0x46))    // 'A' to 'F'
        result = 1;
    else if ((c >= 0x61) && (c <= 0x66))    // 'a' to 'f'
        result = 1;

    return(result);
}

//----------------------------------------------------------------
// Convert ASCII char into corresponding digit value
//----------------------------------------------------------------
u8 hex2int(char c)
{
    u8 result = 0;
    if ((c >= 0x30) && (c <= 0x39))         // '0' to '9'
        result = c - 0x30;
    else if ((c >= 0x41) && (c <= 0x46))    // 'A' to 'F'
        result = c - 0x41 + 10;
    else if ((c >= 0x61) && (c <= 0x66))    // 'a' to 'f'
        result = c - 0x61 + 10;
    else {
        result = 0;
        print("Error : ");
    }
   (void)xil_printf("hex2int = %d\r\n", result);
    return(result);
}

//----------------------------------------------------------------
// Toggle a GPIO bit
//----------------------------------------------------------------
void gpo_toggle(int nBit, int nAddr)
{
    int nRdata =  0;
    nRdata = Xil_In32(nAddr);
    nRdata = toggle_bit(nRdata, nBit);
    Xil_Out32(nAddr, nRdata);
}

//----------------------------------------------------------------
// Set a GPIO bit
//----------------------------------------------------------------
void gpo_set(int nBit, int nAddr)
{
    int nRdata =  Xil_In32(nAddr);

    nRdata =  nRdata | (0x1 << nBit);
    Xil_Out32(nAddr, nRdata);
}

//----------------------------------------------------------------
// Clear a GPIO bit
//----------------------------------------------------------------
void gpo_clr(int nBit, int nAddr)
{
    int nRdata =  Xil_In32(nAddr);
    nRdata = nRdata & ~(0x1 << nBit);       // Clear
    Xil_Out32(nAddr, nRdata);
}


//----------------------------------------------------------------
// Print help menu
//----------------------------------------------------------------
void print_help()
{
   (void)xil_printf("\r\n");
   (void)xil_printf("\r\n");
   (void)xil_printf("---------------------------------------------------------------------\r\n");
   (void)xil_printf(" Project app_qlaser1 : version %s\r\n", g_strVersion);
   (void)xil_printf(" FPGA version : %08X \r\n", Xil_In32(ADR_MISC_VERSION));
   (void)xil_printf("---------------------------------------------------------------------\r\n");
   (void)xil_printf(" h   : Print this message\r\n");
   (void)xil_printf(" R   : Reset DACs/PLL, clear axi switch\r\n");
   (void)xil_printf(" 0-9 : Enter a 'Value'\r\n");
   (void)xil_printf(" P   : Print registers\r\n");
   (void)xil_printf(" c   : Set current pulse channel to 'Value'.  (99 = all channels)\r\n");
   (void)xil_printf(" s   : Set pulse seq length to 'Value'.\r\n");
   (void)xil_printf(" M   : Test all Pulse Channels RAMs.\r\n");
   (void)xil_printf(" g   : (value=bit) toggle green LED bit\r\n");
   (void)xil_printf(" i   : Read port expander\r\n");
   (void)xil_printf(" m   : Set FMC mux {0 or 1}\r\n");
   (void)xil_printf(" L   : Lock/Unlock PLL SPI write access {1=lock, 0=unlock}\r\n");
   (void)xil_printf(" t   : Read temp from FMC216 AD7291 voltage/temp monitor chip\r\n");
   (void)xil_printf(" S   : DAC sleep\r\n");
   (void)xil_printf(" A   : DAC awaken\r\n");
   (void)xil_printf(" d   : Dump FMC registers\r\n");
   (void)xil_printf(" k   : Set FMC devices to 4-wire SPI\r\n");
   (void)xil_printf(" m   : (value = fmc) Select FMC board to talk to (0  or 1)\r\n");
   (void)xil_printf(" T   : Test default regs (0-3 = DACs, 4 = CLK LMK, 5 = CPLD\r\n");
   (void)xil_printf(" I   : AXI-switch : Set Invert flag 1,0   (applied by W)\r\n");
   (void)xil_printf(" Z   : AXI-switch : Set Zero flag 1,0     (applied by W)\r\n");
   (void)xil_printf(" D   : AXI-switch : Set destination DAC output 0-31 (applied by W)\r\n");
   (void)xil_printf(" W   : AXI-switch : Set pulse source 0-31 and apply. 99W = identity map\r\n");
   (void)xil_printf(" y   : Test writes to a DAC reg and a clock reg\r\n");
   (void)xil_printf(" G   : Go. Start ramps running (1G = run, 0G = stop)\r\n");
   (void)xil_printf(" E   : FMC216 analog outputs on/off (1E = amps + DAC TXENABLE on, 0E = mute)\r\n");
   (void)xil_printf(" O   : One-hot channel test. <n>O leaves only channel n ramping. 99O restores all\r\n");
   (void)xil_printf(" e   : JESD link status (SYSREF captured, SYNC~, per-lane ILA)\r\n");
   (void)xil_printf(" F   : Init FMCs Dual-Loop (on-board 100 MHz CLKin2). DACCLK=100 MHz, SYSREF=3.125 MHz.\r\n");
   (void)xil_printf("       Does not match the DAC/JESD 200 MHz / 4.0 Gbps software — use B for bring-up.\r\n");
   (void)xil_printf(" X   : Dual-Loop with EXTERNAL 100 MHz on CLKin1 SMA (CLKin->PLL1->VCXO->PLL2).\r\n");
   (void)xil_printf("       Same 100 MHz DACCLK / 3.125 MHz SYSREF as F. Restores default after.\r\n");
   (void)xil_printf(" B   : Init FMCs in DISTRIBUTION MODE (TI SNAS605 §9.4.5) — both PLLs bypassed;\r\n");
   (void)xil_printf("       external 200 MHz on CLKin1 SMA -> DACCLK=200 MHz (bypass),\r\n");
   (void)xil_printf("       DCLKout10=100 MHz (÷2 GT refclk), SYSREF=6.25 MHz (÷32).\r\n");
   (void)xil_printf("       No PLL lock needed; use when PLL1 path is dead or external master is required.\r\n");
   (void)xil_printf(" C   : Detailed clock debug report (value=FMC 0 or 1)\r\n");
   (void)xil_printf(" J   : LMK CLKin sweep (try CLKin0/1/2 manually, report which lets PLL1 lock)\r\n");
   (void)xil_printf(" Q   : LMK PLL1 deep diagnostic (RB_DAC, holdover/MAN_DAC, dividers vs regmap)\r\n");
   (void)xil_printf("\r\n");
}


//----------------------------------------------------------------
// Print a set of registers
//----------------------------------------------------------------
void print_regs(int nValue) // 0=jesd0, 1=jesd1, 2=pulse gen and misc, 3 = Ramps, 4= JESD switch
{
    int nRdata=0;
    int nChannel = 0;

    if (nValue == 2) 
    {
        (void)xil_printf ("Pulse generator registers\r\n");
        (void)xil_printf ("ADR_PULSE_REG_SEQ_LEN              = %08X\r\n", Xil_In32(ADR_PULSE_REG_SEQ_LEN));
        (void)xil_printf ("ADR_PULSE_REG_CHSEL                = %08X\r\n", Xil_In32(ADR_PULSE_REG_CHSEL  ));
        (void)xil_printf ("ADR_PULSE_REG_GSTATUS              = %08X\r\n", Xil_In32(ADR_PULSE_REG_GSTATUS));
        (void)xil_printf ("ADR_PULSE_REG_CHSTATUS             = %08X\r\n", Xil_In32(ADR_PULSE_REG_CHSTATUS));
        (void)xil_printf ("ADR_PULSE_REG_TIMER                = %08X\r\n", Xil_In32(ADR_PULSE_REG_TIMER  ));
        (void)xil_printf("\r\n");


        (void)xil_printf ("Misc registers\r\n");
        (void)xil_printf ("ADR_MISC_VERSION                   = %08X\r\n", Xil_In32(ADR_MISC_VERSION     ));
        (void)xil_printf ("ADR_MISC_LEDS                      = %08X\r\n", Xil_In32(ADR_MISC_LEDS        ));
        (void)xil_printf ("ADR_MISC_LEDS_EN                   = %08X\r\n", Xil_In32(ADR_MISC_LEDS_EN     ));
        (void)xil_printf ("ADR_MISC_DEBUG_CTRL                = %08X\r\n", Xil_In32(ADR_MISC_DEBUG_CTRL  ));
        (void)xil_printf ("ADR_MISC_TRIGGER                   = %08X\r\n", Xil_In32(ADR_MISC_TRIGGER     ));
        (void)xil_printf("\r\n");
    }
    else if (nValue == 3) 
    {

        (void)xil_printf ("ADR_PULSE_REG_CHSEL                = %08X\r\n", Xil_In32(ADR_PULSE_REG_CHSEL  ));
        nRdata = Xil_In32(ADR_PULSE_REG_CHSEL);
        for (nChannel=0 ; nChannel < 32 ; nChannel++)
        {
            Xil_Out32(ADR_PULSE_REG_CHSEL, (0x1 << nChannel)); // Set channel select reg

        	(void)xil_printf ("ADR_PULSE_RAMP_RATE                = %08X\r\n", Xil_In32(ADR_PULSE_RAMP_RATE  ));
        	//(void)xil_printf ("ADR_PULSE_RAMP_1234                = %08X\r\n", Xil_In32(ADR_PULSE_RAMP_1234  ));
        	//(void)xil_printf ("ADR_PULSE_RAMP_UNDEF               = %08X\r\n", Xil_In32(ADR_PULSE_RAMP_UNDEF ));
        }
        // Restore CHSEL
        Xil_Out32(ADR_PULSE_REG_CHSEL, nRdata);
        (void)xil_printf("\r\n");
    }
    else if (nValue == 4)
    {
        (void)xil_printf ("Switch registers (%d)\r\n", nValue);
        (void)xil_printf ("ADR_SW_MUX7_0               = %08X\r\n", Xil_In32(ADR_SW_MUX7_0  ));
        (void)xil_printf ("ADR_SW_MUX15_8              = %08X\r\n", Xil_In32(ADR_SW_MUX15_8 ));
        (void)xil_printf ("ADR_SW_MUX23_16             = %08X\r\n", Xil_In32(ADR_SW_MUX23_16));
        (void)xil_printf ("ADR_SW_MUX31_24             = %08X\r\n", Xil_In32(ADR_SW_MUX31_24));
        (void)xil_printf ("ADR_SW_INV                  = %08X\r\n", Xil_In32(ADR_SW_INV     ));
        (void)xil_printf ("ADR_SW_ZERO                 = %08X\r\n", Xil_In32(ADR_SW_ZERO    ));
        (void)xil_printf("\r\n");
    }
    else if (nValue == 0) 
    {
        (void)xil_printf ("Xilinx JESD_0 block (%d)\r\n", nValue);
        (void)xil_printf ("ADR_JESD_FMC0_JESD_IP_VERSION                = %08X\r\n", Xil_In32(ADR_JESD(FMC0, REG_JESD_IP_VERSION) ));

        nRdata = Xil_In32(ADR_JESD(FMC0, REG_JESD_IP_CONFIG));
        (void)xil_printf ("ADR_JESD_FMC0_JESD_IP_CONFIG                 = %08X\r\n", nRdata);
        (void)xil_printf ("                      18   FEC=1              = %d\r\n", (nRdata & 0x40000)>>18);
        (void)xil_printf ("                      17   64B66B=1/8B10B=0   = %d\r\n", (nRdata & 0x20000)>>17);
        (void)xil_printf ("                      16   TX=1/RX=0             = %d\r\n", (nRdata & 0x10000)>>16);
        (void)xil_printf ("                    [3:0]  LANES                 = %d\r\n", (nRdata & 0xF));

        nRdata = Xil_In32(ADR_JESD(FMC0, REG_JESD_RESET));
        (void)xil_printf ("ADR_JESD_FMC0_JESD_RESET                 = %08X\r\n", nRdata);
        (void)xil_printf ("                       7   GTs are still reset= %d\r\n", (nRdata & 0x80)>>7);
        (void)xil_printf ("                       5   tx/rx_reset        = %d\r\n", (nRdata & 0x20)>>5);
        (void)xil_printf ("                       4   tx/rx_core_reset   = %d\r\n", (nRdata & 0x10)>>4);
        (void)xil_printf ("                       0   RESET             = %d\r\n", (nRdata & 0x1));

        (void)xil_printf ("ADR_JESD_FMC0_JESD_CTRL_TX_SYNC          = %08X\r\n", Xil_In32(ADR_JESD(FMC0, REG_JESD_CTRL_TX_SYNC     ) ));
        (void)xil_printf ("ADR_JESD_FMC0_JESD_CTRL_SUB_CLASS        = %08X\r\n", Xil_In32(ADR_JESD(FMC0, REG_JESD_CTRL_SUB_CLASS   ) ));

        nRdata = Xil_In32(ADR_JESD(FMC0, REG_JESD_CTRL_8B10B_CFG));
        (void)xil_printf ("ADR_JESD_FMC0_JESD_CTRL_8B10B_CFG        = %08X\r\n", nRdata);
        (void)xil_printf ("                   [31:24] ILA multiframes    = %d\r\n",((nRdata & 0xFF000000)>>24)+1);
        (void)xil_printf ("                   [21:20] Reserved 00        = %d\r\n", (nRdata & 0x00300000)>>20);
        (void)xil_printf ("                      19   Enable LinkErrCnts = %d\r\n", (nRdata & 0x00080000)>>19);
        (void)xil_printf ("                      18   Err rpt using SYNC = %d\r\n", (nRdata & 0x00040000)>>18);
        (void)xil_printf ("                      17   Enable ILA Support = %d\r\n", (nRdata & 0x00020000)>>17);
        (void)xil_printf ("                      16   Enable Scrambling  = %d\r\n", (nRdata & 0x00010000)>>16);
        (void)xil_printf ("                   [12:8]  Frames per Multifr (K) = %d\r\n",((nRdata & 0x00001F00)>> 8)+1);
        (void)xil_printf ("                   [ 7:0]  Octets per Frame   = %d\r\n", (nRdata & 0x000000FF)+1  );

        // Enable all lanes
        (void)xil_printf ("ADR_JESD_FMC0_JESD_CTRL_LANE_ENA (0xFF)  = %08X\r\n", Xil_In32(ADR_JESD(FMC0, REG_JESD_CTRL_LANE_ENA    ) ));

        //----------------------------------------------------------------
        // Test mode. Only bits 2:0 are used in TX 8B10B mode
        //----------------------------------------------------------------
        // Test mode select (8B10B mode):
        // 000 = Normal operation
        // 001 = Transmit receive /K28.5/ indefinitely2
        // 010 = Synchronize as normal then transmit/receive repeated ILA sequences.2
        // 101 = Transmit Modified Random Pattern RPAT (TX only)1
        // 111 = Transmit Scrambled Jitter Pattern JSPAT (TX only)1
        (void)xil_printf ("ADR_JESD_FMC0_JESD_CTRL_TEST_MODE        = %08X\r\n", Xil_In32(ADR_JESD(FMC0, REG_JESD_CTRL_TEST_MODE   ) ));


        //----------------------------------------------------------------
        // 23:16 0x0 (For 64b66b cores only) SYSREF Delay: Add additional delay to SYSREF alignment LEMC. 
        // 0xFF = 255 core_clk cycles delay  ....  0x00 = 0 core_clk cycles delay
        // This register field is used to retard the phase of the LEMC.
        //----------------------------------------------------------------
        // 19:16 0x0 SYSREF Delay:  Add additional delay to SYSREF alignment of LMFC.
        // 1111 = 15 core_clk cycles delay  ....  0000 = 0 core_clk cycles delay
        // This register is used to retard the phase of the LMFC.
        //----------------------------------------------------------------
        // 10:8 0x0 SYSREF Tolerance:
        // Specify a tolerance value in core_clk cycles for SYSREF detection when in
        // SYSREF Always mode. If a SYSREF event is detected within +/- tolerance
        // core_clk cycles from its expected position, no error signal will be issued.
        //----------------------------------------------------------------
        // bit-1 SYSREF Required on Re-Sync. Default 0
        // 1 = Following a Link Re-Sync event, a SYSREF event is required to re-align
        // the local LMFC/LEMC before the link will operate.
        // 0 = No SYSREF is required to restart a link after a Re-sync event.
        //----------------------------------------------------------------
        // bit-0 SYSREF Always. Default 0
        // 1 = The core will align the LMFC/LEMC counter on all SYSREF events.
        // 0 = The core will only align the LMFC/LEMC counter on the first SYSREF
        // event following a reset, all subsequent SYSREF events will be ignored.
        (void)xil_printf ("ADR_JESD_FMC0_JESD_CTRL_SYSREF           = %08X\r\n", Xil_In32(ADR_JESD(FMC0, REG_JESD_CTRL_SYSREF      ) ));
        (void)xil_printf ("                  [19:16]  Sysref dly        = 0x%02X\r\n", (nRdata & 0x000F0000) >> 16);
        (void)xil_printf ("                  [10: 8]  Sysref toler.     = 0x%01X\r\n", (nRdata & 0x00000700) >>  8);
        (void)xil_printf ("                      [1]  Sysref reqd       = %d\r\n",     (nRdata & 0x00000002) >>  1);
        (void)xil_printf ("                      [0]  Sysref always     = %d\r\n",     (nRdata & 0x00000001)      );

        (void)xil_printf ("ADR_JESD_FMC0_JESD_STAT_STATUS           = %08X\r\n", Xil_In32(ADR_JESD(FMC0, REG_JESD_STAT_STATUS      ) ));
        (void)xil_printf ("ADR_JESD_FMC0_JESD_CTRL_IRQ              = %08X\r\n", Xil_In32(ADR_JESD(FMC0, REG_JESD_CTRL_IRQ         ) ));
        (void)xil_printf ("ADR_JESD_FMC0_JESD_STAT_IRQ              = %08X\r\n", Xil_In32(ADR_JESD(FMC0, REG_JESD_STAT_IRQ         ) ));


        //----------------------------------------------------------------
        // Config0
        //----------------------------------------------------------------
        nRdata = Xil_In32(ADR_JESD(FMC0, REG_JESD_CTRL_TX_ILA_CFG0));
        (void)xil_printf ("ADR_JESD_FMC0_JESD_CTRL_TX_ILA_CFG0      = %08X\r\n", nRdata);
        (void)xil_printf ("                   [11:8]  Bank ID           = 0x%01X\r\n", (nRdata & 0x00000F00) >>  8);
        (void)xil_printf ("                   [ 7:0]  Device ID         = 0x%02X\r\n", (nRdata & 0x000000FF)      );

        //----------------------------------------------------------------
        // Config1
        //----------------------------------------------------------------
        // 31:26 –   Reserved
        // 25:24 0x0 CS (Control bits per Sample). Binary value.
        // 23:21 –   Reserved
        // 20:16 0x0 N' (Totals bits per Sample). Binary value minus 1.
        // 15:13 –   Reserved
        // 12:8 0x0  N (Converter Resolution). Binary value minus 1.
        //  7:0 0x0  M (Converters per Device). Binary value minus 1.
        nRdata = Xil_In32(ADR_JESD(FMC0, REG_JESD_CTRL_TX_ILA_CFG1));
        (void)xil_printf ("ADR_JESD_FMC0_JESD_CTRL_TX_ILA_CFG1      = %08X\r\n", nRdata);
        (void)xil_printf ("                   [25:24]  CS Bits/sample     = %d\r\n", ((nRdata & 0x03000000)>>24)    );
        (void)xil_printf ("                   [20:16]  Bits/sample N'     = %d\r\n", ((nRdata & 0x001F0000)>>16)+1  );
        (void)xil_printf ("                   [12: 8]  Conv resolution    = %d\r\n", ((nRdata & 0x0001FF00)>> 8)+1  );
        (void)xil_printf ("                   [ 7: 0]  Conv per dev (M)   = %d\r\n", ((nRdata & 0x000000FF)    )+1  );

        //----------------------------------------------------------------
        // Config2
        //----------------------------------------------------------------
        // 28:24 0x0 CF (Control Words per Frame). Binary value.
        // 16      0 HD (High Density format)
        // 12:8  0x0  S (Samples per Converter per Frame). Binary value minus 1.
        nRdata = Xil_In32(ADR_JESD(FMC0, REG_JESD_CTRL_TX_ILA_CFG2));
        (void)xil_printf ("ADR_JESD_FMC0_JESD_CTRL_TX_ILA_CFG2      = %08X\r\n", nRdata);
        (void)xil_printf ("                   [28:24] Ctrl Words/Frame  (S) = %d\r\n", ((nRdata & 0x1F000000)>>24)    );
        (void)xil_printf ("                       16  HD format             = %d\r\n", ((nRdata & 0x00010000)>>16)    );
        (void)xil_printf ("                   [12: 8] Sample/Conv/Frame (S) = %d\r\n", ((nRdata & 0x00001F00)>> 8)+1  );

        //----------------------------------------------------------------
        // Config3
        // Only used in Subclass 2
        //----------------------------------------------------------------
        (void)xil_printf ("ADR_JESD_FMC0_JESD_CTRL_TX_ILA_CFG3      = %08X\r\n", Xil_In32(ADR_JESD(FMC0, REG_JESD_CTRL_TX_ILA_CFG3 ) ));

        //----------------------------------------------------------------
        // Config4
        // RES2, RES1 are always zero
        //----------------------------------------------------------------
        (void)xil_printf ("ADR_JESD_FMC0_JESD_CTRL_TX_ILA_CFG4      = %08X\r\n", Xil_In32(ADR_JESD(FMC0, REG_JESD_CTRL_TX_ILA_CFG4 ) ));
        (void)xil_printf("\r\n");

        //----------------------------------------------------------------
        // REG_JESD_CTRL_TX_ILA_LID (per lane)
        //----------------------------------------------------------------
        // 31:21 – Reserved
        // 20:16 L Number of lanes per link (binary value minus 1). The default value for all lanes is L (total number of lanes minus 1).
        // These values should be programmed when:
        // • Not all lanes in the generated IP core are enabled.
        // • A single TX core is used to drive multiple DAC devices.
        // • Multiple TX cores are combined to create links with more than eight lanes.
        // 15:5 – Reserved
        // 4:0 N ID of lane N. Value can be anywhere between 0 and 31. The default value N is set to the lane number.
        // For interfaces using more than 8 lanes and hence multiple JESD204C cores, this register should be programmed to
        // ensure each lane has the correct identifier.
        nRdata = Xil_In32(ADR_JESD_LANE(FMC0, LANE0, REG_JESD_CTRL_TX_ILA_LID) );
        (void)xil_printf ("ADR_JESD_FMC0_JESD_CTRL_TX_ILA_LID   0   = %08X\r\n", nRdata);
        (void)xil_printf ("                   [20:16] L Number of lanes per link L-1 = %d\r\n", ((nRdata & 0x001F0000)>>20)+1    );
        (void)xil_printf ("                   [ 4:0 ] ID for Lane                    = %d\r\n", ((nRdata & 0x0000001F))    );

        (void)xil_printf ("ADR_JESD_FMC0_JESD_CTRL_TX_ILA_LID   1   = %08X\r\n", Xil_In32(ADR_JESD_LANE(FMC0, LANE1, REG_JESD_CTRL_TX_ILA_LID) ));
        (void)xil_printf ("ADR_JESD_FMC0_JESD_CTRL_TX_ILA_LID   2   = %08X\r\n", Xil_In32(ADR_JESD_LANE(FMC0, LANE2, REG_JESD_CTRL_TX_ILA_LID) ));
        (void)xil_printf ("ADR_JESD_FMC0_JESD_CTRL_TX_ILA_LID   3   = %08X\r\n", Xil_In32(ADR_JESD_LANE(FMC0, LANE3, REG_JESD_CTRL_TX_ILA_LID) ));
        (void)xil_printf ("ADR_JESD_FMC0_JESD_CTRL_TX_ILA_LID   4   = %08X\r\n", Xil_In32(ADR_JESD_LANE(FMC0, LANE4, REG_JESD_CTRL_TX_ILA_LID) ));
        (void)xil_printf ("ADR_JESD_FMC0_JESD_CTRL_TX_ILA_LID   5   = %08X\r\n", Xil_In32(ADR_JESD_LANE(FMC0, LANE5, REG_JESD_CTRL_TX_ILA_LID) ));
        (void)xil_printf ("ADR_JESD_FMC0_JESD_CTRL_TX_ILA_LID   6   = %08X\r\n", Xil_In32(ADR_JESD_LANE(FMC0, LANE6, REG_JESD_CTRL_TX_ILA_LID) ));
        (void)xil_printf ("ADR_JESD_FMC0_JESD_CTRL_TX_ILA_LID   7   = %08X\r\n", Xil_In32(ADR_JESD_LANE(FMC0, LANE7, REG_JESD_CTRL_TX_ILA_LID) ));

        //----------------------------------------------------------------
        // REG_JESD_CTRL_TX_GT (per lane)
        //----------------------------------------------------------------
        //   4  0   TXINHIBIT   Set High to inhibit transmission of TX data
        //   3  0   TXELECIDLE  Set High to force idle signal on transmitter output
        // 2:1  0x0 TXPD        TX power down
        //   0  0   TXPOLARITY  Set High to invert the polarity of the outgoing TX data
        nRdata = Xil_In32(ADR_JESD_LANE(FMC0, LANE0, REG_JESD_CTRL_TX_GT ) );
        (void)xil_printf ("ADR_JESD_FMC0_JESD_CTRL_TX_GT        0   = %08X\r\n", nRdata);
        (void)xil_printf ("                   [4] TXINHIBIT             = %d\r\n", ((nRdata & 0x00000010)>>4)    );
        (void)xil_printf ("                   [3] TXELECIDLE            = %d\r\n", ((nRdata & 0x00000008)>>3)    );
        (void)xil_printf ("                 [2:1] TXPD                  = %d\r\n", ((nRdata & 0x00000006)>>1)    );
        (void)xil_printf ("                   [0] TXPOLARITY            = %d\r\n", ((nRdata & 0x00000001))       );
        (void)xil_printf ("ADR_JESD_FMC0_JESD_CTRL_TX_GT        1   = %08X\r\n", Xil_In32(ADR_JESD_LANE(FMC0, LANE1, REG_JESD_CTRL_TX_GT ) ));
        (void)xil_printf ("ADR_JESD_FMC0_JESD_CTRL_TX_GT        2   = %08X\r\n", Xil_In32(ADR_JESD_LANE(FMC0, LANE2, REG_JESD_CTRL_TX_GT ) ));
        (void)xil_printf ("ADR_JESD_FMC0_JESD_CTRL_TX_GT        3   = %08X\r\n", Xil_In32(ADR_JESD_LANE(FMC0, LANE3, REG_JESD_CTRL_TX_GT ) ));
        (void)xil_printf ("ADR_JESD_FMC0_JESD_CTRL_TX_GT        4   = %08X\r\n", Xil_In32(ADR_JESD_LANE(FMC0, LANE4, REG_JESD_CTRL_TX_GT ) ));
        (void)xil_printf ("ADR_JESD_FMC0_JESD_CTRL_TX_GT        5   = %08X\r\n", Xil_In32(ADR_JESD_LANE(FMC0, LANE5, REG_JESD_CTRL_TX_GT ) ));
        (void)xil_printf ("ADR_JESD_FMC0_JESD_CTRL_TX_GT        6   = %08X\r\n", Xil_In32(ADR_JESD_LANE(FMC0, LANE6, REG_JESD_CTRL_TX_GT ) ));
        (void)xil_printf ("ADR_JESD_FMC0_JESD_CTRL_TX_GT        7   = %08X\r\n", Xil_In32(ADR_JESD_LANE(FMC0, LANE7, REG_JESD_CTRL_TX_GT ) ));
        (void)xil_printf("\r\n");
    }
    else if (nValue == 1)  
    {
#if !JESD_HAS_FMC1
        (void)xil_printf ("JESD FMC1 not in this bitstream (JESD_HAS_FMC1=0)\r\n");
#else
        (void)xil_printf ("Xilinx JESD_1 block (%d)\r\n", nValue);
        (void)xil_printf ("ADR_JESD_FMC1_JESD_IP_VERSION      = %08X\r\n", Xil_In32(ADR_JESD(FMC1, REG_JESD_IP_VERSION) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_IP_CONFIG             = %08X\r\n", Xil_In32(ADR_JESD(FMC1, REG_JESD_IP_CONFIG        ) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_RESET                 = %08X\r\n", Xil_In32(ADR_JESD(FMC1, REG_JESD_RESET            ) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_CTRL_TX_SYNC          = %08X\r\n", Xil_In32(ADR_JESD(FMC1, REG_JESD_CTRL_TX_SYNC     ) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_CTRL_SUB_CLASS        = %08X\r\n", Xil_In32(ADR_JESD(FMC1, REG_JESD_CTRL_SUB_CLASS   ) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_CTRL_8B10B_CFG        = %08X\r\n", Xil_In32(ADR_JESD(FMC1, REG_JESD_CTRL_8B10B_CFG   ) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_CTRL_LANE_ENA         = %08X\r\n", Xil_In32(ADR_JESD(FMC1, REG_JESD_CTRL_LANE_ENA    ) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_CTRL_TEST_MODE        = %08X\r\n", Xil_In32(ADR_JESD(FMC1, REG_JESD_CTRL_TEST_MODE   ) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_CTRL_SYSREF           = %08X\r\n", Xil_In32(ADR_JESD(FMC1, REG_JESD_CTRL_SYSREF      ) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_STAT_STATUS           = %08X\r\n", Xil_In32(ADR_JESD(FMC1, REG_JESD_STAT_STATUS      ) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_CTRL_IRQ              = %08X\r\n", Xil_In32(ADR_JESD(FMC1, REG_JESD_CTRL_IRQ         ) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_STAT_IRQ              = %08X\r\n", Xil_In32(ADR_JESD(FMC1, REG_JESD_STAT_IRQ         ) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_CTRL_TX_ILA_CFG0      = %08X\r\n", Xil_In32(ADR_JESD(FMC1, REG_JESD_CTRL_TX_ILA_CFG0 ) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_CTRL_TX_ILA_CFG1      = %08X\r\n", Xil_In32(ADR_JESD(FMC1, REG_JESD_CTRL_TX_ILA_CFG1 ) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_CTRL_TX_ILA_CFG2      = %08X\r\n", Xil_In32(ADR_JESD(FMC1, REG_JESD_CTRL_TX_ILA_CFG2 ) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_CTRL_TX_ILA_CFG3      = %08X\r\n", Xil_In32(ADR_JESD(FMC1, REG_JESD_CTRL_TX_ILA_CFG3 ) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_CTRL_TX_ILA_CFG4      = %08X\r\n", Xil_In32(ADR_JESD(FMC1, REG_JESD_CTRL_TX_ILA_CFG4 ) ));
        (void)xil_printf("\r\n");

        (void)xil_printf ("ADR_JESD_FMC1_JESD_CTRL_TX_ILA_LID   0   = %08X\r\n", Xil_In32(ADR_JESD_LANE(FMC1, LANE0, REG_JESD_CTRL_TX_ILA_LID) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_CTRL_TX_GT        0   = %08X\r\n", Xil_In32(ADR_JESD_LANE(FMC1, LANE0, REG_JESD_CTRL_TX_GT ) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_CTRL_TX_ILA_LID   1   = %08X\r\n", Xil_In32(ADR_JESD_LANE(FMC1, LANE1, REG_JESD_CTRL_TX_ILA_LID) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_CTRL_TX_GT        1   = %08X\r\n", Xil_In32(ADR_JESD_LANE(FMC1, LANE1, REG_JESD_CTRL_TX_GT ) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_CTRL_TX_ILA_LID   2   = %08X\r\n", Xil_In32(ADR_JESD_LANE(FMC1, LANE2, REG_JESD_CTRL_TX_ILA_LID) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_CTRL_TX_GT        2   = %08X\r\n", Xil_In32(ADR_JESD_LANE(FMC1, LANE2, REG_JESD_CTRL_TX_GT ) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_CTRL_TX_ILA_LID   3   = %08X\r\n", Xil_In32(ADR_JESD_LANE(FMC1, LANE3, REG_JESD_CTRL_TX_ILA_LID) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_CTRL_TX_GT        3   = %08X\r\n", Xil_In32(ADR_JESD_LANE(FMC1, LANE3, REG_JESD_CTRL_TX_GT ) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_CTRL_TX_ILA_LID   4   = %08X\r\n", Xil_In32(ADR_JESD_LANE(FMC1, LANE4, REG_JESD_CTRL_TX_ILA_LID) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_CTRL_TX_GT        4   = %08X\r\n", Xil_In32(ADR_JESD_LANE(FMC1, LANE4, REG_JESD_CTRL_TX_GT ) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_CTRL_TX_ILA_LID   5   = %08X\r\n", Xil_In32(ADR_JESD_LANE(FMC1, LANE5, REG_JESD_CTRL_TX_ILA_LID) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_CTRL_TX_GT        5   = %08X\r\n", Xil_In32(ADR_JESD_LANE(FMC1, LANE5, REG_JESD_CTRL_TX_GT ) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_CTRL_TX_ILA_LID   6   = %08X\r\n", Xil_In32(ADR_JESD_LANE(FMC1, LANE6, REG_JESD_CTRL_TX_ILA_LID) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_CTRL_TX_GT        6   = %08X\r\n", Xil_In32(ADR_JESD_LANE(FMC1, LANE6, REG_JESD_CTRL_TX_GT ) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_CTRL_TX_ILA_LID   7   = %08X\r\n", Xil_In32(ADR_JESD_LANE(FMC1, LANE7, REG_JESD_CTRL_TX_ILA_LID) ));
        (void)xil_printf ("ADR_JESD_FMC1_JESD_CTRL_TX_GT        7   = %08X\r\n", Xil_In32(ADR_JESD_LANE(FMC1, LANE7, REG_JESD_CTRL_TX_GT ) ));
        (void)xil_printf("\r\n");
#endif
    }
}


//---------------------------------------------------------
//
//---------------------------------------------------------
void set_jesd_ip_subclass(int nFMC, int nSubClass)
{
    int nAddr = (ADR_BASE_JESD + (nFMC * ADR_FMC_STEP) + REG_JESD_CTRL_SUB_CLASS);
    Xil_Out32(nAddr, nSubClass);
}

//---------------------------------------------------------
// CTRL_8B10B_CFG
// FMC216 JESD204B link parameters aligned with DAC39J84 (SLASE48A Table 11) and the LMK
// Distribution 'B' plan: DACCLK=200 MHz, SYSREF=6.25 MHz. FMC216 wires 2 lanes per DAC
// (4 independent L=2 links across the 8 GT lanes). DAC runs interp=2x, so f_DATA=100 MSPS:
//   per link: L=2, M=4, F=4, S=1, K=16 => LMFC = 100M/(S*K) = 6.25 MHz = SYSREF; 4.0 Gbps/lane.
// F/K are per-link scalars (same for all 4 links). These fields are encoded as (value-1).
//---------------------------------------------------------
void set_jesd_ip_8B10B_cfg(int nFMC)
{
    int ILA_Multiframes         = 4;   // 4 ILA multiframes (register value = ILA_Multiframes-1 = 3)
    int En_LinkErrCnts          = 1;   // Enable link error counters
    int Err_Rpt_Sync            = 0;   // Report errors via SYNC~ (not used in TX-only)
    int En_ILA                  = 1;   // Enable ILA sequence (required for JESD204B link establishment)
    int En_Scrambling           = 0;   // No scrambling (DAC39J84 default)
    int Frames_Per_MultiFrame   = 16;  // K=16 (register value = K-1 = 15); LMFC=100M/16=6.25 MHz = SYSREF
    int Octets_Per_Frame        = 4;   // F=4 (register value = F-1 = 3); L=2,M=4,S=1,N'=16 => F = M*S*N'/8/L = 4

    int nWdata = (
            (((ILA_Multiframes-1)       & 0xFF) << 24)
        +   ((En_LinkErrCnts            & 0x01) << 19)
        +   ((Err_Rpt_Sync              & 0x01) << 18)
        +   ((En_ILA                    & 0x01) << 17)
        +   ((En_Scrambling             & 0x01) << 16)
        +   (((Frames_Per_MultiFrame-1) & 0x1F) <<  8)
        +   (((Octets_Per_Frame-1)      & 0xFF)      )
    );

    int nAddr = (ADR_BASE_JESD + (nFMC * ADR_FMC_STEP) + REG_JESD_CTRL_8B10B_CFG);
    Xil_Out32(nAddr, nWdata);
}

//---------------------------------------------------------
// REG_JESD_CTRL_LANE_ENA
//---------------------------------------------------------
void set_jesd_ip_lane_en     (int nFMC, int nEnables)
{
    int nWdata = nEnables;
    int nAddr = (ADR_BASE_JESD + (nFMC * ADR_FMC_STEP) + REG_JESD_CTRL_LANE_ENA);
 
    Xil_Out32(nAddr, nWdata);
}


//---------------------------------------------------------
// REG_JESD_CTRL_TEST_MODE`
//----------------------------------------------------------------
// Test mode. Only bits 2:0 are used in TX 8B10B mode
//----------------------------------------------------------------
// Test mode select (8B10B mode):
// 000 = Normal operation
// 001 = Transmit receive /K28.5/ indefinitely
// 010 = Synchronize as normal then transmit/receive repeated ILA sequences.
// 101 = Transmit Modified Random Pattern RPAT (TX only)
// 111 = Transmit Scrambled Jitter Pattern JSPAT (TX only)
//---------------------------------------------------------
void set_jesd_ip_test_mode   (int nFMC)  
{
    int nWdata =  0x0;  // Normal operation
    int nAddr  =  ADR_BASE_JESD + (nFMC * ADR_FMC_STEP) + REG_JESD_CTRL_TEST_MODE;

    Xil_Out32(nAddr, nWdata);
}


//---------------------------------------------------------
// REG_JESD_CTRL_SYSREF
// #define     REG_JESD_CTRL_SYSREF  0x050    //    RW      RW      RW      RW
//
// LMK SYSREF is fanned out on FMC216 to DAC39J84 and to the FPGA (p_fmc0_tx_sysref_*).
// Non-zero tolerance (core_clk cycles) absorbs small trace skew so FPGA LMFC stays
// coherent with the same SYSREF epoch as the DACs (subclass 1, same LMK source).
//---------------------------------------------------------
void set_jesd_ip_sysref      (int nFMC)  
{
    int nSysrefDly      = 0;
    int nSysrefToler    = 3;
    int nSysrefReqd     = 1;
    int nSysrefAlways   = 0;

    int nWdata = (  ((nSysrefDly    & 0xF) << 16)
    		      + ((nSysrefToler  & 0x7) <<  8)
                  + ((nSysrefReqd   & 0x1) <<  1)
                  + ((nSysrefAlways & 0x1)      )
    );
    int nAddr = (ADR_BASE_JESD + (nFMC * ADR_FMC_STEP) + REG_JESD_CTRL_SYSREF);

    Xil_Out32(nAddr, nWdata);
}


//---------------------------------------------------------
// REG_JESD_CTRL_IRQ 
// #define     REG_JESD_CTRL_IRQ           0x064    //    RW      RW      RW      RW
//---------------------------------------------------------
void set_jesd_ip_ctrl_irq (int nFMC)  
{
    int nWdata = 0x00000000;

    int nAddr = (ADR_BASE_JESD + (nFMC * ADR_FMC_STEP) + REG_JESD_CTRL_IRQ);
    Xil_Out32(nAddr, nWdata);
}


//---------------------------------------------------------
// REG_JESD_CTRL_TX_ILA_CFG0   0x070    //    N/A     N/A     RW      N/A
//      [11:8]  Bank ID   
//      [ 7:0]  Device ID  
//---------------------------------------------------------
void set_jesd_ip_tx_ila_cfg0 (int nFMC)  
{
    int nBankID     = 0;
    int nDeviceID   = 0;
    int nWdata      = ( (nBankID & 0xF) << 8) + (nDeviceID & 0xFF);

    int nAddr = (ADR_BASE_JESD + (nFMC * ADR_FMC_STEP) + REG_JESD_CTRL_TX_ILA_CFG0);
    Xil_Out32(nAddr, nWdata);
}


//---------------------------------------------------------
// REG_JESD_CTRL_TX_ILA_CFG1 
// #define     REG_JESD_CTRL_TX_ILA_CFG1   0x074    // 
// 31:26 –   Reserved
// 25:24 0x0 CS (Control bits per Sample). Binary value.
// 23:21 –   Reserved
// 20:16 0x0 N' (Totals bits per Sample). Binary value minus 1.  [5-bit field]
// 15:13 –   Reserved
// 12:8 0x0  N (Converter Resolution). Binary value minus 1.     [5-bit field]
//  7:0 0x0  M (Converters per Device). Binary value minus 1.
//
// FMC216 default JESD204B parameters (UM s3.7.6):
//   M=4  converters per device (4 DAC channels per DAC39J84)
//   N=16 converter resolution (16-bit DAC)
//   N'=16 total bits per sample
//   CS=0 no control bits
//---------------------------------------------------------
void set_jesd_ip_tx_ila_cfg1 (int nFMC)  
{
    int nCSbitsPerSample        =  0;  // CS=0
    int nTotalBitsPerSample     = 16;  // N'=16 (register = N'-1 = 15)
    int nConverterResolution    = 16;  // N=16  (register = N-1  = 15)
    int nConvertersPerDevice    =  4;  // M=4   (register = M-1  = 3)

    int nWdata      = ( ((nCSbitsPerSample         & 0x03) << 24)
                    +   (((nTotalBitsPerSample-1)  & 0x1F) << 16)  // 5-bit field [20:16]
                    +   (((nConverterResolution-1) & 0x1F) <<  8)  // 5-bit field [12:8]
                    +   (((nConvertersPerDevice-1) & 0xFF)      )
    );
    int nAddr = (ADR_BASE_JESD + (nFMC * ADR_FMC_STEP) + REG_JESD_CTRL_TX_ILA_CFG1);

    Xil_Out32(nAddr, nWdata);
}


//---------------------------------------------------------
// REG_JESD_CTRL_TX_ILA_CFG2
// #define     REG_JESD_CTRL_TX_ILA_CFG2   0x078    //
// 28:24 0x0 CF (Control Words per Frame). Binary value.
// 16      0 HD (High Density format)
// 12:8  0x0  S (Samples per Converter per Frame). Binary value minus 1.
//
// FMC216 default JESD204B parameters (UM s3.7.6):
//   S=1 sample per converter per frame (register = S-1 = 0)
//   CF=0, HD=0
//---------------------------------------------------------
void set_jesd_ip_tx_ila_cfg2 (int nFMC)  
{
    int nCF     = 0;  // CF=0 control words per frame
    int nHD     = 0;  // HD=0 normal (not high density) format
    int nS      = 1;  // S=1  samples per converter per frame (register = S-1 = 0)

    int nWdata  = ( ((nCF    & 0x1F) << 24)
                +   ((nHD    & 0x01) << 16)
                +   (((nS-1) & 0x1F) <<  8)
    );

    int nAddr = (ADR_BASE_JESD + (nFMC * ADR_FMC_STEP) + REG_JESD_CTRL_TX_ILA_CFG2);
    Xil_Out32(nAddr, nWdata);
}


//---------------------------------------------------------
// REG_JESD_CTRL_TX_ILA_CFG3
// #define     REG_JESD_CTRL_TX_ILA_CFG3   0x07C    //  
//
// ADJDIR, PHADJ and ADJCNT are only valid for Subclass 2
//---------------------------------------------------------
void set_jesd_ip_tx_ila_cfg3 (int nFMC)  
{
    int nAdjDir = 0;
    int nPhAdj  = 0;
    int nAdjCnt = 0;
    int nWdata  = ( ((nAdjDir & 0x01) << 16)
                +   ((nPhAdj  & 0x0F) <<  4)
                +   ((nAdjCnt & 0x0F)      )
    );

    int nAddr = (ADR_BASE_JESD + (nFMC * ADR_FMC_STEP) + REG_JESD_CTRL_TX_ILA_CFG3);
    Xil_Out32(nAddr, nWdata);
}


//---------------------------------------------------------
// REG_JESD_CTRL_TX_ILA_CFG4 
// #define     REG_JESD_CTRL_TX_ILA_CFG4   0x080    //
// RES1 and RES2 reserved. Must be zero.
//---------------------------------------------------------
void set_jesd_ip_tx_ila_cfg4 (int nFMC)  
{
    int nRES2   = 0;
    int nRES1   = 0;
    int nWdata  = ( ((nRES2 & 0xFF) << 8)
                +   ((nRES1 & 0xFF)     )
    );

    int nAddr = (ADR_BASE_JESD + (nFMC * ADR_FMC_STEP) + REG_JESD_CTRL_TX_ILA_CFG4);
    Xil_Out32(nAddr, nWdata);
}


//---------------------------------------------------------
// REG_JESD_CTRL_TX_ILA_LID 
// Per-lane register. Programs:
//   [20:16] L: total lanes per LINK, encoded as L-1. FMC216 = 2 lanes/DAC => L=2.
//   [ 4: 0] Lane ID: this lane's ID within its link (0..L-1, i.e. 0 or 1).
//
// Lane ID follows the FMC216 physical routing (UM061 p.44), where a DAC's two lanes are
// four apart rather than adjacent:
//     GT lane 0..3 = DAC0..DAC3 LANE0 -> lane ID 0
//     GT lane 4..7 = DAC0..DAC3 LANE1 -> lane ID 1
// so lane ID = nLane / 4.  The DAC expects exactly this (config70 lid0=0, lid1=1 with
// lane_ena=0x03).  This must stay consistent with the g_jesd_tp_fmc0/g_jesd_tp_fmc1
// generate blocks in the top level and with the transceiver assignment in the block design.
//---------------------------------------------------------
void set_jesd_ip_tx_ila_lid  (int nFMC)   
{
    int nLanesPerLink   = 2;  // L=2 per link (matches DAC config76 l_m1=1)
    int nLaneId         = 0;
    int nAddr           = 0;
    int nWdata          = 0;

    // Write the LID register for all 8 physical lanes (2 per link x 4 links).
    for (int nLane = 0 ; nLane < 8 ; nLane++)
    {
        // ID of lane N. Value can be anywhere between 0 and 31. The default value
        // N is set to the lane number. For interfaces using more than 8 lanes and
        // hence multiple JESD204C cores, this register should be programmed to
        // ensure each lane has the correct identifier.
        //nLaneId = (16*nFMC) + nLane;     
        nLaneId = nLane / 4;   // 0 for the DACs' LANE0 group, 1 for the LANE1 group

        nAddr   = (ADR_BASE_JESD + (nFMC * ADR_FMC_STEP) + (nLane * ADR_LANE_STEP) + REG_JESD_CTRL_TX_ILA_LID);

        nWdata  = ( (((nLanesPerLink-1) & 0x1F) << 16)  // L-1 = 1
                  + (( nLaneId          & 0x1F)      )   // lane ID 0/1 within link
        );

        Xil_Out32(nAddr, nWdata);
    }
}


//---------------------------------------------------------
// REG_JESD_CTRL_TX_GT 
//   4  0   TXINHIBIT   Set High to inhibit transmission of TX data
//   3  0   TXELECIDLE  Set High to force idle signal on transmitter output
// 2:1  0x0 TXPD        TX power down
//   0  0   TXPOLARITY  Set High to invert the polarity of the outgoing TX data
//---------------------------------------------------------
void set_jesd_ip_tx_gt       (int nFMC)  
{
    int nTxInhibit      = 0;
    int nTxElecIdle     = 0;
    int nTxPowerDown    = 0;    // Versal only?
    int nTxPolarity     = 0;

    int nAddr           = 0;
    int nWdata = (  ((nTxInhibit   & 0x1) << 4)
                  + ((nTxElecIdle  & 0x1) << 3)
                  + ((nTxPowerDown & 0x3) << 1)
                  + ((nTxPolarity  & 0x1)     )
    );

    for (int nLane = 0 ; nLane < 8 ; nLane++)   /* all 8 GT lanes active (2 per DAC link) */
    {
        nAddr = (ADR_BASE_JESD + (nFMC * ADR_FMC_STEP) + (nLane * ADR_LANE_STEP) + REG_JESD_CTRL_TX_GT);
        Xil_Out32(nAddr, nWdata);
    }
}



//---------------------------------------------------------
// Program Xilinx JESD IP block for Abaco FMC216 links.
// FMC216 + LMK Distribution 'B': DACCLK=200 MHz, interp=2x => f_DATA=100 MSPS,
// LMFC = f_DATA/(S*K) = 100M/(1*16) = 6.25 MHz = SYSREF; GT refclk = 100 MHz on
// p_fmc*_tx_refclk_* (DCLKout10 = Fin/2). Per-link JESD params (L=2, M=4, F=4, S=1,
// K=16, N=16, N'=16, HD=0, subclass 1, scrambling off) must stay aligned with the DAC regs.
// IMPORTANT: the GT line rate (4.0 Gbps) and the 4-link x 2-lane grouping are set in the
// Vivado block-design JESD204 IP, not here — regenerate the IP to match.
//---------------------------------------------------------
void xil_jesd_ip_init(int nFMC)
{
    xil_printf ("xil_jesd_ip_init(nFMC = %d)\r\n", nFMC);

    set_jesd_ip_subclass    (nFMC, SUBCLASS1);
    set_jesd_ip_8B10B_cfg   (nFMC);
    set_jesd_ip_lane_en     (nFMC, 0xFF);   // All 8 GT lanes active (2 lanes x 4 DAC links)
    set_jesd_ip_test_mode   (nFMC);         // Normal
    set_jesd_ip_sysref      (nFMC);         // 
    set_jesd_ip_tx_ila_cfg0 (nFMC);         // 
    set_jesd_ip_tx_ila_cfg1 (nFMC);         // 
    set_jesd_ip_tx_ila_cfg2 (nFMC);         // 
    set_jesd_ip_tx_ila_cfg3 (nFMC);         // 
    set_jesd_ip_tx_ila_cfg4 (nFMC);         // 
    set_jesd_ip_tx_ila_lid  (nFMC);         // 8 GT lanes; LID = nLane/4 (0 or 1)
    set_jesd_ip_tx_gt       (nFMC);         // all 8 GT lanes
    xil_printf ("xil_jesd_ip_init(nFMC = %d) done\r\n", nFMC);
}


//---------------------------------------------------------
// Report the JESD204B TX link state.
//
// STAT_STATUS (0x060) in 8B10B TX mode:
//   bit  1  sysr_cap   SYSREF edge captured — must be 1 for subclass 1
//   bit  2  sysr_err   SYSREF arrived at the wrong LMFC phase
//   bit 12  sync       SYNC~ from the DACs (1 = DACs are happy, link up)
//
// The pulse block sees the same SYNC~ lines: REG_STATUS bit 4 is set while any
// enabled channel is out of sync, and REG_STATUS_JESD gives it per channel.
//---------------------------------------------------------
void jesd_link_status(int nFMC)
{
    int nStatus = Xil_In32(ADR_JESD(nFMC, REG_JESD_STAT_STATUS));
    int nGStat  = Xil_In32(ADR_PULSE_REG_GSTATUS);
    int nChStat = Xil_In32(ADR_PULSE_REG_CHSTATUS);

    xil_printf ("JESD FMC%d STAT_STATUS = 0x%08X : sysref_captured=%d sysref_err=%d sync=%d\r\n",
                nFMC, nStatus,
                (nStatus >> 1) & 1, (nStatus >> 2) & 1, (nStatus >> 12) & 1);

    xil_printf ("  pulse block: busy=%d jesd_error=%d  per-channel not-synced mask = 0x%08X\r\n",
                nGStat & 1, (nGStat >> 4) & 1, nChStat);

    for (int nLane = 0 ; nLane < 8 ; nLane++)
        xil_printf ("  lane %d: ILA_LID = 0x%08X\r\n", nLane,
                    Xil_In32(ADR_JESD_LANE(nFMC, nLane, REG_JESD_CTRL_TX_ILA_LID)));
}


//---------------------------------------------------------
// Set the PLL2 divisor
//---------------------------------------------------------
void set_lmk_pll2_div  (int nDiv)
{
	int nWdata = nDiv & 0x0FFF;

    xil_printf ("fmc216 set PLL2 clk divisor = %d\r\n", nDiv);

    iic_write_clk_reg(ADR_REG_LMK_PLL2_R1, (nWdata >> 8));   // Upper 4 bits
    iic_write_clk_reg(ADR_REG_LMK_PLL2_R0, (nWdata & 0xFF)); // Lower 8 bits
}

//---------------------------------------------------------
// PLL1 reference selector (which LMK04828 CLKinX to use, dual-loop mode).
//   2 = on-board CCLD-033-50 100 MHz   (Dual-Loop 'F'; FMC216 native build)
//   1 = front-panel EXT CLK IN         (Dual-Loop 'X' expects 100 MHz so PLL1_R=1250;
//                                       Distribution 'B' uses 200 MHz on this same SMA)
//   0 = trigger MUX path               (CLKin0; not normally a clock source)
//
// All three downstream targets (DACCLK, GT refclk, SYSREF) are unchanged
// across these choices because PLL2 is steered by OSCin (491.52 MHz VCXO),
// and OSCin = CLKinX * PLL1_N / CLKinX_R = 100 MHz * 6144 / 1250 = 491.52 MHz
// for any of the three sources as long as CLKin?_R is programmed to 1250.
//---------------------------------------------------------
#define LMK_PLL1_CLKIN_ONBOARD   2
#define LMK_PLL1_CLKIN_EXTERNAL  1
#define LMK_PLL1_CLKIN_TRIG      0

static int s_lmk_pll1_clkin = LMK_PLL1_CLKIN_ONBOARD;

//---------------------------------------------------------
// LMK04828 clock topology selector (TI SNAS605 §9.4).
//
//   LMK_MODE_DUAL_LOOP   : PLL1 (CLKin ? VCXO) + PLL2 (VCXO ? internal VCO 2400 MHz)
//                          ? DCLKoutX = 100 MHz (÷24), SYSREF = 3.125 MHz (÷768).
//                          Datasheet §9.4.1, Table 5.  Native FMC216 use case.
//
//   LMK_MODE_DISTRIBUTION: Both PLLs and OSCin powered down.  External CLKin1/Fin
//                          drives the device clock and SYSREF dividers directly via
//                          VCO_MUX = External.  Bring-up Fin = 200 MHz:
//                              DAC DCLKoutX = Fin (DCLKoutX_MUX = 2 Bypass)
//                              DCLKout10    = Fin / 2 = 100 MHz (FPGA GT refclk)
//                              SYSREF       = Fin / 32 = 6.25 MHz
//                          Datasheet §9.4.5, Table 10 + §9.7.2.1 footnote + §9.7.3.3.
//                          No PLL lock required ? useful as a fallback when the VCXO
//                          / PLL1 path is unavailable or fails to lock.
//
// In Distribution Mode, the PLL1 CLKinX selector still chooses which input pin Fin
// listens to.  For the FMC216 the SMA is wired to CLKin1, so the natural pairing is
// LMK_MODE_DISTRIBUTION + LMK_PLL1_CLKIN_EXTERNAL.
//---------------------------------------------------------
#define LMK_MODE_DUAL_LOOP    0
#define LMK_MODE_DISTRIBUTION 1

static int s_lmk_mode = LMK_MODE_DUAL_LOOP;

static const char *lmk_mode_str(int mode)
{
    switch (mode) {
        case LMK_MODE_DUAL_LOOP:    return "Dual-Loop (PLL1+PLL2, VCO=2400 MHz)";
        case LMK_MODE_DISTRIBUTION: return "Distribution (PLLs bypassed, Fin -> dividers)";
        default:                    return "?";
    }
}

static const char *lmk_pll1_clkin_str(int src)
{
    switch (src) {
        case 0: return "CLKin0 (trigger MUX)";
        case 1: return "CLKin1 (external SMA)";
        case 2: return "CLKin2 (on-board 100 MHz CCLD-033-50)";
        default: return "?";
    }
}

//---------------------------------------------------------
// Override the regmap defaults for whichever CLKinX is currently
// selected as the PLL1 reference.  This is called from fmc216_clks_init()
// AFTER the sorted 0x002..0x165 regmap write, so it can correct three
// things that the static regmap can't know about at compile time:
//
//   1. CLKin?_R divider: must be 1250 (= 100 MHz / 80 kHz) on whichever
//      input is wired to a 100 MHz reference.  The default regmap programs
//      CLKin2_R = 1250 but leaves CLKin0_R = 120 and CLKin1_R = 150 (POR
//      placeholders for unused inputs), so switching to CLKin1 without
//      this override would put f_PD1 at ~667 kHz and OSCin at ~4.1 GHz.
//
//   2. CLKin?_TYPE in 0x146:
//        - on-board CCLD-033-50 on CLKin2 is single-ended LVCMOS  -> MOS
//        - external SMA on CLKin1 is AC-coupled sine/square      -> bipolar
//      (CLKin0 left at bipolar; this path isn't used for PLL1.)
//
//   3. CLKin_SEL_MODE in 0x147[6:4]: selects the manual override source.
//
// f_PD1, OSCin, f_VCO, DCLKout, and SYSREF are all unchanged after this
// override completes for any choice of s_lmk_pll1_clkin.
//---------------------------------------------------------
static void lmk_apply_clkin_source_overrides(void)
{
    int r146 = iic_read_clk_reg(ADR_REG_LMK_CLKIN) & 0xFF;
    int r147 = iic_read_clk_reg(ADR_REG_LMK_CLKIN_POL) & 0xFF;

    xil_printf("fmc216 PLL1 reference source -> %s\r\n",
               lmk_pll1_clkin_str(s_lmk_pll1_clkin));

    switch (s_lmk_pll1_clkin) {
        case LMK_PLL1_CLKIN_TRIG:
            (void)iic_write_clk_reg(ADR_REG_LMK_CLKIN0_R1, 0x04);    /* CLKin0_R[13:8] = 0x04 */
            (void)iic_write_clk_reg(ADR_REG_LMK_CLKIN0_R0, 0xE2);    /* CLKin0_R[7:0]  = 0xE2 -> R=1250 */
            r146 &= ~0x01;                                            /* CLKin0_TYPE = 0 (bipolar) */
            r147 = (r147 & 0x0F) | (0 << 4);                          /* CLKin_SEL_MODE = 0 (CLKin0 manual) */
            break;

        case LMK_PLL1_CLKIN_EXTERNAL:
            (void)iic_write_clk_reg(ADR_REG_LMK_CLKIN1_R1, 0x04);    /* CLKin1_R[13:8] = 0x04 */
            (void)iic_write_clk_reg(ADR_REG_LMK_CLKIN1_R0, 0xE2);    /* CLKin1_R[7:0]  = 0xE2 -> R=1250 */
            r146 &= ~0x02;                                            /* CLKin1_TYPE = 0 (bipolar; AC-coupled SMA) */
            r147 = (r147 & 0x0F) | (1 << 4);                          /* CLKin_SEL_MODE = 1 (CLKin1 manual) */
            break;

        case LMK_PLL1_CLKIN_ONBOARD:
        default:
            (void)iic_write_clk_reg(ADR_REG_LMK_CLKIN2_R1, 0x04);    /* CLKin2_R[13:8] = 0x04 */
            (void)iic_write_clk_reg(ADR_REG_LMK_CLKIN2_R0, 0xE2);    /* CLKin2_R[7:0]  = 0xE2 -> R=1250 */
            r146 |= 0x04;                                             /* CLKin2_TYPE = 1 (MOS; single-ended LVCMOS) */
            r147 = (r147 & 0x0F) | (2 << 4);                          /* CLKin_SEL_MODE = 2 (CLKin2 manual) */
            break;
    }

    (void)iic_write_clk_reg(ADR_REG_LMK_CLKIN,     r146);
    (void)iic_write_clk_reg(ADR_REG_LMK_CLKIN_POL, r147);
}

//---------------------------------------------------------
// Program LMK04828 for Distribution Mode with an external 200 MHz reference on
// CLKin1 / Fin (FMC216 SMA).  After this returns, the chip routes:
//     Fin (200 MHz) -> VCO_MUX (External) -> per-output dividers
//
// Produces (no PLL lock required):
//     DCLKout0/2/4/6/8/12 = 200 MHz  (DCLKoutX_MUX = 2 Bypass)
//     DCLKout10           = 100 MHz  (divider = 2, FPGA GT refclk)
//     SDCLKout3 = SYSREF  = 6.25 MHz (SYSREF_DIV = 32)
//
// Datasheet references (SNAS605AS):
//   §9.4.5 Distribution Mode + Table 10  : power-down map and VCO_MUX = External
//   §9.7.3.1 Table 26 (0x138)            : VCO_MUX field encoding
//   §9.7.3.7 Table 32 (0x140)            : PLL1/VCO/OSCin power-down bits
//   §9.7.4.2 Table 41 (0x147)            : CLKin_SEL_MODE / CLKin1_OUT_MUX = Fin
//   §9.7.2.1 Table 19 + footnote (1)     : DCLKoutX_MUX = 2 Bypass ? effective ÷1
//   §9.7.3.3 Table 28 (0x13A/13B)        : SYSREF_DIV (8..8191); 32 valid
//   §10.3.1/10.3.2                       : CLKin1 receiver — bipolar for AC-coupled
// FMC216 UM061 §3.7 ("External clock"):
//   Both on-board oscillators (OSC100_EN, OSC491_EN in CPLD reg1) MUST be off when
//   in Distribution Mode to keep them from leaking into the LMK or out of the SMA.
//   That gating is handled in fmc216_clks_init() before this function runs, not here.
//
// This is called from fmc216_clks_init() AFTER the sorted 0x002..0x165 regmap write
// (which establishes the Dual-Loop defaults), overriding only the fields that have
// to change for Distribution Mode.  All PLL waits and 0x166..0x174 PLL2-path
// writes in fmc216_clks_init() are skipped when s_lmk_mode == LMK_MODE_DISTRIBUTION.
//---------------------------------------------------------
/* Device-clock pairs that run straight through (DCLKoutX_MUX = 2, Bypass).
 * DCLKout10 is deliberately absent: it feeds the FPGA GT reference clock and
 * uses the divider path instead — see LMK_DIST_DCLK10_DIV below. */
static const int s_lmk_dclk_mux_addrs[6] = {
    ADR_REG_LMK_DCLK0_ADLY, ADR_REG_LMK_DCLK2_ADLY, ADR_REG_LMK_DCLK4_ADLY,
    ADR_REG_LMK_DCLK6_ADLY, ADR_REG_LMK_DCLK8_ADLY, ADR_REG_LMK_DCLK12_ADLY,
};

/* DCLKout10 -> FMC216 GBTCLK1 -> FPGA fmc0/1_tx_refclk.  The DAC device clocks
 * follow Fin, but the GT reference must stay at 100 MHz, so with Fin = 200 MHz
 * this divider is 2.  Valid range 2..31 (1 is illegal with DCLKoutX_MUX = 0;
 * use bypass for divide-by-1).  SNAS605 Table 19. */
#define LMK_DIST_DCLK10_DIV     2

/* Name is leftover: Fin is 200 MHz. DAC clocks bypass; DCLKout10 is ÷2. */
static void lmk_apply_distribution_overrides_fin_100m(void)
{
    int r140, r147, r138;
    unsigned i;

    xil_printf("fmc216 LMK04828 -> Distribution Mode (CLKin1/Fin = 200 MHz)\r\n");
    xil_printf("  Target DACCLK = 200 MHz (bypass), DCLKout10 = 100 MHz (÷2), SYSREF = 6.25 MHz (÷32)\r\n");

    /* --- 0x140 power-downs (Table 10): PLL1, VCO_LDO, VCO, OSCin off; SYSREF block on ---
     * PLL1_PD=1 VCO_LDO_PD=1 VCO_PD=1 OSCin_PD=1 SYSREF_GBL_PD=0 SYSREF_PD=0
     * SYSREF_DDLY_PD=0 SYSREF_PLSR_PD=1.  Value = 0xF1.  Bit assignment per Table 32. */
    r140 = 0xF1;
    (void)iic_write_clk_reg(ADR_REG_LMK_PLL1, r140);

    /* --- 0x173 PLL2_PRE_PD=1, PLL2_PD=1 (Table 10) --- */
    (void)iic_write_clk_reg(ADR_REG_LMK_PLL2_PRE_PD, 0x60);

    /* --- 0x138 VCO_MUX = 2 (External via CLKin1/Fin), OSCout_FMT = 0 (powerdown OSCout)
     * Bits [6:5] = VCO_MUX, bit 4 = OSCout_MUX, bits [3:0] = OSCout_FMT.
     * In Distribution Mode the on-board VCXO/OSCin is powered down, so OSCout must
     * be powered down too (0x40, OSCout_FMT = 0).  See Tables 10 and 26. */
    r138 = 0x40;
    (void)iic_write_clk_reg(ADR_REG_LMK_OSC, r138);

    /* --- 0x147 (Table 41) ---
     * CLKin_SEL_MODE = 1 (CLKin1 manual) [bits 6:4]
     * CLKin1_OUT_MUX = 0 (Fin)            [bits 3:2]
     * CLKin0_OUT_MUX = 0 (SYSREF mux)     [bits 1:0]  (CLKin0 not used here)
     * Result = 0x10 */
    r147 = 0x10;
    (void)iic_write_clk_reg(ADR_REG_LMK_CLKIN_POL, r147);

    /* --- 0x146: keep CLKin1 enabled, bipolar receiver (already 0x3C from regmap default)
     * No write needed; lmk_apply_clkin_source_overrides() is NOT called for Distribution. */

    /* --- DCLKoutX_MUX = 2 (Bypass) for the six DAC device-clock pairs (Table 19 + footnote (1)).
     * Each ADLY register 0x103/0x10B/.../0x133 has DCLKoutX_MUX in bits [1:0].
     * Bypass makes the output equal to VCO_MUX source (= Fin in our case),
     * effective divide of 1 regardless of the DIV field in 0x100/0x108/... */
    for (i = 0; i < sizeof(s_lmk_dclk_mux_addrs)/sizeof(s_lmk_dclk_mux_addrs[0]); i++) {
        int addr = s_lmk_dclk_mux_addrs[i];
        int v = iic_read_clk_reg(addr) & 0xFC;   /* preserve ADLY + ADLY_MUX bits */
        v |= 0x02;                                /* DCLKoutX_MUX = 2 (Bypass) */
        (void)iic_write_clk_reg(addr, v);
    }

    /* --- DCLKout10 = Fin / LMK_DIST_DCLK10_DIV (FPGA GT reference clock) ---
     * 0x128[4:0] = DCLKout10_DIV (Table 19), bits 6:5 (ODL/IDL) preserved.
     * 0x12B[1:0] = DCLKout10_MUX = 0 (Divider only, Table 21); ADLY/ADLY_MUX
     * preserved.  The divider is started/aligned by the SPI SYNC event that
     * fmc216_clks_init() issues after the register image is loaded. */
    {
        int v128 = (iic_read_clk_reg(ADR_REG_LMK_CLK10_11_ODL) & 0x60) | (LMK_DIST_DCLK10_DIV & 0x1F);
        int v12b =  iic_read_clk_reg(ADR_REG_LMK_DCLK10_ADLY)  & 0xFC;
        (void)iic_write_clk_reg(ADR_REG_LMK_CLK10_11_ODL, v128);
        (void)iic_write_clk_reg(ADR_REG_LMK_DCLK10_ADLY,  v12b);
        xil_printf("  DCLKout10 (FPGA GT refclk) = Fin / %d  [0x128=%02X 0x12B=%02X]\r\n",
                   LMK_DIST_DCLK10_DIV, v128, v12b);
    }

    /* --- SYSREF_DIV = 32 ? SDCLKout3 = 200 MHz / 32 = 6.25 MHz (Table 28, §9.7.3.3) ---
     * 0x13A[4:0] = SYSREF_DIV[12:8] = 0; 0x13B[7:0] = SYSREF_DIV[7:0] = 32.  Valid range 8..8191. */
    (void)iic_write_clk_reg(ADR_REG_LMK_SYSREF_DIV1, 0x00);
    (void)iic_write_clk_reg(ADR_REG_LMK_SYSREF_DIV0, 0x20);
}

//---------------------------------------------------------
// Set CLKin_SEL_MODE in 0x147[6:4] to whichever CLKinX is currently
// the configured PLL1 reference (s_lmk_pll1_clkin).
// Bit 7 is CLKin_SEL_POL (active high). The lower nibble
// (CLKin1_OUT_MUX, CLKin0_OUT_MUX) is preserved from readback.
//---------------------------------------------------------
void set_lmk_clk_src()
{
    int nRdata = 0;
    int nWdata = 0;
    int src = s_lmk_pll1_clkin & 0x7;

    xil_printf ("fmc216 set clk source to clkin%d (%s)\r\n",
                src, lmk_pll1_clkin_str(src));

    // Read current value of 0x147 to preserve CLKinX_OUT_MUX bits
    nRdata = iic_read_clk_reg(ADR_REG_LMK_CLKIN_POL);

    // Set CLKin_SEL_MODE [6:4] to the chosen manual source, preserve other bits
    nWdata = (nRdata & 0x0F) | (src << 4);
    iic_write_clk_reg(ADR_REG_LMK_CLKIN_POL, nWdata);

    xil_printf ("fmc216 set clk source done (0x147 = 0x%02X)\r\n", nWdata);
}


//----------------------------------------------------------------
// LMK04828 SPI write trace (enabled only during fmc216_clks_init).
// Logs every iic_write_clk_reg: sequence, phase label, addr, 8-bit data.
//----------------------------------------------------------------
static unsigned int s_lmk_dbg_seq;
static int          s_lmk_dbg_on;
static const char  *s_lmk_dbg_phase = "";

static void lmk_dbg_set_phase(const char *phase)
{
    s_lmk_dbg_phase = (phase != NULL) ? phase : "";
    xil_printf("\r\n--- LMK04828 phase: %s ---\r\n", s_lmk_dbg_phase);
}

static void lmk_dbg_emit_wr(int nReg, int nData)
{
    int addr = nReg & 0x1FFF;
    int data8 = nData & 0xFF;

    if (!s_lmk_dbg_on)
        return;
    s_lmk_dbg_seq++;
    (void)xil_printf("LMK %5u  %-30s  0x%03X <- 0x%02X\r\n",
        s_lmk_dbg_seq, s_lmk_dbg_phase, addr, data8);
}

//----------------------------------------------------------------
// LMK04828: map register address to programming value.
// Uses arr_reg_addr_clk / arr_reg_default_clk (regmap_lmk04828_pll.h);
// missing addresses default to 0. TI §9.5.1: 0x145 must be 0x7F;
// 0x171/0x172 must be 0xAA / 0x02 (not the POR placeholders in the table).
//----------------------------------------------------------------
static int lmk04828_reg_data(unsigned int addr)
{
    int i;

    for (i = 0; i < NUM_REGS_LMK04828; i++) {
        if ((unsigned int)arr_reg_addr_clk[i] == addr) {
            int v = arr_reg_default_clk[i];

            if (addr == ADR_REG_LMK_CONST0)
                return 0x7F;
            if (addr == ADR_REG_LMK_CONST1)
                return 0xAA;
            if (addr == ADR_REG_LMK_CONST2)
                return 0x02;
            return v;
        }
    }
    if (addr == ADR_REG_LMK_CONST0)
        return 0x7F;
    if (addr == ADR_REG_LMK_CONST1)
        return 0xAA;
    if (addr == ADR_REG_LMK_CONST2)
        return 0x02;
    return 0;
}

static int lmk_addr_cmp(const void *pa, const void *pb)
{
    int a = *(const int *)pa;
    int b = *(const int *)pb;
    if (a < b)
        return -1;
    if (a > b)
        return 1;
    return 0;
}

static void lmk04828_write_addrs_sorted_unique(int *addrs, int na)
{
    int j, last = -1;

    if (na <= 0)
        return;
    qsort(addrs, (size_t)na, sizeof(int), lmk_addr_cmp);
    for (j = 0; j < na; j++) {
        if (addrs[j] == last)
            continue;
        last = addrs[j];
        (void)iic_write_clk_reg(last, lmk04828_reg_data(last));
    }
}

static int lmk04828_fill_addrs_from_table(int min_a, int max_a, int *out, int maxout)
{
    int i, n = 0;

    for (i = 0; i < NUM_REGS_LMK04828 && n < maxout; i++) {
        int a = arr_reg_addr_clk[i];
        if (a >= min_a && a <= max_a)
            out[n++] = a;
    }
    return n;
}

static void lmk_report_reg(const char *label, int addr, int expected, int check_expected)
{
    int rd = iic_read_clk_reg(addr) & 0xFF;
    if (check_expected) {
        (void)xil_printf("LMK %-20s [0x%03X] = 0x%02X (exp 0x%02X) %s\r\n",
            label, addr & 0x1FFF, rd, expected & 0xFF,
            (rd == (expected & 0xFF)) ? "PASS" : "FAIL");
    } else {
        (void)xil_printf("LMK %-20s [0x%03X] = 0x%02X\r\n",
            label, addr & 0x1FFF, rd);
    }
}

//----------------------------------------------------------------
// LMK04828 PLL2_P[2:0] field encoding (SNAS605 Table for PLL2_P).
//   field code (bits 7:5 of 0x162) ? physical prescaler value
//----------------------------------------------------------------
static int lmk_decode_pll2_p(int field)
{
    /* LMK04828 datasheet Table 66, register 0x162[7:5].  Field 0 ? P = 8 (NOT 2).
     * The previous LUT had this off-by-one, which caused the diagnostic to report
     * a fictitious "P = 2" while the silicon actually used P = 8 — masking an
     * f_VCO ~9.6 GHz that's outside both VCO bands (i.e. PLL2 FCAL never locked). */
    static const int p_lut[8] = { 8, 2, 2, 3, 4, 5, 6, 7 };
    return p_lut[field & 0x7];
}

//----------------------------------------------------------------
// Read PLL1/PLL2 lock status, dividers, and CLKin/LOS.  Compute the
// implied f_VCO assuming OSCin = LMK_OSCIN_MHZ_X1000 and flag whether
// PLL2 is locked + lying inside a usable VCO band.
//
// Dual-Loop diagnostic: implied f_VCO from OSCin and PLL2 dividers.
// In Distribution 'B' both PLLs are off — lock bits and the ÷24 DCLKout
// print are not meaningful. SYSREF is then Fin/SYSREF_DIV (200/32 = 6.25 MHz),
// not LMK_TARGET_SYSREF_MHZ_X1000 (3.125 MHz Dual-Loop table).
//----------------------------------------------------------------
static void lmk_dump_pll_state(void)
{
    int rb182 = iic_read_clk_reg(ADR_REG_LMK_PLL1_LD_LOST) & 0xFF;
    int rb183 = iic_read_clk_reg(ADR_REG_LMK_PLL2_LD_LOST) & 0xFF;
    int rb184 = iic_read_clk_reg(ADR_REG_LMK_RB_DAC_VALUE1) & 0xFF;
    int osc   = iic_read_clk_reg(ADR_REG_LMK_OSC) & 0xFF;
    int p162  = iic_read_clk_reg(ADR_REG_LMK_PLL2_P) & 0xFF;
    int r1    = iic_read_clk_reg(ADR_REG_LMK_PLL2_R1) & 0xFF;
    int r0    = iic_read_clk_reg(ADR_REG_LMK_PLL2_R0) & 0xFF;
    int n2    = iic_read_clk_reg(ADR_REG_LMK_PLL2_FCAL) & 0xFF;
    int n1    = iic_read_clk_reg(ADR_REG_LMK_PLL2_N1) & 0xFF;
    int n0    = iic_read_clk_reg(ADR_REG_LMK_PLL2_N0) & 0xFF;
    int n2i   = lmk04828_reg_data((unsigned int)ADR_REG_LMK_PLL2_FCAL) & 0xFF;
    int n1i   = lmk04828_reg_data((unsigned int)ADR_REG_LMK_PLL2_N1)   & 0xFF;
    int n0i   = lmk04828_reg_data((unsigned int)ADR_REG_LMK_PLL2_N0)   & 0xFF;
    int misc2 = iic_read_clk_reg(ADR_REG_LMK_PLL2_MISC) & 0xFF;
    int pwrdn = iic_read_clk_reg(ADR_REG_LMK_PLL2_PRE_PD) & 0xFF;
    int pll140= iic_read_clk_reg(ADR_REG_LMK_PLL1) & 0xFF;
    int sd1   = iic_read_clk_reg(ADR_REG_LMK_SYSREF_DIV1) & 0xFF;
    int sd0   = iic_read_clk_reg(ADR_REG_LMK_SYSREF_DIV0) & 0xFF;
    int clkin = iic_read_clk_reg(ADR_REG_LMK_CLKIN) & 0xFF;
    int polmx = iic_read_clk_reg(ADR_REG_LMK_CLKIN_POL) & 0xFF;
    int ck2r1 = iic_read_clk_reg(ADR_REG_LMK_CLKIN2_R1) & 0xFF;
    int ck2r0 = iic_read_clk_reg(ADR_REG_LMK_CLKIN2_R0) & 0xFF;
    int p1n1  = iic_read_clk_reg(ADR_REG_LMK_PLL1_N1) & 0xFF;
    int p1n0  = iic_read_clk_reg(ADR_REG_LMK_PLL1_N0) & 0xFF;
    int cpld1 = iic_read_cpld_reg(IIC_CPLD_REG_CTRL) & 0xFF;

    int pll1_locked = (rb182 & LMK_RB_PLL1_LD_BIT) ? 1 : 0;
    int pll1_lost   = (rb182 & 0x04) ? 1 : 0;   /* RB_PLL1_LD_LOST sticky */
    int pll2_locked = (rb183 & LMK_RB_PLL2_LD_BIT) ? 1 : 0;
    int pll2_lost   = (rb183 & 0x04) ? 1 : 0;   /* RB_PLL2_LD_LOST sticky */
    int vco_mux     = (osc >> 5) & 0x3;
    int oscout_fmt  =  osc       & 0xF;
    int p_field     = (p162 >> 5) & 0x7;
    int p_val       = lmk_decode_pll2_p(p_field);
    int doubler     = (p162 & 0x1) ? 2 : 1;
    int xtal_en     = (p162 >> 1) & 0x1;
    int oscfreq     = (p162 >> 2) & 0x7;
    int pll2_r      = ((r1 & 0x0F) << 8) | r0;
    int pll2_n_spi  = ((n2 & 0x03) << 16) | (n1 << 8) | n0;
    int pll2_n_map  = ((n2i & 0x03) << 16) | (n1i << 8) | n0i;
    /* After soft reset, 0x166..0x168 stay at POR until pll2_path runs.  Reading them early
     * (e.g. pll1_wait_lock failed ? dump before pll2_path) yields N_spi˜12 and bogus f_VCO.
     * Frequency math below uses regmap target whenever SPI disagrees with intent. */
    int pll2_n_math = (pll2_n_spi != pll2_n_map) ? pll2_n_map : pll2_n_spi;
    int sysref_div  = ((sd1 & 0x1F) << 8) | sd0;
    int ck2_en      = (clkin >> 5) & 0x1;
    int ck1_en      = (clkin >> 4) & 0x1;
    int ck0_en      = (clkin >> 3) & 0x1;
    int ck2_typ     = (clkin >> 2) & 0x1;
    int ck1_typ     = (clkin >> 1) & 0x1;
    int ck0_typ     = (clkin     ) & 0x1;
    int sel_mode    = (polmx >> 4) & 0x7;
    int clkin2_r    = ((ck2r1 & 0x3F) << 8) | ck2r0;
    int pll1_n      = ((p1n1  & 0x3F) << 8) | p1n0;

    /* Implied f_VCO and downstream clocks assuming OSCin = LMK_OSCIN_MHZ_X1000 */
    long long oscin_x1000  = (long long)LMK_OSCIN_MHZ_X1000;
    long long fpd2_x1000   = (pll2_r > 0) ? (oscin_x1000 * doubler) / pll2_r : 0;
    long long fvco_x1000   = fpd2_x1000 * (long long)p_val * (long long)pll2_n_math;
    long long fdclk_x1000  = (fvco_x1000 / 24);                /* DCLKoutX_DIV = 24 in regmap */
    long long fsysref_x1k  = (sysref_div > 0) ? (fvco_x1000 / sysref_div) : 0;
    long long fvco_mhz     = fvco_x1000 / 1000;

    int in_vco0 = (fvco_mhz >= LMK_VCO0_MIN_MHZ && fvco_mhz <= LMK_VCO0_MAX_MHZ);
    int in_vco1 = (fvco_mhz >= LMK_VCO1_MIN_MHZ && fvco_mhz <= LMK_VCO1_MAX_MHZ);

    (void)xil_printf("---- LMK PLL state ----\r\n");
    (void)xil_printf("  CPLD reg1 (osc gates)      = 0x%02X (OSC100_EN=%d OSC491_EN=%d RST_DACS_L=%d LMK_RST=%d)\r\n",
                     cpld1,
                     (cpld1     ) & 0x1,
                     (cpld1 >> 1) & 0x1,
                     (cpld1 >> 2) & 0x1,
                     (cpld1 >> 3) & 0x1);
    /* Sanity hint vs current mode (UM061 §3.7 + dual-loop default). */
    {
        int osc_on = (cpld1 & 0x03) == 0x03;
        int osc_off = (cpld1 & 0x03) == 0x00;
        if (s_lmk_mode == LMK_MODE_DISTRIBUTION && !osc_off) {
            (void)xil_printf("    !! Distribution Mode expects OSC100_EN=0 AND OSC491_EN=0 (UM061 §3.7).\r\n");
        } else if (s_lmk_mode == LMK_MODE_DUAL_LOOP && !osc_on) {
            (void)xil_printf("    !! Dual-Loop expects OSC100_EN=1 AND OSC491_EN=1 — PLL1/PLL2 cannot lock otherwise.\r\n");
        }
    }
    (void)xil_printf("  PLL1 lock (0x182=%02X bit1) = %d  (LD_LOST sticky bit2 = %d ? %s)\r\n",
                     rb182, pll1_locked, pll1_lost,
                     pll1_lost ? "LOCKED then LOST (marginal noise)" :
                                 (pll1_locked ? "currently LOCKED" : "never LOCKED (no signal at receiver?)"));
    (void)xil_printf("  PLL2 lock (0x183=%02X bit1) = %d  (LD_LOST sticky bit2 = %d ? %s)\r\n",
                     rb183, pll2_locked, pll2_lost,
                     pll2_lost ? "LOCKED then LOST" :
                                 (pll2_locked ? "currently LOCKED" : "never LOCKED"));
    (void)xil_printf("  CLKin status (0x184)       = %02X (CLKin2_SEL=%d CLKin1_SEL=%d CLKin0_SEL=%d  CLKin1_LOS=%d CLKin0_LOS=%d)\r\n",
                     rb184,
                     (rb184 >> 5) & 0x1,
                     (rb184 >> 4) & 0x1,
                     (rb184 >> 3) & 0x1,
                     (rb184 >> 1) & 0x1,
                     (rb184     ) & 0x1);
    (void)xil_printf("  CLKin enable/type (0x146)  = %02X (CLKin2_EN=%d type=%s, CLKin1_EN=%d type=%s, CLKin0_EN=%d type=%s)\r\n",
                     clkin,
                     ck2_en, ck2_typ ? "MOS" : "bipolar",
                     ck1_en, ck1_typ ? "MOS" : "bipolar",
                     ck0_en, ck0_typ ? "MOS" : "bipolar");
    (void)xil_printf("  CLKin_SEL_MODE (0x147[6:4])= %d (%s)\r\n",
                     sel_mode,
                     (sel_mode == 0) ? "CLKin0 manual" :
                     (sel_mode == 1) ? "CLKin1 manual" :
                     (sel_mode == 2) ? "CLKin2 manual" :
                     (sel_mode == 3) ? "Pin select" :
                     (sel_mode == 4) ? "Auto" : "reserved");
    (void)xil_printf("  PLL1 dividers              : CLKin2_R=%d  PLL1_N=%d  ? f_PD1 = %lu Hz\r\n",
                     clkin2_r, pll1_n,
                     (clkin2_r > 0) ? (unsigned long)((LMK_CLKIN2_MHZ_X1000 * 1000UL) / (unsigned)clkin2_r) : 0UL);
    (void)xil_printf("  VCO_MUX / OSCout_FMT (0x138)= %02X  VCO=%s, OSCout_FMT=%d (%s)\r\n",
                     osc,
                     (vco_mux == 0) ? "VCO0" : (vco_mux == 1) ? "VCO1" : "external",
                     oscout_fmt,
                     (oscout_fmt == 0)  ? "powerdown (no DC bias on shared CLKin2 pins)" :
                     (oscout_fmt == 1)  ? "LVDS (weak driver, preserves DC bias)" :
                     (oscout_fmt == 4)  ? "LVPECL 1600 mVpp" :
                     (oscout_fmt == 5)  ? "LVPECL 2000 mVpp" :
                     (oscout_fmt == 14) ? "LVCMOS Off/Off" : "other");
    if (pll2_n_spi != pll2_n_map) {
        (void)xil_printf("  PLL2 N: SPI readback=%d (0x166..168=%02X %02X %02X) ? regmap=%d — frequency math uses regmap\r\n",
                         pll2_n_spi, n2, n1, n0, pll2_n_map);
        (void)xil_printf("        (Expected before pll2_path on first boot; if persistent after pll2_path, SPI/load fault.)\r\n");
    }
    (void)xil_printf("  PLL2 dividers              : R=%d  P=%d (field=%d)  N_spi=%d  N_regmap=%d  doubler=%dx  XTAL=%d  OSCin_FREQ=%d\r\n",
                     pll2_r, p_val, p_field, pll2_n_spi, pll2_n_map, doubler, xtal_en, oscfreq);
    {
        int cp_gain = (misc2 >> 3) & 0x3;
        int cp_pol  = (misc2 >> 2) & 0x1;
        int cp_tri  = (misc2 >> 1) & 0x1;
        int wnd     = (misc2 >> 5) & 0x3;
        static const int cp_uA_lut[4] = { 100, 400, 1600, 3200 };
        (void)xil_printf("  PLL2_MISC (0x169)          = %02X  CP_GAIN=%d (%d µA)  CP_POL=%d (%s)  CP_TRI=%d  WND_SIZE=%d (%s)\r\n",
                         misc2, cp_gain, cp_uA_lut[cp_gain & 0x3],
                         cp_pol, cp_pol ? "positive-slope (WRONG for internal VCO)" : "negative-slope (correct)",
                         cp_tri,
                         wnd, (wnd == 2) ? "3.7 ns (correct)" : "INVALID");
        (void)xil_printf("  PLL2_PRE_PD/PLL2_PD (0x173)= %02X  PLL2_PRE_PD=%d  PLL2_PD=%d  (%s)\r\n",
                         pwrdn, (pwrdn >> 6) & 1, (pwrdn >> 5) & 1,
                         ((pwrdn >> 6) & 1) || ((pwrdn >> 5) & 1) ? "BLOCKED — PLL2 cannot lock" : "PLL2 powered up");
        (void)xil_printf("  Power-downs (0x140)        = %02X  PLL1_PD=%d VCO_LDO_PD=%d VCO_PD=%d OSCin_PD=%d\r\n",
                         pll140,
                         (pll140 >> 7) & 1,
                         (pll140 >> 6) & 1,
                         (pll140 >> 5) & 1,
                         (pll140 >> 4) & 1);
    }
    (void)xil_printf("  SYSREF_DIV (0x13A/B)       = %d\r\n", sysref_div);
    (void)xil_printf("  Assumed OSCin              = %lu.%03lu MHz\r\n",
                     (unsigned long)(oscin_x1000 / 1000), (unsigned long)(oscin_x1000 % 1000));
    (void)xil_printf("  Computed f_PD2             = %lu.%03lu MHz\r\n",
                     (unsigned long)(fpd2_x1000 / 1000), (unsigned long)(fpd2_x1000 % 1000));
    (void)xil_printf("  Computed f_VCO             = %lu.%03lu MHz  [%s]\r\n",
                     (unsigned long)(fvco_x1000 / 1000), (unsigned long)(fvco_x1000 % 1000),
                     in_vco0 ? "in VCO0 band" : in_vco1 ? "in VCO1 band" : "OUTSIDE BOTH BANDS — PLL2 cannot lock!");
    (void)xil_printf("  Computed DCLKoutX (÷24)    = %lu.%03lu MHz\r\n",
                     (unsigned long)(fdclk_x1000 / 1000), (unsigned long)(fdclk_x1000 % 1000));
    (void)xil_printf("  Computed SYSREF            = %lu.%03lu MHz  (target %lu.%03lu MHz)\r\n",
                     (unsigned long)(fsysref_x1k / 1000), (unsigned long)(fsysref_x1k % 1000),
                     (unsigned long)(LMK_TARGET_SYSREF_MHZ_X1000 / 1000),
                     (unsigned long)(LMK_TARGET_SYSREF_MHZ_X1000 % 1000));
    if (!pll2_locked) {
        if (!pll1_locked) {
            (void)xil_printf("  >>> PLL2 NOT LOCKED <<<  PLL1 is not locked — fix PLL1 first (OSCin/VCXO, CLKin refs, scope).\r\n");
            (void)xil_printf("      PLL2 cannot be diagnosed meaningfully until OSCin is steered by PLL1.\r\n");
        } else {
            (void)xil_printf("  >>> PLL2 NOT LOCKED <<<  Verify (a) OSCin from VCXO after PLL1 lock,\r\n");
            (void)xil_printf("      (b) LMK_OSCIN_MHZ_X1000=%d kHz matches hardware, and\r\n",
                             LMK_OSCIN_MHZ_X1000);
            (void)xil_printf("      (c) computed f_VCO lies inside VCO0 (%d-%d) or VCO1 (%d-%d) MHz.\r\n",
                             LMK_VCO0_MIN_MHZ, LMK_VCO0_MAX_MHZ, LMK_VCO1_MIN_MHZ, LMK_VCO1_MAX_MHZ);
        }
    }
    (void)xil_printf("------------------------\r\n");
}

//----------------------------------------------------------------
// PLL1-only deep diagnostic: RB_DAC (VCXO tuning word), static vs
// moving DAC over 50 ms, manual-DAC / holdover / LOS controls, and
// divider readback vs regmap.  Does not change PLL programming.
// Prerequisites: FMC selected, LMK SPI unlocked (same as J sweep).
//----------------------------------------------------------------
static void lmk_dump_pll1_debug(void)
{
    int rb182;
    int rb184_a, rb185_a, rb184_b, rb185_b;
    int dac_a, dac_b, dac_delta;
    int r146, r147, r13f, r143, r14b, r14c, r150;
    int r157, r158, r159, r15a, r15b, r15c, r15d, r15f;
    int clk2_r_spi, pll1_n_spi, pll1_dld;
    int clk2_r_map, pll1_n_map;
    int misc, cp_gain, cp_pol, cp_tri, wnd;
    int rb188;
    unsigned long f_pd1_hz;
    unsigned long lock_floor_us;

    (void)xil_printf("\r\n==== LMK PLL1 deep diagnostic (RB_PLL1_LD path) ====\r\n");

    rb182 = iic_read_clk_reg(ADR_REG_LMK_PLL1_LD_LOST) & 0xFF;
    rb184_a = iic_read_clk_reg(ADR_REG_LMK_RB_DAC_VALUE1) & 0xFF;
    rb185_a = iic_read_clk_reg(ADR_REG_LMK_RB_DAC_VALUE0) & 0xFF;
    dac_a = (((rb184_a >> 6) & 3) << 8) | rb185_a;

    (void)xil_printf("[A] 0x182 status = 0x%02X  RB_PLL1_LD(bit1)=%d  RB_PLL1_LD_LOST(bit2)=%d\r\n",
                     rb182, (rb182 >> 1) & 1, (rb182 >> 2) & 1);

    (void)xil_printf("[B] RB_DAC (PLL1 VCXO tuning) 0x184/185 = %02X %02X  -> 10-bit=%d /1023\r\n",
                     rb184_a, rb185_a, dac_a);
    if (dac_a <= 32)
        (void)xil_printf("    DAC near LOW rail — wrong CP_POL, no OSCin feedback, MAN_DAC, or VCXO fault\r\n");
    else if (dac_a >= (1023 - 32))
        (void)xil_printf("    DAC near HIGH rail — same class of analog/config faults\r\n");

    (void)xil_printf("    0x184 CLKin mirror: SEL2=%d SEL1=%d SEL0=%d  LOS1=%d LOS0=%d\r\n",
                     (rb184_a >> 5) & 1, (rb184_a >> 4) & 1, (rb184_a >> 3) & 1,
                     (rb184_a >> 1) & 1, rb184_a & 1);
    (void)xil_printf("    (TI: no CLKin2_LOS in this byte — dead CLKin2 does not show LOS here.)\r\n");

    usleep(50 * 1000);
    rb184_b = iic_read_clk_reg(ADR_REG_LMK_RB_DAC_VALUE1) & 0xFF;
    rb185_b = iic_read_clk_reg(ADR_REG_LMK_RB_DAC_VALUE0) & 0xFF;
    dac_b = (((rb184_b >> 6) & 3) << 8) | rb185_b;
    dac_delta = dac_b - dac_a;
    (void)xil_printf("[C] RB_DAC after 50 ms: %02X %02X -> 10-bit=%d  delta=%+d\r\n",
                     rb184_b, rb185_b, dac_b, dac_delta);
    if (dac_delta == 0)
        (void)xil_printf("    STATIC DAC — phase detector quiet (no CLKin?), MAN_DAC/holdover, or stuck rail\r\n");
    else
        (void)xil_printf("    DAC moved — charge pump active; if RB_PLL1_LD still 0, freq may be outside DLD window\r\n");

    r146 = iic_read_clk_reg(ADR_REG_LMK_CLKIN) & 0xFF;
    r147 = iic_read_clk_reg(ADR_REG_LMK_CLKIN_POL) & 0xFF;
    r13f = iic_read_clk_reg(ADR_REG_LMK_NCLK) & 0xFF;
    r143 = iic_read_clk_reg(ADR_REG_LMK_DDLY_CLR) & 0xFF;
    r14b = iic_read_clk_reg(ADR_REG_LMK_LOS_TIMEOUT) & 0xFF;
    r14c = iic_read_clk_reg(ADR_REG_LMK_MAN_DAC) & 0xFF;
    r150 = iic_read_clk_reg(ADR_REG_LMK_OVERRIDE) & 0xFF;
    r157 = iic_read_clk_reg(ADR_REG_LMK_CLKIN2_R1) & 0xFF;
    r158 = iic_read_clk_reg(ADR_REG_LMK_CLKIN2_R0) & 0xFF;
    r159 = iic_read_clk_reg(ADR_REG_LMK_PLL1_N1) & 0xFF;
    r15a = iic_read_clk_reg(ADR_REG_LMK_PLL1_N0) & 0xFF;
    r15b = iic_read_clk_reg(ADR_REG_LMK_PLL1_MISC) & 0xFF;
    r15c = iic_read_clk_reg(ADR_REG_LMK_PLL1_DLD_CNT1) & 0xFF;
    r15d = iic_read_clk_reg(ADR_REG_LMK_PLL1_DLD_CNT0) & 0xFF;
    r15f = iic_read_clk_reg(ADR_REG_LMK_PLL1_LDS) & 0xFF;
    rb188 = iic_read_clk_reg(ADR_REG_LMK_RB_HOLDOVER) & 0xFF;

    clk2_r_spi = ((r157 & 0x3F) << 8) | r158;
    pll1_n_spi = ((r159 & 0x3F) << 8) | r15a;
    pll1_dld = ((r15c & 0x3F) << 8) | r15d;

    clk2_r_map = ((lmk04828_reg_data((unsigned int)ADR_REG_LMK_CLKIN2_R1) & 0x3F) << 8)
               | (lmk04828_reg_data((unsigned int)ADR_REG_LMK_CLKIN2_R0) & 0xFF);
    pll1_n_map = ((lmk04828_reg_data((unsigned int)ADR_REG_LMK_PLL1_N1) & 0x3F) << 8)
               | (lmk04828_reg_data((unsigned int)ADR_REG_LMK_PLL1_N0) & 0xFF);

    (void)xil_printf("[D] CLKin 0x146=%02X  CLKin_POL/mux 0x147=%02X  NCLK 0x13F=%02X  DDLY_CLR 0x143=%02X\r\n",
                     r146, r147, r13f, r143);

    (void)xil_printf("[E] Dividers: CLKin2_R spi=%d regmap=%d | PLL1_N spi=%d regmap=%d\r\n",
                     clk2_r_spi, clk2_r_map, pll1_n_spi, pll1_n_map);
    if (clk2_r_spi != clk2_r_map || pll1_n_spi != pll1_n_map)
        (void)xil_printf("    WARNING: SPI readback differs from regmap table.\r\n");

    f_pd1_hz = (clk2_r_spi > 0)
        ? (unsigned long)((LMK_CLKIN2_MHZ_X1000 * 1000UL) / (unsigned long)clk2_r_spi) : 0UL;
    lock_floor_us = (f_pd1_hz > 0UL && pll1_dld > 0)
        ? ((unsigned long)pll1_dld * 1000000UL) / f_pd1_hz : 0UL;
    (void)xil_printf("    Using LMK_CLKIN2_MHZ_X1000=%d: f_PD1=%lu Hz  PLL1_DLD_CNT=%d -> floor ~%lu us\r\n",
                     LMK_CLKIN2_MHZ_X1000, f_pd1_hz, pll1_dld, lock_floor_us);
    if (pll1_n_spi > 0 && clk2_r_spi > 0) {
        unsigned long long ratio_x1000 =
            (unsigned long long)pll1_n_spi * 1000ULL / (unsigned long long)clk2_r_spi;
        (void)xil_printf("    Ratio PLL1_N/CLKin2_R = %lu.%03lu (OSCin/CLKin if loop locks)\r\n",
                         (unsigned long)(ratio_x1000 / 1000UL),
                         (unsigned long)(ratio_x1000 % 1000UL));
    }

    misc = r15b & 0xFF;
    cp_gain = misc & 0x0F;
    cp_pol = (misc >> 4) & 1;
    cp_tri = (misc >> 5) & 1;
    wnd = (misc >> 6) & 3;
    (void)xil_printf("[F] PLL1_MISC 0x15B=%02X  WND=%d CP_TRI=%d CP_POL=%d CP_GAIN=%d",
                     misc, wnd, cp_tri, cp_pol, cp_gain);
    (void)xil_printf("  (FMC216 VCXO expects CP_POL=1 pos-slope per regmap comments)\r\n");

    (void)xil_printf("[G] PLL1_LD_MUX/type 0x15F=%02X  LD_MUX=%d LD_TYPE=%d\r\n",
                     r15f, (r15f >> 3) & 0x1F, r15f & 7);

    /* TI SNAS605 / E2E plain-text map: 0x14B LOS_TIMEOUT[7:6], LOS_EN[5], TRACK[4],
     * HOLDOVER_FORCE[3], MAN_DAC_EN[2], MAN_DAC[9:8][1:0] */
    {
        int los_to = (r14b >> 6) & 3;
        int los_en = (r14b >> 5) & 1;
        int track_en = (r14b >> 4) & 1;
        int holov_frc = (r14b >> 3) & 1;
        int man_dac_en = (r14b >> 2) & 1;
        int man98 = r14b & 3;
        int man_word = ((man98 << 8) | (r14c & 0xFF)) & 0x3FF;

        (void)xil_printf("[H] 0x14B = 0x%02X  LOS_TIMEOUT=%d LOS_EN=%d TRACK=%d HOLDOV_FRC=%d MAN_DAC_EN=%d  MAN_DAC[9:8]=%d\r\n",
                         r14b, los_to, los_en, track_en, holov_frc, man_dac_en, man98);
        if (man_dac_en)
            (void)xil_printf("    WARNING: MAN_DAC_EN=1 — PLL1 DAC is driven from manual 0x14B[1:0]+0x14C word 0x%03X, not the PLL.\r\n",
                             man_word);
    }

    /* 0x150: bits 7:5 reserved 0; TI SNAS605 */
    (void)xil_printf("[I] 0x150 HOLDOVER cfg = 0x%02X  PLL1_DET=%d LOS_DET=%d VTUNE_DET=%d HITLESS=%d HOLDOVER_EN=%d\r\n",
                     r150,
                     (r150 >> 4) & 1, (r150 >> 3) & 1, (r150 >> 2) & 1,
                     (r150 >> 1) & 1, r150 & 1);
    if (r150 & 1)
        (void)xil_printf("    NOTE: HOLDOVER_EN=1 — check RB_HOLDOVER (0x188) during fault hunt.\r\n");

    (void)xil_printf("[J] 0x188 RB_HOLDOVER byte = 0x%02X  RB_HOLDOVER(bit4)=%d\r\n",
                     rb188, (rb188 >> 4) & 1);

    (void)xil_printf("[K] Readback checklist if PLL1 never locks:\r\n");
    (void)xil_printf("    - Scope CLKin2± / OSCin± after CPLD OSC100_EN+OSC491_EN; verify freq/amplitude.\r\n");
    (void)xil_printf("    - If RB_DAC static and mid/high/low: likely no valid CLKin at PLL1 R-divider.\r\n");
    (void)xil_printf("    - If RB_DAC moves but no lock: wrong CLKin frequency vs N/R (measure CLKin).\r\n");
    (void)xil_printf("    - J sweep all zeros + static DAC: analog path or buffer type (0x146 CLKin2_TYPE).\r\n");
    (void)xil_printf("==========================================================\r\n");
}

//----------------------------------------------------------------
// Force PLL2 frequency calibration (FCAL) and wait for lock.
// Per SNAS605 §9.3.6, *any* write to PLL2_N[7:0] (0x168) re-arms
// FCAL while PLL2_FCAL_DIS = 0.  However, an already-running PLL2
// state machine can sometimes ignore a re-arm if the previous FCAL
// is still considered "in progress" — so before re-triggering we
// briefly set PLL2_FCAL_DIS = 1 (in 0x166), then back to 0, which
// forces the chip to drop any prior FCAL state and start fresh.
//
// Polls RB_PLL2_LD (0x183 bit 1) for up to ~max_ms, sampling every
// 1 ms.  Also tracks the *peak* observed value of bit 1 across the
// poll loop, so the caller can tell the difference between
//   "PLL2 has never locked at all" (peak == 0, hard configuration bug) vs.
//   "PLL2 keeps grabbing then dropping lock"     (peak == 1 but final == 0,
//    points at marginal loop-filter / damping issue).
// Returns 1 if locked at end, 0 if timed out.  *peak_out (if non-NULL)
// receives the highest RB_PLL2_LD value seen during the wait.
//
// Timing floor for lock detection:
//   PLL2_DLD_CNT = 1024 cycles × T_PD2 (6.25 µs at f_PD2 = 160 kHz)
//                = 6.4 ms minimum for RB_PLL2_LD to assert *after*
//   FCAL completes and the loop is steady inside the 3.7 ns DLD
//   window.  FCAL itself adds a few-millisecond band-search.  500 ms
//   per attempt is generous but lets us see slow pull-in.
//----------------------------------------------------------------
static int lmk_force_pll2_fcal_wait_peak(int max_ms, int *peak_out)
{
    int k;
    int loops = (max_ms <= 0) ? 1 : max_ms;
    int peak  = 0;
    int last  = 0;

    /* Drop any prior FCAL state by toggling PLL2_FCAL_DIS = 1 ? 0. */
    (void)iic_write_clk_reg(ADR_REG_LMK_PLL2_FCAL, 0x04);   /* PLL2_FCAL_DIS = 1 */
    usleep(200);
    (void)iic_write_clk_reg(ADR_REG_LMK_PLL2_FCAL, lmk04828_reg_data(ADR_REG_LMK_PLL2_FCAL));
    (void)iic_write_clk_reg(ADR_REG_LMK_PLL2_N1,   lmk04828_reg_data(ADR_REG_LMK_PLL2_N1));
    (void)iic_write_clk_reg(ADR_REG_LMK_PLL2_N0,   lmk04828_reg_data(ADR_REG_LMK_PLL2_N0));

    for (k = 0; k < loops; k++) {
        int rb = iic_read_clk_reg(ADR_REG_LMK_PLL2_LD_LOST) & 0xFF;
        last = (rb & LMK_RB_PLL2_LD_BIT) ? 1 : 0;
        if (last) {
            peak = 1;
            if (peak_out) *peak_out = peak;
            return 1;
        }
        usleep(1000);
    }
    if (peak_out) *peak_out = peak;
    (void)last;
    return 0;
}

static int lmk_force_pll2_fcal_wait(int max_ms)
{
    return lmk_force_pll2_fcal_wait_peak(max_ms, NULL);
}

//----------------------------------------------------------------
// PLL2 lock with retry — re-arm FCAL between attempts.  PLL2's
// VCO calibration is a one-shot that latches whichever VCO band
// best matches OSCin at the instant FCAL runs.  If OSCin is still
// recovering from a PLL1 transient, FCAL can latch the wrong band
// and PLL2 never locks even after OSCin stabilises.  Each retry
// fully drops FCAL (DIS=1?0) and re-writes PLL2_N[7:0] (0x168) to
// re-trigger calibration.  Per attempt we also report the peak
// observed RB_PLL2_LD value, which distinguishes "never locked"
// (config bug) from "transiently locked then lost" (loop filter /
// damping issue).
//----------------------------------------------------------------
static int lmk_pll2_lock_with_retry(int attempts, int per_attempt_ms)
{
    int n;
    int locked = 0;

    for (n = 0; n < attempts && !locked; n++) {
        int peak = 0;
        if (n > 0)
            (void)xil_printf("    PLL2 attempt %d/%d: re-arming FCAL (DIS=1?0)\r\n",
                             n + 1, attempts);
        locked = lmk_force_pll2_fcal_wait_peak(per_attempt_ms, &peak);
        if (!locked) {
            int rb = iic_read_clk_reg(ADR_REG_LMK_PLL2_LD_LOST) & 0xFF;
            (void)xil_printf("    PLL2 attempt %d/%d end: RB_PLL2_LD peak=%d, 0x183=0x%02X (LD_LOST sticky=%d)\r\n",
                             n + 1, attempts, peak, rb & 0xFF,
                             (rb >> 2) & 1);
        }
    }

    return locked;
}

//----------------------------------------------------------------
// Wait for PLL1 lock.  RB_PLL1_LD (0x182 bit 1) needs PLL1_DLD_CNT
// consecutive PFD cycles in window.  Our regmap programs
// PLL1_DLD_CNT = 0x400 = 1024; at f_PD1 = 80 kHz that is 12.8 ms.
//----------------------------------------------------------------
static int lmk_wait_pll1_lock(int max_ms)
{
    int k;
    int loops = (max_ms <= 0) ? 1 : max_ms;

    for (k = 0; k < loops; k++) {
        int rb = iic_read_clk_reg(ADR_REG_LMK_PLL1_LD_LOST) & 0xFF;
        if (rb & LMK_RB_PLL1_LD_BIT)
            return 1;
        usleep(1000);
    }
    return 0;
}

//----------------------------------------------------------------
// PLL1 lock with retry — force a CLKin re-acquisition between
// attempts.  The OSCout/CLKin2 shared pin pair on the LMK04828
// gives borderline signal integrity at the CLKin2 receiver on the
// FMC216 board, so PLL1's first lock attempt after a fresh reset
// frequently fails to converge even with a clean reference present.
// Re-writing 0x147 (CLKin_SEL_POL/CLKin_SEL_MODE) restarts the
// PLL1 R-counter and the input clock acquisition state machine,
// giving the loop a fresh shot.  Each attempt waits up to
// per_attempt_ms for RB_PLL1_LD; we try up to attempts times.
// Returns 1 if any attempt locked, 0 if all attempts timed out.
//----------------------------------------------------------------
static int lmk_pll1_lock_with_retry(int attempts, int per_attempt_ms)
{
    int n;
    int locked = 0;

    for (n = 0; n < attempts && !locked; n++) {
        if (n > 0) {
            /* Force a CLKin re-acquisition: temporarily switch to a
             * different CLKinX, then back to the configured source.
             * This resets the LMK's input-clock-mux state machine and
             * the PLL1 R-counter, kicking the loop into a fresh
             * acquisition attempt with the same reference. */
            int polmx = iic_read_clk_reg(ADR_REG_LMK_CLKIN_POL) & 0xFF;
            int src   = s_lmk_pll1_clkin & 0x7;
            /* Pick any CLKinX != src for the "kick" write. */
            int other = (src == 2) ? 1 : 2;
            (void)iic_write_clk_reg(ADR_REG_LMK_CLKIN_POL, (polmx & 0x0F) | ((other & 0x7) << 4));
            usleep(2000);
            (void)iic_write_clk_reg(ADR_REG_LMK_CLKIN_POL, (polmx & 0x0F) | ((src   & 0x7) << 4));
            usleep(2000);
            (void)xil_printf("    PLL1 attempt %d/%d: re-armed CLKin acquisition (src=CLKin%d)\r\n",
                             n + 1, attempts, src);
        }
        locked = lmk_wait_pll1_lock(per_attempt_ms);
    }

    return locked;
}

//----------------------------------------------------------------
// Diagnostic: try each LMK CLKin (0/1/2) as PLL1 reference and
// report which (if any) lets PLL1 lock.  Useful when the on-board
// 100 MHz oscillator is suspected dead / mis-routed: a successful
// lock on CLKin1 (with an external 100 MHz fed into the FMC216
// front-panel EXT CLK IN) isolates the fault to the on-board
// CCLD-033-50 path.  Caller must already have unlocked SPI and
// selected the FMC I2C mux.
//----------------------------------------------------------------
static void lmk_clksrc_sweep_test(void)
{
    int n;

    (void)xil_printf("\r\n==== LMK CLKin sweep (PLL1 reference fault isolation) ====\r\n");
    (void)xil_printf("Selecting each CLKinX manually for ~250 ms and reading back PLL1 lock.\r\n");

    for (n = 0; n <= 2; n++) {
        int nRdata = iic_read_clk_reg(ADR_REG_LMK_CLKIN_POL) & 0xFF;
        int nWdata = (nRdata & 0x0F) | ((n & 0x7) << 4);
        int locked;
        int rb184;

        (void)iic_write_clk_reg(ADR_REG_LMK_CLKIN_POL, nWdata);
        usleep(2000);
        locked = lmk_wait_pll1_lock(250);
        rb184  = iic_read_clk_reg(ADR_REG_LMK_RB_DAC_VALUE1) & 0xFF;

        (void)xil_printf("  CLKin%d manual : 0x147=0x%02X  CLKin%d_SEL=%d  PLL1_LOCK=%d\r\n",
                         n, nWdata,
                         n, (rb184 >> (3 + n)) & 0x1,
                         locked);
        if (locked) {
            (void)xil_printf("    >>> PLL1 LOCKED on CLKin%d.  This is the live reference.\r\n", n);
        }
    }

    {
        int src   = s_lmk_pll1_clkin & 0x7;
        int nRdata = iic_read_clk_reg(ADR_REG_LMK_CLKIN_POL) & 0xFF;
        int nWdata = (nRdata & 0x0F) | (src << 4);
        (void)iic_write_clk_reg(ADR_REG_LMK_CLKIN_POL, nWdata);
        (void)xil_printf("Restored CLKin_SEL_MODE = CLKin%d manual (0x147 = 0x%02X)\r\n",
                         src, nWdata);
    }
    (void)xil_printf("==========================================================\r\n");
}

void debug_clocks_fmc(int nFMC)
{
    int present;
    int nCtrlBefore, nCtrlAfter;
    int nSpi0, nSpi1, nSpi2;

    if ((nFMC != FMC0) && (nFMC != FMC1)) {
        (void)xil_printf("Clock debug: invalid FMC index %d (use 0 or 1)\r\n", nFMC);
        return;
    }

    (void)xil_printf("\r\n================ Clock Debug FMC%d ================\r\n", nFMC);
    (void)xil_printf("Step 1: Detect FMC and select I2C mux\r\n");
    present = is_present_fmc((nFMC == FMC0) ? FMC_BOARD_0 : FMC_BOARD_1);
    (void)xil_printf("  presence = %d\r\n", present);
    if (!present) {
        (void)xil_printf("  Abort: FMC%d not detected\r\n", nFMC);
        return;
    }
    iic_enable_fmc(nFMC);
    iic_set_fmc_spi4();
    iic_read_fmc_mux();

    (void)xil_printf("Step 2: Pre-init ID and control readback\r\n");
    nCtrlBefore = iic_read_cpld_reg(IIC_CPLD_REG_CTRL);
    (void)xil_printf("  CPLD CTRL pre = 0x%02X\r\n", nCtrlBefore & 0xFF);
    lmk_report_reg("ID_DEVICE_TYPE", ADR_REG_LMK_ID_DEVICE_TYPE, DEF_LMK_ID_DEVICE_TYPE, 1);
    lmk_report_reg("ID_PROD1",       ADR_REG_LMK_ID_PROD1,       DEF_LMK_ID_PROD1,       1);
    lmk_report_reg("ID_PROD0",       ADR_REG_LMK_ID_PROD0,       DEF_LMK_ID_PROD0,       1);
    lmk_report_reg("ID_MASKREV",     ADR_REG_LMK_ID_MASKREV,     DEF_LMK_ID_MASKREV,     1);
    lmk_report_reg("ID_VNDR1",       ADR_REG_LMK_ID_VNDR1,       DEF_LMK_ID_VNDR1,       1);
    lmk_report_reg("ID_VNDR0",       ADR_REG_LMK_ID_VNDR0,       DEF_LMK_ID_VNDR0,       1);
    lmk_report_reg("SPI_LOCK2 pre",  ADR_REG_LMK_SPI_LOCK2,      0x83,                    0);

    (void)xil_printf("Step 3: Program LMK (fmc216_clks_init)\r\n");
    fmc216_clks_init(nFMC);

    (void)xil_printf("Step 4: Post-init focused clock register report\r\n");
    nCtrlAfter = iic_read_cpld_reg(IIC_CPLD_REG_CTRL);
    (void)xil_printf("  CPLD CTRL post = 0x%02X\r\n", nCtrlAfter & 0xFF);
    nSpi0 = iic_read_clk_reg(ADR_REG_LMK_SPI_LOCK0);
    nSpi1 = iic_read_clk_reg(ADR_REG_LMK_SPI_LOCK1);
    nSpi2 = iic_read_clk_reg(ADR_REG_LMK_SPI_LOCK2);
    (void)xil_printf("  LMK SPI lock regs = %02X %02X %02X (expect 01 01 01)\r\n",
        nSpi0 & 0xFF, nSpi1 & 0xFF, nSpi2 & 0xFF);

    lmk_report_reg("CLK0_1_ODL",     ADR_REG_LMK_CLK0_1_ODL,     DEF_LMK_CLK0_1_ODL,     1);
    lmk_report_reg("CLK10_11_ODL",   ADR_REG_LMK_CLK10_11_ODL,   DEF_LMK_CLK10_11_ODL,   1);
    lmk_report_reg("SDCLK1011_PD",   ADR_REG_LMK_SDCLK1011_PD,   DEF_LMK_SDCLK1011_PD,   1);
    lmk_report_reg("SDCLK1011_FMT",  ADR_REG_LMK_SDCLK1011_POLFMT, DEF_LMK_SDCLK1011_POLFMT, 1);
    lmk_report_reg("SYSREF_DIV1",    ADR_REG_LMK_SYSREF_DIV1,    DEF_LMK_SYSREF_DIV1,    1);
    lmk_report_reg("SYSREF_DIV0",    ADR_REG_LMK_SYSREF_DIV0,    DEF_LMK_SYSREF_DIV0,    1);
    lmk_report_reg("CLKIN",          ADR_REG_LMK_CLKIN,          DEF_LMK_CLKIN,          1);
    lmk_report_reg("CLKIN_POL",      ADR_REG_LMK_CLKIN_POL,      0,                      0);
    lmk_report_reg("PLL2_R0",        ADR_REG_LMK_PLL2_R0,        DEF_LMK_PLL2_R0,        1);
    lmk_report_reg("PLL2_N0",        ADR_REG_LMK_PLL2_N0,        DEF_LMK_PLL2_N0,        1);
    lmk_report_reg("PLL2_P",         ADR_REG_LMK_PLL2_P,         DEF_LMK_PLL2_P,         1);
    lmk_report_reg("PLL2_MISC",      ADR_REG_LMK_PLL2_MISC,      DEF_LMK_PLL2_MISC,      1);
    lmk_report_reg("PLL1_LD_LOST",   ADR_REG_LMK_PLL1_LD_LOST,   0,                      0);
    lmk_report_reg("PLL2_LD_LOST",   ADR_REG_LMK_PLL2_LD_LOST,   0,                      0);
    lmk_report_reg("RB_HOLDOVER",    ADR_REG_LMK_RB_HOLDOVER,    0,                      0);
    lmk_report_reg("RB_DAC_VALUE1",  ADR_REG_LMK_RB_DAC_VALUE1,  0,                      0);

    /* Decoded PLL state — the single most useful debug print when SYSREF or refclk are wrong.
     * Reports PLL1/PLL2 lock, CLKin select, dividers, and the implied f_VCO assuming
     * OSCin = LMK_OSCIN_MHZ_X1000.  Flags VCO out-of-band (= unlock cause) explicitly. */
    lmk_dump_pll_state();

    // SYSREF / SYNC enable chain (SNAS605 §9.3.1, §9.3.2.1). Expected post-init values:
    //   0x10C SDCLK3       = 0x20 (SDCLKout3_MUX = 1 ? SYSREF on SDCLKout3)
    //   0x10E SDCLK23_PD   = 0x70 (CLKout2_3 pair on, SDCLKout3 buffer on)
    //   0x10F SDCLK23_FMT  = 0x10 (CLKout3_FMT = LVDS)
    //   0x139 SYSREFMUX    = 0x03 (continuous SYSREF)
    //   0x140 PLL1         = 0x01 (SYSREF block on, only pulser PD)
    //   0x143 DDLY_CLR     = 0x11 (SYSREF_DDLY_CLR cleared after SYNC, SYNC_EN=1, SYNC_MODE=01)
    //   0x144 SYNC_DIS     = 0xFF (alignment locked: SYSREF/SYNC events ignored by dividers)
    lmk_report_reg("SDCLK3 [0x10C]", ADR_REG_LMK_SDCLK3,         DEF_LMK_SDCLK3,         1);
    lmk_report_reg("SDCLK23_PD",     ADR_REG_LMK_SDCLK23_PD,     DEF_LMK_SDCLK23_PD,     1);
    lmk_report_reg("SDCLK23_POLFMT", ADR_REG_LMK_SDCLK23_POLFMT, DEF_LMK_SDCLK23_POLFMT, 1);
    lmk_report_reg("SYSREFMUX",      ADR_REG_LMK_SYSREFMUX,      DEF_LMK_SYSREFMUX,      1);
    lmk_report_reg("PLL1 [0x140]",   ADR_REG_LMK_PLL1,           DEF_LMK_PLL1,           1);
    lmk_report_reg("DDLY_CLR post",  ADR_REG_LMK_DDLY_CLR,       0x11,                   1);
    lmk_report_reg("SYNC_DIS post",  ADR_REG_LMK_SYNC_DIS,       0xFF,                   1);

    /* IBUFDS_GTE4 uses REFCLK_HROW_CK_SEL="01" ? ODIV2 = refclk/2, so J16 is DCLKout10/2.
     * Dual-Loop and 'B' both put 100 MHz on DCLKout10 ? J16 = 50 MHz.
     * J15 SYSREF print uses LMK_TARGET_SYSREF (3.125 MHz Dual-Loop). After 'B' expect 6.25 MHz. */
    (void)xil_printf("Probe expectation (clkdebug top):\r\n");
    (void)xil_printf("  J15 = p_debug_out[4] = fmc0_tx_sysref     = SDCLKout3              ? expect %lu.%03lu MHz\r\n",
                     (unsigned long)(LMK_TARGET_SYSREF_MHZ_X1000 / 1000),
                     (unsigned long)(LMK_TARGET_SYSREF_MHZ_X1000 % 1000));
    (void)xil_printf("  J16 = p_debug_out[5] = bufgt_fmc0_tx_refclk = DCLKout10 ÷2 (GTE4)  ? expect %lu.%03lu MHz\r\n",
                     (unsigned long)((LMK_TARGET_DCLK_MHZ_X1000 / 2) / 1000),
                     (unsigned long)((LMK_TARGET_DCLK_MHZ_X1000 / 2) % 1000));
    (void)xil_printf("================ End Clock Debug FMC%d ================\r\n\r\n", nFMC);
}

/* ps_gpout(4) -> fmc0_tx_core_reset and fmc1_tx_core_reset (qlaser_top_zcu102_fmc0_clkdebug) */
static void jesd_tx_phy_reset_pulse(void)
{
    (void)xil_printf ("jesd: PS GPIO bit4 JESD TX PHY core_reset pulse (FMC0+FMC1)\r\n");
    ps_gpio_bit_set(BIT_GPIO_FMC0_TX_CORE_RESET);
    usleep(2000);
    ps_gpio_bit_clr(BIT_GPIO_FMC0_TX_CORE_RESET);
}

static void jesd_tx_wait_reset_done(unsigned wait_mask, int max_ms)
{
    int k, loops = (max_ms + 1) / 2;

    for (k = 0; k < loops; k++) {
        unsigned g = (unsigned)Xil_In32(ADR_GPIO_IN);
        if ((g & wait_mask) == wait_mask)
            break;
        usleep(2000);
    }
    if (k >= loops)
        (void)xil_printf ("jesd: timeout waiting tx_reset_done mask=0x%08X (GPI=0x%08X)\r\n",
            wait_mask, (unsigned)Xil_In32(ADR_GPIO_IN));
    else
        (void)xil_printf ("jesd: tx_reset_done OK (mask=0x%08X)\r\n", wait_mask);
}


//---------------------------------------------------------
// Program FMC216 clock chip to unlock SPI
//---------------------------------------------------------
void fmc216_clks_spi_unlock()
{
    xil_printf ("fmc216_clks_spi_unlock()\r\n");

    // (Datasheet p101) 0, 0, 83 to allow SPI write access
    iic_write_clk_reg(ADR_REG_LMK_SPI_LOCK0, 0);
    iic_write_clk_reg(ADR_REG_LMK_SPI_LOCK1, 0);
    iic_write_clk_reg(ADR_REG_LMK_SPI_LOCK2, 83);

    xil_printf ("fmc216 PLL chip write unlocked\r\n");
}
//---------------------------------------------------------
// Program FMC216 clock chip to lock SPI (Prevent writes)
// LMK04828 datasheet: registers 0x1FFD, 0x1FFE, 0x1FFF must be
// written in order. 0x1FFF=83 unlocks; any other value (0-82 or
// 84-255) locks. Note: 0x1FFF=0 is also a locked state but 1 is
// used here to be unambiguously non-zero and non-83.
//---------------------------------------------------------
void fmc216_clks_spi_lock()
{
    xil_printf ("fmc216_clks_spi_lock()\r\n");

    // Non-zero values for 0x1FFD and 0x1FFE, and any value != 83 for 0x1FFF
    iic_write_clk_reg(ADR_REG_LMK_SPI_LOCK0, 1);
    iic_write_clk_reg(ADR_REG_LMK_SPI_LOCK1, 1);
    iic_write_clk_reg(ADR_REG_LMK_SPI_LOCK2, 1);   // was 0, which also unlocks

    xil_printf ("fmc216 PLL chip write locked\r\n");
}


//---------------------------------------------------------
// Program FMC216 LMK04828 using TI SNAS605 §9.5.1 (LMK04828).
//
// The function honors two module-level selectors:
//   s_lmk_mode       : LMK_MODE_DUAL_LOOP (default) or LMK_MODE_DISTRIBUTION
//   s_lmk_pll1_clkin : which CLKinX (0/1/2) is selected as the active reference
//
// Sequence in DUAL-LOOP mode (TI SNAS605 §9.4.1):
//   1. SPI unlock
//   2. CPLD osc gate ENABLE (OSC100_EN, OSC491_EN = 1) + 100 ms warm-up
//   3. CPLD LMK_RESET pulse (Abaco FMC216 UM)
//   4. Reg 0x000 RESET = 1 (0x80)
//   5. All mapped registers 0x002..0x165 from regmap (sorted)
//   6. Clear 0x000 (soft reset release)  -- needed before PLL1 acquisition
//   7. CLKinX source override (R counters / type / 0x147 select)
//   8. 0x171 / 0x172 / OPT — then wait for PLL1 lock (CLKin -> OSCin)
//   9. After PLL1 settle + CLR LD_LOST bits: program 0x166..0x174 (PLL2 path), then PLL2 FCAL wait
//  10. Status / SPI-lock regs, SYNC sequence, CLKinX select, SPI lock
//
// Sequence in DISTRIBUTION mode (TI SNAS605 §9.4.5, Table 10):
//   1..4. Same as above (SPI unlock, CPLD osc gate DISABLE, CPLD LMK reset, 0x000 RESET=1).
//   5. All mapped registers 0x002..0x165 from regmap (dual-loop defaults — overridden next).
//   6. lmk_apply_distribution_overrides_fin_100m()  [STILL UNDER RESET]:
//        0x140 = 0xF1 (PLL1/VCO_LDO/VCO/OSCin powered down)
//        0x173 = 0x60 (PLL2_PRE/PLL2 powered down)
//        0x138 = 0x40 (VCO_MUX = External, OSCout_FMT = 0)
//        0x147 = 0x10 (CLKin1 manual sel, CLKin1_OUT_MUX = Fin)
//        DCLKout?_MUX = 2 (Bypass) for the six DAC device-clock pairs
//        DCLKout10    = Fin/2 (MUX=0 divider, DIV=2) for the FPGA GT refclk
//        SYSREF_DIV   = 32 (6.25 MHz from 200 MHz Fin)
//   7. Const/OPT writes (harmless when PLLs off; keeps deterministic chip state)
//   8. Clear 0x000 (soft reset release) — chip wakes up directly in Distribution Mode
//      with DACCLK = Fin = 200 MHz, DCLKout10 = 100 MHz, SDCLKout3 = 6.25 MHz
//      from the first clock cycle after release; no dual-loop transient.
//   9. SKIP PLL1/PLL2 lock waits and 0x166..0x174 PLL2 path entirely
//  10. Status / SPI-lock regs, SYNC sequence, CLKin1 select, SPI lock
//---------------------------------------------------------
void fmc216_clks_init(int nFMC)
{
    int nCtrl = 0;
    int buf[NUM_REGS_LMK04828];
    int na;
    unsigned a;
    int pll1_ok;

    (void)nFMC;

    xil_printf ("fmc216_clks_init() TI §9.5.1 (regmap-based)\r\n");

    s_lmk_dbg_seq = 0U;
    s_lmk_dbg_on  = 1;
    xil_printf ("LMK04828 SPI write trace ON (sequence = order of CPLD SPI writes to LMK)\r\n");

    lmk_dbg_set_phase("spi_unlock");
    fmc216_clks_spi_unlock();

    /* FMC216 UM061 §3.7: CPLD register 1 (IIC_CPLD_REG_CTRL) gates the two on-board
     * oscillators that feed the LMK04828:
     *   bit 0 = OSC100_EN  ? 100 MHz CCLD-033-50 ? CLKin2 (PLL1 reference)
     *   bit 1 = OSC491_EN  ? 491.52 MHz VS-705 VCXO ? OSCin (PLL2 reference)
     *
     * In Dual-Loop mode both must be high or PLL1/PLL2 can't lock.  In Distribution
     * Mode UM061 §3.7 ("External clock") explicitly states both must be POWERED DOWN
     * "to reduce possible noise and interference" since neither internal PLL is used.
     * Either way it's a read-modify-write so we don't disturb other bits. */
    if (s_lmk_mode == LMK_MODE_DISTRIBUTION) {
        lmk_dbg_set_phase("cpld_disable_oscillators");
        nCtrl = iic_read_cpld_reg(IIC_CPLD_REG_CTRL);
        iic_write_cpld_reg(IIC_CPLD_REG_CTRL, (u8)(nCtrl & ~0x03));  /* clear OSC100_EN | OSC491_EN */
        xil_printf("  CPLD reg1: OSC100_EN=0, OSC491_EN=0 (both on-board oscillators OFF — UM061 §3.7)\r\n");
        /* No warm-up needed when powering down.  Small settle so the I2C side completes. */
        usleep(2000);
    } else {
        lmk_dbg_set_phase("cpld_enable_oscillators");
        nCtrl = iic_read_cpld_reg(IIC_CPLD_REG_CTRL);
        iic_write_cpld_reg(IIC_CPLD_REG_CTRL, (u8)(nCtrl | 0x03));   /* OSC100_EN | OSC491_EN */
        xil_printf("  CPLD reg1: OSC100_EN=1, OSC491_EN=1 (on-board 100 MHz + 491.52 MHz VCXO ON)\r\n");
        /* CCLD-033-50 (100 MHz) and VS-705 (491.52 MHz) both need warm-up after enable.
         * FMC216 UM only says "enable oscillators"; datasheet specs are typically ms–100 ms
         * to rated amplitude.  2 ms was empirically marginal — PLL1 intermittently never
         * acquired.  100 ms is conservative and purely startup delay (no LMK registers yet). */
        usleep(100 * 1000);
    }

    lmk_dbg_set_phase("cpld_lmk_reset_pulse");
    nCtrl = iic_read_cpld_reg(IIC_CPLD_REG_CTRL);
    iic_write_cpld_reg(IIC_CPLD_REG_CTRL, (u8)(nCtrl & ~0x08));
    iic_write_cpld_reg(IIC_CPLD_REG_CTRL, (u8)(nCtrl |  0x08));
    usleep(2000);
    iic_write_cpld_reg(IIC_CPLD_REG_CTRL, (u8)(nCtrl & ~0x08));

    lmk_dbg_set_phase("lmk_soft_reset_assert");
    (void)iic_write_clk_reg(ADR_REG_LMK_RESET, 0x80);

    lmk_dbg_set_phase("regmap_0x002_0x165_sorted");
    na = lmk04828_fill_addrs_from_table(0x002, 0x165, buf, NUM_REGS_LMK04828);
    lmk04828_write_addrs_sorted_unique(buf, na);

    /* Branch on clock topology.  Distribution Mode bypasses both PLLs and routes
     * external CLKin1/Fin straight through the output dividers, so PLL waits and
     * the 0x166..0x174 PLL2 path are skipped (TI SNAS605 §9.4.5, Table 10).
     *
     * Ordering note: In Distribution Mode we apply the mode-specific overrides
     * (0x140 power-downs, VCO_MUX, DCLKoutX_MUX bypass, SYSREF_DIV) BEFORE
     * releasing 0x000 RESET, so the chip wakes up directly in its final state
     * and never spends a transient period operating in dual-loop config with
     * dead OSCin/CLKin2.  In Dual-Loop mode reset is released first because
     * PLL1 acquisition and PLL2 FCAL must run with the chip out of reset. */
    xil_printf("fmc216 LMK mode: %s\r\n", lmk_mode_str(s_lmk_mode));

    if (s_lmk_mode == LMK_MODE_DISTRIBUTION) {
        /* All Distribution-mode overrides are loaded WHILE 0x000.RESET is still
         * asserted.  Per SNAS605 §9.7.1 the SPI port is writable during reset and
         * the register image is latched when RESET is released — so the chip exits
         * reset already configured for Distribution Mode (no dual-loop transient). */
        lmk_dbg_set_phase("distribution_mode_overrides");
        lmk_apply_distribution_overrides_fin_100m();

        /* Const/OPT writes are harmless when PLLs are off; preserve them for
         * deterministic chip state across mode changes (TI SNAS605 §9.5.1). */
        lmk_dbg_set_phase("const_opt_regs");
        (void)iic_write_clk_reg(ADR_REG_LMK_CONST1, 0xAA);
        (void)iic_write_clk_reg(ADR_REG_LMK_CONST2, 0x02);
        (void)iic_write_clk_reg(ADR_REG_LMK_OPT_REG1, DEF_LMK_OPT_REG1);
        (void)iic_write_clk_reg(ADR_REG_LMK_OPT_REG2, DEF_LMK_OPT_REG2);

        lmk_dbg_set_phase("lmk_soft_reset_release");
        (void)iic_write_clk_reg(ADR_REG_LMK_RESET, lmk04828_reg_data(ADR_REG_LMK_RESET));
        usleep(10 * 1000);   /* Let digital exit reset; outputs come up at Fin */

        pll1_ok = 0;  /* Not applicable in Distribution Mode */
        xil_printf("  Distribution Mode active — PLL1/PLL2 waits SKIPPED (both powered down).\r\n");
        xil_printf("  Verify on scope: DACCLK = Fin (200 MHz), DCLKout10 = 100 MHz, SDCLKout3 = 6.25 MHz.\r\n");
    } else {
        /* Dual-Loop: release reset first so PLL1 can start acquiring CLKin during
         * the subsequent CLKin source override + PLL1 lock-wait sequence. */
        lmk_dbg_set_phase("lmk_soft_reset_release");
        (void)iic_write_clk_reg(ADR_REG_LMK_RESET, lmk04828_reg_data(ADR_REG_LMK_RESET));
        usleep(10 * 1000);   /* Let digital exit reset before OPT writes + PLL1 acquisition */

        /* Patch CLKin?_R / CLKin?_TYPE / 0x147 for whichever CLKinX is the active PLL1
         * reference (see s_lmk_pll1_clkin).  Must happen AFTER the sorted regmap write
         * (which programs the default-source values) but BEFORE PLL1 acquisition. */
        lmk_dbg_set_phase("clkin_source_override");
        lmk_apply_clkin_source_overrides();

        lmk_dbg_set_phase("const_opt_regs");
        (void)iic_write_clk_reg(ADR_REG_LMK_CONST1, 0xAA);
        (void)iic_write_clk_reg(ADR_REG_LMK_CONST2, 0x02);
        (void)iic_write_clk_reg(ADR_REG_LMK_OPT_REG1, DEF_LMK_OPT_REG1);
        (void)iic_write_clk_reg(ADR_REG_LMK_OPT_REG2, DEF_LMK_OPT_REG2);

        /* PLL1 lock with retry.  The OSCout/CLKin2 shared pin pair on the FMC216 has marginal
         * signal integrity at the CLKin2 receiver: PLL1's first lock attempt after a fresh
         * reset frequently fails to converge even with a clean 100 MHz reference present.
         * Forcing a CLKin re-acquisition (toggling CLKin_SEL_MODE between CLKin1 and CLKin2
         * manual) restarts PLL1's R-counter and gives the loop a fresh shot.  Empirically up
         * to 3 attempts of 500 ms each is enough; the loop usually catches on attempt 2 or 3.
         * At f_PD1 = 80 kHz with PLL1_DLD_CNT = 1024 the per-attempt detect floor is 12.8 ms. */
        lmk_dbg_set_phase("pll1_wait_lock");
        pll1_ok = lmk_pll1_lock_with_retry(4, 500);
        if (pll1_ok) {
            xil_printf("  PLL1 LOCKED (RB_PLL1_LD asserted)\r\n");
        } else {
            xil_printf("  PLL1 NOT LOCKED after 4 retries x 500 ms.\r\n");
            xil_printf("    If J sweep also fails all CLKin: common path is OSCin/VCXO or PLL1, not one CLKin.\r\n");
            xil_printf("    Still verify CPLD bit0 OSC100_EN, scope CLKin2 + OSCin after FMC enables oscillators.\r\n");
            xil_printf("    (Full LMK dump deferred until after pll2_path — avoids POR garbage on 0x166..168.)\r\n");
            xil_printf("    >>> Try Distribution Mode (UART 'B') as an alternative — bypasses PLLs entirely.\r\n");
        }

        /* OSCin settling barrier before PLL2 FCAL.  PLL2's VCO band-calibration is a one-shot
         * that latches whichever band matches OSCin at the instant FCAL runs.  After the PLL1
         * re-acquisition above (which briefly switched to CLKin1, pulling OSCin off-frequency
         * during the loop transient before re-locking on CLKin2), OSCin needs the VCXO loop to
         * fully settle back to 491.52 MHz before PLL2 FCAL can pick the right band.  PLL1 loop
         * filter (C2 = 4700 nF, R2 = 10 kO at PFD = 80 kHz) gives a natural frequency of only
         * ~2 Hz, so the VCXO mechanical/thermal transients can take 200-300 ms to flatten.
         * Verify PLL1 didn't drop lock during this barrier.  Also clear LD_LOST sticky bits so
         * subsequent loss-of-lock events are observable. */
        usleep(250 * 1000);                                     /* 250 ms VCXO settle */
        {
            int pll1_status = iic_read_clk_reg(ADR_REG_LMK_PLL1_LD_LOST) & 0xFF;
            (void)xil_printf("  Post-settle PLL1 status: 0x182=0x%02X (RB_PLL1_LD=%d, LD_LOST sticky=%d)\r\n",
                             pll1_status, (pll1_status >> 1) & 1, (pll1_status >> 2) & 1);
        }
        (void)iic_write_clk_reg(ADR_REG_LMK_PLL1_LD_LOST, 0x01); /* CLR_PLL1_LD_LOST = 1 */
        (void)iic_write_clk_reg(ADR_REG_LMK_PLL2_LD_LOST, 0x01); /* CLR_PLL2_LD_LOST = 1 */

        /* Program PLL2 tail (0x166..0x174) only after PLL1 has had time to steer OSCin.
         * Writes to 0x168 start PLL2 FCAL — doing that earlier (before PLL1 lock) correlated
         * with runs where RB_PLL1_LD never went high across all CLKin sources. */
        lmk_dbg_set_phase("pll2_path_0x166_0x174");
        for (a = 0x166u; a <= 0x174u; a++)
            (void)iic_write_clk_reg((int)a, lmk04828_reg_data((int)a));

        /* SNAS605 §9.3.6: writing PLL2_N[7:0] (0x168) re-arms VCO frequency calibration with
         * PLL2_FCAL_DIS=0.  Like PLL1, the first FCAL after a transient can latch a wrong
         * band; up to 3 retries lets the loop recalibrate against the now-stable OSCin.
         * Each per-attempt timeout of 500 ms is well above the 6.4 ms DLD_CNT floor at
         * f_PD2 = 160 kHz plus the 5-50 ms FCAL band-search time. */
        lmk_dbg_set_phase("pll2_fcal_and_wait_lock");
        if (!lmk_pll2_lock_with_retry(4, 500)) {
            xil_printf("  PLL2 NOT LOCKED after 4 retries x 500 ms — DACCLK / GT refclk / SYSREF will be wrong.\r\n");
            lmk_dump_pll_state();
        } else {
            xil_printf("  PLL2 LOCKED (RB_PLL2_LD asserted)\r\n");
            if (!pll1_ok) {
                xil_printf("  PLL2 locked but PLL1 did not — unusual; full LMK snapshot:\r\n");
                lmk_dump_pll_state();
            }
        }
    }  /* end of mode branch */

    lmk_dbg_set_phase("regmap_0x182_0x188_sorted");
    na = lmk04828_fill_addrs_from_table(0x182, 0x188, buf, NUM_REGS_LMK04828);
    lmk04828_write_addrs_sorted_unique(buf, na);

    // SNAS605 §9.3.2.1 Table 2 + §9.3.2.1.1 "Setup of SYSREF Example".
    // The 0x002..0x165 phase already wrote 0x143 = 0x91 (SYSREF_DDLY_CLR=1, SYNC_EN=1, SYNC_MODE=01).
    // Datasheet requires SYSREF_DDLY_CLR to be held for =15 distribution-clock cycles (~6 ns @ 2.4 GHz);
    // the dozens of intervening I²C writes have already exceeded that. Now release CLR, perform a one-shot
    // SYNC via SPI to align the divider chain (DCLKoutX + SYSREF), then disable further SYNC events so
    // continuous SYSREF cannot re-reset dividers during normal operation.
    lmk_dbg_set_phase("sysref_release_and_sync");
    usleep(10);
    (void)iic_write_clk_reg(ADR_REG_LMK_DDLY_CLR, 0x11);   // SYSREF_DDLY_CLR=0, SYNC_EN=1, SYNC_MODE=01
    usleep(10);
    (void)iic_write_clk_reg(ADR_REG_LMK_DDLY_CLR, 0x31);   // SYNC_POL=1 ? arm SYNC pulse
    usleep(10);
    (void)iic_write_clk_reg(ADR_REG_LMK_DDLY_CLR, 0x11);   // SYNC_POL=0 ? SPI-driven SYNC event on this falling edge
    usleep(10);
    (void)iic_write_clk_reg(ADR_REG_LMK_SYNC_DIS, 0xFF);   // SNAS605 §9.3.2.1.1 step 3a: lock alignment, ignore stray SYNC/SYSREF resets

    lmk_dbg_set_phase("regmap_spi_lock_0x1FFD_0x1FFF_sorted");
    na = lmk04828_fill_addrs_from_table(0x1FFD, 0x1FFF, buf, NUM_REGS_LMK04828);
    lmk04828_write_addrs_sorted_unique(buf, na);

    lmk_dbg_set_phase("pll1_clkin_select");
    set_lmk_clk_src();

    lmk_dbg_set_phase("spi_lock");
    fmc216_clks_spi_lock();

    s_lmk_dbg_on = 0;
    xil_printf ("LMK04828 SPI write trace OFF (last seq was %u)\r\n", s_lmk_dbg_seq);

    xil_printf ("fmc216_clks_init() done\r\n");
}

//----------------------------------------------------------------
// DAC39J84: 16-bit value for register index nReg (0..127 = config0..config127).
// Base: arr_reg_dac_defaults in regmap_dac39j84.h (TI SLASE48A defaults).
//
// System: DACCLK = 200 MHz (LMK Distribution Mode, external 200 MHz on CLKin1/Fin, DAC PLL
// bypassed). FMC216 wires 2 JESD lanes per DAC, so each DAC39J84 is an L=2 link. Per SLASE48A
// Table 11 there is NO L=2/M=4 interp=1 mode, so interpolation >= 2 is mandatory.  Chosen mode:
//   L=2, M=4, F=4, S=1, K=16, N=16, N'=16, HD=0, subclass 1, scrambling off, interpolation = 2x.
//   f_DAC(out)=200 MSPS, f_DATA(in)=100 MSPS -> one waveform point per 10 ns, which is the
//   requirement the 2x interpolation must not be allowed to erode.  Interpolation raises the
//   OUTPUT rate above f_DATA; it does not change the fact that f_DAC is set by DACCLK.
//   LMFC = 100M/(S*K) = 6.25 MHz = LMK SYSREF (Fin/32); 4.0 Gbps/lane.
// SLASE48A field encodings used below:
//   interp 11:8 = 0001 (2x); f_m1 = F-1 = 3; k_m1 = K-1 = 15; l_m1 = L-1 = 1;
//   clkjesd_div 15:13 = 000 => JESD digital clock = DACCLK (200 MHz).  Unchanged from the
//   100 MHz plan: f_DATA doubled too, so the JESD-clock-to-f_DATA ratio still 2.
// SerDes: ref = DACCLK/1 = 200 MHz (config59); Table 3 -> RATE=half means PLL output = 0.5x
//   line rate = 2.0 GHz (inside 1.5625-3.125 GHz), so MPY = 2000/200 = 10x + VRANGE=1
//   (config60), 20-bit bus (config62).  RATE=quarter would demand a 4.0 GHz VCO, out of range.
//   MPY dropped 20x -> 10x and the reference moved off the 100 MHz bottom edge toward TI's
//   300-800 MHz optimal band, both of which ease the SLASE48A caution on refclk jitter.
//----------------------------------------------------------------
static int dac39j84_reg_data(int nReg)
{
    int v;

    if (nReg < 0 || nReg >= NUM_REGS_DAC_39J84)
        return 0;
    v = arr_reg_dac_defaults[nReg];

    switch (nReg) {
    case ADR_CONFIG_0:
        return 0x0118;   /* interp=2x (bits 11:8=0001), inv_sinc off; was 0x0218 (4x) */
    case ADR_CONFIG_1:
        return 0x00A3;   /* daca_compliment (bit7) + dacc_compliment (bit5): FMC216 inverts the A and C
                          * board outputs for trace matching (UM061 §4.4.1 item 1: bits 7,6,5,4 = 1010) */
    case ADR_CONFIG_2:
        return 0x2082;   /* 4-wire SPI readback */
    case ADR_CONFIG_37:
        return 0x0000;   /* clkjesd_div=000 (bits 15:13): full DACCLK to JESD clock (200 MHz) */
    case ADR_CONFIG_59:
        return 0x0000;   /* serdes_clk_sel=0 (DACCLK-from-pins, POR default for PLL-bypass), refclk div+1=1 => 200 MHz */
    case ADR_CONFIG_60:
        return 0x0250;   /* SerDes PLL: MPY=10x (Table 4 code 00101000 in bits8:1), VRANGE=1 (bit9, PLL out < 2.17 GHz);
                          * 200 MHz ref x10 = 2.0 GHz PLL output = 0.5 x 4.0 Gbps line rate at RATE=half */
    case ADR_CONFIG_61:
        return 0x0080;   /* rw_cfgrx0 upper: ENOC=1 (bit7) */
    case ADR_CONFIG_62:
        return 0x0028;   /* RATE=half (bits 6:5=01) -> PLL out = 0.5 x line rate = 2.0 GHz (Table 3);
                          * BUSWIDTH=20b JESD (bits 4:2=010) */
    case ADR_CONFIG_75:
        return 0x0F03;   /* f_m1=3 (F=4 octets/frame), rbd_m1=15 (=k_m1) */
    case ADR_CONFIG_76:
        return 0x0F01;   /* k_m1=15 (K=16), l_m1=1 (L=2 lanes) */
    default:
        break;
    }
    return v;
}

//---------------------------------------------------------
// Full DAC39J84 programming (TI SLASE48A §8.3 Initialization Set Up).
//
// The regmap image (dac39j84_reg_data) holds config74 with jesd_reset_n=0 and
// init_state=1111 so the JESD block stays in reset while every register is loaded
// (§8.3 steps 6-11).  This routine then honors the ordering-critical tail of §8.3:
//   step 12: verify the SerDes PLL locked (alarm_rw0_pll/alarm_rw1_pll in config108)
//   step 13: release JESD (config74: init_state=0000, jesd_reset_n=1) LAST
// SYSREF (§8.3 step 14) is already free-running from the LMK04828; data transmission
// (§8.3 step 15) is gated by the FMC216 hardware TXENABLE path (CPLD reg 3), unchanged.
//
// Abaco UM §4.4: all four DACs share RESET_DACS (CPLD reg 1 bit 2) — pulse once per
// board (nDAC==0).  DACCLK (200 MHz, LMK DCLKout, PLL bypassed) and SYSREF (6.25 MHz
// LMFC, SDCLKout3) must be present before this runs.  Which physical LMK output ties to
// DACCLK vs SYSREF is fixed on the FMC216/carrier schematic (Abaco UM), not here.
//---------------------------------------------------------
void fmc216_dac_init(int nFMC, int nDAC)
{
    int nReg;
    int nCtrl;
    int nAlarm;

    (void)nFMC;

    xil_printf ("fmc216_dac_init(FMC=%d, DAC=%d) full register load (L=2 M=4 F=4 S=1 K=16, interp 2x, 4.0 Gbps/lane)\r\n", nFMC, nDAC);

    if (nDAC == 0) {
        nCtrl = iic_read_cpld_reg(IIC_CPLD_REG_CTRL);
        iic_write_cpld_reg(IIC_CPLD_REG_CTRL, (u8)(nCtrl |  0x04));
        usleep(2000);
        iic_write_cpld_reg(IIC_CPLD_REG_CTRL, (u8)(nCtrl & ~0x04));
    }

    /* §8.3 steps 6-11: load all config registers with the JESD block held in reset
     * (config74 default = 0x031E: lanes 0-1 enabled, init_state=1111, jesd_reset_n=0). */
    for (nReg = 0; nReg < NUM_REGS_DAC_39J84; nReg++)
        (void)iic_write_dac_reg(nDAC, nReg, dac39j84_reg_data(nReg));

    /* §8.3 step 12: verify the SerDes PLL locked (config108, SLASE48A Table 139).
     * alarm_rw0_pll = bit3 (SerDes block0, RX0-3) and alarm_rw1_pll = bit2 (block1, RX4-7);
     * bit0 alarm_from_pll is the DAC clock-multiply PLL and is EXPECTED set (we sleep it).
     * The datasheet notes a false PLL alarm latches while the PLL is acquiring, so clear the
     * alarm bits (write-1-to-clear), wait, then re-read.  With L=2, our 2 lanes live in
     * block0, so a real problem shows as alarm_rw0_pll still set. */
    usleep(2000);   /* SerDes PLL acquisition time (datasheet ~us; generous) */
    (void)iic_write_dac_reg(nDAC, ADR_CONFIG_108, 0x000C);  /* W1C: clear alarm_rw0_pll|alarm_rw1_pll */
    usleep(1000);
    nAlarm = iic_read_reg_dac(nDAC, ADR_CONFIG_108) & 0xFFFF;
    if (nAlarm & 0x0008)   /* bit3 alarm_rw0_pll => our lanes 0-1 SerDes PLL not locked */
        xil_printf ("  DAC%d SerDes PLL alarm: config108=0x%04X (rw0_pll set) — check 2.0GHz PLL out/MPY=10x/RATE=half\r\n",
                    nDAC, nAlarm);
    else
        xil_printf ("  DAC%d SerDes PLL OK (config108=0x%04X)\r\n", nDAC, nAlarm);

    /* §8.3 step 13: start JESD204B link init LAST — init_state=0000, jesd_reset_n=1,
     * lanes 0-1 stay enabled (lane_ena=0x03).  config74 = 0x0301. */
    (void)iic_write_dac_reg(nDAC, ADR_CONFIG_74, 0x0301);

    xil_printf ("fmc216_dac_init(FMC=%d, DAC=%d) done (JESD released: config74=0x0301)\r\n", nFMC, nDAC);
}


//---------------------------------------------------------
// FMC216 analog output path (UM061 Tables 12 and 13).
//
// CPLD register 2 : bits 3-0 power the four AD8000 output amplifier banks
//                   (CH0-3, CH4-7, CH8-11, CH12-15); bits 7-4 are the per-DAC
//                   sleep lines and must be 0 for normal operation.
// CPLD register 3 : bits 3-0 are the DAC39J84 TXENABLE lines.  While a TXENABLE
//                   is low that DAC's outputs stay at midscale whatever the JESD
//                   link is carrying.  Bits 5-4 select the SYNC source and are
//                   preserved here.
//
// The SMA outputs are dead until both registers are set, so this runs at the end
// of board init.  Call with the target FMC already selected on the I2C mux.
//---------------------------------------------------------
void fmc216_outputs_enable(int nFMC, int nEnable)
{
    int nCtrlDac;
    int nEnOut;

    nCtrlDac = iic_read_cpld_reg(IIC_CPLD_REG_CTRL_DAC) & 0xFF;
    nEnOut   = iic_read_cpld_reg(IIC_CPLD_REG_EN_OUT)   & 0xFF;

    if (nEnable) {
        /* amplifier banks on, all four DACs out of sleep */
        iic_write_cpld_reg(IIC_CPLD_REG_CTRL_DAC, (u8)0x0F);
        /* TXENABLE on all four DACs, keep the SYNC source selection */
        iic_write_cpld_reg(IIC_CPLD_REG_EN_OUT,   (u8)((nEnOut & 0xF0) | 0x0F));
    } else {
        iic_write_cpld_reg(IIC_CPLD_REG_EN_OUT,   (u8)(nEnOut & 0xF0));
        iic_write_cpld_reg(IIC_CPLD_REG_CTRL_DAC, (u8)(nCtrlDac & 0xF0));
    }

    xil_printf ("fmc216_outputs_enable(FMC=%d, %s): CPLD reg2=0x%02X reg3=0x%02X\r\n",
                nFMC, nEnable ? "on" : "off",
                iic_read_cpld_reg(IIC_CPLD_REG_CTRL_DAC) & 0xFF,
                iic_read_cpld_reg(IIC_CPLD_REG_EN_OUT)   & 0xFF);
}


//---------------------------------------------------------
// Program any connected FMC216 boards
//---------------------------------------------------------
void fmc216_boards_init()
{
    xil_printf ("fmc216_boards_init()\r\n");

    int nFmc0_detected  = is_present_fmc(FMC_BOARD_0);
    int nFmc1_detected  = is_present_fmc(FMC_BOARD_1);

    if (nFmc0_detected == 1)
    {
        iic_enable_fmc      (FMC0);
        fmc216_clks_init    (FMC0);
        xil_jesd_ip_init    (FMC0);
    }

#if JESD_HAS_FMC1
    if (nFmc1_detected == 1)
    {
        iic_enable_fmc      (FMC1);
        fmc216_clks_init    (FMC1);
        xil_jesd_ip_init    (FMC1);
    }
#endif

    {
        unsigned wait_mask = 0u;
        if (nFmc0_detected == 1)
            wait_mask |= (unsigned)BIT_GPI_FMC0_TX_RESET_DONE;
#if JESD_HAS_FMC1
        if (nFmc1_detected == 1)
            wait_mask |= (unsigned)BIT_GPI_FMC1_TX_RESET_DONE;
#endif
        if (wait_mask != 0u) {
            jesd_tx_phy_reset_pulse();
            jesd_tx_wait_reset_done(wait_mask, 500);
        }
    }

    if (nFmc0_detected == 1)
    {
        iic_enable_fmc      (FMC0);     /* the I2C mux may have been left on FMC1 above */
        fmc216_dac_init     (FMC0, 0);
        fmc216_dac_init     (FMC0, 1);
        fmc216_dac_init     (FMC0, 2);
        fmc216_dac_init     (FMC0, 3);
        fmc216_outputs_enable(FMC0, 1);

        xil_printf ("FMC0 initialized\r\n");
    }

#if JESD_HAS_FMC1
    if (nFmc1_detected == 1)
    {
        iic_enable_fmc      (FMC1);
        //fmc216_clks_init    (FMC1);
        fmc216_dac_init     (FMC1, 0);
        fmc216_dac_init     (FMC1, 1);
        fmc216_dac_init     (FMC1, 2);
        fmc216_dac_init     (FMC1, 3);
        fmc216_outputs_enable(FMC1, 1);
        xil_printf ("FMC1 initialized\r\n");
    }
#else
    if (nFmc1_detected == 1)
        xil_printf ("FMC1 mezzanine present but JESD_HAS_FMC1=0 — skipping FMC1 JESD/DAC init\r\n");
#endif

    // No boards present
    if ((nFmc0_detected == 0) && (nFmc1_detected == 0))
    {
        xil_printf ("**** NO FMC boards in the system ****\r\n");
    }

    xil_printf ("fmc216_boards_init() done\r\n");
}

//---------------------------------------------------------
// Same as fmc216_boards_init() but with a one-shot PLL1 reference
// override.  Restores the default (CLKin2 on-board) when done so that
// a subsequent 'F' (fmc216_boards_init) reverts to native behavior.
//
// src = 1 : program LMK to use the external 100 MHz on CLKin1 (FMC216
//           front-panel SMA), produce DACCLK = 100 MHz and SYSREF = 3.125 MHz
//           identically to the on-board source.
// src = 0 : CLKin0 (trigger MUX path; not normally a clock source — debug only).
// src = 2 : CLKin2 (on-board CCLD-033-50 100 MHz; same as plain 'F').
//---------------------------------------------------------
void fmc216_boards_init_with_clkin_src(int src)
{
    int prev = s_lmk_pll1_clkin;

    if (src != LMK_PLL1_CLKIN_ONBOARD &&
        src != LMK_PLL1_CLKIN_EXTERNAL &&
        src != LMK_PLL1_CLKIN_TRIG) {
        xil_printf("fmc216_boards_init_with_clkin_src: invalid src=%d (use 0/1/2)\r\n", src);
        return;
    }

    xil_printf("fmc216_boards_init_with_clkin_src(%d) -> PLL1 ref will be %s\r\n",
               src, lmk_pll1_clkin_str(src));

    s_lmk_pll1_clkin = src;
    fmc216_boards_init();
    s_lmk_pll1_clkin = prev;
}

//---------------------------------------------------------
// Init FMCs in LMK04828 Distribution Mode (TI SNAS605 §9.4.5) using the external
// 200 MHz reference on CLKin1/Fin (FMC216 front-panel SMA).  Both PLLs are
// powered down — no PLL lock waits.  Outputs:
//     DCLKout0/2/4/6/8/12 = 200 MHz  (DCLKoutX_MUX = 2 Bypass)
//     DCLKout10           = 100 MHz  (DIV=2, FPGA GT refclk)
//     SDCLKout3           = 6.25 MHz (SYSREF_DIV = 32)
//
// Use this when the on-board CCLD-033-50 / VCXO / PLL1 path is unavailable
// (failing to lock, oscillator gating broken, etc.), or when the application
// needs a phase-deterministic relationship to an external master clock.
//
// Restores s_lmk_mode and s_lmk_pll1_clkin defaults when done so that a
// subsequent 'F' or 'X' invocation reverts to the dual-loop configuration.
//---------------------------------------------------------
void fmc216_boards_init_distribution_extref(void)
{
    int prev_mode = s_lmk_mode;
    int prev_src  = s_lmk_pll1_clkin;

    xil_printf("fmc216_boards_init_distribution_extref(): Distribution Mode, Fin = CLKin1 SMA, 200 MHz\r\n");

    s_lmk_mode       = LMK_MODE_DISTRIBUTION;
    s_lmk_pll1_clkin = LMK_PLL1_CLKIN_EXTERNAL;  /* selects 0x147[6:4] for the manual mux */
    fmc216_boards_init();
    s_lmk_mode       = prev_mode;
    s_lmk_pll1_clkin = prev_src;
}


//---------------------------------------------------------
// Load 16-bit pulse waveform table with a data value 
// that ramps up from 0.
//---------------------------------------------------------
void pulse_wave_load(int nChannel, int nAddrStart, int nSize)
{
    xil_printf ("pulse_wave_load(nChannel = %d, nAddrStart = 0x%04X, nSize = %d)\r\n", nChannel, nAddrStart, nSize);

    // Enable access to one selected channel
    pulse_chsel_set(1 << nChannel); 
    
    // A loop to load a ramp
    int nWaddr;
    int nWdata;
    for (int nLoop = 0 ; nLoop < nSize ; nLoop++) {
        nWaddr = nAddrStart + nLoop;
        nWdata = 16 * nLoop;
        xil_printf ("   nAddr = 0x%04X, nValue = 0x%04X)\r\n", nWaddr, nWdata);
        Xil_Out32(nWaddr, nWdata);
    }
}

//---------------------------------------------------------
// Make a pulse definition entry from the set of data fields
//---------------------------------------------------------
// PDEF RAM entry description.
//---------------------------------------------------------
// Entry word 0 :   doutb[23: 0]  : pulse start time 
// Entry word 1 :   doutb[11: 0]  : waveform start address 
//                  doutb[27:16]  : waveform length 
// Entry word 2 :   doutb[15: 0]  : gain scale factor 
//                  doutb[31:16]  : address scale factor 
// Entry word 3 :   doutb[16: 0]  : pulse flat top length in clock cycles 
//---------------------------------------------------------
void pulse_defn_entry_set(int nEntry, int nStartTime, int nWaveAddr, int nWaveLen, int nScaleGain, int nScaleAddr, int nFlattop)
{
    int nWdata;
    int nWaddr;

    xil_printf ("pulse_defn_entry_set(%d)\r\n", nEntry);

    // Check parameter range
    if (nStartTime > 0x00FFFFFF)
        xil_printf ("pulse_defn_entry_set(%d): Start time 0x%06X > 0x00FFFFFF\r\n", nEntry, nStartTime);

    if (nWaveAddr > 0x0FFF)
        xil_printf ("pulse_defn_entry_set(%d): Wave addr 0x%04X > 0x0FFF\r\n", nEntry, nWaveAddr);

    if (nWaveLen > 0x0FFF)
        xil_printf ("pulse_defn_entry_set(%d): Wave len 0x%04X > 0x0FFF\r\n", nEntry, nWaveLen);

    if (nScaleGain > 0xFFFF)
        xil_printf ("pulse_defn_entry_set(%d): Scale Gain 0x%04X > 0xFFFF\r\n", nEntry, nScaleGain);

    if (nScaleAddr > 0xFFFF)
        xil_printf ("pulse_defn_entry_set(%d): Scale addr 0x%04X > 0xFFFF\r\n", nEntry, nScaleAddr);

    if (nFlattop > 0x0001FFFF)
        xil_printf ("pulse_defn_entry_set(%d): Scale addr 0x%08X > 0x0001FFFF\r\n", nEntry, nFlattop);

    nWdata = nStartTime & 0x00FFFFFF;
    nWaddr = ADR_BASE_PULSE_DEFN + 4*nEntry;
    Xil_Out32(nWaddr, nWdata);

    nWdata = ((nWaveLen & 0x0FFF) << 16) + (nWaveAddr & 0x0FFF);
    nWaddr = nWaddr + 1;
    Xil_Out32(nWaddr, nWdata);

    nWdata = ((nScaleAddr & 0xFFFF) << 16) + (nScaleGain & 0xFFFF);
    nWaddr = nWaddr + 1;
    Xil_Out32(nWaddr, nWdata);

    nWdata = nFlattop & 0x0001FFFF;
    nWaddr = nWaddr + 1;
    Xil_Out32(nWaddr, nWdata);
}


//--------------------------------------------------------------
// Load pulse definition table in one channel.
//--------------------------------------------------------------
// Each table entry will require four 32-bit writes
// The table Block RAM holds 256 4-word, 32-bit Pulse Definition entries.
// Port A is for CPU read/write. 1Kx32-bit
// Port B is for pulse definition data output. 1Kx32-bit
//--------------------------------------------------------------
// PDEF RAM entry description.
//--------------------------------------------------------------
// Entry word 0 :   doutb[23: 0]  : pulse start time 
// Entry word 1 :   doutb[11: 0]  : waveform start address 
//                  doutb[27:16]  : waveform length 
// Entry word 2 :   doutb[15: 0]  : gain scale factor 
//                  doutb[31:16]  : address scale factor 
// Entry word 3 :   doutb[16: 0]  : pulse flat top length in clock cycles 
//--------------------------------------------------------------
void pulse_defn_load(int nChannel)
{
    int nStartTime      = 200 + (10*nChannel);
  //int nStartTimeIncr  = 200;
    int nWaveAddr       = 0;
    int nWaveLen        = 4096/256; // 16
    int nScaleGain      = 0x0100;   // 1.0
    int nScaleAddr      = 0x0100;   // 1.0
    int nFlattop        = 8;
    int nFlattopIncr    = 4;

    int nEntry;

    xil_printf ("pulse_defn_load(nChannel = %d)\r\n", nChannel);

    // Enable access to one selected channel
    pulse_chsel_set(1 << nChannel); 

    // Write all entries in RAM
    for (nEntry = 0 ; nEntry < PDEF_NUM_ENTRY ; nEntry++)
    {
        pulse_defn_entry_set(nEntry, nStartTime, nWaveAddr, nWaveLen, nScaleGain, nScaleAddr, nFlattop);

        // Make next start time after end of current pulse
        nStartTime = nStartTime + (nWaveLen + nFlattop + nWaveLen);

        // Increase waveform table pointer and increase flattop length 
        nWaveAddr   = nWaveAddr + nWaveLen;
        nFlattop    = nFlattop + nFlattopIncr;
    }
}


//---------------------------------------------------------
// Set channel select reg
//---------------------------------------------------------
void pulse_chsel_set(int nValue)
{
    xil_printf ("Set channel select reg to 0x%08X\r\n", nValue);
    Xil_Out32(ADR_PULSE_REG_CHSEL, nValue);
}


//---------------------------------------------------------
// Read channel select reg
//---------------------------------------------------------
int pulse_chsel_get()
{
    int nRdata = 0;

    //xil_printf ("Read channel select reg : ");
    nRdata = Xil_In32(ADR_PULSE_REG_CHSEL);
    //xil_printf ("0x%08X\r\n", nRdata);
    return (nRdata);
}

//---------------------------------------------------------
// Set the ramp rate for a single channel in the test (ramp)
// version of the pulse generator
//---------------------------------------------------------
void pulse_ramp_set(int nChannel, int nRampRate)
{
    int nWdata = 0x1 << nChannel;

    xil_printf ("Set channel select reg to 0x%08X\r\n", nWdata);
    Xil_Out32(ADR_PULSE_REG_CHSEL, nWdata);

    xil_printf ("Set channel %d ramp rate to %d\r\n", nChannel, (nRampRate & 0xFFFF));
    Xil_Out32(ADR_PULSE_RAMP_RATE, (nRampRate & 0xFFFF));
}

//---------------------------------------------------------
// Set a different ramp rate for each channel in the test (ramp)
// version of the pulse generator
//---------------------------------------------------------
void pulse_ramp_all_set()   
{
    int nChannel    = 0;
    int nRampRate   = 0;

    xil_printf ("set_pulse_ramp_all()\r\n");
    for (nChannel = 0 ; nChannel < 32 ; nChannel++)
    {
        nRampRate = 16 * (nChannel + 1);
        pulse_ramp_set(nChannel, nRampRate);
    }
}

//---------------------------------------------------------
// Select the pulse channel 0-31 source for a DAC 0-31 
// and set the invert and zero flags.
// ADR_SW_MUX7_0         8, 4-bit mux selects channels 0 to 7 to FMC0 0-15 
// ADR_SW_MUX15_8       
// ADR_SW_MUX23_16      
// ADR_SW_MUX31_24      
// ADR_SW_INV            Invert chN if bit N is set
// ADR_SW_ZERO           Zero chN if bit N is set
//---------------------------------------------------------
void switch_jesd_set(int nDac, int nPulseChannel, int nInvert, int nZero)
{
    int nWdata  = 0;
    int nRdata  = 0;
    int nMask   = 0;
    int nMuxInput = (nPulseChannel & 0x0F); // DACs 16-31 only use pulse channels 16-31 so the mux values are 0-15
    int nDacField = (nDac & 0x07);          // 8 DACfields per register

    xil_printf ("switch_jesd_set : Pulse Channel %2d -> DAC %2d,  invert=%d, zero=%d\r\n", nPulseChannel, nDac, nInvert, nZero);

    if ((nDac < 16) && (nPulseChannel > 16))
    {
        xil_printf ("*** DACs 0-15 use Pulse Channels 0-15 only ***\r\n");
        return;
    }
    else if ((nDac > 15) && (nPulseChannel < 16))
    {
        xil_printf ("*** DACs 16-31 use Pulse Channels 16-31 only ***\r\n");
        return;
    }


    // If DAC is 0-7 then set mux in ADR_SW_MUX7_0
    if (nDac < 8)
    {
        nRdata  = Xil_In32(ADR_SW_MUX7_0);
        nMask   = 0xF << (4 * nDacField);
        nWdata  = nRdata & ~nMask;              		    	// Clear the DAC field
        nWdata  = nWdata | (nMuxInput << (4 * nDacField));      // Set the mux field for a DAC to the pulse channel number
        Xil_Out32(ADR_SW_MUX7_0, nWdata);
        xil_printf ("ADR_SW_MUX7_0   (0x%08X -> 0x%08X)\r\n", nRdata, nWdata);
    }
    // If DAC is 8-15 then set mux in ADR_SW_MUX15_8
    else if (nDac < 16)
    {
        nRdata  = Xil_In32(ADR_SW_MUX15_8);
        nMask   = 0xF << (4 * nDacField);
        nWdata  = nRdata & ~nMask;
        nWdata  = nWdata | (nMuxInput << (4 * nDacField));
        Xil_Out32(ADR_SW_MUX15_8, nWdata);
        xil_printf ("ADR_SW_MUX15_8  (0x%08X -> 0x%08X)\r\n", nRdata, nWdata);
    }
    // If DAC is 16-23 then set mux in ADR_SW_MUX23_16
    else if (nDac < 24)
    {
        nRdata  = Xil_In32(ADR_SW_MUX23_16);
        nMask   = 0xF << (4 * nDacField);
        nWdata  = nRdata & ~nMask;
        nWdata  = nWdata | (nMuxInput << (4 * nDacField));
        Xil_Out32(ADR_SW_MUX23_16, nWdata);
        xil_printf ("ADR_SW_MUX23_16 (0x%08X -> 0x%08X)\r\n", nRdata, nWdata);
    }
    // If DAC is 24-31 then set mux in ADR_SW_MUX31_24
    else if (nDac < 32)
    {
        nRdata  = Xil_In32(ADR_SW_MUX31_24);
        nMask   = 0xF << (4 * nDacField);
        nWdata  = nRdata & ~nMask;              // Clear the mux field
        nWdata  = nWdata | (nMuxInput << (4 * nDacField));  // Set the mux field to the pulse channel number
        Xil_Out32(ADR_SW_MUX31_24, nWdata);
        xil_printf ("ADR_SW_MUX31_24 (0x%08X -> 0x%08X)\r\n", nRdata, nWdata);
    }

    //--------------------------------------------------------
    // Set or clear the appropriate invert bit
    //--------------------------------------------------------
    nRdata  = Xil_In32(ADR_SW_INV);
    nMask   = (0x1 << nDac);        // Set one bit

    if (nInvert == 0) {             // Clear the bit
        nWdata  = nRdata & ~nMask;  // ~nMask has one bit cleared  
      //xil_printf ("Invert bit clearing (0x%08X -> 0x%08X)\r\n", nRdata, nWdata);
        Xil_Out32(ADR_SW_INV, nWdata);
    }
    else if (nInvert == 1) {        // Set the bit
        nWdata  = nRdata | nMask;    
      //xil_printf ("Invert bit setting (0x%08X -> 0x%08X)\r\n", nRdata, nWdata);
        Xil_Out32(ADR_SW_INV, nWdata);
    }
    else
        xil_printf ("Invalid invert bit setting (%d)\r\n", nInvert);


    //--------------------------------------------------------
    // Set or clear the appropriate zero bit
    //--------------------------------------------------------
    nMask   = (0x1 << nDac);        // Set one bit
    nRdata  = Xil_In32(ADR_SW_ZERO);

    if (nZero == 0) {               // Clear the bit
        nWdata  = nRdata & ~nMask;  // ~nMask has one bit cleared  
      //xil_printf ("Zero bit clearing (0x%08X -> 0x%08X)\r\n", nRdata, nWdata);
        Xil_Out32(ADR_SW_ZERO, nWdata);
    }
    else if (nZero == 1) {         // Set the bit
        nWdata  = nRdata | nMask;    
      //xil_printf ("Zero bit setting (0x%08X -> 0x%08X)\r\n", nRdata, nWdata);
        Xil_Out32(ADR_SW_ZERO, nWdata);
    }
    else
        xil_printf ("Invalid zero bit setting (%d)\r\n", nInvert);
}


//---------------------------------------------------------------------
// Set a switch pattern
//---------------------------------------------------------------------
void switch_jesd_clear()
{
	for (int nDac = 0 ; nDac < 16 ; nDac++)
	{
		switch_jesd_set(nDac, 0, 0, 0);
	}
	for (int nDac = 16 ; nDac < 32 ; nDac++)
	{
		switch_jesd_set(nDac, 16, 0, 0);
	}
}


//---------------------------------------------------------------------
// Set a switch pattern
// DAC N gets data from pulse channel N.
// DACs 16-23 are inverted, DACs 24-31 are Zero'ed
//---------------------------------------------------------------------
void switch_jesd_init()
{
	switch_jesd_set( 0,  0, 0, 0);
	switch_jesd_set( 1,  1, 0, 0);
	switch_jesd_set( 2,  2, 0, 0);
	switch_jesd_set( 3,  3, 0, 0);
	switch_jesd_set( 4,  4, 0, 0);
	switch_jesd_set( 5,  5, 0, 0);
	switch_jesd_set( 6,  6, 0, 0);
	switch_jesd_set( 7,  7, 0, 0);
	switch_jesd_set( 8,  8, 0, 0);
	switch_jesd_set( 9,  9, 0, 0);
	switch_jesd_set(10, 10, 0, 0);
	switch_jesd_set(11, 11, 0, 0);
	switch_jesd_set(12, 12, 0, 0);
	switch_jesd_set(13, 13, 0, 0);
	switch_jesd_set(14, 14, 0, 0);
	switch_jesd_set(15, 15, 0, 0);
	switch_jesd_set(16, 16, 1, 0);
	switch_jesd_set(17, 17, 1, 0);
	switch_jesd_set(18, 18, 1, 0);
	switch_jesd_set(19, 19, 1, 0);
	switch_jesd_set(20, 20, 1, 0);
	switch_jesd_set(21, 21, 1, 0);
	switch_jesd_set(22, 22, 1, 0);
	switch_jesd_set(23, 23, 1, 0);
	switch_jesd_set(24, 24, 0, 1);
	switch_jesd_set(25, 25, 0, 1);
	switch_jesd_set(26, 26, 0, 1);
	switch_jesd_set(27, 27, 0, 1);
	switch_jesd_set(28, 28, 0, 1);
	switch_jesd_set(29, 29, 0, 1);
	switch_jesd_set(30, 30, 0, 1);
	switch_jesd_set(31, 31, 0, 1);

}

//---------------------------------------------------------------------
// One-hot output test — the quickest way to confirm the channel ordering
// through the transport layer and the FMC216 routing.
//
// Leaves pulse channel nChannel running its ramp and forces the other 15
// lanes of the same FMC to a constant, so exactly one SMA is moving.  Step
// nChannel through 0..15 and note which connector wakes up each time.
//
// Note this is one-hot *activity*, not one-hot level: the DAC is programmed
// for twos-complement input (config2 bit 1), where the switch's two constants
// 0x0000 and 0xFFFF both land at midscale.  To get a static one-hot *level*
// instead, clear config2 bit 1 on all four DACs first (0x2082 -> 0x2080,
// offset binary); then zero alone is negative full scale and zero+invert is
// positive full scale.  Put it back to 0x2082 afterwards.
//
// nChannel 0-15 selects on FMC0, 16-31 on FMC1.  99 restores all 32 channels.
//---------------------------------------------------------------------
void switch_one_hot(int nChannel)
{
    int nBase;
    int n;

    if (nChannel == 99) {
        for (n = 0 ; n < 32 ; n++)
            switch_jesd_set(n, n, 0, 0);
        xil_printf ("switch_one_hot: restored all 32 channels\r\n");
        return;
    }

    if ((nChannel < 0) || (nChannel > 31)) {
        xil_printf ("switch_one_hot(%d): channel must be 0-31, or 99 to restore\r\n", nChannel);
        return;
    }

    nBase = (nChannel < 16) ? 0 : 16;

    for (n = nBase ; n < (nBase + 16) ; n++)
        switch_jesd_set(n, n, 0, (n == nChannel) ? 0 : 1);

    xil_printf ("switch_one_hot: only channel %d is active on FMC%d (expect the ramp on CH%d)\r\n",
                nChannel, (nBase == 0) ? 0 : 1, nChannel - nBase);
}


//---------------------------------------------------------------------
// Turn on access to all channels and write zeros to clear all RAMs
// Verify all channels are zero
//---------------------------------------------------------------------
int pulse_rams_all_clear()
{
    u32 nEntry      = 0;
    u32 nWaddr      = 0;
    u32 nWdata      = 0;
    u32 nRaddr      = 0;
    u32 nRdata      = 0;
    u32 nErrors     = 0;

    // Enable access to all channels.
    // Each channel should be written with same data.
    pulse_chsel_set(0xFFFFFFFF); 

    //-----------------------------------------------------------------
    // Clear all RAMs
    // Addresses are 4x nEntry because all addresses are byte addresses
    //-----------------------------------------------------------------
    for (nEntry = 0 ; nEntry < SIZERAM_PULSE_WAVE ; nEntry++)
    {
        nWdata = 0x0;
        nWaddr = ADR_BASE_PULSE_WAVE + 4*nEntry;
        Xil_Out32(nWaddr, nWdata);
    }
    // Pdef RAM
    for (nEntry = 0 ; nEntry < SIZERAM_PULSE_DEFN ; nEntry++)
    {
        nWdata = 0x0;
        nWaddr = ADR_BASE_PULSE_DEFN + 4*nEntry;
        Xil_Out32(nWaddr, nWdata);
    }

    //-----------------------------------------------------------------
    // Read back all RAMs. Every channel output is or'ed so when all 
    // channels are enabled the read back values should all still be zero.
    //-----------------------------------------------------------------
    for (nEntry = 0 ; nEntry < SIZERAM_PULSE_WAVE ; nEntry++)
    {
        nRaddr = ADR_BASE_PULSE_WAVE + 4*nEntry;
        nRdata = Xil_In32(nRaddr);
        if (nRdata != 0x0) {
            nErrors++;
            (void)xil_printf("ch all:  wave %d: (0x%08X) = 0x%08X not 0x00000000\r\n", nEntry, nRaddr, nRdata);
        }
    }
    for (nEntry = 0 ; nEntry < SIZERAM_PULSE_DEFN ; nEntry++)
    {
        nRaddr = ADR_BASE_PULSE_DEFN + 4*nEntry;
        nRdata = Xil_In32(nRaddr);
        if (nRdata != 0x0) {
            nErrors++;
            (void)xil_printf("ch all:  defn %d: (0x%08X) = 0x%08X not 0x00000000\r\n", nEntry, nRaddr, nRdata);
        }
    }
    // Report pass/fail
    if (nErrors == 0) 
        (void)xil_printf("Clearing pulse channel RAMs PASSED : %d errors\r\n", nErrors);
    else
        (void)xil_printf("Clearing pulse channel RAMs FAILED : %d errors\r\n", nErrors);

    return nErrors;
}


//---------------------------------------------------------
// Test Pulse Channel RAMs
// Set a bit in nChanValid for each channel that has full logic
// #define SIZERAM_PULSE_WAVE 512      Each memory address contains two waveform points
// #define SIZERAM_PULSE_DEFN 16       Each entry is composted a 4-word 
// RAM base address
// #define ADR_BASE_PULSE_WAVE     (ADR_BASE_DACS_AC + 0x0800)     // Either (512 x 32) for 1K table, or (2K x 32) for 4K tables
// #define ADR_BASE_PULSE_DEFN     (ADR_BASE_DACS_AC + 0x0000)
// Write each channel individually, then read back and check the data.
// Then write all zeros to all channels simultaneously and check that too.
//---------------------------------------------------------
int pulse_channels_rams_test(int nChanValid)
{
    u32 nChannel    = 0;
    u32 nEntry      = 0;
    u32 nWaddrBase  = 0;
    u32 nWdataBase  = 0;
    u32 nWaddr      = 0;
    u32 nWdata      = 0;
    u32 nRdata      = 0;
    u32 nErrors     = 0;

   (void)xil_printf("pulse_channels_rams_test(0x%08X)\r\n", nChanValid);

    //---------------------------------------------------------------------
    // Write RAMS in each channel
    //---------------------------------------------------------------------
    for (nChannel = 0 ; nChannel < 32 ; nChannel++)
    {
       (void)xil_printf("Write channel %d\r\n", nChannel);
        pulse_chsel_set(1 << nChannel); // Enable access to one channel only

        // If channel is full, not empty, write and read back, the waveform RAM and the pulse definition RAM
        // Otherwise write the single test register.
        // Each channel is be written with different data
        if (((nChanValid >> nChannel) & 0x1) == 1)
        {
            nWaddrBase  = ADR_BASE_PULSE_WAVE;
            nWdataBase  = 0x8000;
            for (nEntry = 0 ; nEntry < SIZERAM_PULSE_WAVE ; nEntry++)
            {
                // Two 16-bit data values. Each value is (15) = 1, (14:10)= nChannel, (9:0)= nEntry or nEntry+1
                nWdata = ((nWdataBase + (nChannel << 10) + nEntry + 1) << 16)
                         + nWdataBase + (nChannel << 10) + nEntry;
                nWaddr = nWaddrBase + 4*nEntry;
                Xil_Out32(nWaddr, nWdata);
                //xil_printf("ch %2d: wave %4d: (0x%08X) = 0x%08X\r\n", nChannel, nEntry, nWaddr, nWdata);
            }
           (void)xil_printf("ch %2d: wave done\r\n", nChannel);

            nWaddrBase  = ADR_BASE_PULSE_DEFN;
            nWdataBase  = 0x00800000;
            for (nEntry = 0 ; nEntry < SIZERAM_PULSE_DEFN ; nEntry++)
            {
                // 24-bit data value. (23:16)= nChannel, (3:0)= nEntry or 
                nWdata = nWdataBase + (nChannel << 16) + nEntry;
                nWaddr = nWaddrBase + 4*nEntry;
                Xil_Out32(nWaddr, nWdata);
                //xil_printf("ch %2d: defn %2d: (0x%08X) = 0x%06X\r\n", nChannel, nEntry, nWaddr, nWdata);
            }
           (void)xil_printf("ch %2d: defn done\r\n", nChannel);
        }
        else  // Write a single 32-bit register in 'empty' architecture
        {
            nEntry = 0;
            nWdata =  (1 << 31) + nChannel;     // Set MSB and channel number
            nWaddr  = ADR_BASE_PULSE_WAVE;
            Xil_Out32(nWaddr, nWdata);
           (void)xil_printf("ch %2d: test %d: (0x%08X) = 0x%08X\r\n", nChannel, nEntry, nWaddr, nWdata);
        }
       (void)xil_printf("Writing complete\r\n");
    }

    //---------------------------------------------------------------------
    // If channel is full, read back and test the waveform RAM and the pulse definition RAM,
    // Otherwise read/test the single test register.
    //---------------------------------------------------------------------
    for (nChannel = 0 ; nChannel < 32 ; nChannel++)
    {
       (void)xil_printf("Read channel %d\r\n", nChannel);
        pulse_chsel_set(1 << nChannel); // Enable access to one channel only

        // If channel is full, not empty, read back the waveform RAM and the pulse definition RAM
        // Otherwise read the single test register.
        if (((nChanValid >> nChannel) & 0x1) == 1)
        {
            nWaddrBase  = ADR_BASE_PULSE_WAVE;
            nWdataBase  = 0x8000;
            for (nEntry = 0 ; nEntry < SIZERAM_PULSE_WAVE ; nEntry++)
            {
                // Two 16-bit data values. Each value is (15) = 1, (14:10)= nChannel, (9:0)= nEntry or nEntry+1
                nWdata = ((nWdataBase + (nChannel << 10) + nEntry + 1) << 16)
                         + nWdataBase + (nChannel << 10) + nEntry;
                nWaddr = nWaddrBase + 4*nEntry;
                nRdata = Xil_In32(nWaddr);
                if (nRdata != nWdata)
                {
                    (void)xil_printf("ch %2d: wave %4d: (0x%08X) = 0x%08X not 0x%08X\r\n", nChannel, nEntry, nWaddr, nRdata, nWdata);
                    nErrors++;
                }
            }

            nWaddrBase  = ADR_BASE_PULSE_DEFN;
            nWdataBase  = 0x00800000;
            for (nEntry = 0 ; nEntry < SIZERAM_PULSE_DEFN ; nEntry++)
            {
                // 24-bit data value. (23:16)= nChannel, (3:0)= nEntry or 
                nWdata = nWdataBase + (nChannel << 16) + nEntry;
                nWaddr = nWaddrBase + 4*nEntry;
                nRdata = Xil_In32(nWaddr);
                if (nRdata != nWdata)
                {
                    (void)xil_printf("ch %2d: defn %4d: (0x%08X) = 0x%08X not 0x%08X\r\n", nChannel, nEntry, nWaddr, nRdata, nWdata);
                    nErrors++;
                }
            }
        }
        else  // Read and check 32-bit register in 'empty' architecture
        {
            nEntry = 0;
            nWdata =  (1 << 31) + nChannel;     // Set MSB and channel number
            nWaddr  = ADR_BASE_PULSE_WAVE;
            nRdata = Xil_In32(nWaddr);
            if (nRdata != nWdata)
            {
                (void)xil_printf("ch %2d: test %4d: (0x%08X) = 0x%08X not 0x0%8X\r\n", nChannel, nEntry, nWaddr, nRdata, nWdata);
                nErrors++;
            }
        }
        // Done all read and checking
    }
    nErrors = pulse_rams_all_clear();

    (void)xil_printf("Read test complete : ");
    if (nErrors != 0)
        (void)xil_printf(" %d errors\r\n", nErrors);
    else
        (void)xil_printf(" PASS\r\n");

    return nErrors;
}


//---------------------------------------------------------
// Write the pulse block individual channel enable register.
// One bit per channel.
//---------------------------------------------------------
void pulse_set_ch_en (int nChEnables)
{
	Xil_Out32(ADR_PULSE_REG_CH_EN, nChEnables);
}



//---------------------------------------------------------
// Control the PS GPIO bit that is the pulse block enable (gpio(1)
//---------------------------------------------------------
void set_ps_gpio_pulse_en  (int nValue)
{
	if (nValue == 1)
		ps_gpio_bit_set(BIT_GPIO_PULSE_ENABLE);
	else
		ps_gpio_bit_clr(BIT_GPIO_PULSE_ENABLE);
}


//---------------------------------------------------------
// Set the I2C mux to connect the ZCU102 IIC_1 bus to the Abaco
// FMC boards. The mux is also on the IIC_1 bus 
// FMC_0 requires setting bit-0. FMC_1 requires setting bit-1
//---------------------------------------------------------
int iic_enable_fmc(int nFMC)
{
    int nStatusIic;
    u8  MsgWr[2];


    if (nFMC == 0)
        MsgWr[0] = (u8)0x01; // FMC_0 requires setting bit-0. FMC_1 requires setting bit-1
    else if (nFMC == 1)
        MsgWr[0] = (u8)0x02;
    else {
        xil_printf ("iic_enable_fmc(%d) invalid FMC connector. Must be 0 or 1\r\n", nFMC);
        return XST_FAILURE;
    }

    while (XIicPs_BusIsBusy(&IicPs1)) {
        /* NOP */
    }

    nStatusIic = XIicPs_MasterSendPolled(&IicPs1, &MsgWr[0], 1, IIC_ADDR_ZCU_BUS_MUX);

    if (nStatusIic != XST_SUCCESS) {
        xil_printf("Fail config ZCU IIC mux for access to FMC %d\r\n", nFMC);
        return XST_FAILURE;
    } else {
        xil_printf("Selected FMC %d\r\n", nFMC);
        return XST_SUCCESS;
    }
}


//---------------------------------------------------------
// Read the contents of the IIC_1 mux control register.
// Should be 0x1 or 0
// FMC boards. The mux is also on the IIC_1 bus 
// FMC_0 requires setting bit-0. FMC_1 requires setting bit-1
//---------------------------------------------------------
int iic_read_fmc_mux()
{
    int nStatusIic;
    u8  MsgRd[2];

    // Read back
    while (XIicPs_BusIsBusy(&IicPs1)) {
        /* NOP */
    }
    MsgRd[0] =  0xCC;
    nStatusIic = XIicPs_MasterRecvPolled(&IicPs1, &MsgRd[0], 1, IIC_ADDR_ZCU_BUS_MUX);

    if (nStatusIic != XST_SUCCESS) {
        xil_printf("Fail read ZCU IIC mux\r\n");
        return -1;
    }
    else {
        xil_printf("Read mux = 0x%02X : ", MsgRd[0]);
        if (MsgRd[0] == 0x01) 
            xil_printf ("Access enabled to FMC_0\r\n"); 
        else if (MsgRd[0] == 0x02) 
            xil_printf ("Access enabled to FMC_1\r\n"); 
        else if (MsgRd[0] == 0x03) 
            xil_printf ("Access enabled to FMC_0 and FMC_1\r\n"); 
        else  
            xil_printf ("Unexpected setting\r\n"); 
        return MsgRd[0];
    }
}


//---------------------------------------------------------
// To read the port expander
// Following the successful acknowledgment of the address byte, the bus controller sends a command byte, which
// is stored in the control register in the TCA6416A. Three bits of this data byte state the operation (read or write)
// and the internal registers (input, output, polarity inversion, or configuration) that will be affected. This register can
// be written or read through the I2C bus.
//
// The command byte is sent only during a write transmission.
//
// The last bit of the target address defines the operation (read or write) to be performed. A high (1) selects a read
// operation, while a low (0) selects a write operation.
//---------------------------------------------------------
int iic_read_portexp_reg(int nDevAddr, int nRdReg)
{
    int nStatusIic;
    u8  MsgRd[2];
    u8  MsgWr[2];

    //xil_printf("iic_read_portexp_reg(%d, %d)\r\n", nDevAddr, nRdReg);

    // Wait for bus to be free
    while (XIicPs_BusIsBusy(&IicPs0)) {
        /* NOP */
    }
    // Read Port Expander reg ZCU102 board
    // Write the command byte with the read register address.
    MsgWr[0] = (u8)nRdReg; // Port Expander reg address

    nStatusIic  = XIicPs_MasterSendPolled(&IicPs0, &MsgWr[0], 1, nDevAddr);

    if (nStatusIic != XST_SUCCESS) {
        xil_printf("Fail to set Port Exp address %d , status  0x%04X\r\n", nRdReg, nStatusIic);
        return XST_FAILURE;
    }
    else { // Read back data
        MsgRd[0] =  0xCC;
        nStatusIic = XIicPs_MasterRecvPolled(&IicPs0, &MsgRd[0], 1, nDevAddr);

        if (nStatusIic != XST_SUCCESS) {
            xil_printf("Fail to read Port Exp register %d, status 0x%04X\r\n", nRdReg, nStatusIic);
            return XST_FAILURE;
        }
        else {
            xil_printf("Read PortExp[%d] = 0x%02X\r\n", nRdReg, MsgRd[0]);
            return MsgRd[0];
        }
    }
}


//---------------------------------------------------------
// To write the port expander
// Following the successful acknowledgment of the address byte, the bus controller sends a command byte, which
// is stored in the control register in the TCA6416A. Three bits of this data byte state the operation (read or write)
// and the internal registers (input, output, polarity inversion, or configuration) that will be affected. 
// This register can be written or read through the I2C bus.
//
// The command byte is sent only during a write transmission.
//
// The last bit of the target address defines the operation (read or write) to be performed. A high (1) selects a read
// operation, while a low (0) selects a write operation.
//---------------------------------------------------------
int iic_write_portexp_reg(int nDevAddr, int nWrReg, int nWrData)
{
    int     nStatusIic;
    u8      MsgWr[2];
    bool    bNoisy = true;

    xil_printf("iic_write_portexp_reg(%d, %d, 0x%04X)\r\n", nDevAddr, nWrReg, nWrData);

    // Wait for bus to be free
    while (XIicPs_BusIsBusy(&IicPs0)) {
        /* NOP */
    }
    // Write Port Expander reg ZCU102 board
    // Write the command byte with the write register address.
    MsgWr[0] = (u8)nWrReg; // Port Expander reg address
    MsgWr[1] = (u8)nWrData; // Port Expander reg data

    nStatusIic  = XIicPs_MasterSendPolled(&IicPs0, &MsgWr[0], 2, nDevAddr);

    if (nStatusIic != XST_SUCCESS) {
        xil_printf("Fail to set Port Exp address %d to 0x%02X, status  0x%04X\r\n", nWrReg, nWrData, nStatusIic);
        return XST_FAILURE;
    }
    else {
        if (bNoisy == true)
            xil_printf("Wrote 0x%02X to Port Exp address %d, status  0x%04X\r\n",nWrData, nWrReg,  nStatusIic);
        return XST_SUCCESS;
    }
}


//---------------------------------------------------------
// Read the IIC-0 port expander U97 on the ZCU102 board to
// see if FMC0 and FMC1 have boards plugged in. 
// U97-P10 is for FMC0
// U97-P11 is for FMC1
// The ZCU102 has pullups on these signals.
// The FMC216 DAC boards tie these connector pins to ground.
// Therefore a '0' means 'Board Present'
// Register 1 in the TCA6416A port expander U97 is used to read the level
//---------------------------------------------------------
int is_present_fmc(int nFMC)
{  
    int     nRdata = 0;
    bool    bNoisy = TRUE;

    nRdata = iic_read_portexp_reg(IIC_ADDR_ZCU_PORT_EXP_U97, REG_PORT_EXP_IN1);

    if (nFMC == 0) {
        if ((nRdata & BIT_FMC_HPC0_PRSNT_M2C_B) == 0) {
            if (bNoisy == TRUE)
                xil_printf("FMC0 is present\r\n");
            return 1;
        }
        else {
            if (bNoisy == TRUE)
                xil_printf("FMC0 board is not present\r\n");
            return 0;
        }
    }


    else if (nFMC == 1) {
        if ((nRdata & BIT_FMC_HPC1_PRSNT_M2C_B) == 0) {
            if (bNoisy == TRUE)
                xil_printf("FMC1 is present\r\n");
            return 1;
        }
        else {
            if (bNoisy == TRUE)
                xil_printf("FMC1 board is not present\r\n");
            return 0;
        }
    }
    else
    {
        xil_printf("Invalid FMC board number\r\n");
        return -1;
    }

}


//---------------------------------------------------------
// Read the contents of a CPLD register
//---------------------------------------------------------
int iic_read_cpld_reg(int nReg)
{
    int     nStatusIic;
    u8      MsgRd[2];
    u8      MsgWr[2];
    bool    bNoisy = false;


    if (bNoisy == TRUE)
        xil_printf("iic_read_cpld_reg(%d)\r\n", nReg);

    // Wait for bus to be free
    while (XIicPs_BusIsBusy(&IicPs1)) {
        /* NOP */
    }
    // Read CPLD reg on an attached Abaco FMC216 board 
    // First write the address.
    MsgWr[0] = (u8)nReg; // CPLD reg

    nStatusIic  = XIicPs_MasterSendPolled(&IicPs1, &MsgWr[0], 1, IIC_ADDR_ABA_CPLD);

    if (nStatusIic != XST_SUCCESS) {
        xil_printf("*** Fail to set CPLD address %d , status  0x%04X\r\n", nReg, nStatusIic);
        return XST_FAILURE;
    }
    else { // Read back data
        MsgRd[0] =  0xCC;
        nStatusIic = XIicPs_MasterRecvPolled(&IicPs1, &MsgRd[0], 1, IIC_ADDR_ABA_CPLD);

        if (nStatusIic != XST_SUCCESS) {
            xil_printf("*** Fail to read CPLD register %d, status 0x%04X\r\n", nReg, nStatusIic);
            return XST_FAILURE;
        }
        else {
            if (bNoisy == true)
                xil_printf("Read CPLD[%d] = 0x%02X\r\n", nReg, MsgRd[0]);
            return MsgRd[0];
        }
    }
}

                         
//---------------------------------------------------------
// Write data to a CPLD register
//---------------------------------------------------------
int iic_write_cpld_reg(u8 nReg, u8 nData)
{
    int     nStatusIic;
    u8      MsgWr[2];
    bool    bNoisy = false;

    // Load transmit buffer
    MsgWr[0] = (u8)nReg;    // CPLD reg address
    MsgWr[1] = (u8)nData;   // CPLD reg data

    // Wait for bus to be free
    while (XIicPs_BusIsBusy(&IicPs1)) {
        /* NOP */
    }
    nStatusIic  = XIicPs_MasterSendPolled(&IicPs1, &MsgWr[0], 2, IIC_ADDR_ABA_CPLD);

    if (nStatusIic != XST_SUCCESS) {
        xil_printf("Failed to write CPLD address %d, to 0x%02X,  status  0x%04X\r\n", nReg, nData, nStatusIic);
        return XST_FAILURE;
    }
    else {
        if (bNoisy == true)
            xil_printf("Wrote 0x%02X to CPLD address %d, status  0x%04X\r\n",nData, nReg,  nStatusIic);
        return XST_SUCCESS;
    }
}


//---------------------------------------------------------
// Reset DACs and clock chip on the CURRENTLY SELECTED 
// FMC216 board using the CPLD REG_CTRL bits.
// Write the register to 0x08 then 0x07
//---------------------------------------------------------
void iic_fmc_reset_dacs_and_clk()
{
    iic_write_cpld_reg(IIC_CPLD_REG_CTRL, 0x08);
    iic_write_cpld_reg(IIC_CPLD_REG_CTRL, 0x07);
}


//---------------------------------------------------------
// Write 16-bit data to a FMC216 DAC register
// 
// The 32-bit SPI message is written into four registers on the CPLD
// then the CPLD command register is written with a bit to 
// select the target device.
// The 32-bit message starts with an 8-bit all zero word,
// then R/W bit 1=read, 0=write,
// followed by a 7 bit address and then 16 bits of data
//---------------------------------------------------------
int iic_write_dac_reg(int nDac, int nReg, int nData)
{
    int nStatusIic      = XST_SUCCESS;
    u8 nSpiCommand      = (u8)nReg & 0x7F;       // 7-bit DAC register address
    u8 nSpiDataUpper    = (u8)((nData >> 8) & 0xFF);
    u8 nSpiDataLower    = (u8)(nData & 0xFF);

    // Write SPI word into the four CPLD SPI data registers
    iic_write_cpld_reg(IIC_CPLD_REG_SPI_3, 0x00);           // SPI message 31:24
    iic_write_cpld_reg(IIC_CPLD_REG_SPI_2, nSpiCommand);
    iic_write_cpld_reg(IIC_CPLD_REG_SPI_1, nSpiDataUpper);
    iic_write_cpld_reg(IIC_CPLD_REG_SPI_0, nSpiDataLower);  // SPI message  7:0

    // Trigger SPI write by setting a bit in the CPLD command register 
    if      (nDac == 0)
        nStatusIic  = iic_write_cpld_reg(IIC_CPLD_REG_CMD, CPLD_CMD_WR_DAC0) ;
    else if (nDac == 1)
        nStatusIic  = iic_write_cpld_reg(IIC_CPLD_REG_CMD, CPLD_CMD_WR_DAC1);
    else if (nDac == 2)
        nStatusIic  = iic_write_cpld_reg(IIC_CPLD_REG_CMD, CPLD_CMD_WR_DAC2);
    else if (nDac == 3)
        nStatusIic  = iic_write_cpld_reg(IIC_CPLD_REG_CMD, CPLD_CMD_WR_DAC3);
    else {
        xil_printf("iic_write_dac() illegal DAC number %d. Must be 0-3\r\n", nDac);
        return XST_FAILURE;
    }
    return nStatusIic;
}


//---------------------------------------------------------
// Write/Readback some CPLD registers
//#define IIC_CPLD_REG_CTRL       0x01    // Bit 5 -0 control various oscillator and DAC features
//#define IIC_CPLD_REG_CTRL_DAC   0x02    // Bit 3-0 control DAC amp enables, 7-4 DAC sleep mode
//#define IIC_CPLD_REG_EN_OUT     0x03    // Bit 3-0 DAC output enables, 5-4 SYNC controls
//#define IIC_CPLD_REG_ALARM      0x04    // Bit 3-0 DAC alarms, 4 AD7291 alert, 6-5 GA[1:0] status
//#define IIC_CPLD_REG_VERSION    0x05    // CPLD version (Read only)
//---------------------------------------------------------
int iic_cpld_test()
{
    int nStatusIic      = XST_SUCCESS;
    int nReadData       = 0;
    int nExpVersion     = 0x11;

    nReadData = iic_read_cpld_reg(IIC_CPLD_REG_CTRL);
    xil_printf("iic_cpld_test(0x01     CTRL)  0x%02X\r\n", nReadData);


    nReadData = iic_read_cpld_reg(IIC_CPLD_REG_CTRL_DAC);
    xil_printf("iic_cpld_test(0x02 CTRL_DAC)  0x%02X\r\n", nReadData);


    nReadData = iic_read_cpld_reg(IIC_CPLD_REG_EN_OUT);
    xil_printf("iic_cpld_test(0x03   EN_OUT)  0x%02X\r\n", nReadData);

    nReadData = iic_read_cpld_reg(IIC_CPLD_REG_ALARM);
    xil_printf("iic_cpld_test(0x04    ALARM)  0x%02X\r\n", nReadData);


    nReadData = iic_read_cpld_reg(IIC_CPLD_REG_VERSION);
    if (nReadData == nExpVersion)
        xil_printf("iic_cpld_test(0x05  VERSION)  0x%02X  PASS\r\n", nReadData);
    else
        xil_printf("iic_cpld_test(0x05  VERSION)  0x%02X  FAIL****\r\n", nReadData);
        

    /*
    // Write SPI word into CPLD SPI registers
    iic_write_cpld_reg(IIC_CPLD_REG_SPI_0, 0x06);
    iic_write_cpld_reg(IIC_CPLD_REG_SPI_1, 0x07);
    iic_write_cpld_reg(IIC_CPLD_REG_SPI_2, 0x08);
    iic_write_cpld_reg(IIC_CPLD_REG_SPI_3, 0x09);

    nReadData = iic_read_cpld_reg(IIC_CPLD_REG_SPI_0);
    if (nReadData == nExpData0)
        xil_printf("iic_cpld_test(0) PASS 0x%02X\r\n", nReadData);
    else
        xil_printf("iic_cpld_test(0) FAIL 0x%02X  ****\r\n", nReadData);
        
    nReadData = iic_read_cpld_reg(IIC_CPLD_REG_SPI_1);
    if (nReadData == nExpData1)
        xil_printf("iic_cpld_test(1) PASS 0x%02X\r\n", nReadData);
    else
        xil_printf("iic_cpld_test(1) FAIL 0x%02X  ****\r\n", nReadData);

    nReadData = iic_read_cpld_reg(IIC_CPLD_REG_SPI_2);
    if (nReadData == nExpData2)
        xil_printf("iic_cpld_test(2) PASS 0x%02X\r\n", nReadData);
    else
        xil_printf("iic_cpld_test(2) FAIL 0x%02X  ****\r\n", nReadData);

    nReadData = iic_read_cpld_reg(IIC_CPLD_REG_SPI_3);
    if (nReadData == nExpData3)
        xil_printf("iic_cpld_test(3) PASS 0x%02X\r\n", nReadData);
    else
        xil_printf("iic_cpld_test(3) FAIL 0x%02X  ****\r\n", nReadData);
*/
    return nStatusIic;
}


//---------------------------------------------------------
// Read 16-bit data from a FMC216 DAC register
// 
// The 32-bit SPI message is written into four registers on the CPLD
// then the CPLD command register is written with a bit to 
// select the target device.
// The 32-bit message starts with an 8-bit all zero word,
// then R/W bit 1=read, 0=write,
// followed by a 7 bit address and then 16 bits of dummy data.
// Two CPLD registers will contain the data that was read.
//---------------------------------------------------------
int iic_read_reg_dac(int nDac, int nReg)
{
    int nReadData       = 0xCCCC;
    u8 nSpiCommand      = (u8)((nReg & 0x7F) | 0x80);       // DAC register address, R/W_n = 1

    // Write SPI word into CPLD registers
    iic_write_cpld_reg(IIC_CPLD_REG_SPI_3, 0x00);
    iic_write_cpld_reg(IIC_CPLD_REG_SPI_2, nSpiCommand);
    iic_write_cpld_reg(IIC_CPLD_REG_SPI_1, 0x00);
    iic_write_cpld_reg(IIC_CPLD_REG_SPI_0, 0x00);

    // Trigger SPI read by setting a bit 
    if      (nDac == 0)
        iic_write_cpld_reg(IIC_CPLD_REG_CMD, CPLD_CMD_WR_DAC0) ;
    else if (nDac == 1)
        iic_write_cpld_reg(IIC_CPLD_REG_CMD, CPLD_CMD_WR_DAC1);
    else if (nDac == 2)
        iic_write_cpld_reg(IIC_CPLD_REG_CMD, CPLD_CMD_WR_DAC2);
    else if (nDac == 3)
        iic_write_cpld_reg(IIC_CPLD_REG_CMD, CPLD_CMD_WR_DAC3);
    else {
        xil_printf("iic_write_dac() illegal DAC number %d. Must be 0-3\r\n", nDac);
        return 0x5555;
    }

    // Read DAC data from the two CPLD registers
    nReadData  = iic_read_cpld_reg(IIC_CPLD_REG_SPI_RD_0) << 8;         // Upper bits
    nReadData  = nReadData + iic_read_cpld_reg(IIC_CPLD_REG_SPI_RD_1);  // Lower bits

    return nReadData;
}


//---------------------------------------------------------
// Write 8-bit data to a FMC216 LMK04828 clock chip register
// 
// The 32-bit SPI message is written into four registers on the CPLD
// then the CPLD command register is written with a bit to 
// select the target device.
// The 32-bit message starts with an 8-bit all zero dummy word,
// then R/W bit 1=read, 0=write,
// w1 and w0 bits , both zero,
// followed by a 13 bit address and then 8 bits of data
//---------------------------------------------------------
int iic_write_clk_reg(int nReg, int nData)
{
    int nStatusIic      = XST_SUCCESS;
    int nSpiAddr        = nReg & 0x1FFF;       // A12-A0 Register address
    u8  nSpiCmdUpper    = (u8)(nSpiAddr >> 8); 
    u8  nSpiCmdLower    = (u8)(nSpiAddr & 0xFF); 
    u8  nSpiData        = (u8)(nData & 0xFF);

    //(void)xil_printf("nReg          = 0x%04X\r\n", nReg);
    //(void)xil_printf("nSpiAddr      = 0x%04X\r\n", nSpiAddr);
    //(void)xil_printf("nSpiCmdUpper  = 0x%02X\r\n", nSpiCmdUpper);
    //(void)xil_printf("nSpiCmdLower  = 0x%02X\r\n", nSpiCmdLower);
    //(void)xil_printf("nSpiData      = 0x%02X\r\n", nSpiData);

    // Write SPI word into CPLD registers
    iic_write_cpld_reg(IIC_CPLD_REG_SPI_3, 0x00);           // SPI message 31:24
    iic_write_cpld_reg(IIC_CPLD_REG_SPI_2, nSpiCmdUpper);   // SPI message 23:16  r/w, w[1:0], addr[12:8]
    iic_write_cpld_reg(IIC_CPLD_REG_SPI_1, nSpiCmdLower);   // SPI message 15:8   addr[7:0]
    iic_write_cpld_reg(IIC_CPLD_REG_SPI_0, nSpiData);       // SPI message  7:0   d[7:0]

    // Trigger SPI write by setting a bit 
    nStatusIic  = iic_write_cpld_reg(IIC_CPLD_REG_CMD, CPLD_CMD_WR_CLK) ;

    lmk_dbg_emit_wr(nReg, nData);

    return nStatusIic;
}


//---------------------------------------------------------
// Read 8-bit data from a FMC216 Clock chip register
// 
// The 32-bit SPI message is written into four registers on the CPLD
// then the CPLD command register is written with a bit to 
// select the target device.
// The 32-bit message starts with an 8-bit all zero word,
// then R/W bit 1=read, 0=write,
// w1 and w0 bits , both zero,
// followed by a 13 bit address and then 8 bits of dummy data
// One CPLD register will contain the data that was read.
//---------------------------------------------------------
int iic_read_clk_reg(int nReg)
{
    int nReadData       = 0xCC;
    int nSpiAddr        = nReg & 0x1FFF;       // A12-A0 Register address
    u8  nSpiCmdUpper    = (u8)((nSpiAddr >> 8) | 0x80);
    u8  nSpiCmdLower    = (u8)(nSpiAddr & 0xFF);

    // Write SPI word into CPLD registers
    iic_write_cpld_reg(IIC_CPLD_REG_SPI_3, 0x00);
    iic_write_cpld_reg(IIC_CPLD_REG_SPI_2, nSpiCmdUpper);
    iic_write_cpld_reg(IIC_CPLD_REG_SPI_1, nSpiCmdLower);
    iic_write_cpld_reg(IIC_CPLD_REG_SPI_0, 0x00);

    // Trigger SPI read by setting a bit 
    iic_write_cpld_reg(IIC_CPLD_REG_CMD, CPLD_CMD_WR_CLK) ;

    // Read 8-bit data from the CPLD register
    nReadData  = iic_read_cpld_reg(IIC_CPLD_REG_SPI_RD_0) << 8;
    nReadData  = nReadData + iic_read_cpld_reg(IIC_CPLD_REG_SPI_RD_1);

    return nReadData;
}


//---------------------------------------------------------
// Bit 0 ‘0’ Disables output amplifiers for DAC Channels 0,1,2, and 3
//       ‘1’ Enables output amplifiers for DAC Channels 0,1,2, and 3
// Bit 1, channels 7-4
// Bit 2, channels 11-8
// Bit 3, channels 15-12
// Bit 4, '1'  Places DAC0 in sleep mode
// Bit 5, '1'  Places DAC1 in sleep mode
// Bit 6, '1'  Places DAC2 in sleep mode
// Bit 7, '1'  Places DAC3 in sleep mode
//---------------------------------------------------------
int iic_dacs_sleep(int nData)
{
    int nStatusIic      = XST_SUCCESS;

    // Write SPI word into CPLD registers
    nStatusIic = iic_write_cpld_reg(IIC_CPLD_REG_CTRL_DAC, (u8)(nData & 0xFF));

    return nStatusIic;
}

//---------------------------------------------------------
// Write to the DACs and the Clock generator on the
// selected FMC board to set their SPI interfaces to 4-wire
// mode so that registers can be read.
//---------------------------------------------------------
void iic_set_fmc_spi4()
{
    int nDac    = 0;
    int nWdata  = 0xCC;

    (void)xil_printf("iic_set_fmc_spi4()\r\n");

    // Set all four DAC chips to 4-wire SPI mode
    // Set bit7 (sif4_ena) to '1' in register config02
    nWdata = 0x0080;
    for (nDac = 0; nDac < 4 ; nDac++) {
        iic_write_dac_reg(nDac, 0x0002, nWdata);
        (void)xil_printf("DAC%d SPI set to 4-wire mode\r\n", nDac);
    }

    // Set bit4 (SPI_3WIRE_DIS) to '1' in reg0
    nWdata = 0x0010;
    iic_write_clk_reg(0x0000, nWdata);
    (void)xil_printf("Set LMK04821 SPI set to 4-wire mode  reg_0x000 to 0x%02X\r\n", nWdata);

    // Set PLL1_LD_MUX (reg_0x15F[7:3]) to 7 (SPI_Readback)
    // Set PLL1_LD_TYPE reg_0x15F[2:0]) to 3 (default: Push pull to CPLD. 06=Open drain output to CPLD)
    nWdata = (0x07 << 3) + 0x03;
    iic_write_clk_reg(0x015F, nWdata);
    (void)xil_printf("Set LMK04821 SPI output on PLL1_LD   reg_0x15F to 0x%02X\r\n", nWdata);

    (void)xil_printf("\r\n");
}

//---------------------------------------------------------
// Write to the DACs and the Clock generator on the
// selected FMC board to set their SPI interfaces to 4-wire
// mode so that registers can be read.
//---------------------------------------------------------
void iic_test_write_dacs_clk()
{
    int nDac    = 0;
    int nWdata  = 0x0;

    (void)xil_printf("iic_test_write_dacs_clk()\r\n");

    // Set all four DAC chips alarm reg config4
    nWdata = 0x1230;
    for (nDac = 0; nDac < 4 ; nDac++) {
        iic_write_dac_reg(nDac, ADR_CONFIG_4, (nWdata + nDac));
        (void)xil_printf("DAC%d config04 set to 0x123%d\r\n", nDac, nDac);
    }

    // Set reg 0x101 ADR_REG_LMK_DCLK0_DDLY to 0x44
    nWdata = 0x0044;
    iic_write_clk_reg(ADR_REG_LMK_DCLK0_DDLY, nWdata);
    (void)xil_printf("Set LMK04821 ADR_REG_LMK_DCLK0_DDLY to 0x%02X\r\n", nWdata);

    // Read back all four DAC chips alarm reg config4
    nWdata = 0x1230;
    for (nDac = 0; nDac < 4 ; nDac++) {
        if (iic_read_reg_dac(nDac, ADR_CONFIG_4) == (nWdata + nDac))
            (void)xil_printf("DAC%d config04 set to 0x123%d  PASS\r\n", nDac, nDac);
        else
            (void)xil_printf("DAC%d config04 set to 0x123%d  **** FAIL ****\r\n", nDac, nDac);
    }

    // Readback 0x101 ADR_REG_LMK_DCLK0_DDLY
    nWdata = 0x0044;
    if (iic_read_clk_reg(ADR_REG_LMK_DCLK0_DDLY) == nWdata)
        (void)xil_printf("Set LMK04821 ADR_REG_LMK_DCLK0_DDLY to 0x%02X PASS\r\n", nWdata);
    else
        (void)xil_printf("Set LMK04821 ADR_REG_LMK_DCLK0_DDLY to 0x%02X  **** FAIL ****\r\n", nWdata);

    (void)xil_printf("\r\n");
}


//---------------------------------------------------------
// Read default values from all FMC216 DAC registers
// and compare with expected value
//---------------------------------------------------------
void test_regs_default_dac(u8 nDac)
{
    int nReg    = 0;
    int nRdata  = 0xCC;

    (void)xil_printf("test_regs_default_dac(%d)\r\n", nDac);

    // Compare register values with defaults
    for (nReg = 0; nReg < NUM_REGS_DAC_39J84 ; nReg++) 
    {
        nRdata = iic_read_reg_dac(nDac, nReg);

        (void)xil_printf("DAC%d[%03d] :  0x%04X", nDac, nReg, nRdata);
        if (nRdata == arr_reg_dac_defaults[nReg])
            (void)xil_printf(" PASS\r\n");
        else
            (void)xil_printf(" FAIL ****\r\n");
    }
}

//---------------------------------------------------------
// Read default values from all FMC216 Clock chip registers
// and compare with expected value
//---------------------------------------------------------
void test_regs_default_clk()
{
    int nReg    = 0;
    int nRdata  = 0xCC;
    int nAddr   = 0xFF;

    (void)xil_printf("test_regs_default_clk()\r\n");

    // Compare register values with defaults
    for (nReg = 0; nReg < NUM_REGS_LMK04828 ; nReg++)
    {
        nAddr  = arr_reg_addr_clk[nReg];
        nRdata = iic_read_clk_reg(nAddr);

        (void)xil_printf("PLL[0x%03X] :  0x%02X", nAddr, nRdata);
        if (nRdata == arr_reg_default_clk[nReg])
            (void)xil_printf(" PASS\r\n");
        else
            (void)xil_printf(" FAIL ****\r\n");
    }
}


//---------------------------------------------------------
// Print first 3 DAC regs from currently enabled FMC216 board.
// Print the Clock chip ID regs
//   0x003 ID_DEVICE_TYPE
//   0x004 ID_PROD[15:8]
//   0x005 ID_PROD[7:0]
//   0x006 ID_MASKREV
//   0x00C ID_VNDR[15:8]
//   0x00D ID_VNDR[7:0]
//---------------------------------------------------------
void dump_regs_fmc()
{
    int nDac    = 0;
    int nRdata  = 0xCC;

    (void)xil_printf("dump_regs_fmc()\r\n");

    //-----------------------------------------------------
    // Print the ID registers from all four DAC chips
    for (nDac = 0; nDac < 4 ; nDac++) {
        nRdata = iic_read_reg_dac(nDac, 0x0000);
        (void)xil_printf("DAC%d[0] :  0x%04X\r\n", nDac, nRdata);   // Default 0x0218

        nRdata = iic_read_reg_dac(nDac, 0x0001);
        (void)xil_printf("DAC%d[1] :  0x%04X\r\n", nDac, nRdata);   // Default 0x0003

        nRdata = iic_read_reg_dac(nDac, 0x0002);
        (void)xil_printf("DAC%d[2] :  0x%04X\r\n", nDac, nRdata);   // Default 0x2002 w. 4 wire 0x2082

        (void)xil_printf("\r\n");
    }

    //-----------------------------------------------------
    // Print the Clock chip ID regs
    //   0x003 ID_DEVICE_TYPE
    //   0x004 ID_PROD[15:8]
    //   0x005 ID_PROD[7:0]
    //   0x006 ID_MASKREV
    //   0x00C ID_VNDR[15:8]
    //   0x00D ID_VNDR[7:0]
   nRdata = iic_read_clk_reg(ADR_REG_LMK_RESET);
   (void)xil_printf("LMK04821[LMK_RESET]            :  0x%03X\r\n",  nRdata);

   nRdata = iic_read_clk_reg(ADR_REG_LMK_PWR_DOWN);
   (void)xil_printf("LMK04821[LMK_PWR_DOWN]         :  0x%03X\r\n",  nRdata);

   nRdata = iic_read_clk_reg(ADR_REG_LMK_ID_DEVICE_TYPE);
   (void)xil_printf("LMK04821[LMK_ID_DEVICE_TYPE]   :  0x%03X",  nRdata);
   if (nRdata != DEF_LMK_ID_DEVICE_TYPE)
       (void)xil_printf("** FAIL **  expected 0x%03X\r\n",  DEF_LMK_ID_DEVICE_TYPE);
   else
       (void)xil_printf("\r\n");

   nRdata = iic_read_clk_reg(ADR_REG_LMK_ID_PROD1);
   (void)xil_printf("LMK04821[LMK_ID_PROD1]         :  0x%03X",  nRdata);
   if (nRdata != DEF_LMK_ID_PROD1)
       (void)xil_printf("** FAIL **  expected 0x%03X\r\n",  DEF_LMK_ID_PROD1);
   else
       (void)xil_printf("\r\n");

   nRdata = iic_read_clk_reg(ADR_REG_LMK_ID_PROD0);
   (void)xil_printf("LMK04821[LMK_ID_PROD0]         :  0x%03X",  nRdata);
   if (nRdata != DEF_LMK_ID_PROD0)
       (void)xil_printf("** FAIL **  expected 0x%03X\r\n",  DEF_LMK_ID_PROD0);
   else
       (void)xil_printf("\r\n");

   nRdata = iic_read_clk_reg(ADR_REG_LMK_ID_MASKREV);
   (void)xil_printf("LMK04821[LMK_ID_MASKREV]       :  0x%03X",  nRdata);
   if (nRdata != DEF_LMK_ID_MASKREV)
       (void)xil_printf("** FAIL **  expected 0x%03X\r\n",  DEF_LMK_ID_MASKREV);
   else
       (void)xil_printf("\r\n");

   nRdata = iic_read_clk_reg(ADR_REG_LMK_ID_VNDR1);
   (void)xil_printf("LMK04821[LMK_ID_VNDR1]         :  0x%03X",  nRdata);
   if (nRdata != DEF_LMK_ID_VNDR1)
       (void)xil_printf("** FAIL **  expected 0x%03X\r\n",  DEF_LMK_ID_VNDR1);
   else
       (void)xil_printf("\r\n");

   nRdata = iic_read_clk_reg(ADR_REG_LMK_ID_VNDR0);
   (void)xil_printf("LMK04821[LMK_ID_VNDR0]         :  0x%03X",  nRdata);
   if (nRdata != DEF_LMK_ID_VNDR0)
       (void)xil_printf("** FAIL **  expected 0x%03X\r\n",  DEF_LMK_ID_VNDR0);
   else
       (void)xil_printf("\r\n");}


//---------------------------------------------------------
// Enable AD7291 temperature measurements
//---------------------------------------------------------
int iic_enable_fmc_temp()
{
    int nStatusIic;
    u8  MsgWr[3];

    xil_printf("iic_enable_fmc_temp()\r\n");

    // Wait for bus to be free
    while (XIicPs_BusIsBusy(&IicPs1)) {
        /* NOP */
    }

    // First write the address pointer register followed by 16-bit data.
    MsgWr[0] = (u8)0x00;  // Select the command reg
    MsgWr[1] = (u8)0x00;  // Set MSB[15:8]
    MsgWr[2] = (u8)0x80;  // Set bit 7, TSENSE enable

    nStatusIic  = XIicPs_MasterSendPolled(&IicPs1, &MsgWr[0], 3, IIC_ADDR_ABA_VMON);

    if (nStatusIic != XST_SUCCESS) {
        xil_printf("Fail to set AD7291 address %d , status  0x%04X\r\n", 0, nStatusIic);
        return XST_FAILURE;
    }
    else

        return XST_SUCCESS;
}


//---------------------------------------------------------
// Read the contents of a AD7291 temperature register
//---------------------------------------------------------
int iic_read_fmc_temp(int nReg)
{
    int nStatusIic;
    u8  MsgRd[2];
    u8  MsgWr[2];
    int nTemp = 0;

    xil_printf("iic_read_fmc_temp(%d)\r\n", nReg);

    // Wait for bus to be free
    while (XIicPs_BusIsBusy(&IicPs1)) {
        /* NOP */
    }
    // Read  temperature register
    // First write the address
    MsgWr[0] = (u8)nReg; //

    nStatusIic  = XIicPs_MasterSendPolled(&IicPs1, &MsgWr[0], 1, IIC_ADDR_ABA_VMON);

    if (nStatusIic != XST_SUCCESS) {
        xil_printf("Fail to set AD7291 address %d , status  0x%04X\r\n", nReg, nStatusIic);
        return XST_FAILURE;
    }
    else { // Read back data
        MsgRd[0] =  0xCC;
        MsgRd[1] =  0xCC;

        nStatusIic = XIicPs_MasterRecvPolled(&IicPs1, &MsgRd[0], 2, IIC_ADDR_ABA_VMON);

        if (nStatusIic != XST_SUCCESS) {
            xil_printf("Fail to read VMON register %d, status 0x%04X\r\n", nReg, nStatusIic);
            return XST_FAILURE;
        }
        else {
            nTemp = (MsgRd[0] << 8) + MsgRd[1];
            xil_printf("Read VMON[%d] = 0x%04X\r\n", nReg, nTemp);
            return nTemp;
        }
    }
}


//----------------------------------------------------------------
// MAIN
//----------------------------------------------------------------
int main()
{
    u32     nRdata = 0;

    char    cUartRx;    // Data from UART

    u8      nDigit  = 0;

    int     nValue  = 0;
    int     nSwPulseChannel = 0;
    int     nSwDac          = 0;
    int     nSwInvert       = 0;
    int     nSwZero         = 0;

    int     fmc0_detected = 0;
    int     fmc1_detected = 0;

    int     nStateButtonsLast   = 0;
    int     nStateSwitchesLast  = 0;
    int     nMode = C_MODE_CMD;
    int     nStatusIic;

    init_platform();

   (void)xil_printf("---------------------------------------------------------------------\r\n");
   (void)xil_printf(" app_qlaser1 : version %s\r\n", g_strVersion);
   (void)xil_printf("---------------------------------------------------------------------\r\n");
    nRdata = Xil_In32(ADR_MISC_VERSION);
   (void)xil_printf("FPGA Version = 0x%08X\r\n", nRdata);
    print("\n\r");

    //----------------------------------------------------------------------
    // Initialize the IIC driver so that it's ready to use
    // Look up the configuration in the config table, then initialize it.
    //----------------------------------------------------------------------
    IicConfig0 = XIicPs_LookupConfig(IIC_0_DEVICE_ID);
    if (NULL == IicConfig0) {
        xil_printf("Fail lookup IIC_0\r\n");
    }

    nStatusIic = XIicPs_CfgInitialize(&IicPs0, IicConfig0, IicConfig0->BaseAddress);
    if (nStatusIic != XST_SUCCESS) {
        xil_printf("Fail config IIC_0\r\n");
    }
    else {
        xil_printf("Successfully config IIC_0\r\n");
    }

    IicConfig1 = XIicPs_LookupConfig(IIC_1_DEVICE_ID);
    if (NULL == IicConfig1) {
        xil_printf("Fail lookup IIC_1\r\n");
    }

    nStatusIic = XIicPs_CfgInitialize(&IicPs1, IicConfig1, IicConfig1->BaseAddress);
    if (nStatusIic != XST_SUCCESS) {
        xil_printf("Fail config IIC_1\r\n");
    }
    else {
        xil_printf("Successfully config IIC_1\r\n");
    }
    // Set I2C bus clock rates
    XIicPs_SetSClk(&IicPs0, 100000);
    XIicPs_SetSClk(&IicPs1, 100000);


    //----------------------------------------------------------------------
    // Detect FMC boards (Fpga Mezzanine Cards)
    //----------------------------------------------------------------------
    // Write port expander to make presence detect bits inputs P10, P11
    iic_write_portexp_reg(IIC_ADDR_ZCU_PORT_EXP_U97, REG_PORT_EXP_CONFIG1, 0x03);
    fmc0_detected = is_present_fmc(FMC_BOARD_0);
    (void)xil_printf("fmc0_detected = %d\r\n", fmc0_detected);
    fmc1_detected = is_present_fmc(FMC_BOARD_1);
    (void)xil_printf("fmc1_detected = %d\r\n", fmc1_detected);

    //-----------------------------------------------------
    // Reset DACs and clock. (Required after power-up).
    // Set FMC DACs and Clock chip to 4-wire SPI mode so that they can be read
    //-----------------------------------------------------
    if (fmc0_detected == 1) {
        iic_enable_fmc(0);
        iic_fmc_reset_dacs_and_clk();
        iic_set_fmc_spi4();
        dump_regs_fmc();

        // Lowest power dissipation
        iic_dacs_sleep(0xF0);

        // Enable temperature measurements
        (void)iic_enable_fmc_temp();
    }
    if (fmc1_detected == 1) {
        iic_enable_fmc(1);
        iic_fmc_reset_dacs_and_clk();
        iic_set_fmc_spi4();
        dump_regs_fmc();

        // Lowest power dissipation
        iic_dacs_sleep(0xF0);

        // Enable temperature measurements
        (void)iic_enable_fmc_temp();
    }

    //----------------------------------------------------------------------
    // Write to the ZCU102 board I2C_1 mux. Set bit 0 to enable connection to FMC_0
    //----------------------------------------------------------------------
    if (fmc0_detected == 1) {
        iic_enable_fmc(0);
        iic_read_fmc_mux();
    }


    //----------------------------------------------------------------------
    // Command parser. Loops forever.
    //----------------------------------------------------------------------
    print("Ready>\r\n");

    while (1)
    {
        if (XUartPs_IsReceiveData(STDIN_BASEADDRESS))
        {
            cUartRx = (u8)XUartPs_ReadReg(STDIN_BASEADDRESS, XUARTPS_FIFO_OFFSET);
            outbyte(cUartRx);       // Echo the received char
            outbyte(0x0D);          // CR
            outbyte(0x0A);          // LF

            //---------------------------------------------------------------------
            // In COMMAND mode all non-digit characters are single-character commands
            //---------------------------------------------------------------------
            if (nMode == C_MODE_CMD)
            {
                //---------------------------------------------------------
                // If character is 0-9, build a number value with it.
                // Every time a consecutive digit is received, multiply nValue by 10 and add the new digit.
                //---------------------------------------------------------
                if ( (cUartRx >= 0x30) && (cUartRx <= 0x39) )
                {
                    if (nDigit == 0)
                        nValue = cUartRx - 0x30;
                    else
                        nValue = (nValue * 10) + (cUartRx - 0x30);

                    nDigit++;
                   (void)xil_printf("Value = %d\r\n", nValue);
                }

                else       // All non-digit characters are single-character commands
                {
                    switch (cUartRx)
                    {
                        //---------------------------------------------------------
                        // Help menu
                        //---------------------------------------------------------
                        case 'h': 
                            print_help();
                        break;


                        //---------------------------------------------------------
                        // Print registers
                        //---------------------------------------------------------
                        case 'P':
                            print_regs(nValue);
                        break;


                        //---------------------------------------------------------
                        // Reset stuff
                        //---------------------------------------------------------
                        case 'R':
                            // Reset DACs and clock chip using the CPLD REG_CTRL bits
                            // write 08 then 07
                            iic_fmc_reset_dacs_and_clk();

                            if (fmc0_detected == 1) {
                                iic_enable_fmc(0);
                                iic_fmc_reset_dacs_and_clk();
                                iic_set_fmc_spi4();
                                dump_regs_fmc();

                                // Lowest power dissipation
                                iic_dacs_sleep(0xF0);

                                // Enable temperature measurements
                                (void)iic_enable_fmc_temp();
                            }
                            if (fmc1_detected == 1) {
                                iic_enable_fmc(1);
                                iic_fmc_reset_dacs_and_clk();
                                iic_set_fmc_spi4();
                                dump_regs_fmc();

                                // Lowest power dissipation
                                iic_dacs_sleep(0xF0);

                                // Enable temperature measurements
                                (void)iic_enable_fmc_temp();
                            }

                            // Clear a DACs error count registers (config100-config109)
                            //for (int n = ADR_CONFIG_100 ; n < ADR_CONFIG_110 ; n++) {
                            //    iic_write_dac_reg(nValue, n , 0xFFFF);
                            //}
                            switch_jesd_clear();

                        break;


                        //---------------------------------------------------------
                        // Test Pulse Channel RAMs
                        //---------------------------------------------------------
                        case 'M':
                           // Load each channel and read back. Dummy channels have only a single register
                           int nPulseChannelsFull = 0x00000001;    // Set a bit for each channel that has full logic
                           (void)pulse_channels_rams_test(nPulseChannelsFull);
                        break;


                        //---------------------------------------------------------
                        // Set pulse sequence length
                        //---------------------------------------------------------
                        case 's':
                            (void)xil_printf ("Set pulse seq length to %d\r\n", nValue);

                            Xil_Out32(ADR_PULSE_REG_SEQ_LEN, nValue);
                            nRdata = Xil_In32(ADR_PULSE_REG_SEQ_LEN);
                            (void)xil_printf ("Verify 0x%08X\r\n", nRdata);

                        break;

                        //---------------------------------------------------------
                        // Set Pulse block channel select register
                        //---------------------------------------------------------
                        case 'c':
                            if (nValue == 99)
                                pulse_chsel_set(0xFFFFFFFF);
                            else
                                pulse_chsel_set(nValue);
                        break;

                        //---------------------------------------------------------
                        // AXI-switch routing.  'I', 'Z' and 'D' only latch a value;
                        // 'W' applies them, routing pulse channel 'W' to output 'D'
                        // with the invert/zero flags from 'I'/'Z'.
                        //---------------------------------------------------------
                        case 'I':
                                nSwInvert   = nValue & 0x1;
                                (void)xil_printf("nSwInvert = %d\r\n", nSwInvert);
                        break;
                        case 'Z':
                                nSwZero     = nValue & 0x1;
                                (void)xil_printf("nSwZero = %d\r\n", nSwZero);
                        break;
                        case 'D':
                                nSwDac      = nValue & 0x1F;
                                (void)xil_printf("nSwDac = %d\r\n", nSwDac);
                        break;
                        case 'W':
                        		if (nValue == 99)
                        			switch_jesd_init();
                        		else
                        		{
                        			nSwPulseChannel	= (nValue & 0x1F);
                                	(void)xil_printf("nSwPulseChannel = %d\r\n", nSwPulseChannel);

                                	switch_jesd_set(nSwDac, nSwPulseChannel, nSwInvert, nSwZero);
                        		}
                        break;

                        //---------------------------------------------------------
                        // Toggle a LED bit
                        //---------------------------------------------------------
                        case 'g':
                            //gpo_toggle(nValue, ADR_MISC_LEDS);
                           (void)xil_printf ("Set ADR_MISC_LEDS = to %X\r\n", nValue);
                           (void)xil_printf ("ADR_MISC_LEDS = %08X\r\n", ADR_MISC_LEDS);
                            Xil_Out32(ADR_MISC_LEDS, nValue);
                        break;

                        //----------------------------------------------------------------------
                        // Read from the U61 and U97 port expanders on the ZCU102 board I2C_0 bus.
                        //----------------------------------------------------------------------
                        case 'x':

                            //----------------------------------------------------------------------
                            // Read all Port Expander registers
                            //----------------------------------------------------------------------
                            xil_printf("Read PortExp U61\r\n");
                            iic_read_portexp_reg(IIC_ADDR_ZCU_PORT_EXP_U61, 0);
                            iic_read_portexp_reg(IIC_ADDR_ZCU_PORT_EXP_U61, 1);
                            iic_read_portexp_reg(IIC_ADDR_ZCU_PORT_EXP_U61, 2);
                            iic_read_portexp_reg(IIC_ADDR_ZCU_PORT_EXP_U61, 3);
                            iic_read_portexp_reg(IIC_ADDR_ZCU_PORT_EXP_U61, 4);
                            iic_read_portexp_reg(IIC_ADDR_ZCU_PORT_EXP_U61, 5);
                            iic_read_portexp_reg(IIC_ADDR_ZCU_PORT_EXP_U61, 6);
                            iic_read_portexp_reg(IIC_ADDR_ZCU_PORT_EXP_U61, 7);


                            xil_printf("Read PortExp U97\r\n");
                            iic_read_portexp_reg(IIC_ADDR_ZCU_PORT_EXP_U97, 0);
                            iic_read_portexp_reg(IIC_ADDR_ZCU_PORT_EXP_U97, 1);
                            iic_read_portexp_reg(IIC_ADDR_ZCU_PORT_EXP_U97, 2);
                            iic_read_portexp_reg(IIC_ADDR_ZCU_PORT_EXP_U97, 3);
                            iic_read_portexp_reg(IIC_ADDR_ZCU_PORT_EXP_U97, 4);
                            iic_read_portexp_reg(IIC_ADDR_ZCU_PORT_EXP_U97, 5);
                            iic_read_portexp_reg(IIC_ADDR_ZCU_PORT_EXP_U97, 6);
                            iic_read_portexp_reg(IIC_ADDR_ZCU_PORT_EXP_U97, 7);

                        break;

                        //----------------------------------------------------------------------
                        // Read from the IN1 reg U97 port expander on the ZCU102 board I2C_0 bus.
                        // Bit-7 and bit-6 are presence detect bits for the FMC216 boards
                        //----------------------------------------------------------------------
                        case 'i':

                            //----------------------------------------------------------------------
                            // Detect FMC boards (Fpga Mezzanine Cards)
                            //----------------------------------------------------------------------
                            fmc0_detected = is_present_fmc(FMC_BOARD_0);
                            (void)xil_printf("fmc0_detected = %d\r\n", fmc0_detected);
                            fmc1_detected = is_present_fmc(FMC_BOARD_1);
                            (void)xil_printf("fmc1_detected = %d\r\n", fmc1_detected);

                        break;

                        case 'p':
                            //----------------------------------------------------------------------
                            // Read all CPLD registers
                            //----------------------------------------------------------------------
                            xil_printf("Read FMC216 CPLD registers\r\n");

                            // Read 0 to 15
                            for (int i=0; i < 16 ; i++) 
                            {
                                xil_printf("CPLD[%d] = 0x%02X\r\n", i, iic_read_cpld_reg((u8)i));
                            }
                        break;


                        //----------------------------------------------------------------------
                        // Write to the ZCU102 board I2C_1 mux.
                        // I2C mux setting to 'value'
                        // Set bit 0 to enable connection to FMC_0
                        // Set bit 1 to enable connection to FMC_1
                        //----------------------------------------------------------------------
                        case 'm':

                            iic_enable_fmc(nValue);
                            iic_read_fmc_mux();

                        break;

                        //----------------------------------------------------------------------
                        // Lock/Unlock PLL SPI write access
                        //----------------------------------------------------------------------
                        case 'L':

                        	if (nValue == 0)
                        		fmc216_clks_spi_unlock();
                        	else
                        		fmc216_clks_spi_lock();

                        break;


                        //----------------------------------------------------------------------
                        // Read temp from FMC216 AD7291 voltage/temp monitor chip
                        //----------------------------------------------------------------------
                        case 't':
                            iic_read_fmc_temp(0);
                            iic_read_fmc_temp(1);
                            iic_read_fmc_temp(2);   // Tsense
                            iic_read_fmc_temp(3);   // Averaged Temp
                            iic_read_fmc_temp(4);
                            iic_read_fmc_temp(5);
                            iic_read_fmc_temp(6);
                            iic_read_fmc_temp(7);

                            // Convert 11 LSB to degrees. Bits [15:12] should be 0x80
                            double dTemp = (double)(iic_read_fmc_temp(2) & 0xFFF)/4.0;
                            printf("Temperature = %5.2f degrees C\r\n", dTemp);

                        break;

                        //----------------------------------------------------------------------
                        // Set sleep mode for DACs
                        //----------------------------------------------------------------------
                        case 'S':
                            iic_dacs_sleep(0xF0);
                        break;

                        //----------------------------------------------------------------------
                        // Set awake mode for DACs
                        //----------------------------------------------------------------------
                        case 'A':
                            iic_dacs_sleep(0x0F);
                        break;

                        //----------------------------------------------------------------------
                        // Read some registers from FMC board CPLD, DACs and Clock chip
                        //----------------------------------------------------------------------
                        case 'd':
                            dump_regs_fmc();
                        break;

                        //----------------------------------------------------------------------
                        // Set FMC DACs and Clock chip to 4-wire SPI mode so that they can be read
                        //----------------------------------------------------------------------
                        case 'k':
                            iic_set_fmc_spi4();
                        break;

                        //----------------------------------------------------------------------
                        // Test something
                        //----------------------------------------------------------------------
                        case 'T':
                            // Read default values from DAC chips
                            if      (nValue == 0)
                                test_regs_default_dac(0);
                            else if (nValue == 1)
                                test_regs_default_dac(1);
                            else if (nValue == 2)
                                test_regs_default_dac(2);
                            else if (nValue == 3)
                                test_regs_default_dac(3);

                            // Read default register values of clock generator
                            else if (nValue == 4)
                                test_regs_default_clk();

                            // CPLD test R/W
                            else if (nValue == 5)
                                iic_cpld_test();

                        break;

                        //----------------------------------------------------------------------
                        // Test writes to a DAC reg and a clock reg
                        //----------------------------------------------------------------------
                        case 'y':
                            iic_test_write_dacs_clk();
                        break;

                        //----------------------------------------------------------------------
                        // Initialize FMC216 board PLL and DACs
                        //----------------------------------------------------------------------
                        case 'F':
                            fmc216_boards_init();
                        break;

                        //----------------------------------------------------------------------
                        // Initialize FMCs with an EXTERNAL 100 MHz reference on CLKin1.
                        // Same DACCLK (100 MHz) and SYSREF (3.125 MHz) as 'F'; only the
                        // PLL1 reference source changes (CLKin1 SMA instead of on-board
                        // CCLD-033-50 on CLKin2).  Patches CLKin1_R = 1250 and 0x147[6:4] = 1.
                        //----------------------------------------------------------------------
                        case 'X':
                            fmc216_boards_init_with_clkin_src(LMK_PLL1_CLKIN_EXTERNAL);
                        break;

                        //----------------------------------------------------------------------
                        // LMK04828 Distribution Mode (TI SNAS605 §9.4.5) — bypass BOTH PLLs;
                        // route external 200 MHz on CLKin1/Fin through the output dividers.
                        // DACCLK = 200 MHz (bypass), DCLKout10 = 100 MHz (÷2), SYSREF = 6.25 MHz.
                        // No PLL lock required; ideal fallback when PLL1 won't lock.
                        //----------------------------------------------------------------------
                        case 'B':
                            fmc216_boards_init_distribution_extref();
                        break;

                        //----------------------------------------------------------------------
                        // Detailed clock debug sequence and focused LMK/CPLD report
                        //----------------------------------------------------------------------
                        case 'C':
                            debug_clocks_fmc(nValue);
                        break;

                        //----------------------------------------------------------------------
                        // CLKin sweep: try CLKin0/1/2 manually as PLL1 reference and report
                        // which (if any) lets PLL1 lock.  Use this to isolate a dead on-board
                        // 100 MHz oscillator from a healthy LMK / divider configuration.
                        //----------------------------------------------------------------------
                        case 'J':
                            if (fmc0_detected == 1) {
                                iic_enable_fmc(FMC0);
                            } else if (fmc1_detected == 1) {
                                iic_enable_fmc(FMC1);
                            } else {
                                (void)xil_printf("J: no FMC detected — run F first.\r\n");
                                break;
                            }
                            fmc216_clks_spi_unlock();
                            lmk_clksrc_sweep_test();
                            fmc216_clks_spi_lock();
                        break;

                        //----------------------------------------------------------------------
                        // PLL1 deep diagnostic: RB_DAC motion, MAN_DAC/holdover, divider checks
                        //----------------------------------------------------------------------
                        case 'Q':
                            if (fmc0_detected == 1) {
                                iic_enable_fmc(FMC0);
                            } else if (fmc1_detected == 1) {
                                iic_enable_fmc(FMC1);
                            } else {
                                (void)xil_printf("Q: no FMC detected — run F first.\r\n");
                                break;
                            }
                            iic_set_fmc_spi4();
                            fmc216_clks_spi_unlock();
                            lmk_dump_pll1_debug();
                            fmc216_clks_spi_lock();
                        break;


                        //----------------------------------------------------------------------
                        // 'Go' : Write ramps generators, init the switch, enable all channels
                        // then set the PS output to enable data generation (loop)
                        //----------------------------------------------------------------------
                        case 'G':
                        	switch_jesd_init();
                        	pulse_ramp_all_set();
                        	pulse_set_ch_en (0xFFFFFFFF);
                        	set_ps_gpio_pulse_en(nValue); // 1 to run, 0 to stop
                        break;

                        //----------------------------------------------------------------------
                        // FMC216 analog outputs: 1E enables the amplifier banks and DAC
                        // TXENABLE lines, 0E mutes them (outputs go to midscale).
                        //----------------------------------------------------------------------
                        case 'E':
                            if (fmc0_detected == 1) {
                                iic_enable_fmc(FMC0);
                                fmc216_outputs_enable(FMC0, nValue);
                            }
                            if (fmc1_detected == 1) {
                                iic_enable_fmc(FMC1);
                                fmc216_outputs_enable(FMC1, nValue);
                            }
                            if ((fmc0_detected == 0) && (fmc1_detected == 0))
                                (void)xil_printf("E: no FMC detected — run F first.\r\n");
                        break;

                        //----------------------------------------------------------------------
                        // One-hot channel test: <n>O leaves only channel n ramping so you can
                        // identify which SMA it comes out of.  99O restores all channels.
                        //----------------------------------------------------------------------
                        case 'O':
                            switch_one_hot(nValue);
                        break;

                        //----------------------------------------------------------------------
                        // JESD link status: SYSREF capture, SYNC~ and per-lane ILA settings
                        //----------------------------------------------------------------------
                        case 'e':
                            if (fmc0_detected == 1)
                                jesd_link_status(FMC0);
#if JESD_HAS_FMC1
                            if (fmc1_detected == 1)
                                jesd_link_status(FMC1);
#endif
                            if ((fmc0_detected == 0) && (fmc1_detected == 0))
                                (void)xil_printf("e: no FMC detected — run F first.\r\n");
                        break;

                    }
                    nDigit = 0;
                }
            }
        }

        //----------------------------------------------------------------------
        // Print button state if it changes. Carry out user actions.
        // No de-bouncing but seems to be safe. (Delays in interrupt routine etc)
        //----------------------------------------------------------------------
        nRdata = Xil_In32(ADR_GPIO_BTN);
        g_nStateButtons = nRdata;
        Xil_Out32(ADR_GPIO_LED, nRdata);

        if (g_nStateButtons != nStateButtonsLast)
        {
           (void)xil_printf ("Buttons changed to %d\r\n", g_nStateButtons);

            // Add actions here
            if (g_nStateButtons == 0x1)     // Button 0 was pressed
            {
                xil_printf ("Button 1 \r\n");
            }
            nStateButtonsLast = g_nStateButtons;
        }
        //----------------------------------------------------------------------
        // Print switch state if it changed. Carry out user actions.
        //----------------------------------------------------------------------
        if (g_nStateSwitches != nStateSwitchesLast)
        {
           (void)xil_printf ("Switches changed to %d\r\n", g_nStateSwitches);

            //--------------------------------------------------------------
            // If SW1 is set then enable real messages
            //--------------------------------------------------------------
            if ((g_nStateSwitches & 0x2) == 2) {
                xil_printf ("Switch 2 \r\n");
            }
            //--------------------------------------------------------------
            // If SW0 is set then enable dummy messages
            //--------------------------------------------------------------
            else if ((g_nStateSwitches & 0x1) == 1){
                xil_printf ("Switch 1 \r\n");

            }
            else {
                xil_printf ("Switch ? \r\n");

            }
            nStateSwitchesLast = g_nStateSwitches;
        }
    }

    print("Exit!\n");
    cleanup_platform();
    return 0;
}
