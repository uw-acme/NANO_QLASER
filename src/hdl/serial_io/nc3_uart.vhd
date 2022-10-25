-------------------------------------------------------------------------------
-- File Name   : nc3_uart.vhd
-- Copyright (c) 2012 by GJED, Seattle, WA
-- Purpose     : 8-bit UART, odd,even or no parity.
-------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

entity nc3_uart is
port
(
    clk         : in  std_logic;
    reset       : in  std_logic;

    -- Configuration
    bitwidth    : in  std_logic_vector(11 downto 0);    -- Baud rate divisor 
    parity_on   : in  std_logic;                        -- Enable parity checking and addition
    parity_odd  : in  std_logic;                        -- Set parity to 'odd', else 'even'

    data_tx     : in  std_logic_vector( 7 downto 0);    -- Data to transmit
    data_tx_wr  : in  std_logic;                        -- Write control for data_tx
    tx_ready    : out std_logic;                        -- Ready for transmit data
    tx_active   : out std_logic;                        -- Serial output is active

    data_rx     : out std_logic_vector( 7 downto 0);    -- Received data
    data_rx_dv  : out std_logic;                        -- Received data valid
    data_rx_err : out std_logic;                        -- Error in received data
    
    -- Serial interface
    rxd         : in  std_logic;                        -- Serial input/receive data
    txd         : out std_logic                         -- Serial output/transmit data 
);  
end nc3_uart;

architecture rtl of nc3_uart is

signal parity_tx        : std_logic;  
signal usbitwidth       : unsigned(11 downto 0);  
signal rx_err_parity    : std_logic;  
signal rx_err_framing   : std_logic;  

signal sreg_tx          : std_logic_vector( 7 downto 0);  
signal cnt_bit_tx       : unsigned( 3 downto 0);  
signal cnt_tick_tx      : unsigned(11 downto 0);  

signal sreg_rx          : std_logic_vector( 7 downto 0);  
signal cnt_bit_rx       : unsigned( 3 downto 0);  
signal cnt_tick_rx      : unsigned(11 downto 0);  
signal filtreg_rxd      : std_logic_vector( 7 downto 0);  
signal rxd_filtered     : std_logic;

-- State variable type definitions
type t_state_tx is (S_TX_IDLE, S_TX_START, S_TX_DATA, S_TX_PARITY, S_TX_STOP);
signal state_tx         : t_state_tx;

type t_state_rx is (S_RX_IDLE, S_RX_START, S_RX_DATA, S_RX_PARITY, S_RX_STOP, S_RX_DONE);
signal state_rx         : t_state_rx;

begin
    
    usbitwidth  <= unsigned(bitwidth);
    
    ------------------------------------------------------------------
    -- Input filter
    ------------------------------------------------------------------
    pr_filter : process (clk)
    begin

        if rising_edge(clk) then

            if (reset='1') then
                rxd_filtered    <= '1';
                filtreg_rxd     <= (others=>'1');

            else
                filtreg_rxd     <= filtreg_rxd(6 downto 0) & rxd;

                if (filtreg_rxd = X"00") then
                    rxd_filtered    <= '0';
                elsif (filtreg_rxd = X"FF") then
                    rxd_filtered    <= '1';
                end if;

            end if; 
        end if; 
    end process;
    

    ------------------------------------------------------------------
    -- Transmit state machine
    ------------------------------------------------------------------
    pr_sm_state_tx : process (clk)
    begin
            
        if rising_edge(clk) then  

            if (reset='1') then   
            
                state_tx        <= S_TX_IDLE;
                tx_ready        <= '1';
                tx_active       <= '0';
                cnt_tick_tx     <= (others=>'0');
                txd             <= '1';
            else    
                case state_tx is
                
                    ------------------------------------------------------
                    -- Wait until data is written
                    ------------------------------------------------------
                    when S_TX_IDLE  =>  
                
                        if (data_tx_wr = '1') then
                            state_tx        <= S_TX_START;
                            sreg_tx         <= data_tx;
                            txd             <= '0';
                            tx_ready        <= '0';
                            tx_active       <= '1';
                        else
                            parity_tx       <= parity_odd;
                            txd             <= '1';
                            tx_ready        <= '1';
                            tx_active       <= '0';
                        end if; 
                        cnt_tick_tx     <= (others=>'0');
                        cnt_bit_tx      <= (others=>'0');
                    
                    ------------------------------------------------------
                    -- Start bit. Set the output to '0' for one bit period
                    ------------------------------------------------------
                    when S_TX_START  =>  
                
                        if (cnt_tick_tx = usbitwidth) then

                            -- Calculate parity bit needed
                            parity_tx       <= parity_tx xor sreg_tx(0);

                            state_tx            <= S_TX_DATA;
                            txd                 <= sreg_tx(0);
                            sreg_tx(7 downto 0) <= '1' & sreg_tx(7 downto 1);
                            cnt_tick_tx         <= (others=>'0');
                        else
                            cnt_tick_tx         <= cnt_tick_tx + 1;
                        end if; 
                    
                    ------------------------------------------------------
                    -- Data bits. Shift out 8 bits of data.
                    -- Next state could be 'stop' or 'parity'
                    ------------------------------------------------------
                    when S_TX_DATA  =>  
                
                        if (cnt_tick_tx = usbitwidth) then

                            if (cnt_bit_tx = 7) then
                                if (parity_on = '1') then
                                    state_tx        <= S_TX_PARITY;
                                    txd             <= parity_tx;
                                else
                                    state_tx        <= S_TX_STOP;
                                    txd             <= '1';
                                end if;
                            else
                                parity_tx           <= parity_tx xor sreg_tx(0);
                                txd                 <= sreg_tx(0);
                                sreg_tx(7 downto 0) <= '1' & sreg_tx(7 downto 1);
                                cnt_bit_tx          <= cnt_bit_tx + 1;
                            end if;

                            cnt_tick_tx     <= (others=>'0');
                        else
                            cnt_tick_tx     <= cnt_tick_tx + 1;
                        end if; 
                    
                    ------------------------------------------------------
                    -- Parity bit. Set the parity value for one bit period
                    ------------------------------------------------------
                    when S_TX_PARITY  =>  
                
                        if (cnt_tick_tx = usbitwidth) then
                            state_tx        <= S_TX_STOP;
                            txd             <= '1';
                            cnt_tick_tx     <= (others=>'0');
                        else
                            cnt_tick_tx     <= cnt_tick_tx + 1;
                        end if; 
                    
                    ------------------------------------------------------
                    -- Stop bit. Set the output to '1' for one bit period
                    ------------------------------------------------------
                    when S_TX_STOP  =>  
                
                        if (cnt_tick_tx = usbitwidth) then
                            state_tx        <= S_TX_IDLE;
                            cnt_tick_tx     <= (others=>'0');
                        else
                            cnt_tick_tx     <= cnt_tick_tx + 1;
                        end if; 
                    
                    ------------------------------------------------------
                    -- Default case
                    ------------------------------------------------------
                    when others =>  
                        state_tx        <= S_TX_IDLE;
                
                end case;
            
            end if;
        end if; 
        
    end process;


    ------------------------------------------------------------------
    -- Receive state machine
    ------------------------------------------------------------------
    pr_sm_state_rx : process (clk)
    begin
    
        if rising_edge(clk) then  

            if (reset='1') then   
            
                state_rx        <= S_RX_IDLE;
                data_rx_dv      <= '0';
                data_rx_err     <= '0';
                data_rx         <= (others=>'0');
                rx_err_parity   <= '0';
                rx_err_framing  <= '0';
                cnt_tick_rx     <= (others=>'0');
            
            else            
                case state_rx is
                
                    ------------------------------------------------------
                    -- Wait for the rxd to go low with the start bit
                    ------------------------------------------------------
                    when S_RX_IDLE  =>  
                
                        if (rxd_filtered = '0') then
                            state_rx        <= S_RX_START;
                        end if; 
                        data_rx_dv      <= '0';
                        data_rx_err     <= '0';
                        data_rx         <= (others=>'0');
                        rx_err_parity   <= parity_odd and parity_on;
                        rx_err_framing  <= '0';
                        cnt_tick_rx     <= (others=>'0');
                        cnt_bit_rx      <= (others=>'0');
                    
                    ------------------------------------------------------
                    -- Wait for half a bit-time then sample the start bit.
                    ------------------------------------------------------
                    when S_RX_START  =>  
                
                        if (cnt_tick_rx(11 downto 1) = usbitwidth(11 downto 1)) then
                            if (rxd_filtered='0') then
                                state_rx        <= S_RX_DATA;
                            else
                                state_rx        <= S_RX_IDLE;   -- False start
                            end if;
                            cnt_tick_rx     <= (others=>'0');
                        else
                            cnt_tick_rx     <= cnt_tick_rx + 2;
                        end if; 
                    
                    ------------------------------------------------------
                    -- Sample the data bits
                    ------------------------------------------------------
                    when S_RX_DATA  =>  
                
                        if (cnt_tick_rx = usbitwidth) then

                            if (cnt_bit_rx = 7) then
                                if (parity_on = '1') then
                                    state_rx        <= S_RX_PARITY;
                                else
                                    state_rx        <= S_RX_STOP;
                                end if;
                            else
                                cnt_bit_rx          <= cnt_bit_rx + 1;
                            end if;
                            sreg_rx(7 downto 0) <= rxd_filtered & sreg_rx(7 downto 1);
                            rx_err_parity       <= (rx_err_parity xor rxd_filtered) and parity_on;

                            cnt_tick_rx     <= (others=>'0');
                        else
                            cnt_tick_rx     <= cnt_tick_rx + 1;
                        end if; 
                    
                    ------------------------------------------------------
                    -- Sample the parity bit
                    ------------------------------------------------------
                    when S_RX_PARITY  =>  
                
                        if (cnt_tick_rx = usbitwidth) then
                            state_rx        <= S_RX_STOP;
                            cnt_tick_rx     <= (others=>'0');
                            rx_err_parity   <= rx_err_parity xor rxd_filtered;
                        else
                            cnt_tick_rx     <= cnt_tick_rx + 1;
                        end if; 
                    
                    ------------------------------------------------------
                    -- Sample the stop bit
                    ------------------------------------------------------
                    when S_RX_STOP  =>  
                
                        if (cnt_tick_rx = usbitwidth) then
                            if (rxd_filtered='0') then
                               rx_err_framing   <= '1'; 
                            end if;
                            state_rx        <= S_RX_DONE;
                            cnt_tick_rx     <= (others=>'0');
                        else
                            cnt_tick_rx     <= cnt_tick_rx + 1;
                        end if; 
                    
                    ------------------------------------------------------
                    -- Write the received data, set dv and err flags.
                    ------------------------------------------------------
                    when S_RX_DONE  =>  
                
                        data_rx         <= sreg_rx;
                        data_rx_dv      <= '1';
                        data_rx_err     <= rx_err_parity or rx_err_framing;
                        state_rx        <= S_RX_IDLE;
                    
                    ------------------------------------------------------
                    ------------------------------------------------------
                    when others =>
                        state_rx        <= S_RX_IDLE;
                
                end case;
            
            end if;
        end if;
        
    end process;

end rtl;