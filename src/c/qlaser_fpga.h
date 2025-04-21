#ifndef __QLASER_FPGA_H_
#define __QLASER_FPGA_H_

#include "xparameters.h"
#include <stdio.h>
#include "stdbool.h"
#include "xil_printf.h"
#include "xil_io.h"
#include "xuartps_hw.h"

// Addresses reached through CPUINT
#define ADR_BASE_CPUINT    XPAR_AXI_CPUINT_S00_AXI_BASEADDR   // from xparameters.h

// Debug vGPIO interface
#define ADR_BASE_GPIO_INT  XPAR_AXI_GPIO_INT_BASEADDR
#define ADR_GPIO_IN        (ADR_BASE_GPIO_INT + 0x0)
#define ADR_GPIO_OUT       (ADR_BASE_GPIO_INT + 0x8)

// LED and Button GPIO interfaces
#define ADR_BASE_GPIO_LED_BTN   XPAR_AXI_GPIO_LED_BTN_BASEADDR  // 'XPAR' addresses are from xparameter.h (vitis generated file)
#define ADR_GPIO_LED       (ADR_BASE_GPIO_LED_BTN + 0x0)
#define ADR_GPIO_BTN       (ADR_BASE_GPIO_LED_BTN + 0x8)

// Main sub-block base addresses. ps_addr (17:16) are used to make four block selects.
#define ADR_BASE_DACS_DC    (ADR_BASE_CPUINT + 0x00000)
#define ADR_BASE_DACS_AC    (ADR_BASE_CPUINT + 0x10000)
#define ADR_BASE_MISC       (ADR_BASE_CPUINT + 0x20000)
#define ADR_BASE_P2PMOD     (ADR_BASE_CPUINT + 0x30000)

// MISC block registers (32-bit word addresses)
#define ADR_MISC_VERSION    (ADR_BASE_MISC + 4*0x0000)
#define ADR_MISC_LEDS       (ADR_BASE_MISC + 4*0x0001)     // '1' sets LED on if corresponding bit in reg_leds_en is also set
#define ADR_MISC_LEDS_EN    (ADR_BASE_MISC + 4*0x0002)     // '1' allows CPU control of LEDs. '0' allows FPGA logic
#define ADR_MISC_DEBUG_CTRL (ADR_BASE_MISC + 4*0x0003)     // Select debug output from top level to pins
#define ADR_MISC_TRIGGER    (ADR_BASE_MISC + 4*0x0004)     // Generate trigger
#define ADR_MISC_ENABLE     (ADR_BASE_MISC + 4*0x0005)     // Generate enable

// DAC DC block registers (32-bit word addresses)
#define C_ADDR_SPI0         (ADR_BASE_DACS_DC + 8*4*0x00000)
#define C_ADDR_SPI1         (ADR_BASE_DACS_DC + 8*4*0x00001)
#define C_ADDR_SPI2         (ADR_BASE_DACS_DC + 8*4*0x00002)
#define C_ADDR_SPI3         (ADR_BASE_DACS_DC + 8*4*0x00003)
#define C_ADDR_SPI_ALL      (ADR_BASE_DACS_DC + 8*4*0x00004)
#define C_ADDR_INTERNAL_REF (ADR_BASE_DACS_DC + 8*4*0x00005)
#define C_ADDR_POWER_ON     (ADR_BASE_DACS_DC + 8*4*0x00006)
#define C_ADDR_SPI_STATUS   (ADR_BASE_DACS_DC + 8*4*0x00007)


#define PMOD_ADDR_SPI0         (ADR_BASE_P2PMOD + 8*4*0x00000)
#define PMOD_ADDR_SPI1         (ADR_BASE_P2PMOD + 8*4*0x00001)
#define PMOD_ADDR_INTERNAL_REF (ADR_BASE_P2PMOD + 8*4*0x00005)
#define PMOD_ADDR_POWER_ON     (ADR_BASE_P2PMOD + 8*4*0x00006)
#define PMOD_ADDR_CTRL         (ADR_BASE_P2PMOD + 8*4*0x00007)


// DAC DC block commands (sent to DAC)
#define C_CMD_DAC_DC_WR            0x30000
#define C_CMD_DAC_DC_INTERNAL_REF  0x8
#define C_CMD_DAC_DC_POWER         0x4

// DAC AC (Pulse) block sub-blocks.
// Block contains 32 channels. Channels are accessed by first setting bit to '1' in the channel select reg. REG_CH_SEL)
#define ADR_BASE_PULSE_REGS      (ADR_BASE_DACS_AC + 0x4000)
#define ADR_PULSE_REG_SEQ_LEN    (ADR_BASE_PULSE_REGS + 4*0x00)
#define ADR_PULSE_REG_CHSEL      (ADR_BASE_PULSE_REGS + 4*0x01)    // Channel select
#define ADR_PULSE_REG_CHEN       (ADR_BASE_PULSE_REGS + 4*0x02)    //
#define ADR_PULSE_REG_CHSTATUS   (ADR_BASE_PULSE_REGS + 4*0x03)    // Global status bit-0 = busy, '1' if any ch running, bit-4 error set if any JESD channel is not sync'ed
#define ADR_PULSE_REG_JESDSTATUS (ADR_BASE_PULSE_REGS + 4*0x04)    // Channel JESD status. One bit per channel. Set if JESD not sync'ed.
#define ADR_PULSE_REG_TIMER      (ADR_BASE_PULSE_REGS + 4*0x05)    // Current timer count since trigger
// Errors
#define ADR_REG_ERR_RAM_OF       (ADR_BASE_PULSE_REGS + 4*0x06)
#define ADR_REG_ERR_INVAL_LEN    (ADR_BASE_PULSE_REGS + 4*0x07)
#define ADR_REG_ERR_BIG_STEP     (ADR_BASE_PULSE_REGS + 4*0x08)
#define ADR_REG_ERR_BIG_GAIN     (ADR_BASE_PULSE_REGS + 4*0x09)
#define ADR_REG_ERR_SMALL_TIME   (ADR_BASE_PULSE_REGS + 4*0x0A)
#define ADR_REG_ERR_START_TIME   (ADR_BASE_PULSE_REGS + 4*0x0B)

// RAM base address
#define ADR_BASE_PULSE_WAVE     (ADR_BASE_DACS_AC + 0x2000)       // Either (512 x 32) for 1K table, or (2K x 32) for 4K tables
#define ADR_BASE_PULSE_DEFN     (ADR_BASE_DACS_AC + 0x0000)
// Pulse generator headers
#define SIZERAM_PULSE_WAVE 2048			// Each memory address contains two waveform points
#define SIZERAM_PULSE_DEFN 1024			// Each entry consists of 4 32-bit words
#define PDEF_NUM_ENTRY     (SIZERAM_PULSE_DEFN/4)
#define C_BITS_ADDR_WAVE   16  			// Number of bits in address for waveform
#define MAX_CHANNEL        32           // Numbers of AC channels

//----------------------------------------------------------------------
// PS GPIO constants
//----------------------------------------------------------------------
#define C_GPIO_PS_TRIG         0   // Trigger for PS GPIO
#define C_GPIO_PS_EN           1   // Enable PS GPIO
#define C_GPIO_PS_ERR_CLR      2   // Clear error flags
#define C_GPIO_PS_DEBUG_SEL    3   // Select if PS debug should output PMOD0 or PMOD1

// Mode defines how subsequent characters are handled
#define C_MODE_CMD      0   // single char commands. 0-9 are characters are used to build a decimal value


extern char    g_strVersion[];
extern int     g_nStateButtons;
extern int     g_nStateSwitches;
extern unsigned int address;
extern int g_pulseDefinitions[MAX_CHANNEL][SIZERAM_PULSE_DEFN];
extern int g_waveformTables[MAX_CHANNEL][SIZERAM_PULSE_WAVE];
extern int one_pd[SIZERAM_PULSE_DEFN];
extern int ont_wt[SIZERAM_PULSE_WAVE];

// UART I/O characters
char    inbyte      (void);
void    outbyte     (char c);

// Function declarations (GPT converted... may need to be updated)
// Bit manipulation functions
int set_bit(int nData, u8 nBit);
int clr_bit(int nData, u8 nBit);
int toggle_bit(int nData, u8 nBit);
u8 get_bit(int nData, u8 nBit);

// Hex helper functions
u8 is_hex(char c);
u8 is_only_one_bit(int value);
u8 hex2int(char c);

// Pointer manipulation functions
u32 findZeroIndex(const void *src, int step);

// GPIO functions
void gpo_toggle(int nBit, int addr);
void gpo_set(int nBit, int addr);
void gpo_clr(int nBit, int addr);

// Display/information functions
void print_help(void);
void print_regs(void);

// Pulse definition and manipulation functions
void read_pulse_dfn(int nValue);
void read_pulse_wave(int nValue);
void load_pulse_wave(int nChannel, int nAddrStart, int nSize);
void entry_pulse_defn(int nEntry, int nStartTime, int nWaveAddr, int nWaveLen, 
                     int nScaleGain, int nScaleAddr, int nFlattop);
void load_pulse_defn(int nChannel);
void single_pulse_chsel(int nChannel);
void set_pulse_chsel(int nValue);
int clear_rams(int memsel);
int test_pulse_channels(int nChanValid);

#endif // __QLASER_FPGA_H_