---------------------------------------------------------------
--  File         : qlaser_axis_cpu_sel.vhdl
--  Description  : Select between CPU interface and AXI-Stream interface.
--                 drives the tready high when in the S_IDLE state and there is data available to be used
--  Author       : EYHC <eyhc.link>
----------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.qlaser_dac_dc_pkg.all;
entity qlaser_axis_cpu_sel is
Port (
    clk                : in  std_logic;
    reset              : in  std_logic;

    mode               : in  std_logic;

    cpu_tx_message     : in  std_logic_vector(31 downto 0);
    cpu_tx_message_dv  : in  std_logic;

    axis_tvalid        : in  std_logic;
    axis_tdata         : in  std_logic_vector(15 downto 0);
    axis_tready        : out std_logic;

    spi_busy           : in  std_logic;
    spi_tx_message     : out std_logic_vector(31 downto 0);
    spi_tx_message_dv  : out std_logic
    
);
end qlaser_axis_cpu_sel;

architecture rtl of qlaser_axis_cpu_sel is
constant C_MODE_AXI                 : std_logic := '1';
constant C_MODE_CPU                 : std_logic := '0';
type t_sm_state  is (
    S_RESET ,   -- Wait for mode_axi = '1'. 
    S_IDLE  ,   -- Wait for  axi_tvalid. Do a SPI write and drop tready
    S_BUSY      -- Wait until spi tx has completed
);
signal sm_state             : t_sm_state;
signal ready                : std_logic;
signal message              : std_logic_vector(31 downto 0);
signal message_dv           : std_logic;

begin
    -------------------------------------------------------
    -- Mux between CPU interface and AXI-Stream interface.
    -- reg_ctrl(0) = '1' enables AXI-Stream access.
    -- Sets AXI tready = '0' while transferring data.
    -- drives the tready high when in the S_IDLE state and there is data available to be used
    -------------------------------------------------------
    pr_mux : process(clk, reset)
    begin
        if reset = '1' then
            
            message     <= (others => '0');
            message_dv  <= '0';
            ready         <= '0';
            sm_state            <= S_IDLE;

        elsif rising_edge(clk) then
            
            if (mode = C_MODE_CPU) then
                message     <= cpu_tx_message;
                message_dv  <= cpu_tx_message_dv;
                ready         <= '0';

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
                            message     <= "0000" & C_CMD_DAC_DC_WR & "0000" & axis_tdata(11 downto 0) & "00000000";
                            message_dv  <= '1';
                            ready         <= '1';
                            sm_state            <= S_BUSY;
                            
                        else
                            message     <= (others=>'0');
                            message_dv  <= '0';
                            ready         <= '0';
                        end if;

                    ----------------------------------------
                    -- Wait for SPI tx to complete
                    ----------------------------------------
                    when S_BUSY => 

                        message     <= (others=>'0');
                        message_dv  <= '0';
                        ready         <= '0';

                        -- TX done. Could check tvalid here to begin a transmit earlier
                        if (spi_busy = '0' and message_dv = '0') then
                            sm_state            <= S_IDLE;
                        end if;

                    when others =>
                        sm_state    <= S_IDLE;

                end case;
            end if;
            
        end if;
            
    end process;

    axis_tready       <= ready;
    spi_tx_message    <= message;
    spi_tx_message_dv <= message_dv;
end rtl;