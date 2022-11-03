-------------------------------------------------------------------------------
-- File     : gj_serial_pkg.vhd
-- Copyright (c) 2012 by GJED, Seattle, WA
--
-- Package file for serial interface
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

package gj_serial_pkg is

    -- Clock divide for RS232 baud rate
    --  16MHz : (16,000,000/57,600) =   277.78 = 0x116
    --  40MHz : (40,000,000/57,600) =   694.44 = 0x2B6
    --  48MHz : (48,000,000/57,600) =   833.33 = 0x341
    -- 100MHz :(100,000,000/57,600) =  1736.11 = 0x6C8 
    constant C_BITRATE      : real    := 57600.0;             -- Bits per second
    constant C_FREQ_OSC     : real    := 40.0 * 1000.0 * 1000.0;  -- FPGA clock freq in Hz
    constant C_RATIO        : integer := integer(C_FREQ_OSC/C_BITRATE);
    constant C_RS232_BDIV   : std_logic_vector(11 downto 0) := std_logic_vector(to_unsigned(C_RATIO,12)); 

    -------------------------------------------------------------------
	-- Read/Reply message
    --   0      1        2      3      4
    --   Ack, Data3, Data2, Data1, Data0
    -------------------------------------------------------------------
    constant C_SIZE_RD_MSG  : integer := 5;
	
    -- 0x41, ASCII "A" is the reply message header
    constant C_HDR_ACK      : std_logic_vector( 7 downto 0) := X"41";
	
    -------------------------------------------------------------------
	-- Write message
    --   0      1        2      3      4
    --   Ack, Data3, Data2, Data1, Data0
    -------------------------------------------------------------------
    constant C_SIZE_WR_MSG  : integer := 7;
    constant C_CPU_OP_WR    : std_logic_vector( 7 downto 0) := X"57"; -- 'W' = Write
    constant C_CPU_OP_RD    : std_logic_vector( 7 downto 0) := X"52"; -- 'R' = Read

end gj_serial_pkg;
