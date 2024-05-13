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
use     ieee.numeric_std.all;
use     ieee.std_logic_1164.all; 
use     std.textio.all; 

use     work.qlaser_pkg.all;
use     work.std_iopak.all;
use     work.qlaser_dacs_pulse_channel_pkg.all;


entity tb_cpubus_dacs_pulse_channel is
end    tb_cpubus_dacs_pulse_channel;

architecture behave of tb_cpubus_dacs_pulse_channel is 

signal reset: std_logic;
signal clk: std_logic;
signal enable: std_logic;
signal trigger: std_logic;
signal jesd_syncs: std_logic_vector(31 downto 0);
signal ready: std_logic;
signal busy: std_logic;
signal err: std_logic;
signal error_latched: std_logic;
signal cpu_addr: std_logic_vector(12 downto 0);
signal cpu_wdata: std_logic_vector(31 downto 0);
signal cpu_wr: std_logic;
signal cpu_sel: std_logic;
signal cpu_rdata: std_logic_vector(31 downto 0);
signal cpu_rdata_dv: std_logic;
signal axis_treadys: std_logic_vector(31 downto 0);
signal axis_tdatas: t_arr_slv32x16b;
signal axis_tvalids: std_logic_vector(31 downto 0);
signal axis_tlasts: std_logic_vector(31 downto 0) ;

-- Halts simulation by stopping clock when set true
signal sim_done                     : boolean   := false;

-- Crystal clock freq expressed in MHz
constant CLK_FREQ_MHZ               : real      := 100.0; 
-- Clock period
constant CLK_PER                    : time      := integer(1.0E+6/(CLK_FREQ_MHZ)) * 1 ps;

-- Block registers
-- constant ADR_RAM_PULSE              : integer   :=  to_integer(unsigned(X"0000"));    -- TODO: Modelsim cannot compile this
-- constant ADR_RAM_WAVE               : integer   :=  to_integer(unsigned(X"0200"));    -- TODO: Modelsim cannot compile this
constant ADR_RAM_PULSE              : integer   :=  0;    -- TODO: Modelsim cannot compile this
constant ADR_RAM_WAVE               : integer   :=  2048;    -- TODO: Modelsim cannot compile this


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


begin

    -------------------------------------------------------------
	-- Unit Under Test
    -------------------------------------------------------------
	u_dacs_pulse : entity work.qlaser_dacs_pulse generic map ( G_NCHANS      =>  32)
                            port map ( reset         => reset,
                                       clk           => clk,
                                       enable        => enable,
                                       trigger       => trigger,
                                       jesd_syncs    => jesd_syncs,
                                       ready         => ready,
                                       busy          => busy,
                                       error         => err,
                                       error_latched => error_latched,
                                       
                                       cpu_addr      => cpu_addr,
                                       cpu_wdata     => cpu_wdata,
                                       cpu_wr        => cpu_wr,
                                       cpu_sel       => cpu_sel,
                                       cpu_rdata     => cpu_rdata,
                                       cpu_rdata_dv  => cpu_rdata_dv,
                                       
                                       axis_treadys  => axis_treadys,
                                       axis_tdatas   => axis_tdatas,
                                       axis_tvalids  => axis_tvalids,
                                       axis_tlasts   => axis_tlasts );
	

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
    variable v_ndata32        : integer := 0;
    variable v_ndata16        : integer := 0;
    
    begin
        -- Reset 
        reset       <= '1';
        enable      <= '0';

        cpu_sel     <= '0';
        cpu_wr      <= '0';
		cpu_wdata   <= (others=>'0');
		cpu_addr  	<= (others=>'0');
		jesd_syncs  <= (others=>'1');
		axis_treadys<= (others=>'1');
		
		trigger <= '0';

        cpu_print_msg("Simulation start");
        clk_delay(5);
        trigger <= '1'; -- triggering while reset should do nothing 
        wait until rising_edge(clk);
        trigger <= '0';
        reset       <= '0';

        clk_delay(5);
        enable      <= '1';       

        clk_delay(20);
        
        -- write all registers
        cpu_addr <= (others => '0');
        cpu_addr(12) <= '1';
        cpu_wr <= '1';
        cpu_sel <= '1';
        for i in 0 to 15 loop
            cpu_addr(3 downto 0) <= std_logic_vector(to_unsigned(i, 4));
            cpu_addr(11 downto 4) <= std_logic_vector(to_unsigned(i * 31, 8)); -- put garbage here, make sure it's not used
            cpu_wdata <= X"ABCDEF" & std_logic_vector(to_unsigned(i, 8));
            wait until rising_edge(clk);
        end loop;
        cpu_addr <= (others => '0');
        cpu_wr <= '0';
        cpu_sel <= '0';
        -- end write all registers
        
        -- read all registers
        cpu_addr(12) <= '1';
        for i in 0 to 15 loop
            cpu_addr(3 downto 0) <= std_logic_vector(to_unsigned(i, 4));
            cpu_addr(11 downto 4) <= std_logic_vector(to_unsigned(i * 31, 8)); -- put garbage here, make sure it's not used
            cpu_wdata <= X"FFFFFFFF";
            cpu_wr <= '0';
            cpu_sel <= '1';
            wait until rising_edge(clk);
        end loop;
        cpu_addr <= (others => '0');
        -- end read all registers
        
        -- reset from reset and read all registers
        reset       <= '1';
        enable      <= '0';
        cpu_sel     <= '0';
        cpu_wr      <= '0';
		cpu_wdata   <= (others=>'0');
		cpu_addr  	<= (others=>'0');
		wait until rising_edge(clk);
		reset <= '0';
		wait until rising_edge(clk);
		enable <= '1';
		wait until rising_edge(clk);
		
		cpu_addr <= (others => '0');
        cpu_addr(12) <= '1';
        for i in 0 to 15 loop
            cpu_addr(3 downto 0) <= std_logic_vector(to_unsigned(i, 4));
            cpu_addr(11 downto 4) <= std_logic_vector(to_unsigned(i * 31, 8)); -- put garbage here, make sure it's not used
            cpu_wdata <= X"FFFFFFFF";
            cpu_wr <= '0';
            cpu_sel <= '1';
            wait until rising_edge(clk);
        end loop;
        cpu_addr <= (others => '0');
        -- end reset and read all registers 


               
        
        -- write to enable all channels
        cpu_addr(12) <= '1';
        cpu_addr(11 downto 5) <= (others => '0');
        cpu_addr(3 downto 0) <= "0010";
        cpu_wdata <= X"FFFFFFFF";
        cpu_wr <= '1';
        cpu_sel <= '1';
        wait until rising_edge(clk);
        -- write to select all channels
        cpu_addr(12) <= '1';
        cpu_addr(11 downto 5) <= (others => '0');
        cpu_addr(3 downto 0) <= "0001";
        cpu_wdata <= X"FFFFFFFF";
        cpu_wr <= '1';
        cpu_sel <= '1';
        wait until rising_edge(clk);
        cpu_wr <= '0';
        cpu_sel <= '0';
        cpu_wdata <= (others => '0');
        cpu_addr <= (others => '0');
        -- end write to enable all channels
        
        
        -- constant first pulse entry for all channels
        -- First pulse entry start.
        cpu_addr(4 downto 0) <= "00000"; -- ram_pulse_addra
        wait until rising_edge(clk);
        cpu_wdata <= X"00000004"; -- start time
        cpu_wr <= '1';
        cpu_sel <= '1';
        
        wait until rising_edge(clk);
        cpu_wr <= '0';
        cpu_sel <= '0';
        
        cpu_addr(4 downto 0) <= "00001"; -- ram_pulse_addra
        wait until rising_edge(clk);
        cpu_wdata(11 downto 0) <= X"000"; -- wave start address
        cpu_wdata(25 downto 16) <= "0000001000"; -- wave length
        cpu_wr <= '1';
        cpu_sel <= '1';
        
        wait until rising_edge(clk);
        cpu_wr <= '0';
        cpu_sel <= '0';
        
        cpu_addr(4 downto 0) <= "00010"; -- ram_pulse_addra
        wait until rising_edge(clk);
        cpu_wdata(15 downto 0) <= X"0100";  -- scale 
        cpu_wdata(31 downto 16) <= X"8000"; -- gain 
        cpu_wr <= '1';
        cpu_sel <= '1';
        
        wait until rising_edge(clk);
        cpu_wr <= '0';
        cpu_sel <= '0';
        
        cpu_addr(4 downto 0) <= "00011"; -- ram_pulse_addra
        wait until rising_edge(clk);
        cpu_wdata <= X"00000010"; -- flat top length 
        cpu_wr <= '1';
        cpu_sel <= '1';
        
        wait until rising_edge(clk);
        cpu_wr <= '0';
        cpu_sel <= '0';
        -- First pulse entry end.
        
        -- constant waveforms for all channels
        cpu_addr(11) <= '1'; -- write to waveform table
        for i in 0 to 255 loop
            cpu_addr(9 downto 0) <= std_logic_vector(to_unsigned(i, 10)); -- ram_pulse_addra
            wait until rising_edge(clk);
            cpu_wdata(15 downto 0) <= std_logic_vector(to_unsigned(i, 16));
            cpu_wdata(31 downto 16) <= std_logic_vector(to_unsigned(i, 16));
            cpu_wr <= '1';
            cpu_sel <= '1';
            
            wait until rising_edge(clk);
            cpu_wr <= '0';
            cpu_sel <= '0';
        end loop;
        cpu_addr(11) <= '0';
        cpu_wdata <= X"00000000";
        wait until rising_edge(clk);
        -- end constant waveforms for all channels
        
        
        for i in 0 to 31 loop
            
            -- write to select channel i 
            cpu_wdata <= X"00000000";
            wait until rising_edge(clk);
            cpu_addr(12) <= '1';
            cpu_addr(11 downto 5) <= (others => '0');
            cpu_addr(3 downto 0) <= "0001";
            wait until rising_edge(clk);
            cpu_wdata(i) <= '1';
            cpu_wr <= '1';
            cpu_sel <= '1';
            
            wait until rising_edge(clk);
            cpu_wdata <= X"00000000";
            cpu_wr <= '0';
            cpu_sel <= '0';
            cpu_addr <= (others => '0');
            -- end write to enable channel i 
            
            cpu_addr <= (others => '0');
            wait until rising_edge(clk);
            -- write top value
            cpu_addr(11) <= '1'; -- write to waveform table
            cpu_addr(9 downto 0) <= std_logic_vector(to_unsigned(2 + 3 * i, 10)); -- ram_pulse_addra 
            wait until rising_edge(clk);
            cpu_wdata(15 downto 0) <= std_logic_vector(to_unsigned(2 + 4 * i, 16));
            cpu_wdata(31 downto 16) <= std_logic_vector(to_unsigned(2 + 4 * i, 16));
            cpu_wr <= '1';
            cpu_sel <= '1';
            
            wait until rising_edge(clk);
            cpu_wr <= '0';
            cpu_sel <= '0';
            cpu_addr(11) <= '0';
            cpu_addr(11 downto 5) <= (others => '0');
            -- end write top value 

            
            -- Second pulse entry start.
            cpu_addr(4 downto 0) <= "00100"; -- ram_pulse_addra
            wait until rising_edge(clk);
            cpu_wdata <= std_logic_vector(to_unsigned(i * 2 + 64, 32)); -- start time
            cpu_wr <= '1';
            cpu_sel <= '1';
            
            wait until rising_edge(clk);
            cpu_wr <= '0';
            cpu_sel <= '0';
            
            cpu_addr(4 downto 0) <= "00101"; -- ram_pulse_addra
            wait until rising_edge(clk);
            cpu_wdata(11 downto 0) <=  std_logic_vector(to_unsigned(4 * i, 12)); -- wave start address
            cpu_wdata(25 downto 16) <= std_logic_vector(to_unsigned(4 + 2 * i, 10)); -- wave length
            cpu_wr <= '1';
            cpu_sel <= '1';
            
            wait until rising_edge(clk);
            cpu_wr <= '0';
            cpu_sel <= '0';
            
            cpu_addr(4 downto 0) <= "00110"; -- ram_pulse_addra
            wait until rising_edge(clk);
            cpu_wdata(15 downto 0) <= X"0100"; -- scale 
            cpu_wdata(31 downto 16) <= X"8000"; -- gain
            cpu_wr <= '1';
            cpu_sel <= '1';
            
            wait until rising_edge(clk);
            cpu_wr <= '0';
            cpu_sel <= '0';
            
            cpu_addr(4 downto 0) <= "00111"; -- ram_pulse_addra
            wait until rising_edge(clk);
            cpu_wdata <= std_logic_vector(to_unsigned(i * 2 + 16, 32)); -- flat top length 
            cpu_wr <= '1';
            cpu_sel <= '1';
            
            wait until rising_edge(clk);
            cpu_wr <= '0';
            cpu_sel <= '0';
            -- Second pulse entry end.
        end loop;   
        
        
        -- write reg_seq_length
        cpu_addr <= (others => '0');
        cpu_addr(12) <= '1';
        cpu_addr(3 downto 0) <= "0000";
        cpu_wdata <= X"00000160";
        cpu_wr <= '1';
        cpu_sel <= '1';
        wait until rising_edge(clk);
        cpu_wr <= '0';
        cpu_sel <= '0';
        cpu_addr <= (others => '0');
        -- end write reg_seq_length
        
        -- start first trigger
        trigger <= '1';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        trigger <= '0';
        
        
        clk_delay(5);

        -- triggering while running should do nothing
        trigger <= '1';
        wait until rising_edge(clk);
        trigger <= '0';
        wait until rising_edge(clk);
        -- end triggering while running should do nothing

        
        -- read sm_count_time
        cpu_addr <= (others => '0');
        cpu_addr(12) <= '1';
        cpu_addr(3 downto 0) <= "0101";
        cpu_wr <= '0';
        cpu_sel <= '1';
        wait until rising_edge(clk);
        clk_delay(5);
        cpu_addr <= (others => '0');
        cpu_sel <= '0';
        -- end read sm_count_time
      
        
        clk_delay(400);
        
        -- start second trigger
        trigger <= '1';
        wait until rising_edge(clk);
        trigger <= '0';
        clk_delay(20);

        -- reset from run
        reset       <= '1';
        enable      <= '0';
        cpu_sel     <= '0';
        cpu_wr      <= '0';
		cpu_wdata   <= (others=>'0');
		cpu_addr  	<= (others=>'0');
		wait until rising_edge(clk);
		reset <= '0';
		wait until rising_edge(clk);
		enable <= '1';
		wait until rising_edge(clk);
        -- end reset


        -- reset channel wise top value back to normal
        for i in 0 to 31 loop
            
            -- write to select channel i 
            cpu_wdata <= X"00000000";
            wait until rising_edge(clk);
            cpu_addr(12) <= '1';
            cpu_addr(11 downto 5) <= (others => '0');
            cpu_addr(3 downto 0) <= "0001";
            wait until rising_edge(clk);
            cpu_wdata(i) <= '1';
            cpu_wr <= '1';
            cpu_sel <= '1';
            
            wait until rising_edge(clk);
            cpu_wdata <= X"00000000";
            cpu_wr <= '0';
            cpu_sel <= '0';
            cpu_addr <= (others => '0');
            -- end write to enable channel i 
            
            cpu_addr <= (others => '0');
            wait until rising_edge(clk);
            -- write top value
            cpu_addr(11) <= '1'; -- write to waveform table
            cpu_addr(9 downto 0) <= std_logic_vector(to_unsigned(2 + 3 * i, 10)); -- ram_pulse_addra 
            wait until rising_edge(clk);
            cpu_wdata(15 downto 0) <= std_logic_vector(to_unsigned(2 + 3 * i, 16));
            cpu_wdata(31 downto 16) <= std_logic_vector(to_unsigned(2 + 3 * i, 16));
            cpu_wr <= '1';
            cpu_sel <= '1';
            
            wait until rising_edge(clk);
            cpu_wr <= '0';
            cpu_sel <= '0';
            cpu_addr(11) <= '0';
            cpu_addr(11 downto 5) <= (others => '0');
            -- end write top value 
        end loop;   
        -- endreset channel wise top value back to normal


        for i in 0 to 31 loop
            
            -- write to select channel i 
            cpu_wdata <= X"00000000";
            wait until rising_edge(clk);
            cpu_addr(12) <= '1';
            cpu_addr(11 downto 5) <= (others => '0');
            cpu_addr(3 downto 0) <= "0001";
            wait until rising_edge(clk);
            cpu_wdata(31 - i) <= '1';
            cpu_wr <= '1';
            cpu_sel <= '1';
            
            wait until rising_edge(clk);
            cpu_wdata <= X"00000000";
            cpu_wr <= '0';
            cpu_sel <= '0';
            cpu_addr <= (others => '0');
            -- end write to enable channel i 
            
            cpu_addr <= (others => '0');
            wait until rising_edge(clk);
            -- write top value
            cpu_addr(11) <= '1'; -- write to waveform table
            cpu_addr(9 downto 0) <= std_logic_vector(to_unsigned(2 + 3 * i, 10)); -- ram_pulse_addra 
            wait until rising_edge(clk);
            cpu_wdata(15 downto 0) <= std_logic_vector(to_unsigned(2 + 4 * i, 16));
            cpu_wdata(31 downto 16) <= std_logic_vector(to_unsigned(2 + 4 * i, 16));
            cpu_wr <= '1';
            cpu_sel <= '1';
            
            wait until rising_edge(clk);
            cpu_wr <= '0';
            cpu_sel <= '0';
            cpu_addr(11) <= '0';
            cpu_addr(11 downto 5) <= (others => '0');
            -- end write top value 

            
            -- Second pulse entry start.
            cpu_addr(4 downto 0) <= "00100"; -- ram_pulse_addra
            wait until rising_edge(clk);
            cpu_wdata <= std_logic_vector(to_unsigned(i * 2 + 64, 32)); -- start time
            cpu_wr <= '1';
            cpu_sel <= '1';
            
            wait until rising_edge(clk);
            cpu_wr <= '0';
            cpu_sel <= '0';
            
            cpu_addr(4 downto 0) <= "00101"; -- ram_pulse_addra
            wait until rising_edge(clk);
            cpu_wdata(11 downto 0) <=  std_logic_vector(to_unsigned(4 * i, 12)); -- wave start address
            cpu_wdata(25 downto 16) <= std_logic_vector(to_unsigned(4 + 2 * i, 10)); -- wave length
            cpu_wr <= '1';
            cpu_sel <= '1';
            
            wait until rising_edge(clk);
            cpu_wr <= '0';
            cpu_sel <= '0';
            
            cpu_addr(4 downto 0) <= "00110"; -- ram_pulse_addra
            wait until rising_edge(clk);
            cpu_wdata(15 downto 0) <= X"0100"; -- scale
            cpu_wdata(31 downto 16) <= X"8000"; -- gain
            cpu_wr <= '1';
            cpu_sel <= '1';
            
            wait until rising_edge(clk);
            cpu_wr <= '0';
            cpu_sel <= '0';
            
            cpu_addr(4 downto 0) <= "00111"; -- ram_pulse_addra
            wait until rising_edge(clk);
            cpu_wdata <= std_logic_vector(to_unsigned(i * 2 + 16, 32)); -- flat top length 
            cpu_wr <= '1';
            cpu_sel <= '1';
            
            wait until rising_edge(clk);
            cpu_wr <= '0';
            cpu_sel <= '0';
            -- Second pulse entry end.
        end loop;  

        -- start third trigger
        trigger <= '1';
        wait until rising_edge(clk);
        trigger <= '0';
        clk_delay(400);

        -- reset from idle
        reset       <= '1';
        enable      <= '0';
        cpu_sel     <= '0';
        cpu_wr      <= '0';
		cpu_wdata   <= (others=>'0');
		cpu_addr  	<= (others=>'0');
		wait until rising_edge(clk);
		reset <= '0';
		wait until rising_edge(clk);
		enable <= '1';
		wait until rising_edge(clk);
        -- end reset

        -- start fourth trigger
        trigger <= '1';
        wait until rising_edge(clk);
        trigger <= '0';
        clk_delay(400);


        -- read all rams
        for i in 0 to 31 loop
            
            -- write to select channel i 
            cpu_wdata <= X"00000000";
            wait until rising_edge(clk);
            cpu_addr(12) <= '1';
            cpu_addr(11 downto 5) <= (others => '0');
            cpu_addr(3 downto 0) <= "0001";
            wait until rising_edge(clk);
            cpu_wdata(i) <= '1';
            cpu_wr <= '1';
            cpu_sel <= '1';
            
            wait until rising_edge(clk);
            cpu_wdata <= X"00000000";
            cpu_wr <= '0';
            cpu_sel <= '0';
            cpu_addr <= (others => '0');
            -- end write to enable channel i 
            
            cpu_addr <= (others => '0');
            wait until rising_edge(clk);
            -- read top value
            cpu_addr(11) <= '1'; -- read waveform table
            cpu_addr(9 downto 0) <= std_logic_vector(to_unsigned(2 + 3 * i, 10)); -- ram_pulse_addra 
            wait until rising_edge(clk);
            -- cpu_wdata(15 downto 0) <= std_logic_vector(to_unsigned(2 + 4 * i, 16));
            -- cpu_wdata(31 downto 16) <= std_logic_vector(to_unsigned(2 + 4 * i, 16));
            cpu_wr <= '0';
            cpu_sel <= '1';
            
            wait until rising_edge(clk);
            cpu_wr <= '0';
            cpu_sel <= '0';
            cpu_addr(11) <= '0';
            cpu_addr(11 downto 5) <= (others => '0');
            -- end read top value 

            -- read start time
            cpu_addr(4 downto 0) <= "00100"; -- ram_pulse_addra
            wait until rising_edge(clk);
            -- cpu_wdata <= std_logic_vector(to_unsigned(i * 2 + 64, 32)); -- start time
            cpu_wr <= '0';
            cpu_sel <= '1';
            
            wait until rising_edge(clk);
            cpu_wr <= '0';
            cpu_sel <= '0';
            -- end read start time
        end loop;   
        -- end read all rams


        -- read all at once
        -- write to select all channels 
        cpu_wdata <= X"FFFFFFFF";
        wait until rising_edge(clk);
        cpu_addr(12) <= '1';
        cpu_addr(11 downto 5) <= (others => '0');
        cpu_addr(3 downto 0) <= "0001";
        wait until rising_edge(clk);
        cpu_wr <= '1';
        cpu_sel <= '1';
        
        wait until rising_edge(clk);
        cpu_wdata <= X"00000000";
        cpu_wr <= '0';
        cpu_sel <= '0';
        cpu_addr <= (others => '0');
        -- end write to select all channels
        
        cpu_addr <= (others => '0');
        wait until rising_edge(clk);
        -- read top value
        cpu_addr(11) <= '1'; -- read waveform table
        cpu_addr(9 downto 0) <= std_logic_vector(to_unsigned(5, 10)); -- ram_pulse_addra 
        wait until rising_edge(clk);
        -- cpu_wdata(15 downto 0) <= std_logic_vector(to_unsigned(2 + 4 * i, 16));
        -- cpu_wdata(31 downto 16) <= std_logic_vector(to_unsigned(2 + 4 * i, 16));
        cpu_wr <= '0';
        cpu_sel <= '1';
        
        wait until rising_edge(clk);
        cpu_wr <= '0';
        cpu_sel <= '0';
        cpu_addr(11) <= '0';
        cpu_addr(11 downto 5) <= (others => '0');
        -- end read top value 

        -- read start time
        cpu_addr(4 downto 0) <= "00100"; -- ram_pulse_addra
        wait until rising_edge(clk);
        -- cpu_wdata <= std_logic_vector(to_unsigned(i * 2 + 64, 32)); -- start time
        cpu_wr <= '0';
        cpu_sel <= '1';
        
        wait until rising_edge(clk);
        cpu_wr <= '0';
        cpu_sel <= '0';
        -- end read start time
        -- end read all at once


        -- reset
        reset       <= '1';
        enable      <= '0';
        cpu_sel     <= '0';
        cpu_wr      <= '0';
		cpu_wdata   <= (others=>'0');
		cpu_addr  	<= (others=>'0');
		wait until rising_edge(clk);
		reset <= '0';
		wait until rising_edge(clk);
		enable <= '1';
		wait until rising_edge(clk);
        -- end reset


        -- change time factor and gain factor 
        for i in 0 to 31 loop
            
            -- write to select channel i 
            cpu_wdata <= X"00000000";
            wait until rising_edge(clk);
            cpu_addr(12) <= '1';
            cpu_addr(11 downto 5) <= (others => '0');
            cpu_addr(3 downto 0) <= "0001";
            wait until rising_edge(clk);
            cpu_wdata(31 - i) <= '1';
            cpu_wr <= '1';
            cpu_sel <= '1';
            
            wait until rising_edge(clk);
            cpu_wdata <= X"00000000";
            cpu_wr <= '0';
            cpu_sel <= '0';
            cpu_addr <= (others => '0');
            -- end write to enable channel i 
            
            cpu_addr <= (others => '0');
            wait until rising_edge(clk);
            -- write top value
            cpu_addr(11) <= '1'; -- write to waveform table
            cpu_addr(9 downto 0) <= std_logic_vector(to_unsigned(2 + 3 * i, 10)); -- ram_pulse_addra 
            wait until rising_edge(clk);
            cpu_wdata(15 downto 0) <= std_logic_vector(to_unsigned(2 + 3 * i, 16));
            cpu_wdata(31 downto 16) <= std_logic_vector(to_unsigned(2 + 3 * i, 16));
            cpu_wr <= '1';
            cpu_sel <= '1';
            
            wait until rising_edge(clk);
            cpu_wr <= '0';
            cpu_sel <= '0';
            cpu_addr(11) <= '0';
            cpu_addr(11 downto 5) <= (others => '0');
            -- end write top value 

            
            -- Second pulse entry start.
            cpu_addr(4 downto 0) <= "00100"; -- ram_pulse_addra
            wait until rising_edge(clk);
            cpu_wdata <= std_logic_vector(to_unsigned(64, 32)); -- start time
            cpu_wr <= '1';
            cpu_sel <= '1';
            
            wait until rising_edge(clk);
            cpu_wr <= '0';
            cpu_sel <= '0';
            
            cpu_addr(4 downto 0) <= "00101"; -- ram_pulse_addra
            wait until rising_edge(clk);
            cpu_wdata(11 downto 0) <= X"0FF"; -- wave start address
            cpu_wdata(25 downto 16) <= "0000100000"; -- wave length
            cpu_wr <= '1';
            cpu_sel <= '1';
            
            wait until rising_edge(clk);
            cpu_wr <= '0';
            cpu_sel <= '0';
            
            cpu_addr(4 downto 0) <= "00110"; -- ram_pulse_addra
            wait until rising_edge(clk);
            cpu_wdata(15 downto 0) <= std_logic_vector(to_unsigned((i rem 2)*256 + 256, 16)); -- scale 
            cpu_wdata(31 downto 16) <= std_logic_vector(to_unsigned(i * 128, 16)); -- gain 
            cpu_wr <= '1';
            cpu_sel <= '1';
            
            wait until rising_edge(clk);
            cpu_wr <= '0';
            cpu_sel <= '0';
            
            cpu_addr(4 downto 0) <= "00111"; -- ram_pulse_addra
            wait until rising_edge(clk);
            cpu_wdata <= X"00000010"; -- flat top length 
            cpu_wr <= '1';
            cpu_sel <= '1';
            
            wait until rising_edge(clk);
            cpu_wr <= '0';
            cpu_sel <= '0';
            -- Second pulse entry end.
        end loop;  
        
        -- start fifth trigger
        trigger <= '1';
        wait until rising_edge(clk);
        trigger <= '0';
        clk_delay(400);
        
        cpu_print_msg("Simulation done");
        clk_delay(5);
		
        sim_done    <= true;
        wait;

    end process;

end behave;

