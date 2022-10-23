-------------------------------------------------------------------------------
-- Copyright (c) 2012 by GJED, Seattle, WA
-- Confidential - All rights reserved
-------------------------------------------------------------------------------
-- File       : gj_uart2cpu.vhd
-- Every 7 bytes received write/read the set of data to the 
-- CPU bus (Received in order : Cmd, Addr1, Addr0, Data3(Upper), Data2, Data1, Data0(DataLower)
-- (8-bit address/32-bit data)
-------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

entity gj_uart2cpu is
port (
    clk         : in  std_logic;
    reset       : in  std_logic;

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
end gj_uart2cpu;

architecture rtl of gj_uart2cpu is

-------------------------------------------------------------------
--   Set to packet size - 1
--   5    4      3          2      1      0   
--   Cmd, Addr0, DataUpper, Data2, Data1, DataLower
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
    
begin

    -------------------------------------------------------------------                    
    -- Load data shift register with UART data
    -------------------------------------------------------------------                    
    pr_pkt : process (clk)
    begin

        if rising_edge(clk) then

            cpu_rd   <= '0';
            cpu_wr   <= '0';
              
            if (reset='1') then
                sreg_err    <= (others=>'1');
                sreg_cmd    <= (others=>'0');
                new_data    <= '0';
                    
                for I in 0 to C_SIZE_MSG-1 loop
                    rx_words(I) <= (others=>'0');
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
                        cpu_rd      <= '1';
                    elsif (rx_words(C_BYTE_CMD) = CPU_OP_WR) then
                        cpu_wr      <= '1';
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

end rtl;

