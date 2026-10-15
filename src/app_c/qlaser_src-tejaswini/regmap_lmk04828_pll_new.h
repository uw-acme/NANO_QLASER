//--------------------------------------------------------------------------------------------------------------------------------------------
// Address map and register default values for the LMK04828 PLL chip
//
// FMC216 + ZCU102 (see ZCU102_FMC216_PinMapping.xlsx). Two LMK operating modes:
//
//   Distribution 'B' (bring-up / matches DAC + JESD software):
//     External 200 MHz on CLKin1/Fin. Both PLLs off. Runtime overrides in
//     lmk_apply_distribution_overrides_fin_100m() (name leftover; Fin is 200 MHz).
//       • DACCLK  DCLKout0/2/4/6/8/12 = Fin (bypass) = 200 MHz
//       • GT ref  DCLKout10 = Fin/2 = 100 MHz → p_fmc*_tx_refclk_*
//       • SYSREF  SDCLKout3 = Fin/32 = 6.25 MHz = LMFC at f_DATA=100 MSPS, K=16
//
//   Dual-Loop 'F'/'X' (this table's SPI defaults; not the matching JESD path):
//     PLL2 VCO 2400 MHz feeds DCLKout ÷24 = 100 MHz and SYSREF_DIV=768 = 3.125 MHz.
//
//==========================================================================================
//  DUAL-LOOP CLOCK PLAN  (table defaults — change here and re-derive PLL1/PLL2 dividers)
//==========================================================================================
//  Board: Abaco FMC216 mezzanine (UM061 r1.1 §3.7).  Two on-board oscillators:
//      • Vectron VS-705       491.52 MHz VCXO       → OSCin     (steered by PLL1)
//      • Connor-Winfield      100   MHz internal    → CLKin2    (PLL1 reference)
//                                CCLD-033-50 — gated by CPLD reg 1 bit 0 (OSC100_EN, must be 1)
//  CLKin0 = trigger MUX (CPLD-driven), CLKin1 = front-panel EXT CLK IN.
//
//  PLL_OSCIN_MHZ        = 491.52  ← actual VCXO frequency (NOT 100 MHz).  Locked by PLL1.
//  PLL_TARGET_VCO_MHZ   = 2400    ← inside VCO0 (2370–2630).  VCO_MUX = 00 in 0x138.
//  PLL_TARGET_DCLK_MHZ  = 100     ← Dual-Loop DACCLK + GT refclk = f_VCO / 24.
//                                    J16 debug pin = DCLKout10 / 2 via IBUFDS_GTE4 ⇒ J16 = 50 MHz.
//  PLL_TARGET_SYSREF_MHZ= 3.125   ← Dual-Loop table: f_VCO/768. Not the 'B' LMFC (6.25 MHz).
//==========================================================================================
//  PLL2 math (LMK04828 §9.3.6):
//      f_PD2  = (OSCin × OSC_2X) / PLL2_R           ; OSC_2X = 2 if PLL2_REF_2X_EN else 1
//      f_VCO  =  f_PD2 × PLL2_P × PLL2_N            ; PLL2_P encoding (0..7) = {2,2,2,8,4,5,6,7}
//      DCLKoutX = f_VCO / DCLKoutX_DIV[4:0]         ; per-pair (5-bit, 1..32)
//      f_SYSREF = f_VCO / SYSREF_DIV[12:0]          ; 8..8191
//
//  PLL1 math:
//      f_PD1   = CLKin2 / CLKin2_R    =    OSCin / PLL1_N
//      ⇒ OSCin = CLKin2 × PLL1_N / CLKin2_R
//
//  Locked plan @ OSCin = 491.52 MHz, PFD2 = 160 kHz (matches FMC216 PLL2 loop filter):
//      PLL2_R = 3072,  PLL2_P = 2,  PLL2_N = 7500,  PLL2_REF_2X_EN = 0  (doubler OFF)
//          ⇒ f_PD2 = 491.52/3072 = 0.16 MHz = 160 kHz
//          ⇒ f_VCO = 0.16 × 2 × 7500 = 2400 MHz   (VCO0)
//          ⇒ DCLKoutX_DIV = 24 → 100 MHz, SYSREF_DIV = 768 → 3.125 MHz.
//
//  Locked plan @ CLKin2 = 100 MHz (internal ref), OSCin = 491.52 MHz, PFD1 = 80 kHz:
//      CLKin2_R = 1250 (= 100/0.080),  PLL1_N = 6144 (= 491.52/0.080)
//          ⇒ f_PD1 = 80 kHz, OSCin pulled to 100 × 6144/1250 = 491.52 MHz exactly.
//
//  Why the previous numbers (R=2/P=2/N=12/2X) did NOT work:
//      They assumed OSCin = 100 MHz (PLL2 ×24 multiplier).  With actual OSCin = 491.52 MHz
//      the chip was being commanded to a phase detector of 491.52 MHz and a VCO of 11.8 GHz —
//      both impossible.  PLL2 never locked, the VCO drifted to ~2764.8 MHz (between VCO0 and
//      VCO1 bands), and SYSREF measured 3.6 MHz on the scope while the GTE4 refused to bring
//      up DCLKout10 ⇒ J16 was dead.  Both symptoms come from the single root cause:
//      PLL1+PLL2 dividers were sized for the wrong on-board reference.  See FMC216 UM061 §3.7.
//==========================================================================================
//
// VHDL cannot tie DACCLK and GBTCLK to one pin — the mezzanine uses separate traces.
// Dual-Loop keeps them at the same divide from PLL2. Distribution 'B' sets DACCLK = Fin
// and DCLKout10 = Fin/2 so the GT refclk stays 100 MHz.
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
#define ADR_REG_LMK_LOS_TIMEOUT         0x14B //  LOS_TIMEOUT[7:6] LOS_EN[5] TRACK_EN[4] HOLDOVER_FORCE[3] MAN_DAC_EN[2] MAN_DAC[9:8][1:0]

#define ADR_REG_LMK_MAN_DAC             0x14C //  MAN_DAC[7:0]
#define ADR_REG_LMK_DAC_TRIP_LOW        0x14D //  0 0 DAC_TRIP_LOW
#define ADR_REG_LMK_DAC_CLK             0x14E //  DAC_CLK_MULT DAC_TRIP_HIGH
#define ADR_REG_LMK_DAC_CLK_CNTR        0x14F //  DAC_CLK_CNTR
#define ADR_REG_LMK_OVERRIDE            0x150 //  0[7:5] HOLDOVER_PLL1_DET[4] HOLDOVER_LOS_DET[3] HOLDOVER_VTUNE_DET[2] HOLDOVER_HITLESS_SWITCH[1] HOLDOVER_EN[0]
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
// Clock plan constants — the diagnostic readback in app_qlaser1.c uses these to flag
// "PLL2 not at expected f_VCO" without having to recompute the PLL2 math at runtime.
//--------------------------------------------------------------------------------------------------------------------------------------------
#define LMK_OSCIN_MHZ_X1000           491520  // FMC216 on-board VS-705 VCXO (UM061 §3.7).  Locked to CLKin2 by PLL1.
#define LMK_CLKIN2_MHZ_X1000          100000  // FMC216 on-board CCLD-033-50 (UM061 §3.7).  CPLD reg1 bit0 = OSC100_EN must be 1.
#define LMK_TARGET_VCO_MHZ_X1000     2400000  // 2400 MHz, in VCO0 (2370–2630 MHz)
#define LMK_TARGET_DCLK_MHZ_X1000     100000  // Dual-Loop table: 100 MHz on every used DCLKoutX
#define LMK_TARGET_SYSREF_MHZ_X1000     3125  // Dual-Loop table: 3.125 MHz (2400/768). 'B' is 6.25 MHz.

#define LMK_VCO0_MIN_MHZ                2370
#define LMK_VCO0_MAX_MHZ                2630
#define LMK_VCO1_MIN_MHZ                2920
#define LMK_VCO1_MAX_MHZ                3080

#define LMK_RB_PLL1_LD_BIT              0x02  // 0x182 bit 1 = RB_PLL1_LD (1 = locked)
#define LMK_RB_PLL2_LD_BIT              0x02  // 0x183 bit 1 = RB_PLL2_LD (1 = locked)

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

// DCLKoutX_DIV[4:0] (reg 0x100/0x108/... bits 4:0, SNAS605 §9.7.2.1): f_DCLKout = f_VCO / DCLKoutX_DIV.
// Dual-Loop table: 100 MHz on every FMC216-used device clock — DACCLK (DCLKout 0/2/4/6/8) and
// FPGA GTH ref (DCLKout10 → GBTCLK1). Use the same DIV (24 = 0x18) on all of them so DAC
// and JESD TX see the same frequency from one VCO. Distribution 'B' overrides DCLKout mux/div
// at runtime (DAC clocks bypass Fin; DCLKout10 DIV=2).
#define DEF_LMK_CLK0_1_ODL          0x18    //  DCLKout0_DIV = 24 → 100 MHz DAC/device clock
#define DEF_LMK_CLK2_3_ODL          0x18    //  DCLKout2_DIV = 24
#define DEF_LMK_CLK4_5_ODL          0x18    //  DCLKout4_DIV = 24
#define DEF_LMK_CLK6_7_ODL          0x18    //  DCLKout6_DIV = 24
#define DEF_LMK_CLK8_9_ODL          0x18    //  DCLKout8_DIV = 24
#define DEF_LMK_CLK10_11_ODL        0x18    //  DCLKout10_DIV = 24
#define DEF_LMK_CLK12_13_ODL        0x18    //  DCLKout12_DIV = 24

#define DEF_LMK_DCLK_DDLY           5*16 + 5  //  Same DDLY value written to each DCLKout*_DDLY reg pair in arr_reg_default_clk
#define DEF_LMK_DCLK_ADLY           0         //  
#define DEF_LMK_SDCLK               0         //  Default SDCLKoutY register (0x12C/0x134): MUX=0 (device clock), unused outputs SDCLKout11/13.
// *** CHANGED (DAC SYSREF) *** FMC216 UM061 Fig.13: each DAC39J84 takes DACCLK + SYSREF from its own LMK pair:
//   DAC0 = DCLKout0/SDCLKout1, DAC3 = DCLKout4/SDCLKout5, DAC1 = DCLKout6/SDCLKout7, DAC2 = DCLKout8/SDCLKout9.
//   SDCLKout1/5/7/9 must carry SYSREF (MUX=1, bit 5) so the DAC LMFC (sysref_mode_link0=001) aligns to the FPGA.
#define DEF_LMK_SDCLK_DAC           0x20      //  0x104/0x114/0x11C/0x124: SDCLKoutY_MUX=1 (SYSREF), DDLY=0, HS=0
// SNAS605 §9.3.1 + Table 1: SDCLKout3 carries SYSREF on FMC216 (CLK1_M2C → fmc0_tx_sysref).
//   Need SDCLKout3_MUX = 1 (SYSREF) → bit 5 = 1 in reg 0x10C → 0x20.
#define DEF_LMK_SDCLK3              0x20      //  0x10C: 0 DCLKout2_HS SDCLKout3_MUX=1 SDCLKout3_DDLY=0 SDCLKout3_HS=0
#define DEF_LMK_SDCLK_ADLY          0         //  

// *** CHANGED (DAC0 clocks) *** Was 0x79: CLKout0_1_PD=1 left DAC0 with no DACCLK and no SYSREF (POR default is
//   powered down for pair 0_1, SNAS605 Table 24).  0x70 = pair on, SDCLKout1 buffer on, DIS_MODE=0, DDLY on.
#define DEF_LMK_SDCLK01_PD          0x70    // 0111 {0} 00 0 — CLKout0_1 pair on (DAC0 DACCLK), SDCLKout1 on (DAC0 SYSREF)
// SNAS605 §9.3.1 footnote: "SDCLKoutY_PD = 0 as required per SYSREF output."
//   Enable CLKout2_3 pair (bit3 = 0) and the SDCLKout3 output buffer (bit0 = 0) so SYSREF can leave the chip.
//   DCLKout2 remains powered-down via CLKout2_FMT = 000 in 0x10F.
#define DEF_LMK_SDCLK23_PD          0x70    // 0111 {0} 00 0 — CLKout2_3 pair on, SDCLKout3 enabled for SYSREF
// *** CHANGED (DAC SYSREF) *** Was 0x71: SDCLKout5/7/9_PD=1 => DAC3/DAC1/DAC2 received no SYSREF.  bit0 -> 0.
#define DEF_LMK_SDCLK45_PD          0x70    // 0111 {0} 00 0 — CLKout4_5 pair on, SDCLKout5 on (DAC3 SYSREF)
#define DEF_LMK_SDCLK67_PD          0x70    // 0111 {0} 00 0 — CLKout6_7 pair on, SDCLKout7 on (DAC1 SYSREF)
#define DEF_LMK_SDCLK89_PD          0x70    // 0111 {0} 00 0 — CLKout8_9 pair on, SDCLKout9 on (DAC2 SYSREF)
#define DEF_LMK_SDCLK1011_PD        0x71    // 0111 {0} 00 1
#define DEF_LMK_SDCLK1213_PD        0x79    // 0111 {1} 00 1

// *** CHANGED (DAC0 clocks) *** Was 0x00 (both outputs format=powerdown).  0x11 = SDCLKout1 LVDS + DCLKout0 LVDS
//   (SNAS605 Table 25; same LVDS format already used for DCLKout4/6/8 and SDCLKout3).
#define DEF_LMK_SDCLK01_POLFMT      0x11    // 0 001 0 001 — SDCLKout1 = LVDS (SYSREF), DCLKout0 = LVDS (DACCLK)
// 0x10F: bit7 SDCLKout3_POL, bits6:4 CLKout3_FMT (SDCLKout3 format), bit3 DCLKout2_POL, bits2:0 CLKout2_FMT (DCLKout2 format).
//   CLKout3_FMT = 001 → LVDS for SDCLKout3 SYSREF output. CLKout2_FMT = 000 keeps DCLKout2 off.
#define DEF_LMK_SDCLK23_POLFMT      0x10    // 0 001 0 000 — SDCLKout3 = LVDS, DCLKout2 powered-down
// *** CHANGED (DAC SYSREF) *** Was 0x01: SDCLKoutY_FMT=000 (powerdown).  bits 6:4 -> 001 LVDS.  DCLKoutX stays LVDS.
#define DEF_LMK_SDCLK45_POLFMT      0x11    // 0 001 0 001 — SDCLKout5 = LVDS, DCLKout4 = LVDS
#define DEF_LMK_SDCLK67_POLFMT      0x11    // 0 001 0 001 — SDCLKout7 = LVDS, DCLKout6 = LVDS
#define DEF_LMK_SDCLK89_POLFMT      0x11    // 0 001 0 001 — SDCLKout9 = LVDS, DCLKout8 = LVDS
#define DEF_LMK_SDCLK1011_POLFMT    0x01    // 0 000 0 {001} 
#define DEF_LMK_SDCLK1213_POLFMT    0x00    // 0 000 0 {000} 

// 0x138 — VCO_MUX | OSCout_MUX | OSCout_FMT
//   bits 6:5 = VCO_MUX:    00 = VCO0  (f_VCO = 2400 MHz lies in VCO0 band)
//   bit  4   = OSCout_MUX: 0  = Buffered OSCin
//   bits 3:0 = OSCout_FMT: 1  = LVDS  (~350 mVpp current-mode differential)
//
// OSCout± and CLKin2± are physically the same pad pair on the LMK04828 (datasheet pin
// table for pins 40/41).  On the FMC216 the CCLD-033-50 100 MHz LVCMOS oscillator is
// AC-coupled onto this same pin pair as the PLL1 reference.  Two empirical observations
// drove this setting:
//   • OSCout_FMT = 4 (LVPECL 1600 mVpp, original):  PLL1 occasionally locks but is
//     unreliable.  The LVPECL driver's strong (≈800 mV) swing partially overpowers the
//     external CCLD signal.
//   • OSCout_FMT = 0 (powerdown):  PLL1 never locks.  With the OSCout driver fully off,
//     the pins lose their DC bias and the AC-coupled LVCMOS signal floats outside the
//     CLKin2 receiver's common-mode input range — the FMC216 board topology relies on
//     OSCout providing the DC bias for the shared pin pair.
// LVDS (mode 1) provides the DC bias the board needs while emitting only ~350 mVpp diff
// swing — weak enough for the CCLD's full-rail (≈3.3 Vpp) push-pull LVCMOS output to
// reliably dominate at the CLKin2 receiver, giving consistent PLL1 lock.
#define DEF_LMK_OSC                     0x01    // VCO0, OSCout = LVDS (weak driver, preserves DC bias for CLKin2 input)
// SNAS605 §9.3.1 Table 1 "Continuous SYSREF": SYSREF_MUX = 11 (3) (with SYSREF_PD=0, SYSREF_DDLY_PD=0, SYSREF_PLSR_PD=1).
//   Dual-Loop table keeps ~3.125 MHz SYSREF on SDCLKout3. Distribution 'B' overrides
//   SYSREF_DIV=32 so Fin/32 = 6.25 MHz (LMFC at f_DATA=100 MSPS, K=16).
#define DEF_LMK_SYSREFMUX               0x03    // 0x139 SYSREF_CLKin0_MUX=0, SYSREF_MUX=11 (continuous SYSREF)
// Dual-Loop SYSREF_DIV[12:0]: f_SYSREF = f_VCO / SYSREF_DIV (SNAS605).
//   f_VCO ≈ 2.4 GHz → SYSREF_DIV = 768 (0x300) → 3.125 MHz. Distribution 'B' writes 32 instead.
#define DEF_LMK_SYSREF_DIV1             0x03    // SYSREF_DIV[12:8] = 3
#define DEF_LMK_SYSREF_DIV0             0x00    // SYSREF_DIV[7:0] = 0  → total 768
#define DEF_LMK_SYSREF_DDLY1            0x00      // [11:0] 
#define DEF_LMK_SYSREF_DDLY0            0x08      //  
#define DEF_LMK_SYSREF_PCNT             0x03      // [1:0] 3 = 8 pulses

#define DEF_LMK_NCLK                    0x00    // 0x13F //  0 0 0 PLL2_NCLK_MUX PLL1_NCLK_MUX FB_MUX FB_MUX_EN
// SNAS605 §9.3.2.1 Table 2 "How To Enable SYSREF": SYSREF_PD = 0 and SYSREF_DDLY_PD = 0 are mandatory.
//   With continuous-SYSREF mode (SYSREF_MUX=3) the pulser is unused, so SYSREF_PLSR_PD = 1 is allowed.
//   Previous value 0x07 powered down the entire SYSREF block — no SYSREF could ever leave the chip.
#define DEF_LMK_PLL1                    0x01    // 0x140 — PLL1/VCO/OSCin on, SYSREF block on, only pulser powered down
                                                //         bits: PLL1_PD=0 VCO_LDO_PD=0 VCO_PD=0 OSCin_PD=0 SYSREF_GBL_PD=0 SYSREF_PD=0 SYSREF_DDLY_PD=0 SYSREF_PLSR_PD=1
#define DEF_LMK_DDLY_SYSREF_EN          0x00    // 0x141 //  DDLYd_SYSREF_EN DDLYd12_EN DDLYd10_EN DDLYd7_EN DDLYd6_EN DDLYd4_EN DDLYd2_EN DDLYd0_EN
#define DEF_LMK_DDLY_STEP_CNT           0x00    // 0x142 //  0 0 0 DDLYd_STEP_CNT
#define DEF_LMK_DDLY_CLR                0x91    // 0x143 //  SYSREF_DDLY_CLR SYNC_1SHOT_EN SYNC_POL SYNC_EN SYNC_PLL2_DLD SYNC_PLL1_DLD SYNC_MODE
#define DEF_LMK_SYNC_DIS                0x00    // 0x144 //  SYNC_DISSYSREF SYNC_DIS12 SYNC_DIS10 SYNC_DIS8 SYNC_DIS6 SYNC_DIS4 SYNC_DIS2 SYNC_DIS0
#define DEF_LMK_CONST0                  0x3F    // 0x145 //  0 1 1 1 1 1 1 1
// 0x146 bit assignment (LMK04828 datasheet Table 40, page 75-76):
//   bit5 = CLKin2_EN, bit4 = CLKin1_EN, bit3 = CLKin0_EN, bit2 = CLKin2_TYPE, bit1 = CLKin1_TYPE, bit0 = CLKin0_TYPE.
//   TYPE: 0 = bipolar (recommended for LVDS/LVPECL diff inputs), 1 = MOS (recommended for
//   DC-coupled single-ended inputs).
// On the FMC216 we drive PLL1 from CLKin2, which is wired to the on-board 100 MHz
// Connor-Winfield CCLD-033-50 — a single-ended LVCMOS oscillator.  Per the LMK datasheet
// the bipolar buffer is unsuitable for single-ended LVCMOS (it expects AC-coupled diff
// signals around Vcm), so CLKin2_TYPE MUST be 1 (MOS) for PLL1 to actually slice the
// 100 MHz reference and lock.  CLKin0 (trigger MUX) and CLKin1 (front-panel EXT CLK IN
// via TC2-72T transformer) remain bipolar, which matches their differential routing.
#define DEF_LMK_CLKIN                   0x3C    // 0x146 //  0 0 1 1 1 1 0 0  → CLKin0/1/2 enabled; CLKin2=MOS, CLKin0/1=bipolar
// 0x147 bit assignment (LMK04828 datasheet Table 41, page 76):
//   bit7 = CLKin_SEL_POL, bits 6:4 = CLKin_SEL_MODE, bits 3:2 = CLKin1_OUT_MUX, bits 1:0 = CLKin0_OUT_MUX.
//   CLKin_SEL_MODE encoding:  0=CLKin0 manual, 1=CLKin1 manual, 2=CLKin2 manual,
//                             3=Pin select (POR default), 4=Auto, 5-7=reserved.
// On the FMC216 the 100 MHz internal reference is wired to CLKin2, so we MUST manually
// select CLKin2 (mode = 2) before the PLL1-lock wait runs.  The previous default of 0x3A
// left the chip in Pin-Select mode, where with no driven CLKin_SEL0/1 strap pins it fell
// back to CLKin0 (the trigger MUX) — PLL1 had no usable reference.  Setting CLKin_SEL_MODE
// directly here means set_lmk_clk_src() at the end of init becomes a no-op restate.
//   bits 3:2 = 10 → CLKin1 buffer routed to PLL1 (kept available for ext-clock mode).
//   bits 1:0 = 10 → CLKin0 buffer routed to PLL1 (used by trigger MUX path).
#define DEF_LMK_CLKIN_POL               0x2A    // 0x147 //  0 010 10 10  → CLKin2 manual, CLKin1→PLL1, CLKin0→PLL1
#define DEF_LMK_CLKIN_SEL0              0x02    // 0x148 //  0 0 CLKin_SEL0_MUX CLKin_SEL0_TYPE
#define DEF_LMK_CLKIN_SEL1              0x42    // 0x149 //  0 SDIO_RDBK_TYPE CLKin_SEL1_MUX CLKin_SEL1_TYPE
#define DEF_LMK_RESET_MUX               0x02    // 0x14A //  0 0 RESET_MUX RESET_TYPE
/* 0x16 enabled MAN_DAC_EN — PLL1 DAC follows 0x14B[1:0]+0x14C, not the loop (PLL1 never locks). */
#define DEF_LMK_LOS_TIMEOUT             0x12    // 0x14B — same as 0x16 but MAN_DAC_EN=0 (TI SNAS605 bit map)
#define DEF_LMK_MAN_DAC                 0x00    // 0x14C //  MAN_DAC[7:0]
#define DEF_LMK_DAC_TRIP_LOW            0x00    // 0x14D //  0 0 DAC_TRIP_LOW
#define DEF_LMK_DAC_CLK                 0x00    // 0x14E //  DAC_CLK_MULT DAC_TRIP_HIGH
#define DEF_LMK_DAC_CLK_CNTR            0x7F    // 0x14F //  DAC_CLK_CNTR
#define DEF_LMK_OVERRIDE                0x03    // 0x150 //  0 CLKin_OVERRIDE 0 HOLDOVER_PLL1_DET HOLDOVER_LOS_DET HOLDOVER_VTUNE_DET HOLDOVER_HITLESS_SWITCH HOLDOVER_EN
#define DEF_LMK_HOLD_DLD_CNT1           0x02    // 0x151 //  0 0 HOLDOVER_DLD_CNT[13:8]
#define DEF_LMK_HOLD_DLD_CNT0           0x00    // 0x152 //  HOLDOVER_DLD_CNT[7:0]
#define DEF_LMK_CLKIN0_R1               0x00    // 0x153 //  0 0 CLKin0_R[13:8]   (CLKin0 = trigger MUX, unused for PLL1)
#define DEF_LMK_CLKIN0_R0               0x78    // 0x154 //  CLKin0_R[7:0]
#define DEF_LMK_CLKIN1_R1               0x00    // 0x155 //  0 0 CLKin1_R[13:8]   (CLKin1 = front-panel EXT CLK IN, unused for PLL1)
#define DEF_LMK_CLKIN1_R0               0x96    // 0x156 //  CLKin1_R[7:0]
// PLL1: CLKin2 (= 100 MHz internal CCLD-033-50) → 491.52 MHz VS-705 VCXO on OSCin.
//   f_PD1 = CLKin2 / CLKin2_R = 100 MHz / 1250 = 80 kHz (matches FMC216 PLL1 loop filter
//   designed for 80 kHz per UM061 §3.7).  PLL1_N = 6144 ⇒ OSCin = 80 kHz × 6144 = 491.52 MHz.
#define DEF_LMK_CLKIN2_R1               0x04    // 0x157 //  CLKin2_R[13:8] = 0x04
#define DEF_LMK_CLKIN2_R0               0xE2    // 0x158 //  CLKin2_R[7:0]  = 0xE2  (R = 1250)
#define DEF_LMK_PLL1_N1                 0x18    // 0x159 //  PLL1_N[13:8]   = 0x18
#define DEF_LMK_PLL1_N0                 0x00    // 0x15A //  PLL1_N[7:0]    = 0x00  (N = 6144)
#define DEF_LMK_PLL1_MISC               0xD4    // 0x15B //  PLL1_WND_SIZE=11 (43 ns, max), CP_TRI=0, CP_POL=1 (pos-slope VCXO), CP_GAIN=4 (450 µA)
// PLL1 lock-detect counter: number of consecutive in-window PFD cycles required to assert
// RB_PLL1_LD.  The original 0x2000 (8192 cycles → 102.4 ms at f_PD1 = 80 kHz) was so large
// that any single phase-noise excursion >43 ns over a 100 ms window reset the counter and
// PLL1 never reported "locked" even when the loop was stably tracking — observed as
// intermittent F-vs-J behaviour.  1024 cycles (= 12.8 ms at 80 kHz) is still strict enough
// to filter out genuine momentary glitches but ~8x more tolerant of stochastic VCXO/REF
// phase noise on a fresh start.
#define DEF_LMK_PLL1_DLD_CNT1           0x04    // 0x15C //  PLL1_DLD_CNT[13:8] = 0x04
#define DEF_LMK_PLL1_DLD_CNT0           0x00    // 0x15D //  PLL1_DLD_CNT[7:0]  = 0x00  (DLD_CNT = 1024)
#define DEF_LMK_PLL1_DLYS               0x00    // 0x15E //  0 0 PLL1_R_DLY PLL1_N_DLY
#define DEF_LMK_PLL1_LDS                0x3B    // 0x15F //  PLL1_LD_MUX PLL1_LD_TYPE (Changed from 0x0E because pin is used for SPI readback
// PLL2 dividers — sized for OSCin = 491.52 MHz (FMC216 VS-705 VCXO).
//   PLL2_R = 3072 = 0x0C00 → f_PD2 = 491.52/3072 = 160 kHz (matches FMC216 PLL2 loop filter
//   designed for 160 kHz PFD per UM061 §3.7 "PLL Design").  Doubler OFF (PLL2_REF_2X_EN=0).
//   PLL2_P = 2 (field code 0), OSCin_FREQ = 7 (>127 MHz range), PLL2_XTAL_EN = 0.
//   PLL2_N = PLL2_N_CAL = 7500 = 0x1D4C → f_VCO = 0.16 MHz × 2 × 7500 = 2400 MHz (in VCO0).
//   ⇒ DCLKoutX_DIV = 24 → 100 MHz, SYSREF_DIV = 768 → 3.125 MHz exactly.
#define DEF_LMK_PLL2_R1                 0x0C    // 0x160 //  PLL2_R[11:8] = 0xC  (R = 3072)
#define DEF_LMK_PLL2_R0                 0x00    // 0x161 //  PLL2_R[7:0]  = 0x00
// PLL2_P encoding (LMK04828 datasheet Table 66, register 0x162 bits 7:5):
//   field 0 → P = 8     ← NOT what we want — pushes f_VCO to ~9.6 GHz, outside both VCO bands
//   field 1 → P = 2
//   field 2 → P = 2     ← POR default; use this to match TI's reference programming
//   field 3 → P = 3, …  field 7 → P = 7
// We want P = 2 so that f_VCO = OSCin (491.52 MHz) × P × N / R = 491.52 × 2 × 7500 / 3072
// = 2400 MHz (inside VCO0 band 2370–2630 MHz).  Set bits 7:5 = 010 (field 2).
// OSCin_FREQ field (bits 4:2) per datasheet Table 66:
//   0=0–63 MHz, 1=63–127 MHz, 2=127–255 MHz, 3=reserved, 4=255–500 MHz, 5–7=reserved.
// 491.52 MHz falls in range 4 (255–500 MHz).  Set bits 4:2 = 100.
// PLL2_XTAL_EN (bit 1) = 0  (we use external VCXO on OSCin, not internal XTAL amp).
// PLL2_REF_2X_EN (bit 0) = 0  (doubler off; at 491.52 MHz OSCin we don't need the doubler
// to reach the 160 kHz PFD2 target with R=3072).
#define DEF_LMK_PLL2_P                  0x50    // 0x162 //  010-100-0-0  PLL2_P=2 (field 2), OSCin_FREQ=4, XTAL=0, doubler OFF
#define DEF_LMK_PLL2_N_CAL2             0x00    // 0x163 //  PLL2_N_CAL[17:16] = 0
#define DEF_LMK_PLL2_N_CAL1             0x1D    // 0x164 //  PLL2_N_CAL[15:8]  = 0x1D
#define DEF_LMK_PLL2_N_CAL0             0x4C    // 0x165 //  PLL2_N_CAL[7:0]   = 0x4C  (N_CAL = 7500)

// reg 0x166
#define DEF_LMK_PLL2_FCAL               0x00  // 0x166  // PLL2_FCAL_DIS=0 (FCAL armed), PLL2_N[17:16]=0
#define DEF_LMK_PLL2_N1                 0x1D  // 0x167  // PLL2_N[15:8]  = 0x1D
#define DEF_LMK_PLL2_N0                 0x4C  // 0x168  // PLL2_N[7:0]   = 0x4C  (N = 7500); writing 0x168 re-arms FCAL
// 0x169 PLL2_MISC (Table 71): WND_SIZE=2 (3.7 ns, mandatory), CP_GAIN=3 (3200 µA),
// CP_POL=0 (negative slope, internal VCO), CP_TRI=0, fixed bit0=1 → 0x59.
#define DEF_LMK_PLL2_MISC               0x59  // 0x169
// PLL2 lock-detect counter: same rationale as PLL1.  Original 0x2000 (8192 cycles
// → 51.2 ms at f_PD2 = 160 kHz) is overly strict and intermittently fails on fresh start.
// 1024 cycles (= 6.4 ms at 160 kHz) is well above noise floor but tolerant of jitter.
// SYSREF_REQ_EN = bit 6 of 0x16A — kept = 0 (we drive SYSREF via SYSREF_MUX = continuous,
// not via the SYNC/SYSREF_REQ pin).
#define DEF_LMK_PLL2_DLD_CNT1           0x04  // 0x16A  // SYSREF_REQ_EN=0, PLL2_DLD_CNT[13:8]=0x04
#define DEF_LMK_PLL2_DLD_CNT0           0x00  // 0x16B  // PLL2_DLD_CNT[7:0]=0x00  (DLD_CNT = 1024)
#define DEF_LMK_PLL2_LF_R               0x00  // 0x16C  // 0 0 PLL2_LF_R4 PLL2_LF_R3
#define DEF_LMK_PLL2_LF_C               0x00  // 0x16D  // PLL2_LF_C4 PLL2_LF_C3
#define DEF_LMK_PLL2_LD_MUX             0x16  // 0x16E  // PLL2_LD_MUX PLL2_LD_TYPE 2,6 -> 00010_110
#define DEF_LMK_CONST1                  0xAA  // 0x171  // TI SNAS605 §9.5.1: must program 0xAA (not POR)
#define DEF_LMK_CONST2                  0x02  // 0x172  // TI SNAS605 §9.5.1: must program 0x02 (not POR)
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
 DEF_LMK_CLK0_1_ODL             ,   // 0x100: DCLKout0_DIV=24 → 100 MHz DACCLK path
 DEF_LMK_DCLK_DDLY              ,   // 0x101
 DEF_LMK_DCLK_ADLY              ,   // 0         //  
 DEF_LMK_SDCLK_DAC              ,   // 0x104: *** CHANGED *** SDCLKout1_MUX=1 → SYSREF to DAC0
 DEF_LMK_SDCLK_ADLY             ,   // 0x105
 DEF_LMK_SDCLK01_PD             ,   // 0x106: *** CHANGED *** 0x70 — CLKout0_1 pair on, SDCLKout1 on (was 0x79)
 DEF_LMK_SDCLK01_POLFMT         ,   // 0x107: *** CHANGED *** 0x11 — DCLKout0 + SDCLKout1 LVDS (was 0x00)
 DEF_LMK_CLK2_3_ODL             ,   // 0x108: DCLKout2_DIV=24
 DEF_LMK_DCLK_DDLY              ,   // 0x109
 DEF_LMK_DCLK_ADLY              ,   // 0x10B
 DEF_LMK_SDCLK3                 ,   // 0x10C: SDCLKout3_MUX = 1 (SYSREF) → SYSREF on FMC216 CLK1_M2C
 DEF_LMK_SDCLK_ADLY             ,   // 0x10D
 DEF_LMK_SDCLK23_PD             ,   // 0x10E: 0x70 — CLKout2_3 pair on, SDCLKout3 buffer enabled
 DEF_LMK_SDCLK23_POLFMT         ,   // 0x10F: 0x10 — SDCLKout3 = LVDS, DCLKout2 powered down
 DEF_LMK_CLK4_5_ODL             ,   // 0x110: DCLKout4_DIV=24
 DEF_LMK_DCLK_DDLY              ,   // 0x111
 DEF_LMK_DCLK_ADLY              ,   // 0         //  
 DEF_LMK_SDCLK_DAC              ,   // 0x114: *** CHANGED *** SDCLKout5_MUX=1 → SYSREF to DAC3
 DEF_LMK_SDCLK_ADLY             ,   // 0x115
 DEF_LMK_SDCLK45_PD             ,   // 0x116: *** CHANGED *** 0x70 — SDCLKout5 on (was 0x71)
 DEF_LMK_SDCLK45_POLFMT         ,   // 0x117: *** CHANGED *** 0x11 — SDCLKout5 LVDS (was 0x01)
 DEF_LMK_CLK6_7_ODL             ,   // 0x118: DCLKout6_DIV=24
 DEF_LMK_DCLK_DDLY              ,   // 0x119
 DEF_LMK_DCLK_ADLY              ,   // 0         //  
 DEF_LMK_SDCLK_DAC              ,   // 0x11C: *** CHANGED *** SDCLKout7_MUX=1 → SYSREF to DAC1
 DEF_LMK_SDCLK_ADLY             ,   // 0x11D
 DEF_LMK_SDCLK67_PD             ,   // 0x11E: *** CHANGED *** 0x70 — SDCLKout7 on (was 0x71)
 DEF_LMK_SDCLK67_POLFMT         ,   // 0x11F: *** CHANGED *** 0x11 — SDCLKout7 LVDS (was 0x01)
 DEF_LMK_CLK8_9_ODL             ,   // 0x120: DCLKout8_DIV=24
 DEF_LMK_DCLK_DDLY              ,   // 0x121
 DEF_LMK_DCLK_ADLY              ,   // 0         //  
 DEF_LMK_SDCLK_DAC              ,   // 0x124: *** CHANGED *** SDCLKout9_MUX=1 → SYSREF to DAC2
 DEF_LMK_SDCLK_ADLY             ,   // 0x125
 DEF_LMK_SDCLK89_PD             ,   // 0x126: *** CHANGED *** 0x70 — SDCLKout9 on (was 0x71)
 DEF_LMK_SDCLK89_POLFMT         ,   // 0x127: *** CHANGED *** 0x11 — SDCLKout9 LVDS (was 0x01)
 DEF_LMK_CLK10_11_ODL           ,   // 0x128 Dual-Loop: DCLKout10_DIV=24 → 100 MHz. 'B' writes DIV=2.
 DEF_LMK_DCLK_DDLY              ,   // 0x129
 DEF_LMK_DCLK_ADLY              ,   // 0         //  
 DEF_LMK_SDCLK                  ,   // 0         //  
 DEF_LMK_SDCLK_ADLY             ,   // 0         //  
 DEF_LMK_SDCLK1011_PD           ,   // 0x71    // 0111 {0} 00 1
 DEF_LMK_SDCLK1011_POLFMT       ,   // 0x01    // 0 000 0 {001} 
 DEF_LMK_CLK12_13_ODL           ,   // 0x130: DCLKout12 (ext clock out path); div=24 if used
 DEF_LMK_DCLK_DDLY              ,   // 0x131
 DEF_LMK_DCLK_ADLY              ,   // 0         //  
 DEF_LMK_SDCLK                  ,   // 0         //  
 DEF_LMK_SDCLK_ADLY             ,   // 0         //  
 DEF_LMK_SDCLK1213_PD           ,   // 0x79    // 0111 {1} 00 1
 DEF_LMK_SDCLK1213_POLFMT       ,   // 0x00    // 0 000 0 {000} 
 DEF_LMK_OSC                    ,   // 0x01 Dual-Loop: VCO0 + OSCout LVDS. 'B' writes 0x40 (external, OSCout off).
 DEF_LMK_SYSREFMUX              ,   // 0x03    // 0x139 SYSREF_MUX = 11 (continuous SYSREF)
  DEF_LMK_SYSREF_DIV1            ,   // 0x03 Dual-Loop SYSREF_DIV=768 → 3.125 MHz. 'B' writes 32.
  DEF_LMK_SYSREF_DIV0            ,   // 0x00
 DEF_LMK_SYSREF_DDLY1           ,   // 0x00    // [11:0] 
 DEF_LMK_SYSREF_DDLY0           ,   // 0x08    //  
 DEF_LMK_SYSREF_PCNT            ,   // 0x03    // [1:0] 3 = 8 pulses
 DEF_LMK_NCLK                   ,   // 0x00    // 0x13F //  0 0 0 PLL2_NCLK_MUX PLL1_NCLK_MUX FB_MUX FB_MUX_EN
 DEF_LMK_PLL1                   ,   // 0x01    // 0x140 — PLLs/VCO/OSCin on, SYSREF block + DDLY on, only SYSREF_PLSR_PD set
 DEF_LMK_DDLY_SYSREF_EN         ,   // 0x00    // 0x141 //  DDLYd_SYSREF_EN DDLYd12_EN DDLYd10_EN DDLYd7_EN DDLYd6_EN DDLYd4_EN DDLYd2_EN DDLYd0_EN
 DEF_LMK_DDLY_STEP_CNT          ,   // 0x00    // 0x142 //  0 0 0 DDLYd_STEP_CNT
 DEF_LMK_DDLY_CLR               ,   // 0x91    // 0x143 //  SYSREF_DDLY_CLR SYNC_1SHOT_EN SYNC_POL SYNC_EN SYNC_PLL2_DLD SYNC_PLL1_DLD SYNC_MODE
 DEF_LMK_SYNC_DIS               ,   // 0x00    // 0x144 //  SYNC_DISSYSREF SYNC_DIS12 SYNC_DIS10 SYNC_DIS8 SYNC_DIS6 SYNC_DIS4 SYNC_DIS2 SYNC_DIS0
 DEF_LMK_CONST0                 ,   // 0x3F    // 0x145 //  0 1 1 1 1 1 1 1
 DEF_LMK_CLKIN                  ,   // 0x18    // 0x146 //  0 0 CLKin2_EN CLKin1_EN CLKin0_EN CLKin2_TYPE CLKin1_TYPE CLKin0_TYPE
 DEF_LMK_CLKIN_POL              ,   // 0x2A    // 0x147 //  CLKin2 manual select | CLKin1→PLL1 | CLKin0→PLL1
 DEF_LMK_CLKIN_SEL0             ,   // 0x02    // 0x148 //  0 0 CLKin_SEL0_MUX CLKin_SEL0_TYPE
 DEF_LMK_CLKIN_SEL1             ,   // 0x42    // 0x149 //  0 SDIO_RDBK_TYPE CLKin_SEL1_MUX CLKin_SEL1_TYPE
 DEF_LMK_RESET_MUX              ,   // 0x02    // 0x14A //  0 0 RESET_MUX RESET_TYPE
 DEF_LMK_LOS_TIMEOUT            ,   // 0x12    // 0x14B — MAN_DAC_EN=0 (was 0x16)
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
 DEF_LMK_PLL1_MISC              ,   // DEF_LMK_PLL1_MISC (0xD4) // 0x15B
 DEF_LMK_PLL1_DLD_CNT1          ,   // 0x20    // 0x15C //  0 0 PLL1_DLD_CNT[13:8]
 DEF_LMK_PLL1_DLD_CNT0          ,   // 0x00    // 0x15D //  PLL1_DLD_CNT[7:0]
 DEF_LMK_PLL1_DLYS              ,   // 0x00    // 0x15E //  0 0 PLL1_R_DLY PLL1_N_DLY
 DEF_LMK_PLL1_LDS               ,   // DEF_LMK_PLL1_LDS (0x3B) // 0x15F
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
 DEF_LMK_CONST1                 ,   // 0xAA  // 0x171  // TI mandatory
 DEF_LMK_CONST2                 ,   // 0x02  // 0x172  // TI mandatory
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

