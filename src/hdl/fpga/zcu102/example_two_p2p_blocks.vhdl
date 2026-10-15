
-- New block selects
signal cpu_sel_p2p0         : std_logic; 
signal cpu_sel_p2p1         : std_logic; 

-- New readout signals
signal p2p0_cpu_rdata       : std_logic_vector(31 downto 0);
signal p2p0_cpu_rdata_dv    : std_logic; 
signal p2p1_cpu_rdata       : std_logic_vector(31 downto 0);
signal p2p1_cpu_rdata_dv    : std_logic; 

-- Two sets of p2p outputs
signal p2p0_spi_sclk        : std_logic; 
signal p2p0_spi_mosi        : std_logic; 
signal p2p0_spi_cs_n        : std_logic; 
signal p2p1_spi_sclk        : std_logic; 
signal p2p1_spi_mosi        : std_logic; 
signal p2p1_spi_cs_n        : std_logic; 

signal p2p_busy0            : std_logic;    -- Set to '1' while SPI interface is busy
signal p2p_busy1            : std_logic; 

begin
.
.
.

    -- Split 'SEL_SPARE' block select into two
    cpu_sel_p2p0 <= cpu_sels(SEL_SPARE) and not cpu_addr(15); 
    cpu_sel_p2p1 <= cpu_sels(SEL_SPARE) and     cpu_addr(15); 

    -- Combine 2 p2p block readout back into one to drive back to qlaser_cif block
    arr_cpu_dout(SEL_SPARE)     <= p2p0_cpu_rdata or p2p1_cpu_rdata;
    arr_cpu_dout_dv(SEL_SPARE)  <= p2p0_cpu_rdata_dv or p2p1_cpu_rdata_dv;

    p2p_busy    <= p2p_busy0 or p2p_busy1;


    -----------------------------------------------------------------------------------
    --      **** FOR PROTOTYPE TESTING ****
    --
    -- Block containing an AXI-Stream FIFO and a stream-to-spi PMOD interface 
    -- Allows pulse data to drive a 'dc' DAC at a low speed.
    -----------------------------------------------------------------------------------
    u_pulse2pmod0 : entity work.pulse2pmod
    port map(
        clk                 => clk                          ,  -- in  std_logic;
        reset               => reset                        ,  -- in  std_logic;

        busy                => p2p_busy0                    ,  -- out std_logic;    -- Set to '1' while SPI interface is busy

        -- CPU interface
        cpu_addr            => cpu_addr( 5 downto 0)        ,  -- in  std_logic_vector( 5 downto 0);
        cpu_wdata           => cpu_din                      ,  -- in  std_logic_vector(31 downto 0);
        cpu_wr              => cpu_wr                       ,  -- in  std_logic;
        cpu_sel             => cpu_sel_p2p0                 ,  -- in  std_logic;
        cpu_rdata           => p2p0_cpu_dout                ,  -- out std_logic_vector(31 downto 0);
        cpu_rdata_dv        => p2p0_cpu_dout_dv             ,  -- out std_logic; 

        -- AXI-stream input to FIFO
        s_axis_tready       => dacs_pulse_axis_treadys(0)   ,  -- out std_logic;
        s_axis_tvalid       => dacs_pulse_axis_tvalids(0)   ,  -- in  std_logic;
        s_axis_tdata        => dacs_pulse_axis_tdatas(0)    ,  -- in  std_logic_vector(15 downto 0);
        s_axis_tlast        => dacs_pulse_axis_tlasts(0)    ,  -- in  std_logic;
                                        
        -- Interface SPI bus to 8-channel PMOD for DC channels 0-7
        spi_sclk            => p2p0_spi_sclk                ,  -- out std_logic;
        spi_mosi            => p2p0_spi_mosi                ,  -- out std_logic;
        spi_cs_n            => p2p0_spi_cs_n                   -- out std_logic 
    );
    
    -- P2P0 drives PMOD2
    p_dc2_sclk      <= p2p0_spi_sclk; 
    p_dc2_mosi      <= p2p0_spi_mosi; 
    p_dc2_cs_n      <= p2p0_spi_cs_n; 


    -----------------------------------------------------------------------------------
    --      **** FOR PROTOTYPE TESTING ****
    --
    -- Block containing an AXI-Stream FIFO and a stream-to-spi PMOD interface 
    -- Allows pulse data to drive a 'dc' DAC at a low speed.
    -----------------------------------------------------------------------------------
    u_pulse2pmod1 : entity work.pulse2pmod
    port map(
        clk                 => clk                          ,  -- in  std_logic;
        reset               => reset                        ,  -- in  std_logic;

        busy                => p2p_busy1                    ,  -- out std_logic;    -- Set to '1' while SPI interface is busy

        -- CPU interface
        cpu_addr            => cpu_addr( 5 downto 0)        ,  -- in  std_logic_vector( 5 downto 0);
        cpu_wdata           => cpu_din                      ,  -- in  std_logic_vector(31 downto 0);
        cpu_wr              => cpu_wr                       ,  -- in  std_logic;
        cpu_sel             => cpu_sel_p2p1                 ,  -- in  std_logic;
        cpu_rdata           => p2p1_cpu_dout                ,  -- out std_logic_vector(31 downto 0);
        cpu_rdata_dv        => p2p1_cpu_dout_dv             ,  -- out std_logic; 

        -- AXI-stream input to FIFO
        s_axis_tready       => dacs_pulse_axis_treadys(1)   ,  -- out std_logic;
        s_axis_tvalid       => dacs_pulse_axis_tvalids(1)   ,  -- in  std_logic;
        s_axis_tdata        => dacs_pulse_axis_tdatas(1)    ,  -- in  std_logic_vector(15 downto 0);
        s_axis_tlast        => dacs_pulse_axis_tlasts(1)    ,  -- in  std_logic;
                                        
        -- Interface SPI bus to 8-channel PMOD for DC channels 0-7
        spi_sclk            => p2p1_spi_sclk                ,  -- out std_logic;
        spi_mosi            => p2p1_spi_mosi                ,  -- out std_logic;
        spi_cs_n            => p2p1_spi_cs_n                   -- out std_logic 
    );
    
    -- P2P1 drives PMOD3
    p_dc3_sclk      <= p2p1_spi_sclk; 
    p_dc3_mosi      <= p2p1_spi_mosi; 
    p_dc3_cs_n      <= p2p1_spi_cs_n; 


