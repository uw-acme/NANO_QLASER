---------------------------------------------------------------
--  File         : qlaser_dacs_dc.vhd
--  Description  : DC output control of Qlaser FPGA
--                 Block drives 4 SPI-bus interfaces to 8 channel DAC boards
--                 Writing to a DAC register starts data transfer to DAC
----------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use work.qlaser_dac_dc_pkg.all;

entity qlaser_dacs_dc is
port (
    clk                 : in  std_logic; 
    reset               : in  std_logic;

    busy                : out std_logic_vector( 3 downto 0);    -- Set to '1' while SPI interface is busy

    -- CPU interface
    cpu_addr            : in  std_logic_vector(15 downto 0);    -- Address input
    cpu_wdata           : in  std_logic_vector(31 downto 0);    -- Data input
    cpu_wr              : in  std_logic;                        -- Write enable 
    cpu_sel             : in  std_logic;                        -- Block select
    cpu_rdata           : out std_logic_vector(31 downto 0);    -- Data output
    cpu_rdata_dv        : out std_logic;                        -- Acknowledge output
                   
    -- Interface SPI bus to 8-channel PMOD for DC channels 0-7
    dc0_sclk            : out std_logic;          -- Clock (50 MHz?)
    dc0_mosi            : out std_logic;          -- Master out, Slave in. (Data to DAC)
    dc0_cs_n            : out std_logic          -- Active low chip select (sync_n)

    -- Interface SPI bus to 8-channel PMOD for DC channels 8-15
    --dc1_sclk            : out std_logic;  
    --dc1_mosi            : out std_logic;  
    --dc1_cs_n            : out std_logic;  
    --
    ---- Interface SPI bus to 8-channel PMOD for DC channels 16-23
    --dc2_sclk            : out std_logic;  
    --dc2_mosi            : out std_logic;  
    --dc2_cs_n            : out std_logic;  
    --
    ---- Interface SPI bus to 8-channel PMOD for DC channels 24-31
    --dc3_sclk            : out std_logic; 
    --dc3_mosi            : out std_logic;  
    --dc3_cs_n            : out std_logic  
);
end entity;

---------------------------------------------------------------
-- Dummy architecture with CPU bus to allow bit-level control
-- of outputs
---------------------------------------------------------------
architecture rtl of qlaser_dacs_dc is

--signal reg_debug    : std_logic_vector(31 downto 0); 
signal spi0_tx_message              : std_logic_vector(31 downto 0);
signal spi0_tx_message_dv           : std_logic;
signal spi0_busy                    : std_logic;



begin

    busy(0)        <= spi0_busy; 
    --dc1_sclk    <= reg_debug(3);  
    --dc1_mosi    <= reg_debug(4);  
    --dc1_cs_n    <= reg_debug(5);  
    --dc2_sclk    <= reg_debug(6);  
    --dc2_mosi    <= reg_debug(7);  
    --dc2_cs_n    <= reg_debug(8);  
    --dc3_sclk    <= reg_debug(9); 
    --dc3_mosi    <= reg_debug(10);  
    --dc3_cs_n    <= reg_debug(11); 

    u_spi0: entity work.qlaser_spi
    port map(  
        clk                 => clk,  
        reset               => reset, 
    
        busy                => spi0_busy,
    
        -- Transmit data
        tx_message_dv       => spi0_tx_message_dv,                        -- Start message transmit
        tx_message          => spi0_tx_message,    -- Message data
    
        -- SPI interface 
        spi_sclk            => dc0_sclk,                        -- Serial clock input
        spi_mosi            => dc0_mosi,                        -- Serial data. (Master Out, Slave In)
        spi_sel             => dc0_cs_n                         -- Serial block select
    );
    -------------------------------------------------------
    -- CPU interface.
    -------------------------------------------------------
    pr_cpu : process(clk, reset)
    begin
        if reset = '1' then
            spi0_tx_message <= (others => '0');
        elsif rising_edge(clk) then
          
            spi0_tx_message_dv <= '0';
            
            if cpu_wr = '1' and cpu_addr(15) = '0' then
            
                if cpu_addr(14 downto 10) = C_ADDR_SPI0 then
                    spi0_tx_message <= cpu_wdata;
                    spi0_tx_message_dv <= '1';
                end if;
            
            end if;
        
        end if;
            
    end process;
    --pr_cpu_rw : process (clk)
    --begin
    --
    --    if rising_edge(clk) then
    --
    --        cpu_rdata       <= (others=>'0');
    --        cpu_rdata_dv    <= '0';
    --
    --        if (reset='1') then
    --            reg_debug           <= (others=>'0');
    --            
    --        -- Write registers
    --        elsif (cpu_sel='1' and cpu_wr='1') then
    --
    --            case to_integer(unsigned(cpu_addr(3 downto 0))) is
    --
    --                when  0         => reg_debug         <= cpu_wdata;
    --                when others     => null;
    --            end case;
    --
    --        -- Read registers
    --        elsif (cpu_sel='1' and cpu_wr='0') then
    --
    --            case to_integer(unsigned(cpu_addr(3 downto 0))) is
    --
    --                when   0        => cpu_rdata        <= reg_debug;    
    --                when others     => cpu_rdata        <= X"CCCCCCCC";
    --            end case;
    --            cpu_rdata_dv  <= '1';
    --
    --        end if;
    --
    --    end if;
    --
    --end process;

end rtl;
