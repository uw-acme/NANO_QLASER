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
        
        ram0_data         : out std_logic_vector(39 downto 0);
                       
        -- Pulse train outputs
        dacs_pulse        : out std_logic_vector(31 downto 0)     -- Data output
);
end entity;


architecture rtl of qlaser_dacs_pulse is

signal reg_pulse        : std_logic_vector(31 downto 0);
signal ram0_addr        : std_logic_vector(4 downto 0);
signal ram0_din         : std_logic_vector(39 downto 0);
signal ram0_dout        : std_logic_vector(39 downto 0);
signal ram0_ena         : std_logic_vector(0 downto 0);
signal ram0_max_addr    : std_logic_vector(4 downto 0);
signal cpu_wdata_reg    : std_logic_vector(31 downto 0);

signal ram0_addrb       : std_logic_vector(4 downto 0);
signal ram0_doutb       : std_logic_vector(39 downto 0);

signal trigger_i        : std_logic;

type t_state is (S_IDLE, S_READ, S_WRITE_STAGE_1, S_WRITE_STAGE_2, S_WRITE_STAGE_3);
signal state        : t_state;

type t_state2 is (S0, S1, S2, S3, S4);
signal trig_state   : t_state2;

begin

    dacs_pulse  <= reg_pulse;
    busy        <= '0';


    -------------------------------------------------------
    -- CPU interface.
    -------------------------------------------------------
    --pr_cpu_rw : process (clk)
    --begin
    --
    --    if rising_edge(clk) then
    --
    --        cpu_rdata       <= (others=>'0');
    --        cpu_rdata_dv    <= '0';
    --
    --        if (reset='1') then
    --            reg_pulse           <= (others=>'0');
    --            
    --        -- Write registers
    --        elsif (cpu_sel='1' and cpu_wr='1') then
    --
    --            case to_integer(unsigned(cpu_addr(3 downto 0))) is
    --
    --                when  0         => reg_pulse         <= cpu_wdata;
    --                when others     => null;
    --            end case;
    --
    --        -- Read registers
    --        elsif (cpu_sel='1' and cpu_wr='0') then
    --
    --            case to_integer(unsigned(cpu_addr(3 downto 0))) is
    --
    --                when   0        => cpu_rdata        <= reg_pulse;    
    --                when others     => cpu_rdata        <= X"CCCCCCCC";
    --            end case;
    --            cpu_rdata_dv  <= '1';
    --
    --        end if;
    --
    --    end if;
    --
    --end process;
    
    u_ram0: entity work.blk_mem_40x32
    port map(
        addra               => ram0_addr,
        clka                => clk, 

        dina                => ram0_din,
        
        wea                 => ram0_ena,
        
        addrb               => ram0_addrb,
        clkb                => clk,
        doutb               => ram0_doutb
    );
    
    --pr_cpu : process(clk, reset)
    --begin
    --    if reset = '1' then
    --        ram0_addr <= (others => '1');
    --        ram0_din  <= (others => '0');
    --        ram0_max_addr   <= (others => '1');
    --
    --    elsif rising_edge(clk) then
    --        ram0_ena <= "0";
    --        
    --        if cpu_wr = '1' and cpu_sel = '1' then
    --            
    --            case cpu_addr(1 downto 0) is
    --            
    --                when C_ADDR_RAM0    =>
    --                    ram0_addr   <= std_logic_vector(unsigned(ram0_addr) + "1");
    --                    ram0_max_addr <= std_logic_vector(unsigned(ram0_addr) + "1");
    --                    ram0_din    <= "00000000" & cpu_wdata;
    --                    ram0_ena    <= "1";  
    --
    --                when others => null;
    --                    
    --            end case;
    --        
    --        end if;
    --    
    --    end if;
    --        
    --end process;
    
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
    
    ram0_data   <= ram0_doutb;
    
    pr_trigger  : process(clk, reset)
    begin
        if reset = '1' then
            state <= S_IDLE;
            ram0_addr <= (others => '0');
            ram0_din  <= (others => '0');
            ram0_max_addr   <= (others => '0');
            ram0_addrb  <= (others => '0');
            
        elsif rising_edge(clk) then
            case state is
                when S_IDLE =>
                    
                    if trigger_i = '1' then
                        state <= S_READ;
                        ram0_max_addr <= std_logic_vector(unsigned(ram0_addr) - "1");
                    elsif cpu_wr = '1' and cpu_sel = '1' then
                        state <= S_WRITE_STAGE_1;
                        cpu_wdata_reg <= cpu_wdata;
                    else
                        state <= S_IDLE;
                    end if;
                    
                when S_WRITE_STAGE_1 =>
                    ram0_din <= "00000000" & cpu_wdata_reg;
                    state <= S_WRITE_STAGE_2;
                    
                when S_WRITE_STAGE_2 => 
                        ram0_ena <= "1";
                        state <= S_WRITE_STAGE_3;
                        
                when S_WRITE_STAGE_3 =>
                    ram0_addr   <= std_logic_vector(unsigned(ram0_addr) + "1");
                    ram0_ena <= "0";
                    state <= S_IDLE;
                        
                when S_READ =>
                    ram0_addrb   <= std_logic_vector(unsigned(ram0_addrb) + "1");
                    state <= S_IDLE;    
                        
            end case;
        end if;
    end process;

end rtl;
