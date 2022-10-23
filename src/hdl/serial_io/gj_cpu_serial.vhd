-------------------------------------------------------------------------------
-- Copyright (c) 2012 by GJED, Seattle, WA
-- Confidential - All rights reserved
-------------------------------------------------------------------------------
-- File       : gj_cpu_serial.vhd
-- Wrapper around the serial interface to do address decoding and combine the
-- return data.
-- Messages (R/W) are 32-bit data and 16-bit address
-- Read replies are 32-bit data
-------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.gj_serial_pkg.all;

entity gj_cpu_serial is
port (
    clk             : in  std_logic;
    reset           : in  std_logic;

    -- RS232 serial interface
    rxd             : in  std_logic;    -- UART Receive data
    txd             : out std_logic;    -- UART Transmit data 

    -- CPU interface signals
    cpu_rd          : out std_logic;
    cpu_wr          : out std_logic;
    csbus           : out std_logic_vector(C_NUM_BLOCKS-1 downto 0); -- Decoded from upper 4-bits of addresses
    cpu_addr        : out std_logic_vector(15 downto 0);
    cpu_din         : out std_logic_vector(31 downto 0);

    cpu_dout_dv     : in  std_logic_vector(C_NUM_BLOCKS-1 downto 0);
    arr_cpu_dout    : in  t_arr_cpu_dout;

    debug           : out std_logic_vector( 3 downto 0)
);
end gj_cpu_serial;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
architecture rtl of gj_cpu_serial is

signal cpuint_rd        : std_logic;
signal cpuint_wr        : std_logic;
signal cpuint_addr      : std_logic_vector(15 downto 0);
signal cpuint_din       : std_logic_vector(31 downto 0);
signal cpuint_dout_dv   : std_logic;
signal cpuint_dout      : std_logic_vector(31 downto 0);

signal masked_dout_dv   : std_logic;
signal ack_mask         : std_logic;

begin

    -------------------------------------------------------------------------------
    -- Serial interface
    -------------------------------------------------------------------------------
    u_cpuint_serial : entity work.gj_cpuint_serial
    port map(
        clk         => clk              , -- in  std_logic;
        reset       => reset            , -- in  std_logic;

        -- RS232 serial interface
        rxd         => rxd              , -- in  std_logic;    -- UART Receive data
        txd         => txd              , -- out std_logic;    -- UART Transmit data 

        -- CPU interface signals
        cpu_rd      => cpuint_rd        , -- out std_logic;
        cpu_wr      => cpuint_wr        , -- out std_logic;
        cpu_addr    => cpuint_addr      , -- out std_logic_vector(15 downto 0);
        cpu_din     => cpuint_din       , -- out std_logic_vector(31 downto 0);

        cpu_dout_dv => masked_dout_dv   , -- in  std_logic;
        cpu_dout    => cpuint_dout      , -- in  std_logic_vector(31 downto 0);

        debug       => open               -- out std_logic_vector( 3 downto 0)
    );


    -------------------------------------------------------------------------------
    -- Decode upper address bits.
    -------------------------------------------------------------------------------
    pr_cpubus : process (reset, clk)
    begin

        if (reset = '1') then

            cpu_rd      <= '0';
            cpu_wr      <= '0';
            csbus       <= (others=>'0');
            cpu_addr    <= (others=>'0');
            cpu_din     <= (others=>'0');

        elsif rising_edge(clk) then

            cpu_rd      <= cpuint_rd;
            cpu_wr      <= cpuint_wr;
            cpu_addr    <= "0000" & cpuint_addr(11 downto 0);
            cpu_din     <= cpuint_din;

            csbus       <= (others=>'0');
            if (cpuint_rd='1' or cpuint_wr='1') then
                csbus(to_integer(unsigned(cpuint_addr(15 downto 12)))) <= '1';
            end if;

        end if;
        
    end process;


    -------------------------------------------------------------------------------
    -- This signal prevents blocks that set their 'dout_dv' high on writes as well
    -- as reads from causing a reply message to be sent on writes.
    -------------------------------------------------------------------------------
    pr_ack_mask : process (reset, clk)
    begin

        if (reset = '1') then

            ack_mask    <= '0';

        elsif rising_edge(clk) then

            if (cpuint_wr='1') then
                ack_mask    <= '1';
            elsif (cpuint_dout_dv='1') then 
                ack_mask    <= '0';
            end if;

        end if;
        
    end process;


    -------------------------------------------------------------------------------
    -- Combine cpu_dout and cpu_dout_dv signals into one set.
    -------------------------------------------------------------------------------
    pr_cpuint_dout : process (reset, clk)
    variable v_cpu_dout     : std_logic_vector(31 downto 0) := (others=>'0'); 
    variable v_cpu_dout_dv  : std_logic := '0'; 
    begin

        if (reset = '1') then

            cpuint_dout_dv  <= '0'; 
            masked_dout_dv  <= '0';
            cpuint_dout     <= (others=>'0'); 

        elsif rising_edge(clk) then
            v_cpu_dout      := (others=>'0');
            v_cpu_dout_dv   := '0';
            
            for I in 0 to C_NUM_BLOCKS-1 loop
                
                v_cpu_dout_dv  := v_cpu_dout_dv or cpu_dout_dv(I);
                v_cpu_dout     := v_cpu_dout    or arr_cpu_dout(I);

            end loop;

            cpuint_dout_dv  <= v_cpu_dout_dv;
            masked_dout_dv  <= v_cpu_dout_dv and not(ack_mask);
            cpuint_dout     <= v_cpu_dout;

        end if;

    end process;
        
end rtl;
