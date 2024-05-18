----------------------------------------------------------------------------------
-- ps1_wrapper   THIS FILE IS FOR SIMULATION
----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

--use     std.textio.all; 
--use     work.std_iopak.all;


use     work.qlaser_pkg.all;
use     work.tb_zcu102_ps_cpu_pkg.all;
use     work.qlaser_addr_zcu102_pkg.all;

entity ps1_wrapper is
port (
    clk_cpu             : out std_logic;
    cpu_addr            : out std_logic_vector(17 downto 0);
    cpu_rd              : out std_logic;
    cpu_rdata           : in  std_logic_vector(31 downto 0);
    cpu_rdata_dv        : in  std_logic;
    cpu_wdata           : out std_logic_vector(31 downto 0);
    cpu_wr              : out std_logic;

    -- gpio_int_in_tri_i   : in  std_logic_vector( 7 downto 0);
    -- gpio_int_out_tri_o  : out std_logic_vector( 7 downto 0);
    gpio_leds_tri_o     : out std_logic_vector( 7 downto 0);
    gpio_pbtns_tri_i    : in  std_logic_vector( 4 downto 0);

    pl_clk0             : out std_logic;
    pl_resetn0          : out std_logic;
    reset               : in  std_logic
);
end ps1_wrapper;


architecture sim of ps1_wrapper is  

-- Crystal clock freq expressed in MHz
constant CLK_FREQ_MHZ   : real      := 100.0;

-- Clock period
constant CLK_PER        : time      := integer(1.0E+6/(CLK_FREQ_MHZ)) * 1 ps;

signal clk              : std_logic;
signal rd               : std_logic;
signal wr               : std_logic;
signal addr             : std_logic_vector(17 downto 0);
signal wdata            : std_logic_vector(31 downto 0);
signal rdata            : std_logic_vector(31 downto 0);
signal rdata_dv         : std_logic;

-- Halts simulation by stopping clock when set true
signal sim_done         : boolean   := false; 

begin
  
    -- Drive all outputs to '0' except PL clk0 and resetn0
    -- Rename input/outputs to/from shorter internal equivalents
    clk_cpu             <= '0';   
    cpu_rd              <= rd;    
    cpu_wr              <= wr;    
    cpu_addr            <= addr;  
    cpu_wdata           <= wdata; 

    rdata               <= cpu_rdata;
    rdata_dv            <= cpu_rdata_dv;
    
    -- gpio_int_out_tri_o  <= (others=>'0');   -- out std_logic_vector( 7 downto 0);
    gpio_leds_tri_o     <= (others=>'0');   -- out std_logic_vector( 7 downto 0);


    -------------------------------------------------------------
    -- 
    -------------------------------------------------------------
    pr_main : process
    variable v_ndata32  : integer := 0;
    variable v_ndata16  : integer := 0;
    begin

        wr          <= '0';
        rd          <= '0';
		wdata       <= (others=>'0');
		addr  	    <= (others=>'0');

        cpu_print_msg("Simulation start");

        clk_delay(20, clk);

        ----------------------------------------------------------------
        -- ADD CUSTOM REGISTER COMMANDS BELOW HERE
        ----------------------------------------------------------------
        
        ----------------------------------------------------------------
        -- CPU writes to PMOD DAC registers
        ----------------------------------------------------------------
        -- Write control register. Bit-0 = '0' for CPU bus access to PMOD DACs
        -- cpu_write(clk, to_integer(unsigned(ADR_REG_PULSE2PMOD_CTRL))    , X"00000000", rd, wr, addr, wdata);
        -- clk_delay(10, clk);

        cpu_write(clk, PMOD_ADDR_INTERNAL_REF    , X"00000001", rd, wr, addr, wdata);
        cpu_write(clk, PMOD_ADDR_POWER_ON    , X"00000001", rd, wr, addr, wdata);
        cpu_write(clk, "00" & X"0080"    , X"00000001", rd, wr, addr, wdata); --caddrspiall

        -- Write DAC0 register
        cpu_write(clk, PMOD_ADDR_SPI0    , X"00000001", rd, wr, addr, wdata);
        clk_delay(70, clk);

        -- Write DAC0 register
        cpu_write(clk, PMOD_ADDR_SPI0    , X"00000010", rd, wr, addr, wdata);
        clk_delay(70, clk);


        -- trigger
        cpu_write(clk, ADR_MISC_DEBUG_TRIGGER    , X"00000001", rd, wr, addr, wdata); --ADR_MISC_TRIGGER
        clk_delay(70, clk);

        ----------------------------------------------------------------
        -- ADD CUSTOM REGISTER COMMANDS ABOVE HERE
        ----------------------------------------------------------------
        
        cpu_print_msg("CPU done");
        clk_delay(5, clk);
		
        sim_done    <= true;
        wait; 

    end process;



    -------------------------------------------------------------
    -- Generate pl_clk0 clock. Halt when sim_done is true.
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
	
	pl_clk0  <= clk;


    -------------------------------------------------------------
    -- Generate pl_resetn0
    -------------------------------------------------------------
    pr_resetn0 : process
    begin
        pl_resetn0  <= '0';
        wait for (5*CLK_PER/2);
        pl_resetn0  <= '1';
        wait;
    end process;
    

end sim;
