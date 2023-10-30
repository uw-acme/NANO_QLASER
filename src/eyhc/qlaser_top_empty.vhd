---------------------------------------------------------------
--  File         : qlaser_top_empty.vhd
--  Description  : Empty Top-level of Qlaser FPGA
----------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.qlaser_pkg.all;

entity qlaser_top is
port (
    p_clk                   : in    std_logic;          -- Clock 
    p_reset_n               : in    std_logic;          -- Reset. Check polarity is correct 

    p_trigger               : in    std_logic;          -- Trigger (rising edge) to start pulse output
    p_busy                  : out   std_logic;          -- Set to '1' while pulse outputs are occurring

    -- Serial interface for register read/write
    p_serial_rxd            : in    std_logic;          -- UART Receive data
    p_serial_txd            : out   std_logic;          -- UART Transmit data 

    
    -- Interface SPI bus to 8-channel PMOD for DC channels 0-7
    p_dc0_sclk              : out   std_logic;          -- Clock (50 MHz?)
    p_dc0_mosi              : out   std_logic;          -- Master out, Slave in. (Data to DAC)
    p_dc0_cs_n              : out   std_logic;          -- Active low chip select (sync_n)

    -- Interface SPI bus to 8-channel PMOD for DC channels 8-15
    p_dc1_sclk              : out   std_logic;  
    p_dc1_mosi              : out   std_logic;  
    p_dc1_cs_n              : out   std_logic;  

    -- Interface SPI bus to 8-channel PMOD for DC channels 16-23
    p_dc2_sclk              : out   std_logic;  
    p_dc2_mosi              : out   std_logic;  
    p_dc2_cs_n              : out   std_logic;  

    -- Interface SPI bus to 8-channel PMOD for DC channels 24-31
    p_dc3_sclk              : out   std_logic; 
    p_dc3_mosi              : out   std_logic;  
    p_dc3_cs_n              : out   std_logic;  

    -- 32 pulse outputs
    p_dacs_pulse            : out   std_logic_vector(31 downto 0);

    -- User buttons
    p_btn0                  : in    std_logic; 
    p_btn1                  : in    std_logic; 

    -- Indicator LEDs
    p_leds0_rgb             : out   std_logic_vector( 2 downto 0);      -- 
    p_leds1_rgb             : out   std_logic_vector( 2 downto 0);      -- 

    -- Debug port (if present)
    p_debug_out             : out   std_logic_vector( 7 downto 0)       -- 
);
end entity;

---------------------------------------------------------------
-- Empty architecture to use as a starting point.
---------------------------------------------------------------
architecture empty of qlaser_top is

-- LED colors
constant C_LED_BLU          : integer := 0;
constant C_LED_GRN          : integer := 1;
constant C_LED_RED          : integer := 2;

begin

    p_busy                  <= '0';
    p_serial_txd            <= '0';

    p_dc0_sclk              <= '0';
    p_dc0_mosi              <= '0';
    p_dc0_cs_n              <= '0';
    p_dc1_sclk              <= '0';
    p_dc1_mosi              <= '0';
    p_dc1_cs_n              <= '0';
    p_dc2_sclk              <= '0';
    p_dc2_mosi              <= '0';
    p_dc2_cs_n              <= '0';
    p_dc3_sclk              <= '0';
    p_dc3_mosi              <= '0';
    p_dc3_cs_n              <= '0';
    p_dacs_pulse            <= (others=>'0');

    -- Set LED0 to be green
    p_leds0_rgb(C_LED_RED)  <= '0';
    p_leds0_rgb(C_LED_GRN)  <= '1';
    p_leds0_rgb(C_LED_BLU)  <= '0';

    -- Set LED1 to be blue. Btn0 and 1 change the color
    p_leds1_rgb(C_LED_RED)  <= not(p_btn0);
    p_leds1_rgb(C_LED_GRN)  <= not(p_btn1);
    p_leds1_rgb(C_LED_BLU)  <= '1';

    p_debug_out             <= (others=>'0');

end empty;