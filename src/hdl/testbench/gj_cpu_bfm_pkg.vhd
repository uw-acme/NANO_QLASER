---------------------------------------------------------------
--  File         : gj_cpu_bfm_pkg.vhd
--  Description  : CPU bus transactions. 
----------------------------------------------------------------
--
----------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     std.textio.all;

library std_developerskit;
use     std_developerskit.std_iopak.all;

--use     work.gj_tb_pkg.all;
use     work.gj_cpu_pkg.all;

--use     work.gj_fpga_io_pkg.all;
use     work.moco_fpga_pkg.all;

package gj_cpu_bfm_pkg is


    procedure cpu_bfm_reset(
        signal   clk        : in    std_logic;
        signal   cpubus     : inout trec_cpubus;
        signal   gpout      : out std_logic_vector(NUM_CPU_GPIO-1 downto 0)
    );

    -- Wait for 'N' clock cycles
    procedure cpu_bfm_delay(
        signal   clk        : in    std_logic;
        constant length     : in    integer;
        signal   cpubus     : inout trec_cpubus
    );
                              
    -- Wait for a specific time
    procedure cpu_bfm_delay(
        signal   clk        : in    std_logic;
        constant length     : in    time;
        signal   cpubus     : inout trec_cpubus
    );
                              
    -- Word write (32-bit slv)
    procedure cpu_bfm_write(
        signal   clk_i      : in    std_logic;
        constant adr_i      : in    integer;
        constant wdat_i     : in    std_logic_vector(15 downto 0);
        signal   cpubus     : inout trec_cpubus
    );
                              
    ---- Word write (32-bit unsigned)
    --procedure cpu_bfm_write(
    --    signal   clk_i      : in    std_logic;
    --    constant adr_i      : in    integer;
    --    constant wdat_i     : in    unsigned(15 downto 0);
    --    signal   cpubus     : inout trec_cpubus
    --);

    -- Word read. No expected data used, returns the read data value
    procedure cpu_bfm_read(
        signal   clk_i      : in    std_logic;
        constant adr_i      : in    integer;
        signal   cpubus     : inout trec_cpubus;
        signal   rdat_o     : out   std_logic_vector(15 downto 0)
    );

    -- Word read. Return expected data as variable.
    procedure cpu_bfm_read_var(
        signal   clk_i      : in    std_logic;
        constant adr_i      : in    integer;
        signal   cpubus     : inout trec_cpubus;
        variable v_rdat_o   : out   std_logic_vector(15 downto 0)
    );

    -- Word read. No expected data used, does not return the read data value
    procedure cpu_bfm_read(
        signal   clk_i      : in    std_logic;
        constant adr_i      : in    integer;
        signal   cpubus     : inout trec_cpubus
    );

    -- Word read, using expected data
    procedure cpu_bfm_test(
        signal   clk_i      : in    std_logic;
        constant adr_i      : in    integer;
        signal   cpubus     : inout trec_cpubus;
        constant expdat_i   : in    std_logic_vector(15 downto 0);
        constant msg        : in    string
    );

    -- Word read, using expected data and a mask.
    procedure cpu_bfm_test(
        signal   clk_i      : in    std_logic;
        constant adr_i      : in    integer;
        signal   cpubus     : inout trec_cpubus;
        constant expdat_i   : in    std_logic_vector(15 downto 0);
        constant maskdat_i  : in    std_logic_vector(15 downto 0);
        constant msg        : in    string
    );


end package;


---------------------------------------------------------------
---------------------------------------------------------------
package body gj_cpu_bfm_pkg is

    ----------------------------------------------------------------
    -- reset operation
    ----------------------------------------------------------------
    procedure cpu_bfm_reset(
        signal   clk        : in    std_logic;
        signal   cpubus     : inout trec_cpubus;
        signal   gpout      : out   std_logic_vector(NUM_CPU_GPIO-1 downto 0)
    ) is
    begin

        gpout           <= (others=>'Z');

        wait until rising_edge(clk);
        cpubus.cs       <= (others=>'0');
        cpubus.rd       <= '0';
        cpubus.wr       <= '0';
        cpubus.adr      <= (others=>'Z');
        cpubus.idat     <= (others=>'Z');
        cpubus.odat     <= (others=>'Z');
        cpubus.ack      <= 'Z';
        for I in 0 to NUM_CPU_COUNTERS-1 loop
            cpubus.arrcnt(I) <= 0;
        end loop;
        wait until rising_edge(clk);

    end procedure cpu_bfm_reset;


    ----------------------------------------------------------------
    -- Delay in clock cycles
    ----------------------------------------------------------------
    procedure cpu_bfm_delay(
        signal   clk        : in    std_logic;
        constant length     : in    integer;
        signal   cpubus     : inout trec_cpubus
    ) is

    variable v_length   : integer;

    begin
        v_length    := length;

        for I in 0 to v_length-1 loop
            wait until rising_edge(clk);
        end loop;
            
    end procedure cpu_bfm_delay;

    ----------------------------------------------------------------
    -- Delay (in time units)
    ----------------------------------------------------------------
    procedure cpu_bfm_delay(
        signal   clk        : in    std_logic;
        constant length     : in    time;
        signal   cpubus     : inout trec_cpubus
    ) is

    begin
        wait for length;
        wait until rising_edge(clk);
            
    end procedure cpu_bfm_delay;


    ----------------------------------------------------------------
    -- Word write.
    ----------------------------------------------------------------
    procedure cpu_bfm_write(
        signal   clk_i      : in    std_logic;
        constant adr_i      : in    integer;
        constant wdat_i     : in    std_logic_vector(15 downto 0);
        signal   cpubus     : inout trec_cpubus
    ) is

    variable v_nblock : integer range 0 to C_WIDTH_CSBUS-1;
    variable v_addr   : std_logic_vector(15 downto 0); 

    begin
        v_addr              := std_logic_vector(to_unsigned(adr_i,16));
        v_nblock            := to_integer(unsigned(v_addr(BIT_DECODE_HI downto BIT_DECODE_LO)));
        cpubus.ack          <= 'Z';
        cpubus.idat         <= (others=>'Z');
        cpubus.odat         <= (others=>'Z');

        wait until rising_edge(clk_i);
        cpubus.adr          <= std_logic_vector(v_addr(C_WIDTH_ABUS-1 downto 0));

        wait until rising_edge(clk_i);
        cpubus.cs(v_nblock) <= '1';
        cpubus.rd           <= '0';
        cpubus.wr           <= '1';
        cpubus.odat         <= wdat_i(C_WIDTH_DBUS-1 downto 0);
        for i in 1 to NUM_CPU_WAITS loop
            wait until rising_edge(clk_i);
        end loop;

        --while (cpubus.ack /= '1') loop
        --    wait until rising_edge(clk_i);
        --end loop;

        cpubus.wr           <= '0';
        cpubus.cs           <= (others=>'0');
        cpubus.odat         <= (others=>'Z');
        wait until rising_edge(clk_i);

        cpubus.adr              <= (others=>'1');
        wait until rising_edge(clk_i);

    end procedure cpu_bfm_write;


    ----------------------------------------------------------------
    -- Word write (unsigned data).
    ----------------------------------------------------------------
    --procedure cpu_bfm_write(
    --    signal   clk_i      : in    std_logic;
    --    constant adr_i      : in    integer;
    --    constant wdat_i     : in    unsigned(15 downto 0);
    --    signal   cpubus     : inout trec_cpubus
    --) is
    --
    --variable v_wdat_slv 	: std_logic_vector(15 downto 0);
    --
    --begin
    --    v_wdat_slv  := std_logic_vector(wdat_i);
    --    cpu_bfm_write(clk_i, adr_i, v_wdat_slv, cpubus);
    --
    --end procedure cpu_bfm_write;



    ----------------------------------------------------------------
    -- Read operation
    ----------------------------------------------------------------
    procedure cpu_bfm_read(
        signal   clk_i      : in    std_logic;
        constant adr_i      : in    integer;
        signal   cpubus     : inout trec_cpubus;
        signal   rdat_o     : out   std_logic_vector(15 downto 0)
    ) is

    variable v_nblock : integer range 0 to C_WIDTH_CSBUS-1;
    variable v_addr   : std_logic_vector(15 downto 0); 

    begin
        v_addr              := std_logic_vector(to_unsigned(adr_i,16));
        v_nblock            := to_integer(unsigned(v_addr(BIT_DECODE_HI downto BIT_DECODE_LO)));

        cpubus.idat         <= (others=>'Z');
        cpubus.odat         <= (others=>'Z');
        cpubus.ack          <= 'Z';

        wait until falling_edge(clk_i);
        cpubus.cs(v_nblock) <= '1';
        cpubus.adr          <= std_logic_vector(v_addr(C_WIDTH_ABUS-1 downto 0));
        cpubus.wr           <= '0';

        wait until rising_edge(clk_i);
        cpubus.rd           <= '1';

        wait until falling_edge(clk_i);

        for i in 0 to NUM_CPU_WAITS loop
            wait until falling_edge(clk_i);
        end loop;

        while (cpubus.ack /= '1') loop
            wait until falling_edge(clk_i);
        end loop;

        rdat_o          <= X"0000" & cpubus.idat;
        cpubus.rd       <= '0';
        wait until falling_edge(clk_i);
        cpubus.cs       <= (others=>'0');
        cpubus.adr      <= (others=>'1');
        wait until falling_edge(clk_i);

    end procedure cpu_bfm_read;


    ----------------------------------------------------------------
    -- Read operation into variable
    ----------------------------------------------------------------
    procedure cpu_bfm_read_var(
        signal   clk_i      : in    std_logic;
        constant adr_i      : in    integer; 
        signal   cpubus     : inout trec_cpubus;
        variable v_rdat_o   : out   std_logic_vector(15 downto 0)
    ) is

    variable v_nblock : integer range 0 to C_WIDTH_CSBUS-1;
    variable v_addr   : std_logic_vector(15 downto 0); 

    begin
        v_addr              := std_logic_vector(to_unsigned(adr_i,16));
        v_nblock            := to_integer(unsigned(v_addr(BIT_DECODE_HI downto BIT_DECODE_LO)));

        cpubus.idat         <= (others=>'Z');
        cpubus.odat         <= (others=>'Z');
        cpubus.ack          <= 'Z';

        wait until falling_edge(clk_i);
        cpubus.adr          <= std_logic_vector(v_addr(C_WIDTH_ABUS-1 downto 0));
        cpubus.wr           <= '0';
        cpubus.cs(v_nblock) <= '1';

        wait until rising_edge(clk_i);
        cpubus.rd       <= '1';
        wait until falling_edge(clk_i);

        for i in 0 to NUM_CPU_WAITS loop
            wait until falling_edge(clk_i);
        end loop;

        while (cpubus.ack /= '1') loop
            wait until falling_edge(clk_i);
        end loop;

        v_rdat_o        := X"0000" & cpubus.idat;
        cpubus.rd       <= '0';
        wait until falling_edge(clk_i);
        cpubus.cs       <= (others=>'0');
        cpubus.adr      <= (others=>'1');
        wait until falling_edge(clk_i);

    end procedure cpu_bfm_read_var;


    ----------------------------------------------------------------
    -- Read operation
    ----------------------------------------------------------------
    procedure cpu_bfm_read(
        signal   clk_i      : in    std_logic;
        constant adr_i      : in    integer;
        signal   cpubus     : inout trec_cpubus
    ) is

    variable v_nblock : integer range 0 to C_WIDTH_CSBUS-1;
    variable v_addr   : std_logic_vector(15 downto 0); 

    begin
        v_addr              := std_logic_vector(to_unsigned(adr_i,16));
        v_nblock            := to_integer(unsigned(v_addr(BIT_DECODE_HI downto BIT_DECODE_LO)));

        cpubus.idat         <= (others=>'Z');
        cpubus.odat         <= (others=>'Z');
        cpubus.ack          <= 'Z';
        wait until falling_edge(clk_i);
        cpubus.adr          <= std_logic_vector(v_addr(C_WIDTH_ABUS-1 downto 0));
        cpubus.wr           <= '0';
        cpubus.cs(v_nblock) <= '1';
        wait until rising_edge(clk_i);
        cpubus.rd       <= '1';
        wait until falling_edge(clk_i);

        for i in 0 to NUM_CPU_WAITS loop
            wait until falling_edge(clk_i);
        end loop;

        while (cpubus.ack /= '1') loop
            wait until falling_edge(clk_i);
        end loop;

        cpubus.rd       <= '0';
        wait until falling_edge(clk_i);
        cpubus.cs       <= (others=>'0');
        cpubus.adr      <= (others=>'1');
        wait until falling_edge(clk_i);

    end procedure cpu_bfm_read;


    ----------------------------------------------------------------
    -- Read operation, using expected data
    ----------------------------------------------------------------
    procedure cpu_bfm_test(
        signal   clk_i      : in    std_logic;
        constant adr_i      : in    integer;
        signal   cpubus     : inout trec_cpubus;
        constant expdat_i   : in    std_logic_vector(15 downto 0);
        constant msg        : in    string
    ) is

    variable str_out    : string (1 to 256);
    variable v_dat      : std_logic_vector(C_WIDTH_DBUS-1 downto 0);
    variable v_nblock   : integer range 0 to C_WIDTH_CSBUS-1;
    variable v_addr     : std_logic_vector(15 downto 0); 

    begin
        v_addr              := std_logic_vector(to_unsigned(adr_i, 16));
        v_nblock            := to_integer(unsigned(v_addr(BIT_DECODE_HI downto BIT_DECODE_LO)));

        cpubus.idat         <= (others=>'Z');
        cpubus.odat         <= (others=>'Z');
        cpubus.ack          <= 'Z';
        wait until falling_edge(clk_i);
        cpubus.adr          <= std_logic_vector(v_addr(C_WIDTH_ABUS-1 downto 0));
        cpubus.wr           <= '0';
        cpubus.cs(v_nblock) <= '1';

        wait until rising_edge(clk_i);
        cpubus.rd       <= '1';
        wait until falling_edge(clk_i);

        for i in 0 to NUM_CPU_WAITS loop
            wait until falling_edge(clk_i);
        end loop;

        while (cpubus.ack /= '1') loop
            wait until falling_edge(clk_i);
        end loop;

        -- Convert 'H' and 'L' to '1' and '0'.
        for I in 0 to C_WIDTH_DBUS-1 loop
            if (cpubus.idat(I) = 'H') then 
                v_dat(I) := '1';
            elsif (cpubus.idat(I) = 'L') then 
                v_dat(I) := '0';
            else
                v_dat(I) := cpubus.idat(I);
            end if;
        end loop;

        -- Test the value
        if (v_dat /= expdat_i) then 
            fprint(str_out, "%s  exp: 0x%s  actual: 0x%s\n",
                                msg,
                                to_string(to_bitvector(expdat_i),"%04X"),
                                to_string(to_bitvector(cpubus.idat),"%04X"));

            report str_out severity error;
        end if;

        cpubus.rd       <= '0';
        wait until falling_edge(clk_i);
        cpubus.cs       <= (others=>'0');
        cpubus.adr      <= (others=>'1');

        wait until falling_edge(clk_i);

    end procedure cpu_bfm_test;

    ----------------------------------------------------------------
    -- Read operation, using expected data with a mask.
    -- Set a '1' in the mask bits to enable testing of each bit.
    ----------------------------------------------------------------
    procedure cpu_bfm_test(
        signal   clk_i      : in    std_logic;
        constant adr_i      : in    integer;
        signal   cpubus     : inout trec_cpubus;
        constant expdat_i   : in    std_logic_vector(15 downto 0);
        constant maskdat_i  : in    std_logic_vector(15 downto 0);
        constant msg        : in    string
    ) is

    variable v_nblock   : integer range 0 to C_WIDTH_CSBUS-1;
    variable str_out    : string (1 to 256);
    variable v_match    : boolean := true;
    variable v_dat      : std_logic_vector(15 downto 0);
    variable v_addr     : std_logic_vector(15 downto 0); 

    begin
        v_addr              := std_logic_vector(to_unsigned(adr_i,16));
        v_nblock            := to_integer(unsigned(v_addr(BIT_DECODE_HI downto BIT_DECODE_LO)));

		cpubus.idat         <= (others=>'Z');
        cpubus.odat         <= (others=>'Z');
        cpubus.ack          <= 'Z';

        wait until falling_edge(clk_i);
        cpubus.adr          <= std_logic_vector(v_addr(C_WIDTH_ABUS-1 downto 0));
        cpubus.wr           <= '0';
        cpubus.cs(v_nblock) <= '1';
        
        wait until rising_edge(clk_i);
        cpubus.rd       <= '1';
        wait until falling_edge(clk_i);

        for i in 0 to NUM_CPU_WAITS loop
            wait until falling_edge(clk_i);
        end loop;

        while (cpubus.ack /= '1') loop
            wait until falling_edge(clk_i);
        end loop;

        -- Convert 'H' and 'L' to '1' and '0'.
        for I in 0 to C_WIDTH_DBUS-1 loop
            if (cpubus.idat(I) = 'H') then 
                v_dat(I)  := '1';
            elsif (cpubus.idat(I) = 'L') then 
                v_dat(I)  := '0';
            else
                v_dat(I)  := cpubus.idat(I);
            end if;
        end loop;

        -- Test the value using the mask
        for I in 0 to C_WIDTH_DBUS-1 loop
            if (maskdat_i(I)='1' and (v_dat(I) /= expdat_i(I))) then 
                v_match := false;
            end if;
        end loop;

        -- Print message if there was a mismatch.
        if (v_match = false) then 
            fprint(str_out, "%s  exp: 0x%s, actual: 0x%s, mask %s\n",
                                msg,
                                to_string(to_bitvector(expdat_i),"%04X"),
                                to_string(to_bitvector(cpubus.idat),"%04X"),
                                to_string(to_bitvector(maskdat_i),"%04X"));

            report str_out severity error;
        end if;
        cpubus.rd       <= '0';

        wait until falling_edge(clk_i);
        cpubus.cs       <= (others=>'0');
        cpubus.adr      <= (others=>'1');

        wait until falling_edge(clk_i);

    end procedure cpu_bfm_test;




end package body gj_cpu_bfm_pkg;

