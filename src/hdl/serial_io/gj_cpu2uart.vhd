-------------------------------------------------------------------------------
-- File       : gj_cpu2uart.vhd
-- Copyright (c) 2012 by GJED, Seattle, WA
-- Confidential - All rights reserved
-------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

entity gj_cpu2uart is
port (
    clk           : in  std_logic;
    reset         : in  std_logic;
	
    busy          : out std_logic;

    cpu_data      : in  std_logic_vector(31 downto 0);
    cpu_dout_dv   : in  std_logic;
    
    -- Interface to UART
    tx_ready      : in  std_logic; -- Data has been moved into the shift register
    data_tx_wr    : out std_logic; -- write control for tx_data
    data_tx       : out std_logic_vector( 7 downto 0)
);
end gj_cpu2uart;

-------------------------------------------------------------------------------
-- Arch that not not assume that cpu_data is held stable during the transmit.
-------------------------------------------------------------------------------
architecture rtl of gj_cpu2uart is

-- ASCII 'A' is "ACK" header bytes
constant C_HDR_ACK      : std_logic_vector( 7 downto 0) := X"41";
constant C_SIZE_MSG     : integer := 5; -- Number of bytes in the message
constant C_SIZE_DATA    : integer := 4; -- Number of bytes of data in the message

type t_sm_state  is (S_IDLE, S_WR_CMD, S_WR_DATA, S_WAIT );

signal sm_state          : t_sm_state;

signal start_xmit        : std_logic;
type t_pktdata is array (C_SIZE_DATA-1 downto 0) of std_logic_vector ( 7 downto 0);
signal pktdata           : t_pktdata;
signal cntwords          : integer range 0 to C_SIZE_DATA;

begin
	
	busy	<= '0' when sm_state = S_IDLE else '1';
	
    -------------------------------------------------------------------                    
    -- Set 'start_xmit' when a cpu read occurs. Store the cpu data being
    -- sent.
    -------------------------------------------------------------------                    
    pr_start : process (clk)
    variable v_bitstart : integer range 0 to 8*C_SIZE_DATA;
    begin

        if rising_edge(clk) then

            if (reset='1') then
                start_xmit  <= '0';
            else
                -- New data to transmit
                if (cpu_dout_dv = '1') then
                    start_xmit  <= '1';

                    -- Convert the dat bus into an array of bytes
                    -- pktdata(0)  <= cpu_data(31 downto 24);
                    -- pktdata(1)  <= cpu_data(23 downto 16);
                    -- pktdata(2)  <= cpu_data(15 downto  8);
                    -- pktdata(3)  <= cpu_data( 7 downto  0);
                    v_bitstart  := 8*C_SIZE_DATA;
                    for I in 0 to C_SIZE_DATA-1 loop
                        pktdata(I)  <= cpu_data(v_bitstart-1 downto v_bitstart-8);
                        v_bitstart  := v_bitstart - 8;
                    end loop;
                else
                    start_xmit  <= '0';
                end if;
            end if;
        end if;

    end process;
    

    ----------------------------------------------------------------------
    -- State machine to write bytes of pktdata to UART.
    -- The message starts with the 'A' character followed by the upper 
    -- then lower bytes of the data.
    -- Started by 'start_xmit'.  Ignores 'start_xmit' if in middle of xmit 
    -- or if uart is busy.
    ----------------------------------------------------------------------
    pr_sm : process (clk)

    begin

        if rising_edge(clk) then

            if (reset='1') then
                sm_state    <= S_IDLE;
                data_tx_wr  <= '0';
                data_tx     <= (others=>'0');
                cntwords    <= 0;

            else

                case sm_state is

                    -- When new data arrives and the UART is ready
                    -- write message header data to the UART.
                    when S_IDLE => 
                        if (start_xmit = '1') and (tx_ready='1') then
                            sm_state    <= S_WR_CMD ;
                            data_tx_wr  <= '1';
                            data_tx     <= C_HDR_ACK;
                        else
                            data_tx_wr  <= '0';
                            data_tx     <= (others=>'0');
                        end if;
                        cntwords    <= 0;
                    
                    -- End the write and wait for tx_ready to go low.
                    when S_WR_CMD => 
                        data_tx_wr      <= '0';
                        if (tx_ready = '0') then
                            sm_state    <= S_WAIT;
                        end if;
                    
                    -- Wait until UART is ready then write  
                    -- 8-bits of the data.
                    when S_WAIT => 
                        if (tx_ready = '1') then
                            sm_state    <= S_WR_DATA;
                            data_tx_wr  <= '1';
                            data_tx     <= pktdata(cntwords);
                            cntwords    <= cntwords + 1;
                        else
                            data_tx_wr  <= '0';
                        end if;
                    
                    -- End the write and wait for tx_ready to go low.
                    when S_WR_DATA => 
                        data_tx_wr      <= '0';
                        data_tx         <= (others=>'0');
                        if (tx_ready = '0') then
                            if (cntwords = C_SIZE_DATA) then
                                sm_state    <= S_IDLE ;
                            else
                                sm_state    <= S_WAIT ;
                            end if;
                        end if;
                    
                    
                    when others => 
                        sm_state    <= S_IDLE;

                end case;

            end if;

        end if;

    end process;

end rtl;

