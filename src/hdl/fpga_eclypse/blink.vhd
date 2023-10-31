-------------------------------------------------------------------------------
-- Copyright (c) 2013 by GJED, Seattle, WA
-- Confidential - All rights reserved
-------------------------------------------------------------------------------
-- File       : blink.vhd
-------------------------------------------------------------------------------
-- Make a double blink signal for driving an LED.
-- Generate 1 msec and 1 sec ticks.
-- Stretch pulses.
-------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use work.qlaser_pkg.all;

entity blink is
generic (
    G_NBITS                 : in   integer := 4;    -- Default number of pulse stretch bits
    G_INTERVAL_TICK_SLOW    : in   integer := 20    -- Set flash and stretch timing
);
port (
    reset      : in   std_logic;
    clk        : in   std_logic;
    flash      : out  std_logic;
    tick_sec   : out  std_logic;    -- Output tick every 1 sec
    tick_msec  : out  std_logic;    -- Output tick every 1 millisec
    tick_usec  : out  std_logic;    -- Output tick every 1 microsec

    pulse      : in   std_logic_vector(G_NBITS-1 downto 0);
    stretched  : out  std_logic_vector(G_NBITS-1 downto 0)
);
end blink;

architecture rtl of blink is

-- Tick interval
constant C_TICK_INTERVAL_US     : real    :=  1.0;      -- 1 usec

--constant C_LOGIC_FREQ_HZ    : real    := C_CLK_FREQ_MHZ * 1000.0 * 1000.0;    -- FPGA clock freq in Hz set in qlaser.pkg

constant C_DIV_TICK_USEC    : integer := integer(C_CLK_FREQ_MHZ);
constant C_DIV_TICK_MSEC    : integer := 1000;
constant C_DIV_TICK_SEC     : integer := 1000;

constant BIT_FLASH          : integer :=  2; -- Set the flash rate
constant DURATION           : integer := 10; -- Duration of stretched pulses and flash

signal cnt_tick_usec        : integer range 0 to C_DIV_TICK_USEC;
signal tick_usec_i          : std_logic := '0';
signal cnt_tick_msec        : integer range 0 to C_DIV_TICK_MSEC;
signal tick_msec_i          : std_logic := '0';
signal cnt_tick_sec         : integer range 0 to C_DIV_TICK_SEC;
signal tick_sec_i           : std_logic := '0';

signal cnt_tick             : integer range 0 to G_INTERVAL_TICK_SLOW;
signal tick_i               : std_logic := '0';

signal count                : unsigned( 7 downto 0);
signal pulse_d1             : std_logic_vector(G_NBITS-1 downto 0);
signal edge_low             : std_logic_vector(G_NBITS-1 downto 0);
signal clr_edge_low         : std_logic_vector(G_NBITS-1 downto 0);
signal edge_high            : std_logic_vector(G_NBITS-1 downto 0);
signal clr_edge_high        : std_logic_vector(G_NBITS-1 downto 0);
signal last_level           : std_logic_vector(G_NBITS-1 downto 0);

type t_state  is (S_STABLE, S_CHANGED, S_DONE, S_WAIT);
type t_states is array (G_NBITS-1 downto 0) of t_state;
signal states               : t_states;

type t_cnt_stretch is array (G_NBITS-1 downto 0) of unsigned( 3 downto 0);
signal cnt_stretch          : t_cnt_stretch;

signal toggle_1usec         : std_logic;    -- Toggle a signal every microsecond. Use to reduce LED brightness
begin

    tick_usec       <= tick_usec_i;
    tick_msec       <= tick_msec_i;
    tick_sec        <= tick_sec_i;


    -----------------------------------------------------------
    -- Make 1 microsecond tick.
    -- Single clock cycle high every N cycles
    -- Toggle a signal every microsecond. Use to reduce LED brightness
    -----------------------------------------------------------
    pr_tick_usec : process (reset, clk)
    begin
        if (reset='1') then
            cnt_tick_usec   <= 0;
            tick_usec_i     <= '0';
            toggle_1usec    <= '0'; 

        elsif rising_edge(clk) then

            if (cnt_tick_usec = C_DIV_TICK_USEC-1) then
                cnt_tick_usec   <= 0;
                tick_usec_i     <= '1';
                toggle_1usec    <= not(toggle_1usec); 
            else
                cnt_tick_usec   <= cnt_tick_usec + 1 ;
                tick_usec_i     <= '0';
            end if;

        end if;
    end process;


    -----------------------------------------------------------
    -- Make 1 millisecond tick.
    -- Single clock cycle high every 1000 usec ticks 
    -----------------------------------------------------------
    pr_tick_msec : process (reset, clk)
    begin
        if (reset='1') then
            cnt_tick_msec   <= 0;
            tick_msec_i     <= '0';

        elsif rising_edge(clk) then

            if (tick_usec_i = '1') then

                if (cnt_tick_msec = C_DIV_TICK_MSEC-1) then
                    cnt_tick_msec   <= 0;
                    tick_msec_i     <= '1';
                else
                    cnt_tick_msec   <= cnt_tick_msec + 1 ;
                    tick_msec_i     <= '0';
                end if;

            else
                tick_msec_i     <= '0';
            end if;

        end if;
    end process;


    -----------------------------------------------------------
    -- Make 1sec tick from millisecond tick.
    -- Single clock cycle high every 1000 millisec ticks
    -----------------------------------------------------------
    pr_tick_sec : process (reset, clk)
    begin
        if (reset='1') then
            cnt_tick_sec    <=  0;
            tick_sec_i      <= '0';

        elsif rising_edge(clk) then

            if (tick_msec_i = '1') then

                if (cnt_tick_sec = C_DIV_TICK_SEC-1) then
                    cnt_tick_sec    <=  0;
                    tick_sec_i      <= '1';
                else
                    cnt_tick_sec    <= cnt_tick_sec + 1 ;
                    tick_sec_i      <= '0';
                end if;

            else
                tick_sec_i      <= '0';
            end if;

        end if;
    end process;


    -----------------------------------------------------------
    -- Make slow tick from millisecond tick.
    -- Single clock cycle high every M cycles
    -----------------------------------------------------------
    pr_tick : process (reset, clk)
    begin
        if (reset='1') then
            cnt_tick    <=  0;
            tick_i      <= '0';

        elsif rising_edge(clk) then

            if (tick_msec_i = '1') then

                if (cnt_tick = G_INTERVAL_TICK_SLOW-1) then
                    cnt_tick    <=  0;
                    tick_i      <= '1';
                else
                    cnt_tick    <= cnt_tick + 1 ;
                    tick_i      <= '0';
                end if;

            else
                tick_i      <= '0';
            end if;

        end if;
    end process;


    -----------------------------------------------------------
    -- Count ticks.
    -- Used to create patterns for the LED's
    -----------------------------------------------------------
    pr_count : process (reset, clk)
    begin
        if (reset='1') or (tick_sec_i='1') then
            count   <= (others=>'0');
        elsif rising_edge(clk) then
            if (tick_i='1') then
                count   <= count + 1;
            end if;
        end if;
    end process;


    -----------------------------------------------------------
    -- Use count bits to generate a 'flash' signal that blinks twice 
    -- Toggle signal reduces flash LED brightness
    -----------------------------------------------------------
    pr_flash : process (clk)
    begin
        if rising_edge(clk) then
            if (count(7 downto 4)="0000" and count(BIT_FLASH)='0' and toggle_1usec = '1') then
                flash  <= '1';
            else
                flash  <= '0';
            end if ;
        end if;
    end process;


    -----------------------------------------------------------
    -- Stretch an input signal so that any change is stretched 
    -- to at least the time between ticks.
    -----------------------------------------------------------
    pr_clk_str : process (reset, clk)
    begin
        if (reset='1') then
            pulse_d1        <= (others=>'0');
            stretched       <= (others=>'0');
            edge_low        <= (others=>'0');
            clr_edge_low    <= (others=>'0');
            edge_high       <= (others=>'0');
            clr_edge_high   <= (others=>'0');
            last_level      <= (others=>'0');
            for N in 0 to G_NBITS-1 loop
                states(N)           <= S_STABLE;
                cnt_stretch(N)      <= (others=>'0');
            end loop;

        elsif rising_edge(clk) then

            for N in 0 to G_NBITS-1 loop

                pulse_d1(N)     <= pulse(N);

                -- Set a flag whenever a rising edge occurs
                -- Cleared by state machine
                if (pulse(N)='1' and pulse_d1(N)='0') then
                    edge_high(N)    <= '1';
                elsif (clr_edge_high(N)='1') then
                    edge_high(N)    <= '0';
                end if;

                -- Set a flag whenever a falling edge occurs
                -- Cleared by state machine
                if (pulse(N)='0' and pulse_d1(N)='1') then
                    edge_low(N)     <= '1';
                elsif (clr_edge_low(N)='1') then
                    edge_low(N)     <= '0';
                end if;

                case states(N) is

                    -- Wait for a transition on the input. A transition to a different level has priority
                    -- Set the output to the new level.
                    when S_STABLE   =>
                                    if ((edge_high(N)='1' and edge_low(N)='0') or
                                        (edge_high(N)='1' and edge_low(N)='1'and last_level(N)='0')) then
                                        states(N)       <= S_CHANGED;
                                        stretched(N)    <= '1';
                                        last_level(N)   <= '1';
                                    elsif ((edge_high(N)='0' and edge_low(N)='1') or
                                        (edge_high(N)='1' and edge_low(N)='1'and last_level(N)='1')) then
                                        states(N)       <= S_CHANGED;
                                        stretched(N)    <= '0';
                                        last_level(N)   <= '0';
                                    else
                                        stretched(N)    <= pulse(N);
                                    end if;
                                    clr_edge_high(N)    <= '0';
                                    clr_edge_low(N)     <= '0';

                    -- Hold the output
                    when S_CHANGED  =>
                                    if (tick_i='1') then
                                        if (cnt_stretch(N)=DURATION) then
                                            cnt_stretch(N)  <= (others=>'0'); 
                                            states(N)       <= S_DONE;
                                        else
                                            cnt_stretch(N) <= cnt_stretch(N) + 1;
                                        end if;
                                    end if;

                    -- Clear the transition flag
                    when S_DONE    =>
                                    if (tick_i='1') then
                                        states(N)       <= S_WAIT;
                                        if (last_level(N)='1') then
                                            clr_edge_high(N)    <='1';
                                        else    
                                            clr_edge_low(N)     <='1';
                                        end if;
                                    end if;

                    when S_WAIT    =>
                                    states(N)   <= S_STABLE;

                    when others =>
                                    states(N)   <= S_STABLE;
                end case;

            end loop;

        end if;

    end process;

end rtl ;
