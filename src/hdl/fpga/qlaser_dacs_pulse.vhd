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
                       
        -- Pulse train outputs
        dacs_pulse        : out std_logic_vector(31 downto 0);    -- Data output
        
        data_to_JESD      : out t_arr_data_JESD
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

type t_state2 is (S0, S1, S2, S3, S4);
signal trig_state   : t_state2;

signal channel_sels     : std_logic_vector(31 downto 0);

begin

    dacs_pulse  <= reg_pulse;
    busy        <= '0';
    
    -- Select channel from address during write.
    pr_channel_sel : process(cpu_wr, cpu_sel, cpu_addr)
    begin
        channel_sels    <= (others=>'0');
        if (cpu_wr = '1' and cpu_sel = '1') then
            channel_sels(to_integer(unsigned(cpu_addr(4 downto 0)))) <= '1';
        end if;
    end process;
    
    g_pulsed_dacs: for i in 0 to 31 generate
        u_pulsed_channel : entity work.qlaser_single_pulse_channel
            port map(
                clk               => clk, 
                reset             => reset,
        
                trigger           => trigger_i,                        -- Trigger (rising edge) to start pulse output
        
                -- CPU interface
                cpu_addr          => cpu_addr,    -- Address input
                cpu_wdata         => cpu_wdata,    -- Data input
                cpu_wr            => cpu_wr,                        -- Write enable 
                cpu_sel           => channel_sels(i),                        -- Block select
                
                data_to_JESD      => data_to_JESD(i)
            );
    end generate;
    
   
    
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
    

end rtl;
