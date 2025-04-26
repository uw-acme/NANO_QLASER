#include "qlaser_fpga.h"

//----------------------------------------------------------------
// 1.0.a Initial version.
// 1.0.b Test RAMs in pulse channel 0.
// 1.0.c Test RAMs in all pulse channels.
// 1.0.d Test all channel clear
// 1.0.e Start I2C dev
// 1.0.f More iic functions
// 1.0.g Set FMC216 board DACs and Clk to use 4-wire SPI so CPLD readback works
// 1.0.h Set LMK SPI output mux
// 1.0.i AC+DC thru PMOD and set then thru Python CLI.
// 1.0.j Updated for second iteration of the Python API
// 1.0.k Updated for third iteration of the Python API
//
// Any other values beside those are internal debug only
//----------------------------------------------------------------
char    g_strVersion[]          = "1.0.k";
int     g_nStateButtons 		= 0;
int     g_nStateSwitches 		= 0;
unsigned int address;
int g_pulseDefinitions[MAX_CHANNEL][SIZERAM_PULSE_DEFN];
int g_waveformTables[MAX_CHANNEL][SIZERAM_PULSE_WAVE];
int one_pd[SIZERAM_PULSE_DEFN];
int ont_wt[SIZERAM_PULSE_WAVE];

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

u8 is_only_one_bit(int value) {
    // Check if value is non-zero and has only one bit set
    // This uses the trick that (value & (value - 1)) clears the rightmost set bit
    return value != 0 && (value & (value - 1)) == 0;
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
// Find the index of the first zero in a 32-bit memory
// With an optional step size
//----------------------------------------------------------------
u32 findZeroIndex(const void *src, int step)
{
    const u32 *s = (const u32 *)src;
    u32 index = 0;

    while (s[index] != 0U) {
        index += step;
    }
    return index;
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
   (void)xil_printf(" e   : Echo Command. Default off. Nonzero value to turn on. Zero value to turn off.\r\n");
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
// Print a set of registers. Subroutine for status regs dumps
//----------------------------------------------------------------
void print_regs()
{
    //int i=0;

    //xil_printf("%u\r\n", nValue);
   (void)xil_printf ("ADR_PULSE_REG_SEQ_LEN              = 0x%08X\r\n", Xil_In32(ADR_PULSE_REG_SEQ_LEN ));
   (void)xil_printf ("ADR_PULSE_REG_CHSEL                = 0x%08X\r\n", Xil_In32(ADR_PULSE_REG_CHSEL   ));
   (void)xil_printf ("ADR_PULSE_REG_CHEN                 = 0x%08X\r\n", Xil_In32(ADR_PULSE_REG_CHEN    ));
   (void)xil_printf ("ADR_PULSE_REG_CHSTATUS             = 0x%08X\r\n", Xil_In32(ADR_PULSE_REG_CHSTATUS));
   (void)xil_printf ("ADR_PULSE_REG_TIMER                = 0x%08X\r\n", Xil_In32(ADR_PULSE_REG_TIMER   ));
   (void)xil_printf ("ERR_RAM_OF                         = 0x%08X\r\n", Xil_In32(ADR_REG_ERR_RAM_OF    ));
   (void)xil_printf ("ERR_INVAL_LEN                      = 0x%08X\r\n", Xil_In32(ADR_REG_ERR_INVAL_LEN ));
   (void)xil_printf ("ERR_BIG_STEP                       = 0x%08X\r\n", Xil_In32(ADR_REG_ERR_BIG_STEP  ));
   (void)xil_printf ("ERR_BIG_GAIN                       = 0x%08X\r\n", Xil_In32(ADR_REG_ERR_BIG_GAIN  ));
   (void)xil_printf ("ERR_SMALL_TIME                     = 0x%08X\r\n", Xil_In32(ADR_REG_ERR_SMALL_TIME));
   (void)xil_printf ("ERR_START_TIME                     = 0x%08X\r\n", Xil_In32(ADR_REG_ERR_START_TIME));

   (void)xil_printf ("ADR_BASE_DACS_DC_STATS             = 0x%08X\r\n", Xil_In32(C_ADDR_SPI_STATUS     ));
   (void)xil_printf ("ADR_BASE_DACS_DC_SPI0_MSG          = 0x%08X\r\n", Xil_In32(C_ADDR_SPI0           ));
   (void)xil_printf ("ADR_BASE_DACS_DC_SPI1_MSG          = 0x%08X\r\n", Xil_In32(C_ADDR_SPI1           ));
   (void)xil_printf ("ADR_BASE_DACS_DC_SPI2_MSG          = 0x%08X\r\n", Xil_In32(C_ADDR_SPI2           ));
   (void)xil_printf ("ADR_BASE_DACS_DC_SPI0_MSG          = 0x%08X\r\n", Xil_In32(C_ADDR_SPI3           ));

   (void)xil_printf ("ADR_MISC_VERSION                   = 0x%08X\r\n", Xil_In32(ADR_MISC_VERSION      ));
   (void)xil_printf ("ADR_MISC_LEDS                      = 0x%08X\r\n", Xil_In32(ADR_MISC_LEDS         ));
   (void)xil_printf ("ADR_MISC_LEDS_EN                   = 0x%08X\r\n", Xil_In32(ADR_MISC_LEDS_EN      ));
   (void)xil_printf ("ADR_MISC_DEBUG_CTRL                = 0x%08X\r\n", Xil_In32(ADR_MISC_DEBUG_CTRL   ));
   (void)xil_printf ("ADR_MISC_TRIGGER                   = 0x%08X\r\n", Xil_In32(ADR_MISC_TRIGGER      ));
   (void)xil_printf ("ADR_MISC_ENABLE                    = 0x%08X\r\n", Xil_In32(ADR_MISC_ENABLE       ));

   (void)xil_printf ("ADR_BLOCK_SPARE                    = 0x%08X\r\n", Xil_In32(ADR_BASE_P2PMOD       ));

   (void)xil_printf ("ADR_GPIO_IN                        = 0x%08X\r\n", Xil_In32(ADR_GPIO_IN           ));
}

//----------------------------------------------------------------
// Print pulse definition RAM for up to N addresses, zero for all
//----------------------------------------------------------------
void read_pulse_dfn(int nValue)
{
    // lower 10 bits for address to read to, upper [25:16] for read from
	u16 endAddr = (u16)(nValue & (SIZERAM_PULSE_DEFN - 1));
    u16 startAddr = (u16)((nValue >> 16) & (SIZERAM_PULSE_DEFN - 1));
    u32 nRdata = 0;

    if (endAddr == 0) {  // zero means read all
        endAddr = SIZERAM_PULSE_DEFN;
    }

    // (void)xil_printf ("[");
    // fencepost to make sure all writes are done before reading
    for (int i = startAddr; i < endAddr - 1; i++) {
        nRdata = Xil_In32(ADR_BASE_PULSE_DEFN + 4*i);
        (void)xil_printf ("%u,", nRdata);
    }
    nRdata = Xil_In32(ADR_BASE_PULSE_DEFN + 4*(endAddr - 1));
    (void)xil_printf ("%u\r\n", nRdata);
}

//---------------------------------------------------------
// Print waveform RAM for up to N addresses, zero for all
//---------------------------------------------------------
void read_pulse_wave(int nValue)
{
    // lower 12 bits for address to read to, upper [27:16] for read from
	u16 endAddr = (u16)(nValue & 0x0FFF);
    u16 startAddr = (u16)((nValue >> 16) & 0x0FFF);
    u32 nRdata = 0;

    if (endAddr == 0) {  // zero means read all
        endAddr = SIZERAM_PULSE_WAVE * 2;
    }

    // fencepost to make sure all writes are done before reading
    for (int i = startAddr; i < endAddr - 1; i++) {
        nRdata = Xil_In16(ADR_BASE_PULSE_WAVE + 2*i);
        (void)xil_printf ("%u,", nRdata);
    }
    nRdata = Xil_In16(ADR_BASE_PULSE_WAVE + 2*(endAddr - 1));
    (void)xil_printf ("%u\r\n", nRdata);
}

//---------------------------------------------------------
// Load a ramp into pulse waveform table
//---------------------------------------------------------
void load_pulse_wave(int nChannel, int nAddrStart, int nSize)
{
    if (nChannel == 99) {
        // load to all channels
        set_pulse_chsel(0xFFFFFFFF);
    } else {

        xil_printf ("load_pulse_table(nChannel = %u, nAddrStart = 0x%04X, nSize = %u)\r\n", nChannel, nAddrStart, nSize);

        // Enable access to one selected channel
        set_pulse_chsel(1 << nChannel);
    }

    // TODO: size actually not used...
    //for loop to load a ramp
    u32 nWaddrBase  = ADR_BASE_PULSE_WAVE;
    u32 nWaddr;
    u32 nWdata;
    int nEntry;
    int nData16 = 1;

    int nData_up = 0;
    int nData_lo = 0;

        for (nEntry = 0 ; nEntry < SIZERAM_PULSE_WAVE ; nEntry++)
        {
            nWaddr = nWaddrBase + 4*nEntry;

            nData_up = (nData16 << C_BITS_ADDR_WAVE);
            nData_lo = nData16 - 1;

            Xil_Out32(nWaddr, nData_up + nData_lo);
            nData16 += 2;
        }

//    for (nEntry = 0 ; nEntry < SIZERAM_PULSE_WAVE ; nEntry++)
//    {
//        nWaddr = nWaddrBase + 4*nEntry;
//
//        nData_up = ((nEntry + 1) << C_BITS_ADDR_WAVE);
//        nData_lo = nEntry;
//
//        Xil_Out32(nWaddr, nData_up + nData_lo);
////        xil_printf("ch %2d: wave %4d: (0x%08X) = 0x%08X\r\n", nChannel, nEntry, nWaddr, nWdata);
//    }

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

    xil_printf ("entry_pulse_defn(%u)\r\n", nEntry);

    if (nStartTime > 0x00FFFFFF)
        xil_printf ("entry_pulse_defn(%u): Start time 0x%06X > 0x00FFFFFF\r\n", nEntry, nStartTime);

    if (nWaveAddr > 0x0FFF)
        xil_printf ("entry_pulse_defn(%u): Wave addr 0x%04X > 0x0FFF\r\n", nEntry, nWaveAddr);

    if (nWaveLen > 0x0FFF)
        xil_printf ("entry_pulse_defn(%u): Wave len 0x%04X > 0x0FFF\r\n", nEntry, nWaveLen);

    if (nScaleGain > 0xFFFF)
        xil_printf ("entry_pulse_defn(%u): Scale Gain 0x%04X > 0xFFFF\r\n", nEntry, nScaleGain);

    if (nScaleAddr > 0xFFFF)
        xil_printf ("entry_pulse_defn(%u): Scale addr 0x%04X > 0xFFFF\r\n", nEntry, nScaleAddr);

    if (nFlattop > 0x0001FFFF)
        xil_printf ("entry_pulse_defn(%u): Scale addr 0x%08X > 0x0001FFFF\r\n", nEntry, nFlattop);


//    xil_printf ("entry_pulse_defn0(%u)\r\n", nEntry);

    nWdata = nStartTime & 0x00FFFFFF;
    nWaddr = 4*4*nEntry;
    (void)xil_printf ("Set data going to sent: %u\r\n", nWdata);
    Xil_Out32(ADR_BASE_PULSE_DEFN + nWaddr, nWdata);

    nWdata = ((nWaveLen & 0x0FFF) << 16) + (nWaveAddr & 0x0FFF);
    nWaddr = nWaddr + 4;
    (void)xil_printf ("Set data going to sent: %u\r\n", nWdata);
    Xil_Out32(ADR_BASE_PULSE_DEFN + nWaddr, nWdata);

    nWdata = ((nScaleGain & 0xFFFF) << 16) + (nScaleAddr & 0xFFFF);
    nWaddr = nWaddr + 4;
    (void)xil_printf ("Set data going to sent: %u\r\n", nWdata);
    Xil_Out32(ADR_BASE_PULSE_DEFN + nWaddr, nWdata);

    nWdata = nFlattop & 0x0001FFFF;
    nWaddr = nWaddr + 4;
    (void)xil_printf ("Set data going to sent: %u\r\n", nWdata);
    Xil_Out32(ADR_BASE_PULSE_DEFN + nWaddr, nWdata);
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

    xil_printf ("load_pulse_defn(nChannel = %u)\r\n", nChannel);

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
	// TODO: seperate those out
    Xil_Out32(ADR_PULSE_REG_CHSEL, nValue);
    Xil_Out32(ADR_PULSE_REG_CHEN, nValue);
}

//------------------------------------------------------------
// select a single channel with value 0 to channel number - 1
//-------------------------------------------------------------
void single_pulse_chsel(int nChannel)
{
    if (nChannel > 31) {
		(void) xil_printf ("*ERR*: Invalid channel number %u\r\n", nChannel);
		return;
	}

	// Enable access to one selected channel
	Xil_Out32(ADR_PULSE_REG_CHSEL, 1 << nChannel);
}

//---------------------------------------------------------------------
// Turn on access to all channels and write zeros to clear all RAMs
// Verify all channels are zero
// Must select a channel before calling this function
// memsel = 0x0 = pulse definitions, 0x1 = waveform tables
//---------------------------------------------------------------------
int clear_rams(int memsel)
{
    u32 nEntry      = 0;
    u32 nWaddr      = 0;
    u32 nWdata      = 0;
    u32 nRaddr      = 0;
    u32 nRdata      = 0;
    u32 nErrors     = 0;

    // Clearing out the fake pd mem
    if ((memsel & 0x1) == 1) {
        memset(g_waveformTables, 0, sizeof(g_waveformTables));
    } else {
        memset(g_pulseDefinitions, 0, sizeof(g_pulseDefinitions));
    }

    //-----------------------------------------------------------------
    // Clear all RAMs
    // Addresses are 4x nEntry because all addresses are byte addresses
    //-----------------------------------------------------------------
    if ((memsel & 0x1) == 1) {
        for (nEntry = 0 ; nEntry < SIZERAM_PULSE_WAVE ; nEntry++)
        {
            nWdata = 0x0;
            nWaddr = ADR_BASE_PULSE_WAVE + 4*nEntry;
            Xil_Out32(nWaddr, nWdata);
        }  
    } else { // Pdef RAM
        for (nEntry = 0 ; nEntry < SIZERAM_PULSE_DEFN ; nEntry++)
        {
            nWdata = 0x0;
            nWaddr = ADR_BASE_PULSE_DEFN + 4*nEntry;
            Xil_Out32(nWaddr, nWdata);
        }
    }
    
    

    //-----------------------------------------------------------------
    // Read back all RAMs. Every channel output is or'ed so when all
    // channels are enabled the read back values should all still be zero.
    //-----------------------------------------------------------------
    if ((memsel & 0x1) == 1) {
        for (nEntry = 0 ; nEntry < SIZERAM_PULSE_WAVE ; nEntry++)
        {
            nRaddr = ADR_BASE_PULSE_WAVE + 4*nEntry;
            nRdata = Xil_In32(nRaddr);
            if (nRdata != 0x0) {
                nErrors++;
                (void)xil_printf("ch all:  wave %u: (0x%08X) = 0x%08X not 0x00000000\r\n", nEntry, nRaddr, nRdata);
            }
        }        
    } else {
        for (nEntry = 0 ; nEntry < SIZERAM_PULSE_DEFN ; nEntry++)
        {
            nRaddr = ADR_BASE_PULSE_DEFN + 4*nEntry;
            nRdata = Xil_In32(nRaddr);
            if (nRdata != 0x0) {
                nErrors++;
                (void)xil_printf("ch all:  defn %u: (0x%08X) = 0x%08X not 0x00000000\r\n", nEntry, nRaddr, nRdata);
            }
        }        
    }

    // clear errors as well if pulse definition cleared
    if ((memsel & 0x1) == 0) {
        nRdata = Xil_In32(ADR_GPIO_IN);
        Xil_Out32(ADR_GPIO_OUT, set_bit(nRdata, C_GPIO_PS_ERR_CLR));
        nRdata = Xil_In32(ADR_GPIO_IN);
        Xil_Out32(ADR_GPIO_OUT, clr_bit(nRdata, C_GPIO_PS_ERR_CLR));
    }


    // Report pass/fail
    if (nErrors == 0)
        (void)xil_printf("Clearing RAMs PASSED : %u errors\r\n", nErrors);
    else
        (void)xil_printf("Clearing RAMs FAILED : %u errors\r\n", nErrors);

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
       (void)xil_printf("Write channel %u\r\n", nChannel);
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
           (void)xil_printf("ch %2d: test %u: (0x%08X) = 0x%08X\r\n", nChannel, nEntry, nWaddr, nWdata);
        }
       (void)xil_printf("Writing complete\r\n");
    }

    //---------------------------------------------------------------------
    // If channel is full, read back and test the waveform RAM and the pulse definition RAM,
    // Otherwise read/test the single test register.
    //---------------------------------------------------------------------
    for (nChannel = 0 ; nChannel < 32 ; nChannel++)
    {
       (void)xil_printf("Read channel %u\r\n", nChannel);
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
    nErrors += clear_rams(0);
    nErrors += clear_rams(1);

    (void)xil_printf("Read test complete : ");
    if (nErrors != 0)
        (void)xil_printf(" %u errors\r\n", nErrors);
    else
        (void)xil_printf(" PASS\r\n");

    return nErrors;
}
