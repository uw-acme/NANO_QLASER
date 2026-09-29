---------------------------------------------------------------
--  File         : switch_axis_16bx32.vhdl
--  Description  : A switch block to allow the output of any one
--                 of 32 channels of 16-bit pulse generators to
--                 be sent to any one of the two 16-channel JESD
--                 interface blocks
--
-- there are 16 DACs on each FMC0 or FMC1 JESD interface. 
-- Channels 0-15 can be muxed to any FMC0 DAC.
-- Channels 16-31 can be muxed to any FMC1 DAC.
-- Output values can be passed (muxed), passed inverted (to compensate for
-- FMC216 inversions) or zeroed.
----------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     ieee.std_logic_misc.all;

use     work.qlaser_pkg.all;


---------------------------------------------------------------------------
-- Switch
---------------------------------------------------------------------------
entity switch_axis_16bx32 is
port (
    reset                   : in  std_logic;
    clk                     : in  std_logic; 

    -- CPU interface
    cpu_addr                : in  std_logic_vector(11 downto 0);    -- Address input
    cpu_wdata               : in  std_logic_vector(31 downto 0);    -- Data input
    cpu_wr                  : in  std_logic;                        -- Write enable 
    cpu_sel                 : in  std_logic;                        -- Block select
    cpu_rdata               : out std_logic_vector(31 downto 0);    -- Data output
    cpu_rdata_dv            : out std_logic;                        -- Acknowledge output

    -- AXI-stream input array of 32 16-bit streams
    dacs_pulse_axis_treadys : out std_logic_vector(31 downto 0);     -- axi_stream ready to upstream module 
    dacs_pulse_axis_tdatas  : in  t_arr_slv32x16b;                   -- axi stream output data array
    dacs_pulse_axis_tvalids : in  std_logic_vector(31 downto 0);     -- axi_stream output data valid
    dacs_pulse_axis_tlasts  : in  std_logic_vector(31 downto 0);     -- axi_stream output set on last data  

    ---------------------------------------------------------------------------
    -- AXI-stream output 2 256-bit streams, one for each JESD block
    ---------------------------------------------------------------------------
    -- FMC0 JESD interface 
    axis_fmc0_tready        : in  std_logic;                        -- axi_stream ready from downstream module
    axis_fmc0_tdata         : out std_logic_vector(255 downto 0);   -- axi stream output data
    axis_fmc0_tvalid        : out std_logic;                        -- axi_stream output data valid
    axis_fmc0_tlast         : out std_logic;                        -- axi_stream output set on last data  

    -- FMC1 JESD interface 
    axis_fmc1_tready        : in  std_logic;                        -- axi_stream ready from downstream module
    axis_fmc1_tdata         : out std_logic_vector(255 downto 0);   -- axi stream output data
    axis_fmc1_tvalid        : out std_logic;                        -- axi_stream output data valid
    axis_fmc1_tlast         : out std_logic                         -- axi_stream output set on last data  
);
end entity;


----------------------------------------------------------------
-- Channels 0-15 can be muxed to any FMC0 DAC.
-- Channels 16-31 can be muxed to any FMC1 DAC.
-- Output values can be passed (muxed), passed inverted (to compensate for
-- FMC216 inversions) or zeroed.
-- Single cycle delay
----------------------------------------------------------------
architecture rtl of switch_axis_16bx32 is

signal reg_invert       : std_logic_vector(31 downto 0);
signal reg_zero         : std_logic_vector(31 downto 0);
type t_arr_reg_muxsel   is array (0 to 31) of std_logic_vector(3 downto 0); 
signal arr_reg_muxsel   : t_arr_reg_muxsel; 

constant C_ID_SWITCH    : std_logic_vector(31 downto 0) := X"55000001";     -- Meaningless number just to test block reg access

begin

    -- Always accept data
    dacs_pulse_axis_treadys <= (others=>'1');


    ----------------------------------------------------------------
    -- AXI-Stream switch to JESD_0.
    ----------------------------------------------------------------
    pr_fmc0_axi_s   : process (reset, clk)
    begin

        if (reset = '1') then

            axis_fmc0_tdata     <= (others=>'0');   -- axi_stream output data
            axis_fmc0_tvalid    <= '0';             -- axi_stream output data valid
            axis_fmc0_tlast     <= '0';

        elsif rising_edge(clk) then

            -- Switch for FMC0 JESD interface 16 x 16b
            for N in 0 to 15 loop

                if (reg_zero(N) = '1') then
                    if (reg_invert(N) = '1') then
                        axis_fmc0_tdata(16*(N+1)-1 downto 16*N)         <= (others=>'1'); 
                    else
                        axis_fmc0_tdata(16*(N+1)-1 downto 16*N)         <= (others=>'0'); 
                    end if;
                else
                    if (reg_invert(N) = '1') then
                        axis_fmc0_tdata(16*(N+1)-1 downto 16*N)         <= not(dacs_pulse_axis_tdatas(to_integer(unsigned(arr_reg_muxsel(N)))));   
                    else
                        axis_fmc0_tdata(16*(N+1)-1 downto 16*N)         <= dacs_pulse_axis_tdatas(to_integer(unsigned(arr_reg_muxsel(N))));   
                    end if;
                end if;

                axis_fmc0_tvalid  	<= dacs_pulse_axis_tvalids(N);
                axis_fmc0_tlast   	<= dacs_pulse_axis_tlasts(N); 
                
            end loop;

        end if;
    end process;


    ----------------------------------------------------------------
    -- AXI-Stream switch to JESD_1.
    ----------------------------------------------------------------
    pr_fmc1_axi_s   : process (reset, clk)
    begin

        if (reset = '1') then

            axis_fmc1_tdata     <= (others=>'0');   -- axi_stream output data
            axis_fmc1_tvalid    <= '0';             -- axi_stream output data valid
            axis_fmc1_tlast     <= '0';

        elsif rising_edge(clk) then

            -- Switch for FMC1 JESD interface 16 x 16b
            for N in 0 to 15  loop
            
                if (reg_zero(N+16) = '1') then
                    if (reg_invert(N+16) = '1') then
                        axis_fmc1_tdata(16*(N+1)-1 downto 16*N) <= (others=>'1'); 
                    else
                        axis_fmc1_tdata(16*(N+1)-1 downto 16*N) <= (others=>'0'); 
                    end if;
                else
                    if (reg_invert(N+16) = '1') then
                        axis_fmc1_tdata(16*(N+1)-1 downto 16*N) <= not(dacs_pulse_axis_tdatas(to_integer(unsigned(arr_reg_muxsel(N+16)))+16));   
                    else
                        axis_fmc1_tdata(16*(N+1)-1 downto 16*N) <=     dacs_pulse_axis_tdatas(to_integer(unsigned(arr_reg_muxsel(N+16)))+16);   
                    end if;
                end if;
                
                axis_fmc1_tvalid  	<= dacs_pulse_axis_tvalids(N+16);
                axis_fmc1_tlast   	<= dacs_pulse_axis_tlasts(N+16); 

            end loop;

        end if;
    end process;


    ----------------------------------------------------------------
    -- CPU Read/Write 
    ----------------------------------------------------------------
    pr_ram_rw  : process (reset, clk)
    begin
        if (reset = '1') then
        
            cpu_rdata           <= (others=>'0');
            cpu_rdata_dv        <= '0'; 

            -- Default 
            -- Channels 0-15 to FMC0 lanes 0-15.
            -- Channels 16-31 to FMC1 lanes 0-15.
            for I in 0 to 15 loop
                arr_reg_muxsel(I)       <= std_logic_vector(to_unsigned(I, 4));
                arr_reg_muxsel(I+16)    <= std_logic_vector(to_unsigned(I, 4));
            end loop;
            
            reg_invert          <= (others=>'0');   -- No inversion
            reg_zero            <= (others=>'0');   -- No zeroing

        elsif rising_edge(clk) then
        
            -------------------------------------------------
            -- CPU write
            -- ADDR_SW_MUX7_0    X"000"
            -- ADDR_SW_MUX15_8   X"001"
            -- ADDR_SW_MUX23_16  X"002"
            -- ADDR_SW_MUX31_24  X"003"
            -- ADDR_SW_INV       X"004"
            -- ADDR_SW_ZERO      X"005"
            -------------------------------------------------
            if (cpu_wr = '1') and (cpu_sel = '1') then
            
                case cpu_addr is

                    when X"000" =>  arr_reg_muxsel( 0)  <= cpu_wdata( 3 downto  0);
                                    arr_reg_muxsel( 1)  <= cpu_wdata( 7 downto  4);
                                    arr_reg_muxsel( 2)  <= cpu_wdata(11 downto  8);
                                    arr_reg_muxsel( 3)  <= cpu_wdata(15 downto 12);
                                    arr_reg_muxsel( 4)  <= cpu_wdata(19 downto 16);
                                    arr_reg_muxsel( 5)  <= cpu_wdata(23 downto 20);
                                    arr_reg_muxsel( 6)  <= cpu_wdata(27 downto 24);
                                    arr_reg_muxsel( 7)  <= cpu_wdata(31 downto 28);

                    when X"001" =>  arr_reg_muxsel( 8)  <= cpu_wdata( 3 downto  0);
                                    arr_reg_muxsel( 9)  <= cpu_wdata( 7 downto  4);
                                    arr_reg_muxsel(10)  <= cpu_wdata(11 downto  8);
                                    arr_reg_muxsel(11)  <= cpu_wdata(15 downto 12);
                                    arr_reg_muxsel(12)  <= cpu_wdata(19 downto 16);
                                    arr_reg_muxsel(13)  <= cpu_wdata(23 downto 20);
                                    arr_reg_muxsel(14)  <= cpu_wdata(27 downto 24);
                                    arr_reg_muxsel(15)  <= cpu_wdata(31 downto 28);

                    when X"002" =>  arr_reg_muxsel(16)  <= cpu_wdata( 3 downto  0);
                                    arr_reg_muxsel(17)  <= cpu_wdata( 7 downto  4);
                                    arr_reg_muxsel(18)  <= cpu_wdata(11 downto  8);
                                    arr_reg_muxsel(19)  <= cpu_wdata(15 downto 12);
                                    arr_reg_muxsel(20)  <= cpu_wdata(19 downto 16);
                                    arr_reg_muxsel(21)  <= cpu_wdata(23 downto 20);
                                    arr_reg_muxsel(22)  <= cpu_wdata(27 downto 24);
                                    arr_reg_muxsel(23)  <= cpu_wdata(31 downto 28);

                    when X"003" =>  arr_reg_muxsel(24)  <= cpu_wdata( 3 downto  0);
                                    arr_reg_muxsel(25)  <= cpu_wdata( 7 downto  4);
                                    arr_reg_muxsel(26)  <= cpu_wdata(11 downto  8);
                                    arr_reg_muxsel(27)  <= cpu_wdata(15 downto 12);
                                    arr_reg_muxsel(28)  <= cpu_wdata(19 downto 16);
                                    arr_reg_muxsel(29)  <= cpu_wdata(23 downto 20);
                                    arr_reg_muxsel(30)  <= cpu_wdata(27 downto 24);
                                    arr_reg_muxsel(31)  <= cpu_wdata(31 downto 28);

                    when X"004" =>  reg_invert  <= cpu_wdata(31 downto 0);
                    when X"005" =>  reg_zero    <= cpu_wdata(31 downto 0);

                    when others =>  null;
                end case;

            -------------------------------------------------
            -- CPU read
            -------------------------------------------------
            elsif (cpu_wr = '0') and (cpu_sel = '1') then
                
                case cpu_addr is
                    when X"000" =>  cpu_rdata   <= arr_reg_muxsel( 7) & arr_reg_muxsel( 6) & arr_reg_muxsel( 5) & arr_reg_muxsel( 4)
                                                 & arr_reg_muxsel( 3) & arr_reg_muxsel( 2) & arr_reg_muxsel( 1) & arr_reg_muxsel( 0);
                    when X"001" =>  cpu_rdata   <= arr_reg_muxsel(15) & arr_reg_muxsel(14) & arr_reg_muxsel(13) & arr_reg_muxsel(12)
                                                 & arr_reg_muxsel(11) & arr_reg_muxsel(10) & arr_reg_muxsel( 9) & arr_reg_muxsel( 8);
                    when X"002" =>  cpu_rdata   <= arr_reg_muxsel(23) & arr_reg_muxsel(22) & arr_reg_muxsel(21) & arr_reg_muxsel(20)
                                                 & arr_reg_muxsel(19) & arr_reg_muxsel(18) & arr_reg_muxsel(17) & arr_reg_muxsel(16);
                    when X"003" =>  cpu_rdata   <= arr_reg_muxsel(31) & arr_reg_muxsel(30) & arr_reg_muxsel(29) & arr_reg_muxsel(28)
                                                 & arr_reg_muxsel(27) & arr_reg_muxsel(26) & arr_reg_muxsel(25) & arr_reg_muxsel(24);
                    when X"004" =>  cpu_rdata   <= reg_invert;
                    when X"005" =>  cpu_rdata   <= reg_zero;
                    when X"006" =>  cpu_rdata   <= C_ID_SWITCH;
                    when others =>  cpu_rdata   <= X"CCCCCCCC";                    
                end case;
                cpu_rdata_dv    <= '1';     

            else
                cpu_rdata       <= (others=>'0');
                cpu_rdata_dv    <= '0';
            
            end if;
            
        end if;
        
    end process;

end rtl;


