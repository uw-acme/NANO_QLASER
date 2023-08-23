--------------------------------------------------------------------------
--  File         : gj_cpu_e.vhd
--  Description  : Entity definition for a generic CPU
----------------------------------------------------------------------------
----------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;

use work.gj_cpu_pkg.all;

entity gj_cpu is
port(
    clk_i           : in    std_logic;
    reset_i         : in    std_logic;
    csbus_o         : out   std_logic_vector(C_WIDTH_CSBUS-1 downto 0); -- Decoded from 4-bits of addresses
    rd_o            : out   std_logic;
    wr_o            : out   std_logic;
    addr_o          : out   std_logic_vector(11 downto 0);
    dat_o           : out   std_logic_vector(15 downto 0);
    dat_i           : in    std_logic_vector(15 downto 0);
    ack_i           : in    std_logic;
    gp_io           : inout std_logic_vector(NUM_CPU_GPIO-1 downto 0);
    interrupts_i    : in    std_logic_vector( 7 downto 0);
    triggers_i      : in    std_logic_vector(NUM_CPU_TRIG-1 downto 0);
    done_o          : out   boolean
);
end gj_cpu;

