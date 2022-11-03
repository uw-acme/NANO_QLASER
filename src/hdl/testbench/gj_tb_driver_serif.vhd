-------------------------------------------------------------------------------
-- File : gj_tb_driver_serif.vhd
-------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;

use     work.gj_tb_pkg.all;
use     work.gj_serial_pkg.all;

entity gj_tb_driver_serif is
port (
    reset           : in  std_logic;
    clk             : in  std_logic;

    -- CPU Control interface
    cpu_wr          : in  std_logic; -- write enable
    cpu_sel         : in  std_logic; -- block select
    cpu_addr        : in  std_logic_vector(27 downto 0);
    cpu_din         : in  std_logic_vector(31 downto 0);
    cpu_dout        : out std_logic_vector(31 downto 0);
    cpu_ack         : out std_logic; 
    interrupt       : out std_logic;  -- TX or RX done 

    rxd             : in  std_logic;
    txd             : out std_logic
);
end gj_tb_driver_serif;

-------------------------------------------------------------------------------
-- Convert a cpu bus write of 32 bits to a 7-byte rs232 
-- message ('W', Address1,0, Data-3,2,1,0)
-------------------------------------------------------------------------------
architecture rtl of gj_tb_driver_serif is


signal reg_tx_data      : std_logic_vector(31 downto 0);
signal reg_tx_addr      : std_logic_vector(15 downto 0);
signal reg_tx_wr        : std_logic;
signal reg_bitwidth     : std_logic_vector(11 downto 0); -- Set the serial interface baudrate
signal reg_config       : std_logic_vector( 1 downto 0); -- Enable parity and select type
signal reg_force_err_tx : std_logic_vector( 7 downto 0); -- Force data and parity errors on message bytes

signal data_tx          : std_logic_vector( 7 downto 0); -- Data to transmit
signal data_tx_wr       : std_logic;                     -- Write control for data_tx
signal tx_ready         : std_logic;                     -- Ready for transmit data
signal data_rx          : std_logic_vector( 7 downto 0); -- Received data
signal data_rx_dv       : std_logic;                     -- Received data valid
signal data_rx_err      : std_logic;                     -- Error in received data
signal tx_err_parity    : std_logic;                     -- Force a parity error
signal tx_err_data      : std_logic;                     -- Force a data error
signal rx_msg_data      : std_logic_vector(31 downto 0);
signal rx_err_ack       : std_logic;                     -- Flag for bad msg header
signal rx_err_word      : std_logic_vector(C_SIZE_RD_MSG-1 downto 0); -- Flag for error in each word
signal parity_on        : std_logic;
signal parity_odd       : std_logic;

signal start_tx         : std_logic := '0';
signal tied_low         : std_logic := '0';
signal tied_high        : std_logic := '1';
signal zeros            : std_logic_vector(31 downto 0);

signal interrupt_rx_done: std_logic := '0';
signal interrupt_tx_done: std_logic := '0';

begin
	
	zeros		<= (others=>'0');
    interrupt   <= interrupt_tx_done or interrupt_rx_done;


    -------------------------------------------------------
    -- CPU interface.
    -------------------------------------------------------
    pr_clk_rw : process (clk)
        variable out_string : string(1 to 256);
    begin

        if (clk'event and clk='1') then

            if (reset='1' ) then
                cpu_ack             <= '0';
                cpu_dout            <= (others=>'0');
                start_tx            <= '0';
                reg_tx_data         <= (others=>'0');
                reg_tx_addr         <= (others=>'0');
                reg_tx_wr           <= '0';
                reg_bitwidth        <= C_RS232_BDIV;
                reg_config          <= PARITY_EVEN;
                reg_force_err_tx    <= (others=>'0');
                
            -- Write registers
            elsif (cpu_sel='1' and cpu_wr='1') then

                case cpu_addr(19 downto 16) is

                    -- Execute a 'Read' command 
                    when  "0000" => 
                        reg_tx_data <= X"1234EECC";
                        reg_tx_addr <= cpu_addr(15 downto 0);
                        reg_tx_wr   <= '0';
                        start_tx    <= '1';

                    -- Execute a 'Write' command 
                    when  "0001" =>
                        reg_tx_data <= cpu_din(31 downto 0);
                        reg_tx_addr <= cpu_addr(15 downto 0);
                        reg_tx_wr   <= '1';
                        start_tx    <= '1';
                    
                    when "0010" => reg_bitwidth     <= cpu_din(11 downto 0); -- Baudrate divisor
                    when "0011" => reg_config       <= cpu_din( 1 downto 0); -- Parity 00=off, 01=even, 11=odd
                    when "0100" => reg_force_err_tx <= cpu_din( 7 downto 0); -- Force errors
                    when others => null;

                end case;
                cpu_ack     <= '1';

            -- Read control, status and received data regs
            elsif (cpu_sel='1' and cpu_wr='0') then

                case cpu_addr(19 downto 16) is
                    when "0000" => cpu_dout    <= rx_msg_data;
                    when "0001" => cpu_dout    <= zeros(31 downto C_SIZE_RD_MSG+1) & rx_err_ack & rx_err_word ;
                    when "0010" => cpu_dout    <= X"00000" & reg_bitwidth;
                    when "0011" => cpu_dout    <= X"0000000" & "00" & reg_config;
                    when "0100" => cpu_dout    <= X"000000" & reg_force_err_tx;
                    when others => cpu_dout    <= X"CCCCCCCC";
                end case;
                start_tx    <= '0';
                cpu_ack     <= '1';

            else
                cpu_dout    <= (others=>'0');
                start_tx    <= '0';
                cpu_ack     <= '0';

            end if;
        end if;
        
    end process;

    parity_on   <= reg_config(0);
    parity_odd  <= reg_config(1);


    -----------------------------------------------------------
    -- Transfer a 7-byte CPU command (r/w, addr1,0 ,data3,2,1,0) to UART
    -----------------------------------------------------------
    u_gj_cpu2uart : entity work.gj_serif_cpu2uart
    port map(
        clk                 => clk                      , -- in  std_logic;
        reset               => reset                    , -- in  std_logic;
        start               => start_tx                 , -- in  std_logic;
        cpu_wr              => reg_tx_wr                , -- in  std_logic;
        cpu_data            => reg_tx_data(31 downto 0) , -- in  std_logic_vector(31 downto 0);
        cpu_addr            => reg_tx_addr(15 downto 0) , -- in  std_logic_vector(15 downto 0);
        force_err           => reg_force_err_tx         , -- in  std_logic_vector( 7 downto 0);
        tx_ready            => tx_ready                 , -- in  std_logic;                        -- Ready for transmit data
        data_tx             => data_tx                  , -- out std_logic_vector( 7 downto 0);    -- Data to transmit
        data_tx_wr          => data_tx_wr               , -- out std_logic;                        -- Write control for data_tx
        err_parity          => tx_err_parity            , -- out std_logic;                        -- 
        err_data            => tx_err_data              , -- out std_logic;                        -- 
        interrupt           => interrupt_tx_done          -- out std_logic
    );

 
    -----------------------------------------------------------
    -- UART
    -----------------------------------------------------------
    u_gj_uart_tb : entity work.gj_uart_tb
    port map(
        reset               => reset                , -- in  std_logic;
        clk                 => clk                  , -- in  std_logic;

        bitwidth            => reg_bitwidth         , -- in  std_logic_vector(11 downto 0);    -- Baud rate divisor 
        parity_on           => parity_on            , -- in  std_logic;                        -- Enable parity checking and addition
        parity_odd          => parity_odd           , -- in  std_logic;                        -- Set parity to 'odd', else 'even'
        err_parity          => tx_err_parity        , -- in  std_logic;                        -- Force a parity error
        err_data            => tx_err_data          , -- in  std_logic;                        -- Force a data error

        data_tx             => data_tx              , -- in  std_logic_vector( 7 downto 0);    -- Data to transmit
        data_tx_wr          => data_tx_wr           , -- in  std_logic;                        -- Write control for data_tx
        tx_ready            => tx_ready             , -- out std_logic;                        -- Ready for transmit data

        data_rx             => data_rx              , -- out std_logic_vector( 7 downto 0);    -- Received data
        data_rx_dv          => data_rx_dv           , -- out std_logic;                        -- Received data valid
        data_rx_err         => data_rx_err          , -- out std_logic;                        -- Error in received data

        -- Serial data
        rxd                 => rxd                  , -- in  std_logic;                        -- Serial input/receive data
        txd                 => txd                    -- out std_logic                         -- Serial output/transmit data 
    );


    -------------------------------------------------------------------------------
    -- Receive a message : ack, data(N:0)
    -------------------------------------------------------------------------------
    u_gj_uart2cpu : entity work.gj_serif_uart2cpu 
    port map(
        clk                 => clk                      , -- in  std_logic;
        reset               => reset                    , -- in  std_logic;
        data_rx             => data_rx                  , -- in  std_logic_vector( 7 downto 0);    -- Received data
        data_rx_dv          => data_rx_dv               , -- in  std_logic;                        -- Received data valid
        data_rx_err         => data_rx_err              , -- in  std_logic;                        -- Error in received data
        msg_data            => rx_msg_data(31 downto 0) , -- out std_logic_vector(31 downto 0);
        err_ack             => rx_err_ack               , -- out std_logic;                        -- Flag for bad msg header
        err_word            => rx_err_word              , -- out std_logic_vector(C_SIZE_RD_MSG-1 downto 0);    -- Flag for error in each word
        interrupt           => interrupt_rx_done          -- out std_logic
    );

end; 
