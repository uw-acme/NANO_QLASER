-------------------------------------------------------------------------------
-- File       : gj_serif_cpu2uart.vhd
-------------------------------------------------------------------------------
-- Transfer a CPU command (r/w, addr1, addr0 ,data3, data2 ,data1, data0) to UART
-------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_arith.all;
use     ieee.std_logic_unsigned.all;

use     work.gj_serial_pkg.all;

entity gj_serif_cpu2uart is
port (
    clk             : in  std_logic;
    reset           : in  std_logic;

    start           : in  std_logic;
    cpu_wr          : in  std_logic;
    cpu_data        : in  std_logic_vector(31 downto 0);
    cpu_addr        : in  std_logic_vector(15 downto 0);
    force_err       : in  std_logic_vector( 7 downto 0);
    
    -- Interface to UART
    tx_ready        : in  std_logic;                        -- Ready for transmit data
    data_tx         : out std_logic_vector( 7 downto 0);    -- Data to transmit
    data_tx_wr      : out std_logic;                        -- Write control for data_tx
    err_parity      : out std_logic;                        -- 
    err_data        : out std_logic;                        -- 

    interrupt       : out std_logic
);
end gj_serif_cpu2uart;

-------------------------------------------------------------------------------
-- Minimal arch that assumes that cpu_data is held stable during the transmit.
-------------------------------------------------------------------------------
architecture rtl of gj_serif_cpu2uart is

--constant C_CPU_OP_WR    : std_logic_vector( 7 downto 0) := X"57"; -- 'W' = Write
--constant C_CPU_OP_RD    : std_logic_vector( 7 downto 0) := X"52"; -- 'R' = Read

type t_state  is (S_IDLE,
                  S_WR_PKT0, S_WAIT0, S_WR_PKT1, S_WAIT1,
                  S_WR_PKT2, S_WAIT2, S_WR_PKT3, S_WAIT3,
                  S_WR_PKT4, S_WAIT4, S_WR_PKT5, S_WAIT5,
                  S_WR_PKT6, S_WAIT6
);

signal state            : t_state;

signal start_d1         : std_logic;
signal start_xmit       : std_logic;
signal pktdata0         : std_logic_vector( 7 downto 0);
signal pktdata1         : std_logic_vector( 7 downto 0);
signal pktdata2         : std_logic_vector( 7 downto 0);
signal pktdata3         : std_logic_vector( 7 downto 0);
signal pktdata4         : std_logic_vector( 7 downto 0);
signal pktdata5         : std_logic_vector( 7 downto 0);
signal pktdata6         : std_logic_vector( 7 downto 0);
    
begin

    -------------------------------------------------------------------                    
    -- Start transmit on rising edge of 'start'.
    -------------------------------------------------------------------                    
    pr_clk_start : process (clk)
    begin

        if (clk'event and clk='1') then
            if (reset='1') then
                start_d1    <= '0';
                start_xmit  <= '0';
                pktdata0    <= (others=>'0'); 
                pktdata1    <= (others=>'0'); 
                pktdata2    <= (others=>'0'); 
                pktdata3    <= (others=>'0'); 
                pktdata4    <= (others=>'0'); 
                pktdata5    <= (others=>'0'); 
                pktdata6    <= (others=>'0'); 
            else
                start_d1    <= start;

                -- Start transmit
                if (start='1' and start_d1='0') then
                    start_xmit  <= '1';
                    if (cpu_wr='1') then
                        pktdata0    <= C_CPU_OP_WR; 
                    else    
                        pktdata0    <= C_CPU_OP_RD; 
                    end if;
                    pktdata1    <= cpu_addr(15 downto  8);
                    pktdata2    <= cpu_addr( 7 downto  0);
                    pktdata3    <= cpu_data(31 downto 24);
                    pktdata4    <= cpu_data(23 downto 16);
                    pktdata5    <= cpu_data(15 downto  8);
                    pktdata6    <= cpu_data( 7 downto  0);
                else
                    start_xmit  <= '0';
                end if;
            end if;
        end if;

    end process;
    
    ----------------------------------------------------------------------
    -- State machine to write 7 bytes of pktdata to UART.
    -- Started by 'start_xmit'.  Ignores 'start_xmit' if in middle of xmit 
    -- or if uart is still busy.
    ----------------------------------------------------------------------
    pr_clk_sm : process (clk)
    begin

        if (clk'event and clk='1') then

            if (reset='1') then
                state       <= S_IDLE;
                data_tx_wr  <= '0'; 
                data_tx     <= (others=>'0');
                interrupt   <= '0'; 
                err_parity  <= '0'; 
                err_data    <= '0'; 

            else
                case state is

                    when S_IDLE => 
                        if (start_xmit = '1') and (tx_ready='1') then
                            state       <= S_WR_PKT0;
                            data_tx_wr  <= '1';
                            data_tx     <= pktdata0;
                        else
                            data_tx_wr  <= '0';
                            data_tx     <= (others=>'0');
                            err_parity  <= force_err(0); 
                            err_data    <= force_err(4); 
                        end if;
                        interrupt       <= '0'; 
                    
                    when S_WR_PKT0 => 
                        data_tx_wr      <= '0';
                        if (tx_ready = '0') then
                            state       <= S_WAIT0;
                        end if;
                    
                    when S_WAIT0 => 
                        if (tx_ready = '1') then
                            state       <= S_WR_PKT1;
                            data_tx_wr  <= '1';
                            data_tx     <= pktdata1;
                            err_parity  <= force_err(1); 
                            err_data    <= force_err(5); 
                        else
                            data_tx_wr  <= '0';
                        end if;
                    
                    when S_WR_PKT1 => 
                        data_tx_wr      <= '0';
                        data_tx         <= (others=>'0');
                        if (tx_ready = '0') then
                            state       <= S_WAIT1;
                        end if;
                    
                    when S_WAIT1 => 
                        if (tx_ready = '1') then
                            state       <= S_WR_PKT2;
                            data_tx_wr  <= '1';
                            data_tx     <= pktdata2;
                            err_parity  <= force_err(2); 
                            err_data    <= force_err(6); 
                        else
                            data_tx_wr  <= '0';
                        end if;
                    
                    when S_WR_PKT2 => 
                        data_tx_wr      <= '0';
                        if (tx_ready = '0') then
                            state       <= S_WAIT2;
                        end if;
                    
                    when S_WAIT2 => 
                        if (tx_ready = '1') then
                            state       <= S_WR_PKT3;
                            data_tx_wr  <= '1';
                            data_tx     <= pktdata3;
                            err_parity  <= force_err(3); 
                            err_data    <= force_err(7); 
                        else
                            data_tx_wr  <= '0';
                        end if;
                    
                    when S_WR_PKT3 => 
                        data_tx_wr      <= '0';
                        if (tx_ready = '0') then
                            state       <= S_WAIT3;
                        end if;
                    
                    when S_WAIT3 => 
                        if (tx_ready = '1') then
                            state       <= S_WR_PKT4;
                            data_tx_wr  <= '1';
                            data_tx     <= pktdata4;
                        else
                            data_tx_wr  <= '0';
                        end if;
                    
                    ---- 4
                    when S_WR_PKT4 => 
                        data_tx_wr      <= '0';
                        if (tx_ready = '0') then
                            state       <= S_WAIT4;
                        end if;
                    
                    when S_WAIT4 => 
                        if (tx_ready = '1') then
                            state       <= S_WR_PKT5;
                            data_tx_wr  <= '1';
                            data_tx     <= pktdata5;
                        else
                            data_tx_wr  <= '0';
                        end if;
                    
                    ---- 5
                    when S_WR_PKT5 => 
                        data_tx_wr      <= '0';
                        if (tx_ready = '0') then
                            state       <= S_WAIT5;
                        end if;
                    
                    when S_WAIT5 => 
                        if (tx_ready = '1') then
                            state       <= S_WR_PKT6;
                            data_tx_wr  <= '1';
                            data_tx     <= pktdata6;
                        else
                            data_tx_wr  <= '0';
                        end if;
                    
                    ---- 6
                    when S_WR_PKT6 => 
                        data_tx_wr      <= '0';
                        if (tx_ready = '0') then
                            state       <= S_WAIT6;
                        end if;
                    
                    when S_WAIT6 => 
                        if (tx_ready = '1') then
                            state       <= S_IDLE;
                            interrupt   <= '1'; 
                            data_tx     <= (others=>'0');
                        else
                            data_tx_wr  <= '0';
                        end if;
                    
                    when others => 
                        state           <= S_IDLE;

                end case;

            end if;
        end if;
    end process;

end rtl;

