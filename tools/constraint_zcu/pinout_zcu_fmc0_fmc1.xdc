#--------------------------------------------------------------------------------------------------------
# Pin constraint file for ZCU102 board
#--------------------------------------------------------------------------------------------------------
#
#--------------------------------------------------------------------------------------------------------
# CPU reset button
#--------------------------------------------------------------------------------------------------------
set_property PACKAGE_PIN AM13     [get_ports "p_reset"] ;# Bank 44  - IO_L4N_AD8N_44
set_property IOSTANDARD  LVCMOS33 [get_ports "p_reset"] ;# Bank 44  - IO_L4N_AD8N_44

#--------------------------------------------------------------------------------------------------------
## Buttons  Five buttons arranged at 4 cardinal points and one in the center
#--------------------------------------------------------------------------------------------------------
set_property IOSTANDARD  LVCMOS33 [get_ports "p_btn*"]  ;# Bank 44  
set_property PACKAGE_PIN AE14     [get_ports "p_btn_e"] ;# Bank 44  GPIO_SW_E  - IO_L12N_AD0N_44
set_property PACKAGE_PIN AE15     [get_ports "p_btn_s"] ;# Bank 44  GPIO_SW_S  - IO_L12P_AD0P_44
set_property PACKAGE_PIN AG15     [get_ports "p_btn_n"] ;# Bank 44  GPIO_SW_N  - IO_L11N_AD1N_44
set_property PACKAGE_PIN AF15     [get_ports "p_btn_w"] ;# Bank 44  GPIO_SW_W  - IO_L11P_AD1P_44
set_property PACKAGE_PIN AG13     [get_ports "p_btn_c"] ;# Bank 44  GPIO_SW_C  - IO_L10N_AD2N_44

#--------------------------------------------------------------------------------------------------------
## LEDs
#--------------------------------------------------------------------------------------------------------
set_property IOSTANDARD  LVCMOS33 [get_ports "p_leds[*]"] ;# Bank 44 
set_property PACKAGE_PIN AG14     [get_ports "p_leds[0]"] ;# Bank 44  - IO_L10P_AD2P_44
set_property PACKAGE_PIN AF13     [get_ports "p_leds[1]"] ;# Bank 44  - IO_L9N_AD3N_44
set_property PACKAGE_PIN AE13     [get_ports "p_leds[2]"] ;# Bank 44  - IO_L9P_AD3P_44
set_property PACKAGE_PIN AJ14     [get_ports "p_leds[3]"] ;# Bank 44  - IO_L8N_HDGC_AD4N_44
set_property PACKAGE_PIN AJ15     [get_ports "p_leds[4]"] ;# Bank 44  - IO_L8P_HDGC_AD4P_44
set_property PACKAGE_PIN AH13     [get_ports "p_leds[5]"] ;# Bank 44  - IO_L7N_HDGC_AD5N_44
set_property PACKAGE_PIN AH14     [get_ports "p_leds[6]"] ;# Bank 44  - IO_L7P_HDGC_AD5P_44
set_property PACKAGE_PIN AL12     [get_ports "p_leds[7]"] ;# Bank 44  - IO_L6N_HDGC_AD6N_44


#--------------------------------------------------------------------------------------------------------
## Pmod Header J55
#--------------------------------------------------------------------------------------------------------
set_property PACKAGE_PIN A20      [get_ports "p_dc0_cs_n"] ;# Bank 47  PMOD0_0  - IO_L12N_AD0N_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc0_cs_n"] ;# Bank 47  PMOD0_0  - IO_L12N_AD0N_47
set_property PACKAGE_PIN B20      [get_ports "p_dc0_mosi"] ;# Bank 47  PMOD0_1  - IO_L12P_AD0P_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc0_mosi"] ;# Bank 47  PMOD0_1  - IO_L12P_AD0P_47
# set_property PACKAGE_PIN A22      [get_ports "p_dc0_nc"] ;# Bank 47  PMOD0_2  - IO_L11N_AD1N_47
# set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc0_nc"] ;# Bank 47  PMOD0_2  - IO_L11N_AD1N_47
set_property PACKAGE_PIN A21      [get_ports "p_dc0_sclk"] ;# Bank 47  PMOD0_3  - IO_L11P_AD1P_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc0_sclk"] ;# Bank 47  PMOD0_3  - IO_L11P_AD1P_47
set_property PACKAGE_PIN B21      [get_ports "p_dc1_cs_n"] ;# Bank 47  PMOD0_4  - IO_L10N_AD2N_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc1_cs_n"] ;# Bank 47  PMOD0_4  - IO_L10N_AD2N_47
set_property PACKAGE_PIN C21      [get_ports "p_dc1_mosi"] ;# Bank 47  PMOD0_5  - IO_L10P_AD2P_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc1_mosi"] ;# Bank 47  PMOD0_5  - IO_L10P_AD2P_47
# set_property PACKAGE_PIN C22      [get_ports "p_dc1_nc"] ;# Bank 47  PMOD0_6  - IO_L9N_AD3N_47
# set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc1_nc"] ;# Bank 47  PMOD0_6  - IO_L9N_AD3N_47
set_property PACKAGE_PIN D21      [get_ports "p_dc1_sclk"] ;# Bank 47  PMOD0_7  - IO_L9P_AD3P_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc1_sclk"] ;# Bank 47  PMOD0_7  - IO_L9P_AD3P_47

#--------------------------------------------------------------------------------------------------------
## Pmod Header J87
#--------------------------------------------------------------------------------------------------------
set_property PACKAGE_PIN D20      [get_ports "p_dc2_cs_n"] ;# Bank 47  PMOD1_0  - IO_L8N_HDGC_AD4N_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc2_cs_n"] ;# Bank 47  PMOD1_0  - IO_L8N_HDGC_AD4N_47
set_property PACKAGE_PIN E20      [get_ports "p_dc2_mosi"] ;# Bank 47  PMOD1_1  - IO_L8P_HDGC_AD4P_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc2_mosi"] ;# Bank 47  PMOD1_1  - IO_L8P_HDGC_AD4P_47
#set_property PACKAGE_PIN D22      [get_ports "p_dc2_nc"]  ;# Bank 47  PMOD1_2  - IO_L7N_HDGC_AD5N_47
#set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc2_nc"]  ;# Bank 47  PMOD1_2  - IO_L7N_HDGC_AD5N_47
set_property PACKAGE_PIN E22      [get_ports "p_dc2_sclk"] ;# Bank 47  PMOD1_3  - IO_L7N_HDGC_AD5N_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc2_sclk"] ;# Bank 47  PMOD1_3  - IO_L7N_HDGC_AD5N_47
set_property PACKAGE_PIN F20      [get_ports "p_dc3_cs_n"] ;# Bank 47  PMOD1_4  - IO_L8N_HDGC_AD4N_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc3_cs_n"] ;# Bank 47  PMOD1_4  - IO_L8N_HDGC_AD4N_47
set_property PACKAGE_PIN G20      [get_ports "p_dc3_mosi"] ;# Bank 47  PMOD1_5  - IO_L8P_HDGC_AD4P_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc3_mosi"] ;# Bank 47  PMOD1_5  - IO_L8P_HDGC_AD4P_47
#set_property PACKAGE_PIN J20      [get_ports "p_dc3_nc"]  ;# Bank 47  PMOD1_6  - IO_L7N_HDGC_AD5N_47
#set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc3_nc"]  ;# Bank 47  PMOD1_6  - IO_L7N_HDGC_AD5N_47
set_property PACKAGE_PIN J19      [get_ports "p_dc3_sclk"] ;# Bank 47  PMOD1_7  - IO_L7N_HDGC_AD5N_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc3_sclk"] ;# Bank 47  PMOD1_7  - IO_L7N_HDGC_AD5N_47

#--------------------------------------------------------------------------------------------------------
# The ZCU102 evaluation board provides a 2x12 male header prototype header J3 which
# makes ten Bank 50 GPIO connections available. Figure 3-30 shows connector J3 with its
# MPSoC (U1) Bank 50 connections.
#--------------------------------------------------------------------------------------------------------
set_property IOSTANDARD  LVCMOS33 [get_ports "p_debug_out[*]"] ;# Bank 50 
set_property PACKAGE_PIN J15      [get_ports "p_debug_out[0]"] ;# Bank 50  - IO_L12N_AD8N_50
set_property PACKAGE_PIN J16      [get_ports "p_debug_out[1]"] ;# Bank 50  - IO_L12P_AD8P_50
set_property PACKAGE_PIN G16      [get_ports "p_debug_out[2]"] ;# Bank 50  - IO_L11N_AD9N_50
set_property PACKAGE_PIN H16      [get_ports "p_debug_out[3]"] ;# Bank 50  - IO_L11P_AD9P_50
set_property PACKAGE_PIN H14      [get_ports "p_debug_out[4]"] ;# Bank 50  - IO_L10N_AD10N_50
set_property PACKAGE_PIN J14      [get_ports "p_debug_out[5]"] ;# Bank 50  - IO_L10P_AD10P_50
set_property PACKAGE_PIN G14      [get_ports "p_debug_out[6]"] ;# Bank 50  - IO_L9N_AD11N_50
set_property PACKAGE_PIN G15      [get_ports "p_debug_out[7]"] ;# Bank 50  - IO_L9P_AD11P_50

#--------------------------------------------------------------------------------------------------------
# Connections for J5. Abaco DAC board with JESD interface
#--------------------------------------------------------------------------------------------------------
#   p_fmc1_tx_sync_p        : in    std_logic_vector( 3 downto 0);  -- LVS sync for each link
#   p_fmc0_tx_sync_n        : in    std_logic_vector( 3 downto 0);
#--------------------------------------------------------------------------------------------------------
set_property IOSTANDARD  LVDS   [get_ports "p_fmc0_tx_sync_p[*]"] ; 
set_property PACKAGE_PIN  V2    [get_ports "p_fmc0_tx_sync_p[0]"] ;
set_property PACKAGE_PIN  V1    [get_ports "p_fmc0_tx_sync_n[0]"] ;
set_property PACKAGE_PIN  Y2    [get_ports "p_fmc0_tx_sync_p[1]"] ;
set_property PACKAGE_PIN  Y1    [get_ports "p_fmc0_tx_sync_n[1]"] ;
set_property PACKAGE_PIN  AA2   [get_ports "p_fmc0_tx_sync_p[2]"] ;
set_property PACKAGE_PIN  AA1   [get_ports "p_fmc0_tx_sync_n[2]"] ;
set_property PACKAGE_PIN  AB3   [get_ports "p_fmc0_tx_sync_p[3]"] ;
set_property PACKAGE_PIN  AC3   [get_ports "p_fmc0_tx_sync_n[3]"] ;

#--------------------------------------------------------------------------------------------------------
#   p_fmc0_tx_sysref_p      : in    std_logic;
#   p_fmc0_tx_sysref_n      : in    std_logic;
#--------------------------------------------------------------------------------------------------------
# IBUFDS
set_property IOSTANDARD  LVDS   [get_ports "p_fmc0_tx_sysref_p"] ; 
set_property PACKAGE_PIN  T8    [get_ports "p_fmc0_tx_sysref_p"] ;
set_property PACKAGE_PIN  R8    [get_ports "p_fmc0_tx_sysref_n"] ;

#--------------------------------------------------------------------------------------------------------
#   p_fmc0_tx_refclk_p      : in    std_logic;
#   p_fmc0_tx_refclk_n      : in    std_logic;
#--------------------------------------------------------------------------------------------------------
# IBUFDS_GTE4
set_property PACKAGE_PIN L8     [get_ports "p_fmc0_tx_refclk_p"] ;
set_property PACKAGE_PIN L7     [get_ports "p_fmc0_tx_refclk_n"] ;

#--------------------------------------------------------------------------------------------------------
# -- Differential JESD outputs for FMC0. 8 lanes in 4 links
# -- PACKAGE_PIN constraints are not needed since the JESD Phy requires the setting of the first
#    transceiver location and the other seven are placed relative to that.
#    The FMC0 transcievers start at X1Y4 (R4,R3) and go up to X1Y11 (
#--------------------------------------------------------------------------------------------------------
#   p_fmc0_txp_out          : out   std_logic_vector( 7 downto 0);  
#   p_fmc0_txn_out          : out   std_logic_vector( 7 downto 0);
#--------------------------------------------------------------------------------------------------------
#set_property PACKAGE_PIN G4     [get_ports "p_fmc0_txp_out[0]"] ;# DAC0_LANE0_P
#set_property PACKAGE_PIN G3     [get_ports "p_fmc0_txn_out[0]"] ;# DAC0_LANE0_N
#set_property PACKAGE_PIN H6     [get_ports "p_fmc0_txp_out[1]"] ;# DAC1_LANE0_P
#set_property PACKAGE_PIN H5     [get_ports "p_fmc0_txn_out[1]"] ;# DAC1_LANE0_N
#set_property PACKAGE_PIN F6     [get_ports "p_fmc0_txp_out[2]"] ;# DAC2_LANE0_P
#set_property PACKAGE_PIN F5     [get_ports "p_fmc0_txn_out[2]"] ;# DAC2_LANE0_N
#set_property PACKAGE_PIN K6     [get_ports "p_fmc0_txp_out[3]"] ;# DAC3_LANE0_P
#set_property PACKAGE_PIN K5     [get_ports "p_fmc0_txn_out[3]"] ;# DAC3_LANE0_N
#set_property PACKAGE_PIN M6     [get_ports "p_fmc0_txp_out[4]"] ;# DAC0_LANE1_P
#set_property PACKAGE_PIN M5     [get_ports "p_fmc0_txn_out[4]"] ;# DAC0_LANE1_N
#set_property PACKAGE_PIN P6     [get_ports "p_fmc0_txp_out[5]"] ;# DAC1_LANE1_P
#set_property PACKAGE_PIN P5     [get_ports "p_fmc0_txn_out[5]"] ;# DAC1_LANE1_N
#set_property PACKAGE_PIN R4     [get_ports "p_fmc0_txp_out[6]"] ;# DAC2_LANE1_P
#set_property PACKAGE_PIN R3     [get_ports "p_fmc0_txn_out[6]"] ;# DAC2_LANE1_N
#set_property PACKAGE_PIN N4     [get_ports "p_fmc0_txp_out[7]"] ;# DAC3_LANE1_P
#set_property PACKAGE_PIN N3     [get_ports "p_fmc0_txn_out[7]"] ;# DAC3_LANE1_N

#--------------------------------------------------------------------------------------------------------
# Connections for J4. Abaco DAC board with JESD interface FMC1
#--------------------------------------------------------------------------------------------------------
#   p_fmc1_tx_sync_p        : in    std_logic_vector( 3 downto 0);  -- LVS sync for each link
#   p_fmc1_tx_sync_n        : in    std_logic_vector( 3 downto 0);
#--------------------------------------------------------------------------------------------------------
set_property IOSTANDARD  LVDS   [get_ports "p_fmc1_tx_sync_p[*]"] ; 
set_property PACKAGE_PIN AD2    [get_ports "p_fmc1_tx_sync_p[0]"] ;
set_property PACKAGE_PIN AD1    [get_ports "p_fmc1_tx_sync_n[0]"] ;
set_property PACKAGE_PIN AH1    [get_ports "p_fmc1_tx_sync_p[1]"] ;
set_property PACKAGE_PIN AJ1    [get_ports "p_fmc1_tx_sync_n[1]"] ;
set_property PACKAGE_PIN AG3    [get_ports "p_fmc1_tx_sync_p[2]"] ;
set_property PACKAGE_PIN AH3    [get_ports "p_fmc1_tx_sync_n[2]"] ;
set_property PACKAGE_PIN AF2    [get_ports "p_fmc1_tx_sync_p[3]"] ;
set_property PACKAGE_PIN AF1    [get_ports "p_fmc1_tx_sync_n[3]"] ;

#--------------------------------------------------------------------------------------------------------
#   p_fmc1_tx_sysref_p      : in    std_logic;
#   p_fmc1_tx_sysref_n      : in    std_logic;
#--------------------------------------------------------------------------------------------------------
# IBUFDS
set_property IOSTANDARD  LVDS   [get_ports "p_fmc1_tx_sysref_p"] ; 
set_property PACKAGE_PIN P10    [get_ports "p_fmc1_tx_sysref_p"] ;
set_property PACKAGE_PIN P9     [get_ports "p_fmc1_tx_sysref_n"] ;

#--------------------------------------------------------------------------------------------------------
#   p_fmc1_tx_refclk_p      : in    std_logic;
#   p_fmc1_tx_refclk_n      : in    std_logic;
#--------------------------------------------------------------------------------------------------------
# IBUFDS_GTE4
set_property PACKAGE_PIN G27    [get_ports "p_fmc1_tx_refclk_p"] ;
set_property PACKAGE_PIN G28    [get_ports "p_fmc1_tx_refclk_n"] ;

#--------------------------------------------------------------------------------------------------------
#  -- Differential JESD outputs for FMC1. 8 lanes in 4 links
# -- PACKAGE_PIN constraints are not needed since the JESD Phy requires the setting of the first
#    transceiver location and the other seven are placed relative to that.
#--------------------------------------------------------------------------------------------------------
#   p_fmc1_txp_out          : out   std_logic_vector( 7 downto 0);  
#   p_fmc1_txn_out          : out   std_logic_vector( 7 downto 0);
#--------------------------------------------------------------------------------------------------------
#set_property PACKAGE_PIN F29     [get_ports "p_fmc1_txp_out[0]"] ;
#set_property PACKAGE_PIN F30     [get_ports "p_fmc1_txn_out[0]"] ;
#set_property PACKAGE_PIN D29     [get_ports "p_fmc1_txp_out[1]"] ;
#set_property PACKAGE_PIN D30     [get_ports "p_fmc1_txn_out[1]"] ;
#set_property PACKAGE_PIN B29     [get_ports "p_fmc1_txp_out[2]"] ;
#set_property PACKAGE_PIN B30     [get_ports "p_fmc1_txn_out[2]"] ;
#set_property PACKAGE_PIN A31     [get_ports "p_fmc1_txp_out[3]"] ;
#set_property PACKAGE_PIN A32     [get_ports "p_fmc1_txn_out[3]"] ;
#set_property PACKAGE_PIN K29     [get_ports "p_fmc1_txp_out[4]"] ;
#set_property PACKAGE_PIN K30     [get_ports "p_fmc1_txn_out[4]"] ;
#set_property PACKAGE_PIN J31     [get_ports "p_fmc1_txp_out[5]"] ;
#set_property PACKAGE_PIN J32     [get_ports "p_fmc1_txn_out[5]"] ;
#set_property PACKAGE_PIN H29     [get_ports "p_fmc1_txp_out[6]"] ;
#set_property PACKAGE_PIN H30     [get_ports "p_fmc1_txn_out[6]"] ;
#set_property PACKAGE_PIN G31     [get_ports "p_fmc1_txp_out[7]"] ;
#set_property PACKAGE_PIN G32     [get_ports "p_fmc1_txn_out[7]"] ;

