---------------------------------------------------------------
--  File         : qlaser_dacs_pulse_channel_wave_4K_pdef_96b.vhdl
--  Description  : Single channel of pulse output
----------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.qlaser_pkg.all;

entity qlaser_dacs_pulse_channel is
port (
    reset               : in  std_logic;
    clk                 : in  std_logic; 

    enable              : in  std_logic;                        -- Set to allow channel to run. Rising edge send 0 to DAC.
    start               : in  std_logic;                        -- Set when pulse generation sequence begins
    cnt_time            : in  std_logic_vector(23 downto 0);    -- Time since trigger.

    busy                : out std_logic;                        -- Status signal

    -- CPU interface
    cpu_addr            : in  std_logic_vector(12 downto 0);    -- Address input
    cpu_wdata           : in  std_logic_vector(31 downto 0);    -- Data input
    cpu_wr              : in  std_logic;                        -- Write enable 
    cpu_sel             : in  std_logic;                        -- Block select
    cpu_rdata           : out std_logic_vector(31 downto 0);    -- Data output
    cpu_rdata_dv        : out std_logic;                        -- Acknowledge output
     
    -- AXI-stream output
    axis_tready         : in  std_logic;                        -- axi_stream ready from downstream module
    axis_tdata          : out std_logic_vector(15 downto 0);    -- axi stream output data
    axis_tvalid         : out std_logic;                        -- axi_stream output data valid
    axis_tlast          : out std_logic                         -- axi_stream output set on last data  
);
end entity;


----------------------------------------------------------------
-- Single channel pulse generator with two RAMs
----------------------------------------------------------------
architecture wave_4K_pdef_96b of qlaser_dacs_pulse_channel is

-- RAM, pulse definition, CPU port, read/write
constant C_NUM_PULSE        : integer   := 16;                  -- Number of output data values from pulse RAM (16x24-bit)
signal ram_pulse_addra      : std_logic_vector( 3 downto 0);    -- 16 entry RAM
signal ram_pulse_dina       : std_logic_vector(95 downto 0);
signal ram_pulse_douta      : std_logic_vector(95 downto 0);
signal ram_pulse_douta_d1   : std_logic_vector(95 downto 0);    -- Delay distrib RAM output to match pipeline of Block RAM
signal ram_pulse_we         : std_logic;

-- RAM, pulse definition, from state machine
signal ram_pulse_addrb      : std_logic_vector( 3 downto 0);
signal ram_pulse_doutb      : std_logic_vector(95 downto 0);

signal cpu_rdata_dv_e1      : std_logic;
signal cpu_rdata_dv_e2      : std_logic;
signal cpu_rdata_ramsel_d1  : std_logic;
signal cpu_rdata_ramsel_d2  : std_logic;

-- Waveform RAM port connections. 
-- NOTE: Port A is 32-bit data, port B is 16-bit
constant C_LENGTH_WAVEFORM  : integer   := 4*1024;                -- Number of output data values from waveform RAM (4096x16-bit)
signal ram_waveform_ena     : std_logic;
signal ram_waveform_wea     : std_logic_vector( 0 downto 0);
signal ram_waveform_addra   : std_logic_vector(10 downto 0);
signal ram_waveform_dina    : std_logic_vector(31 downto 0);
signal ram_waveform_douta   : std_logic_vector(31 downto 0);

signal ram_waveform_enb     : std_logic := '0';
signal ram_waveform_web     : std_logic_vector( 0 downto 0) := (others=>'0');
signal ram_waveform_addrb   : std_logic_vector(11 downto 0);
signal ram_waveform_dinb    : std_logic_vector(15 downto 0) := (others=>'0');
signal ram_waveform_doutb   : std_logic_vector(15 downto 0);


-- State variable type declaration for main state machine
type t_sm_state  is (
    S_RESET,    -- Wait for 'enable'. Stay here until JESD interface is up and running,
    S_IDLE,     -- Wait for 'start'
    S_WAIT,     -- Wait for cnt_time, external input, to match pulse position RAM output
    S_WAVE      -- Output waveform RAM table
    -- ** MORE STATES **
);
signal sm_state             : t_sm_state;
signal sm_wavedata          : std_logic_vector(15 downto 0);    -- Waveform RAM data
signal sm_wavedata_dv       : std_logic;    -- Signal to indicate that waveform RAM data is valid
signal sm_busy              : std_logic;    -- Signal to indicate that s.m. is not idle

-- Pipeline delays
signal start_d1             : std_logic;
signal enable_d1            : std_logic;

begin

    busy    <= sm_busy;

    ----------------------------------------------------------------
    -- Distributed RAM to hold 16 96-bit Pulse Definition data.
    -- Synch write, Asynch read
    -- Port A is for CPU read/write. 16x96-bit
    -- Port B is for pulse time data output. 16x96-bit
    ----------------------------------------------------------------
    u_ram_pdef : entity work.bram_pulse_defn
    port map(
        clk        => clk               ,   -- input  std_logic
        a          => ram_pulse_addra   ,   -- input  slv[3:0]
        d          => ram_pulse_dina    ,   -- input  slv[23 downto 0)
        we         => ram_pulse_we      ,
        spo        => ram_pulse_douta   ,   -- output slv(95 downto 0)
         
        dpra       => ram_pulse_addrb   ,   -- input  slv[3:0]
        dpo        => ram_pulse_doutb       -- output slv(95 downto 0)
    );
    
    
    ----------------------------------------------------------------
    -- Waveform table Block RAM.
    -- Synch write, Synch read
    -- Port A is for CPU read/write. 2048x32-bit
    -- Port B is for waveform data.  4096x16-bit
    ----------------------------------------------------------------
    u_ram_waveform : entity work.bram_waveform
    port map (
        -- Port A CPU Bus
        clka        => clk                ,   -- input  std_logic
        ena         => ram_waveform_ena   ,   -- input  std_logic
        wea         => ram_waveform_wea   ,   -- input  slv( 0 downto 0)
        addra       => ram_waveform_addra ,   -- input  slv(10 downto 0)
        dina        => ram_waveform_dina  ,   -- input  slv(31 downto 0)
        douta       => ram_waveform_douta ,   -- output slv(31 downto 0)
        
        -- Port B waveform output
        clkb        => clk                ,   -- input  std_logic
        enb         => ram_waveform_enb   ,   -- input  std_logic
        web         => (others=>'0')      ,   -- input  slv( 0 downto 0)
        addrb       => ram_waveform_addrb ,   -- input  slv(11 downto 0)
        dinb        => (others=>'0')      ,   -- input  slv(15 downto 0)
        doutb       => ram_waveform_doutb     -- output slv(15 downto 0)
    );
    
    

    ----------------------------------------------------------------
    -- State machine: 
    -- Compares cnt_time input against current output from pulse position RAM.
    -- When values match it increments the pulse postion RAM address to 
    -- retrieve the next pulse position and also starts reading the 
    -- entire waveform table, one value every clock cycle, until it reaches the end.
    -- Once the pulse is complete it waits for the next cnt_time match.
    -- Repeat until all pulse position RAM times have triggered a pulse output 
    -- or until the maximum counter time has been reached.
    ----------------------------------------------------------------
    pr_sm : process (reset, clk)
    begin
        if (reset = '1') then

            sm_state            <= S_RESET;
            ram_pulse_addrb     <= (others=>'0');
            ram_waveform_addrb  <= (others=>'0');

            sm_wavedata         <= (others=>'0');
            sm_wavedata_dv      <= '0';
            sm_busy             <= '0';
            ram_waveform_enb    <= '0';

        elsif rising_edge(clk) then

        end if;

    end process;

    -- AXI-Stream output.
    axis_tdata          <= sm_wavedata;     -- axi stream output data
    axis_tvalid         <= sm_wavedata_dv;  -- axi_stream output data valid

    -- TBD : Generate in state machine? Not really necessary?
    axis_tlast          <= '0';                 -- axi_stream output last 



    ----------------------------------------------------------------
    -- CPU Read/Write RAM
    -- cpu_addr(11) is used to select one of the two RAMs 
    -- to read/write, and the remainder are a  11-bit or 4-bit RAM address.
    ----------------------------------------------------------------
    pr_ram_rw  : process (reset, clk)
    begin
        if (reset = '1') then
        
            ram_pulse_addra     <= (others=>'0');
            ram_pulse_dina      <= (others=>'0');
            ram_pulse_we        <= '0';

            ram_waveform_ena    <= '0';
            ram_waveform_wea    <= (others=>'0');
            ram_waveform_addra  <= (others=>'0');
            ram_waveform_dina   <= (others=>'0');

            cpu_rdata           <= (others=>'0');
            cpu_rdata_dv        <= '0';
            cpu_rdata_dv_e1     <= '0';
            cpu_rdata_dv_e2     <= '0';
            cpu_rdata_ramsel_d1 <= '0';
            cpu_rdata_ramsel_d2 <= '0';
            
        elsif rising_edge(clk) then
        
            ram_waveform_ena    <= '0';

            -------------------------------------------------
            -- CPU writing RAM
            -------------------------------------------------
            if (cpu_wr = '1') and (cpu_sel = '1') then
            
                -- 0 for pulse position, 1 for waveform table
                if (cpu_addr(11) = '1') then

                    ram_pulse_addra     <= (others=>'0');
                    ram_pulse_dina      <= (others=>'0');
                    ram_pulse_we        <= '0';

                    ram_waveform_wea(0) <= '1';
                    ram_waveform_ena    <= '1';
                    ram_waveform_addra  <= cpu_addr(10 downto 0);
                    ram_waveform_dina   <= cpu_wdata;

                else

                    -- Three writes for pulse definition RAM

                end if;
                    
                cpu_rdata_dv_e1     <= '0';
                cpu_rdata_dv_e2     <= '0';
                cpu_rdata_ramsel_d1 <= '0';
                cpu_rdata_ramsel_d2 <= '0';

            
            -------------------------------------------------
            -- CPU read
            -------------------------------------------------
            elsif (cpu_wr = '0') and (cpu_sel = '1') then
                
                if (cpu_addr(11) = '1') then -- Waveform
                    ram_waveform_ena    <= '1';
                    ram_pulse_addra     <= (others=>'0');
                    ram_waveform_addra  <= cpu_addr(10 downto 0);
                else                        -- Pulse
                    ram_pulse_addra     <= cpu_addr( 3 downto 0);
                    ram_pulse_douta_d1  <= ram_pulse_douta;         -- Delay distrib RAM output to match pipeline of Block RAM
                    ram_waveform_addra  <= (others=>'0');
                end if;

                ram_pulse_we        <= '0';
                ram_waveform_wea(0) <= '0';
                
                cpu_rdata_dv_e2     <= '1';             -- DV for cycle, when RAM output occurs
                cpu_rdata_dv_e1     <= cpu_rdata_dv_e2; -- DV for next cycle
                cpu_rdata_ramsel_d1 <= cpu_addr(11);    -- Save the select bit one cycle later
                cpu_rdata_ramsel_d2 <= cpu_rdata_ramsel_d1;  
                    
            else
                ram_pulse_addra     <= (others=>'0');
                ram_pulse_we        <= '0';
                ram_waveform_addra  <= (others=>'0');
                ram_waveform_wea(0) <= '0';

                cpu_rdata_dv_e2     <= '0';
                cpu_rdata_dv_e1     <= cpu_rdata_dv_e2; -- DV for next cycle
                cpu_rdata_ramsel_d1 <= '0';
                cpu_rdata_ramsel_d2 <= cpu_rdata_ramsel_d1;  
            
            end if;
            
            -------------------------------------------------
            -- Output 32-bits from part of the delayed RAM data
            -- This adds a pipeline delay to the cpu_rdata_dv to account for
            -- the delay in reading data from the RAM
            -------------------------------------------------
            if (cpu_rdata_dv_e1 = '1') then
                    
                cpu_rdata_dv    <= '1';
                
                -- Select source of output data
                if (cpu_rdata_ramsel_d2 = '1') then   -- Output is from waveform table
                    cpu_rdata   <= ram_waveform_douta;

                elsif (cpu_rdata_ramsel_d2 = '0') then
                    cpu_rdata   <= X"00" & ram_pulse_douta_d1;
                end if;

            else
                cpu_rdata       <= (others=>'0');
                cpu_rdata_dv    <= '0';
            end if;
            
        end if;
        
    end process;

end wave_4K_pdef_96b;

