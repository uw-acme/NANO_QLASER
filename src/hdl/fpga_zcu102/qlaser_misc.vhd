----------------------------------------------------------------------------
--  File         : qlaser_misc.vhd
----------------------------------------------------------------------------
-- UW Neurochip :
-- Description  : Miscellaneous signals interface.  
--                Includes version number register, trigger register and 'blink' block.
----------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.qlaser_version_pkg.all;

entity qlaser_misc is
port (
    clk             : in  std_logic;
    reset           : in  std_logic;

    -- CPU interface
    cpu_addr        : in  std_logic_vector(11 downto 0);    -- Address input
    cpu_wdata       : in  std_logic_vector(31 downto 0);    -- Data input
    cpu_wr          : in  std_logic;                        -- Write enable 
    cpu_sel         : in  std_logic;                        -- Block select
    cpu_rdata       : out std_logic_vector(31 downto 0);    -- Data output
    cpu_rdata_dv    : out std_logic;                        -- Acknowledge output

    pulse           : in  std_logic_vector( 3 downto 0);
    pulse_stretched : out std_logic_vector( 3 downto 0);

    leds            : out std_logic_vector( 3 downto 0);    -- CPU controlled LED drive
    leds_en         : out std_logic_vector( 3 downto 0);    -- CPU controlled LED enable 
    flash           : out std_logic;                        -- For blinking an LED 

    -- Other block outputs              
    tick_usec       : out std_logic;                        -- Single cycle high every 1 microsec. Used by SNN
    tick_msec       : out std_logic;                        -- Single cycle high every 1 msec. Used by SD interface debug registers
    tick_sec        : out std_logic;                        -- Single cycle high every 1 sec. 
    dbg_ctrl        : out std_logic_vector( 3 downto 0);    -- Select output to debug pins
    trigger         : in std_logic;
    enable          : out std_logic
);
end qlaser_misc;

---------------------------------------------------------------------------------
-- Version number, LEDs, debug
---------------------------------------------------------------------------------
architecture rtl of qlaser_misc is

constant ADR_REG_VERSION    : integer := 0;     -- Read-only register containing HDL code version number
constant ADR_REG_LEDS       : integer := 1;     -- '1' sets LED on if corresponding bit in reg_leds_en is also set
constant ADR_REG_LEDS_EN    : integer := 2;     -- '1' allows CPU control of LEDs. '0' allows FPGA logic
constant ADR_REG_DEBUG_CTRL : integer := 3;     -- Select debug output from top level to pins
constant ADR_REG_TRIGGER    : integer := 4;     -- Generate trigger
constant ADR_REG_EN         : integer := 5;     -- Generate enable

signal reg_leds             : std_logic_vector( 3 downto 0); 
signal reg_leds_en          : std_logic_vector( 3 downto 0); 
signal reg_dbg_ctrl         : std_logic_vector( 3 downto 0);
signal reg_trigger          : std_logic;
signal reg_enable           : std_logic;

begin  
    
    --------------------------------------------------------------------
    -- Flash can be used to blink an LED.
    -- Pulse inputs get stretched to make them visible on LEDs.
    -- The 'tick_msec' signal is used by the SD card interface to
    -- measure the duration of card 'busy' times and could be used to reset the 
    -- serial interface if a message is corrupted.
    --------------------------------------------------------------------
    u_blink : entity work.blink
    generic map (
        G_NBITS                => 4,
        G_INTERVAL_TICK_SLOW   => 10  -- TODO 20. Set flash and stretch timing 
    )
    port map(
        reset      => reset             , -- in   std_logic;
        clk        => clk               , -- in   std_logic;
        flash      => flash             , -- out  std_logic;
        tick_sec   => tick_sec          , -- out  std_logic;    -- Slower tick rate
        tick_msec  => tick_msec         , -- out  std_logic;
        tick_usec  => tick_usec         , -- out  std_logic;
        pulse      => pulse             , -- in   std_logic_vector(NBITS-1 downto 0);
        stretched  => pulse_stretched     -- out  std_logic_vector(NBITS-1 downto 0)
    );

    -- Register values connected to ports
    leds            <= reg_leds;
    leds_en         <= reg_leds_en;
    dbg_ctrl        <= reg_dbg_ctrl;
    -- trigger         <= reg_trigger;
    enable          <= reg_enable;

   
    ---------------------------------------------------------------------------------
    -- CPU interface.
    -- CPU can write the table RAM or registers
    ---------------------------------------------------------------------------------
    pr_cpu_rw : process (clk)
    begin
    
        if rising_edge(clk) then

            cpu_rdata       <= (others=>'0');
            cpu_rdata_dv    <= '0';
    
            if (reset='1') then
                reg_leds            <= X"0";
                reg_leds_en         <= X"0";
                reg_dbg_ctrl        <= (others=>'1');   -- Debug outputs driven to zero. Power reduction.
                reg_trigger         <= '0';
                reg_enable          <= '0';
                
            -- Write registers
            elsif (cpu_sel='1' and cpu_wr='1') then
    
                case to_integer(unsigned(cpu_addr(3 downto 0))) is
    
                    when ADR_REG_LEDS       => reg_leds         <= cpu_wdata( 3 downto 0);
                    when ADR_REG_LEDS_EN    => reg_leds_en      <= cpu_wdata( 3 downto 0);
                    when ADR_REG_DEBUG_CTRL => reg_dbg_ctrl     <= cpu_wdata( 3 downto 0);
                    when ADR_REG_TRIGGER    => reg_trigger      <= trigger;
                    when ADR_REG_EN         => reg_enable       <= cpu_wdata(0);
                    when others             => null;
                end case;
    
            -- Read registers
            elsif (cpu_sel='1' and cpu_wr='0') then
    
                case to_integer(unsigned(cpu_addr(3 downto 0))) is

                    when ADR_REG_VERSION    => cpu_rdata        <= C_QLASER_VERSION;    
                    when ADR_REG_LEDS       => cpu_rdata        <= X"0000000" & reg_leds;    
                    when ADR_REG_LEDS_EN    => cpu_rdata        <= X"0000000" & reg_leds_en;    
                    when ADR_REG_DEBUG_CTRL => cpu_rdata        <= X"0000000" & reg_dbg_ctrl;    
                    when ADR_REG_TRIGGER    => cpu_rdata        <= X"0000000" & "000" & reg_trigger;
                    when ADR_REG_EN         => cpu_rdata        <= X"0000000" & "000" & reg_enable;    
                    when others             => cpu_rdata        <= X"CCCCCCCC";
                end case;
                cpu_rdata_dv  <= '1';
    
            end if;
    
        end if;
    
    end process;

	
end;

