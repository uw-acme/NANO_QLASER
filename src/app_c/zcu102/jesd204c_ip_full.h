//----------------------------------------------------------------------
//
// jesd204c.h
//
//----------------------------------------------------------------------
#include "xparameters.h"


#define ADR_BASE_JESD       XPAR_AXI_??__BASEADDR

//----------------------------------------------------------------------------------------------------
// Registers that are not used in 8B10B TX-only, are commented out 
//
//          Register Name                   AXI4-Lite Addr                64B66B          8B10B
//                                                                        TX      RX      TX      RX 
//----------------------------------------------------------------------------------------------------
#define     ADR_JESD0_IP_VERSION         (ADR_BASE_JESD + 0x000)    //    R       R       R       R
#define     ADR_JESD0_IP_CONFIG          (ADR_BASE_JESD + 0x004)    //    R       R       R       R
#define     ADR_JESD0_RESET              (ADR_BASE_JESD + 0x020)    //    RW      RW      RW      RW
//#define   ADR_JESD0_CTRL_ENABLE        (ADR_BASE_JESD + 0x024)    // -  RW      RW      N/A     N/A
#define     ADR_JESD0_CTRL_TX_SYNC       (ADR_BASE_JESD + 0x028)    //    N/A     N/A     RW      N/A
//#define   ADR_JESD0_CTRL_MB_IN_EMB     (ADR_BASE_JESD + 0x030)    // -  RW      RW      N/A     N/A
#define     ADR_JESD0_CTRL_SUB_CLASS     (ADR_BASE_JESD + 0x034)    //    RW      RW      RW      RW
//#define   ADR_JESD0_CTRL_META_MODE     (ADR_BASE_JESD + 0x038)    // -  RW      RW      N/A     N/A
#define     ADR_JESD0_CTRL_8B10B_CFG     (ADR_BASE_JESD + 0x03C)    //    N/A     N/A     RW      RW
#define     ADR_JESD0_CTRL_LANE_ENA      (ADR_BASE_JESD + 0x040)    //    RW      RW      RW      RW
//#define   ADR_JESD0_CTRL_RX_BUF_ADV    (ADR_BASE_JESD + 0x044)    // -  N/A     RW      N/A     RW
#define     ADR_JESD0_CTRL_TEST_MODE     (ADR_BASE_JESD + 0x048)    //    RW      RW      RW      RW
//#define   ADR_JESD0_CTRL_RX_MBLOCK_TH  (ADR_BASE_JESD + 0x04C)    // -  N/A     RW      N/A     N/A
#define     ADR_JESD0_CTRL_SYSREF        (ADR_BASE_JESD + 0x050)    //    RW      RW      RW      RW
//#define   ADR_JESD0_STAT_LOCK_DEBUG    (ADR_BASE_JESD + 0x054)    // -  N/A     R       N/A     N/A
//#define   ADR_JESD0_STAT_RX_ERR        (ADR_BASE_JESD + 0x058)    // -  N/A     N/A     N/A     R
//#define   ADR_JESD0_STAT_RX_DEBUG      (ADR_BASE_JESD + 0x05C)    // -  N/A     N/A     N/A     R
//#define   ADR_JESD0_STAT_STATUS        (ADR_BASE_JESD + 0x060)    // -  R       R       R       R
#define     ADR_JESD0_CTRL_IRQ           (ADR_BASE_JESD + 0x064)    //    RW      RW      RW      RW
#define     ADR_JESD0_STAT_IRQ           (ADR_BASE_JESD + 0x068)    //    R       R       R       R
#define     ADR_JESD0_CTRL_TX_ILA_CFG0   (ADR_BASE_JESD + 0x070)    //    N/A     N/A     RW      N/A
#define     ADR_JESD0_CTRL_TX_ILA_CFG1   (ADR_BASE_JESD + 0x074)    //    N/A     N/A     RW      N/A
#define     ADR_JESD0_CTRL_TX_ILA_CFG2   (ADR_BASE_JESD + 0x078)    //    N/A     N/A     RW      N/A
#define     ADR_JESD0_CTRL_TX_ILA_CFG3   (ADR_BASE_JESD + 0x07C)    //    N/A     N/A     RW      N/A
#define     ADR_JESD0_CTRL_TX_ILA_CFG4   (ADR_BASE_JESD + 0x080)    //    N/A     N/A     RW      N/A
//------------------------------------------------------------
// Lane0 status regs (RX only)
//------------------------------------------------------------
//#define   ADR_JESD0_STAT_RX_BUF_LVL    (ADR_BASE_JESD + 0x400)    // -  N/A     R       N/A     R
#define     ADR_JESD0_CTRL_TX_ILA_LID    (ADR_BASE_JESD + 0x404)    //    N/A     N/A     RW      N/A
//#define   ADR_JESD0_STAT_RX_ERROR_CNT0 (ADR_BASE_JESD + 0x410)    // -  N/A     R       N/A     N/A
//#define   ADR_JESD0_STAT_RX_ERROR_CNT1 (ADR_BASE_JESD + 0x414)    // -  N/A     R       N/A     N/A
//#define   ADR_JESD0_STAT_LINK_ERR_CNT  (ADR_BASE_JESD + 0x420)    // -  N/A     N/A     N/A     R
//#define   ADR_JESD0_STAT_TEST_ERR_CNT  (ADR_BASE_JESD + 0x424)    // -  N/A     N/A     N/A     R
//#define   ADR_JESD0_STAT_TEST_ILA_CNT  (ADR_BASE_JESD + 0x428)    // -  N/A     N/A     N/A     R
//#define   ADR_JESD0_STAT_TEST_MF_CNT   (ADR_BASE_JESD + 0x42C)    // -  N/A     N/A     N/A     R
//#define   ADR_JESD0_CTRL_RX_ILA_CFG0   (ADR_BASE_JESD + 0x430)    // -  N/A     N/A     N/A     R
//#define   ADR_JESD0_CTRL_RX_ILA_CFG1   (ADR_BASE_JESD + 0x434)    // -  N/A     N/A     N/A     R
//#define   ADR_JESD0_CTRL_RX_ILA_CFG2   (ADR_BASE_JESD + 0x438)    // -  N/A     N/A     N/A     R
//#define   ADR_JESD0_CTRL_RX_ILA_CFG3   (ADR_BASE_JESD + 0x43C)    // -  N/A     N/A     N/A     R
//#define   ADR_JESD0_CTRL_RX_ILA_CFG4   (ADR_BASE_JESD + 0x440)    // -  N/A     N/A     N/A     R
//#define   ADR_JESD0_CTRL_RX_ILA_CFG5   (ADR_BASE_JESD + 0x444)    // -  N/A     N/A     N/A     R
//#define   ADR_JESD0_CTRL_RX_ILA_CFG6   (ADR_BASE_JESD + 0x448)    // -  N/A     N/A     N/A     R
//#define   ADR_JESD0_CTRL_RX_ILA_CFG7   (ADR_BASE_JESD + 0x44C)    // -  N/A     N/A     N/A     R
//------------------------------------------------------------
#define     ADR_JESD0_CTRL_TX_GT         (ADR_BASE_JESD + 0x460)    //    RW      RW      RW      RW
//#define   ADR_JESD0_CTRL_RX_GT         (ADR_BASE_JESD + 0x464)    // -  RW      RW      RW      RW Versal
//#define   ADR_JESD0_CTRL_TX_VERSAL_GTY (ADR_BASE_JESD + 0x468)    // -  RW      RW      RW      RW
//#define   ADR_JESD0_CTRL_TX_VERSAL_GTM (ADR_BASE_JESD + 0x46C)    // -  RW      RW      RW      RW
//------------------------------------------------------------
// Lane1 status regs (RX only)
//------------------------------------------------------------
//#define ADR_JESD0_STAT_RX_BUF_LVL      (ADR_BASE_JESD +0x480)     // -  N/A     R       N/A     R
#define   ADR_JESD0_CTRL_TX_ILA_LID      (ADR_BASE_JESD +0x404)     //    N/A     N/A     RW      N/A
//------------------------------------------------------------
// (Lane2 etc)
//------------------------------------------------------------
//#define ADR_JESD0_STAT_RX_BUF_LVL      (ADR_BASE_JESD + 0x500)    // -  N/A     R       N/A     R
#define   ADR_JESD0_CTRL_TX_ILA_LID      (ADR_BASE_JESD + 0x504)    //    N/A     N/A     RW      N/A
                                        
                                        
#define ADR_FMC_STEP 0x01000000         // This is the base address difference between the JESD interfaces
#define ADR_LANE_STEP 0x0100            // This is the address difference between the registers for each individual lane in a JESD interfaces
#define ADR_JESD(FMC, ADR_REG)           (ADR_BASE_JESD + (FMC * ADR_FMC_STEP) + ADR_REG)