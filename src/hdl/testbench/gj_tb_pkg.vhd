-------------------------------------------------------------------------------
-- File       : gj_tb_pkg.vhd
-------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

package gj_tb_pkg is

    constant VERSION            	: std_logic_vector(31 downto 0) := X"00000001";

    constant PARITY_OFF         	: std_logic_vector( 1 downto 0) := "00";
    constant PARITY_EVEN        	: std_logic_vector( 1 downto 0) := "01";
    constant PARITY_ODD         	: std_logic_vector( 1 downto 0) := "11";

    constant C_RESET_DURATION   	: time      :=  10 us; -- 

    -- Clock frequencies expressed in MHz
    constant CLK_FREQ_OSC       	: real      := 8.0;           -- Used for the 'CPU'
    constant CLK_FREQ_P_CLK     	: real      := CLK_FREQ_OSC;  -- FPGA clock (in MHz)

    -- Clock periods
    constant CLK_PER_OSC        	: time      := 1000.0/(CLK_FREQ_OSC) * 1 ns;
    constant CLK_PER_P_CLK      	: time      := 1000.0/(CLK_FREQ_P_CLK) * 1 ns;

    -- Define the number of blocks that are addressed by the CPU
    constant C_NUM_BLOCKS       : integer   := 4; 
    type t_arr_cpu_dout is array (0 to C_NUM_BLOCKS-1) of std_logic_vector(31 downto 0);

    constant CPU_CS0                : integer   := 0; 
    constant CPU_CS1                : integer   := 1; 
    constant CPU_CS2                : integer   := 2; 
    constant CPU_CS3                : integer   := 3; 
    -- Max 16
    
    -- CPU chip selects for testbench blocks
    constant CS_DRV_SERIF           : integer   := CPU_CS0;     -- Serial driver
    constant CS_DRV_GPIO            : integer   := CPU_CS1;     -- GPIO monitor/driver 
    constant CS_DRV_ANALOG          : integer   := CPU_CS2;     -- A/D interface driver 
    
    -------------------------------------------------------------------
    -- Block base addresses
    -------------------------------------------------------------------
    constant ADR_DRV_SERIF_BASE     : unsigned(31 downto 0) := X"0000" & to_unsigned(CS_DRV_SERIF   ,4) & X"000"; 
    constant ADR_DRV_GPIO_BASE      : unsigned(31 downto 0) := X"0000" & to_unsigned(CS_DRV_GPIO    ,4) & X"000"; 
    constant ADR_DRV_ANALOG_BASE    : unsigned(31 downto 0) := X"0000" & to_unsigned(CS_DRV_ANALOG  ,4) & X"000"; 
                                                                                                                                           

    -------------------------------------------------------------------
    -- Serial interface driver register addresses
    -- tx_data is cpu_din(31:0)
    -- tx_addr is cpu_addr(15:0)
    -- A write command is issued when cpu_addr(19:16)= X'0
    -- A read command is issued when cpu_addr(19:16)= X'1
    -------------------------------------------------------------------
    constant ADR_DRV_SERIF_READ     : unsigned(31 downto 0) := unsigned(ADR_DRV_SERIF_BASE) + X"00000"; 
    constant ADR_DRV_SERIF_WRITE    : unsigned(31 downto 0) := unsigned(ADR_DRV_SERIF_BASE) + X"10000"; 
    constant ADR_DRV_SERIF_RATE     : unsigned(31 downto 0) := unsigned(ADR_DRV_SERIF_BASE) + X"20000"; 
    constant ADR_DRV_SERIF_CONFIG   : unsigned(31 downto 0) := unsigned(ADR_DRV_SERIF_BASE) + X"30000"; 
    constant ADR_DRV_SERIF_FORCE_ERR: unsigned(31 downto 0) := unsigned(ADR_DRV_SERIF_BASE) + X"40000"; 



    -- GPIO driver/reader chip selects                                                                                                     
    constant FPGA                   : integer :=  0; 
    constant BOARD                  : integer :=  1;                                                                                               
    constant MAX_GPIO_BLK           : integer :=  1;
	constant CPU                    : integer := 99;  -- Not decoded on the board, used to drive arm_gpio pins 

    -------------------------------------------------------------------
    -- Define CPU triggers
    -------------------------------------------------------------------
    constant TRIG_0                 : integer :=  0;
    constant TRIG_1                 : integer :=  1;
    constant TRIG_2                 : integer :=  2;
    constant TRIG_3                 : integer :=  3;
    constant TRIG_4                 : integer :=  4;
    constant TRIG_5                 : integer :=  5;
    constant TRIG_6                 : integer :=  6;
    constant TRIG_7                 : integer :=  7;

    -------------------------------------------------------------------
    -- CPU interrupt mapping 
    -------------------------------------------------------------------
    constant INTR_SERIF             : integer :=  0;  -- From first testbench RIU driver interface


    -------------------------------------------------------------------
    -- CPU trigger mapping. These is no real difference between the way
    -- an interrupt and a trigger are used. The interrupts are just 
    -- reserved for the real board-level interrupt signals and triggers
    -- are other signals that we want to use to control the CPU code. 
    -------------------------------------------------------------------
    --constant TRIG_XX       : integer := TRIG_0; --

    -------------------------------------------------------------------
    -- An array to allow converting a GPIO block name into a string.
    -------------------------------------------------------------------
    type t_str_lookup2 is array (0 to MAX_GPIO_BLK) of string(1 to 10);
    constant gpio_block_names : t_str_lookup2 := (
        "GPIO_BOARD", 
        "GPIO_FPGA "
    );
	
    -------------------------------------------------------------------
    -- An array to allow converting an interrupt name into a string.
    -------------------------------------------------------------------
    type t_str_lookup_intr is array (0 to 7) of string(1 to 7);
    constant interrupt_names : t_str_lookup_intr := (
        "FPGA   ", 
        "unused1",
        "unused2",
        "unused3",
        "unused4",
        "unused5",
        "unused6",
        "unused7" 
    );


end gj_tb_pkg;






