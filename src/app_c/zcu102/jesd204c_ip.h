//----------------------------------------------------------------------
//
// jesd204c_ip.h
//
// Assumes FMC216 + LMK Distribution 'B': 100 MHz GT ref (DCLKout10 = Fin/2) and
// LMFC 6.25 MHz SYSREF (Fin/32 with Fin=200 MHz). Line rate 4.0 Gbps is set in Vivado.
// xil_jesd_ip_init() must match DAC39J84 JESD register defaults (regmap_dac39j84.h).
//----------------------------------------------------------------------
#include "xparameters.h"


/* Peripheral Definitions for peripheral JESD_FMC0_JESD204C */
// #define XPAR_JESD_FMC0_JESD204C_BASEADDR 0xA1000000
// #define XPAR_JESD_FMC0_JESD204C_HIGHADDR 0xA100FFFF
//
//
// /* Peripheral Definitions for peripheral JESD_FMC1_JESD204C */
// #define XPAR_JESD_FMC1_JESD204C_BASEADDR 0xA2000000
// #define XPAR_JESD_FMC1_JESD204C_HIGHADDR 0xA200FFFF

#define ADR_BASE_JESD       XPAR_JESD_FMC0_JESD204C_BASEADDR
/* Second JESD base (FMC1) when in BSP — used by qlaser_top_zcu102_fmc0_clkdebug and fmc0_2links tops */
#ifdef XPAR_JESD_FMC1_JESD204C_BASEADDR
#define JESD_HAS_FMC1       1
#define ADR_FMC_STEP        (XPAR_JESD_FMC1_JESD204C_BASEADDR - XPAR_JESD_FMC0_JESD204C_BASEADDR)
#else
#define JESD_HAS_FMC1       0
#define ADR_FMC_STEP        0
#endif
// Address difference between the per-lane register blocks.  The IP places the lane
// bank at 0x400 and gives each lane 0x80 bytes (lane0 LID 0x404, lane1 0x484,
// lane2 0x504 ... lane7 0x784), confirmed in the generated
// jesd204c_0_jesd204c_regif_lane.v decode.  A 0x100 step here would write lane N's
// settings into lane 2N and push lanes 4-7 outside the bank.
#define ADR_LANE_STEP       0x0080


//----------------------------------------------------------------------------------------------------
// Register map of Xilinx JESD204C IP block version 4.2 from document PG242
// Registers that are not used in 8B10B TX-only, are commented out
//
//          Register Name           AXI4-Lite Addr      64B66B          8B10B
//                                                     TX      RX      TX      RX
//----------------------------------------------------------------------------------------------------
#define     REG_JESD_IP_VERSION         0x000    //    R       R       R       R
#define     REG_JESD_IP_CONFIG          0x004    //    R       R       R       R
#define     REG_JESD_RESET              0x020    //    RW      RW      RW      RW
#define     REG_JESD_CTRL_TX_SYNC       0x028    //    N/A     N/A     RW      N/A
#define     REG_JESD_CTRL_SUB_CLASS     0x034    //    RW      RW      RW      RW
#define     REG_JESD_CTRL_8B10B_CFG     0x03C    //    N/A     N/A     RW      RW
#define     REG_JESD_CTRL_LANE_ENA      0x040    //    RW      RW      RW      RW
#define     REG_JESD_CTRL_TEST_MODE     0x048    //    RW      RW      RW      RW
#define     REG_JESD_CTRL_SYSREF        0x050    //    RW      RW      RW      RW
#define     REG_JESD_STAT_STATUS        0x060    // -  R       R       R       R
#define     REG_JESD_CTRL_IRQ           0x064    //    RW      RW      RW      RW
#define     REG_JESD_STAT_IRQ           0x068    //    R       R       R       R
#define     REG_JESD_CTRL_TX_ILA_CFG0   0x070    //    N/A     N/A     RW      N/A
#define     REG_JESD_CTRL_TX_ILA_CFG1   0x074    //    N/A     N/A     RW      N/A
#define     REG_JESD_CTRL_TX_ILA_CFG2   0x078    //    N/A     N/A     RW      N/A
#define     REG_JESD_CTRL_TX_ILA_CFG3   0x07C    //    N/A     N/A     RW      N/A
#define     REG_JESD_CTRL_TX_ILA_CFG4   0x080    //    N/A     N/A     RW      N/A

//------------------------------------------------------------
// Per Lane regs (TX only)
//------------------------------------------------------------
#define     REG_JESD_CTRL_TX_ILA_LID   0x404    //    N/A     N/A     RW      N/A
#define     REG_JESD_CTRL_TX_GT        0x460    //    RW      RW      RW      RW

//------------------------------------------------------------
// Constants for FMC connectors and IP lanes.
//------------------------------------------------------------
#define FMC0    0
#define FMC1    1
#define LANE0   0
#define LANE1   1
#define LANE2   2
#define LANE3   3
#define LANE4   4
#define LANE5   5
#define LANE6   6
#define LANE7   7

//------------------------------------------------------------
// Macro for reading a register from a particular FMC interface
//------------------------------------------------------------
// Read the JESD registers. e.g. ADR_JESD(FMC0, REG_JESD_IP_VERSION)
#define ADR_JESD(FMC, ADR_REG)          (ADR_BASE_JESD + (FMC * ADR_FMC_STEP) + ADR_REG)

// Read the per-lane registers. e.g. ADR_JESD_LANE(FMC1, LANE3, REG_JESD_CTRL_TX_ILA_LID)
#define ADR_JESD_LANE(FMC, LANE, ADR_REG)    (ADR_BASE_JESD + (FMC * ADR_FMC_STEP) + (LANE * ADR_LANE_STEP) + ADR_REG)

#define SUBCLASS0  0
#define SUBCLASS1  1
#define SUBCLASS2  2


//  //----------------------------------------------------------------------------------------------------
//  // Full list of registers
//  //
//  //
//  //          Register Name                   AXI4-Lite Addr                64B66B          8B10B
//  //                                                                        TX      RX      TX      RX
//  //----------------------------------------------------------------------------------------------------
//  #define     ADR_JESD0_IP_VERSION         (ADR_BASE_JESD + 0x000)    //    R       R       R       R
//  #define     ADR_JESD0_IP_CONFIG          (ADR_BASE_JESD + 0x004)    //    R       R       R       R
//  #define     ADR_JESD0_RESET              (ADR_BASE_JESD + 0x020)    //    RW      RW      RW      RW
//  #define     ADR_JESD0_CTRL_EN            (ADR_BASE_JESD + 0x024)    //    RW      RW      N/A     N/A
//  #define     ADR_JESD0_CTRL_TX_SYNC       (ADR_BASE_JESD + 0x028)    //    N/A     N/A     RW      N/A
//  #define     ADR_JESD0_CTRL_SUB_CLASS     (ADR_BASE_JESD + 0x034)    //    RW      RW      RW      RW
//  #define     ADR_JESD0_CTRL_8B10B_CFG     (ADR_BASE_JESD + 0x03C)    //    N/A     N/A     RW      RW
//  #define     ADR_JESD0_CTRL_LANE_ENA      (ADR_BASE_JESD + 0x040)    //    RW      RW      RW      RW
//  #define     ADR_JESD0_CTRL_TEST_MODE     (ADR_BASE_JESD + 0x048)    //    RW      RW      RW      RW
//  #define     ADR_JESD0_CTRL_SYSREF        (ADR_BASE_JESD + 0x050)    //    RW      RW      RW      RW
//  #define     ADR_JESD0_STAT_STATUS        (ADR_BASE_JESD + 0x060)    // -  R       R       R       R
//  #define     ADR_JESD0_CTRL_IRQ           (ADR_BASE_JESD + 0x064)    //    RW      RW      RW      RW
//  #define     ADR_JESD0_STAT_IRQ           (ADR_BASE_JESD + 0x068)    //    R       R       R       R
//  #define     ADR_JESD0_CTRL_TX_ILA_CFG0   (ADR_BASE_JESD + 0x070)    //    N/A     N/A     RW      N/A
//  #define     ADR_JESD0_CTRL_TX_ILA_CFG1   (ADR_BASE_JESD + 0x074)    //    N/A     N/A     RW      N/A
//  #define     ADR_JESD0_CTRL_TX_ILA_CFG2   (ADR_BASE_JESD + 0x078)    //    N/A     N/A     RW      N/A
//  #define     ADR_JESD0_CTRL_TX_ILA_CFG3   (ADR_BASE_JESD + 0x07C)    //    N/A     N/A     RW      N/A
//  #define     ADR_JESD0_CTRL_TX_ILA_CFG4   (ADR_BASE_JESD + 0x080)    //    N/A     N/A     RW      N/A
//
//  //------------------------------------------------------------
//  // Per Lane status regs (TX only)
//  //------------------------------------------------------------
//  #define     ADR_JESD0_CTRL_TX_ILA_LID_0  (ADR_BASE_JESD + 0x404)    //    N/A     N/A     RW      N/A
//  #define     ADR_JESD0_CTRL_TX_GT_0       (ADR_BASE_JESD + 0x460)    //    RW      RW      RW      RW
//  //------------------------------------------------------------
//  // Lane1 status regs (TX only)
//  //------------------------------------------------------------
//  #define     ADR_JESD0_CTRL_TX_ILA_LID_1  (ADR_BASE_JESD + 0x480 + 0x04)    //    N/A     N/A     RW      N/A
//  #define     ADR_JESD0_CTRL_TX_GT_1       (ADR_BASE_JESD + 0x480 + 0x60)    //    RW      RW      RW      RW
//  //------------------------------------------------------------
//  // Lane2 status regs (TX only)
//  //------------------------------------------------------------
//  #define     ADR_JESD0_CTRL_TX_ILA_LID_2  (ADR_BASE_JESD + 0x500 + 0x04)    //    N/A     N/A     RW      N/A
//  #define     ADR_JESD0_CTRL_TX_GT_2       (ADR_BASE_JESD + 0x500 + 0x60)    //    RW      RW      RW      RW
//  //------------------------------------------------------------
//  // ... Lane 3  0x580
//  // ... Lane 4  0x680
//  // ... Lane 5  0x680
//  // ... Lane 6  0x700
//  //------------------------------------------------------------
//  // Lane7 status regs (TX only)
//  //------------------------------------------------------------
//  #define     ADR_JESD0_CTRL_TX_ILA_LID_7  (ADR_BASE_JESD + 0x780 + 0x04)    //    N/A     N/A     RW      N/A
//  #define     ADR_JESD0_CTRL_TX_GT_7       (ADR_BASE_JESD + 0x780 + 0x60)    //    RW      RW      RW      RW
//  //------------------------------------------------------------
//

