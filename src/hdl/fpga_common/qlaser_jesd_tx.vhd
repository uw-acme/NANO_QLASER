---------------------------------------------------------------
--  File         : qlaser_top.vhd
--  Description  : Top-level of Qlaser FPGA
----------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

use     work.qlaser_pkg.all;

entity qlaser_jesd_tx is
port (
        clk               : in  std_logic; 
        reset             : in  std_logic;
        
        core_clk          : in  std_logic;
        
        tx_tdata          : in std_logic_vector(255 downto 0);
        tx_tready         : out std_logic;
        
        tx_sysref         : in std_logic
        
);
end entity;

architecture rtl of qlaser_jesd_tx is
    signal s_axi_aresetn        : STD_LOGIC;
    signal s_axi_awaddr         : STD_LOGIC_VECTOR(11 DOWNTO 0);
    signal s_axi_awvalid        : STD_LOGIC;
    signal s_axi_awready        : STD_LOGIC;
    signal s_axi_wdata          : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal s_axi_wstrb          : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal s_axi_wvalid         : STD_LOGIC;
    signal s_axi_wready         : STD_LOGIC;
    signal s_axi_bresp          : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal s_axi_bvalid         : STD_LOGIC;
    signal s_axi_bready         : STD_LOGIC;
    signal s_axi_araddr         : STD_LOGIC_VECTOR(11 DOWNTO 0);
    signal s_axi_arvalid        : STD_LOGIC;
    signal s_axi_arready        : STD_LOGIC;
    signal s_axi_rdata          : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal s_axi_rresp          : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal s_axi_rvalid         : STD_LOGIC;
    signal s_axi_rready         : STD_LOGIC;
    signal tx_core_clk          : STD_LOGIC;
    signal tx_core_reset        : STD_LOGIC;
    signal irq                  : STD_LOGIC;
    signal tx_aresetn           : STD_LOGIC;
    signal tx_sof               : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal tx_somf              : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal tx_sync              : STD_LOGIC;
    signal tx_reset_gt          : STD_LOGIC;
    signal gt0_txdata           : STD_LOGIC_VECTOR(63 DOWNTO 0);
    signal gt0_txcharisk        : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal gt0_txheader         : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal gt1_txdata           : STD_LOGIC_VECTOR(63 DOWNTO 0);
    signal gt1_txcharisk        : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal gt1_txheader         : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal gt2_txdata           : STD_LOGIC_VECTOR(63 DOWNTO 0);
    signal gt2_txcharisk        : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal gt2_txheader         : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal gt3_txdata           : STD_LOGIC_VECTOR(63 DOWNTO 0);
    signal gt3_txcharisk        : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal gt3_txheader         : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal gt4_txdata           : STD_LOGIC_VECTOR(63 DOWNTO 0);
    signal gt4_txcharisk        : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal gt4_txheader         : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal gt5_txdata           : STD_LOGIC_VECTOR(63 DOWNTO 0);
    signal gt5_txcharisk        : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal gt5_txheader         : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal gt6_txdata           : STD_LOGIC_VECTOR(63 DOWNTO 0);
    signal gt6_txcharisk        : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal gt6_txheader         : STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal gt7_txdata           : STD_LOGIC_VECTOR(63 DOWNTO 0);
    signal gt7_txcharisk        : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal gt7_txheader         : STD_LOGIC_VECTOR(1 DOWNTO 0);
    
    type t_axi_write_state is (IDLE, ADDR, DATA, BRESP);
    signal write_state   : t_axi_write_state;
    
    type t_axi_read_state is (IDLE, ADDR, DATA, RRESP);
    signal read_state   : t_axi_read_state;
    
    signal read_complete        : std_logic;
    signal read_error           : std_logic;
    signal read_data            : std_logic_vector(31 downto 0);
    signal read_request         : std_logic;
    signal rresp_data           : std_logic_vector(1 downto 0);
    
    
    signal write_complete       : std_logic;
    signal write_error          : std_logic;
    signal send_write           : std_logic;
    
    signal write_addr : std_logic_vector(11 downto 0);
    signal write_data : std_logic_vector(31 downto 0);
    
    type t_setup_state is (IDLE, RESET_WAIT, ILA_WRITE, OCTETS_WRITE, FRAME_WRITE, RESET_WRITE, RESET_READ, ILA_READ, OCTETS_READ, FRAME_READ, DONE);
    signal setup_state : t_setup_state;
    
    type t_test_state is (IDLE, WAITING, READING, WRITE_ONE, READING2, DONE);
    signal test_state : t_test_state;
    signal wait_cnt : std_logic_vector(9 downto 0);
    
    signal setup_error : std_logic;
    
    signal sysref_re   : std_logic;
    
    
    -- PHY signals
    signal txp_out : std_logic_vector(7 downto 0);
    signal txn_out : std_logic_vector(7 downto 0);



    signal txoutclk     : std_logic;
    signal rxoutclk     : std_logic;
    signal gt_prbssel   : std_logic_vector(3 downto 0);

    signal tx_reset_done    : std_logic;
    signal gt_powergood     : std_logic;
    signal gt0_rxdata       : std_logic_vector(31 downto 0);
    signal gt0_rxcharisk    : std_logic_vector(3 downto 0);
    signal gt0_rxdisperr    : std_logic_vector(3 downto 0);
    signal gt0_rxnotintable : std_logic_vector(3 downto 0);
    signal gt1_rxdata       : std_logic_vector(31 downto 0);
    signal gt1_rxcharisk    : std_logic_vector(3 downto 0);
    signal gt1_rxdisperr    : std_logic_vector(3 downto 0);
    signal gt1_rxnotintable : std_logic_vector(3 downto 0);
    signal gt2_rxdata       : std_logic_vector(31 downto 0);
    signal gt2_rxcharisk    : std_logic_vector(3 downto 0);
    signal gt2_rxdisperr    : std_logic_vector(3 downto 0);
    signal gt2_rxnotintable : std_logic_vector(3 downto 0);
    signal gt3_rxdata       : std_logic_vector(31 downto 0);
    signal gt3_rxcharisk    : std_logic_vector(3 downto 0);
    signal gt3_rxdisperr    : std_logic_vector(3 downto 0);
    signal gt3_rxnotintable : std_logic_vector(3 downto 0);
    signal gt4_rxdata       : std_logic_vector(31 downto 0);
    signal gt4_rxcharisk    : std_logic_vector(3 downto 0);
    signal gt4_rxdisperr    : std_logic_vector(3 downto 0);
    signal gt4_rxnotintable : std_logic_vector(3 downto 0);
    signal gt5_rxdata       : std_logic_vector(31 downto 0);
    signal gt5_rxcharisk    : std_logic_vector(3 downto 0);
    signal gt5_rxdisperr    : std_logic_vector(3 downto 0);
    signal gt5_rxnotintable : std_logic_vector(3 downto 0);
    signal gt6_rxdata       : std_logic_vector(31 downto 0);
    signal gt6_rxcharisk    : std_logic_vector(3 downto 0);
    signal gt6_rxdisperr    : std_logic_vector(3 downto 0);
    signal gt6_rxnotintable : std_logic_vector(3 downto 0);
    signal gt7_rxdata       : std_logic_vector(31 downto 0);
    signal gt7_rxcharisk    : std_logic_vector(3 downto 0);
    signal gt7_rxdisperr    : std_logic_vector(3 downto 0);
    signal gt7_rxnotintable : std_logic_vector(3 downto 0);
    signal rx_reset_done    : std_logic;
    
    ------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
COMPONENT jesd204_phy_0
  PORT (
    cpll_refclk : IN STD_LOGIC;
    drpclk : IN STD_LOGIC;
    tx_reset_gt : IN STD_LOGIC;
    rx_reset_gt : IN STD_LOGIC;
    tx_sys_reset : IN STD_LOGIC;
    rx_sys_reset : IN STD_LOGIC;
    txp_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    txn_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    rxp_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    rxn_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    tx_core_clk : IN STD_LOGIC;
    rx_core_clk : IN STD_LOGIC;
    txoutclk : OUT STD_LOGIC;
    rxoutclk : OUT STD_LOGIC;
    gt_prbssel : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt0_txdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt0_txcharisk : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt1_txdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt1_txcharisk : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt2_txdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt2_txcharisk : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt3_txdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt3_txcharisk : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt4_txdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt4_txcharisk : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt5_txdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt5_txcharisk : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt6_txdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt6_txcharisk : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt7_txdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt7_txcharisk : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    tx_reset_done : OUT STD_LOGIC;
    gt_powergood : OUT STD_LOGIC;
    gt0_rxdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt0_rxcharisk : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt0_rxdisperr : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt0_rxnotintable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt1_rxdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt1_rxcharisk : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt1_rxdisperr : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt1_rxnotintable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt2_rxdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt2_rxcharisk : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt2_rxdisperr : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt2_rxnotintable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt3_rxdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt3_rxcharisk : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt3_rxdisperr : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt3_rxnotintable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt4_rxdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt4_rxcharisk : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt4_rxdisperr : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt4_rxnotintable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt5_rxdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt5_rxcharisk : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt5_rxdisperr : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt5_rxnotintable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt6_rxdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt6_rxcharisk : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt6_rxdisperr : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt6_rxnotintable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt7_rxdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    gt7_rxcharisk : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt7_rxdisperr : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    gt7_rxnotintable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    rx_reset_done : OUT STD_LOGIC;
    rxencommaalign : IN STD_LOGIC 
  );
END COMPONENT;
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

begin

    s_axi_aresetn <= not reset;
    ------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
    u_jesd_tx : entity work.jesd204c_0
    PORT MAP (
        s_axi_aclk => clk,
        s_axi_aresetn => s_axi_aresetn,
        s_axi_awaddr => s_axi_awaddr,
        s_axi_awvalid => s_axi_awvalid,
        s_axi_awready => s_axi_awready,
        s_axi_wdata => s_axi_wdata,
        s_axi_wstrb => s_axi_wstrb,
        s_axi_wvalid => s_axi_wvalid,
        s_axi_wready => s_axi_wready,
        s_axi_bresp => s_axi_bresp,
        s_axi_bvalid => s_axi_bvalid,
        s_axi_bready => s_axi_bready,
        s_axi_araddr => s_axi_araddr,
        s_axi_arvalid => s_axi_arvalid,
        s_axi_arready => s_axi_arready,
        s_axi_rdata => s_axi_rdata,
        s_axi_rresp => s_axi_rresp,
        s_axi_rvalid => s_axi_rvalid,
        s_axi_rready => s_axi_rready,
        tx_core_clk => core_clk,
        tx_core_reset => reset,
        tx_sysref => tx_sysref,
        irq => irq,
        tx_tdata => tx_tdata,
        tx_tready => tx_tready,
        tx_aresetn => tx_aresetn,
        tx_sof => tx_sof,
        tx_somf => tx_somf,
        tx_sync => '0',
        tx_reset_gt => tx_reset_gt,
        tx_reset_done => tx_reset_done,
        gt0_txdata => gt0_txdata,
        gt0_txcharisk => gt0_txcharisk,
        gt0_txheader => gt0_txheader,
        gt1_txdata => gt1_txdata,
        gt1_txcharisk => gt1_txcharisk,
        gt1_txheader => gt1_txheader,
        gt2_txdata => gt2_txdata,
        gt2_txcharisk => gt2_txcharisk,
        gt2_txheader => gt2_txheader,
        gt3_txdata => gt3_txdata,
        gt3_txcharisk => gt3_txcharisk,
        gt3_txheader => gt3_txheader,
        gt4_txdata => gt4_txdata,
        gt4_txcharisk => gt4_txcharisk,
        gt4_txheader => gt4_txheader,
        gt5_txdata => gt5_txdata,
        gt5_txcharisk => gt5_txcharisk,
        gt5_txheader => gt5_txheader,
        gt6_txdata => gt6_txdata,
        gt6_txcharisk => gt6_txcharisk,
        gt6_txheader => gt6_txheader,
        gt7_txdata => gt7_txdata,
        gt7_txcharisk => gt7_txcharisk,
        gt7_txheader => gt7_txheader
    );
    -- INST_TAG_END ------ End INSTANTIATION Template ---------
    
    ------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
    jesd_phy : jesd204_phy_0
    PORT MAP (
        cpll_refclk => tx_core_clk,
        drpclk => clk,
        tx_reset_gt => reset,
        rx_reset_gt => reset,
        tx_sys_reset => reset,
        rx_sys_reset => reset,
        txp_out => txp_out,
        txn_out => txn_out,
        rxp_in => "00000000",
        rxn_in => "00000000",
        tx_core_clk => tx_core_clk,
        rx_core_clk => '0',
        txoutclk => txoutclk,
        rxoutclk => rxoutclk,
        gt_prbssel => "0000",
        gt0_txdata => gt0_txdata(31 downto 0),
        gt0_txcharisk => gt0_txcharisk,
        gt1_txdata => gt1_txdata(31 downto 0),
        gt1_txcharisk => gt1_txcharisk,
        gt2_txdata => gt2_txdata(31 downto 0),
        gt2_txcharisk => gt2_txcharisk,
        gt3_txdata => gt3_txdata(31 downto 0),
        gt3_txcharisk => gt3_txcharisk,
        gt4_txdata => gt4_txdata(31 downto 0),
        gt4_txcharisk => gt4_txcharisk,
        gt5_txdata => gt5_txdata(31 downto 0),
        gt5_txcharisk => gt5_txcharisk,
        gt6_txdata => gt6_txdata(31 downto 0),
        gt6_txcharisk => gt6_txcharisk,
        gt7_txdata => gt7_txdata(31 downto 0),
        gt7_txcharisk => gt7_txcharisk,
        tx_reset_done => tx_reset_done,
        gt_powergood => gt_powergood,
        gt0_rxdata => gt0_rxdata,
        gt0_rxcharisk => gt0_rxcharisk,
        gt0_rxdisperr => gt0_rxdisperr,
        gt0_rxnotintable => gt0_rxnotintable,
        gt1_rxdata => gt1_rxdata,
        gt1_rxcharisk => gt1_rxcharisk,
        gt1_rxdisperr => gt1_rxdisperr,
        gt1_rxnotintable => gt1_rxnotintable,
        gt2_rxdata => gt2_rxdata,
        gt2_rxcharisk => gt2_rxcharisk,
        gt2_rxdisperr => gt2_rxdisperr,
        gt2_rxnotintable => gt2_rxnotintable,
        gt3_rxdata => gt3_rxdata,
        gt3_rxcharisk => gt3_rxcharisk,
        gt3_rxdisperr => gt3_rxdisperr,
        gt3_rxnotintable => gt3_rxnotintable,
        gt4_rxdata => gt4_rxdata,
        gt4_rxcharisk => gt4_rxcharisk,
        gt4_rxdisperr => gt4_rxdisperr,
        gt4_rxnotintable => gt4_rxnotintable,
        gt5_rxdata => gt5_rxdata,
        gt5_rxcharisk => gt5_rxcharisk,
        gt5_rxdisperr => gt5_rxdisperr,
        gt5_rxnotintable => gt5_rxnotintable,
        gt6_rxdata => gt6_rxdata,
        gt6_rxcharisk => gt6_rxcharisk,
        gt6_rxdisperr => gt6_rxdisperr,
        gt6_rxnotintable => gt6_rxnotintable,
        gt7_rxdata => gt7_rxdata,
        gt7_rxcharisk => gt7_rxcharisk,
        gt7_rxdisperr => gt7_rxdisperr,
        gt7_rxnotintable => gt7_rxnotintable,
        rx_reset_done => rx_reset_done,
        rxencommaalign => '0'
    );
    -- INST_TAG_END ------ End INSTANTIATION Template ---------
    

    -- Process for doing 1 axi write, starts from asserting "send_write" outside of this process
    pr_axi_write : process(clk, reset)
    begin
        if reset = '1' then
            s_axi_awvalid   <= '0';
            s_axi_wstrb     <= (others => '1');
            s_axi_wvalid    <= '0';
            s_axi_bready    <= '0';
            write_complete  <= '0';
            write_error     <= '0';
            write_state     <= IDLE;
        elsif rising_edge(clk) then
         case write_state is
            when IDLE =>
                s_axi_awvalid   <= '0';
                s_axi_wstrb     <= (others => '1');
                s_axi_wvalid    <= '0';
                s_axi_bready    <= '0';
                write_complete  <= '0';
                write_error     <= '0';
                
                
                if send_write = '1' then
                    write_state <= ADDR;
                    s_axi_awvalid <= '1';
                    s_axi_wvalid  <= '1';
                else
                    write_state <= IDLE;
                end if;
                
            
            -- Send the write address
            when ADDR => 
                -- wait for awready to be 1.
                if s_axi_awready = '1' then
                    write_state <= DATA;
                    s_axi_awvalid <= '0';
                else
                    write_state <= ADDR;
                end if;
            
            -- Send the write data
            when DATA =>
                -- wait for wready to be 1.
                if s_axi_wready = '1' then
                    write_state <= BRESP;
                    s_axi_wvalid <= '0';
                    s_axi_bready <= '1';
                else
                    write_state <= DATA;
                end if;
            
            -- Wait for response to verify transaction worked.
            when BRESP =>
                -- Wait for bvalid to be 1
                if s_axi_bvalid = '0' then
                    write_state <= BRESP;
                else
                    s_axi_bready <= '0';
                    -- if bresp is 00, transaction was successful
                    if s_axi_bresp = "00" then
                        write_complete <= '1';
                        write_state <= IDLE;
                    -- otherwise try to send the message again.
                    else
                        write_error <= '1';
                        write_state <= ADDR;
                    end if;
                end if;
         end case;
        end if;
    end process;
    
    -- Process for doing 1 axi read, starts from asserting "read_request" outside of this process
    pr_axi_read : process(clk, reset)
    begin
        if reset = '1' then
            s_axi_arvalid   <= '0';
            s_axi_rready    <= '0';
            read_state      <= IDLE;
            read_complete   <= '0';
            read_error      <= '0';
        elsif rising_edge(clk) then
            case read_state is
                when IDLE =>
                    s_axi_arvalid   <= '0';
                    s_axi_rready    <= '0';
                    read_complete   <= '0';
                    read_error      <= '0';
                    
                    if read_request = '1' then
                        read_state <= ADDR;
                    else
                        read_state <= IDLE;
                    end if;
                
                when ADDR =>
                    s_axi_arvalid <= '1';
                    -- wait for arready to be '1'
                    if s_axi_arready = '1' then
                        read_state <= DATA;
                        s_axi_arvalid <= '0';
                    else
                        read_state <= ADDR;
                    end if;
                    
                when DATA =>
                    s_axi_rready <= '1';
                    -- wait for rvalid to be '1'
                    if s_axi_rvalid = '1' then
                        read_data <= s_axi_rdata;
                        rresp_data <= s_axi_rresp;
                        read_state <= RRESP;
                        s_axi_rready <= '0';
                    else
                        read_state <= DATA;
                    end if;
                    
                when RRESP =>
                    if rresp_data /= "00" then
                        read_error <= '1';
                        read_state <= ADDR;
                    else
                        read_complete <= '1';
                        read_state <= IDLE;
                    end if;
            end case;
        end if;
    end process;
    
    pr_testing : process(clk, reset)
    begin
        if reset = '1' then
            read_request <= '0';
            send_write   <= '0';
            wait_cnt     <= (others => '0');
            
            s_axi_araddr <= x"000";
            test_state   <= IDLE;
        elsif rising_edge(clk) then
            case test_state is
                when IDLE =>
                    read_request <= '0';
                    test_state <= WAITING;
                    
                when WAITING =>
                    if wait_cnt /= "1111111111" then
                        wait_cnt <= std_logic_vector(unsigned(wait_cnt) + "0000000001");
                        test_state <= WAITING;
                    else
                        test_state <= READING;
                        read_request <= '1';
                    end if;
                    
                when READING =>
                    read_request <= '0';
                    if read_complete = '0' then
                        test_state <= READING;
                    else
                        if s_axi_araddr = x"03C" then
                            send_write <= '1';
                            s_axi_awaddr <= x"01C";
                            s_axi_wdata <= x"FFFFFFFF";
                            test_state <= WRITE_ONE;
                        else
                            read_request <= '1';
                            s_axi_araddr <= std_logic_vector(unsigned(s_axi_araddr) + x"004");
                            test_state <= READING;
                        end if;
                    end if;
                    
                when WRITE_ONE =>
                    send_write <= '0';
                    if write_complete = '0' then
                        test_state <= WRITE_ONE;
                    else
                        read_request <= '1';
                        s_axi_araddr <= x"000";
                        test_state <= READING2;
                    end if;
                    
                when READING2 =>
                    read_request <= '0';
                    if read_complete = '0' then
                        test_state <= READING2;
                    else
                        if s_axi_araddr = x"03C" then
                            test_state <= DONE;
                        else
                            read_request <= '1';
                            s_axi_araddr <= std_logic_vector(unsigned(s_axi_araddr) + x"004");
                            test_state <= READING2;
                        end if;
                    end if;
                
                when DONE =>
                    test_state <= DONE;
            end case;
        end if;
        
    end process;
    
    --pr_setup : process(clk, reset)
    --begin
    --    if reset = '1' then
    --        read_request <= '0';
    --        send_write <= '0';
    --        
    --        s_axi_araddr    <= x"004";--(others => '0');
    --        s_axi_awaddr    <= x"008";--(others => '0');
    --        s_axi_wdata     <= x"00000001";--(others => '0');
    --        
    --        setup_error <= '0';
    --        setup_state <= IDLE;
    --        
    --    elsif rising_edge(clk) then
    --        case setup_state is
    --            when IDLE =>
    --                -- Write ILA register to enable ILA
    --                s_axi_awaddr <= x"008";
    --                s_axi_wdata <= x"00000001";
    --
    --                s_axi_araddr <= x"004";
    --                read_request <= '1';
    --                setup_state <= RESET_WAIT;
    --                
    --            when RESET_WAIT =>
    --                read_request <= '0';
    --
    --                if read_complete = '0' then
    --                    setup_state <= RESET_WAIT;
    --                else
    --                    if read_data(0) /= '0' then
    --                        read_request <= '1';
    --                        setup_state <= RESET_WAIT;
    --                    else
    --                        send_write <= '1';
    --                        setup_state <= ILA_WRITE;
    --                    end if;
    --                end if;
    --            
    --            -- Write ILA register to enable ILA    
    --            when ILA_WRITE =>
    --                send_write <= '0';
    --                if write_complete = '0' then
    --                    setup_state <= ILA_WRITE;
    --                else
    --                    -- Write Octets per Frame register with F = 4
    --                    setup_state <= OCTETS_WRITE;
    --                    s_axi_awaddr <= x"020";
    --                    s_axi_wdata <= x"00000003";
    --                    send_write <= '1';
    --                end if;
    --            
    --            when OCTETS_WRITE =>
    --                send_write <= '0';
    --                if write_complete = '0' then
    --                    setup_state <= OCTETS_WRITE;
    --                else
    --                    -- Write Frames per Multiframe with K = 32
    --                    setup_state <= FRAME_WRITE;
    --                    s_axi_awaddr <= x"024";
    --                    s_axi_wdata <= x"0000001F";
    --                    send_write <= '1';
    --                end if;
    --            
    --            when FRAME_WRITE =>
    --                send_write <= '0';
    --                if write_complete = '0' then
    --                    setup_state <= FRAME_WRITE;
    --                else
    --                    -- Write reset register to finish configuration.
    --                    setup_state <= RESET_WRITE;
    --                    s_axi_awaddr <= x"004";
    --                    s_axi_wdata <= x"00000001";
    --                    send_write <= '1';
    --                end if;
    --                
    --            when RESET_WRITE =>
    --                send_write <= '0';
    --                if write_complete = '0' then
    --                    setup_state <= RESET_WRITE;
    --                else 
    --                    setup_state <= RESET_READ;
    --                    s_axi_araddr <= x"004";
    --                    read_request <= '1';
    --                end if;
    --            
    --            -- Read back registers to verify configuration was successful.
    --            when RESET_READ =>
    --                
    --                read_request <= '0';
    --
    --                if read_complete = '0' then
    --                    setup_state <= RESET_READ;
    --                else
    --                    read_request <= '1';
    --                    if read_data(0) /= '0' then
    --                        setup_state <= RESET_READ;
    --                    else
    --                        setup_state <= ILA_READ;
    --                        s_axi_araddr <= x"008";
    --                    end if;
    --                end if;
    --                
    --            when ILA_READ =>
    --                read_request <= '0';
    --                if read_complete = '0' then
    --                    setup_state <= ILA_READ;
    --                else
    --                    --if read_data /= x"00000001" then
    --                    --    setup_error <= '1';
    --                    --end if;
    --                    setup_state <= OCTETS_READ;
    --                    s_axi_araddr <= x"020";
    --                    read_request <= '1';
    --                end if;
    --            
    --            when OCTETS_READ =>
    --                read_request <= '0';
    --                if read_complete = '0' then
    --                    setup_state <= OCTETS_READ;
    --                else
    --                    setup_state <= FRAME_READ;
    --                    s_axi_araddr <= x"024";
    --                    read_request <= '1';
    --                end if;
    --            
    --            when FRAME_READ =>
    --                read_request <= '0';
    --                if read_complete = '0' then
    --                    setup_state <= FRAME_READ;
    --                else
    --                    setup_state <= DONE;
    --
    --                end if;    
    --                
    --            when DONE =>
    --                setup_state <= DONE;
    --                
    --        end case;
    --    end if;
    --end process;


end rtl;
