## 300MHz Clock from USER_SI570
#set_property PACKAGE_PIN AL7      [get_ports "p_clk_n"] ;# Bank  64 VCCO - VCC1V2   - IO_L12N_T1U_N11_GC_64
#set_property IOSTANDARD  DIFF_SSTL12 [get_ports "p_clk_n"] ;# Bank  64 VCCO - VCC1V2   - IO_L12N_T1U_N11_GC_64
#set_property PACKAGE_PIN AL8      [get_ports "p_clk_p"] ;# Bank  64 VCCO - VCC1V2   - IO_L12P_T1U_N10_GC_64
#set_property IOSTANDARD  DIFF_SSTL12 [get_ports "p_clk_p"] ;# Bank  64 VCCO - VCC1V2   - IO_L12P_T1U_N10_GC_64

## Buttons SW_C
# set_property -dict {PACKAGE_PIN C17 IOSTANDARD LVCMOS33} [get_ports p_reset]

set_property PACKAGE_PIN AN14     [get_ports "p_reset"] ;# Bank  44 VCCO - VCC3V3   
set_property IOSTANDARD  LVCMOS33 [get_ports "p_reset"] ;# Bank  44 VCCO - VCC3V3   - IO_L10N_AD2N_44
## LEDs
set_property PACKAGE_PIN AG14     [get_ports "p_leds[0]"] ;# Bank  44 VCCO - VCC3V3   - IO_L10P_AD2P_44
set_property IOSTANDARD  LVCMOS33 [get_ports "p_leds[0]"] ;# Bank  44 VCCO - VCC3V3   - IO_L10P_AD2P_44
set_property PACKAGE_PIN AF13     [get_ports "p_leds[1]"] ;# Bank  44 VCCO - VCC3V3   - IO_L9N_AD3N_44
set_property IOSTANDARD  LVCMOS33 [get_ports "p_leds[1]"] ;# Bank  44 VCCO - VCC3V3   - IO_L9N_AD3N_44
set_property PACKAGE_PIN AE13     [get_ports "p_leds[2]"] ;# Bank  44 VCCO - VCC3V3   - IO_L9P_AD3P_44
set_property IOSTANDARD  LVCMOS33 [get_ports "p_leds[2]"] ;# Bank  44 VCCO - VCC3V3   - IO_L9P_AD3P_44
set_property PACKAGE_PIN AJ14     [get_ports "p_leds[3]"] ;# Bank  44 VCCO - VCC3V3   - IO_L8N_HDGC_AD4N_44
set_property IOSTANDARD  LVCMOS33 [get_ports "p_leds[3]"] ;# Bank  44 VCCO - VCC3V3   - IO_L8N_HDGC_AD4N_44
set_property PACKAGE_PIN AJ15     [get_ports "p_leds[4]"] ;# Bank  44 VCCO - VCC3V3   - IO_L8P_HDGC_AD4P_44
set_property IOSTANDARD  LVCMOS33 [get_ports "p_leds[4]"] ;# Bank  44 VCCO - VCC3V3   - IO_L8P_HDGC_AD4P_44
set_property PACKAGE_PIN AH13     [get_ports "p_leds[5]"] ;# Bank  44 VCCO - VCC3V3   - IO_L7N_HDGC_AD5N_44
set_property IOSTANDARD  LVCMOS33 [get_ports "p_leds[5]"] ;# Bank  44 VCCO - VCC3V3   - IO_L8P_HDGC_AD4P_44
set_property PACKAGE_PIN AH14     [get_ports "p_leds[6]"] ;# Bank  44 VCCO - VCC3V3
set_property IOSTANDARD  LVCMOS33 [get_ports "p_leds[6]"] ;# Bank  44 VCCO - VCC3V3
set_property PACKAGE_PIN AL12     [get_ports "p_leds[7]"] ;# Bank  44 VCCO - VCC3V3
set_property IOSTANDARD  LVCMOS33 [get_ports "p_leds[7]"] ;# Bank  44 VCCO - VCC3V3

# set_property -dict {PACKAGE_PIN A17 IOSTANDARD LVCMOS33} [get_ports {p_leds0_rgb[0]}]
# set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS33} [get_ports {p_leds0_rgb[1]}]
# set_property -dict {PACKAGE_PIN B17 IOSTANDARD LVCMOS33} [get_ports {p_leds0_rgb[2]}]

# set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33} [get_ports {p_leds1_rgb[0]}]
# set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS33} [get_ports {p_leds1_rgb[1]}]
# set_property -dict {PACKAGE_PIN A19 IOSTANDARD LVCMOS33} [get_ports {p_leds1_rgb[2]}]


## Pmod Header J55
set_property PACKAGE_PIN A20      [get_ports "p_dc0_cs_n"] ;# Bank  47 VCCO - VCC3V3   - IO_L12N_AD0N_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc0_cs_n"] ;# Bank  47 VCCO - VCC3V3   - IO_L12N_AD0N_47
set_property PACKAGE_PIN B20      [get_ports "p_dc0_mosi"] ;# Bank  47 VCCO - VCC3V3   - IO_L12P_AD0P_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc0_mosi"] ;# Bank  47 VCCO - VCC3V3   - IO_L12P_AD0P_47
# set_property PACKAGE_PIN A22      [get_ports "p_dc0_nc"] ;# Bank  47 VCCO - VCC3V3   - IO_L11N_AD1N_47
# set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc0_nc"] ;# Bank  47 VCCO - VCC3V3   - IO_L11N_AD1N_47
set_property PACKAGE_PIN A21      [get_ports "p_dc0_sclk"] ;# Bank  47 VCCO - VCC3V3   - IO_L11P_AD1P_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc0_sclk"] ;# Bank  47 VCCO - VCC3V3   - IO_L11P_AD1P_47
set_property PACKAGE_PIN B21      [get_ports "p_dc1_cs_n"] ;# Bank  47 VCCO - VCC3V3   - IO_L10N_AD2N_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc1_cs_n"] ;# Bank  47 VCCO - VCC3V3   - IO_L10N_AD2N_47
set_property PACKAGE_PIN C21      [get_ports "p_dc1_mosi"] ;# Bank  47 VCCO - VCC3V3   - IO_L10P_AD2P_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc1_mosi"] ;# Bank  47 VCCO - VCC3V3   - IO_L10P_AD2P_47
# set_property PACKAGE_PIN C22      [get_ports "p_dc1_nc"] ;# Bank  47 VCCO - VCC3V3   - IO_L9N_AD3N_47
# set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc1_nc"] ;# Bank  47 VCCO - VCC3V3   - IO_L9N_AD3N_47
set_property PACKAGE_PIN D21      [get_ports "p_dc1_sclk"] ;# Bank  47 VCCO - VCC3V3   - IO_L9P_AD3P_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc1_sclk"] ;# Bank  47 VCCO - VCC3V3   - IO_L9P_AD3P_47

## Pmod Header J87
set_property PACKAGE_PIN D20      [get_ports "p_dc2_cs_n"] ;# Bank  47 VCCO - VCC3V3   - IO_L8N_HDGC_AD4N_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc2_cs_n"] ;# Bank  47 VCCO - VCC3V3   - IO_L8N_HDGC_AD4N_47
set_property PACKAGE_PIN E20      [get_ports "p_dc2_mosi"] ;# Bank  47 VCCO - VCC3V3   - IO_L8P_HDGC_AD4P_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc2_mosi"] ;# Bank  47 VCCO - VCC3V3   - IO_L8P_HDGC_AD4P_47
set_property PACKAGE_PIN E22      [get_ports "p_dc2_sclk"] ;# Bank  47 VCCO - VCC3V3   - IO_L7N_HDGC_AD5N_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc2_sclk"] ;# Bank  47 VCCO - VCC3V3   - IO_L7N_HDGC_AD5N_47

set_property PACKAGE_PIN F20      [get_ports "p_dc3_cs_n"] ;# Bank  47 VCCO - VCC3V3   - IO_L8N_HDGC_AD4N_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc3_cs_n"] ;# Bank  47 VCCO - VCC3V3   - IO_L8N_HDGC_AD4N_47
set_property PACKAGE_PIN G20      [get_ports "p_dc3_mosi"] ;# Bank  47 VCCO - VCC3V3   - IO_L8P_HDGC_AD4P_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc3_mosi"] ;# Bank  47 VCCO - VCC3V3   - IO_L8P_HDGC_AD4P_47
set_property PACKAGE_PIN J19      [get_ports "p_dc3_sclk"] ;# Bank  47 VCCO - VCC3V3   - IO_L7N_HDGC_AD5N_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc3_sclk"] ;# Bank  47 VCCO - VCC3V3   - IO_L7N_HDGC_AD5N_47

# UART
#set_property PACKAGE_PIN E13      [get_ports "p_serial_rxd"] ;# Bank  49 VCCO - VCC3V3   - IO_L12N_AD8N_49
#set_property IOSTANDARD  LVCMOS33 [get_ports "p_serial_rxd"] ;# Bank  49 VCCO - VCC3V3   - IO_L12N_AD8N_49
#set_property PACKAGE_PIN F13      [get_ports "p_serial_txd"] ;# Bank  49 VCCO - VCC3V3   - IO_L12P_AD8P_49
#set_property IOSTANDARD  LVCMOS33 [get_ports "p_serial_txd"] ;# Bank  49 VCCO - VCC3V3   - IO_L12P_AD8P_49

# UART Debug (unsure, maybe just indicator LEDs?)
#set_property PACKAGE_PIN D12      [get_ports "p_debug_out[0]"] ;# Bank  49 VCCO - VCC3V3   - IO_L11N_AD9N_49
#set_property IOSTANDARD  LVCMOS33 [get_ports "p_debug_out[0]"] ;# Bank  49 VCCO - VCC3V3   - IO_L11N_AD9N_49
#set_property PACKAGE_PIN E12      [get_ports "p_debug_out[1]"] ;# Bank  49 VCCO - VCC3V3   - IO_L11P_AD9P_49
#set_property IOSTANDARD  LVCMOS33 [get_ports "p_debug_out[1]"] ;# Bank  49 VCCO - VCC3V3   - IO_L11P_AD9P_49


