-------------------------------------------------------------------------------
--  File         : gj_cpu_pkg.vhd
--  Description  : CPU package.
--------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;

package gj_cpu_pkg is

    ----------------------------------------------------------------------------
    -- Control the address decoding and chip select generation
    ----------------------------------------------------------------------------
    constant C_WIDTH_ADDR_CODE  : integer :=  16;   -- Width of address field CPU instruction code
    constant C_WIDTH_ABUS       : integer :=  12;   -- Width of address bus on CPU
    constant C_WIDTH_CSBUS      : integer :=  16;   -- Width of chip select bus on CPU

    constant BIT_DECODE_LO      : integer :=  12;   -- Lowest bit of address field used to decode to make chip select bus
    constant BIT_DECODE_HI      : integer :=  15;   -- Highest bit of address field used to decode to make chip select bus

    constant C_WIDTH_DBUS       : integer :=  16;   -- Width of data bus

    -- Names for counters used in the bus record 
    constant CNT_OP             : integer := 0;     
    constant CNT_RD             : integer := 1;     
    constant CNT_WR             : integer := 2;     
    constant CNT_PASS           : integer := 3;     
    constant CNT_FAIL0          : integer := 4;     
    constant CNT_FAIL1          : integer := 5;     
    constant CNT_FAIL2          : integer := 6;     
    constant CNT_FAIL3          : integer := 7;     
    constant CNT_TESTNUM        : integer := 8;     
    constant NUM_CPU_COUNTERS   : integer := 9;     

    type t_arrcnt is array (0 to NUM_CPU_COUNTERS-1) of integer;
	
    -- Record type for the CPU bus. Includes error counters
    type trec_cpubus is record
        cs              : std_logic_vector(C_WIDTH_CSBUS-1 downto 0);
        rd              : std_logic;
        wr              : std_logic;
        adr             : std_logic_vector(C_WIDTH_ABUS-1 downto 0);
        idat            : std_logic_vector(C_WIDTH_DBUS-1 downto 0);
        odat            : std_logic_vector(C_WIDTH_DBUS-1 downto 0);
        ack             : std_logic; 
        arrcnt          : t_arrcnt;
    end record;

    constant NUM_CPU_WAITS      : integer :=  3; -- Number of CPU wait states

    ----------------------------------------------------------------------------
    -- GPIO definitions. (From the CPU's p.o.v. Don't add any here. 
    -- Any alternative names used on the board should be defined in gj_tb_pkg.vhd
    ----------------------------------------------------------------------------
    constant NUM_CPU_GPIO       : integer := 16; -- Number of CPU GPIOs
    constant CPU_GPIO_0         : integer :=  0;
    constant CPU_GPIO_1         : integer :=  1;
    constant CPU_GPIO_2         : integer :=  2;
    constant CPU_GPIO_3         : integer :=  3;
    constant CPU_GPIO_4         : integer :=  4;
    constant CPU_GPIO_5         : integer :=  5;
    constant CPU_GPIO_6         : integer :=  6;
    constant CPU_GPIO_7         : integer :=  7;
    constant CPU_GPIO_8         : integer :=  8;
    constant CPU_GPIO_9         : integer :=  9;
    constant CPU_GPIO_10        : integer := 10;
    constant CPU_GPIO_11        : integer := 11;
    constant CPU_GPIO_12        : integer := 12;
    constant CPU_GPIO_13        : integer := 13;
    constant CPU_GPIO_14        : integer := 14;
    constant CPU_GPIO_15        : integer := 15;
    constant CPU_GPIO_16        : integer := 16;
    constant CPU_GPIO_17        : integer := 17;

    constant NUM_CPU_TRIG       : integer :=  8; -- Number of CPU Triggers

    ----------------------------------------------------------------------------
    -- Type definitions for the testbench.
    ----------------------------------------------------------------------------
    constant MAX_BURST_LEN      : integer := 32; -- 16-bit words
    type t_arr_rdat_burst is array (0 to MAX_BURST_LEN-1) of std_logic_vector(31 downto 0);

    constant MAX_DAT_ARRAY_LEN  : integer := 1024; -- 16-bit words
    type t_dat_array is array (0 to MAX_DAT_ARRAY_LEN-1) of std_logic_vector(31 downto 0);

    constant LENGTH_TESTNAME    : integer := 50;     
    
end package;

---------------------------------------------------------------
---------------------------------------------------------------
package body gj_cpu_pkg is

end package body;
