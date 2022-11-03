-----------------------------------------------------------
-- File : gj_tb_driver_gpio.vhd
-----------------------------------------------------------
-- Testbench file. Enables CPU to set and monitor board-
-- -level signals.
-----------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

--synthesis_off
library std_developerskit;
use     std_developerskit.std_iopak.all;
--synthesis_on

entity gj_tb_driver_gpio is
generic (
    G_GPINMIN       : in    integer := 0;
    G_GPINMAX       : in    integer := 1;
    G_GPOUTMIN      : in    integer := 2;
    G_GPOUTMAX      : in    integer := 3
);
port (
    reset           : in  std_logic;
    clk             : in  std_logic;
    gp_default_i    : in  std_logic_vector(G_GPOUTMAX downto G_GPOUTMIN);

    -- CPU Control interface
    cpu_wr          : in  std_logic; -- write enable
    cpu_sel         : in  std_logic; -- block select
    cpu_addr        : in  std_logic_vector(15 downto 0);
    cpu_din         : in  std_logic_vector(31 downto 0);
    cpu_dout        : out std_logic_vector(31 downto 0);
    cpu_ack         : out std_logic; 

    gp_i            : in  std_logic_vector(G_GPINMAX  downto G_GPINMIN);
    gp_o            : out std_logic_vector(G_GPOUTMAX downto G_GPOUTMIN)
);
end gj_tb_driver_gpio;

-----------------------------------------------------------
-----------------------------------------------------------
architecture rtl of gj_tb_driver_gpio is

signal reg_gpout    : std_logic_vector(G_GPOUTMAX downto G_GPOUTMIN);

begin

    gp_o    <= reg_gpout;

    -------------------------------------------------------
    -- CPU interface.
    -------------------------------------------------------
    pr_rw : process (clk)
    variable nbit       : integer;
    variable out_string : string(1 to 256);

    begin

        if rising_edge(clk) then

            if (reset='1' ) then
                reg_gpout   <= gp_default_i;
                cpu_dout    <= (others=>'0');
                cpu_ack     <= '0';
                
            -- Write a bit
            elsif (cpu_sel='1' and cpu_wr='1') then

                nbit    := to_integer(unsigned(cpu_addr));
                if (nbit >= G_GPINMIN) and (nbit <= G_GPINMAX) then
                    --synthesis_off
                    fprint(out_string, " GPIO : Attempt to set a value on an input, %s\n", to_string(nbit));
                    --synthesis_on
                elsif (nbit >= G_GPOUTMIN) and (nbit <= G_GPOUTMAX) then
                    reg_gpout(nbit)     <= cpu_din(0);
                else
                    --synthesis_off
                    fprint(out_string, " GPIO : Attempt to set non-existent output %s\n", to_string(nbit));
                    report out_string severity error;
                    --synthesis_on
                end if;
                cpu_ack     <= '1';

            -- Read a bit
            elsif (cpu_sel='1' and cpu_wr='0') then
                nbit    := to_integer(unsigned(cpu_addr));
                if (nbit >= G_GPINMIN) and (nbit <= G_GPINMAX) then
                    cpu_dout <= X"0000000" & "000" & gp_i(nbit);
                elsif (nbit >= G_GPOUTMIN) and (nbit <= G_GPOUTMAX) then
                    cpu_dout <= X"0000000" & "000" & reg_gpout(nbit);
                else
                    cpu_dout <= (others=>'0');
                    --synthesis_off
                    fprint(out_string, " GPIO : Attempt to read a non-existent output, %s\n", to_string(nbit));
                    report out_string severity error;
                    --synthesis_on
                end if;
                cpu_ack     <= '1';

            else

                cpu_dout    <= (others=>'0');
                cpu_ack     <= '0';

            end if;
        end if;
        
    end process;

end ;

