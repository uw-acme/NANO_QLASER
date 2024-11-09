-----------------------------------------------------------
-- File : tb_pulse_channel_random_polynomials.vhd
-----------------------------------------------------------
-- 
-- More complex testbench for the pulse channel.
--
--  Description  : Generates random polynomials and tests the pulse channel
--                 Compare the output of the pulse channel with the output of a
--                 floating-point reference model.
--
----------------------------------------------------------
library ieee;
library std;
library std_developerskit;
use     ieee.numeric_std.all;

use     ieee.std_logic_1164.all; 
use     ieee.std_logic_textio.all;
use     ieee.std_logic_misc.all;
use     std.textio.all;

use     ieee.math_real.all;

use     std_developerskit.std_iopak.all;
use     work.qlaser_pkg.all;
use     work.qlaser_dacs_pulse_channel_pkg.all;
use     work.qlasert_pulse_channel_tasks.all;

entity tb_pulse_channel_random_polynomials is
    -- TODO: EricToGeoff: is there way to put it in the package or separate file?
    generic (
        SEED        : integer := 1;
        RESULT_FILE : string  := "errors.txt";
        DEGREES     : integer := 2
    );
end    tb_pulse_channel_random_polynomials;

architecture verify of tb_pulse_channel_random_polynomials is 

------------------------------------------------------------------------
-- Pulse Channel DUT signals
------------------------------------------------------------------------
signal clk                          : std_logic;
signal reset                        : std_logic;
signal enable                       : std_logic;  
signal start                        : std_logic;  
signal cnt_time                     : std_logic_vector(23 downto 0);  
signal busy                         : std_logic;  
signal done_seq                     : std_logic;
signal cpu_wr                       : std_logic;
signal cpu_sel                      : std_logic;
signal cpu_addr                     : std_logic_vector(15 downto 0);
signal cpu_wdata                    : std_logic_vector(31 downto 0);
signal cpu_rdata                    : std_logic_vector(31 downto 0);
signal cpu_rdata_dv                 : std_logic; 
signal erros                        : std_logic_vector(C_ERRORS_TOTAL - 1 downto 0);
signal clear_errors                 : std_logic;

-- AXI-stream output interface
signal axis_tready                  : std_logic := '1'; -- Always ready
signal axis_tdata                   : std_logic_vector(15 downto 0);
signal axis_tvalid                  : std_logic;
signal axis_tlast                   : std_logic;

------------------------------------------------------------------------
-- Simulation signals
------------------------------------------------------------------------
-- Halts simulation by stopping clock when set true
signal sim_done                     : boolean   := false;

-- Simulation "RAMs"
signal fakeram_wt                   : real_array(0 to C_LENGTH_WAVEFORM - 1);         -- fake waveform RAM
signal start_times                  : real_array(0 to 255);                           -- start times for each pulse (st_n)
signal pulse_times                  : real_array(0 to 255);                           -- pulse times for each pulse (sp_n)
signal start_idx                    : real_array(0 to 255);                           -- start index for each pulse 
signal pulse_delays                 : real_array(0 to 255);                           -- pulse flats for each pulse (D_n)
signal time_factors                 : real_array(0 to 255);                           -- time factors for each pulse
signal gain_factors                 : real_array(0 to 255);                           -- gain factors for each pulse

-- Simulation signals (more for waveform debugging)
signal total_pulses                 : integer := 0;                                   -- total number of pulses
signal wave_values                  : real;
signal diffs                        : real    := 0.0;                                 -- difference between expected and actual values
signal axis_tdata_d1                : real    := 0.0;                                 -- previous axis_tdata
signal max_error                    : real    := 0.0;                                 -- record the maximum error
signal mx_err_delta                 : real    := 0.0;                                 -- the delta between current max errored value and its previous output value
signal mx_err_time                  : integer := 0;                                   -- the time when the maximum error occurs
signal mx_err_pulse                 : integer := 0;                                   -- the pulse with maximum error
signal mx_sim_time                  : time;                                           -- the time when the maximum error occurs
signal mx_param_errs                : std_logic_vector(C_ERRORS_TOTAL - 1 downto 0);  -- record the input errors of the max error

type real_arr_2d is array (255 downto 0) of real_array(0 to C_LENGTH_WAVEFORM - 1);
signal arr_coeffs                   : real_arr_2d := (others => (others => 0.0));

-------------------------------------------------------------
-- Delay
-------------------------------------------------------------
procedure clk_delay(
    constant nclks  : in  integer
) is
begin
    for I in 0 to nclks loop
        wait until clk'event and clk ='0';
    end loop;
end;

-------------------------------------------------------------
-- Other helper functions are now moved to qlasert_pulse_channel_tasks.vhdl
-------------------------------------------------------------

function real_arr_to_string(
    constant size : in integer;  -- numbers of items
    constant arr  : in real_array;
    constant sep  : in string := ", "
) return string is
    variable result  : string(1 to 256);  -- Adjust size as needed
    variable strsize : integer;
    variable index   : integer := 1;
    variable i       : integer := 0;
begin
    -- Add remaining elements
    for i in 0 to size - 1 loop
    -- TODO: while loop is not working, need to fix it so dont depend on the size
    -- while strlen(to_string(arr(i+1))) > 0 loop
        strsize := strlen(to_string(arr(i)));
        result(index to index + strsize - 1 + strlen(sep)) := to_string(arr(i)) & sep;
        index := index + strsize + strlen(sep);
        -- i := i + 1;
    end loop;

    -- Return the constructed string
    return result(1 to index - 1 - strlen(sep));
end real_arr_to_string;

begin
    -------------------------------------------------------------
	-- Unit Under Test
    -------------------------------------------------------------
	u_dac_pulse : entity work.qlaser_dacs_pulse_channel
	port map (
        clk             => clk                      , -- in  std_logic;
        reset           => reset                    , -- in  std_logic;

        enable          => enable                   , -- out std_logic;  
        start           => start                    , -- out std_logic; 
        cnt_time        => cnt_time                 , -- out std_logic_vector(23 downto 0);

        busy            => busy                     , -- out std_logic;
        done_seq        => done_seq                 , -- in std_logic;

        erros           => erros                    , -- out std_logic_vector(C_ERRORS_TOTAL - 1 downto 0);
        clear_errors    => clear_errors             , -- in  std_logic;

        -- CPU interface
        cpu_wr          => cpu_wr                   , -- in  std_logic;
        cpu_sel         => cpu_sel                  , -- in  std_logic;
        cpu_addr        => cpu_addr(11 downto 0)    , -- in  std_logic_vector(11 downto 0);
        cpu_wdata       => cpu_wdata                , -- in  std_logic_vector(31 downto 0);

        cpu_rdata       => cpu_rdata                , -- out std_logic_vector(31 downto 0);
        cpu_rdata_dv    => cpu_rdata_dv             , -- out std_logic; 

                   
        -- AXI-Stream interface
        axis_tready     => axis_tready              , -- in  std_logic;          -- Clock (50 MHz max)
        axis_tdata      => axis_tdata               , -- out std_logic_vector(15 downto 0);
        axis_tvalid     => axis_tvalid              , -- out std_logic;          -- Master out, Slave in. (Data to DAC)
        axis_tlast      => axis_tlast                 -- out std_logic;          -- Active low chip select (sync_n)
    );
	
    -------------------------------------------------------------
    -- Generate system clock. Halt when sim_done is true.
    -------------------------------------------------------------
    pr_clk : process
    begin
        clk  <= '0';
        wait for (CLK_PER/2);
        clk  <= '1';
        wait for (CLK_PER-CLK_PER/2);
        if (sim_done=true) then
            wait; 
        end if;
    end process;
    -------------------------------------------------------------
    -- Reset and drive CPU bus 
    -------------------------------------------------------------
    pr_main : process
    -- Read/Write files
    file err_out              : ascii_text open append_mode is RESULT_FILE;
    file err_in               : ascii_text open read_mode is RESULT_FILE;

    variable line_buf         : string(1 TO 256);
    variable line_cnt         : integer     := 1;    -- line counter

    -- variables for loading the waveform RAM
    variable v_ndata32        : integer     := 0;
    variable v_ndata16        : integer     := 0;
    variable v_ndata32_upper  : integer     := 0;
    variable v_ndata32_lower  : integer     := 0;

    -- base definitions of each pulses, all pulses are based on these but scaled/offset a bit
    variable v_pulsetime      : integer     := 0;    -- For 24-bit pulse time
    variable v_timefactor     : real        := 0.0;  -- For 16-bit fixed point timestep
    variable v_gainfactor     : real        := 0.0;  -- For 16-bit fixed point gain
    variable v_wavesteps      : integer     := 0;    -- For 10-bit number of steps i.e. 0 = 1 step, X"3FF" = 1024 points
    variable v_wavetopwidth   : integer     := 0;    -- For 17-bit number of clock cycles in top of waveform

    -- for RNG's
    variable int_seed         : integer;
    variable seed1            : positive;
    variable seed2            : positive;
    variable x                : real;

    -- for generating multiple polynomials
    variable wave_val         : real        := 0.0;
    variable sim_addr         : integer     := 0;                               -- for fakeram table address
    variable v_coeffs         : real_array(0 to 4095);                          -- coefficients for the polynomial

    -- variables for the floating point pulse generator
    variable x_processed      : real        := 0.0;                             -- the processed (shifted/scaled) x value for the polynomial
    variable rel_time         : real        := 0.0;                             -- the relative time for the polynomial
    variable pulse_width      : real        := 0.0;                             -- the pulse width for the polynomial
                                            
    -- variables for calculating the error
    variable v_dff            : real        := 0.0;                             -- difference between expected and actual values

    variable v_pulseaddr      : integer     := 0;                               -- manually set the pulse address, 0 to 255

    begin
        -- Reset 
        reset            <= '1';
        enable           <= '0';
        start            <= '0';
        clear_errors     <= '0';
        done_seq         <= '0';
        cnt_time         <= (others=>'0');

        cpu_sel          <= '0';
        cpu_wr           <= '0';
        cpu_wdata        <= (others=>'0');
        cpu_addr  	     <= (others=>'0');

        wave_values      <= 0.0;

        fakeram_wt       <= (others => 0.0);
        start_times      <= (others => 0.0);
        pulse_times      <= (others => 0.0);
        pulse_delays     <= (others => 0.0);
        start_idx        <= (others => 0.0);
        time_factors     <= (others => 0.0);
        gain_factors     <= (others => 0.0);

        cpu_print_msg("Simulation start");

    
        clk_delay(5);
        reset            <= '0';

        clk_delay(5);
        enable           <= '1';
    
        clk_delay(20);

        v_coeffs         := (others => 0.0);
        
        -- parse the line until the end of the file
        while not endfile(err_in) loop
            fgetline(line_buf, err_in);
            line_cnt := line_cnt + 1;
        end loop;

        if line_cnt = 1 then
            fputs("Run#" & ", Time (ns)" & ", Max Error" & ", Delta" & ", Error/Delta" & ", Pulse Number" & ", CNT-Time", err_out);
        end if;

        ----------------------------------------------------------------
        -- Generate random polynomials and pulse parameters
        -- Right now, sp_n and D_n are randomly generated, and st_n is calculated using a simple formula
        ----------------------------------------------------------------
        cpu_print_msg("generating random polynomials...");
        int_seed         := SEED;
        seed1            := positive(int_seed);
        seed2            := positive(int_seed + 1);
        cpu_print_msg("Seed: " & to_string(int_seed));

        while sim_addr < C_LENGTH_WAVEFORM and v_pulseaddr < 256 loop  -- make sure we don't go over the rams sizes
            cpu_print_msg("Generating pulse " & to_string(v_pulseaddr));
            for NCOEFF in 0 to DEGREES + 1 loop
                uniform(seed1, seed2, x);
                v_coeffs(NCOEFF) := x;
            end loop;
            
            -- generate random pulse steps (sp_n)
            uniform(seed1, seed2, x);
            v_wavesteps        := integer(x * 1022.0) + 1;  -- the ramdom value is always 0 to 1, so we scale it to 1 to 1024 (2^10) (minimum 1 step, maximum 1024 steps)
            -- check if the rest of the ram is enough to store the rest of the waveform. If not, assume this is the last pulse
            if sim_addr + v_wavesteps >= C_LENGTH_WAVEFORM then
                v_wavesteps := C_LENGTH_WAVEFORM - sim_addr;
                total_pulses <= v_pulseaddr;
            end if;
            
            -- generate random pulse flats (D_n)
            uniform(seed1, seed2, x);
            v_wavetopwidth     := integer(x * 1000.0);  -- the ramdom value is always 0 to 1, so we scale it to 0 to 65536, note this number can be modified to anything
            
            -- generate the time and gain factors
            uniform(seed1, seed2, x);
            v_timefactor     := x * 255.0;
            if v_timefactor > real(v_wavesteps - 1) then
                v_timefactor := x * real(v_wavesteps - 1);
            end if;

            -- check if time factor is still less than 1. if so manually add 1
            if v_timefactor < 1.0 then
                v_timefactor := v_timefactor + 1.0;
            end if;
            
            uniform(seed1, seed2, x);
            v_gainfactor     := x;
            
            -- store the parameters for the pulse into appropriate arrays
            start_times(v_pulseaddr)  <= round_to_n_decimal_places(real(v_pulsetime), 0);
            pulse_times(v_pulseaddr)  <= round_to_n_decimal_places(real(v_wavesteps), 0);
            start_idx(v_pulseaddr)    <= round_to_n_decimal_places(real(sim_addr), 0);
            pulse_delays(v_pulseaddr) <= round_to_n_decimal_places(real(v_wavetopwidth), 0);
            time_factors(v_pulseaddr) <= round_to_n_decimal_places(v_timefactor, BIT_FRAC);
            gain_factors(v_pulseaddr) <= round_to_n_decimal_places(v_gainfactor, BIT_FRAC_GAIN);
            arr_coeffs(v_pulseaddr)   <= v_coeffs;

            -- generate rise of a pulse, and put it into the wave table array
            for NTIME in 0 to v_wavesteps - 1 loop
                wave_val := poly_gen(DEGREES, real(NTIME) / real(v_wavesteps), v_coeffs);

                fakeram_wt(sim_addr)   <= round_to_n_decimal_places(wave_val, BIT_FRAC_DATA);
                sim_addr               := sim_addr + 1;
                clk_delay(0);
            end loop;

            v_pulseaddr := v_pulseaddr + 1;
            v_pulsetime := v_pulsetime + 2 * (1 + integer(floor(real(v_wavesteps - 1) / v_timefactor))) + v_wavetopwidth + 431;
        end loop;

        cpu_print_msg("Done generating random polynomials");
        clk_delay(20);
        cpu_print_msg("Total Pulses: " & to_string(total_pulses));

        ----------------------------------------------------------------
        -- Load pulse RAM with a series of pulse start times
        ----------------------------------------------------------------
        cpu_print_msg("Load pulse RAM");
        for NADDR in 0 to 255 loop
            cpu_write_pulsedef(
                clk, 
                NADDR*4, 
                integer(start_times(NADDR)), 
                time_factors(NADDR), 
                gain_factors(NADDR), 
                integer(start_idx(NADDR)), 
                integer(pulse_times(NADDR)), 
                integer(pulse_delays(NADDR)), 
                cpu_sel, 
                cpu_wr, 
                cpu_addr, 
                cpu_wdata);
        end loop;
        cpu_print_msg("Pulse RAM loaded");
        clk_delay(20);

        ----------------------------------------------------------------
        -- Load waveform RAM with a simple ramp
        -- Write two 16-bit values with each write
        ----------------------------------------------------------------
        cpu_print_msg("Load waveform RAM");
        v_ndata16 := 1; -- first waveform value
        for NADDR in 0 to 2047 loop
            v_ndata32_upper := integer(fakeram_wt(v_ndata16)) * 2**C_BITS_ADDR_WAVE;
            v_ndata32_lower := integer(fakeram_wt(v_ndata16 - 1));
            v_ndata32       := v_ndata32_upper + v_ndata32_lower;
            cpu_write(clk, (ADR_RAM_WAVE + NADDR) , std_logic_vector(to_unsigned(v_ndata32,32)), cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
            v_ndata16       := v_ndata16 + 2;
        end loop;

        cpu_print_msg("Waveform RAM Loaded");
        clk_delay(20);
        v_pulseaddr     := 0;    -- manually reset the pulse address, 0 to 255
        ----------------------------------------------------------------
        -- Start the pulse outputs
        ----------------------------------------------------------------        
        clk_delay(5);
        start      <= '1';
        clk_delay(5);
        start      <= '0';

        cpu_print_msg("Start the pulse outputs");
        while v_pulseaddr < total_pulses - 1 loop
            cnt_time      <= std_logic_vector(unsigned(cnt_time) + 1); 
            
            -- Force increment the pulse address if the current time is the next pulse start time or falling edge of axis_tvalid (wave just finished output)
            if (start_times(v_pulseaddr + 1) = real(to_integer(unsigned(cnt_time)))) or falling_edge(axis_tvalid) then
                v_pulseaddr := v_pulseaddr + 1;  -- force increment the pulse address
            end if;

            -- Output wave infomations to the console
            if real(to_integer(unsigned(cnt_time))) = start_times(v_pulseaddr) then
                cpu_print_msg("""pulse_"& to_string(v_pulseaddr)& """: {");
                cpu_print_msg("    ""constants"":    [" & real_arr_to_string(DEGREES, arr_coeffs(v_pulseaddr)) & "],");
                cpu_print_msg("    ""gain_factors"": " & to_string(gain_factors(v_pulseaddr)) & ",");
                cpu_print_msg("    ""time_factors"": " & to_string(time_factors(v_pulseaddr)) & ",");
                cpu_print_msg("    ""size"":  " & to_string(pulse_times(v_pulseaddr)) & "");
                cpu_print_msg("}");
            end if;

            -- exit on any error
            if or_reduce(erros) = '1' then
                cpu_print_msg("Hardware error detected: " & to_string(erros));
                exit;
            end if; 

            wave_values   <= poly_gen(DEGREES, x_processed / pulse_times(v_pulseaddr), arr_coeffs(v_pulseaddr)) * gain_factors(v_pulseaddr);
            rel_time      := real(to_integer(unsigned(cnt_time))) - start_times(v_pulseaddr);  -- First calculate relative time once
            pulse_width   := (1.0 + (floor(real(pulse_times(v_pulseaddr) - 1.0) / time_factors(v_pulseaddr))));

            -- Cleaner piecewise regions
            if (rel_time >= 0.0) and (rel_time < pulse_width) then
                -- Rising edge
                x_processed := rel_time * time_factors(v_pulseaddr);
            elsif (rel_time >= pulse_width) and (rel_time < pulse_width + pulse_delays(v_pulseaddr)) then
                -- Hold at peak
                x_processed := pulse_times(v_pulseaddr) - 1.0;                
            elsif (rel_time >= pulse_width + pulse_delays(v_pulseaddr)) and (rel_time < 2.0 * pulse_width + (pulse_delays(v_pulseaddr) - 1.0)) then
                -- Falling edge, flip + shifted of the rising edge 
                x_processed := (2.0 * pulse_width + pulse_delays(v_pulseaddr) - 1.0 - rel_time) * time_factors(v_pulseaddr);
            else
                -- Outside pulse
                x_processed := 0.0;
            end if;

            -- Always check the difference between the expected and actual values when hardware tells the data is valid
            if axis_tvalid = '1' then
                v_dff     := abs(wave_values - real(to_integer(unsigned(axis_tdata))));
            else
                v_dff     := 0.0;
            end if;

            axis_tdata_d1 <= real(to_integer(unsigned(axis_tdata)));
            diffs         <= v_dff;

            -- compare the difference and store the maximum error
            if v_dff > max_error then
                max_error     <= v_dff;
                mx_err_delta  <= abs(real(to_integer(unsigned(axis_tdata))) - axis_tdata_d1);
                mx_err_time   <= to_integer(unsigned(cnt_time));
                mx_sim_time   <= now;
                mx_err_pulse  <= v_pulseaddr;
            end if;
            clk_delay(0);
        end loop;

        -- Export max errors, step size, max errors/step size…. Add stuff needed to know what causes the error
        fputs(to_string(int_seed) & ", " & to_string(real(mx_sim_time / 1 ns)) & ", " & to_string(max_error) & ", " & to_string(mx_err_delta) & ", " & to_string(max_error/mx_err_delta) & ", " & to_string(mx_err_pulse) & ", " & to_string(mx_err_time), err_out);

        clear_errors <= '1';  -- assert clear errors to clear errors
        clk_delay(5);
        done_seq <= '1';

        -- End of test
        cpu_print_msg("Simulation done");
        sim_done    <= true;
        wait;
    end process;
end verify;
