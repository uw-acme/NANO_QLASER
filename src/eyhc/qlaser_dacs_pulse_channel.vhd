---------------------------------------------------------------
--  File         : qlaser_dacs_pulse_channel.vhd
--  Description  : Single channel of pulse output
----------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.qlaser_pkg.all;

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
                               
        t_ready			  : in std_logic;                         -- axi_stream ready
		dout              : out std_logic_vector(15 downto 0);    -- output data
        dout_dv           : out std_logic                         -- dout valid (new output)
);
end entity;


----------------------------------------------------------------
----------------------------------------------------------------
architecture rtl of qlaser_dacs_pulse_channel is

-- CPU RAM port
signal ram_addra        : std_logic_vector( 3 downto 0);	-- 32 entry RAM
signal ram_dina         : std_logic_vector(23 downto 0);
signal ram_douta        : std_logic_vector(23 downto 0);
signal ram_we           : std_logic;

-- Sequencer RAM port
signal ram_addrb        : std_logic_vector( 3 downto 0);
signal ram_doutb        : std_logic_vector(23 downto 0);

signal cpu_rdata_dv_e1	: std_logic;
signal cpu_rdata_msb	: std_logic;

signal ram_time         : std_logic_vector(23 downto 0);
signal ram_amplitude    : std_logic_vector(15 downto 0);

-- Waveform RAM port
signal ram_waveform_ena		: std_logic;
-- signal ram_waveform_wea		: std_logic;
signal ram_waveform_addra	: std_logic_vector(8 downto 0);
-- signal ram_waveform_dina	: std_logic_vector(31 downto 0);
signal ram_waveform_douta	: std_logic_vector(31 downto 0);

signal ram_waveform_enb		: std_logic;
signal ram_waveform_web		: std_logic_vector(0 downto 0);
signal ram_waveform_addrb	: std_logic_vector(9 downto 0);
signal ram_waveform_dinb	: std_logic_vector(15 downto 0);
signal ram_waveform_doutb	: std_logic_vector(15 downto 0);

-- FIFO
signal fifo_wr_en			: std_logic;
signal fifo_full			: std_logic;
signal fifo_empty			: std_logic;
signal fifo_wr_rst_busy		: std_logic;
signal fifo_rd_rst_busy		: std_logic;

begin

	----------------------------------------------------------------
	-- RAM currently has 32 40-bit entries.
	-- Port A is for CPU read/write.
	-- Port B is for pulse data.
	-- Each entry LSB24 is a time and the MSB16 are an amplitude.
	-- For JESD output the RAM will be increased to 1024 entries
	----------------------------------------------------------------
	-- Distributed RAM
    u_ram_pulse : entity work.bram_pulseposition
    port map(
        clk                => clk,			-- input std_logic
        a                  => ram_addra,	-- input slv[3:0]
        d                  => ram_dina,		-- input slv[23 downto 0)
        we                 => ram_we,
        spo                => ram_douta,	-- output slv(23 downto 0)
         
		dpra               => ram_addrb,	-- input slv[3:0]
        dpo                => ram_doutb		-- output slv(23 downto 0)
    );

	u_ram_waveform : entity work.bram_waveform
	port map (
		-- Port A internal use, read only
		clka => clk,					-- input std_logic
		ena => ram_waveform_ena,		-- input std_logic
		wea => (others => '0'),			-- input slv(0 downto 0)
		addra => ram_waveform_addra,	-- input slv(8 downto 0)
		dina => (others => '0'),		-- input slv(31 downto 0)
		douta => ram_waveform_douta,	-- output slv(31 downto 0)
		-- Port B CPU use
		clkb => clk,					-- input std_logic
		enb => ram_waveform_enb,		-- input std_logic
		web => ram_waveform_web,		-- input slv(0 downto 0)
		addrb => ram_waveform_addrb,	-- input slv(9 downto 0)
		dinb => ram_waveform_dinb,		-- input slv(15 downto 0)
		doutb => ram_waveform_doutb		-- output slv(15 downto 0)
	);

	u_data_to_stream : entity work.fifo_data_to_stream
	port map (
		clk => clk,  						-- input std_logic
		srst => reset,						-- input std_logic
		din => ram_waveform_douta,			-- input slv(31 downto 0)
		wr_en => fifo_wr_en,				-- input std_logic
		rd_en => t_ready,					-- input std_logic
		dout => dout,						-- output slv(15 downto 0)
		full => fifo_full,					-- output std_logic
		empty => fifo_empty,				-- output std_logic
		wr_rst_busy => fifo_wr_rst_busy,	-- output std_logic
		rd_rst_busy => fifo_rd_rst_busy		-- output std_logic
	);

       
	-- ----------------------------------------------------------------
	-- -- CPU Read/Write RAM
	-- For the new version, MSB1 of cpu_addr is used to select which RAM to read/write, and the rest can be
	-- either 10 bit for zero-extended 4 bits, depends on the RAM to use.
	-- ----------------------------------------------------------------
    -- pr_ram_rw  : process(reset, clk)
    -- begin
    --     if (reset = '1') then
		
    --         ram_addra    	<= (others=>'0');
    --         ram_addrb       <= (others=>'0');  
	-- 		ram_dina        <= (others=>'0');
    --         ram_we          <= '0';
	-- 		cpu_rdata		<= (others=>'0');
	-- 		cpu_rdata_dv	<= '0';
	-- 		cpu_rdata_dv_e1	<= '0';
	-- 		cpu_rdata_msb	<= '0';
			
    --     elsif rising_edge(clk) then
		
	-- 		-- CPU writing RAM
    --         if (cpu_wr = '1') and (cpu_sel = '1') then
			
	-- 				-- Hold new time data if address is even, write 40 bits if odd
	-- 				-- For new version, this is going to be select which RAM to write to
    --                 if (cpu_addr(0) = '0') then
    --                     ram_addra 	<= (others=>'0');
	-- 					ram_dina	<= X"0000" & cpu_wdata(23 downto 0);
    --                     ram_we  	<= '0';
	-- 				else
    --                     ram_addra 	<= cpu_addr(5 downto 1);
	-- 					ram_dina(39 downto 24)	<= cpu_wdata(15 downto 0);
    --                     ram_we  	<= '1';
	-- 				end if;
	-- 				cpu_rdata_dv_e1	<= '0';
	-- 				cpu_rdata_msb	<= '0';
			
	-- 		-- CPU reading RAM
    --         elsif (cpu_wr = '0') and (cpu_sel = '1') then
				
	-- 			ram_addra 		<= cpu_addr(5 downto 1);
	-- 			ram_we   		<= '0';
				
	-- 			cpu_rdata_dv_e1	<= '1';				-- DV for next cycle, when RAM output occurs
	-- 			cpu_rdata_msb   <= cpu_addr(0);		-- Save the lower bit to select bits one cycle later
					
	-- 		else
    --             ram_addra 		<= (others=>'0');
    --             ram_we   		<= '0';
	-- 			cpu_rdata_dv_e1	<= '0';
	-- 			cpu_rdata_msb	<= '0';
			
	-- 		end if;
			
	-- 		-------------------------------------
	-- 		-- Output the delayed RAM data
	-- 		-------------------------------------
	-- 		if (cpu_rdata_dv_e1 = '1') then
					
	-- 			cpu_rdata_dv	<= '1';
				
	-- 			-- for the new version, this is going to decide which RAM to read from
	-- 			if (cpu_rdata_msb = '0') then	-- Output 'time' field
	-- 				cpu_rdata		<= X"00" & ram_douta(23 downto 0);

	-- 			elsif (cpu_rdata_msb = '1') then
	-- 				cpu_rdata		<= X"0000" & ram_douta(39 downto 24);
	-- 			end if;

	-- 		else
    --             cpu_rdata		<= (others=>'0');
	-- 			cpu_rdata_dv	<= '0';
	-- 		end if;
			
    --     end if;
		
    -- end process;


	-- ----------------------------------------------------------------
	-- -- Read time and amplitude from RAM to generate pulses
	-- -- When input cnt_time equals RAM time output then set dout
	-- -- to RAM amplitude output and read next set of RAM data.
	-- ----------------------------------------------------------------
    -- pr_dout  : process(reset, clk)
    -- begin
    --     if (reset = '1') then
		
    --         ram_addrb       <= (others => '0');
    --         dout            <= (others => '0');
	-- 		dout_dv			<= '0';

    --     elsif rising_edge(clk) then

	-- 		dout		<= ram_amplitude;
			
	-- 		if (cnt_time = X"000000") then	-- Not triggered
	-- 			ram_addrb	<= (others=>'0');
	-- 			dout_dv		<= '0';
				
	-- 		elsif (ram_time = cnt_time) then
    --             ram_addrb	<= std_logic_vector(unsigned(ram_addrb) + 1);
	-- 			dout_dv		<= '1';
				
	-- 		else
	-- 			dout_dv		<= '0';
    --         end if;

    --     end if;
		 
    -- end process;
	
	-- For new versions, ram_doutb are differnt RAMs b port outputs, ram_amplitude should go thought a FIFO first from RAM
	ram_time		<= ram_doutb;
	-- ram_amplitude	<= ram_doutb(39 downto 24);

end rtl;
