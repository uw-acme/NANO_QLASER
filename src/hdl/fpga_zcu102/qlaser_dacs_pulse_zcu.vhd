---------------------------------------------------------------
-- File         : qlaser_dacs_pulse_ch1.vhdl
-- Description  : Single channel pulse output
---------------------------------------------------------------
-- Instantiates single channel pulse generator.
-- Common 24-bit sequence counter.
--
-- Address decoding uses a 32-bit channel select register.
-- Multiple channels can be written at one time but only one channel
-- should be read as channel outputs are or'ed together.
-- This reduces the width of the address bus required to write to 32 channels
-- (13 bits instead of the 18 bits that would be required if there was full 
-- addressing of the 32 channel blocks. 
-- Writing to a particular channel block's RAMs requires first setting
-- a bit in the channel select register 'reg_ch_sel' (see below).
-- This means that the same data can be written to multiple channels 
-- simultaneously by setting multiple bits in the register.
-- For example all channel RAMs can be cleared by setting 0xFFFFFFFF in the
-- register then writing all zero to the RAM addresses.
--
-- Reading must be done by only setting one channel bit in the select register.
-- otherwise the contents of multiple channel's RAM will be or'ed to create the output. 
----------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     ieee.std_logic_misc.all;

use     work.qlaser_pkg.all;

entity qlaser_dacs_pulse is
generic (
    G_NCHANS            : integer := 1      -- Generic that specifies the number of 'full' channels vs number of 'empty' channels
);
port (
    reset               : in  std_logic;
    clk                 : in  std_logic; 

    enable              : in  std_logic;                        -- Set DAC interface is running
    trigger             : in  std_logic;                        -- Rising edge starts pulse generation sequence on enabled channels (trigger)
    jesd_syncs          : in  std_logic_vector(31 downto 0);    -- Inputs from each JESD TX interface

    -- Status signals
    ready               : out std_logic;                        -- Status signal indicating all JESD channels are sync'ed.
    busy                : out std_logic;                        -- Running a waveform generation sequence.
    error               : out std_logic;                        -- Instantanous JESD sync status.
    error_latched       : out std_logic;                        -- JESD lost sync after ready. Cleared by trigger

    -- CPU interface
    cpu_addr            : in  std_logic_vector(12 downto 0);    -- Address input
    cpu_wdata           : in  std_logic_vector(31 downto 0);    -- Data input
    cpu_wr              : in  std_logic;                        -- Write enable 
    cpu_sel             : in  std_logic;                        -- Block select
    cpu_rdata           : out std_logic_vector(31 downto 0);    -- Data output
    cpu_rdata_dv        : out std_logic;                        -- Acknowledge output
     
    -- Array of 32 AXI-Stream buses. Each with 16-bit data. Interface to JESD TX Interfaces
    axis_treadys        : in  std_logic_vector(31 downto 0);    -- axi_stream ready from downstream modules
    axis_tdatas         : out t_arr_slv32x16b;   -- axi stream output data array
    axis_tvalids        : out std_logic_vector(31 downto 0);    -- axi_stream output data valid
    axis_tlasts         : out std_logic_vector(31 downto 0)     -- axi_stream output set on last data  
);
end entity;


----------------------------------------------------------------
-- Instantiates single channel pulse generator.
-- Common 24-bit sequence counter.
-- Address decoding uses a 32-bit channel select register.
----------------------------------------------------------------
architecture ch1 of qlaser_dacs_pulse is

-- Registers.

-- Set max sequence time
signal reg_sequence_len     : std_logic_vector(23 downto 0);

-- CPU bus read/write access register. Selects channel(s) for CPU to write to. Setting X"FFFFFFF" writes to all channels
signal reg_ch_sels          : std_logic_vector(31 downto 0);

-- Enable for each channel to run. Also mask for JESD enables. 
-- Set bit to '1' for each channel with a JESD DAC
signal reg_ch_en            : std_logic_vector(31 downto 0);
signal ch_enables           : std_logic_vector(31 downto 0);

signal reg_status           : std_logic_vector(31 downto 0);    -- Current 'error' and 'busy' flags
signal reg_status_jesd      : std_logic_vector(31 downto 0);    -- Per channel latched JESD loss of sync. Cleared by trigger.


-- State variable type declaration for main state machine
type t_sm_state  is (
    S_RESET ,   -- Wait for 'enable'. Stay here until all JESD interfaces are sync'ed up
    S_IDLE  ,   -- Wait for 'trigger'
    S_RUN       -- Run for cnt_time

);
signal sm_state             : t_sm_state;
signal sm_busy              : std_logic;
-- Counter for clock cycles since trigger
signal sm_cnt_time          : unsigned(23 downto 0);

signal ch_busy              : std_logic_vector(31 downto 0);    -- Signal to indicate that a channel is not idle
signal ch_errs_wave         : t_arr_ac_errors;                  -- Error signal
signal ch_errs_jesd         : std_logic_vector(31 downto 0);    -- JESD not sync'ed
signal busy_i               : std_logic;
signal any_errs_jesd        : std_logic;

signal done_seq             : std_logic;

-- Channel CPU interface
signal cpu_ch_addr          : std_logic_vector(11 downto 0);    -- Address input
signal cpu_ch_wdata         : std_logic_vector(31 downto 0);    -- Data input
signal cpu_ch_wr            : std_logic;                        -- Write enable 
signal cpu_ch_sels          : std_logic_vector(31 downto 0);    -- Block selects
signal cpu_ch_rdatas        : t_arr_slv32x32b;                  -- CPU read data output array
signal cpu_ch_rdata_dvs     : std_logic_vector(31 downto 0);    -- CPU read data valid outputs

signal reg_rdata            : std_logic_vector(31 downto 0);    -- Register Data output
signal reg_rdata_dv         : std_logic;                        -- Register Data valid output

-- Pipeline delays
signal trigger_d1           : std_logic;
signal enable_d1            : std_logic;

signal errs_jesd_latched    : std_logic_vector(31 downto 0);

begin

    -- Combine channel busy signals with state machine busy for output
    busy_i          <= or_reduce(ch_busy) or sm_busy;
    busy            <= busy_i;

    error       	<= any_errs_jesd;
    error_latched   <= or_reduce(errs_jesd_latched);

    -- Set 'ready' when all enabled JESD channels are sync'ed 
    ready           <= not(any_errs_jesd);

    -- Status registers
    reg_status      <= X"000000" & "000" & any_errs_jesd & "000" & busy_i;
    reg_status_jesd <= errs_jesd_latched;


    -------------------------------------------------------------------------------
    -- Invert current jesd sync to make errors
    -- Mask errors in channels that are not enabled
    -- Combine masked errors into a single signal
    -------------------------------------------------------------------------------
    pr_ch_errs_jesd : process (reset, clk)
    begin

        if (reset = '1') then
            ch_errs_jesd    <= (others=>'0');
        elsif rising_edge(clk) then

            for I in 0 to 31 loop
                if (reg_ch_en(I) = '1' and jesd_syncs(I) = '0') then
                    ch_errs_jesd(I)   <= '1';
                else    
                    ch_errs_jesd(I)   <= '0';
                end if;
            end loop;

        end if;
            
        any_errs_jesd   <= or_reduce(ch_errs_jesd);
        
    end process;
	
	
    -------------------------------------------------------------------------------
    -- Create a separate enable for each channel
    -------------------------------------------------------------------------------
    pr_ch_enables : process (reset, clk)
    begin

        if (reset = '1') then
            ch_enables  <= (others=>'0');

        elsif rising_edge(clk) then

            for I in 0 to 31 loop
                if (enable = '1' and reg_ch_en(I) = '1') then
                    ch_enables(I)   <= '1';
                else    
                    ch_enables(I)   <= '0';
                end if;
            end loop;

        end if;
    end process;


    ----------------------------------------------------------------
    -- Instantiate G_NCHANS pulse channel blocks and remaining empty channels
    -- 'Empty' blocks read back X"CCCCCCCC" if corresponding bit is 
    -- set in the channel select register.
    -- Only one channel should be enabled for reading at any time
    -- otherwise block outputs will be or'ed together
    ----------------------------------------------------------------
    g_ch : for I in 0 to 31 generate
    begin
        
        ch_full : if (I < G_NCHANS) generate
        begin
            -- Full channel block
          --u_ch : entity work.qlaser_dacs_pulse_channel(wave_4K_pdef_1Kx32)
            u_ch : entity work.qlaser_dacs_pulse_channel(channel)
            port map(
                reset           => reset                ,   -- in  std_logic;
                clk             => clk                  ,   -- in  std_logic
                enable          => ch_enables(I)        ,   -- in  std_logic;                        -- Set to allow channel to run. Rising edge send 0 to DAC.
                start           => trigger              ,   -- in  std_logic;                        -- Set when pulse generation sequence begins
                cnt_time        => std_logic_vector(sm_cnt_time) ,   -- in  std_logic_vector(23 downto 0);    -- Time since trigger.
                busy            => ch_busy(I)           ,   -- out std_logic;                        -- Status signal
                done_seq        => done_seq             ,   -- in std_logic;   
    
                -- status signals to indicate any errors
                erros           => ch_errs_wave(I)      ,   -- out std_logic;                        -- Status signal
                clear_errors    => '0'                  ,   -- in std_logic;                         -- Clear error flags, always low for now as a reset would clear them.
                -- CPU interface
                cpu_addr        => cpu_ch_addr          ,   -- in  std_logic_vector(11 downto 0);    -- Address input
                cpu_wdata       => cpu_ch_wdata         ,   -- in  std_logic_vector(31 downto 0);    -- Data input
                cpu_wr          => cpu_ch_wr            ,   -- in  std_logic;                        -- Write enable 
                cpu_sel         => cpu_ch_sels(I)       ,   -- in  std_logic;                        -- Block select
                cpu_rdata       => cpu_ch_rdatas(I)     ,   -- out std_logic_vector(31 downto 0);    -- Data output
                cpu_rdata_dv    => cpu_ch_rdata_dvs(I)  ,   -- out std_logic;                        -- Acknowledge output
    
                -- AXI-stream
                axis_tready     => axis_treadys(I)      ,   -- in  std_logic;                        -- axi_stream ready from downstream module
                axis_tdata      => axis_tdatas(I)       ,   -- out std_logic_vector(15 downto 0);    -- axi stream output data
                axis_tvalid     => axis_tvalids(I)      ,   -- out std_logic;                        -- axi_stream output data valid
                axis_tlast      => axis_tlasts(I)           -- out std_logic                         -- axi_stream output set on last data  
            );
        end generate ch_full;
        
        -- 'Empty' blocks read back X"CCCCCCCC" if corresponding bit is set in channel select register
        ch_empty : if ( I >= G_NCHANS) generate
        begin    
            -- Empty channel block
            u_empty : entity work.qlaser_dacs_pulse_channel(empty)
            port map(
                reset           => reset                ,   -- in  std_logic;
                clk             => clk                  ,   -- in  std_logic
                enable          => ch_enables(I)        ,   -- in  std_logic;                        -- Set to allow channel to run. Rising edge send 0 to DAC.
                start           => trigger              ,   -- in  std_logic;                        -- Set when pulse generation sequence begins
                cnt_time        => std_logic_vector(sm_cnt_time) ,   -- in  std_logic_vector(23 downto 0);    -- Time since trigger.
                busy            => ch_busy(I)           ,   -- out std_logic;
                done_seq        => done_seq             ,   -- in std_logic;   

                -- status signals to indicate any errors
                erros           => ch_errs_wave(I)      ,   -- out std_logic;                        -- Status signal
                clear_errors    => '0'                  ,   -- in std_logic;                         -- Clear error flags, always low for now as a reset would clear them.
                -- CPU interface
                cpu_addr        => cpu_ch_addr          ,   -- in  std_logic_vector(11 downto 0);    -- Address input
                cpu_wdata       => cpu_ch_wdata         ,   -- in  std_logic_vector(31 downto 0);    -- Data input
                cpu_wr          => cpu_ch_wr            ,   -- in  std_logic;                        -- Write enable 
                cpu_sel         => cpu_ch_sels(I)       ,   -- in  std_logic;                        -- Block select
                cpu_rdata       => cpu_ch_rdatas(I)     ,   -- out std_logic_vector(31 downto 0);    -- Data output
                cpu_rdata_dv    => cpu_ch_rdata_dvs(I)  ,   -- out std_logic;                        -- Acknowledge output
    
                -- AXI-stream
                axis_tready     => axis_treadys(I)      ,   -- in  std_logic;                        -- axi_stream ready from downstream module
                axis_tdata      => axis_tdatas(I)       ,   -- out std_logic_vector(15 downto 0);    -- axi stream output data
                axis_tvalid     => axis_tvalids(I)      ,   -- out std_logic;                        -- axi_stream output data valid
                axis_tlast      => axis_tlasts(I)           -- out std_logic                         -- axi_stream output set on last data  
            );
            
        end generate ch_empty;
        
    end generate g_ch;

    
    ----------------------------------------------------------------
    -- State machine: 
    -- When trigger rises, start incrementing the time counter 
    -- until the maximum programmed counter time has been reached.
    ----------------------------------------------------------------
    pr_sm : process (reset, clk)
    begin
        if (reset = '1') then

            sm_state            <= S_RESET;
            sm_busy             <= '0';
            errs_jesd_latched   <= (others=>'0');
            sm_cnt_time         <= (others=>'0');

        elsif rising_edge(clk) then

            -- Pipeline delays to use for rising edge detection
            enable_d1       <= enable;  
            trigger_d1      <= trigger;  

            ------------------------------------------------------------------------
            -- Main state machine
            ------------------------------------------------------------------------
            case sm_state is

                ------------------------------------------------------------------------
                -- Wait for rising edge of enable
                -- This is set when the JESD interface is aligned and functional.
                -- Send a zero value to initialize the DAC then go to idle.
                ------------------------------------------------------------------------
                when  S_RESET   =>

                    if (enable = '1') and (enable_d1 = '0') then
                        sm_state        <= S_IDLE;
                    end if;

                    sm_busy             <= '0';
                    sm_cnt_time         <= (others=>'0');
                    errs_jesd_latched   <= (others=>'0');
                    done_seq            <= '0';

                ------------------------------------------------------------------------
                -- Wait for rising edge of 'trigger'.
                -- No data output.
                ------------------------------------------------------------------------
                when  S_IDLE    =>

                    if (trigger = '1') and (trigger_d1 = '0') then
                        sm_state    <= S_RUN;
                        sm_busy     <= '1';
                        done_seq    <= '0';
                        errs_jesd_latched   <= (others=>'0');
                    else
                        sm_busy     <= '0';
                    end if;

                    sm_cnt_time     <= (others=>'0');

                ------------------------------------------------------------------------
                -- Return to idle state if max time is reached. Output waveform value zero. 
                ------------------------------------------------------------------------
                when  S_RUN    =>

                    -- Increment time counter
                    if (sm_cnt_time < unsigned(reg_sequence_len)) then
                        sm_cnt_time    <= sm_cnt_time + 1;

                    elsif (sm_cnt_time = X"FFFFFF") then
                        done_seq        <= '1';
                        sm_state        <= S_IDLE;
                    else 
                        done_seq        <= '1';
                        sm_state        <= S_IDLE;
                    end if;

                    for I in 0 to 31 loop
                        errs_jesd_latched(I) <= errs_jesd_latched(I) or ch_errs_jesd(I);
                    end loop;

                ------------------------------------------------------------------------
                -- Default
                ------------------------------------------------------------------------
                when others =>
                        sm_state            <= S_IDLE;

            end case;
        end if;

    end process;


    ----------------------------------------------------------------
    -- CPU Read/Write local registers and RAMs in 32 channels
    -- MSB of cpu_addr is used to select one of the two RAMs 
    -- to read/write, and the remainder are a  11-bit or 8-bit RAM address.
    ----------------------------------------------------------------
    pr_cpu_rw  : process (reset, clk)
    begin
        if (reset = '1') then
        
            reg_ch_sels         <= (others=>'1');
            reg_ch_en           <= (others=>'0');
            reg_sequence_len    <= X"800000";

            -- CPU connections to each channel
            cpu_ch_addr         <= (others=>'0');   -- std_logic_vector(11 downto 0);    -- Address input
            cpu_ch_wdata        <= (others=>'0');   -- std_logic_vector(31 downto 0);    -- Data input
            cpu_ch_wr           <= '0';             -- std_logic;                        -- Write enable 
            cpu_ch_sels         <= (others=>'0');   -- std_logic_vector(31 downto 0);    -- Block selects

            reg_rdata           <= (others=>'0');
            reg_rdata_dv        <= '0';

        elsif rising_edge(clk) then
        
            -------------------------------------------------
            -- CPU writing 
            -------------------------------------------------
            if (cpu_wr = '1') and (cpu_sel = '1') then
                                
                -- Address 1 for local register, 0 for channel internal RAMs
                if (cpu_addr(12) = '1') then

                    -- Write registers
                    case cpu_addr(3 downto 0) is
                        when "0000" =>  reg_sequence_len    <= cpu_wdata(23 downto 0);
                        when "0001" =>  reg_ch_sels         <= cpu_wdata;
                        when "0010" =>  reg_ch_en           <= cpu_wdata;
                        when others =>  null;
                    end case;
                        
                    cpu_ch_addr         <= (others=>'0');
                    cpu_ch_wdata        <= (others=>'0');
                    cpu_ch_wr           <= '0';          
                    cpu_ch_sels         <= (others=>'0');
                    
                else

                    cpu_ch_addr         <= cpu_addr(11 downto 0);
                    cpu_ch_wdata        <= cpu_wdata;
                    cpu_ch_wr           <= cpu_wr;          
                    cpu_ch_sels         <= reg_ch_sels; -- Write to any channels with their corresponding bit set in the register reg_ch_sels

                end if;
                
                reg_rdata           <= (others=>'0');
                reg_rdata_dv        <= '0';
                    
            -------------------------------------------------
            -- CPU read
            -------------------------------------------------
            elsif (cpu_wr = '0') and (cpu_sel = '1') then
                
                -- Address bit 1 for local registers, 0 for any logic in the channel blocks
                if (cpu_addr(12) = '1') then

                    -- Read registers
                    case cpu_addr(3 downto 0) is
                        when "0000" =>  reg_rdata       <= X"00" & reg_sequence_len;
                        when "0001" =>  reg_rdata       <= reg_ch_sels;
                        when "0010" =>  reg_rdata       <= reg_ch_en;
                        when "0011" =>  reg_rdata       <= reg_status;
                        when "0100" =>  reg_rdata       <= reg_status_jesd;
                        when "0101" =>  reg_rdata       <= X"00" & std_logic_vector(sm_cnt_time);
                        when others =>  reg_rdata       <= (others=>'0');
                    end case;
                    reg_rdata_dv        <= '1';
                        
                    cpu_ch_addr         <= (others=>'0');
                    cpu_ch_wdata        <= (others=>'0');
                    cpu_ch_wr           <= '0';          
                    cpu_ch_sels         <= (others=>'0');
                    
                else
                    reg_rdata           <= (others=>'0');
                    reg_rdata_dv        <= '0';

                    cpu_ch_addr         <= cpu_addr(11 downto 0);
                    cpu_ch_wdata        <= cpu_wdata;
                    cpu_ch_wr           <= cpu_wr;          
                    cpu_ch_sels         <= reg_ch_sels;

                end if;
            
            else
                cpu_ch_addr         <= (others=>'0');   -- std_logic_vector(11 downto 0);    -- Address input
                cpu_ch_wdata        <= (others=>'0');   -- std_logic_vector(31 downto 0);    -- Data input
                cpu_ch_wr           <= '0';             -- std_logic;                        -- Write enable 
                cpu_ch_sels         <= (others=>'0');   -- std_logic_vector(31 downto 0);    -- Block selects

                reg_rdata           <= (others=>'0');
                reg_rdata_dv        <= '0';

            end if;

        end if;
        
    end process;


    -------------------------------------------------------------------------------
    -- CPU Read
    -- Combine all register and channel cpu_rdata and cpu_rdata_dv signals
    -- To perform reads correctly only one bit should be set in reg_ch_sel.
    -- If more than one bit is set then RAM contents from multiple channels
    -- will be ore'ed together.
    -------------------------------------------------------------------------------
    pr_cpu_rdata : process (reset, clk)
    variable v_cpu_rdata     : std_logic_vector(31 downto 0) := (others=>'0');
    variable v_cpu_rdata_dv  : std_logic := '0';
    begin

        if (reset = '1') then

            cpu_rdata     <= (others=>'0');
            cpu_rdata_dv  <= '0';

        elsif rising_edge(clk) then

            v_cpu_rdata      := (others=>'0');
            v_cpu_rdata_dv   := '0';

            for I in 0 to 31 loop

                v_cpu_rdata     := v_cpu_rdata    or cpu_ch_rdatas(I);
                v_cpu_rdata_dv  := v_cpu_rdata_dv or cpu_ch_rdata_dvs(I);

            end loop;

            cpu_rdata     <= v_cpu_rdata    or reg_rdata;
            cpu_rdata_dv  <= v_cpu_rdata_dv or reg_rdata_dv;

        end if;

    end process;


end ch1;
