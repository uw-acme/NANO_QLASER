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

                                
constant BIT_FRAC           : integer    := 8;                                    -- Define the number of fractional bits
constant BIT_FRAC_GAIN      : integer    := C_BITS_GAIN_FACTOR - 1;               -- Define the number of fractional bits of the gain
constant BIT_FRAC_DATA      : integer    := 15;                                   -- Define the number of fractional bits of the data, the ram output

-- Error Constants
constant C_ERR_RAM_OF       : integer    := 0;                                    -- Wave table RAM overflow (start address + length > 4096)
constant C_INVAL_LENGTH     : integer    := 1;                                    -- Invalid length of rise/fall (<=1)
constant C_ERR_BIG_STEP     : integer    := 2;                                    -- Step too big than the waveform length
constant C_ERR_BIG_GAIN     : integer    := 3;                                    -- Gain too big (>1)
constant C_ERR_SMALL_TIME   : integer    := 4;                                    -- Time step too small (<1)
constant C_ERR_START_TIME   : integer    := 5;                                    -- Start time too early (<5 from last pulse)



-- Simulation constants
CONSTANT C_RUN_START        : integer := 0;                                       -- Start of the simulation
CONSTANT C_DEGREES_MAX      : integer := 64;                                     -- Maximum number of degrees of the polynomial

type real_array is array (natural range <>) of real;
type int_array is array (natural range <>) of integer;

-- Pulse definition record
type t_rec_pdef is record
    starttime      : integer;    -- For 24-bit pulse time
    timefactor     : real;       -- For 16-bit fixed point timestep
    gainfactor     : real;       -- For 16-bit fixed point gain
    startaddr      : integer;    -- For 12-bit address i.e. 1024 point waveform RAM
    steps          : integer;    -- For 10-bit number of steps i.e. 0 = 1 step, X"3FF" = 1024 points
    sustain        : integer;    -- For 17-bit number of clock cycles in top of waveform
    coefficients   : real_array(0 to C_DEGREES_MAX - 1);  -- Coefficients of the polynomial
end record t_rec_pdef;
type arr_pdef is array (0 to C_LEN_PULSE - 1) of t_rec_pdef;

end package qlaser_dacs_pulse_channel_pkg;