---------------------------------------------------------------
--  File         : qlaser_top.vhd
--  Description  : Top-level of Qlaser FPGA
----------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.qlaser_pkg.all;
use     work.qlaser_dacs_pulse_channel_pkg.all;

entity qlaser_top is
port (
    p_clk_p                 : in    std_logic;          -- Clock, P
    p_clk_n                 : in    std_logic;          -- Clock, N
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
    
    -- Interface SPI bus to 8-channel PMOD for DC channels 8-15
    p_dc1_sclk              : out   std_logic;  
    p_dc1_mosi              : out   std_logic;  
    p_dc1_cs_n              : out   std_logic;  
    
    -- Interface SPI bus to 8-channel PMOD for DC channels 16-23
    p_dc2_sclk              : out   std_logic;  
    p_dc2_mosi              : out   std_logic;  
    p_dc2_cs_n              : out   std_logic;

    p_trigger               : in    std_logic;
    p_enable_dacs_pulse     : in    std_logic;          -- Set when DAC interface is running
    
    -- Interface SPI bus to 8-channel PMOD for DC channels 24-31
    p_dc3_sclk              : out   std_logic; 
    p_dc3_mosi              : out   std_logic;  
    p_dc3_cs_n              : out   std_logic;  
    
    ---- 32 pulse outputs
    -- p_dacs_pulse            : out   std_logic_vector(31 downto 0);
    --
    ---- User buttons
    -- p_btn0                  : in    std_logic; 
    -- p_btn1                  : in    std_logic;
    -- p_btn_e                 : in    std_logic; 
    -- p_btn_s                 : in    std_logic; 
    -- p_btn_n                 : in    std_logic; 
    -- p_btn_w                 : in    std_logic; 
    -- p_btn_c                 : in    std_logic; 

    -- Indicator LEDs
    p_leds_0             : out   std_logic;      -- 
    p_leds_1             : out   std_logic;      --
    p_leds_2             : out   std_logic;      --
    p_leds_3             : out   std_logic;      --
    p_leds_4             : out   std_logic;      --
    p_leds_5             : out   std_logic;      -- 


    -- -- PS unit ports
    -- DDR_addr                : inout std_logic_vector(14 downto 0);
    -- DDR_ba                  : inout std_logic_vector( 2 downto 0);
    -- DDR_cas_n               : inout std_logic;
    -- DDR_ck_n                : inout std_logic;
    -- DDR_ck_p                : inout std_logic;
    -- DDR_cke                 : inout std_logic;
    -- DDR_cs_n                : inout std_logic;
    -- DDR_dm                  : inout std_logic_vector( 3 downto 0);
    -- DDR_dq                  : inout std_logic_vector(31 downto 0);
    -- DDR_dqs_n               : inout std_logic_vector( 3 downto 0);
    -- DDR_dqs_p               : inout std_logic_vector( 3 downto 0);
    -- DDR_odt                 : inout std_logic;
    -- DDR_ras_n               : inout std_logic;
    -- DDR_reset_n             : inout std_logic;
    -- DDR_we_n                : inout std_logic;
    -- FIXED_IO_ddr_vrn        : inout std_logic;
    -- FIXED_IO_ddr_vrp        : inout std_logic;
    -- FIXED_IO_mio            : inout std_logic_vector( 53 downto 0 );
    -- FIXED_IO_ps_clk         : inout std_logic;
    -- FIXED_IO_ps_porb        : inout std_logic;
    -- FIXED_IO_ps_srstb       : inout std_logic;

    -- Debug port (if present)
    p_debug_out             : out   std_logic_vector( 1 downto 0)       -- 
);
end entity;

---------------------------------------------------------------
-- Top level of FPGA.  Serial interface for register R/W.
-- PS for booting.
---------------------------------------------------------------
architecture rtl_zcu of qlaser_top is

signal clk                  : std_logic;
signal reset                : std_logic;
signal ext_reset_n          : std_logic;

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
constant SEL_SPARE          : integer :=  3;    -- Spare

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

-- -- LED colors
-- constant C_LED_BLUE         : integer := 0;
-- constant C_LED_GREEN        : integer := 1;
-- constant C_LED_RED          : integer := 2;

signal reg_led0             : std_logic_vector(2 downto 0);
signal reg_led1             : std_logic_vector(2 downto 0);

signal dc0_sclk             : std_logic;
signal dc0_mosi             : std_logic;
signal dc0_cs_n             : std_logic;

signal ram0_data            : std_logic_vector(39 downto 0);

-- signal data_to_JESD     : t_arr_data_JESD;
-- for Pmod Pulse testings

signal dacs_pulse_ready         : std_logic;                        -- Status signal indicating all JESD channels are sync'ed.
signal dacs_pulse_error         : std_logic;                        -- Instantanous JESD sync status.
signal dacs_pulse_error_latched : std_logic;                        -- JESD lost sync after ready. Cleared by trigger
                
 -- Array of 32 AXI-Stream buses. Each with 16-bit data. Interface to JESD TX Interfaces
signal dacs_pulse_axis_treadys  : std_logic_vector(31 downto 0);    -- axi_stream ready from downstream modules
signal dacs_pulse_axis_tdatas   : t_arr_slv32x16b;                  -- axi stream output data array
signal dacs_pulse_axis_tvalids  : std_logic_vector(31 downto 0);    -- axi_stream output data valid
signal dacs_pulse_axis_tlasts   : std_logic_vector(31 downto 0);    -- axi_stream output set on last data  

signal jesd_syncs               : std_logic_vector(31 downto 0);    -- Inputs from each JESD TX interface

-- Pulse to PMOD block outputs == PROTO USE ONLY ==
signal p2p_busy                 : std_logic;    -- Set to '1' while SPI interface is busy
signal p2p_spi_sclk             : std_logic;    -- Clock (50 MHz?)
signal p2p_spi_mosi             : std_logic;    -- Master out, Slave in. (Data to DAC)
signal p2p_spi_cs_n             : std_logic;    -- Active low chip select (sync_n)

signal gpio_btns                : std_logic_vector( 4 downto 0); 

begin

    --p_busy  <= dacs_dc_busy(0) or dacs_dc_busy(1) or dacs_dc_busy(2) or dacs_dc_busy(3) or dacs_pulse_busy;

    --------------------------------------------------------------------
    -- Power on reset circuit. Wait until clock is stable before 
    -- releasing reset.
    --------------------------------------------------------------------
    u_clkreset : entity work.clkreset
    port map(
        -- Reset and clock from pads
        p_reset      => p_reset     , -- in  std_logic;
        p_clk_n      => p_clk_n     , -- in  std_logic;
        p_clk_p      => p_clk_p     , -- in  std_logic;

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


    ---------------------------------------------------------------------------------
    -- DC DAC interface
    ---------------------------------------------------------------------------------
    u_dacs_dc : entity work.qlaser_dacs_dc
    port map(
        clk                 => clk                          , -- in  std_logic; 
        reset               => reset                        , -- in  std_logic;
    
        busy                => dacs_dc_busy                 , -- out std_logic_vector( 3 downto 0);    -- Set to '1' while pulse outputs are occurring
    
        -- CPU interface
        cpu_addr            => cpu_addr(5 downto 0)         , -- in  std_logic_vector(5 downto 0);    -- Address input
        cpu_wdata           => cpu_din(11 downto 0)         , -- in  std_logic_vector(31 downto 0);    -- Data input
        cpu_wr              => cpu_wr                       , -- in  std_logic;                        -- Write enable 
        cpu_sel             => cpu_sels(SEL_DAC_DC)         , -- in  std_logic;                        -- Block select
        cpu_rdata           => arr_cpu_dout(SEL_DAC_DC)     , -- out std_logic_vector(31 downto 0);    -- Data output
        cpu_rdata_dv        => arr_cpu_dout_dv(SEL_DAC_DC)  , -- out std_logic;                        -- Acknowledge output
                       
        -- Interface SPI bus to 8-channel PMOD for DC channels 0-7
        dc0_sclk            => p_dc0_sclk                   , -- out   std_logic;          -- Clock (50 MHz?)
        dc0_mosi            => p_dc0_mosi                   , -- out   std_logic;          -- Master out, Slave in. (Data to DAC)
        dc0_cs_n            => p_dc0_cs_n                   , -- out   std_logic;          -- Active low chip select (sync_n)
        --
        -- Interface SPI bus to 8-channel PMOD for DC channels 8-15
        dc1_sclk            => p_dc1_sclk                   , -- out   std_logic;  
        dc1_mosi            => p_dc1_mosi                   , -- out   std_logic;  
        dc1_cs_n            => p_dc1_cs_n                   , -- out   std_logic;  
        
        -- Interface SPI bus to 8-channel PMOD for DC channels 16-23
        dc2_sclk            => p_dc2_sclk                   , -- out   std_logic;  
        dc2_mosi            => p_dc2_mosi                   , -- out   std_logic;  
        dc2_cs_n            => p_dc2_cs_n                   , -- out   std_logic;  
        
        -- Interface SPI bus to 8-channel PMOD for DC channels 24-31
        dc3_sclk            => open                   , -- out   std_logic; 
        dc3_mosi            => open                   , -- out   std_logic;  
        dc3_cs_n            => open                     -- out   std_logic;
        
    );
    
   
    -----------------------------------------------------------------------------------
    ---- Pulse DAC interface
    -----------------------------------------------------------------------------------
    u_dacs_pulse : entity work.qlaser_dacs_pulse
    generic map(
        G_NCHANS            => 1                                  -- integer := 1
    )
    port map(
        clk                 => clk                              , -- in  std_logic; 
        reset               => reset                            , -- in  std_logic;
    
        enable              => p_enable_dacs_pulse              , -- in  std_logic;                        -- Set when DAC interface is running
        trigger             => p_trigger                        , -- in  std_logic;                        -- Set when pulse generation sequence begins (trigger)
        jesd_syncs          => jesd_syncs                       , -- in  std_logic_vector(31 downto 0);    -- Inputs from each JESD TX interface

        -- Status signals
        ready               => dacs_pulse_ready                 , -- out std_logic;                        -- Status signal indicating all JESD channels are sync'ed.
        busy                => dacs_pulse_busy                  , -- out std_logic;                        -- Running a waveform generation sequence.
        error               => dacs_pulse_error                 , -- out std_logic;                        -- Instantanous JESD sync status.
        error_latched       => dacs_pulse_error_latched         , -- out std_logic;                        -- JESD lost sync after ready. Cleared by trigger
    
        -- CPU interface
        cpu_addr            => cpu_addr(12 downto 0)            , -- in  std_logic_vector(12 downto 0);    -- Address input
        cpu_wdata           => cpu_din                          , -- in  std_logic_vector(31 downto 0);    -- Data input
        cpu_wr              => cpu_wr                           , -- in  std_logic;                        -- Write enable 
        cpu_sel             => cpu_sels(SEL_DAC_PULSE)          , -- in  std_logic;                        -- Block select
        cpu_rdata           => arr_cpu_dout(SEL_DAC_PULSE)      , -- out std_logic_vector(31 downto 0);    -- Data output
        cpu_rdata_dv        => arr_cpu_dout_dv(SEL_DAC_PULSE)   , -- out std_logic;                        -- Acknowledge output
                       
        -- Array of 32 AXI-Stream buses. Each with 16-bit data. Interface to JESD TX Interfaces
        axis_treadys        => dacs_pulse_axis_treadys          , -- in  std_logic_vector(31 downto 0);    -- axi_stream ready from downstream modules
        axis_tdatas         => dacs_pulse_axis_tdatas           , -- out t_arr_slv32x16b;   -- axi stream output data array
        axis_tvalids        => dacs_pulse_axis_tvalids          , -- out std_logic_vector(31 downto 0);    -- axi_stream output data valid
        axis_tlasts         => dacs_pulse_axis_tlasts             -- out std_logic_vector(31 downto 0)     -- axi_stream output set on last data  
    );
    
    -- TODO : This will be driven by JESD interface status
    jesd_syncs  <= (others=>'1');
    
    -- Combine p_trigger (from pad) with misc block trigger to create internal trigger
    trigger     <= misc_trigger; -- or with p_trigger when implemented

        -----------------------------------------------------------------------------------
    --      **** FOR PROTOTYPE TESTING ****
    --
    -- Block containing an AXI-Stream FIFO and a stream-to-spi PMOD interface 
    -- Allows pulse data to drive a 'dc' DAC at a low speed.
    -----------------------------------------------------------------------------------
    u_pulse2pmod : entity work.pulse2pmod
    port map(
        clk                 => clk                          ,  -- in  std_logic;
        reset               => reset                        ,  -- in  std_logic;

        busy                => p2p_busy                     ,  -- out std_logic;    -- Set to '1' while SPI interface is busy

        -- CPU interface
        cpu_addr            => cpu_addr( 5 downto 0)        ,  -- in  std_logic_vector( 5 downto 0);
        cpu_wdata           => cpu_din                      ,  -- in  std_logic_vector(31 downto 0);
        cpu_wr              => cpu_wr                       ,  -- in  std_logic;
        cpu_sel             => cpu_sels(SEL_SPARE)          ,  -- in  std_logic;
        cpu_rdata           => arr_cpu_dout(SEL_SPARE)      ,  -- out std_logic_vector(31 downto 0);
        cpu_rdata_dv        => arr_cpu_dout_dv(SEL_SPARE)   ,  -- out std_logic; 

        -- AXI-stream input to FIFO
        s_axis_tready       => dacs_pulse_axis_treadys(0)   ,  -- out std_logic;
        s_axis_tvalid       => dacs_pulse_axis_tvalids(0)   ,  -- in  std_logic;
        s_axis_tdata        => dacs_pulse_axis_tdatas(0)    ,  -- in  std_logic_vector(15 downto 0);
        s_axis_tlast        => dacs_pulse_axis_tlasts(0)    ,  -- in  std_logic;
                                        
        -- Interface SPI bus to 8-channel PMOD for DC channels 0-7
        spi_sclk            => p2p_spi_sclk                 ,  -- out std_logic;
        spi_mosi            => p2p_spi_mosi                 ,  -- out std_logic;
        spi_cs_n            => p2p_spi_cs_n                    -- out std_logic 
    );

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
    --        p_leds0_rgb(C_LED_BLUE)     <= misc_flash;
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
    
    -- Input to pulse stretcher in the misc block which will make signals visible on the LEDs
    pulse(0)    <= tick_sec;
    pulse(1)    <= trigger or dacs_dc_busy(0) or dacs_dc_busy(1) or dacs_dc_busy(2) or dacs_dc_busy(3) or dacs_pulse_busy;
    pulse(2)    <= not(p_serial_rxd);
    pulse(3)    <= not(cpuint_txd);

    p_debug_out(0)              <= cpuint_rxd;
    p_debug_out(1)              <= cpuint_txd;
    
    p_leds_0      <= pulse_stretched(1);  -- trigger, dac busy, etc.
    p_leds_1      <= '0';
    p_leds_2      <= '0';  
    
    p_leds_3      <= pulse_stretched(3);  -- cpuint_txd  
    p_leds_4      <= pulse_stretched(2);  -- p_serial_rxd;
    p_leds_5      <= misc_flash;
    
    

    ---------------------------------------------------------------------------------
    -- UART pins
    ---------------------------------------------------------------------------------
    cpuint_rxd          <= p_serial_rxd;
    p_serial_txd        <= cpuint_txd;

    
    -- ---------------------------------------------------------------------------------
    -- -- Processing system.  No current use. Had to add to use SDK to build boot files
    -- ---------------------------------------------------------------------------------
    -- u_ps1 : entity work.ps1_wrapper
    -- port map(
    --     DDR_addr            => DDR_addr             , -- inout std_logic_vector(14 downto 0);
    --     DDR_ba              => DDR_ba               , -- inout std_logic_vector( 2 downto 0);
    --     DDR_cas_n           => DDR_cas_n            , -- inout std_logic;
    --     DDR_ck_n            => DDR_ck_n             , -- inout std_logic;
    --     DDR_ck_p            => DDR_ck_p             , -- inout std_logic;
    --     DDR_cke             => DDR_cke              , -- inout std_logic;
    --     DDR_cs_n            => DDR_cs_n             , -- inout std_logic;
    --     DDR_dm              => DDR_dm               , -- inout std_logic_vector( 3 downto 0);
    --     DDR_dq              => DDR_dq               , -- inout std_logic_vector(31 downto 0);
    --     DDR_dqs_n           => DDR_dqs_n            , -- inout std_logic_vector( 3 downto 0);
    --     DDR_dqs_p           => DDR_dqs_p            , -- inout std_logic_vector( 3 downto 0);
    --     DDR_odt             => DDR_odt              , -- inout std_logic;
    --     DDR_ras_n           => DDR_ras_n            , -- inout std_logic;
    --     DDR_reset_n         => DDR_reset_n          , -- inout std_logic;
    --     DDR_we_n            => DDR_we_n             , -- inout std_logic;
    --     FIXED_IO_ddr_vrn    => FIXED_IO_ddr_vrn     , -- inout std_logic;
    --     FIXED_IO_ddr_vrp    => FIXED_IO_ddr_vrp     , -- inout std_logic;
    --     FIXED_IO_mio        => FIXED_IO_mio         , -- inout std_logic_vector ( 53 downto 0 );
    --     FIXED_IO_ps_clk     => FIXED_IO_ps_clk      , -- inout std_logic;
    --     FIXED_IO_ps_porb    => FIXED_IO_ps_porb     , -- inout std_logic;
    --     FIXED_IO_ps_srstb   => FIXED_IO_ps_srstb    , -- inout std_logic;
    --     ext_reset_n         => ext_reset_n            -- in    std_logic
    -- );

    -- Invert external reset to use in PS
    ext_reset_n   <= not(p_reset);

end rtl_zcu;
