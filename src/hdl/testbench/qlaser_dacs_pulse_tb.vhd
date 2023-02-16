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
    
    signal ram_data         : std_logic_vector(39 downto 0);
                   
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
        
        ram_data       => ram_data,         
                       
        -- Pulse train outputs
        dacs_pulse      => dacs_pulse            -- Data output
    );
    
    process is
    begin
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        
        reset <= '0';
        
        -- First pulse entry start.
        wait until rising_edge(clk);
        cpu_wdata <= X"00001234";
        cpu_wr <= '1';
        cpu_sel <= '1';
        
        wait until rising_edge(clk);
        cpu_wr <= '0';
        cpu_sel <= '0';
        
        for i in 0 to 6 loop
            wait until rising_edge(clk);
        end loop;
        
        
        wait until rising_edge(clk);
        cpu_wdata <= X"ABABABAB";
        cpu_wr <= '1';
        cpu_sel <= '1';
        
        wait until rising_edge(clk);
        cpu_wr <= '0';
        cpu_sel <= '0';
        
        for i in 0 to 6 loop
            wait until rising_edge(clk);
        end loop;
        
        wait until rising_edge(clk);
        cpu_wdata <= X"00002345";
        cpu_wr <= '1';
        cpu_sel <= '1';
        
        wait until rising_edge(clk);
        cpu_wr <= '0';
        cpu_sel <= '0';
        
        for i in 0 to 6 loop
            wait until rising_edge(clk);
        end loop;
        -- First pulse entry end.
        
        
        -- Second pulse entry start.
        wait until rising_edge(clk);
        cpu_wdata <= X"00003456";
        cpu_wr <= '1';
        cpu_sel <= '1';
        
        wait until rising_edge(clk);
        cpu_wr <= '0';
        cpu_sel <= '0';
        
        for i in 0 to 6 loop
            wait until rising_edge(clk);
        end loop;
        
        
        wait until rising_edge(clk);
        cpu_wdata <= X"BCBCBCBC";
        cpu_wr <= '1';
        cpu_sel <= '1';
        
        wait until rising_edge(clk);
        cpu_wr <= '0';
        cpu_sel <= '0';
        
        for i in 0 to 6 loop
            wait until rising_edge(clk);
        end loop;
        
        wait until rising_edge(clk);
        cpu_wdata <= X"00004567";
        cpu_wr <= '1';
        cpu_sel <= '1';
        
        wait until rising_edge(clk);
        cpu_wr <= '0';
        cpu_sel <= '0';
        
        for i in 0 to 6 loop
            wait until rising_edge(clk);
        end loop;
        -- Second pulse entry end.
        
        -- Third pulse entry start.
        wait until rising_edge(clk);
        cpu_wdata <= X"00005678";
        cpu_wr <= '1';
        cpu_sel <= '1';
        
        wait until rising_edge(clk);
        cpu_wr <= '0';
        cpu_sel <= '0';
        
        for i in 0 to 6 loop
            wait until rising_edge(clk);
        end loop;
        
        
        wait until rising_edge(clk);
        cpu_wdata <= X"CDCDCDCD";
        cpu_wr <= '1';
        cpu_sel <= '1';
        
        wait until rising_edge(clk);
        cpu_wr <= '0';
        cpu_sel <= '0';
        
        for i in 0 to 6 loop
            wait until rising_edge(clk);
        end loop;
        
        wait until rising_edge(clk);
        cpu_wdata <= X"00006789";
        cpu_wr <= '1';
        cpu_sel <= '1';
        
        wait until rising_edge(clk);
        cpu_wr <= '0';
        cpu_sel <= '0';
        
        for i in 0 to 6 loop
            wait until rising_edge(clk);
        end loop;
        -- Third pulse entry end.
        
        
        trigger <= '1';
        wait until rising_edge(clk);
        trigger <= '0';
        
        for i in 0 to 5 loop
            wait until rising_edge(clk);
        end loop;
        
        wait;
        
        
    end process;
    
end architecture sim;