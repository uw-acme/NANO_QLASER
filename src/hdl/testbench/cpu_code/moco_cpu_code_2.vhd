-------------------------------------------------------------------------------
-- Copyright (c) 2015 by GJED, Seattle, WA
-- Confidential - All rights reserved
-------------------------------------------------------------------------------
-- File       : moco_cpu_code_2.vhd
-- Contains code to generate and CPU bus transactions.
--
-- Copy J.M.'s test instructions  11/24/15
-------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.gj_cpu_pkg.all;
use     work.moco_fpga_pkg.all;   -- CPU functions

library std_developerskit;
use     std_developerskit.std_iopak.all;

use     work.gj_cpu_pkg.all;
use     work.gj_cpu_bfm_pkg.all;

architecture code_2 of gj_cpu is


signal clk          : std_logic;
signal reset        : std_logic;
signal cpubus       : trec_cpubus;
signal str_testname : string(1 to LENGTH_TESTNAME);
signal str_filename : string(1 to 9) := "code_2   ";

signal rdat         : std_logic_vector(31 downto 0);
signal spi_interrupt: std_logic;

signal gpin         : std_logic_vector(NUM_CPU_GPIO-1 downto 0);
signal gpout        : std_logic_vector(NUM_CPU_GPIO-1 downto 0);

signal tied_low     : std_logic;
signal tied_high    : std_logic;
signal delay        : integer range 0 to 4095; 
signal tbl_addr     : integer range 0 to 255; 

begin

    tied_low        <= '0';
    tied_high       <= '1';
    clk             <= clk_i;
    reset           <= reset_i;
    cpubus.ack      <= ack_i;
    cpubus.idat     <= dat_i;
    dat_o           <= cpubus.odat when cpubus.wr = '1' else (others=>'0');

    spi_interrupt   <= interrupts_i(0);

    ----------------------------------------------------------------------------------
    -- Convert the bidir gpio bus ports into separate in and out signals.
    ----------------------------------------------------------------------------------
    pr_drv_gpio : process(gpout)
    begin
        for I in 0 to NUM_CPU_GPIO-1 loop
            if (gpout(I)='0' or gpout(I)='1') then
                gp_io(I)    <= gpout(I);
            else
                gp_io(I)    <= 'Z';
            end if;
        end loop;
    end process;
    gpin            <= gp_io;

    csbus_o         <= cpubus.cs;
    rd_o            <= cpubus.rd;
    wr_o            <= cpubus.wr;
    addr_o          <= cpubus.adr;


    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    pr_cpu : process
    variable v_wdata            : std_logic_vector(31 downto 0); 
    variable v_delay_cyc        : integer := 10; 
    variable v_addr             : integer range 0 to 65535; 
    variable v_addr_loop_begin  : integer range 0 to 255; 
    variable v_addr_loop_end    : integer range 0 to 255; 
    begin

        done_o      <= false;

        cpu_bfm_reset(clk, cpubus, gpout);

        wait until reset_i = '0' or reset_i = 'L';
        wait for 1 us;

        -- Set the reset. Should already be on.
        cpu_bfm_write(clk, ADR_REG_CTRL     , X"0001", cpubus);
        cpu_bfm_test (clk, ADR_REG_CTRL              , cpubus, X"0001", "test ctrl_reset set");

        -- Load command data and device ADC 
        --cpu_bfm_write(clk, ADR_REG_CMD_DATA0, X"8001", cpubus);
        --cpu_bfm_write(clk, ADR_REG_CMD_DATA1, X"0765", cpubus);
        --spi_transmit(clk, spi_interrupt                  , cpubus);

        -- Set the reset. CPU mode off.
        cpu_bfm_write(clk, ADR_REG_CTRL     , X"0001", cpubus);

        -- ADC Refdac init
        cpu_bfm_write(clk, ADR_TABLE + 0    , X"1002", cpubus);     -- 16-bit command
        cpu_bfm_write(clk, ADR_TABLE + 1    , X"0000", cpubus);     -- device 0
        cpu_bfm_write(clk, ADR_TABLE + 2    , X"03FF", cpubus);     -- 16-bit command
        cpu_bfm_write(clk, ADR_TABLE + 3    , X"0000", cpubus);
        cpu_bfm_write(clk, ADR_TABLE + 4    , X"1005", cpubus);     -- 16-bit command
        cpu_bfm_write(clk, ADR_TABLE + 5    , X"0000", cpubus);
        cpu_bfm_write(clk, ADR_TABLE + 6    , X"03FF", cpubus);     -- 16-bit command
        cpu_bfm_write(clk, ADR_TABLE + 7    , X"0000", cpubus);
        -- Pause command
        cpu_bfm_write(clk, ADR_TABLE + 8    , X"0000", cpubus);     -- n/a
        cpu_bfm_write(clk, ADR_TABLE + 9    , X"9000", cpubus);     -- Pause command

        ------------------------------------------------------------
        -- Start of main loop
        ------------------------------------------------------------
        -- Load the table with 4 ADC reads
         -- tx_message      <= reg_cmd_data(27 downto  0);
         -- tx_device       <= reg_cmd_data(30 downto 28);

        cpu_bfm_write(clk, ADR_TABLE + 10    , X"1002", cpubus);     -- 16-bit command
        cpu_bfm_write(clk, ADR_TABLE + 11    , X"0000", cpubus);     -- device 0
        cpu_bfm_write(clk, ADR_TABLE + 12    , X"8002", cpubus);     -- 16-bit command
        cpu_bfm_write(clk, ADR_TABLE + 13    , X"0000", cpubus);
        cpu_bfm_write(clk, ADR_TABLE + 14    , X"8003", cpubus);     -- 16-bit command
        cpu_bfm_write(clk, ADR_TABLE + 15    , X"0000", cpubus);
        cpu_bfm_write(clk, ADR_TABLE + 16    , X"8004", cpubus);     -- 16-bit command
        cpu_bfm_write(clk, ADR_TABLE + 17    , X"0000", cpubus);

        -- ADLX : Read 5 regs to get 4 data values
		--v_data := X"0000B200"; 	 -- Read, Address 0x32, Data 00
        cpu_bfm_write(clk, ADR_TABLE + 18   , X"B200", cpubus);     -- Low part of 27-bit command
        cpu_bfm_write(clk, ADR_TABLE + 19   , X"1000", cpubus);     -- Device 1 and upper part of 27-bit command

        cpu_bfm_write(clk, ADR_TABLE + 20   , X"B300", cpubus);     -- Low part of 27-bit command
        cpu_bfm_write(clk, ADR_TABLE + 21   , X"2000", cpubus);     -- Device 2
        cpu_bfm_write(clk, ADR_TABLE + 22   , X"B400", cpubus);     -- Low part of 27-bit command
        cpu_bfm_write(clk, ADR_TABLE + 23   , X"3000", cpubus);     -- Device 3
        cpu_bfm_write(clk, ADR_TABLE + 24   , X"B500", cpubus);     -- Low part of 27-bit command
        cpu_bfm_write(clk, ADR_TABLE + 25   , X"4000", cpubus);     -- Device 4

        -- Pause command
        cpu_bfm_write(clk, ADR_TABLE + 26    , X"0000", cpubus);     -- n/a
        cpu_bfm_write(clk, ADR_TABLE + 27    , X"9000", cpubus);     -- Pause command


        -- Set up the loop boundaries 32-bit readout. Addr 0 to 21/2 = 0 to 10
        cpu_bfm_write(clk, ADR_REG_LOOP     , X"0D05", cpubus);

        -- Set the trigger interval. Trigger occurs every N microseconds. 
        -- 0xFF = 255 usec and means that the sequencer loop will run every 255 usec
        cpu_bfm_write(clk, ADR_REG_TRIG_RATE, X"00FF", cpubus); 

        -- Release the reset. CPU mode off.
        cpu_bfm_write(clk, ADR_REG_CTRL     , X"0000", cpubus);

        done_o      <= true;
        wait;
    end process;


        
end code_2;

