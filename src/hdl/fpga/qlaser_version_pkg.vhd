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
-- 0x0001     : First version.
----------------------------------------------------------------------------------------
constant C_QLASER_VERSION   : std_logic_vector(31 downto 0) := X"3DA0500D";     -- HDL Version


end package qlaser_version_pkg;

