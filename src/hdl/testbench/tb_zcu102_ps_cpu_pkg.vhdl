-------------------------------------------------------------------------------
-- File       : tb_zcu102_ps_cpu_pkg.vhdl
-- PS CPU bus.	
--
-- *** HAS 'CPU_RD' not CPU_SEL ***
-------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     std.textio.all; 
use     work.std_iopak.all;

use     work.qlaser_pkg.all;


package tb_zcu102_ps_cpu_pkg is
	
constant C_WIDTH_PS_ADDR_BUS	: integer := 18;

-------------------------------------------------------------
-- CPU write procedure. Address in hex. Data in hex
-------------------------------------------------------------
procedure cpu_write( 
    signal clk          : in  std_logic;
    constant a          : in  std_logic_vector(C_WIDTH_PS_ADDR_BUS-1 downto 0);
    constant d          : in  std_logic_vector(31 downto 0);
    signal cpu_rd       : out std_logic;
    signal cpu_wr       : out std_logic;
    signal cpu_addr     : out std_logic_vector(C_WIDTH_PS_ADDR_BUS-1 downto 0);
    signal cpu_wdata    : out std_logic_vector(31 downto 0)
);

-------------------------------------------------------------
-- CPU write procedure. Address in decimal. Data in hex
-------------------------------------------------------------
procedure cpu_write( 
    signal clk          : in  std_logic;
    constant a          : in  integer;
    constant d          : in  std_logic_vector(31 downto 0);
    signal cpu_rd       : out std_logic;
    signal cpu_wr       : out std_logic;
    signal cpu_addr     : out std_logic_vector(C_WIDTH_PS_ADDR_BUS-1 downto 0);
    signal cpu_wdata    : out std_logic_vector(31 downto 0)
);

-------------------------------------------------------------
-- CPU write procedure. Address and Data in decimal
-------------------------------------------------------------
procedure cpu_write( 
    signal clk          : in  std_logic;
    constant a          : in  integer;
    constant d          : in  integer;
    signal cpu_rd       : out std_logic;
    signal cpu_wr       : out std_logic;
    signal cpu_addr     : out std_logic_vector(C_WIDTH_PS_ADDR_BUS-1 downto 0);
    signal cpu_wdata    : out std_logic_vector(31 downto 0)
);

-------------------------------------------------------------
-- CPU write for PDEF RAM
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

    signal cpu_rd           : out std_logic;
    signal cpu_wr           : out std_logic;
    signal cpu_addr         : out std_logic_vector(C_WIDTH_PS_ADDR_BUS-1 downto 0);
    signal cpu_wdata        : out std_logic_vector(31 downto 0)
);


-------------------------------------------------------------
-- CPU read procedure
-------------------------------------------------------------
procedure cpu_read( 
    signal clk          : in  std_logic;
    constant a          : in  integer;
    constant exp_d      : in  std_logic_vector(31 downto 0);
    signal cpu_rd       : out std_logic;
    signal cpu_wr       : out std_logic;
    signal cpu_addr     : out std_logic_vector(C_WIDTH_PS_ADDR_BUS-1 downto 0);
    signal cpu_wdata    : out std_logic_vector(31 downto 0);
    signal cpu_rdata    : in  std_logic_vector(31 downto 0);
    signal cpu_rdata_dv : in  std_logic
);


-------------------------------------------------------------
-- Delay
-------------------------------------------------------------
procedure clk_delay(
    constant nclks      : in  integer;
    signal clk          : in  std_logic
);


----------------------------------------------------------------
-- Print a string with no time or instance path.
----------------------------------------------------------------
procedure cpu_print_msg(
    constant msg        : in    string
);

end package;

package body tb_zcu102_ps_cpu_pkg is

    -------------------------------------------------------------
    -- CPU write procedure. Address in hex. Data in hex
    -------------------------------------------------------------
    procedure cpu_write( 
        signal clk          : in  std_logic;
        constant a          : in  std_logic_vector(C_WIDTH_PS_ADDR_BUS-1 downto 0);
        constant d          : in  std_logic_vector(31 downto 0);
        signal cpu_rd       : out std_logic;
        signal cpu_wr       : out std_logic;
        signal cpu_addr     : out std_logic_vector(C_WIDTH_PS_ADDR_BUS-1 downto 0);
        signal cpu_wdata    : out std_logic_vector(31 downto 0)
    ) is
    begin
        wait until clk'event and clk='0';
        cpu_rd      <= '0';
        cpu_wr      <= '1';
        cpu_addr    <= a;
        cpu_wdata   <= d;
        wait until clk'event and clk='0';
        cpu_rd      <= '0';
        cpu_wr      <= '0';
        cpu_addr    <= (others=>'0');
        cpu_wdata   <= (others=>'0');
        wait until clk'event and clk='0';
    end;


    -------------------------------------------------------------
    -- CPU write procedure. Address in decimal. Data in hex
    -------------------------------------------------------------
    procedure cpu_write( 
        signal clk          : in  std_logic;
        constant a          : in  integer;
        constant d          : in  std_logic_vector(31 downto 0);
        signal cpu_rd       : out std_logic;
        signal cpu_wr       : out std_logic;
        signal cpu_addr     : out std_logic_vector(C_WIDTH_PS_ADDR_BUS-1 downto 0);
        signal cpu_wdata    : out std_logic_vector(31 downto 0)
    ) is
    begin
        wait until clk'event and clk='0';
        cpu_rd      <= '0';
        cpu_wr      <= '1';
        cpu_addr    <= std_logic_vector(to_unsigned(a, C_WIDTH_PS_ADDR_BUS));
        cpu_wdata   <= d;
        wait until clk'event and clk='0';
        cpu_rd      <= '0';
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
        signal cpu_rd       : out std_logic;
        signal cpu_wr       : out std_logic;
        signal cpu_addr     : out std_logic_vector(C_WIDTH_PS_ADDR_BUS-1 downto 0);
        signal cpu_wdata    : out std_logic_vector(31 downto 0)
    ) is
    begin
        cpu_write(clk, a , std_logic_vector(to_unsigned(d,32)), cpu_rd, cpu_wr, cpu_addr, cpu_wdata);
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

        signal cpu_rd           : out std_logic;
        signal cpu_wr           : out std_logic;
        signal cpu_addr         : out std_logic_vector(C_WIDTH_PS_ADDR_BUS-1 downto 0);
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
        cpu_write(clk, ADR_RAM_PDEF+(4*num_entry  ) , C_ZEROS(31 downto 24) & slv_pulsetime,       cpu_rd, cpu_wr, cpu_addr, cpu_wdata);
        cpu_write(clk, ADR_RAM_PDEF+(4*num_entry+1) , C_ZEROS(31 downto 26) & slv_wavesteps
                                                    & C_ZEROS(15 downto 12) & slv_wavestartaddr,   cpu_rd, cpu_wr, cpu_addr, cpu_wdata);
        cpu_write(clk, ADR_RAM_PDEF+(4*num_entry+2) , slv_timefactor        & slv_gainfactor,      cpu_rd, cpu_wr, cpu_addr, cpu_wdata);
        cpu_write(clk, ADR_RAM_PDEF+(4*num_entry+3) , C_ZEROS(31 downto 17) & slv_wavetopwidth,    cpu_rd, cpu_wr, cpu_addr, cpu_wdata);
    end;


    -------------------------------------------------------------
    -- CPU read procedure
    -------------------------------------------------------------
    procedure cpu_read( 
        signal clk          : in  std_logic;
        constant a          : in  integer;
        constant exp_d      : in  std_logic_vector(31 downto 0);
        signal cpu_rd       : out std_logic;
        signal cpu_wr       : out std_logic;
        signal cpu_addr     : out std_logic_vector(C_WIDTH_PS_ADDR_BUS-1 downto 0);
        signal cpu_wdata    : out std_logic_vector(31 downto 0);
        signal cpu_rdata    : in  std_logic_vector(31 downto 0);
        signal cpu_rdata_dv : in  std_logic
    ) is
    variable v_bdone    : boolean := false; 
    variable str_out    : string(1 to 256);
    begin
        wait until clk'event and clk='0';
        cpu_rd      <= '1';
        cpu_wr      <= '0';
        cpu_addr    <= std_logic_vector(to_unsigned(a, 18));
        cpu_wdata   <= (others=>'0');
        while (v_bdone = false) loop
            wait until clk'event and clk='0';
            cpu_rd  	<= '1';
            if (cpu_rdata_dv = '1') then
                if (cpu_rdata /= exp_d) then
                    fprint(str_out, "Read  exp: 0x%s  actual: 0x%s\n", to_string(to_bitvector(exp_d),"%08X"), to_string(to_bitvector(cpu_rdata),"%08X"));
                    report str_out severity error;
                end if;
                v_bdone := true; 
                cpu_rd      <= '0';
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
        constant nclks  : in  integer;
        signal clk      : in  std_logic
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


end tb_zcu102_ps_cpu_pkg;
