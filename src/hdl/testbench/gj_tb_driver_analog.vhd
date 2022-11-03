-----------------------------------------------------------
-- File : gj_tb_driver_analog.vhd
-----------------------------------------------------------
-- Testbench file. Enables CPU to set an analog signal
-- level.
-----------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

entity gj_tb_driver_analog is
port (
    reset           : in  std_logic;
    clk             : in  std_logic;
    ana_default_i   : in  real;

    -- CPU Control interface
    cpu_wr          : in  std_logic;
    cpu_sel         : in  std_logic;
    cpu_addr        : in  std_logic_vector(15 downto 0);
    cpu_din         : in  std_logic_vector(31 downto 0);
    cpu_dout        : out std_logic_vector(31 downto 0);
    cpu_ack         : out std_logic; 

    ana_o           : out real
);
end gj_tb_driver_analog;

-----------------------------------------------------------
-----------------------------------------------------------
architecture rtl of gj_tb_driver_analog is

signal reg_ana      : real;

begin

    ana_o   <= reg_ana;

    -------------------------------------------------------
    -- CPU interface.
    -------------------------------------------------------
    pr_rw : process (clk)
    variable out_string : string(1 to 256);

    begin

        if rising_edge(clk) then

                cpu_dout    <= (others=>'0');
                cpu_ack     <= '0';

            if (reset='1') then	-- real(to_integer(reg_ana))/65536.0
                reg_ana     <=  ana_default_i;
                
            -- Write
            elsif (cpu_sel='1' and cpu_wr='1') then
				-- Real
                reg_ana     <= real(to_integer(unsigned(cpu_din))) / 65536.0;
                cpu_ack     <= '1';

            -- Read
            elsif (cpu_sel='1' and cpu_wr='0') then
                cpu_dout    <= std_logic_vector(to_unsigned(integer(reg_ana * 65536.0),32));
                cpu_ack     <= '1';

            end if;
        end if;
        
    end process;

end;

