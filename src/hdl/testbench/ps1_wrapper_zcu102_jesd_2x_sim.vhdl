----------------------------------------------------------------------------------
-- ps1_wrapper   THIS FILE IS FOR SIMULATION
----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

--use     std.textio.all; 
--use     work.std_iopak.all;

use     work.qlaser_pkg.all;
--use     work.tb_zcu102_ps_cpu_pkg.all;
--use     work.qlaser_addr_zcu102_pkg.all;

entity ps1_wrapper is
port (
    reset               : in  std_logic;

    clk_cpu             : out std_logic;
    cpu_addr            : out std_logic_vector(17 downto 0);
    cpu_rd              : out std_logic;
    cpu_rdata           : in  std_logic_vector(31 downto 0);
    cpu_rdata_dv        : in  std_logic;
    cpu_wdata           : out std_logic_vector(31 downto 0);
    cpu_wr              : out std_logic;

    pl_clk0             : out std_logic;
    pl_resetn0          : out std_logic;

    gpio_leds_tri_o     : out std_logic_vector( 7 downto 0);
    gpio_pbtns_tri_i    : in  std_logic_vector( 4 downto 0);
    gpio_int_in_tri_i   : in  std_logic_vector( 7 downto 0);
    gpio_int_out_tri_o  : out std_logic_vector( 7 downto 0);

    ------------------------------------------------------------------------    
    -- FMC0 JESD interface (4 links, each with 2 lanes)
    ------------------------------------------------------------------------    
    s_axis_fmc0_tx_tdata    : in  std_logic_vector(255 downto 0);
    s_axis_fmc0_tx_tready   : out std_logic;
 
    fmc0_tx_core_reset      : in  std_logic;
    fmc0_tx_refclk          : in  std_logic;
    fmc0_tx_sysref          : in  std_logic;
    fmc0_tx_syncs           : in  std_logic_vector( 3 downto 0);
    fmc0_txp_out            : out std_logic_vector( 7 downto 0);
    fmc0_txn_out            : out std_logic_vector( 7 downto 0);
    fmc0_tx_sof             : out std_logic_vector( 3 downto 0);
    fmc0_tx_somf            : out std_logic_vector( 3 downto 0);
    fmc0_tx_aresetn         : out std_logic;
    fmc0_tx_reset_done      : out std_logic;
    fmc0_gt_powergood       : out std_logic;
    fmc0_irq                : out std_logic;

    ------------------------------------------------------------------------    
    -- FMC1 JESD interface (4 links, each with 2 lanes)
    ------------------------------------------------------------------------    
    s_axis_fmc1_tx_tdata    : in  std_logic_vector(255 downto 0);
    s_axis_fmc1_tx_tready   : out std_logic;
    fmc1_tx_core_reset      : in  std_logic;
    fmc1_tx_refclk          : in  std_logic;
    fmc1_tx_sysref          : in  std_logic;
    fmc1_tx_syncs           : in  std_logic_vector( 3 downto 0);
    fmc1_txp_out            : out std_logic_vector( 7 downto 0);
    fmc1_txn_out            : out std_logic_vector( 7 downto 0);
    fmc1_tx_sof             : out std_logic_vector( 3 downto 0);
    fmc1_tx_somf            : out std_logic_vector( 3 downto 0);
    fmc1_tx_aresetn         : out std_logic;
    fmc1_tx_reset_done      : out std_logic;
    fmc1_gt_powergood       : out std_logic;
    fmc1_irq                : out std_logic
);
end ps1_wrapper;

architecture sim_jesd_2x of ps1_wrapper is

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
    
    gpio_int_out_tri_o  <= (others=>'0');   -- out std_logic_vector( 7 downto 0);
    gpio_leds_tri_o     <= (others=>'0');   -- out std_logic_vector( 7 downto 0);

    fmc0_txp_out        <= (others=>'0');
    fmc0_txn_out        <= (others=>'1');
    fmc0_tx_sof         <= (others=>'0');
    fmc0_tx_somf        <= (others=>'0');
    fmc0_tx_aresetn     <= '0'; 
    fmc0_tx_reset_done  <= '0'; 
    fmc0_gt_powergood   <= '0'; 
    fmc0_irq            <= '0'; 

    fmc1_txp_out        <= (others=>'0');
    fmc1_txn_out        <= (others=>'1');
    fmc1_tx_sof         <= (others=>'0');
    fmc1_tx_somf        <= (others=>'0');
    fmc1_tx_aresetn     <= '0'; 
    fmc1_tx_reset_done  <= '0'; 
    fmc1_gt_powergood   <= '0'; 
    fmc1_irq            <= '0'; 

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
        cpu_write(clk, to_integer(unsigned(ADR_REG_PULSE2PMOD_CTRL))    , X"00000000", rd, wr, addr, wdata);
        clk_delay(10, clk);

        -- Write DAC0 register
        cpu_write(clk, ADR_REG_PULSE2PMOD_DAC0    , X"00000001", rd, wr, addr, wdata);
        clk_delay(70, clk);

        -- Write DAC0 register
        cpu_write(clk, ADR_REG_PULSE2PMOD_DAC0    , X"00000010", rd, wr, addr, wdata);
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
    

end sim_jesd_2x;
