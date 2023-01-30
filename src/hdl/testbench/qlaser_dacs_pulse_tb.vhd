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

    signal trigger           : std_logic;                        -- Trigger (rising edge) to start pulse output
    signal busy              : std_logic;                        -- Set to '1' while pulse outputs are occurring

    -- CPU interface
    signal cpu_addr          : std_logic_vector(11 downto 0);    -- Address input
    signal cpu_wdata         : std_logic_vector(31 downto 0) := X"00000000";    -- Data input
    signal cpu_wr            : std_logic := '0';                        -- Write enable 
    signal cpu_sel           : std_logic := '0';                        -- Block select
    signal cpu_rdata         : std_logic_vector(31 downto 0);    -- Data output
    signal cpu_rdata_dv      : std_logic;                        -- Acknowledge output
    
    signal ram0_data         : std_logic_vector(39 downto 0);
                   
    -- Pulse train outputs
    signal dacs_pulse        : std_logic_vector(31 downto 0);     -- Data output
begin

    clk <= not clk after 5 ns;
    
    DUT : entity work.qlaser_dacs_pulse(rtl)
    port map(
        clk             => clk,              
        reset           => reset,            

        trigger         => trigger,              -- Trigger (rising edge) to start pulse output
        busy            => busy,                 -- Set to '1' while pulse outputs are occurring

        -- CPU interface
        cpu_addr        => cpu_addr,              -- Address input
        cpu_wdata       => cpu_wdata,             -- Data input
        cpu_wr          => cpu_wr,                -- Write enable 
        cpu_sel         => cpu_sel,               -- Block select
        cpu_rdata       => cpu_rdata,             -- Data output
        cpu_rdata_dv    => cpu_rdata_dv,          -- Acknowledge output
        
        ram0_data       => ram0_data,         
                       
        -- Pulse train outputs
        dacs_pulse      => dacs_pulse            -- Data output
    );
    
    process is
    begin
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        
        reset <= '0';
        
        wait until rising_edge(clk);
        cpu_wdata <= X"00000001";
        cpu_wr <= '1';
        cpu_sel <= '1';
        
        wait until rising_edge(clk);
        cpu_wr <= '0';
        cpu_sel <= '0';
        
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        
        wait until rising_edge(clk);
        cpu_wdata <= X"00000002";
        cpu_wr <= '1';
        cpu_sel <= '1';
        
        wait until rising_edge(clk);
        cpu_wr <= '0';
        cpu_sel <= '0';
        
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        
        wait until rising_edge(clk);
        cpu_wdata <= X"00000003";
        cpu_wr <= '1';
        cpu_sel <= '1';
        
        wait until rising_edge(clk);
        cpu_wr <= '0';
        cpu_sel <= '0';
        
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        
        wait until rising_edge(clk);
        cpu_wdata <= X"00000004";
        cpu_wr <= '1';
        cpu_sel <= '1';
        
        wait until rising_edge(clk);
        cpu_wr <= '0';
        cpu_sel <= '0';
        
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        
        wait until rising_edge(clk);
        cpu_wdata <= X"00000005";
        cpu_wr <= '1';
        cpu_sel <= '1';
        
        wait until rising_edge(clk);
        cpu_wr <= '0';
        cpu_sel <= '0';
        
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        
        trigger <= '1';
        wait until rising_edge(clk);
        trigger <= '0';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        
        trigger <= '1';
        wait until rising_edge(clk);
        trigger <= '0';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        
        trigger <= '1';
        wait until rising_edge(clk);
        trigger <= '0';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        
        trigger <= '1';
        wait until rising_edge(clk);
        trigger <= '0';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        
        trigger <= '1';
        wait until rising_edge(clk);
        trigger <= '0';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait;
        
        
    end process;
    
end architecture sim;