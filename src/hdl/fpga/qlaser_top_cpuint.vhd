---------------------------------------------------------------
--  File         : qlaser_top_cpuint.vhd
--  Description  : Top-level of Qlaser FPGA with CPU interface 
--                 and one CPU bus connection (qlaser_misc)
----------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.qlaser_pkg.all;

entity qlaser_top is
port (
    p_clk                   : in    std_logic;          -- Clock 
    p_reset_n               : in    std_logic;          -- Reset. Check polarity is correct 

    p_trigger               : in    std_logic;          -- Trigger (rising edge) to start pulse output
    p_busy                  : out   std_logic;          -- Set to '1' while pulse outputs are occurring

    -- Serial interface for register read/write
    p_serial_rxd            : in    std_logic;          -- UART Receive data
    p_serial_txd            : out   std_logic;          -- UART Transmit data 

    
    -- Interface SPI bus to 8-channel PMOD for DC channels 0-7
    p_dc0_sclk              : out   std_logic;          -- Clock (50 MHz?)
    p_dc0_mosi              : out   std_logic;          -- Master out, Slave in. (Data to DAC)
    p_dc0_cs_n              : out   std_logic;          -- Active low chip select (sync_n)

    -- Interface SPI bus to 8-channel PMOD for DC channels 8-15
    p_dc1_sclk              : out   std_logic;  
    p_dc1_mosi              : out   std_logic;  
    p_dc1_cs_n              : out   std_logic;  

    -- Interface SPI bus to 8-channel PMOD for DC channels 16-23
    p_dc2_sclk              : out   std_logic;  
    p_dc2_mosi              : out   std_logic;  
    p_dc2_cs_n              : out   std_logic;  

    -- Interface SPI bus to 8-channel PMOD for DC channels 24-31
    p_dc3_sclk              : out   std_logic; 
    p_dc3_mosi              : out   std_logic;  
    p_dc3_cs_n              : out   std_logic;  

    -- 32 pulse outputs
    p_dacs_pulse            : out   std_logic_vector(31 downto 0);

    -- User buttons
    p_btn0                  : in    std_logic; 
    p_btn1                  : in    std_logic; 

    -- Indicator LEDs
    p_leds0_rgb             : out   std_logic_vector( 2 downto 0);      -- 
    p_leds1_rgb             : out   std_logic_vector( 2 downto 0);      -- 

    -- Debug port (if present)
    p_debug_out             : out   std_logic_vector( 7 downto 0)       -- 
);
end entity;

---------------------------------------------------------------
--
---------------------------------------------------------------
architecture cpuint of qlaser_top is

signal clk                  : std_logic;
signal reset                : std_logic;

signal cpuint_rxd           : std_logic;    -- UART Receive data
signal cpuint_txd           : std_logic;    -- UART Transmit data 
signal cpuint_debug         : std_logic_vector( 3 downto 0);

-- CPU interface
signal cpu_sels             : std_logic_vector(C_NUM_BLOCKS-1 downto 0);    -- CPU block selects 
signal cpu_wr               : std_logic;
signal cpu_addr             : std_logic_vector(15 downto 0);
signal cpu_din              : std_logic_vector(31 downto 0);
signal cpu_debug            : std_logic_vector( 3 downto 0);

signal arr_cpu_dout         : t_arr_cpu_dout;
signal arr_cpu_dout_dv      : std_logic_vector(C_NUM_BLOCKS-1 downto 0);

constant SEL_DAC_DC         : integer :=  0;    -- For DC DACs
constant SEL_DAC_PULSE      : integer :=  1;    -- For Pulse DACs
constant SEL_MISC           : integer :=  2;    -- Misc, LEDs, switches, version

signal misc_leds            : std_logic_vector( 3 downto 0);
signal misc_leds_en         : std_logic_vector( 3 downto 0);
signal misc_flash           : std_logic;
signal tick_msec            : std_logic;                        --  Timing intervals
signal tick_sec             : std_logic;            
signal misc_dbg_ctrl        : std_logic_vector( 3 downto 0);
signal misc_trigger         : std_logic;

signal pulse                : std_logic_vector( 3 downto 0);
signal pulse_stretched      : std_logic_vector( 3 downto 0);

signal pll_lock             : std_logic;
signal trigger              : std_logic;

signal dacs_dc_busy         : std_logic_vector( 3 downto 0);    -- Set to '1' while SPI bus is busy
signal dacs_pulse_busy      : std_logic;                        -- Set to '1' while pulse outputs are occurring

-- LED colors
constant C_LED_BLUE         : integer := 0;
constant C_LED_GREEN        : integer := 1;
constant C_LED_RED          : integer := 2;

begin

    p_busy  <= dacs_dc_busy(0) or dacs_dc_busy(1) or dacs_dc_busy(2) or dacs_dc_busy(3) or dacs_pulse_busy;

    --------------------------------------------------------------------
    -- Power on reset circuit. Wait until clock is stable before 
    -- releasing reset.
    --------------------------------------------------------------------
    u_clkreset : entity work.clkreset
    port map(
        -- Reset and clock from pads
        p_reset_n    => p_reset_n   , -- in  std_logic;
        p_clk        => p_clk       , -- in  std_logic;

        -- Reset and clock outputs to all internal logic
        clk          => clk         , -- out std_logic;
        lock         => pll_lock    , -- out std_logic;
        reset        => reset         -- out std_logic
    );


    --------------------------------------------------------------------
    -- Serial interface to convert between UART lines and CPU bus 
    --------------------------------------------------------------------
    u_cpuint : entity work.qlaser_cpuint
    port map(
        clk                 => clk                      , -- in  std_logic;
        reset               => reset                    , -- in  std_logic;
        tick_msec           => tick_msec                , -- in  std_logic;    -- Used to reset serial interface if a message is corrupted

        -- UART interface to CPU
        rxd                 => cpuint_rxd               , -- in  std_logic;    -- UART Receive data
        txd                 => cpuint_txd               , -- out std_logic;    -- UART Transmit data 

        -- CPU master interface to other blocks in the FPGA
        cpu_rd              => open                     , -- out std_logic;
        cpu_wr              => cpu_wr                   , -- out std_logic;
        cpu_sels            => cpu_sels                 , -- out std_logic_vector(C_NUM_BLOCKS-1 downto 0); -- Decoded from upper 4-bits of addresses
        cpu_addr            => cpu_addr                 , -- out std_logic_vector(15 downto 0);
        cpu_din             => cpu_din                  , -- out std_logic_vector(31 downto 0);
        arr_cpu_dout_dv     => arr_cpu_dout_dv          , -- in  std_logic_vector(C_NUM_BLOCKS-1 downto 0);
        arr_cpu_dout        => arr_cpu_dout             , -- in  t_arr_cpu_dout;

        debug               => cpu_debug                  -- out std_logic_vector( 3 downto 0);
    );


    -- Tie off unused CPU outputs
    arr_cpu_dout_dv(SEL_DAC_DC)     <= '0';
    arr_cpu_dout(SEL_DAC_DC)        <= (others=>'0');

    arr_cpu_dout_dv(SEL_DAC_PULSE)  <= '0';
    arr_cpu_dout(SEL_DAC_PULSE)     <= (others=>'0');


    -- Combine p_trigger (from pad) with misc block trigger to create internal trigger
    trigger     <= p_trigger or misc_trigger;

    ---------------------------------------------------------------------------------
    -- Misc interfaces. LEDs, Debug
    ---------------------------------------------------------------------------------
    u_misc_if : entity work.qlaser_misc
    port map(
        clk                 => clk                      , -- in  std_logic; 
        reset               => reset                    , -- in  std_logic;

        -- CPU interface
        cpu_addr            => cpu_addr(11 downto 0)    , -- in  std_logic_vector(11 downto 0);    -- Address input
        cpu_wdata           => cpu_din                  , -- in  std_logic_vector(31 downto 0);    -- Data input
        cpu_wr              => cpu_wr                   , -- in  std_logic;                        -- Write enable 
        cpu_sel             => cpu_sels(SEL_MISC)       , -- in  std_logic;                        -- Block select
        cpu_rdata           => arr_cpu_dout(SEL_MISC)   , -- out std_logic_vector(31 downto 0);    -- Data output
        cpu_rdata_dv        => arr_cpu_dout_dv(SEL_MISC), -- out std_logic;                        -- Data valid
                       
        pulse               => pulse                    , -- in  std_logic_vector( 3 downto 0);
        pulse_stretched     => pulse_stretched          , -- out std_logic_vector( 3 downto 0);

        -- Block outputs              
        leds                => misc_leds                , -- out std_logic_vector( 3 downto 0);    -- LED output
        leds_en             => misc_leds_en             , -- out std_logic_vector( 3 downto 0);    -- CPU controlled LED enable 
        flash               => misc_flash               , -- out std_logic;    --     
        tick_msec           => tick_msec                , -- out std_logic;                        -- Single cycle high every 1 msec. Used by SD interface debug registers
        tick_sec            => tick_sec                 , -- out std_logic;                        -- Single cycle high every N msec. 

        dbg_ctrl            => misc_dbg_ctrl            , -- out std_logic_vector( 3 downto 0);
        trigger             => misc_trigger               -- out std_logic
    );

 
    ---------------------------------------------------------------------------------
    -- Control RGB LEDs either from the 'misc_if' block or from FPGA logic
    -- LEDs are active high
    ---------------------------------------------------------------------------------
    pr_leds : process (clk)
    begin
        if rising_edge(clk) then

            p_leds0_rgb(C_LED_BLUE)     <= misc_flash;

            -- LEDs can be controlled by the CPU or from pulse stretcher.
            for N in 1 to 3 loop
                if (misc_leds_en(N) = '1') then
                    p_leds1_rgb(N) <= not(misc_leds(N));
                else
                    p_leds1_rgb(N) <= not(pulse_stretched(N));
                end if;
            end loop;

         end if;
    end process;

    -- Input to pulse stretcher in the misc block which will make signals visible on the LEDs
    pulse(0)    <= '0';
    pulse(1)    <= trigger or dacs_dc_busy(0) or dacs_dc_busy(1) or dacs_dc_busy(2) or dacs_dc_busy(3) or dacs_pulse_busy;
    pulse(2)    <= p_serial_rxd;
    pulse(3)    <= cpuint_txd;


    ---------------------------------------------------------------------------------
    -- UART pins
    ---------------------------------------------------------------------------------
    cpuint_rxd          <= p_serial_rxd;
    p_serial_txd        <= cpuint_txd;


    ---------------------------------------------------------------------------------
    -- Debug output mux.
    ---------------------------------------------------------------------------------
    pr_dbg_mux : process (clk)
    begin
        if rising_edge(clk) then

            case to_integer(unsigned(misc_dbg_ctrl)) is

                -- "1111" is the default setting for misc_dbg_ctrl
                -- Normally selects all zero debug output.
                when 15  => -- Default
                        p_debug_out    <= (others=>'0');


                when 14 => 
                        p_debug_out(0)              <= '0';
                        p_debug_out(1)              <= '0';
                        p_debug_out(2)              <= pll_lock;
                        p_debug_out(3)              <= tick_msec;
                        p_debug_out(4)              <= tick_sec;
                        p_debug_out(7 downto  5)    <= (others=>'0');


                when others => 
                        p_debug_out                 <= (others=>'0');
            end case;
        end if;
    end process;


end cpuint;