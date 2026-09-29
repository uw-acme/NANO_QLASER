-----------------------------------------------------------
-- File : cpuint_code_pmod_pulse.vhd
-----------------------------------------------------------
-- 
--  Description  : Architecture code_pmode_pulse for qlaser_cpuint
--                 Intended for use with qlaser_cpuint_e.vhdl
--
-- Pulse output control of Qlaser FPGA through PMOD
--
----------------------------------------------------------
library ieee;
use     ieee.numeric_std.all;
use     ieee.std_logic_1164.all; 
use     std.textio.all; 

use     work.std_iopak.all;

use     work.qlaser_pkg.all;
use     work.qlaser_tb_pkg.all;


architecture code_pmode_pulse of qlaser_cpuint is 

constant ADR_REG_CTRL               : integer := to_integer(unsigned(X"38"));
constant ADR_REG_DC_DAC0            : integer := 0;

signal wr                           : std_logic;
signal rd                           : std_logic;
signal sel                          : std_logic;
signal addr                         : std_logic_vector(15 downto 0);
signal wdata                        : std_logic_vector(31 downto 0);
signal rdata                        : std_logic_vector(31 downto 0);
signal rdata_dv                     : std_logic; 


begin

  
    -------------------------------------------------------------
    -- Reset and drive CPU bus 
    -------------------------------------------------------------
    pr_main : process
    variable v_ndata32  : integer := 0;
    variable v_ndata16 : integer := 0;
    begin

        sel         <= '0';
        wr          <= '0';
        rd          <= '0';
        
		wdata       <= (others=>'0');
		addr  	    <= (others=>'0');

        cpu_print_msg("Simulation start");
        clk_delay(5, clk);


        clk_delay(20, clk);

        ----------------------------------------------------------------
        -- ADD CUSTOM REGISTER COMMANDS BELOW HERE
        ----------------------------------------------------------------
        
        ----------------------------------------------------------------
        -- CPU writes to PMOD DAC registers
        ----------------------------------------------------------------
        -- Write control register. Bit-0 = '0' for CPU bus access to PMOD DACs
        cpu_write(clk, ADR_REG_CTRL       , X"00000000", sel, wr, addr, wdata);
        clk_delay(10, clk);

        -- Write DAC0 register
        cpu_write(clk, ADR_REG_DC_DAC0    , X"00000001", sel, wr, addr, wdata);
        clk_delay(70, clk);

        -- Write DAC0 register
        cpu_write(clk, ADR_REG_DC_DAC0    , X"00000010", sel, wr, addr, wdata);
        clk_delay(70, clk);


        ----------------------------------------------------------------
        -- ADD CUSTOM REGISTER COMMANDS ABOVE HERE
        ----------------------------------------------------------------
        
        cpu_print_msg("CPU done");
        clk_delay(5, clk);
		
        --sim_done    <= true;
        wait;

    end process;


    -------------------------------------------------------------------------------
    -- DO NOT CHANGE CODE BELOW THIS LINE
    -------------------------------------------------------------------------------
    debug   <= (others=>'0');


    -------------------------------------------------------------------------------
    -- Drive output ports wr => cpu_wr etc.
    -- Decode upper address bits into block select bits.
    -- Keep decoded upper 4 bits of output address to zero.
    -------------------------------------------------------------------------------
    pr_cpubus : process (reset, clk)
    begin

        if (reset = '1') then

            cpu_rd      <= '0';
            cpu_wr      <= '0';
            cpu_sels    <= (others=>'0');
            cpu_addr    <= (others=>'0');
            cpu_din     <= (others=>'0');

        elsif rising_edge(clk) then

            cpu_rd      <= rd;
            cpu_wr      <= wr;
            cpu_addr    <= "0000" & addr(11 downto 0);
            cpu_din     <= wdata;

            cpu_sels    <= (others=>'0');
            if (rd='1' or wr='1') then
                cpu_sels(to_integer(unsigned(addr(15 downto 12)))) <= '1';
            end if;

        end if;

    end process;


    -------------------------------------------------------------------------------
    -- Combine returned cpu_dout and cpu_dout_dv signals into one set.
    -------------------------------------------------------------------------------
    pr_cpuint_dout : process (reset, clk)
    variable v_cpu_dout     : std_logic_vector(31 downto 0) := (others=>'0');
    variable v_cpu_dout_dv  : std_logic := '0';
    begin

        if (reset = '1') then

            rdata_dv  <= '0';
            rdata     <= (others=>'0');

        elsif rising_edge(clk) then

            v_cpu_dout      := (others=>'0');
            v_cpu_dout_dv   := '0';

            for I in 0 to C_NUM_BLOCKS-1 loop

                v_cpu_dout_dv  := v_cpu_dout_dv or arr_cpu_dout_dv(I);
                v_cpu_dout     := v_cpu_dout    or arr_cpu_dout(I);

            end loop;

            rdata_dv  <= v_cpu_dout_dv;
            rdata     <= v_cpu_dout;

        end if;

    end process;

end code_pmode_pulse;

