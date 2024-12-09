-------------------------------------------------------------------------------
-- Filename :   qlaser_addr_zcu102_pkg.vhd
-------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

--------------------------------------------------------------------------------
-- FPGA constant definitions
-------------------------------------------------------------------------------
package qlaser_addr_zcu102_pkg is

--------------------------------------------------------------------------------
-- FPGA Addresses
-- Main blocks. Decoded from upper 2 bits of address [17:16]
--------------------------------------------------------------------------------
constant ADR_BASE_DC            : std_logic_vector(17 downto 16) :=  "00";    -- Registers to load DC DAC values
constant ADR_BASE_PULSE         : std_logic_vector(17 downto 16) :=  "01";    -- RAMs for Pulse output start/stop times
constant ADR_BASE_MISC          : std_logic_vector(17 downto 16) :=  "10";    -- Misc, LEDs, switches, power control
constant ADR_BASE_SPARE         : std_logic_vector(17 downto 16) :=  "11";    -- 

-------------------------------------------------------------------------------------------------------------------------- 
-- 'DC' DAC block registers. 32 16-bit DAC outputs [5:3]
constant C_ADDR_CH_SPI0         : std_logic_vector(2 downto 0) := "000";
constant C_ADDR_CH_SPI1         : std_logic_vector(2 downto 0) := "001";
constant C_ADDR_CH_SPI2         : std_logic_vector(2 downto 0) := "010";
constant C_ADDR_CH_SPI3         : std_logic_vector(2 downto 0) := "011";
constant C_ADDR_CH_SPI_ALL      : std_logic_vector(2 downto 0) := "100";
constant C_ADDR_INTERNAL_REF    : std_logic_vector(2 downto 0) := "101";
constant C_ADDR_POWER_ON        : std_logic_vector(2 downto 0) := "110";

-------------------------------------------------------------------------------------------------------------------------- 
-- Individual DAC data registers
-------------------------------------------------------------------------------------------------------------------------- 
constant ADR_DAC_DC0            : std_logic_vector(17 downto 0) := ADR_BASE_DC  & "0000000000" & C_ADDR_CH_SPI0 & "000";   -- 
constant ADR_DAC_DC1            : std_logic_vector(17 downto 0) := ADR_BASE_DC  & "0000000000" & C_ADDR_CH_SPI0 & "001";   -- 
constant ADR_DAC_DC2            : std_logic_vector(17 downto 0) := ADR_BASE_DC  & "0000000000" & C_ADDR_CH_SPI0 & "010";   -- 
constant ADR_DAC_DC3            : std_logic_vector(17 downto 0) := ADR_BASE_DC  & "0000000000" & C_ADDR_CH_SPI0 & "011";   -- 
constant ADR_DAC_DC4            : std_logic_vector(17 downto 0) := ADR_BASE_DC  & "0000000000" & C_ADDR_CH_SPI0 & "100";   -- 
constant ADR_DAC_DC5            : std_logic_vector(17 downto 0) := ADR_BASE_DC  & "0000000000" & C_ADDR_CH_SPI0 & "101";   -- 
constant ADR_DAC_DC6            : std_logic_vector(17 downto 0) := ADR_BASE_DC  & "0000000000" & C_ADDR_CH_SPI0 & "110";   -- 
constant ADR_DAC_DC7            : std_logic_vector(17 downto 0) := ADR_BASE_DC  & "0000000000" & C_ADDR_CH_SPI0 & "111";   -- 

constant ADR_DAC_DC8            : std_logic_vector(17 downto 0) := ADR_BASE_DC  & "0000000000" & C_ADDR_CH_SPI1 & "000";   -- 
constant ADR_DAC_DC9            : std_logic_vector(17 downto 0) := ADR_BASE_DC  & "0000000000" & C_ADDR_CH_SPI1 & "001";   -- 

constant ADR_DAC_DC16           : std_logic_vector(17 downto 0) := ADR_BASE_DC  & "0000000000" & C_ADDR_CH_SPI2 & "000";   -- 
constant ADR_DAC_DC17           : std_logic_vector(17 downto 0) := ADR_BASE_DC  & "0000000000" & C_ADDR_CH_SPI2 & "001";   -- 
-- etc. etc.
constant ADR_DAC_DC24           : std_logic_vector(17 downto 0) := ADR_BASE_DC  & "0000000000" & C_ADDR_CH_SPI3 & "000";   -- 
constant ADR_DAC_DC25           : std_logic_vector(17 downto 0) := ADR_BASE_DC  & "0000000000" & C_ADDR_CH_SPI3 & "001";   --
 

constant ADR_DAC_DC_ALL         : std_logic_vector(17 downto 0) := ADR_BASE_DC  & "0000000000" & C_ADDR_CH_SPI_ALL & "000";     -- Write all channels 
constant ADR_DAC_DC_IREF        : std_logic_vector(17 downto 0) := ADR_BASE_DC  & "0000000000" & C_ADDR_INTERNAL_REF & "000";   --  
constant ADR_DAC_DC_POWER_ON    : std_logic_vector(17 downto 0) := ADR_BASE_DC  & "0000000000" & C_ADDR_POWER_ON & "000";       --  
constant ADR_DAC_DC_STATUS      : std_logic_vector(17 downto 0) := ADR_BASE_DC  & X"0000";                                   -- Reading any address returns SPI interface busy status 


-------------------------------------------------------------------------------------------------------------------------- 
-- The PS address space uses a byte address [17:0]
-- This is converted into a word address by discarding the lower two bits. 
-- All addresses in this file are 32-bit. 
-------------------------------------------------------------------------------------------------------------------------- 
-- 'Pulse' DAC block registers. 
-- The block has a set of block registers and contains 32 'channels'
-- Each channel has a 1024 word x 32-bit memory to hold pulse definition parameters.
-- Each pdef entry used 4 of the 32-bit words
----------------------------------------------------------------
-- Fields of pulse definition
-- Entry word 0 :   doutb[23: 0]  : pulse start time 
-- Entry word 1 :   doutb[11: 0]  : waveform start address 
--                  doutb[27:16]  : waveform length 
-- Entry word 2 :   doutb[15: 0]  : gain scale factor 
--                  doutb[31:16]  : address scale factor 
-- Entry word 3 :   doutb[16: 0]  : pulse flat top length in clock cycles 
----------------------------------------------------------------
-- The Waveform RAM contains 4K x 16-bit waveform values.
-- The waveform data is loaded over a 32-bit bus so there are 2K addresses (10:0)
-------------------------------------------------------------------------------------------------------------------------- 
-- Block-level registers
-- PS_ADDR(14) = CPU_ADDR(12) 
--      '1' selects local regs
--      '0' selects access to any of the 32 channel specified in reg_ctrl(31:0)
-- 
-- PS_ADDR(13) = CPU_ADDR(11)
--      '1' selects waveform RAM
--      '0' selects PDEF RAM
--
-- PS_ADDR(12:2) = CPU_ADDR(10:0) selects Waveform RAM word address (2K x 32-bit)
-- PS_ADDR(11:2) = CPU_ADDR( 9:0) selects pdef RAM word address
-------------------------------------------------------------------------------------------------------------------------- 
-- Addresses for block-level registers.
-- PS_ADDR[15] currently not used
------------------------------------------------------------------------------------------------------------------------- 
constant ADR_REG_AC_SEQ_LEN     : std_logic_vector(17 downto 0) := ADR_BASE_PULSE  & X"4000";   -- Max time for pulse train
constant ADR_REG_AC_CH_SEL      : std_logic_vector(17 downto 0) := ADR_BASE_PULSE  & X"4004";   -- Each set bit enables read/write access to channel RAMs
constant ADR_REG_AC_CH_EN       : std_logic_vector(17 downto 0) := ADR_BASE_PULSE  & X"4008";   -- Enable bit for each individual channel. Masks JESD sync
constant ADR_REG_AC_STATUS      : std_logic_vector(17 downto 0) := ADR_BASE_PULSE  & X"400C";   -- R/O Level status for output of each channel
constant ADR_REG_AC_STATUS_JESD : std_logic_vector(17 downto 0) := ADR_BASE_PULSE  & X"4010";   -- R/O JESD status for output of each channel
constant ADR_REG_AC_CNT_TIME    : std_logic_vector(17 downto 0) := ADR_BASE_PULSE  & X"4014";   -- R/O Current timer value (used by all channels)
------------------------------------------------------------------------------------------------------------------------- 

-------------------------------------------------------------------------------------------------------------------------- 
-- Misc block registers -- double checked
-------------------------------------------------------------------------------------------------------------------------- 
constant ADR_MISC_VERSION       : std_logic_vector(17 downto 0) := ADR_BASE_MISC & X"0000";   -- HDL code version
constant ADR_MISC_LEDS          : std_logic_vector(17 downto 0) := ADR_BASE_MISC & X"0004";   -- LEDs
constant ADR_MISC_LEDS_EN       : std_logic_vector(17 downto 0) := ADR_BASE_MISC & X"0008";   -- LEDs enable
constant ADR_MISC_DEBUG_CTRL    : std_logic_vector(17 downto 0) := ADR_BASE_MISC & X"000C";   -- Read board switch settings (if present)
constant ADR_MISC_DEBUG_TRIGGER    : std_logic_vector(17 downto 0) := ADR_BASE_MISC & X"0010";   -- Select debug output from top level to pins

-------------------------------------------------------------------------------------------------------------------------- 
-- Pulse-to-Pmod block addresses -- double checked
-------------------------------------------------------------------------------------------------------------------------- 
constant ADR_BASE_PULSE2PMOD    	: std_logic_vector(17 downto 16) 	:= ADR_BASE_SPARE;             -- p2p uses 'spare' address range 
constant PMOD_ADDR_SPI0	: std_logic_vector(17 downto 0) 	:= ADR_BASE_SPARE & X"0000";   
constant PMOD_ADDR_SPI1	: std_logic_vector(17 downto 0) 	:= ADR_BASE_SPARE & X"0001";   
constant PMOD_ADDR_INTERNAL_REF	: std_logic_vector(17 downto 0) 	:= ADR_BASE_SPARE & X"00A0";   
constant PMOD_ADDR_POWER_ON	: std_logic_vector(17 downto 0) 	:= ADR_BASE_SPARE & X"00C0";   
constant PMOD_ADDR_CTRL	: std_logic_vector(17 downto 0) 	:= ADR_BASE_SPARE & X"00E0";   
-- constant ADR_REG_PULSE2PMOD_CTRL	: std_logic_vector(17 downto 0) 	:= ADR_BASE_SPARE & X"001C";   -- Control reg. Bit-0 =1 selects stream input
-- constant ADR_REG_PULSE2PMOD_DAC0 	: std_logic_vector(17 downto 0) 	:= ADR_BASE_SPARE & X"0000";   -- Only DAC0 is used. We need full SPI bandwidth 


-- constant ADR_BASE_PULSE         : std_logic_vector(17 downto 16) :=  "01";    -- RAMs for Pulse output start/stop times

constant ADR_BASE_PULSE_DEFN : std_logic_vector(17 downto 0) := ADR_BASE_PULSE & X"0000";
constant ADR_BASE_PULSE_WAVE : std_logic_vector(17 downto 0) := ADR_BASE_PULSE & X"2000";

end package;

package body qlaser_addr_zcu102_pkg is

end package body;

