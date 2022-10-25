---------------------------------------------------------------
--  File         : qlaser_dacs_dc.vhd
--  Description  : DC output control of Qlaser FPGA
--                 Block drives 4 SPI-bus interfaces to 8 channel DAC boards
--                 Writing to a DAC register starts data transfer to DAC
----------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

entity qlaser_dacs_dc is
port (
    clk                 : in  std_logic; 
    reset               : in  std_logic;

    busy                : out std_logic_vector( 3 downto 0);    -- Set to '1' while SPI interface is busy

    -- CPU interface
    cpu_addr            : in  std_logic_vector(11 downto 0);    -- Address input
    cpu_wdata           : in  std_logic_vector(31 downto 0);    -- Data input
    cpu_wr              : in  std_logic;                        -- Write enable 
    cpu_sel             : in  std_logic;                        -- Block select
    cpu_rdata           : out std_logic_vector(31 downto 0);    -- Data output
    cpu_rdata_dv        : out std_logic;                        -- Acknowledge output
                   
    -- Interface SPI bus to 8-channel PMOD for DC channels 0-7
    dc0_sclk            : out std_logic;          -- Clock (50 MHz?)
    dc0_mosi            : out std_logic;          -- Master out, Slave in. (Data to DAC)
    dc0_cs_n            : out std_logic;          -- Active low chip select (sync_n)

    -- Interface SPI bus to 8-channel PMOD for DC channels 8-15
    dc1_sclk            : out std_logic;  
    dc1_mosi            : out std_logic;  
    dc1_cs_n            : out std_logic;  

    -- Interface SPI bus to 8-channel PMOD for DC channels 16-23
    dc2_sclk            : out std_logic;  
    dc2_mosi            : out std_logic;  
    dc2_cs_n            : out std_logic;  

    -- Interface SPI bus to 8-channel PMOD for DC channels 24-31
    dc3_sclk            : out std_logic; 
    dc3_mosi            : out std_logic;  
    dc3_cs_n            : out std_logic  
);
end entity;

---------------------------------------------------------------
-- Dummy architecture with CPU bus to allow bit-level control
-- of outputs
---------------------------------------------------------------
architecture dummy of qlaser_dacs_dc is

signal reg_debug    : std_logic_vector(31 downto 0); 

begin

    busy        <= (others=>'0');

    dc0_sclk    <= reg_debug(0);  
    dc0_mosi    <= reg_debug(1);  
    dc0_cs_n    <= reg_debug(2);  
    dc1_sclk    <= reg_debug(3);  
    dc1_mosi    <= reg_debug(4);  
    dc1_cs_n    <= reg_debug(5);  
    dc2_sclk    <= reg_debug(6);  
    dc2_mosi    <= reg_debug(7);  
    dc2_cs_n    <= reg_debug(8);  
    dc3_sclk    <= reg_debug(9); 
    dc3_mosi    <= reg_debug(10);  
    dc3_cs_n    <= reg_debug(11); 

    -------------------------------------------------------
    -- CPU interface.
    -------------------------------------------------------
    pr_cpu_rw : process (clk)
    begin
    
        if rising_edge(clk) then

            cpu_rdata       <= (others=>'0');
            cpu_rdata_dv    <= '0';
    
            if (reset='1') then
                reg_debug           <= (others=>'0');
                
            -- Write registers
            elsif (cpu_sel='1' and cpu_wr='1') then
    
                case to_integer(unsigned(cpu_addr(3 downto 0))) is
    
                    when  0         => reg_debug         <= cpu_wdata;
                    when others     => null;
                end case;
    
            -- Read registers
            elsif (cpu_sel='1' and cpu_wr='0') then
    
                case to_integer(unsigned(cpu_addr(3 downto 0))) is

                    when   0        => cpu_rdata        <= reg_debug;    
                    when others     => cpu_rdata        <= X"CCCCCCCC";
                end case;
                cpu_rdata_dv  <= '1';
    
            end if;
    
        end if;
    
    end process;

end dummy;
