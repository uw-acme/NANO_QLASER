---------------------------------------------------------------
--  File         : qlaser_2pmods_pulse.vhd
--  Description  : Block drives a SPI-bus interface to two 8 channel DAC boards.
--                 Intended for testing AC pulse generation.
--                 SPI bus can be written by CPU or by AXI-Stream input.
--                 A control register selects the data source
----------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.qlaser_dac_dc_pkg.all;

entity qlaser_2pmods_pulse is
port (
    clk                 : in  std_logic; 
    reset               : in  std_logic;

    busy0               : out std_logic;                        -- Set to '1' while SPI interface 0 is busy
    busy1               : out std_logic;                        -- Set to '1' while SPI interface 1 is busy

    -- CPU interface
    cpu_addr            : in  std_logic_vector(5 downto 0);     -- Address input
    cpu_wdata           : in  std_logic_vector(11 downto 0);    -- Data input
    cpu_wr              : in  std_logic;                        -- Write enable 
    cpu_sel             : in  std_logic;                        -- Block select
    cpu_rdata           : out std_logic_vector(31 downto 0);    -- Data output
    cpu_rdata_dv        : out std_logic;                        -- Acknowledge output
    
    -- AXI-stream input 0
    axis0_tready         : out std_logic;                        -- axi_stream ready 
    axis0_tdata          : in  std_logic_vector(15 downto 0);    -- axi stream data
    axis0_tvalid         : in  std_logic;                        -- axi_stream data valid
    axis0_tlast          : in  std_logic;                        -- axi_stream set on last data  

    -- AXI-stream input 1
    axis1_tready         : out std_logic;                        -- axi_stream ready
    axis1_tdata          : in  std_logic_vector(15 downto 0);    -- axi stream data
    axis1_tvalid         : in  std_logic;                        -- axi_stream data valid
    axis1_tlast          : in  std_logic;                        -- axi_stream set on last data

    -- Interface SPI bus to 8-channel PMOD for DC channels 0-7
    spi0_sclk            : out std_logic;          -- Clock (50 MHz?)
    spi0_mosi            : out std_logic;          -- Master out, Slave in. (Data to DAC)
    spi0_cs_n            : out std_logic;           -- Active low chip select (sync_n)

    -- Second SPI interface
    spi1_sclk            : out std_logic;          -- Clock (50 MHz?)
    spi1_mosi            : out std_logic;          -- Master out, Slave in. (Data to DAC)
    spi1_cs_n            : out std_logic           -- Active low chip select (sync_n)
);
end entity;

---------------------------------------------------------------
-- SPI bus can be written by CPU or by AXI-Stream input.
-- A control register selects the data source
---------------------------------------------------------------
architecture rtl of qlaser_2pmods_pulse is

constant C_ADDR_CTRL                : std_logic_vector(2 downto 0) := "111";

-- PMOD SPI interface signals
signal spi0_tx_message              : std_logic_vector(31 downto 0);
signal spi0_tx_message_dv           : std_logic;
signal spi0_busy                    : std_logic;

signal spi1_tx_message              : std_logic_vector(31 downto 0);
signal spi1_tx_message_dv           : std_logic;
signal spi1_busy                    : std_logic;

signal cpu_tx_message               : std_logic_vector(31 downto 0);
signal cpu_tx_message_dv            : std_logic;

-- Control register to select data source. 
signal reg_ctrl                     : std_logic;    -- Bit-0 = '1' for AXI-Stream input
alias  mode                         : std_logic is reg_ctrl;

begin

    busy0        <= spi0_busy; 
    busy1        <= spi1_busy;


    ---------------------------------------------------------------
    -- SPI interface
    ---------------------------------------------------------------
    u_spi0: entity work.qlaser_spi
    port map(  
        clk                 => clk,  
        reset               => reset, 
    
        busy                => spi0_busy,
    
        -- Transmit data
        tx_message_dv       => spi0_tx_message_dv,                        -- Start message transmit
        tx_message          => spi0_tx_message,    -- Message data
    
        -- SPI interface 
        spi_sclk            => spi0_sclk,                        -- Serial clock input
        spi_mosi            => spi0_mosi,                        -- Serial data. (Master Out, Slave In)
        spi_sel             => spi0_cs_n                         -- Serial block select
    );

    u_spi1: entity work.qlaser_spi
    port map(  
        clk                 => clk,  
        reset               => reset, 
    
        busy                => spi1_busy,
    
        -- Transmit data
        tx_message_dv       => spi1_tx_message_dv,                        -- Start message transmit
        tx_message          => spi1_tx_message,    -- Message data
    
        -- SPI interface 
        spi_sclk            => spi1_sclk,                        -- Serial clock input
        spi_mosi            => spi1_mosi,                        -- Serial data. (Master Out, Slave In)
        spi_sel             => spi1_cs_n                         -- Serial block select
    );
    
    u_tready_sel0: entity work.qlaser_axis_cpu_sel
    port map(
        clk                 => clk,
        reset               => reset,
        mode                => mode,
        cpu_tx_message      => cpu_tx_message,
        cpu_tx_message_dv   => cpu_tx_message_dv,
        axis_tvalid         => axis0_tvalid,
        axis_tdata          => axis0_tdata,
        spi_busy            => spi0_busy,
        spi_tx_message      => spi0_tx_message,
        spi_tx_message_dv   => spi0_tx_message_dv,
        axis_tready         => axis0_tready
    );

    u_tready_sel1: entity work.qlaser_axis_cpu_sel
    port map(
        clk                 => clk,
        reset               => reset,
        mode                => mode,
        cpu_tx_message      => cpu_tx_message,
        cpu_tx_message_dv   => cpu_tx_message_dv,
        axis_tvalid         => axis1_tvalid,
        axis_tdata          => axis1_tdata,
        spi_busy            => spi1_busy,
        spi_tx_message      => spi1_tx_message,
        spi_tx_message_dv   => spi1_tx_message_dv,
        axis_tready         => axis1_tready
    );


    -------------------------------------------------------
    -- CPU interface.
    -------------------------------------------------------
    pr_cpu : process(clk, reset)
    begin
        if reset = '1' then
            
            cpu_tx_message      <= (others => '0');
            cpu_tx_message_dv   <= '0';

            cpu_rdata           <= (others=>'0');
            cpu_rdata_dv        <= '0';

        elsif rising_edge(clk) then
          
            cpu_tx_message_dv   <= '0';

            -- CPU writes 
            if (cpu_wr = '1' and cpu_sel = '1') then
                
                case cpu_addr(5 downto 3) is
                        
                   -- THIS CASE ONLY FOR DEVELOPMENT, WILL BE REMOVED LATER
                   -- Enable the DAC internal reference 
                    when C_ADDR_INTERNAL_REF =>
                        cpu_tx_message      <= "0000" & C_CMD_DAC_DC_INTERNAL_REF & "0000" & "000000000000" & "00000001";
                        cpu_tx_message_dv  <= '1';

                    when C_ADDR_POWER_ON =>
                        cpu_tx_message     <= "0000" & C_CMD_DAC_DC_POWER & "1111" & "000000000000" & "11111111";
                        cpu_tx_message_dv  <= '1';

                    when C_ADDR_SPI0 =>
                        cpu_tx_message     <= "0000" & C_CMD_DAC_DC_WR & "0" & cpu_addr(2 downto 0) & cpu_wdata(11 downto 0) & "00000000";
                        cpu_tx_message_dv  <= '1';
                    
                    when C_ADDR_SPI1 =>
                        cpu_tx_message     <= "0000" & C_CMD_DAC_DC_WR & "1" & cpu_addr(2 downto 0) & cpu_wdata(11 downto 0) & "00000000";
                        cpu_tx_message_dv  <= '1';
    
                        
                    when C_ADDR_CTRL =>
                        reg_ctrl            <= cpu_wdata(0);

                        when others => null;
                        
                end case;
            
            -- Read status and part of control register
            elsif (cpu_sel = '1' and cpu_wr = '0') then

                cpu_rdata           <= X"000000" & "000" & reg_ctrl & "00" & spi1_busy & spi0_busy;
                cpu_rdata_dv        <= '1';

            end if;
        
        end if;
            
    end process;

end rtl;

