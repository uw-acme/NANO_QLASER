//----------------------------------------------------------------------
//
// jesd204c_ip.h
//
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

#define ADR_BASE_JESD      XPAR_JESD_FMC0_JESD204C_BASEADDR 
#define ADR_FMC_STEP      (XPAR_JESD_FMC0_JESD204C_BASEADDR - XPAR_JESD_FMC0_JESD204C_BASEADDR)   // This is the base address difference between the JESD interfaces

                                        
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
// Per Lane status regs (TX only)
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
#define ADR_LANE_STEP 0x0100            // This is the address difference between the registers for each individual lane in a JESD interfaces
#define ADR_JESD_LANE(FMC, LANE, ADR_REG)    (ADR_BASE_JESD + (FMC * ADR_FMC_STEP) + (LANE * ADR_LANE_STEP) + ADR_REG)




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

