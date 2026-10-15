-----------------------------------------------------------
-- File : tb_cpubus_pmod_pulse.vhd
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

entity tb_cpubus_pmod_pulse is
end    tb_cpubus_pmod_pulse;

architecture behave of tb_cpubus_pmod_pulse is 

--   case cpu_addr(5 downto 3) is
constant ADR_REG_CTRL               : integer := to_integer(unsigned(X"38"));
constant ADR_REG_DC_DAC0            : integer := 0;

signal clk                          : std_logic;
signal reset                        : std_logic;
signal resetn                       : std_logic;
signal busy                         : std_logic;  

signal cpu_wr                       : std_logic;
signal cpu_sel                      : std_logic;
signal cpu_addr                     : std_logic_vector(15 downto 0);
signal cpu_wdata                    : std_logic_vector(31 downto 0);
signal cpu_rdata                    : std_logic_vector(31 downto 0);
signal cpu_rdata_dv                 : std_logic; 

-- AXI-stream input to FIFO
signal cnt_tdata                    : unsigned(15 downto 0);
signal axis_tready                  : std_logic;                        -- axi_stream ready 
signal axis_tdata                   : std_logic_vector(15 downto 0);    -- axi stream data
signal axis_tvalid                  : std_logic;                        -- axi_stream data valid
signal axis_tlast                   : std_logic;                        -- axi_stream set on last data  

-- AXI_stream output from FIFO
signal fifo_axis_tvalid             : std_logic;
signal fifo_axis_tready             : std_logic;
signal fifo_axis_tdata              : std_logic_vector(15 downto 0);
signal fifo_axis_tlast              : std_logic;

signal fifo_almost_full             : std_logic;
signal fifo_almost_empty            : std_logic;

-- Interface SPI bus to 8-channel PMOD for DC channels 0-7
signal dc0_sclk                     : std_logic;          -- Clock (50 MHz?)
signal dc0_mosi                     : std_logic;          -- Master out, Slave in. (Data to DAC)
signal dc0_cs_n                     : std_logic;          -- Active low chip select (sync_n)

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
    
    -------------------------------------------------------------
    -- AXI_Stream FIFO buffer between pulse generator and SPI interface
    -------------------------------------------------------------
    u_axi_fifo : entity work.axis_data_fifo_32Kx16b
    port map(
        s_axis_aresetn  => resetn           , -- in  std_logic;
        s_axis_aclk     => clk              , -- in  std_logic;

        s_axis_tvalid   => axis_tvalid      , -- in  std_logic;
        s_axis_tready   => axis_tready      , -- out std_logic;
        s_axis_tdata    => axis_tdata       , -- in  std_logic_vector(15 downto 0);
      --s_axis_tlast    => axis_tlast       , -- in  std_logic;

        m_axis_tvalid   => fifo_axis_tvalid , -- out std_logic;
        m_axis_tready   => fifo_axis_tready , -- in  std_logic;
        m_axis_tdata    => fifo_axis_tdata  , -- out std_logic_vector(15 downto 0);
      --m_axis_tlast    => fifo_axis_tlast  , -- out std_logic;

        almost_full     => fifo_almost_full , -- out std_logic 
        almost_empty    => fifo_almost_empty  -- out std_logic 
    );


    -------------------------------------------------------------
	-- Unit Under Test
    -------------------------------------------------------------
	u_dac_pulse : entity work.qlaser_pmod_pulse
	port map (
        clk             => clk                      , -- in  std_logic;
        reset           => reset                    , -- in  std_logic;

        busy            => busy                     , -- out std_logic;    -- Set to '1' while SPI interface is busy

        -- CPU interface
        cpu_addr        => cpu_addr( 5 downto 0)    , -- in  std_logic_vector( 5 downto 0);
        cpu_wdata       => cpu_wdata(11 downto 0)   , -- in  std_logic_vector(11 downto 0);
        cpu_wr          => cpu_wr                   , -- in  std_logic;
        cpu_sel         => cpu_sel                  , -- in  std_logic;

        cpu_rdata       => cpu_rdata                , -- out std_logic_vector(31 downto 0);
        cpu_rdata_dv    => cpu_rdata_dv             , -- out std_logic; 

        -- AXI-Stream bus.  16-bit data.
        axis_tready     => fifo_axis_tready         , -- out std_logic;    -- axi_stream ready from downstream modules
        axis_tdata      => fifo_axis_tdata          , -- in  std_logic_vector(15 downto 0);   -- axi stream output data array
        axis_tvalid     => fifo_axis_tvalid         , -- in  std_logic;    -- axi_stream output data valid
        axis_tlast      => fifo_axis_tlast          , -- in  std_logic     -- axi_stream output set on last data  

        -- Interface SPI bus to 8-channel PMOD for DC channels 0-7
        spi_sclk        => dc0_sclk        , --  out std_logic;          -- Clock (50 MHz?)
        spi_mosi        => dc0_mosi        , --  out std_logic;          -- Master out, Slave in. (Data to DAC)
        spi_cs_n        => dc0_cs_n          --  out std_logic           -- Active low chip select (sync_n)
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

        cnt_tdata   <= (0=>'1', others=>'0');
        axis_tdata  <= (others=>'0');
        axis_tvalid <= '0';
        axis_tlast  <= '0';

        cpu_sel     <= '0';
        cpu_wr      <= '0';
		cpu_wdata   <= (others=>'0');
		cpu_addr  	<= (others=>'0');

        cpu_print_msg("Simulation start");
        clk_delay(5);
        reset       <= '0';

        clk_delay(20);


        ----------------------------------------------------------------
        -- CPU writes to PMOD DAC registers
        ----------------------------------------------------------------
        -- Write control register. Bit-0 = '0' for CPU bus access to PMOD DACs
        cpu_write(clk, ADR_REG_CTRL       , X"00000000", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(10);

        -- Write DAC0 register
        cpu_write(clk, ADR_REG_DC_DAC0    , X"00000001", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(70);

        -- Write DAC0 register
        cpu_write(clk, ADR_REG_DC_DAC0    , X"00000010", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(70);


        ----------------------------------------------------------------
        -- AXI-stream writes to PMOD DAC registers
        ----------------------------------------------------------------
        -- Write control register. Bit-0 = '1' for AXI-Stream bus access to PMOD DACs
        cpu_write(clk, ADR_REG_CTRL       , X"00000001", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(10);

        -- Loop, writing data when tready = '1'
        while cnt_tdata < 10 loop

            clk_delay(0);

            if (axis_tready = '1') then
                axis_tdata  <= std_logic_vector(cnt_tdata);
                axis_tvalid <= '1';
                cnt_tdata   <= cnt_tdata + 1;
            else
                axis_tvalid <= '0';
            end if;
            
        end loop;
        axis_tvalid <= '0';
        axis_tdata  <= (others=>'0');
            
        
        -- Done stream generation
        cpu_print_msg("AXI stream writes completed");
        clk_delay(70);
        
        -- Done stream
        wait until fifo_almost_empty = '1';  -- out std_logic 
        cpu_print_msg("AXI stream FIFO nearly empty");

        clk_delay(70);
        clk_delay(70);
        clk_delay(70);
        clk_delay(70);
        clk_delay(70);
        
        cpu_print_msg("Simulation done");
        clk_delay(5);
		
        sim_done    <= true;
        wait;

    end process;

end behave;

