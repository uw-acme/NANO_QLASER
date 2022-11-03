-------------------------------------------------------------------------------
-- File       : gj_serif_uart2cpu.vhd
-------------------------------------------------------------------------------
-- Copyright (c) 2012 Geoff Jones
-------------------------------------------------------------------------------
-- Receive a five byte message (ack, data3, data2, data1, data0).
-- Check that the expected message header occurred else set a flag.
-------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_arith.all;
use     ieee.std_logic_unsigned.all;

use     work.gj_serial_pkg.all;


entity gj_serif_uart2cpu is
port (
    clk             : in  std_logic;
    reset           : in  std_logic;

    -- Interface to UART
    data_rx         : in  std_logic_vector( 7 downto 0);    -- Received data
    data_rx_dv      : in  std_logic;                        -- Received data valid
    data_rx_err     : in  std_logic;                        -- Error in received data
    
    -- Interface to cpu bus
    msg_data        : out std_logic_vector(31 downto 0);
    err_ack         : out std_logic;                        -- Flag for bad msg header
    err_word        : out std_logic_vector(C_SIZE_RD_MSG-1 downto 0);	-- Flag for error in each word
    interrupt       : out std_logic
);
end gj_serif_uart2cpu;

architecture rtl of gj_serif_uart2cpu is

-------------------------------------------------------------------
--   0      1        2      3      4
--   Ack, Data3, Data2, Data1, Data0
-------------------------------------------------------------------
--constant C_SIZE_RD_MSG  : integer := 5;

-- 0x41, ASCII "A" is the message header
--constant C_HDR_ACK      : std_logic_vector( 7 downto 0) := X"41";

type   t_rx_words is array (C_SIZE_RD_MSG-1 downto 0) of std_logic_vector(7 downto 0);
signal rx_words         : t_rx_words;

signal cnt_words        : integer range 0 to C_SIZE_RD_MSG;
signal msg_done         : std_logic;
    
begin

    -------------------------------------------------------------------                    
    -- Load packet data buffer with UART data
    -- Start CPU operation after PKT_SIZE bytes.
    -------------------------------------------------------------------                    
    pr_clk_rcv : process (clk)
    begin

        if (clk'event and clk='1') then
              
            if (reset='1') then

                err_word    <= (others=>'0');
                cnt_words   <= 0;
	            msg_done    <= '0';
                for I in 0 to C_SIZE_RD_MSG-1 loop
                    rx_words(I) <= (others=>'0'); 
                end loop;

            -- UART writes data
            elsif (data_rx_dv='1') then

                rx_words(cnt_words) <= data_rx;
                err_word(cnt_words) <= data_rx_err;

	            if (cnt_words = C_SIZE_RD_MSG-1) then
	                cnt_words   <= 0;
	                msg_done    <= '1';
	            else
	                cnt_words   <= cnt_words + 1;
	            end if;
                
            else
	            msg_done    <= '0';
            end if;
        end if;

    end process;

    ----------------------------------------------------------------------
    -- Generate an interrupt and output the data.
    -- If first word was not the 'HDR_ACK' then set 'err_ack' until the next
    -- message is done.
    ----------------------------------------------------------------------
    pr_clk_cpu : process (clk)
    begin

        if (clk'event and clk='1') then

            if (reset='1') then

                err_ack     <= '0'; 
                interrupt   <= '0'; 
                msg_data    <= (others=>'0'); 

            elsif (msg_done = '1') then

                if (rx_words(0) = C_HDR_ACK) then
                    interrupt   <= '1'; 
                    err_ack     <= '0'; 
                else
                    err_ack     <= '1'; 
                end if;

                msg_data    <= rx_words(1) & rx_words(2) & rx_words(3) & rx_words(4);
                
            else
                interrupt   <= '0'; 
            end if;

        end if;

    end process;

end rtl;

