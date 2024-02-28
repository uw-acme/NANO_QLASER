---------------------------------------------------------------
--  File         : qlaser_dacs_pulse_channel.vhd
--  Description  : Single channel of pulse output
----------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.qlaser_pkg.all;
use     work.qlaser_dacs_pulse_channel_pkg.all;

entity qlaser_dacs_pulse_channel is
port (
    reset               : in  std_logic;
    clk                 : in  std_logic; 

    enable              : in  std_logic;                        -- Set when DAC interface is running
    start               : in  std_logic;                        -- Set when pulse generation sequence begins (trigger)
    cnt_time            : in  std_logic_vector(23 downto 0);    -- Time since trigger.

    busy                : out std_logic;                        -- Status signal
    err_wave            : out std_logic;
    done_seq            : in  std_logic;                        -- Status signal to terminate sequence
    -- TODO: Add another status signal to indicate any errors?

    -- CPU interface
    cpu_addr            : in  std_logic_vector(11 downto 0);    -- Address input
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
-- Empty architecture with a single 32-bit r/w register
----------------------------------------------------------------
architecture empty of qlaser_dacs_pulse_channel is

signal reg_test : std_logic_vector(31 downto 0);
begin

    busy    <= '0';
    err_wave <= '0';

    -- AXI-Stream output.
    axis_tdata          <= (others=>'0');   -- axi stream output data
    axis_tvalid         <= '0';             -- axi_stream output data valid
    axis_tlast          <= '0';             -- axi_stream output last 


    ----------------------------------------------------------------
    -- CPU Read/Write 
    ----------------------------------------------------------------
    pr_ram_rw  : process (reset, clk)
    begin
        if (reset = '1') then
        
            cpu_rdata           <= (others=>'0');
            cpu_rdata_dv        <= '0'; 
            reg_test            <= X"CCCCCCCC";
            
        elsif rising_edge(clk) then
        
            -------------------------------------------------
            -- CPU write
            -------------------------------------------------
            if (cpu_wr = '1') and (cpu_sel = '1') then
            
                reg_test        <= cpu_wdata;

            -------------------------------------------------
            -- CPU read
            -------------------------------------------------
            elsif (cpu_wr = '0') and (cpu_sel = '1') then
                
                cpu_rdata_dv    <= '1';     
                cpu_rdata       <= reg_test; 
                    
            else
                cpu_rdata_dv    <= '0';
                cpu_rdata       <= (others=>'0');
            
            end if;
            
        end if;
        
    end process;

end empty;

---------------------------------------------------------------------------
-- Single channel pulse generator with two RAMs
---------------------------------------------------------------------------
architecture channel of qlaser_dacs_pulse_channel is
-- Constants declearations
constant C_RAM_SELECT       : integer   := 11;                                    -- Select bit for which RAM for CPU read/write
-- constant C_NUM_PULSE        : integer   := 16;                -- Number of output data values from pulse RAM (16x24-bit)

constant C_START_TIME       : integer   := 24;                                    -- Start time for pulse generation
constant C_BITS_ADDR_START  : integer   := 12;                                    -- Number of bits for starting address
constant C_BITS_ADDR_LENGTH : integer   := 10;                                    -- Number of bits for length address used by an edge of a pulse
constant C_BITS_GAIN_FACTOR : integer   := 16;                                    -- Number of bits in gain table
constant C_BITS_TIME_FACTOR : integer   := 16;                                    -- Number of bits in time table
constant C_BITS_TIME_INT    : integer   := 14;                                    -- Starting bit for time integer part of the time factor, counting from MSB
constant C_BITS_TIME_FRAC   : integer   :=  5;                                    -- Starting bit for time fractional part of the time factor, counting from MSB
constant C_BITS_ADDR_TOP    : integer   := 17;                                    -- Number of bits for the "flat top", the top of the pulse

constant C_LENGTH_WAVEFORM  : integer   := 4096;                                  -- Number of output data values from waveform RAM (4kx16-bit)
constant C_BITS_ADDR_WAVE   : integer   := 16;                                    -- Number of bits in address for waveform RAM

constant C_BITS_ADDR_PULSE  : integer   := 10;                                    -- Number of bits in address for pulse definition RAM
constant C_LEN_PULSE        : integer   := 2**C_BITS_ADDR_PULSE;                  -- Numbers of address for pulse definition RAM
constant C_PC_INCR          : integer   := 4;                                     -- Width of pulse counter increment
constant C_BITS_ADDR_FULL : integer := 20;                                        -- Number of bits for the untruncated address, should be C_BITS_ADDR_LENGTH + fractional bits of time factor


-- Signal declarations for pulse RAM
signal ram_pulse_we         : std_logic_vector( 0 downto 0);                      -- Write enable for pulse RAM
signal ram_pulse_addra      : std_logic_vector( 9 downto 0);                      -- Address for pulse RAM
signal ram_pulse_dina       : std_logic_vector(31 downto 0);                      -- Data for pulse RAM
signal ram_pulse_douta      : std_logic_vector(31 downto 0);                      -- Data out from pulse RAM
signal ram_pulse_addrb      : std_logic_vector( 9 downto 0);                      -- Address for pulse RAM
signal ram_pulse_doutb      : std_logic_vector(31 downto 0);                      -- Data out from pulse RAM

-- Signal declarations for waveform RAM
signal ram_waveform_wea     : std_logic_vector( 0 downto 0);                      -- Write enable for waveform RAM
signal ram_waveform_addra   : std_logic_vector(10 downto 0);                      -- Address for waveform RAM
signal ram_waveform_dina    : std_logic_vector(31 downto 0);                      -- Data for waveform RAM
signal ram_waveform_douta   : std_logic_vector(31 downto 0);                      -- Data out from waveform RAM
signal ram_waveform_addrb   : std_logic_vector(19 downto 0);                      -- Address for waveform RAM
signal ram_waveform_doutb   : std_logic_vector(15 downto 0);                      -- Data out from waveform RAM

-- State variable type declaration for main state machine
type t_sm_state  is (
    S_RESET,    -- Wait for 'enable'. Stay here until JESD interface is up and running,
    S_IDLE,     -- Wait for 'start'
    S_WAIT,     -- Wait for cnt_time, external input, to match pulse position RAM output
    S_LOAD,     -- Load the pulse channel RAM addresses and start the waveform output
    S_HOLD,     -- Hold the last pulse definition address and output its data
    S_WAVE_UP,  -- Output the rising edge of a waveform
    S_WAVE_FLAT,-- Output the flat top part of a waveform
    S_WAVE_DOWN -- Output the falling edge of a waveform
);
signal sm_state             : t_sm_state;
signal sm_wavedata          : std_logic_vector(15 downto 0);                      -- Waveform RAM data
signal sm_wavedata_dv       : std_logic;                                          -- Signal to indicate that waveform RAM data is valid
signal sm_busy              : std_logic;                                          -- Signal to indicate that s.m. is not idle
signal cnt_wave_len         :         unsigned(C_BITS_ADDR_LENGTH - 1 downto 0);  -- Counter used for incremnet/decrement wave table addresses
signal cnt_wave_top         :         unsigned(C_BITS_ADDR_TOP - 1 downto 0);     -- Counter for the flat top of the waveform
signal cnt_addr             :         unsigned(C_BITS_ADDR_START - 1 downto 0);  -- Counter to keep track of address increments 
signal wave_last_addr       : std_logic_vector(C_BITS_ADDR_FULL - 1 downto 0);    -- Last address of the waveform table

-- Misc signals
signal cpu_rdata_dv_e1      : std_logic;
signal cpu_rdata_dv_e2      : std_logic;
signal cpu_rdata_ramsel_d1  : std_logic;
signal cpu_rdata_ramsel_d2  : std_logic;

signal pc                   : std_logic_vector(C_BITS_ADDR_PULSE - 1 downto 0);  -- pulse counter, used to count the number of pulses generated

----------------------------------------------------------------
-- Assign values from the pulse definition ram to regfiles (?) with the following:
-- 1. Start time 24 bits. [23:0]
-- 2. Wave start addr 12 bit at [11:0]
--    Wave length 10-bit at [25:16]
-- 3. Scale factors 16, 16. [31:16] [15:0]
-- 4. Flat-top 17-bit. [16:0]
----------------------------------------------------------------
signal reg_pulse_time       : std_logic_vector(31 downto 0);                      -- first register which stores the pulse's start time
signal reg_wave_start_addr  : std_logic_vector(C_BITS_ADDR_START - 1 downto 0);   -- the start address of the wavetable
signal reg_wave_length      :         unsigned(C_BITS_ADDR_LENGTH - 1 downto 0);  -- the length of the wavetable
signal reg_wave_end_addr    :         unsigned(C_BITS_ADDR_FULL - 1 downto 0);    -- the end address of the wavetable
signal reg_scale_gain       :         unsigned(C_BITS_TIME_FACTOR - 1 downto 0);  -- scale factor for the gain, amplitude
signal reg_scale_time       :         unsigned(C_BITS_TIME_FACTOR - 1 downto 0);  -- scale factor for the time, length
signal reg_pulse_flattop    :         unsigned(C_BITS_ADDR_TOP - 1 downto 0);     -- fourth register which stores the pulse's flat top value

-- Pipeline delays
signal sm_state_d1          : t_sm_state;
signal start_d1             : std_logic;
signal enable_d1            : std_logic;

-- error signal
signal err_addr_of          : std_logic;


begin

    err_wave <= '0';

    ----------------------------------------------------------------
    -- Pulse Definition Block RAM.
    -- Synch write, Synch read
    -- Port A is for CPU read/write. 1024x32-bit
    -- Port B is for pulse time data output. 1024x32-bit
    ----------------------------------------------------------------
    u_ram_pulse : entity work.bram_pulse_definition
    port map(
        -- Port A CPU Bus
        clka  => clk,                  -- input std_logic
        wea   => ram_pulse_we,         -- input slv( 0 to 0 )
        addra => ram_pulse_addra,      -- input slv( 9 downto 0 )
        dina  => ram_pulse_dina,       -- input slv( 31 downto 0 )
        douta => ram_pulse_douta,      -- output slv( 31 downto 0 ),
        -- Port B waveform input        
        clkb  => clk,
        web   => (others=>'0'),
        addrb => ram_pulse_addrb,      -- input slv( 9 downto 0 )
        dinb  => (others=>'0'),
        doutb => ram_pulse_doutb       -- output slv( 31 downto 0 )
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
        wea         => ram_waveform_wea   ,   -- input  slv(0 downto 0)
        addra       => ram_waveform_addra ,   -- input  slv(10 downto 0)
        dina        => ram_waveform_dina  ,   -- input  slv(31 downto 0)
        douta       => ram_waveform_douta ,   -- output slv(31 downto 0)
        
        -- Port B waveform output
        clkb        => clk                ,   -- input  std_logic
        web         => (others=>'0')      ,   -- input  slv(0 downto 0)
        addrb       => ram_waveform_addrb(19 downto 8) ,   -- input  slv(11 downto 0)
        dinb        => (others=>'0')      ,   -- input  slv(15 downto 0)
        doutb       => ram_waveform_doutb     -- output slv(15 downto 0)
    );

    ----------------------------------------------------------------
    -- CPU Read/Write RAM
    -- MSB of cpu_addr is used to select one of the two RAMs 
    -- to read/write, and the remainder are a  9-bit or 4-bit RAM address.
    ----------------------------------------------------------------
    pr_ram_rw  : process (reset, clk)
    begin
        if (reset = '1') then
        
            ram_pulse_addra     <= (others=>'0');
            ram_pulse_dina      <= (others=>'0');
            ram_pulse_we        <= (others=>'0');

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
        

            -------------------------------------------------
            -- CPU writing RAM
            -------------------------------------------------
            if (cpu_wr = '1') and (cpu_sel = '1') then
            
                -- 0 for pulse definition, 1 for waveform table
                if (cpu_addr(C_RAM_SELECT) = '1') then

                    ram_pulse_addra     <= (others=>'0');
                    ram_pulse_dina      <= (others=>'0');
                    ram_pulse_we        <= (others=>'0');

                    ram_waveform_wea(0) <= '1';
                    ram_waveform_addra  <= cpu_addr(10 downto 0);
                    ram_waveform_dina   <= cpu_wdata;

                else

                    ram_pulse_addra     <= cpu_addr(9 downto 0);
                    ram_pulse_dina      <= cpu_wdata;
                    ram_pulse_we(0)     <= '1';
                    ram_waveform_wea    <= (others=>'0');
                    ram_waveform_addra  <= (others=>'0');
                    ram_waveform_dina   <= (others=>'0');

                end if;
                    
                cpu_rdata_dv_e1     <= '0';
                cpu_rdata_dv_e2     <= '0';
                cpu_rdata_ramsel_d1 <= '0';
                cpu_rdata_ramsel_d2 <= '0';

            
            -------------------------------------------------
            -- CPU read
            -------------------------------------------------
            elsif (cpu_wr = '0') and (cpu_sel = '1') then
                
                if (cpu_addr(C_RAM_SELECT) = '1') then -- Waveform
                    ram_pulse_addra     <= (others=>'0');
                    ram_waveform_addra  <= cpu_addr(10 downto 0);
                else                                   -- Pulse
                    ram_pulse_addra     <= cpu_addr(9 downto 0);
                    ram_waveform_addra  <= (others=>'0');
                end if;

                ram_pulse_we        <= (others=>'0');
                ram_waveform_wea(0) <= '0';
                
                cpu_rdata_dv_e2     <= '1';                     -- DV for cycle, when RAM output occurs
                cpu_rdata_dv_e1     <= cpu_rdata_dv_e2;         -- DV for next cycle
                cpu_rdata_ramsel_d1 <= cpu_addr(C_RAM_SELECT);  -- Save the select bit one cycle later
                cpu_rdata_ramsel_d2 <= cpu_rdata_ramsel_d1;  
                    
            else
                ram_pulse_addra     <= (others=>'0');
                ram_pulse_we        <= (others=>'0');
                ram_waveform_addra  <= (others=>'0');
                ram_waveform_wea(0) <= '0';

                cpu_rdata_dv_e2     <= '0';
                cpu_rdata_dv_e1     <= cpu_rdata_dv_e2;         -- DV for next cycle
                cpu_rdata_ramsel_d1 <= '0';
                cpu_rdata_ramsel_d2 <= cpu_rdata_ramsel_d1;  
            
            end if;
            
            -------------------------------------------------
            -- Output the delayed RAM data
            -- This adds a pipeline delay to the cpu_rdata_dv to account for
            -- the delay in reading data from the RAM
            -------------------------------------------------
            if (cpu_rdata_dv_e1 = '1') then
                    
                cpu_rdata_dv    <= '1';
                
                -- Select source of output data
                if (cpu_rdata_ramsel_d2 = '1') then   -- Output is from waveform table
                    cpu_rdata   <= ram_waveform_douta;

                elsif (cpu_rdata_ramsel_d2 = '0') then
                    cpu_rdata   <= ram_pulse_douta;
                end if;

            else
                cpu_rdata       <= (others=>'0');
                cpu_rdata_dv    <= '0';
            end if;
            
        end if;
        
    end process;

    ----------------------------------------------------------------
    -- State machine: 
    -- Compares cnt_time input against current output from pulse position RAM.
    -- When values match iti incremnts the pulse postion RAM address to 
    -- retrieve the next pulse position and also starts reading the 
    -- entire waveform table, one value every clock cycle, until it reaches the end.
    -- Once the pulse is complete it waits for the next cnt_time match.
    -- Repeat until all pulse position RAM times have triggered a pulse output 
    -- or until the maximum counter time has been reached.
    ----------------------------------------------------------------
    pr_sm : process (reset, clk)
    -- Temp variables for waveform output
    variable v_ram_waveform_doutb_multiplied : std_logic_vector(C_BITS_GAIN_FACTOR + 15 downto 0);
    variable v_ram_waveform_addrb_scaled     : std_logic_vector(C_BITS_ADDR_START  + 15 downto 0);
    variable v_ram_waveform_addrb_raw        :         unsigned(C_BITS_ADDR_START  -  1 downto 0);
    begin
        if (reset = '1') then

            sm_state            <= S_IDLE;  -- TODO: Eric: Should this be S_RESET since we reset the JEDS interface as well?
            ram_pulse_addrb     <= (others=>'0');
            ram_waveform_addrb  <= (others=>'0');
            cnt_addr            <= (others=>'0');
            wave_last_addr      <= (others=>'0');

            sm_wavedata         <= (others=>'0');
            sm_wavedata_dv      <= '0';
            sm_busy             <= '0';
            reg_wave_start_addr <= (others=>'0');
            reg_wave_length     <= (others=>'0');
            reg_scale_gain      <= (others=>'0');
            reg_scale_time      <= (others=>'0');
            reg_wave_end_addr   <= (others=>'0');
            reg_pulse_time      <= (others=>'0');
            reg_pulse_flattop   <= (others=>'0');
            

            pc                  <= (others=>'0');
            cnt_wave_len        <= (others=>'0');
            cnt_wave_top        <= (others=>'0');
        elsif rising_edge(clk) then
            

            -- Pipeline delays to use for rising edge detection
            enable_d1       <= enable;  
            start_d1        <= start;
            sm_state_d1     <= sm_state;

            -- Default 
            sm_wavedata     <= (others=>'0');
            sm_wavedata_dv  <= '0';

            

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
                        sm_wavedata     <= (others=>'0');
                        sm_wavedata_dv  <= '1'; 
                        sm_state        <= S_IDLE;
                    end if;
                    sm_busy                         <= '0';

                ------------------------------------------------------------------------
                -- Wait for rising edge of 'start'.
                -- No data output.
                ------------------------------------------------------------------------
                when  S_IDLE    =>

                    if (start = '1') and (start_d1 = '0') then
                        sm_state    <= S_LOAD;
                        sm_busy     <= '1';
                    else
                        sm_busy     <= '0';
                    end if;

                ------------------------------------------------------------------------
                -- Load four addresses from pulse definition RAM into four 32 bits regesters
                ------------------------------------------------------------------------
                when  S_LOAD    =>
                    -- TODO: FromEric: does is needed here? or should be inside the if-else loops
                    -- Load the pulse channel RAM addresses and start the waveform output
                    sm_busy                         <= '1';
                    if (sm_state_d1 = S_WAVE_DOWN) then  -- output the last pulse definition address for one more clock cycle
                        v_ram_waveform_doutb_multiplied := std_logic_vector(unsigned(ram_waveform_doutb) * reg_scale_gain);
                        sm_wavedata                     <= v_ram_waveform_doutb_multiplied(30 downto 15); 
                        -- ram_waveform_addrb  <= (others=>'0'); -- reset the address for the next waveform
                        sm_wavedata_dv                  <= '1';
                    end if;  
                    -- Pipline the pulse definition address
                    if (unsigned(ram_pulse_addrb) mod 4 = 0) then
                        ram_pulse_addrb  <= std_logic_vector(unsigned(pc) + 1);
                        sm_state            <= S_LOAD;
                                                                                                                    -- first quarter of the pulse definition, no register is loaded
                        
                    elsif (unsigned(ram_pulse_addrb) mod 4 = 1) then
                        ram_pulse_addrb  <= std_logic_vector(unsigned(pc) + 2);
                        sm_state            <= S_LOAD;
                                                                                                                    -- second quarter of the pulse definition, the start time is loaded
                        reg_pulse_time      <= ram_pulse_doutb;
                        
                        
                    elsif (unsigned(ram_pulse_addrb) mod 4 = 2) then
                        ram_pulse_addrb  <= std_logic_vector(unsigned(pc) + 3);
                        sm_state            <= S_LOAD;
                                                                                                                    -- third quarter of the pulse definition, the length and start address of the wavetable are loaded
                        reg_wave_start_addr <= ram_pulse_doutb(C_BITS_ADDR_START - 1 downto 0);
                        reg_wave_length     <= unsigned(ram_pulse_doutb(25 downto 16));                            -- TODO: make this a constant

                    elsif (unsigned(ram_pulse_addrb) mod 4 = 3) then
                        sm_state            <= S_WAIT;                                                             -- address is on the forth word of the entry, the loading process is complete. Moving onto the next state
                                                                                                                    -- hold the last pulse definition address as it will be used in the next state
                        pc                  <= std_logic_vector(unsigned(pc) + C_PC_INCR);                         -- incremnet the pulse counter and start waiting to output the wave
                                                                                                                    -- forth quarter of the pulse definition, the scale factors are loaded
                        reg_scale_gain      <= unsigned(ram_pulse_doutb(31 downto 16));
                        reg_scale_time      <= unsigned(ram_pulse_doutb(15 downto 0));
                        reg_wave_end_addr  <=  resize(unsigned(reg_wave_start_addr) + reg_wave_length, 20) sll 8;  -- get the supposed last value of the wavetable                        

                    end if;

                ------------------------------------------------------------------------
                -- Wait for cnt_time, external input, to match pulse position RAM output
                -- Return to idle state if max time is reached. Output waveform value zero. 
                ------------------------------------------------------------------------
                when  S_WAIT    =>
                    -- read the last word of the pulse definition, the flat top value
                    reg_pulse_flattop               <= unsigned(ram_pulse_doutb(C_BITS_ADDR_TOP - 1 downto 0));
                    -- Start to output wave and increment pulse position RAM address
                    if (reg_pulse_time(C_START_TIME - 1 downto 0) = cnt_time) then
                        sm_state            <= S_WAVE_UP;
                        
                        ram_waveform_addrb  <= reg_wave_start_addr & std_logic_vector(to_unsigned(0, 8));          -- set the wavetable's address to the starting address defined from the pulse ram
                        -- cnt_addr            <= unsigned(reg_wave_start_addr);
                        -- reset the wave lenth counter
                        cnt_wave_len        <= (others=>'0');
                    elsif (cnt_time = X"FFFFFF") or (done_seq = '1') then
                        sm_state            <= S_IDLE;
                    end if;


                ------------------------------------------------------------------------
                -- Output the raising edge of a waveform
                -- Hold the last address when complete
                ------------------------------------------------------------------------
                when  S_WAVE_UP =>
                    -- Check if is end of rise of the waveform, next address >= end address. if so pad the address pointer to the end address and move to next state
                    -- TODO: convert the numbers below to constaint. right now just make sure I'm not confused
                    if (unsigned(ram_waveform_addrb) + reg_scale_time >= reg_wave_end_addr) then
                        -- ram_waveform_addrb  <= std_logic_vector(reg_wave_end_addr);                                -- pad the address pointer to the end address
                        if (sm_state_d1 = S_WAVE_UP) then
                            ram_waveform_addrb  <= std_logic_vector(reg_wave_end_addr);                                -- pad the address pointer to the end address
                        end if;
                        wave_last_addr      <= std_logic_vector(unsigned(ram_waveform_addrb));                     -- hold the last address of the wavetable
                        -- skip the flat top state if the flat top value is zero
                        if (reg_pulse_flattop = 0) then
                            sm_state            <= S_WAVE_DOWN;
                            -- reset the counter for the next transition
                            cnt_wave_len        <= (others=>'0');
                        else
                            sm_state            <= S_WAVE_FLAT;
                            -- reset the counter for the next transition
                            cnt_wave_len        <= (others=>'0');
                            cnt_wave_top        <= (others=>'0');
                        end if;
                    else
                        cnt_wave_len        <= cnt_wave_len + 1;
                        cnt_addr            <= cnt_addr + 1;
                        ram_waveform_addrb  <= std_logic_vector(unsigned(ram_waveform_addrb) + reg_scale_time);
                        wave_last_addr      <= std_logic_vector(unsigned(ram_waveform_addrb) + reg_scale_time);    -- hold the last address of the wavetable
                    end if;
                    
                    -- sm_wavedata         <= std_logic_vector(unsigned(ram_waveform_doutb) * reg_scale_gain)(31 downto 16); 
                    -- Modelsim Cannot synthesize this above line, so we *have to* seperate them into two lines
                    -- # ** Error: Prefix of slice name cannot be type conversion (STD_LOGIC_VECTOR) expression.
                    v_ram_waveform_doutb_multiplied := std_logic_vector(unsigned(ram_waveform_doutb) * reg_scale_gain);
                    sm_wavedata                     <= v_ram_waveform_doutb_multiplied(30 downto 15); 
                    if (sm_state_d1 = S_WAIT) then                                                                 -- data valid is delayed by one clock cycle
                        sm_wavedata_dv                  <= '0';
                    else
                        sm_wavedata_dv                  <= '1';
                    end if;
                    
                ------------------------------------------------------------------------
                -- Hold the last address and output its data
                -- decrement from this address when finished waiting
                ------------------------------------------------------------------------
                when S_WAVE_FLAT =>
                    -- count the 17-bit flat top, if the counter reaches the flat top value, then go to the next state
                    if (cnt_wave_top = reg_pulse_flattop) then
                        sm_state            <= S_WAVE_DOWN;
                        
                        cnt_wave_top        <= (others=>'0');                                                      -- reset the counter for the next transition
                        
                    else
                        cnt_wave_top        <= cnt_wave_top + 1;
                    end if;
                    v_ram_waveform_doutb_multiplied := std_logic_vector(unsigned(ram_waveform_doutb) * reg_scale_gain);
                    sm_wavedata                     <= v_ram_waveform_doutb_multiplied(30 downto 15);
                    sm_wavedata_dv                  <= '1';
                    
                ------------------------------------------------------------------------
                -- Output the falling edge of a waveform
                -- Hold the start address when complete
                ------------------------------------------------------------------------
                when S_WAVE_DOWN =>
                    
                -- End of waveform?
                    -- TODO: convert the numbers below to constaint. right now just make sure I'm not confused
                    if (unsigned(ram_waveform_addrb) - reg_scale_time < (resize(unsigned(reg_wave_start_addr), 20) sll 8)) or (unsigned(ram_waveform_addrb) = 0) then
                        ram_waveform_addrb  <= (others=>'0'); -- reset the address for the next waveform
                        cnt_addr            <= (others=>'0');
                        -- If the end of the pulse table is reached then go to idle, increment pulse address for the next waveform otherwise
                        if (ram_pulse_addrb = std_logic_vector(to_unsigned(C_LEN_PULSE-1, C_BITS_ADDR_PULSE))) then
                            ram_pulse_addrb     <= (others=>'0');
                            pc                  <= (others=>'0');
                            sm_state            <= S_IDLE;

                        else                                                                                       -- increment pulse address for the next waveform
                            ram_pulse_addrb     <= pc;
                            sm_state            <= S_LOAD;
                        end if;
                            
                    -- Output waveform from RAM with decremented address
                    else
                        cnt_wave_len        <= cnt_wave_len + 1;
                        -- ram_waveform_addrb  <= std_logic_vector(unsigned(ram_waveform_addrb) - reg_scale_time);
                        -- TODO: replace the above line with the following code if fall should be EXACTLY the same as rise
                        if (sm_state_d1 = S_WAVE_FLAT) or (sm_state_d1 = S_WAVE_UP) then  -- previous state was either S_WAVE_UP or S_WAVE_FLAT, so the ram_waveform_addrb should be whatever it was in the S_WAVE_UP state
                            ram_waveform_addrb  <= wave_last_addr;                                                 -- get the last address of the wavetable
                        else
                            ram_waveform_addrb  <= std_logic_vector(unsigned(ram_waveform_addrb) - reg_scale_time);
                        end if;
                        cnt_addr            <= cnt_addr - 1;
                    end if;
                    v_ram_waveform_doutb_multiplied := std_logic_vector(unsigned(ram_waveform_doutb) * reg_scale_gain);
                    sm_wavedata                     <= v_ram_waveform_doutb_multiplied(30 downto 15); 
                    sm_wavedata_dv                  <= '1'; 

                ------------------------------------------------------------------------
                -- Default
                ------------------------------------------------------------------------
                when others =>
                        sm_state                    <= S_IDLE;

            end case;
        end if;
    end process;

    busy <= sm_busy;

    -- AXI-Stream output.
    -- TBD: This should come from a FIFO
    -- TODO: the bits are not correct, should be top bits (C_BITS_GAIN_FACTOR + 16 downto C_BITS_GAIN_FACTOR), but for now just make it this way so modelsim can simulate
    axis_tdata          <= sm_wavedata;         -- axi stream output data, this output should be multiplied by the gain factor, then take the top 16 bits
    axis_tvalid         <= sm_wavedata_dv;      -- axi_stream output data valid

    -- TBD : Generate in state machine?
    axis_tlast          <= '0';                 -- axi_stream output last 
end channel;