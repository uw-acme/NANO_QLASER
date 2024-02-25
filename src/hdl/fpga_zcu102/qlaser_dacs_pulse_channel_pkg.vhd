----------------------------------------------------------------------------------------
-- Project       : qlaser FPGA
-- File          : qlaser_dacs_pulse_channel.vhd
-- Description   : Pulse Channel package file specifying constants
-- Author        : eyhc
----------------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;

package qlaser_dacs_pulse_channel_pkg is
-- Constants declearations
constant C_RAM_SELECT       : integer   := 11;                                    -- Select bit for which RAM for CPU read/write
-- constant C_NUM_PULSE        : integer   := 16;                -- Number of output data values from pulse RAM (16x24-bit)

constant C_START_TIME       : integer   := 24;                                    -- Start time for pulse generation
constant C_BITS_ADDR_START  : integer   := 12;                                    -- Number of bits for starting address
constant C_BITS_ADDR_LENGTH : integer   := 10;                                    -- Number of bits for length address used by an edge of a pulse
constant C_BITS_GAIN_FACTOR : integer   := 16;                                    -- Number of bits in gain table
constant C_BITS_TIME_FACTOR : integer   := 16;                                    -- Number of bits in time table
constant C_BITS_TIME_INT    : integer   := 14;                                    -- Starting bit for time integer part of the time factor, counting from MSB
constant C_BITS_TIME_FRAC   : integer   :=  5;                                    -- Starting bit for time fractional part of the time factor, counting from MSB
constant C_BITS_ADDR_TOP    : integer   := 17;                                    -- Number of bits for the "flat top", the top of the pulse
constant C_BITS_ADDR_FULL   : integer   := 20;                                    -- Number of bits for the untruncated address, should be C_BITS_ADDR_LENGTH + fractional bits of time factor

constant C_LENGTH_WAVEFORM  : integer   := 4096;                                  -- Number of output data values from waveform RAM (4kx16-bit)
constant C_BITS_ADDR_WAVE   : integer   := 16;                                    -- Number of bits in address for waveform RAM

constant C_BITS_ADDR_PULSE  : integer   := 10;                                    -- Number of bits in address for pulse definition RAM
constant C_LEN_PULSE        : integer   := 2**C_BITS_ADDR_PULSE;                  -- Numbers of address for pulse definition RAM
constant C_PC_INCR          : integer   := 4;     
                                                                                  -- Width of pulse counter increment

                                
constant BIT_FRAC :          integer    := 8;                                     -- Define the number of fractional bits
constant BIT_FRAC_GAIN :     integer    := C_BITS_GAIN_FACTOR - 1;                -- Define the number of fractional bits of the gain
end package qlaser_dacs_pulse_channel_pkg;