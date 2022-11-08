-----------------------------------------------------------
-- File : tb_cpubus_dacs_dc.vhd
-----------------------------------------------------------
-- 
-- Testbench for CPU bus peripheral.
--
--  Description  : DC output control of Qlaser FPGA
--                 Block drives 4 SPI-bus interfaces to 8 channel DAC boards
--                 Writing to a DAC register starts data transfer to DAC
--
----------------------------------------------------------
library ieee;
use     ieee.numeric_std.all;
use     ieee.std_logic_1164.all; 
use     std.textio.all; 

use     work.std_iopak.all;


entity tb_cpubus_dacs_dc is
end    tb_cpubus_dacs_dc;

architecture behave of tb_cpubus_dacs_dc is 

signal clk                          : std_logic;
signal reset                        : std_logic;
signal dacs_dc_busy                 : std_logic_vector( 3 downto 0);  
signal cpu_wr                       : std_logic;
signal cpu_sel                      : std_logic;
signal cpu_addr                     : std_logic_vector(15 downto 0);
signal cpu_wdata                    : std_logic_vector(31 downto 0);
signal cpu_rdata                    : std_logic_vector(31 downto 0);
signal cpu_rdata_dv                 : std_logic; 

-- Interface SPI bus to 8-channel PMOD for DC channels 0-7
signal dc0_sclk                     : std_logic; 
signal dc0_mosi                     : std_logic;  
signal dc0_cs_n                     : std_logic;  

-- Interface SPI bus to 8-channel PMOD for DC channels 8-15
signal dc1_sclk                     : std_logic; 
signal dc1_mosi                     : std_logic;  
signal dc1_cs_n                     : std_logic;  

-- Interface SPI bus to 8-channel PMOD for DC channels 16-23
signal dc2_sclk                     : std_logic; 
signal dc2_mosi                     : std_logic;  
signal dc2_cs_n                     : std_logic; 

-- Interface SPI bus to 8-channel PMOD for DC channels 24-31
signal dc3_sclk                     : std_logic; 
signal dc3_mosi                     : std_logic;  
signal dc3_cs_n                     : std_logic;  

-- Halts simulation by stopping clock when set true
signal sim_done                     : boolean   := false;

-- Crystal clock freq expressed in MHz
constant CLK_FREQ_MHZ               : real      := 100.0; 
-- Clock period
constant CLK_PER                    : time      := integer(1.0E+6/(CLK_FREQ_MHZ)) * 1 ps;

-- Block registers
constant ADR_REG_DC_CTRL            : integer   :=  0;    -- 
constant ADR_REG_DC_STATUS          : integer   :=  1;    -- 

constant ADR_REG_DC_DAC0            : integer   := 32;    -- 
constant ADR_REG_DC_DAC1            : integer   := ADR_REG_DC_DAC0 +  1;    -- 
constant ADR_REG_DC_DAC2            : integer   := ADR_REG_DC_DAC0 +  2;    -- 
constant ADR_REG_DC_DAC3            : integer   := ADR_REG_DC_DAC0 +  3;    -- 
-- ....
constant ADR_REG_DC_DAC30           : integer   := ADR_REG_DC_DAC0 + 31;    -- 
constant ADR_REG_DC_DAC31           : integer   := ADR_REG_DC_DAC0 + 32;    -- 

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
	u_dacs_dc : entity work.qlaser_dacs_dc
	port map (
        clk             => clk                      , -- in  std_logic;
        reset           => reset                    , -- in  std_logic;

        busy            => dacs_dc_busy             , -- out std_logic_vector( 3 downto 0);    -- Set to '1' while SPI interface is busy

        -- CPU interface
        cpu_wr          => cpu_wr                   , -- in  std_logic;
        cpu_sel         => cpu_sel                  , -- in  std_logic;
        cpu_addr        => cpu_addr(11 downto 0)    , -- in  std_logic_vector(11 downto 0);
        cpu_wdata       => cpu_wdata                , -- in  std_logic_vector(31 downto 0);
        cpu_rdata       => cpu_rdata                , -- out std_logic_vector(31 downto 0);
        cpu_rdata_dv    => cpu_rdata_dv             , -- out std_logic; 

                   
        -- Interface SPI bus to 8-channel PMOD for DC channels 0-7
        dc0_sclk        => dc0_sclk                 , -- out std_logic;          -- Clock (50 MHz max)
        dc0_mosi        => dc0_mosi                 , -- out std_logic;          -- Master out, Slave in. (Data to DAC)
        dc0_cs_n        => dc0_cs_n                 , -- out std_logic;          -- Active low chip select (sync_n)

        -- Interface SPI bus to 8-channel PMOD for DC channels 8-15
        dc1_sclk        => dc1_sclk                 , -- out std_logic;  
        dc1_mosi        => dc1_mosi                 , -- out std_logic;  
        dc1_cs_n        => dc1_cs_n                 , -- out std_logic;  

        -- Interface SPI bus to 8-channel PMOD for DC channels 16-23
        dc2_sclk        => dc2_sclk                 , -- out std_logic;  
        dc2_mosi        => dc2_mosi                 , -- out std_logic;  
        dc2_cs_n        => dc2_cs_n                 , -- out std_logic;  

        -- Interface SPI bus to 8-channel PMOD for DC channels 24-31
        dc3_sclk        => dc3_sclk                 , -- out std_logic; 
        dc3_mosi        => dc3_mosi                 , -- out std_logic;  
        dc3_cs_n        => dc3_cs_n                   -- out std_logic  
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
    variable v_ndac  : integer := 0;
    variable v_ndata : integer := 0;
    begin
        -- Reset 
        reset       <= '1';
        cpu_sel     <= '0';
        cpu_wr      <= '0';
		cpu_wdata   <= (others=>'0');
		cpu_addr  	<= (others=>'0');

        cpu_print_msg("Simulation start");
        clk_delay(5);
        reset     <= '0';

        clk_delay(5);
       

        -- Write control register
        cpu_write(clk, ADR_REG_DC_CTRL    , X"12345678", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(20);

        -- Write DAC0 register
        cpu_write(clk, ADR_REG_DC_DAC0    , X"00000001", cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        clk_delay(20);

        -- Loop writing DAC1 to DAC31
        v_ndata := 512;

        for NDAC in 1 to 31 loop
            cpu_write(clk, ADR_REG_DC_DAC0 + NDAC  , v_ndata + (16*NDAC), cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        end loop;
        cpu_print_msg("All DACs written");

        -- Read back status reg. All four channels should be busy
        cpu_read (clk, ADR_REG_DC_STATUS  , X"0000000F", cpu_sel, cpu_wr, cpu_addr, cpu_wdata, cpu_rdata, cpu_rdata_dv);
        -- Read back control reg.
        cpu_read (clk, ADR_REG_DC_CTRL    , X"12345678", cpu_sel, cpu_wr, cpu_addr, cpu_wdata, cpu_rdata, cpu_rdata_dv);

        -- Done reg write/read check
                                               
        wait for 10 us;
        cpu_print_msg("Simulation done");
        clk_delay(5);
		
        sim_done    <= true;
        wait;

    end process;

end behave;

