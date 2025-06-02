//----------------------------------------------------------------------
//
// app_monitor_basic.c
//
// 
// 'XPAR' addresses are from xparameter.h (vitis generated file)
//----------------------------------------------------------------------
#include "qlaser_fpga.h"
#include "platform.h"

int main()
{
    u32     nRdata = 0;

    char    cUartRx;    // Data from UART

    bool    echo = false; // Echo the received char

    u64     nValue  = 0;

    int     nMode = C_MODE_CMD;

    init_platform();
    // Initialize PMOD
    Xil_Out32(PMOD_ADDR_INTERNAL_REF, nRdata);
    Xil_Out32(PMOD_ADDR_CTRL, 0x1);
    Xil_Out32(C_ADDR_INTERNAL_REF, 0x00000000);
    // initialize the RAMs
    clear_rams(0);
    clear_rams(1);


    (void)xil_printf("---------------------------------------------------------------------\r\n");
    (void)xil_printf(" app_qlaser_py : version %s\r\n", g_strVersion);
    (void)xil_printf("---------------------------------------------------------------------\r\n");
    nRdata = Xil_In32(ADR_MISC_VERSION);
    (void)xil_printf("FPGA Version = 0x%08X\r\n", nRdata);
    print("Ready\n\r");


	//----------------------------------------------------------------------
    // Command parser. Loops forever.
    //----------------------------------------------------------------------

    while (1)
    {
        if (XUartPs_IsReceiveData(STDIN_BASEADDRESS))
        {
            cUartRx = (u8)XUartPs_ReadReg(STDIN_BASEADDRESS, XUARTPS_FIFO_OFFSET);
            if (echo) outbyte(cUartRx);       // Echo the received char

            //---------------------------------------------------------------------
            // In COMMAND mode all non-digit characters are single-character commands
            //---------------------------------------------------------------------
            // TODO: Eric2Geoff: there are no other modes, so I don't think this is needed. Should always be in CMD mode.
            if (nMode == C_MODE_CMD)
            {
                //---------------------------------------------------------
                // If character is 0-9, build a number value with it.
                // Every time a consecutive digit is received, multiply nValue by 10 and add the new digit.
                //---------------------------------------------------------
                if ( (cUartRx >= 0x30) && (cUartRx <= 0x39) )
                {
                    nValue = (nValue * 10) + (cUartRx - 0x30);
                }

                //---------------------------------------------------------
                // Otherwise, characters are single-character commands
                //---------------------------------------------------------
                else       
                {
                    if (echo) {
                        outbyte(0x0D);          // CR
                        outbyte(0x0A);          // LF
                    }
                    switch (cUartRx)
                    {
                    	// Section I and II are for python CLI, not meant to be directly accessed from UART

						//--------------------------------------------------------
						// SECTION I: GENERAL CPU2BLOCK SELECT FOR BLOCK LVL REGS
						//--------------------------------------------------------
						//-----------------------------------------------------------------
						// Read Pulse defn addr from given addr in AC block
						//-----------------------------------------------------------------
						case 0xA0:
							nRdata = Xil_In32(ADR_BASE_PULSE_DEFN + 4*nValue);
							(void)xil_printf ("%d\r\n", nRdata);
						break;
						//-----------------------------------------------------------------
						// Read Pulse wave addr from given addr in AC block
						//-----------------------------------------------------------------
						case 0xB0:
							nRdata = Xil_In32(ADR_BASE_PULSE_WAVE + 4*nValue);
							(void)xil_printf ("%d\r\n", nRdata);
						break;
						//--------------------------------------------------------
						// Select AC Block. Generic (currently for dev only)
						//--------------------------------------------------------
						case 0xC0:
							nRdata = Xil_In32(ADR_BASE_DACS_AC + 4*nValue);
							(void)xil_printf ("%d\r\n", nRdata);
						break;
                        //--------------------------------------------------------
						// Select DC Block
						//--------------------------------------------------------
                        case 0xD0:
                            nRdata = Xil_In32(ADR_BASE_DACS_DC + 4*nValue);
                            (void)xil_printf ("%d\r\n", nRdata);
                        break;
						//--------------------------------------------------------
						// Select Misc Block
						//--------------------------------------------------------
						case 0xE0:
							nRdata = Xil_In32(ADR_BASE_MISC + 4*nValue);
							(void)xil_printf ("%d\r\n", nRdata);
						break;


						//--------------------------------------------------------
						// SECTION II: BLOCK-LEVEL Write ACTIONS
						//--------------------------------------------------------
						//---------------------------------------------------------
						// Write PD ram.
						//---------------------------------------------------------
						case 0xA1:
							Xil_Out32(ADR_BASE_PULSE_DEFN + 4*((u16)(nValue >> 32)), (u32)(nValue & 0xFFFFFFFF));
						break;
						//-----------------------------------------------------------------
						// Write to the waveform ram.
						//-----------------------------------------------------------------
						case 0xB1:
							Xil_Out32(ADR_BASE_PULSE_WAVE + 4*((u16)(nValue >> 32)), (u32)(nValue & 0xFFFFFFFF));
						break;
                        //--------------------------------------------------------
                        // Generic Write to AC block (currently for dev only)
                        //--------------------------------------------------------
                        case 0xC1:
                            Xil_Out32(ADR_BASE_DACS_AC + 4*((u16)(nValue >> 32)), (u32)(nValue & 0xFFFFFFFF));
                        break;
                        //--------------------------------------------------------
						// Write to the DC channel
						//--------------------------------------------------------
                    	case 0xD1:
                            Xil_Out32(ADR_BASE_DACS_DC + 4*((u16)(nValue >> 32)), (u32)(nValue & 0xFFFFFFFF));
                        break;
						//-----------------------------------------------------------------
						// Generic Write to Misc block
						//-----------------------------------------------------------------
						case 0xE1:
							Xil_Out32(ADR_BASE_MISC + 4*((u16)(nValue >> 32)), (u32)(nValue & 0xFFFFFFFF));
						break;
						//---------------------------------------------------------
						// Check AC channels errors. JSONfied for Python to decode
						//---------------------------------------------------------
						case 0x90:
							(void)xil_printf("{\"wave table overflow\": %d, \"rise size too small\": %d, \"time step bigger than rise\": %d, \"amplitude scale larger than 1\": %d, \"time step smaller than 1\": %d, \"start time too early\": %d}",
							                Xil_In32(ADR_REG_ERR_RAM_OF),
							                Xil_In32(ADR_REG_ERR_INVAL_LEN),
							                Xil_In32(ADR_REG_ERR_BIG_STEP),
							                Xil_In32(ADR_REG_ERR_BIG_GAIN),
							                Xil_In32(ADR_REG_ERR_SMALL_TIME),
                                            Xil_In32(ADR_REG_ERR_START_TIME));
						break;

						//----------------------------------------------------------------
						// SECTION III: ASCII COMMANDS FOR OTHER GENERAL OR DEBUG PURPOSE
						//----------------------------------------------------------------
                        //---------------------------------------------------------
                        // Command Echoing
                        //---------------------------------------------------------
                        case 'e':
                        	if (nValue == 0) {
								echo = false;
							} else {
								echo = true;
								xil_printf("Command Echo On!\r\n");
							}
						break;
						//---------------------------------------------------------
						// Get versions only
						//---------------------------------------------------------
						case 'v':
							(void)xil_printf(" Firmware Version %s\r\n", g_strVersion);
							(void)xil_printf(" FPGA version : %08X \r\n", Xil_In32(ADR_MISC_VERSION));
						break;                        
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
                            print_regs();
                        break;
                        //---------------------------------------------------------
                        // Reset stuff
                        // TODO: Properly reset the FPGA itself from here?
                        //---------------------------------------------------------
                        case 'R':
                            // psu_ps_pl_reset_config_data();
                            nRdata = 0;
                            echo = false;
                            nValue  = 0;

                            // Use vGPIO MSB pin for FPGA reset
                            Xil_Out32(ADR_GPIO_OUT, 1 << 31);

                            // Clear vGPIOs
                            Xil_Out32(ADR_GPIO_OUT, 0);

                            // Clear RAMs
                            clear_rams(0);
                            clear_rams(1);

                            // Clear all DC channels
                            Xil_Out32(C_ADDR_SPI_ALL, 0x10000000);
                            Xil_Out32(C_ADDR_INTERNAL_REF, 0x00000000);
                        break;
                        //---------------------------------------------------------
                        // Reset memory. 0 for pulse definition, 1 for waveform
                        //---------------------------------------------------------
                        case 'r':
                            clear_rams(nValue);
                        break;
                        //---------------------------------------------------------
                        // Set pulse sequence length
                        //---------------------------------------------------------
                        case 's':
 						    Xil_Out32(ADR_PULSE_REG_SEQ_LEN, nValue);
                            if (echo)
                                (void)xil_printf ("Set sequence 0x%08X\r\n", Xil_In32(ADR_PULSE_REG_SEQ_LEN));
                        break;
                        //---------------------------------------------------------
                        // Set Pulse block channel select register
                        //---------------------------------------------------------
                        case 'c':
                            if (nValue == 0) {
                                (void)xil_printf ("*ERR*: Channel select cannot be %d\r\n", nValue);
                            } else if (nValue == 99) {
                        		Xil_Out32(ADR_PULSE_REG_CHSEL, 0xFFFFFFFF);
                        		(void)xil_printf ("Selected all Channels\r\n");
                        	} else {
                        		Xil_Out32(ADR_PULSE_REG_CHSEL, nValue);
                        		(void)xil_printf ("Selected channel(s): 0x%08X\r\n", nValue);
                        	}
                        break;
                        //---------------------------------------------------------
                        // Enable Pulse Generator(s)
                        //---------------------------------------------------------
                        case 'C':
							Xil_Out32(ADR_MISC_ENABLE, 0x1);

                        	if (nValue == 99) {
                        		Xil_Out32(ADR_PULSE_REG_CHEN, 0xFFFFFFFF);
                        		(void)xil_printf ("Enable all channels\r\n");
                        	} else {
                        		Xil_Out32(ADR_PULSE_REG_CHEN, nValue);
                        		(void)xil_printf ("Enable channel(s): 0x%08X\r\n", nValue);
                        	}
						break;
                        //---------------------------------------------------------
                        // mimic TTL trigger using vGPIO. Take LSB of input nValue
                        //---------------------------------------------------------
                        case 't':
                        	nRdata = Xil_In32(ADR_GPIO_IN);
                        	if ((nValue & 0x1) == 1) {  // LSB of nValue
                                // clear error flags before setting trigger
                                nRdata = set_bit(nRdata, C_GPIO_PS_ERR_CLR);
                                Xil_Out32(ADR_GPIO_OUT, nRdata);
                                nRdata = clr_bit(nRdata, C_GPIO_PS_ERR_CLR);
                                Xil_Out32(ADR_GPIO_OUT, nRdata);
                                Xil_Out32(ADR_GPIO_OUT, set_bit(nRdata, C_GPIO_PS_TRIG));
                            } else {
                                Xil_Out32(ADR_GPIO_OUT, clr_bit(nRdata, C_GPIO_PS_TRIG));
                            }
                            // Read bacc trigger register to check trigger status, use lambda to print
                            nRdata = Xil_In32(ADR_MISC_TRIGGER);
                            (void)xil_printf ("Trigger status: %d\r\n", nRdata);

                        break;
                        //---------------------------------------------------------
                        // Print waveform RAM for up to N addresses, zero for all
                        //---------------------------------------------------------
                        case 'W':
                            if (echo)
                                (void)xil_printf ("Read waveform RAM: ");
                            read_pulse_wave(nValue);
                        break;
                        //----------------------------------------------------------------
                        // Print pulse definition RAM for up to N addresses, zero for all
                        //----------------------------------------------------------------
                        case 'w':
                            if (echo)
                                (void)xil_printf ("Read pulse definition RAM: ");
                            read_pulse_dfn(nValue);
                        break;
                        //-------------------------------------------------------------
                        // Get the next zero-valued 32-bit address in the waveform RAM
                        // nValue: 0x0 = pulse definitions, 0x1 = waveform tables
                        // For pulse definition, it is assuemd start time = 0 means
                        // empty entry, as it is invalid anyways
                        //-------------------------------------------------------------
                        case 'i':
                            nRdata = ((nValue & 0x1) == 1) ? findZeroIndex(ADR_BASE_PULSE_WAVE, 1) * 2 : findZeroIndex(ADR_BASE_PULSE_DEFN, 4);
                            (void)xil_printf ("%d\r\n", nRdata);
                        break;
                        //---------------------------------------------------------
                        // Experimental. Anything
                        //---------------------------------------------------------
                        case 'x':

                        break;
                        //---------------------------------------------------------
                        // Catch-all for unknown commands
                        //---------------------------------------------------------
                        default:
                        	(void)xil_printf ("*ERR*: Command 0x%02X is invalid!\r\n", cUartRx);
						break;
                    }
                    // clean up for next transaction
                    nValue = 0;
                }
            }
        }
    }

    print("Exit!\n");
    cleanup_platform();
    return 0;
}

