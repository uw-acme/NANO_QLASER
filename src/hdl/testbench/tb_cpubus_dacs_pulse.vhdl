-----------------------------------------------------------
-- File : tb_cpubus_dacs_pulse.vhd
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

use     work.qlaser_pkg.all;

entity tb_cpubus_dacs_pulse is
end    tb_cpubus_dacs_pulse;

architecture behave of tb_cpubus_dacs_pulse is 

signal clk                          : std_logic;
signal reset                        : std_logic;
signal enable                       : std_logic;  
signal trigger                      : std_logic;  
signal busy                         : std_logic;  
signal jesd_syncs                   : std_logic_vector(31 downto 0);    -- Inputs from each JESD TX interface
signal ready                        : std_logic;                        -- Status signal indicating all JESD channels are sync'ed.
signal error_ac                     : std_logic;                        -- Instantanous JESD sync status.
signal error_latched                : std_logic;                        -- JESD lost sync after ready. Cleared by trigger
signal cpu_wr                       : std_logic;
signal cpu_sel                      : std_logic;
signal cpu_addr                     : std_logic_vector(15 downto 0);
signal cpu_wdata                    : std_logic_vector(31 downto 0);
signal cpu_rdata                    : std_logic_vector(31 downto 0);
signal cpu_rdata_dv                 : std_logic; 

-- AXI-stream output interface
signal axis_treadys                 : std_logic_vector(31 downto 0);    -- axi_stream ready from downstream modules
signal axis_tdatas                  : t_arr_slv32x16b;   -- axi stream output data array
signal axis_tvalids                 : std_logic_vector(31 downto 0);    -- axi_stream output data valid
signal axis_tlasts                  : std_logic_vector(31 downto 0);    -- axi_stream output set on last data  

-- Halts simulation by stopping clock when set true
signal sim_done                     : boolean   := false;

-- Crystal clock freq expressed in MHz
constant CLK_FREQ_MHZ               : real      := 100.0; 
-- Clock period
constant CLK_PER                    : time      := integer(1.0E+6/(CLK_FREQ_MHZ)) * 1 ps;

-- channel RAM addresses
constant ADR_RAM_PULSE              : integer   :=  to_integer(unsigned(X"0000"));    -- 
constant ADR_RAM_WAVE               : integer   :=  to_integer(unsigned(X"0200"));    -- 

-- Block registers
-- cpu_addr(11) = '1' for dac_pulse registers = X"8000"
constant ADR_REG_AC_SEQ_LEN         : integer   :=  to_integer(unsigned(X"0800"));    -- 
constant ADR_REG_AC_CH_SELS         : integer   :=  to_integer(unsigned(X"0801"));    -- 
constant ADR_REG_AC_STATUS          : integer   :=  to_integer(unsigned(X"0802"));    -- 
constant ADR_REG_AC_STATUS_CH       : integer   :=  to_integer(unsigned(X"0803"));    -- 
constant ADR_REG_AC_CNT_TIME        : integer   :=  to_integer(unsigned(X"0804"));    -- 

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

    -------------------------------------------------------------
	-- Unit Under Test
    -------------------------------------------------------------
	u_dac_pulse : entity work.qlaser_dacs_pulse
	port map (
        clk             => clk                      , -- in  std_logic;
        reset           => reset                    , -- in  std_logic;

        enable          => enable                   , -- in  std_logic;  
        trigger         => trigger                  , -- in  std_logic;                        -- Set when pulse generation sequence begins (trigger)
        jesd_syncs      => jesd_syncs               , -- in  std_logic_vector(31 downto 0);    -- Inputs from each JESD TX interface

        busy            => busy                     , -- out std_logic;    -- Set to '1' while SPI interface is busy
        ready           => ready                    , -- out std_logic;                        -- Status signal indicating all JESD channels are sync'ed.
        error           => error_ac                 , -- out std_logic;                        -- Instantanous JESD sync status.
        error_latched   => error_latched            , -- out std_logic;                        -- JESD lost sync after ready. Cleared by trigger

        -- CPU interface
        cpu_addr        => cpu_addr(11 downto 0)    , -- in  std_logic_vector(11 downto 0);
        cpu_wdata       => cpu_wdata                , -- in  std_logic_vector(31 downto 0);
        cpu_wr          => cpu_wr                   , -- in  std_logic;
        cpu_sel         => cpu_sel                  , -- in  std_logic;

        cpu_rdata       => cpu_rdata                , -- out std_logic_vector(31 downto 0);
        cpu_rdata_dv    => cpu_rdata_dv             , -- out std_logic; 

                   
        -- Array of 32 AXI-Stream buses. Each with 16-bit data. Interface to JESD TX Interfaces
        axis_treadys    => axis_treadys             , -- in  std_logic_vector(31 downto 0);    -- axi_stream ready from downstream modules
        axis_tdatas     => axis_tdatas              , -- out t_arr_slv32x16b;   -- axi stream output data array
        axis_tvalids    => axis_tvalids             , -- out std_logic_vector(31 downto 0);    -- axi_stream output data valid
        axis_tlasts     => axis_tlasts                -- out std_logic_vector(31 downto 0)     -- axi_stream output set on last data  
    );
    axis_treadys    <= (others=>'1');	


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
        trigger     <= '0';
        jesd_syncs  <= (others=>'0');

        cpu_sel     <= '0';
        cpu_wr      <= '0';
		cpu_wdata   <= (others=>'0');
		cpu_addr  	<= (others=>'0');

        cpu_print_msg("Simulation start");
        clk_delay(5);
        reset       <= '0';

        clk_delay(5);
        enable      <= '1';
       

        clk_delay(20);
        jesd_syncs  <= (others=>'1');


        ----------------------------------------------------------------
        -- Read local registers
        ----------------------------------------------------------------
        cpu_read (clk, ADR_REG_AC_SEQ_LEN     , X"00800000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata, cpu_rdata, cpu_rdata_dv);
        cpu_read (clk, ADR_REG_AC_CH_SELS     , X"FFFFFFFF", cpu_sel, cpu_wr, cpu_addr, cpu_wdata, cpu_rdata, cpu_rdata_dv);
        cpu_read (clk, ADR_REG_AC_STATUS      , X"00000000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata, cpu_rdata, cpu_rdata_dv);
        cpu_read (clk, ADR_REG_AC_STATUS_CH   , X"00000000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata, cpu_rdata, cpu_rdata_dv);
        cpu_read (clk, ADR_REG_AC_CNT_TIME    , X"00000000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata, cpu_rdata, cpu_rdata_dv);

        ----------------------------------------------------------------
        -- Load ch0 pulse RAM with a series of pulse start times
        ----------------------------------------------------------------
        v_ndata32 := 128; -- Time for first pulse
        cpu_print_msg("Load pulse RAM");
        for NADDR in 0 to 15 loop
            cpu_write(clk, ADR_RAM_PULSE + NADDR  , v_ndata32 + (NADDR*(1024+32)), cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        end loop;
        cpu_print_msg("Pulse RAM loaded");
        clk_delay(20);

        ----------------------------------------------------------------
        -- Load waveform RAM with a simple ramp
        -- Write two 16-bit values with each write
        ----------------------------------------------------------------
        cpu_print_msg("Load waveform RAM");
        v_ndata16 := 1; -- first waveform value
        for NADDR in 0 to 5 loop
            v_ndata32 := (((v_ndata16+1) * 65536) + v_ndata16);
            cpu_write(clk, (ADR_RAM_WAVE + NADDR)  , v_ndata32, cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
            v_ndata16 := v_ndata16 + 2;
        end loop;
        cpu_print_msg("Waveform RAM loaded");
        clk_delay(20);


        ----------------------------------------------------------------
        -- Read back Pulse RAM. 
        ----------------------------------------------------------------
        v_ndata32 := 128; -- Time for first pulse
        for NADDR in 0 to 15 loop
            cpu_read (clk, ADR_RAM_PULSE + NADDR  , std_logic_vector(to_unsigned(v_ndata32 + (NADDR*(1024+32)),32 )), cpu_sel, cpu_wr, cpu_addr, cpu_wdata, cpu_rdata, cpu_rdata_dv);
        end loop;
        clk_delay(20);

        ----------------------------------------------------------------
        -- Read back Waveform RAM
        ----------------------------------------------------------------
        v_ndata16 := 1; -- first waveform value
        for NADDR in 0 to 5 loop
            v_ndata32 := (((v_ndata16+1) * 65536) + v_ndata16);
            cpu_read (clk, ADR_RAM_WAVE + NADDR  , std_logic_vector(to_unsigned(v_ndata32, 32)) , cpu_sel, cpu_wr, cpu_addr, cpu_wdata, cpu_rdata, cpu_rdata_dv);
            v_ndata16 := v_ndata16 + 2;
        end loop;
        
        -- Done reg write/read check
        cpu_print_msg("RAM readback completed");
        clk_delay(20);
                                               


        ----------------------------------------------------------------
        -- Start the pulse outputs
        ----------------------------------------------------------------
        clk_delay(5);
        trigger    <= '1';
        clk_delay(5);
        trigger    <= '0';
        
        wait for 10 us;
        
        cpu_print_msg("Simulation done");
        clk_delay(5);
		
        sim_done    <= true;
        wait;

    end process;

end behave;

