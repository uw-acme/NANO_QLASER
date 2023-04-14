---------------------------------------------------------------
--  File         : qlaser_top.vhd
--  Description  : Top-level of Qlaser FPGA
----------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.qlaser_pkg.all;
use     work.qlaser_dac_pulse_pkg.all;

entity qlaser_single_pulse_channel is
port (
        clk               : in  std_logic; 
        reset             : in  std_logic;

        trigger           : in  std_logic;                        -- Trigger (rising edge) to start pulse output

        -- CPU interface
        cpu_addr          : in  std_logic_vector(11 downto 0);    -- Address input
        cpu_wdata         : in  std_logic_vector(31 downto 0);    -- Data input
        cpu_wr            : in  std_logic;                        -- Write enable 
        cpu_sel           : in  std_logic;                        -- Block select
        
                       
        data_to_JESD      : out std_logic_vector(15 downto 0)
);
end entity;


architecture rtl of qlaser_single_pulse_channel is

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


type t_state is (S_IDLE, S_READ, S_AMPLITUDE, S_LOAD_RAM);
signal state        : t_state;

begin

    
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
    
    pr_trigger  : process(clk, reset)
    begin
        if reset = '1' then
            state           <= S_IDLE;
            ram_addr        <= (others => '0');
            ram_din         <= (others => '0');
            ram_addrb       <= (others => '0');
            ram_din_reg     <= (others => '0');
            time_count      <= (others => '0');
            data_to_JESD    <= (others => '0');
            
        elsif rising_edge(clk) then
            case state is
                when S_IDLE =>
                    -- If we just entered this state after a write, set enable to 0 and increment the address.
                    if ram_ena = "1" then
                        ram_ena <= "0";
                        ram_addr <= std_logic_vector(unsigned(ram_addr) + "1");
                    end if;

                    if trigger = '1' then
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
                
                
                when S_READ =>
                    if time_count /= C_MAX_TIME then
                        data_to_JESD <= (others => '0');
                        time_count <= std_logic_vector(unsigned(time_count) + "1");
                        -- If the current time equals the time of the entry, send a JESD message and increment address.
                        if time_count = ram_doutb(23 downto 0) then
                            ram_addrb   <= std_logic_vector(unsigned(ram_addrb) + "1");
                            -- TODO: Add JESD message send.
                            data_to_JESD <= ram_doutb(39 downto 24);
                        end if;
                        state <= S_READ;
                    else
                        -- TODO: Send JESD message to set amplitude to 0 in case the table wasn't entered correctly.
                        data_to_JESD <= (others => '0');
                        state <= S_IDLE;
                    end if;
    
                        
            end case;
        end if;
    end process;

end rtl;