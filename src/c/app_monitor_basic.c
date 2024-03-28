//----------------------------------------------------------------------
//
// app_monitor_basic.c
//
// 
// 'XPAR' addresses are from xparameter.h (vitis generated file)
//----------------------------------------------------------------------
#include "xparameters.h"
#include <stdio.h>
#include "stdbool.h"
#include "platform.h"
#include "xil_printf.h"
#include "xil_io.h"
#include "xuartps_hw.h"

#include "xiicps.h"

#include "qlaser_fpga.h"

//----------------------------------------------------------------
// Design-specific addresses. Yours are probably different
//----------------------------------------------------------------
// AXI_GPIO IP block register map
//#define XGPIO_DATA_OFFSET	    0x0   /**< Data register for 1st channel */
//#define XGPIO_TRI_OFFSET	    0x4   /**< I/O direction reg for 1st channel */
//#define XGPIO_DATA2_OFFSET	0x8   /**< Data register for 2nd channel */
//#define XGPIO_TRI2_OFFSET	    0xC   /**< I/O direction reg for 2nd channel */
#define ADR_BASE_GPIO_INT  XPAR_AXI_GPIO_INT_BASEADDR
#define ADR_GPIO_OUT       (ADR_BASE_GPIO_INT + 0x0)
#define ADR_GPIO_IN        (ADR_BASE_GPIO_INT + 0x8)

// LED and Button GPIO interfaces
#define ADR_BASE_GPIO_LED_BTN   XPAR_AXI_GPIO_LED_BTN_BASEADDR  // 'XPAR' addresses are from xparameter.h (vitis generated file)
#define ADR_GPIO_LED       (ADR_BASE_GPIO_LED_BTN + 0x0)
#define ADR_GPIO_BTN       (ADR_BASE_GPIO_LED_BTN + 0x8)

// Addresses reached through CPUINT
#define ADR_BASE_CPUINT    XPAR_AXI_CPUINT_S00_AXI_BASEADDR    // from xparameters.h

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



// Mode defines how subsequent characters are handled
#define C_MODE_CMD      0   // single char commands. 0-9 are characters are used to build a decimal value


//----------------------------------------------------------------
// 1.0.a Initial version.
//----------------------------------------------------------------
char    g_strVersion[]          = "1.0.a";
int     g_nStateButtons 		= 0;
int     g_nStateSwitches 		= 0;

// UART I/O characters
char    inbyte      (void);
void    outbyte     (char c);

// Useful function declarations
int     set_bit                 (int nData, u8 nBit);
int     clr_bit                 (int nData, u8 nBit);
int     toggle_bit              (int nData, u8 nBit);
u8      get_bit                 (int nData, u8 nBit);
u8      is_hex                  (char c);
u8      hex2int                 (char c);


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
   (void)xil_printf(" app_monitor_basic : version %s\r\n", g_strVersion);
   (void)xil_printf(" FPGA version : %08X \r\n", Xil_In32(ADR_MISC_VERSION));
   (void)xil_printf("---------------------------------------------------------------------\r\n");
   (void)xil_printf(" h   : Print this message\r\n");
   (void)xil_printf(" 0-9 : Enter a 'Value'\r\n");
   (void)xil_printf(" P   : Print registers\r\n");
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
   (void)xil_printf ("ADR_PULSE_REG_GSTATUS              = %08X\r\n", Xil_In32(ADR_PULSE_REG_GSTATUS));
   (void)xil_printf ("ADR_PULSE_REG_CHSTATUS             = %08X\r\n", Xil_In32(ADR_PULSE_REG_CHSTATUS));
   (void)xil_printf ("ADR_PULSE_REG_TIMER                = %08X\r\n", Xil_In32(ADR_PULSE_REG_TIMER  ));

   (void)xil_printf ("ADR_MISC_VERSION                   = %08X\r\n", Xil_In32(ADR_MISC_VERSION     ));
   (void)xil_printf ("ADR_MISC_LEDS                      = %08X\r\n", Xil_In32(ADR_MISC_LEDS        ));
   (void)xil_printf ("ADR_MISC_LEDS_EN                   = %08X\r\n", Xil_In32(ADR_MISC_LEDS_EN     ));
   (void)xil_printf ("ADR_MISC_DEBUG_CTRL                = %08X\r\n", Xil_In32(ADR_MISC_DEBUG_CTRL  ));
   (void)xil_printf ("ADR_MISC_TRIGGER                   = %08X\r\n", Xil_In32(ADR_MISC_TRIGGER     ));
   (void)xil_printf("\r\n");
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
   (void)xil_printf(" app_monitor_basic : version %s\r\n", g_strVersion);
   (void)xil_printf("---------------------------------------------------------------------\r\n");
    nRdata = Xil_In32(ADR_MISC_VERSION);
   (void)xil_printf("FPGA Version = 0x%08X\r\n", nRdata);
    print("\n\r");


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

                //---------------------------------------------------------
                // Otherwise, characters are single-character commands
                //---------------------------------------------------------
                else       
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
                        // Add more commands
                        //---------------------------------------------------------
                        //case 'x':
                        //    function_x(nValue);
                        //break;
                    }
                    nDigit = 0; // Clear the digit counter once a command is executed. Value is still held.
                }
            }
        }

        //----------------------------------------------------------------------
        // Print button state if it changes. Carry out user actions.
        // No de-bouncing but seems to be safe. 
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
            // If SW1 is set 
            //--------------------------------------------------------------
            if ((g_nStateSwitches & 0x2) == 2) {
            	xil_printf ("Switch 2 \r\n");
            }

            //--------------------------------------------------------------
            // If SW0 is set
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

