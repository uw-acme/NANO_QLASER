--------------------------------------------------------------------------
--  File         : clkreset.vhd
----------------------------------------------------------------------------
--  Description  : Wrapper for clock PLL and reset logic
--
-- External 'p_reset_n' input resets the PLL immediately and sets the 'reset'
-- active high to the internal FPGA logic. 
-- When the reset goes inactive the PLL will try to generate the requested
-- output freq clock 'clk_i' for the FPGA internal logic from the 'p_clk' input. 
-- Once the PLL output clock is stable the PLL sets the 'pll_locked' output high.
-- A counter then increments to 255 and then the 'reset' output is set low
-- to allow the FPGA logic to run.  
--
-- *** Check p_reset_n polarity, design assumes active low ***
--
----------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;


entity clkreset is
port(
    -- Reset and clock from pads
    p_reset      : in  std_logic;   -- From RESET input pad
    p_clk        : in  std_logic;   -- From CLOCK input pad

    -- Reset and clock outputs to all internal logic
    clk          : out std_logic;
    lock         : out std_logic;
    reset        : out std_logic
);
end clkreset;

------------------------------------------------------------------------
-- Structural architecture instantiates a vendor IP block clock tile.
------------------------------------------------------------------------
architecture struct of clkreset is

signal pll_locked       : std_logic;
signal pll_locked_d1    : std_logic := '0';
signal clk_i            : std_logic;
signal cnt_reset        : unsigned(7 downto 0)  := X"00";
signal reset_pll        : std_logic;

-- Clock generator IP. Use MMCM or PLL
component clkpll 
port (
    refclk     :  in  std_logic := '0'; -- refclk.clk
    reset      :  in  std_logic := '0'; -- reset.reset
    outclk_0   :  out std_logic;        -- outclk0.clk
    locked     :  out std_logic         -- locked.export
);
end component;

begin

    clk         <= clk_i;
    lock        <= pll_locked_d1;
    reset_pll   <= p_reset;
     
    ---------------------------------------------------------------------------------
    -- Clock generator. 100 MHz clock from XX MHz board clock input
    ---------------------------------------------------------------------------------
    u_clkpll : clkpll 
    port map(
        refclk      => p_clk       , -- in  std_logic := '0'; -- refclk.clk
        reset       => reset_pll   , -- in  std_logic := '0'; -- reset.reset
        outclk_0    => clk_i       , -- out std_logic;        -- outclk0.clk
        locked      => pll_locked    -- out std_logic         -- locked.export
    );


    -------------------------------------------------------------------------------
    -- Keep main logic reset until PLL locked for 255 clock cycles
    -------------------------------------------------------------------------------
    pr_reset : process (p_reset, pll_locked, clk_i)
    begin
        if (p_reset = '1' or pll_locked = '0') then
            reset           <= '1';                    
            pll_locked_d1   <= '0';
            cnt_reset       <= X"00";

        elsif rising_edge(clk_i) then

            pll_locked_d1   <= pll_locked;

            if (pll_locked_d1 = '1' and cnt_reset < X"FF") then
                cnt_reset   <= cnt_reset + 1;
            end if;

            if (cnt_reset < X"FF") then
                reset       <= '1';                    
            else    
                reset       <= '0';                    
            end if;

        end if;
    end process;

end struct;


