//------------------------------------------------------------------------------------------------------------------------
// Address definitions  
//------------------------------------------------------------------------------------------------------------------------
#include "xparameters.h"
#include "xil_cache.h"

//--------------------------------------------------------------------------------
#define ADR_BASE_DDR                        0x00000000


//------------------------------------------------------------------------
// Interrupt sources
/******************************************************************/

/* Definitions for Fabric interrupts connected to ps7_scugic_0 */
//#define XPAR_FABRIC_IRQ_F2P0_INTR 61U
//#define XPAR_FABRIC_IRQ_F2P1_INTR 62U
//#define XPAR_FABRIC_IRQ_F2P2_INTR 63U
//#define XPAR_FABRIC_IRQ_F2P3_INTR 64U
//#define XPAR_FABRIC_IRQ_F2P4_INTR 65U
//#define XPAR_FABRIC_IRQ_F2P5_INTR 66U
//#define XPAR_FABRIC_IRQ_F2P6_INTR 67U
//#define XPAR_FABRIC_IRQ_F2P7_INTR 68U
//#define XPAR_FABRIC_IRQ_F2P8_INTR 84U
//#define XPAR_FABRIC_IRQ_F2P9_INTR 85U
//#define XPAR_FABRIC_IRQ_F2P10_INTR 86U
//#define XPAR_FABRIC_IRQ_F2P11_INTR 87U
//#define XPAR_FABRIC_IRQ_F2P12_INTR 88U
//#define XPAR_FABRIC_IRQ_F2P13_INTR 89U
//#define XPAR_FABRIC_IRQ_F2P14_INTR 90U
//#define XPAR_FABRIC_IRQ_F2P15_INTR 91U

//------------------------------------------------------------------------
#define INTR_TICK_SEC                  XPAR_FABRIC_IRQ_F2P0_INTR
#define INTR_MISC                      XPAR_FABRIC_IRQ_F2P1_INTR

#define FMC_BOARD_0 0
#define FMC_BOARD_1 1

/*
 * PS AXI GPIO (gpio_int) ties to ps_gpin / ps_gpout in qlaser_top_zcu102_fmc0_clkdebug.vhdl:
 *   gpout[0] = pulse trigger, [1] = pulse enable, [4] = fmc0_tx_core_reset + fmc1_tx_core_reset (JESD PHY)
 *   gpin[0] = fmc0_tx_reset_done, [1] = fmc1_tx_reset_done, [4] = fmc0_gt_powergood, [5] = fmc1_gt_powergood
 * (qlaser_top_zcu102_fmc0_2links uses wider nibbles on gpin[3:0]/[7:4]/[11:8]/[15:12] instead — not this map.)
 */
#define BIT_GPIO_PULSE_TRIGGER_PS   0
#define BIT_GPIO_PULSE_ENABLE_PS    1
#define BIT_GPIO_FMC0_TX_CORE_RESET 4
#define BIT_GPI_FMC0_TX_RESET_DONE  (1u << 0)
#define BIT_GPI_FMC1_TX_RESET_DONE  (1u << 1)
#define BIT_GPI_FMC0_GT_PGOOD       (1u << 4)
#define BIT_GPI_FMC1_GT_PGOOD       (1u << 5)

//----------------------------------------------------------------------------------------------------------------------
// General purpose inputs to CPU GPIO reg 
// Avnet carrier board has 8 LEDs, 4 buttons
// ThruWave carrier board has 4 LEDs, 4 switches.
//------------------------------------------------------------------------------------------------------------------------
#define BIT_GPI_BUTTON_0     0
#define BIT_GPI_BUTTON_1     1
#define BIT_GPI_BUTTON_2     2
#define BIT_GPI_BUTTON_3     3

#define BIT_GPI_SW_0         0
#define BIT_GPI_SW_1         1
#define BIT_GPI_SW_2         2
#define BIT_GPI_SW_3         3

// GPO bus bit assignments
#define BIT_GPO_USER_LED0    0
#define BIT_GPO_USER_LED1    1
#define BIT_GPO_USER_LED2    2
#define BIT_GPO_USER_LED3    3
#define BIT_GPO_USER_LED4    4
#define BIT_GPO_USER_LED5    5
#define BIT_GPO_USER_LED6    6
#define BIT_GPO_USER_LED7    7
#define BIT_GPO_8            8
#define BIT_GPO_9            9
#define BIT_GPO_10          10
#define BIT_GPO_11          11
#define BIT_GPO_12          12
#define BIT_GPO_13          13
#define BIT_GPO_14          14
#define BIT_GPO_15          15
#define BIT_GPO_16          16
#define BIT_GPO_17          17
#define BIT_GPO_18          18
#define BIT_GPO_19          19
#define BIT_GPO_21          21
#define BIT_GPO_22          22
#define BIT_GPO_23          23
#define BIT_GPO_24          24
#define BIT_GPO_25          25
#define BIT_GPO_26          26
#define BIT_GPO_27          27
#define BIT_GPO_28          28
#define BIT_GPO_29          29
#define BIT_GPO_30          30
#define BIT_GPO_31          31

