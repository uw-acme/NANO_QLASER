//--------------------------------------------------------------------------------------------------------------------------------------------
// Address map and register default values for the LMK04828 PLL chip
//
//
//--------------------------------------------------------------------------------------------------------------------------------------------
// Name  Addr[11:0] Default (MSB) Bit 7 Bit 6 Bit 5 Bit 4 Bit 3 Bit 2 Bit 1 Bit0 (LSB)
//--------------------------------------------------------------------------------------------------------------------------------------------
#define ADR_REG_LMK_RESET               0x000 //  RESET 0 0 SPI_3WIRE_DIS 0 0 0 0
#define ADR_REG_LMK_PWR_DOWN            0x002 //  0 0 0 0 0 0 0 POWER_DOWN
#define ADR_REG_LMK_ID_DEVICE_TYPE      0x003 //  ID_DEVICE_TYPE
#define ADR_REG_LMK_ID_PROD1            0x004 //  ID_PROD[15:8]
#define ADR_REG_LMK_ID_PROD0            0x005 //  ID_PROD[7:0]
#define ADR_REG_LMK_ID_MASKREV          0x006 //  ID_MASKREV
#define ADR_REG_LMK_ID_VNDR1            0x00C //  ID_VNDR[15:8]
#define ADR_REG_LMK_ID_VNDR0            0x00D //  ID_VNDR[7:0]

// Clocks 0 and 1
#define ADR_REG_LMK_CLK0_1_ODL          0x100 //  0 CLKout0_1_ODL[1:0] CLKout0_1_IDL[1:0] DCLKout0_DIV[4:0]
#define ADR_REG_LMK_DCLK0_DDLY          0x101 //  DCLKout0_DDLY_CNTH[7:4] DCLKout0_DDLY_CNTL[3:0]
#define ADR_REG_LMK_DCLK0_ADLY          0x103 //  DCLKout0_ADLY[7:3] DCLKout0_ADLY_MUX DCLKout0_MUX
#define ADR_REG_LMK_SDCLK1              0x104 //  0 DCLKout0_HS SDCLKout1_MUX SDCLKout1_DDLY SDCLKout1_HS
#define ADR_REG_LMK_SDCLK1_ADLY         0x105 //  0 0 0 SDCLKout1_ADLY_EN SDCLKout1_ADLY
#define ADR_REG_LMK_SDCLK01_PD          0x106 //  DCLKout0_DDLY_PD DCLKout0_HSg_PD DCLKout0_ADLYg_PD DCLKout0_ADLY_PD CLKout0_1_PD SDCLKout1_DIS_MODE SDCLKout1_PD
#define ADR_REG_LMK_SDCLK01_POLFMT      0x107 //  SDCLKout1_POL CLKout1_FMT DCLKout0_POL CLKout0_FMT

// Clocks 2 and 3
#define ADR_REG_LMK_CLK2_3_ODL          0x108 //  0 CLKout2_3_ODL CLKout2_3_IDL DCLKout2_DIV
#define ADR_REG_LMK_DCLK2_DDLY          0x109 //  DCLKout2_DDLY_CNTH DCLKout2_DDLY_CNTL
#define ADR_REG_LMK_DCLK2_ADLY          0x10B //  DCLKout2_ADLY DCLKout2_ADLY_MUX DCLKout2_MUX
#define ADR_REG_LMK_SDCLK3              0x10C //  0 DCLKout2_HS SDCLKout3_MUX SDCLKout3_DDLY SDCLKout3_HS
#define ADR_REG_LMK_SDCLK3_ADLY         0x10D //  0 0 0 SDCLKout3_ADLY_EN SDCLKout3_ADLY
#define ADR_REG_LMK_SDCLK23_PD          0x10E //  DCLKout2_DDLY_PD DCLKout2_HSg_PD DCLKout2_ADLYg_PD DCLKout2_ADLY_PD CLKout2_3_PD SDCLKout3_DIS_MODE SDCLKout3_PD
#define ADR_REG_LMK_SDCLK23_POLFMT      0x10F //  SDCLKout3_POL CLKout3_FMT DCLKout2_POL CLKout2_FMT

// Clocks 4 and 5
#define ADR_REG_LMK_CLK4_5_ODL          0x110 //  0 CLKout4_5_ODL CLKout4_5_IDL DCLKout4_DIV
#define ADR_REG_LMK_DCLK4_DDLY          0x111 //  DCLKout4_DDLY_CNTH DCLKout4_DDLY_CNTL
#define ADR_REG_LMK_DCLK4_ADLY          0x113 //  DCLKout4_ADLY DCLKout4_ADLY_MUX DCLKout4_MUX
#define ADR_REG_LMK_SDCLK5              0x114 //  0 DCLKout4_HS SDCLKout5_MUX SDCLKout5_DDLY SDCLKout5_HS
#define ADR_REG_LMK_SDCLK5_ADLY         0x115 //  0 0 0 SDCLKout5_ADLY_EN SDCLKout5_ADLY
#define ADR_REG_LMK_SDCLK45_PD          0x116 //  DCLKout4_DDLY_PD DCLKout4_HSg_PD DCLKout4_ADLYg_PD DCLKout4_ADLY_PD CLKout4_5_PD SDCLKout5_DIS_MODE SDCLKout5_PD
#define ADR_REG_LMK_SDCLK45_POLFMT      0x117 //  SDCLKout5_POL CLKout5_FMT DCLKout4_POL CLKout4_FMT

// Clocks 6 and 7
#define ADR_REG_LMK_CLK6_7_ODL          0x118 //  0 CLKout6_7_ODL CLKout6_8_IDL DCLKout6_DIV
#define ADR_REG_LMK_DCLK6_DDLY          0x119 //  DCLKout6_DDLY_CNTH DCLKout6_DDLY_CNTL
#define ADR_REG_LMK_DCLK6_ADLY          0x11B //  DCLKout6_ADLY DCLKout6_ADLY_MUX DCLKout6_MUX
#define ADR_REG_LMK_SDCLK7              0x11C //  0 DCLKout6_HS SDCLKout7_MUX SDCLKout7_DDLY SDCLKout7_HS
#define ADR_REG_LMK_SDCLK7_ADLY         0x11D //  0 0 0 SDCLKout7_ADLY_EN SDCLKout7_ADLY
#define ADR_REG_LMK_SDCLK67_PD          0x11E //  DCLKout6_DDLY_PD DCLKout6_HSg_PD DCLKout6_ADLYg_PD DCLKout6_ADLY_PD CLKout6_7_PD SDCLKout7_DIS_MODE SDCLKout7_PD
#define ADR_REG_LMK_SDCLK67_POLFMT      0x11F //  SDCLKout7_POL CLKout7_FMT DCLKout6_POL CLKout6_FMT

// Clocks 8 and 9
#define ADR_REG_LMK_CLK8_9_ODL          0x120 //  0 CLKout8_9_ODL CLKout8_9_IDL DCLKout8_DIV
#define ADR_REG_LMK_DCLK8_DDLY          0x121 //  DCLKout8_DDLY_CNTH DCLKout8_DDLY_CNTL
#define ADR_REG_LMK_DCLK8_ADLY          0x123 //  DCLKout8_ADLY DCLKout8_ADLY_MUX DCLKout8_MUX
#define ADR_REG_LMK_SDCLK9              0x124 //  0 DCLKout8_HS SDCLKout9_MUX SDCLKout9_DDLY SDCLKout9_HS
#define ADR_REG_LMK_SDCLK9_ADLY         0x125 //  0 0 0 SDCLKout9_ADLY_EN SDCLKout9_ADLY
#define ADR_REG_LMK_SDCLK89_PD          0x126 //  DCLKout8_DDLY_PD DCLKout8_HSg_PD DCLKout8_ADLYg_PD DCLKout8_ADLY_PD CLKout8_9_PD SDCLKout9_DIS_MODE SDCLKout9_PD
#define ADR_REG_LMK_SDCLK89_POLFMT      0x127 //  SDCLKout9_POL CLKout9_FMT DCLKout8_POL CLKout8_FMT

// Clocks 10 and 11
#define ADR_REG_LMK_CLK10_11_ODL        0x128 //  0 CLKout10_11_ODL CLKout10_11_IDL DCLKout10_DIV
#define ADR_REG_LMK_DCLK10_DDLY         0x129 //  DCLKout10_DDLY_CNTH DCLKout10_DDLY_CNTL
#define ADR_REG_LMK_DCLK10_ADLY         0x12B //  DCLKout10_ADLY DCLKout10_ADLY_MUX DCLKout10_MUX
#define ADR_REG_LMK_SDCLK11             0x12C //  0 DCLKout10_HS SDCLKout11_MUX SDCLKout11_DDLY SDCLKout11_HS
#define ADR_REG_LMK_SDCLK11_ADLY        0x12D //  0 0 0 SDCKLout11_ADLY_EN SDCLKout11_ADLY
#define ADR_REG_LMK_SDCLK1011_PD        0x12E //  DCLKout10_DDLY_PD DCLKout10_HSg_PD DLCLKout10_ADLYg_PD DCLKout10_ADLY_PD CLKout10_11_PD SDCLKout11_DIS_MODE SDCLKout11_PD
#define ADR_REG_LMK_SDCLK1011_POLFMT    0x12F //  SDCLKout11_POL CLKout11_FMT DCLKout10_POL CLKout10_FMT

// Clocks 12 and 13
#define ADR_REG_LMK_CLK12_13_ODL        0x130 //  0 CLKout12_13_ODL CLKout12_13_IDL DCLKout12_DIV
#define ADR_REG_LMK_DCLK12_DDLY         0x131 //  DCLKout12_DDLY_CNTH DCLKout12_DDLY_CNTL
#define ADR_REG_LMK_DCLK12_ADLY         0x133 //  DCLKout12_ADLY DCLKout12_ADLY_MUX DCLKout12_MUX
#define ADR_REG_LMK_SDCLK13             0x134 //  0 DCLKout12_HS SDCLKout13_MUX SDCLKout13_DDLY SDCLKout13_HS
#define ADR_REG_LMK_SDCLK13_ADLY        0x135 //  0 0 0 SDCLKout13_ADLY_EN SDCLKout13_ADLY
#define ADR_REG_LMK_SDCLK1213_PD        0x136 //  DCLKout12_DDLY_PD DCLKout12_HSg_PD DCLKout12_ADLYg_PD DCLKout12_ADLY_PD CLKout12_13_PD SDCLKout13_DIS_MODE SDCLKout13_PD
#define ADR_REG_LMK_SDCLK1213_POLFMT    0x137 //  SDCLKout13_POL CLKout13_FMT DCLKout12_POL CLKout12_FMT

#define ADR_REG_LMK_OSC                 0x138 //  0 VCO_MUX OSCout_MUX OSCout_FMT
#define ADR_REG_LMK_SYSREFMUX           0x139 //  0 0 0 0 0 SYSREF_CLKin0_MUX SYSREF_MUX
#define ADR_REG_LMK_SYSREF_DIV1         0x13A //  0 0 0 SYSREF_DIV[12:8]
#define ADR_REG_LMK_SYSREF_DIV0         0x13B //  SYSREF_DIV[7:0]
#define ADR_REG_LMK_SYSREF_DDLY1        0x13C //  0 0 0 SYSREF_DDLY[12:8] 
#define ADR_REG_LMK_SYSREF_DDLY0        0x13D //  SYSREF_DDLY[7:0]
#define ADR_REG_LMK_SYSREF_PCNT         0x13E //  0 0 0 0 0 0 SYSREF_PULSE_CNT

#define ADR_REG_LMK_NCLK                0x13F //  0 0 0 PLL2_NCLK_MUX PLL1_NCLK_MUX FB_MUX FB_MUX_EN
#define ADR_REG_LMK_PLL1                0x140 //  PLL1_PD VCO_LDO_PD VCO_PD OSCin_PD SYSREF_GBL_PD SYSREF_PD SYSREF_DDLY_PD SYSREF_PLSR_PD
#define ADR_REG_LMK_DDLY_SYSREF_EN      0x141 //  DDLYd_SYSREF_EN DDLYd12_EN DDLYd10_EN DDLYd7_EN DDLYd6_EN DDLYd4_EN DDLYd2_EN DDLYd0_EN
#define ADR_REG_LMK_DDLY_STEP_CNT       0x142 //  0 0 0 DDLYd_STEP_CNT
#define ADR_REG_LMK_DDLY_CLR            0x143 //  SYSREF_DDLY_CLR SYNC_1SHOT_EN SYNC_POL SYNC_EN SYNC_PLL2_DLD SYNC_PLL1_DLD SYNC_MODE
#define ADR_REG_LMK_SYNC_DIS            0x144 //  SYNC_DISSYSREF SYNC_DIS12 SYNC_DIS10 SYNC_DIS8 SYNC_DIS6 SYNC_DIS4 SYNC_DIS2 SYNC_DIS0
#define ADR_REG_LMK_CONST0              0x145 //  0 1 1 1 1 1 1 1

#define ADR_REG_LMK_CLKIN               0x146 //  0 0 CLKin2_EN CLKin1_EN CLKin0_EN CLKin2_TYPE CLKin1_TYPE CLKin0_TYPE
#define ADR_REG_LMK_CLKIN_POL           0x147 //  CLKin_SEL_POL CLKin_SEL_MODE CLKin1_OUT_MUX CLKin0_OUT_MUX
#define ADR_REG_LMK_CLKIN_SEL0          0x148 //  0 0 CLKin_SEL0_MUX CLKin_SEL0_TYPE
#define ADR_REG_LMK_CLKIN_SEL1          0x149 //  0 SDIO_RDBK_TYPE CLKin_SEL1_MUX CLKin_SEL1_TYPE
#define ADR_REG_LMK_RESET_MUX           0x14A //  0 0 RESET_MUX RESET_TYPE
#define ADR_REG_LMK_LOS_TIMEOUT         0x14B //  LOS_TIMEOUT LOS_EN TRACK_EN HOLDOVER_FORCE MAN_DAC_EN MAN_DAC[9:8]

#define ADR_REG_LMK_MAN_DAC             0x14C //  MAN_DAC[7:0]
#define ADR_REG_LMK_DAC_TRIP_LOW        0x14D //  0 0 DAC_TRIP_LOW
#define ADR_REG_LMK_DAC_CLK             0x14E //  DAC_CLK_MULT DAC_TRIP_HIGH
#define ADR_REG_LMK_DAC_CLK_CNTR        0x14F //  DAC_CLK_CNTR
#define ADR_REG_LMK_OVERRIDE            0x150 //  0 CLKin_OVERRIDE 0 HOLDOVER_PLL1_DET HOLDOVER_LOS_DET HOLDOVER_VTUNE_DET HOLDOVER_HITLESS_SWITCH HOLDOVER_EN
#define ADR_REG_LMK_HOLD_DLD_CNT1       0x151 //  0 0 HOLDOVER_DLD_CNT[13:8]
#define ADR_REG_LMK_HOLD_DLD_CNT0       0x152 //  HOLDOVER_DLD_CNT[7:0]
#define ADR_REG_LMK_CLKIN0_R1           0x153 //  0 0 CLKin0_R[13:8]
#define ADR_REG_LMK_CLKIN0_R0           0x154 //  CLKin0_R[7:0]
#define ADR_REG_LMK_CLKIN1_R1           0x155 //  0 0 CLKin1_R[13:8]
#define ADR_REG_LMK_CLKIN1_R0           0x156 //  CLKin1_R[7:0]
#define ADR_REG_LMK_CLKIN2_R1           0x157 //  0 0 CLKin2_R[13:8]
#define ADR_REG_LMK_CLKIN2_R0           0x158 //  CLKin2_R[7:0]

#define ADR_REG_LMK_PLL1_N1             0x159 //  0 0 PLL1_N[13:8]
#define ADR_REG_LMK_PLL1_N0             0x15A //  PLL1_N[7:0]
#define ADR_REG_LMK_PLL1_MISC           0x15B //  PLL1_WND_SIZE PLL1_CP_TRI PLL1_CP_POL PLL1_CP_GAIN
#define ADR_REG_LMK_PLL1_DLD_CNT1       0x15C //  0 0 PLL1_DLD_CNT[13:8]
#define ADR_REG_LMK_PLL1_DLD_CNT0       0x15D //  PLL1_DLD_CNT[7:0]
#define ADR_REG_LMK_PLL1_DLYS           0x15E //  0 0 PLL1_R_DLY PLL1_N_DLY
#define ADR_REG_LMK_PLL1_LDS            0x15F //  PLL1_LD_MUX PLL1_LD_TYPE

#define ADR_REG_LMK_PLL2_R1             0x160 //  0 0 0 0 PLL2_R[11:8]
#define ADR_REG_LMK_PLL2_R0             0x161 //  PLL2_R[7:0]
#define ADR_REG_LMK_PLL2_P              0x162   //  PLL2_P OSCin_FREQ PLL2_XTAL_EN PLL2_REF_2X_EN
#define ADR_REG_LMK_PLL2_N_CAL2         0x163   //  0 0 0 0 0 0 PLL2_N_CAL[17:16]
#define ADR_REG_LMK_PLL2_N_CAL1         0x164   //  PLL2_N_CAL[15:8]
#define ADR_REG_LMK_PLL2_N_CAL0         0x165   //  PLL2_N_CAL[7:0]

#define ADR_REG_LMK_PLL2_FCAL           0x166   // PLL2_FCAL_DIS PLL2_N[17:16]
#define ADR_REG_LMK_PLL2_N1             0x167   // PLL2_N[15:8]
#define ADR_REG_LMK_PLL2_N0             0x168   // PLL2_N[7:0]
#define ADR_REG_LMK_PLL2_MISC           0x169   // 0 PLL2_WND_SIZE PLL2_CP_GAIN PLL2_CP_POL PLL2_CP_TRI 1
#define ADR_REG_LMK_PLL2_DLD_CNT1       0x16A   // 0 SYSREF_REQ_EN PLL2_DLD_CNT[15:8]
#define ADR_REG_LMK_PLL2_DLD_CNT0       0x16B   // PLL2_DLD_CNT[7:0]
#define ADR_REG_LMK_PLL2_LF_R           0x16C   // 0 0 PLL2_LF_R4 PLL2_LF_R3
#define ADR_REG_LMK_PLL2_LF_C           0x16D   // PLL2_LF_C4 PLL2_LF_C3
#define ADR_REG_LMK_PLL2_LD_MUX         0x16E   // PLL2_LD_MUX PLL2_LD_TYPE
#define ADR_REG_LMK_CONST1              0x171   // 1 0 1 0 1 0 1 0  (0xAA)
#define ADR_REG_LMK_CONST2              0x172   // 0 0 0 0 0 0 1 0  (0x02)
#define ADR_REG_LMK_PLL2_PRE_PD         0x173   // 0 PLL2_PRE_PD PLL2_PD 0 0 0 0 0
#define ADR_REG_LMK_VCO1_DIV            0x174   // 0 0 0 VCO1_DIV

#define ADR_REG_LMK_OPT_REG1            0x17C   // OPT_REG_1
#define ADR_REG_LMK_OPT_REG2            0x17D   // OPT_REG_2

#define ADR_REG_LMK_PLL1_LD_LOST        0x182   // 0 0 0 0 0 RB_PLL1_LD_LOST RB_PLL1_LD CLR_PLL1_LD_LOST
#define ADR_REG_LMK_PLL2_LD_LOST        0x183   // 0 0 0 0 0 RB_PLL2_LD_LOST RB_PLL2_LD CLR_PLL2_LD_LOST
#define ADR_REG_LMK_RB_DAC_VALUE1       0x184   // RB_DAC_VALUE[9:8] RB_CLKin2_SEL RB_CLKin1_SEL RB_CLKin0_SEL X RB_CLKin1_LOS RB_CLKin0_LOS
#define ADR_REG_LMK_RB_DAC_VALUE0       0x185   // RB_DAC_VALUE[7:0]
#define ADR_REG_LMK_RB_HOLDOVER         0x188   // 0 0 0 RB_HOLDOVER X X X X
#define ADR_REG_LMK_SPI_LOCK0           0x1FFD  // SPI_LOCK[23:16]
#define ADR_REG_LMK_SPI_LOCK1           0x1FFE  // SPI_LOCK[15:8]
#define ADR_REG_LMK_SPI_LOCK2           0x1FFF  // SPI_LOCK[7:0]



//--------------------------------------------------------------------------------------------------------------------------------------------
// Device constant defaults
//--------------------------------------------------------------------------------------------------------------------------------------------
#define ID_DEVICE_TYPE        6     // PLL
#define ID_PROD_MSB         208 
#define ID_PROD_LSB          91 
#define ID_MASKREV           32     // LMK04828
#define ID_VNDR_MSB          81     // [15:0] (2 regs)
#define ID_VNDR_LSB           4     // 

//--------------------------------------------------------------------------------------------------------------------------------------------
// Register defaults
//      Name               Default (MSB) Bit 7 Bit 6 Bit 5 Bit 4 Bit 3 Bit 2 Bit 1 Bit0 (LSB)
//--------------------------------------------------------------------------------------------------------------------------------------------
#define DEF_LMK_RESET               0               // 0x000
#define DEF_LMK_PWR_DOWN            0               // 0x002 //  0 0 0 0 0 0 0 POWER_DOWN
#define DEF_LMK_ID_DEVICE_TYPE      ID_DEVICE_TYPE  // 0x003 //  ID_DEVICE_TYPE
#define DEF_LMK_ID_PROD1            ID_PROD_MSB     // 0x004 //  ID_PROD[15:8]
#define DEF_LMK_ID_PROD0            ID_PROD_LSB     // 0x005 //  ID_PROD[7:0]
#define DEF_LMK_ID_MASKREV          ID_MASKREV      // 0x006 //  ID_MASKREV
#define DEF_LMK_ID_VNDR1            ID_VNDR_MSB     // 0x00C //  ID_VNDR[15:8]
#define DEF_LMK_ID_VNDR0            ID_VNDR_LSB     // 0x00D //  ID_VNDR[7:0]

#define DEF_LMK_CLK0_1_ODL          2       //  
#define DEF_LMK_CLK2_3_ODL          4       // 
#define DEF_LMK_CLK4_5_ODL          8       //
#define DEF_LMK_CLK6_7_ODL          8       //
#define DEF_LMK_CLK8_9_ODL          8       //
#define DEF_LMK_CLK10_11_ODL        8       //
#define DEF_LMK_CLK12_13_ODL        2       //

#define DEF_LMK_DCLK_DDLY           5*16 + 5  //  DCLKout12_DDLY_CNTH DCLKout12_DDLY_CNTL
#define DEF_LMK_DCLK_ADLY           0         //  
#define DEF_LMK_SDCLK               0         //  
#define DEF_LMK_SDCLK_ADLY          0         //  

#define DEF_LMK_SDCLK01_PD          0x79    // 0111 {1} 00 1
#define DEF_LMK_SDCLK23_PD          0x79    // 0111 {1} 00 1
#define DEF_LMK_SDCLK45_PD          0x71    // 0111 {0} 00 1
#define DEF_LMK_SDCLK67_PD          0x71    // 0111 {0} 00 1
#define DEF_LMK_SDCLK89_PD          0x71    // 0111 {0} 00 1
#define DEF_LMK_SDCLK1011_PD        0x71    // 0111 {0} 00 1
#define DEF_LMK_SDCLK1213_PD        0x79    // 0111 {1} 00 1

#define DEF_LMK_SDCLK01_POLFMT      0x00    // 0 000 0 {000}
#define DEF_LMK_SDCLK23_POLFMT      0x00    // 0 000 0 {000} 
#define DEF_LMK_SDCLK45_POLFMT      0x01    // 0 000 0 {001} 
#define DEF_LMK_SDCLK67_POLFMT      0x01    // 0 000 0 {001} 
#define DEF_LMK_SDCLK89_POLFMT      0x01    // 0 000 0 {001} 
#define DEF_LMK_SDCLK1011_POLFMT    0x01    // 0 000 0 {001} 
#define DEF_LMK_SDCLK1213_POLFMT    0x00    // 0 000 0 {000} 

// 0x138
#define DEF_LMK_OSC                     0x04    // LVPECL
#define DEF_LMK_SYSREFMUX               0x00    // src = sysref mux, normal sync
#define DEF_LMK_SYSREF_DIV1             0x0C    // [11:0] 12x16 = 0xC0
#define DEF_LMK_SYSREF_DIV0             0x00    //  
#define DEF_LMK_SYSREF_DDLY1            0x00      // [11:0] 
#define DEF_LMK_SYSREF_DDLY0            0x08      //  
#define DEF_LMK_SYSREF_PCNT             0x03      // [1:0] 3 = 8 pulses

#define DEF_LMK_NCLK                    0x00    // 0x13F //  0 0 0 PLL2_NCLK_MUX PLL1_NCLK_MUX FB_MUX FB_MUX_EN
#define DEF_LMK_PLL1                    0x07    // 0x140 //  PLL1_PD VCO_LDO_PD VCO_PD OSCin_PD SYSREF_GBL_PD SYSREF_PD SYSREF_DDLY_PD SYSREF_PLSR_PD
#define DEF_LMK_DDLY_SYSREF_EN          0x00    // 0x141 //  DDLYd_SYSREF_EN DDLYd12_EN DDLYd10_EN DDLYd7_EN DDLYd6_EN DDLYd4_EN DDLYd2_EN DDLYd0_EN
#define DEF_LMK_DDLY_STEP_CNT           0x00    // 0x142 //  0 0 0 DDLYd_STEP_CNT
#define DEF_LMK_DDLY_CLR                0x91    // 0x143 //  SYSREF_DDLY_CLR SYNC_1SHOT_EN SYNC_POL SYNC_EN SYNC_PLL2_DLD SYNC_PLL1_DLD SYNC_MODE
#define DEF_LMK_SYNC_DIS                0x00    // 0x144 //  SYNC_DISSYSREF SYNC_DIS12 SYNC_DIS10 SYNC_DIS8 SYNC_DIS6 SYNC_DIS4 SYNC_DIS2 SYNC_DIS0
#define DEF_LMK_CONST0                  0x3F    // 0x145 //  0 1 1 1 1 1 1 1
#define DEF_LMK_CLKIN                   0x18    // 0x146 //  0 0 CLKin2_EN CLKin1_EN CLKin0_EN CLKin2_TYPE CLKin1_TYPE CLKin0_TYPE
#define DEF_LMK_CLKIN_POL               0x3A    // 0x147 //  CLKin_SEL_POL CLKin_SEL_MODE CLKin1_OUT_MUX CLKin0_OUT_MUX
#define DEF_LMK_CLKIN_SEL0              0x02    // 0x148 //  0 0 CLKin_SEL0_MUX CLKin_SEL0_TYPE
#define DEF_LMK_CLKIN_SEL1              0x42    // 0x149 //  0 SDIO_RDBK_TYPE CLKin_SEL1_MUX CLKin_SEL1_TYPE
#define DEF_LMK_RESET_MUX               0x02    // 0x14A //  0 0 RESET_MUX RESET_TYPE
#define DEF_LMK_LOS_TIMEOUT             0x16    // 0x14B //  LOS_TIMEOUT LOS_EN TRACK_EN HOLDOVER_FORCE MAN_DAC_EN MAN_DAC[9:8]
#define DEF_LMK_MAN_DAC                 0x00    // 0x14C //  MAN_DAC[7:0]
#define DEF_LMK_DAC_TRIP_LOW            0x00    // 0x14D //  0 0 DAC_TRIP_LOW
#define DEF_LMK_DAC_CLK                 0x00    // 0x14E //  DAC_CLK_MULT DAC_TRIP_HIGH
#define DEF_LMK_DAC_CLK_CNTR            0x3F    // 0x14F //  DAC_CLK_CNTR
#define DEF_LMK_OVERRIDE                0x03    // 0x150 //  0 CLKin_OVERRIDE 0 HOLDOVER_PLL1_DET HOLDOVER_LOS_DET HOLDOVER_VTUNE_DET HOLDOVER_HITLESS_SWITCH HOLDOVER_EN
#define DEF_LMK_HOLD_DLD_CNT1           0x02    // 0x151 //  0 0 HOLDOVER_DLD_CNT[13:8]
#define DEF_LMK_HOLD_DLD_CNT0           0x00    // 0x152 //  HOLDOVER_DLD_CNT[7:0]
#define DEF_LMK_CLKIN0_R1               0x00    // 0x153 //  0 0 CLKin0_R[13:8]
#define DEF_LMK_CLKIN0_R0               0x78    // 0x154 //  CLKin0_R[7:0]
#define DEF_LMK_CLKIN1_R1               0x00    // 0x155 //  0 0 CLKin1_R[13:8]
#define DEF_LMK_CLKIN1_R0               0x96    // 0x156 //  CLKin1_R[7:0]
#define DEF_LMK_CLKIN2_R1               0x00    // 0x157 //  0 0 CLKin2_R[13:8]
#define DEF_LMK_CLKIN2_R0               0x96    // 0x158 //  CLKin2_R[7:0]
#define DEF_LMK_PLL1_N1                 0x00    // 0x159 //  0 0 PLL1_N[13:8]
#define DEF_LMK_PLL1_N0                 0x78    // 0x15A //  PLL1_N[7:0]
#define DEF_LMK_PLL1_MISC               0xDC    // 0x15B //  PLL1_WND_SIZE PLL1_CP_TRI PLL1_CP_POL PLL1_CP_GAIN
#define DEF_LMK_PLL1_DLD_CNT1           0x20    // 0x15C //  0 0 PLL1_DLD_CNT[13:8]
#define DEF_LMK_PLL1_DLD_CNT0           0x00    // 0x15D //  PLL1_DLD_CNT[7:0]
#define DEF_LMK_PLL1_DLYS               0x00    // 0x15E //  0 0 PLL1_R_DLY PLL1_N_DLY
#define DEF_LMK_PLL1_LDS                0x0E    // 0x15F //  PLL1_LD_MUX PLL1_LD_TYPE
#define DEF_LMK_PLL2_R1                 0x00    // 0x160 //  0 0 0 0 PLL2_R[11:8]
#define DEF_LMK_PLL2_R0                 0x02    // 0x161 //  PLL2_R[7:0]
#define DEF_LMK_PLL2_P                  0x5D    // 0x162   // 010-111-0-1  PLL2_P OSCin_FREQ PLL2_XTAL_EN PLL2_REF_2X_EN
#define DEF_LMK_PLL2_N_CAL2             0x00    // 0x163   //  0 0 0 0 0 0 PLL2_N_CAL[17:16]
#define DEF_LMK_PLL2_N_CAL1             0x00    // 0x164   //  PLL2_N_CAL[15:8]
#define DEF_LMK_PLL2_N_CAL0             0x0C    // 0x165   //  PLL2_N_CAL[7:0]

// reg 0x166
#define DEF_LMK_PLL2_FCAL               0x00  // 0x166  // PLL2_FCAL_DIS PLL2_N[17:16]
#define DEF_LMK_PLL2_N1                 0x00  // 0x167  // PLL2_N[15:8]
#define DEF_LMK_PLL2_N0                 0x0C  // 0x168  // PLL2_N[7:0]
#define DEF_LMK_PLL2_MISC               0x59  // 0x169  // 0 PLL2_WND_SIZE PLL2_CP_GAIN PLL2_CP_POL PLL2_CP_TRI 1
                                              //           0-10-11-0-0-1 = 0x59
#define DEF_LMK_PLL2_DLD_CNT1           0x20  // 0x16A  // SYSREF_REQ_EN PLL2_DLD_CNT[15:8]
#define DEF_LMK_PLL2_DLD_CNT0           0x00  // 0x16B  // PLL2_DLD_CNT[7:0]
#define DEF_LMK_PLL2_LF_R               0x00  // 0x16C  // 0 0 PLL2_LF_R4 PLL2_LF_R3
#define DEF_LMK_PLL2_LF_C               0x00  // 0x16D  // PLL2_LF_C4 PLL2_LF_C3
#define DEF_LMK_PLL2_LD_MUX             0x16  // 0x16E  // PLL2_LD_MUX PLL2_LD_TYPE 2,6 -> 00010_110
#define DEF_LMK_CONST1                  0x0A  // 0x171  // 1 0 1 0 1 0 1 0  (program to 0xAA)
#define DEF_LMK_CONST2                  0x00  // 0x172  // 0 0 0 0 0 0 1 0  (program to 0x02)
#define DEF_LMK_PLL2_PRE_PD             0x00  // 0x173  // 0 PLL2_PRE_PD PLL2_PD 0 0 0 0 0
#define DEF_LMK_VCO1_DIV                0x00  // 0x174  // 0 0 0 VCO1_DIV
#define DEF_LMK_OPT_REG1                0x15  // 0x17C  // OPT_REG_1  value for LMK04828 = 21
#define DEF_LMK_OPT_REG2                0x33  // 0x17D  // OPT_REG_2  value for LMK04828 = 51
#define DEF_LMK_PLL1_LD_LOST            0x00  // 0x182  // 0 0 0 0 0 RB_PLL1_LD_LOST RB_PLL1_LD CLR_PLL1_LD_LOST
#define DEF_LMK_PLL2_LD_LOST            0x00  // 0x183  // 0 0 0 0 0 RB_PLL2_LD_LOST RB_PLL2_LD CLR_PLL2_LD_LOST
#define DEF_LMK_RB_DAC_VALUE1           0x02  // 0x184  // RB_DAC_VALUE[9:8] RB_CLKin2_SEL RB_CLKin1_SEL RB_CLKin0_SEL X RB_CLKin1_LOS RB_CLKin0_LOS
#define DEF_LMK_RB_DAC_VALUE0           0x00  // 0x185  // RB_DAC_VALUE[7:0]
#define DEF_LMK_RB_HOLDOVER             0x00  // 0x188  // 0 0 0 RB_HOLDOVER X X X X
#define DEF_LMK_SPI_LOCK0               0x00  // 0x1FFD // SPI_LOCK[23:16]
#define DEF_LMK_SPI_LOCK1               0x00  // 0x1FFE // SPI_LOCK[15:8]
#define DEF_LMK_SPI_LOCK2               0x83  // 0x1FFF // SPI_LOCK[7:0]



//--------------------------------------------------------------------------------------------------------------------------------------------
// Array of all register addresses (125 values)
//--------------------------------------------------------------------------------------------------------------------------------------------
#define NUM_REGS_LMK04828 	126
int arr_reg_addr_clk [NUM_REGS_LMK04828] = {
 ADR_REG_LMK_RESET             ,  //  0x000 
 ADR_REG_LMK_PWR_DOWN          ,  //  0x002 
 ADR_REG_LMK_ID_DEVICE_TYPE    ,  //  0x003 
 ADR_REG_LMK_ID_PROD1          ,  //  0x004 
 ADR_REG_LMK_ID_PROD0          ,  //  0x005 
 ADR_REG_LMK_ID_MASKREV        ,  //  0x006 
 ADR_REG_LMK_ID_VNDR1          ,  //  0x00C 
 ADR_REG_LMK_ID_VNDR0          ,  //  0x00D 
 ADR_REG_LMK_CLK0_1_ODL        ,  //  0x100 
 ADR_REG_LMK_DCLK0_DDLY        ,  //  0x101 
 ADR_REG_LMK_DCLK0_ADLY        ,  //  0x103 
 ADR_REG_LMK_SDCLK1            ,  //  0x104 
 ADR_REG_LMK_SDCLK1_ADLY       ,  //  0x105 
 ADR_REG_LMK_SDCLK01_PD        ,  //  0x106 
 ADR_REG_LMK_SDCLK01_POLFMT    ,  //  0x107 
 ADR_REG_LMK_CLK2_3_ODL        ,  //  0x108 
 ADR_REG_LMK_DCLK2_DDLY        ,  //  0x109 
 ADR_REG_LMK_DCLK2_ADLY        ,  //  0x10B 
 ADR_REG_LMK_SDCLK3            ,  //  0x10C 
 ADR_REG_LMK_SDCLK3_ADLY       ,  //  0x10D 
 ADR_REG_LMK_SDCLK23_PD        ,  //  0x10E 
 ADR_REG_LMK_SDCLK23_POLFMT    ,  //  0x10F 
 ADR_REG_LMK_CLK4_5_ODL        ,  //  0x110 
 ADR_REG_LMK_DCLK4_DDLY        ,  //  0x111 
 ADR_REG_LMK_DCLK4_ADLY        ,  //  0x113 
 ADR_REG_LMK_SDCLK5            ,  //  0x114 
 ADR_REG_LMK_SDCLK5_ADLY       ,  //  0x115 
 ADR_REG_LMK_SDCLK45_PD        ,  //  0x116 
 ADR_REG_LMK_SDCLK45_POLFMT    ,  //  0x117 
 ADR_REG_LMK_CLK6_7_ODL        ,  //  0x118 
 ADR_REG_LMK_DCLK6_DDLY        ,  //  0x119 
 ADR_REG_LMK_DCLK6_ADLY        ,  //  0x11B 
 ADR_REG_LMK_SDCLK7            ,  //  0x11C 
 ADR_REG_LMK_SDCLK7_ADLY       ,  //  0x11D 
 ADR_REG_LMK_SDCLK67_PD        ,  //  0x11E 
 ADR_REG_LMK_SDCLK67_POLFMT    ,  //  0x11F 
 ADR_REG_LMK_CLK8_9_ODL        ,  //  0x120 
 ADR_REG_LMK_DCLK8_DDLY        ,  //  0x121 
 ADR_REG_LMK_DCLK8_ADLY        ,  //  0x123 
 ADR_REG_LMK_SDCLK9            ,  //  0x124 
 ADR_REG_LMK_SDCLK9_ADLY       ,  //  0x125 
 ADR_REG_LMK_SDCLK89_PD        ,  //  0x126 
 ADR_REG_LMK_SDCLK89_POLFMT    ,  //  0x127 
 ADR_REG_LMK_CLK10_11_ODL      ,  //  0x128 
 ADR_REG_LMK_DCLK10_DDLY       ,  //  0x129 
 ADR_REG_LMK_DCLK10_ADLY       ,  //  0x12B 
 ADR_REG_LMK_SDCLK11           ,  //  0x12C 
 ADR_REG_LMK_SDCLK11_ADLY      ,  //  0x12D 
 ADR_REG_LMK_SDCLK1011_PD      ,  //  0x12E 
 ADR_REG_LMK_SDCLK1011_POLFMT  ,  //  0x12F 
 ADR_REG_LMK_CLK12_13_ODL      ,  //  0x130 
 ADR_REG_LMK_DCLK12_DDLY       ,  //  0x131 
 ADR_REG_LMK_DCLK12_ADLY       ,  //  0x133 
 ADR_REG_LMK_SDCLK13           ,  //  0x134 
 ADR_REG_LMK_SDCLK13_ADLY      ,  //  0x135 
 ADR_REG_LMK_SDCLK1213_PD      ,  //  0x136 
 ADR_REG_LMK_SDCLK1213_POLFMT  ,  //  0x137 
 ADR_REG_LMK_OSC               ,  //  0x138 
 ADR_REG_LMK_SYSREFMUX         ,  //  0x139 
 ADR_REG_LMK_SYSREF_DIV1       ,  //  0x13A 
 ADR_REG_LMK_SYSREF_DIV0       ,  //  0x13B 
 ADR_REG_LMK_SYSREF_DDLY1      ,  //  0x13C 
 ADR_REG_LMK_SYSREF_DDLY0      ,  //  0x13D 
 ADR_REG_LMK_SYSREF_PCNT       ,  //  0x13E 
 ADR_REG_LMK_NCLK              ,  //  0x13F 
 ADR_REG_LMK_PLL1              ,  //  0x140 
 ADR_REG_LMK_DDLY_SYSREF_EN    ,  //  0x141 
 ADR_REG_LMK_DDLY_STEP_CNT     ,  //  0x142 
 ADR_REG_LMK_DDLY_CLR          ,  //  0x143 
 ADR_REG_LMK_SYNC_DIS          ,  //  0x144 
 ADR_REG_LMK_CONST0            ,  //  0x145 
 ADR_REG_LMK_CLKIN             ,  //  0x146 
 ADR_REG_LMK_CLKIN_POL         ,  //  0x147 
 ADR_REG_LMK_CLKIN_SEL0        ,  //  0x148 
 ADR_REG_LMK_CLKIN_SEL1        ,  //  0x149 
 ADR_REG_LMK_RESET_MUX         ,  //  0x14A 
 ADR_REG_LMK_LOS_TIMEOUT       ,  //  0x14B 
 ADR_REG_LMK_MAN_DAC           ,  //  0x14C 
 ADR_REG_LMK_DAC_TRIP_LOW      ,  //  0x14D 
 ADR_REG_LMK_DAC_CLK           ,  //  0x14E 
 ADR_REG_LMK_DAC_CLK_CNTR      ,  //  0x14F 
 ADR_REG_LMK_OVERRIDE          ,  //  0x150 
 ADR_REG_LMK_HOLD_DLD_CNT1     ,  //  0x151 
 ADR_REG_LMK_HOLD_DLD_CNT0     ,  //  0x152 
 ADR_REG_LMK_CLKIN0_R1         ,  //  0x153 
 ADR_REG_LMK_CLKIN0_R0         ,  //  0x154 
 ADR_REG_LMK_CLKIN1_R1         ,  //  0x155 
 ADR_REG_LMK_CLKIN1_R0         ,  //  0x156 
 ADR_REG_LMK_CLKIN2_R1         ,  //  0x157 
 ADR_REG_LMK_CLKIN2_R0         ,  //  0x158 
 ADR_REG_LMK_PLL1_N1           ,  //  0x159 
 ADR_REG_LMK_PLL1_N0           ,  //  0x15A 
 ADR_REG_LMK_PLL1_MISC         ,  //  0x15B 
 ADR_REG_LMK_PLL1_DLD_CNT1     ,  //  0x15C 
 ADR_REG_LMK_PLL1_DLD_CNT0     ,  //  0x15D 
 ADR_REG_LMK_PLL1_DLYS         ,  //  0x15E 
 ADR_REG_LMK_PLL1_LDS          ,  //  0x15F 
 ADR_REG_LMK_PLL2_R1           ,  //  0x160 
 ADR_REG_LMK_PLL2_R0           ,  //  0x161 
 ADR_REG_LMK_PLL2_P            ,  //  0x162 
 ADR_REG_LMK_PLL2_N_CAL2       ,  //  0x163 
 ADR_REG_LMK_PLL2_N_CAL1       ,  //  0x164 
 ADR_REG_LMK_PLL2_N_CAL0       ,  //  0x165 
 ADR_REG_LMK_PLL2_FCAL         ,  //  0x166 
 ADR_REG_LMK_PLL2_N1           ,  //  0x167 
 ADR_REG_LMK_PLL2_N0           ,  //  0x168 
 ADR_REG_LMK_PLL2_MISC         ,  //  0x169 
 ADR_REG_LMK_PLL2_DLD_CNT1     ,  //  0x16A 
 ADR_REG_LMK_PLL2_DLD_CNT0     ,  //  0x16B 
 ADR_REG_LMK_PLL2_LF_R         ,  //  0x16C 
 ADR_REG_LMK_PLL2_LF_C         ,  //  0x16D 
 ADR_REG_LMK_PLL2_LD_MUX       ,  //  0x16E 
 ADR_REG_LMK_CONST1            ,  //  0x171 
 ADR_REG_LMK_CONST2            ,  //  0x172 
 ADR_REG_LMK_PLL2_PRE_PD       ,  //  0x173 
 ADR_REG_LMK_VCO1_DIV          ,  //  0x174 
 ADR_REG_LMK_OPT_REG1          ,  //  0x17C 
 ADR_REG_LMK_OPT_REG2          ,  //  0x17D 
 ADR_REG_LMK_PLL1_LD_LOST      ,  //  0x182 
 ADR_REG_LMK_PLL2_LD_LOST      ,  //  0x183 
 ADR_REG_LMK_RB_DAC_VALUE1     ,  //  0x184 
 ADR_REG_LMK_RB_DAC_VALUE0     ,  //  0x185 
 ADR_REG_LMK_RB_HOLDOVER       ,  //  0x188 
 ADR_REG_LMK_SPI_LOCK0         ,  //  0x1FFD
 ADR_REG_LMK_SPI_LOCK1         ,  //  0x1FFE
 ADR_REG_LMK_SPI_LOCK2            //  0x1FFF
};


//--------------------------------------------------------------------------------------------------------------------------------------------
// Array of all register default values (125 values)
//--------------------------------------------------------------------------------------------------------------------------------------------
int arr_reg_default_clk [NUM_REGS_LMK04828] = {
 DEF_LMK_RESET                  ,   // 0x000 
 DEF_LMK_PWR_DOWN               ,   // 0               // 0x002 //  0 0 0 0 0 0 0 POWER_DOWN
 DEF_LMK_ID_DEVICE_TYPE         ,   // ID_DEVICE_TYPE  // 0x003 //  ID_DEVICE_TYPE
 DEF_LMK_ID_PROD1               ,   // ID_PROD_MSB     // 0x004 //  ID_PROD[15:8]
 DEF_LMK_ID_PROD0               ,   // ID_PROD_LSB     // 0x005 //  ID_PROD[7:0]
 DEF_LMK_ID_MASKREV             ,   // ID_MASKREV      // 0x006 //  ID_MASKREV
 DEF_LMK_ID_VNDR1               ,   // ID_VNDR_MSB     // 0x00C //  ID_VNDR[15:8]
 DEF_LMK_ID_VNDR0               ,   // ID_VNDR_LSB     // 0x00D //  ID_VNDR[7:0]
 DEF_LMK_CLK0_1_ODL             ,   // 2       //  
 DEF_LMK_DCLK_DDLY              ,   // 5*16 + 5  //  DCLKout12_DDLY_CNTH DCLKout12_DDLY_CNTL
 DEF_LMK_DCLK_ADLY              ,   // 0         //  
 DEF_LMK_SDCLK                  ,   // 0         //  
 DEF_LMK_SDCLK_ADLY             ,   // 0         //  
 DEF_LMK_SDCLK01_PD             ,   // 0x79    // 0111 {1} 00 1
 DEF_LMK_SDCLK01_POLFMT         ,   // 0x00    // 0 000 0 {000}
 DEF_LMK_CLK2_3_ODL             ,   // 4       // 
 DEF_LMK_DCLK_DDLY              ,   // 5*16 + 5  //  DCLKout12_DDLY_CNTH DCLKout12_DDLY_CNTL
 DEF_LMK_DCLK_ADLY              ,   // 0         //  
 DEF_LMK_SDCLK                  ,   // 0         //  
 DEF_LMK_SDCLK_ADLY             ,   // 0         //  
 DEF_LMK_SDCLK23_PD             ,   // 0x79    // 0111 {1} 00 1
 DEF_LMK_SDCLK23_POLFMT         ,   // 0x00    // 0 000 0 {000} 
 DEF_LMK_CLK4_5_ODL             ,   // 8       //
 DEF_LMK_DCLK_DDLY              ,   // 5*16 + 5  //  DCLKout12_DDLY_CNTH DCLKout12_DDLY_CNTL
 DEF_LMK_DCLK_ADLY              ,   // 0         //  
 DEF_LMK_SDCLK                  ,   // 0         //  
 DEF_LMK_SDCLK_ADLY             ,   // 0         //  
 DEF_LMK_SDCLK45_PD             ,   // 0x71    // 0111 {0} 00 1
 DEF_LMK_SDCLK45_POLFMT         ,   // 0x01    // 0 000 0 {001} 
 DEF_LMK_CLK6_7_ODL             ,   // 8       //
 DEF_LMK_DCLK_DDLY              ,   // 5*16 + 5  //  DCLKout12_DDLY_CNTH DCLKout12_DDLY_CNTL
 DEF_LMK_DCLK_ADLY              ,   // 0         //  
 DEF_LMK_SDCLK                  ,   // 0         //  
 DEF_LMK_SDCLK_ADLY             ,   // 0         //  
 DEF_LMK_SDCLK67_PD             ,   // 0x71    // 0111 {0} 00 1
 DEF_LMK_SDCLK67_POLFMT         ,   // 0x01    // 0 000 0 {001} 
 DEF_LMK_CLK8_9_ODL             ,   // 8       //
 DEF_LMK_DCLK_DDLY              ,   // 5*16 + 5  //  DCLKout12_DDLY_CNTH DCLKout12_DDLY_CNTL
 DEF_LMK_DCLK_ADLY              ,   // 0         //  
 DEF_LMK_SDCLK                  ,   // 0         //  
 DEF_LMK_SDCLK_ADLY             ,   // 0         //  
 DEF_LMK_SDCLK89_PD             ,   // 0x71    // 0111 {0} 00 1
 DEF_LMK_SDCLK89_POLFMT         ,   // 0x01    // 0 000 0 {001} 
 DEF_LMK_CLK10_11_ODL           ,   // 8       //
 DEF_LMK_DCLK_DDLY              ,   // 5*16 + 5  //  DCLKout12_DDLY_CNTH DCLKout12_DDLY_CNTL
 DEF_LMK_DCLK_ADLY              ,   // 0         //  
 DEF_LMK_SDCLK                  ,   // 0         //  
 DEF_LMK_SDCLK_ADLY             ,   // 0         //  
 DEF_LMK_SDCLK1011_PD           ,   // 0x71    // 0111 {0} 00 1
 DEF_LMK_SDCLK1011_POLFMT       ,   // 0x01    // 0 000 0 {001} 
 DEF_LMK_CLK12_13_ODL           ,   // 2       //
 DEF_LMK_DCLK_DDLY              ,   // 5*16 + 5  //  DCLKout12_DDLY_CNTH DCLKout12_DDLY_CNTL
 DEF_LMK_DCLK_ADLY              ,   // 0         //  
 DEF_LMK_SDCLK                  ,   // 0         //  
 DEF_LMK_SDCLK_ADLY             ,   // 0         //  
 DEF_LMK_SDCLK1213_PD           ,   // 0x79    // 0111 {1} 00 1
 DEF_LMK_SDCLK1213_POLFMT       ,   // 0x00    // 0 000 0 {000} 
 DEF_LMK_OSC                    ,   // 0x04    // LVPECL
 DEF_LMK_SYSREFMUX              ,   // 0x00    // src = sysref mux, normal sync
 DEF_LMK_SYSREF_DIV1            ,   // 0x0C    // [11:0] 12x16 = 0xC0
 DEF_LMK_SYSREF_DIV0            ,   // 0x00    //  
 DEF_LMK_SYSREF_DDLY1           ,   // 0x00    // [11:0] 
 DEF_LMK_SYSREF_DDLY0           ,   // 0x08    //  
 DEF_LMK_SYSREF_PCNT            ,   // 0x03    // [1:0] 3 = 8 pulses
 DEF_LMK_NCLK                   ,   // 0x00    // 0x13F //  0 0 0 PLL2_NCLK_MUX PLL1_NCLK_MUX FB_MUX FB_MUX_EN
 DEF_LMK_PLL1                   ,   // 0x07    // 0x140 //  PLL1_PD VCO_LDO_PD VCO_PD OSCin_PD SYSREF_GBL_PD SYSREF_PD SYSREF_DDLY_PD SYSREF_PLSR_PD
 DEF_LMK_DDLY_SYSREF_EN         ,   // 0x00    // 0x141 //  DDLYd_SYSREF_EN DDLYd12_EN DDLYd10_EN DDLYd7_EN DDLYd6_EN DDLYd4_EN DDLYd2_EN DDLYd0_EN
 DEF_LMK_DDLY_STEP_CNT          ,   // 0x00    // 0x142 //  0 0 0 DDLYd_STEP_CNT
 DEF_LMK_DDLY_CLR               ,   // 0x91    // 0x143 //  SYSREF_DDLY_CLR SYNC_1SHOT_EN SYNC_POL SYNC_EN SYNC_PLL2_DLD SYNC_PLL1_DLD SYNC_MODE
 DEF_LMK_SYNC_DIS               ,   // 0x00    // 0x144 //  SYNC_DISSYSREF SYNC_DIS12 SYNC_DIS10 SYNC_DIS8 SYNC_DIS6 SYNC_DIS4 SYNC_DIS2 SYNC_DIS0
 DEF_LMK_CONST0                 ,   // 0x3F    // 0x145 //  0 1 1 1 1 1 1 1
 DEF_LMK_CLKIN                  ,   // 0x18    // 0x146 //  0 0 CLKin2_EN CLKin1_EN CLKin0_EN CLKin2_TYPE CLKin1_TYPE CLKin0_TYPE
 DEF_LMK_CLKIN_POL              ,   // 0x3A    // 0x147 //  CLKin_SEL_POL CLKin_SEL_MODE CLKin1_OUT_MUX CLKin0_OUT_MUX
 DEF_LMK_CLKIN_SEL0             ,   // 0x02    // 0x148 //  0 0 CLKin_SEL0_MUX CLKin_SEL0_TYPE
 DEF_LMK_CLKIN_SEL1             ,   // 0x42    // 0x149 //  0 SDIO_RDBK_TYPE CLKin_SEL1_MUX CLKin_SEL1_TYPE
 DEF_LMK_RESET_MUX              ,   // 0x02    // 0x14A //  0 0 RESET_MUX RESET_TYPE
 DEF_LMK_LOS_TIMEOUT            ,   // 0x16    // 0x14B //  LOS_TIMEOUT LOS_EN TRACK_EN HOLDOVER_FORCE MAN_DAC_EN MAN_DAC[9:8]
 DEF_LMK_MAN_DAC                ,   // 0x00    // 0x14C //  MAN_DAC[7:0]
 DEF_LMK_DAC_TRIP_LOW           ,   // 0x00    // 0x14D //  0 0 DAC_TRIP_LOW
 DEF_LMK_DAC_CLK                ,   // 0x00    // 0x14E //  DAC_CLK_MULT DAC_TRIP_HIGH
 DEF_LMK_DAC_CLK_CNTR           ,   // 0x3F    // 0x14F //  DAC_CLK_CNTR
 DEF_LMK_OVERRIDE               ,   // 0x03    // 0x150 //  0 CLKin_OVERRIDE 0 HOLDOVER_PLL1_DET HOLDOVER_LOS_DET HOLDOVER_VTUNE_DET HOLDOVER_HITLESS_SWITCH HOLDOVER_EN
 DEF_LMK_HOLD_DLD_CNT1          ,   // 0x02    // 0x151 //  0 0 HOLDOVER_DLD_CNT[13:8]
 DEF_LMK_HOLD_DLD_CNT0          ,   // 0x00    // 0x152 //  HOLDOVER_DLD_CNT[7:0]
 DEF_LMK_CLKIN0_R1              ,   // 0x00    // 0x153 //  0 0 CLKin0_R[13:8]
 DEF_LMK_CLKIN0_R0              ,   // 0x78    // 0x154 //  CLKin0_R[7:0]
 DEF_LMK_CLKIN1_R1              ,   // 0x00    // 0x155 //  0 0 CLKin1_R[13:8]
 DEF_LMK_CLKIN1_R0              ,   // 0x96    // 0x156 //  CLKin1_R[7:0]
 DEF_LMK_CLKIN2_R1              ,   // 0x00    // 0x157 //  0 0 CLKin2_R[13:8]
 DEF_LMK_CLKIN2_R0              ,   // 0x96    // 0x158 //  CLKin2_R[7:0]
 DEF_LMK_PLL1_N1                ,   // 0x00    // 0x159 //  0 0 PLL1_N[13:8]
 DEF_LMK_PLL1_N0                ,   // 0x78    // 0x15A //  PLL1_N[7:0]
 DEF_LMK_PLL1_MISC              ,   // 0xDC    // 0x15B //  PLL1_WND_SIZE PLL1_CP_TRI PLL1_CP_POL PLL1_CP_GAIN
 DEF_LMK_PLL1_DLD_CNT1          ,   // 0x20    // 0x15C //  0 0 PLL1_DLD_CNT[13:8]
 DEF_LMK_PLL1_DLD_CNT0          ,   // 0x00    // 0x15D //  PLL1_DLD_CNT[7:0]
 DEF_LMK_PLL1_DLYS              ,   // 0x00    // 0x15E //  0 0 PLL1_R_DLY PLL1_N_DLY
 DEF_LMK_PLL1_LDS               ,   // 0x0E    // 0x15F //  PLL1_LD_MUX PLL1_LD_TYPE
 DEF_LMK_PLL2_R1                ,   // 0x00    // 0x160 //  0 0 0 0 PLL2_R[11:8]
 DEF_LMK_PLL2_R0                ,   // 0x02    // 0x161 //  PLL2_R[7:0]
 DEF_LMK_PLL2_P                 ,   // 0x5D    // 0x162   // 010-111-0-1  PLL2_P OSCin_FREQ PLL2_XTAL_EN PLL2_REF_2X_EN
 DEF_LMK_PLL2_N_CAL2            ,   // 0x00    // 0x163   //  0 0 0 0 0 0 PLL2_N_CAL[17:16]
 DEF_LMK_PLL2_N_CAL1            ,   // 0x00    // 0x164   //  PLL2_N_CAL[15:8]
 DEF_LMK_PLL2_N_CAL0            ,   // 0x0C    // 0x165   //  PLL2_N_CAL[7:0]
 DEF_LMK_PLL2_FCAL              ,   // 0x00  // 0x166  // PLL2_FCAL_DIS PLL2_N[17:16]
 DEF_LMK_PLL2_N1                ,   // 0x00  // 0x167  // PLL2_N[15:8]
 DEF_LMK_PLL2_N0                ,   // 0x0C  // 0x168  // PLL2_N[7:0]
 DEF_LMK_PLL2_MISC              ,   // 0x59  // 0x169  // 0 PLL2_WND_SIZE PLL2_CP_GAIN PLL2_CP_POL PLL2_CP_TRI 1
 DEF_LMK_PLL2_DLD_CNT1          ,   // 0x20  // 0x16A  // SYSREF_REQ_EN PLL2_DLD_CNT[15:8]
 DEF_LMK_PLL2_DLD_CNT0          ,   // 0x00  // 0x16B  // PLL2_DLD_CNT[7:0]
 DEF_LMK_PLL2_LF_R              ,   // 0x00  // 0x16C  // 0 0 PLL2_LF_R4 PLL2_LF_R3
 DEF_LMK_PLL2_LF_C              ,   // 0x00  // 0x16D  // PLL2_LF_C4 PLL2_LF_C3
 DEF_LMK_PLL2_LD_MUX            ,   // 0x16  // 0x16E  // PLL2_LD_MUX PLL2_LD_TYPE 2,6 -> 00010_110
 DEF_LMK_CONST1                 ,   // 0x0A  // 0x171  // 1 0 1 0 1 0 1 0  (program to 0xAA)
 DEF_LMK_CONST2                 ,   // 0x00  // 0x172  // 0 0 0 0 0 0 1 0  (program to 0x02)
 DEF_LMK_PLL2_PRE_PD            ,   // 0x00  // 0x173  // 0 PLL2_PRE_PD PLL2_PD 0 0 0 0 0
 DEF_LMK_VCO1_DIV               ,   // 0x00  // 0x174  // 0 0 0 VCO1_DIV
 DEF_LMK_OPT_REG1               ,   // 0x15  // 0x17C  // OPT_REG_1  value for LMK04828 = 21
 DEF_LMK_OPT_REG2               ,   // 0x33  // 0x17D  // OPT_REG_2  value for LMK04828 = 51
 DEF_LMK_PLL1_LD_LOST           ,   // 0x00  // 0x182  // 0 0 0 0 0 RB_PLL1_LD_LOST RB_PLL1_LD CLR_PLL1_LD_LOST
 DEF_LMK_PLL2_LD_LOST           ,   // 0x00  // 0x183  // 0 0 0 0 0 RB_PLL2_LD_LOST RB_PLL2_LD CLR_PLL2_LD_LOST
 DEF_LMK_RB_DAC_VALUE1          ,   // 0x02  // 0x184  // RB_DAC_VALUE[9:8] RB_CLKin2_SEL RB_CLKin1_SEL RB_CLKin0_SEL X RB_CLKin1_LOS RB_CLKin0_LOS
 DEF_LMK_RB_DAC_VALUE0          ,   // 0x00  // 0x185  // RB_DAC_VALUE[7:0]
 DEF_LMK_RB_HOLDOVER            ,   // 0x00  // 0x188  // 0 0 0 RB_HOLDOVER X X X X
 DEF_LMK_SPI_LOCK0              ,   // 0x00  // 0x1FFD // SPI_LOCK[23:16]
 DEF_LMK_SPI_LOCK1              ,   // 0x00  // 0x1FFE // SPI_LOCK[15:8]
 DEF_LMK_SPI_LOCK2                  // 0x83  // 0x1FFF // SPI_LOCK[7:0]
};

