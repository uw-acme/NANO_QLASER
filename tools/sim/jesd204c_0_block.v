//----------------------------------------------------------------------------
// Title : Block Level
// Project : JESD204C
//----------------------------------------------------------------------------
// File : jesd204c_block.v
//----------------------------------------------------------------------------
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES. 
//
//----------------------------------------------------------------------------

`timescale 1ns / 1ps

(* DowngradeIPIdentifiedWarnings = "yes" *)
module jesd204c_0_block #(
  // AXI port dependant parameters
  parameter  C_BUF_SZ                    = 6,
  parameter  C_C_NOT_B                   = 0,
  parameter  C_IS_TX                     = 1,
  parameter  C_GPI_CNT                   = 5,
  parameter  C_LANES                     = 8,
  parameter  C_ADD_FEC                   = 0,
  parameter  C_ADD_RPAT                  = 0,
  parameter  C_ADD_JSPAT                 = 0,
  parameter  EGW_IS_PARENT_IP            = 0  // Attribute for Versal hard block planner visibility
)(
  // Clk and Reset
  input            ext_reset,
  input            core_clk,

  // TX AXIS interface
  output           tx_aresetn,
  output           tx_tready,
  input    [255:0] tx_tdata,
  output     [3:0] tx_sof,
  output     [3:0] tx_somf,


  // TX GT interface
  // TX Lane 0
  output     [3:0] gt0_txcharisk,
  output     [1:0] gt0_txheader,
  output    [63:0] gt0_txdata,
  
  // TX Lane 1
  output     [3:0] gt1_txcharisk,
  output     [1:0] gt1_txheader,
  output    [63:0] gt1_txdata,
  
  // TX Lane 2
  output     [3:0] gt2_txcharisk,
  output     [1:0] gt2_txheader,
  output    [63:0] gt2_txdata,
  
  // TX Lane 3
  output     [3:0] gt3_txcharisk,
  output     [1:0] gt3_txheader,
  output    [63:0] gt3_txdata,
  
  // TX Lane 4
  output     [3:0] gt4_txcharisk,
  output     [1:0] gt4_txheader,
  output    [63:0] gt4_txdata,
  
  // TX Lane 5
  output     [3:0] gt5_txcharisk,
  output     [1:0] gt5_txheader,
  output    [63:0] gt5_txdata,
  
  // TX Lane 6
  output     [3:0] gt6_txcharisk,
  output     [1:0] gt6_txheader,
  output    [63:0] gt6_txdata,
  
  // TX Lane 7
  output     [3:0] gt7_txcharisk,
  output     [1:0] gt7_txheader,
  output    [63:0] gt7_txdata,
  


  // Reset done from JESD PHY
  input            gt_reset_done,
  // Reset output to drive JES PHY Reset input
  output           reset_gt,

  input            tx_sync,
  input            sysref,


  output           irq,

  // AXI-Lite Control/Status
  input            s_axi_aclk,
  input            s_axi_aresetn,
  input     [11:0] s_axi_awaddr,
  input            s_axi_awvalid,
  output           s_axi_awready,
  input     [31:0] s_axi_wdata,
  input      [3:0] s_axi_wstrb,
  input            s_axi_wvalid,
  output           s_axi_wready,
  output     [1:0] s_axi_bresp,
  output           s_axi_bvalid,
  input            s_axi_bready,
  input     [11:0] s_axi_araddr,
  input            s_axi_arvalid,
  output           s_axi_arready,
  output    [31:0] s_axi_rdata,
  output     [1:0] s_axi_rresp,
  output           s_axi_rvalid,
  input            s_axi_rready
);

  //----Declare top level ports unused in this configuration as wires----
  wire        tx_soemb;

  wire [255:0] tx_cmd_tdata = 0;
  wire        tx_cmd_tvalid = 0;
  wire        tx_cmd_tready;
  wire [255:0] rx_tdata;
  wire        rx_tvalid;
  wire        rx_crc_err;
  wire        rx_emb_err;
  wire        rx_soemb;
  wire  [31:0] rx_frm_err;
  wire  [3:0] rx_sof;
  wire  [3:0] rx_somf;
  wire [255:0] rx_cmd_tdata;
  wire        rx_cmd_tvalid;
  wire  [7:0] rx_cmd_tuser;
  wire  [31:0] rxcharisk =0;
  wire  [31:0] rxdisperr =0;
  wire  [31:0] rxnotintable =0;
  wire        encommaalign;
  wire  [15:0] rxhead =0;
  wire  [7:0] rxblock_sync =0;
  wire  [7:0] rxmisalign =0;
  wire [511:0] rxdata =0;
  wire        rx_sync;


  //------------- Wire Declarations -------------
  wire  [31:0] txcharisk;
  wire  [15:0] txhead;
  wire [511:0] txdata;



  wire        timeout_enable;
  wire [11:0] timeout_value;
  wire        reset;
  wire        ctrl_reset;
  wire        stat_reset;
  wire        ctrl_gt_dp_reset_sel;
  wire        stat_reset_ext;
  wire        stat_reset_ctrl;
  wire        stat_reset_pwrgood;
  wire        stat_reset_gtbzy;
  wire  [7:0] stat_reset_pmarstbzy;
  wire  [7:0] stat_reset_mstrstbzy;


  /////////////////////////////////////////////////////////////////////////////
  // AXI Regif wires
  // CTRL interface All Common
  wire  [7:0] ctrl_lane_ena;
  wire  [2:0] ctrl_test_mode; //testmode
  wire  [1:0] ctrl_sub_class;
  wire        ctrl_sysr_alw;
  wire        ctrl_sysr_req;
  wire  [2:0] ctrl_sysr_tol;
  wire  [7:0] ctrl_sysr_del;

  // CTRL interface TX Common
  wire  [C_LANES-1:0] ctrl_tx_gtpolarity;
  wire  [(C_LANES*2)-1:0] ctrl_tx_gtpd;
  wire  [C_LANES-1:0] ctrl_tx_gtelecidle;
  wire  [C_LANES-1:0] ctrl_tx_gtinhibit;
  wire  [(C_LANES*5)-1:0] ctrl_tx_gtdiffctrl;
  wire  [(C_LANES*5)-1:0] ctrl_tx_gtpostcursor;
  wire  [(C_LANES*5)-1:0] ctrl_tx_gtprecursor;

  // CTRL interface RX Common
  wire  [C_LANES-1:0] ctrl_rx_gtpolarity;
  wire  [(C_LANES*2)-1:0] ctrl_rx_gtpd;
  wire  [9:0] ctrl_rx_buf_adv;

  // CTRL interface 8b10b Common
  wire  [7:0] ctrl_opf;
  wire  [4:0] ctrl_fpmf;
  wire        ctrl_scr;
  wire        ctrl_ila_req;

  // CTRL interface 64b66b Common
  wire  [7:0] ctrl_mb_in_emb;    //Number of MB in EMB
  wire  [1:0] ctrl_meta_mode;    //meta word mode
  wire        ctrl_en_data;      //Enable dataflow
  wire        ctrl_en_cmd;       //Enable cmd flow
  wire        core_ctrl_en_data; //Enable dataflow (synchronized to core_clk)
  wire        core_ctrl_en_cmd;  //Enable cmd flow (synchronized to core_clk)

  // CTRL interface 8b10b TX
  wire       ctrl_tx_sync_force;
  wire       core_ctrl_tx_sync_force;
  wire [7:0] ctrl_tx_ila_mf;
  wire       ctrl_tx_ila_cs_all;
  wire [7:0] ctrl_tx_ila_did;
  wire [3:0] ctrl_tx_ila_bid;
  wire [7:0] ctrl_tx_ila_m;
  wire [1:0] ctrl_tx_ila_cs;
  wire [4:0] ctrl_tx_ila_n;
  wire [4:0] ctrl_tx_ila_np;
  wire [4:0] ctrl_tx_ila_s;
  wire       ctrl_tx_ila_hd;
  wire [7:0] ctrl_tx_ila_res1;
  wire [7:0] ctrl_tx_ila_res2;
  wire [4:0] ctrl_tx_ila_cf;
  wire [3:0] ctrl_tx_ila_adjcnt;
  wire       ctrl_tx_ila_adjdir;
  wire       ctrl_tx_ila_phadj;
  wire [(C_LANES*5)-1:0] ctrl_tx_ila_lid;      // Lanes IDs for each lane
  wire [(C_LANES*5)-1:0] ctrl_tx_ila_lid_pdef; // Default values for Lanes IDs for each lane
  wire [(C_LANES*5)-1:0] ctrl_tx_ila_nll;      // Number of lanes per link for each lane
  wire [(C_LANES*5)-1:0] ctrl_tx_ila_nll_pdef; // Default values for number of lanes per link for each lane

  // CTRL interface 8b10b RX
  wire       ctrl_rx_err_rep_ena;
  wire       ctrl_rx_err_cnt_ena;

  // CTRL interface 64b66b TX
  //NA

  // CTRL interface 64b66b RX
  wire  [2:0] ctrl_rx_mblock_th;

  ////////////////////////////////////
  // STAT interface All Common
  wire        stat_irq_pend;
  wire        stat_sysr_cap;
  wire        stat_sysr_err;
  wire        axi_stat_err_clr;
  wire        core_stat_err_clr;
  // STAT interface TX Common
  //NA
  // STAT interface RX Common
  wire        stat_rx_over_err;
  wire [79:0] stat_rx_buf_lvl;

  // STAT interface 8b10b Common
  wire        stat_sync;       // in_sync!

  // STAT interface 64b66b Common
  //NA
  // STAT interface 8b10b TX
  // STAT interface 8b10b RX
  wire        stat_rx_cgs;
  wire        stat_rx_started;
  wire        stat_rx_align_err;

  wire [31:0] stat_rx_err;
  wire        axi_stat_rx_err_clr;
  wire        core_stat_rx_err_clr;
  wire [31:0] stat_rx_deb;
  wire        axi_stat_rx_deb_clr;
  wire        core_stat_rx_deb_clr;
  wire [(C_LANES*32)-1:0] stat_link_err_cnt;
  wire  [7:0] axi_stat_link_err_cnt_clr;
  wire  [7:0] core_stat_link_err_cnt_clr;
  wire [(C_LANES*32)-1:0] stat_test_err_cnt;
  wire  [7:0] axi_stat_test_err_cnt_clr;
  wire  [7:0] core_stat_test_err_cnt_clr;
  wire [(C_LANES*32)-1:0] stat_test_ila_cnt;
  wire  [7:0] axi_stat_test_ila_cnt_clr;
  wire  [7:0] core_stat_test_ila_cnt_clr;
  wire [(C_LANES*32)-1:0] stat_test_mf_cnt;
  wire  [7:0] axi_stat_test_mf_cnt_clr;
  wire  [7:0] core_stat_test_mf_cnt_clr;
  wire [(C_LANES*3)-1:0] stat_rx_ila_jesdv;
  wire [(C_LANES*3)-1:0] stat_rx_ila_subc;
  wire [(C_LANES*8)-1:0] stat_rx_ila_f;
  wire [(C_LANES*5)-1:0] stat_rx_ila_k;
  wire     [C_LANES-1:0] stat_rx_ila_scr;
  wire [(C_LANES*5)-1:0] stat_rx_ila_l;
  wire [(C_LANES*8)-1:0] stat_rx_ila_did;
  wire [(C_LANES*4)-1:0] stat_rx_ila_bid;
  wire [(C_LANES*8)-1:0] stat_rx_ila_m;
  wire [(C_LANES*2)-1:0] stat_rx_ila_cs;
  wire [(C_LANES*5)-1:0] stat_rx_ila_n;
  wire [(C_LANES*5)-1:0] stat_rx_ila_np;
  wire [(C_LANES*5)-1:0] stat_rx_ila_s;
  wire     [C_LANES-1:0] stat_rx_ila_hd;
  wire [(C_LANES*8)-1:0] stat_rx_ila_res1;
  wire [(C_LANES*8)-1:0] stat_rx_ila_res2;
  wire [(C_LANES*5)-1:0] stat_rx_ila_cf;
  wire [(C_LANES*4)-1:0] stat_rx_ila_adjcnt;
  wire [C_LANES-1:0] stat_rx_ila_adjdir;
  wire [C_LANES-1:0] stat_rx_ila_phadj;
  wire [(C_LANES*5)-1:0] stat_rx_ila_lid;
  wire [(C_LANES*8)-1:0] stat_rx_ila_fchk;

  // STAT interface 64b66b TX

  // STAT interface 64b66b RX
  wire        stat_rx_sh_lock;
  wire        stat_rx_emb_lock;
  wire  [7:0] stat_rx_sh_lock_dbg;
  wire  [7:0] stat_rx_emb_lock_dbg;
  wire  [7:0] axi_stat_rx_err_cnt0_clr;
  wire  [7:0] core_stat_rx_err_cnt0_clr;
  wire [255:0] stat_rx_err_cnt0;
  wire  [7:0] axi_stat_rx_err_cnt1_clr;
  wire  [7:0] core_stat_rx_err_cnt1_clr;
  wire [255:0] stat_rx_err_cnt1;

  //////////////////////////////////////
  // IRQ CTRL interface All Common
  wire        axi_ctrl_irq_clr;
  wire        core_ctrl_irq_clr;
  wire        ctrl_en_irq;
  wire        ctrl_en_sysr_cap_irq;
  wire        ctrl_en_sysr_err_irq;
  // IRQ CTRL interface TX Common
  // IRQ CTRL interface RX Common
  wire        ctrl_rx_en_over_err_irq;
  // IRQ CTRL interface 8b10b Common
  wire        ctrl_en_sync_irq;
  wire        ctrl_en_resync_irq;
  wire        ctrl_en_started_irq;
  // IRQ CTRL interface 64b66b Common
  // IRQ CTRL interface 8b10b TX
  // IRQ CTRL interface 8b10b RX
  // IRQ CTRL interface 64b66b TX
  // IRQ CTRL interface 64b66b RX
  wire        ctrl_rx_en_sh_lock_irq;
  wire        ctrl_rx_en_emb_lock_irq;
  wire        ctrl_rx_en_block_sync_err_irq;
  wire        ctrl_rx_en_emb_align_err_irq;
  wire        ctrl_rx_en_crc_err_irq;
  wire        ctrl_rx_en_fec_err_irq;

  //////////////////////////////////////////
  // IRQ STAT interface All Common
  wire        stat_sysr_cap_irq;
  wire        stat_sysr_err_irq;
  // IRQ STAT interface TX Common
  // IRQ STAT interface RX Common
  wire        stat_rx_over_err_irq;
  // IRQ STAT interface 8b10b Common
  wire        stat_sync_irq;
  wire        stat_resync_irq;
  wire        stat_started_irq;
  // IRQ STAT interface 64b66b Common
  // IRQ STAT interface 8b10b TX
  // IRQ STAT interface 8b10b RX
  // IRQ STAT interface 64b66b TX
  // IRQ STAT interface 64b66b RX
  wire        stat_rx_sh_lock_irq;
  wire        stat_rx_emb_lock_irq;
  wire        stat_rx_block_sync_err_irq;
  wire        stat_rx_emb_align_err_irq;
  wire        stat_rx_crc_err_irq;
  wire        stat_rx_fec_err_irq;

  wire        ext_reset_sync_core_clk;
  wire        ctrl_reset_sync_core_clk;
  wire        ext_reset_sync_axi_clk;
  wire        gt_reset_done_sync_core_clk;

  wire        reset_gt_i;

  wire        reset_i;

  wire        s_axi_aresetn_inv;
  
  

//------------- AXI register interface --------
jesd204c_0_jesd204c_regif jesd204c_0_regif_c (
  .timeout_enable                 (timeout_enable                ),
  .timeout_value                  (timeout_value                 ),
  .timeout_enable_in              (timeout_enable                ),
  .timeout_value_in               (timeout_value                 ),
  .ctrl_reset                     (ctrl_reset                    ),
  .stat_reset                     (stat_reset                    ),
  .ctrl_gt_dp_reset_sel           (ctrl_gt_dp_reset_sel          ),
  .stat_reset_ext                 (stat_reset_ext                ),
  .stat_reset_ctrl                (stat_reset_ctrl               ),
  .stat_reset_pwrgood             (stat_reset_pwrgood            ),
  .stat_reset_gtbzy               (stat_reset_gtbzy              ),
  .stat_reset_pmarstbzy           (stat_reset_pmarstbzy          ),
  .stat_reset_mstrstbzy           (stat_reset_mstrstbzy          ),

  // CTRL interface All Common
  .ctrl_lane_ena                  (ctrl_lane_ena                 ),
  .ctrl_test_mode                 (ctrl_test_mode                ),
  .ctrl_sub_class                 (ctrl_sub_class                ),
  .ctrl_sysr_alw                  (ctrl_sysr_alw                 ),
  .ctrl_sysr_req                  (ctrl_sysr_req                 ),
  .ctrl_sysr_tol                  (ctrl_sysr_tol                 ),
  .ctrl_sysr_del                  (ctrl_sysr_del                 ),

  // CTRL interface TX Common
  .ctrl_tx_loopback               ( ),

  .ctrl_tx_gtpolarity              (ctrl_tx_gtpolarity           ),
  .ctrl_tx_gtpd                    (ctrl_tx_gtpd                 ),
  .ctrl_tx_gtelecidle              (ctrl_tx_gtelecidle           ),
  .ctrl_tx_gtinhibit               (ctrl_tx_gtinhibit            ),
  .ctrl_tx_gtdiffctrl              (ctrl_tx_gtdiffctrl           ),
  .ctrl_tx_gtpostcursor            (ctrl_tx_gtpostcursor         ),
  .ctrl_tx_gtprecursor             (ctrl_tx_gtprecursor          ),

  // CTRL interface RX Common
  .ctrl_rx_buf_adv                 (ctrl_rx_buf_adv              ),
  .ctrl_rx_gtpolarity              (ctrl_rx_gtpolarity           ),
  .ctrl_rx_gtpd                    (ctrl_rx_gtpd                 ),

  // CTRL interface 8b10b Common
  .ctrl_opf                       (ctrl_opf                      ),
  .ctrl_fpmf                      (ctrl_fpmf                     ),
  .ctrl_scr                       (ctrl_scr                      ),
  .ctrl_ila_req                   (ctrl_ila_req                  ),

  // CTRL interface 64b66b Common
  .ctrl_mb_in_emb                 (ctrl_mb_in_emb                ),
  .ctrl_meta_mode                 (ctrl_meta_mode                ),
  .ctrl_en_data                   (ctrl_en_data                  ),
  .ctrl_en_cmd                    (ctrl_en_cmd                   ),

  // CTRL interface 8b10b TX
  .ctrl_tx_sync_force             (ctrl_tx_sync_force            ),
  .ctrl_tx_ila_mf                 (ctrl_tx_ila_mf                ),
  .ctrl_tx_ila_cs_all             (ctrl_tx_ila_cs_all            ),
  .ctrl_tx_ila_did                (ctrl_tx_ila_did               ),
  .ctrl_tx_ila_bid                (ctrl_tx_ila_bid               ),
  .ctrl_tx_ila_m                  (ctrl_tx_ila_m                 ),
  .ctrl_tx_ila_cs                 (ctrl_tx_ila_cs                ),
  .ctrl_tx_ila_n                  (ctrl_tx_ila_n                 ),
  .ctrl_tx_ila_np                 (ctrl_tx_ila_np                ),
  .ctrl_tx_ila_s                  (ctrl_tx_ila_s                 ),
  .ctrl_tx_ila_hd                 (ctrl_tx_ila_hd                ),
  .ctrl_tx_ila_res1               (ctrl_tx_ila_res1              ),
  .ctrl_tx_ila_res2               (ctrl_tx_ila_res2              ),
  .ctrl_tx_ila_cf                 (ctrl_tx_ila_cf                ),
  .ctrl_tx_ila_adjcnt             (ctrl_tx_ila_adjcnt            ),
  .ctrl_tx_ila_adjdir             (ctrl_tx_ila_adjdir            ),
  .ctrl_tx_ila_phadj              (ctrl_tx_ila_phadj             ),
  .ctrl_tx_ila_lid                (ctrl_tx_ila_lid               ),
  .ctrl_tx_ila_lid_pdef           (ctrl_tx_ila_lid_pdef          ),
  .ctrl_tx_ila_nll                (ctrl_tx_ila_nll               ),
  .ctrl_tx_ila_nll_pdef           (ctrl_tx_ila_nll_pdef          ),

  // CTRL interface 8b10b RX
  .ctrl_rx_err_rep_ena            (ctrl_rx_err_rep_ena           ),
  .ctrl_rx_err_cnt_ena            (ctrl_rx_err_cnt_ena           ),

  // CTRL interface 64b66b TX
  // CTRL interface 64b66b RX
  .ctrl_rx_mblock_th              (ctrl_rx_mblock_th             ),


  //////////////////////////////////////////
  // STAT interface All Common
  .stat_irq_pend                  (stat_irq_pend                 ),
  .stat_sysr_cap                  (stat_sysr_cap                 ),
  .stat_sysr_err                  (stat_sysr_err                 ),
  .stat_sysr_err_pls_h            (axi_stat_err_clr              ),
  // STAT interface TX Common
  // STAT interface RX Common
  .stat_rx_over_err               (stat_rx_over_err              ),
  .stat_rx_buf_lvl                (stat_rx_buf_lvl               ),
  // STAT interface 8b10b Common
  .stat_sync                      (stat_sync                     ),
  // STAT interface 64b66b Common
  // STAT interface 8b10b TX
  // STAT interface 8b10b RX
  .stat_rx_cgs                    (stat_rx_cgs                   ),
  .stat_rx_started                (stat_rx_started               ),
  .stat_rx_align_err              (stat_rx_align_err             ),
  .stat_rx_err                    (stat_rx_err                   ),
  .stat_rx_err_pls_h              (axi_stat_rx_err_clr           ),
  .stat_rx_deb                    (stat_rx_deb                   ),
  .stat_rx_deb_pls_h              (axi_stat_rx_deb_clr           ),
  .stat_link_err_cnt              (stat_link_err_cnt             ),
  .stat_link_err_cnt_pls_h        (axi_stat_link_err_cnt_clr     ),
  .stat_test_err_cnt              (stat_test_err_cnt             ),
  .stat_test_err_cnt_pls_h        (axi_stat_test_err_cnt_clr     ),
  .stat_test_ila_cnt              (stat_test_ila_cnt             ),
  .stat_test_ila_cnt_pls_h        (axi_stat_test_ila_cnt_clr     ),
  .stat_test_mf_cnt               (stat_test_mf_cnt              ),
  .stat_test_mf_cnt_pls_h         (axi_stat_test_mf_cnt_clr      ),
  .stat_rx_ila_jesdv              (stat_rx_ila_jesdv             ),
  .stat_rx_ila_subc               (stat_rx_ila_subc              ),
  .stat_rx_ila_f                  (stat_rx_ila_f                 ),
  .stat_rx_ila_k                  (stat_rx_ila_k                 ),
  .stat_rx_ila_scr                (stat_rx_ila_scr               ),
  .stat_rx_ila_l                  (stat_rx_ila_l                 ),
  .stat_rx_ila_did                (stat_rx_ila_did               ),
  .stat_rx_ila_bid                (stat_rx_ila_bid               ),
  .stat_rx_ila_m                  (stat_rx_ila_m                 ),
  .stat_rx_ila_cs                 (stat_rx_ila_cs                ),
  .stat_rx_ila_n                  (stat_rx_ila_n                 ),
  .stat_rx_ila_np                 (stat_rx_ila_np                ),
  .stat_rx_ila_s                  (stat_rx_ila_s                 ),
  .stat_rx_ila_hd                 (stat_rx_ila_hd                ),
  .stat_rx_ila_res1               (stat_rx_ila_res1              ),
  .stat_rx_ila_res2               (stat_rx_ila_res2              ),
  .stat_rx_ila_cf                 (stat_rx_ila_cf                ),
  .stat_rx_ila_adjcnt             (stat_rx_ila_adjcnt            ),
  .stat_rx_ila_adjdir             (stat_rx_ila_adjdir            ),
  .stat_rx_ila_phadj              (stat_rx_ila_phadj             ),
  .stat_rx_ila_lid                (stat_rx_ila_lid               ),
  .stat_rx_ila_fchk               (stat_rx_ila_fchk              ),
  // STAT interface 64b66b TX
  // STAT interface 64b66b RX
  .stat_rx_sh_lock                (stat_rx_sh_lock               ),
  .stat_rx_emb_lock               (stat_rx_emb_lock              ),
  .stat_rx_sh_lock_dbg            (stat_rx_sh_lock_dbg           ),
  .stat_rx_emb_lock_dbg           (stat_rx_emb_lock_dbg          ),
  .stat_rx_err_cnt0_pls_h         (axi_stat_rx_err_cnt0_clr      ),
  .stat_rx_err_cnt0               (stat_rx_err_cnt0              ),
  .stat_rx_err_cnt1_pls_h         (axi_stat_rx_err_cnt1_clr      ),
  .stat_rx_err_cnt1               (stat_rx_err_cnt1              ),

  // IRQ CTRL interface All Common
  .stat_sysr_cap_irq_pls_h        (axi_ctrl_irq_clr              ),
  .ctrl_en_irq                    (ctrl_en_irq                   ),
  .ctrl_en_sysr_cap_irq           (ctrl_en_sysr_cap_irq          ),
  .ctrl_en_sysr_err_irq           (ctrl_en_sysr_err_irq          ),

  // IRQ CTRL interface TX Common
  // IRQ CTRL interface RX Common
  .ctrl_rx_en_over_err_irq        (ctrl_rx_en_over_err_irq       ),
  // IRQ CTRL interface 8b10b Common
  .ctrl_en_sync_irq               (ctrl_en_sync_irq              ),
  .ctrl_en_resync_irq             (ctrl_en_resync_irq            ),
  .ctrl_en_started_irq            (ctrl_en_started_irq           ),

  // IRQ CTRL interface 64b66b Common
  // IRQ CTRL interface 8b10b TX
  // IRQ CTRL interface 8b10b RX
  // IRQ CTRL interface 64b66b TX
  // IRQ CTRL interface 64b66b RX
  .ctrl_rx_en_sh_lock_irq         (ctrl_rx_en_sh_lock_irq        ),
  .ctrl_rx_en_emb_lock_irq        (ctrl_rx_en_emb_lock_irq       ),
  .ctrl_rx_en_block_sync_err_irq  (ctrl_rx_en_block_sync_err_irq ),
  .ctrl_rx_en_emb_align_err_irq   (ctrl_rx_en_emb_align_err_irq  ),
  .ctrl_rx_en_crc_err_irq         (ctrl_rx_en_crc_err_irq        ),
  .ctrl_rx_en_fec_err_irq         (ctrl_rx_en_fec_err_irq        ),

  // IRQ STAT interface All Common
  .stat_sysr_cap_irq              (stat_sysr_cap_irq             ),
  .stat_sysr_err_irq              (stat_sysr_err_irq             ),
  // IRQ STAT interface TX Common
  // IRQ STAT interface RX Common
  .stat_rx_over_err_irq           (stat_rx_over_err_irq          ),
  // IRQ STAT interface 8b10b Common
  .stat_sync_irq                  (stat_sync_irq                 ),
  .stat_resync_irq                (stat_resync_irq               ),
  .stat_started_irq               (stat_started_irq              ),

  // IRQ STAT interface 64b66b Common
  // IRQ STAT interface 8b10b TX
  // IRQ STAT interface 8b10b RX
  // IRQ STAT interface 64b66b TX
  // IRQ STAT interface 64b66b RX
  .stat_rx_sh_lock_irq            (stat_rx_sh_lock_irq           ),
  .stat_rx_emb_lock_irq           (stat_rx_emb_lock_irq          ),
  .stat_rx_block_sync_err_irq     (stat_rx_block_sync_err_irq    ),
  .stat_rx_emb_align_err_irq      (stat_rx_emb_align_err_irq     ),
  .stat_rx_crc_err_irq            (stat_rx_crc_err_irq           ),
  .stat_rx_fec_err_irq            (stat_rx_fec_err_irq           ),

  .s_axi_aclk                     (s_axi_aclk                    ),
  .s_axi_aresetn                  (s_axi_aresetn                 ),
  .s_axi_awaddr                   (s_axi_awaddr                  ),
  .s_axi_awvalid                  (s_axi_awvalid                 ),
  .s_axi_awready                  (s_axi_awready                 ),
  .s_axi_wdata                    (s_axi_wdata                   ),
  .s_axi_wvalid                   (s_axi_wvalid                  ),
  .s_axi_wready                   (s_axi_wready                  ),
  .s_axi_bresp                    (s_axi_bresp                   ),
  .s_axi_bvalid                   (s_axi_bvalid                  ),
  .s_axi_bready                   (s_axi_bready                  ),
  .s_axi_araddr                   (s_axi_araddr                  ),
  .s_axi_arvalid                  (s_axi_arvalid                 ),
  .s_axi_arready                  (s_axi_arready                 ),
  .s_axi_rdata                    (s_axi_rdata                   ),
  .s_axi_rresp                    (s_axi_rresp                   ),
  .s_axi_rvalid                   (s_axi_rvalid                  ),
  .s_axi_rready                   (s_axi_rready                  )
);



  //Synchronize gt reset done to core clock domain
  jesd204c_0_sync_block #(
    .TYPE_RST_NOT_DATA (1'b1),
    .RST_ACTIVE_HIGH   (1'b0)
  ) sync_gt_resetdone
  (
    .clk             (core_clk),
    .data_in         (gt_reset_done),
    .data_out        (gt_reset_done_sync_core_clk)
  );

  //Synchronize core external reset to axi clock domain
  jesd204c_0_sync_block #(
    .TYPE_RST_NOT_DATA (1'b1),
    .RST_ACTIVE_HIGH   (1'b1)
  ) sync_core_rst_axi
  (
    .clk             (s_axi_aclk),
    .data_in         (ext_reset),
    .data_out        (ext_reset_sync_axi_clk)
  );
  //Synchronize core reset to core clock domain
  jesd204c_0_sync_block #(
    .TYPE_RST_NOT_DATA (1'b1),
    .RST_ACTIVE_HIGH   (1'b1)
  ) sync_core_rst
  (
    .clk             (core_clk),
    .data_in         (ext_reset),
    .data_out        (ext_reset_sync_core_clk)
  );

  //Synchronize control reset to core clock domain
  jesd204c_0_sync_block #(
    .TYPE_RST_NOT_DATA (1'b1),
    .RST_ACTIVE_HIGH   (1'b1)
  ) sync_ctrl_rst
  (
    .clk             (core_clk),
    .data_in         (ctrl_reset),
    .data_out        (ctrl_reset_sync_core_clk)
  );


  assign reset_i = ext_reset_sync_core_clk | !gt_reset_done_sync_core_clk | ctrl_reset_sync_core_clk;
  assign reset_gt_i = ext_reset_sync_axi_clk | ctrl_reset;
  assign stat_reset  = ext_reset_sync_core_clk | !gt_reset_done_sync_core_clk | ctrl_reset;
  //Reset debug bits
  assign stat_reset_ext       = ext_reset;
  assign stat_reset_ctrl      = ctrl_reset;
  //HTW_FIX stat_reg is power not good!
  assign stat_reset_pwrgood   = 1'b0;
  assign stat_reset_gtbzy     = !gt_reset_done_sync_core_clk;
  assign stat_reset_pmarstbzy = 8'b0;
  assign stat_reset_mstrstbzy = 8'b0;

  assign tx_aresetn = !reset;

  //This will make sure reset_gt is asserted asynchronously but deasserted synchronously to s_axis_aclk. This has been done to prevent
  //any following synchronizers from being driven by combinatorial logic, thus avoiding CDC-10. It's important to sync to a free running
  //clock not the core_clk in the case where it is sourced from txoutclk or rxoutclk.
  xpm_cdc_async_rst #(
    .DEST_SYNC_FF    (5),
    .RST_ACTIVE_HIGH (1)
  ) xpm_cdc_reset_gt (
    .src_arst  (reset_gt_i),
    .dest_clk  (s_axi_aclk),
    .dest_arst (reset_gt)
  );

  //This will make sure reset is asserted asynchronously but deasserted synchronously to core_clk. This has been done to prevent
  //any following synchronizers from being driven by combinatorial logic, thus avoiding CDC-10.
  xpm_cdc_async_rst #(
    .DEST_SYNC_FF    (5),
    .RST_ACTIVE_HIGH (1)
  ) xpm_cdc_reset (
    .src_arst  (reset_i),
    .dest_clk  (core_clk),
    .dest_arst (reset)
  );


  //
  jesd204c_v4_2_8_top #(
    .C_C_NOT_B                      (C_C_NOT_B),
    .C_IS_TX                        (C_IS_TX),
    .C_ADD_RPAT                     (C_ADD_RPAT),
    .C_ADD_JSPAT                    (C_ADD_JSPAT),
    .C_ADD_FEC                      (C_ADD_FEC),
    .C_LANES                        (C_LANES),
    .C_GPI_CNT                      (C_GPI_CNT),
    .C_BUF_SZ                       (C_BUF_SZ)
  ) jesd204c_0_top_c (
    // Clk and Reset
    .clk                            (core_clk                      ),
    .srst                           (reset                         ),

    // TX AXIS interface
    .tx_tdata                       (tx_tdata                      ),
    .tx_tready                      (tx_tready                     ),
    .tx_soemb                       (tx_soemb                      ),
    .tx_sof                         (tx_sof                        ),
    .tx_somf                        (tx_somf                       ),

    // TX AXIS command interface
    .tx_cmd_tdata                   (tx_cmd_tdata                  ),
    .tx_cmd_tvalid                  (tx_cmd_tvalid                 ),
    .tx_cmd_tready                  (tx_cmd_tready                 ),

    // TX GT interface
    .txcharisk                      (txcharisk                     ),
    .txhead                         (txhead                        ),
    .txdata                         (txdata                        ),

    // RX AXIS interfaces
    .rx_tdata                       (rx_tdata                      ),
    .rx_tvalid                      (rx_tvalid                     ),
    .rx_soemb                       (rx_soemb                      ),
    .rx_crc_err                     (rx_crc_err                    ),
    .rx_emb_err                     (rx_emb_err                    ),
    .rx_frm_err                     (rx_frm_err                    ),
    .rx_sof                         (rx_sof                        ),
    .rx_somf                        (rx_somf                       ),

    .rx_cmd_tdata                   (rx_cmd_tdata                  ),
    .rx_cmd_tvalid                  (rx_cmd_tvalid                 ),
    .rx_cmd_tready                  (rx_cmd_tready                 ),
    .rx_cmd_tuser                   (rx_cmd_tuser                  ),

    // RX GT interface
    .rxcharisk                      (rxcharisk                     ),
    .rxdisperr                      (rxdisperr                     ),
    .rxnotintable                   (rxnotintable                  ),
    .encommaalign                   (encommaalign                  ),
    .rxhead                         (rxhead                        ),
    .rxblock_sync                   (rxblock_sync                  ),
    .rxmisalign                     (rxmisalign                    ),
    .rxdata                         (rxdata                        ),

    .tx_sync                        (tx_sync                       ),
    .rx_sync                        (rx_sync                       ),
    .sysref                         (sysref                        ),
    .irq                            (irq                           ),

    //Register interface ports

    // CTRL interface All Common
    .ctrl_lane_ena                  (ctrl_lane_ena                 ),
    .ctrl_test_mode                 (ctrl_test_mode                ),
    .ctrl_sub_class                 (ctrl_sub_class                ),
    .ctrl_sysr_alw                  (ctrl_sysr_alw                 ),
    .ctrl_sysr_req                  (ctrl_sysr_req                 ),
    .ctrl_sysr_tol                  (ctrl_sysr_tol                 ),
    .ctrl_sysr_del                  (ctrl_sysr_del                 ),
    // CTRL interface TX Common
    //NA

    // CTRL interface RX Common
    .ctrl_rx_buf_adv                (ctrl_rx_buf_adv               ),

    // CTRL interface 8b10b Common
    .ctrl_opf                       (ctrl_opf                      ),
    .ctrl_fpmf                      (ctrl_fpmf                     ),
    .ctrl_scr                       (ctrl_scr                      ),
    .ctrl_ila_req                   (ctrl_ila_req                  ),

    // CTRL interface 64b66b Common
    .ctrl_mb_in_emb                 (ctrl_mb_in_emb                ),
    .ctrl_meta_mode                 (ctrl_meta_mode                ),
    .ctrl_en_data                   (core_ctrl_en_data             ),
    .ctrl_en_cmd                    (core_ctrl_en_cmd              ),
    // CTRL interface 8b10b TX
    .ctrl_tx_sync_force             (core_ctrl_tx_sync_force       ),
    .ctrl_tx_ila_mf                 (ctrl_tx_ila_mf                ),
    .ctrl_tx_ila_cs_all             (ctrl_tx_ila_cs_all            ),
    .ctrl_tx_ila_did                (ctrl_tx_ila_did               ),
    .ctrl_tx_ila_bid                (ctrl_tx_ila_bid               ),
    .ctrl_tx_ila_m                  (ctrl_tx_ila_m                 ),
    .ctrl_tx_ila_cs                 (ctrl_tx_ila_cs                ),
    .ctrl_tx_ila_n                  (ctrl_tx_ila_n                 ),
    .ctrl_tx_ila_np                 (ctrl_tx_ila_np                ),
    .ctrl_tx_ila_s                  (ctrl_tx_ila_s                 ),
    .ctrl_tx_ila_hd                 (ctrl_tx_ila_hd                ),
    .ctrl_tx_ila_res1               (ctrl_tx_ila_res1              ),
    .ctrl_tx_ila_res2               (ctrl_tx_ila_res2              ),
    .ctrl_tx_ila_cf                 (ctrl_tx_ila_cf                ),
    .ctrl_tx_ila_adjcnt             (ctrl_tx_ila_adjcnt            ),
    .ctrl_tx_ila_adjdir             (ctrl_tx_ila_adjdir            ),
    .ctrl_tx_ila_phadj              (ctrl_tx_ila_phadj             ),
    .ctrl_tx_ila_lid                (ctrl_tx_ila_lid               ),
    .ctrl_tx_ila_nll                (ctrl_tx_ila_nll               ),
    // CTRL interface 8b10b RX
    .ctrl_rx_err_rep_ena            (ctrl_rx_err_rep_ena           ),
    .ctrl_rx_err_cnt_ena            (ctrl_rx_err_cnt_ena           ),

    // CTRL interface 64b66b TX
    // CTRL interface 64b66b RX
    .ctrl_rx_mblock_th              (ctrl_rx_mblock_th             ),

    // STAT interface All Common
    .stat_irq_pend                  (stat_irq_pend                 ),
    .stat_sysr_cap                  (stat_sysr_cap                 ),
    .stat_sysr_err                  (stat_sysr_err                 ),
    .stat_err_clr                   (core_stat_err_clr             ),

    // STAT interface TX Common
    // STAT interface RX Common
    .stat_rx_over_err               (stat_rx_over_err              ),
    .stat_rx_buf_lvl                (stat_rx_buf_lvl               ),

    // STAT interface 8b10b Common
    .stat_sync                      (stat_sync                     ),

    // STAT interface 64b66b Common
    // STAT interface 8b10b TX
    // STAT interface 8b10b RX
    .stat_rx_cgs                    (stat_rx_cgs                   ),
    .stat_rx_started                (stat_rx_started               ),
    .stat_rx_align_err              (stat_rx_align_err             ),
    .stat_rx_err                    (stat_rx_err                   ),
    .stat_rx_err_clr                (core_stat_rx_err_clr          ),
    .stat_rx_deb                    (stat_rx_deb                   ),
    .stat_rx_deb_clr                (core_stat_rx_deb_clr          ),
    .stat_link_err_cnt              (stat_link_err_cnt             ),
    .stat_link_err_cnt_clr          (core_stat_link_err_cnt_clr    ),
    .stat_test_err_cnt              (stat_test_err_cnt             ),
    .stat_test_err_cnt_clr          (core_stat_test_err_cnt_clr    ),
    .stat_test_ila_cnt              (stat_test_ila_cnt             ),
    .stat_test_ila_cnt_clr          (core_stat_test_ila_cnt_clr    ),
    .stat_test_mf_cnt               (stat_test_mf_cnt              ),
    .stat_test_mf_cnt_clr           (core_stat_test_mf_cnt_clr     ),
    .stat_rx_ila_jesdv              (stat_rx_ila_jesdv             ),
    .stat_rx_ila_subc               (stat_rx_ila_subc              ),
    .stat_rx_ila_f                  (stat_rx_ila_f                 ),
    .stat_rx_ila_k                  (stat_rx_ila_k                 ),
    .stat_rx_ila_scr                (stat_rx_ila_scr               ),
    .stat_rx_ila_l                  (stat_rx_ila_l                 ),
    .stat_rx_ila_did                (stat_rx_ila_did               ),
    .stat_rx_ila_bid                (stat_rx_ila_bid               ),
    .stat_rx_ila_m                  (stat_rx_ila_m                 ),
    .stat_rx_ila_cs                 (stat_rx_ila_cs                ),
    .stat_rx_ila_n                  (stat_rx_ila_n                 ),
    .stat_rx_ila_np                 (stat_rx_ila_np                ),
    .stat_rx_ila_s                  (stat_rx_ila_s                 ),
    .stat_rx_ila_hd                 (stat_rx_ila_hd                ),
    .stat_rx_ila_res1               (stat_rx_ila_res1              ),
    .stat_rx_ila_res2               (stat_rx_ila_res2              ),
    .stat_rx_ila_cf                 (stat_rx_ila_cf                ),
    .stat_rx_ila_adjcnt             (stat_rx_ila_adjcnt            ),
    .stat_rx_ila_adjdir             (stat_rx_ila_adjdir            ),
    .stat_rx_ila_phadj              (stat_rx_ila_phadj             ),
    .stat_rx_ila_lid                (stat_rx_ila_lid               ),
    .stat_rx_ila_fchk               (stat_rx_ila_fchk              ),

    // STAT interface 64b66b TX
    // STAT interface 64b66b RX
    .stat_rx_sh_lock                (stat_rx_sh_lock               ),
    .stat_rx_emb_lock               (stat_rx_emb_lock              ),
    .stat_rx_sh_lock_dbg            (stat_rx_sh_lock_dbg           ),
    .stat_rx_emb_lock_dbg           (stat_rx_emb_lock_dbg          ),
    .stat_rx_err_cnt0_clr           (core_stat_rx_err_cnt0_clr     ),
    .stat_rx_err_cnt0               (stat_rx_err_cnt0              ),
    .stat_rx_err_cnt1_clr           (core_stat_rx_err_cnt1_clr     ),
    .stat_rx_err_cnt1               (stat_rx_err_cnt1              ),


    // IRQ CTRL interface All Common
    .ctrl_irq_clr                   (core_ctrl_irq_clr             ),
    .ctrl_en_irq                    (ctrl_en_irq                   ),
    .ctrl_en_sysr_cap_irq           (ctrl_en_sysr_cap_irq          ),
    .ctrl_en_sysr_err_irq           (ctrl_en_sysr_err_irq          ),
    // IRQ CTRL interface TX Common
    // IRQ CTRL interface RX Common
    .ctrl_rx_en_over_err_irq        (ctrl_rx_en_over_err_irq       ),
    // IRQ CTRL interface 8b10b Common
    .ctrl_en_sync_irq               (ctrl_en_sync_irq              ),
    .ctrl_en_resync_irq             (ctrl_en_resync_irq            ),    // IRQ CTRL interface 64b66b Common
    .ctrl_en_started_irq            (ctrl_en_started_irq           ),    // IRQ CTRL interface 8b10b TX
    // IRQ CTRL interface 8b10b RX
    // IRQ CTRL interface 64b66b TX
    // IRQ CTRL interface 64b66b RX
    .ctrl_rx_en_sh_lock_irq         (ctrl_rx_en_sh_lock_irq        ),
    .ctrl_rx_en_emb_lock_irq        (ctrl_rx_en_emb_lock_irq       ),
    .ctrl_rx_en_block_sync_err_irq  (ctrl_rx_en_block_sync_err_irq ),
    .ctrl_rx_en_emb_align_err_irq   (ctrl_rx_en_emb_align_err_irq  ),
    .ctrl_rx_en_crc_err_irq         (ctrl_rx_en_crc_err_irq        ),
    .ctrl_rx_en_fec_err_irq         (ctrl_rx_en_fec_err_irq        ),

    // IRQ STAT interface All Common
    .stat_sysr_cap_irq              (stat_sysr_cap_irq             ),
    .stat_sysr_err_irq              (stat_sysr_err_irq             ),
    // IRQ STAT interface TX Common
    // IRQ STAT interface RX Common
    .stat_rx_over_err_irq           (stat_rx_over_err_irq          ),
    // IRQ STAT interface 8b10b Common
    .stat_sync_irq                  (stat_sync_irq                 ),  // IRQ STAT interface 64b66b Common
    .stat_resync_irq                (stat_resync_irq               ),  // IRQ STAT interface 8b10b TX
    .stat_started_irq               (stat_started_irq              ),  // IRQ STAT interface 8b10b RX
    // IRQ STAT interface 64b66b TX
    // IRQ STAT interface 64b66b RX
    .stat_rx_sh_lock_irq            (stat_rx_sh_lock_irq           ),
    .stat_rx_emb_lock_irq           (stat_rx_emb_lock_irq          ),
    .stat_rx_block_sync_err_irq     (stat_rx_block_sync_err_irq    ),
    .stat_rx_emb_align_err_irq      (stat_rx_emb_align_err_irq     ),
    .stat_rx_crc_err_irq            (stat_rx_crc_err_irq           ),
    .stat_rx_fec_err_irq            (stat_rx_fec_err_irq           )
);

assign s_axi_aresetn_inv = !s_axi_aresetn;

//Synchronize axi_ctrl_irq_clr to core clock domain
jesd204c_0_sync_pulse_block sync_ctrl_irq_clr_c (
  .src_clk    (s_axi_aclk),
  .src_rst    (s_axi_aresetn_inv),
  .src_pulse  (axi_ctrl_irq_clr),
  .dest_clk   (core_clk),
  .dest_rst   (reset),
  .dest_pulse (core_ctrl_irq_clr)
);

//Synchronize axi_stat_err_clr to core clock domain
jesd204c_0_sync_pulse_block sync_stat_err_clr_c (
  .src_clk    (s_axi_aclk),
  .src_rst    (s_axi_aresetn_inv),
  .src_pulse  (axi_stat_err_clr),
  .dest_clk   (core_clk),
  .dest_rst   (reset),
  .dest_pulse (core_stat_err_clr)
);

  //Synchronize ctrl_en_cmd to core clock domain
  jesd204c_0_sync_block #(
    .TYPE_RST_NOT_DATA (1'b0)
  ) sync_en_cmd
  (
    .clk             (core_clk),
    .data_in         (ctrl_en_cmd),
    .data_out        (core_ctrl_en_cmd)
  );

  //Synchronize ctrl_en_data to core clock domain
  jesd204c_0_sync_block #(
    .TYPE_RST_NOT_DATA (1'b0)
  ) sync_en_data
  (
    .clk             (core_clk),
    .data_in         (ctrl_en_data),
    .data_out        (core_ctrl_en_data)
  );

  //Synchronize ctrl_tx_sync_force to core clock domain
  jesd204c_0_sync_block #(
    .TYPE_RST_NOT_DATA (1'b0)
  ) sync_tx_sync_force
  (
    .clk             (core_clk),
    .data_in         (ctrl_tx_sync_force),
    .data_out        (core_ctrl_tx_sync_force)
  );

  // Assign JESD204C data to GT data buses
  assign gt0_txcharisk  =  txcharisk[3:0];
  assign gt0_txheader   =  txhead[1:0];
  assign gt0_txdata     =  txdata[63:0];
  assign gt1_txcharisk  =  txcharisk[7:4];
  assign gt1_txheader   =  txhead[3:2];
  assign gt1_txdata     =  txdata[127:64];
  assign gt2_txcharisk  =  txcharisk[11:8];
  assign gt2_txheader   =  txhead[5:4];
  assign gt2_txdata     =  txdata[191:128];
  assign gt3_txcharisk  =  txcharisk[15:12];
  assign gt3_txheader   =  txhead[7:6];
  assign gt3_txdata     =  txdata[255:192];
  assign gt4_txcharisk  =  txcharisk[19:16];
  assign gt4_txheader   =  txhead[9:8];
  assign gt4_txdata     =  txdata[319:256];
  assign gt5_txcharisk  =  txcharisk[23:20];
  assign gt5_txheader   =  txhead[11:10];
  assign gt5_txdata     =  txdata[383:320];
  assign gt6_txcharisk  =  txcharisk[27:24];
  assign gt6_txheader   =  txhead[13:12];
  assign gt6_txdata     =  txdata[447:384];
  assign gt7_txcharisk  =  txcharisk[31:28];
  assign gt7_txheader   =  txhead[15:14];
  assign gt7_txdata     =  txdata[511:448];

  assign ctrl_tx_ila_nll_pdef = {8{5'd7}};
  assign ctrl_tx_ila_lid_pdef =  {5'd7,5'd6, 5'd5, 5'd4, 5'd3, 5'd2, 5'd1, 5'd0};
  assign core_stat_link_err_cnt_clr[0] = 0;
  assign core_stat_test_err_cnt_clr[0] = 0;
  assign core_stat_test_ila_cnt_clr[0] = 0;
  assign core_stat_test_mf_cnt_clr[0]  = 0;
  assign core_stat_rx_err_cnt0_clr[0] = 0;
  assign core_stat_rx_err_cnt1_clr[0] = 0;
  assign core_stat_link_err_cnt_clr[1] = 0;
  assign core_stat_test_err_cnt_clr[1] = 0;
  assign core_stat_test_ila_cnt_clr[1] = 0;
  assign core_stat_test_mf_cnt_clr[1]  = 0;
  assign core_stat_rx_err_cnt0_clr[1] = 0;
  assign core_stat_rx_err_cnt1_clr[1] = 0;
  assign core_stat_link_err_cnt_clr[2] = 0;
  assign core_stat_test_err_cnt_clr[2] = 0;
  assign core_stat_test_ila_cnt_clr[2] = 0;
  assign core_stat_test_mf_cnt_clr[2]  = 0;
  assign core_stat_rx_err_cnt0_clr[2] = 0;
  assign core_stat_rx_err_cnt1_clr[2] = 0;
  assign core_stat_link_err_cnt_clr[3] = 0;
  assign core_stat_test_err_cnt_clr[3] = 0;
  assign core_stat_test_ila_cnt_clr[3] = 0;
  assign core_stat_test_mf_cnt_clr[3]  = 0;
  assign core_stat_rx_err_cnt0_clr[3] = 0;
  assign core_stat_rx_err_cnt1_clr[3] = 0;
  assign core_stat_link_err_cnt_clr[4] = 0;
  assign core_stat_test_err_cnt_clr[4] = 0;
  assign core_stat_test_ila_cnt_clr[4] = 0;
  assign core_stat_test_mf_cnt_clr[4]  = 0;
  assign core_stat_rx_err_cnt0_clr[4] = 0;
  assign core_stat_rx_err_cnt1_clr[4] = 0;
  assign core_stat_link_err_cnt_clr[5] = 0;
  assign core_stat_test_err_cnt_clr[5] = 0;
  assign core_stat_test_ila_cnt_clr[5] = 0;
  assign core_stat_test_mf_cnt_clr[5]  = 0;
  assign core_stat_rx_err_cnt0_clr[5] = 0;
  assign core_stat_rx_err_cnt1_clr[5] = 0;
  assign core_stat_link_err_cnt_clr[6] = 0;
  assign core_stat_test_err_cnt_clr[6] = 0;
  assign core_stat_test_ila_cnt_clr[6] = 0;
  assign core_stat_test_mf_cnt_clr[6]  = 0;
  assign core_stat_rx_err_cnt0_clr[6] = 0;
  assign core_stat_rx_err_cnt1_clr[6] = 0;
  assign core_stat_link_err_cnt_clr[7] = 0;
  assign core_stat_test_err_cnt_clr[7] = 0;
  assign core_stat_test_ila_cnt_clr[7] = 0;
  assign core_stat_test_mf_cnt_clr[7]  = 0;
  assign core_stat_rx_err_cnt0_clr[7] = 0;
  assign core_stat_rx_err_cnt1_clr[7] = 0;
  assign core_stat_rx_err_clr = 0;
  assign core_stat_rx_deb_clr = 0;




endmodule
