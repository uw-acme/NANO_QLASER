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
-- Uses multiple copies of a single channel pulse generator 
----------------------------------------------------------------
architecture rtl of qlaser_dacs_pulse is

-- Local registers
-- CPU_ADDR(11) = '0' selects local regs
-- CPU_ADDR(11) = '1' selects the channel specified in reg_ctrl(3 :0)
--               Then CPU_ADDR(10:1) selects RAM word address    (1024 address MAX)
--					  CPU_ADDR(0) selects MSB or LSB of 40-bit RAM word (time or amplitude)
signal reg_ctrl         : std_logic_vector( 3 downto 0);
signal reg_runtime      : std_logic_vector(23 downto 0);
signal reg_enable       : std_logic_vector(31 downto 0);
signal reg_rdata        : std_logic_vector(31 downto 0);
signal reg_rdata_dv     : std_logic;

signal cnt_time         : std_logic_vector(23 downto 0);

signal trigger_d1       : std_logic;

type  t_state_ac is (S_IDLE, S_RUN, S_DONE);
signal state_ac         : t_state_ac;

signal cpu_ch_sels     	: std_logic_vector(31 downto 0);
signal cpu_ch_addr		: std_logic_vector(10 downto 0);	-- RAM address in channel
signal cpu_ch_wdata		: std_logic_vector(31 downto 0);
signal cpu_ch_wr		: std_logic;
signal cpu_ch_rdata_dv	: std_logic;
signal cpu_ch_rdata		: t_arr_dout_ac;
signal cpu_ch_rdata_dv	: std_logic_vector(15 downto 0);

signal busy_i			: std_logic;
signal arr_ch_dout		: t_arr_dout_ac;

begin
  	
	----------------------------------------------------------------
    -- Select channel from address during write.
	----------------------------------------------------------------
    pr_cpu_sels : process(clk)
	variable v_rdata 		: std_logic_vector(31 downto 0);
	variable v_rdata_dv 	: std_logic;
    begin
	    if reset = '1' then
            cpu_ch_sels 	<= (others=>'0');
			cpu_ch_wr		<= '0';
			cpu_ch_addr		<= (others=>'0');

        elsif rising_edge(clk) then
		
			-- Pass CPU signals to the selected channel
			cpu_ch_wr		<= cpu_addr(11) and cpu_wr;
			cpu_ch_addr		<= (others=>'0');

			cpu_ch_sels    	<= (others=>'0');			
			
			if (cpu_addr(11) = '1' and cpu_sel = '1') then
				cpu_ch_sels(to_integer(unsigned(reg_ctrl(4 downto 0)))) <= '1';  -- Max 32 channels
				cpu_ch_addr	<= cpu_addr(10 downto 0);
			else
				cpu_ch_sels <= (others=>'0');
				cpu_ch_addr	<= (others=>'0');
			end if;
			
			
			-- Combine channel RAM readbacks
			v_rdata		<= (others=>'0');
			v_rdata_dv  <= '0';
			for NBIT in 0 to 31
				for NCHAN in 0 to 31
					v_rdata(NBIT)	:= v_rdata(NBIT) or cpu_ch_rdata(NCHAN)(NBIT);
					v_rdata_dv		:= v_rdata_dv    or cpu_ch_rdata_dv(NCHAN);
				end for;
			end for;
			
			-- Combine channel readback with register readback
			cpu_rdata		<= v_rdata    or reg_rdata;
			cpu_rdata_dv	<= v_rdata_dv or reg_rdata_dv;
			
        end if;
		
    end process;
    
	
	----------------------------------------------------------------
    -- Write local registers.
	-- constant ADR_DAC_PULSE_CTRL     : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"800";   -- 3:0 select channel for CPU read/write
	-- constant ADR_DAC_PULSE_STATUS   : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"801";   -- R/O Level status for output of each channel
	-- constant ADR_DAC_PULSE_RUNTIME  : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"802";   -- Max time for pulse train
	-- constant ADR_DAC_PULSE_CH_EN    : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"803";   -- Enable bit for each individual channel
	-- constant ADR_DAC_PULSE_TIMER    : std_logic_vector(15 downto 0) := ADR_BASE_PULSE  & X"804";   -- R/O Current timer value (used by all channels)
	----------------------------------------------------------------
    pr_regs : process(clk)
    begin
	    if (reset = '1') then
            reg_ctrl		<= (others=>'0');
			reg_enable		<= (others=>'1');
			reg_runtime		<= C_MAX_TIME_PULSE;
			reg_rdata		<= (others=>'0');
			reg_rdata_dv	<= '0';

        elsif rising_edge(clk) then
			
			if (cpu_addr(11) = '0' and cpu_wr = '1' and cpu_sel = '1') then
				case cpu_addr(7 downto 0) is
					when X"00" 	=>	reg_ctrl	<= cpu_wdata( 4 downto 0);
				  --when X"01" status
					when X"02" 	=>	reg_enable	<= cpu_wdata(31 downto 0);
					when X"03" 	=>	reg_runtime <= cpu_wdata(23 downto 0);
				  --when X"04" current time
				    when others =>  null;
				end case;
				reg_rdata		<= (others=>'0');
				reg_rdata_dv	<= '0';
				
			elsif (cpu_addr(11) = '0' and cpu_wr = '0' and cpu_sel = '1') then
				case cpu_addr(7 downto 0) is
					when X"00" 	=>	reg_rdata( 4 downto 0)	<= reg_ctrl;
									reg_rdata(31 downto 5)	<= (others=>'0');
				    when X"01"  =>  reg_rdata				<= reg_status;
					when X"02" 	=>	reg_rdata               <= reg_enable;
					when X"03" 	=>	reg_rdata(23 downto 0)  <= reg_runtime;
									reg_rdata(31 downto 24) <= (others=>'0');
				    when others =>  reg_rdata				<= (others=>'0');
				end case;
				reg_rdata_dv	<= '1';
				
			else
				reg_rdata		<= (others=>'0');
				reg_rdata		<= '0';
			end if;
			
        end if;
    end process;
    

	----------------------------------------------------------------
	-- Instantiate one channel for each output
	----------------------------------------------------------------
    g_pulsed_dacs: for i in 0 to 31 generate
	
        u_pulse_channel : entity work.qlaser_dacs_pulse_channel
		port map(
			clk             => clk, 
			reset           => reset,
	
			cnt_time        => cnt_time				,    -- Time in clock cycles since triggering
	
			-- CPU interface
			cpu_addr        => cpu_ch_addr			,    -- Address input
			cpu_wdata       => cpu_ch_wdata			,    -- Data input
			cpu_wr          => cpu_ch_wr			,    -- Write enable 
			cpu_sel         => cpu_ch_sels(i)   	,    -- Block select
			cpu_rdata       => cpu_ch_rdata(i)		,    -- Data output
			cpu_rdata_dv    => cpu_ch_rdata_dv(i)	,    -- Data output valid 
			
			dout            => ch_dout(i)       	,    -- DAC data out (16-bit)
			dout_dv			=> ch_dout_dv(i)             
		);
    end generate;
   
    
	----------------------------------------------------------------
	-- Triggered time counter
	----------------------------------------------------------------
    pr_cnt_time : process(clk, reset)
    begin
        if reset = '1' then
            trigger_d1 	<= '0';
			busy		<= '0';
			cnt_time	<= (others=>'0');
            state_ac 	<= S_IDLE;
			
        elsif rising_edge(clk) then
		
            trigger_d1 	<= trigger;
			
            case state_ac is
			
                when S_IDLE =>
				
                    if (trigger = '1') and (trigger_d1= '0') then

                        state_ac 	<= S_RUN;
						busy	    <= '1';
						cnt_time 	<= std_logic_vector(unsigned(cnt_time) + 1);
						
                    end if;
                    
                when S_RUN =>				

					if (cnt_time = reg_time_max) then
						state_ac	<= S_IDLE;
						cnt_time	<= (others=>'0');
						busy		<= '0';
					else
						cnt_time 	<= std_logic_vector(unsigned(cnt_time) + 1);
                    end if;
                
						
            end case;
        end if;
            
    end process;
    

	----------------------------------------------------------------
	-- MSB of each channel output used as pulse output
	----------------------------------------------------------------
	pr_dacs_pulse : process (arr_ch_dout, reg_enable)
	begin
		for NCHAN in 0 to 31 
			dacs_pulse(NCHAN)	<= arr_ch_dout(NCHAN)(15) and reg_enable(NCHAN);
		end loop;
	end process;
	
end rtl;
