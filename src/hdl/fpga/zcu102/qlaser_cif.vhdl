-----------------------------------------------------------
-- File : qlaser_cif.vhd
-----------------------------------------------------------
-- An adapter between the axi_cpuint bus from the PS and 
-- the CPU bus used in the PL blocks.
-- Converts the ps_cpu_addr byte-address bus into a 32-bit-word address bus.
-- Decodes upper two ps_cpu_addr bits into 4 blocl selects cpu_sels[3:0] 
-- Supports a 14-bit address space (16K x 32-bit) 
-----------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all; 
use     ieee.numeric_std.all;

use     work.qlaser_pkg.all;

entity qlaser_cif is
port(
        clk             : in  std_logic;
        reset           : in  std_logic;

        -- From PS
        ps_clk_cpu      : in  std_logic;
        ps_cpu_addr     : in  std_logic_vector(17 downto 0);
        ps_cpu_wdata    : in  std_logic_vector(31 downto 0);
        ps_cpu_wr       : in  std_logic;
        ps_cpu_rd       : in  std_logic;
        -- to PS
        ps_cpu_rdata    : out std_logic_vector( 31 downto 0);
        ps_cpu_rdata_dv : out std_logic;

        -- to CPU peripherals
        cpu_addr        : out std_logic_vector(15 downto 2);             -- Address to sub-blocks
        cpu_wdata       : out std_logic_vector(31 downto 0);             -- Data input
        cpu_wr          : out std_logic;                                 -- Write enable 
        cpu_sels        : out std_logic_vector(C_NUM_BLOCKS-1 downto 0); -- Block select
        -- from CPU peripherals
        arr_cpu_rdata   : in  t_arr_cpu_dout;                            -- Data output
        arr_cpu_rdata_dv: in  std_logic_vector(C_NUM_BLOCKS-1 downto 0)  -- Acknowledge output
);
end qlaser_cif;

-----------------------------------------------------------
-- This architecture decodes address 17:16 to generate 4 
-- block selects.
-- The Xilinx ARM cores use byte addressing but the CPU 
-- peripherals use 32-bit word addressing so we drop the 
-- lower two address bits from the PS.
-----------------------------------------------------------
architecture rtl_4blk of qlaser_cif is 

signal last_dv  : std_logic;

begin

    -------------------------------------------------------------------------------
    -- Decode upper address bits into block select bits.
    -- Set upper 4 bits of output address to zero.
    -------------------------------------------------------------------------------
    pr_cpubus : process (reset, clk)
    begin

        if (reset = '1') then

            cpu_wr      <= '0';
            cpu_sels    <= (others=>'0');
            cpu_addr    <= (others=>'0');
            cpu_wdata   <= (others=>'0');

        elsif rising_edge(clk) then

            cpu_wr      <= ps_cpu_wr;
            cpu_addr    <= ps_cpu_addr(15 downto 2);
            cpu_wdata   <= ps_cpu_wdata;

            cpu_sels    <= (others=>'0');
            if (ps_cpu_rd='1' or ps_cpu_wr='1') then
                cpu_sels(to_integer(unsigned(ps_cpu_addr(17 downto 16)))) <= '1';
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

            last_dv         <= '0';
            ps_cpu_rdata_dv <= '0';
            ps_cpu_rdata    <= (others=>'0');

        elsif rising_edge(clk) then
        
            v_cpu_dout      := (others=>'0');
            v_cpu_dout_dv   := '0';

            for I in 0 to C_NUM_BLOCKS-1 loop

                v_cpu_dout_dv  := v_cpu_dout_dv or arr_cpu_rdata_dv(I);
                v_cpu_dout     := v_cpu_dout    or arr_cpu_rdata(I);

            end loop;

            -- Set dv high for one clock cycle
            if (last_dv = '0' and v_cpu_dout_dv = '1') then
                ps_cpu_rdata    <= v_cpu_dout;
                ps_cpu_rdata_dv <= '1';
                last_dv         <= '1';
            else
                ps_cpu_rdata    <= (others=>'0');
                ps_cpu_rdata_dv <= '0';
                last_dv         <= '0';
            end if;


        end if;

    end process;

end rtl_4blk;

