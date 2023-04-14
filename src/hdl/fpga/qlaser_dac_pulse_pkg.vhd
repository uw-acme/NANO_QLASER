----------------------------------------------------------------------------------------
-- Project       : qlaser FPGA
-- File          : qlaser_version_pkg.vhd
-- Description   : Version package file.
-- Author        : akozyra
----------------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;

package qlaser_dac_pulse_pkg is

----------------------------------------------------------------------------------------
--  Constants 
----------------------------------------------------------------------------------------

-- Addresses
constant C_ADDR_RAM0                : std_logic_vector(1 downto 0)  := "00";
constant C_MAX_TIME                 : std_logic_vector(23 downto 0) := X"4C4B40";

end package qlaser_dac_pulse_pkg;