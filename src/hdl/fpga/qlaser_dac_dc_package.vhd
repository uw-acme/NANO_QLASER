----------------------------------------------------------------------------------------
-- Project       : qlaser FPGA
-- File          : qlaser_version_pkg.vhd
-- Description   : Version package file.
-- Author        : akozyra
----------------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;

package qlaser_dac_dc_pkg is

----------------------------------------------------------------------------------------
--  Constants 
----------------------------------------------------------------------------------------
constant C_ADDR_SPI0        : std_logic_vector(4 downto 0) := "00000";
constant C_ADDR_SPI1        : std_logic_vector(4 downto 0) := "00001";
constant C_ADDR_SPI2        : std_logic_vector(4 downto 0) := "00010";
constant C_ADDR_SPI3        : std_logic_vector(4 downto 0) := "00011";

end package qlaser_dac_dc_pkg;