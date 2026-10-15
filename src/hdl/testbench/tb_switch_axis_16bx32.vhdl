-----------------------------------------------------------
-- File : tb_switch_axis_16bx32.vhd
-----------------------------------------------------------
-- 
-- Testbench for CPU bus peripheral with AXI-Stream input port.
--
--  Description  : Pulse output control of Qlaser FPGA through PMOD
--
----------------------------------------------------------
library ieee;
use     ieee.numeric_std.all;
use     ieee.std_logic_1164.all; 
use     std.textio.all; 

use     work.std_iopak.all;

use     work.qlaser_pkg.all;
use     work.qlaser_dac_dc_pkg.all;

entity tb_switch_axis_16bx32 is
end    tb_switch_axis_16bx32;

architecture behave of tb_switch_axis_16bx32 is 

constant ADR_REG_MUXSEL0            : integer := 0;
constant ADR_REG_MUXSEL1            : integer := 1;
constant ADR_REG_MUXSEL2            : integer := 2;
constant ADR_REG_MUXSEL3            : integer := 3;
constant ADR_REG_INVERT             : integer := 4;
constant ADR_REG_ZERO               : integer := 5;
constant ADR_REG_ID_SW              : integer := 6;
constant C_ID_SWITCH                : std_logic_vector(31 downto 0) := X"55000001";     -- Meaning less number just to test block reg access

signal clk                          : std_logic;
signal reset                        : std_logic;
signal resetn                       : std_logic;

signal cpu_wr                       : std_logic;
signal cpu_sel                      : std_logic;
signal cpu_addr                     : std_logic_vector(15 downto 0);
signal cpu_wdata                    : std_logic_vector(31 downto 0);
signal cpu_rdata                    : std_logic_vector(31 downto 0);
signal cpu_rdata_dv                 : std_logic; 


-- AXI-stream input array of 32 16-bit streams
signal dacs_pulse_axis_treadys : std_logic_vector(31 downto 0);     -- axi_stream ready from downstream modules (IGNORED)
signal dacs_pulse_axis_tdatas  : t_arr_slv32x16b;                   -- axi stream output data array
signal dacs_pulse_axis_tvalids : std_logic_vector(31 downto 0);     -- axi_stream output data valid
signal dacs_pulse_axis_tlasts  : std_logic_vector(31 downto 0);     -- axi_stream output set on last data  

---------------------------------------------------------------------------
-- AXI-stream output 2 256-bit streams, one for each JESD block
---------------------------------------------------------------------------
-- FMC0 JESD interface 
signal axis_fmc0_tready    : std_logic;                        -- axi_stream ready from downstream module
signal axis_fmc0_tdata     : std_logic_vector(255 downto 0);   -- axi stream output data
signal axis_fmc0_tvalid    : std_logic;                        -- axi_stream output data valid
signal axis_fmc0_tlast     : std_logic;                        -- axi_stream output set on last data  

-- FMC1 JESD interface 
signal axis_fmc1_tready    : std_logic;                        -- axi_stream ready from downstream module
signal axis_fmc1_tdata     : std_logic_vector(255 downto 0);   -- axi stream output data
signal axis_fmc1_tvalid    : std_logic;                        -- axi_stream output data valid
signal axis_fmc1_tlast     : std_logic;                         -- axi_stream output set on last data  


-- Halts simulation by stopping clock when set true
signal sim_done                     : boolean   := false;

-- Crystal clock freq expressed in MHz
constant CLK_FREQ_MHZ               : real      := 100.0; 
-- Clock period
constant CLK_PER                    : time      := integer(1.0E+6/(CLK_FREQ_MHZ)) * 1 ps;


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

    resetn  <= not(reset);
    dacs_pulse_axis_treadys     <= (others=>'0');

    
    -------------------------------------------------------------
    -- AXI_Stream FIFO buffer between pulse generator and SPI interface
    -------------------------------------------------------------
    u_switch : entity work.switch_axis_16bx32
    port map(
        reset                   => reset                    , --  in  std_logic;
        clk                     => clk                      , --  in  std_logic; 

        -- CPU interface
        cpu_addr                => cpu_addr(11 downto 0)    , --  in  std_logic_vector(11 downto 0);    -- Address input
        cpu_wdata               => cpu_wdata                , --  in  std_logic_vector(31 downto 0);    -- Data input
        cpu_wr                  => cpu_wr                   , --  in  std_logic;                        -- Write enable 
        cpu_sel                 => cpu_sel                  , --  in  std_logic;                        -- Block select
        cpu_rdata               => cpu_rdata                , --  out std_logic_vector(31 downto 0);    -- Data output
        cpu_rdata_dv            => cpu_rdata_dv             , --  out std_logic;                        -- Acknowledge output

        -- AXI-stream input array of 32 16-bit streams
        dacs_pulse_axis_treadys => dacs_pulse_axis_treadys  , --  out std_logic_vector(31 downto 0);     -- axi_stream ready to upstream module 
        dacs_pulse_axis_tdatas  => dacs_pulse_axis_tdatas   , --  in  t_arr_slv32x16b;                   -- axi stream output data array
        dacs_pulse_axis_tvalids => dacs_pulse_axis_tvalids  , --  in  std_logic_vector(31 downto 0);     -- axi_stream output data valid
        dacs_pulse_axis_tlasts  => dacs_pulse_axis_tlasts   , --  in  std_logic_vector(31 downto 0)      -- axi_stream output set on last data  

        ---------------------------------------------------------------------------
        -- AXI-stream output 2 256-bit streams, one for each JESD block
        ---------------------------------------------------------------------------
        -- FMC0 JESD interface 
        axis_fmc0_tready        => axis_fmc0_tready         , --  in  std_logic;                        -- axi_stream ready from downstream module
        axis_fmc0_tdata         => axis_fmc0_tdata          , --  out std_logic_vector(255 downto 0);   -- axi stream output data
        axis_fmc0_tvalid        => axis_fmc0_tvalid         , --  out std_logic;                        -- axi_stream output data valid
        axis_fmc0_tlast         => axis_fmc0_tlast          , --  out std_logic;                        -- axi_stream output set on last data  

        -- FMC1 JESD interface 
        axis_fmc1_tready        => axis_fmc1_tready         , --  in  std_logic;                        -- axi_stream ready from downstream module
        axis_fmc1_tdata         => axis_fmc1_tdata          , --  out std_logic_vector(255 downto 0);   -- axi stream output data
        axis_fmc1_tvalid        => axis_fmc1_tvalid         , --  out std_logic;                        -- axi_stream output data valid
        axis_fmc1_tlast         => axis_fmc1_tlast            --  out std_logic                         -- axi_stream output set on last data  
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
    variable v_data32  : std_logic_vector(31 downto 0):= (others=>'0');
    begin
        -- Reset 
        reset       <= '1';


        cpu_sel     <= '0';
        cpu_wr      <= '0';
		cpu_wdata   <= (others=>'0');
		cpu_addr  	<= (others=>'0');

        for I in 0 to 31 loop
            dacs_pulse_axis_tdatas(I)   <= X"0000";
            dacs_pulse_axis_tvalids(I)  <= '0';
            dacs_pulse_axis_tlasts(I)   <= '0';
        end loop;

        cpu_print_msg("Simulation start");
        clk_delay(5);
        reset       <= '0';

        clk_delay(20);


        ----------------------------------------------------------------
        -- CPU read defaults 
        ----------------------------------------------------------------
        cpu_read(clk, ADR_REG_ID_SW       , C_ID_SWITCH, cpu_sel, cpu_wr, cpu_addr, cpu_wdata, cpu_rdata, cpu_rdata_dv);
        cpu_read(clk, ADR_REG_ZERO        , X"00000000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata, cpu_rdata, cpu_rdata_dv);
        cpu_read(clk, ADR_REG_INVERT      , X"00000000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata, cpu_rdata, cpu_rdata_dv);
        cpu_read(clk, ADR_REG_MUXSEL0     , X"76543210", cpu_sel, cpu_wr, cpu_addr, cpu_wdata, cpu_rdata, cpu_rdata_dv);
        cpu_read(clk, ADR_REG_MUXSEL1     , X"FEDCBA98", cpu_sel, cpu_wr, cpu_addr, cpu_wdata, cpu_rdata, cpu_rdata_dv);
        cpu_read(clk, ADR_REG_MUXSEL2     , X"76543210", cpu_sel, cpu_wr, cpu_addr, cpu_wdata, cpu_rdata, cpu_rdata_dv);
        cpu_read(clk, ADR_REG_MUXSEL3     , X"FEDCBA98", cpu_sel, cpu_wr, cpu_addr, cpu_wdata, cpu_rdata, cpu_rdata_dv);
        cpu_print_msg("Finished default reg test");

        clk_delay(20);

        -- Drive pulse data
        for I in 0 to 15 loop
            dacs_pulse_axis_tdatas(I)       <= X"AA" & std_logic_vector(to_unsigned(I,8));
            dacs_pulse_axis_tdatas(I+16)    <= X"BB" & std_logic_vector(to_unsigned(I,8));
            dacs_pulse_axis_tvalids(I)      <= '1';
            dacs_pulse_axis_tvalids(I+16)   <= '1';
        end loop;

        clk_delay(10);

        -- Write zero register. 
        cpu_print_msg("Zero all outputs");
        cpu_write(clk, ADR_REG_ZERO       , X"FFFFFFFF", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(50);

        -- Write invert reg to invert all data
        cpu_print_msg("Invert all outputs");
        cpu_write(clk, ADR_REG_INVERT     , X"FFFFFFFF", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(50);

        -- Write invert register to end inversions. 
        cpu_print_msg("End Invert all outputs");
        cpu_write(clk, ADR_REG_INVERT     , X"00000000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(50);

        -- Write zero register. 
        cpu_print_msg("End Zero all outputs");
        cpu_write(clk, ADR_REG_ZERO       , X"00000000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(50);

        -- Test individual zeros
        -- Walk a zero through the zero register to 'unzero' one channel at a time. 
        cpu_print_msg("Walk zeroing across outputs");
        v_data32   := (others=>'0');
        for I in 0 to 31 loop
            v_data32   := v_data32(30 downto 0) & '1';
            cpu_write(clk, ADR_REG_ZERO       , v_data32, cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
            clk_delay(10);
        end loop;
        clk_delay(100);

        -- Write zero register. 
        cpu_print_msg("End Zero all outputs");
        cpu_write(clk, ADR_REG_ZERO       , X"00000000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(50);

        -- Put one const value all channels except 0 and 16
        cpu_print_msg("Const for all channels except 0, 16");
        for I in 0 to 15 loop
            dacs_pulse_axis_tdatas(I)       <= X"00CC";
            dacs_pulse_axis_tdatas(I+16)    <= X"00DD";
        end loop;
        dacs_pulse_axis_tdatas(0)       <= X"AA00";
        dacs_pulse_axis_tdatas(16)      <= X"BB00";
        clk_delay(20);

        -- Test switching input channel 0 to all FMC0 outputs
        cpu_print_msg("Switch ch0 to all FMC0");
        cpu_write(clk, ADR_REG_MUXSEL0     , X"76543200", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(5);
        cpu_write(clk, ADR_REG_MUXSEL0     , X"76543000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(5);
        cpu_write(clk, ADR_REG_MUXSEL0     , X"76540000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(5);
        cpu_write(clk, ADR_REG_MUXSEL0     , X"76500000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(5);
        cpu_write(clk, ADR_REG_MUXSEL0     , X"76000000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(5);
        cpu_write(clk, ADR_REG_MUXSEL0     , X"70000000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(5);
        cpu_write(clk, ADR_REG_MUXSEL0     , X"00000000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(5);
        cpu_write(clk, ADR_REG_MUXSEL1     , X"FEDCBA90", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(5);
        cpu_write(clk, ADR_REG_MUXSEL1     , X"FEDCBA00", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(5);
        cpu_write(clk, ADR_REG_MUXSEL1     , X"FEDCB000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(5);
        cpu_write(clk, ADR_REG_MUXSEL1     , X"FEDC0000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(5);
        cpu_write(clk, ADR_REG_MUXSEL1     , X"FED00000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(5);
        cpu_write(clk, ADR_REG_MUXSEL1     , X"FE000000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(5);
        cpu_write(clk, ADR_REG_MUXSEL1     , X"F0000000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(5);
        cpu_write(clk, ADR_REG_MUXSEL1     , X"00000000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(50);

        -- Test switching input channel 16 to all FMC1 outputs
        cpu_print_msg("Switch ch16 to all FMC1");
        cpu_write(clk, ADR_REG_MUXSEL2     , X"76543200", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(5);
        cpu_write(clk, ADR_REG_MUXSEL2     , X"76543000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(5);
        cpu_write(clk, ADR_REG_MUXSEL2     , X"76540000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(5);
        cpu_write(clk, ADR_REG_MUXSEL2     , X"76500000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(5);
        cpu_write(clk, ADR_REG_MUXSEL2     , X"76000000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(5);
        cpu_write(clk, ADR_REG_MUXSEL2     , X"70000000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(5);
        cpu_write(clk, ADR_REG_MUXSEL2     , X"00000000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(5);
        cpu_write(clk, ADR_REG_MUXSEL3     , X"FEDCBA90", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(5);
        cpu_write(clk, ADR_REG_MUXSEL3     , X"FEDCBA00", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(5);
        cpu_write(clk, ADR_REG_MUXSEL3     , X"FEDCB000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(5);
        cpu_write(clk, ADR_REG_MUXSEL3     , X"FEDC0000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(5);
        cpu_write(clk, ADR_REG_MUXSEL3     , X"FED00000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(5);
        cpu_write(clk, ADR_REG_MUXSEL3     , X"FE000000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(5);
        cpu_write(clk, ADR_REG_MUXSEL3     , X"F0000000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(5);
        cpu_write(clk, ADR_REG_MUXSEL3     , X"00000000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);


        -- Done stream generation
        cpu_print_msg("AXI stream writes completed");
        clk_delay(50);
        
        cpu_print_msg("Simulation done");
        clk_delay(5);
		
        sim_done    <= true;
        wait;

    end process;

end behave;

