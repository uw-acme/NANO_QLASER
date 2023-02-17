--Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
--Date        : Sun Feb  5 13:18:56 2023
--Host        : RATBAG running 64-bit major release  (build 9200)
--Command     : generate_target ps1_wrapper.bd
--Design      : ps1_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
-- ps1_wrapper is maintained by Vivado.  THIS FILE IS FOR SIMULATION
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity ps1_wrapper is
  port (
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_cas_n : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    FCLK_CLK0 : out STD_LOGIC;
    FCLK_RESET0_N : out STD_LOGIC;
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    ext_reset_n : in STD_LOGIC
  );
end ps1_wrapper;


architecture sim_empty of ps1_wrapper is
begin
  
    -- Drive everything to '0'
    DDR_addr            <= (others=>'0');   -- inout std_logic_vector(14 downto 0 );
    DDR_ba              <= (others=>'0');   -- inout std_logic_vector( 2 downto 0 );
    DDR_cas_n           <= '0';             -- inout std_logic;
    DDR_ck_n            <= '0';             -- inout std_logic;
    DDR_ck_p            <= '0';             -- inout std_logic;
    DDR_cke             <= '0';             -- inout std_logic;
    DDR_cs_n            <= '0';             -- inout std_logic;
    DDR_dm              <= (others=>'0');   -- inout std_logic_vector( 3 downto 0 );
    DDR_dq              <= (others=>'0');   -- inout std_logic_vector(31 downto 0 );
    DDR_dqs_n           <= (others=>'0');   -- inout std_logic_vector( 3 downto 0 );
    DDR_dqs_p           <= (others=>'0');   -- inout std_logic_vector( 3 downto 0 );
    DDR_odt             <= '0';             -- inout std_logic;
    DDR_ras_n           <= '0';             -- inout std_logic;
    DDR_reset_n         <= '0';             -- inout std_logic;
    DDR_we_n            <= '0';             -- inout std_logic;
    FCLK_CLK0           <= '0';             -- out   std_logic;
    FCLK_RESET0_N       <= '0';             -- out   std_logic;
    FIXED_IO_ddr_vrn    <= '0';             -- inout std_logic;
    FIXED_IO_ddr_vrp    <= '0';             -- inout std_logic;
    FIXED_IO_mio        <= (others=>'0');   -- inout std_logic_vector(53 downto 0 );
    FIXED_IO_ps_clk     <= '0';             -- inout std_logic;
    FIXED_IO_ps_porb    <= '0';             -- inout std_logic;
    FIXED_IO_ps_srstb   <= '0';             -- inout std_logic;

end sim_empty;
