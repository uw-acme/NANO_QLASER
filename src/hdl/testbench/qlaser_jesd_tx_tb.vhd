library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.qlaser_pkg.all;
use     work.qlaser_dac_pulse_pkg.all;

entity qlaser_dacs_pulse_tb is
end entity qlaser_dacs_pulse_tb;

architecture sim of qlaser_dacs_pulse_tb is

    signal clk               : std_logic := '0'; 
    signal reset             : std_logic := '1';

    signal tx_tdata          : std_logic_vector(255 downto 0);
    signal tx_tready         : std_logic;
begin

    clk <= not clk after 5 ns;
    
    DUT : entity work.qlaser_jesd_tx(rtl)
    port map(
        clk             => clk,              
        reset           => reset,            

        tx_tdata        => tx_tdata,
        tx_tready       => tx_tready
    );
    
    process is
    begin
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        
        reset <= '1';
        
        wait until rising_edge(clk);
        
        reset <= '0';
        
        wait 1 ms;
    end process;
    
end architecture sim;