-------------------------------------------------------------------------------
-- File       : qlaser_cpuint_e.vhd
--
-- Entity definition for CPU interface.
-- This is meant for use in simulation when you are 
-- using procedure calls to generate read/write operations in
-- separate architecture files instead of using the serial interface.
-------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;

use     work.qlaser_pkg.all;

entity qlaser_cpuint is
port (
    clk             : in  std_logic;
    reset           : in  std_logic;
    tick_msec       : in  std_logic;    -- Used to reset interface if a message is corrupted

    -- RS232 serial interface
    rxd             : in  std_logic;    -- UART Receive data
    txd             : out std_logic;    -- UART Transmit data

    -- CPU interface signals
    cpu_rd          : out std_logic;
    cpu_wr          : out std_logic;
    cpu_sels        : out std_logic_vector(C_NUM_BLOCKS-1 downto 0); -- Decoded from upper 4-bits of addresses
    cpu_addr        : out std_logic_vector(15 downto 0);
    cpu_din         : out std_logic_vector(31 downto 0);

    arr_cpu_dout_dv : in  std_logic_vector(C_NUM_BLOCKS-1 downto 0);
    arr_cpu_dout    : in  t_arr_cpu_dout;

    debug           : out std_logic_vector( 3 downto 0)
);
end qlaser_cpuint;

