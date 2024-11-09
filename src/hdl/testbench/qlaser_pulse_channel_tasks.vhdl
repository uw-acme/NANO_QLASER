-------------------------------------------------------------
-- File Name: qlasert_pulse_channel_tasks.vhdl
-----------------------------------------------------------
-- Description: Tasks, functions and procedures for the pulse channel waveform generation testcase
-------------------------------------------------------------
library ieee;
library std;
library std_developerskit;
use     ieee.numeric_std.all;
use     ieee.math_real.all;

use     ieee.std_logic_1164.all; 
use     std.textio.all;
use     std_developerskit.std_iopak.all;


-- use     ieee.math_real.all;
use     work.qlaser_dacs_pulse_channel_pkg.all;

-- TODO: merge with qlaser_dacs_pulse_channel_pkg and seperate into two files, one ocntains package header one contains the body
package qlasert_pulse_channel_tasks is

    -- test constant may or may not be used in the testbench
    constant REPEAT_CNT                 : integer   := 1;

    -- Crystal clock freq expressed in MHz
    constant CLK_FREQ_MHZ               : real      := 100.0; 
    -- Clock period
    constant CLK_PER                    : time      := integer(1.0E+6/(CLK_FREQ_MHZ)) * 1 ps;

    -- Block registers
    constant ADR_RAM_PULSE              : integer   :=  0;
    constant ADR_RAM_WAVE               : integer   :=  2048;

    -- numbers of different "polynimials" to be generated
    constant NUM_PULSE                  : integer   :=  2;

    -- -------------------------------------------------------------
    -- -- Header functions
    -- -------------------------------------------------------------
    function round_to_n_decimal_places(
        value : real; 
        n     : integer
    ) return real;

    function poly_gen(
        degrees : in integer;       -- number of coefficients
        times   : in real;          -- time stamp (should be real?)
        coeff   : in real_array    -- coefficient
    ) return real;

    procedure poly_gen_ram(
        signal clk           : in  std_logic;
        constant start_addr  : in  integer;
        constant size        : in  integer;
        constant degrees     : in  integer;
        constant coeff       : in  real_array;
        signal cpu_sel       : out std_logic;
        signal cpu_wr        : out std_logic;
        signal cpu_addr      : out std_logic_vector(15 downto 0);
        signal cpu_wdata     : out std_logic_vector(31 downto 0)
    );

    procedure cpu_print_msg(
        constant msg    : in    string
    );

    procedure cpu_print_arr(
        constant size    : in integer;
        constant arr     : in    real_array
    );

    procedure cpu_write_msg(
        constant msg  : in string;
        file out_file :    text
    );

    procedure cpu_write( 
        signal clk          : in  std_logic;
        constant a          : in  integer;
        constant d          : in  std_logic_vector(31 downto 0);
        signal cpu_sel      : out std_logic;
        signal cpu_wr       : out std_logic;
        signal cpu_addr     : out std_logic_vector(15 downto 0);
        signal cpu_wdata    : out std_logic_vector(31 downto 0)
    );

    procedure cpu_write( 
        signal clk          : in  std_logic;
        constant a          : in  integer;
        constant d          : in  integer;
        signal cpu_sel      : out std_logic;
        signal cpu_wr       : out std_logic;
        signal cpu_addr     : out std_logic_vector(15 downto 0);
        signal cpu_wdata    : out std_logic_vector(31 downto 0)
    );

    procedure cpu_write_pulsedef(
        signal clk              : in  std_logic;
        constant num_entry      : in  integer;
        constant pulsetime      : in  integer;
        constant timefactor     : in  real;
        constant gainfactor     : in  real;
        constant wavestartaddr  : in  integer;
        constant wavesteps      : in  integer;
        constant wavetopwidth   : in  integer;
        signal cpu_sel          : out std_logic;
        signal cpu_wr           : out std_logic;
        signal cpu_addr         : out std_logic_vector(15 downto 0);
        signal cpu_wdata        : out std_logic_vector(31 downto 0)
    );

    procedure pulse_check(
        constant exp_d             : in   real;
        constant actual            : in   unsigned;
        constant valid             : in   std_logic;
        constant thresh            : in   real;
        constant curr_cnt_time     : in   integer;
        signal diffs               : out  real
    );
end package;


package body qlasert_pulse_channel_tasks is
    -------------------------------------------------------------
    -- Round a real number to n decimal places
    -------------------------------------------------------------
    function round_to_n_decimal_places(
        value : real; 
        n     : integer
    ) return real is
        variable scaling_factor : real := 2.0 ** n;
        variable scaled_value   : integer;
        variable result         : real;
    begin
        -- -- Scale the value
        -- scaled_value := value * 2.0 ** n;
    
        -- -- Truncate to an integer
        -- scaled_value := real(integer(scaled_value));

        scaled_value := integer(value * scaling_factor);
    
        -- Scale back to get the desired number of decimal places
        result := real(scaled_value) / scaling_factor;
    
        return result;
    end function;


    -------------------------------------------------------------
    -- Polynomial Solver
    -- Given a set of random coefficients and time stamp, return value for the polynomial for the given time
    -- Assume the numbers of coefficients is the same as the number of time stamps which is the degrees number
    -------------------------------------------------------------
    function poly_gen(
        degrees : in integer;       -- number of coefficients
        times   : in real;          -- time stamp (should be real?)
        coeff   : in real_array    -- coefficient
    ) return real is
        variable poly_sum : real := 0.0;
    begin
        -- add from first to the Nth term. We always assume the zeroth term is 0
        for i in 1 to degrees loop
            poly_sum := poly_sum + coeff(i - 1)*(times)**i;
        end loop;
        return (poly_sum)/(real(degrees + 1)) * 2.0**(C_BITS_ADDR_WAVE - 1); -- out = (f{x'} / (N+1)) * (ADC height/2), we divide by 2 to since integer is half of whatever the floating point value is
    end poly_gen;    

    ------------------------------------------------------------------
    -- Generate a polynomial and store it in the wave table RAM
    -- Assume the polynomial function always start from 0
    -- TODO: add error checking for invalid polynomial (e.g. <2 size)
    ------------------------------------------------------------------
    procedure poly_gen_ram(
        signal clk           : in  std_logic;
        constant start_addr  : in  integer;
        constant size        : in  integer;
        constant degrees     : in  integer;
        constant coeff       : in  real_array;
        signal cpu_sel       : out std_logic;
        signal cpu_wr        : out std_logic;
        signal cpu_addr      : out std_logic_vector(15 downto 0);
        signal cpu_wdata     : out std_logic_vector(31 downto 0)
    ) is
        variable v_ndata32        : integer     := 0;
        variable v_ndata16        : integer     := 1;
        variable v_ndata32_upper  : integer     := 0;
        variable v_ndata32_lower  : integer     := 0;
        variable v_wavetime       : integer     := 0;                                            -- for single waveform time
        variable v_cpuaddr_start  : integer     := integer(floor(real(start_addr)/2.0));         -- start address for the waveform ram CPU side
        variable v_cpuaddr_end    : integer     := integer(floor(real(start_addr + size)/2.0));  -- end address for the waveform ram CPU side
    begin
        -- TODO: BUG - the cpu end addr is differernt than the waveform, which start_addr based on.
        for NADDR in v_cpuaddr_start to v_cpuaddr_end loop
            -- gen two poly values for each write
            v_ndata32_lower := integer(poly_gen(degrees, real(v_wavetime) / real(size), coeff));
            v_ndata32_upper := integer(poly_gen(degrees, real(v_wavetime + 1) / real(size), coeff)) * 2**C_BITS_ADDR_WAVE;
            v_ndata32       := v_ndata32_upper + v_ndata32_lower;

            cpu_write(clk, (ADR_RAM_WAVE + NADDR) , std_logic_vector(to_unsigned(v_ndata32,32)), cpu_sel, cpu_wr, cpu_addr, cpu_wdata);

            v_wavetime := v_wavetime + 2;
        end loop;
    end procedure poly_gen_ram;

    -- -------------------------------------------------------------
    -- -- Delay
    -- -------------------------------------------------------------
    -- procedure clk_delay(
    --     constant nclks  : in  integer
    -- ) is
    -- begin
    --     for I in 0 to nclks loop
    --         wait until clk'event and clk ='0';
    --     end loop;
    -- end;
    ----------------------------------------------------------------
    -- Print a string with no time or instance path.
    ----------------------------------------------------------------
    procedure cpu_print_msg(
        constant msg    : in    string
    ) is
    variable line_out   : line;
    begin
        write(line_out, msg);
        writeline(output, line_out);
    end procedure cpu_print_msg;
    ----------------------------------------------------------------
    -- Print an array of reals, with given size.
    ----------------------------------------------------------------
    procedure cpu_print_arr(
        constant size    : in    integer;        -- numbers of items
        constant arr     : in    real_array
    ) is
    variable line_out   : line;
    begin
        write(line_out, to_string(arr(0)));  -- print the first element, fencepost
        for i in 2 to size loop
            write(line_out, string'(", "));
            write(line_out, to_string(arr(i - 1)));
        end loop;
        writeline(output, line_out);
    end procedure cpu_print_arr;
    ----------------------------------------------------------------
    -- Write string to a file.
    -- DEPRECATED: Use fputs from iopak instead.
    ----------------------------------------------------------------
    procedure cpu_write_msg(
        constant msg  : in string;
        file out_file :    text
    ) is
    variable line_out   : line;
    begin
        write(line_out, msg);
        writeline(out_file, line_out);
    end procedure cpu_write_msg;
    -------------------------------------------------------------
    -- CPU write procedure. Address in decimal. Data in hex
    -------------------------------------------------------------
    procedure cpu_write( 
        signal clk          : in  std_logic;
        constant a          : in  integer;
        constant d          : in  std_logic_vector(31 downto 0);
        signal cpu_sel      : out std_logic;
        signal cpu_wr       : out std_logic;
        signal cpu_addr     : out std_logic_vector(15 downto 0);
        signal cpu_wdata    : out std_logic_vector(31 downto 0)
    ) is
    begin
        wait until clk'event and clk='0';
        cpu_sel     <= '1';
        cpu_wr      <= '1';
        cpu_addr    <= std_logic_vector(to_unsigned(a, 16));
        cpu_wdata   <= std_logic_vector(d);
        wait until clk'event and clk='0';
        cpu_sel     <= '0';
        cpu_wr      <= '0';
        cpu_addr    <= (others=>'0');
        cpu_wdata   <= (others=>'0');
        wait until clk'event and clk='0';
    end;
    -------------------------------------------------------------
    -- CPU write procedure. Address and Data in decimal
    -------------------------------------------------------------
    procedure cpu_write( 
        signal clk          : in  std_logic;
        constant a          : in  integer;
        constant d          : in  integer;
        signal cpu_sel      : out std_logic;
        signal cpu_wr       : out std_logic;
        signal cpu_addr     : out std_logic_vector(15 downto 0);
        signal cpu_wdata    : out std_logic_vector(31 downto 0)
    ) is
    begin
        cpu_write(clk, a , std_logic_vector(to_unsigned(d,32)), cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
    end;

    -------------------------------------------------------------
    -- CPU write pulse definition RAM
    -- Make fore 32-bit data write
    -------------------------------------------------------------
    procedure cpu_write_pulsedef(
        signal clk              : in  std_logic;

        constant num_entry      : in  integer;

        -- TODO: Partial ? list of parameters, there could be more if need more features
        constant pulsetime      : in  integer;  -- Pulse time in clock cycles
        constant timefactor     : in  real;     -- Fixed point time scale factor
        constant gainfactor     : in  real;     -- Fixed point gain value. Max value 1.0 is hex X"8000". Gain 0.5 is therefore X"4000"
        constant wavestartaddr  : in  integer;  -- Start address in waveform RAM
        constant wavesteps      : in  integer;  -- Number of steps in waveform rise and fall
        constant wavetopwidth   : in  integer;  -- Number of clock cycles in waveform top between end of rise and start of fall
        

        signal cpu_sel          : out std_logic;
        signal cpu_wr           : out std_logic;
        signal cpu_addr         : out std_logic_vector(15 downto 0);
        signal cpu_wdata        : out std_logic_vector(31 downto 0)
    ) is
    -- Vectors for converted values
    variable slv_pulsetime      : std_logic_vector(23 downto 0);  -- For 24-bit pulse time
    variable slv_timefactor     : std_logic_vector(15 downto 0);  -- For 16-bit fixed point timestep
    variable slv_gainfactor     : std_logic_vector(15 downto 0);  -- For 16-bit fixed point gain
    variable slv_wavestartaddr  : std_logic_vector(11 downto 0);  -- For 12-bit address i.e. 1024 point waveform RAM
    variable slv_wavesteps      : std_logic_vector( 9 downto 0);  -- For 10-bit number of steps i.e. 0 = 1 step, X"3FF" = 1024 points
    variable slv_wavetopwidth   : std_logic_vector(16 downto 0);  -- For 17-bit number of clock cycles in top of waveform
    begin
        -- Convert each field into its std_logic_vector equivalent
        slv_pulsetime     := std_logic_vector(to_unsigned(pulsetime, 24));
        slv_timefactor    := std_logic_vector(to_unsigned(integer(timefactor * real(2**BIT_FRAC)), 16));       -- Convert real to std_logic_vector keeping the fractional part
        slv_gainfactor    := std_logic_vector(to_unsigned(integer(gainfactor * real(2**BIT_FRAC_GAIN)), 16));  -- Convert real to std_logic_vector keeping the fractional part
        slv_wavestartaddr := std_logic_vector(to_unsigned(wavestartaddr, 12));
        slv_wavesteps     := std_logic_vector(to_unsigned(wavesteps, 10));
        slv_wavetopwidth  := std_logic_vector(to_unsigned(wavetopwidth, 17));
        
        
        --etc, etc.
        -- 4 writes.  (Address is an integer)
        cpu_write(clk, ADR_RAM_PULSE+num_entry   , x"00" & slv_pulsetime, cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        cpu_write(clk, ADR_RAM_PULSE+(num_entry+1) , "00" & x"0" & slv_wavesteps & x"0" & slv_wavestartaddr, cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        cpu_write(clk, ADR_RAM_PULSE+(num_entry+2) , slv_gainfactor & slv_timefactor, cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        cpu_write(clk, ADR_RAM_PULSE+(num_entry+3) , "0000000" & x"00" & slv_wavetopwidth, cpu_sel, cpu_wr, cpu_addr, cpu_wdata);

    end;

    -------------------------------------------------------------
    -- Output comparison
    -- TODO: try imm assertion?
    -------------------------------------------------------------
    procedure pulse_check(
        constant exp_d             : in   real;
        constant actual            : in   unsigned;
        constant valid             : in   std_logic;  -- valid signal, so we don't conpare garbage with nonsense
        constant thresh            : in   real;       -- max difference allowed
        constant curr_cnt_time     : in   integer;    -- current cnt time
        signal diffs               : out  real        -- difference between expected and actual values
    ) is
    variable v_bdone    : boolean := false; 
    variable str_out    : string(1 to 256);
    variable diff       : real;
    begin
        -- do compare only when the valid signal is high
        if valid = '1' then
            -- find the abs difference between the expected and actual values
            diff := abs(real(to_integer(unsigned(actual))) - exp_d);
            if diff > thresh then
                -- str_out := "ERROR (CNT_TIME=" & integer'image(curr_cnt_time) & "): Expected: " & real'image(exp_d) & ", Actual: " & integer'image(to_integer(unsigned(actual))) & ", Diff: " & real'image(diff);
                report str_out severity error;
                cpu_print_msg("ERROR (CNT_TIME=" & integer'image(curr_cnt_time) & "): Expected: " & real'image(exp_d) & ", Actual: " & integer'image(to_integer(unsigned(actual))) & ", Diff: " & real'image(diff));
            end if;
            diffs <= diff;
        end if;
        
    end;


end package body;