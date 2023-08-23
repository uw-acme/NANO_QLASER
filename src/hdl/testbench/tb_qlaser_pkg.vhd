-------------------------------------------------------------------------------
-- Filename		: 	tb_qlaser_pkg.vhd
-------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     std.textio.all;

library std_developerskit;
use     std_developerskit.std_iopak.all;

use     work.qlaser_pkg.all;

--------------------------------------------------------------------------------
--  
--------------------------------------------------------------------------------
package tb_qlaser_pkg is



----------------------------------------------------------------
-- Delay in clock cycles
----------------------------------------------------------------
procedure cpu_delay(
    signal   clk        : in    std_logic;
    constant length     : in    integer
);


----------------------------------------------------------------
-- Print a string with no time or instance path.
----------------------------------------------------------------
procedure cpu_print_msg(
    constant msg    : in    string
);

-------------------------------------------------------------
-- CPU write procedure (address is an integer)
-------------------------------------------------------------
procedure cpu_write( 
    signal clk          : in  std_logic;
    constant a          : in  integer;
    constant d          : in  std_logic_vector(31 downto 0);
    signal cpu_rd       : out std_logic;
    signal cpu_wr       : out std_logic;
    signal cpu_addr     : out std_logic_vector(15 downto 0);
    signal cpu_wdata    : out std_logic_vector(31 downto 0)
);

-------------------------------------------------------------
-- CPU write procedure (address is an slv16)
-------------------------------------------------------------
procedure cpu_write( 
    signal clk          : in  std_logic;
    constant a          : in  std_logic_vector(15 downto 0);
    constant d          : in  std_logic_vector(31 downto 0);
    signal cpu_rd       : out std_logic;
    signal cpu_wr       : out std_logic;
    signal cpu_addr     : out std_logic_vector(15 downto 0);
    signal cpu_wdata    : out std_logic_vector(31 downto 0)
);


-------------------------------------------------------------
-- CPU read with test procedure (address is integer)
-------------------------------------------------------------
procedure cpu_test( 
    signal clk          : in  std_logic;
    constant a          : in  integer;
    constant exp_d      : in  std_logic_vector(31 downto 0);
    signal cpu_rd       : out std_logic;
    signal cpu_wr       : out std_logic;
    signal cpu_addr     : out std_logic_vector(15 downto 0);
    signal cpu_wdata    : out std_logic_vector(31 downto 0);
    signal cpu_rdata    : in  std_logic_vector(31 downto 0);
    signal cpu_rdata_dv : in  std_logic;
    signal result       : out std_logic_vector(31 downto 0) -- The returned value for use outside the function
    
);

-------------------------------------------------------------
-- CPU read with test procedure (address is SLV16)
-------------------------------------------------------------
procedure cpu_test( 
    signal clk          : in  std_logic;
    constant a          : in  std_logic_vector(15 downto 0);
    constant exp_d      : in  std_logic_vector(31 downto 0);
    signal cpu_rd       : out std_logic;
    signal cpu_wr       : out std_logic;
    signal cpu_addr     : out std_logic_vector(15 downto 0);
    signal cpu_wdata    : out std_logic_vector(31 downto 0);
    signal cpu_rdata    : in  std_logic_vector(31 downto 0);
    signal cpu_rdata_dv : in  std_logic;
    signal result       : out std_logic_vector(31 downto 0) -- The returned value for use outside the function
);

-------------------------------------------------------------
-- CPU read procedure (address is integer)
-------------------------------------------------------------
procedure cpu_read( 
    signal clk          : in  std_logic;
    constant a          : in  integer;

    signal cpu_rd       : out std_logic;
    signal cpu_wr       : out std_logic;
    signal cpu_addr     : out std_logic_vector(15 downto 0);
    signal cpu_wdata    : out std_logic_vector(31 downto 0);
    signal cpu_rdata    : in  std_logic_vector(31 downto 0);
    signal cpu_rdata_dv : in  std_logic;
    signal result       : out std_logic_vector(31 downto 0) -- The returned value for use outside the function
    
);

-------------------------------------------------------------
-- CPU read procedure (address is SLV16)
-------------------------------------------------------------
procedure cpu_read( 
    signal clk          : in  std_logic;
    constant a          : in  std_logic_vector(15 downto 0);

    signal cpu_rd       : out std_logic;
    signal cpu_wr       : out std_logic;
    signal cpu_addr     : out std_logic_vector(15 downto 0);
    signal cpu_wdata    : out std_logic_vector(31 downto 0);
    signal cpu_rdata    : in  std_logic_vector(31 downto 0);
    signal cpu_rdata_dv : in  std_logic;
    signal result       : out std_logic_vector(31 downto 0) -- The returned value for use outside the function
);

end package;


--------------------------------------------------------------------------------
--  
--------------------------------------------------------------------------------
package body tb_qlaser_pkg is

    ----------------------------------------------------------------
    -- Delay in clock cycles
    ----------------------------------------------------------------
    procedure cpu_delay(
        signal   clk        : in    std_logic;
        constant length     : in    integer
    ) is

    variable v_length   : integer;

    begin
        v_length    := length;

        for I in 0 to v_length-1 loop
            wait until rising_edge(clk);
        end loop;
            
    end procedure cpu_delay;

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


    -------------------------------------------------------------
    -- CPU write procedure (address is an integer)
    -------------------------------------------------------------
    procedure cpu_write( 
        signal clk          : in  std_logic;
        constant a          : in  integer;
        constant d          : in  std_logic_vector(31 downto 0);
        signal cpu_rd       : out std_logic;
        signal cpu_wr       : out std_logic;
        signal cpu_addr     : out std_logic_vector(15 downto 0);
        signal cpu_wdata    : out std_logic_vector(31 downto 0)
    ) is
    begin
        wait until clk'event and clk='0';
        cpu_rd      <= '0';
        cpu_wr      <= '1';
        cpu_addr    <= std_logic_vector(to_unsigned(a, 16));
        cpu_wdata   <= std_logic_vector(d);
        wait until clk'event and clk='0';
        cpu_rd      <= '0';
        cpu_wr      <= '0';
        cpu_addr    <= (others=>'0');
        cpu_wdata   <= (others=>'0');
        wait until clk'event and clk='0';
    end;


    -------------------------------------------------------------
    -- CPU write procedure (address is an slv16)
    -------------------------------------------------------------
    procedure cpu_write( 
        signal clk          : in  std_logic;
        constant a          : in  std_logic_vector(15 downto 0);
        constant d          : in  std_logic_vector(31 downto 0);
        signal cpu_rd       : out std_logic;
        signal cpu_wr       : out std_logic;
        signal cpu_addr     : out std_logic_vector(15 downto 0);
        signal cpu_wdata    : out std_logic_vector(31 downto 0)
    ) is
    variable v_nadr : integer;
    begin
        v_nadr := to_integer(unsigned(a));
        cpu_write(clk, v_nadr, d, cpu_rd, cpu_wr, cpu_addr, cpu_wdata);
    end;


    -------------------------------------------------------------
    -- CPU test procedure (address is integer)
    -------------------------------------------------------------
    procedure cpu_test( 
        signal clk          : in  std_logic;
        constant a          : in  integer;
        constant exp_d      : in  std_logic_vector(31 downto 0);
        signal cpu_rd       : out std_logic;
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
        cpu_rd      <= '1';
        cpu_wr      <= '0';
        cpu_addr    <= std_logic_vector(to_unsigned(a, 16));
        cpu_wdata   <= (others=>'0');
        while (v_bdone = false) loop
            wait until clk'event and clk='0';
            cpu_rd      <= '0';
            cpu_wr      <= '0';
            cpu_addr    <= (others=>'0');
            if (cpu_rdata_dv = '1') then
                if (cpu_rdata /= exp_d) then
                    fprint(str_out, "Read  exp: 0x%s  actual: 0x%s\n", to_string(to_bitvector(exp_d),"%08X"), to_string(to_bitvector(cpu_rdata),"%08X"));
                    report str_out severity error;
                end if;
                v_bdone := true; 
            end if;
        end loop;
        wait until clk'event and clk='0';
        wait until clk'event and clk='0';
    end;

    -------------------------------------------------------------
    -- CPU test procedure (address is SLV16)
    -------------------------------------------------------------
    procedure cpu_test( 
        signal clk          : in  std_logic;
        constant a          : in  std_logic_vector(15 downto 0);
        constant exp_d      : in  std_logic_vector(31 downto 0);
        signal cpu_rd       : out std_logic;
        signal cpu_wr       : out std_logic;
        signal cpu_addr     : out std_logic_vector(15 downto 0);
        signal cpu_wdata    : out std_logic_vector(31 downto 0);
        signal cpu_rdata    : in  std_logic_vector(31 downto 0);
        signal cpu_rdata_dv : in  std_logic
    ) is
    variable v_nadr : integer;
    begin
        v_nadr := to_integer(unsigned(a));
        cpu_test (clk, v_nadr, exp_d, cpu_rd, cpu_wr, cpu_addr, cpu_wdata, cpu_rdata, cpu_rdata_dv);
    end;


    -------------------------------------------------------------
    -- CPU read procedure (address is integer)
    -------------------------------------------------------------
    procedure cpu_read( 
        signal clk          : in  std_logic;
        constant a          : in  integer;

        signal cpu_rd       : out std_logic;
        signal cpu_wr       : out std_logic;
        signal cpu_addr     : out std_logic_vector(15 downto 0);
        signal cpu_wdata    : out std_logic_vector(31 downto 0);
        signal cpu_rdata    : in  std_logic_vector(31 downto 0);
        signal cpu_rdata_dv : in  std_logic;
        signal result       : out std_logic_vector(31 downto 0)
        
    ) is
    variable v_bdone    : boolean := false; 
    variable str_out    : string(1 to 256);
    begin
        wait until clk'event and clk='0';
        cpu_rd      <= '1';
        cpu_wr      <= '0';
        cpu_addr    <= std_logic_vector(to_unsigned(a, 16));
        cpu_wdata   <= (others=>'0');
        while (v_bdone = false) loop
            wait until clk'event and clk='0';
            cpu_rd      <= '0';
            cpu_wr      <= '0';
            cpu_addr    <= (others=>'0');
            
            if (cpu_rdata_dv = '1') then
                result <= cpu_rdata;
                v_bdone := true; 
            end if;
            
        end loop;
        wait until clk'event and clk='0';
        wait until clk'event and clk='0';
    end;

    -------------------------------------------------------------
    -- CPU read procedure (address is SLV16)
    -------------------------------------------------------------
    procedure cpu_read( 
        signal clk          : in  std_logic;
        constant a          : in  std_logic_vector(15 downto 0);

        signal cpu_rd       : out std_logic;
        signal cpu_wr       : out std_logic;
        signal cpu_addr     : out std_logic_vector(15 downto 0);
        signal cpu_wdata    : out std_logic_vector(31 downto 0);
        signal cpu_rdata    : in  std_logic_vector(31 downto 0);
        signal cpu_rdata_dv : in  std_logic;
        signal result       : out std_logic_vector(31 downto 0)
    ) is
    variable v_nadr : integer;
    begin
        v_nadr := to_integer(unsigned(a));
        cpu_read (clk, v_nadr, cpu_rd, cpu_wr, cpu_addr, cpu_wdata, cpu_rdata, cpu_rdata_dv, result);
    end;

end package body;

