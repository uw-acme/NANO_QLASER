-------------------------------------------------------------------------------
-- Copyright (c) 2013 by GJED, Seattle, WA
-- Confidential - All rights reserved
-------------------------------------------------------------------------------
-- File       : nc3_cpuint_serial.vhd
-- Bidir interface between serial port and CPU bus.
-- Contains UART
-------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.nc3_serial_pkg.all;
use     work.qlaser_pkg.all;

entity qlaser_cpuint is
port (
    clk             : in  std_logic;
    reset           : in  std_logic;
    tick_msec       : in  std_logic;    -- Used to reset interface if a message is corrupted

    -- RS232 serial interface
    rxd             : in  std_logic;    -- UART Receive data
    txd             : out std_logic;    -- UART Transmit data

    -- CPU interface signals
    cpu_rd          : out std_logic;
    cpu_wr          : out std_logic;
    cpu_sels        : out std_logic_vector(C_NUM_BLOCKS-1 downto 0); -- Decoded from upper 4-bits of addresses
    cpu_addr        : out std_logic_vector(15 downto 0);
    cpu_din         : out std_logic_vector(31 downto 0);

    arr_cpu_dout_dv : in  std_logic_vector(C_NUM_BLOCKS-1 downto 0);
    arr_cpu_dout    : in  t_arr_cpu_dout;

    debug           : out std_logic_vector( 3 downto 0)
);
end qlaser_cpuint;

architecture serial of qlaser_cpuint is

signal tied_low     : std_logic;

signal data_rx      : std_logic_vector( 7 downto 0);
signal data_rx_dv   : std_logic;
signal data_rx_err  : std_logic;

signal cpu2uart_busy: std_logic;    -- cpu2int is transmitting a reply message
signal tx_msg_busy  : std_logic;    -- cpu2int is transmitting a reply message
signal tx_ready     : std_logic;    -- UART ready for new character
signal data_tx_wr   : std_logic;
signal data_tx      : std_logic_vector( 7 downto 0);

-- When using IrDA, used to ignore IrDA input during transmit
signal tx_active    : std_logic;    -- UART is transmitting a reply character

signal cpuint_rd        : std_logic;
signal cpuint_wr        : std_logic;
signal cpuint_addr      : std_logic_vector(15 downto 0);
signal cpuint_din       : std_logic_vector(31 downto 0);
signal cpuint_dout_dv   : std_logic;
signal cpuint_dout      : std_logic_vector(31 downto 0);

begin

    tied_low    <= '0';

    debug(0)    <= data_rx_dv;
    debug(1)    <= data_rx_err;
    debug(2)    <= tx_ready;
    debug(3)    <= tx_msg_busy;


    ---------------------------------------------------------------------
    -- Bidir UART connected to RS-232 port
    ---------------------------------------------------------------------
    u_nc3_uart : entity work.nc3_uart
    port map (
        clk         => clk          , -- in  std_logic;
        reset       => reset        , -- in  std_logic;
        bitwidth    => RS232_BDIV   , -- in  std_logic_vector( 7 downto 0);
        parity_on   => tied_low     , -- in  std_logic;
        parity_odd  => tied_low     , -- in  std_logic;
        data_tx     => data_tx      , -- in  std_logic_vector( 7 downto 0);
        data_tx_wr  => data_tx_wr   , -- in  std_logic;
        tx_ready    => tx_ready     , -- out std_logic;
        tx_active   => tx_active    , -- out std_logic                         -- Serial output is active
        data_rx     => data_rx      , -- out std_logic_vector( 7 downto 0);
        data_rx_dv  => data_rx_dv   , -- out std_logic;
        data_rx_err => data_rx_err  , -- out std_logic;
        rxd         => rxd          , -- in  std_logic;
        txd         => txd            -- out std_logic
    );

    ---------------------------------------------------------------------
    -- Convert received messages to write/read the set of data to the CPU bus
    ---------------------------------------------------------------------
    u_nc3_uart2cpu : entity work.nc3_uart2cpu
    port map (
        clk         => clk          , -- in  std_logic;
        reset       => reset        , -- in  std_logic;
        tick_msec   => tick_msec    , -- in  std_logic;    -- Used to reset interface if a message is corrupted
        data_rx     => data_rx      , -- in  std_logic_vector( 7 downto 0);
        data_rx_dv  => data_rx_dv   , -- in  std_logic;
        data_rx_err => data_rx_err  , -- in  std_logic;
        cpu_rd      => cpuint_rd    , -- out std_logic;
        cpu_wr      => cpuint_wr    , -- out std_logic;
        cpu_addr    => cpuint_addr  , -- out std_logic_vector(15 downto 0);
        cpu_data    => cpuint_din     -- out std_logic_vector(31 downto 0)
    );

    ---------------------------------------------------------------------
    -- When cpu_dout_dv is set, send cpu_data to UART
    -- (N bytes of data, prefixed with a header byte.)
    ---------------------------------------------------------------------
    u_nc3_cpu2uart : entity work.nc3_cpu2uart
    port map (
        clk         => clk              , -- in  std_logic;
        reset       => reset            , -- in  std_logic;
        busy        => cpu2uart_busy    , -- out std_logic;
        cpu_data    => cpuint_dout      , -- in  std_logic_vector(31 downto 0);
        cpu_dout_dv => cpuint_dout_dv   , -- in  std_logic;
        tx_ready    => tx_ready         , -- in  std_logic;
        data_tx_wr  => data_tx_wr       , -- out std_logic;
        data_tx     => data_tx            -- out std_logic_vector( 7 downto 0)
    );

    -- Combine busy signals to make a signal that is active until the last
    -- bit of a message has been transmitted
    tx_msg_busy     <= cpu2uart_busy or tx_active;


    -------------------------------------------------------------------------------
    -- Decode upper address bits into block select bits.
    -- Set upper 4 bits of output address to zero.
    -------------------------------------------------------------------------------
    pr_cpubus : process (reset, clk)
    begin

        if (reset = '1') then

            cpu_rd      <= '0';
            cpu_wr      <= '0';
            cpu_sels    <= (others=>'0');
            cpu_addr    <= (others=>'0');
            cpu_din     <= (others=>'0');

        elsif rising_edge(clk) then

            cpu_rd      <= cpuint_rd;
            cpu_wr      <= cpuint_wr;
            cpu_addr    <= "0000" & cpuint_addr(11 downto 0);
            cpu_din     <= cpuint_din;

            cpu_sels    <= (others=>'0');
            if (cpuint_rd='1' or cpuint_wr='1') then
                cpu_sels(to_integer(unsigned(cpuint_addr(15 downto 12)))) <= '1';
            end if;

        end if;

    end process;

    -------------------------------------------------------------------------------
    -- Combine returned cpu_dout and cpu_dout_dv signals into one set.
    -------------------------------------------------------------------------------
    pr_cpuint_dout : process (reset, clk)
    variable v_cpu_dout     : std_logic_vector(31 downto 0) := (others=>'0');
    variable v_cpu_dout_dv  : std_logic := '0';
    begin

        if (reset = '1') then

            cpuint_dout_dv  <= '0';
            cpuint_dout     <= (others=>'0');

        elsif rising_edge(clk) then
            v_cpu_dout      := (others=>'0');
            v_cpu_dout_dv   := '0';

            for I in 0 to C_NUM_BLOCKS-1 loop

                v_cpu_dout_dv  := v_cpu_dout_dv or arr_cpu_dout_dv(I);
                v_cpu_dout     := v_cpu_dout    or arr_cpu_dout(I);

            end loop;

            cpuint_dout_dv  <= v_cpu_dout_dv;
            cpuint_dout     <= v_cpu_dout;

        end if;

    end process;

end serial;
