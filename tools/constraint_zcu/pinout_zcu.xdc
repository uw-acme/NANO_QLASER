## 300MHz Clock from USER_SI570
#set_property PACKAGE_PIN AL7      [get_ports "p_clk_n"] ;# Bank  64 VCCO - VCC1V2   - IO_L12N_T1U_N11_GC_64
#set_property IOSTANDARD  DIFF_SSTL12 [get_ports "p_clk_n"] ;# Bank  64 VCCO - VCC1V2   - IO_L12N_T1U_N11_GC_64
#set_property PACKAGE_PIN AL8      [get_ports "p_clk_p"] ;# Bank  64 VCCO - VCC1V2   - IO_L12P_T1U_N10_GC_64
#set_property IOSTANDARD  DIFF_SSTL12 [get_ports "p_clk_p"] ;# Bank  64 VCCO - VCC1V2   - IO_L12P_T1U_N10_GC_64

# TODO: EricToGeoff: can we just wildcard p_* for all "IOSTANDARD  LVCMOS33"?

set_property PACKAGE_PIN AN14 [get_ports p_reset]
set_property IOSTANDARD LVCMOS33 [get_ports p_reset]
## LEDs
set_property IOSTANDARD LVCMOS33 [get_ports {p_leds[*]}]
set_property PACKAGE_PIN AG14 [get_ports {p_leds[0]}]
set_property PACKAGE_PIN AF13 [get_ports {p_leds[1]}]
set_property PACKAGE_PIN AE13 [get_ports {p_leds[2]}]
set_property PACKAGE_PIN AJ14 [get_ports {p_leds[3]}]
set_property PACKAGE_PIN AJ15 [get_ports {p_leds[4]}]
set_property PACKAGE_PIN AH13 [get_ports {p_leds[5]}]
set_property PACKAGE_PIN AH14 [get_ports {p_leds[6]}]
set_property PACKAGE_PIN AL12 [get_ports {p_leds[7]}]

# set_property -dict {PACKAGE_PIN A17 IOSTANDARD LVCMOS33} [get_ports {p_leds0_rgb[0]}]
# set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS33} [get_ports {p_leds0_rgb[1]}]
# set_property -dict {PACKAGE_PIN B17 IOSTANDARD LVCMOS33} [get_ports {p_leds0_rgb[2]}]

# set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33} [get_ports {p_leds1_rgb[0]}]
# set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS33} [get_ports {p_leds1_rgb[1]}]
# set_property -dict {PACKAGE_PIN A19 IOSTANDARD LVCMOS33} [get_ports {p_leds1_rgb[2]}]

# Buttons
set_property IOSTANDARD LVCMOS33 [get_ports p_btn*]
set_property PACKAGE_PIN AE14 [get_ports p_btn_e]
set_property PACKAGE_PIN AE15 [get_ports p_btn_s]
set_property PACKAGE_PIN AG15 [get_ports p_btn_n]
set_property PACKAGE_PIN AF15 [get_ports p_btn_w]
set_property PACKAGE_PIN AG13 [get_ports p_btn_c]


## Pmod Header J55
set_property PACKAGE_PIN A20 [get_ports p_dc0_cs_n]
set_property IOSTANDARD LVCMOS33 [get_ports p_dc0_cs_n]
set_property PACKAGE_PIN B20 [get_ports p_dc0_mosi]
set_property IOSTANDARD LVCMOS33 [get_ports p_dc0_mosi]
# set_property PACKAGE_PIN A22      [get_ports "p_dc0_nc"] ;# Bank  47 VCCO - VCC3V3   - IO_L11N_AD1N_47
# set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc0_nc"] ;# Bank  47 VCCO - VCC3V3   - IO_L11N_AD1N_47
set_property PACKAGE_PIN A21 [get_ports p_dc0_sclk]
set_property IOSTANDARD LVCMOS33 [get_ports p_dc0_sclk]
set_property PACKAGE_PIN B21 [get_ports p_dc1_cs_n]
set_property IOSTANDARD LVCMOS33 [get_ports p_dc1_cs_n]
set_property PACKAGE_PIN C21 [get_ports p_dc1_mosi]
set_property IOSTANDARD LVCMOS33 [get_ports p_dc1_mosi]
# set_property PACKAGE_PIN C22      [get_ports "p_dc1_nc"] ;# Bank  47 VCCO - VCC3V3   - IO_L9N_AD3N_47
# set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc1_nc"] ;# Bank  47 VCCO - VCC3V3   - IO_L9N_AD3N_47
set_property PACKAGE_PIN D21 [get_ports p_dc1_sclk]
set_property IOSTANDARD LVCMOS33 [get_ports p_dc1_sclk]

## Pmod Header J87
set_property PACKAGE_PIN D20 [get_ports p_dc2_cs_n]
set_property IOSTANDARD LVCMOS33 [get_ports p_dc2_cs_n]
set_property PACKAGE_PIN E20 [get_ports p_dc2_mosi]
set_property IOSTANDARD LVCMOS33 [get_ports p_dc2_mosi]
set_property PACKAGE_PIN E22 [get_ports p_dc2_sclk]
set_property IOSTANDARD LVCMOS33 [get_ports p_dc2_sclk]

set_property PACKAGE_PIN F20 [get_ports p_dc3_cs_n]
set_property IOSTANDARD LVCMOS33 [get_ports p_dc3_cs_n]
set_property PACKAGE_PIN G20 [get_ports p_dc3_mosi]
set_property IOSTANDARD LVCMOS33 [get_ports p_dc3_mosi]
set_property PACKAGE_PIN J19 [get_ports p_dc3_sclk]
set_property IOSTANDARD LVCMOS33 [get_ports p_dc3_sclk]

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

# Debug GPIO @ header J3. (page 78 of the board documentation). Arranged to match the order of the pins on the header.
set_property IOSTANDARD LVCMOS33 [get_ports {p_debug_out[*]}]
set_property PACKAGE_PIN H14 [get_ports {p_debug_out[0]}]
set_property PACKAGE_PIN J14 [get_ports {p_debug_out[1]}]
set_property PACKAGE_PIN G14 [get_ports {p_debug_out[2]}]
set_property PACKAGE_PIN G15 [get_ports {p_debug_out[3]}]
set_property PACKAGE_PIN J15 [get_ports {p_debug_out[4]}]
set_property PACKAGE_PIN J16 [get_ports {p_debug_out[5]}]
set_property PACKAGE_PIN G16 [get_ports {p_debug_out[6]}]
set_property PACKAGE_PIN H16 [get_ports {p_debug_out[7]}]
set_property PACKAGE_PIN G13 [get_ports {p_debug_out[8]}]
set_property PACKAGE_PIN H13 [get_ports {p_debug_out[9]}]





