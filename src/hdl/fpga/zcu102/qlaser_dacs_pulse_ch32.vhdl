---------------------------------------------------------------
--  File         : qlaser_dacs_pulse_ch32.vhdl
--  Description  : 32 channel pulse output
----------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     ieee.std_logic_misc.all;

use     work.qlaser_pkg.all;

entity qlaser_dacs_pulse is
port (
    reset               : in  std_logic;
    clk                 : in  std_logic; 

    enable              : in  std_logic;                        -- Set when DAC interface is running
    trigger             : in  std_logic;                        -- Set when pulse generation sequence begins (trigger)
    jesd_syncs          : in  std_logic_vector(31 downto 0);    -- Inputs from each JESD TX interface

    -- Status signals
    ready               : out std_logic;                        -- Status signal indicating all JESD channels are sync'ed.
    busy                : out std_logic;                        -- Running a waveform generation sequence.
    error               : out std_logic;                        -- Instantanous JESD sync status.
    error_latched       : out std_logic;                        -- JESD lost sync after ready. Cleared by trigger

    -- CPU interface
    cpu_addr            : in  std_logic_vector(11 downto 0);    -- Address input
    cpu_wdata           : in  std_logic_vector(31 downto 0);    -- Data input
    cpu_wr              : in  std_logic;                        -- Write enable 
    cpu_sel             : in  std_logic;                        -- Block select
    cpu_rdata           : out std_logic_vector(31 downto 0);    -- Data output
    cpu_rdata_dv        : out std_logic;                        -- Acknowledge output
     
    -- Array of 32 AXI-Stream buses. Each with 16-bit data. Interface to JESD TX Interfaces
    axis_treadys         : in  std_logic_vector(31 downto 0);    -- axi_stream ready from downstream modules
    axis_tdatas          : out t_arr_slv32x16b;   -- axi stream output data array
    axis_tvalids         : out std_logic_vector(31 downto 0);    -- axi_stream output data valid
    axis_tlasts          : out std_logic_vector(31 downto 0)     -- axi_stream output set on last data  
);
end entity;


----------------------------------------------------------------
-- Instantiates 32 channels of pulse generators.
-- Common 24-bit sequence counter.
-- Address decoding uses a 32-bit channel select register.
----------------------------------------------------------------
architecture ch32 of qlaser_dacs_pulse is

-- Registers.

-- Set max sequence time
signal reg_sequence_len     : std_logic_vector(23 downto 0);

-- CPU bus write enable register. Selects channel(s) for CPU to write to. Setting X"FFFFFFF" writes to all channels
signal reg_ch_sels          : std_logic_vector(31 downto 0);

signal reg_status           : std_logic_vector(31 downto 0);    -- Current 'error' and 'busy' flags
signal reg_status_ch        : std_logic_vector(31 downto 0);    -- Per channel latched JESD loss of sync. Cleared by trigger.


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
signal busy_i               : std_logic;
signal error_i              : std_logic;

-- Channel CPU interface
signal cpu_ch_addr          : std_logic_vector( 9 downto 0);    -- Address input
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

signal jesd_errs            : std_logic_vector(31 downto 0);
signal jesd_errs_latched    : std_logic_vector(31 downto 0);

begin

    -- Combine channel busy signals with state machine busy for output
    busy_i      <= or_reduce(ch_busy) or sm_busy;
    busy        <= busy_i;

    -- Invert current jesd sync to make error
    jesd_errs   <= not(jesd_syncs);
    error_i     <= or_reduce(jesd_errs);
    error       <= error_i;
    error_latched   <= or_reduce(jesd_errs_latched);

    -- Set 'ready' when all JESD channels and sync'ed 
    ready       <= and_reduce(jesd_syncs);

    -- status registers
    reg_status      <= X"000000" & "000" & error_i & "000" & busy_i;
    reg_status_ch   <= jesd_errs_latched;


    ----------------------------------------------------------------
    -- Instantiate 32 pulse channel blocks
    ----------------------------------------------------------------
    g_ch : for I in 0 to 31 generate
        
        u_ch : entity work.qlaser_dacs_pulse_channel(rtl)
        port map(
            reset           => reset                ,   -- in  std_logic;
            clk             => clk                  ,   -- in  std_logic
            enable          => enable               ,   -- in  std_logic;                        -- Set to allow channel to run. Rising edge send 0 to DAC.
            start           => trigger              ,   -- in  std_logic;                        -- Set when pulse generation sequence begins
            cnt_time        => std_logic_vector(sm_cnt_time) ,   -- in  std_logic_vector(23 downto 0);    -- Time since trigger.
            busy            => ch_busy(I)           ,   -- out std_logic;                        -- Status signal

            -- CPU interface
            cpu_addr        => cpu_ch_addr          ,   -- in  std_logic_vector( 9 downto 0);    -- Address input
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
    end generate;

    
    ----------------------------------------------------------------
    -- State machine: 
    -- When trigger rises start incrementing the time counter until
    -- until the maximum programmed counter time has been reached.
    ----------------------------------------------------------------
    pr_sm : process (reset, clk)
    begin
        if (reset = '1') then

            sm_state            <= S_RESET;
            sm_busy             <= '0';
            jesd_errs_latched   <= (others=>'0');
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
                    jesd_errs_latched   <= (others=>'0');


                ------------------------------------------------------------------------
                -- Wait for rising edge of 'trigger'.
                -- No data output.
                ------------------------------------------------------------------------
                when  S_IDLE    =>

                    if (trigger = '1') and (trigger_d1 = '0') then
                        sm_state    <= S_RUN;
                        sm_busy     <= '1';
                        jesd_errs_latched   <= (others=>'0');
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
                        sm_state        <= S_IDLE;
                    else 
                        sm_state        <= S_IDLE;
                    end if;

                    for I in 0 to 31 loop
                        jesd_errs_latched(I) <= jesd_errs_latched(I) or jesd_errs(I);
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
    -- to read/write, and the remainder are a  9-bit or 4-bit RAM address.
    ----------------------------------------------------------------
    pr_cpu_rw  : process (reset, clk)
    begin
        if (reset = '1') then
        
            reg_ch_sels         <= (others=>'1');
            reg_sequence_len    <= X"800000";

            -- CPU connections to each channel
            cpu_ch_addr         <= (others=>'0');   -- std_logic_vector( 9 downto 0);    -- Address input
            cpu_ch_wdata        <= (others=>'0');   -- std_logic_vector(31 downto 0);    -- Data input
            cpu_ch_wr           <= '0';             -- std_logic;                        -- Write enable 
            cpu_ch_sels         <= (others=>'0');   -- std_logic_vector(31 downto 0);    -- Block selects

        elsif rising_edge(clk) then
        
            -------------------------------------------------
            -- CPU writing 
            -------------------------------------------------
            if (cpu_wr = '1') and (cpu_sel = '1') then
                                
                -- Address MSB 1 for local register, 0 for channel RAMs
                if (cpu_addr(11) = '1') then

                    -- Write registers
                    case cpu_addr(3 downto 0) is
                        when "0000" =>  reg_sequence_len    <= cpu_wdata(23 downto 0);
                        when "0001" =>  reg_ch_sels         <= cpu_wdata;
                        when others =>  null;
                    end case;
                        
                    cpu_ch_addr         <= (others=>'0');
                    cpu_ch_wdata        <= (others=>'0');
                    cpu_ch_wr           <= '0';          
                    cpu_ch_sels         <= (others=>'0');
                    
                else

                    cpu_ch_addr         <= cpu_addr( 9 downto 0);
                    cpu_ch_wdata        <= cpu_wdata;
                    cpu_ch_wr           <= cpu_wr;          
                    cpu_ch_sels         <= reg_ch_sels;

                end if;
                
                reg_rdata           <= (others=>'0');
                reg_rdata_dv        <= '0';
                    
            -------------------------------------------------
            -- CPU read
            -------------------------------------------------
            elsif (cpu_wr = '0') and (cpu_sel = '1') then
                
                -- Address MSB 1 for local register, 0 for channel RAMs
                if (cpu_addr(11) = '1') then

                    -- Read registers
                    case cpu_addr(3 downto 0) is
                        when "0000" =>  reg_rdata       <= X"00" & reg_sequence_len;
                        when "0001" =>  reg_rdata       <= reg_ch_sels;
                        when "0010" =>  reg_rdata       <= reg_status;
                        when "0011" =>  reg_rdata       <= reg_status_ch;
                        when "0100" =>  reg_rdata       <= X"00" & std_logic_vector(sm_cnt_time);
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

                    cpu_ch_addr         <= cpu_addr( 9 downto 0);
                    cpu_ch_wdata        <= cpu_wdata;
                    cpu_ch_wr           <= cpu_wr;          
                    cpu_ch_sels         <= reg_ch_sels;

                end if;
            
            else
                cpu_ch_addr         <= (others=>'0');   -- std_logic_vector( 9 downto 0);    -- Address input
                cpu_ch_wdata        <= (others=>'0');   -- std_logic_vector(31 downto 0);    -- Data input
                cpu_ch_wr           <= '0';             -- std_logic;                        -- Write enable 
                cpu_ch_sels         <= (others=>'0');   -- std_logic_vector(31 downto 0);    -- Block selects

                reg_rdata           <= (others=>'0');
                reg_rdata_dv        <= '0';

            end if;

        end if;
        
    end process;


    -------------------------------------------------------------------------------
    -- Combine all register and channel cpu_rdata and cpu_rdata_dv signals
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


end ch32;
