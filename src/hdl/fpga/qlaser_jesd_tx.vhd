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
        tx_tready         : out std_logic
        
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
    signal tx_sysref            : STD_LOGIC;
    signal irq                  : STD_LOGIC;
    signal tx_aresetn           : STD_LOGIC;
    signal tx_sof               : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal tx_somf              : STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal tx_sync              : STD_LOGIC;
    signal tx_reset_gt          : STD_LOGIC;
    signal tx_reset_done        : STD_LOGIC;
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
    signal read_addr            : std_logic_vector(11 downto 0);
    signal read_data            : std_logic_vector(31 downto 0);
    signal read_request         : std_logic;
    signal rresp_data           : std_logic_vector(1 downto 0);
    
    
    signal write_complete       : std_logic;
    signal write_error          : std_logic;
    signal send_write           : std_logic;
    
    signal write_addr : std_logic_vector(11 downto 0);
    signal write_data : std_logic_vector(31 downto 0);
    
    type t_setup_state is (IDLE, ILA_WRITE, ILA_READ, DONE);
    signal setup_state : t_setup_state;
    
    signal setup_error : std_logic;

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
        tx_sync => tx_sync,
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
            tx_reset_done   <= '0';
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
    
    pr_setup : process(clk, reset)
    begin
        if reset = '1' then
            read_request <= '0';
            send_write <= '0';
            
            s_axi_araddr    <= x"008";--(others => '0');
            s_axi_awaddr    <= x"008";--(others => '0');
            s_axi_wdata     <= x"00000001";--(others => '0');
            
            setup_error <= '0';
            setup_state <= IDLE;
            
        elsif rising_edge(clk) then
            case setup_state is
                when IDLE =>
                    s_axi_awaddr <= x"008";
                    s_axi_wdata <= x"00000001";
                    send_write <= '1';
                    setup_state <= ILA_WRITE;
                    
                when ILA_WRITE =>
                    send_write <= '0';
                    if write_complete = '0' then
                        setup_state <= ILA_WRITE;
                    else
                        setup_state <= ILA_READ;
                        read_request <= '1';
                        s_axi_araddr <= x"008";
                    end if;
                    
                when ILA_READ =>
                    read_request <= '0';
                    if read_complete = '0' then
                        setup_state <= ILA_READ;
                    else
                        if read_data /= x"00000001" then
                            setup_error <= '1';
                        end if;
                        setup_state <= DONE;
                    end if;
                
                when DONE =>
                    setup_state <= DONE;
                    
            end case;
        end if;
    end process;


end rtl;
