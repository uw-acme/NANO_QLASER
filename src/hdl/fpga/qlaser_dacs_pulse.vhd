---------------------------------------------------------------
--  File         : qlaser_top.vhd
--  Description  : Top-level of Qlaser FPGA
----------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.qlaser_pkg.all;
use     work.qlaser_dac_pulse_pkg.all;

entity qlaser_dacs_pulse is
port (
        clk               : in  std_logic; 
        reset             : in  std_logic;

        trigger           : in  std_logic;                        -- Trigger (rising edge) to start pulse output
        busy              : out std_logic;                        -- Set to '1' while pulse outputs are occurring

        -- CPU interface
        cpu_addr          : in  std_logic_vector(11 downto 0);    -- Address input
        cpu_wdata         : in  std_logic_vector(31 downto 0);    -- Data input
        cpu_wr            : in  std_logic;                        -- Write enable 
        cpu_sel           : in  std_logic;                        -- Block select
        cpu_rdata         : out std_logic_vector(31 downto 0);    -- Data output
        cpu_rdata_dv      : out std_logic;                        -- Acknowledge output
        
        ram_data         : out std_logic_vector(39 downto 0);
                       
        -- Pulse train outputs
        dacs_pulse        : out std_logic_vector(31 downto 0)     -- Data output
);
end entity;


architecture rtl of qlaser_dacs_pulse is

signal reg_pulse        : std_logic_vector(31 downto 0);
signal ram_addr         : std_logic_vector(4 downto 0);
signal ram_din          : std_logic_vector(39 downto 0);
signal ram_dout         : std_logic_vector(39 downto 0);
signal ram_ena          : std_logic_vector(0 downto 0);
signal cpu_wdata_reg    : std_logic_vector(31 downto 0);
signal ram_din_reg      : std_logic_vector(23 downto 0);

signal ram_addrb        : std_logic_vector(4 downto 0);
signal ram_doutb        : std_logic_vector(39 downto 0);

signal time_count       : std_logic_vector(23 downto 0);

signal trigger_i        : std_logic;

type t_state is (S_IDLE, S_READ, S_AMPLITUDE, S_LOAD_RAM, S_LOAD_RAM2, S_STOP_TIME);
signal state        : t_state;

type t_state2 is (S0, S1, S2, S3, S4);
signal trig_state   : t_state2;

begin

    dacs_pulse  <= reg_pulse;
    busy        <= '0';

    
    u_ram: entity work.blk_mem_40x32
    port map(
        addra               => ram_addr,
        clka                => clk, 

        dina                => ram_din,
        
        wea                 => ram_ena,
        
        addrb               => ram_addrb,
        clkb                => clk,
        doutb               => ram_doutb
    );
    
   
    
    pr_trig_debounce : process(clk, reset)
    begin
        if reset = '1' then
            trigger_i <= '0';
            trig_state <= S0;
        elsif rising_edge(clk) then
            case trig_state is
                when S0 =>
                    if trigger = '1' then
                        trigger_i <= '1';
                        trig_state <= S1;
                    end if;
                    
                when S1 =>
                    trigger_i <= '0';
                    trig_state <= S2;
                
                when S2 =>
                    trig_state <= S3;
                    
                when S3 =>
                    trig_state <= S4;
                    
                when S4 =>
                    if trigger = '0' then
                        trig_state <= S0;
                    end if;
            end case;
        end if;
            
    end process;
    
    ram_data   <= ram_doutb;
    
    pr_trigger  : process(clk, reset)
    begin
        if reset = '1' then
            state           <= S_IDLE;
            ram_addr        <= (others => '0');
            ram_din         <= (others => '0');
            ram_addrb       <= (others => '0');
            ram_din_reg     <= (others => '0');
            time_count      <= (others => '0');
            
        elsif rising_edge(clk) then
            case state is
                when S_IDLE =>
                    -- If we just entered this state after a write, set enable to 0 and increment the address.
                    if ram_ena = "1" then
                        ram_ena <= "0";
                        ram_addr <= std_logic_vector(unsigned(ram_addr) + "1");
                    end if;

                    if trigger_i = '1' then
                        time_count <= (others => '0');
                        ram_addrb  <= (others => '0');
                        state <= S_READ;
                    -- Wait for the first cpu write which contains the start time of a pulse.
                    elsif cpu_wr = '1' and cpu_sel = '1' then
                        state <= S_AMPLITUDE;
                        ram_din_reg(23 downto 0) <= cpu_wdata(23 downto 0);
                    else
                        state <= S_IDLE;
                    end if;
                
                -- Wait for another cpu write to get the amplitude of the pulse.
                when S_AMPLITUDE =>
                    if cpu_wr = '1' and cpu_sel = '1' then
                        ram_din <= cpu_wdata(15 downto 0) & ram_din_reg;
                        state <= S_LOAD_RAM;
                    else
                        state <= S_AMPLITUDE;
                    end if;
                        
                -- Load the amplitude/time into the RAM.    
                when S_LOAD_RAM => 
                        ram_ena <= "1";
                        state <= S_IDLE;
                        
                -- Wait for another cpu write that contains the stop time of the pulse.        
                --when S_STOP_TIME =>
                --    -- If we just entered this state, set enable to 0 and increment the address.
                --    if ram_ena = "1" then
                --        ram_ena <= "0";
                --        ram_addr <= std_logic_vector(unsigned(ram_addr) + "1");
                --    end if;
                --        
                --
                --    if cpu_wr = '1' and cpu_sel = '1' then
                --        -- The amplitude should be 0.
                --        ram_din <= X"0000" & cpu_wdata(23 downto 0);
                --        state <= S_LOAD_RAM2;
                --    else
                --        state <= S_STOP_TIME;
                --    end if;
                --
                ---- Load the end of the pulse into the RAM.
                --when S_LOAD_RAM2 =>
                --    ram_ena <= "1";
                --    state <= S_IDLE;
                
                
                when S_READ =>
                    if time_count /= C_MAX_TIME then
                        time_count <= std_logic_vector(unsigned(time_count) + "1");
                        -- If the current time equals the time of the entry, send a JESD message and increment address.
                        if time_count = ram_doutb(23 downto 0) then
                            ram_addrb   <= std_logic_vector(unsigned(ram_addrb) + "1");
                            -- TODO: Add JESD message send.
                        end if;
                        state <= S_READ;
                    else
                        -- TODO: Send JESD message to set amplitude to 0 in case the table wasn't entered correctly.
                        state <= S_IDLE;
                    end if;
    
                        
            end case;
        end if;
    end process;

end rtl;
