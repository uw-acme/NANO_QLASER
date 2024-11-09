--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2022.1.2 (win64) Build 3605665 Fri Aug  5 22:53:37 MDT 2022
--Date        : Fri Nov  8 17:13:19 2024
--Host        : STATIONX2 running 64-bit major release  (build 9200)
--Command     : generate_target ps1_wrapper.bd
--Design      : ps1_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity ps1_wrapper is
  port (
    clk_cpu : out STD_LOGIC;
    cpu_addr : out STD_LOGIC_VECTOR ( 17 downto 0 );
    cpu_rd : out STD_LOGIC;
    cpu_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    cpu_rdata_dv : in STD_LOGIC;
    cpu_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    cpu_wr : out STD_LOGIC;
    gpio_leds_tri_o : out STD_LOGIC_VECTOR ( 7 downto 0 );
    gpio_pbtns_tri_i : in STD_LOGIC_VECTOR ( 4 downto 0 );
    pl_clk0 : out STD_LOGIC;
    pl_resetn0 : out STD_LOGIC;
    reset : in STD_LOGIC
  );
end ps1_wrapper;

architecture STRUCTURE of ps1_wrapper is
  component ps1 is
  port (
    gpio_leds_tri_o : out STD_LOGIC_VECTOR ( 7 downto 0 );
    gpio_pbtns_tri_i : in STD_LOGIC_VECTOR ( 4 downto 0 );
    clk_cpu : out STD_LOGIC;
    cpu_addr : out STD_LOGIC_VECTOR ( 17 downto 0 );
    cpu_rd : out STD_LOGIC;
    cpu_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    cpu_rdata_dv : in STD_LOGIC;
    cpu_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    cpu_wr : out STD_LOGIC;
    reset : in STD_LOGIC;
    pl_resetn0 : out STD_LOGIC;
    pl_clk0 : out STD_LOGIC
  );
  end component ps1;
begin
ps1_i: component ps1
     port map (
      clk_cpu => clk_cpu,
      cpu_addr(17 downto 0) => cpu_addr(17 downto 0),
      cpu_rd => cpu_rd,
      cpu_rdata(31 downto 0) => cpu_rdata(31 downto 0),
      cpu_rdata_dv => cpu_rdata_dv,
      cpu_wdata(31 downto 0) => cpu_wdata(31 downto 0),
      cpu_wr => cpu_wr,
      gpio_leds_tri_o(7 downto 0) => gpio_leds_tri_o(7 downto 0),
      gpio_pbtns_tri_i(4 downto 0) => gpio_pbtns_tri_i(4 downto 0),
      pl_clk0 => pl_clk0,
      pl_resetn0 => pl_resetn0,
      reset => reset
    );
end STRUCTURE;
