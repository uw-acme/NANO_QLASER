-------------------------------------------------------------------------------
-- Copyright (c) 2012 by GJED, Seattle, WA
-- Confidential - All rights reserved
-------------------------------------------------------------------------------
-- File       : nc3_uart2cpu.vhd
-- Every 7 bytes received write/read the set of data to the 
-- CPU bus (Received in order : Cmd, Addr1, Addr0, Data3(Upper), Data2, Data1, Data0(DataLower)
-------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.nc3_serial_pkg.all;

entity nc3_uart2cpu is
port (
    clk         : in  std_logic;
    reset       : in  std_logic;
    tick_msec   : in  std_logic;    -- Used to reset interface if a message is corrupted

    -- Interface to UART
    data_rx     : in  std_logic_vector( 7 downto 0);
    data_rx_dv  : in  std_logic;
    data_rx_err : in  std_logic;
    
    -- Interface to cpu bus
    cpu_rd      : out std_logic;
    cpu_wr      : out std_logic;
    cpu_addr    : out std_logic_vector(15 downto 0);
    cpu_data    : out std_logic_vector(31 downto 0)
);
end nc3_uart2cpu;

architecture rtl of nc3_uart2cpu is

-------------------------------------------------------------------
--   Set to packet size - 1
--   6    5      4      3          2      1      0   
--   Cmd, Addr1, Addr0, DataUpper, Data2, Data1, DataLower
-------------------------------------------------------------------
-- Command characters 
constant CPU_OP_WR      : std_logic_vector( 7 downto 0) := X"57"; -- 'W' = Write
constant CPU_OP_RD      : std_logic_vector( 7 downto 0) := X"52"; -- 'R' = Read

constant C_SIZE_MSG     : integer := 7; -- Number of bytes in the message
constant C_BYTE_CMD     : integer := 6; --
constant C_BYTE_ADDR1   : integer := 5; -- 
constant C_BYTE_ADDR0   : integer := 4; -- 
constant C_BYTE_DATA3   : integer := 3; -- 
constant C_BYTE_DATA2   : integer := 2; -- 
constant C_BYTE_DATA1   : integer := 1; -- 
constant C_BYTE_DATA0   : integer := 0; -- 

type   t_rx_words is array (C_SIZE_MSG-1 downto 0) of std_logic_vector(7 downto 0);
signal rx_words         : t_rx_words;

signal sreg_err         : std_logic_vector(C_SIZE_MSG-1 downto 0) := (others=>'1');
signal sreg_cmd         : std_logic_vector(C_SIZE_MSG-1 downto 0) := (others=>'0');
signal new_data         : std_logic := '0';

signal msg_busy         : std_logic;                -- Set when first message byte is received. Cleared when read/write occurs
signal cnt_tick         : integer range 0 to 31;    -- IrDA timeout in msec. 
signal msg_timeout      : std_logic;                -- Set when receiving a message when max gap between data is exceeded.
    
signal cpu_rd_i         : std_logic;
signal cpu_wr_i         : std_logic;

begin

    cpu_rd  <= cpu_rd_i;
    cpu_wr  <= cpu_wr_i;


    -------------------------------------------------------------------                    
    -- Load data shift register with UART data
    -------------------------------------------------------------------                    
    pr_pkt : process (clk)
    begin

        if rising_edge(clk) then

            cpu_rd_i <= '0';
            cpu_wr_i <= '0';
              
            if (reset='1' or msg_timeout='1') then
                sreg_err    <= (others=>'1');
                sreg_cmd    <= (others=>'0');
                new_data    <= '0';
				for I in 0 to C_SIZE_MSG-1 loop
					rx_words(I)	<= (others=>'0');
				end loop;

            else
                new_data    <= data_rx_dv;

                -- Save data from UART
                if (data_rx_dv='1') then

                    rx_words    <= rx_words(C_SIZE_MSG-2 downto 0) & data_rx;
                    sreg_err    <= sreg_err(C_SIZE_MSG-2 downto 0) & data_rx_err;

                    -- Set a shift reg bit when a command is seen
                    if ((data_rx=CPU_OP_RD) or (data_rx=CPU_OP_WR)) then
                        sreg_cmd    <= sreg_cmd(C_SIZE_MSG-2 downto 0) & '1';
                    else
                        sreg_cmd    <= sreg_cmd(C_SIZE_MSG-2 downto 0) & '0';
                    end if;

                -- On the cycle after each new byte, if the command shift reg has a bit set in the msb 
                -- and there are no errors then we see which command it is and execute a cpu bus transaction.
                -- TODO : Possible false command detection if data is misaligned and the address or data field includes a command value. 
                elsif (new_data='1' and sreg_cmd(C_BYTE_CMD) = '1' and sreg_err="0000000") then

                    if    (rx_words(C_BYTE_CMD) = CPU_OP_RD) then
                        cpu_rd_i    <= '1';
                    elsif (rx_words(C_BYTE_CMD) = CPU_OP_WR) then
                        cpu_wr_i    <= '1';
                    end if;

                    sreg_err    <= (others=>'1'); -- Preload with 'errors' that must be flushed out
                    sreg_cmd    <= (others=>'0');
                
                end if;
            end if;
        end if;

    end process;

    -- Assign received data to address and data busses
    cpu_addr <= rx_words(C_BYTE_ADDR1) & rx_words(C_BYTE_ADDR0);
    cpu_data <= rx_words(C_BYTE_DATA3) & rx_words(C_BYTE_DATA2) & rx_words(C_BYTE_DATA1) & rx_words(C_BYTE_DATA0);


    -------------------------------------------------------------------                    
    -- Reset uart2cpu when too large of a gap occurs between characters
    -------------------------------------------------------------------                    
    pr_timeout : process (clk)
    begin

        if rising_edge(clk) then

            msg_timeout <= '0';     -- Set when receiving a message when max gap between data is exceeded.

            if (reset='1' or msg_timeout='1') then
                msg_busy    <= '0';     -- Set when first message byte is received. Cleared when read/write occurs
                cnt_tick    <= 0;       -- IrDA timeout in msec. 

            else

                -- See data from UART
                if (data_rx_dv='1') then
                    msg_busy    <= '1';
                    cnt_tick    <= 0;

                elsif (cpu_rd_i='1' or cpu_wr_i='1') then
                    msg_busy    <= '0';
                    cnt_tick    <= 0;

                elsif (msg_busy='1' and tick_msec='1') then
                    if (cnt_tick = C_TIMEOUT_SERIAL) then
                        msg_timeout <= '1';
                    else
                        cnt_tick    <= cnt_tick + 1;
                    end if;

                end if;
            end if;
        end if;

    end process;

end rtl;

