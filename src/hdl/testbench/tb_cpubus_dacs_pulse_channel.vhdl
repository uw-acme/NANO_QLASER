-----------------------------------------------------------
-- File : tb_cpubus_dacs_pulse_channel.vhd
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

use     work.std_iopak.all;


entity tb_cpubus_dacs_pulse_channel is
end    tb_cpubus_dacs_pulse_channel;

architecture behave of tb_cpubus_dacs_pulse_channel is 

signal clk                          : std_logic;
signal reset                        : std_logic;
signal enable                       : std_logic;  
signal start                        : std_logic;  
signal cnt_time                     : std_logic_vector(23 downto 0);  
signal busy                         : std_logic; 
signal err_wave                     : std_logic; 

signal cpu_wr                       : std_logic;
signal cpu_sel                      : std_logic;
signal cpu_addr                     : std_logic_vector(15 downto 0);
signal cpu_wdata                    : std_logic_vector(31 downto 0);
signal cpu_rdata                    : std_logic_vector(31 downto 0);
signal cpu_rdata_dv                 : std_logic; 

-- AXI-stream output interface
signal axis_tready                  : std_logic := '1'; -- Always ready
signal axis_tdata                   : std_logic_vector(15 downto 0);
signal axis_tvalid                  : std_logic;
signal axis_tlast                   : std_logic;

-- Halts simulation by stopping clock when set true
signal sim_done                     : boolean   := false;

-- Crystal clock freq expressed in MHz
constant CLK_FREQ_MHZ               : real      := 100.0; 
-- Clock period
constant CLK_PER                    : time      := integer(1.0E+6/(CLK_FREQ_MHZ)) * 1 ps;

-- Block registers
constant ADR_MISC_VERSION           : integer   := 0;    	-- 
constant ADR_RAM_PULSE              : integer   := 0;    	-- 
constant ADR_RAM_WAVE               : integer   := 2048; 	-- bit 11 of addr selects RAM 


-------------------------------------------------------------
-- CPU write procedure. Address in decimal. Data in hex
-------------------------------------------------------------
procedure cpu_write( 
    signal clk          : in  std_logic;
    constant a          : in  integer;
    constant d          : in  std_logic_vector(31 downto 0);
    signal cpu_sel      : out std_logic;
    signal cpu_wr       : out std_logic;
    signal cpu_addr     : out std_logic_vector(15 downto 0);
    signal cpu_wdata    : out std_logic_vector(31 downto 0)
) is
begin
    wait until clk'event and clk='0';
    cpu_sel     <= '1';
    cpu_wr      <= '1';
    cpu_addr    <= std_logic_vector(to_unsigned(a, 16));
    cpu_wdata   <= std_logic_vector(d);
    wait until clk'event and clk='0';
    cpu_sel     <= '0';
    cpu_wr      <= '0';
    cpu_addr    <= (others=>'0');
    cpu_wdata   <= (others=>'0');
    wait until clk'event and clk='0';
end;


-------------------------------------------------------------
-- CPU write procedure. Address and Data in decimal
-------------------------------------------------------------
procedure cpu_write( 
    signal clk          : in  std_logic;
    constant a          : in  integer;
    constant d          : in  integer;
    signal cpu_sel      : out std_logic;
    signal cpu_wr       : out std_logic;
    signal cpu_addr     : out std_logic_vector(15 downto 0);
    signal cpu_wdata    : out std_logic_vector(31 downto 0)
) is
begin
    cpu_write(clk, a , std_logic_vector(to_unsigned(d,32)), cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
end;


-------------------------------------------------------------
-- CPU write pulse definition RAM
-- Use four 32-bit writes
-------------------------------------------------------------
-- cpu_write_pdef(clk, entry, pulsetime, wavestartaddr, wavesteps, wavetopwidth, gainfac, timefac, sel,wr, addr, wdata)                  
-------------------------------------------------------------
-- Usage : cpu_write_pulsedef(clk, 123, 0, 1024, 512, 1.0, 1.0);
-------------------------------------------------------------
procedure cpu_write_pdef( 
    signal clk              : in  std_logic;

    constant num_entry      : in  integer;

    -- Parameters
    constant pulsetime      : in  integer;  -- Pulse start time in clock cycles
    constant wavestartaddr  : in  integer;  -- Start address in waveform RAM
    constant wavesteps      : in  integer;  -- Number of steps in waveform rise and fall
    constant wavetopwidth   : in  integer;  -- Number of clock cycles in waveform top between end of rise and start of fall
    constant gainfactor     : in  real;     -- Fixed point gain value. Max value 1.0 is hex X"8000". Gain 0.5 is therefore X"4000" 
    constant timefactor     : in  real;     -- Fixed point time scale factor

    signal cpu_sel          : out std_logic;
    signal cpu_wr           : out std_logic;
    signal cpu_addr         : out std_logic_vector(15 downto 0);
    signal cpu_wdata        : out std_logic_vector(31 downto 0)
) is
-- Vectors for converted values
variable slv_pulsetime      : std_logic_vector(23 downto 0);  -- For 24-bit pulse time
variable slv_wavestartaddr  : std_logic_vector(11 downto 0);  -- For 12-bit address i.e. 4K point waveform RAM 
variable slv_wavesteps      : std_logic_vector( 9 downto 0);  -- For 10-bit number of steps i.e. 0 = 1 step, X"3FF" = 1024 points 
variable slv_gainfactor     : std_logic_vector(15 downto 0);  -- For 16-bit fixed point gain 
variable slv_timefactor     : std_logic_vector(15 downto 0);  -- For 16-bit fixed point timestep
variable slv_wavetopwidth   : std_logic_vector(16 downto 0);  -- For 17-bit number of clock cycles in top of waveform

constant C_ZEROS            : std_logic_vector(31 downto 0) := (others=>'0');

constant ADR_RAM_PDEF       : integer   := 0;    	-- 
constant ADR_RAM_WAVE       : integer   := 2048; 	-- bit 11 of addr selects RAM 

-- Define the number of fractional bits
-- Gain factor is a multiplier for the waveform RAM output value.
-- It has a maximum of 1.0, an unsigned, fixed point, represented by X"8000" [1.15]
-- A gain of 0.5 would be stored as X"4000". 
constant BIT_FRAC_GAIN      : integer := 15;  -- TODO: this should be defined in qlaser_pkg

-- Time factor is used to control the step increments for the waveform table address.
-- A maximum of 255.0, and a min of 1/256. So an unsigned, fixed point,  [8.8]
-- A factor of 1.0 (default) is stored as X"0100"
-- A factor of 2.0           is stored as X"0200" Skip alternate wave values
-- A factor of 0.5           is stored as X"0080" Use every wave value twice
constant BIT_FRAC_TIME      : integer :=  8;  -- TODO: this should be defined in qlaser_pkg

begin

    -- Convert each field into its std_logic_vector equivalent
    slv_pulsetime     := std_logic_vector(to_unsigned(pulsetime, 24));
    slv_timefactor    := std_logic_vector(to_unsigned(integer(timefactor * real(2**BIT_FRAC_TIME)), 16));  -- Convert real to std_logic_vector keeping the fractional part
    slv_gainfactor    := std_logic_vector(to_unsigned(integer(gainfactor * real(2**BIT_FRAC_GAIN)), 16));  -- Convert real to std_logic_vector keeping the fractional part
    slv_wavestartaddr := std_logic_vector(to_unsigned(wavestartaddr, 12));
    slv_wavesteps     := std_logic_vector(to_unsigned(wavesteps, 10));
    slv_wavetopwidth  := std_logic_vector(to_unsigned(wavetopwidth, 17));

    -- Each entry is made up of four 32-bit RAM locations.
    -- Parameters are aligned to 8-bit boundaries
    cpu_write(clk, ADR_RAM_PDEF+(4*num_entry  ) , C_ZEROS(31 downto 24) & slv_pulsetime,       cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
    cpu_write(clk, ADR_RAM_PDEF+(4*num_entry+1) , C_ZEROS(31 downto 26) & slv_wavesteps
                                                & C_ZEROS(15 downto 12) & slv_wavestartaddr,   cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
    cpu_write(clk, ADR_RAM_PDEF+(4*num_entry+2) , slv_timefactor        & slv_gainfactor,      cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
    cpu_write(clk, ADR_RAM_PDEF+(4*num_entry+3) , C_ZEROS(31 downto 17) & slv_wavetopwidth,    cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
	
end;


-------------------------------------------------------------
-- CPU read procedure
-------------------------------------------------------------
procedure cpu_read( 
    signal clk          : in  std_logic;
    constant a          : in  integer;
    constant exp_d      : in  std_logic_vector(31 downto 0);
    signal cpu_sel      : out std_logic;
    signal cpu_wr       : out std_logic;
    signal cpu_addr     : out std_logic_vector(15 downto 0);
    signal cpu_wdata    : out std_logic_vector(31 downto 0);
    signal cpu_rdata    : in  std_logic_vector(31 downto 0);
    signal cpu_rdata_dv : in  std_logic
) is
variable v_bdone    : boolean := false; 
variable str_out    : string(1 to 256);
begin
    wait until clk'event and clk='0';
    cpu_sel     <= '1';
    cpu_wr      <= '0';
    cpu_addr    <= std_logic_vector(to_unsigned(a, 16));
    cpu_wdata   <= (others=>'0');
    while (v_bdone = false) loop
        wait until clk'event and clk='0';
        cpu_sel     <= '1';
        if (cpu_rdata_dv = '1') then
            if (cpu_rdata /= exp_d) then
                fprint(str_out, "Read  exp: 0x%s  actual: 0x%s\n", to_string(to_bitvector(exp_d),"%08X"), to_string(to_bitvector(cpu_rdata),"%08X"));
                report str_out severity error;
            end if;
            v_bdone := true; 
            cpu_sel     <= '0';
            cpu_addr    <= (others=>'0');
        end if;
    end loop;
    wait until clk'event and clk='0';
    wait until clk'event and clk='0';
end;


-------------------------------------------------------------
-- CPU read procedure
-------------------------------------------------------------
procedure cpu_read( 
    signal clk          : in  std_logic;
    constant a          : in  std_logic_vector(15 downto 0);
    constant exp_d      : in  std_logic_vector(31 downto 0);
    signal cpu_sel      : out std_logic;
    signal cpu_wr       : out std_logic;
    signal cpu_addr     : out std_logic_vector(15 downto 0);
    signal cpu_wdata    : out std_logic_vector(31 downto 0);
    signal cpu_rdata    : in  std_logic_vector(31 downto 0);
    signal cpu_rdata_dv : in  std_logic
) is
variable v_bdone    : boolean := false; 
variable str_out    : string(1 to 256);
begin
    wait until clk'event and clk='0';
    cpu_sel     <= '1';
    cpu_wr      <= '0';
    cpu_addr    <= a(15 downto 0);
    cpu_wdata   <= (others=>'0');
    while (v_bdone = false) loop
        wait until clk'event and clk='0';
        cpu_sel     <= '1';
        if (cpu_rdata_dv = '1') then
            if (cpu_rdata /= exp_d) then
                fprint(str_out, "Read  exp: 0x%s  actual: 0x%s\n", to_string(to_bitvector(exp_d),"%08X"), to_string(to_bitvector(cpu_rdata),"%08X"));
                report str_out severity error;
            end if;
            v_bdone := true; 
            cpu_sel     <= '0';
            cpu_addr    <= (others=>'0');
        end if;
    end loop;
    wait until clk'event and clk='0';
    wait until clk'event and clk='0';
end;


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

    -------------------------------------------------------------
	-- Unit Under Test
    -------------------------------------------------------------
	u_dac_pulse : entity work.qlaser_dacs_pulse_channel(wave_4K_pdef_1Kx32)
	port map (
        clk             => clk                      , -- in  std_logic;
        reset           => reset                    , -- in  std_logic;

        enable          => enable                   , -- out std_logic;  
        start           => start                    , -- out std_logic; 
        cnt_time        => cnt_time                 , -- out std_logic_vector(23 downto 0);    -- Set to '1' while SPI interface is busy

        busy            => busy                     , -- out std_logic;                        -- Set to '1' while SPI interface is busy
    	err_wave        => err_wave                 , -- out std_logic;                        -- Error signal. Waveform RAM read-past-end

        -- CPU interface
        cpu_wr          => cpu_wr                   , -- in  std_logic;
        cpu_sel         => cpu_sel                  , -- in  std_logic;
        cpu_addr        => cpu_addr(11 downto 0)    , -- in  std_logic_vector(11 downto 0);
        cpu_wdata       => cpu_wdata                , -- in  std_logic_vector(31 downto 0);

        cpu_rdata       => cpu_rdata                , -- out std_logic_vector(31 downto 0);
        cpu_rdata_dv    => cpu_rdata_dv             , -- out std_logic; 

                   
        -- AXI-Stream interface
        axis_tready     => axis_tready              , -- in  std_logic;          -- Clock (50 MHz max)
        axis_tdata      => axis_tdata               , -- out std_logic_vector(15 downto 0);
        axis_tvalid     => axis_tvalid              , -- out std_logic;          -- Master out, Slave in. (Data to DAC)
        axis_tlast      => axis_tlast                 -- out std_logic;          -- Active low chip select (sync_n)
    );
	

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
    variable v_ndata32  : integer := 0;
    variable v_ndata16 : integer := 0;
    begin
        -- Reset 
        reset       <= '1';
        enable      <= '0';
        start       <= '0';
        cnt_time    <= (others=>'0');

        cpu_sel     <= '0';
        cpu_wr      <= '0';
		cpu_wdata   <= (others=>'0');
		cpu_addr  	<= (others=>'0');

        cpu_print_msg("Simulation start");
        clk_delay(5);
        reset       <= '0';

        clk_delay(5);
        enable      <= '1';
       

        clk_delay(5);

        ----------------------------------------------------------------
        -- Load pulse RAM using parameterized function
        -- cpu_write_pdef(clk, entry, pulsetime, wavestartaddr, wavesteps, wavetopwidth, gainfac, timefac, sel,wr, addr, wdata)                  
        ----------------------------------------------------------------
        cpu_write_pdef(clk, 0, 123,   0, 127, 15, 1.0, 1.0, cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        cpu_write_pdef(clk, 1, 555, 128, 256, 15, 0.5, 2.0, cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(5);
		

        ----------------------------------------------------------------
        -- Load pulse RAM with a series of pulse start times
        ----------------------------------------------------------------
        v_ndata32 := 128; -- Time for first pulse
        cpu_print_msg("Load pulse RAM");
        for NADDR in 0 to 1023 loop
            cpu_write(clk, ADR_RAM_PULSE + NADDR  , v_ndata32 + (NADDR*(1024+32)), cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        end loop;
        --cpu_write(clk, ADR_RAM_PULSE + 8  , X"33335555", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        cpu_print_msg("Pulse RAM loaded");
        clk_delay(10);

        ----------------------------------------------------------------
        -- Load waveform RAM with a simple ramp
        -- Write two 16-bit values with each write
        ----------------------------------------------------------------
        cpu_print_msg("Load waveform RAM");
        v_ndata16 := 1; -- first waveform value
        for NADDR in 0 to 2047 loop --2048 loop
            v_ndata32 := (((v_ndata16+1) * 65536) + v_ndata16);
            cpu_write(clk, (ADR_RAM_WAVE + NADDR)  , v_ndata32, cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
            v_ndata16 := v_ndata16 + 2;
        end loop;
        --cpu_write(clk, (ADR_RAM_WAVE + 16)  , X"01234567", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        cpu_print_msg("Waveform RAM loaded");
        clk_delay(10);


        ----------------------------------------------------------------
        -- Read back Pulse RAM. 
        ----------------------------------------------------------------
        v_ndata32 := 128; -- Time for first pulse
        for NADDR in 0 to 1023 loop
            cpu_read (clk, ADR_RAM_PULSE + NADDR  , std_logic_vector(to_unsigned(v_ndata32 + (NADDR*(1024+32)),32 )), cpu_sel, cpu_wr, cpu_addr, cpu_wdata, cpu_rdata, cpu_rdata_dv);
        end loop;
        clk_delay(10);
        --cpu_read (clk, ADR_RAM_PULSE + 8  , X"33335555", cpu_sel, cpu_wr, cpu_addr, cpu_wdata, cpu_rdata, cpu_rdata_dv);

        ----------------------------------------------------------------
        -- Read back Waveform RAM
        ----------------------------------------------------------------
        v_ndata16 := 1; -- first waveform value
        for NADDR in 0 to 2047 loop
            v_ndata32 := (((v_ndata16+1) * 65536) + v_ndata16);
            cpu_read (clk, ADR_RAM_WAVE + NADDR  , std_logic_vector(to_unsigned(v_ndata32, 32)) , cpu_sel, cpu_wr, cpu_addr, cpu_wdata, cpu_rdata, cpu_rdata_dv);
            v_ndata16 := v_ndata16 + 2;
        end loop;
        --cpu_read (clk, ADR_RAM_WAVE + 16  , X"01234567" , cpu_sel, cpu_wr, cpu_addr, cpu_wdata, cpu_rdata, cpu_rdata_dv);
        
        -- Done reg write/read check
        cpu_print_msg("RAM readback completed");
        clk_delay(10);
                                               
        sim_done    <= true;
        wait;

        ----------------------------------------------------------------
        -- Start the pulse outputs
        ----------------------------------------------------------------
        clk_delay(5);
        start      <= '1';
        clk_delay(5);
        start      <= '0';

        -- Wait for cnt_time to reach last pulse start time + waveform size
        for NCNT in 1 to (128 + 16*(1024+32)+ 1024) loop
            cnt_time    <= std_logic_vector(unsigned(cnt_time) + 1); 
            clk_delay(0);
        end loop;
        
        wait for 10 us;
        
        cpu_print_msg("Simulation done");
        clk_delay(5);
		
        sim_done    <= true;
        wait;

    end process;

end behave;

