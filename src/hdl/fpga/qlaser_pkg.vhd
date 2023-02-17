-------------------------------------------------------------------------------
-- Filename :   qlaser_pkg.vhd
-------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;


--------------------------------------------------------------------------------
-- FPGA constant definitions
-------------------------------------------------------------------------------
package qlaser_pkg is

-- FPGA internal (PLL) clock freq expressed in MHz
constant C_CLK_FREQ_MHZ         : real      := 100.0; 
-- Clock period
constant C_CLK_PERIOD           : time      := integer(1.0E+6/(C_CLK_FREQ_MHZ)) * 1 ps;


--------------------------------------------------------------------------------
-- FPGA Addresses
-- Main blocks. Decoded from upper 4 bits of address
--------------------------------------------------------------------------------
constant ADR_BASE_DC            : std_logic_vector( 3 downto 0) :=  X"0";    -- Registers to load DC DAC values
constant ADR_BASE_PULSE         : std_logic_vector( 3 downto 0) :=  X"1";    -- RAMs for Pulse output start/stop times
constant ADR_BASE_MISC          : std_logic_vector( 3 downto 0) :=  X"2";    -- Misc, LEDs, switches, power control

--------------------------------------------------------------------------------
-- Define the number of internal blocks that are addressed by the CPU
--------------------------------------------------------------------------------
constant C_NUM_BLOCKS           : integer   := 3; 
type t_arr_cpu_dout is array (0 to C_NUM_BLOCKS-1) of std_logic_vector(31 downto 0);


-------------------------------------------------------------------------------------------------------------------------- 
-- 'DC' DAC block registers. 32 16-bit DAC outputs
-------------------------------------------------------------------------------------------------------------------------- 
constant ADR_DAC_DC0            : std_logic_vector(15 downto 0) := ADR_BASE_DC  & X"000";   -- 
constant ADR_DAC_DC1            : std_logic_vector(15 downto 0) := ADR_BASE_DC  & X"001";   -- 
constant ADR_DAC_DC2            : std_logic_vector(15 downto 0) := ADR_BASE_DC  & X"002";   -- 
-- etc. etc.
constant ADR_DAC_DC30           : std_logic_vector(15 downto 0) := ADR_BASE_DC  & X"01E";   -- 
constant ADR_DAC_DC31           : std_logic_vector(15 downto 0) := ADR_BASE_DC  & X"01F";   -- 
constant ADR_DAC_DC_STATUS      : std_logic_vector(15 downto 0) := ADR_BASE_DC  & X"100";   -- 

-------------------------------------------------------------------------------------------------------------------------- 
-- 'Pulse' DAC block registers. 
-- Initially 32 single-bit GPIO outputs. Each channel has a 32-bit memory to specify 24-bit pulse start and stop times.
-- Future versions with have a 16-bit ADC value associated with each on/off time.
-------------------------------------------------------------------------------------------------------------------------- 
constant ADR_DAC_PULSE0         : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"000";   -- Base address of 64-word RAM
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

constant ADR_DAC_PULSE_RUNTIME  : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"800";   -- Max time for pulse train
constant ADR_DAC_PULSE_EN       : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"801";   -- Enable bit for each individual channel
constant ADR_DAC_PULSE_STATUS   : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"802";   -- Level status for outpu of each channel
constant ADR_DAC_PULSE_TIMER    : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"803";   -- Current timer value (used by all channels)


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

