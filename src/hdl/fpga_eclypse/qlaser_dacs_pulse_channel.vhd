---------------------------------------------------------------
--  File         : qlaser_dacs_pulse_channel.vhd
--  Description  : Single channel of pulse output
----------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.qlaser_pkg.all;
use     work.qlaser_dac_pulse_pkg.all;

entity qlaser_dacs_pulse_channel is
port (
        clk               : in  std_logic; 
        reset             : in  std_logic;

        cnt_time          : in  std_logic_vector(23 downto 0);    -- Time since trigger.

        -- CPU interface
        cpu_addr          : in  std_logic_vector(10 downto 0);    -- Address input
        cpu_wdata         : in  std_logic_vector(31 downto 0);    -- Data input
        cpu_wr            : in  std_logic;                        -- Write enable 
        cpu_sel           : in  std_logic;                        -- Block select
        cpu_rdata         : out std_logic_vector(31 downto 0);    -- Data output
        cpu_rdata_dv      : out std_logic;                        -- Acknowledge output
                               
        dout              : out std_logic_vector(15 downto 0);    -- output data
        dout_dv           : out std_logic                         -- dout valid (new output)
);
end entity;


----------------------------------------------------------------
----------------------------------------------------------------
architecture rtl of qlaser_dacs_pulse_channel is

-- CPU RAM port
signal ram_addra        : std_logic_vector( 4 downto 0);	-- 32 entry RAM
signal ram_dina         : std_logic_vector(39 downto 0);
signal ram_douta        : std_logic_vector(39 downto 0);
signal ram_we           : std_logic;

-- Sequencer RAM port
signal ram_addrb        : std_logic_vector( 4 downto 0);
signal ram_doutb        : std_logic_vector(39 downto 0);

signal cpu_rdata_dv_e1	: std_logic;
signal cpu_rdata_msb	: std_logic;

signal ram_time         : std_logic_vector(23 downto 0);
signal ram_amplitude    : std_logic_vector(15 downto 0);

begin

	----------------------------------------------------------------
	-- RAM currently has 32 40-bit entries.
	-- Port A is for CPU read/write.
	-- Port B is for pulse data.
	-- Each entry LSB24 is a time and the MSB16 are an amplitude.
	-- For JESD output the RAM will be increased to 1024 entries
	----------------------------------------------------------------
	-- Distributed RAM
    u_ram : entity work.dpram_32wx40b
    port map(
        clk                => clk,         -- input std_logic
        a                  => ram_addra,   -- input slv[4:0]
        d                  => ram_dina,     -- input slv[39 downto 0)
        we                 => ram_we,
        spo                => ram_douta,    -- output slv(39 downto 0)
         
		dpra               => ram_addrb,    -- input slv[4:0]
        dpo                => ram_doutb    -- output slv(39 downto 0)
    );

       
	----------------------------------------------------------------
	-- CPU Read/Write RAM
	----------------------------------------------------------------
    pr_ram_rw  : process(reset, clk)
    begin
        if (reset = '1') then
		
            ram_addra    	<= (others=>'0');
            ram_addrb       <= (others=>'0');  
			ram_dina        <= (others=>'0');
            ram_we          <= '0';
			cpu_rdata		<= (others=>'0');
			cpu_rdata_dv	<= '0';
			cpu_rdata_dv_e1	<= '0';
			cpu_rdata_msb	<= '0';
			
        elsif rising_edge(clk) then
		
			-- CPU writing RAM
            if (cpu_wr = '1') and (cpu_sel = '1') then
			
					-- Hold new time data if address is even, write 40 bits if odd
                    if (cpu_addr(0) = '0') then
                        ram_addra 	<= (others=>'0');
						ram_dina	<= X"0000" & cpu_wdata(23 downto 0);
                        ram_we  	<= '0';
					else
                        ram_addra 	<= cpu_addr(5 downto 1);
						ram_dina(39 downto 24)	<= cpu_wdata(15 downto 0);
                        ram_we  	<= '1';
					end if;
					cpu_rdata_dv_e1	<= '0';
					cpu_rdata_msb	<= '0';
			
			-- CPU reading RAM
            elsif (cpu_wr = '0') and (cpu_sel = '1') then
				
				ram_addra 		<= cpu_addr(5 downto 1);
				ram_we   		<= '0';
				
				cpu_rdata_dv_e1	<= '1';				-- DV for next cycle, when RAM output occurs
				cpu_rdata_msb   <= cpu_addr(0);		-- Save the lower bit to select bits one cycle later
					
			else
                ram_addra 		<= (others=>'0');
                ram_we   		<= '0';
				cpu_rdata_dv_e1	<= '0';
				cpu_rdata_msb	<= '0';
			
			end if;
			
			-------------------------------------
			-- Output the delayed RAM data
			-------------------------------------
			if (cpu_rdata_dv_e1 = '1') then
					
				cpu_rdata_dv	<= '1';
						
				if (cpu_rdata_msb = '0') then	-- Output 'time' field
					cpu_rdata		<= X"00" & ram_douta(23 downto 0);

				elsif (cpu_rdata_msb = '1') then
					cpu_rdata		<= X"0000" & ram_douta(39 downto 24);
				end if;

			else
                cpu_rdata		<= (others=>'0');
				cpu_rdata_dv	<= '0';
			end if;
			
        end if;
		
    end process;


	----------------------------------------------------------------
	-- Read time and amplitude from RAM to generate pulses
	-- When input cnt_time equals RAM time output then set dout
	-- to RAM amplitude output and read next set of RAM data.
	----------------------------------------------------------------
    pr_dout  : process(reset, clk)
    begin
        if (reset = '1') then
		
            ram_addrb       <= (others => '0');
            dout            <= (others => '0');
			dout_dv			<= '0';

        elsif rising_edge(clk) then

			dout		<= ram_amplitude;
			
			if (cnt_time = X"000000") then	-- Not triggered
				ram_addrb	<= (others=>'0');
				dout_dv		<= '0';
				
			elsif (ram_time = cnt_time) then
                ram_addrb	<= std_logic_vector(unsigned(ram_addrb) + 1);
				dout_dv		<= '1';
				
			else
				dout_dv		<= '0';
            end if;

        end if;
		 
    end process;
	
	ram_time		<= ram_doutb(23 downto  0);
	ram_amplitude	<= ram_doutb(39 downto 24);

end rtl;
