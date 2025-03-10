---------------------------------------------------------------
--  File         : qlaser_top_zcu102.vhd
--  Description  : Top-level of Qlaser FPGA with CPU interface 
--                 PL clock and reset come from PS.
--                 Contains 4 PL blocks with a CPU bus driven from PS
--                 qlaser_dacs_dc       :
--                 qlaser_dacs_pulse    :
--                 qlaser_misc          : 
--                 PS (ps1)             : CPU with GPIO and CPUbus interfaces
----------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     ieee.std_logic_misc.all;

use     work.qlaser_pkg.all;

entity qlaser_top is
port (
    p_reset                 : in    std_logic;          -- Reset. Check polarity is correct 

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

    -- 32 pulse outputs (JESD differential signals)
  --p_dacs_pulse            : out   std_logic_vector(31 downto 0);

    -- User buttons
    p_btn_e                 : in    std_logic; 
    p_btn_s                 : in    std_logic; 
    p_btn_n                 : in    std_logic; 
    p_btn_w                 : in    std_logic; 
    p_btn_c                 : in    std_logic; 

    -- Indicator LEDs
    p_leds                  : out   std_logic_vector( 7 downto 0);      -- 

    -- Interface to DAC board through FMC_0 (HPC)
--    p_tx0_sync              : in   std_logic;
--    p_tx0_sysref            : in   std_logic
--    p_tx0n_out              : out  std_logic_vector( 1 downto 0);            -- Differential JESD outputs
--    p_tx0p_out              : out  std_logic_vector( 1 downto 0)  

    -- Debug port (if present)
    p_debug_out             : inout   std_logic_vector( 9 downto 0)   
    
--    dip_switches_8bits_tri_i : in std_logic_vector( 7 downto 0) 
);
end entity;

---------------------------------------------------------------
--
---------------------------------------------------------------
architecture zc102 of qlaser_top is

signal clk                  : std_logic;
signal reset                : std_logic;
signal resetn               : std_logic;
signal cif_reset            : std_logic;

-- CPU interface
signal cpu_sels             : std_logic_vector(C_NUM_BLOCKS-1 downto 0);    -- CPU block selects 
signal cpu_wr               : std_logic;
signal cpu_addr             : std_logic_vector(17 downto 0);
signal cpu_din              : std_logic_vector(31 downto 0);
signal cpu_debug            : std_logic_vector( 3 downto 0);

signal arr_cpu_dout         : t_arr_cpu_dout;
signal arr_cpu_dout_dv      : std_logic_vector(C_NUM_BLOCKS-1 downto 0);

constant SEL_DAC_DC         : integer :=  0;    -- For DC DACs
constant SEL_DAC_PULSE      : integer :=  1;    -- For Pulse DACs
constant SEL_MISC           : integer :=  2;    -- Misc, LEDs, switches, version number etc.
constant SEL_SPARE          : integer :=  3;    -- Spare

signal misc_leds            : std_logic_vector( 3 downto 0);
signal misc_leds_en         : std_logic_vector( 3 downto 0);
signal misc_flash           : std_logic;
signal tick_usec            : std_logic;                        --  Timing intervals
signal tick_msec            : std_logic;                        --  Timing intervals
signal tick_sec             : std_logic;            
signal misc_dbg_ctrl        : std_logic_vector( 3 downto 0);
signal misc_trigger         : std_logic;
signal misc_enable          : std_logic;

-- PS (Processor) outputs to PL
signal ps_clk0                  : std_logic;
signal ps_resetn0               : std_logic;
signal ps_leds                  : std_logic_vector( 7 downto 0);
signal ps_gpin                  : std_logic_vector(31 downto 0);
signal ps_gpout                 : std_logic_vector(31 downto 0);
-- Connections to PS axi_cpuint IP block
signal ps_clk_cpu               : std_logic;
signal ps_cpu_addr              : std_logic_vector(17 downto 0);
signal ps_cpu_wdata             : std_logic_vector(31 downto 0);
signal ps_cpu_wr                : std_logic;
signal ps_cpu_rd                : std_logic;
signal cif_cpu_rdata            : std_logic_vector( 31 downto 0);
signal cif_cpu_rdata_dv         : std_logic;

signal pulse                    : std_logic_vector( 3 downto 0);
signal pulse_stretched          : std_logic_vector( 3 downto 0);

signal trigger_dacs_pulse       : std_logic;
signal ps_enable_dacs_pulse     : std_logic;

signal any_dacs_busy            : std_logic;
signal dacs_dc_busy             : std_logic_vector( 3 downto 0);    -- Set to '1' while SPI bus is busy
signal dacs_pulse_ready         : std_logic;                        -- Status signal indicating all JESD channels are sync'ed.
signal dacs_pulse_busy          : std_logic;                        -- Running a waveform generation sequence.
signal dacs_pulse_error         : std_logic;                        -- Instantanous JESD sync status.
signal dacs_pulse_error_latched : std_logic;                        -- JESD lost sync after ready. Cleared by trigger

-- Array of pulse errors
signal pulse_errors             : t_arr_ac_errors;
signal clr_errors               : std_logic_vector(31 downto 0);
                
 -- Array of 32 AXI-Stream buses. Each with 16-bit data. Interface to JESD TX Interfaces
signal dacs_pulse_axis_treadys  : std_logic_vector(31 downto 0);    -- axi_stream ready from downstream modules
signal dacs_pulse_axis_tdatas   : t_arr_slv32x16b;                  -- axi stream output data array
signal dacs_pulse_axis_tvalids  : std_logic_vector(31 downto 0);    -- axi_stream output data valid
signal dacs_pulse_axis_tlasts   : std_logic_vector(31 downto 0);    -- axi_stream output set on last data  

signal jesd_syncs               : std_logic_vector(31 downto 0);    -- Inputs from each JESD TX interface

-- Pulse to PMOD block outputs == PROTO USE ONLY ==
signal p2p0_busy                 : std_logic;    -- Set to '1' while SPI interface is busy
signal p2p_spi0_sclk             : std_logic;    -- Clock (50 MHz?)
signal p2p_spi0_mosi             : std_logic;    -- Master out, Slave in. (Data to DAC)
signal p2p_spi0_cs_n             : std_logic;    -- Active low chip select (sync_n)

signal p2p1_busy                 : std_logic;    -- Set to '1' while SPI interface is busy
signal p2p_spi1_sclk             : std_logic;    -- Clock (50 MHz?)
signal p2p_spi1_mosi             : std_logic;    -- Master out, Slave in. (Data to DAC)
signal p2p_spi1_cs_n             : std_logic;    -- Active low chip select (sync_n)

-- New block selects
signal cpu_sel_p2p0         : std_logic; 
signal cpu_sel_p2p1         : std_logic; 

-- New readout signals
signal p2p0_cpu_rdata       : std_logic_vector(31 downto 0);
signal p2p0_cpu_rdata_dv    : std_logic; 
signal p2p1_cpu_rdata       : std_logic_vector(31 downto 0);
signal p2p1_cpu_rdata_dv    : std_logic; 

signal p2pmodBusy0D1: std_logic;
signal p2pmodBusy0D2: std_logic;
signal p2pmodBusy0D3: std_logic;
signal p2pmodBusy0D4: std_logic;

signal p2pmodBusy1D1: std_logic;
signal p2pmodBusy1D2: std_logic;
signal p2pmodBusy1D3: std_logic;
signal p2pmodBusy1D4: std_logic;

signal  p2p0_active  : STD_LOGIC;
signal  p2p1_active  : STD_LOGIC;

signal gpio_btns                : std_logic_vector( 4 downto 0); 

-- JESD interface for FMC_0 connections to PS block
signal s_axis_tx_fmc0_tdata     : std_logic_vector(63 downto 0);  -- in 
signal s_axis_tx_fmc0_tready    : std_logic;                      -- out
signal tx0_aresetn              : std_logic;                      -- out
signal tx0_core_reset           : std_logic;                      -- in 
signal tx0_reset_done           : std_logic;                      -- out
signal tx0_sof                  : std_logic_vector( 3 downto 0);  -- out    Start of Frame
signal tx0_somf                 : std_logic_vector( 3 downto 0);  -- out    Start of Multi-Frame
signal tx0_sync                 : std_logic;                      -- in     sync from DAC board
signal tx0_sysref               : std_logic;                      -- in     clock from DAC board connector
signal ps_jesd_tx0outclk        : std_logic;
signal ps_jesd_tx0n_out         : std_logic_vector( 1 downto 0);
signal ps_jesd_tx0p_out         : std_logic_vector( 1 downto 0);

-- AXI_stream output from FIFO to PMOD
signal fifo_axis0_tvalid             : std_logic;
signal fifo_axis0_tready             : std_logic;
signal fifo_axis0_tdata              : std_logic_vector(15 downto 0);
signal fifo_axis0_tlast              : std_logic;

signal fifo_almost_full0             : std_logic;
signal fifo_almost_empty0            : std_logic;

-- second one
signal fifo_axis1_tvalid             : std_logic;
signal fifo_axis1_tready             : std_logic;
signal fifo_axis1_tdata              : std_logic_vector(15 downto 0);
signal fifo_axis1_tlast              : std_logic;

signal fifo_almost_full1             : std_logic;
signal fifo_almost_empty1            : std_logic;


signal pulse2pmod0_busy              : std_logic;
signal pulse2pmod1_busy              : std_logic;


begin

    clk     <= ps_clk0;
    reset   <= p_reset or not(ps_resetn0) or ps_gpout(31);  -- added to allow reset from PS. TODO: temporary solution using MSB of gpout. need to figure out use of reset from PS
    resetn  <= not(reset);
    cif_reset <= not(ps_resetn0);

    -- Combine p_btn trigger (from pad) with misc block trigger and ps_gpout(0) to create internal trigger
    trigger_dacs_pulse      <= (p_btn_c or misc_trigger or ps_gpout(C_GPIO_PS_TRIG) or p_debug_out(0)) and not(p2p0_active) and not(p2p1_active) and not(dacs_pulse_busy);  -- ensure ALL resources are available 
    ps_enable_dacs_pulse    <= ps_gpout(C_GPIO_PS_EN) or misc_enable;
    any_dacs_busy           <= dacs_dc_busy(0) or dacs_dc_busy(1) or dacs_dc_busy(2) or dacs_dc_busy(3) or dacs_pulse_busy;

    -- Split 'SEL_SPARE' block select into two
    cpu_sel_p2p0 <= cpu_sels(SEL_SPARE) and not cpu_addr(15); 
    cpu_sel_p2p1 <= cpu_sels(SEL_SPARE) and     cpu_addr(15); 

    -- clear pulse errors
    -- TODO: Should we have it sync'd across all 32 channels should we control one by one?
    g_clr: for I in 0 to 31 generate
        clr_errors(I) <= ps_gpout(C_GPIO_PS_ERR_CLR);
    end generate g_clr;

    -- JESD outputs
--    p_tx0n_out              <= ps_jesd_tx0n_out;
--    p_tx0p_out              <= ps_jesd_tx0p_out;
--    tx0_sync                <= p_tx0_sync; 
--    tx0_sysref              <= p_tx0_sysref;
    
    gpio_btns(0)            <= p_btn_e;
    gpio_btns(1)            <= p_btn_s;
    gpio_btns(2)            <= p_btn_n;
    gpio_btns(3)            <= p_btn_w;
    gpio_btns(4)            <= p_btn_c;


    -- Pulse 2 PMOD SPI interface
    p_dc2_sclk      <= p2p_spi0_sclk; 
    p_dc2_mosi      <= p2p_spi0_mosi; 
    p_dc2_cs_n      <= p2p_spi0_cs_n; 

    p_dc3_sclk      <= p2p_spi1_sclk;
    p_dc3_mosi      <= p2p_spi1_mosi;
    p_dc3_cs_n      <= p2p_spi1_cs_n;


    ---------------------------------------------------------------------------------
    -- Processing system.  CPU, JESD interfaces, Console UART etc
    ---------------------------------------------------------------------------------
    u_ps2 : entity work.ps1_wrapper
    port map(
        reset                   => p_reset              , -- in  std_logic
        -- Signals to/from axi_cpuint peripheral
        clk_cpu                 => ps_clk_cpu           , -- out std_logic;
        cpu_addr                => ps_cpu_addr          , -- out std_logic_vector(17 downto 0);
        cpu_wdata               => ps_cpu_wdata         , -- out std_logic_vector(31 downto 0);
        cpu_wr                  => ps_cpu_wr            , -- out std_logic;
        cpu_rd                  => ps_cpu_rd            , -- out std_logic;
        cpu_rdata               => cif_cpu_rdata        , -- in  std_logic_vector( 31 downto 0);
        cpu_rdata_dv            => cif_cpu_rdata_dv     , -- in  std_logic;
        
        
        pl_clk0                 => ps_clk0              , -- out std_logic;
        pl_resetn0              => ps_resetn0           , -- out std_logic;
        
        
        gpio_leds_tri_o         => ps_leds              , -- out std_logic_vector( 7 downto 0);
        gpio_pbtns_tri_i        => gpio_btns            ,-- in  std_logic_vector( 4 downto 0);

     -- another gpio block to this interface so we can use it to write some test fw to debug the pulse channel
        gpio_int_in_tri_i       => ps_gpin              , -- in  std_logic_vector( 31 downto 0);
        gpio_int_out_tri_o      => ps_gpout               -- out std_logic_vector( 31 downto 0);
    );
    -- Instantiate Differential pads

    ---------------------------------------------------------------------------------
    -- Adapter from PS CPU interface and PL CPU bus. 
    -- Generates block selects and merges rdata readback.
    ---------------------------------------------------------------------------------
    u_cif : entity work.qlaser_cif      -- Cpu InterFace
    port map(
        clk                 => clk                 , -- in  std_logic;
        reset               => cif_reset           , -- in  std_logic;
        -- From PS
        ps_clk_cpu          => ps_clk_cpu           , -- in  std_logic;
        ps_cpu_addr         => ps_cpu_addr          , -- in  std_logic_vector(17 downto 0);
        ps_cpu_wdata        => ps_cpu_wdata         , -- in  std_logic_vector(31 downto 0);
        ps_cpu_wr           => ps_cpu_wr            , -- in  std_logic;
        ps_cpu_rd           => ps_cpu_rd            , -- in  std_logic;
        -- to PS
        ps_cpu_rdata        => cif_cpu_rdata        , -- out std_logic_vector( 31 downto 0);
        ps_cpu_rdata_dv     => cif_cpu_rdata_dv     , -- out std_logic;

        -- to CPU peripherals
        cpu_addr            => cpu_addr(13 downto 0), -- out std_logic_vector(15 downto 2);             -- Address input to core blocks (13:0)
        cpu_wdata           => cpu_din              , -- out std_logic_vector(31 downto 0);             -- Data input
        cpu_wr              => cpu_wr               , -- out std_logic;                                 -- Write enable 
        cpu_sels            => cpu_sels             , -- out std_logic_vector(C_NUM_BLOCKS-1 downto 0); -- Block select
        -- from CPU peripherals
        arr_cpu_rdata       => arr_cpu_dout         , -- in  t_arr_cpu_dout                             -- Data output
        arr_cpu_rdata_dv    => arr_cpu_dout_dv        -- in  std_logic_vector(C_NUM_BLOCKS-1 downto 0); -- Acknowledge output
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
        dc0_sclk            => p_dc0_sclk             , -- out   std_logic;          -- Clock (50 MHz?)
        dc0_mosi            => p_dc0_mosi             , -- out   std_logic;          -- Master out, Slave in. (Data to DAC)
        dc0_cs_n            => p_dc0_cs_n             , -- out   std_logic;          -- Active low chip select (sync_n)
        --
        -- Interface SPI bus to 8-channel PMOD for DC channels 8-15
        dc1_sclk            => p_dc1_sclk             , -- out   std_logic;  
        dc1_mosi            => p_dc1_mosi             , -- out   std_logic;  
        dc1_cs_n            => p_dc1_cs_n             , -- out   std_logic;  
        
        -- Interface SPI bus to 8-channel PMOD for DC channels 16-23
        dc2_sclk            => open                   , -- out   std_logic;  
        dc2_mosi            => open                   , -- out   std_logic;  
        dc2_cs_n            => open                   , -- out   std_logic;  
        
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
        G_NCHANS            => 2                                  -- integer := 1
    )
    port map(
        clk                 => clk                              , -- in  std_logic; 
        reset               => reset                            , -- in  std_logic;
    
        enable              => ps_enable_dacs_pulse             , -- in  std_logic;                        -- Set when DAC interface is running
        trigger             => trigger_dacs_pulse               , -- in  std_logic;                        -- Set when pulse generation sequence begins (trigger)
        jesd_syncs          => jesd_syncs                       , -- in  std_logic_vector(31 downto 0);    -- Inputs from each JESD TX interface

        -- Status signals
        ready               => dacs_pulse_ready                 , -- out std_logic;                        -- Status signal indicating all JESD channels are sync'ed.
        busy                => dacs_pulse_busy                  , -- out std_logic;                        -- Running a waveform generation sequence.
        error               => dacs_pulse_error                 , -- out std_logic;                        -- Instantanous JESD sync status.
        error_latched       => dacs_pulse_error_latched         , -- out std_logic;                        -- JESD lost sync after ready. Cleared by trigger
    
        -- CPU interface
        cpu_addr            => cpu_addr(12 downto 0)            , -- in  std_logic_vector(11 downto 0);    -- Address input
        cpu_wdata           => cpu_din                          , -- in  std_logic_vector(31 downto 0);    -- Data input
        cpu_wr              => cpu_wr                           , -- in  std_logic;                        -- Write enable 
        cpu_sel             => cpu_sels(SEL_DAC_PULSE)          , -- in  std_logic;                        -- Block select
        cpu_rdata           => arr_cpu_dout(SEL_DAC_PULSE)      , -- out std_logic_vector(31 downto 0);    -- Data output
        cpu_rdata_dv        => arr_cpu_dout_dv(SEL_DAC_PULSE)   , -- out std_logic;                        -- Acknowledge output
                       
        -- Array of 32 AXI-Stream buses. Each with 16-bit data. Interface to JESD TX Interfaces
        axis_treadys        => dacs_pulse_axis_treadys          , -- in  std_logic_vector(31 downto 0);    -- axi_stream ready from downstream modules
        axis_tdatas         => dacs_pulse_axis_tdatas           , -- out t_arr_slv32x16b;   -- axi stream output data array
        axis_tvalids        => dacs_pulse_axis_tvalids          , -- out std_logic_vector(31 downto 0);    -- axi_stream output data valid
        axis_tlasts         => dacs_pulse_axis_tlasts           , -- out std_logic_vector(31 downto 0)     -- axi_stream output set on last data  

        -- pulse errors
        wave_errors        => pulse_errors                      , -- out t_arr_ac_errors
        clr_errors         => clr_errors                          -- in  std_logic_vector(31 downto 0)
    );
    
    -- TODO : This will be driven by JESD interface status
    jesd_syncs  <= (others=>'1');
    

    -----------------------------------------------------------------------------------
    --      **** FOR PROTOTYPE TESTING ****
    --
    -- Block containing an AXI-Stream FIFO and a stream-to-spi PMOD interface 
    -- Allows pulse data to drive a 'dc' DAC at a low speed.
    -------------------------------------------------------------
    -- AXI_Stream FIFO buffer between pulse generator and SPI interface
    -------------------------------------------------------------
    u_axi0_fifo : entity work.axis_data_fifo_32Kx16b
    port map(
        s_axis_aresetn  => resetn       , -- in  std_logic;
        s_axis_aclk     => clk              , -- in  std_logic;

        s_axis_tvalid   => dacs_pulse_axis_tvalids(0), -- in  std_logic;
        s_axis_tready   => dacs_pulse_axis_treadys(0), -- out std_logic;
        s_axis_tdata    => dacs_pulse_axis_tdatas(0), -- in  std_logic_vector(15 downto 0);
        s_axis_tlast    => dacs_pulse_axis_tlasts(0), -- in  std_logic;

        m_axis_tvalid   => fifo_axis0_tvalid , -- out std_logic;
        m_axis_tready   => fifo_axis0_tready , -- in  std_logic;
        m_axis_tdata    => fifo_axis0_tdata  , -- out std_logic_vector(15 downto 0);
        m_axis_tlast    => fifo_axis0_tlast  , -- out std_logic;

        almost_full     => fifo_almost_full0 , -- out std_logic 
        almost_empty    => fifo_almost_empty0  -- out std_logic 
    );

    u_axi0_fif1 : entity work.axis_data_fifo_32Kx16b
    port map(
        s_axis_aresetn  => resetn       , -- in  std_logic;
        s_axis_aclk     => clk              , -- in  std_logic;

        s_axis_tvalid   => dacs_pulse_axis_tvalids(1), -- in  std_logic;
        s_axis_tready   => dacs_pulse_axis_treadys(1), -- out std_logic;
        s_axis_tdata    => dacs_pulse_axis_tdatas(1), -- in  std_logic_vector(15 downto 0);
        s_axis_tlast    => dacs_pulse_axis_tlasts(1), -- in  std_logic;

        m_axis_tvalid   => fifo_axis1_tvalid , -- out std_logic;
        m_axis_tready   => fifo_axis1_tready , -- in  std_logic;
        m_axis_tdata    => fifo_axis1_tdata  , -- out std_logic_vector(15 downto 0);
        m_axis_tlast    => fifo_axis1_tlast  , -- out std_logic;

        almost_full     => fifo_almost_full1 , -- out std_logic 
        almost_empty    => fifo_almost_empty1  -- out std_logic 
    );


    -------------------------------------------------------------
	-- PMOD interface
    --  Block drives a SPI-bus interface to 8 channel DAC boards.
    --  Intended for testing AC pulse generation.
    --  SPI bus can be written by CPU or by AXI-Stream input.
    --  A control register selects the data source
    -------------------------------------------------------------
	u_dac_pulse : entity work.qlaser_2pmods_pulse
	port map (
        clk             => clk                        , -- in  std_logic;
        reset           => reset                      , -- in  std_logic;

        busy0            => pulse2pmod0_busy          , -- out std_logic;    -- Set to '1' while SPI interface is busy
        busy1            => pulse2pmod1_busy          , -- out std std_logic;    -- Set to '1' while SPI interface is busy

        -- CPU interface
        cpu_addr        => cpu_addr( 5 downto 0)      , -- in  std_logic_vector( 5 downto 0);
        cpu_wdata       => cpu_din(11 downto 0)       , -- in  std_logic_vector(11 downto 0);
        cpu_wr          => cpu_wr                     , -- in  std_logic;
        cpu_sel         => cpu_sels(SEL_SPARE)        , -- in  std_logic;

        cpu_rdata       => arr_cpu_dout(SEL_SPARE)    , -- out std_logic_vector(31 downto 0);
        cpu_rdata_dv    => arr_cpu_dout_dv(SEL_SPARE) , -- out std_logic; 

        -- AXI-Stream bus.  16-bit data.
        axis0_tready     => fifo_axis0_tready         , -- out std_logic;    -- axi_stream ready from downstream modules
        axis0_tdata      => fifo_axis0_tdata          , -- in  std_logic_vector(15 downto 0);   -- axi stream output data array
        axis0_tvalid     => fifo_axis0_tvalid         , -- in  std_logic;    -- axi_stream output data valid
        axis0_tlast      => fifo_axis0_tlast          , -- in  std_logic     -- axi_stream output set on last data  

        -- Second AXI-Stream bus.  16-bit data.
        axis1_tready     => fifo_axis1_tready         , -- out std_logic;    -- axi_stream ready from downstream modules
        axis1_tdata      => fifo_axis1_tdata          , -- in  std_logic_vector(15 downto 0);   -- axi stream output data array
        axis1_tvalid     => fifo_axis1_tvalid         , -- in  std_logic;    -- axi_stream output data valid
        axis1_tlast      => fifo_axis1_tlast          , -- in  std_logic     -- axi_stream output set on last data  

        -- Interface SPI bus to 8-channel PMOD for DC channels 0-7
        spi0_sclk        => p2p_spi0_sclk            , --  out std_logic;          -- Clock (50 MHz?)
        spi0_mosi        => p2p_spi0_mosi            , --  out std_logic;          -- Master out, Slave in. (Data to DAC)
        spi0_cs_n        => p2p_spi0_cs_n            , --  out std_logic           -- Active low chip select (sync_n)

        -- Interface SPI bus to 8-channel PMOD for DC channels 8-15
        spi1_sclk        => p2p_spi1_sclk            , --  out std_logic;
        spi1_mosi        => p2p_spi1_mosi            , --  out std_logic;
        spi1_cs_n        => p2p_spi1_cs_n              --  out std_logic;
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
        tick_usec           => tick_usec                , -- out std_logic;                        -- Single cycle high every 1 usec. Used by SD interface debug registers
        tick_msec           => tick_msec                , -- out std_logic;                        -- Single cycle high every 1 msec. Used by SD interface debug registers
        tick_sec            => tick_sec                 , -- out std_logic;                        -- Single cycle high every N msec. 

        dbg_ctrl            => misc_dbg_ctrl            , -- out std_logic_vector( 3 downto 0);
        trigger             => misc_trigger             , -- out std_logic
        enable              => misc_enable                -- out std_logic
    );

 
    -- Input to pulse stretcher in the misc block which can be used to make signals visible on the LEDs
    pulse(0)              <= trigger_dacs_pulse or dacs_dc_busy(0) or dacs_dc_busy(1) or dacs_dc_busy(2) or dacs_dc_busy(3) or dacs_pulse_busy;
    pulse(1)              <= p2p0_busy;
    pulse(2)              <= tick_sec;
    pulse(3)              <= trigger_dacs_pulse;

    p_leds(0)             <= misc_flash or gpio_btns(0);
    -- Geoff drops lower two bits of cpu_addr, so we connect those two to LED so we know if we have wrong address
    p_leds(1)             <= ps_cpu_addr(0) or ps_cpu_addr(1);
    p_leds(2)             <= cpu_sels(SEL_DAC_DC);
    p_leds(3)             <= p2p0_active;
    p_leds(4)             <= p2p1_active;
    p_leds(5)             <= (not ps_resetn0) or ps_leds(0) or dacs_pulse_busy;  
    p_leds(6)             <= reset or ps_leds(1) or trigger_dacs_pulse;  
    p_leds(7)             <= ps_leds(2) or ps_enable_dacs_pulse;
    

    ---------------------------------------------------------------------------------
    -- Signals for PS GPIO block
    ---------------------------------------------------------------------------------
    -- Pulse 0 errors
    ps_gpin( 7 downto 0)  <= pulse_errors(0);
    -- Pulse 2 errors
    ps_gpin(15 downto 8)  <= pulse_errors(1);
    
    -- Debug signals
    ps_gpin(16)           <= trigger_dacs_pulse;
    ps_gpin(17)           <= tick_usec;

    -- FIFO-PMOD interface, use ps gpio pin ps_gpout(3) to select which pmod data to get
    ps_gpin(18)           <= fifo_axis0_tready when ps_gpout(C_GPIO_PS_DEBUG_SEL) = '1' else fifo_axis0_tready;
    ps_gpin(19)           <= fifo_axis1_tvalid when ps_gpout(C_GPIO_PS_DEBUG_SEL) = '1' else fifo_axis0_tvalid;
    ps_gpin(31 downto 20) <= fifo_axis1_tdata(11 downto 0) when ps_gpout(C_GPIO_PS_DEBUG_SEL) = '1' else fifo_axis0_tdata(11 downto 0);

    ---------------------------------------------------------------------------------
    -- Debug output mux.
    ---------------------------------------------------------------------------------
    p2p0_busy <= pulse2pmod0_busy and not(fifo_almost_empty0);  -- Set to '1' while SPI interface is busy and FIFO is not empty (just in case...)
    p2p1_busy <= pulse2pmod1_busy and not(fifo_almost_empty1);  -- Set to '1' while SPI interface is busy and FIFO is not empty (just in case...)
    pr_dbg_mux : process (clk)
    begin
        if reset = '1' then
            p2pmodBusy0D1 <= '0';
            p2pmodBusy0D2 <= '0';
            p2pmodBusy0D3 <= '0';
            p2pmodBusy0D4 <= '0';

            p2pmodBusy1D1 <= '0';
            p2pmodBusy1D2 <= '0';
            p2pmodBusy1D3 <= '0';
            p2pmodBusy1D4 <= '0';
        elsif rising_edge(clk) then
            -- First delay stage
            p2pmodBusy0D1 <= p2p0_busy;
            -- Second delay stage
            p2pmodBusy0D2 <= p2pmodBusy0D1;
            -- Third delay stage
            p2pmodBusy0D3 <= p2pmodBusy0D2;
            -- Fourth delay stage
            p2pmodBusy0D4 <= p2pmodBusy0D3;

            -- First delay stage
            p2pmodBusy1D1 <= p2p1_busy;
            -- Second delay stage
            p2pmodBusy1D2 <= p2pmodBusy1D1;
            -- Third delay stage
            p2pmodBusy1D3 <= p2pmodBusy1D2;
            -- Fourth delay stage
            p2pmodBusy1D4 <= p2pmodBusy1D3;
        end if;
        
         p2p0_active <= p2p0_busy or p2pmodBusy0D4;
         p2p1_active <= p2p1_busy or p2pmodBusy1D4;

        if rising_edge(clk) then

            -- p_debug_out(0)              <= p2p_spi0_sclk;
            -- p_debug_out(1)              <= p2p_spi0_mosi;
            -- p_debug_out(2)              <= p2p_spi0_cs_n;
            -- p_debug_out(3)              <= p2p_spi1_sclk;
            -- p_debug_out(4)              <= p2p_spi1_mosi;
            -- p_debug_out(5)              <= p2p_spi1_cs_n;
            -- p_debug_out(6)              <= fifo_axis0_tvalid;
            -- p_debug_out(7)              <= fifo_axis1_tvalid;
            p_debug_out(8)              <= tick_msec;
            p_debug_out(9)              <= trigger_dacs_pulse;
        end if;
    end process;

end zc102;