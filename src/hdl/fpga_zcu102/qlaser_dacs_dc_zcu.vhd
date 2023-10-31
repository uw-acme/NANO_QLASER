---------------------------------------------------------------
--  File         : qlaser_dacs_dc.vhd
--  Description  : DC output control of Qlaser FPGA
--                 Block drives 4 SPI-bus interfaces to 8 channel DAC boards
--                 Writing to a DAC register starts data transfer to DAC.
--                 Reading any address return the busy flags.
----------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use work.qlaser_dac_dc_pkg.all;

entity qlaser_dacs_dc is
port (
    clk                 : in  std_logic; 
    reset               : in  std_logic;

    busy                : out std_logic_vector( 3 downto 0);    -- Set to '1' while SPI interface is busy

    -- CPU interface
    cpu_addr            : in  std_logic_vector(5 downto 0);    -- Address input
    cpu_wdata           : in  std_logic_vector(11 downto 0);    -- Data input
    cpu_wr              : in  std_logic;                        -- Write enable 
    cpu_sel             : in  std_logic;                        -- Block select
    cpu_rdata           : out std_logic_vector(31 downto 0);    -- Data output
    cpu_rdata_dv        : out std_logic;                        -- Acknowledge output
                   
    -- Interface SPI bus to 8-channel PMOD for DC channels 0-7
    dc0_sclk            : out std_logic;          -- Clock (50 MHz?)
    dc0_mosi            : out std_logic;          -- Master out, Slave in. (Data to DAC)
    dc0_cs_n            : out std_logic;          -- Active low chip select (sync_n)

    -- Interface SPI bus to 8-channel PMOD for DC channels 8-15
    dc1_sclk            : out std_logic;  
    dc1_mosi            : out std_logic;  
    dc1_cs_n            : out std_logic;  
    
    -- Interface SPI bus to 8-channel PMOD for DC channels 16-23
    dc2_sclk            : out std_logic;  
    dc2_mosi            : out std_logic;  
    dc2_cs_n            : out std_logic;  
    
    -- Interface SPI bus to 8-channel PMOD for DC channels 24-31
    dc3_sclk            : out std_logic; 
    dc3_mosi            : out std_logic;  
    dc3_cs_n            : out std_logic
);
end entity;

---------------------------------------------------------------
-- Dummy architecture with CPU bus to allow bit-level control
-- of outputs
---------------------------------------------------------------
architecture rtl of qlaser_dacs_dc is

signal spi0_tx_message              : std_logic_vector(31 downto 0);
signal spi0_tx_message_dv           : std_logic;

signal spi1_tx_message              : std_logic_vector(31 downto 0);
signal spi1_tx_message_dv           : std_logic;

signal spi2_tx_message              : std_logic_vector(31 downto 0);
signal spi2_tx_message_dv           : std_logic;

signal spi3_tx_message              : std_logic_vector(31 downto 0);
signal spi3_tx_message_dv           : std_logic;

signal spi_busy                     : std_logic_vector( 3 downto 0);


begin

    busy       <= spi_busy; 


    --------------------------------------------
    -- Serial interface to an 8-DAC PMOD
    --------------------------------------------
    u_spi0: entity work.qlaser_spi
    port map(  
        clk                 => clk,  
        reset               => reset, 
    
        busy                => spi_busy(0),
    
        -- Transmit data
        tx_message_dv       => spi0_tx_message_dv,                        -- Start message transmit
        tx_message          => spi0_tx_message,    -- Message data
    
        -- SPI interface 
        spi_sclk            => dc0_sclk,                        -- Serial clock input
        spi_mosi            => dc0_mosi,                        -- Serial data. (Master Out, Slave In)
        spi_sel             => dc0_cs_n                         -- Serial block select
    );
    
    --------------------------------------------
    --------------------------------------------
    u_spi1: entity work.qlaser_spi
    port map(
        clk                 => clk,  
        reset               => reset, 
    
        busy                => spi_busy(1),
    
        -- Transmit data
        tx_message_dv       => spi1_tx_message_dv,                        -- Start message transmit
        tx_message          => spi1_tx_message,    -- Message data
    
        -- SPI interface 
        spi_sclk            => dc1_sclk,                        -- Serial clock input
        spi_mosi            => dc1_mosi,                        -- Serial data. (Master Out, Slave In)
        spi_sel             => dc1_cs_n                         -- Serial block select
    );
    
    --------------------------------------------
    --------------------------------------------
    u_spi2: entity work.qlaser_spi
    port map(
        clk                 => clk,  
        reset               => reset, 
    
        busy                => spi_busy(2),
    
        -- Transmit data
        tx_message_dv       => spi2_tx_message_dv,                        -- Start message transmit
        tx_message          => spi2_tx_message,    -- Message data
    
        -- SPI interface 
        spi_sclk            => dc2_sclk,                        -- Serial clock input
        spi_mosi            => dc2_mosi,                        -- Serial data. (Master Out, Slave In)
        spi_sel             => dc2_cs_n                         -- Serial block select
    );
    
    --------------------------------------------
    --------------------------------------------
    u_spi3: entity work.qlaser_spi
    port map(
        clk                 => clk,  
        reset               => reset, 
    
        busy                => spi_busy(3),
    
        -- Transmit data
        tx_message_dv       => spi3_tx_message_dv,                        -- Start message transmit
        tx_message          => spi3_tx_message,    -- Message data
    
        -- SPI interface 
        spi_sclk            => dc3_sclk,                        -- Serial clock input
        spi_mosi            => dc3_mosi,                        -- Serial data. (Master Out, Slave In)
        spi_sel             => dc3_cs_n                         -- Serial block select
    );


    -------------------------------------------------------
    -- CPU interface.
    -------------------------------------------------------
    pr_cpu : process(clk, reset)
    begin
        if reset = '1' then

            spi0_tx_message <= (others=>'0');
            spi1_tx_message <= (others=>'0');
            spi2_tx_message <= (others=>'0');
            spi3_tx_message <= (others=>'0');

            cpu_rdata       <= (others=>'0');
            cpu_rdata_dv    <= '0';

        elsif rising_edge(clk) then
          
            spi0_tx_message_dv <= '0';  -- Defaults
            spi1_tx_message_dv <= '0';
            spi2_tx_message_dv <= '0';
            spi3_tx_message_dv <= '0';
            
            cpu_rdata       <= (others=>'0');
            cpu_rdata_dv    <= '0';

            -- Write to one or more channels
            if (cpu_sel = '1' and cpu_wr = '1') then
                
                case cpu_addr(5 downto 3) is
                        
                    --------------------------------------------------
                    -- Message to all SPI devices
                    -- Enable the DAC internal reference 
                    --------------------------------------------------
                    when C_ADDR_INTERNAL_REF =>

                        spi0_tx_message     <= "0000" & C_CMD_DAC_DC_INTERNAL_REF & "0000" & "000000000000" & "00000001";
                        spi1_tx_message     <= "0000" & C_CMD_DAC_DC_INTERNAL_REF & "0000" & "000000000000" & "00000001";
                        spi2_tx_message     <= "0000" & C_CMD_DAC_DC_INTERNAL_REF & "0000" & "000000000000" & "00000001";
                        spi3_tx_message     <= "0000" & C_CMD_DAC_DC_INTERNAL_REF & "0000" & "000000000000" & "00000001";

                        spi0_tx_message_dv  <= '1';
                        spi1_tx_message_dv  <= '1';
                        spi2_tx_message_dv  <= '1';
                        spi3_tx_message_dv  <= '1';

                    --------------------------------------------------
                    -- Message to all SPI devices
                    -- Enable DAC power
                    --------------------------------------------------
                    when C_ADDR_POWER_ON =>

                        spi0_tx_message     <= "0000" & C_CMD_DAC_DC_POWER & "1111" & "000000000000" & "11111111";
                        spi1_tx_message     <= "0000" & C_CMD_DAC_DC_POWER & "1111" & "000000000000" & "11111111";
                        spi2_tx_message     <= "0000" & C_CMD_DAC_DC_POWER & "1111" & "000000000000" & "11111111";
                        spi3_tx_message     <= "0000" & C_CMD_DAC_DC_POWER & "1111" & "000000000000" & "11111111";
                        
                        spi0_tx_message_dv  <= '1';
                        spi1_tx_message_dv  <= '1';
                        spi2_tx_message_dv  <= '1';
                        spi3_tx_message_dv  <= '1';

                    --------------------------------------------------
                    -- Write 12-bit value to one of 8 DC DACs
                    --------------------------------------------------
                    when C_ADDR_SPI0 =>
                        spi0_tx_message     <= "0000" & C_CMD_DAC_DC_WR & "0" & cpu_addr(2 downto 0) & cpu_wdata(11 downto 0) & "00000000";
                        spi0_tx_message_dv  <= '1';
                    
                    when C_ADDR_SPI1 =>
                        spi1_tx_message     <= "0000" & C_CMD_DAC_DC_WR & "0" & cpu_addr(2 downto 0) & cpu_wdata(11 downto 0) & "00000000";
                        spi1_tx_message_dv  <= '1';
                        
                    when C_ADDR_SPI2 =>
                        spi2_tx_message     <= "0000" & C_CMD_DAC_DC_WR & "0" & cpu_addr(2 downto 0) & cpu_wdata(11 downto 0) & "00000000";
                        spi2_tx_message_dv  <= '1';
                    
                    when C_ADDR_SPI3 =>
                        spi3_tx_message     <= "0000" & C_CMD_DAC_DC_WR & "0" & cpu_addr(2 downto 0) & cpu_wdata(11 downto 0) & "00000000";
                        spi3_tx_message_dv  <= '1';
                        
                    --------------------------------------------------
                    -- Write a common 12-bit value to all DC ADCs
                    --------------------------------------------------
                    when C_ADDR_SPI_ALL =>  
                        spi0_tx_message     <= "0000" & C_CMD_DAC_DC_WR & "1111" & cpu_wdata(11 downto 0) & "00000000";
                        spi1_tx_message     <= "0000" & C_CMD_DAC_DC_WR & "1111" & cpu_wdata(11 downto 0) & "00000000";
                        spi2_tx_message     <= "0000" & C_CMD_DAC_DC_WR & "1111" & cpu_wdata(11 downto 0) & "00000000";
                        spi3_tx_message     <= "0000" & C_CMD_DAC_DC_WR & "1111" & cpu_wdata(11 downto 0) & "00000000";
                        
                        spi0_tx_message_dv  <= '1';
                        spi1_tx_message_dv  <= '1';
                        spi2_tx_message_dv  <= '1';
                        spi3_tx_message_dv  <= '1';    
   
                    when others => null;
                        
                end case;
            
            -- Read status register
            elsif (cpu_sel = '1' and cpu_wr = '0') then

                -- cpu_rdata           <= X"0000000" & spi3_busy & spi2_busy & spi1_busy & spi0_busy;
                cpu_rdata           <= X"0000000" & spi_busy(3) & spi_busy(2) & spi_busy(2) & spi_busy(0);
                cpu_rdata_dv        <= '1';

            end if;
        
        end if;
            
    end process;

end rtl;
