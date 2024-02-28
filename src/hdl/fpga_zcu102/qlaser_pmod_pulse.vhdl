---------------------------------------------------------------
--  File         : qlaser_pmod_pulse.vhd
--  Description  : Block drives a SPI-bus interface to 8 channel DAC boards.
--                 Intended for testing AC pulse generation.
--                 SPI bus can be written by CPU or by AXI-Stream input.
--                 A control register selects the data source
----------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.qlaser_dac_dc_pkg.all;

entity qlaser_pmod_pulse is
port (
    clk                 : in  std_logic; 
    reset               : in  std_logic;

    busy                : out std_logic;                        -- Set to '1' while SPI interface is busy

    -- CPU interface
    cpu_addr            : in  std_logic_vector(5 downto 0);     -- Address input
    cpu_wdata           : in  std_logic_vector(11 downto 0);    -- Data input
    cpu_wr              : in  std_logic;                        -- Write enable 
    cpu_sel             : in  std_logic;                        -- Block select
    cpu_rdata           : out std_logic_vector(31 downto 0);    -- Data output
    cpu_rdata_dv        : out std_logic;                        -- Acknowledge output
    
    -- AXI-stream input
    axis_tready         : out std_logic;                        -- axi_stream ready 
    axis_tdata          : in  std_logic_vector(15 downto 0);    -- axi stream data
    axis_tvalid         : in  std_logic;                        -- axi_stream data valid
    axis_tlast          : in  std_logic;                        -- axi_stream set on last data  

    -- Interface SPI bus to 8-channel PMOD for DC channels 0-7
    spi_sclk            : out std_logic;          -- Clock (50 MHz?)
    spi_mosi            : out std_logic;          -- Master out, Slave in. (Data to DAC)
    spi_cs_n            : out std_logic           -- Active low chip select (sync_n)
);
end entity;

---------------------------------------------------------------
-- SPI bus can be written by CPU or by AXI-Stream input.
-- A control register selects the data source
---------------------------------------------------------------
architecture rtl of qlaser_pmod_pulse is

constant C_ADDR_CTRL                : std_logic_vector(2 downto 0) := "111";

-- PMOD SPI interface signals
signal spi0_tx_message              : std_logic_vector(31 downto 0);
signal spi0_tx_message_dv           : std_logic;
signal spi0_busy                    : std_logic;

signal cpu_tx_message               : std_logic_vector(31 downto 0);
signal cpu_tx_message_dv            : std_logic;

-- Control register to select data source. 
signal reg_ctrl                     : std_logic;    -- Bit-0 = '1' for AXI-Stream input
alias  mode                         : std_logic is reg_ctrl;
constant C_MODE_CPU                 : std_logic := '0';
constant C_MODE_AXI                 : std_logic := '1';

-- State variable type declaration for AXI interface state machine
type t_sm_state  is (
    S_RESET ,   -- Wait for mode_axi = '1'. 
    S_IDLE  ,   -- Wait for  axi_tvalid. Do a SPI write and drop tready
    S_BUSY      -- Wait until spi tx has completed
);
signal sm_state             : t_sm_state;
begin

    busy        <= spi0_busy; 


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
        spi_sclk            => spi_sclk,                        -- Serial clock input
        spi_mosi            => spi_mosi,                        -- Serial data. (Master Out, Slave In)
        spi_sel             => spi_cs_n                         -- Serial block select
    );
    

    -------------------------------------------------------
    -- Mux between CPU interface and AXI-Stream interface.
    -- reg_ctrl(0) = '1' enables AXI-Stream access.
    -- Sets AXI tready = '0' while transferring data.
    -------------------------------------------------------
    pr_mux : process(clk, reset)
    begin
        if reset = '1' then
            
            spi0_tx_message     <= (others => '0');
            spi0_tx_message_dv  <= '0';
            axis_tready         <= '0';
            sm_state            <= S_IDLE;

        elsif rising_edge(clk) then
            
            if (mode = C_MODE_CPU) then
                spi0_tx_message     <= cpu_tx_message;
                spi0_tx_message_dv  <= cpu_tx_message_dv;
                axis_tready         <= '0';

            else    -- mode = AXI
                case sm_state is


                    ----------------------------------------
                    -- Wait for AXI data or mode change
                    ----------------------------------------
                    when S_IDLE => 

                        if (mode = C_MODE_CPU) then
                            sm_state    <= S_IDLE;

                        elsif (axis_tvalid = '1') then
                            -- Build a 32-bit command to write 12-bit data from 16-bit AXI data to DAC0
                            --                               Command           DACn     Data
                            spi0_tx_message     <= "0000" & C_CMD_DAC_DC_WR & "0000" & axis_tdata(11 downto 0) & "00000000";
                            spi0_tx_message_dv  <= '1';
                            axis_tready         <= '1';
                            sm_state            <= S_BUSY;
                            
                        else
                            spi0_tx_message     <= (others=>'0');
                            spi0_tx_message_dv  <= '0';
                            axis_tready         <= '0';
                        end if;

                    ----------------------------------------
                    -- Wait for SPI tx to complete
                    ----------------------------------------
                    when S_BUSY => 

                        spi0_tx_message     <= (others=>'0');
                        spi0_tx_message_dv  <= '0';
                        axis_tready         <= '0';

                        -- TX done. Could check tvalid here to begin a transmit earlier
                        if (spi0_busy = '0' and spi0_tx_message_dv = '0') then
                            sm_state            <= S_IDLE;
                        end if;

                    when others =>
                        sm_state    <= S_IDLE;

                end case;
            end if;
            
        end if;
            
    end process;


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

                    when C_ADDR_CTRL =>
                        reg_ctrl            <= cpu_wdata(0);

                        when others => null;
                        
                end case;
            
            -- Read status and part of control register
            elsif (cpu_sel = '1' and cpu_wr = '0') then

                cpu_rdata           <= X"000000" & "000" & reg_ctrl & "000" & spi0_busy;
                cpu_rdata_dv        <= '1';

            end if;
        
        end if;
            
    end process;

end rtl;

