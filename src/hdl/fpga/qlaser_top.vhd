---------------------------------------------------------------
--  File         : qlaser_top.vhd
--  Description  : Top-level of Qlaser FPGA
----------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.qlaser_pkg.all;

entity qlaser_top is
port (
    p_clk                   : in    std_logic;          -- Clock 
    p_reset                 : in    std_logic;          -- Reset. Check polarity is correct 

    --p_trigger               : in    std_logic;          -- Trigger (rising edge) to start pulse output
    --p_busy                  : out   std_logic;          -- Set to '1' while pulse outputs are occurring

    -- Serial interface for register read/write
    p_serial_rxd            : in    std_logic;          -- UART Receive data
    p_serial_txd            : out   std_logic;          -- UART Transmit data 

    
    -- Interface SPI bus to 8-channel PMOD for DC channels 0-7
    p_dc0_sclk              : out   std_logic;          -- Clock (50 MHz?)
    p_dc0_mosi              : out   std_logic;          -- Master out, Slave in. (Data to DAC)
    p_dc0_cs_n              : out   std_logic;          -- Active low chip select (sync_n)
    
    p_dc0_sclk_debug        : out   std_logic;          -- Clock (50 MHz?)
    p_dc0_mosi_debug        : out   std_logic;          -- Master out, Slave in. (Data to DAC)
    p_dc0_cs_n_debug        : out   std_logic;          -- Active low chip select (sync_n)
    --
    ---- Interface SPI bus to 8-channel PMOD for DC channels 8-15
    --p_dc1_sclk              : out   std_logic;  
    --p_dc1_mosi              : out   std_logic;  
    --p_dc1_cs_n              : out   std_logic;  
    --
    ---- Interface SPI bus to 8-channel PMOD for DC channels 16-23
    --p_dc2_sclk              : out   std_logic;  
    --p_dc2_mosi              : out   std_logic;  
    --p_dc2_cs_n              : out   std_logic;  
    --
    ---- Interface SPI bus to 8-channel PMOD for DC channels 24-31
    --p_dc3_sclk              : out   std_logic; 
    --p_dc3_mosi              : out   std_logic;  
    --p_dc3_cs_n              : out   std_logic;  
    --
    ---- 32 pulse outputs
    --p_dacs_pulse            : out   std_logic_vector(31 downto 0);
    --
    ---- User buttons
    --p_btn0                  : in    std_logic; 
    --p_btn1                  : in    std_logic; 

    -- Indicator LEDs
    p_leds0_rgb             : out   std_logic_vector( 2 downto 0);      -- 
    p_leds1_rgb             : out   std_logic_vector( 2 downto 0)      -- 

    -- Debug port (if present)
    --p_debug_out             : out   std_logic_vector( 7 downto 0)       -- 
);
end entity;

---------------------------------------------------------------
--
---------------------------------------------------------------
architecture rtl of qlaser_top is

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

signal led0_reg             : std_logic_vector(2 downto 0);
signal led1_reg             : std_logic_vector(2 downto 0);

signal dc0_sclk             : std_logic;
signal dc0_mosi             : std_logic;
signal dc0_cs_n             : std_logic;

begin

    --p_busy  <= dacs_dc_busy(0) or dacs_dc_busy(1) or dacs_dc_busy(2) or dacs_dc_busy(3) or dacs_pulse_busy;

    --------------------------------------------------------------------
    -- Power on reset circuit. Wait until clock is stable before 
    -- releasing reset.
    --------------------------------------------------------------------
    u_clkreset : entity work.clkreset
    port map(
        -- Reset and clock from pads
        p_reset      => p_reset   , -- in  std_logic;
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
        rxd          => cpuint_rxd               , -- in  std_logic;    -- UART Receive data
        txd          => cpuint_txd               , -- out std_logic;    -- UART Transmit data 

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


    ---------------------------------------------------------------------------------
    -- DC DAC interface
    ---------------------------------------------------------------------------------
    u_dacs_dc : entity work.qlaser_dacs_dc
    port map(
        clk                 => clk                          , -- in  std_logic; 
        reset               => reset                        , -- in  std_logic;
    
        busy                => dacs_dc_busy                 , -- out std_logic_vector( 3 downto 0);    -- Set to '1' while pulse outputs are occurring
    
        -- CPU interface
        cpu_addr            => cpu_addr(15 downto 0)        , -- in  std_logic_vector(11 downto 0);    -- Address input
        cpu_wdata           => cpu_din                      , -- in  std_logic_vector(31 downto 0);    -- Data input
        cpu_wr              => cpu_wr                       , -- in  std_logic;                        -- Write enable 
        cpu_sel             => cpu_sels(SEL_DAC_DC)         , -- in  std_logic;                        -- Block select
        cpu_rdata           => arr_cpu_dout(SEL_DAC_DC)     , -- out std_logic_vector(31 downto 0);    -- Data output
        cpu_rdata_dv        => arr_cpu_dout_dv(SEL_DAC_DC)  , -- out std_logic;                        -- Acknowledge output
                       
        -- Interface SPI bus to 8-channel PMOD for DC channels 0-7
        dc0_sclk            => dc0_sclk                   , -- out   std_logic;          -- Clock (50 MHz?)
        dc0_mosi            => dc0_mosi                   , -- out   std_logic;          -- Master out, Slave in. (Data to DAC)
        dc0_cs_n            => dc0_cs_n                    -- out   std_logic;          -- Active low chip select (sync_n)
        --
        ---- Interface SPI bus to 8-channel PMOD for DC channels 8-15
        --dc1_sclk            => p_dc1_sclk                   , -- out   std_logic;  
        --dc1_mosi            => p_dc1_mosi                   , -- out   std_logic;  
        --dc1_cs_n            => p_dc1_cs_n                   , -- out   std_logic;  
        --
        ---- Interface SPI bus to 8-channel PMOD for DC channels 16-23
        --dc2_sclk            => p_dc2_sclk                   , -- out   std_logic;  
        --dc2_mosi            => p_dc2_mosi                   , -- out   std_logic;  
        --dc2_cs_n            => p_dc2_cs_n                   , -- out   std_logic;  
        --
        ---- Interface SPI bus to 8-channel PMOD for DC channels 24-31
        --dc3_sclk            => p_dc3_sclk                   , -- out   std_logic; 
        --dc3_mosi            => p_dc3_mosi                   , -- out   std_logic;  
        --dc3_cs_n            => p_dc3_cs_n                     -- out   std_logic;  
    );
    
    p_dc0_sclk <= dc0_sclk;
    p_dc0_mosi <= dc0_mosi;
    p_dc0_cs_n <= dc0_cs_n;
    
    p_dc0_sclk_debug <= dc0_sclk;
    p_dc0_mosi_debug <= dc0_mosi;
    p_dc0_cs_n_debug <= dc0_cs_n;
    -----------------------------------------------------------------------------------
    ---- Pulse DAC interface
    ----
    -----------------------------------------------------------------------------------
    --u_dacs_pulse : entity work.qlaser_dacs_pulse
    --port map(
    --    clk                 => clk                              , -- in  std_logic; 
    --    reset               => reset                            , -- in  std_logic;
    --
    --    trigger             => trigger                          , -- in  std_logic;                        -- Trigger (rising edge) to start pulse output
    --    busy                => dacs_pulse_busy                  , -- out std_logic;                        -- Set to '1' while pulse outputs are occurring
    --
    --    -- CPU interface
    --    cpu_addr            => cpu_addr(11 downto 0)            , -- in  std_logic_vector(11 downto 0);    -- Address input
    --    cpu_wdata           => cpu_din                          , -- in  std_logic_vector(31 downto 0);    -- Data input
    --    cpu_wr              => cpu_wr                           , -- in  std_logic;                        -- Write enable 
    --    cpu_sel             => cpu_sels(SEL_DAC_PULSE)          , -- in  std_logic;                        -- Block select
    --    cpu_rdata           => arr_cpu_dout(SEL_DAC_PULSE)      , -- out std_logic_vector(31 downto 0);    -- Data output
    --    cpu_rdata_dv        => arr_cpu_dout_dv(SEL_DAC_PULSE)   , -- out std_logic;                        -- Acknowledge output
    --                   
    --    -- Pulse train outputs
    --    dacs_pulse          => p_dacs_pulse                       -- out std_logic_vector(31 downto 0);    -- Data output
    --);
    --
    ---- Combine p_trigger (from pad) with misc block trigger to create internal trigger
    --trigger     <= p_trigger or misc_trigger;

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
    --pr_leds : process (clk)
    --begin
    --    if rising_edge(clk) then
    --
    --
    --        p_leds0_rgb(C_LED_BLUE)     <= misc_flash;
    --
    --
    --        -- LEDs can be controlled by the CPU or from pulse stretcher.
    --        for N in 1 to 3 loop
    --            if (misc_leds_en(N) = '1') then
    --                p_leds1_rgb(N) <= not(misc_leds(N));
    --            else
    --                p_leds1_rgb(N) <= not(pulse_stretched(N));
    --            end if;
    --        end loop;
    --
    --     end if;
    --end process;
    
    p_leds0_rgb <= led0_reg;
    p_leds1_rgb <= led1_reg;
    
    pr_leds: process(clk, reset)
    begin
        if reset = '1' then
            led0_reg <= "000";
            led1_reg <= "000";
        elsif rising_edge(clk) then
            case cpu_addr is
                when X"0001" =>
                    if cpu_wr = '1' then
                        led0_reg <= cpu_din(2 downto 0);
                    end if;
                    
                when X"0002" =>
                    if cpu_wr = '1' then
                        led1_reg <= cpu_din(2 downto 0);
                    end if;
                when others => 
                    null;
                
            end case;
            
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
    --pr_dbg_mux : process (clk)
    --begin
    --    if rising_edge(clk) then
    --
    --        case to_integer(unsigned(misc_dbg_ctrl)) is
    --
    --            -- "1111" is the default setting for misc_dbg_ctrl
    --            -- Normally selects all zero debug output.
    --            when 15  => -- Default
    --                    p_debug_out    <= (others=>'0');
    --
    --
    --            when 14 => 
    --                    p_debug_out(0)              <= '0';
    --                    p_debug_out(1)              <= '0';
    --                    p_debug_out(2)              <= pll_lock;
    --                    p_debug_out(3)              <= tick_msec;
    --                    p_debug_out(4)              <= tick_sec;
    --                    p_debug_out(7 downto  5)    <= (others=>'0');
    --
    --
    --            when others => 
    --                    p_debug_out                 <= (others=>'0');
    --        end case;
    --    end if;
    --end process;


end rtl;