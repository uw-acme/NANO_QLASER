-----------------------------------------------------------------------------------------------------
-- ps1_wrapper   THIS FILE IS FOR SIMULATION
-- Test for Pulse Channel's error reporting. 
-- Deliberately write known bad values to the Pulse Channel's registers and check for error flags.
-- The main test is in the `pr_main` process with following sections:
-- 1. Setup PMOD DAC registers
-- 2. Write to Pulse Channles. Select channel(s) and then write pulse definitions and waveforms
-- 3. Start pulse output sequence
-- 4. Read back GPIO and CPU Values
-----------------------------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

--use     std.textio.all; 
--use     work.std_iopak.all;


use     work.qlaser_pkg.all;
use     work.tb_zcu102_ps_cpu_pkg.all;
use     work.qlaser_addr_zcu102_pkg.all;
use     work.std_iopak.all;

entity ps1_wrapper is
    generic (
        SEQ_LENGTH      : integer := 10000;  -- Number of sequence steps, not actually used 
        SIM_DURATION    : integer := 32768
    );
port (
    clk_cpu             : out std_logic;
    cpu_addr            : out std_logic_vector(17 downto 0);
    cpu_rd              : out std_logic;
    cpu_rdata           : in  std_logic_vector(31 downto 0);
    cpu_rdata_dv        : in  std_logic;
    cpu_wdata           : out std_logic_vector(31 downto 0);
    cpu_wr              : out std_logic;

    gpio_int_in_tri_i   : in  std_logic_vector(31 downto 0);
    gpio_int_out_tri_o  : out std_logic_vector(31 downto 0);
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

signal gpio_int_o       : std_logic_vector(31 downto 0);

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
    
    gpio_int_out_tri_o  <= gpio_int_o;   -- out std_logic_vector( 7 downto 0);
    gpio_leds_tri_o     <= (others=>'0');   -- out std_logic_vector( 7 downto 0);

    


    -------------------------------------------------------------
    -- 
    -------------------------------------------------------------
    pr_main : process
     -- variables for loading the waveform RAM
     variable v_ndata32        : integer     := 0;
     variable v_ndata16        : integer     := 0;
     variable v_ndata32_upper  : integer     := 0;
     variable v_ndata32_lower  : integer     := 0;
    begin

        wr          <= '0';
        rd          <= '0';
		wdata       <= (others=>'0');
		addr  	    <= (others=>'0');

        gpio_int_o  <= (others=>'0');

        pl_resetn0 <= '0';

        clk_delay(5, clk);
        
        cpu_print_msg("Simulation start");
        pl_resetn0 <= '1';


        clk_delay(20, clk);

        ----------------------------------------------------------------
        -- ADD CUSTOM REGISTER COMMANDS BELOW HERE
        ----------------------------------------------------------------
        
        ----------------------------------------------------------------
        -- SECTION I: Setup PMOD DAC registers
        ----------------------------------------------------------------
        cpu_print_msg("Setting up PMOD DACs");
        -- Write control register. Bit-0 = '0' for CPU bus access to PMOD DACs
        -- cpu_write(clk, to_integer(unsigned(ADR_REG_PULSE2PMOD_CTRL))    , X"00000000", rd, wr, addr, wdata);
        cpu_write(clk, to_integer(unsigned(PMOD_ADDR_CTRL))    , X"00000000", rd, wr, addr, wdata);
        -- clk_delay(10, clk);

        cpu_write(clk, PMOD_ADDR_INTERNAL_REF    , X"00000001", rd, wr, addr, wdata);
        cpu_write(clk, PMOD_ADDR_POWER_ON    , X"00000001", rd, wr, addr, wdata);
        clk_delay(70, clk);

        -- Write DAC0 register
        cpu_write(clk, PMOD_ADDR_SPI0    , X"00000001", rd, wr, addr, wdata);
        clk_delay(70, clk);
        cpu_write(clk, PMOD_ADDR_SPI0    , X"00000010", rd, wr, addr, wdata);
        clk_delay(70, clk);
        cpu_write(clk, PMOD_ADDR_SPI0    , X"00000100", rd, wr, addr, wdata);
        clk_delay(70, clk);

        -- Write DAC1 register
        cpu_write(clk, PMOD_ADDR_SPI1    , X"00000001", rd, wr, addr, wdata);
        clk_delay(70, clk);
        cpu_write(clk, PMOD_ADDR_SPI1    , X"00000010", rd, wr, addr, wdata);
        clk_delay(70, clk);
        cpu_write(clk, PMOD_ADDR_SPI1    , X"00000100", rd, wr, addr, wdata);
        clk_delay(70, clk);

        -- write sequence length
        cpu_print_msg("Set sequence length");
        cpu_write(clk, ADR_REG_AC_SEQ_LEN, std_logic_vector(to_unsigned(SEQ_LENGTH, 32)), rd, wr, addr, wdata);
        -------------------------------------------------------------------
        -- SECTION II: Write to Pulse Channles. Select channel(s) and then
        -- write pulse definitions and waveforms
        -------------------------------------------------------------------
        -- Select channel 1
        cpu_write(clk, ADR_REG_AC_CH_SEL    , X"00000001", rd, wr, addr, wdata);

        cpu_print_msg("Define pulses");

        cpu_write_pdef(clk, 0,  5, 4, 5, 4, 1.0, 1.0, rd, wr, addr, wdata);
        cpu_write_pdef(clk, 1, 31, 0, 4, 4, 1.0, 5.0, rd, wr, addr, wdata);
        
        clk_delay(10, clk);

        -- Select channel 2
        cpu_write(clk, ADR_REG_AC_CH_SEL    , X"00000002", rd, wr, addr, wdata);

        cpu_print_msg("Define pulses");

        cpu_write_pdef(clk, 0,  5, 1, 1, 1, 1.0, 2.0, rd, wr, addr, wdata);  -- num_entry, pulsetime, wavestartaddr, wavesteps, wavetopwidth, gainfactor, timefactor
        cpu_write_pdef(clk, 1, 31, 0, 4, 4, 1.0, 1.0, rd, wr, addr, wdata);
        

        clk_delay(10, clk);
        cpu_write(clk, ADR_REG_AC_CH_SEL    , X"00000003", rd, wr, addr, wdata);
        cpu_print_msg("write waveform");
        -- Load a ramp waveform into the RAM
        for NADDR in 0 to 2047 loop
            v_ndata32_upper := (v_ndata16 + 1) * 2**16;
            v_ndata32_lower := v_ndata16;
            v_ndata32       := v_ndata32_upper + v_ndata32_lower;
            cpu_write(
                clk, 
                to_integer(unsigned(ADR_BASE_PULSE_WAVE)) + 4*NADDR,
                v_ndata32,
                rd, 
                wr, 
                addr,
                wdata
            );
            v_ndata16       := v_ndata16 + 2;
        end loop;

        cpu_print_msg("##### Waves loaded! #####");
        clk_delay(10, clk);

        ----------------------------------------------------------------
        -- SECTION III: Start pulse output sequence
        ----------------------------------------------------------------
        -- enable ch 1 and ch 2
        cpu_write(clk, ADR_REG_AC_CH_EN     , X"00000003", rd, wr, addr, wdata);
        -- switch control
        cpu_write(clk, to_integer(unsigned(PMOD_ADDR_CTRL))    , X"00000001", rd, wr, addr, wdata);

        -- trigger
        cpu_print_msg("Enable Pulse");
        cpu_write(clk, ADR_MISC_DEBUG_EN    , X"00000001", rd, wr, addr, wdata);
        clk_delay(0, clk);

        cpu_print_msg("Toggle trigger");
        clk_delay(0, clk);
        cpu_write(clk, ADR_MISC_DEBUG_TRIGGER    , X"00000001", rd, wr, addr, wdata); -- start run

        clk_delay(SIM_DURATION, clk);
        cpu_print_msg("CPU done");
        ----------------------------------------------------------------
        -- SECTION IV: Read back GPIO and check CPU Values
        ----------------------------------------------------------------
        cpu_print_msg("Current debug value: " & to_string(gpio_int_in_tri_i));
        
        cpu_print_msg("Read back ADR_REG_AC_SEQ_LEN:");
        cpu_read(clk, to_integer(unsigned(ADR_REG_AC_SEQ_LEN)), std_logic_vector(to_unsigned(SEQ_LENGTH, 32)), rd, wr, addr, wdata, rdata, rdata_dv);
        cpu_print_msg("Read back ERR_BIG_STEP:");
        cpu_read(clk, to_integer(unsigned(ADR_REG_ERR_BIG_STEP)), X"00000003", rd, wr, addr, wdata, rdata, rdata_dv);
        cpu_print_msg("Read back ERR_INVAL_LEN:");
        cpu_read(clk, to_integer(unsigned(ADR_REG_ERR_INVAL_LEN)), X"00000002", rd, wr, addr, wdata, rdata, rdata_dv);
        cpu_print_msg("Read back ADR_REG_AC_CH_EN:");
        cpu_read(clk, to_integer(unsigned(ADR_REG_AC_CH_EN)), X"00000003", rd, wr, addr, wdata, rdata, rdata_dv);
        -- cpu_read(clk, to_integer(unsigned(PMOD_ADDR_SPI0)), X"00000013", rd, wr, addr, wdata, rdata, rdata_dv);

		
        sim_done    <= true;
        wait; 

    end process;



    -------------------------------------------------------------
    -- Generate pl_clk0 clock.
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


    -- -------------------------------------------------------------
    -- -- Generate pl_resetn0
    -- -------------------------------------------------------------
    -- pr_resetn0 : process
    -- begin
    --     pl_resetn0  <= '0';
    --     wait for (5*CLK_PER/2);
    --     pl_resetn0  <= '1';
    --     wait;
    -- end process;
    

end sim;
