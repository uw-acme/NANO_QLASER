---------------------------------------------------------------
--  File         : qlaser_top_zcu102_fmc0_clkdebug.vhdl
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

library UNISIM;
use     UNISIM.vcomponents.all;

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

    -- User buttons
    p_btn_e                 : in    std_logic; 
    p_btn_s                 : in    std_logic; 
    p_btn_n                 : in    std_logic; 
    p_btn_w                 : in    std_logic; 
    p_btn_c                 : in    std_logic; 

    -- Indicator LEDs
    p_leds                  : out   std_logic_vector( 7 downto 0);      -- 

    -- Interface to DAC board through FMC0 (HPC)
    p_fmc0_tx_sync_p        : in    std_logic_vector( 3 downto 0);  -- LVS sync for each link
    p_fmc0_tx_sync_n        : in    std_logic_vector( 3 downto 0);
    p_fmc0_tx_sysref_p      : in    std_logic;
    p_fmc0_tx_sysref_n      : in    std_logic;
    p_fmc0_tx_refclk_p      : in    std_logic;
    p_fmc0_tx_refclk_n      : in    std_logic;

    -- Differential JESD outputs for FMC0. 8 lanes in 4 links
    p_fmc0_txp_out          : out   std_logic_vector( 7 downto 0);  
    p_fmc0_txn_out          : out   std_logic_vector( 7 downto 0);

    -- Interface to DAC board through FMC1 (HPC)
    p_fmc1_tx_sync_p        : in    std_logic_vector( 3 downto 0);  -- LVS sync for each link
    p_fmc1_tx_sync_n        : in    std_logic_vector( 3 downto 0);
    p_fmc1_tx_sysref_p      : in    std_logic;
    p_fmc1_tx_sysref_n      : in    std_logic;
    p_fmc1_tx_refclk_p      : in    std_logic;
    p_fmc1_tx_refclk_n      : in    std_logic;

    -- Differential JESD outputs for FMC0. 8 lanes in 4 links
    p_fmc1_txp_out          : out   std_logic_vector( 7 downto 0);  
    p_fmc1_txn_out          : out   std_logic_vector( 7 downto 0);

    -- Debug port (if present)
    p_debug_out             : out   std_logic_vector( 9 downto 0)       -- 
);
end entity;

---------------------------------------------------------------------------
-- Version of the ZCU102 using only FMC0 with two JESD IP blocks (links)
-- with 2 lanes per link.
-- A full FMC216 connection has 4 links, one to each DAC.
---------------------------------------------------------------------------
architecture zc102_fmc0_clkdebug of qlaser_top is

signal clk                      : std_logic;
signal reset                    : std_logic;

-- CPU interface
signal cpu_sels                 : std_logic_vector(C_NUM_BLOCKS-1 downto 0);    -- CPU block selects 
signal cpu_wr                   : std_logic;
signal cpu_addr                 : std_logic_vector(13 downto 0);
signal cpu_din                  : std_logic_vector(31 downto 0);
signal cpu_debug                : std_logic_vector( 3 downto 0);

signal arr_cpu_dout             : t_arr_cpu_dout;
signal arr_cpu_dout_dv          : std_logic_vector(C_NUM_BLOCKS-1 downto 0);

constant SEL_DAC_DC             : integer :=  0;    -- For DC DACs
constant SEL_DAC_PULSE          : integer :=  1;    -- For Pulse DACs
constant SEL_MISC               : integer :=  2;    -- Misc, LEDs, switches, version number etc.
constant SEL_SWITCH             : integer :=  3;    -- JESD bus data switch

signal misc_leds                : std_logic_vector( 3 downto 0);
signal misc_leds_en             : std_logic_vector( 3 downto 0);
signal misc_flash               : std_logic;
signal tick_msec                : std_logic;                        --  Timing intervals
signal tick_sec                 : std_logic;            
signal misc_dbg_ctrl            : std_logic_vector( 3 downto 0);
signal misc_trigger             : std_logic;

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
                
 -- Array of 32 AXI-Stream buses. Each with 16-bit data. Interface to JESD TX Interfaces
signal dacs_pulse_axis_treadys  : std_logic_vector(31 downto 0);    -- axi_stream ready from downstream modules
signal dacs_pulse_axis_tdatas   : t_arr_slv32x16b;                  -- axi stream output data array
signal dacs_pulse_axis_tvalids  : std_logic_vector(31 downto 0);    -- axi_stream output data valid
signal dacs_pulse_axis_tlasts   : std_logic_vector(31 downto 0);    -- axi_stream output set on last data  

signal gpio_btns                : std_logic_vector( 4 downto 0); 

-- JESD_0 interface (4 links, each with 2 lanes)
signal sw_fmc0_samples          : std_logic_vector(255 downto 0);   -- 16 x 16-bit samples from switch
signal axis_fmc0_tx_tdata       : std_logic_vector(255 downto 0);   -- 8 lanes x 4 octets to JESD core
signal axis_fmc0_tx_tready      : std_logic;

signal fmc0_tx_core_reset       : std_logic;
signal fmc0_tx_refclk           : std_logic;
signal fmc0_tx_sysref           : std_logic;
signal fmc0_tx_syncs            : std_logic_vector( 3 downto 0);
signal fmc0_tx_refclk_odiv2     : std_logic;    -- ODIV2 output from GTE4
signal bufgt_fmc0_tx_refclk     : std_logic;

signal fmc0_txp_out             : std_logic_vector( 7 downto 0);
signal fmc0_txn_out             : std_logic_vector( 7 downto 0);
signal fmc0_tx_sof              : std_logic_vector( 3 downto 0);
signal fmc0_tx_somf             : std_logic_vector( 3 downto 0);
signal fmc0_tx_aresetn          : std_logic;
signal fmc0_tx_reset_done       : std_logic;
signal fmc0_gt_powergood        : std_logic;
signal fmc0_irq                 : std_logic;


-- JESD_1 interface (4 links, each with 2 lanes)
signal sw_fmc1_samples          : std_logic_vector(255 downto 0);   -- 16 x 16-bit samples from switch
signal axis_fmc1_tx_tdata       : std_logic_vector(255 downto 0);   -- 8 lanes x 4 octets to JESD core
signal axis_fmc1_tx_tready      : std_logic;

signal fmc1_tx_core_reset       : std_logic;
signal fmc1_tx_refclk           : std_logic;
signal fmc1_tx_sysref           : std_logic;
signal fmc1_tx_syncs            : std_logic_vector( 3 downto 0);
signal fmc1_tx_refclk_odiv2     : std_logic;
signal bufgt_fmc1_tx_refclk     : std_logic;

signal fmc1_txp_out             : std_logic_vector( 7 downto 0);
signal fmc1_txn_out             : std_logic_vector( 7 downto 0);
signal fmc1_tx_sof              : std_logic_vector( 3 downto 0);
signal fmc1_tx_somf             : std_logic_vector( 3 downto 0);
signal fmc1_tx_aresetn          : std_logic;
signal fmc1_tx_reset_done       : std_logic;
signal fmc1_gt_powergood        : std_logic;
signal fmc1_irq                 : std_logic;

-- One for each link.
signal jesd_syncs               : std_logic_vector(31 downto 0) := (others=>'1');

begin

    clk     <= ps_clk0;
    reset   <= not(ps_resetn0);

    -- Combine p_btn trigger (from pad) with misc block trigger and ps_gpout(0) to create internal trigger
    trigger_dacs_pulse      <= p_btn_c or misc_trigger or ps_gpout(0);
    ps_enable_dacs_pulse    <= ps_gpout(1);
    any_dacs_busy           <= dacs_dc_busy(0) or dacs_dc_busy(1) or dacs_dc_busy(2) or dacs_dc_busy(3) or dacs_pulse_busy;

    
    gpio_btns(0)            <= p_btn_e;
    gpio_btns(1)            <= p_btn_s;
    gpio_btns(2)            <= p_btn_n;
    gpio_btns(3)            <= p_btn_w;
    gpio_btns(4)            <= p_btn_c;


    ---------------------------------------------------------------------------------
    -- Processing system.  CPU, JESD interfaces, Console UART etc
    ---------------------------------------------------------------------------------
    u_ps1 : entity work.ps1_wrapper
    port map(
        reset                   => p_reset                  , -- in  std_logic
        
        -- Signals to/from axi_cpuint peripheral
        clk_cpu                 => ps_clk_cpu               , -- out std_logic;
        cpu_addr                => ps_cpu_addr              , -- out std_logic_vector(17 downto 0);
        cpu_wdata               => ps_cpu_wdata             , -- out std_logic_vector(31 downto 0);
        cpu_wr                  => ps_cpu_wr                , -- out std_logic;
        cpu_rd                  => ps_cpu_rd                , -- out std_logic;
        cpu_rdata               => cif_cpu_rdata            , -- in  std_logic_vector( 31 downto 0);
        cpu_rdata_dv            => cif_cpu_rdata_dv         , -- in  std_logic;

        pl_clk0                 => ps_clk0                  , -- out std_logic;
        pl_resetn0              => ps_resetn0               , -- out std_logic;

        gpio_leds_tri_o         => ps_leds                  , -- out std_logic_vector( 7 downto 0);
        gpio_pbtns_tri_i        => gpio_btns                , -- in  std_logic_vector( 4 downto 0);

        gpio_int_in_tri_i       => ps_gpin                  , -- in  std_logic_vector(31 downto 0);
        gpio_int_out_tri_o      => ps_gpout                 , -- out std_logic_vector(31 downto 0);

        ------------------------------------------------------------------------    
        -- FMC0 JESD interface (4 links, each with 2 lanes)
        ------------------------------------------------------------------------    
        s_axis_fmc0_tx_tdata    => axis_fmc0_tx_tdata       , -- in  std_logic_vector(255 downto 0);
        s_axis_fmc0_tx_tready   => axis_fmc0_tx_tready      , -- out std_logic;

        fmc0_tx_core_reset      => fmc0_tx_core_reset       , -- in  std_logic;
        fmc0_tx_refclk          => fmc0_tx_refclk           , -- in  std_logic;
        fmc0_tx_sysref          => fmc0_tx_sysref           , -- in  std_logic;
        fmc0_tx_syncs           => fmc0_tx_syncs            , -- in  std_logic_vector( 3 downto 0);
        fmc0_txp_out            => fmc0_txp_out             , -- out std_logic_vector( 7 downto 0);
        fmc0_txn_out            => fmc0_txn_out             , -- out std_logic_vector( 7 downto 0);
        fmc0_tx_sof             => fmc0_tx_sof              , -- out std_logic_vector( 3 downto 0);
        fmc0_tx_somf            => fmc0_tx_somf             , -- out std_logic_vector( 3 downto 0);
        fmc0_tx_aresetn         => fmc0_tx_aresetn          , -- out std_logic;
        fmc0_tx_reset_done      => fmc0_tx_reset_done       , -- out std_logic;
        fmc0_gt_powergood       => fmc0_gt_powergood        , -- out std_logic;
        fmc0_irq                => fmc0_irq                 , -- out std_logic;

        ------------------------------------------------------------------------    
        -- FMC1 JESD interface (4 links, each with 2 lanes)
        -- **** NOT CONNECTED ****
        ------------------------------------------------------------------------    
        s_axis_fmc1_tx_tdata    => axis_fmc1_tx_tdata       , -- in  std_logic_vector(255 downto 0);
        s_axis_fmc1_tx_tready   => axis_fmc1_tx_tready      , -- out std_logic;

        fmc1_tx_core_reset      => fmc1_tx_core_reset       , -- in  std_logic;
        fmc1_tx_refclk          => fmc1_tx_refclk           , -- in  std_logic;
        fmc1_tx_sysref          => fmc1_tx_sysref           , -- in  std_logic;
        fmc1_tx_syncs           => fmc1_tx_syncs            , -- in  std_logic_vector( 3 downto 0);
        fmc1_txp_out            => fmc1_txp_out             , -- out std_logic_vector( 7 downto 0);
        fmc1_txn_out            => fmc1_txn_out             , -- out std_logic_vector( 7 downto 0);
        fmc1_tx_sof             => fmc1_tx_sof              , -- out std_logic_vector( 3 downto 0);
        fmc1_tx_somf            => fmc1_tx_somf             , -- out std_logic_vector( 3 downto 0);
        fmc1_tx_aresetn         => fmc1_tx_aresetn          , -- out std_logic;
        fmc1_tx_reset_done      => fmc1_tx_reset_done       , -- out std_logic;
        fmc1_gt_powergood       => fmc1_gt_powergood        , -- out std_logic;
        fmc1_irq                => fmc1_irq                   -- out std_logic;
    );

    -- Connect control and status signals to PS GPIOs
    ps_gpin(0)          <= fmc0_tx_reset_done;
    ps_gpin(1)          <= fmc1_tx_reset_done;
    ps_gpin(4)          <= fmc0_gt_powergood;
    ps_gpin(5)          <= fmc1_gt_powergood;
    fmc0_tx_core_reset  <= ps_gpout(4);
    fmc1_tx_core_reset  <= ps_gpout(4);

    -- Connect JESD data lines to pads
    p_fmc0_txp_out          <= fmc0_txp_out;  
    p_fmc0_txn_out          <= fmc0_txn_out;  
    p_fmc1_txp_out          <= fmc1_txp_out;  
    p_fmc1_txn_out          <= fmc1_txn_out;  


    ---------------------------------------------------------------------------------
    -- Instantiate differential pads for FMC0 sync inputs
    ---------------------------------------------------------------------------------
    u_fmc0sync0 : IBUFDS  
    port map(
        I     => p_fmc0_tx_sync_p(0),
        IB    => p_fmc0_tx_sync_n(0),
        O     => fmc0_tx_syncs(0)
    );
    u_fmc0sync1 : IBUFDS  
    port map(
        I     => p_fmc0_tx_sync_p(1),
        IB    => p_fmc0_tx_sync_n(1),
        O     => fmc0_tx_syncs(1)
    );
    u_fmc0sync2 : IBUFDS  
    port map(
        I     => p_fmc0_tx_sync_p(2),
        IB    => p_fmc0_tx_sync_n(2),
        O     => fmc0_tx_syncs(2)
    );
    u_fmc0sync3 : IBUFDS  
    port map(
        I     => p_fmc0_tx_sync_p(3),
        IB    => p_fmc0_tx_sync_n(3),
        O     => fmc0_tx_syncs(3)
    );

    ---------------------------------------------------------------------------------
    -- Instantiate differential pads for FMC1 sync inputs
    ---------------------------------------------------------------------------------
    u_fmc1sync0 : IBUFDS  
    port map(
        I     => p_fmc1_tx_sync_p(0),
        IB    => p_fmc1_tx_sync_n(0),
        O     => fmc1_tx_syncs(0)
    );
    u_fmc1sync1 : IBUFDS  
    port map(
        I     => p_fmc1_tx_sync_p(1),
        IB    => p_fmc1_tx_sync_n(1),
        O     => fmc1_tx_syncs(1)
    );
    u_fmc1sync2 : IBUFDS  
    port map(
        I     => p_fmc1_tx_sync_p(2),
        IB    => p_fmc1_tx_sync_n(2),
        O     => fmc1_tx_syncs(2)
    );
    u_fmc1sync3 : IBUFDS  
    port map(
        I     => p_fmc1_tx_sync_p(3),
        IB    => p_fmc1_tx_sync_n(3),
        O     => fmc1_tx_syncs(3)
    );

    jesd_syncs  <=  fmc1_tx_syncs(3) & fmc1_tx_syncs(3) & fmc1_tx_syncs(3) & fmc1_tx_syncs(3) 
                  & fmc1_tx_syncs(2) & fmc1_tx_syncs(2) & fmc1_tx_syncs(2) & fmc1_tx_syncs(2) 
                  & fmc1_tx_syncs(1) & fmc1_tx_syncs(1) & fmc1_tx_syncs(1) & fmc1_tx_syncs(1) 
                  & fmc1_tx_syncs(0) & fmc1_tx_syncs(0) & fmc1_tx_syncs(0) & fmc1_tx_syncs(0) 
                  & fmc0_tx_syncs(3) & fmc0_tx_syncs(3) & fmc0_tx_syncs(3) & fmc0_tx_syncs(3)
                  & fmc0_tx_syncs(2) & fmc0_tx_syncs(2) & fmc0_tx_syncs(2) & fmc0_tx_syncs(2) 
                  & fmc0_tx_syncs(1) & fmc0_tx_syncs(1) & fmc0_tx_syncs(1) & fmc0_tx_syncs(1) 
                  & fmc0_tx_syncs(0) & fmc0_tx_syncs(0) & fmc0_tx_syncs(0) & fmc0_tx_syncs(0);
  
  --jesd_syncs  <= (others=>'1'); 

    ---------------------------------------------------------------------------------
    -- Instantiate differential pads for FMC sysref clock inputs
    -- LMK SDCLKout3 → same SYSREF epoch as DAC39J84 (subclass 1); ~3.125 MHz @ 100 MSPS LMFC.
    ---------------------------------------------------------------------------------
    u_sysref0 : IBUFDS 
    port map(
        I     => p_fmc0_tx_sysref_p,
        IB    => p_fmc0_tx_sysref_n,
        O     => fmc0_tx_sysref
    );
    u_sysref1 : IBUFDS 
    port map(
        I     => p_fmc1_tx_sysref_p,
        IB    => p_fmc1_tx_sysref_n,
        O     => fmc1_tx_sysref
    );


    ---------------------------------------------------------------------------------
    -- Instantiate differential transciever pads for FMC refclk inputs
    -- LMK DCLKout10 → GBTCLK1: same 100 MHz as DACCLK (DCLKout ÷24), coherent with u_sysref0.
    ---------------------------------------------------------------------------------
    u_refclk0 : IBUFDS_GTE4  
    generic map (
        REFCLK_EN_TX_PATH   => '0', 
        REFCLK_HROW_CK_SEL  => "01",    -- Selects refclk/2. '00' selects refclk
        REFCLK_ICNTL_RX     => "00" 
    )
    port map(
        I       => p_fmc0_tx_refclk_p,
        IB      => p_fmc0_tx_refclk_n,
        ODIV2   => fmc0_tx_refclk_odiv2,
        CEB     => '0',
        O       => fmc0_tx_refclk
    );
    ---------------------------------------------------------------------------------
    -- Buffer for ODIV2 output from GTE4 
    ---------------------------------------------------------------------------------
    u_bufg_gt0 : BUFG_GT
    generic map (
       SIM_DEVICE => "ULTRASCALE_PLUS"  -- ULTRASCALE, ULTRASCALE_PLUS
    )
    port map (
       O        => bufgt_fmc0_tx_refclk , -- 1-bit output: Buffer
       CE       => '1'                  , -- 1-bit input: Buffer enable
       CEMASK   => '0'                  , -- 1-bit input: CE Mask
       CLR      => '0'                  , -- 1-bit input: Asynchronous clear
       CLRMASK  => '0'                  , -- 1-bit input: CLR Mask
       DIV      => "000"                , -- 3-bit input: Dynamic divide Value
       I        => fmc0_tx_refclk_odiv2   -- 1-bit input: Buffer
    );

    ---------------------------------------------------------------------------------
    -- Refclk input buffer
    ---------------------------------------------------------------------------------
    u_refclk1 : IBUFDS_GTE4  
    generic map (
        REFCLK_EN_TX_PATH   => '0', 
        REFCLK_HROW_CK_SEL  => "01",    -- Selects refclk/2. '00' selects refclk
        REFCLK_ICNTL_RX     => "00" 
    )
    port map(
        I       => p_fmc1_tx_refclk_p,
        IB      => p_fmc1_tx_refclk_n,
        ODIV2   => fmc1_tx_refclk_odiv2,
        CEB     => '0',   -- High powers down the buffer
        O       => fmc1_tx_refclk
    );

    ---------------------------------------------------------------------------------
    -- Buffer for ODIV2 output from GTE4 
    ---------------------------------------------------------------------------------
    u_bufg_gt1 : BUFG_GT
    generic map (
       SIM_DEVICE => "ULTRASCALE_PLUS"  -- ULTRASCALE, ULTRASCALE_PLUS
    )
    port map (
       O        => bufgt_fmc1_tx_refclk , -- 1-bit output: Buffer
       CE       => '1'                  , -- 1-bit input: Buffer enable
       CEMASK   => '0'                  , -- 1-bit input: CE Mask
       CLR      => '0'                  , -- 1-bit input: Asynchronous clear
       CLRMASK  => '0'                  , -- 1-bit input: CLR Mask
       DIV      => "000"                , -- 3-bit input: Dynamic divide Value
       I        => fmc1_tx_refclk_odiv2    -- 1-bit input: Buffer
    );


    ---------------------------------------------------------------------------------
    -- JESD204B transport layer for FMC0.
    -- Frames the 16 switch output samples into the 8-lane octet bus expected by
    -- the JESD204 TX core (LMF = 244 per DAC39J84, one link per DAC).
    -- Channel re-mapping for the FMC216 board routing is done in the switch mux
    -- registers; the A/C output inversion is undone in the DAC itself
    -- (config1 daca_compliment / dacc_compliment, see FMC216 UM061).
    ---------------------------------------------------------------------------------
    g_jesd_tp_fmc0 : for d in 0 to 3 generate

        axis_fmc0_tx_tdata(32*d + 31 downto 32*d) <=
              sw_fmc0_samples(16*(4*d+1) +  7 downto 16*(4*d+1)    )
            & sw_fmc0_samples(16*(4*d+1) + 15 downto 16*(4*d+1) + 8)
            & sw_fmc0_samples(16*(4*d+0) +  7 downto 16*(4*d+0)    )
            & sw_fmc0_samples(16*(4*d+0) + 15 downto 16*(4*d+0) + 8);

        axis_fmc0_tx_tdata(32*(d+4) + 31 downto 32*(d+4)) <=
              sw_fmc0_samples(16*(4*d+3) +  7 downto 16*(4*d+3)    )
            & sw_fmc0_samples(16*(4*d+3) + 15 downto 16*(4*d+3) + 8)
            & sw_fmc0_samples(16*(4*d+2) +  7 downto 16*(4*d+2)    )
            & sw_fmc0_samples(16*(4*d+2) + 15 downto 16*(4*d+2) + 8);

    end generate g_jesd_tp_fmc0;

    dacs_pulse_axis_treadys(0)  <= axis_fmc0_tx_tready;
    dacs_pulse_axis_treadys(1)  <= axis_fmc0_tx_tready;
    dacs_pulse_axis_treadys(2)  <= axis_fmc0_tx_tready;
    dacs_pulse_axis_treadys(3)  <= axis_fmc0_tx_tready;
    dacs_pulse_axis_treadys(4)  <= axis_fmc0_tx_tready;
    dacs_pulse_axis_treadys(5)  <= axis_fmc0_tx_tready;
    dacs_pulse_axis_treadys(6)  <= axis_fmc0_tx_tready;
    dacs_pulse_axis_treadys(7)  <= axis_fmc0_tx_tready;
    dacs_pulse_axis_treadys(8)  <= axis_fmc0_tx_tready;
    dacs_pulse_axis_treadys(9)  <= axis_fmc0_tx_tready;
    dacs_pulse_axis_treadys(10) <= axis_fmc0_tx_tready;
    dacs_pulse_axis_treadys(11) <= axis_fmc0_tx_tready;
    dacs_pulse_axis_treadys(12) <= axis_fmc0_tx_tready;
    dacs_pulse_axis_treadys(13) <= axis_fmc0_tx_tready;
    dacs_pulse_axis_treadys(14) <= axis_fmc0_tx_tready;
    dacs_pulse_axis_treadys(15) <= axis_fmc0_tx_tready;


    ---------------------------------------------------------------------------------
    -- JESD204B transport layer for FMC1 (same framing as FMC0)
    ---------------------------------------------------------------------------------
    g_jesd_tp_fmc1 : for d in 0 to 3 generate

        axis_fmc1_tx_tdata(32*d + 31 downto 32*d) <=
              sw_fmc1_samples(16*(4*d+1) +  7 downto 16*(4*d+1)    )
            & sw_fmc1_samples(16*(4*d+1) + 15 downto 16*(4*d+1) + 8)
            & sw_fmc1_samples(16*(4*d+0) +  7 downto 16*(4*d+0)    )
            & sw_fmc1_samples(16*(4*d+0) + 15 downto 16*(4*d+0) + 8);

        axis_fmc1_tx_tdata(32*(d+4) + 31 downto 32*(d+4)) <=
              sw_fmc1_samples(16*(4*d+3) +  7 downto 16*(4*d+3)    )
            & sw_fmc1_samples(16*(4*d+3) + 15 downto 16*(4*d+3) + 8)
            & sw_fmc1_samples(16*(4*d+2) +  7 downto 16*(4*d+2)    )
            & sw_fmc1_samples(16*(4*d+2) + 15 downto 16*(4*d+2) + 8);

    end generate g_jesd_tp_fmc1;

    dacs_pulse_axis_treadys(16)  <= axis_fmc1_tx_tready;
    dacs_pulse_axis_treadys(17)  <= axis_fmc1_tx_tready;
    dacs_pulse_axis_treadys(18)  <= axis_fmc1_tx_tready;
    dacs_pulse_axis_treadys(19)  <= axis_fmc1_tx_tready;
    dacs_pulse_axis_treadys(20)  <= axis_fmc1_tx_tready;
    dacs_pulse_axis_treadys(21)  <= axis_fmc1_tx_tready;
    dacs_pulse_axis_treadys(22)  <= axis_fmc1_tx_tready;
    dacs_pulse_axis_treadys(23)  <= axis_fmc1_tx_tready;
    dacs_pulse_axis_treadys(24)  <= axis_fmc1_tx_tready;
    dacs_pulse_axis_treadys(25)  <= axis_fmc1_tx_tready;
    dacs_pulse_axis_treadys(26)  <= axis_fmc1_tx_tready;
    dacs_pulse_axis_treadys(27)  <= axis_fmc1_tx_tready;
    dacs_pulse_axis_treadys(28)  <= axis_fmc1_tx_tready;
    dacs_pulse_axis_treadys(29)  <= axis_fmc1_tx_tready;
    dacs_pulse_axis_treadys(30)  <= axis_fmc1_tx_tready;
    dacs_pulse_axis_treadys(31)  <= axis_fmc1_tx_tready;



    ---------------------------------------------------------------------------------
    -- Adapter from PS CPU interface and PL CPU bus. 
    -- Generates block selects and merges rdata readback.
    ---------------------------------------------------------------------------------
    u_cif : entity work.qlaser_cif      -- Cpu InterFace
    port map(
        clk                 => clk                  , -- in  std_logic;
        reset               => reset                , -- in  std_logic;
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
        cpu_addr            => cpu_addr             , -- out std_logic_vector(15 downto 2);             -- Address input to core blocks (13:0)
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
        dc0_sclk            => p_dc0_sclk                   , -- out   std_logic;          -- Clock (50 MHz?)
        dc0_mosi            => p_dc0_mosi                   , -- out   std_logic;          -- Master out, Slave in. (Data to DAC)
        dc0_cs_n            => p_dc0_cs_n                   , -- out   std_logic;          -- Active low chip select (sync_n)
        --
        -- Interface SPI bus to 8-channel PMOD for DC channels 8-15
        dc1_sclk            => p_dc1_sclk                   , -- out   std_logic;  
        dc1_mosi            => p_dc1_mosi                   , -- out   std_logic;  
        dc1_cs_n            => p_dc1_cs_n                   , -- out   std_logic;  
        
        -- Interface SPI bus to 8-channel PMOD for DC channels 16-23
        dc2_sclk            => open                         , -- out   std_logic;  
        dc2_mosi            => open                         , -- out   std_logic;  
        dc2_cs_n            => open                         , -- out   std_logic;  
        
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
        G_NCHANS            => 32                                -- integer := 1
    )
    port map(
        clk                 => clk                              , -- in  std_logic; 
        reset               => reset                            , -- in  std_logic;
    
        enable              => ps_enable_dacs_pulse             , -- in  std_logic;                         -- Set when DAC interface is running
        trigger             => trigger_dacs_pulse               , -- in  std_logic;                         -- Set when pulse generation sequence begins (trigger)
        jesd_syncs          => jesd_syncs                       , -- in  std_logic_vector(31 downto 0);     -- Inputs from each JESD TX interface

        -- Status signals
        ready               => dacs_pulse_ready                 , -- out std_logic;                         -- Status signal indicating all JESD channels are sync'ed.
        busy                => dacs_pulse_busy                  , -- out std_logic;                         -- Running a waveform generation sequence.
        error               => dacs_pulse_error                 , -- out std_logic;                         -- Instantanous JESD sync status.
        error_latched       => dacs_pulse_error_latched         , -- out std_logic;                         -- JESD lost sync after ready. Cleared by trigger
    
        -- CPU interface
        cpu_addr            => cpu_addr(12 downto 0)            , -- in  std_logic_vector(11 downto 0);     -- Address input
        cpu_wdata           => cpu_din                          , -- in  std_logic_vector(31 downto 0);     -- Data input
        cpu_wr              => cpu_wr                           , -- in  std_logic;                         -- Write enable 
        cpu_sel             => cpu_sels(SEL_DAC_PULSE)          , -- in  std_logic;                         -- Block select
        cpu_rdata           => arr_cpu_dout(SEL_DAC_PULSE)      , -- out std_logic_vector(31 downto 0);     -- Data output
        cpu_rdata_dv        => arr_cpu_dout_dv(SEL_DAC_PULSE)   , -- out std_logic;                         -- Acknowledge output
                       
        -- Array of 32 AXI-Stream buses. Each with 16-bit data. Interface to JESD TX Interfaces
        axis_treadys        => dacs_pulse_axis_treadys          , -- in  std_logic_vector(31 downto 0);     -- axi_stream ready from downstream modules
        axis_tdatas         => dacs_pulse_axis_tdatas           , -- out t_arr_slv32x16b;                   -- axi stream output data array
        axis_tvalids        => dacs_pulse_axis_tvalids          , -- out std_logic_vector(31 downto 0);     -- axi_stream output data valid
        axis_tlasts         => dacs_pulse_axis_tlasts             -- out std_logic_vector(31 downto 0)      -- axi_stream output set on last data  
    );
    
    ---------------------------------------------------------------------------
    -- Switch
    ---------------------------------------------------------------------------
    u_sw_axis : entity work.switch_axis_16bx32
    port map(
        reset                   => reset                        , --  in  std_logic;
        clk                     => clk                          , --  in  std_logic; 

        -- CPU interface
        cpu_addr                => cpu_addr(11 downto 0)        , -- in  std_logic_vector(11 downto 0);    -- Address input
        cpu_wdata               => cpu_din                      , --  in  std_logic_vector(31 downto 0);    -- Data input
        cpu_wr                  => cpu_wr                       , --  in  std_logic;                        -- Write enable 
        cpu_sel                 => cpu_sels(SEL_SWITCH)         , --  in  std_logic;                        -- Block select
        cpu_rdata               => arr_cpu_dout(SEL_SWITCH)     , --  out std_logic_vector(31 downto 0);    -- Data output
        cpu_rdata_dv            => arr_cpu_dout_dv(SEL_SWITCH)  , --  out std_logic;                        -- Acknowledge output

        -- AXI-stream input array of 32 16-bit streams
        dacs_pulse_axis_treadys => dacs_pulse_axis_treadys      , --  out std_logic_vector(31 downto 0);     -- axi_stream ready to upstream module 
        dacs_pulse_axis_tdatas  => dacs_pulse_axis_tdatas       , --  in  t_arr_slv32x16b;                   -- axi stream output data array
        dacs_pulse_axis_tvalids => dacs_pulse_axis_treadys      , --  in  std_logic_vector(31 downto 0);     -- axi_stream output data valid
        dacs_pulse_axis_tlasts  => X"00000000"                  , --  in  std_logic_vector(31 downto 0);     -- axi_stream output set on last data  

        ---------------------------------------------------------------------------
        -- AXI-stream output 2 256-bit streams, one for each JESD interface in the 
        -- block diagram
        ---------------------------------------------------------------------------
        -- FMC0 JESD interface 
        axis_fmc0_tready        => axis_fmc0_tx_tready          , --  in  std_logic;                        -- axi_stream ready from downstream module
        axis_fmc0_tdata         => sw_fmc0_samples              , --  out std_logic_vector(255 downto 0);   -- 16 x 16-bit samples -> transport layer
        axis_fmc0_tvalid        => open                         , --  out std_logic;                        -- axi_stream output data valid
        axis_fmc0_tlast         => open                         , --  out std_logic;                        -- axi_stream output set on last data  

        -- FMC1 JESD interface 
        axis_fmc1_tready        => axis_fmc1_tx_tready          , --  in  std_logic;                        -- axi_stream ready from downstream module
        axis_fmc1_tdata         => sw_fmc1_samples              , --  out std_logic_vector(255 downto 0);   -- 16 x 16-bit samples -> transport layer
        axis_fmc1_tvalid        => open                         , --  out std_logic;                        -- axi_stream output data valid
        axis_fmc1_tlast         => open                           --  out std_logic;                        -- axi_stream output set on last data  
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

 
    -- Input to pulse stretcher in the misc block which can be used to make signals visible on the LEDs
    pulse(0)    <= trigger_dacs_pulse or dacs_dc_busy(0) or dacs_dc_busy(1) or dacs_dc_busy(2) or dacs_dc_busy(3) or dacs_pulse_busy;
    pulse(1)    <= dacs_pulse_axis_tvalids(0);
    pulse(2)    <= tick_sec;
    pulse(3)    <= '0';

    p_leds(0)   <= misc_flash or gpio_btns(0);          -- continuous flash. overridden by pushbutton
    p_leds(3)   <= misc_flash and ps_leds(0);           -- Controlled flash. Use for FMC0 board present
    p_leds(4)   <= misc_flash and ps_leds(1);           -- Controlled flash. Use for FMC1 board present 
    p_leds(1)   <= pulse_stretched(0);  -- trigger, dac busy, etc.
    p_leds(2)   <= pulse_stretched(1);  
    p_leds(5)   <= or_reduce(dacs_pulse_axis_tdatas(1));  
    p_leds(6)   <= or_reduce(dacs_pulse_axis_tdatas(2));  
    p_leds(7)   <= or_reduce(dacs_pulse_axis_tdatas(3)) or ps_leds(2) or gpio_btns(4);  
    
    
 
    ---------------------------------------------------------------------------------
    -- Debug output mux.
    ---------------------------------------------------------------------------------
    pr_dbg_mux : process (clk)
    begin
        if rising_edge(clk) then

            p_debug_out(0)              <= dacs_pulse_axis_tdatas(0)(3);
            p_debug_out(1)              <= dacs_pulse_axis_tdatas(0)(7);
            p_debug_out(2)              <= dacs_pulse_axis_tdatas(0)(11);
            p_debug_out(3)              <= dacs_pulse_axis_tdatas(0)(15);
            p_debug_out(8)              <= dacs_pulse_axis_tvalids(0);

        end if;
    end process;

    -- **** DEBUG ***
    -- FMC0 SYSREF (same epoch as DAC on FMC0) -> p_debug_out[4] / J15 per pinout_zcu_fmc0_fmc1.xdc
    p_debug_out(4)              <= fmc0_tx_sysref;

    -- refclk has to go into a GTE4 and then the ODIV2 must go to a BUF_GT to
    -- drive other logic.
    p_debug_out(5)              <= bufgt_fmc0_tx_refclk;    -- Div by 2
    p_debug_out(6)              <= bufgt_fmc1_tx_refclk;    -- Div by 2

    p_debug_out(7)              <= or_reduce(fmc0_tx_syncs);
    p_debug_out(9)              <= or_reduce(fmc1_tx_syncs);


end zc102_fmc0_clkdebug;
