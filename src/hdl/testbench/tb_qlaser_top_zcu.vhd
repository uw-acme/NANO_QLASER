-----------------------------------------------------------
-- File : tb_qlaser_top_zcu.vhd
-----------------------------------------------------------
-- 
-- Testbench for CPU bus peripheral.
--
--  Description  : Pulse output control of Qlaser FPGA
--                 Block drives AXI-stream to JESD DACs
--
----------------------------------------------------------
library ieee;
use     ieee.numeric_std.all;
use     ieee.std_logic_1164.all; 
use     std.textio.all; 

use     work.qlaser_pkg.all;
use     work.std_iopak.all;
use     work.qlaser_dacs_pulse_channel_pkg.all;


entity tb_qlaser_top is
    generic (
        SIM_DURATION : integer := 32768
    );
end    tb_qlaser_top;

architecture behave of tb_qlaser_top is 

-- component qlaser_top
--   port (
--       p_reset                 : in    std_logic;
--       p_dc0_sclk              : out   std_logic;
--       p_dc0_mosi              : out   std_logic;
--       p_dc0_cs_n              : out   std_logic;
--       p_dc1_sclk              : out   std_logic;  
--       p_dc1_mosi              : out   std_logic;  
--       p_dc1_cs_n              : out   std_logic;
--       p_dc2_sclk              : out   std_logic;  
--       p_dc2_mosi              : out   std_logic;  
--       p_dc2_cs_n              : out   std_logic;
--       p_dc3_sclk              : out   std_logic; 
--       p_dc3_mosi              : out   std_logic;  
--       p_dc3_cs_n              : out   std_logic;
--       p_btn_e                 : in    std_logic; 
--       p_btn_s                 : in    std_logic; 
--       p_btn_n                 : in    std_logic; 
--       p_btn_w                 : in    std_logic; 
--       p_btn_c                 : in    std_logic;
--       p_leds                  : out   std_logic_vector( 7 downto 0);
--       p_debug_out             : out   std_logic_vector( 9 downto 0)
--   );
--   end component;


-- component ad5628 port (
--                                  sclk_n       : in  std_logic;
--                                  sync_n       : in  std_logic;
--                                  din          : in  std_logic;
--                                  vref         : in  real;
--                                  vout0        : out real;
--                                  vout1        : out real;
--                                  vout2        : out real;
--                                  vout3        : out real;
--                                  vout4        : out real;
--                                  vout5        : out real;
--                                  vout6        : out real;
--                                  vout7        : out real
--                              );
-- end component;


signal clk: std_logic;  

signal p_reset: std_logic;
signal p_dc0_sclk: std_logic;
signal p_dc0_mosi: std_logic;
signal p_dc0_cs_n: std_logic;
signal p_dc1_sclk: std_logic;
signal p_dc1_mosi: std_logic;
signal p_dc1_cs_n: std_logic;
signal p_dc2_sclk: std_logic;
signal p_dc2_mosi: std_logic;
signal p_dc2_cs_n: std_logic;
signal p_dc3_sclk: std_logic;
signal p_dc3_mosi: std_logic;
signal p_dc3_cs_n: std_logic;
signal p_btn_e: std_logic;
signal p_btn_s: std_logic;
signal p_btn_n: std_logic;
signal p_btn_w: std_logic;
signal p_btn_c: std_logic;
signal p_leds: std_logic_vector( 7 downto 0);
signal p_debug_out: std_logic_vector( 9 downto 0) ;

signal vref0: real;
signal vout0: real;
signal vout1: real;
signal vout2: real;
signal vout3: real;
signal vout4: real;
signal vout5: real;
signal vout6: real;
signal vout7: real;

signal vref1: real;
signal vout8: real;
signal vout9: real;
signal vout10: real;
signal vout11: real;
signal vout12: real;
signal vout13: real;
signal vout14: real;
signal vout15: real;

-- Halts simulation by stopping clock when set true
signal sim_done                     : boolean   := false;

-- Crystal clock freq expressed in MHz
constant CLK_FREQ_MHZ               : real      := 100.0; 
-- Clock period
constant CLK_PER                    : time      := integer(1.0E+6/(CLK_FREQ_MHZ)) * 1 ps;

-- Block registers
-- constant ADR_RAM_PULSE              : integer   :=  to_integer(unsigned(X"0000"));    -- TODO: Modelsim cannot compile this
-- constant ADR_RAM_WAVE               : integer   :=  to_integer(unsigned(X"0200"));    -- TODO: Modelsim cannot compile this
constant ADR_RAM_PULSE              : integer   :=  0;    -- TODO: Modelsim cannot compile this
constant ADR_RAM_WAVE               : integer   :=  2048;    -- TODO: Modelsim cannot compile this


-------------------------------------------------------------
-- Delay
-------------------------------------------------------------
procedure clk_delay(
    constant nclks  : in  integer
) is
begin
    for I in 0 to nclks loop
        wait until clk'event and clk ='0';
    end loop;
end;


----------------------------------------------------------------
-- Print a string with no time or instance path.
----------------------------------------------------------------
procedure cpu_print_msg(
    constant msg    : in    string
) is
variable line_out   : line;
begin
    write(line_out, msg);
    writeline(output, line_out);
end procedure cpu_print_msg;


begin
    p_debug_out(0) <= '0';
    -------------------------------------------------------------
	-- Unit Under Test
    -------------------------------------------------------------
	u_qlaser_top : entity work.qlaser_top 
    port map ( 
        p_reset     => p_reset,
        p_dc0_sclk  => p_dc0_sclk,
        p_dc0_mosi  => p_dc0_mosi,
        p_dc0_cs_n  => p_dc0_cs_n,
        p_dc1_sclk  => p_dc1_sclk,
        p_dc1_mosi  => p_dc1_mosi,
        p_dc1_cs_n  => p_dc1_cs_n,
        p_dc2_sclk  => p_dc2_sclk,
        p_dc2_mosi  => p_dc2_mosi,
        p_dc2_cs_n  => p_dc2_cs_n,
        p_dc3_sclk  => p_dc3_sclk,
        p_dc3_mosi  => p_dc3_mosi,
        p_dc3_cs_n  => p_dc3_cs_n,
        p_btn_e     => p_btn_e,
        p_btn_s     => p_btn_s,
        p_btn_n     => p_btn_n,
        p_btn_w     => p_btn_w,
        p_btn_c     => p_btn_c,
        p_leds      => p_leds,
        p_debug_out => p_debug_out 
    );

    -- testad5628: ad5628 port map ( 
    --     sclk_n => p_dc0_sclk,
    --     sync_n => p_dc0_cs_n,
    --     din    => p_dc0_mosi,
    --     vref   => vref,
    --     vout0  => vout0,
    --     vout1  => vout1,
    --     vout2  => vout2,
    --     vout3  => vout3,
    --     vout4  => vout4,
    --     vout5  => vout5,
    --     vout6  => vout6,
    --     vout7  => vout7 );

    u_pmoddac0: entity work.ad5628 
    port map ( 
        sclk_n => p_dc0_sclk,
        sync_n => p_dc0_cs_n,
        din    => p_dc0_mosi,
        vref   => vref0,
        vout0  => vout0,
        vout1  => vout1,
        vout2  => vout2,
        vout3  => vout3,
        vout4  => vout4,
        vout5  => vout5,
        vout6  => vout6,
        vout7  => vout7 );

    u_pmoddac1: entity work.ad5628
    port map ( 
        sclk_n => p_dc1_sclk,
        sync_n => p_dc1_cs_n,
        din    => p_dc1_mosi,
        vref   => vref1,
        vout0  => vout8,
        vout1  => vout9,
        vout2  => vout10,
        vout3  => vout11,
        vout4  => vout12,
        vout5  => vout13,
        vout6  => vout14,
        vout7  => vout15 );
	

    -------------------------------------------------------------
    -- Generate system clock. Halt when sim_done is true.
    -------------------------------------------------------------
    pr_clk : process
    begin
        clk  <= '0';
        wait for (CLK_PER/2);
        clk  <= '1';
        wait for (CLK_PER-CLK_PER/2);
        if (sim_done=true) then
            wait; 
        end if;
    end process;

  
    -------------------------------------------------------------
    -- Reset and drive CPU bus 
    -------------------------------------------------------------
    pr_main : process
    variable v_ndata32        : integer := 0;
    variable v_ndata16        : integer := 0;
    
    begin
        -- Reset 
        p_reset <= '1';
        p_btn_e <= '0';
        p_btn_s <= '0';
        p_btn_n <= '0';
        p_btn_w <= '0';
        p_btn_c <= '0';
        vref0   <= 3.3;
        vref1   <= 3.3;
        clk_delay(5);
        
        cpu_print_msg("Simulation start");
        p_reset <= '0';


        clk_delay(SIM_DURATION);
        
        cpu_print_msg("Simulation done");
        clk_delay(10);
		
        sim_done    <= true;
        wait;

    end process;

end behave;

