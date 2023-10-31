---------------------------------------------------------------
--  File         : qlaser_dacs_pulse.vhd
--  Description  : Qlaser FPGA, pulsed outputs
----------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.qlaser_pkg.all;
use     work.qlaser_dac_pulse_pkg.all;

entity qlaser_dacs_pulse is
port (
	clk             	: in  std_logic; 
	reset             	: in  std_logic;

	trigger           	: in  std_logic;                      -- Trigger (rising edge) to start pulse output
	busy              	: out std_logic;                      -- Set to '1' while pulse outputs are occurring

	-- CPU interface
	cpu_addr          	: in  std_logic_vector(11 downto 0);  -- Address input
	cpu_wdata         	: in  std_logic_vector(31 downto 0);  -- Data input
	cpu_wr            	: in  std_logic;                      -- Write enable 
	cpu_sel           	: in  std_logic;                      -- Block select
	cpu_rdata         	: out std_logic_vector(31 downto 0);  -- Data output
	cpu_rdata_dv      	: out std_logic;                      -- Acknowledge output
				   
	-- Pulse train outputs
	dacs_pulse        	: out std_logic_vector(31 downto 0); 	-- Single bit pulse data output
	
	arr_dout_ac       	: out t_arr_dout_ac;
	arr_dout_ac_dv		: out std_logic
);
end entity;

----------------------------------------------------------------
-- Contains block-level registers
-- and uses multiple copies of a single channel pulse generator 
----------------------------------------------------------------
architecture rtl of qlaser_dacs_pulse is

-- Block-level registers
-- CPU_ADDR(11) = '1' selects local regs
-- CPU_ADDR(11) = '0' selects the channel specified in reg_ctrl(3 :0)
--               Then CPU_ADDR(10:1) selects RAM word address    (1024 address MAX)
--					  CPU_ADDR(0) selects MSB or LSB of 40-bit RAM word (time or amplitude)
signal reg_ctrl         : std_logic_vector( 8 downto 0);    -- bits[4:0] reserved to select one of 32 channels to load RAM
                                                            -- bit 8 rising edge generates an internal trigger to start 
signal reg_status       : std_logic_vector(31 downto 0);
signal reg_runtime      : std_logic_vector(23 downto 0);
signal reg_enable       : std_logic_vector(31 downto 0);
signal reg_rdata        : std_logic_vector(31 downto 0);
signal reg_rdata_dv     : std_logic;

signal cnt_time         : std_logic_vector(23 downto 0);

alias  reg_ctrl_trigger : std_logic is reg_ctrl(8);
signal trigger_comb     : std_logic;
signal trigger_d1       : std_logic;

signal busy_i           : std_logic;

type  t_state_ac is (S_IDLE, S_RUN, S_DONE);
signal state_ac         : t_state_ac;

signal cpu_ch_sels     	: std_logic_vector(31 downto 0);
signal cpu_ch_addr		: std_logic_vector(10 downto 0);	-- RAM address in channel
signal cpu_ch_wdata		: std_logic_vector(31 downto 0);
signal cpu_ch_wr		: std_logic;
--signal cpu_ch_rdata_dv	: std_logic;
signal cpu_ch_rdata		: t_arr_dout_ac;
signal cpu_ch_rdata_dv	: std_logic_vector(15 downto 0);

begin
-- empty for now as waiting for the stand-alone to work
end rtl;
