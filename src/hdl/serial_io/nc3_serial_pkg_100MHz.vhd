-------------------------------------------------------------------------------
-- File     : nc3_serial_pkg.vhd
-- Copyright (c) 2012 by GJED, Seattle, WA
--
-- Package file for serial interface
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

package nc3_serial_pkg is

    ---------------------------------------------------------------------------------------
    -- Calculate clock divisor from serial bitrate and FPGA logic clock frequency
    ---------------------------------------------------------------------------------------
    constant C_BITRATE      : real    := 115200.0;                  -- Bits per second, CPU interface 
    constant C_FREQ_LOGIC   : real    := 100.0 * 1000.0 * 1000.0;   -- FPGA clock freq in Hz
    constant C_RATIO        : integer := integer(C_FREQ_LOGIC/C_BITRATE);
    constant RS232_BDIV     : std_logic_vector(11 downto 0) := std_logic_vector(to_unsigned(C_RATIO,12)); 

    -- Timeout (in msec) for interface to reset if it is in the middle of a message and does not see
    -- a new character.
    constant C_TIMEOUT_SERIAL   : integer := 31; 

 end nc3_serial_pkg;
