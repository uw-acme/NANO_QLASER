-----------------------------------------------------------
-- File : tb_cpubus_dacs_pulse_channel.vhd
-----------------------------------------------------------
-- 
-- Testbench for CPU bus peripheral.
--
--  Description  : Pulse output control of Qlaser FPGA
--                 Block drives AXI-stream to JESD DACs
--
----------------------------------------------------------
library ieee;
library std_developerskit;
use     ieee.numeric_std.all;
use     ieee.std_logic_1164.all; 
use     ieee.std_logic_textio.all;
use     ieee.std_logic_misc.all;
use     std.textio.all;

use     ieee.math_real.all;



use     std_developerskit.std_iopak.all;
use     work.qlaser_dacs_pulse_channel_pkg.all;
use     work.qlasert_pulse_channel_tasks.all;

entity tb_cpubus_dacs_pulse_channel is
    generic (
        SEED        : integer := 1;
        RESULT_FILE : string  := "errors.txt";
        DEGREES     : integer := 2;
        SEQ_LENGTH  : integer := 32000
    );
end    tb_cpubus_dacs_pulse_channel;

architecture behave of tb_cpubus_dacs_pulse_channel is 

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

-- AXI-stream output interface
signal axis_tready                  : std_logic := '1'; -- Always ready
signal axis_tdata                   : std_logic_vector(15 downto 0);
signal axis_tvalid                  : std_logic;
signal axis_tlast                   : std_logic;

-- Halts simulation by stopping clock when set true
signal sim_done                     : boolean   := false;

signal erros                        : std_logic_vector(C_ERRORS_TOTAL - 1 downto 0);
signal clear_errors                 : std_logic;

-- Simulation signals
signal wave_values                  : real := 0.0;                             -- waveform values
signal diffs                        : real := 0.0;                             -- difference between expected and actual values
signal axis_tdata_d1                : real := 0.0;                             -- previous axis_tdata


signal pdef_fakeram                 : arr_pdef;                               -- fake pulse definition RAM

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
-- Mathematical model of the waveform generator
-------------------------------------------------------------
function calc_pulse_value(
    current_time : in integer;
    start_time   : in integer;
    pulse_time   : in integer;
    sustain_time : in integer;
    timefactor   : in real;
    gainfactor   : in real;
    coefficients : in real_array;
    degree       : in integer
) return real is
    variable rel_time       : real := real(current_time - start_time);
    variable pulse_width    : real := ceil(real(pulse_time - 1) / timefactor) + 1.0;
    variable time_processed : real;
begin
    if (rel_time >= 0.0) and (rel_time < pulse_width) then
        time_processed := rel_time * timefactor;
    elsif (rel_time >= pulse_width) and (rel_time < pulse_width + real(sustain_time)) then
        time_processed := real(pulse_time - 1);
    elsif (rel_time >= pulse_width + real(sustain_time)) and (rel_time < 2.0 * pulse_width + (real(sustain_time) - 1.0)) then
        time_processed := (2.0 * pulse_width + real(sustain_time) - 1.0 - rel_time) * timefactor;
    else
        time_processed := 0.0;
    end if;

    return poly_gen(degree, time_processed / real(pulse_time), coefficients) * gainfactor;
end calc_pulse_value;

begin

    -------------------------------------------------------------
	-- Unit Under Test
    -------------------------------------------------------------
	u_dac_pulse : entity work.qlaser_dacs_pulse_channel(channel)
	port map (
        clk             => clk                      , -- in  std_logic;
        reset           => reset                    , -- in  std_logic;

        enable          => enable                   , -- in std_logic;  
        start           => start                    , -- in std_logic; 
        cnt_time        => cnt_time                 , -- in std_logic_vector(23 downto 0);

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
    variable v_pulseaddr       : integer := 0;    -- manually set the pulse address, 0 to 255
    variable v_pdef            : arr_pdef;        -- pulse definition arrays
    variable v_pulsetime_total : integer := 0;    -- total time for all pulses

    begin
        -- Reset 
        reset       <= '1';
        enable      <= '0';
        start       <= '0';
        done_seq    <= '0';
        cnt_time    <= (others=>'0');

        cpu_sel     <= '0';
        cpu_wr      <= '0';
		cpu_wdata   <= (others=>'0');
		cpu_addr  	<= (others=>'0');

        cpu_print_msg("Simulation start");
        clk_delay(5);
        reset       <= '0';

        clk_delay(5);
        enable      <= '1';
       

        clk_delay(20);
        -------------------------------------------------------------
        -- Load RAMs
        -------------------------------------------------------------
        cpu_print_msg("Load pulse RAM");
        
        -- Same pulse but scaled addr
        v_pulseaddr := 0;
        v_pdef(v_pulseaddr).starttime := 4;
        -- v_pdef(v_pulseaddr).timefactor := 174.796875;
        -- v_pdef(v_pulseaddr).gainfactor := 0.186554;
        -- v_pdef(v_pulseaddr).startaddr := 0;
        -- v_pdef(v_pulseaddr).steps := 430;
        -- v_pdef(v_pulseaddr).sustain := 5;
        -- v_pdef(v_pulseaddr).coefficients(0 to 1) := (0.385649, 0.483473);

        v_pdef(v_pulseaddr).timefactor := 1.996094;
        v_pdef(v_pulseaddr).gainfactor := 0.476990;
        v_pdef(v_pulseaddr).startaddr := 0;
        v_pdef(v_pulseaddr).steps := 4;
        v_pdef(v_pulseaddr).sustain := 2;
        v_pdef(v_pulseaddr).coefficients(0 to 1) := (0.563951, 0.703244);

        -- v_pdef(v_pulseaddr + 1).starttime := v_pdef(v_pulseaddr).starttime + v_pdef(v_pulseaddr).steps * 2 + v_pdef(v_pulseaddr).sustain + 4 + 3 + 1;
        pdef_fakeram(v_pulseaddr) <= v_pdef(v_pulseaddr);
        cpu_write_pulsedef(clk, v_pulseaddr*4, v_pdef(v_pulseaddr).starttime, v_pdef(v_pulseaddr).timefactor, v_pdef(v_pulseaddr).gainfactor, v_pdef(v_pulseaddr).startaddr, v_pdef(v_pulseaddr).steps, v_pdef(v_pulseaddr).sustain, cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        
        cpu_print_msg("Pulse RAM loaded");
        clk_delay(20);

        -- TODO: if coeff is >= 1 vhdl doesnt like it?
        poly_gen_ram(clk, v_pdef(v_pulseaddr).startaddr, v_pdef(v_pulseaddr).steps, DEGREES, v_pdef(v_pulseaddr).coefficients, cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        cpu_print_msg("Load waveform RAM");  
        clk_delay(20);
        
        -- -- -----------------------------------------------------------------------------------------------------
        -- v_pulseaddr := 1;
        -- v_pdef(v_pulseaddr).starttime := 10000 - 512;
        -- v_pdef(v_pulseaddr).timefactor := 1.0;
        -- v_pdef(v_pulseaddr).gainfactor := 1.0;
        -- v_pdef(v_pulseaddr).startaddr := 0;
        -- v_pdef(v_pulseaddr).steps := 512;
        -- v_pdef(v_pulseaddr).sustain := 16;
        -- v_pdef(v_pulseaddr).coefficients(0 to 1) := (1.0, 1.0);

        -- -- v_pdef(v_pulseaddr + 1).starttime := v_pdef(v_pulseaddr).starttime + v_pdef(v_pulseaddr).steps * 2 + v_pdef(v_pulseaddr).sustain + 4 + 3 + 1;
        -- pdef_fakeram(v_pulseaddr) <= v_pdef(v_pulseaddr);
        -- cpu_write_pulsedef(clk, v_pulseaddr*4, v_pdef(v_pulseaddr).starttime, v_pdef(v_pulseaddr).timefactor, v_pdef(v_pulseaddr).gainfactor, v_pdef(v_pulseaddr).startaddr, v_pdef(v_pulseaddr).steps, v_pdef(v_pulseaddr).sustain, cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        
        -- cpu_print_msg("Pulse RAM loaded");
        -- clk_delay(20);

        -- -- TODO: if coeff is >= 1 vhdl doesnt like it?
        -- poly_gen_ram(clk, v_pdef(v_pulseaddr).startaddr, v_pdef(v_pulseaddr).steps, DEGREES, v_pdef(v_pulseaddr).coefficients, cpu_sel, cpu_wr, cpu_addr, cpu_wdata);
        -- cpu_print_msg("Load waveform RAM");  
        -- clk_delay(20);

        -- cpu_print_msg("start pulse" & to_string(pdef_fakeram(v_pulseaddr).starttime) & " " & to_string(pdef_fakeram(v_pulseaddr).timefactor) & " " & to_string(pdef_fakeram(v_pulseaddr).gainfactor) & " " & to_string(pdef_fakeram(v_pulseaddr).startaddr) & " " & to_string(pdef_fakeram(v_pulseaddr).steps) & " " & to_string(pdef_fakeram(v_pulseaddr).sustain) & " " & to_string(pdef_fakeram(v_pulseaddr).coefficients(0)) & " " & to_string(pdef_fakeram(v_pulseaddr).coefficients(1)));

        ----------------------------------------------------------------
        -- Start the pulse outputs
        ----------------------------------------------------------------
        v_pulsetime_total := v_pdef(v_pulseaddr).starttime + integer(real(v_pdef(v_pulseaddr).steps) / v_pdef(v_pulseaddr).timefactor) * 2 + v_pdef(v_pulseaddr).sustain + 3; -- + 4 + 3 + 1;

        clk_delay(5);
        start      <= '1';
        clk_delay(5);
        start      <= '0';

        v_pulseaddr := 0;    -- reset the pulse address
        -- TODO: we may need to modify the for loop to make sure the simulation time is long enough to cover all the pulses
        -- Wait for cnt_time to reach last pulse start time + waveform size
        
        for NCNT in 1 to SEQ_LENGTH loop  -- TODO: EricToGeoff/Sara: in the real settings do we have a constant amount of time or the total time also vary? if so, how much?
        -- for NCNT in 1 to 128 loop    -- count the time shorter for now so it won't take too long to simulate
            cnt_time      <= std_logic_vector(unsigned(cnt_time) + 1);

            -- increment when next pulse start time is reached or current pulse finishes
            if (v_pdef(v_pulseaddr + 1).starttime = to_integer(unsigned(cnt_time))) or falling_edge(axis_tvalid) then
                v_pulseaddr := v_pulseaddr + 1;  -- force increment the pulse address
                -- x           := real(v_pdef(v_pulseaddr).starttime);  -- set x to the start time of the next pulse
                cpu_print_msg("##### Moving on to pulse #" & to_string(v_pulseaddr));
            end if;
            
            -- -- stop on error
            -- if or_reduce(erros) = '1' then
            --     cpu_print_msg("##### [ERROR] Hardware error detected: " & to_string(erros));
            --     exit;
            -- end if; 

            wave_values <= calc_pulse_value(
                to_integer(unsigned(cnt_time) - 1),
                v_pdef(v_pulseaddr).starttime,
                v_pdef(v_pulseaddr).steps,
                v_pdef(v_pulseaddr).sustain,
                v_pdef(v_pulseaddr).timefactor,
                v_pdef(v_pulseaddr).gainfactor,
                v_pdef(v_pulseaddr).coefficients,
                DEGREES
            );

            if axis_tvalid = '1' then
                diffs <= wave_values - real(to_integer(signed(axis_tdata)));
            else
                diffs <= 0.0;
            end if;

            clk_delay(0);
        end loop;
        
        -- wait for 10 us;
        
        cpu_print_msg("Simulation done");
        -- clk_delay(5);
		done_seq <= '1';
        clear_errors <= '1';
        sim_done    <= true;
        wait;

    end process;

end behave;

