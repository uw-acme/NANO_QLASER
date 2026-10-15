#--------------------------------------------------------------------------------------------------------
# Pin constraint file for ZCU102 board
#--------------------------------------------------------------------------------------------------------
#
create_clock -period 10.000 -name fmc0_tx_sysref -waveform {0.000 5.000} [get_ports p_fmc0_tx_sysref_p]
create_clock -period 10.000 -name fmc0_tx_refclk -waveform {0.000 5.000} [get_ports p_fmc0_tx_refclk_p]
#
#--------------------------------------------------------------------------------------------------------
# CPU reset button
#--------------------------------------------------------------------------------------------------------
set_property PACKAGE_PIN AM13 [get_ports p_reset]
set_property IOSTANDARD LVCMOS33 [get_ports p_reset]

#--------------------------------------------------------------------------------------------------------
## Buttons  Five buttons arranged at 4 cardinal points and one in the center
#--------------------------------------------------------------------------------------------------------
set_property IOSTANDARD LVCMOS33 [get_ports p_btn*]
set_property PACKAGE_PIN AE14 [get_ports p_btn_e]
set_property PACKAGE_PIN AE15 [get_ports p_btn_s]
set_property PACKAGE_PIN AG15 [get_ports p_btn_n]
set_property PACKAGE_PIN AF15 [get_ports p_btn_w]
set_property PACKAGE_PIN AG13 [get_ports p_btn_c]

#--------------------------------------------------------------------------------------------------------
## LEDs
#--------------------------------------------------------------------------------------------------------
set_property IOSTANDARD LVCMOS33 [get_ports {p_leds[*]}]
set_property PACKAGE_PIN AG14 [get_ports {p_leds[0]}]
set_property PACKAGE_PIN AF13 [get_ports {p_leds[1]}]
set_property PACKAGE_PIN AE13 [get_ports {p_leds[2]}]
set_property PACKAGE_PIN AJ14 [get_ports {p_leds[3]}]
set_property PACKAGE_PIN AJ15 [get_ports {p_leds[4]}]
set_property PACKAGE_PIN AH13 [get_ports {p_leds[5]}]
set_property PACKAGE_PIN AH14 [get_ports {p_leds[6]}]
set_property PACKAGE_PIN AL12 [get_ports {p_leds[7]}]


#--------------------------------------------------------------------------------------------------------
## Pmod Header J55
#--------------------------------------------------------------------------------------------------------
set_property PACKAGE_PIN A20 [get_ports p_dc0_cs_n]
set_property IOSTANDARD LVCMOS33 [get_ports p_dc0_cs_n]
set_property PACKAGE_PIN B20 [get_ports p_dc0_mosi]
set_property IOSTANDARD LVCMOS33 [get_ports p_dc0_mosi]
# set_property PACKAGE_PIN A22      [get_ports "p_dc0_nc"] ;# Bank  47 VCCO - VCC3V3 PMOD0_2  - IO_L11N_AD1N_47
# set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc0_nc"] ;# Bank  47 VCCO - VCC3V3 PMOD0_2  - IO_L11N_AD1N_47
set_property PACKAGE_PIN A21 [get_ports p_dc0_sclk]
set_property IOSTANDARD LVCMOS33 [get_ports p_dc0_sclk]
set_property PACKAGE_PIN B21 [get_ports p_dc1_cs_n]
set_property IOSTANDARD LVCMOS33 [get_ports p_dc1_cs_n]
set_property PACKAGE_PIN C21 [get_ports p_dc1_mosi]
set_property IOSTANDARD LVCMOS33 [get_ports p_dc1_mosi]
# set_property PACKAGE_PIN C22      [get_ports "p_dc1_nc"] ;# Bank  47 VCCO - VCC3V3 PMOD0_6  - IO_L9N_AD3N_47
# set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc1_nc"] ;# Bank  47 VCCO - VCC3V3 PMOD0_6  - IO_L9N_AD3N_47
set_property PACKAGE_PIN D21 [get_ports p_dc1_sclk]
set_property IOSTANDARD LVCMOS33 [get_ports p_dc1_sclk]

#--------------------------------------------------------------------------------------------------------
## Pmod Header J87
#--------------------------------------------------------------------------------------------------------
set_property PACKAGE_PIN D20 [get_ports p_dc2_cs_n]
set_property IOSTANDARD LVCMOS33 [get_ports p_dc2_cs_n]
set_property PACKAGE_PIN E20 [get_ports p_dc2_mosi]
set_property IOSTANDARD LVCMOS33 [get_ports p_dc2_mosi]
#set_property PACKAGE_PIN D22      [get_ports "p_dc2_nc"]  ;# Bank  47 VCCO - VCC3V3 PMOD1_2  - IO_L7N_HDGC_AD5N_47
#set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc2_nc"]  ;# Bank  47 VCCO - VCC3V3 PMOD1_2  - IO_L7N_HDGC_AD5N_47
set_property PACKAGE_PIN E22 [get_ports p_dc2_sclk]
set_property IOSTANDARD LVCMOS33 [get_ports p_dc2_sclk]
set_property PACKAGE_PIN F20 [get_ports p_dc3_cs_n]
set_property IOSTANDARD LVCMOS33 [get_ports p_dc3_cs_n]
set_property PACKAGE_PIN G20 [get_ports p_dc3_mosi]
set_property IOSTANDARD LVCMOS33 [get_ports p_dc3_mosi]
#set_property PACKAGE_PIN J20      [get_ports "p_dc3_nc"]   ;# Bank  47 VCCO - VCC3V3 PMOD1_6  - IO_L7N_HDGC_AD5N_47
#set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc3_nc"]   ;# Bank  47 VCCO - VCC3V3 PMOD1_6  - IO_L7N_HDGC_AD5N_47
set_property PACKAGE_PIN J19 [get_ports p_dc3_sclk]
set_property IOSTANDARD LVCMOS33 [get_ports p_dc3_sclk]

#--------------------------------------------------------------------------------------------------------
# The ZCU102 evaluation board provides a 2x12 male header prototype header J3 which
# makes ten Bank 50 GPIO connections available. Figure 3-30 shows connector J3 with its
# MPSoC (U1) Bank 50 connections.
#--------------------------------------------------------------------------------------------------------
set_property IOSTANDARD LVCMOS33 [get_ports {p_debug_out[*]}]
set_property PACKAGE_PIN J15 [get_ports {p_debug_out[0]}]
set_property PACKAGE_PIN J16 [get_ports {p_debug_out[1]}]
set_property PACKAGE_PIN G16 [get_ports {p_debug_out[2]}]
set_property PACKAGE_PIN H16 [get_ports {p_debug_out[3]}]
set_property PACKAGE_PIN H14 [get_ports {p_debug_out[4]}]
set_property PACKAGE_PIN J14 [get_ports {p_debug_out[5]}]
set_property PACKAGE_PIN G14 [get_ports {p_debug_out[6]}]
set_property PACKAGE_PIN G15 [get_ports {p_debug_out[7]}]

#--------------------------------------------------------------------------------------------------------
# Connections for J5. Abaco DAC board with JESD interface
#--------------------------------------------------------------------------------------------------------
#   p_fmc1_tx_sync_p        : in    std_logic_vector( 3 downto 0);  -- LVS sync for each link
#   p_fmc0_tx_sync_n        : in    std_logic_vector( 3 downto 0);
#--------------------------------------------------------------------------------------------------------
set_property PACKAGE_PIN V2  [get_ports {p_fmc0_tx_sync_p[0]}]
set_property PACKAGE_PIN V1  [get_ports {p_fmc0_tx_sync_n[0]}]
set_property PACKAGE_PIN Y2  [get_ports {p_fmc0_tx_sync_p[1]}]
set_property PACKAGE_PIN Y1  [get_ports {p_fmc0_tx_sync_n[1]}]
set_property PACKAGE_PIN AA2 [get_ports {p_fmc0_tx_sync_p[2]}]
set_property PACKAGE_PIN AA1 [get_ports {p_fmc0_tx_sync_n[2]}]
set_property PACKAGE_PIN AB3 [get_ports {p_fmc0_tx_sync_p[3]}]
set_property PACKAGE_PIN AC3 [get_ports {p_fmc0_tx_sync_n[3]}]

#--------------------------------------------------------------------------------------------------------
#   p_fmc0_tx_sysref_p      : in    std_logic;
#   p_fmc0_tx_sysref_n      : in    std_logic;
#--------------------------------------------------------------------------------------------------------
set_property PACKAGE_PIN  T8     [get_ports {p_fmc0_tx_sysref_p}]
set_property PACKAGE_PIN  R8     [get_ports {p_fmc0_tx_sysref_n}]

#--------------------------------------------------------------------------------------------------------
#   p_fmc0_tx_refclk_p      : in    std_logic;
#   p_fmc0_tx_refclk_n      : in    std_logic;
#--------------------------------------------------------------------------------------------------------
set_property PACKAGE_PIN L7     [get_ports p_fmc0_tx_refclk_n]
set_property PACKAGE_PIN L8     [get_ports p_fmc0_tx_refclk_p]

#--------------------------------------------------------------------------------------------------------
#   -- Differential JESD outputs for FMC0. 8 lanes in 4 links
#--------------------------------------------------------------------------------------------------------
#   p_fmc0_txp_out          : out   std_logic_vector( 7 downto 0);
#   p_fmc0_txn_out          : out   std_logic_vector( 7 downto 0);
#--------------------------------------------------------------------------------------------------------
set_property PACKAGE_PIN G4     [get_ports {p_fmc0_txp_out[0]}]
set_property PACKAGE_PIN G3     [get_ports {p_fmc0_txn_out[0]}]
set_property PACKAGE_PIN H6     [get_ports {p_fmc0_txp_out[1]}]
set_property PACKAGE_PIN H5     [get_ports {p_fmc0_txn_out[1]}]
set_property PACKAGE_PIN F6     [get_ports {p_fmc0_txp_out[2]}]
set_property PACKAGE_PIN F5     [get_ports {p_fmc0_txn_out[2]}]
set_property PACKAGE_PIN K6     [get_ports {p_fmc0_txp_out[3]}]
set_property PACKAGE_PIN K5     [get_ports {p_fmc0_txn_out[3]}]
set_property PACKAGE_PIN M6     [get_ports {p_fmc0_txp_out[4]}]
set_property PACKAGE_PIN M5     [get_ports {p_fmc0_txn_out[4]}]
set_property PACKAGE_PIN P6     [get_ports {p_fmc0_txp_out[5]}]
set_property PACKAGE_PIN P5     [get_ports {p_fmc0_txn_out[5]}]
set_property PACKAGE_PIN R4     [get_ports {p_fmc0_txp_out[6]}]
set_property PACKAGE_PIN R3     [get_ports {p_fmc0_txn_out[6]}]
set_property PACKAGE_PIN N4     [get_ports {p_fmc0_txp_out[7]}]
set_property PACKAGE_PIN N3     [get_ports {p_fmc0_txn_out[7]}]



