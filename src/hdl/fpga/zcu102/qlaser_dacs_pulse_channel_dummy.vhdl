---------------------------------------------------------------
--  File         : qlaser_dacs_pulse_channel_dummy.vhd
--  Description  : Single channel of pulse output
--                 Mainly empty except for one 'test' register
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
-- Single channel pulse generator with two RAMs
----------------------------------------------------------------
architecture dummy of qlaser_dacs_pulse_channel is

-- Simple register
signal reg_test : std_logic_vector(31 downto 0);

begin

    busy    <= '0';

    -- AXI-Stream output.
    axis_tdata          <= (others=>'0');   -- axi stream output data
    axis_tvalid         <= '0';             -- axi_stream output data valid
    axis_tlast          <= '0';             -- axi_stream output last 


    ----------------------------------------------------------------
    -- CPU Read/Write 
    ----------------------------------------------------------------
    pr_ram_rw  : process (reset, clk)
    begin
        if (reset = '1') then
        
            cpu_rdata           <= (others=>'0');
            cpu_rdata_dv        <= '0'; 
            reg_test            <= (others=>'0');
            
        elsif rising_edge(clk) then
        
            -------------------------------------------------
            -- CPU write
            -------------------------------------------------
            if (cpu_wr = '1') and (cpu_sel = '1') then
            
                reg_test        <= cpu_wdata;

            -------------------------------------------------
            -- CPU read
            -------------------------------------------------
            elsif (cpu_wr = '0') and (cpu_sel = '1') then
                
                cpu_rdata_dv    <= '1';     
                cpu_rdata       <= reg_test; 
                    
            else
                cpu_rdata_dv    <= '0';
                cpu_rdata       <= (others=>'0');
            
            end if;
            
        end if;
        
    end process;

end dummy;
