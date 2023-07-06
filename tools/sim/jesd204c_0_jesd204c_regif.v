//-----------------------------------------------------------------------------
// Title      : jesd204c_regif
// Project    : NA
//-----------------------------------------------------------------------------
// File       : jesd204c_regif.v
// Author     : Xilinx Inc.
//-----------------------------------------------------------------------------
// (c) Copyright 2021 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE 'AS IS' AND
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
// (individually and collectively, 'Critical
// Applications'). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//-----------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module jesd204c_0_jesd204c_regif #(
 parameter integer  C_S_AXI_ADDR_WIDTH             = 12,
 parameter integer  BANK_DECODE_HIGH_BIT           = 11,
 parameter integer  BANK_DECODE_HIGH_LOW           = 10,
 parameter integer  C_S_TIMEOUT_WIDTH              = 12
) (
 
//-----------------------------------------------------------------------------
// Signal declarations for BANK jesd204c_regif_csr
//-----------------------------------------------------------------------------
   output                                 timeout_enable,
   output      [11:0]                     timeout_value,
   output                                 ctrl_reset,
   input                                  stat_reset,
   output                                 ctrl_gt_dp_reset_sel,
   input                                  stat_reset_ext,
   input                                  stat_reset_ctrl,
   input                                  stat_reset_pwrgood,
   input                                  stat_reset_gtbzy,
   input       [7:0]                      stat_reset_pmarstbzy,
   input       [7:0]                      stat_reset_mstrstbzy,
   output                                 ctrl_en_cmd,
   output                                 ctrl_en_data,
   output                                 ctrl_tx_sync_force,
   output      [7:0]                      ctrl_mb_in_emb,
   output      [1:0]                      ctrl_sub_class,
   output      [1:0]                      ctrl_meta_mode,
   output      [7:0]                      ctrl_opf,
   output      [4:0]                      ctrl_fpmf,
   output                                 ctrl_scr,
   output                                 ctrl_ila_req,
   output                                 ctrl_rx_err_rep_ena,
   output                                 ctrl_rx_err_cnt_ena,
   output                                 ctrl_tx_ila_cs_all,
   output      [7:0]                      ctrl_tx_ila_mf,
   output      [7:0]                      ctrl_lane_ena,
   output      [9:0]                      ctrl_rx_buf_adv,
   output      [2:0]                      ctrl_test_mode,
   output      [2:0]                      ctrl_tx_loopback,
   output      [2:0]                      ctrl_rx_mblock_th,
   output                                 ctrl_sysr_alw,
   output                                 ctrl_sysr_req,
   output      [2:0]                      ctrl_sysr_tol,
   output      [7:0]                      ctrl_sysr_del,
   input       [7:0]                      stat_rx_sh_lock_dbg,
   input       [7:0]                      stat_rx_emb_lock_dbg,
   input       [31:0]                     stat_rx_err,
   output                                 stat_rx_err_pls_h,
   input       [31:0]                     stat_rx_deb,
   output                                 stat_rx_deb_pls_h,
   input                                  stat_irq_pend,
   input                                  stat_sysr_cap,
   input                                  stat_sysr_err,
   output                                 stat_sysr_err_pls_h,
   input                                  stat_rx_sh_lock,
   input                                  stat_rx_emb_lock,
   input                                  stat_rx_over_err,
   input                                  stat_sync,
   input                                  stat_rx_cgs,
   input                                  stat_rx_started,
   input                                  stat_rx_align_err,
   output                                 ctrl_en_irq,
   output                                 ctrl_en_sysr_cap_irq,
   output                                 ctrl_en_sysr_err_irq,
   output                                 ctrl_rx_en_sh_lock_irq,
   output                                 ctrl_rx_en_emb_lock_irq,
   output                                 ctrl_rx_en_block_sync_err_irq,
   output                                 ctrl_rx_en_emb_align_err_irq,
   output                                 ctrl_rx_en_crc_err_irq,
   output                                 ctrl_rx_en_fec_err_irq,
   output                                 ctrl_rx_en_over_err_irq,
   output                                 ctrl_en_sync_irq,
   output                                 ctrl_en_resync_irq,
   output                                 ctrl_en_started_irq,
   input                                  stat_sysr_cap_irq,
   output                                 stat_sysr_cap_irq_pls_h,
   input                                  stat_sysr_err_irq,
   input                                  stat_rx_sh_lock_irq,
   input                                  stat_rx_emb_lock_irq,
   input                                  stat_rx_block_sync_err_irq,
   input                                  stat_rx_emb_align_err_irq,
   input                                  stat_rx_crc_err_irq,
   input                                  stat_rx_fec_err_irq,
   input                                  stat_rx_over_err_irq,
   input                                  stat_sync_irq,
   input                                  stat_resync_irq,
   input                                  stat_started_irq,
   output      [7:0]                      ctrl_tx_ila_did,
   output      [3:0]                      ctrl_tx_ila_bid,
   output      [7:0]                      ctrl_tx_ila_m,
   output      [4:0]                      ctrl_tx_ila_n,
   output      [4:0]                      ctrl_tx_ila_np,
   output      [1:0]                      ctrl_tx_ila_cs,
   output      [4:0]                      ctrl_tx_ila_s,
   output                                 ctrl_tx_ila_hd,
   output      [4:0]                      ctrl_tx_ila_cf,
   output      [3:0]                      ctrl_tx_ila_adjcnt,
   output                                 ctrl_tx_ila_phadj,
   output                                 ctrl_tx_ila_adjdir,
   output      [7:0]                      ctrl_tx_ila_res1,
   output      [7:0]                      ctrl_tx_ila_res2,

 
//-----------------------------------------------------------------------------
// Signal declarations for BANK jesd204c_regif_lane
//-----------------------------------------------------------------------------
   input       [79:0]                     stat_rx_buf_lvl,
   output      [39:0]                     ctrl_tx_ila_lid,
   input       [39:0]                     ctrl_tx_ila_lid_pdef,
   output      [39:0]                     ctrl_tx_ila_nll,
   input       [39:0]                     ctrl_tx_ila_nll_pdef,
   input       [255:0]                    stat_rx_err_cnt0,
   output      [7:0]                      stat_rx_err_cnt0_pls_h,
   input       [255:0]                    stat_rx_err_cnt1,
   output      [7:0]                      stat_rx_err_cnt1_pls_h,
   input       [255:0]                    stat_link_err_cnt,
   output      [7:0]                      stat_link_err_cnt_pls_h,
   input       [255:0]                    stat_test_err_cnt,
   output      [7:0]                      stat_test_err_cnt_pls_h,
   input       [255:0]                    stat_test_ila_cnt,
   output      [7:0]                      stat_test_ila_cnt_pls_h,
   input       [255:0]                    stat_test_mf_cnt,
   output      [7:0]                      stat_test_mf_cnt_pls_h,
   input       [23:0]                     stat_rx_ila_jesdv,
   input       [23:0]                     stat_rx_ila_subc,
   input       [63:0]                     stat_rx_ila_f,
   input       [39:0]                     stat_rx_ila_k,
   input       [63:0]                     stat_rx_ila_did,
   input       [31:0]                     stat_rx_ila_bid,
   input       [39:0]                     stat_rx_ila_lid,
   input       [39:0]                     stat_rx_ila_l,
   input       [63:0]                     stat_rx_ila_m,
   input       [39:0]                     stat_rx_ila_n,
   input       [39:0]                     stat_rx_ila_np,
   input       [15:0]                     stat_rx_ila_cs,
   input       [7:0]                      stat_rx_ila_scr,
   input       [39:0]                     stat_rx_ila_s,
   input       [7:0]                      stat_rx_ila_hd,
   input       [39:0]                     stat_rx_ila_cf,
   input       [31:0]                     stat_rx_ila_adjcnt,
   input       [7:0]                      stat_rx_ila_phadj,
   input       [7:0]                      stat_rx_ila_adjdir,
   input       [63:0]                     stat_rx_ila_res1,
   input       [63:0]                     stat_rx_ila_res2,
   input       [63:0]                     stat_rx_ila_fchk,
   output      [7:0]                      ctrl_tx_gtpolarity,
   output      [15:0]                     ctrl_tx_gtpd,
   output      [7:0]                      ctrl_tx_gtelecidle,
   output      [7:0]                      ctrl_tx_gtinhibit,
   output      [39:0]                     ctrl_tx_gtdiffctrl,
   output      [39:0]                     ctrl_tx_gtpostcursor,
   output      [39:0]                     ctrl_tx_gtprecursor,
   output      [7:0]                      ctrl_rx_gtpolarity,
   output      [15:0]                     ctrl_rx_gtpd,


//-----------------------------------------------------------------------------
// Other clock domain IO
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Time out connections in
//-----------------------------------------------------------------------------
   input                                  timeout_enable_in,
   input       [C_S_TIMEOUT_WIDTH-1:0]    timeout_value_in,

//-----------------------------------------------------------------------------
// AXI Lite IO
//-----------------------------------------------------------------------------
   input                                  s_axi_aclk,
   input                                  s_axi_aresetn,
   input       [C_S_AXI_ADDR_WIDTH-1:0]   s_axi_awaddr,
   input                                  s_axi_awvalid,
   output                                 s_axi_awready,
   input       [31:0]                     s_axi_wdata,
   input                                  s_axi_wvalid,
   output                                 s_axi_wready,
   output      [1:0]                      s_axi_bresp,
   output                                 s_axi_bvalid,
   input                                  s_axi_bready,
   input       [C_S_AXI_ADDR_WIDTH-1:0]   s_axi_araddr,
   input                                  s_axi_arvalid,
   output                                 s_axi_arready,
   output      [31:0]                     s_axi_rdata,
   output      [1:0]                      s_axi_rresp,
   output                                 s_axi_rvalid,
   input                                  s_axi_rready

);

//-----------------------------------------------------------------------------
// internal register strobe declarations
//-----------------------------------------------------------------------------
   wire        [BANK_DECODE_HIGH_LOW-1:2] slv_addr;
   wire        [31:0]                     slv_wdata;   
   wire                                   slv_reg_rden;

   wire        [31:0]                     strb_b0_slv_rdata;
   wire                                   strb_b0_slv_wren;
   wire                                   strb_b0_slv_rden;
   wire                                   strb_b0_slv_wr_done;
   wire                                   strb_b0_slv_rd_done;
  
   wire        [31:0]                     strb_b1_slv_rdata;
   wire                                   strb_b1_slv_wren;
   wire                                   strb_b1_slv_rden;
   wire                                   strb_b1_slv_wr_done;
   wire                                   strb_b1_slv_rd_done;
  
//-----------------------------------------------------------------------------
// Signal bus wire declarations for BANK jesd204c_regif_lane
//-----------------------------------------------------------------------------
   wire        [9:0]                      stat_rx_buf_lvl_0;
   wire        [4:0]                      ctrl_tx_ila_lid_0;
   wire        [4:0]                      ctrl_tx_ila_lid_0_pdef;
   wire        [4:0]                      ctrl_tx_ila_nll_0;
   wire        [4:0]                      ctrl_tx_ila_nll_0_pdef;
   wire        [31:0]                     stat_rx_err_cnt0_0;
   wire        [31:0]                     stat_rx_err_cnt1_0;
   wire        [31:0]                     stat_link_err_cnt_0;
   wire        [31:0]                     stat_test_err_cnt_0;
   wire        [31:0]                     stat_test_ila_cnt_0;
   wire        [31:0]                     stat_test_mf_cnt_0;
   wire        [2:0]                      stat_rx_ila_jesdv_0;
   wire        [2:0]                      stat_rx_ila_subc_0;
   wire        [7:0]                      stat_rx_ila_f_0;
   wire        [4:0]                      stat_rx_ila_k_0;
   wire        [7:0]                      stat_rx_ila_did_0;
   wire        [3:0]                      stat_rx_ila_bid_0;
   wire        [4:0]                      stat_rx_ila_lid_0;
   wire        [4:0]                      stat_rx_ila_l_0;
   wire        [7:0]                      stat_rx_ila_m_0;
   wire        [4:0]                      stat_rx_ila_n_0;
   wire        [4:0]                      stat_rx_ila_np_0;
   wire        [1:0]                      stat_rx_ila_cs_0;
   wire                                   stat_rx_ila_scr_0;
   wire        [4:0]                      stat_rx_ila_s_0;
   wire                                   stat_rx_ila_hd_0;
   wire        [4:0]                      stat_rx_ila_cf_0;
   wire        [3:0]                      stat_rx_ila_adjcnt_0;
   wire                                   stat_rx_ila_phadj_0;
   wire                                   stat_rx_ila_adjdir_0;
   wire        [7:0]                      stat_rx_ila_res1_0;
   wire        [7:0]                      stat_rx_ila_res2_0;
   wire        [7:0]                      stat_rx_ila_fchk_0;
   wire                                   ctrl_tx_gtpolarity_0;
   wire        [1:0]                      ctrl_tx_gtpd_0;
   wire                                   ctrl_tx_gtelecidle_0;
   wire                                   ctrl_tx_gtinhibit_0;
   wire        [4:0]                      ctrl_tx_gtdiffctrl_0;
   wire        [4:0]                      ctrl_tx_gtpostcursor_0;
   wire        [4:0]                      ctrl_tx_gtprecursor_0;
   wire                                   ctrl_rx_gtpolarity_0;
   wire        [1:0]                      ctrl_rx_gtpd_0;

   wire        [9:0]                      stat_rx_buf_lvl_1;
   wire        [4:0]                      ctrl_tx_ila_lid_1;
   wire        [4:0]                      ctrl_tx_ila_lid_1_pdef;
   wire        [4:0]                      ctrl_tx_ila_nll_1;
   wire        [4:0]                      ctrl_tx_ila_nll_1_pdef;
   wire        [31:0]                     stat_rx_err_cnt0_1;
   wire        [31:0]                     stat_rx_err_cnt1_1;
   wire        [31:0]                     stat_link_err_cnt_1;
   wire        [31:0]                     stat_test_err_cnt_1;
   wire        [31:0]                     stat_test_ila_cnt_1;
   wire        [31:0]                     stat_test_mf_cnt_1;
   wire        [2:0]                      stat_rx_ila_jesdv_1;
   wire        [2:0]                      stat_rx_ila_subc_1;
   wire        [7:0]                      stat_rx_ila_f_1;
   wire        [4:0]                      stat_rx_ila_k_1;
   wire        [7:0]                      stat_rx_ila_did_1;
   wire        [3:0]                      stat_rx_ila_bid_1;
   wire        [4:0]                      stat_rx_ila_lid_1;
   wire        [4:0]                      stat_rx_ila_l_1;
   wire        [7:0]                      stat_rx_ila_m_1;
   wire        [4:0]                      stat_rx_ila_n_1;
   wire        [4:0]                      stat_rx_ila_np_1;
   wire        [1:0]                      stat_rx_ila_cs_1;
   wire                                   stat_rx_ila_scr_1;
   wire        [4:0]                      stat_rx_ila_s_1;
   wire                                   stat_rx_ila_hd_1;
   wire        [4:0]                      stat_rx_ila_cf_1;
   wire        [3:0]                      stat_rx_ila_adjcnt_1;
   wire                                   stat_rx_ila_phadj_1;
   wire                                   stat_rx_ila_adjdir_1;
   wire        [7:0]                      stat_rx_ila_res1_1;
   wire        [7:0]                      stat_rx_ila_res2_1;
   wire        [7:0]                      stat_rx_ila_fchk_1;
   wire                                   ctrl_tx_gtpolarity_1;
   wire        [1:0]                      ctrl_tx_gtpd_1;
   wire                                   ctrl_tx_gtelecidle_1;
   wire                                   ctrl_tx_gtinhibit_1;
   wire        [4:0]                      ctrl_tx_gtdiffctrl_1;
   wire        [4:0]                      ctrl_tx_gtpostcursor_1;
   wire        [4:0]                      ctrl_tx_gtprecursor_1;
   wire                                   ctrl_rx_gtpolarity_1;
   wire        [1:0]                      ctrl_rx_gtpd_1;

   wire        [9:0]                      stat_rx_buf_lvl_2;
   wire        [4:0]                      ctrl_tx_ila_lid_2;
   wire        [4:0]                      ctrl_tx_ila_lid_2_pdef;
   wire        [4:0]                      ctrl_tx_ila_nll_2;
   wire        [4:0]                      ctrl_tx_ila_nll_2_pdef;
   wire        [31:0]                     stat_rx_err_cnt0_2;
   wire        [31:0]                     stat_rx_err_cnt1_2;
   wire        [31:0]                     stat_link_err_cnt_2;
   wire        [31:0]                     stat_test_err_cnt_2;
   wire        [31:0]                     stat_test_ila_cnt_2;
   wire        [31:0]                     stat_test_mf_cnt_2;
   wire        [2:0]                      stat_rx_ila_jesdv_2;
   wire        [2:0]                      stat_rx_ila_subc_2;
   wire        [7:0]                      stat_rx_ila_f_2;
   wire        [4:0]                      stat_rx_ila_k_2;
   wire        [7:0]                      stat_rx_ila_did_2;
   wire        [3:0]                      stat_rx_ila_bid_2;
   wire        [4:0]                      stat_rx_ila_lid_2;
   wire        [4:0]                      stat_rx_ila_l_2;
   wire        [7:0]                      stat_rx_ila_m_2;
   wire        [4:0]                      stat_rx_ila_n_2;
   wire        [4:0]                      stat_rx_ila_np_2;
   wire        [1:0]                      stat_rx_ila_cs_2;
   wire                                   stat_rx_ila_scr_2;
   wire        [4:0]                      stat_rx_ila_s_2;
   wire                                   stat_rx_ila_hd_2;
   wire        [4:0]                      stat_rx_ila_cf_2;
   wire        [3:0]                      stat_rx_ila_adjcnt_2;
   wire                                   stat_rx_ila_phadj_2;
   wire                                   stat_rx_ila_adjdir_2;
   wire        [7:0]                      stat_rx_ila_res1_2;
   wire        [7:0]                      stat_rx_ila_res2_2;
   wire        [7:0]                      stat_rx_ila_fchk_2;
   wire                                   ctrl_tx_gtpolarity_2;
   wire        [1:0]                      ctrl_tx_gtpd_2;
   wire                                   ctrl_tx_gtelecidle_2;
   wire                                   ctrl_tx_gtinhibit_2;
   wire        [4:0]                      ctrl_tx_gtdiffctrl_2;
   wire        [4:0]                      ctrl_tx_gtpostcursor_2;
   wire        [4:0]                      ctrl_tx_gtprecursor_2;
   wire                                   ctrl_rx_gtpolarity_2;
   wire        [1:0]                      ctrl_rx_gtpd_2;

   wire        [9:0]                      stat_rx_buf_lvl_3;
   wire        [4:0]                      ctrl_tx_ila_lid_3;
   wire        [4:0]                      ctrl_tx_ila_lid_3_pdef;
   wire        [4:0]                      ctrl_tx_ila_nll_3;
   wire        [4:0]                      ctrl_tx_ila_nll_3_pdef;
   wire        [31:0]                     stat_rx_err_cnt0_3;
   wire        [31:0]                     stat_rx_err_cnt1_3;
   wire        [31:0]                     stat_link_err_cnt_3;
   wire        [31:0]                     stat_test_err_cnt_3;
   wire        [31:0]                     stat_test_ila_cnt_3;
   wire        [31:0]                     stat_test_mf_cnt_3;
   wire        [2:0]                      stat_rx_ila_jesdv_3;
   wire        [2:0]                      stat_rx_ila_subc_3;
   wire        [7:0]                      stat_rx_ila_f_3;
   wire        [4:0]                      stat_rx_ila_k_3;
   wire        [7:0]                      stat_rx_ila_did_3;
   wire        [3:0]                      stat_rx_ila_bid_3;
   wire        [4:0]                      stat_rx_ila_lid_3;
   wire        [4:0]                      stat_rx_ila_l_3;
   wire        [7:0]                      stat_rx_ila_m_3;
   wire        [4:0]                      stat_rx_ila_n_3;
   wire        [4:0]                      stat_rx_ila_np_3;
   wire        [1:0]                      stat_rx_ila_cs_3;
   wire                                   stat_rx_ila_scr_3;
   wire        [4:0]                      stat_rx_ila_s_3;
   wire                                   stat_rx_ila_hd_3;
   wire        [4:0]                      stat_rx_ila_cf_3;
   wire        [3:0]                      stat_rx_ila_adjcnt_3;
   wire                                   stat_rx_ila_phadj_3;
   wire                                   stat_rx_ila_adjdir_3;
   wire        [7:0]                      stat_rx_ila_res1_3;
   wire        [7:0]                      stat_rx_ila_res2_3;
   wire        [7:0]                      stat_rx_ila_fchk_3;
   wire                                   ctrl_tx_gtpolarity_3;
   wire        [1:0]                      ctrl_tx_gtpd_3;
   wire                                   ctrl_tx_gtelecidle_3;
   wire                                   ctrl_tx_gtinhibit_3;
   wire        [4:0]                      ctrl_tx_gtdiffctrl_3;
   wire        [4:0]                      ctrl_tx_gtpostcursor_3;
   wire        [4:0]                      ctrl_tx_gtprecursor_3;
   wire                                   ctrl_rx_gtpolarity_3;
   wire        [1:0]                      ctrl_rx_gtpd_3;

   wire        [9:0]                      stat_rx_buf_lvl_4;
   wire        [4:0]                      ctrl_tx_ila_lid_4;
   wire        [4:0]                      ctrl_tx_ila_lid_4_pdef;
   wire        [4:0]                      ctrl_tx_ila_nll_4;
   wire        [4:0]                      ctrl_tx_ila_nll_4_pdef;
   wire        [31:0]                     stat_rx_err_cnt0_4;
   wire        [31:0]                     stat_rx_err_cnt1_4;
   wire        [31:0]                     stat_link_err_cnt_4;
   wire        [31:0]                     stat_test_err_cnt_4;
   wire        [31:0]                     stat_test_ila_cnt_4;
   wire        [31:0]                     stat_test_mf_cnt_4;
   wire        [2:0]                      stat_rx_ila_jesdv_4;
   wire        [2:0]                      stat_rx_ila_subc_4;
   wire        [7:0]                      stat_rx_ila_f_4;
   wire        [4:0]                      stat_rx_ila_k_4;
   wire        [7:0]                      stat_rx_ila_did_4;
   wire        [3:0]                      stat_rx_ila_bid_4;
   wire        [4:0]                      stat_rx_ila_lid_4;
   wire        [4:0]                      stat_rx_ila_l_4;
   wire        [7:0]                      stat_rx_ila_m_4;
   wire        [4:0]                      stat_rx_ila_n_4;
   wire        [4:0]                      stat_rx_ila_np_4;
   wire        [1:0]                      stat_rx_ila_cs_4;
   wire                                   stat_rx_ila_scr_4;
   wire        [4:0]                      stat_rx_ila_s_4;
   wire                                   stat_rx_ila_hd_4;
   wire        [4:0]                      stat_rx_ila_cf_4;
   wire        [3:0]                      stat_rx_ila_adjcnt_4;
   wire                                   stat_rx_ila_phadj_4;
   wire                                   stat_rx_ila_adjdir_4;
   wire        [7:0]                      stat_rx_ila_res1_4;
   wire        [7:0]                      stat_rx_ila_res2_4;
   wire        [7:0]                      stat_rx_ila_fchk_4;
   wire                                   ctrl_tx_gtpolarity_4;
   wire        [1:0]                      ctrl_tx_gtpd_4;
   wire                                   ctrl_tx_gtelecidle_4;
   wire                                   ctrl_tx_gtinhibit_4;
   wire        [4:0]                      ctrl_tx_gtdiffctrl_4;
   wire        [4:0]                      ctrl_tx_gtpostcursor_4;
   wire        [4:0]                      ctrl_tx_gtprecursor_4;
   wire                                   ctrl_rx_gtpolarity_4;
   wire        [1:0]                      ctrl_rx_gtpd_4;

   wire        [9:0]                      stat_rx_buf_lvl_5;
   wire        [4:0]                      ctrl_tx_ila_lid_5;
   wire        [4:0]                      ctrl_tx_ila_lid_5_pdef;
   wire        [4:0]                      ctrl_tx_ila_nll_5;
   wire        [4:0]                      ctrl_tx_ila_nll_5_pdef;
   wire        [31:0]                     stat_rx_err_cnt0_5;
   wire        [31:0]                     stat_rx_err_cnt1_5;
   wire        [31:0]                     stat_link_err_cnt_5;
   wire        [31:0]                     stat_test_err_cnt_5;
   wire        [31:0]                     stat_test_ila_cnt_5;
   wire        [31:0]                     stat_test_mf_cnt_5;
   wire        [2:0]                      stat_rx_ila_jesdv_5;
   wire        [2:0]                      stat_rx_ila_subc_5;
   wire        [7:0]                      stat_rx_ila_f_5;
   wire        [4:0]                      stat_rx_ila_k_5;
   wire        [7:0]                      stat_rx_ila_did_5;
   wire        [3:0]                      stat_rx_ila_bid_5;
   wire        [4:0]                      stat_rx_ila_lid_5;
   wire        [4:0]                      stat_rx_ila_l_5;
   wire        [7:0]                      stat_rx_ila_m_5;
   wire        [4:0]                      stat_rx_ila_n_5;
   wire        [4:0]                      stat_rx_ila_np_5;
   wire        [1:0]                      stat_rx_ila_cs_5;
   wire                                   stat_rx_ila_scr_5;
   wire        [4:0]                      stat_rx_ila_s_5;
   wire                                   stat_rx_ila_hd_5;
   wire        [4:0]                      stat_rx_ila_cf_5;
   wire        [3:0]                      stat_rx_ila_adjcnt_5;
   wire                                   stat_rx_ila_phadj_5;
   wire                                   stat_rx_ila_adjdir_5;
   wire        [7:0]                      stat_rx_ila_res1_5;
   wire        [7:0]                      stat_rx_ila_res2_5;
   wire        [7:0]                      stat_rx_ila_fchk_5;
   wire                                   ctrl_tx_gtpolarity_5;
   wire        [1:0]                      ctrl_tx_gtpd_5;
   wire                                   ctrl_tx_gtelecidle_5;
   wire                                   ctrl_tx_gtinhibit_5;
   wire        [4:0]                      ctrl_tx_gtdiffctrl_5;
   wire        [4:0]                      ctrl_tx_gtpostcursor_5;
   wire        [4:0]                      ctrl_tx_gtprecursor_5;
   wire                                   ctrl_rx_gtpolarity_5;
   wire        [1:0]                      ctrl_rx_gtpd_5;

   wire        [9:0]                      stat_rx_buf_lvl_6;
   wire        [4:0]                      ctrl_tx_ila_lid_6;
   wire        [4:0]                      ctrl_tx_ila_lid_6_pdef;
   wire        [4:0]                      ctrl_tx_ila_nll_6;
   wire        [4:0]                      ctrl_tx_ila_nll_6_pdef;
   wire        [31:0]                     stat_rx_err_cnt0_6;
   wire        [31:0]                     stat_rx_err_cnt1_6;
   wire        [31:0]                     stat_link_err_cnt_6;
   wire        [31:0]                     stat_test_err_cnt_6;
   wire        [31:0]                     stat_test_ila_cnt_6;
   wire        [31:0]                     stat_test_mf_cnt_6;
   wire        [2:0]                      stat_rx_ila_jesdv_6;
   wire        [2:0]                      stat_rx_ila_subc_6;
   wire        [7:0]                      stat_rx_ila_f_6;
   wire        [4:0]                      stat_rx_ila_k_6;
   wire        [7:0]                      stat_rx_ila_did_6;
   wire        [3:0]                      stat_rx_ila_bid_6;
   wire        [4:0]                      stat_rx_ila_lid_6;
   wire        [4:0]                      stat_rx_ila_l_6;
   wire        [7:0]                      stat_rx_ila_m_6;
   wire        [4:0]                      stat_rx_ila_n_6;
   wire        [4:0]                      stat_rx_ila_np_6;
   wire        [1:0]                      stat_rx_ila_cs_6;
   wire                                   stat_rx_ila_scr_6;
   wire        [4:0]                      stat_rx_ila_s_6;
   wire                                   stat_rx_ila_hd_6;
   wire        [4:0]                      stat_rx_ila_cf_6;
   wire        [3:0]                      stat_rx_ila_adjcnt_6;
   wire                                   stat_rx_ila_phadj_6;
   wire                                   stat_rx_ila_adjdir_6;
   wire        [7:0]                      stat_rx_ila_res1_6;
   wire        [7:0]                      stat_rx_ila_res2_6;
   wire        [7:0]                      stat_rx_ila_fchk_6;
   wire                                   ctrl_tx_gtpolarity_6;
   wire        [1:0]                      ctrl_tx_gtpd_6;
   wire                                   ctrl_tx_gtelecidle_6;
   wire                                   ctrl_tx_gtinhibit_6;
   wire        [4:0]                      ctrl_tx_gtdiffctrl_6;
   wire        [4:0]                      ctrl_tx_gtpostcursor_6;
   wire        [4:0]                      ctrl_tx_gtprecursor_6;
   wire                                   ctrl_rx_gtpolarity_6;
   wire        [1:0]                      ctrl_rx_gtpd_6;

   wire        [9:0]                      stat_rx_buf_lvl_7;
   wire        [4:0]                      ctrl_tx_ila_lid_7;
   wire        [4:0]                      ctrl_tx_ila_lid_7_pdef;
   wire        [4:0]                      ctrl_tx_ila_nll_7;
   wire        [4:0]                      ctrl_tx_ila_nll_7_pdef;
   wire        [31:0]                     stat_rx_err_cnt0_7;
   wire        [31:0]                     stat_rx_err_cnt1_7;
   wire        [31:0]                     stat_link_err_cnt_7;
   wire        [31:0]                     stat_test_err_cnt_7;
   wire        [31:0]                     stat_test_ila_cnt_7;
   wire        [31:0]                     stat_test_mf_cnt_7;
   wire        [2:0]                      stat_rx_ila_jesdv_7;
   wire        [2:0]                      stat_rx_ila_subc_7;
   wire        [7:0]                      stat_rx_ila_f_7;
   wire        [4:0]                      stat_rx_ila_k_7;
   wire        [7:0]                      stat_rx_ila_did_7;
   wire        [3:0]                      stat_rx_ila_bid_7;
   wire        [4:0]                      stat_rx_ila_lid_7;
   wire        [4:0]                      stat_rx_ila_l_7;
   wire        [7:0]                      stat_rx_ila_m_7;
   wire        [4:0]                      stat_rx_ila_n_7;
   wire        [4:0]                      stat_rx_ila_np_7;
   wire        [1:0]                      stat_rx_ila_cs_7;
   wire                                   stat_rx_ila_scr_7;
   wire        [4:0]                      stat_rx_ila_s_7;
   wire                                   stat_rx_ila_hd_7;
   wire        [4:0]                      stat_rx_ila_cf_7;
   wire        [3:0]                      stat_rx_ila_adjcnt_7;
   wire                                   stat_rx_ila_phadj_7;
   wire                                   stat_rx_ila_adjdir_7;
   wire        [7:0]                      stat_rx_ila_res1_7;
   wire        [7:0]                      stat_rx_ila_res2_7;
   wire        [7:0]                      stat_rx_ila_fchk_7;
   wire                                   ctrl_tx_gtpolarity_7;
   wire        [1:0]                      ctrl_tx_gtpd_7;
   wire                                   ctrl_tx_gtelecidle_7;
   wire                                   ctrl_tx_gtinhibit_7;
   wire        [4:0]                      ctrl_tx_gtdiffctrl_7;
   wire        [4:0]                      ctrl_tx_gtpostcursor_7;
   wire        [4:0]                      ctrl_tx_gtprecursor_7;
   wire                                   ctrl_rx_gtpolarity_7;
   wire        [1:0]                      ctrl_rx_gtpd_7;


//-----------------------------------------------------------------------------
// Signal bus wire declarations for BANK jesd204c_regif_lane
//-----------------------------------------------------------------------------









//-----------------------------------------------------------------------------
// Main AXI interface
//-----------------------------------------------------------------------------
jesd204c_0_jesd204c_regif_axi #(
.C_S_AXI_ADDR_WIDTH           (C_S_AXI_ADDR_WIDTH),
.BANK_DECODE_HIGH_BIT         (BANK_DECODE_HIGH_BIT),
.BANK_DECODE_HIGH_LOW         (BANK_DECODE_HIGH_LOW),
.C_S_TIMEOUT_WIDTH            (C_S_TIMEOUT_WIDTH)
) axi_register_if_i (

  .slv_reg_rden                             (slv_reg_rden                            ),
  .slv_addr                                 (slv_addr                                ),
  .slv_wdata                                (slv_wdata                               ),

  .strb_b0_slv_rdata                        (strb_b0_slv_rdata                       ),
  .strb_b0_slv_wren                         (strb_b0_slv_wren                        ),
  .strb_b0_slv_rden                         (strb_b0_slv_rden                        ),
  .strb_b0_slv_rd_done                      (strb_b0_slv_rd_done                     ),
  .strb_b0_slv_wr_done                      (strb_b0_slv_wr_done                     ),

  .strb_b1_slv_rdata                        (strb_b1_slv_rdata                       ),
  .strb_b1_slv_wren                         (strb_b1_slv_wren                        ),
  .strb_b1_slv_rden                         (strb_b1_slv_rden                        ),
  .strb_b1_slv_rd_done                      (strb_b1_slv_rd_done                     ),
  .strb_b1_slv_wr_done                      (strb_b1_slv_wr_done                     ),

  .timeout_enable_in                        (timeout_enable_in                       ),
  .timeout_value_in                         (timeout_value_in                        ),
 
  .s_axi_aclk                               (s_axi_aclk                              ),
  .s_axi_aresetn                            (s_axi_aresetn                           ),

  .s_axi_awaddr                             (s_axi_awaddr                            ),
  .s_axi_awvalid                            (s_axi_awvalid                           ),
  .s_axi_awready                            (s_axi_awready                           ),

  .s_axi_wdata                              (s_axi_wdata                             ),
  .s_axi_wvalid                             (s_axi_wvalid                            ),
  .s_axi_wready                             (s_axi_wready                            ),

  .s_axi_bresp                              (s_axi_bresp                             ),
  .s_axi_bvalid                             (s_axi_bvalid                            ),
  .s_axi_bready                             (s_axi_bready                            ),

  .s_axi_araddr                             (s_axi_araddr                            ),
  .s_axi_arvalid                            (s_axi_arvalid                           ),
  .s_axi_arready                            (s_axi_arready                           ),

  .s_axi_rdata                              (s_axi_rdata                             ),
  .s_axi_rresp                              (s_axi_rresp                             ),
  .s_axi_rvalid                             (s_axi_rvalid                            ),
  .s_axi_rready                             (s_axi_rready                            )

);

//-----------------------------------------------------------------------------
// jesd204c_0_jesd204c_regif_csr register bank
//-----------------------------------------------------------------------------
jesd204c_0_jesd204c_regif_csr #(
   .C_S_AXI_ADDR_WIDTH           (BANK_DECODE_HIGH_LOW)
) jesd204c_0_jesd204c_regif_csr_i (

  .timeout_enable                           (timeout_enable                          ),
  .timeout_value                            (timeout_value                           ),
  .ctrl_reset                               (ctrl_reset                              ),
  .stat_reset                               (stat_reset                              ),
  .ctrl_gt_dp_reset_sel                     (ctrl_gt_dp_reset_sel                    ),
  .stat_reset_ext                           (stat_reset_ext                          ),
  .stat_reset_ctrl                          (stat_reset_ctrl                         ),
  .stat_reset_pwrgood                       (stat_reset_pwrgood                      ),
  .stat_reset_gtbzy                         (stat_reset_gtbzy                        ),
  .stat_reset_pmarstbzy                     (stat_reset_pmarstbzy                    ),
  .stat_reset_mstrstbzy                     (stat_reset_mstrstbzy                    ),
  .ctrl_en_cmd                              (ctrl_en_cmd                             ),
  .ctrl_en_data                             (ctrl_en_data                            ),
  .ctrl_tx_sync_force                       (ctrl_tx_sync_force                      ),
  .ctrl_mb_in_emb                           (ctrl_mb_in_emb                          ),
  .ctrl_sub_class                           (ctrl_sub_class                          ),
  .ctrl_meta_mode                           (ctrl_meta_mode                          ),
  .ctrl_opf                                 (ctrl_opf                                ),
  .ctrl_fpmf                                (ctrl_fpmf                               ),
  .ctrl_scr                                 (ctrl_scr                                ),
  .ctrl_ila_req                             (ctrl_ila_req                            ),
  .ctrl_rx_err_rep_ena                      (ctrl_rx_err_rep_ena                     ),
  .ctrl_rx_err_cnt_ena                      (ctrl_rx_err_cnt_ena                     ),
  .ctrl_tx_ila_cs_all                       (ctrl_tx_ila_cs_all                      ),
  .ctrl_tx_ila_mf                           (ctrl_tx_ila_mf                          ),
  .ctrl_lane_ena                            (ctrl_lane_ena                           ),
  .ctrl_rx_buf_adv                          (ctrl_rx_buf_adv                         ),
  .ctrl_test_mode                           (ctrl_test_mode                          ),
  .ctrl_tx_loopback                         (ctrl_tx_loopback                        ),
  .ctrl_rx_mblock_th                        (ctrl_rx_mblock_th                       ),
  .ctrl_sysr_alw                            (ctrl_sysr_alw                           ),
  .ctrl_sysr_req                            (ctrl_sysr_req                           ),
  .ctrl_sysr_tol                            (ctrl_sysr_tol                           ),
  .ctrl_sysr_del                            (ctrl_sysr_del                           ),
  .stat_rx_sh_lock_dbg                      (stat_rx_sh_lock_dbg                     ),
  .stat_rx_emb_lock_dbg                     (stat_rx_emb_lock_dbg                    ),
  .stat_rx_err                              (stat_rx_err                             ),
  .stat_rx_err_pls_h                        (stat_rx_err_pls_h                       ),
  .stat_rx_deb                              (stat_rx_deb                             ),
  .stat_rx_deb_pls_h                        (stat_rx_deb_pls_h                       ),
  .stat_irq_pend                            (stat_irq_pend                           ),
  .stat_sysr_cap                            (stat_sysr_cap                           ),
  .stat_sysr_err                            (stat_sysr_err                           ),
  .stat_sysr_err_pls_h                      (stat_sysr_err_pls_h                     ),
  .stat_rx_sh_lock                          (stat_rx_sh_lock                         ),
  .stat_rx_emb_lock                         (stat_rx_emb_lock                        ),
  .stat_rx_over_err                         (stat_rx_over_err                        ),
  .stat_sync                                (stat_sync                               ),
  .stat_rx_cgs                              (stat_rx_cgs                             ),
  .stat_rx_started                          (stat_rx_started                         ),
  .stat_rx_align_err                        (stat_rx_align_err                       ),
  .ctrl_en_irq                              (ctrl_en_irq                             ),
  .ctrl_en_sysr_cap_irq                     (ctrl_en_sysr_cap_irq                    ),
  .ctrl_en_sysr_err_irq                     (ctrl_en_sysr_err_irq                    ),
  .ctrl_rx_en_sh_lock_irq                   (ctrl_rx_en_sh_lock_irq                  ),
  .ctrl_rx_en_emb_lock_irq                  (ctrl_rx_en_emb_lock_irq                 ),
  .ctrl_rx_en_block_sync_err_irq            (ctrl_rx_en_block_sync_err_irq           ),
  .ctrl_rx_en_emb_align_err_irq             (ctrl_rx_en_emb_align_err_irq            ),
  .ctrl_rx_en_crc_err_irq                   (ctrl_rx_en_crc_err_irq                  ),
  .ctrl_rx_en_fec_err_irq                   (ctrl_rx_en_fec_err_irq                  ),
  .ctrl_rx_en_over_err_irq                  (ctrl_rx_en_over_err_irq                 ),
  .ctrl_en_sync_irq                         (ctrl_en_sync_irq                        ),
  .ctrl_en_resync_irq                       (ctrl_en_resync_irq                      ),
  .ctrl_en_started_irq                      (ctrl_en_started_irq                     ),
  .stat_sysr_cap_irq                        (stat_sysr_cap_irq                       ),
  .stat_sysr_cap_irq_pls_h                  (stat_sysr_cap_irq_pls_h                 ),
  .stat_sysr_err_irq                        (stat_sysr_err_irq                       ),
  .stat_rx_sh_lock_irq                      (stat_rx_sh_lock_irq                     ),
  .stat_rx_emb_lock_irq                     (stat_rx_emb_lock_irq                    ),
  .stat_rx_block_sync_err_irq               (stat_rx_block_sync_err_irq              ),
  .stat_rx_emb_align_err_irq                (stat_rx_emb_align_err_irq               ),
  .stat_rx_crc_err_irq                      (stat_rx_crc_err_irq                     ),
  .stat_rx_fec_err_irq                      (stat_rx_fec_err_irq                     ),
  .stat_rx_over_err_irq                     (stat_rx_over_err_irq                    ),
  .stat_sync_irq                            (stat_sync_irq                           ),
  .stat_resync_irq                          (stat_resync_irq                         ),
  .stat_started_irq                         (stat_started_irq                        ),
  .ctrl_tx_ila_did                          (ctrl_tx_ila_did                         ),
  .ctrl_tx_ila_bid                          (ctrl_tx_ila_bid                         ),
  .ctrl_tx_ila_m                            (ctrl_tx_ila_m                           ),
  .ctrl_tx_ila_n                            (ctrl_tx_ila_n                           ),
  .ctrl_tx_ila_np                           (ctrl_tx_ila_np                          ),
  .ctrl_tx_ila_cs                           (ctrl_tx_ila_cs                          ),
  .ctrl_tx_ila_s                            (ctrl_tx_ila_s                           ),
  .ctrl_tx_ila_hd                           (ctrl_tx_ila_hd                          ),
  .ctrl_tx_ila_cf                           (ctrl_tx_ila_cf                          ),
  .ctrl_tx_ila_adjcnt                       (ctrl_tx_ila_adjcnt                      ),
  .ctrl_tx_ila_phadj                        (ctrl_tx_ila_phadj                       ),
  .ctrl_tx_ila_adjdir                       (ctrl_tx_ila_adjdir                      ),
  .ctrl_tx_ila_res1                         (ctrl_tx_ila_res1                        ),
  .ctrl_tx_ila_res2                         (ctrl_tx_ila_res2                        ),


  .slv_addr                                 (slv_addr                                ),
  .slv_wdata                                (slv_wdata                               ),
  .slv_rden                                 (strb_b0_slv_rden                        ),
  .slv_wren                                 (strb_b0_slv_wren                        ),

  .slv_wr_done                              (strb_b0_slv_wr_done                     ),
  .slv_rd_done                              (strb_b0_slv_rd_done                     ),
  .slv_rdata                                (strb_b0_slv_rdata                       ),

  .s_axi_aclk                               (s_axi_aclk                              ),
  .s_axi_aresetn                            (s_axi_aresetn                           )

);
//-----------------------------------------------------------------------------
// jesd204c_0_jesd204c_regif_lane register bank, with replicated IO and internal select
//-----------------------------------------------------------------------------
jesd204c_0_jesd204c_regif_lane #(
   .C_S_AXI_ADDR_WIDTH           (BANK_DECODE_HIGH_LOW)
) jesd204c_0_jesd204c_regif_lane_i (


  .stat_rx_buf_lvl_0                        (stat_rx_buf_lvl_0                       ),
  .ctrl_tx_ila_lid_0                        (ctrl_tx_ila_lid_0                       ),
  .ctrl_tx_ila_lid_0_pdef                   (ctrl_tx_ila_lid_0_pdef                  ),
  .ctrl_tx_ila_nll_0                        (ctrl_tx_ila_nll_0                       ),
  .ctrl_tx_ila_nll_0_pdef                   (ctrl_tx_ila_nll_0_pdef                  ),
  .stat_rx_err_cnt0_0                       (stat_rx_err_cnt0_0                      ),
  .stat_rx_err_cnt0_0_pls_h                 (stat_rx_err_cnt0_0_pls_h                ),
  .stat_rx_err_cnt1_0                       (stat_rx_err_cnt1_0                      ),
  .stat_rx_err_cnt1_0_pls_h                 (stat_rx_err_cnt1_0_pls_h                ),
  .stat_link_err_cnt_0                      (stat_link_err_cnt_0                     ),
  .stat_link_err_cnt_0_pls_h                (stat_link_err_cnt_0_pls_h               ),
  .stat_test_err_cnt_0                      (stat_test_err_cnt_0                     ),
  .stat_test_err_cnt_0_pls_h                (stat_test_err_cnt_0_pls_h               ),
  .stat_test_ila_cnt_0                      (stat_test_ila_cnt_0                     ),
  .stat_test_ila_cnt_0_pls_h                (stat_test_ila_cnt_0_pls_h               ),
  .stat_test_mf_cnt_0                       (stat_test_mf_cnt_0                      ),
  .stat_test_mf_cnt_0_pls_h                 (stat_test_mf_cnt_0_pls_h                ),
  .stat_rx_ila_jesdv_0                      (stat_rx_ila_jesdv_0                     ),
  .stat_rx_ila_subc_0                       (stat_rx_ila_subc_0                      ),
  .stat_rx_ila_f_0                          (stat_rx_ila_f_0                         ),
  .stat_rx_ila_k_0                          (stat_rx_ila_k_0                         ),
  .stat_rx_ila_did_0                        (stat_rx_ila_did_0                       ),
  .stat_rx_ila_bid_0                        (stat_rx_ila_bid_0                       ),
  .stat_rx_ila_lid_0                        (stat_rx_ila_lid_0                       ),
  .stat_rx_ila_l_0                          (stat_rx_ila_l_0                         ),
  .stat_rx_ila_m_0                          (stat_rx_ila_m_0                         ),
  .stat_rx_ila_n_0                          (stat_rx_ila_n_0                         ),
  .stat_rx_ila_np_0                         (stat_rx_ila_np_0                        ),
  .stat_rx_ila_cs_0                         (stat_rx_ila_cs_0                        ),
  .stat_rx_ila_scr_0                        (stat_rx_ila_scr_0                       ),
  .stat_rx_ila_s_0                          (stat_rx_ila_s_0                         ),
  .stat_rx_ila_hd_0                         (stat_rx_ila_hd_0                        ),
  .stat_rx_ila_cf_0                         (stat_rx_ila_cf_0                        ),
  .stat_rx_ila_adjcnt_0                     (stat_rx_ila_adjcnt_0                    ),
  .stat_rx_ila_phadj_0                      (stat_rx_ila_phadj_0                     ),
  .stat_rx_ila_adjdir_0                     (stat_rx_ila_adjdir_0                    ),
  .stat_rx_ila_res1_0                       (stat_rx_ila_res1_0                      ),
  .stat_rx_ila_res2_0                       (stat_rx_ila_res2_0                      ),
  .stat_rx_ila_fchk_0                       (stat_rx_ila_fchk_0                      ),
  .ctrl_tx_gtpolarity_0                     (ctrl_tx_gtpolarity_0                    ),
  .ctrl_tx_gtpd_0                           (ctrl_tx_gtpd_0                          ),
  .ctrl_tx_gtelecidle_0                     (ctrl_tx_gtelecidle_0                    ),
  .ctrl_tx_gtinhibit_0                      (ctrl_tx_gtinhibit_0                     ),
  .ctrl_tx_gtdiffctrl_0                     (ctrl_tx_gtdiffctrl_0                    ),
  .ctrl_tx_gtpostcursor_0                   (ctrl_tx_gtpostcursor_0                  ),
  .ctrl_tx_gtprecursor_0                    (ctrl_tx_gtprecursor_0                   ),
  .ctrl_rx_gtpolarity_0                     (ctrl_rx_gtpolarity_0                    ),
  .ctrl_rx_gtpd_0                           (ctrl_rx_gtpd_0                          ),

  .stat_rx_buf_lvl_1                        (stat_rx_buf_lvl_1                       ),
  .ctrl_tx_ila_lid_1                        (ctrl_tx_ila_lid_1                       ),
  .ctrl_tx_ila_lid_1_pdef                   (ctrl_tx_ila_lid_1_pdef                  ),
  .ctrl_tx_ila_nll_1                        (ctrl_tx_ila_nll_1                       ),
  .ctrl_tx_ila_nll_1_pdef                   (ctrl_tx_ila_nll_1_pdef                  ),
  .stat_rx_err_cnt0_1                       (stat_rx_err_cnt0_1                      ),
  .stat_rx_err_cnt0_1_pls_h                 (stat_rx_err_cnt0_1_pls_h                ),
  .stat_rx_err_cnt1_1                       (stat_rx_err_cnt1_1                      ),
  .stat_rx_err_cnt1_1_pls_h                 (stat_rx_err_cnt1_1_pls_h                ),
  .stat_link_err_cnt_1                      (stat_link_err_cnt_1                     ),
  .stat_link_err_cnt_1_pls_h                (stat_link_err_cnt_1_pls_h               ),
  .stat_test_err_cnt_1                      (stat_test_err_cnt_1                     ),
  .stat_test_err_cnt_1_pls_h                (stat_test_err_cnt_1_pls_h               ),
  .stat_test_ila_cnt_1                      (stat_test_ila_cnt_1                     ),
  .stat_test_ila_cnt_1_pls_h                (stat_test_ila_cnt_1_pls_h               ),
  .stat_test_mf_cnt_1                       (stat_test_mf_cnt_1                      ),
  .stat_test_mf_cnt_1_pls_h                 (stat_test_mf_cnt_1_pls_h                ),
  .stat_rx_ila_jesdv_1                      (stat_rx_ila_jesdv_1                     ),
  .stat_rx_ila_subc_1                       (stat_rx_ila_subc_1                      ),
  .stat_rx_ila_f_1                          (stat_rx_ila_f_1                         ),
  .stat_rx_ila_k_1                          (stat_rx_ila_k_1                         ),
  .stat_rx_ila_did_1                        (stat_rx_ila_did_1                       ),
  .stat_rx_ila_bid_1                        (stat_rx_ila_bid_1                       ),
  .stat_rx_ila_lid_1                        (stat_rx_ila_lid_1                       ),
  .stat_rx_ila_l_1                          (stat_rx_ila_l_1                         ),
  .stat_rx_ila_m_1                          (stat_rx_ila_m_1                         ),
  .stat_rx_ila_n_1                          (stat_rx_ila_n_1                         ),
  .stat_rx_ila_np_1                         (stat_rx_ila_np_1                        ),
  .stat_rx_ila_cs_1                         (stat_rx_ila_cs_1                        ),
  .stat_rx_ila_scr_1                        (stat_rx_ila_scr_1                       ),
  .stat_rx_ila_s_1                          (stat_rx_ila_s_1                         ),
  .stat_rx_ila_hd_1                         (stat_rx_ila_hd_1                        ),
  .stat_rx_ila_cf_1                         (stat_rx_ila_cf_1                        ),
  .stat_rx_ila_adjcnt_1                     (stat_rx_ila_adjcnt_1                    ),
  .stat_rx_ila_phadj_1                      (stat_rx_ila_phadj_1                     ),
  .stat_rx_ila_adjdir_1                     (stat_rx_ila_adjdir_1                    ),
  .stat_rx_ila_res1_1                       (stat_rx_ila_res1_1                      ),
  .stat_rx_ila_res2_1                       (stat_rx_ila_res2_1                      ),
  .stat_rx_ila_fchk_1                       (stat_rx_ila_fchk_1                      ),
  .ctrl_tx_gtpolarity_1                     (ctrl_tx_gtpolarity_1                    ),
  .ctrl_tx_gtpd_1                           (ctrl_tx_gtpd_1                          ),
  .ctrl_tx_gtelecidle_1                     (ctrl_tx_gtelecidle_1                    ),
  .ctrl_tx_gtinhibit_1                      (ctrl_tx_gtinhibit_1                     ),
  .ctrl_tx_gtdiffctrl_1                     (ctrl_tx_gtdiffctrl_1                    ),
  .ctrl_tx_gtpostcursor_1                   (ctrl_tx_gtpostcursor_1                  ),
  .ctrl_tx_gtprecursor_1                    (ctrl_tx_gtprecursor_1                   ),
  .ctrl_rx_gtpolarity_1                     (ctrl_rx_gtpolarity_1                    ),
  .ctrl_rx_gtpd_1                           (ctrl_rx_gtpd_1                          ),

  .stat_rx_buf_lvl_2                        (stat_rx_buf_lvl_2                       ),
  .ctrl_tx_ila_lid_2                        (ctrl_tx_ila_lid_2                       ),
  .ctrl_tx_ila_lid_2_pdef                   (ctrl_tx_ila_lid_2_pdef                  ),
  .ctrl_tx_ila_nll_2                        (ctrl_tx_ila_nll_2                       ),
  .ctrl_tx_ila_nll_2_pdef                   (ctrl_tx_ila_nll_2_pdef                  ),
  .stat_rx_err_cnt0_2                       (stat_rx_err_cnt0_2                      ),
  .stat_rx_err_cnt0_2_pls_h                 (stat_rx_err_cnt0_2_pls_h                ),
  .stat_rx_err_cnt1_2                       (stat_rx_err_cnt1_2                      ),
  .stat_rx_err_cnt1_2_pls_h                 (stat_rx_err_cnt1_2_pls_h                ),
  .stat_link_err_cnt_2                      (stat_link_err_cnt_2                     ),
  .stat_link_err_cnt_2_pls_h                (stat_link_err_cnt_2_pls_h               ),
  .stat_test_err_cnt_2                      (stat_test_err_cnt_2                     ),
  .stat_test_err_cnt_2_pls_h                (stat_test_err_cnt_2_pls_h               ),
  .stat_test_ila_cnt_2                      (stat_test_ila_cnt_2                     ),
  .stat_test_ila_cnt_2_pls_h                (stat_test_ila_cnt_2_pls_h               ),
  .stat_test_mf_cnt_2                       (stat_test_mf_cnt_2                      ),
  .stat_test_mf_cnt_2_pls_h                 (stat_test_mf_cnt_2_pls_h                ),
  .stat_rx_ila_jesdv_2                      (stat_rx_ila_jesdv_2                     ),
  .stat_rx_ila_subc_2                       (stat_rx_ila_subc_2                      ),
  .stat_rx_ila_f_2                          (stat_rx_ila_f_2                         ),
  .stat_rx_ila_k_2                          (stat_rx_ila_k_2                         ),
  .stat_rx_ila_did_2                        (stat_rx_ila_did_2                       ),
  .stat_rx_ila_bid_2                        (stat_rx_ila_bid_2                       ),
  .stat_rx_ila_lid_2                        (stat_rx_ila_lid_2                       ),
  .stat_rx_ila_l_2                          (stat_rx_ila_l_2                         ),
  .stat_rx_ila_m_2                          (stat_rx_ila_m_2                         ),
  .stat_rx_ila_n_2                          (stat_rx_ila_n_2                         ),
  .stat_rx_ila_np_2                         (stat_rx_ila_np_2                        ),
  .stat_rx_ila_cs_2                         (stat_rx_ila_cs_2                        ),
  .stat_rx_ila_scr_2                        (stat_rx_ila_scr_2                       ),
  .stat_rx_ila_s_2                          (stat_rx_ila_s_2                         ),
  .stat_rx_ila_hd_2                         (stat_rx_ila_hd_2                        ),
  .stat_rx_ila_cf_2                         (stat_rx_ila_cf_2                        ),
  .stat_rx_ila_adjcnt_2                     (stat_rx_ila_adjcnt_2                    ),
  .stat_rx_ila_phadj_2                      (stat_rx_ila_phadj_2                     ),
  .stat_rx_ila_adjdir_2                     (stat_rx_ila_adjdir_2                    ),
  .stat_rx_ila_res1_2                       (stat_rx_ila_res1_2                      ),
  .stat_rx_ila_res2_2                       (stat_rx_ila_res2_2                      ),
  .stat_rx_ila_fchk_2                       (stat_rx_ila_fchk_2                      ),
  .ctrl_tx_gtpolarity_2                     (ctrl_tx_gtpolarity_2                    ),
  .ctrl_tx_gtpd_2                           (ctrl_tx_gtpd_2                          ),
  .ctrl_tx_gtelecidle_2                     (ctrl_tx_gtelecidle_2                    ),
  .ctrl_tx_gtinhibit_2                      (ctrl_tx_gtinhibit_2                     ),
  .ctrl_tx_gtdiffctrl_2                     (ctrl_tx_gtdiffctrl_2                    ),
  .ctrl_tx_gtpostcursor_2                   (ctrl_tx_gtpostcursor_2                  ),
  .ctrl_tx_gtprecursor_2                    (ctrl_tx_gtprecursor_2                   ),
  .ctrl_rx_gtpolarity_2                     (ctrl_rx_gtpolarity_2                    ),
  .ctrl_rx_gtpd_2                           (ctrl_rx_gtpd_2                          ),

  .stat_rx_buf_lvl_3                        (stat_rx_buf_lvl_3                       ),
  .ctrl_tx_ila_lid_3                        (ctrl_tx_ila_lid_3                       ),
  .ctrl_tx_ila_lid_3_pdef                   (ctrl_tx_ila_lid_3_pdef                  ),
  .ctrl_tx_ila_nll_3                        (ctrl_tx_ila_nll_3                       ),
  .ctrl_tx_ila_nll_3_pdef                   (ctrl_tx_ila_nll_3_pdef                  ),
  .stat_rx_err_cnt0_3                       (stat_rx_err_cnt0_3                      ),
  .stat_rx_err_cnt0_3_pls_h                 (stat_rx_err_cnt0_3_pls_h                ),
  .stat_rx_err_cnt1_3                       (stat_rx_err_cnt1_3                      ),
  .stat_rx_err_cnt1_3_pls_h                 (stat_rx_err_cnt1_3_pls_h                ),
  .stat_link_err_cnt_3                      (stat_link_err_cnt_3                     ),
  .stat_link_err_cnt_3_pls_h                (stat_link_err_cnt_3_pls_h               ),
  .stat_test_err_cnt_3                      (stat_test_err_cnt_3                     ),
  .stat_test_err_cnt_3_pls_h                (stat_test_err_cnt_3_pls_h               ),
  .stat_test_ila_cnt_3                      (stat_test_ila_cnt_3                     ),
  .stat_test_ila_cnt_3_pls_h                (stat_test_ila_cnt_3_pls_h               ),
  .stat_test_mf_cnt_3                       (stat_test_mf_cnt_3                      ),
  .stat_test_mf_cnt_3_pls_h                 (stat_test_mf_cnt_3_pls_h                ),
  .stat_rx_ila_jesdv_3                      (stat_rx_ila_jesdv_3                     ),
  .stat_rx_ila_subc_3                       (stat_rx_ila_subc_3                      ),
  .stat_rx_ila_f_3                          (stat_rx_ila_f_3                         ),
  .stat_rx_ila_k_3                          (stat_rx_ila_k_3                         ),
  .stat_rx_ila_did_3                        (stat_rx_ila_did_3                       ),
  .stat_rx_ila_bid_3                        (stat_rx_ila_bid_3                       ),
  .stat_rx_ila_lid_3                        (stat_rx_ila_lid_3                       ),
  .stat_rx_ila_l_3                          (stat_rx_ila_l_3                         ),
  .stat_rx_ila_m_3                          (stat_rx_ila_m_3                         ),
  .stat_rx_ila_n_3                          (stat_rx_ila_n_3                         ),
  .stat_rx_ila_np_3                         (stat_rx_ila_np_3                        ),
  .stat_rx_ila_cs_3                         (stat_rx_ila_cs_3                        ),
  .stat_rx_ila_scr_3                        (stat_rx_ila_scr_3                       ),
  .stat_rx_ila_s_3                          (stat_rx_ila_s_3                         ),
  .stat_rx_ila_hd_3                         (stat_rx_ila_hd_3                        ),
  .stat_rx_ila_cf_3                         (stat_rx_ila_cf_3                        ),
  .stat_rx_ila_adjcnt_3                     (stat_rx_ila_adjcnt_3                    ),
  .stat_rx_ila_phadj_3                      (stat_rx_ila_phadj_3                     ),
  .stat_rx_ila_adjdir_3                     (stat_rx_ila_adjdir_3                    ),
  .stat_rx_ila_res1_3                       (stat_rx_ila_res1_3                      ),
  .stat_rx_ila_res2_3                       (stat_rx_ila_res2_3                      ),
  .stat_rx_ila_fchk_3                       (stat_rx_ila_fchk_3                      ),
  .ctrl_tx_gtpolarity_3                     (ctrl_tx_gtpolarity_3                    ),
  .ctrl_tx_gtpd_3                           (ctrl_tx_gtpd_3                          ),
  .ctrl_tx_gtelecidle_3                     (ctrl_tx_gtelecidle_3                    ),
  .ctrl_tx_gtinhibit_3                      (ctrl_tx_gtinhibit_3                     ),
  .ctrl_tx_gtdiffctrl_3                     (ctrl_tx_gtdiffctrl_3                    ),
  .ctrl_tx_gtpostcursor_3                   (ctrl_tx_gtpostcursor_3                  ),
  .ctrl_tx_gtprecursor_3                    (ctrl_tx_gtprecursor_3                   ),
  .ctrl_rx_gtpolarity_3                     (ctrl_rx_gtpolarity_3                    ),
  .ctrl_rx_gtpd_3                           (ctrl_rx_gtpd_3                          ),

  .stat_rx_buf_lvl_4                        (stat_rx_buf_lvl_4                       ),
  .ctrl_tx_ila_lid_4                        (ctrl_tx_ila_lid_4                       ),
  .ctrl_tx_ila_lid_4_pdef                   (ctrl_tx_ila_lid_4_pdef                  ),
  .ctrl_tx_ila_nll_4                        (ctrl_tx_ila_nll_4                       ),
  .ctrl_tx_ila_nll_4_pdef                   (ctrl_tx_ila_nll_4_pdef                  ),
  .stat_rx_err_cnt0_4                       (stat_rx_err_cnt0_4                      ),
  .stat_rx_err_cnt0_4_pls_h                 (stat_rx_err_cnt0_4_pls_h                ),
  .stat_rx_err_cnt1_4                       (stat_rx_err_cnt1_4                      ),
  .stat_rx_err_cnt1_4_pls_h                 (stat_rx_err_cnt1_4_pls_h                ),
  .stat_link_err_cnt_4                      (stat_link_err_cnt_4                     ),
  .stat_link_err_cnt_4_pls_h                (stat_link_err_cnt_4_pls_h               ),
  .stat_test_err_cnt_4                      (stat_test_err_cnt_4                     ),
  .stat_test_err_cnt_4_pls_h                (stat_test_err_cnt_4_pls_h               ),
  .stat_test_ila_cnt_4                      (stat_test_ila_cnt_4                     ),
  .stat_test_ila_cnt_4_pls_h                (stat_test_ila_cnt_4_pls_h               ),
  .stat_test_mf_cnt_4                       (stat_test_mf_cnt_4                      ),
  .stat_test_mf_cnt_4_pls_h                 (stat_test_mf_cnt_4_pls_h                ),
  .stat_rx_ila_jesdv_4                      (stat_rx_ila_jesdv_4                     ),
  .stat_rx_ila_subc_4                       (stat_rx_ila_subc_4                      ),
  .stat_rx_ila_f_4                          (stat_rx_ila_f_4                         ),
  .stat_rx_ila_k_4                          (stat_rx_ila_k_4                         ),
  .stat_rx_ila_did_4                        (stat_rx_ila_did_4                       ),
  .stat_rx_ila_bid_4                        (stat_rx_ila_bid_4                       ),
  .stat_rx_ila_lid_4                        (stat_rx_ila_lid_4                       ),
  .stat_rx_ila_l_4                          (stat_rx_ila_l_4                         ),
  .stat_rx_ila_m_4                          (stat_rx_ila_m_4                         ),
  .stat_rx_ila_n_4                          (stat_rx_ila_n_4                         ),
  .stat_rx_ila_np_4                         (stat_rx_ila_np_4                        ),
  .stat_rx_ila_cs_4                         (stat_rx_ila_cs_4                        ),
  .stat_rx_ila_scr_4                        (stat_rx_ila_scr_4                       ),
  .stat_rx_ila_s_4                          (stat_rx_ila_s_4                         ),
  .stat_rx_ila_hd_4                         (stat_rx_ila_hd_4                        ),
  .stat_rx_ila_cf_4                         (stat_rx_ila_cf_4                        ),
  .stat_rx_ila_adjcnt_4                     (stat_rx_ila_adjcnt_4                    ),
  .stat_rx_ila_phadj_4                      (stat_rx_ila_phadj_4                     ),
  .stat_rx_ila_adjdir_4                     (stat_rx_ila_adjdir_4                    ),
  .stat_rx_ila_res1_4                       (stat_rx_ila_res1_4                      ),
  .stat_rx_ila_res2_4                       (stat_rx_ila_res2_4                      ),
  .stat_rx_ila_fchk_4                       (stat_rx_ila_fchk_4                      ),
  .ctrl_tx_gtpolarity_4                     (ctrl_tx_gtpolarity_4                    ),
  .ctrl_tx_gtpd_4                           (ctrl_tx_gtpd_4                          ),
  .ctrl_tx_gtelecidle_4                     (ctrl_tx_gtelecidle_4                    ),
  .ctrl_tx_gtinhibit_4                      (ctrl_tx_gtinhibit_4                     ),
  .ctrl_tx_gtdiffctrl_4                     (ctrl_tx_gtdiffctrl_4                    ),
  .ctrl_tx_gtpostcursor_4                   (ctrl_tx_gtpostcursor_4                  ),
  .ctrl_tx_gtprecursor_4                    (ctrl_tx_gtprecursor_4                   ),
  .ctrl_rx_gtpolarity_4                     (ctrl_rx_gtpolarity_4                    ),
  .ctrl_rx_gtpd_4                           (ctrl_rx_gtpd_4                          ),

  .stat_rx_buf_lvl_5                        (stat_rx_buf_lvl_5                       ),
  .ctrl_tx_ila_lid_5                        (ctrl_tx_ila_lid_5                       ),
  .ctrl_tx_ila_lid_5_pdef                   (ctrl_tx_ila_lid_5_pdef                  ),
  .ctrl_tx_ila_nll_5                        (ctrl_tx_ila_nll_5                       ),
  .ctrl_tx_ila_nll_5_pdef                   (ctrl_tx_ila_nll_5_pdef                  ),
  .stat_rx_err_cnt0_5                       (stat_rx_err_cnt0_5                      ),
  .stat_rx_err_cnt0_5_pls_h                 (stat_rx_err_cnt0_5_pls_h                ),
  .stat_rx_err_cnt1_5                       (stat_rx_err_cnt1_5                      ),
  .stat_rx_err_cnt1_5_pls_h                 (stat_rx_err_cnt1_5_pls_h                ),
  .stat_link_err_cnt_5                      (stat_link_err_cnt_5                     ),
  .stat_link_err_cnt_5_pls_h                (stat_link_err_cnt_5_pls_h               ),
  .stat_test_err_cnt_5                      (stat_test_err_cnt_5                     ),
  .stat_test_err_cnt_5_pls_h                (stat_test_err_cnt_5_pls_h               ),
  .stat_test_ila_cnt_5                      (stat_test_ila_cnt_5                     ),
  .stat_test_ila_cnt_5_pls_h                (stat_test_ila_cnt_5_pls_h               ),
  .stat_test_mf_cnt_5                       (stat_test_mf_cnt_5                      ),
  .stat_test_mf_cnt_5_pls_h                 (stat_test_mf_cnt_5_pls_h                ),
  .stat_rx_ila_jesdv_5                      (stat_rx_ila_jesdv_5                     ),
  .stat_rx_ila_subc_5                       (stat_rx_ila_subc_5                      ),
  .stat_rx_ila_f_5                          (stat_rx_ila_f_5                         ),
  .stat_rx_ila_k_5                          (stat_rx_ila_k_5                         ),
  .stat_rx_ila_did_5                        (stat_rx_ila_did_5                       ),
  .stat_rx_ila_bid_5                        (stat_rx_ila_bid_5                       ),
  .stat_rx_ila_lid_5                        (stat_rx_ila_lid_5                       ),
  .stat_rx_ila_l_5                          (stat_rx_ila_l_5                         ),
  .stat_rx_ila_m_5                          (stat_rx_ila_m_5                         ),
  .stat_rx_ila_n_5                          (stat_rx_ila_n_5                         ),
  .stat_rx_ila_np_5                         (stat_rx_ila_np_5                        ),
  .stat_rx_ila_cs_5                         (stat_rx_ila_cs_5                        ),
  .stat_rx_ila_scr_5                        (stat_rx_ila_scr_5                       ),
  .stat_rx_ila_s_5                          (stat_rx_ila_s_5                         ),
  .stat_rx_ila_hd_5                         (stat_rx_ila_hd_5                        ),
  .stat_rx_ila_cf_5                         (stat_rx_ila_cf_5                        ),
  .stat_rx_ila_adjcnt_5                     (stat_rx_ila_adjcnt_5                    ),
  .stat_rx_ila_phadj_5                      (stat_rx_ila_phadj_5                     ),
  .stat_rx_ila_adjdir_5                     (stat_rx_ila_adjdir_5                    ),
  .stat_rx_ila_res1_5                       (stat_rx_ila_res1_5                      ),
  .stat_rx_ila_res2_5                       (stat_rx_ila_res2_5                      ),
  .stat_rx_ila_fchk_5                       (stat_rx_ila_fchk_5                      ),
  .ctrl_tx_gtpolarity_5                     (ctrl_tx_gtpolarity_5                    ),
  .ctrl_tx_gtpd_5                           (ctrl_tx_gtpd_5                          ),
  .ctrl_tx_gtelecidle_5                     (ctrl_tx_gtelecidle_5                    ),
  .ctrl_tx_gtinhibit_5                      (ctrl_tx_gtinhibit_5                     ),
  .ctrl_tx_gtdiffctrl_5                     (ctrl_tx_gtdiffctrl_5                    ),
  .ctrl_tx_gtpostcursor_5                   (ctrl_tx_gtpostcursor_5                  ),
  .ctrl_tx_gtprecursor_5                    (ctrl_tx_gtprecursor_5                   ),
  .ctrl_rx_gtpolarity_5                     (ctrl_rx_gtpolarity_5                    ),
  .ctrl_rx_gtpd_5                           (ctrl_rx_gtpd_5                          ),

  .stat_rx_buf_lvl_6                        (stat_rx_buf_lvl_6                       ),
  .ctrl_tx_ila_lid_6                        (ctrl_tx_ila_lid_6                       ),
  .ctrl_tx_ila_lid_6_pdef                   (ctrl_tx_ila_lid_6_pdef                  ),
  .ctrl_tx_ila_nll_6                        (ctrl_tx_ila_nll_6                       ),
  .ctrl_tx_ila_nll_6_pdef                   (ctrl_tx_ila_nll_6_pdef                  ),
  .stat_rx_err_cnt0_6                       (stat_rx_err_cnt0_6                      ),
  .stat_rx_err_cnt0_6_pls_h                 (stat_rx_err_cnt0_6_pls_h                ),
  .stat_rx_err_cnt1_6                       (stat_rx_err_cnt1_6                      ),
  .stat_rx_err_cnt1_6_pls_h                 (stat_rx_err_cnt1_6_pls_h                ),
  .stat_link_err_cnt_6                      (stat_link_err_cnt_6                     ),
  .stat_link_err_cnt_6_pls_h                (stat_link_err_cnt_6_pls_h               ),
  .stat_test_err_cnt_6                      (stat_test_err_cnt_6                     ),
  .stat_test_err_cnt_6_pls_h                (stat_test_err_cnt_6_pls_h               ),
  .stat_test_ila_cnt_6                      (stat_test_ila_cnt_6                     ),
  .stat_test_ila_cnt_6_pls_h                (stat_test_ila_cnt_6_pls_h               ),
  .stat_test_mf_cnt_6                       (stat_test_mf_cnt_6                      ),
  .stat_test_mf_cnt_6_pls_h                 (stat_test_mf_cnt_6_pls_h                ),
  .stat_rx_ila_jesdv_6                      (stat_rx_ila_jesdv_6                     ),
  .stat_rx_ila_subc_6                       (stat_rx_ila_subc_6                      ),
  .stat_rx_ila_f_6                          (stat_rx_ila_f_6                         ),
  .stat_rx_ila_k_6                          (stat_rx_ila_k_6                         ),
  .stat_rx_ila_did_6                        (stat_rx_ila_did_6                       ),
  .stat_rx_ila_bid_6                        (stat_rx_ila_bid_6                       ),
  .stat_rx_ila_lid_6                        (stat_rx_ila_lid_6                       ),
  .stat_rx_ila_l_6                          (stat_rx_ila_l_6                         ),
  .stat_rx_ila_m_6                          (stat_rx_ila_m_6                         ),
  .stat_rx_ila_n_6                          (stat_rx_ila_n_6                         ),
  .stat_rx_ila_np_6                         (stat_rx_ila_np_6                        ),
  .stat_rx_ila_cs_6                         (stat_rx_ila_cs_6                        ),
  .stat_rx_ila_scr_6                        (stat_rx_ila_scr_6                       ),
  .stat_rx_ila_s_6                          (stat_rx_ila_s_6                         ),
  .stat_rx_ila_hd_6                         (stat_rx_ila_hd_6                        ),
  .stat_rx_ila_cf_6                         (stat_rx_ila_cf_6                        ),
  .stat_rx_ila_adjcnt_6                     (stat_rx_ila_adjcnt_6                    ),
  .stat_rx_ila_phadj_6                      (stat_rx_ila_phadj_6                     ),
  .stat_rx_ila_adjdir_6                     (stat_rx_ila_adjdir_6                    ),
  .stat_rx_ila_res1_6                       (stat_rx_ila_res1_6                      ),
  .stat_rx_ila_res2_6                       (stat_rx_ila_res2_6                      ),
  .stat_rx_ila_fchk_6                       (stat_rx_ila_fchk_6                      ),
  .ctrl_tx_gtpolarity_6                     (ctrl_tx_gtpolarity_6                    ),
  .ctrl_tx_gtpd_6                           (ctrl_tx_gtpd_6                          ),
  .ctrl_tx_gtelecidle_6                     (ctrl_tx_gtelecidle_6                    ),
  .ctrl_tx_gtinhibit_6                      (ctrl_tx_gtinhibit_6                     ),
  .ctrl_tx_gtdiffctrl_6                     (ctrl_tx_gtdiffctrl_6                    ),
  .ctrl_tx_gtpostcursor_6                   (ctrl_tx_gtpostcursor_6                  ),
  .ctrl_tx_gtprecursor_6                    (ctrl_tx_gtprecursor_6                   ),
  .ctrl_rx_gtpolarity_6                     (ctrl_rx_gtpolarity_6                    ),
  .ctrl_rx_gtpd_6                           (ctrl_rx_gtpd_6                          ),

  .stat_rx_buf_lvl_7                        (stat_rx_buf_lvl_7                       ),
  .ctrl_tx_ila_lid_7                        (ctrl_tx_ila_lid_7                       ),
  .ctrl_tx_ila_lid_7_pdef                   (ctrl_tx_ila_lid_7_pdef                  ),
  .ctrl_tx_ila_nll_7                        (ctrl_tx_ila_nll_7                       ),
  .ctrl_tx_ila_nll_7_pdef                   (ctrl_tx_ila_nll_7_pdef                  ),
  .stat_rx_err_cnt0_7                       (stat_rx_err_cnt0_7                      ),
  .stat_rx_err_cnt0_7_pls_h                 (stat_rx_err_cnt0_7_pls_h                ),
  .stat_rx_err_cnt1_7                       (stat_rx_err_cnt1_7                      ),
  .stat_rx_err_cnt1_7_pls_h                 (stat_rx_err_cnt1_7_pls_h                ),
  .stat_link_err_cnt_7                      (stat_link_err_cnt_7                     ),
  .stat_link_err_cnt_7_pls_h                (stat_link_err_cnt_7_pls_h               ),
  .stat_test_err_cnt_7                      (stat_test_err_cnt_7                     ),
  .stat_test_err_cnt_7_pls_h                (stat_test_err_cnt_7_pls_h               ),
  .stat_test_ila_cnt_7                      (stat_test_ila_cnt_7                     ),
  .stat_test_ila_cnt_7_pls_h                (stat_test_ila_cnt_7_pls_h               ),
  .stat_test_mf_cnt_7                       (stat_test_mf_cnt_7                      ),
  .stat_test_mf_cnt_7_pls_h                 (stat_test_mf_cnt_7_pls_h                ),
  .stat_rx_ila_jesdv_7                      (stat_rx_ila_jesdv_7                     ),
  .stat_rx_ila_subc_7                       (stat_rx_ila_subc_7                      ),
  .stat_rx_ila_f_7                          (stat_rx_ila_f_7                         ),
  .stat_rx_ila_k_7                          (stat_rx_ila_k_7                         ),
  .stat_rx_ila_did_7                        (stat_rx_ila_did_7                       ),
  .stat_rx_ila_bid_7                        (stat_rx_ila_bid_7                       ),
  .stat_rx_ila_lid_7                        (stat_rx_ila_lid_7                       ),
  .stat_rx_ila_l_7                          (stat_rx_ila_l_7                         ),
  .stat_rx_ila_m_7                          (stat_rx_ila_m_7                         ),
  .stat_rx_ila_n_7                          (stat_rx_ila_n_7                         ),
  .stat_rx_ila_np_7                         (stat_rx_ila_np_7                        ),
  .stat_rx_ila_cs_7                         (stat_rx_ila_cs_7                        ),
  .stat_rx_ila_scr_7                        (stat_rx_ila_scr_7                       ),
  .stat_rx_ila_s_7                          (stat_rx_ila_s_7                         ),
  .stat_rx_ila_hd_7                         (stat_rx_ila_hd_7                        ),
  .stat_rx_ila_cf_7                         (stat_rx_ila_cf_7                        ),
  .stat_rx_ila_adjcnt_7                     (stat_rx_ila_adjcnt_7                    ),
  .stat_rx_ila_phadj_7                      (stat_rx_ila_phadj_7                     ),
  .stat_rx_ila_adjdir_7                     (stat_rx_ila_adjdir_7                    ),
  .stat_rx_ila_res1_7                       (stat_rx_ila_res1_7                      ),
  .stat_rx_ila_res2_7                       (stat_rx_ila_res2_7                      ),
  .stat_rx_ila_fchk_7                       (stat_rx_ila_fchk_7                      ),
  .ctrl_tx_gtpolarity_7                     (ctrl_tx_gtpolarity_7                    ),
  .ctrl_tx_gtpd_7                           (ctrl_tx_gtpd_7                          ),
  .ctrl_tx_gtelecidle_7                     (ctrl_tx_gtelecidle_7                    ),
  .ctrl_tx_gtinhibit_7                      (ctrl_tx_gtinhibit_7                     ),
  .ctrl_tx_gtdiffctrl_7                     (ctrl_tx_gtdiffctrl_7                    ),
  .ctrl_tx_gtpostcursor_7                   (ctrl_tx_gtpostcursor_7                  ),
  .ctrl_tx_gtprecursor_7                    (ctrl_tx_gtprecursor_7                   ),
  .ctrl_rx_gtpolarity_7                     (ctrl_rx_gtpolarity_7                    ),
  .ctrl_rx_gtpd_7                           (ctrl_rx_gtpd_7                          ),

  .slv_addr                                 (slv_addr                                ),
  .slv_wdata                                (slv_wdata                               ),
  .slv_rden                                 (strb_b1_slv_rden                        ),
  .slv_wren                                 (strb_b1_slv_wren                        ),

  .slv_wr_done                              (strb_b1_slv_wr_done                     ),
  .slv_rd_done                              (strb_b1_slv_rd_done                     ),
  .slv_rdata                                (strb_b1_slv_rdata                       ),

  .s_axi_aclk                               (s_axi_aclk                              ),
  .s_axi_aresetn                            (s_axi_aresetn                           )

);


//-----------------------------------------------------------------------------
// Signal bus assignments for BANK jesd204c_regif_lane
//-----------------------------------------------------------------------------
assign stat_rx_buf_lvl_0                        = stat_rx_buf_lvl[9:0];
assign ctrl_tx_ila_lid[4:0]                     = ctrl_tx_ila_lid_0;
assign ctrl_tx_ila_lid_0_pdef                   = ctrl_tx_ila_lid_pdef[4:0];
assign ctrl_tx_ila_nll[4:0]                     = ctrl_tx_ila_nll_0;
assign ctrl_tx_ila_nll_0_pdef                   = ctrl_tx_ila_nll_pdef[4:0];
assign stat_rx_err_cnt0_0                       = stat_rx_err_cnt0[31:0];
assign stat_rx_err_cnt0_pls_h[0]                = stat_rx_err_cnt0_0_pls_h;
assign stat_rx_err_cnt1_0                       = stat_rx_err_cnt1[31:0];
assign stat_rx_err_cnt1_pls_h[0]                = stat_rx_err_cnt1_0_pls_h;
assign stat_link_err_cnt_0                      = stat_link_err_cnt[31:0];
assign stat_link_err_cnt_pls_h[0]               = stat_link_err_cnt_0_pls_h;
assign stat_test_err_cnt_0                      = stat_test_err_cnt[31:0];
assign stat_test_err_cnt_pls_h[0]               = stat_test_err_cnt_0_pls_h;
assign stat_test_ila_cnt_0                      = stat_test_ila_cnt[31:0];
assign stat_test_ila_cnt_pls_h[0]               = stat_test_ila_cnt_0_pls_h;
assign stat_test_mf_cnt_0                       = stat_test_mf_cnt[31:0];
assign stat_test_mf_cnt_pls_h[0]                = stat_test_mf_cnt_0_pls_h;
assign stat_rx_ila_jesdv_0                      = stat_rx_ila_jesdv[2:0];
assign stat_rx_ila_subc_0                       = stat_rx_ila_subc[2:0];
assign stat_rx_ila_f_0                          = stat_rx_ila_f[7:0];
assign stat_rx_ila_k_0                          = stat_rx_ila_k[4:0];
assign stat_rx_ila_did_0                        = stat_rx_ila_did[7:0];
assign stat_rx_ila_bid_0                        = stat_rx_ila_bid[3:0];
assign stat_rx_ila_lid_0                        = stat_rx_ila_lid[4:0];
assign stat_rx_ila_l_0                          = stat_rx_ila_l[4:0];
assign stat_rx_ila_m_0                          = stat_rx_ila_m[7:0];
assign stat_rx_ila_n_0                          = stat_rx_ila_n[4:0];
assign stat_rx_ila_np_0                         = stat_rx_ila_np[4:0];
assign stat_rx_ila_cs_0                         = stat_rx_ila_cs[1:0];
assign stat_rx_ila_scr_0                        = stat_rx_ila_scr[0];
assign stat_rx_ila_s_0                          = stat_rx_ila_s[4:0];
assign stat_rx_ila_hd_0                         = stat_rx_ila_hd[0];
assign stat_rx_ila_cf_0                         = stat_rx_ila_cf[4:0];
assign stat_rx_ila_adjcnt_0                     = stat_rx_ila_adjcnt[3:0];
assign stat_rx_ila_phadj_0                      = stat_rx_ila_phadj[0];
assign stat_rx_ila_adjdir_0                     = stat_rx_ila_adjdir[0];
assign stat_rx_ila_res1_0                       = stat_rx_ila_res1[7:0];
assign stat_rx_ila_res2_0                       = stat_rx_ila_res2[7:0];
assign stat_rx_ila_fchk_0                       = stat_rx_ila_fchk[7:0];
assign ctrl_tx_gtpolarity[0]                    = ctrl_tx_gtpolarity_0;
assign ctrl_tx_gtpd[1:0]                        = ctrl_tx_gtpd_0;
assign ctrl_tx_gtelecidle[0]                    = ctrl_tx_gtelecidle_0;
assign ctrl_tx_gtinhibit[0]                     = ctrl_tx_gtinhibit_0;
assign ctrl_tx_gtdiffctrl[4:0]                  = ctrl_tx_gtdiffctrl_0;
assign ctrl_tx_gtpostcursor[4:0]                = ctrl_tx_gtpostcursor_0;
assign ctrl_tx_gtprecursor[4:0]                 = ctrl_tx_gtprecursor_0;
assign ctrl_rx_gtpolarity[0]                    = ctrl_rx_gtpolarity_0;
assign ctrl_rx_gtpd[1:0]                        = ctrl_rx_gtpd_0;

assign stat_rx_buf_lvl_1                        = stat_rx_buf_lvl[19:10];
assign ctrl_tx_ila_lid[9:5]                     = ctrl_tx_ila_lid_1;
assign ctrl_tx_ila_lid_1_pdef                   = ctrl_tx_ila_lid_pdef[9:5];
assign ctrl_tx_ila_nll[9:5]                     = ctrl_tx_ila_nll_1;
assign ctrl_tx_ila_nll_1_pdef                   = ctrl_tx_ila_nll_pdef[9:5];
assign stat_rx_err_cnt0_1                       = stat_rx_err_cnt0[63:32];
assign stat_rx_err_cnt0_pls_h[1]                = stat_rx_err_cnt0_1_pls_h;
assign stat_rx_err_cnt1_1                       = stat_rx_err_cnt1[63:32];
assign stat_rx_err_cnt1_pls_h[1]                = stat_rx_err_cnt1_1_pls_h;
assign stat_link_err_cnt_1                      = stat_link_err_cnt[63:32];
assign stat_link_err_cnt_pls_h[1]               = stat_link_err_cnt_1_pls_h;
assign stat_test_err_cnt_1                      = stat_test_err_cnt[63:32];
assign stat_test_err_cnt_pls_h[1]               = stat_test_err_cnt_1_pls_h;
assign stat_test_ila_cnt_1                      = stat_test_ila_cnt[63:32];
assign stat_test_ila_cnt_pls_h[1]               = stat_test_ila_cnt_1_pls_h;
assign stat_test_mf_cnt_1                       = stat_test_mf_cnt[63:32];
assign stat_test_mf_cnt_pls_h[1]                = stat_test_mf_cnt_1_pls_h;
assign stat_rx_ila_jesdv_1                      = stat_rx_ila_jesdv[5:3];
assign stat_rx_ila_subc_1                       = stat_rx_ila_subc[5:3];
assign stat_rx_ila_f_1                          = stat_rx_ila_f[15:8];
assign stat_rx_ila_k_1                          = stat_rx_ila_k[9:5];
assign stat_rx_ila_did_1                        = stat_rx_ila_did[15:8];
assign stat_rx_ila_bid_1                        = stat_rx_ila_bid[7:4];
assign stat_rx_ila_lid_1                        = stat_rx_ila_lid[9:5];
assign stat_rx_ila_l_1                          = stat_rx_ila_l[9:5];
assign stat_rx_ila_m_1                          = stat_rx_ila_m[15:8];
assign stat_rx_ila_n_1                          = stat_rx_ila_n[9:5];
assign stat_rx_ila_np_1                         = stat_rx_ila_np[9:5];
assign stat_rx_ila_cs_1                         = stat_rx_ila_cs[3:2];
assign stat_rx_ila_scr_1                        = stat_rx_ila_scr[1];
assign stat_rx_ila_s_1                          = stat_rx_ila_s[9:5];
assign stat_rx_ila_hd_1                         = stat_rx_ila_hd[1];
assign stat_rx_ila_cf_1                         = stat_rx_ila_cf[9:5];
assign stat_rx_ila_adjcnt_1                     = stat_rx_ila_adjcnt[7:4];
assign stat_rx_ila_phadj_1                      = stat_rx_ila_phadj[1];
assign stat_rx_ila_adjdir_1                     = stat_rx_ila_adjdir[1];
assign stat_rx_ila_res1_1                       = stat_rx_ila_res1[15:8];
assign stat_rx_ila_res2_1                       = stat_rx_ila_res2[15:8];
assign stat_rx_ila_fchk_1                       = stat_rx_ila_fchk[15:8];
assign ctrl_tx_gtpolarity[1]                    = ctrl_tx_gtpolarity_1;
assign ctrl_tx_gtpd[3:2]                        = ctrl_tx_gtpd_1;
assign ctrl_tx_gtelecidle[1]                    = ctrl_tx_gtelecidle_1;
assign ctrl_tx_gtinhibit[1]                     = ctrl_tx_gtinhibit_1;
assign ctrl_tx_gtdiffctrl[9:5]                  = ctrl_tx_gtdiffctrl_1;
assign ctrl_tx_gtpostcursor[9:5]                = ctrl_tx_gtpostcursor_1;
assign ctrl_tx_gtprecursor[9:5]                 = ctrl_tx_gtprecursor_1;
assign ctrl_rx_gtpolarity[1]                    = ctrl_rx_gtpolarity_1;
assign ctrl_rx_gtpd[3:2]                        = ctrl_rx_gtpd_1;

assign stat_rx_buf_lvl_2                        = stat_rx_buf_lvl[29:20];
assign ctrl_tx_ila_lid[14:10]                   = ctrl_tx_ila_lid_2;
assign ctrl_tx_ila_lid_2_pdef                   = ctrl_tx_ila_lid_pdef[14:10];
assign ctrl_tx_ila_nll[14:10]                   = ctrl_tx_ila_nll_2;
assign ctrl_tx_ila_nll_2_pdef                   = ctrl_tx_ila_nll_pdef[14:10];
assign stat_rx_err_cnt0_2                       = stat_rx_err_cnt0[95:64];
assign stat_rx_err_cnt0_pls_h[2]                = stat_rx_err_cnt0_2_pls_h;
assign stat_rx_err_cnt1_2                       = stat_rx_err_cnt1[95:64];
assign stat_rx_err_cnt1_pls_h[2]                = stat_rx_err_cnt1_2_pls_h;
assign stat_link_err_cnt_2                      = stat_link_err_cnt[95:64];
assign stat_link_err_cnt_pls_h[2]               = stat_link_err_cnt_2_pls_h;
assign stat_test_err_cnt_2                      = stat_test_err_cnt[95:64];
assign stat_test_err_cnt_pls_h[2]               = stat_test_err_cnt_2_pls_h;
assign stat_test_ila_cnt_2                      = stat_test_ila_cnt[95:64];
assign stat_test_ila_cnt_pls_h[2]               = stat_test_ila_cnt_2_pls_h;
assign stat_test_mf_cnt_2                       = stat_test_mf_cnt[95:64];
assign stat_test_mf_cnt_pls_h[2]                = stat_test_mf_cnt_2_pls_h;
assign stat_rx_ila_jesdv_2                      = stat_rx_ila_jesdv[8:6];
assign stat_rx_ila_subc_2                       = stat_rx_ila_subc[8:6];
assign stat_rx_ila_f_2                          = stat_rx_ila_f[23:16];
assign stat_rx_ila_k_2                          = stat_rx_ila_k[14:10];
assign stat_rx_ila_did_2                        = stat_rx_ila_did[23:16];
assign stat_rx_ila_bid_2                        = stat_rx_ila_bid[11:8];
assign stat_rx_ila_lid_2                        = stat_rx_ila_lid[14:10];
assign stat_rx_ila_l_2                          = stat_rx_ila_l[14:10];
assign stat_rx_ila_m_2                          = stat_rx_ila_m[23:16];
assign stat_rx_ila_n_2                          = stat_rx_ila_n[14:10];
assign stat_rx_ila_np_2                         = stat_rx_ila_np[14:10];
assign stat_rx_ila_cs_2                         = stat_rx_ila_cs[5:4];
assign stat_rx_ila_scr_2                        = stat_rx_ila_scr[2];
assign stat_rx_ila_s_2                          = stat_rx_ila_s[14:10];
assign stat_rx_ila_hd_2                         = stat_rx_ila_hd[2];
assign stat_rx_ila_cf_2                         = stat_rx_ila_cf[14:10];
assign stat_rx_ila_adjcnt_2                     = stat_rx_ila_adjcnt[11:8];
assign stat_rx_ila_phadj_2                      = stat_rx_ila_phadj[2];
assign stat_rx_ila_adjdir_2                     = stat_rx_ila_adjdir[2];
assign stat_rx_ila_res1_2                       = stat_rx_ila_res1[23:16];
assign stat_rx_ila_res2_2                       = stat_rx_ila_res2[23:16];
assign stat_rx_ila_fchk_2                       = stat_rx_ila_fchk[23:16];
assign ctrl_tx_gtpolarity[2]                    = ctrl_tx_gtpolarity_2;
assign ctrl_tx_gtpd[5:4]                        = ctrl_tx_gtpd_2;
assign ctrl_tx_gtelecidle[2]                    = ctrl_tx_gtelecidle_2;
assign ctrl_tx_gtinhibit[2]                     = ctrl_tx_gtinhibit_2;
assign ctrl_tx_gtdiffctrl[14:10]                = ctrl_tx_gtdiffctrl_2;
assign ctrl_tx_gtpostcursor[14:10]              = ctrl_tx_gtpostcursor_2;
assign ctrl_tx_gtprecursor[14:10]               = ctrl_tx_gtprecursor_2;
assign ctrl_rx_gtpolarity[2]                    = ctrl_rx_gtpolarity_2;
assign ctrl_rx_gtpd[5:4]                        = ctrl_rx_gtpd_2;

assign stat_rx_buf_lvl_3                        = stat_rx_buf_lvl[39:30];
assign ctrl_tx_ila_lid[19:15]                   = ctrl_tx_ila_lid_3;
assign ctrl_tx_ila_lid_3_pdef                   = ctrl_tx_ila_lid_pdef[19:15];
assign ctrl_tx_ila_nll[19:15]                   = ctrl_tx_ila_nll_3;
assign ctrl_tx_ila_nll_3_pdef                   = ctrl_tx_ila_nll_pdef[19:15];
assign stat_rx_err_cnt0_3                       = stat_rx_err_cnt0[127:96];
assign stat_rx_err_cnt0_pls_h[3]                = stat_rx_err_cnt0_3_pls_h;
assign stat_rx_err_cnt1_3                       = stat_rx_err_cnt1[127:96];
assign stat_rx_err_cnt1_pls_h[3]                = stat_rx_err_cnt1_3_pls_h;
assign stat_link_err_cnt_3                      = stat_link_err_cnt[127:96];
assign stat_link_err_cnt_pls_h[3]               = stat_link_err_cnt_3_pls_h;
assign stat_test_err_cnt_3                      = stat_test_err_cnt[127:96];
assign stat_test_err_cnt_pls_h[3]               = stat_test_err_cnt_3_pls_h;
assign stat_test_ila_cnt_3                      = stat_test_ila_cnt[127:96];
assign stat_test_ila_cnt_pls_h[3]               = stat_test_ila_cnt_3_pls_h;
assign stat_test_mf_cnt_3                       = stat_test_mf_cnt[127:96];
assign stat_test_mf_cnt_pls_h[3]                = stat_test_mf_cnt_3_pls_h;
assign stat_rx_ila_jesdv_3                      = stat_rx_ila_jesdv[11:9];
assign stat_rx_ila_subc_3                       = stat_rx_ila_subc[11:9];
assign stat_rx_ila_f_3                          = stat_rx_ila_f[31:24];
assign stat_rx_ila_k_3                          = stat_rx_ila_k[19:15];
assign stat_rx_ila_did_3                        = stat_rx_ila_did[31:24];
assign stat_rx_ila_bid_3                        = stat_rx_ila_bid[15:12];
assign stat_rx_ila_lid_3                        = stat_rx_ila_lid[19:15];
assign stat_rx_ila_l_3                          = stat_rx_ila_l[19:15];
assign stat_rx_ila_m_3                          = stat_rx_ila_m[31:24];
assign stat_rx_ila_n_3                          = stat_rx_ila_n[19:15];
assign stat_rx_ila_np_3                         = stat_rx_ila_np[19:15];
assign stat_rx_ila_cs_3                         = stat_rx_ila_cs[7:6];
assign stat_rx_ila_scr_3                        = stat_rx_ila_scr[3];
assign stat_rx_ila_s_3                          = stat_rx_ila_s[19:15];
assign stat_rx_ila_hd_3                         = stat_rx_ila_hd[3];
assign stat_rx_ila_cf_3                         = stat_rx_ila_cf[19:15];
assign stat_rx_ila_adjcnt_3                     = stat_rx_ila_adjcnt[15:12];
assign stat_rx_ila_phadj_3                      = stat_rx_ila_phadj[3];
assign stat_rx_ila_adjdir_3                     = stat_rx_ila_adjdir[3];
assign stat_rx_ila_res1_3                       = stat_rx_ila_res1[31:24];
assign stat_rx_ila_res2_3                       = stat_rx_ila_res2[31:24];
assign stat_rx_ila_fchk_3                       = stat_rx_ila_fchk[31:24];
assign ctrl_tx_gtpolarity[3]                    = ctrl_tx_gtpolarity_3;
assign ctrl_tx_gtpd[7:6]                        = ctrl_tx_gtpd_3;
assign ctrl_tx_gtelecidle[3]                    = ctrl_tx_gtelecidle_3;
assign ctrl_tx_gtinhibit[3]                     = ctrl_tx_gtinhibit_3;
assign ctrl_tx_gtdiffctrl[19:15]                = ctrl_tx_gtdiffctrl_3;
assign ctrl_tx_gtpostcursor[19:15]              = ctrl_tx_gtpostcursor_3;
assign ctrl_tx_gtprecursor[19:15]               = ctrl_tx_gtprecursor_3;
assign ctrl_rx_gtpolarity[3]                    = ctrl_rx_gtpolarity_3;
assign ctrl_rx_gtpd[7:6]                        = ctrl_rx_gtpd_3;

assign stat_rx_buf_lvl_4                        = stat_rx_buf_lvl[49:40];
assign ctrl_tx_ila_lid[24:20]                   = ctrl_tx_ila_lid_4;
assign ctrl_tx_ila_lid_4_pdef                   = ctrl_tx_ila_lid_pdef[24:20];
assign ctrl_tx_ila_nll[24:20]                   = ctrl_tx_ila_nll_4;
assign ctrl_tx_ila_nll_4_pdef                   = ctrl_tx_ila_nll_pdef[24:20];
assign stat_rx_err_cnt0_4                       = stat_rx_err_cnt0[159:128];
assign stat_rx_err_cnt0_pls_h[4]                = stat_rx_err_cnt0_4_pls_h;
assign stat_rx_err_cnt1_4                       = stat_rx_err_cnt1[159:128];
assign stat_rx_err_cnt1_pls_h[4]                = stat_rx_err_cnt1_4_pls_h;
assign stat_link_err_cnt_4                      = stat_link_err_cnt[159:128];
assign stat_link_err_cnt_pls_h[4]               = stat_link_err_cnt_4_pls_h;
assign stat_test_err_cnt_4                      = stat_test_err_cnt[159:128];
assign stat_test_err_cnt_pls_h[4]               = stat_test_err_cnt_4_pls_h;
assign stat_test_ila_cnt_4                      = stat_test_ila_cnt[159:128];
assign stat_test_ila_cnt_pls_h[4]               = stat_test_ila_cnt_4_pls_h;
assign stat_test_mf_cnt_4                       = stat_test_mf_cnt[159:128];
assign stat_test_mf_cnt_pls_h[4]                = stat_test_mf_cnt_4_pls_h;
assign stat_rx_ila_jesdv_4                      = stat_rx_ila_jesdv[14:12];
assign stat_rx_ila_subc_4                       = stat_rx_ila_subc[14:12];
assign stat_rx_ila_f_4                          = stat_rx_ila_f[39:32];
assign stat_rx_ila_k_4                          = stat_rx_ila_k[24:20];
assign stat_rx_ila_did_4                        = stat_rx_ila_did[39:32];
assign stat_rx_ila_bid_4                        = stat_rx_ila_bid[19:16];
assign stat_rx_ila_lid_4                        = stat_rx_ila_lid[24:20];
assign stat_rx_ila_l_4                          = stat_rx_ila_l[24:20];
assign stat_rx_ila_m_4                          = stat_rx_ila_m[39:32];
assign stat_rx_ila_n_4                          = stat_rx_ila_n[24:20];
assign stat_rx_ila_np_4                         = stat_rx_ila_np[24:20];
assign stat_rx_ila_cs_4                         = stat_rx_ila_cs[9:8];
assign stat_rx_ila_scr_4                        = stat_rx_ila_scr[4];
assign stat_rx_ila_s_4                          = stat_rx_ila_s[24:20];
assign stat_rx_ila_hd_4                         = stat_rx_ila_hd[4];
assign stat_rx_ila_cf_4                         = stat_rx_ila_cf[24:20];
assign stat_rx_ila_adjcnt_4                     = stat_rx_ila_adjcnt[19:16];
assign stat_rx_ila_phadj_4                      = stat_rx_ila_phadj[4];
assign stat_rx_ila_adjdir_4                     = stat_rx_ila_adjdir[4];
assign stat_rx_ila_res1_4                       = stat_rx_ila_res1[39:32];
assign stat_rx_ila_res2_4                       = stat_rx_ila_res2[39:32];
assign stat_rx_ila_fchk_4                       = stat_rx_ila_fchk[39:32];
assign ctrl_tx_gtpolarity[4]                    = ctrl_tx_gtpolarity_4;
assign ctrl_tx_gtpd[9:8]                        = ctrl_tx_gtpd_4;
assign ctrl_tx_gtelecidle[4]                    = ctrl_tx_gtelecidle_4;
assign ctrl_tx_gtinhibit[4]                     = ctrl_tx_gtinhibit_4;
assign ctrl_tx_gtdiffctrl[24:20]                = ctrl_tx_gtdiffctrl_4;
assign ctrl_tx_gtpostcursor[24:20]              = ctrl_tx_gtpostcursor_4;
assign ctrl_tx_gtprecursor[24:20]               = ctrl_tx_gtprecursor_4;
assign ctrl_rx_gtpolarity[4]                    = ctrl_rx_gtpolarity_4;
assign ctrl_rx_gtpd[9:8]                        = ctrl_rx_gtpd_4;

assign stat_rx_buf_lvl_5                        = stat_rx_buf_lvl[59:50];
assign ctrl_tx_ila_lid[29:25]                   = ctrl_tx_ila_lid_5;
assign ctrl_tx_ila_lid_5_pdef                   = ctrl_tx_ila_lid_pdef[29:25];
assign ctrl_tx_ila_nll[29:25]                   = ctrl_tx_ila_nll_5;
assign ctrl_tx_ila_nll_5_pdef                   = ctrl_tx_ila_nll_pdef[29:25];
assign stat_rx_err_cnt0_5                       = stat_rx_err_cnt0[191:160];
assign stat_rx_err_cnt0_pls_h[5]                = stat_rx_err_cnt0_5_pls_h;
assign stat_rx_err_cnt1_5                       = stat_rx_err_cnt1[191:160];
assign stat_rx_err_cnt1_pls_h[5]                = stat_rx_err_cnt1_5_pls_h;
assign stat_link_err_cnt_5                      = stat_link_err_cnt[191:160];
assign stat_link_err_cnt_pls_h[5]               = stat_link_err_cnt_5_pls_h;
assign stat_test_err_cnt_5                      = stat_test_err_cnt[191:160];
assign stat_test_err_cnt_pls_h[5]               = stat_test_err_cnt_5_pls_h;
assign stat_test_ila_cnt_5                      = stat_test_ila_cnt[191:160];
assign stat_test_ila_cnt_pls_h[5]               = stat_test_ila_cnt_5_pls_h;
assign stat_test_mf_cnt_5                       = stat_test_mf_cnt[191:160];
assign stat_test_mf_cnt_pls_h[5]                = stat_test_mf_cnt_5_pls_h;
assign stat_rx_ila_jesdv_5                      = stat_rx_ila_jesdv[17:15];
assign stat_rx_ila_subc_5                       = stat_rx_ila_subc[17:15];
assign stat_rx_ila_f_5                          = stat_rx_ila_f[47:40];
assign stat_rx_ila_k_5                          = stat_rx_ila_k[29:25];
assign stat_rx_ila_did_5                        = stat_rx_ila_did[47:40];
assign stat_rx_ila_bid_5                        = stat_rx_ila_bid[23:20];
assign stat_rx_ila_lid_5                        = stat_rx_ila_lid[29:25];
assign stat_rx_ila_l_5                          = stat_rx_ila_l[29:25];
assign stat_rx_ila_m_5                          = stat_rx_ila_m[47:40];
assign stat_rx_ila_n_5                          = stat_rx_ila_n[29:25];
assign stat_rx_ila_np_5                         = stat_rx_ila_np[29:25];
assign stat_rx_ila_cs_5                         = stat_rx_ila_cs[11:10];
assign stat_rx_ila_scr_5                        = stat_rx_ila_scr[5];
assign stat_rx_ila_s_5                          = stat_rx_ila_s[29:25];
assign stat_rx_ila_hd_5                         = stat_rx_ila_hd[5];
assign stat_rx_ila_cf_5                         = stat_rx_ila_cf[29:25];
assign stat_rx_ila_adjcnt_5                     = stat_rx_ila_adjcnt[23:20];
assign stat_rx_ila_phadj_5                      = stat_rx_ila_phadj[5];
assign stat_rx_ila_adjdir_5                     = stat_rx_ila_adjdir[5];
assign stat_rx_ila_res1_5                       = stat_rx_ila_res1[47:40];
assign stat_rx_ila_res2_5                       = stat_rx_ila_res2[47:40];
assign stat_rx_ila_fchk_5                       = stat_rx_ila_fchk[47:40];
assign ctrl_tx_gtpolarity[5]                    = ctrl_tx_gtpolarity_5;
assign ctrl_tx_gtpd[11:10]                      = ctrl_tx_gtpd_5;
assign ctrl_tx_gtelecidle[5]                    = ctrl_tx_gtelecidle_5;
assign ctrl_tx_gtinhibit[5]                     = ctrl_tx_gtinhibit_5;
assign ctrl_tx_gtdiffctrl[29:25]                = ctrl_tx_gtdiffctrl_5;
assign ctrl_tx_gtpostcursor[29:25]              = ctrl_tx_gtpostcursor_5;
assign ctrl_tx_gtprecursor[29:25]               = ctrl_tx_gtprecursor_5;
assign ctrl_rx_gtpolarity[5]                    = ctrl_rx_gtpolarity_5;
assign ctrl_rx_gtpd[11:10]                      = ctrl_rx_gtpd_5;

assign stat_rx_buf_lvl_6                        = stat_rx_buf_lvl[69:60];
assign ctrl_tx_ila_lid[34:30]                   = ctrl_tx_ila_lid_6;
assign ctrl_tx_ila_lid_6_pdef                   = ctrl_tx_ila_lid_pdef[34:30];
assign ctrl_tx_ila_nll[34:30]                   = ctrl_tx_ila_nll_6;
assign ctrl_tx_ila_nll_6_pdef                   = ctrl_tx_ila_nll_pdef[34:30];
assign stat_rx_err_cnt0_6                       = stat_rx_err_cnt0[223:192];
assign stat_rx_err_cnt0_pls_h[6]                = stat_rx_err_cnt0_6_pls_h;
assign stat_rx_err_cnt1_6                       = stat_rx_err_cnt1[223:192];
assign stat_rx_err_cnt1_pls_h[6]                = stat_rx_err_cnt1_6_pls_h;
assign stat_link_err_cnt_6                      = stat_link_err_cnt[223:192];
assign stat_link_err_cnt_pls_h[6]               = stat_link_err_cnt_6_pls_h;
assign stat_test_err_cnt_6                      = stat_test_err_cnt[223:192];
assign stat_test_err_cnt_pls_h[6]               = stat_test_err_cnt_6_pls_h;
assign stat_test_ila_cnt_6                      = stat_test_ila_cnt[223:192];
assign stat_test_ila_cnt_pls_h[6]               = stat_test_ila_cnt_6_pls_h;
assign stat_test_mf_cnt_6                       = stat_test_mf_cnt[223:192];
assign stat_test_mf_cnt_pls_h[6]                = stat_test_mf_cnt_6_pls_h;
assign stat_rx_ila_jesdv_6                      = stat_rx_ila_jesdv[20:18];
assign stat_rx_ila_subc_6                       = stat_rx_ila_subc[20:18];
assign stat_rx_ila_f_6                          = stat_rx_ila_f[55:48];
assign stat_rx_ila_k_6                          = stat_rx_ila_k[34:30];
assign stat_rx_ila_did_6                        = stat_rx_ila_did[55:48];
assign stat_rx_ila_bid_6                        = stat_rx_ila_bid[27:24];
assign stat_rx_ila_lid_6                        = stat_rx_ila_lid[34:30];
assign stat_rx_ila_l_6                          = stat_rx_ila_l[34:30];
assign stat_rx_ila_m_6                          = stat_rx_ila_m[55:48];
assign stat_rx_ila_n_6                          = stat_rx_ila_n[34:30];
assign stat_rx_ila_np_6                         = stat_rx_ila_np[34:30];
assign stat_rx_ila_cs_6                         = stat_rx_ila_cs[13:12];
assign stat_rx_ila_scr_6                        = stat_rx_ila_scr[6];
assign stat_rx_ila_s_6                          = stat_rx_ila_s[34:30];
assign stat_rx_ila_hd_6                         = stat_rx_ila_hd[6];
assign stat_rx_ila_cf_6                         = stat_rx_ila_cf[34:30];
assign stat_rx_ila_adjcnt_6                     = stat_rx_ila_adjcnt[27:24];
assign stat_rx_ila_phadj_6                      = stat_rx_ila_phadj[6];
assign stat_rx_ila_adjdir_6                     = stat_rx_ila_adjdir[6];
assign stat_rx_ila_res1_6                       = stat_rx_ila_res1[55:48];
assign stat_rx_ila_res2_6                       = stat_rx_ila_res2[55:48];
assign stat_rx_ila_fchk_6                       = stat_rx_ila_fchk[55:48];
assign ctrl_tx_gtpolarity[6]                    = ctrl_tx_gtpolarity_6;
assign ctrl_tx_gtpd[13:12]                      = ctrl_tx_gtpd_6;
assign ctrl_tx_gtelecidle[6]                    = ctrl_tx_gtelecidle_6;
assign ctrl_tx_gtinhibit[6]                     = ctrl_tx_gtinhibit_6;
assign ctrl_tx_gtdiffctrl[34:30]                = ctrl_tx_gtdiffctrl_6;
assign ctrl_tx_gtpostcursor[34:30]              = ctrl_tx_gtpostcursor_6;
assign ctrl_tx_gtprecursor[34:30]               = ctrl_tx_gtprecursor_6;
assign ctrl_rx_gtpolarity[6]                    = ctrl_rx_gtpolarity_6;
assign ctrl_rx_gtpd[13:12]                      = ctrl_rx_gtpd_6;

assign stat_rx_buf_lvl_7                        = stat_rx_buf_lvl[79:70];
assign ctrl_tx_ila_lid[39:35]                   = ctrl_tx_ila_lid_7;
assign ctrl_tx_ila_lid_7_pdef                   = ctrl_tx_ila_lid_pdef[39:35];
assign ctrl_tx_ila_nll[39:35]                   = ctrl_tx_ila_nll_7;
assign ctrl_tx_ila_nll_7_pdef                   = ctrl_tx_ila_nll_pdef[39:35];
assign stat_rx_err_cnt0_7                       = stat_rx_err_cnt0[255:224];
assign stat_rx_err_cnt0_pls_h[7]                = stat_rx_err_cnt0_7_pls_h;
assign stat_rx_err_cnt1_7                       = stat_rx_err_cnt1[255:224];
assign stat_rx_err_cnt1_pls_h[7]                = stat_rx_err_cnt1_7_pls_h;
assign stat_link_err_cnt_7                      = stat_link_err_cnt[255:224];
assign stat_link_err_cnt_pls_h[7]               = stat_link_err_cnt_7_pls_h;
assign stat_test_err_cnt_7                      = stat_test_err_cnt[255:224];
assign stat_test_err_cnt_pls_h[7]               = stat_test_err_cnt_7_pls_h;
assign stat_test_ila_cnt_7                      = stat_test_ila_cnt[255:224];
assign stat_test_ila_cnt_pls_h[7]               = stat_test_ila_cnt_7_pls_h;
assign stat_test_mf_cnt_7                       = stat_test_mf_cnt[255:224];
assign stat_test_mf_cnt_pls_h[7]                = stat_test_mf_cnt_7_pls_h;
assign stat_rx_ila_jesdv_7                      = stat_rx_ila_jesdv[23:21];
assign stat_rx_ila_subc_7                       = stat_rx_ila_subc[23:21];
assign stat_rx_ila_f_7                          = stat_rx_ila_f[63:56];
assign stat_rx_ila_k_7                          = stat_rx_ila_k[39:35];
assign stat_rx_ila_did_7                        = stat_rx_ila_did[63:56];
assign stat_rx_ila_bid_7                        = stat_rx_ila_bid[31:28];
assign stat_rx_ila_lid_7                        = stat_rx_ila_lid[39:35];
assign stat_rx_ila_l_7                          = stat_rx_ila_l[39:35];
assign stat_rx_ila_m_7                          = stat_rx_ila_m[63:56];
assign stat_rx_ila_n_7                          = stat_rx_ila_n[39:35];
assign stat_rx_ila_np_7                         = stat_rx_ila_np[39:35];
assign stat_rx_ila_cs_7                         = stat_rx_ila_cs[15:14];
assign stat_rx_ila_scr_7                        = stat_rx_ila_scr[7];
assign stat_rx_ila_s_7                          = stat_rx_ila_s[39:35];
assign stat_rx_ila_hd_7                         = stat_rx_ila_hd[7];
assign stat_rx_ila_cf_7                         = stat_rx_ila_cf[39:35];
assign stat_rx_ila_adjcnt_7                     = stat_rx_ila_adjcnt[31:28];
assign stat_rx_ila_phadj_7                      = stat_rx_ila_phadj[7];
assign stat_rx_ila_adjdir_7                     = stat_rx_ila_adjdir[7];
assign stat_rx_ila_res1_7                       = stat_rx_ila_res1[63:56];
assign stat_rx_ila_res2_7                       = stat_rx_ila_res2[63:56];
assign stat_rx_ila_fchk_7                       = stat_rx_ila_fchk[63:56];
assign ctrl_tx_gtpolarity[7]                    = ctrl_tx_gtpolarity_7;
assign ctrl_tx_gtpd[15:14]                      = ctrl_tx_gtpd_7;
assign ctrl_tx_gtelecidle[7]                    = ctrl_tx_gtelecidle_7;
assign ctrl_tx_gtinhibit[7]                     = ctrl_tx_gtinhibit_7;
assign ctrl_tx_gtdiffctrl[39:35]                = ctrl_tx_gtdiffctrl_7;
assign ctrl_tx_gtpostcursor[39:35]              = ctrl_tx_gtpostcursor_7;
assign ctrl_tx_gtprecursor[39:35]               = ctrl_tx_gtprecursor_7;
assign ctrl_rx_gtpolarity[7]                    = ctrl_rx_gtpolarity_7;
assign ctrl_rx_gtpd[15:14]                      = ctrl_rx_gtpd_7;


endmodule

