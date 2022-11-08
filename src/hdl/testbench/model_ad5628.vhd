---------------------------------------------------------------
-- File         : model_ad5628.vhd
-- Description  : 8 channel CMOS 12bit DAC. 
--                16-bit 3-wire serial interface 
---------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     std.textio.all;

use     work.std_iopak.all;


entity ad5628 is
port (
    sclk_n       : in  std_logic;   -- Shift reg clock (falling edge. Output update on Nth edge)
    sync_n       : in  std_logic;   -- Frame sync. (Active low to shift)
    din          : in  std_logic;   -- Serial data in

    vref         : in  real;
    vout0        : out real;
    vout1        : out real;
    vout2        : out real;
    vout3        : out real;
    vout4        : out real;
    vout5        : out real;
    vout6        : out real;
    vout7        : out real;
);
end entity;

---------------------------------------------------------------
-- Model of ad5628
---------------------------------------------------------------
architecture rtl of ad5628 is

signal reg_shift    : std_logic_vector(31 downto 0)     := (others=>'0');    -- Shift reg
signal cnt_shift    : integer                           := 0;
signal vreg         : integer                           := 0;

signal tf_sync      : time                              :=  0 ns;
signal tf_sclk      : time                              :=  0 ns;

constant t_sync_fall_to_sclk_fall : time := 13 ns;      -- TODO : Fix values
constant t_sclk_fall_to_sync_rise : time := 20 ns;
constant t_sclk_fall_to_sync_fall : time :=  0 ns;

begin       


    ----------------------------------------------------------------
    -- Count number of sclk falling edges after sync_n goes low.
    -- Shift data in when sync_n is low.
    ----------------------------------------------------------------
    pr_sclk_cnt : process (sclk_n, sync_n)
    variable v_pd : integer := 0;   -- Power down status
    begin
        if falling_edge(sync_n) then
            cnt_shift   <= 0;

        elsif falling_edge(sclk_n) then

            if (sync_n = '0') then

                reg_shift    <= reg_shift(30 downto 0) & din;

                if (cnt_shift = 31) then

                    -- **** TODO : DECODE THIS CORRECTLY
                    v_pd    := to_integer(unsigned(reg_shift(12 downto 11)));

                    if (v_pd = 0) then
                        vreg <= to_integer(unsigned(reg_shift(10 downto 0) & din));
                    else
                        vreg <= 0;
                    end if;
                end if;
                cnt_shift   <= cnt_shift + 1;
            end if;

        elsif rising_edge(sync_n) then
            cnt_shift   <= 0;

        end if;

    end process;
    
    -- *** TODO : decode upper bits of shift reg for commands and dac select
    -- Set output voltage
    vout0   <= (vref * real(vreg))/4096.0;

	
    ----------------------------------------------------------------
    -- Save the times of sclk edges.
    ----------------------------------------------------------------
    process (sclk_n)
    begin
        if falling_edge(sclk_n) then tf_sclk <= now; end if;
    end process;

    ----------------------------------------------------------------
    -- Save the times of sync_n edges.
    ----------------------------------------------------------------
    process (sync_n)
    begin
        if falling_edge(sync_n) then tf_sync <= now; end if;
    end process;


    ----------------------------------------------------------------
    -- Timing checks
    ----------------------------------------------------------------
    process (sclk_n)
    begin
        if ((now/=0 ns) and (now-tf_sync) < t_sync_fall_to_sclk_fall) then 
           report ("AD5628  : t_sync_fall_to_sclk_fall violation") 
           severity warning;
        end if;
    end process;


    process (sync_n)
    begin
        -- Rising edge of sync
--        if rising_edge(sync_n) then
--            if ((now/=0 ns) and (now-tf_sclk) < t_sclk_fall_to_sync_rise) then 
--               report ("AD5628  : t_sclk_fall_to_sync_rise violation") 
--               severity error;
--            end if;
--        end if;

        -- Falling edge of sync
        if falling_edge(sync_n) then
            if ((now/=0 ns) and (now-tf_sclk) < t_sclk_fall_to_sync_fall) then 
               report ("AD5628  : t_sclk_fall_to_sync_fall violation") 
               severity error;
            end if;
        end if;
    end process;


end rtl;
