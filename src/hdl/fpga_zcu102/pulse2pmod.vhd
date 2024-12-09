-----------------------------------------------------------
-- File : pulse2pmod.vhd
-- 
--  Description  : Converts AXI-Stream Pulse data into a 
--                 (much slower) series of SPI transactions
--                 to a DAC
--
----------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all; 
use     ieee.numeric_std.all;

use     work.qlaser_pkg.all;

entity pulse2pmod is
port(
        clk             : in  std_logic;
        reset           : in  std_logic;

        busy            : out std_logic;    -- Set to '1' while SPI interface is busy

        -- CPU interface
        cpu_addr        : in  std_logic_vector( 5 downto 0);
        cpu_wdata       : in  std_logic_vector(31 downto 0);
        cpu_wr          : in  std_logic;
        cpu_sel         : in  std_logic;

        cpu_rdata       : out std_logic_vector(31 downto 0);
        cpu_rdata_dv    : out std_logic; 

        -- AXI-stream input to FIFO
        s_axis_tvalid   : in  std_logic;
        s_axis_tready   : out std_logic;
        s_axis_tdata    : in  std_logic_vector(15 downto 0);
        s_axis_tlast    : in  std_logic;

        -- Interface SPI bus to 8-channel PMOD for DC channels 0-7
        spi_sclk        : out std_logic;          -- Clock (50 MHz?)
        spi_mosi        : out std_logic;          -- Master out, Slave in. (Data to DAC)
        spi_cs_n        : out std_logic           -- Active low chip select (sync_n)
);
end pulse2pmod;

-----------------------------------------------------------
-- Architecture with a 32K depth 16-bit FIFO to buffer the
-- AXI-Stream input data for the 50MHz serial output SPI bus
-- to the DAC PMOD
-----------------------------------------------------------
architecture fifo32K of pulse2pmod is 

signal resetn                       : std_logic;

-- AXI_stream output from FIFO to PMOD
signal fifo_axis_tvalid             : std_logic;
signal fifo_axis_tready             : std_logic;
signal fifo_axis_tdata              : std_logic_vector(15 downto 0);
signal fifo_axis_tlast              : std_logic;

signal fifo_almost_full             : std_logic;
signal fifo_almost_empty            : std_logic;
signal fifo_full                    : std_logic;
signal fifo_empty                   : std_logic;

signal busy_i                       : std_logic;

begin

    resetn  <= not(reset);

    busy    <= busy_i and not(fifo_almost_empty);  -- Set to '1' while SPI interface is busy and FIFO is not empty (just in case...)

    -------------------------------------------------------------
    -- AXI_Stream FIFO buffer between pulse generator and SPI interface
    -------------------------------------------------------------
    u_axi_fifo : entity work.axis_data_fifo_32Kx16b
    port map(
        s_axis_aresetn  => resetn           , -- in  std_logic;
        s_axis_aclk     => clk              , -- in  std_logic;

        s_axis_tvalid   => s_axis_tvalid    , -- in  std_logic;
        s_axis_tready   => s_axis_tready    , -- out std_logic;
        s_axis_tdata    => s_axis_tdata     , -- in  std_logic_vector(15 downto 0);
        s_axis_tlast    => s_axis_tlast     , -- in  std_logic;

        m_axis_tvalid   => fifo_axis_tvalid , -- out std_logic;
        m_axis_tready   => fifo_axis_tready , -- in  std_logic;
        m_axis_tdata    => fifo_axis_tdata  , -- out std_logic_vector(15 downto 0);
        m_axis_tlast    => fifo_axis_tlast  , -- out std_logic;

        almost_full     => fifo_almost_full , -- out std_logic 
        almost_empty    => fifo_almost_empty  -- out std_logic 
    );


    -------------------------------------------------------------
	-- PMOD interface
    --  Block drives a SPI-bus interface to 8 channel DAC boards.
    --  Intended for testing AC pulse generation.
    --  SPI bus can be written by CPU or by AXI-Stream input.
    --  A control register selects the data source
    -------------------------------------------------------------
	u_dac_pulse : entity work.qlaser_pmod_pulse
	port map (
        clk             => clk                      , -- in  std_logic;
        reset           => reset                    , -- in  std_logic;

        busy            => busy_i                   , -- out std_logic;    -- Set to '1' while SPI interface is busy

        -- CPU interface
        cpu_addr        => cpu_addr( 5 downto 0)    , -- in  std_logic_vector( 5 downto 0);
        cpu_wdata       => cpu_wdata(11 downto 0)   , -- in  std_logic_vector(11 downto 0);
        cpu_wr          => cpu_wr                   , -- in  std_logic;
        cpu_sel         => cpu_sel                  , -- in  std_logic;

        cpu_rdata       => cpu_rdata                , -- out std_logic_vector(31 downto 0);
        cpu_rdata_dv    => cpu_rdata_dv             , -- out std_logic; 

        -- AXI-Stream bus.  16-bit data.
        axis_tready     => fifo_axis_tready         , -- out std_logic;    -- axi_stream ready from downstream modules
        axis_tdata      => fifo_axis_tdata          , -- in  std_logic_vector(15 downto 0);   -- axi stream output data array
        axis_tvalid     => fifo_axis_tvalid         , -- in  std_logic;    -- axi_stream output data valid
        axis_tlast      => fifo_axis_tlast          , -- in  std_logic     -- axi_stream output set on last data  

        -- Interface SPI bus to 8-channel PMOD for DC channels 0-7
        spi_sclk        => spi_sclk                 , --  out std_logic;          -- Clock (50 MHz?)
        spi_mosi        => spi_mosi                 , --  out std_logic;          -- Master out, Slave in. (Data to DAC)
        spi_cs_n        => spi_cs_n                   --  out std_logic           -- Active low chip select (sync_n)
    );
    -- fifo_axis_tlast <= '0';

end fifo32K;

