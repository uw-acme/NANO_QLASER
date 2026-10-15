-------------------------------------------------------------------------------
-- File       : qlaser_tb_pkg.vhdl
-- Bidir interface between serial port and CPU bus.
-- Contains UART
-------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     std.textio.all; 
use     work.std_iopak.all;

use     work.qlaser_pkg.all;


package qlaser_tb_pkg is

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
);

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
);


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

package body qlaser_tb_pkg is

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
    -- CPU write 
    -- Use 96 bit data to make three 32-bit writes
    -------------------------------------------------------------
--    procedure cpu_write96( 
--        signal clk          : in  std_logic;
--        constant a          : in  integer;
--        constant d          : in  std_logic_vector(95 downto 0);
--        signal cpu_sel      : out std_logic;
--        signal cpu_wr       : out std_logic;
--        signal cpu_addr     : out std_logic_vector(15 downto 0);
--        signal cpu_wdata    : out std_logic_vector(31 downto 0)
--    ) is
--    begin
--        cpu_write(clk, a   , d(31 downto  0), cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
--        cpu_write(clk, a+1 , d(63 downto 32), cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
--        cpu_write(clk, a+2 , d(95 downto 64), cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
--    end;


    -------------------------------------------------------------
    -- CPU write pulse definition RAM
    -- Use 96 bit data to make three 32-bit writes
    -- Usage : cpu_write_pulsedef(clk, 0, 0, 1024, 512, 1.0, 1.0);
    -------------------------------------------------------------
--    procedure cpu_write_pulsedef( 
--        signal clk              : in  std_logic;
--
--        constant num_entry      : in  integer;
--
--        -- Partial ? list of parameters
--        constant wavestartaddr  : in  integer;  -- Start address in waveform RAM
--        constant wavesteps      : in  integer;  -- Number of steps in waveform rise and fall
--        constant wavetopwidth   : in  integer;  -- Number of clock cycles in waveform top between end of rise and start of fall
--        constant gainfactor     : in  real;     -- Fixed point gain value. Max value 1.0 is hex X"8000". Gain 0.5 is therefore X"4000" 
--        constant timefactor     : in  real;     -- Fixed point time scale factor
--
--        signal cpu_sel          : out std_logic;
--        signal cpu_wr           : out std_logic;
--        signal cpu_addr         : out std_logic_vector(15 downto 0);
--        signal cpu_wdata        : out std_logic_vector(31 downto 0)
--    ) is
--    -- Vectors for converted values
--    variable slv_wavestartaddr  : std_logic_vector( 9 downto 0);  -- For 10-bit address i.e. 1024 point waveform RAM 
--    variable slv_wavesteps      : std_logic_vector( 9 downto 0);  -- For 10-bit number of steps i.e. 0 = 1 step, X"3FF" = 1024 points 
--    variable slv_gainfactor     : std_logic_vector(15 downto 0);  -- For 16-bit fixed point gain 
--    variable slv_timefactor     : std_logic_vector(15 downto 0);  -- For 16-bit fixed point timestep
--
--    variable slv_entry_data     : std_logic_vector(95 downto 0);  -- Vector for entire memory entry
--
--    constant ADR_PULSE_DEF      : integer :=  to_integer(unsigned(X"?????"));    -- Use address of pulse definition RAM from qlaser_pkg
--    begin
--
--        -- Convert each field into its std_logic_vector equivalent
--        slv_wavesteps   <= std_logic_vector(to_unsigned(wavestartaddr, 10);
--        -- etc, etc
--        slv_gainfactor  <= std_logic_vector(to_unsigned((wavestartaddr * 32*1024), 16));    -- Convert real in range 0-1.0 to unsigned X"0000" to X"8000"
--        --etc, etc.
--
--        -- Build full entry out of component fields. Final length should be 96 bits.
--        slv_entry_data  <= slv_timefactor & slv_gainfactor & "000000" & slv_wavesteps & "000000" & slv_wavestartaddr;   -- This is not correct 
--
--        -- Write 96-bit entry in 3 writes.  (Address is an integer)
--        cpu_write(clk, ADR_PULSE_DEF+(4*num_entry)   , slv_entry_data(31 downto  0), cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
--        cpu_write(clk, ADR_PULSE_DEF+(4*num_entry)+1 , slv_entry_data(63 downto 32), cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
--        cpu_write(clk, ADR_PULSE_DEF+(4*num_entry)+2 , slv_entry_data(95 downto 64), cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
--    end;


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


end qlaser_tb_pkg;
