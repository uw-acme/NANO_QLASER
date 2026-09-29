#--------------------------------------------------------------------------------------------------------
# Pin constraint file for ZCU102 board
#--------------------------------------------------------------------------------------------------------
#
#--------------------------------------------------------------------------------------------------------
# CPU reset button
#--------------------------------------------------------------------------------------------------------
set_property PACKAGE_PIN AM13     [get_ports "p_reset"] ;# Bank  44 VCCO - VCC3V3   - IO_L4N_AD8N_44
set_property IOSTANDARD  LVCMOS33 [get_ports "p_reset"] ;# Bank  44 VCCO - VCC3V3   - IO_L4N_AD8N_44

#--------------------------------------------------------------------------------------------------------
## Buttons  Five buttons arranged at 4 cardinal points and one in the center
#--------------------------------------------------------------------------------------------------------
set_property IOSTANDARD  LVCMOS33 [get_ports "p_btn*"] ;# Bank  44 VCCO - VCC3V3 
set_property PACKAGE_PIN AE14     [get_ports "p_btn_e"] ;# Bank  44 VCCO - VCC3V3 GPIO_SW_E  - IO_L12N_AD0N_44
set_property PACKAGE_PIN AE15     [get_ports "p_btn_s"] ;# Bank  44 VCCO - VCC3V3 GPIO_SW_S  - IO_L12P_AD0P_44
set_property PACKAGE_PIN AG15     [get_ports "p_btn_n"] ;# Bank  44 VCCO - VCC3V3 GPIO_SW_N  - IO_L11N_AD1N_44
set_property PACKAGE_PIN AF15     [get_ports "p_btn_w"] ;# Bank  44 VCCO - VCC3V3 GPIO_SW_W  - IO_L11P_AD1P_44
set_property PACKAGE_PIN AG13     [get_ports "p_btn_c"] ;# Bank  44 VCCO - VCC3V3 GPIO_SW_C  - IO_L10N_AD2N_44

#--------------------------------------------------------------------------------------------------------
## LEDs
#--------------------------------------------------------------------------------------------------------
set_property IOSTANDARD  LVCMOS33 [get_ports "p_leds[*]"] ;# Bank  44 VCCO - VCC3V3
set_property PACKAGE_PIN AG14     [get_ports "p_leds[0]"] ;# Bank  44 VCCO - VCC3V3   - IO_L10P_AD2P_44
set_property PACKAGE_PIN AF13     [get_ports "p_leds[1]"] ;# Bank  44 VCCO - VCC3V3   - IO_L9N_AD3N_44
set_property PACKAGE_PIN AE13     [get_ports "p_leds[2]"] ;# Bank  44 VCCO - VCC3V3   - IO_L9P_AD3P_44
set_property PACKAGE_PIN AJ14     [get_ports "p_leds[3]"] ;# Bank  44 VCCO - VCC3V3   - IO_L8N_HDGC_AD4N_44
set_property PACKAGE_PIN AJ15     [get_ports "p_leds[4]"] ;# Bank  44 VCCO - VCC3V3   - IO_L8P_HDGC_AD4P_44
set_property PACKAGE_PIN AH13     [get_ports "p_leds[5]"] ;# Bank  44 VCCO - VCC3V3   - IO_L7N_HDGC_AD5N_44
set_property PACKAGE_PIN AH14     [get_ports "p_leds[6]"] ;# Bank  44 VCCO - VCC3V3   - IO_L7P_HDGC_AD5P_44
set_property PACKAGE_PIN AL12     [get_ports "p_leds[7]"] ;# Bank  44 VCCO - VCC3V3   - IO_L6N_HDGC_AD6N_44


#--------------------------------------------------------------------------------------------------------
## Pmod Header J55
#--------------------------------------------------------------------------------------------------------
set_property PACKAGE_PIN A20      [get_ports "p_dc0_cs_n"] ;# Bank  47 VCCO - VCC3V3 PMOD0_0  - IO_L12N_AD0N_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc0_cs_n"] ;# Bank  47 VCCO - VCC3V3 PMOD0_0  - IO_L12N_AD0N_47
set_property PACKAGE_PIN B20      [get_ports "p_dc0_mosi"] ;# Bank  47 VCCO - VCC3V3 PMOD0_1  - IO_L12P_AD0P_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc0_mosi"] ;# Bank  47 VCCO - VCC3V3 PMOD0_1  - IO_L12P_AD0P_47
# set_property PACKAGE_PIN A22      [get_ports "p_dc0_nc"] ;# Bank  47 VCCO - VCC3V3 PMOD0_2  - IO_L11N_AD1N_47
# set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc0_nc"] ;# Bank  47 VCCO - VCC3V3 PMOD0_2  - IO_L11N_AD1N_47
set_property PACKAGE_PIN A21      [get_ports "p_dc0_sclk"] ;# Bank  47 VCCO - VCC3V3 PMOD0_3  - IO_L11P_AD1P_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc0_sclk"] ;# Bank  47 VCCO - VCC3V3 PMOD0_3  - IO_L11P_AD1P_47
set_property PACKAGE_PIN B21      [get_ports "p_dc1_cs_n"] ;# Bank  47 VCCO - VCC3V3 PMOD0_4  - IO_L10N_AD2N_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc1_cs_n"] ;# Bank  47 VCCO - VCC3V3 PMOD0_4  - IO_L10N_AD2N_47
set_property PACKAGE_PIN C21      [get_ports "p_dc1_mosi"] ;# Bank  47 VCCO - VCC3V3 PMOD0_5  - IO_L10P_AD2P_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc1_mosi"] ;# Bank  47 VCCO - VCC3V3 PMOD0_5  - IO_L10P_AD2P_47
# set_property PACKAGE_PIN C22      [get_ports "p_dc1_nc"] ;# Bank  47 VCCO - VCC3V3 PMOD0_6  - IO_L9N_AD3N_47
# set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc1_nc"] ;# Bank  47 VCCO - VCC3V3 PMOD0_6  - IO_L9N_AD3N_47
set_property PACKAGE_PIN D21      [get_ports "p_dc1_sclk"] ;# Bank  47 VCCO - VCC3V3 PMOD0_7  - IO_L9P_AD3P_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc1_sclk"] ;# Bank  47 VCCO - VCC3V3 PMOD0_7  - IO_L9P_AD3P_47

#--------------------------------------------------------------------------------------------------------
## Pmod Header J87
#--------------------------------------------------------------------------------------------------------
set_property PACKAGE_PIN D20      [get_ports "p_dc2_cs_n"] ;# Bank  47 VCCO - VCC3V3 PMOD1_0  - IO_L8N_HDGC_AD4N_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc2_cs_n"] ;# Bank  47 VCCO - VCC3V3 PMOD1_0  - IO_L8N_HDGC_AD4N_47
set_property PACKAGE_PIN E20      [get_ports "p_dc2_mosi"] ;# Bank  47 VCCO - VCC3V3 PMOD1_1  - IO_L8P_HDGC_AD4P_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc2_mosi"] ;# Bank  47 VCCO - VCC3V3 PMOD1_1  - IO_L8P_HDGC_AD4P_47
#set_property PACKAGE_PIN D22      [get_ports "p_dc2_nc"]  ;# Bank  47 VCCO - VCC3V3 PMOD1_2  - IO_L7N_HDGC_AD5N_47
#set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc2_nc"]  ;# Bank  47 VCCO - VCC3V3 PMOD1_2  - IO_L7N_HDGC_AD5N_47
set_property PACKAGE_PIN E22      [get_ports "p_dc2_sclk"] ;# Bank  47 VCCO - VCC3V3 PMOD1_3  - IO_L7N_HDGC_AD5N_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc2_sclk"] ;# Bank  47 VCCO - VCC3V3 PMOD1_3  - IO_L7N_HDGC_AD5N_47
set_property PACKAGE_PIN F20      [get_ports "p_dc3_cs_n"] ;# Bank  47 VCCO - VCC3V3 PMOD1_4  - IO_L8N_HDGC_AD4N_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc3_cs_n"] ;# Bank  47 VCCO - VCC3V3 PMOD1_4  - IO_L8N_HDGC_AD4N_47
set_property PACKAGE_PIN G20      [get_ports "p_dc3_mosi"] ;# Bank  47 VCCO - VCC3V3 PMOD1_5  - IO_L8P_HDGC_AD4P_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc3_mosi"] ;# Bank  47 VCCO - VCC3V3 PMOD1_5  - IO_L8P_HDGC_AD4P_47
#set_property PACKAGE_PIN J20      [get_ports "p_dc3_nc"]   ;# Bank  47 VCCO - VCC3V3 PMOD1_6  - IO_L7N_HDGC_AD5N_47
#set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc3_nc"]   ;# Bank  47 VCCO - VCC3V3 PMOD1_6  - IO_L7N_HDGC_AD5N_47
set_property PACKAGE_PIN J19      [get_ports "p_dc3_sclk"] ;# Bank  47 VCCO - VCC3V3 PMOD1_7  - IO_L7N_HDGC_AD5N_47
set_property IOSTANDARD  LVCMOS33 [get_ports "p_dc3_sclk"] ;# Bank  47 VCCO - VCC3V3 PMOD1_7  - IO_L7N_HDGC_AD5N_47

#--------------------------------------------------------------------------------------------------------
# The ZCU102 evaluation board provides a 2x12 male header prototype header J3 which
# makes ten Bank 50 GPIO connections available. Figure 3-30 shows connector J3 with its
# MPSoC (U1) Bank 50 connections.
#--------------------------------------------------------------------------------------------------------
set_property IOSTANDARD  LVCMOS33 [get_ports "p_debug_out[*]"] ;# Bank  50 VCCO - VCC3V3  
set_property PACKAGE_PIN J15      [get_ports "p_debug_out[0]"] ;# Bank  50 VCCO - VCC3V3   - IO_L12N_AD8N_50
set_property PACKAGE_PIN J16      [get_ports "p_debug_out[1]"] ;# Bank  50 VCCO - VCC3V3   - IO_L12P_AD8P_50
set_property PACKAGE_PIN G16      [get_ports "p_debug_out[2]"] ;# Bank  50 VCCO - VCC3V3   - IO_L11N_AD9N_50
set_property PACKAGE_PIN H16      [get_ports "p_debug_out[3]"] ;# Bank  50 VCCO - VCC3V3   - IO_L11P_AD9P_50
set_property PACKAGE_PIN H14      [get_ports "p_debug_out[4]"] ;# Bank  50 VCCO - VCC3V3   - IO_L10N_AD10N_50
set_property PACKAGE_PIN J14      [get_ports "p_debug_out[5]"] ;# Bank  50 VCCO - VCC3V3   - IO_L10P_AD10P_50
set_property PACKAGE_PIN G14      [get_ports "p_debug_out[6]"] ;# Bank  50 VCCO - VCC3V3   - IO_L9N_AD11N_50
set_property PACKAGE_PIN G15      [get_ports "p_debug_out[7]"] ;# Bank  50 VCCO - VCC3V3   - IO_L9P_AD11P_50
#set_property PACKAGE_PIN G13      [get_ports "p_debug_out[8]"] ;# Bank  50 VCCO - VCC3V3   - IO_L8N_HDGC_50
#set_property PACKAGE_PIN H13      [get_ports "p_debug_out[9]"] ;# Bank  50 VCCO - VCC3V3   - IO_L8P_HDGC_50

