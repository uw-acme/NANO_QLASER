----------------------------------------------------------------------------------------
-- Project       : qlaser FPGA
-- File          : qlaser_dac_dc_pkg.vhd
-- Description   : Version package file.
-- Author        : akozyra
----------------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;

package qlaser_dac_dc_pkg is

----------------------------------------------------------------------------------------
--  Constants 
----------------------------------------------------------------------------------------

-- Addresses
constant C_ADDR_SPI0                : std_logic_vector(2 downto 0) := "000";
constant C_ADDR_SPI1                : std_logic_vector(2 downto 0) := "001";
constant C_ADDR_SPI2                : std_logic_vector(2 downto 0) := "010";
constant C_ADDR_SPI3                : std_logic_vector(2 downto 0) := "011";
constant C_ADDR_SPI_ALL             : std_logic_vector(2 downto 0) := "100";
constant C_ADDR_INTERNAL_REF        : std_logic_vector(2 downto 0) := "101";
constant C_ADDR_POWER_ON            : std_logic_vector(2 downto 0) := "110";

-- Commands
constant C_CMD_DAC_DC_WR            : std_logic_vector(3 downto 0) := "0011";
constant C_CMD_DAC_DC_INTERNAL_REF  : std_logic_vector(3 downto 0) := "1000";
constant C_CMD_DAC_DC_POWER         : std_logic_vector(3 downto 0) := "0100";

end package qlaser_dac_dc_pkg;