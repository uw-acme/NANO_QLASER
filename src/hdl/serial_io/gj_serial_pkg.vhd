-------------------------------------------------------------------------------
-- File     : gj_serial_pkg.vhd
-- Copyright (c) 2013 by GJED, Seattle, WA
--
-- Package file for serial interface
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;


package gj_serial_pkg is

    -- Clock divide for RS232 baud rate
    constant C_BITRATE          : real    := 115200.0;                                   -- Bits per second
    constant C_LOGIC_FREQ_HZ    : real    := 100 * 1000.0 * 1000.0;                      -- FPGA clock freq in Hz
    constant C_RATIO            : integer := integer(C_LOGIC_FREQ_HZ/C_BITRATE);
    constant RS232_BDIV         : std_logic_vector(11 downto 0) := std_logic_vector(to_unsigned(C_RATIO,12)); 

end gj_serial_pkg;
