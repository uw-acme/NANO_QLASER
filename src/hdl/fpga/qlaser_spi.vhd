-------------------------------------------------------------------------------
-- File         : qlaser_spi.vhd
-- Description  : SPI interface in to communicate with low-speed DC DACs
-------------------------------------------------------------------------------
-- The interface receives data at the same time as it produces output data.
-------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

entity qlaser_spi is
port (  
    clk                 : in  std_logic;
    reset               : in  std_logic;

    busy                : out std_logic;

    -- Transmit data
    tx_message_dv       : in  std_logic;                        -- Start message transmit
    tx_message          : in  std_logic_vector(31 downto 0);    -- Message data

    -- SPI interface 
    spi_sclk            : out std_logic;                        -- Serial clock input
    spi_mosi            : out std_logic;                        -- Serial data. (Master Out, Slave In)
    spi_sel             : out std_logic                         -- Serial block select
);
end qlaser_spi;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
architecture rtl of qlaser_spi is

constant C_SPI_MSG_LENGTH : integer := 32;

-- Number of FPGA main clock cycles in one half cycle of the SPI clock.
constant C_SPI_DIVISOR_CLK  : integer := 1; 

signal sreg_dout            : std_logic_vector(C_SPI_MSG_LENGTH-1 downto 0);
signal cnt_divclk           : integer range 0 to C_SPI_DIVISOR_CLK-1;
signal cnt_bit              : integer range 0 to C_SPI_MSG_LENGTH-1;
signal sm_advance           : std_logic;

type   t_state_spi is (
        S_SPI_IDLE, S_SPI_START, S_SPI_CLKLOW, S_SPI_CLKHIGH, S_SPI_DONE
);
signal state_spi            : t_state_spi;

signal spi_sel_i            : std_logic;

begin

    spi_sel     <= not spi_sel_i;
    busy        <= spi_sel_i;
    spi_mosi    <= sreg_dout(C_SPI_MSG_LENGTH-1);


    ---------------------------------------------------
    -- Sets the bit rate.
    -- Generate a single-cycle pulse every 'N' clocks.
    ---------------------------------------------------
    pr_divclk : process (reset, clk)
    begin

        if rising_edge(clk) then

            if (reset='1') then
                cnt_divclk  <= 0;
                sm_advance  <= '0';

            elsif (state_spi = S_SPI_IDLE) then
                cnt_divclk  <= 0;
                sm_advance  <= '0';

            elsif (cnt_divclk = C_SPI_DIVISOR_CLK-1) then
                cnt_divclk  <= 0;
                sm_advance  <= '1';
            else
                cnt_divclk  <= cnt_divclk + 1;
                sm_advance  <= '0';
            end if;

        end if;
    end process;


    -------------------------------------------------------
    -- State machine.
    -------------------------------------------------------
    pr_sm_spi : process (clk)
    begin

        if rising_edge(clk) then


            if (reset='1') then
                state_spi       <= S_SPI_IDLE;
                spi_sel_i       <= '0';
                spi_sclk        <= '0';
                sreg_dout       <= (others=>'0');
                
                cnt_bit         <= 0;
            else
                case state_spi is

                    ---------------------------------------------------
                    -- Wait until a message is ready for sending
                    ---------------------------------------------------
                    when S_SPI_IDLE =>

                        if (tx_message_dv = '1') then
                            state_spi   <= S_SPI_START ;
                            sreg_dout   <= tx_message;
                            spi_sel_i   <= '1';
                        else
                            spi_sel_i   <= '0';
                        end if;

                        cnt_bit     <= 0;
                        spi_sclk    <= '0';

                    ---------------------------------------------------
                    -- Wait for the counter
                    ---------------------------------------------------
                    when S_SPI_START    =>

                        if (sm_advance = '1') then
                            state_spi       <= S_SPI_CLKHIGH ;
                            spi_sclk        <= '1';
                        end if;

                     ---------------------------------------------------
                    -- Clock is high. At end of clock period count, set
                    -- clock low and sample the incoming data
                    ---------------------------------------------------
                    when S_SPI_CLKHIGH =>

                        if (sm_advance = '1') then
                            state_spi   <= S_SPI_CLKLOW;
                            spi_sclk     <= '0';

                        end if;
                        
                    ---------------------------------------------------
                    -- Clock is low. At end of clock period count, set
                    -- clock high  
                    ---------------------------------------------------
                    when S_SPI_CLKLOW => 

                        if (sm_advance = '1') then

                            if (cnt_bit = C_SPI_MSG_LENGTH-1) then -- End of message
                                state_spi   <= S_SPI_DONE;
                            else
                                state_spi   <= S_SPI_CLKHIGH;
                                cnt_bit     <= cnt_bit + 1;
                            end if;
                            
                            spi_sclk    <= '1';
                            -- Shift data out on rising edge of the clock. Bit 31 sent first
                            sreg_dout(C_SPI_MSG_LENGTH-1 downto 0)  <= sreg_dout(C_SPI_MSG_LENGTH-2 downto 0) & '0';
                            
                        end if;
     
                    when S_SPI_DONE => 

                        if (sm_advance = '1') then
                            state_spi   <= S_SPI_IDLE;
                            spi_sclk    <= '0';
                            spi_sel_i   <= '0';
                        end if;

                    when others =>
                        state_spi       <= S_SPI_IDLE ;

                end case;

            end if;
        end if;

    end process;

end rtl;
