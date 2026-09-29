---------------------------------------------------------------
--  File         : qlaser_dacs_pulse_channel_ramp.vhdl
--  Description  : Channel of pulse output for debugging JESD interface
--                 that, when enabled, generates a repeating ramp 
--                 from 0 to 2^16-1, increasing by a programmable 
--                 step size, resetting to zero after reaching the max value.
----------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.qlaser_pkg.all;

entity qlaser_dacs_pulse_channel is
port (
    reset               : in  std_logic;
    clk                 : in  std_logic; 

    enable              : in  std_logic;                        -- Set to allow channel to run. Rising edge send 0 to DAC.
    start               : in  std_logic;                        -- Set when pulse generation sequence begins
    cnt_time            : in  std_logic_vector(23 downto 0);    -- Time since trigger.

    busy                : out std_logic;                        -- Status signal
    err_wave            : out std_logic;                        -- 

    -- CPU interface
    cpu_addr            : in  std_logic_vector(11 downto 0);    -- Address input
    cpu_wdata           : in  std_logic_vector(31 downto 0);    -- Data input
    cpu_wr              : in  std_logic;                        -- Write enable 
    cpu_sel             : in  std_logic;                        -- Block select
    cpu_rdata           : out std_logic_vector(31 downto 0);    -- Data output
    cpu_rdata_dv        : out std_logic;                        -- Acknowledge output
     
    -- AXI-stream output
    axis_tready         : in  std_logic;                        -- axi_stream ready from downstream module
    axis_tdata          : out std_logic_vector(15 downto 0);    -- axi stream output data
    axis_tvalid         : out std_logic;                        -- axi_stream output data valid
    axis_tlast          : out std_logic                         -- axi_stream output set on last data  
);
end entity;


----------------------------------------------------------------
-- Empty architecture with a single 32-bit r/w register
----------------------------------------------------------------
architecture ramp of qlaser_dacs_pulse_channel is

signal reg_ramp : std_logic_vector(15 downto 0);
signal cnt_ramp : unsigned(19 downto 0);

begin

    err_wave            <= '0'; -- No possible errors

    ----------------------------------------------------------------
    -- Set busy whenever enabled
    ----------------------------------------------------------------
    pr_busy  : process (reset, clk)
    begin
        if (reset = '1') then
            busy    <= '0';
        elsif rising_edge(clk) then
            busy    <= enable;
        end if;
    end process;


    ----------------------------------------------------------------
    -- AXI-Stream output. A continuous ramp that wraps back to zero 
    -- from 0xFFFF
    ----------------------------------------------------------------
    pr_axi_s  : process (reset, clk)
    begin
        if (reset = '1') then

            cnt_ramp            <= (others=>'0');   -- Ramp value
            axis_tvalid         <= '0';             -- axi_stream output data valid

        elsif rising_edge(clk) then

            if (enable = '1') then

                if (cnt_ramp + unsigned(reg_ramp) > X"0FFFF") then
                    cnt_ramp    <= (others=>'0');
                else    
                    cnt_ramp    <= cnt_ramp + unsigned(reg_ramp);
                end if;
                
                axis_tvalid     <= '1';             -- axi_stream output data valid

            else    
                cnt_ramp        <= (others=>'0');
                axis_tvalid     <= '0'; 
            end if;

        end if;
    end process;

    axis_tdata          <= std_logic_vector(cnt_ramp(15 downto 0));     -- axi stream output data
    axis_tlast          <= '0';                                         -- axi_stream output last 


    ----------------------------------------------------------------
    -- CPU Read/Write 
    ----------------------------------------------------------------
    pr_ram_rw  : process (reset, clk)
    begin
        if (reset = '1') then
        
            cpu_rdata           <= (others=>'0');
            cpu_rdata_dv        <= '0'; 
            reg_ramp            <= X"0001";
            
        elsif rising_edge(clk) then
        
            -------------------------------------------------
            -- CPU write
            -------------------------------------------------
            if (cpu_wr = '1') and (cpu_sel = '1') then
            
                case cpu_addr is
                    when X"000" =>  reg_ramp    <= cpu_wdata(15 downto 0);
                    when others =>  null;
                end case;

            -------------------------------------------------
            -- CPU read
            -------------------------------------------------
            elsif (cpu_wr = '0') and (cpu_sel = '1') then
                
                case cpu_addr is
                    when X"000" =>  cpu_rdata   <= X"0000" & reg_ramp(15 downto 0); 
                    when X"001" =>  cpu_rdata   <= X"00001234"; -- Just a test value
                    when others =>  cpu_rdata   <= X"CCCCCCCC"; -- All other addresses                   
                end case;
                cpu_rdata_dv    <= '1';     

            else
                cpu_rdata       <= (others=>'0');
                cpu_rdata_dv    <= '0';
            
            end if;
            
        end if;
        
    end process;

end ramp;

