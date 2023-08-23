-------------------------------------------------------------------------------
-- Copyright (c) 2015 by GJED, Seattle, WA
-- Confidential - All rights reserved
-------------------------------------------------------------------------------
-- File       : moco_cpuint_code_adc_intan.vhd
-- Contains code to generate and CPU bus transactions.
-- No UART 
--
-- This code programs the interface to the Intan ADC and starts the conversion sequencee
-------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.nc3b_pkg.all;
use     work.tb_nc3b_pkg.all;   -- CPU functions


architecture code_1 of gj_cpu is

---------------------------------------------------------------
---- Convert data and register address into an Intan command
---- Prefix with zeros and 'command' identifier
---------------------------------------------------------------
--function instr_intan_wr(wdata, reg : integer) return std_logic_vector is
--begin
--    return ("00000000000000" & CMD_INTAN & INTAN_CMD_WR & std_logic_vector(to_unsigned(reg,6)) & std_logic_vector(to_unsigned(wdata,8)));
--end instr_intan_wr;
--
---------------------------------------------------------------
---- Build the memory value for an Intan convert command
---- with flags for EOG or EOF
---------------------------------------------------------------
--function instr_intan_convert(channel : integer; flag : integer) return std_logic_vector is
--begin
--    if (flag = FLAG_EOG) then
--        return ("00000000000000" & CMD_INTAN_EOG & INTAN_CMD_CONVERT & std_logic_vector(to_unsigned(channel,6)) & X"00");
--    elsif (flag = FLAG_EOF) then
--        return ("00000000000000" & CMD_INTAN_EOF & INTAN_CMD_CONVERT & std_logic_vector(to_unsigned(channel,6)) & X"00");
--    else
--        return ("00000000000000" & CMD_INTAN     & INTAN_CMD_CONVERT & std_logic_vector(to_unsigned(channel,6)) & X"00");
--        
--    end if;
--end instr_intan_convert;
--
---------------------------------------------------------------
---- Build the memory value for an Intan convert command
---- with no flags for EOG or EOF
---------------------------------------------------------------
--function instr_intan_convert(channel : integer) return std_logic_vector is
--begin
--    return ("00000000000000" & CMD_INTAN     & INTAN_CMD_CONVERT & std_logic_vector(to_unsigned(channel,6)) & X"00");
--end instr_intan_convert;
--
--function instr_intan_rd(reg : integer) return std_logic_vector is
--begin
--    return ("00000000000000" & CMD_INTAN & INTAN_CMD_RD & std_logic_vector(to_unsigned(reg,6)) & X"00");
--end instr_intan_rd;
--
--function instr_delay(delay : integer) return std_logic_vector is
--begin
--    return ("00000000000000" & CMD_DELAY & "0000" & std_logic_vector(to_unsigned(delay,12)));
--end instr_delay;
--
-----------------------------------------------------------------------------------
---- Build CPU bus word for filter setup
-----------------------------------------------------------------------------------
---- bit     0    filter_on         |      bit 0
---- bit     1    chan_a_on         |      bit 1
---- bit     2    chan_b_on         |      bit 2
---- bit     3    rectify           |      bit 3
---- bit  9: 4    Channel A 0-63    |      bit 9:4
---- bit 11:10    00                |
---- bit 17:12    Channel B 0-63    |      bit 15:10
---- bit 31:18    00000000000000    |      
-----------------------------------------------------------------
--function filter_setup(
--    filt_on  : integer;
--    ch_a_on  : integer;
--    ch_b_on  : integer;
--    rect_on  : integer;
--    ch_a     : integer;
--    ch_b     : integer
--) return std_logic_vector is
--
--variable v_filt_on  : std_logic;
--variable v_ch_a_on  : std_logic;
--variable v_ch_b_on  : std_logic;
--variable v_rect_on  : std_logic;
--variable v_ch_a     : std_logic;
--variable v_ch_b     : std_logic;
--variable v_wdata    : std_logic_vector(31 downto 0);
--begin
--
--    if (filt_on = 1) then
--        v_filt_on   := '1';
--    else
--        v_filt_on   := '0';
--    end if;
--
--    if (ch_a_on = 1) then
--        v_ch_a_on   := '1';
--    else
--        v_ch_a_on   := '0';
--    end if;
--
--    if (ch_b_on = 1) then
--        v_ch_b_on   := '1';
--    else
--        v_ch_b_on   := '0';
--    end if;
--
--    if (rect_on = 1) then
--        v_rect_on   := '1';
--    else
--        v_rect_on   := '0';
--    end if;
--
--    v_wdata := "00000000000000" 
--               & std_logic_vector(to_unsigned(ch_b,6)) 
--               & "00"
--               & std_logic_vector(to_unsigned(ch_a,6))
--               & v_rect_on & v_ch_b_on & v_ch_a_on & v_filt_on;
--    return v_wdata;
--
--end filter_setup;


signal tied_low             : std_logic;
signal tied_high            : std_logic;

signal cpuint_rd            : std_logic;
signal cpuint_wr            : std_logic;
signal cpuint_addr          : std_logic_vector(15 downto 0);
signal cpuint_din           : std_logic_vector(31 downto 0);
signal cpuint_dout_dv       : std_logic;
signal cpuint_dout          : std_logic_vector(31 downto 0);

constant C_SAMPLE_DELAY     : integer := 1000;

begin

    tied_low    <= '0';
    tied_high   <= '1';
    debug       <= (others=>'0');
    txd         <= tied_high;

    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    pr_cpuint : process
    variable v_wdata            : std_logic_vector(31 downto 0); 
    variable v_delay_cyc        : integer := C_SAMPLE_DELAY; 
    variable v_addr             : integer range 0 to 65535; 
    variable v_addr_loop_begin  : integer range 0 to 255; 
    variable v_addr_loop_end    : integer range 0 to 255; 
    begin

        wait until rising_edge(clk);
        wait until reset = '0';

        cpuint_addr    <= (others=>'0');
        cpuint_din     <= (others=>'0');
        cpuint_wr      <= '0';
        cpuint_rd      <= '0';

        for I in 0 to 10 loop
            wait until rising_edge(clk);
        end loop;

        cpu_print_msg("** Testing Intan ADC interface ** ");

        -- Load MCU interface registers
        cpu_print_msg("Set PARC interface to lowest speed using clkdiv register");
        cpu_write(clk, ADR_MCU_CLKDIV, X"0000000F"                  , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);

        -- Load filter registers
        cpu_print_msg("Load filter registers");

        v_wdata := filter_setup(FILT_ON, A_ON , B_OFF, RECT_OFF, 1, 0);
        cpu_write(clk, ADR_FILT_FILTER0, v_wdata                    , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);

        v_wdata := filter_setup(FILT_ON, A_ON , B_OFF, RECT_OFF, 2, 0);
        cpu_write(clk, ADR_FILT_FILTER1, v_wdata                    , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);

        v_wdata := filter_setup(FILT_ON, A_ON , B_OFF, RECT_OFF, 3, 0);
        cpu_write(clk, ADR_FILT_FILTER2, v_wdata                    , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);

        v_wdata := filter_setup(FILT_ON, A_ON , B_ON , RECT_OFF, 1, 2);
        cpu_write(clk, ADR_FILT_FILTER3, v_wdata                    , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);

        v_wdata := filter_setup(FILT_ON, A_ON , B_ON , RECT_OFF, 2, 4);
        cpu_write(clk, ADR_FILT_FILTER4, v_wdata                    , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);

        v_wdata := filter_setup(FILT_ON, A_OFF, B_ON , RECT_OFF, 0, 1);
        cpu_write(clk, ADR_FILT_FILTER5 , v_wdata                   , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);

        v_wdata := filter_setup(FILT_ON, A_OFF, B_ON , RECT_OFF, 1, 2);
        cpu_write(clk, ADR_FILT_FILTER6, v_wdata                    , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);

        v_wdata := filter_setup(FILT_ON , A_ON , B_ON , RECT_ON, 1, 3);
        cpu_write(clk, ADR_FILT_FILTER7, v_wdata                    , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);

        cpu_write(clk, ADR_FILT_SUPPRESS, X"00001234"               , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        cpu_write(clk, ADR_FILT_OUTSEL  , X"00000000"               , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        cpu_write(clk, ADR_FILT_DELAY   , X"00000070"               , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        cpu_write(clk, ADR_FILT_DEBUG   , X"00000000"               , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        cpu_write(clk, ADR_FILT_CTRL    , X"00000000"               , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);

        cpu_print_msg("Load filter coefficients");
        v_wdata := X"00001001";

        for NFILT in 0 to 7 loop
            
            for NCOEFF in OFFS_B0 to OFFS_A2 loop
                v_addr  := NADR_FILT_MEM + (16 * NFILT) + NCOEFF;
                cpu_write(clk, v_addr  , v_wdata    , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
                v_wdata := std_logic_vector(unsigned(v_wdata) + 1);
            end loop;

        end loop;

        -- Program the sequencer table to write a set of registers and then sample some channels
        cpu_print_msg("Load ADC interface ** ");
        v_addr := 0;

        cpu_write(clk, (NADR_ADC_MEM+v_addr), instr_intan_wr(1,1)  , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        v_addr := v_addr + 1;

        cpu_write(clk, (NADR_ADC_MEM+v_addr), instr_intan_wr(2,2)  , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        v_addr := v_addr + 1;

        cpu_write(clk, (NADR_ADC_MEM+v_addr), instr_intan_wr(3,3)  , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        v_addr := v_addr + 1;

        -- Conversion loop
        -- Channels can be sampled 4 times in a loop. If a channel is not sampled in a section of the loop
        -- then its sample instruction is replaced by a dummy read.,
        --
        v_addr_loop_begin  := v_addr; 
        --------------------------------------------------------------------------------------------------------------
        -- Channel 1 sampled 4 times, channel 2 sampled twice, channel 3 sampled once
        --------------------------------------------------------------------------------------------------------------
        cpu_write(clk, (NADR_ADC_MEM+v_addr), instr_intan_convert(1)            , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        v_addr := v_addr + 1;
        cpu_write(clk, (NADR_ADC_MEM+v_addr), instr_intan_convert(2)            , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        v_addr := v_addr + 1;
        cpu_write(clk, (NADR_ADC_MEM+v_addr), instr_intan_convert(3, FLAG_EOG)  , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        v_addr := v_addr + 1;
        cpu_write(clk, (NADR_ADC_MEM+v_addr), instr_intan_rd(40)                , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        v_addr := v_addr + 1;
        cpu_write(clk, (NADR_ADC_MEM+v_addr), instr_intan_rd(40)                , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        v_addr := v_addr + 1;

        cpu_write(clk, (NADR_ADC_MEM+v_addr), instr_delay(v_delay_cyc)          , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        v_addr := v_addr + 1;

        --------------------------------------------------------------------------------------------------------------
        cpu_write(clk, (NADR_ADC_MEM+v_addr), instr_intan_convert(1, FLAG_EOG)  , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        v_addr := v_addr + 1;
        cpu_write(clk, (NADR_ADC_MEM+v_addr), instr_intan_rd(40)                , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        v_addr := v_addr + 1;
        cpu_write(clk, (NADR_ADC_MEM+v_addr), instr_intan_rd(40)                , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        v_addr := v_addr + 1;
        cpu_write(clk, (NADR_ADC_MEM+v_addr), instr_intan_rd(40)                , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        v_addr := v_addr + 1;
        cpu_write(clk, (NADR_ADC_MEM+v_addr), instr_intan_rd(40)                , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        v_addr := v_addr + 1;

        cpu_write(clk, (NADR_ADC_MEM+v_addr), instr_delay(v_delay_cyc)          , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        v_addr := v_addr + 1;

        --------------------------------------------------------------------------------------------------------------
        cpu_write(clk, (NADR_ADC_MEM+v_addr), instr_intan_convert(1)            , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        v_addr := v_addr + 1;
        cpu_write(clk, (NADR_ADC_MEM+v_addr), instr_intan_convert(2, FLAG_EOG)  , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        v_addr := v_addr + 1;
        cpu_write(clk, (NADR_ADC_MEM+v_addr), instr_intan_rd(40)                , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        v_addr := v_addr + 1;
        cpu_write(clk, (NADR_ADC_MEM+v_addr), instr_intan_rd(40)                , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        v_addr := v_addr + 1;
        cpu_write(clk, (NADR_ADC_MEM+v_addr), instr_intan_rd(40)                , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        v_addr := v_addr + 1;

        cpu_write(clk, (NADR_ADC_MEM+v_addr), instr_delay(v_delay_cyc)          , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        v_addr := v_addr + 1;

        --------------------------------------------------------------------------------------------------------------
        cpu_write(clk, (NADR_ADC_MEM+v_addr), instr_intan_convert(1, FLAG_EOF)  , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        v_addr := v_addr + 1;
        cpu_write(clk, (NADR_ADC_MEM+v_addr), instr_intan_rd(40)                , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        v_addr := v_addr + 1;
        cpu_write(clk, (NADR_ADC_MEM+v_addr), instr_intan_rd(40)                , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        v_addr := v_addr + 1;
        cpu_write(clk, (NADR_ADC_MEM+v_addr), instr_intan_rd(40)                , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        v_addr := v_addr + 1;
        cpu_write(clk, (NADR_ADC_MEM+v_addr), instr_intan_rd(40)                , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        v_addr := v_addr + 1;

        cpu_write(clk, (NADR_ADC_MEM+v_addr), instr_delay(v_delay_cyc)          , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        v_addr_loop_end := v_addr; 

        for I in 0 to 10 loop
            wait until rising_edge(clk);
        end loop;


        --------------------------------------------------------------------------------------------------------------
        -- Program interface registers 
        --------------------------------------------------------------------------------------------------------------
        cpu_write(clk, ADR_ADC_CTRL         , X"00000000", cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);   -- Turn off test mode
        v_wdata := X"0000" & std_logic_vector(to_unsigned(v_addr_loop_end,8)) & std_logic_vector(to_unsigned(v_addr_loop_begin,8));
        cpu_write(clk, ADR_ADC_LOOP         , v_wdata    , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);   -- 

        cpu_write(clk, ADR_ADC_DELAY        , X"00000003", cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);   -- 
        cpu_write(clk, ADR_ADC_DEBUG        , X"00000001", cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);   -- 


        -- Clear the sequencer reset and set loop mode
        cpu_write(clk, ADR_ADC_CTRL, X"00000000", cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);    -- 
           

        wait;
    end process;


    -------------------------------------------------------------------------------
    -- Decode upper address bits.
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

            cpu_rd      <= cpuint_rd;
            cpu_wr      <= cpuint_wr;
            cpu_addr    <= "0000" & cpuint_addr(11 downto 0);
            cpu_din     <= cpuint_din;

            cpu_sels    <= (others=>'0');

            if (cpuint_rd='1' or cpuint_wr='1') then
                cpu_sels(to_integer(unsigned(cpuint_addr(15 downto 12)))) <= '1';
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

            cpuint_dout_dv  <= '0'; 
            cpuint_dout     <= (others=>'0'); 

        elsif rising_edge(clk) then
            v_cpu_dout      := (others=>'0');
            v_cpu_dout_dv   := '0';
            
            for I in 0 to C_NUM_BLOCKS-1 loop
                
                v_cpu_dout_dv  := v_cpu_dout_dv or arr_cpu_dout_dv(I);
                v_cpu_dout     := v_cpu_dout    or arr_cpu_dout(I);

            end loop;

            cpuint_dout_dv  <= v_cpu_dout_dv;
            cpuint_dout     <= v_cpu_dout;

        end if;

    end process;
        
end code_adc_intan;
