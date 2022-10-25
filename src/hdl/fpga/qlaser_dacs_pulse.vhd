---------------------------------------------------------------
--  File         : qlaser_top.vhd
--  Description  : Top-level of Qlaser FPGA
----------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.qlaser_pkg.all;

entity qlaser_dacs_pulse is
port (
        clk               : in  std_logic; 
        reset             : in  std_logic;

        trigger           : in  std_logic;                        -- Trigger (rising edge) to start pulse output
        busy              : out std_logic;                        -- Set to '1' while pulse outputs are occurring

        -- CPU interface
        cpu_addr          : in  std_logic_vector(11 downto 0);    -- Address input
        cpu_wdata         : in  std_logic_vector(31 downto 0);    -- Data input
        cpu_wr            : in  std_logic;                        -- Write enable 
        cpu_sel           : in  std_logic;                        -- Block select
        cpu_rdata         : out std_logic_vector(31 downto 0);    -- Data output
        cpu_rdata_dv      : out std_logic;                        -- Acknowledge output
                       
        -- Pulse train outputs
        dacs_pulse        : out std_logic_vector(31 downto 0)     -- Data output
);
end entity;

---------------------------------------------------------------
-- Dummy architecture with CPU bus to allow bit-level control
-- of outputs
---------------------------------------------------------------
architecture dummy of qlaser_dacs_pulse is

signal reg_pulse    : std_logic_vector(31 downto 0); 

begin

    dacs_pulse  <= reg_pulse;
    busy        <= '0';


    -------------------------------------------------------
    -- CPU interface.
    -------------------------------------------------------
    pr_cpu_rw : process (clk)
    begin
    
        if rising_edge(clk) then

            cpu_rdata       <= (others=>'0');
            cpu_rdata_dv    <= '0';
    
            if (reset='1') then
                reg_pulse           <= (others=>'0');
                
            -- Write registers
            elsif (cpu_sel='1' and cpu_wr='1') then
    
                case to_integer(unsigned(cpu_addr(3 downto 0))) is
    
                    when  0         => reg_pulse         <= cpu_wdata;
                    when others     => null;
                end case;
    
            -- Read registers
            elsif (cpu_sel='1' and cpu_wr='0') then
    
                case to_integer(unsigned(cpu_addr(3 downto 0))) is

                    when   0        => cpu_rdata        <= reg_pulse;    
                    when others     => cpu_rdata        <= X"CCCCCCCC";
                end case;
                cpu_rdata_dv  <= '1';
    
            end if;
    
        end if;
    
    end process;

end dummy;
