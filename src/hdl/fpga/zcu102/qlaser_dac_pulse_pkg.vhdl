----------------------------------------------------------------------------------------
-- Project       : qlaser FPGA
-- File          : qlaser_dac_pulse_pkg.vhd
-- Description   : package file.
----------------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;

package qlaser_dac_pulse_pkg is

----------------------------------------------------------------------------------------
--  Constants 
----------------------------------------------------------------------------------------
-- Addresses
constant C_MAX_TIME_PULSE           : std_logic_vector(23 downto 0) := X"4C4B40";


end package qlaser_dac_pulse_pkg;