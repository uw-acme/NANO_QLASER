----------------------------------------------------------------------------------------
-- Project       : qlaser FPGA
-- File          : qlaser_dac_ac_pkg.vhd
-- Description   : Constants and typedefs for the AC waveform block
-- Author        : Gjones
----------------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;

package qlaser_dac_ac_pkg is

----------------------------------------------------------------------------------------
--  Constants 
----------------------------------------------------------------------------------------

-- Addresses
constant C_ADDR_XXX                 : std_logic_vector(2 downto 0) := "000";

-- Array for 32 16-bit signals
type t_arr_dout_ac is array (31 downto 0) of std_logic_vector(15 downto 0);


end package qlaser_dac_ac_pkg;
