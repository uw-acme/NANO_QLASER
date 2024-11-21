//----------------------------------------------------------------------
//
// app_qlaser.c
//
//----------------------------------------------------------------------
// this one has full channel controlling p2pmod. channel 0
#include "xparameters.h"
#include <stdio.h>
#include "stdbool.h"
#include "platform.h"
#include "xil_printf.h"
#include "xil_io.h"
#include "xuartps_hw.h"

#include "xiicps.h"
#define IIC_0_DEVICE_ID		XPAR_XIICPS_0_DEVICE_ID
#define IIC_1_DEVICE_ID		XPAR_XIICPS_1_DEVICE_ID


// #include "qlaser_fpga.h"
//#include "qlaser_fpga_zc102.h"          // Constant definitions. Register addresses etc.

// Memory size on CPU bus
#define SIZERAM_PULSE_WAVE 2048			// Each memory address contains two waveform points
#define SIZERAM_PULSE_DEFN 1024			// Each entry consists of 4 32-bit words
#define PDEF_NUM_ENTRY     (SIZERAM_PULSE_DEFN/4)

#define ADR_BASE_GPIO_INT  XPAR_AXI_GPIO_INT_BASEADDR
#define ADR_GPIO_OUT       (ADR_BASE_GPIO_INT + 0x0)
#define ADR_GPIO_IN        (ADR_BASE_GPIO_INT + 0x8)

// LED and Button GPIO interfaces
#define ADR_BASE_GPIO_LED_BTN   XPAR_AXI_GPIO_LED_BTN_BASEADDR  // 'XPAR' addresses are from xparameter.h (vitis generated file)
#define ADR_GPIO_LED       (ADR_BASE_GPIO_LED_BTN + 0x0)
#define ADR_GPIO_BTN       (ADR_BASE_GPIO_LED_BTN + 0x8)


// Addresses reached through CPUINT
#define ADR_BASE_CPUINT    XPAR_AXI_CPUINT_S00_AXI_BASEADDR   // from xparameters.h

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

// DAC DC block registers (32-bit word addresses)
#define C_ADDR_SPI0         (ADR_BASE_DACS_DC + 8*4*0x00000)
#define C_ADDR_SPI2         (ADR_BASE_DACS_DC + 8*4*0x00002)
#define C_ADDR_SPI1         (ADR_BASE_DACS_DC + 8*4*0x00001)
#define C_ADDR_SPI3         (ADR_BASE_DACS_DC + 8*4*0x00003)
#define C_ADDR_SPI_ALL      (ADR_BASE_DACS_DC + 8*4*0x00004)
#define C_ADDR_INTERNAL_REF (ADR_BASE_DACS_DC + 8*4*0x00005)
#define C_ADDR_POWER_ON     (ADR_BASE_DACS_DC + 8*4*0x00006)


#define PMOD_ADDR_SPI0         (ADR_BASE_P2PMOD + 8*4*0x00000)
#define PMOD_ADDR_INTERNAL_REF (ADR_BASE_P2PMOD + 8*4*0x00005)
#define PMOD_ADDR_POWER_ON     (ADR_BASE_P2PMOD + 8*4*0x00006)
#define PMOD_ADDR_CTRL         (ADR_BASE_P2PMOD + 8*4*0x00007)


// DAC DC block commands (sent to DAC)
#define C_CMD_DAC_DC_WR            0x3
#define C_CMD_DAC_DC_INTERNAL_REF  0x8
#define C_CMD_DAC_DC_POWER         0x4

// DAC AC (Pulse) block sub-blocks.
// Block contains 32 channels. Channels are accessed by first setting bit to '1' in the channel select reg. REG_CH_SEL)
#define ADR_BASE_PULSE_REGS     (ADR_BASE_DACS_AC + 0x4000)
#define ADR_PULSE_REG_SEQ_LEN   (ADR_BASE_PULSE_REGS + 4*0x00)
#define ADR_PULSE_REG_CHSEL     (ADR_BASE_PULSE_REGS + 4*0x01)    // Channel select
#define ADR_PULSE_REG_CHEN   (ADR_BASE_PULSE_REGS + 4*0x02)    // Global status bit-0 = busy, '1' if any ch running, bit-4 error set if any JESD channel is not sync'ed
#define ADR_PULSE_REG_CHSTATUS  (ADR_BASE_PULSE_REGS + 4*0x03)    // Channel JESD status. One bit per channel. Set if JESD not sync'ed.
#define ADR_PULSE_REG_JESDSTATUS     (ADR_BASE_PULSE_REGS + 4*0x04)     // Channel JESD status. One bit per channel. Set if JESD not sync'ed.
#define ADR_PULSE_REG_TIMER     (ADR_BASE_PULSE_REGS + 4*0x05)    // Current timer count since trigger

// RAM base address
#define ADR_BASE_PULSE_WAVE     (ADR_BASE_DACS_AC + 0x2000)     // Either (512 x 32) for 1K table, or (2K x 32) for 4K tables
#define ADR_BASE_PULSE_DEFN     (ADR_BASE_DACS_AC + 0x0000)

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

// IIC CPLD internal addresses
#define IIC_CPLD_REG_CMD        0x00    // Bits initiate SPI transfers to DACs and Clk
#define     CPLD_CMD_WR_CLK         0x01    // Bit-0 triggers SPI xfer to LMK04828
#define     CPLD_CMD_WR_DAC0        0x02    // Bit-1 triggers SPI xfer to DAC0
#define     CPLD_CMD_WR_DAC1        0x04    // Bit-2 triggers SPI xfer to DAC1
#define     CPLD_CMD_WR_DAC2        0x08    // Bit-3 triggers SPI xfer to DAC2
#define     CPLD_CMD_WR_DAC3        0x10    // Bit-4 triggers SPI xfer to DAC3

#define IIC_CPLD_REG_CTRL       0x01    // Bit 5 -0 control various oscillator and DAC features
#define IIC_CPLD_REG_CTRL_DAC   0x02    // Bit 3-0 control DAC amp enables, 7-4 DAC sleep mode
#define IIC_CPLD_REG_EN_OUT     0x03    // Bit 3-0 DAC output enables, 5-4 SYNC controls
#define IIC_CPLD_REG_ALARM      0x04    // Bit 3-0 DAC alarms, 4 AD7291 alert, 6-5 GA[1:0] status
#define IIC_CPLD_REG_VERSION    0x05    // CPLD version
#define IIC_CPLD_REG_SPI_0      0x06    // SPI byte 0 bits 7-0 last sent
#define IIC_CPLD_REG_SPI_1      0x07    // SPI byte 1
#define IIC_CPLD_REG_SPI_2      0x08    // SPI byte 2
#define IIC_CPLD_REG_SPI_3      0x09    // SPI byte 3 bits 31-24 first sent
#define IIC_CPLD_REG_SPI_RD_1   0x0E    // SPI byte readback upper bits 15-8
#define IIC_CPLD_REG_SPI_RD_0   0x0F    // SPI byte readback lower bits  7-0


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
//----------------------------------------------------------------
char    g_strVersion[]          = "1.0.h";
int     g_nStateButtons 		= 0;
int     g_nStateSwitches 		= 0;
unsigned int address;

// UART I/O characters
char    inbyte      (void);
void    outbyte     (char c);

// Function declarations
int     toggle_bit              (int nData, u8 nBit);
int     set_bit                 (int nData, u8 nBit);
int     clr_bit                 (int nData, u8 nBit);
u8      get_bit                 (int nData, u8 nBit);
u8      is_hex                  (char c);
u8      hex2int                 (char c);
void    set_pulse_chsel         (int nValue);
int     get_pulse_chsel         ();
int     clear_all_pulse_rams    ();
int     test_pulse_channels     (int nChanValid);


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
        result = c - 0x41 + 10;
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
void gpo_toggle(int nBit, int addr)
{
    int nRdata =  0;
    nRdata = Xil_In32(addr);
    nRdata = toggle_bit(nRdata, nBit);
    Xil_Out32(addr, nRdata);
}

//----------------------------------------------------------------
// Set a GPIO bit
//----------------------------------------------------------------
void gpo_set(int nBit, int addr)
{
    int nRdata =  Xil_In32(addr);

    nRdata =  nRdata | (0x1 << nBit);
    Xil_Out32(addr, nRdata);
}

//----------------------------------------------------------------
// Clear a GPIO bit
//----------------------------------------------------------------
void gpo_clr(int nBit, int addr)
{
    int nRdata =  Xil_In32(addr);
    nRdata = nRdata & ~(0x1 << nBit);       // Clear
    Xil_Out32(addr, nRdata);
}


//----------------------------------------------------------------
// Print help menu
//----------------------------------------------------------------
void print_help()
{
   (void)xil_printf("\r\n");
   (void)xil_printf("\r\n");
   (void)xil_printf("---------------------------------------------------------------------\r\n");
   (void)xil_printf(" app_qlaser1 : version %s\r\n", g_strVersion);
   (void)xil_printf(" FPGA version : %08X \r\n", Xil_In32(ADR_MISC_VERSION));
   (void)xil_printf("---------------------------------------------------------------------\r\n");
   (void)xil_printf(" h   : Print this message\r\n");
   (void)xil_printf(" 0-9 : Enter a 'Value'\r\n");
   (void)xil_printf(" P   : Print registers\r\n");
   (void)xil_printf(" c   : Set current pulse channel to 'Value'.  (99 = all channels)\r\n");
   (void)xil_printf(" s   : Set pulse seq length to 'Value'.\r\n");
   (void)xil_printf(" M   : Test all Pulse Channels RAMs.\r\n");
   (void)xil_printf(" g   : (value=bit) toggle green LED bit\r\n");
   (void)xil_printf(" i   : Read port expander\r\n");
   (void)xil_printf(" m   : Set FMC mux {0 or 1}\r\n");
   (void)xil_printf(" t   : Read temp from FMC216 AD7291 voltage/temp monitor chip\r\n");
   (void)xil_printf(" S   : DAC sleep\r\n");
   (void)xil_printf(" A   : DAC awaken\r\n");
   (void)xil_printf(" d   : Dump FMC registers\r\n");
   (void)xil_printf(" D   : Set FMC devices to 4-wire SPI\r\n");
   (void)xil_printf("\r\n");
}


//----------------------------------------------------------------
// Print a set of registers
//----------------------------------------------------------------
void print_regs(int nValue)
{
    //int i=0;

    //xil_printf("%d\r\n", nValue);
   (void)xil_printf ("ADR_PULSE_REG_SEQ_LEN              = %08X\r\n", Xil_In32(ADR_PULSE_REG_SEQ_LEN));
   (void)xil_printf ("ADR_PULSE_REG_CHSEL                = %08X\r\n", Xil_In32(ADR_PULSE_REG_CHSEL  ));
   (void)xil_printf ("ADR_PULSE_REG_CHEN              = %08X\r\n", Xil_In32(ADR_PULSE_REG_CHEN));
   (void)xil_printf ("ADR_PULSE_REG_CHSTATUS             = %08X\r\n", Xil_In32(ADR_PULSE_REG_CHSTATUS));
   (void)xil_printf ("ADR_PULSE_REG_TIMER                = %08X\r\n", Xil_In32(ADR_PULSE_REG_TIMER  ));

   (void)xil_printf ("ADR_MISC_VERSION                   = %08X\r\n", Xil_In32(ADR_MISC_VERSION     ));
   (void)xil_printf ("ADR_MISC_LEDS                      = %08X\r\n", Xil_In32(ADR_MISC_LEDS        ));
   (void)xil_printf ("ADR_MISC_LEDS_EN                   = %08X\r\n", Xil_In32(ADR_MISC_LEDS_EN     ));
   (void)xil_printf ("ADR_MISC_DEBUG_CTRL                = %08X\r\n", Xil_In32(ADR_MISC_DEBUG_CTRL  ));
   (void)xil_printf ("ADR_MISC_TRIGGER                   = %08X\r\n", Xil_In32(ADR_MISC_TRIGGER     ));
   (void)xil_printf("\r\n");
}

//---------------------------------------------------------
// Load pulse waveform table
//---------------------------------------------------------
void load_pulse_wave(int nChannel, int nAddrStart, int nSize)
{
    xil_printf ("load_pulse_table(nChannel = %d, nAddrStart = 0x%04X, nSize = %d)\r\n", nChannel, nAddrStart, nSize);

    // Enable access to one selected channel
    set_pulse_chsel(1 << nChannel);

    //for loop to load a ramp up and down
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
void entry_pulse_defn(int nEntry, int nStartTime, int nWaveAddr, int nWaveLen, int nScaleGain, int nScaleAddr, int nFlattop)
{
	u32 nWdata;
	u32 nWaddr;

    xil_printf ("entry_pulse_defn(%d)\r\n", nEntry);

    if (nStartTime > 0x00FFFFFF)
        xil_printf ("entry_pulse_defn(%d): Start time 0x%06X > 0x00FFFFFF\r\n", nEntry, nStartTime);

    if (nWaveAddr > 0x0FFF)
        xil_printf ("entry_pulse_defn(%d): Wave addr 0x%04X > 0x0FFF\r\n", nEntry, nWaveAddr);

    if (nWaveLen > 0x0FFF)
        xil_printf ("entry_pulse_defn(%d): Wave len 0x%04X > 0x0FFF\r\n", nEntry, nWaveLen);

    if (nScaleGain > 0xFFFF)
        xil_printf ("entry_pulse_defn(%d): Scale Gain 0x%04X > 0xFFFF\r\n", nEntry, nScaleGain);

    if (nScaleAddr > 0xFFFF)
        xil_printf ("entry_pulse_defn(%d): Scale addr 0x%04X > 0xFFFF\r\n", nEntry, nScaleAddr);

    if (nFlattop > 0x0001FFFF)
        xil_printf ("entry_pulse_defn(%d): Scale addr 0x%08X > 0x0001FFFF\r\n", nEntry, nFlattop);


//    xil_printf ("entry_pulse_defn0(%d)\r\n", nEntry);

    nWdata = nStartTime & 0x00FFFFFF;
    nWaddr = ADR_BASE_PULSE_DEFN + 4*4*nEntry;
    Xil_Out32(nWaddr, nWdata);

    nWdata = ((nWaveLen & 0x0FFF) << 16) + (nWaveAddr & 0x0FFF);
    nWaddr = nWaddr + 4;
    Xil_Out32(nWaddr, nWdata);

    nWdata = ((nScaleGain & 0xFFFF) << 16) + (nScaleAddr & 0xFFFF);
    nWaddr = nWaddr + 4;
    Xil_Out32(nWaddr, nWdata);

    nWdata = nFlattop & 0x0001FFFF;
    nWaddr = nWaddr + 4;
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
void load_pulse_defn(int nChannel)
{
    int nStartTime      = 200 + (10*nChannel);
  //int nStartTimeIncr  = 200;
    int nWaveAddr       = 0;
    int nWaveLen        = 4096/256; // 16
    int nScaleGain      = 0x0100;   // 1.0 // was 0x0100
    int nScaleAddr      = 0x8000;   // 1.0 // was 0x0100
    int nFlattop        = 8;
    int nFlattopIncr    = 4;

    int nEntry;

    xil_printf ("load_pulse_defn(nChannel = %d)\r\n", nChannel);

    // Enable access to one selected channel
    set_pulse_chsel(1 << nChannel);

    // Write all entries in RAM
    for (nEntry = 0 ; nEntry < PDEF_NUM_ENTRY ; nEntry++)
    {
        entry_pulse_defn(nEntry, nStartTime, nWaveAddr, nWaveLen, nScaleGain, nScaleAddr, nFlattop);

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
void set_pulse_chsel(int nValue)
{
    //xil_printf ("Set channel select reg to 0x%08X\r\n", nValue);
    Xil_Out32(ADR_PULSE_REG_CHSEL, nValue);
}


//---------------------------------------------------------
// Read channel select reg
//---------------------------------------------------------
int get_pulse_chsel()
{
    int nRdata = 0;

    //xil_printf ("Read channel select reg : ");
    nRdata = Xil_In32(ADR_PULSE_REG_CHSEL);
    xil_printf ("0x%08X\r\n", nRdata);
    return (nRdata);
}


//---------------------------------------------------------------------
// Turn on access to all channels and write zeros to clear all RAMs
// Verify all channels are zero
//---------------------------------------------------------------------
int clear_all_pulse_rams()
{
    u32 nEntry      = 0;
    u32 nWaddr      = 0;
    u32 nWdata      = 0;
    u32 nRaddr      = 0;
    u32 nRdata      = 0;
    u32 nErrors     = 0;

    // Enable access to all channels.
    // Each channel should be written with same data.
    set_pulse_chsel(0xFFFFFFFF);

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
// #define SIZERAM_PULSE_WAVE 512	   Each memory address contains two waveform points
// #define SIZERAM_PULSE_DEFN 16	   Each entry is composted a 4-word
// RAM base address
// #define ADR_BASE_PULSE_WAVE     (ADR_BASE_DACS_AC + 0x0800)     // Either (512 x 32) for 1K table, or (2K x 32) for 4K tables
// #define ADR_BASE_PULSE_DEFN     (ADR_BASE_DACS_AC + 0x0000)
// Write each channel individually, then read back and check the data.
// Then write all zeros to all channels simultaneously and check that too.
//---------------------------------------------------------
int test_pulse_channels(int nChanValid)
{
    u32 nChannel    = 0;
    u32 nEntry      = 0;
    u32 nWaddrBase  = 0;
    u32 nWdataBase  = 0;
    u32 nWaddr      = 0;
    u32 nWdata      = 0;
    u32 nRdata      = 0;
    u32 nErrors     = 0;

   (void)xil_printf("test_pulse_channels(0x%08X)\r\n", nChanValid);

    //---------------------------------------------------------------------
    // Write RAMS in each channel
    //---------------------------------------------------------------------
    for (nChannel = 0 ; nChannel < 32 ; nChannel++)
    {
       (void)xil_printf("Write channel %d\r\n", nChannel);
        set_pulse_chsel(1 << nChannel); // Enable access to one channel only

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
        set_pulse_chsel(1 << nChannel); // Enable access to one channel only

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
    nErrors += clear_all_pulse_rams();

    (void)xil_printf("Read test complete : ");
    if (nErrors != 0)
        (void)xil_printf(" %d errors\r\n", nErrors);
    else
        (void)xil_printf(" PASS\r\n");

    return nErrors;
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
	    xil_printf("Fail config iZCU IIC mux for access to FMC %d\r\n", nFMC);
        return XST_FAILURE;
    } else {
        return XST_SUCCESS;
    }
}


//---------------------------------------------------------
// Read the contents of the IIC_1 mus control register.
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
    MsgWr[0] = (u8)nRdReg; // CPLD reg

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
// Read the contents of a CPLD register
//---------------------------------------------------------
int iic_read_cpld_reg(int nReg)
{
	int 	nStatusIic;
    u8 		MsgRd[2];
    u8  	MsgWr[2];
    bool	bNoisy = false;


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
	int 	nStatusIic;
    u8  	MsgWr[2];
    bool 	bNoisy = false;

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
    u8 nSpiCommand      = (u8)nReg & 0x7F;       // DAC register address
    u8 nSpiDataUpper    = (u8)((nData >> 8) & 0xFF);
    u8 nSpiDataLower    = (u8)(nData & 0xFF);

    // Write SPI word into CPLD registers
    iic_write_cpld_reg(IIC_CPLD_REG_SPI_3, 0x00);           // SPI message 31:24
    iic_write_cpld_reg(IIC_CPLD_REG_SPI_2, nSpiCommand);
    iic_write_cpld_reg(IIC_CPLD_REG_SPI_1, nSpiDataUpper);
    iic_write_cpld_reg(IIC_CPLD_REG_SPI_0, nSpiDataLower);  // SPI message  7:0

    // Trigger SPI write by setting a bit
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


//
//---------------------------------------------------------
int iic_cpld_test()
{
	int nStatusIic      = XST_SUCCESS;

    // Write SPI word into CPLD registers
    iic_write_cpld_reg(0x06, 0x06);
    iic_write_cpld_reg(0x07, 0x07);
    iic_write_cpld_reg(0x08, 0x08);
    iic_write_cpld_reg(0x09, 0x09);

    iic_read_cpld_reg(0x06);
    iic_read_cpld_reg(0x07);
    iic_read_cpld_reg(0x08);
    iic_read_cpld_reg(0x09);

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
int iic_read_dac_reg(int nDac, int nReg)
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
    nReadData  = iic_read_cpld_reg(IIC_CPLD_REG_SPI_RD_0) << 8; 		// Upper bits
    nReadData  = nReadData + iic_read_cpld_reg(IIC_CPLD_REG_SPI_RD_1);	// Lower bits

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

    (void)xil_printf("nReg          = 0x%04X\r\n", nReg);
    (void)xil_printf("nSpiAddr      = 0x%04X\r\n", nSpiAddr);
    (void)xil_printf("nSpiCmdUpper  = 0x%02X\r\n", nSpiCmdUpper);
    (void)xil_printf("nSpiCmdLower  = 0x%02X\r\n", nSpiCmdLower);
    (void)xil_printf("nSpiData      = 0x%02X\r\n", nSpiData);

    // Write SPI word into CPLD registers
    iic_write_cpld_reg(IIC_CPLD_REG_SPI_3, 0x00);           // SPI message 31:24
    iic_write_cpld_reg(IIC_CPLD_REG_SPI_2, nSpiCmdUpper);   // SPI message 23:16  r/w, w[1:0], addr[12:8]
    iic_write_cpld_reg(IIC_CPLD_REG_SPI_1, nSpiCmdLower);   // SPI message 15:8   addr[7:0]
    iic_write_cpld_reg(IIC_CPLD_REG_SPI_0, nSpiData);       // SPI message  7:0   d[7:0]

    // Trigger SPI write by setting a bit
    nStatusIic  = iic_write_cpld_reg(IIC_CPLD_REG_CMD, CPLD_CMD_WR_CLK) ;

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
	int nReadData = 0xCC;
    int nSpiAddr         = nReg & 0x1FFF;       // A12-A0 Register address
    u8  nSpiCmdUpper     = (u8)((nSpiAddr >> 8) | 0x80);
    u8  nSpiCmdLower     = (u8)(nSpiAddr & 0xFF);

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
// Bit 0 ï¿½0ï¿½ Disables output amplifiers for DAC Channels 0,1,2, and 3
//       ï¿½1ï¿½ Enables output amplifiers for DAC Channels 0,1,2, and 3
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
    // Print the ID registers from all four DAC chips
    for (nDac = 0; nDac < 4 ; nDac++) {
    	nRdata = iic_read_dac_reg(nDac, 0x0000);
    	(void)xil_printf("DAC%d[0] :  0x%04X\r\n", nDac, nRdata);	// Default 0x0218

    	nRdata = iic_read_dac_reg(nDac, 0x0001);
    	(void)xil_printf("DAC%d[1] :  0x%04X\r\n", nDac, nRdata);	// Default 0x0003

    	nRdata = iic_read_dac_reg(nDac, 0x0002);
    	(void)xil_printf("DAC%d[2] :  0x%04X\r\n", nDac, nRdata);	// Default 0x2002 w. 4 wire 0x2082

    	(void)xil_printf("\r\n");
    }

       nRdata = iic_read_clk_reg(0x0000);
       (void)xil_printf("LMK04821[0] :  0x%02X\r\n",  nRdata);

       nRdata = iic_read_clk_reg(0x0003);
       (void)xil_printf("LMK04821[3] :  0x%02X\r\n",  nRdata);

       nRdata = iic_read_clk_reg(0x0004);
       (void)xil_printf("LMK04821[4] :  0x%02X\r\n",  nRdata);

       nRdata = iic_read_clk_reg(0x0005);
       (void)xil_printf("LMK04821[5] :  0x%02X\r\n",  nRdata);

       nRdata = iic_read_clk_reg(0x0006);
       (void)xil_printf("LMK04821[6] :  0x%02X\r\n",  nRdata);

       nRdata = iic_read_clk_reg(0x000C);
       (void)xil_printf("LMK04821[0xC] :  0x%02X\r\n",  nRdata);

       nRdata = iic_read_clk_reg(0x000D);
       (void)xil_printf("LMK04821[0xD] :  0x%02X\r\n",  nRdata);

}


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

    int     nStateButtonsLast   = 0;
    int     nStateSwitchesLast  = 0;
    int     nMode = C_MODE_CMD;
	int 	nStatusIic;

    init_platform();

   (void)xil_printf("---------------------------------------------------------------------\r\n");
   (void)xil_printf(" app_qlaser1 : version %s\r\n", g_strVersion);
   (void)xil_printf("---------------------------------------------------------------------\r\n");
//     nRdata = Xil_In32(ADR_MISC_VERSION);
//    (void)xil_printf("FPGA Version = 0x%08X\r\n", nRdata);
//     print("\n\r");

	//----------------------------------------------------------------------
	// Initialize the IIC driver so that it's ready to use
	// Look up the configuration in the config table, then initialize it.
	//--
	print("Ready>\r\n");

    Xil_Out32(ADR_PULSE_REG_SEQ_LEN, 0xA0100000);
	nRdata = Xil_In32(ADR_PULSE_REG_SEQ_LEN);
	(void)xil_printf ("Seq length %x\r\n", nRdata);

//    set_pulse_chsel(0xFF000000);
//
//	Xil_Out32(ADR_BASE_DACS_AC + 0x0008, 0x10000001);
//	nRdata = Xil_In32(ADR_BASE_DACS_AC + 0x0008);
//	(void)xil_printf ("Empty channels %x\r\n", nRdata);
//
//    set_pulse_chsel(0xF0000000);
//
//
//	Xil_Out32(ADR_BASE_DACS_AC + 0x0008, 0x10000010);
//	nRdata = Xil_In32(ADR_BASE_DACS_AC + 0x0008);
//	(void)xil_printf ("Empty channels %x\r\n", nRdata);
//
//    set_pulse_chsel(0xFF000000);
//
//
//	nRdata = Xil_In32(ADR_BASE_DACS_AC + 0x0008);
//	(void)xil_printf ("Empty channels ored %x\r\n", nRdata);
//
//    clear_all_pulse_rams();
//
//    nRdata = Xil_In32(ADR_BASE_DACS_AC + 0x0008);
//	(void)xil_printf ("Cleared channels ored %x\r\n", nRdata);
//
//
//	set_pulse_chsel(0x00000001);
//
//
//	Xil_Out32(ADR_BASE_DACS_AC + 0x0008, 0x10000010);
//	nRdata = Xil_In32(ADR_BASE_DACS_AC + 0x0008);
//	(void)xil_printf ("Full channel %x\r\n", nRdata);
//
//	Xil_Out32(ADR_BASE_DACS_AC + 0x0000, 0x0ABC0000);
//	nRdata = Xil_In32(ADR_BASE_DACS_AC + 0x0000);
//	(void)xil_printf ("Full channel %x\r\n", nRdata);
//
//	set_pulse_chsel(0x00000002);
//
//	Xil_Out32(ADR_BASE_DACS_AC + 0x0008, 0x10000001);
//	nRdata = Xil_In32(ADR_BASE_DACS_AC + 0x0008);
//	(void)xil_printf ("Full channel %x\r\n", nRdata);
//
//	set_pulse_chsel(0x00000003);
//
//	nRdata = Xil_In32(ADR_BASE_DACS_AC + 0x0008);
//	(void)xil_printf ("Full channels ored %x\r\n", nRdata);

//--------------------------------------------------------------------
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
	// Write to the ZCU102 board I2C_1 mux. Set bit 0 to enable connection to FMC_0
	//----------------------------------------------------------------------
    iic_enable_fmc(0);
    iic_read_fmc_mux();

    // iic_dacs_sleep(0xF0);

	// Enable temperature measurements
	(void)iic_enable_fmc_temp();

	//----------------------------------------------------------------------
    // Command parser. Loops forever.
    //----------------------------------------------------------------------
    print("Ready>\r\n");


    Xil_Out32(PMOD_ADDR_INTERNAL_REF, nRdata);
    Xil_Out32(C_ADDR_INTERNAL_REF, nRdata);

    bool on = false;
    bool trigger = false;



    // write wave def
//	set_pulse_chsel(1);

//	load_pulse_defn(1);
//	entry_pulse_defn(0, 40, 0, 0x0010, 1, 1, 0x00010);
//	void entry_pulse_defn(int nEntry, int nStartTime, int nWaveAddr, int nWaveLen, int nScaleGain, int nScaleAddr, int nFlattop)


	u32 nWaddrBase  = ADR_BASE_PULSE_WAVE;
	u32 nWaddr;
//	int nEntry;
//	for (nEntry = 0 ; nEntry < SIZERAM_PULSE_WAVE ; nEntry++)
//	{
//		nWaddr = nWaddrBase + 4*nEntry;
//		Xil_Out32(nWaddr, 0xFFFFFFFF);
//		//xil_printf("ch %2d: wave %4d: (0x%08X) = 0x%08X\r\n", nChannel, nEntry, nWaddr, nWdata);
//	}
	//	void entry_pulse_defn(int nEntry, int nStartTime, int nWaveAddr, int nWaveLen, int nScaleGain, int nScaleAddr, int nFlattop)
	int nEntry = 0;
	int nStartTime = 50;
	int nWaveAddr = 0;
	int nWaveLen = 100;
	int nScaleGain = 0x8000;
	int nScaleAddr = 0x0100;


    while (1)
    {
        nRdata = Xil_In32(ADR_GPIO_BTN);
    	Xil_Out32(ADR_GPIO_LED, nRdata);



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
                           nValue = 0;
                        break;


                        //---------------------------------------------------------
                        // Test Pulse Channel RAMs
                        //---------------------------------------------------------
                        case 'M':
                           // Load each channel and read back. Dummy channels have only a single register
                           int nPulseChannelsFull = 0x0000000F;    // Set a bit for each channel that has full logic
                           (void)test_pulse_channels(nPulseChannelsFull);
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
                        		set_pulse_chsel(0xFFFFFFFF);
                        	else
                        		set_pulse_chsel(nValue);
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
                    	// Read from the U97 port expander on the ZCU102 board I2C_0 bus.
                        // Bit-7 and bit-6 are presence detect bits for the FMC216 boards
                    	//----------------------------------------------------------------------
                        case 'i':

                        	//----------------------------------------------------------------------
                            // Read all CPLD registers
                        	//----------------------------------------------------------------------
                            xil_printf("Read FMC216 CPLD registers\r\n");

                            // Read 0 to 15
                            for (int i=0; i < 15 ; i++) {
                            	xil_printf("CPLD[%d] = 0x%02X\r\n", i, iic_read_cpld_reg((u8)i));

                        	    //MsgWr[0] = (u8)i; // reg addr
                        	    //nStatusIic = XIicPs_MasterSendPolled(&IicPs1, &MsgWr[0], 1, IIC_ADDR_ABA_CPLD);
                        	    //if (nStatusIic != XST_SUCCESS)
                        	    //	xil_printf("Status after Write CPLD = 0x%04X\r\n", nStatusIic);

                        	    //MsgRd[0] =  0xCC;
                        	    //nStatusIic = XIicPs_MasterRecvPolled(&IicPs1, &MsgRd[0], 1, IIC_ADDR_ABA_CPLD);
                        	    //if (nStatusIic == XST_SUCCESS)
                        	    //	xil_printf("Read CPLD[%2d] = 0x%02X\r\n", i, MsgRd[0]);
                        	    //else
                        	    //	xil_printf("** Read CPLD[%2d] = 0x%02X, nStatusIic = 0x%04X\r\n", i, MsgRd[0], nStatusIic);
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
                        // Read temp from FMC216 AD7291 voltage/temp monitor chip
                    	//----------------------------------------------------------------------
//                        case 't':
//                            iic_read_fmc_temp(0);
//                            iic_read_fmc_temp(1);
//                            iic_read_fmc_temp(2);	// Tsense
//                            iic_read_fmc_temp(3);	// Averaged Temp
//                            iic_read_fmc_temp(4);
//                            iic_read_fmc_temp(5);
//                            iic_read_fmc_temp(6);
//                            iic_read_fmc_temp(7);
//
//                            // Convert 11 LSB to degrees. Bits [15:12] should be 0x80
//                            double dTemp = (double)(iic_read_fmc_temp(2) & 0xFFF)/4.0;
//                    	    printf("Temperature = %5.2f degrees C\r\n", dTemp);
//
//                        break;

                    	//----------------------------------------------------------------------
                        // Set sleep mode for DACs
                    	//----------------------------------------------------------------------
                        case 'S':
                            iic_dacs_sleep(0x70);
                        break;

                    	//----------------------------------------------------------------------
                        // Set awake mode for DACs
                    	//----------------------------------------------------------------------
                        case 'A':
                            iic_dacs_sleep(0x01);
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
                        case 'D':
                            iic_set_fmc_spi4();
                        break;

                    	//----------------------------------------------------------------------
                        // Test something
                    	//----------------------------------------------------------------------
                        case 'T':
                            iic_cpld_test();
                        break;

                        //---------------------------------------------------------
						// Print registers
						//---------------------------------------------------------
						case 'L':
							Xil_Out32(ADR_GPIO_LED, nValue);
//							Xil_Out32(ADR_GPIO_LED + 1, nValue);
							nRdata = Xil_In32(ADR_GPIO_LED);
							(void)xil_printf ("LED val %d\r\n", nRdata);
						break;


						case 'Z':
							nRdata = Xil_In32(ADR_GPIO_BTN);
							(void)xil_printf ("DIP val %d\r\n", nRdata);
						break;

						case 'Q':
							nRdata = Xil_In32(ADR_GPIO_LED);
							(void)xil_printf ("LED val %d\r\n", nRdata);

							nRdata = Xil_In32(ADR_GPIO_LED + 0x0008);
							(void)xil_printf ("LED val %d\r\n", nRdata);

							nRdata = Xil_In32(ADR_GPIO_BTN);
							(void)xil_printf ("LED val %d\r\n", nRdata);

							nRdata = Xil_In32(ADR_GPIO_BTN + 0x0008);
							(void)xil_printf ("LED val %d\r\n", nRdata);

						break;


//						case 'I':
//							for (address = 0xA0000000; address <= 0xA001FFFF; address += 4) {
//								nRdata = Xil_In32(address);
//								if (nRdata != 0 && nRdata != 0xFFFFFFFF) {
//									printf("Address: 0x%08X, Data: 0x%08X\n", address, nRdata);
//								}
//							}
//							nRdata = Xil_In32(0xA0010000);
//							if (nRdata != 0 && nRdata != 0xFFFFFFFF) {
//								printf("1 Address: 0xA0010000, Data: 0x%08X\n", nRdata);
//							}
//							printf("2 Address: 0xA0010000, Data: 0x%08X\n", nRdata);
//							nRdata = Xil_In32(ADR_GPIO_LED);
//							printf("3 Address: 0x%08X, Data: 0x%08X\n", ADR_GPIO_LED, nRdata);
//						break;

                        case 'p':
                            on = !on;
                            Xil_Out32(PMOD_ADDR_POWER_ON, nRdata);
							Xil_Out32(C_ADDR_POWER_ON, nRdata);
							if (on) {
                                printf("on\n");
                            } else {
                                printf("off\n");
                            }
					        if (on) {
					            Xil_Out32(C_ADDR_SPI_ALL, 0x000000FF);
					            Xil_Out32(PMOD_ADDR_SPI0, 0x000000FF);
					//            Xil_Out32(C_ADDR_SPI0, 0xFFFFFFFF);
					        } else {
					            Xil_Out32(C_ADDR_SPI_ALL, 0x10000000);
					        	Xil_Out32(PMOD_ADDR_SPI0, 0x10000000);
					//            Xil_Out32(PMOD_ADDR_SPI0, 0xFFFFFFFF);
					        }
						break;

                        case 'f':
                            Xil_Out32(PMOD_ADDR_INTERNAL_REF, nRdata);
                            Xil_Out32(C_ADDR_INTERNAL_REF, nRdata);
						break;

                        case 'C':
							Xil_Out32(PMOD_ADDR_CTRL, 0x1);
//							Xil_Out32(C_ADDR_INTERNAL_REF, nRdata);
						break;

                        case 't':
                        	trigger = !trigger;
                        	if (trigger) {
                        		Xil_Out32(ADR_MISC_TRIGGER, 0x1);
								printf("on\n");
							} else {
								Xil_Out32(ADR_MISC_TRIGGER, 0x0);
								printf("off\n");
							}
                        	(void)xil_printf ("ADR_PULSE_REG_TIMER                = %08X\r\n", Xil_In32(ADR_PULSE_REG_TIMER  ));
                        	(void)xil_printf ("ADR_PULSE_REG_TIMER                = %08X\r\n", Xil_In32(ADR_PULSE_REG_TIMER  ));
                        	(void)xil_printf ("ADR_PULSE_REG_TIMER                = %08X\r\n", Xil_In32(ADR_PULSE_REG_TIMER  ));

						break;

                        case 'w':
                        	set_pulse_chsel(0xFFFFFFFF);
                        	Xil_Out32(ADR_PULSE_REG_CHEN, 0xFFFFFFFF);

                        	//	load_pulse_defn(1);
							entry_pulse_defn(0, 200,    0,     0x0200, 0x8000, 0x0100, 0x0080);
							entry_pulse_defn(1, 0x1000, 1000,  0x0100, 0x8000, 0x0100, 0x0120);
							//	void entry_pulse_defn(int nEntry, int nStartTime, int nWaveAddr, int nWaveLen, int nScaleGain, int nScaleAddr, int nFlattop)
//							nWdata = nStartTime & 0x00FFFFFF;
//							nWaddr = ADR_BASE_PULSE_DEFN + 4*4*nEntry;
//							Xil_Out32(nWaddr, nWdata);
//
//							nWdata = ((nWaveLen & 0x0FFF) << 16) + (nWaveAddr & 0x0FFF);
//							nWaddr = nWaddr + 4;
//							Xil_Out32(nWaddr, nWdata);
//
//							nWdata = ((nScaleAddr & 0xFFFF) << 16) + (nScaleGain & 0xFFFF);
//							nWaddr = nWaddr + 4;
//							Xil_Out32(nWaddr, nWdata);
//
//							nWdata = nFlattop & 0x0001FFFF;
//							nWaddr = nWaddr + 4;
//							Xil_Out32(nWaddr, nWdata);
//                        	int i;
//                        	for (i = 0; i < 32; i++) {
//                        		load_pulse_defn(i);
//                        	}


//							load_pulse_defn(0); // put this back?
							set_pulse_chsel(0xFFFFFFFF);
							u32 nWaddrBase  = ADR_BASE_PULSE_WAVE;
							u32 nWaddr;
							int nEntry;
							for (nEntry = 0 ; nEntry < SIZERAM_PULSE_WAVE ; nEntry++)
							{
								nWaddr = nWaddrBase + 4*nEntry;
								Xil_Out32(nWaddr, nEntry + nEntry * 65536);
								//xil_printf("ch %2d: wave %4d: (0x%08X) = 0x%08X\r\n", nChannel, nEntry, nWaddr, nWdata);
							}

							for (nEntry = 100 ; nEntry < SIZERAM_PULSE_WAVE ; nEntry++)
							{
								nWaddr = nWaddrBase + 4*nEntry;
								Xil_Out32(nWaddr, 2 * nEntry - 100 + (2 * nEntry - 100) * 65536);
								//xil_printf("ch %2d: wave %4d: (0x%08X) = 0x%08X\r\n", nChannel, nEntry, nWaddr, nWdata);
							}

							for (nEntry = 500 ; nEntry < SIZERAM_PULSE_WAVE ; nEntry++)
							{
								nWaddr = nWaddrBase + 4*nEntry;
								Xil_Out32(nWaddr, 8 * nEntry - 500 * 8 + (8 * nEntry - 500 * 8) * 65536);
								//xil_printf("ch %2d: wave %4d: (0x%08X) = 0x%08X\r\n", nChannel, nEntry, nWaddr, nWdata);
							}
						break;

                        case 'W':
                        	// read what was written
							set_pulse_chsel(0xFFFFFFFF);

							nWaddrBase  = ADR_BASE_PULSE_WAVE;
							nRdata = Xil_In32(nWaddrBase);
							printf("1 Address: waaddr, Data: 0x%08X\n", nRdata);
							nRdata = Xil_In32(nWaddrBase + 128);
							printf("1 Address: waddr+128, Data: 0x%08X\n", nRdata);

							set_pulse_chsel(0x1);

							nWaddrBase  = ADR_BASE_PULSE_WAVE;
							nRdata = Xil_In32(nWaddrBase);
							printf("1 Address: waaddr, Data: 0x%08X\n", nRdata);
							nRdata = Xil_In32(nWaddrBase + 128);
							printf("1 Address: waddr+128, Data: 0x%08X\n", nRdata);

							nWaddrBase = ADR_BASE_PULSE_DEFN;
							nRdata = Xil_In32(nWaddrBase);
							printf("1 Address: start time, Data: 0x%08X\n", nRdata);
							nRdata = Xil_In32(nWaddrBase + 4);
							printf("1 Address: start adddr, wave length, Data: 0x%08X\n", nRdata);
							nRdata = Xil_In32(nWaddrBase + 8);
							printf("1 Address: scale, gain, Data: 0x%08X\n", nRdata);
							nRdata = Xil_In32(nWaddrBase + 12);
							printf("1 Address: flat top, Data: 0x%08X\n", nRdata);

						break;

                        case 'z':

						break;

                        case 'r':

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
