library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.qlaser_pkg.all;
use     work.qlaser_dac_pulse_pkg.all;

entity qlaser_jesd_tx_tb is
end entity qlaser_jesd_tx_tb;

architecture sim of qlaser_jesd_tx_tb is

    signal clk               : std_logic := '0'; 
    signal reset             : std_logic := '1';
    signal core_clk          : std_logic := '0';

    signal tx_tdata          : std_logic_vector(255 downto 0);
    signal tx_tready         : std_logic;
    
    signal tx_sysref         : std_logic;
    signal sysref_count      : std_logic_vector(5 downto 0);
begin

    clk <= not clk after 5 ns;
    core_clk <= not core_clk after 1.6 ns;
  
    pr_sysref : process(clk, reset)
    begin
        if reset = '1' then
            sysref_count <= (others => '0');
            tx_sysref <= '0';
        elsif rising_edge(clk) then
            sysref_count <= std_logic_vector(unsigned(sysref_count) + 1);
            if sysref_count = "111111" then
                tx_sysref <= '1';
            else
                tx_sysref <= '0';
            end if;
        end if;
    end process;
    
    DUT : entity work.qlaser_jesd_tx(rtl)
    port map(
        clk             => clk,              
        reset           => reset,

        core_clk        => core_clk,

        tx_tdata        => tx_tdata,
        tx_tready       => tx_tready,
        
        tx_sysref       => tx_sysref
    );
    
    process is
    begin
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        
        reset <= '1';
        
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        
        reset <= '0';
        
        wait for 1 ms;
        
        wait;
    end process;
    
end architecture sim;