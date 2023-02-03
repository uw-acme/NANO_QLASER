----------------------------------------------------------------------------------------
-- Project       : qlaser FPGA
-- File          : qlaser_version_pkg.vhd
-- Description   : Version package file.
-- Author        : gjones
----------------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;

package qlaser_version_pkg is

----------------------------------------------------------------------------------------
--  Constants 
----------------------------------------------------------------------------------------
-- 0xDC000001     : First version of DC only system.
----------------------------------------------------------------------------------------
constant C_QLASER_VERSION   : std_logic_vector(31 downto 0) := X"DC000001";     -- HDL Version


end package qlaser_version_pkg;

