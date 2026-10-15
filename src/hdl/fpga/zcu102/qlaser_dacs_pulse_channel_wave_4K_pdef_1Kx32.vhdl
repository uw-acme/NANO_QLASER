---------------------------------------------------------------
--  File         : qlaser_dacs_pulse_channel_wave_4K_pdef_1Kx32.vhdl
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
    err_wave            : out std_logic;                        -- Error signal. Waveform RAM read-past-end

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
-- Single channel pulse generator with two RAMs
----------------------------------------------------------------
architecture wave_4K_pdef_1Kx32 of qlaser_dacs_pulse_channel is

-- RAM, pulse definition, CPU port, read/write
constant C_NUM_PULSE        : integer   := 256;                  -- Number of output data values from pulse def RAM (1Kx32 = 256x128-bit)
signal ram_pdef_wea         : std_logic_vector( 0 downto 0);
signal ram_pdef_addra       : std_logic_vector( 9 downto 0);    -- 16 entry RAM
signal ram_pdef_dina        : std_logic_vector(31 downto 0);
signal ram_pdef_douta       : std_logic_vector(31 downto 0);

signal ram_pdef_web         : std_logic_vector( 0 downto 0) := (others=>'0');   -- Unused
signal ram_pdef_addrb       : std_logic_vector( 9 downto 0);                    -- From state machine
signal ram_pdef_dinb        : std_logic_vector(31 downto 0) := (others=>'0');   -- Unused
signal ram_pdef_doutb       : std_logic_vector(31 downto 0);                    -- From state machine

signal cpu_rdata_dv_e2      : std_logic;
signal cpu_rdata_dv_e1      : std_logic;
signal cpu_rdata_ramsel_d1  : std_logic;
signal cpu_rdata_ramsel_d2  : std_logic;

-- Waveform RAM port connections. 
-- NOTE: Port A is 2Kx32-bit data, port B is 4Kx16-bit
constant C_LENGTH_WAVEFORM  : integer   := 4*1024;                -- Number of output data values from waveform RAM (4096x16-bit)
signal ram_waveform_wea     : std_logic_vector( 0 downto 0);
signal ram_waveform_addra   : std_logic_vector(10 downto 0);
signal ram_waveform_dina    : std_logic_vector(31 downto 0);
signal ram_waveform_douta   : std_logic_vector(31 downto 0);

signal ram_waveform_web     : std_logic_vector( 0 downto 0) := (others=>'0');
signal ram_waveform_addrb   : std_logic_vector(11 downto 0);
signal ram_waveform_dinb    : std_logic_vector(15 downto 0) := (others=>'0');
signal ram_waveform_doutb   : std_logic_vector(15 downto 0);

----------------------------------------------------------------
-- Fields of pulse definition
-- Entry word 0 :   doutb[23: 0]  : pulse start time 
-- Entry word 1 :   doutb[11: 0]  : waveform start address 
--                  doutb[27:16]  : waveform length 
-- Entry word 2 :   doutb[15: 0]  : gain scale factor 
--                  doutb[31:16]  : address scale factor 
-- Entry word 3 :   doutb[16: 0]  : pulse flat top length in clock cycles 
----------------------------------------------------------------
signal reg_pdef_start       : std_logic_vector(23 downto 0);
signal reg_pdef_wave_addr   : std_logic_vector(11 downto 0);
signal reg_pdef_wave_len    : unsigned( 9 downto 0);
signal reg_pdef_gscale      : std_logic_vector(15 downto 0);
signal reg_pdef_tscale      : std_logic_vector(15 downto 0);
signal reg_pdef_flattop     : unsigned(16 downto 0);

-- State variable type declaration for main state machine
type t_sm_state  is (
    S_RESET     , -- Wait for 'enable'. Stay here until JESD interface is up and running.
    S_IDLE      , -- Wait for 'start'.
    S_RD_PDEF   , -- Read next entry (4 values) from pdef RAM.
    S_WAIT      , -- Wait for cnt_time, to match pdef RAM start-time output.
    S_WAVE_RISE , -- Output waveform RAM table. Start address and number of points from pulse def RAM.
    S_WAVE_TOP  , -- Output constant last value of rising waveform. Number of clock cycles from pulse def RAM.
    S_WAVE_FALL   -- Output waveform RAM table in reverse order. Then go to S_RD_PDEF
);
signal sm_state             : t_sm_state;
signal sm_wavedata          : std_logic_vector(15 downto 0);    -- Waveform RAM data
signal sm_wavedata_dv       : std_logic;    -- Signal to indicate that waveform RAM data is valid
signal sm_busy              : std_logic;    -- Signal to indicate that s.m. is not idle

-- Pipeline delays
signal start_d1             : std_logic;
signal enable_d1            : std_logic;

signal cnt_pdef_entry       : unsigned( 7 downto 0);        -- Pulse definition entry counter. Upper bits of PDEF RAM address
signal cnt_pdef_rd          : std_logic_vector( 1 downto 0);-- Lower two bits of PDEF RAM address 
signal cnt_wave             : unsigned(16 downto 0);        -- Counter for wave rise/flat/fall states duration

begin

    busy    <= sm_busy;

    ----------------------------------------------------------------
    -- Block RAM to hold 256 4-word, 32-bit Pulse Definition entries.
    -- Port A is for CPU read/write. 1Kx32-bit
    -- Port B is for pulse definition data output. 1Kx32-bit
    ----------------------------------------------------------------
    -- PDEF RAM
    -- Entry word 0 :   doutb[23: 0]  : pulse start time 
    -- Entry word 1 :   doutb[11: 0]  : waveform start address 
    --                  doutb[27:16]  : waveform length 
    -- Entry word 2 :   doutb[15: 0]  : gain scale factor 
    --                  doutb[31:16]  : address scale factor 
    -- Entry word 3 :   doutb[16: 0]  : pulse flat top length in clock cycles 
    ----------------------------------------------------------------
    u_ram_pdef : entity work.bram_pdef
    port map(

        -- Port A CPU Bus
        clka        => clk              ,   -- input  std_logic
        wea         => ram_pdef_wea     ,   -- input  slv( 0 downto 0)
        addra       => ram_pdef_addra   ,   -- input  slv( 9 downto 0)
        dina        => ram_pdef_dina    ,   -- input  slv(31 downto 0)
        douta       => ram_pdef_douta   ,   -- output slv(31 downto 0)
        
        -- Port B waveform output
        clkb        => clk              ,   -- input  std_logic
        web         => (others=>'0')    ,   -- input  slv( 0 downto 0)
        addrb       => ram_pdef_addrb   ,   -- input  slv( 9 downto 0)
        dinb        => (others=>'0')    ,   -- input  slv(31 downto 0)
        doutb       => ram_pdef_doutb       -- output slv(31 downto 0)
    );
    
    
    ----------------------------------------------------------------
    -- Waveform table Block RAM.
    -- Synch write, Synch read
    -- Port A is for CPU read/write. 2048x32-bit
    -- Port B is for waveform data.  4096x16-bit
    ----------------------------------------------------------------
    u_ram_waveform : entity work.bram_waveform_4kx16
    port map (
        -- Port A CPU Bus
        clka        => clk                ,   -- input  std_logic
        wea         => ram_waveform_wea   ,   -- input  slv( 0 downto 0)
        addra       => ram_waveform_addra ,   -- input  slv(10 downto 0)
        dina        => ram_waveform_dina  ,   -- input  slv(31 downto 0)
        douta       => ram_waveform_douta ,   -- output slv(31 downto 0)
        
        -- Port B waveform output
        clkb        => clk                ,   -- input  std_logic
        web         => (others=>'0')      ,   -- input  slv( 0 downto 0)
        addrb       => ram_waveform_addrb ,   -- input  slv(11 downto 0)
        dinb        => (others=>'0')      ,   -- input  slv(15 downto 0)
        doutb       => ram_waveform_doutb     -- output slv(15 downto 0)
    );
    

    ----------------------------------------------------------------
    -- State machine: 
    -- Waits for JESD channels to sync.
    -- Waits for a 'start' rising edge.
    -- Reads first pulse definition entry. (Four words from pdef RAM)
    -- Compares cnt_time input against start time from pdef RAM.
    -- When values match it starts reading the waveform RAM. 
    -- one value value every clock cycle. Pdef RAM specs start and number of points to read.
    -- Addresses calculated using addr scale factor.
    -- Then holds output for duration of flat-top count.
    -- Then outputs waveform in reverse order.
    -- Reads next pulse definition entry and waits for the next cnt_time match.
    -- Repeat until all pulse position RAM times have triggered a pulse output 
    -- or until the maximum counter time has been reached.
    ----------------------------------------------------------------
    pr_sm : process (reset, clk)
    begin
        if (reset = '1') then

            sm_state            <= S_RESET;
            ram_pdef_addrb      <= (others=>'0');
            ram_waveform_addrb  <= (others=>'0');

            sm_wavedata         <= (others=>'0');
            sm_wavedata_dv      <= '0';
            sm_busy             <= '0';
            err_wave            <= '0';

            reg_pdef_start      <= (others=>'0'); 
            reg_pdef_wave_addr  <= (others=>'0'); 
            reg_pdef_wave_len   <= (others=>'0'); 
            reg_pdef_gscale     <= (others=>'0'); 
            reg_pdef_tscale     <= (others=>'0'); 
            reg_pdef_flattop    <= (others=>'0'); 
            cnt_pdef_entry      <= (others=>'0'); 
            cnt_pdef_rd         <= (others=>'0'); 
            cnt_wave            <= (others=>'0'); 

        elsif rising_edge(clk) then

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
                    sm_busy             <= '0';
                    cnt_pdef_entry      <= (others=>'0');
                    ram_pdef_addrb      <= std_logic_vector(cnt_pdef_entry) & "00";


                ------------------------------------------------------------------------
                -- Wait for rising edge of 'start'.
                -- No data output.
                ------------------------------------------------------------------------
                when  S_IDLE    =>

                    if (start = '1') and (start_d1 = '0') then
                        sm_state    <= S_RD_PDEF;
                        sm_busy     <= '1';
                        err_wave    <= '0';
                    else
                        sm_busy     <= '0';
                    end if;


                ------------------------------------------------------------------------
                -- Read next entry (4 values) from pdef RAM and save values in registers.
                -- reg_pdef_start       : std_logic_vector(23 downto 0);
                -- reg_pdef_wave_addr   : std_logic_vector(11 downto 0);
                -- reg_pdef_wave_len    : std_logic_vector( 9 downto 0);
                -- reg_pdef_gscale      : std_logic_vector(15 downto 0);
                -- reg_pdef_tscale      : std_logic_vector(15 downto 0);
                -- reg_pdef_flattop     : std_logic_vector(16 downto 0);
                ------------------------------------------------------------------------
                when  S_RD_PDEF   =>

                    if (cnt_pdef_rd = "00") then
                        reg_pdef_start      <= ram_pdef_doutb(23 downto 0);
                        ram_pdef_addrb      <= std_logic_vector(cnt_pdef_entry) & "01";
                        cnt_pdef_rd         <= "01";
                        
                    elsif (cnt_pdef_rd = "01") then
                        reg_pdef_wave_addr  <= ram_pdef_doutb(11 downto  0);
                        reg_pdef_wave_len   <= unsigned(ram_pdef_doutb(25 downto 16));
                        ram_pdef_addrb      <= std_logic_vector(cnt_pdef_entry) & "10";
                        cnt_pdef_rd         <= "10";
                        
                    elsif (cnt_pdef_rd = "10") then
                        reg_pdef_gscale     <= ram_pdef_doutb(15 downto  0);
                        reg_pdef_tscale     <= ram_pdef_doutb(31 downto 16);
                        ram_pdef_addrb      <= std_logic_vector(cnt_pdef_entry) & "11";
                        cnt_pdef_rd         <= "10";
                        
                    elsif (cnt_pdef_rd = "11") then
                        reg_pdef_flattop    <= unsigned(ram_pdef_doutb(16 downto  0));
                        ram_pdef_addrb      <= std_logic_vector(cnt_pdef_entry) & "00";
                        cnt_pdef_rd         <= "00";
                        sm_state            <= S_WAIT;
                        
                    end if;

                    sm_wavedata         <= ram_waveform_doutb; 
                    sm_wavedata_dv      <= '1'; 

                ------------------------------------------------------------------------
                -- Wait for cnt_time, an external input, to match pdef RAM output
                -- Return to idle state if max time is reached. Output waveform value zero. 
                ------------------------------------------------------------------------
                when  S_WAIT    =>

                    -- Start to output wave 
                    if (cnt_time = reg_pdef_start) then
                        sm_state            <= S_WAVE_RISE;
                        ram_waveform_addrb  <= std_logic_vector(reg_pdef_wave_addr);

                    elsif (cnt_time = X"FFFFFF") then
                        sm_state        <= S_IDLE;
                    end if;


                ------------------------------------------------------------------------
                -- Output waveform RAM table 
                -- Start address and number of points from pulse def RAM.
                ------------------------------------------------------------------------
                when  S_WAVE_RISE    =>

                    -- End of waveform rise?
                    if (cnt_wave(9 downto 0) = reg_pdef_wave_len) then

                        sm_state        <= S_WAVE_TOP;

                        cnt_wave            <= (others=>'0');
                        sm_wavedata         <= ram_waveform_doutb; 
                        sm_wavedata_dv      <= '1'; 
                            
                    -- Output waveform from RAM with data valid set
                    -- Increment waveform address.  -- TODO use reg_pdef_tscale instead of incrementing
                    else
                        -- If going to overflow the pulse table is reached then set error?
                        if (ram_waveform_addrb = std_logic_vector(to_unsigned(C_NUM_PULSE-1,10))) then
                            err_wave  <= '1';

                        else
                            ram_waveform_addrb  <= std_logic_vector(unsigned(ram_waveform_addrb) + 1);
                            sm_wavedata         <= ram_waveform_doutb; 
                            sm_wavedata_dv      <= '1'; 
						end if;
						
                    end if;


                ------------------------------------------------------------------------
                -- Output constant last value of rising waveform. Number of clock cycles from pulse def RAM.
                ------------------------------------------------------------------------
                when S_WAVE_TOP     =>

                    if (cnt_wave = reg_pdef_flattop) then
                        sm_state    <= S_WAVE_FALL;
                        cnt_wave    <= (others=>'0');
                    else
                        cnt_wave    <= cnt_wave + 1;
                    end if;


                ------------------------------------------------------------------------
                -- Output waveform RAM table in reverse order. Then go to S_RD_PDEF
                -- or IDLE
                ------------------------------------------------------------------------
                when S_WAVE_FALL    =>
                
                    -- End of waveform rise?
                    if (cnt_wave(9 downto 0) = reg_pdef_wave_len) then

                        sm_state            <= S_RD_PDEF;
                        cnt_pdef_rd         <= "00";
                        cnt_wave            <= (others=>'0');

                        sm_wavedata         <= ram_waveform_doutb; 
                        sm_wavedata_dv      <= '1'; 
                            
                    -- Output waveform from RAM with data valid set
                    -- Decrement waveform address.  -- TODO use reg_pdef_tscale instead of decrementing
                    else
                        ram_waveform_addrb  <= std_logic_vector(unsigned(ram_waveform_addrb) - 1);
                        sm_wavedata         <= ram_waveform_doutb; 
                        sm_wavedata_dv      <= '1'; 
                    end if;


                ------------------------------------------------------------------------
                -- Default
                ------------------------------------------------------------------------
                when others =>
                        sm_state            <= S_IDLE;

            end case;

        end if;

    end process;

    -- AXI-Stream output.
    -- TODO: Scale by gain factor
    axis_tdata          <= sm_wavedata;     -- axi stream output data
    axis_tvalid         <= sm_wavedata_dv;  -- axi_stream output data valid

    -- TBD : Generate in state machine? Not really necessary?
    axis_tlast          <= '0';                 -- axi_stream output last 


    ----------------------------------------------------------------
    -- CPU Read/Write RAM
    -- cpu_addr(11) is used to select one of the two RAMs 
    -- to read/write, and the remainder are an 11-bit RAM address.
    ----------------------------------------------------------------
    pr_ram_rw  : process (reset, clk)
    begin
        if (reset = '1') then
        
            ram_pdef_addra     <= (others=>'0');
            ram_pdef_dina      <= (others=>'0');
            ram_pdef_wea       <= (others=>'0');

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
            
                -- 0 for pdef, 1 for waveform table
                if (cpu_addr(11) = '1') then

                    ram_pdef_wea(0)     <= '0';
                    ram_pdef_addra      <= (others=>'0');
                    ram_pdef_dina       <= (others=>'0');

                    ram_waveform_wea(0) <= '1';
                    ram_waveform_addra  <= cpu_addr(10 downto 0);
                    ram_waveform_dina   <= cpu_wdata;

                else

                    ram_pdef_wea(0)     <= '1';
                    ram_pdef_addra      <= cpu_addr( 9 downto 0);
                    ram_pdef_dina       <= cpu_wdata;

                    ram_waveform_wea(0) <= '0';
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
                
                if (cpu_addr(11) = '1') then -- Waveform RAM
                    ram_pdef_addra      <= (others=>'0');
                    ram_waveform_addra  <= cpu_addr(10 downto 0);
                else                        -- Pulse RAM
                    ram_pdef_addra      <= cpu_addr( 9 downto 0);
                    ram_waveform_addra  <= (others=>'0');
                end if;

                ram_pdef_wea(0)     <= '0';
                ram_waveform_wea(0) <= '0';
                
                cpu_rdata_dv_e2     <= '1';             -- DV for cycle, when RAM output occurs
                cpu_rdata_dv_e1     <= cpu_rdata_dv_e2; -- DV for next cycle
                cpu_rdata_ramsel_d1 <= cpu_addr(11);    -- Save the select bit one cycle later
                cpu_rdata_ramsel_d2 <= cpu_rdata_ramsel_d1;  
                    
            else
                ram_pdef_addra      <= (others=>'0');
                ram_pdef_wea(0)     <= '0';
                ram_waveform_addra  <= (others=>'0');
                ram_waveform_wea(0) <= '0';

                cpu_rdata_dv_e2     <= '0';
                cpu_rdata_dv_e1     <= cpu_rdata_dv_e2; -- DV for next cycle
                cpu_rdata_ramsel_d1 <= '0';
                cpu_rdata_ramsel_d2 <= cpu_rdata_ramsel_d1;  
            
            end if;
            
            ---------------------------------------------------------
            -- Output 32-bits from part of the delayed RAM data
            -- This adds a pipeline delay to the cpu_rdata_dv 
            -- to account for the delay in reading data from the RAM
            ---------------------------------------------------------
            if (cpu_rdata_dv_e1 = '1') then
                    
                cpu_rdata_dv    <= '1';
                
                -- Select source of output data
                if (cpu_rdata_ramsel_d2 = '1') then   -- Output is from waveform table
                    cpu_rdata   <= ram_waveform_douta;

                elsif (cpu_rdata_ramsel_d2 = '0') then
                    cpu_rdata   <= ram_pdef_douta;
                end if;

            else
                cpu_rdata       <= (others=>'0');
                cpu_rdata_dv    <= '0';
            end if;
            
        end if;
        
    end process;

end wave_4K_pdef_1Kx32;

