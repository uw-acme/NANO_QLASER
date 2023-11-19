---------------------------------------------------------------
--  File         : qlaser_dacs_pulse_channel.vhd
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

    enable              : in  std_logic;                        -- Set when DAC interface is running
    start               : in  std_logic;                        -- Set when pulse generation sequence begins (trigger)
    cnt_time            : in  std_logic_vector(23 downto 0);    -- Time since trigger.

    busy                : out std_logic;                        -- Status signal

    -- CPU interface
    cpu_addr            : in  std_logic_vector( 9 downto 0);    -- Address input
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
-- Single channel pulse generator with two RAMs and a FIFO
----------------------------------------------------------------
architecture rtl of qlaser_dacs_pulse_channel is

-- RAM, pulse position, CPU port, read/write
constant C_NUM_PULSE        : integer   := 16;                  -- Number of output data values from pulse RAM (16x24-bit)
signal ram_pulse_addra      : std_logic_vector( 3 downto 0);    -- 16 entry RAM
signal ram_pulse_dina       : std_logic_vector(23 downto 0);
signal ram_pulse_douta      : std_logic_vector(23 downto 0);
signal ram_pulse_douta_d1   : std_logic_vector(23 downto 0);    -- Delay distrib RAM output to match pipeline of Block RAM
signal ram_pulse_we         : std_logic;

-- RAM, pulse position, from state machine
signal ram_pulse_addrb      : std_logic_vector( 3 downto 0);
signal ram_pulse_doutb      : std_logic_vector(23 downto 0);

signal cpu_rdata_dv_e1      : std_logic;
signal cpu_rdata_dv_e2      : std_logic;
signal cpu_rdata_ramsel_d1  : std_logic;
signal cpu_rdata_ramsel_d2  : std_logic;

-- Waveform RAM port connections. 
-- NOTE: Port A is 32-bit data, port B is 16-bit
constant C_LENGTH_WAVEFORM  : integer   := 1024;                -- Number of output data values from waveform RAM (1024x16-bit)
signal ram_waveform_ena     : std_logic;
signal ram_waveform_wea     : std_logic_vector( 0 downto 0);
signal ram_waveform_addra   : std_logic_vector( 8 downto 0);
signal ram_waveform_dina    : std_logic_vector(31 downto 0);
signal ram_waveform_douta   : std_logic_vector(31 downto 0);

signal ram_waveform_enb     : std_logic := '0';
signal ram_waveform_web     : std_logic_vector( 0 downto 0) := (others=>'0');
signal ram_waveform_addrb   : std_logic_vector( 9 downto 0);
signal ram_waveform_dinb    : std_logic_vector(15 downto 0) := (others=>'0');
signal ram_waveform_doutb   : std_logic_vector(15 downto 0);


-- State variable type declaration for main state machine
type t_sm_state  is (
    S_RESET,    -- Wait for 'enable'. Stay here until JESD interface is up and running,
    S_IDLE,     -- Wait for 'start'
    S_WAIT,     -- Wait for cnt_time, external input, to match pulse position RAM output
    S_WAVE      -- Output waveform RAM table
);
signal sm_state             : t_sm_state;
signal sm_wavedata          : std_logic_vector(15 downto 0);    -- Waveform RAM data
signal sm_wavedata_dv       : std_logic;    -- Signal to indicate that waveform RAM data is valid
signal sm_busy              : std_logic;    -- Signal to indicate that s.m. is not idle


---- FIFO port connections
--signal fifo_wr_en           : std_logic;
--signal fifo_full            : std_logic;
--signal fifo_empty           : std_logic;
--signal fifo_wr_rst_busy     : std_logic;
--signal fifo_rd_rst_busy     : std_logic;
--signal fifo_rd_en           : std_logic;
---- FIFO status signals for debug purpose
--signal fifo_wr_ack          : std_logic;
--signal fifo_overflow        : std_logic;
--signal fifo_valid           : std_logic;
--signal fifo_underflow       : std_logic;

-- Pipeline delays
signal start_d1             : std_logic;
signal enable_d1            : std_logic;

begin

    busy    <= sm_busy;

    ----------------------------------------------------------------
    -- Distributed RAM to hold 16 24-bit Pulse start times.
    -- Synch write, Asynch read
    -- Port A is for CPU read/write. 16x24-bit
    -- Port B is for pulse time data output. 16x24-bit
    ----------------------------------------------------------------
    u_ram_pulse : entity work.bram_pulseposition
    port map(
        clk        => clk               ,   -- input std_logic
        a          => ram_pulse_addra   ,   -- input slv[3:0]
        d          => ram_pulse_dina    ,   -- input slv[23 downto 0)
        we         => ram_pulse_we      ,
        spo        => ram_pulse_douta   ,   -- output slv(23 downto 0)
         
        dpra       => ram_pulse_addrb   ,   -- input slv[3:0]
        dpo        => ram_pulse_doutb       -- output slv(23 downto 0)
    );
    
    
    ----------------------------------------------------------------
    -- Waveform table Block RAM.
    -- Synch write, Synch read
    -- Port A is for CPU read/write. 512x32-bit
    -- Port B is for waveform data.  1024x16-bit
    ----------------------------------------------------------------
    u_ram_waveform : entity work.bram_waveform
    port map (
        -- Port A CPU Bus
        clka        => clk                ,   -- input  std_logic
        ena         => ram_waveform_ena   ,   -- input  std_logic
        wea         => ram_waveform_wea   ,   -- input  slv(0 downto 0)
        addra       => ram_waveform_addra ,   -- input  slv(8 downto 0)
        dina        => ram_waveform_dina  ,   -- input  slv(31 downto 0)
        douta       => ram_waveform_douta ,   -- output slv(31 downto 0)
        
        -- Port B waveform output
        clkb        => clk                ,   -- input  std_logic
        enb         => ram_waveform_enb   ,   -- input  std_logic
        web         => (others=>'0')      ,   -- input  slv(0 downto 0)
        addrb       => ram_waveform_addrb ,   -- input  slv(9 downto 0)
        dinb        => (others=>'0')      ,   -- input  slv(15 downto 0)
        doutb       => ram_waveform_doutb       -- output slv(15 downto 0)
    );
    
    

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
    begin
        if (reset = '1') then

            sm_state            <= S_IDLE;
            ram_pulse_addrb     <= (others=>'0');
            ram_waveform_addrb  <= (others=>'0');

            sm_wavedata         <= (others=>'0');
            sm_wavedata_dv      <= '0';
            sm_busy             <= '0';
            ram_waveform_enb    <= '0';

        elsif rising_edge(clk) then

            -- Pipeline delays to use for rising edge detection
            enable_d1       <= enable;  
            start_d1        <= start;  

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
                    sm_busy             <= '0';
                    ram_waveform_enb    <= '0';


                ------------------------------------------------------------------------
                -- Wait for rising edge of 'start'.
                -- No data output.
                ------------------------------------------------------------------------
                when  S_IDLE    =>

                    if (start = '1') and (start_d1 = '0') then
                        sm_state    <= S_WAIT;
                        sm_busy     <= '1';
                    else
                        sm_busy     <= '0';
                    end if;

                    ram_waveform_enb    <= '0';

                ------------------------------------------------------------------------
                -- Wait for cnt_time, external input, to match pulse position RAM output
                -- Return to idle state if max time is reached. Output waveform value zero. 
                ------------------------------------------------------------------------
                when  S_WAIT    =>

                    -- Start to output wave and increment pulse position RAM address
                    if (ram_pulse_doutb = cnt_time) then
                        sm_state        <= S_WAVE;

                    elsif (cnt_time = X"FFFFFF") then
                        sm_state        <= S_IDLE;
                    end if;

                    ram_waveform_enb    <= '1';

                ------------------------------------------------------------------------
                -- Output entire waveform RAM table
                -- Increment pulse address when complete
                ------------------------------------------------------------------------
                when  S_WAVE    =>

                    -- End of waveform?
                    if (ram_waveform_addrb = std_logic_vector(to_unsigned(C_LENGTH_WAVEFORM-1,10))) then

                        -- If the end of the pulse table is reached then go to idle
                        if (ram_pulse_addrb = std_logic_vector(to_unsigned(C_NUM_PULSE-1,10))) then
                            ram_pulse_addrb     <= (others=>'0');
                            sm_state            <= S_IDLE;

                        else    -- Increment pulse address. Wait for next pulse start time
                            ram_pulse_addrb     <= std_logic_vector(unsigned(ram_pulse_addrb) + 1);
                            sm_state            <= S_WAIT;
                        end if;
                            
                        ram_waveform_addrb  <= (others=>'0');

                    -- Output waveform from RAM with data valid set
                    else
                        ram_waveform_addrb  <= std_logic_vector(unsigned(ram_waveform_addrb) + 1);
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
    -- TBD: This should come from a FIFO
    axis_tdata          <= sm_wavedata;    -- axi stream output data
    axis_tvalid         <= sm_wavedata_dv;      -- axi_stream output data valid

    -- TBD : Generate in state machine?
    axis_tlast          <= '0';                 -- axi_stream output last 


    ----------------------------------------------------------------
    -- **** TBD : ADD FIFO ****
    ----------------------------------------------------------------
    -- FIFO for waveform data
    -- connect to external output to whatever we want to connect
    ----------------------------------------------------------------
    --u_data_to_stream : entity work.fifo_data_to_stream
    --port map (
    --    clk         => clk,                -- input std_logic
    --    srst        => reset,              -- input std_logic
    --    rd_en       => fifo_rd_en,         -- input std_logic
    --    wr_en       => fifo_wr_en,         -- input std_logic
    --    empty       => fifo_empty,         -- output std_logic
    --    full        => fifo_full,          -- output std_logic
    --    din         => ram_waveform_doutb, -- input slv(15 downto 0)
    --    dout        => fifo_dout,          -- output slv(15 downto 0)
    --    
    --    -- FIFO signals, some of then are for debug purpose
    --    wr_ack      => fifo_wr_ack,        -- output std_logic
    --    overflow    => fifo_overflow,      -- output std_logic
    --    valid       => fifo_valid,         -- output std_logic
    --    underflow   => fifo_underflow,     -- output std_logic
    --    wr_rst_busy => fifo_wr_rst_busy,   -- output std_logic
    --    rd_rst_busy => fifo_rd_rst_busy    -- output std_logic
    --);


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
                if (cpu_addr(9) = '1') then

                    ram_pulse_addra     <= (others=>'0');
                    ram_pulse_dina      <= (others=>'0');
                    ram_pulse_we        <= '0';

                    ram_waveform_wea(0) <= '1';
                    ram_waveform_ena    <= '1';
                    ram_waveform_addra  <= cpu_addr(8 downto 0);
                    ram_waveform_dina   <= cpu_wdata;

                else

                    ram_pulse_addra     <= cpu_addr(3 downto 0);
                    ram_pulse_dina      <= cpu_wdata(23 downto 0);
                    ram_pulse_we        <= '1';

                    ram_waveform_ena    <= '0';
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
                
                if (cpu_addr(9) = '1') then -- Waveform
                    ram_waveform_ena    <= '1';
                    ram_pulse_addra     <= (others=>'0');
                    ram_waveform_addra  <= cpu_addr(8 downto 0);
                else                        -- Pulse
                    ram_pulse_addra     <= cpu_addr(3 downto 0);
                    ram_pulse_douta_d1  <= ram_pulse_douta;         -- Delay distrib RAM output to match pipeline of Block RAM
                    ram_waveform_addra  <= (others=>'0');
                end if;

                ram_pulse_we        <= '0';
                ram_waveform_wea(0) <= '0';
                
                cpu_rdata_dv_e2     <= '1';             -- DV for cycle, when RAM output occurs
                cpu_rdata_dv_e1     <= cpu_rdata_dv_e2; -- DV for next cycle
                cpu_rdata_ramsel_d1 <= cpu_addr(9);     -- Save the select bit one cycle later
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
                    cpu_rdata   <= X"00" & ram_pulse_douta_d1;
                end if;

            else
                cpu_rdata       <= (others=>'0');
                cpu_rdata_dv    <= '0';
            end if;
            
        end if;
        
    end process;


--      ----------------------------------------------------------------
--      -- Read time from RAM to generate pulses
--      -- When input cnt_time equals RAM time output then set dout
--      -- to RAM amplitude output and read next set of RAM data.
--      -- Keep reading waveform RAM every clock cycle until the end of the RAM 
--      ----------------------------------------------------------------
--      pr_ram_pulse  : process(reset, clk)
--      begin
--          if (reset = '1') then
--          
--              ram_pulse_addrb     <= (others => '0');
--              start_pulse         <= '0';
--              dout_dv             <= '0';
--  
--          elsif rising_edge(clk) then
--  
--              -- dout     <= ram_amplitude;
--              
--              if (cnt_time = X"000000") then  -- Not triggered
--                  ram_pulse_addrb <= (others=>'0');
--                  dout_dv         <= '0';
--                  start_pulse     <= '0';
--                  
--              elsif (ram_time = cnt_time) then
--  
--                  ram_pulse_addrb <= std_logic_vector(unsigned(ram_pulse_addrb) + 1);
--                  dout_dv         <= '1';
--                  start_pulse     <= '1';
--                  
--              else
--                  dout_dv         <= '0';
--                  start_pulse     <= '0';
--              end if;
--  
--          end if;
--           
--      end process;
--  
--  
--      ----------------------------------------------------------------
--      -- Read amplitude from Waveform RAM to generate pulses
--      -- When start_pulse is asserted, and when FIFO is not full, write
--      -- amplitude to FIFO.
--      ----------------------------------------------------------------
--      pr_ram_wavetable : process(reset, clk)
--      begin
--          if (reset = '1') then
--              fifo_wr_en         <= '0';
--              ram_waveform_addrb <= (others => '0');
--              ram_waveform_enb   <= '0';
--              busy               <= '0';
--          elsif rising_edge(clk) then
--              if (read_table = '1') then  -- start_pulse get asserted
--                  busy               <= '1';
--                  -- TODO EricToGeoff   : This condition may not satisfy all cases of a fifo_ready, maybe also utilize fifo_wr_ack or just a simple FSM?
--                  if (fifo_full = '0') then
--                      fifo_wr_en         <= '1';
--                      ram_waveform_addrb <= std_logic_vector(unsigned(ram_waveform_addrb) + 1);
--                      ram_waveform_enb   <= '1';
--                  else
--                      fifo_wr_en <= '0';
--                      -- FIFO is full, wait
--                      ram_waveform_addrb <= ram_waveform_addrb;
--                      ram_waveform_enb   <= '0';
--                  end if;
--              else
--                  fifo_wr_en         <= '0';
--                  ram_waveform_addrb <= (others => '0');
--                  ram_waveform_enb   <= '0';
--              end if;
--          end if;
--  
--      end process;
--      
--      -- For new versions, ram_doutb are differnt RAMs b port outputs, ram_amplitude should go thought a FIFO first from RAM
--      ram_time        <= ram_doutb;
--      read_table      <= start_pulse;
--  
--      fifo_rd_en      <= axi_tready and fifo_full;

end rtl;
