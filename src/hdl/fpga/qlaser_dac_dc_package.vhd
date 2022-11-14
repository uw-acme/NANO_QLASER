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
-- 0x0001     : First version.
----------------------------------------------------------------------------------------
--constant C_ADDR_DC_CH0      : std_logic_vector(4 downto 0) := X"0000";     -- HDL Version
--constant C_ADDR_DC_CH1      : std_logic_vector(4 downto 0) := X"0001";
--constant C_ADDR_DC_CH2      : std_logic_vector(4 downto 0) := X"0002";
--constant C_ADDR_DC_CH3      : std_logic_vector(4 downto 0) := X"0003";
--constant C_ADDR_DC_CH4      : std_logic_vector(4 downto 0) := X"0004";
--constant C_ADDR_DC_CH5      : std_logic_vector(4 downto 0) := X"0005";
--constant C_ADDR_DC_CH6      : std_logic_vector(4 downto 0) := X"0006";
--constant C_ADDR_DC_CH7      : std_logic_vector(4 downto 0) := X"0007";
--constant C_ADDR_DC_CH8      : std_logic_vector(4 downto 0) := X"0008";
--constant C_ADDR_DC_CH9      : std_logic_vector(4 downto 0) := X"0009";
--constant C_ADDR_DC_CH10     : std_logic_vector(4 downto 0) := X"000A";
--constant C_ADDR_DC_CH11     : std_logic_vector(4 downto 0) := X"000B";
--constant C_ADDR_DC_CH12     : std_logic_vector(4 downto 0) := X"000C";
--constant C_ADDR_DC_CH13     : std_logic_vector(4 downto 0) := X"000D";
--constant C_ADDR_DC_CH14     : std_logic_vector(4 downto 0) := X"000E";
--constant C_ADDR_DC_CH15     : std_logic_vector(4 downto 0) := X"000F";
--constant C_ADDR_DC_CH16     : std_logic_vector(4 downto 0) := X"0010";
--constant C_ADDR_DC_CH17     : std_logic_vector(4 downto 0) := X"0011";
--constant C_ADDR_DC_CH18     : std_logic_vector(4 downto 0) := X"0012";
--constant C_ADDR_DC_CH19     : std_logic_vector(4 downto 0) := X"0013";
--constant C_ADDR_DC_CH20     : std_logic_vector(4 downto 0) := X"0014";
--constant C_ADDR_DC_CH21     : std_logic_vector(4 downto 0) := X"0015";
--constant C_ADDR_DC_CH22     : std_logic_vector(4 downto 0) := X"0016";
--constant C_ADDR_DC_CH23     : std_logic_vector(4 downto 0) := X"0017";
--constant C_ADDR_DC_CH24     : std_logic_vector(4 downto 0) := X"0018";
--constant C_ADDR_DC_CH25     : std_logic_vector(4 downto 0) := X"0019";
--constant C_ADDR_DC_CH26     : std_logic_vector(4 downto 0) := X"001A";
--constant C_ADDR_DC_CH27     : std_logic_vector(4 downto 0) := X"001B";
--constant C_ADDR_DC_CH28     : std_logic_vector(4 downto 0) := X"001C";
--constant C_ADDR_DC_CH29     : std_logic_vector(4 downto 0) := X"001D";
--constant C_ADDR_DC_CH30     : std_logic_vector(4 downto 0) := X"001E";
--constant C_ADDR_DC_CH31     : std_logic_vector(4 downto 0) := X"001F";

constant C_ADDR_SPI0        : std_logic_vector(4 downto 0) := "00000";
end package qlaser_dac_dc_pkg;