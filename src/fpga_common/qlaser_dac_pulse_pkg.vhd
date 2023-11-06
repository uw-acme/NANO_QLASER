----------------------------------------------------------------------------------------
-- Project       : qlaser FPGA
-- File          : qlaser_version_pkg.vhd
-- Description   : Version package file.
-- Author        : akozyra
----------------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;

package qlaser_dac_pulse_pkg is

----------------------------------------------------------------------------------------
--  Constants 
----------------------------------------------------------------------------------------

-- Addresses
constant C_ADDR_RAM0                : std_logic_vector(1 downto 0)  := "00";
constant C_MAX_TIME_PULSE           : std_logic_vector(23 downto 0) := X"4C4B40";

------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
COMPONENT jesd204_phy_0
  PORT (
    cpll_refclk : IN STD_LOGIC;
    drpclk : IN STD_LOGIC;
    tx_reset_gt : IN STD_LOGIC;
    rx_reset_gt : IN STD_LOGIC;
    tx_sys_reset : IN STD_LOGIC;
    rx_sys_reset : IN STD_LOGIC;
    txp_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    txn_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    rxp_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    rxn_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    tx_core_clk : IN STD_LOGIC;
    rx_core_clk : IN STD_LOGIC;
    txoutclk : OUT STD_LOGIC;
    rxoutclk : OUT STD_LOGIC;
    gt_prbssel : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt0_txdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt0_txcharisk : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt1_txdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt1_txcharisk : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt2_txdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt2_txcharisk : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt3_txdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt3_txcharisk : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt4_txdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt4_txcharisk : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt5_txdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt5_txcharisk : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt6_txdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt6_txcharisk : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt7_txdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt7_txcharisk : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    tx_reset_done : OUT STD_LOGIC;
    gt_powergood : OUT STD_LOGIC;
    gt0_rxdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt0_rxcharisk : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt0_rxdisperr : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt0_rxnotintable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt1_rxdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt1_rxcharisk : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt1_rxdisperr : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt1_rxnotintable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt2_rxdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt2_rxcharisk : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt2_rxdisperr : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt2_rxnotintable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt3_rxdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt3_rxcharisk : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt3_rxdisperr : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt3_rxnotintable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt4_rxdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt4_rxcharisk : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt4_rxdisperr : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt4_rxnotintable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt5_rxdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt5_rxcharisk : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt5_rxdisperr : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt5_rxnotintable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt6_rxdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt6_rxcharisk : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt6_rxdisperr : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt6_rxnotintable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt7_rxdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt7_rxcharisk : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt7_rxdisperr : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt7_rxnotintable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    rx_reset_done : OUT STD_LOGIC;
    rxencommaalign : IN STD_LOGIC 
  );
END COMPONENT;
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

end package qlaser_dac_pulse_pkg;