----------------------------------------------------------------------------------
-- ps1_wrapper   THIS FILE IS FOR SIMULATION
-- Empty version that just generates a clock and reset.
----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library unisim;
use i   unisim.vcomponents.all;

entity ps1_wrapper is
    port (
        clk_cpu             : out std_logic;
        cpu_addr            : out std_logic_vector(17 downto 0);
        cpu_rd              : out std_logic;
        cpu_rdata           : in  std_logic_vector(31 downto 0);
        cpu_rdata_dv        : in  std_logic;
        cpu_wdata           : out std_logic_vector(31 downto 0);
        cpu_wr              : out std_logic;
        gpio_int_in_tri_i   : in  std_logic_vector( 7 downto 0);
        gpio_int_out_tri_o  : out std_logic_vector( 7 downto 0);
        gpio_leds_tri_o     : out std_logic_vector( 7 downto 0);
        gpio_pbtns_tri_i    : in  std_logic_vector( 4 downto 0);
        pl_clk0             : out std_logic;
        pl_resetn0          : out std_logic;
        reset               : in  std_logic
  );
end ps1_wrapper;


architecture empty of ps1_wrapper is
-- Halts simulation by stopping clock when set true
signal sim_done                     : boolean   := false;

-- Crystal clock freq expressed in MHz
constant CLK_FREQ_MHZ               : real      := 100.0; 
-- Clock period
constant CLK_PER                    : time      := integer(1.0E+6/(CLK_FREQ_MHZ)) * 1 ps;

begin
  
    -- Drive all outputs to '0' except PL clk0 and resetn0
    clk_cpu             <= '0';             -- out std_logic;
    cpu_addr            <= (others=>'0');   -- out std_logic_vector(17 downto 0);
    cpu_rd              <= '0';             -- out std_logic;
    cpu_wdata           <= (others=>'0');   -- out std_logic_vector(31 downto 0);
    cpu_wr              <= '0';             -- out std_logic;
    
    gpio_int_out_tri_o  <= (others=>'0');   -- out std_logic_vector( 7 downto 0);
    gpio_leds_tri_o     <= (others=>'0');   -- out std_logic_vector( 7 downto 0);



    -------------------------------------------------------------
    -- Generate pl_clk0 clock. Halt when sim_done is true.
    -------------------------------------------------------------
    pr_clk0 : process
    begin
        pl_clk0  <= '0';
        wait for (CLK_PER/2);
        pl_clk0  <= '1';
        wait for (CLK_PER-CLK_PER/2);
        if (sim_done=true) then
            wait; 
        end if;
    end process;


    -------------------------------------------------------------
    -- Generate pl_resetn0
    -------------------------------------------------------------
    pr_resetn0 : process
    begin
        pl_resetn0  <= '0';
        wait for (5*CLK_PER/2);
        pl_resetn0  <= '1';
        wait
    end process;
    
end empty;
