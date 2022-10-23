-------------------------------------------------------------------------------
-- Copyright (c) 2012 by GJED, Seattle, WA
-- Confidential - All rights reserved
-------------------------------------------------------------------------------
-- File       : gj_cpuint_serial.vhd
-- Bidir interface between serial port and CPU bus.
-- Contains UART 
-------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.gj_serial_pkg.all;

entity gj_cpuint_serial is
port (
    clk         : in  std_logic;
    reset       : in  std_logic;

    -- RS232 serial interface
    rxd         : in  std_logic;    -- UART Receive data
    txd         : out std_logic;    -- UART Transmit data 

    -- CPU interface signals
    cpu_rd      : out std_logic;
    cpu_wr      : out std_logic;
    cpu_addr    : out std_logic_vector(15 downto 0);
    cpu_din     : out std_logic_vector(31 downto 0);

    cpu_dout_dv : in  std_logic;
    cpu_dout    : in  std_logic_vector(31 downto 0);

    debug       : out std_logic_vector( 3 downto 0)
);
end gj_cpuint_serial;

architecture rtl of gj_cpuint_serial is

signal tied_low     : std_logic;
signal tied_high    : std_logic;

signal data_rx      : std_logic_vector( 7 downto 0);
signal data_rx_dv   : std_logic;
signal data_rx_err  : std_logic;

signal cpu2uart_busy: std_logic;	-- cpu2int is transmitting a reply message
signal tx_msg_busy  : std_logic;	-- cpu2int is transmitting a reply message
signal tx_ready     : std_logic;	-- UART ready for new character
signal data_tx_wr   : std_logic;
signal data_tx      : std_logic_vector( 7 downto 0);

-- When using IrDA, used to ignore IrDA input during transmit
signal tx_active    : std_logic;    -- UART is transmitting a reply character 
signal rxd_gated    : std_logic;                    

begin

    tied_low    <= '0';
    tied_high   <= '1';

    debug(0)    <= data_rx_dv;
    debug(1)    <= data_rx_err;
    debug(2)    <= tx_ready;
    debug(3)    <= tx_msg_busy;

    ---------------------------------------------------------------------
    -- When using IrDA the received serial input signal must be ignored
    -- during transmits because it echoes the transmitted signal.
    -- The rxd_gated signal to the UART is kept high during transmit.
    -- i.e. there is no duplex mode.
    ---------------------------------------------------------------------
    rxd_gated   <= rxd or tx_active; 
    
    ---------------------------------------------------------------------
    -- Bidir UART connected to RS-232 port
    ---------------------------------------------------------------------
    u_gj_uart : entity work.gj_uart
    port map (
        clk         => clk          , -- in  std_logic;
        reset       => reset        , -- in  std_logic;
        bitwidth    => RS232_BDIV   , -- in  std_logic_vector(11 downto 0);
        parity_on   => tied_high    , -- in  std_logic;                    
        parity_odd  => tied_low     , -- in  std_logic;                    
        data_tx     => data_tx      , -- in  std_logic_vector( 7 downto 0);
        data_tx_wr  => data_tx_wr   , -- in  std_logic;                    
        tx_ready    => tx_ready     , -- out std_logic;                    
        tx_active   => tx_active    , -- out std_logic                         -- Serial output is active
        data_rx     => data_rx      , -- out std_logic_vector( 7 downto 0);
        data_rx_dv  => data_rx_dv   , -- out std_logic;                    
        data_rx_err => data_rx_err  , -- out std_logic;                    
        rxd         => rxd_gated    , -- in  std_logic;                    
        txd         => txd            -- out std_logic                     
    );

    ---------------------------------------------------------------------
    -- Convert received messages to write/read the set of data to the CPU bus 
    ---------------------------------------------------------------------
    u_gj_uart2cpu : entity work.gj_uart2cpu
    port map (
        clk         => clk          , -- in  std_logic;
        reset       => reset        , -- in  std_logic;
        data_rx     => data_rx      , -- in  std_logic_vector( 7 downto 0);
        data_rx_dv  => data_rx_dv   , -- in  std_logic;
        data_rx_err => data_rx_err  , -- in  std_logic;
        cpu_rd      => cpu_rd       , -- out std_logic;
        cpu_wr      => cpu_wr       , -- out std_logic;
        cpu_addr    => cpu_addr     , -- out std_logic_vector( 7 downto 0);
        cpu_data    => cpu_din        -- out std_logic_vector(31 downto 0)
    );

    ---------------------------------------------------------------------
    -- When cpu_dout_dv is set, send cpu_data to UART 
    -- (N bytes of data, prefixed with a header byte.)
    ---------------------------------------------------------------------
    u_gj_cpu2uart : entity work.gj_cpu2uart
    port map (
        clk         => clk          , -- in  std_logic;
        reset       => reset        , -- in  std_logic;
        busy        => cpu2uart_busy, -- out std_logic;
        cpu_data    => cpu_dout     , -- in  std_logic_vector(31 downto 0);
        cpu_dout_dv => cpu_dout_dv  , -- in  std_logic;
        tx_ready    => tx_ready     , -- in  std_logic;
        data_tx_wr  => data_tx_wr   , -- out std_logic;
        data_tx     => data_tx        -- out std_logic_vector( 7 downto 0)
    );

    -- Combine busy signals to make a signal that is active until the last
    -- bit of a message has been transmitted
    tx_msg_busy     <= cpu2uart_busy or tx_active; 

end rtl;
