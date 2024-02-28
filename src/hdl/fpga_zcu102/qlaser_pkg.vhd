-------------------------------------------------------------------------------
-- Filename :   qlaser_pkg.vhd
-------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.qlaser_dac_dc_pkg.all;
-- use     work.qlaser_dac_ac_pkg.all;
use     work.qlaser_dacs_pulse_channel_pkg.all;

--------------------------------------------------------------------------------
-- FPGA constant definitions
-------------------------------------------------------------------------------
package qlaser_pkg is

-- FPGA internal (PLL) clock freq expressed in MHz
constant C_CLK_FREQ_MHZ         : real      := 100.0; 
-- Clock period
constant C_CLK_PERIOD           : time      := integer(1.0E+6/(C_CLK_FREQ_MHZ)) * 1 ps;

constant C_NUM_CHAN_DC          : integer := 32;    -- Number of DC channels
constant C_NUM_CHAN_AC          : integer := 32;    -- Number of AC (pulse) channels

--------------------------------------------------------------------------------
-- FPGA Addresses
-- Main blocks. Decoded from upper 4 bits of address [15:12]
--------------------------------------------------------------------------------
constant ADR_BASE_DC            : std_logic_vector( 3 downto 0) :=  X"0";    -- Registers to load DC DAC values
constant ADR_BASE_PULSE         : std_logic_vector( 3 downto 0) :=  X"1";    -- RAMs for Pulse output start/stop times
constant ADR_BASE_MISC          : std_logic_vector( 3 downto 0) :=  X"2";    -- Misc, LEDs, switches, power control

--------------------------------------------------------------------------------
-- Define the number of internal blocks that are addressed by the CPU
--------------------------------------------------------------------------------
constant C_NUM_BLOCKS           : integer   := 4; 
type t_arr_cpu_dout is array (0 to C_NUM_BLOCKS-1) of std_logic_vector(31 downto 0);
type t_arr_dout_ac  is array (0 to C_NUM_CHAN_AC-1) of std_logic_vector(15 downto 0);


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
constant ADR_DAC_DC0            : std_logic_vector(15 downto 0) := ADR_BASE_DC  & "000000" & C_ADDR_SPI0 & "000";   -- 
constant ADR_DAC_DC1            : std_logic_vector(15 downto 0) := ADR_BASE_DC  & "000000" & C_ADDR_SPI0 & "001";   -- 
constant ADR_DAC_DC2            : std_logic_vector(15 downto 0) := ADR_BASE_DC  & "000000" & C_ADDR_SPI0 & "010";   -- 
constant ADR_DAC_DC3            : std_logic_vector(15 downto 0) := ADR_BASE_DC  & "000000" & C_ADDR_SPI0 & "011";   -- 
constant ADR_DAC_DC4            : std_logic_vector(15 downto 0) := ADR_BASE_DC  & "000000" & C_ADDR_SPI0 & "100";   -- 
constant ADR_DAC_DC5            : std_logic_vector(15 downto 0) := ADR_BASE_DC  & "000000" & C_ADDR_SPI0 & "101";   -- 
constant ADR_DAC_DC6            : std_logic_vector(15 downto 0) := ADR_BASE_DC  & "000000" & C_ADDR_SPI0 & "110";   -- 
constant ADR_DAC_DC7            : std_logic_vector(15 downto 0) := ADR_BASE_DC  & "000000" & C_ADDR_SPI0 & "111";   -- 

constant ADR_DAC_DC8            : std_logic_vector(15 downto 0) := ADR_BASE_DC  & "000000" & C_ADDR_SPI1 & "000";   -- 
constant ADR_DAC_DC9            : std_logic_vector(15 downto 0) := ADR_BASE_DC  & "000000" & C_ADDR_SPI1 & "001";   -- 

-- constant ADR_DAC_DC6            : std_logic_vector(15 downto 0) := ADR_BASE_DC  & "000000" & C_ADDR_SPI2 & "000";   -- 
-- constant ADR_DAC_DC7            : std_logic_vector(15 downto 0) := ADR_BASE_DC  & "000000" & C_ADDR_SPI2 & "001";   -- 
-- etc. etc.
-- constant ADR_DAC_DC6            : std_logic_vector(15 downto 0) := ADR_BASE_DC  & "000000" & C_ADDR_SPI3 & "110";   -- 
-- constant ADR_DAC_DC7            : std_logic_vector(15 downto 0) := ADR_BASE_DC  & "000000" & C_ADDR_SPI3 & "111";   -- 
constant ADR_DAC_DC30           : std_logic_vector(15 downto 0) := ADR_BASE_DC  & X"01E";   -- 
constant ADR_DAC_DC31           : std_logic_vector(15 downto 0) := ADR_BASE_DC  & X"01F";   -- 

constant ADR_DAC_DC_ALL         : std_logic_vector(15 downto 0) := ADR_BASE_DC  & "000000" & C_ADDR_CH_SPI_ALL & "000";     -- Write all channels 
constant ADR_DAC_DC_IREF        : std_logic_vector(15 downto 0) := ADR_BASE_DC  & "000000" & C_ADDR_INTERNAL_REF & "000";   --  
constant ADR_DAC_DC_POWER_ON    : std_logic_vector(15 downto 0) := ADR_BASE_DC  & "000000" & C_ADDR_POWER_ON & "000";       --  
constant ADR_DAC_DC_STATUS      : std_logic_vector(15 downto 0) := ADR_BASE_DC  & X"000";                               -- Reading any address returns SPI interface busy status (this was 32 bit, but decleared as 16, so I changed to 16)


-------------------------------------------------------------------------------------------------------------------------- 
-- 'Pulse' DAC block registers. 
-- The block has a set of block registers and contains 16 'channels'
-- Each channel has a 40-bit memory to specify 24-bit time and a 16-bit level.
-- Initially just using the MSB of the level to drive a single pin output 
--
-------------------------------------------------------------------------------------------------------------------------- 
-- Block-level registers
-- CPU_ADDR(11) = '0' selects local regs
-- CPU_ADDR(11) = '1' selects the channel specified in reg_ctrl(3 :0)
--               Then CPU_ADDR(10:1) selects RAM word address    (1024 address MAX)
--					  CPU_ADDR(0) selects MSB or LSB of 40-bit RAM word (time or amplitude)
-------------------------------------------------------------------------------------------------------------------------- 
-- Addresses for block-level registers.
------------------------------------------------------------------------------------------------------------------------- 
constant ADR_DAC_PULSE_CTRL     : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"800";   -- 4:0 select channel RAM for CPU read/write.  Bit 8 is rising edge internal trigger
constant ADR_DAC_PULSE_STATUS   : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"801";   -- R/O Level status for output of each channel
constant ADR_DAC_PULSE_RUNTIME  : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"802";   -- Max time for pulse train
constant ADR_DAC_PULSE_CH_EN    : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"803";   -- Enable bit for each individual channel
constant ADR_DAC_PULSE_TIMER    : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"804";   -- R/O Current timer value (used by all channels)
------------------------------------------------------------------------------------------------------------------------- 

-------------------------------------------------------------------------------------------------------------------------- 
-- Pulse Channel offsets
-------------------------------------------------------------------------------------------------------------------------- 
constant ADR_DAC_PULSE0         : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"000";   -- Base address of a 16-word x 40-bit RAM
constant ADR_DAC_PULSE1         : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"040";   -- 
constant ADR_DAC_PULSE2         : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"080";   -- 
constant ADR_DAC_PULSE3         : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"0C0";   -- 
--
constant ADR_DAC_PULSE4         : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"100";   -- 
constant ADR_DAC_PULSE5         : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"140";   -- 
constant ADR_DAC_PULSE6         : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"180";   -- 
constant ADR_DAC_PULSE7         : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"1C0";   -- 
--
constant ADR_DAC_PULSE8         : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"200";   -- 
constant ADR_DAC_PULSE9         : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"240";   -- 
constant ADR_DAC_PULSE10        : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"280";   -- 
constant ADR_DAC_PULSE11        : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"2C0";   -- 
--
constant ADR_DAC_PULSE12        : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"300";   -- 
constant ADR_ADC_PULSE13        : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"340";   -- 
constant ADR_DAC_PULSE14        : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"380";   -- 
constant ADR_DAC_PULSE15        : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"3C0";   -- 
--
-- etc. etc.
constant ADR_DAC_PULSE28        : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"700";   -- 
constant ADR_DAC_PULSE29        : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"740";   -- 
constant ADR_DAC_PULSE30        : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"780";   -- 
constant ADR_DAC_PULSE31        : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"7C0";   -- 



-------------------------------------------------------------------------------------------------------------------------- 
-- Misc block registers
-------------------------------------------------------------------------------------------------------------------------- 
constant ADR_MISC_VERSION       : std_logic_vector(15 downto 0) := ADR_BASE_MISC & X"000";   -- HDL code version
constant ADR_MISC_LEDS          : std_logic_vector(15 downto 0) := ADR_BASE_MISC & X"001";   -- LEDs
constant ADR_MISC_LEDS_EN       : std_logic_vector(15 downto 0) := ADR_BASE_MISC & X"002";   -- LEDs enable
constant ADR_MISC_SW_IN         : std_logic_vector(15 downto 0) := ADR_BASE_MISC & X"003";   -- Read board switch settings (if present)
constant ADR_MISC_DEBUG_CTRL    : std_logic_vector(15 downto 0) := ADR_BASE_MISC & X"004";   -- Select debug output from top level to pins


end package;

package body qlaser_pkg is

end package body;

