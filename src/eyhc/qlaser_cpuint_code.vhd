-------------------------------------------------------------------------------
-- Copyright (c) 2023 by GJED, Seattle, WA
-- Confidential - All rights reserved
-------------------------------------------------------------------------------
-- File       : qlaser_cpuint_code.vhd
--
-- Contains code to generate CPU bus transactions as if they were received by the UART
-- No UART 
--
-- Writes to DC ADC and AC pulse blocks
-------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.qlaser_pkg.all;
use     work.qlaser_dac_dc_pkg.all  -- Address map
use     work.qlaser_dac_ac_pkg.all  -- Address map

use     work.tb_qlaser_pkg.all;     -- CPU bus functions


entity qlaser_cpuint is
port (
    clk             : in  std_logic;
    reset           : in  std_logic;
    tick_msec       : in  std_logic;    -- Used to reset interface if a message is corrupted

    -- RS232 serial interface
    rxd             : in  std_logic;    -- UART Receive data
    txd             : out std_logic;    -- UART Transmit data 

    -- CPU interface signals
    cpu_rd          : out std_logic;
    cpu_wr          : out std_logic;
    cpu_sels        : out std_logic_vector(C_NUM_BLOCKS-1 downto 0); -- Decoded from upper 4-bits of addresses
    cpu_addr        : out std_logic_vector(15 downto 0);
    cpu_din         : out std_logic_vector(31 downto 0);

    arr_cpu_dout_dv : in  std_logic_vector(C_NUM_BLOCKS-1 downto 0);
    arr_cpu_dout    : in  t_arr_cpu_dout;

    debug           : out std_logic_vector( 3 downto 0)
);
end qlaser_cpuint;

architecture code of qlaser_cpuint is

signal tied_low             : std_logic;
signal tied_high            : std_logic;

signal cpuint_rd            : std_logic;
signal cpuint_wr            : std_logic;
signal cpuint_addr          : std_logic_vector(15 downto 0);
signal cpuint_din           : std_logic_vector(31 downto 0);
signal cpuint_dout_dv       : std_logic;
signal cpuint_dout          : std_logic_vector(31 downto 0);

constant NUM_DAC_PULSE      : integer := 16;
constant C_SPI_MSG_CLKS     : integer := 64;    -- Number of clock cycles for a SPI message to be sent

begin

    tied_low    <= '0';
    tied_high   <= '1';
    debug       <= (others=>'0');
    txd         <= tied_high;


    -------------------------------------------------------------------------------
    -- Main prcess
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

        cpu_print_msg("** Testing DC ADC SPI interfaces ** ");


        -- Initialize interface to DC DAC PMOD
        cpu_write(clk, ADR_DAC_DC_ALL       , X"00000000"               , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        cpu_delay(C_SPI_MSG_CLKS);
        cpu_write(clk, ADR_DAC_DC_IREF      , X"00000000"               , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        cpu_delay(C_SPI_MSG_CLKS);
        cpu_write(clk, ADR_DAC_DC_POWER_ON  , X"00000000"               , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
        cpu_delay(C_SPI_MSG_CLKS);

        cpu_print_msg("Load SPI interface to DC ADCs");
        v_wdata     := X"00000001";
        v_addr_spi0 := C_ADDR_SPI0;
        v_addr_spi1 := C_ADDR_SPI1;
        v_addr_spi2 := C_ADDR_SPI2;
        v_addr_spi3 := C_ADDR_SPI3;
        
        
        ----------------------------------------------------------------------------------------------------
        -- Write 32 DC SPI data values to four interfaces at one time
        ----------------------------------------------------------------------------------------------------
        for N in 0 (to NUM_DAC_DC/4)-1 loop
        
                cpu_write(clk, v_addr_spi0  , v_wdata    , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
                v_wdata := v_wdata + 1;
                cpu_write(clk, v_addr_spi1  , v_wdata    , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
                v_wdata := v_wdata + 1;
                cpu_write(clk, v_addr_spi2  , v_wdata    , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
                v_wdata := v_wdata + 1;
                cpu_write(clk, v_addr_spi3  , v_wdata    , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
                v_wdata := v_wdata + 1;
                
                v_addr_spi0 := v_addr_spi0 + 1;
                v_addr_spi1 := v_addr_spi1 + 1;
                v_addr_spi2 := v_addr_spi2 + 1;
                v_addr_spi3 := v_addr_spi3 + 1;
   
        end loop;

        ----------------------------------------------------------------------------------------------------
        -- Each Pulse channel has a 16 x 40 bit RAM holding a set of [delay[23:0], level[15:0]] values
        ----------------------------------------------------------------------------------------------------
        for N in 0 to NUM_DAC_PULSE-1 loop
            
                v_addr  := NADR_FILT_MEM + (16 * NFILT) + OFFS_B0;
                cpu_write(clk, v_addr  , v_wdata    , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
                v_wdata := std_logic_vector(unsigned(v_wdata) + 1);

                v_addr  := NADR_FILT_MEM + (16 * NFILT) + OFFS_B1;
                cpu_write(clk, v_addr  , v_wdata    , cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
                v_wdata := std_logic_vector(unsigned(v_wdata) + 1);

                v_addr  := NADR_FILT_MEM + (16 * NFILT) + OFFS_B2;
                cpu_write(clk, v_addr  , X"00000000", cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
                v_wdata := std_logic_vector(unsigned(v_wdata) + 1);

                v_addr  := NADR_FILT_MEM + (16 * NFILT) + OFFS_A1;
                cpu_write(clk, v_addr  , X"00000000", cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
                v_wdata := std_logic_vector(unsigned(v_wdata) + 1);

                v_addr  := NADR_FILT_MEM + (16 * NFILT) + OFFS_A2;
                cpu_write(clk, v_addr  , X"00000000", cpuint_rd, cpuint_wr, cpuint_addr, cpuint_din);
                v_wdata := std_logic_vector(unsigned(v_wdata) + 1);

            

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
    -- Decode upper address bits into chip selects (cpu_sels(n downto 0))
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
        
end code;
