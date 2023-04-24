//-----------------------------------------------------------------------------
// Title      : jesd204c_regif_lane
// Project    : NA
//-----------------------------------------------------------------------------
// File       : jesd204c_regif_lane.v
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

module jesd204c_0_jesd204c_regif_lane #(
   parameter integer                   C_S_AXI_ADDR_WIDTH   = 11
   )
(
   input                                  s_axi_aclk,
   input                                  s_axi_aresetn,
   
   // IO for bank 0 
   input       [9:0]                      stat_rx_buf_lvl_0,
   output reg  [4:0]                      ctrl_tx_ila_lid_0 = 0,
   input wire  [4:0]                      ctrl_tx_ila_lid_0_pdef,
   output reg  [4:0]                      ctrl_tx_ila_nll_0 = 0,
   input wire  [4:0]                      ctrl_tx_ila_nll_0_pdef,
   input       [31:0]                     stat_rx_err_cnt0_0,
   output reg                             stat_rx_err_cnt0_0_pls_h = 0,
   input       [31:0]                     stat_rx_err_cnt1_0,
   output reg                             stat_rx_err_cnt1_0_pls_h = 0,
   input       [31:0]                     stat_link_err_cnt_0,
   output reg                             stat_link_err_cnt_0_pls_h = 0,
   input       [31:0]                     stat_test_err_cnt_0,
   output reg                             stat_test_err_cnt_0_pls_h = 0,
   input       [31:0]                     stat_test_ila_cnt_0,
   output reg                             stat_test_ila_cnt_0_pls_h = 0,
   input       [31:0]                     stat_test_mf_cnt_0,
   output reg                             stat_test_mf_cnt_0_pls_h = 0,
   input       [2:0]                      stat_rx_ila_jesdv_0,
   input       [2:0]                      stat_rx_ila_subc_0,
   input       [7:0]                      stat_rx_ila_f_0,
   input       [4:0]                      stat_rx_ila_k_0,
   input       [7:0]                      stat_rx_ila_did_0,
   input       [3:0]                      stat_rx_ila_bid_0,
   input       [4:0]                      stat_rx_ila_lid_0,
   input       [4:0]                      stat_rx_ila_l_0,
   input       [7:0]                      stat_rx_ila_m_0,
   input       [4:0]                      stat_rx_ila_n_0,
   input       [4:0]                      stat_rx_ila_np_0,
   input       [1:0]                      stat_rx_ila_cs_0,
   input                                  stat_rx_ila_scr_0,
   input       [4:0]                      stat_rx_ila_s_0,
   input                                  stat_rx_ila_hd_0,
   input       [4:0]                      stat_rx_ila_cf_0,
   input       [3:0]                      stat_rx_ila_adjcnt_0,
   input                                  stat_rx_ila_phadj_0,
   input                                  stat_rx_ila_adjdir_0,
   input       [7:0]                      stat_rx_ila_res1_0,
   input       [7:0]                      stat_rx_ila_res2_0,
   input       [7:0]                      stat_rx_ila_fchk_0,
   output reg                             ctrl_tx_gtpolarity_0 = 0,
   output reg  [1:0]                      ctrl_tx_gtpd_0 = 0,
   output reg                             ctrl_tx_gtelecidle_0 = 0,
   output reg                             ctrl_tx_gtinhibit_0 = 0,
   output reg  [4:0]                      ctrl_tx_gtdiffctrl_0 = 0,
   output reg  [4:0]                      ctrl_tx_gtpostcursor_0 = 0,
   output reg  [4:0]                      ctrl_tx_gtprecursor_0 = 0,
   output reg                             ctrl_rx_gtpolarity_0 = 0,
   output reg  [1:0]                      ctrl_rx_gtpd_0 = 0,

   // IO for bank 1 
   input       [9:0]                      stat_rx_buf_lvl_1,
   output reg  [4:0]                      ctrl_tx_ila_lid_1 = 0,
   input wire  [4:0]                      ctrl_tx_ila_lid_1_pdef,
   output reg  [4:0]                      ctrl_tx_ila_nll_1 = 0,
   input wire  [4:0]                      ctrl_tx_ila_nll_1_pdef,
   input       [31:0]                     stat_rx_err_cnt0_1,
   output reg                             stat_rx_err_cnt0_1_pls_h = 0,
   input       [31:0]                     stat_rx_err_cnt1_1,
   output reg                             stat_rx_err_cnt1_1_pls_h = 0,
   input       [31:0]                     stat_link_err_cnt_1,
   output reg                             stat_link_err_cnt_1_pls_h = 0,
   input       [31:0]                     stat_test_err_cnt_1,
   output reg                             stat_test_err_cnt_1_pls_h = 0,
   input       [31:0]                     stat_test_ila_cnt_1,
   output reg                             stat_test_ila_cnt_1_pls_h = 0,
   input       [31:0]                     stat_test_mf_cnt_1,
   output reg                             stat_test_mf_cnt_1_pls_h = 0,
   input       [2:0]                      stat_rx_ila_jesdv_1,
   input       [2:0]                      stat_rx_ila_subc_1,
   input       [7:0]                      stat_rx_ila_f_1,
   input       [4:0]                      stat_rx_ila_k_1,
   input       [7:0]                      stat_rx_ila_did_1,
   input       [3:0]                      stat_rx_ila_bid_1,
   input       [4:0]                      stat_rx_ila_lid_1,
   input       [4:0]                      stat_rx_ila_l_1,
   input       [7:0]                      stat_rx_ila_m_1,
   input       [4:0]                      stat_rx_ila_n_1,
   input       [4:0]                      stat_rx_ila_np_1,
   input       [1:0]                      stat_rx_ila_cs_1,
   input                                  stat_rx_ila_scr_1,
   input       [4:0]                      stat_rx_ila_s_1,
   input                                  stat_rx_ila_hd_1,
   input       [4:0]                      stat_rx_ila_cf_1,
   input       [3:0]                      stat_rx_ila_adjcnt_1,
   input                                  stat_rx_ila_phadj_1,
   input                                  stat_rx_ila_adjdir_1,
   input       [7:0]                      stat_rx_ila_res1_1,
   input       [7:0]                      stat_rx_ila_res2_1,
   input       [7:0]                      stat_rx_ila_fchk_1,
   output reg                             ctrl_tx_gtpolarity_1 = 0,
   output reg  [1:0]                      ctrl_tx_gtpd_1 = 0,
   output reg                             ctrl_tx_gtelecidle_1 = 0,
   output reg                             ctrl_tx_gtinhibit_1 = 0,
   output reg  [4:0]                      ctrl_tx_gtdiffctrl_1 = 0,
   output reg  [4:0]                      ctrl_tx_gtpostcursor_1 = 0,
   output reg  [4:0]                      ctrl_tx_gtprecursor_1 = 0,
   output reg                             ctrl_rx_gtpolarity_1 = 0,
   output reg  [1:0]                      ctrl_rx_gtpd_1 = 0,

   // IO for bank 2 
   input       [9:0]                      stat_rx_buf_lvl_2,
   output reg  [4:0]                      ctrl_tx_ila_lid_2 = 0,
   input wire  [4:0]                      ctrl_tx_ila_lid_2_pdef,
   output reg  [4:0]                      ctrl_tx_ila_nll_2 = 0,
   input wire  [4:0]                      ctrl_tx_ila_nll_2_pdef,
   input       [31:0]                     stat_rx_err_cnt0_2,
   output reg                             stat_rx_err_cnt0_2_pls_h = 0,
   input       [31:0]                     stat_rx_err_cnt1_2,
   output reg                             stat_rx_err_cnt1_2_pls_h = 0,
   input       [31:0]                     stat_link_err_cnt_2,
   output reg                             stat_link_err_cnt_2_pls_h = 0,
   input       [31:0]                     stat_test_err_cnt_2,
   output reg                             stat_test_err_cnt_2_pls_h = 0,
   input       [31:0]                     stat_test_ila_cnt_2,
   output reg                             stat_test_ila_cnt_2_pls_h = 0,
   input       [31:0]                     stat_test_mf_cnt_2,
   output reg                             stat_test_mf_cnt_2_pls_h = 0,
   input       [2:0]                      stat_rx_ila_jesdv_2,
   input       [2:0]                      stat_rx_ila_subc_2,
   input       [7:0]                      stat_rx_ila_f_2,
   input       [4:0]                      stat_rx_ila_k_2,
   input       [7:0]                      stat_rx_ila_did_2,
   input       [3:0]                      stat_rx_ila_bid_2,
   input       [4:0]                      stat_rx_ila_lid_2,
   input       [4:0]                      stat_rx_ila_l_2,
   input       [7:0]                      stat_rx_ila_m_2,
   input       [4:0]                      stat_rx_ila_n_2,
   input       [4:0]                      stat_rx_ila_np_2,
   input       [1:0]                      stat_rx_ila_cs_2,
   input                                  stat_rx_ila_scr_2,
   input       [4:0]                      stat_rx_ila_s_2,
   input                                  stat_rx_ila_hd_2,
   input       [4:0]                      stat_rx_ila_cf_2,
   input       [3:0]                      stat_rx_ila_adjcnt_2,
   input                                  stat_rx_ila_phadj_2,
   input                                  stat_rx_ila_adjdir_2,
   input       [7:0]                      stat_rx_ila_res1_2,
   input       [7:0]                      stat_rx_ila_res2_2,
   input       [7:0]                      stat_rx_ila_fchk_2,
   output reg                             ctrl_tx_gtpolarity_2 = 0,
   output reg  [1:0]                      ctrl_tx_gtpd_2 = 0,
   output reg                             ctrl_tx_gtelecidle_2 = 0,
   output reg                             ctrl_tx_gtinhibit_2 = 0,
   output reg  [4:0]                      ctrl_tx_gtdiffctrl_2 = 0,
   output reg  [4:0]                      ctrl_tx_gtpostcursor_2 = 0,
   output reg  [4:0]                      ctrl_tx_gtprecursor_2 = 0,
   output reg                             ctrl_rx_gtpolarity_2 = 0,
   output reg  [1:0]                      ctrl_rx_gtpd_2 = 0,

   // IO for bank 3 
   input       [9:0]                      stat_rx_buf_lvl_3,
   output reg  [4:0]                      ctrl_tx_ila_lid_3 = 0,
   input wire  [4:0]                      ctrl_tx_ila_lid_3_pdef,
   output reg  [4:0]                      ctrl_tx_ila_nll_3 = 0,
   input wire  [4:0]                      ctrl_tx_ila_nll_3_pdef,
   input       [31:0]                     stat_rx_err_cnt0_3,
   output reg                             stat_rx_err_cnt0_3_pls_h = 0,
   input       [31:0]                     stat_rx_err_cnt1_3,
   output reg                             stat_rx_err_cnt1_3_pls_h = 0,
   input       [31:0]                     stat_link_err_cnt_3,
   output reg                             stat_link_err_cnt_3_pls_h = 0,
   input       [31:0]                     stat_test_err_cnt_3,
   output reg                             stat_test_err_cnt_3_pls_h = 0,
   input       [31:0]                     stat_test_ila_cnt_3,
   output reg                             stat_test_ila_cnt_3_pls_h = 0,
   input       [31:0]                     stat_test_mf_cnt_3,
   output reg                             stat_test_mf_cnt_3_pls_h = 0,
   input       [2:0]                      stat_rx_ila_jesdv_3,
   input       [2:0]                      stat_rx_ila_subc_3,
   input       [7:0]                      stat_rx_ila_f_3,
   input       [4:0]                      stat_rx_ila_k_3,
   input       [7:0]                      stat_rx_ila_did_3,
   input       [3:0]                      stat_rx_ila_bid_3,
   input       [4:0]                      stat_rx_ila_lid_3,
   input       [4:0]                      stat_rx_ila_l_3,
   input       [7:0]                      stat_rx_ila_m_3,
   input       [4:0]                      stat_rx_ila_n_3,
   input       [4:0]                      stat_rx_ila_np_3,
   input       [1:0]                      stat_rx_ila_cs_3,
   input                                  stat_rx_ila_scr_3,
   input       [4:0]                      stat_rx_ila_s_3,
   input                                  stat_rx_ila_hd_3,
   input       [4:0]                      stat_rx_ila_cf_3,
   input       [3:0]                      stat_rx_ila_adjcnt_3,
   input                                  stat_rx_ila_phadj_3,
   input                                  stat_rx_ila_adjdir_3,
   input       [7:0]                      stat_rx_ila_res1_3,
   input       [7:0]                      stat_rx_ila_res2_3,
   input       [7:0]                      stat_rx_ila_fchk_3,
   output reg                             ctrl_tx_gtpolarity_3 = 0,
   output reg  [1:0]                      ctrl_tx_gtpd_3 = 0,
   output reg                             ctrl_tx_gtelecidle_3 = 0,
   output reg                             ctrl_tx_gtinhibit_3 = 0,
   output reg  [4:0]                      ctrl_tx_gtdiffctrl_3 = 0,
   output reg  [4:0]                      ctrl_tx_gtpostcursor_3 = 0,
   output reg  [4:0]                      ctrl_tx_gtprecursor_3 = 0,
   output reg                             ctrl_rx_gtpolarity_3 = 0,
   output reg  [1:0]                      ctrl_rx_gtpd_3 = 0,

   // IO for bank 4 
   input       [9:0]                      stat_rx_buf_lvl_4,
   output reg  [4:0]                      ctrl_tx_ila_lid_4 = 0,
   input wire  [4:0]                      ctrl_tx_ila_lid_4_pdef,
   output reg  [4:0]                      ctrl_tx_ila_nll_4 = 0,
   input wire  [4:0]                      ctrl_tx_ila_nll_4_pdef,
   input       [31:0]                     stat_rx_err_cnt0_4,
   output reg                             stat_rx_err_cnt0_4_pls_h = 0,
   input       [31:0]                     stat_rx_err_cnt1_4,
   output reg                             stat_rx_err_cnt1_4_pls_h = 0,
   input       [31:0]                     stat_link_err_cnt_4,
   output reg                             stat_link_err_cnt_4_pls_h = 0,
   input       [31:0]                     stat_test_err_cnt_4,
   output reg                             stat_test_err_cnt_4_pls_h = 0,
   input       [31:0]                     stat_test_ila_cnt_4,
   output reg                             stat_test_ila_cnt_4_pls_h = 0,
   input       [31:0]                     stat_test_mf_cnt_4,
   output reg                             stat_test_mf_cnt_4_pls_h = 0,
   input       [2:0]                      stat_rx_ila_jesdv_4,
   input       [2:0]                      stat_rx_ila_subc_4,
   input       [7:0]                      stat_rx_ila_f_4,
   input       [4:0]                      stat_rx_ila_k_4,
   input       [7:0]                      stat_rx_ila_did_4,
   input       [3:0]                      stat_rx_ila_bid_4,
   input       [4:0]                      stat_rx_ila_lid_4,
   input       [4:0]                      stat_rx_ila_l_4,
   input       [7:0]                      stat_rx_ila_m_4,
   input       [4:0]                      stat_rx_ila_n_4,
   input       [4:0]                      stat_rx_ila_np_4,
   input       [1:0]                      stat_rx_ila_cs_4,
   input                                  stat_rx_ila_scr_4,
   input       [4:0]                      stat_rx_ila_s_4,
   input                                  stat_rx_ila_hd_4,
   input       [4:0]                      stat_rx_ila_cf_4,
   input       [3:0]                      stat_rx_ila_adjcnt_4,
   input                                  stat_rx_ila_phadj_4,
   input                                  stat_rx_ila_adjdir_4,
   input       [7:0]                      stat_rx_ila_res1_4,
   input       [7:0]                      stat_rx_ila_res2_4,
   input       [7:0]                      stat_rx_ila_fchk_4,
   output reg                             ctrl_tx_gtpolarity_4 = 0,
   output reg  [1:0]                      ctrl_tx_gtpd_4 = 0,
   output reg                             ctrl_tx_gtelecidle_4 = 0,
   output reg                             ctrl_tx_gtinhibit_4 = 0,
   output reg  [4:0]                      ctrl_tx_gtdiffctrl_4 = 0,
   output reg  [4:0]                      ctrl_tx_gtpostcursor_4 = 0,
   output reg  [4:0]                      ctrl_tx_gtprecursor_4 = 0,
   output reg                             ctrl_rx_gtpolarity_4 = 0,
   output reg  [1:0]                      ctrl_rx_gtpd_4 = 0,

   // IO for bank 5 
   input       [9:0]                      stat_rx_buf_lvl_5,
   output reg  [4:0]                      ctrl_tx_ila_lid_5 = 0,
   input wire  [4:0]                      ctrl_tx_ila_lid_5_pdef,
   output reg  [4:0]                      ctrl_tx_ila_nll_5 = 0,
   input wire  [4:0]                      ctrl_tx_ila_nll_5_pdef,
   input       [31:0]                     stat_rx_err_cnt0_5,
   output reg                             stat_rx_err_cnt0_5_pls_h = 0,
   input       [31:0]                     stat_rx_err_cnt1_5,
   output reg                             stat_rx_err_cnt1_5_pls_h = 0,
   input       [31:0]                     stat_link_err_cnt_5,
   output reg                             stat_link_err_cnt_5_pls_h = 0,
   input       [31:0]                     stat_test_err_cnt_5,
   output reg                             stat_test_err_cnt_5_pls_h = 0,
   input       [31:0]                     stat_test_ila_cnt_5,
   output reg                             stat_test_ila_cnt_5_pls_h = 0,
   input       [31:0]                     stat_test_mf_cnt_5,
   output reg                             stat_test_mf_cnt_5_pls_h = 0,
   input       [2:0]                      stat_rx_ila_jesdv_5,
   input       [2:0]                      stat_rx_ila_subc_5,
   input       [7:0]                      stat_rx_ila_f_5,
   input       [4:0]                      stat_rx_ila_k_5,
   input       [7:0]                      stat_rx_ila_did_5,
   input       [3:0]                      stat_rx_ila_bid_5,
   input       [4:0]                      stat_rx_ila_lid_5,
   input       [4:0]                      stat_rx_ila_l_5,
   input       [7:0]                      stat_rx_ila_m_5,
   input       [4:0]                      stat_rx_ila_n_5,
   input       [4:0]                      stat_rx_ila_np_5,
   input       [1:0]                      stat_rx_ila_cs_5,
   input                                  stat_rx_ila_scr_5,
   input       [4:0]                      stat_rx_ila_s_5,
   input                                  stat_rx_ila_hd_5,
   input       [4:0]                      stat_rx_ila_cf_5,
   input       [3:0]                      stat_rx_ila_adjcnt_5,
   input                                  stat_rx_ila_phadj_5,
   input                                  stat_rx_ila_adjdir_5,
   input       [7:0]                      stat_rx_ila_res1_5,
   input       [7:0]                      stat_rx_ila_res2_5,
   input       [7:0]                      stat_rx_ila_fchk_5,
   output reg                             ctrl_tx_gtpolarity_5 = 0,
   output reg  [1:0]                      ctrl_tx_gtpd_5 = 0,
   output reg                             ctrl_tx_gtelecidle_5 = 0,
   output reg                             ctrl_tx_gtinhibit_5 = 0,
   output reg  [4:0]                      ctrl_tx_gtdiffctrl_5 = 0,
   output reg  [4:0]                      ctrl_tx_gtpostcursor_5 = 0,
   output reg  [4:0]                      ctrl_tx_gtprecursor_5 = 0,
   output reg                             ctrl_rx_gtpolarity_5 = 0,
   output reg  [1:0]                      ctrl_rx_gtpd_5 = 0,

   // IO for bank 6 
   input       [9:0]                      stat_rx_buf_lvl_6,
   output reg  [4:0]                      ctrl_tx_ila_lid_6 = 0,
   input wire  [4:0]                      ctrl_tx_ila_lid_6_pdef,
   output reg  [4:0]                      ctrl_tx_ila_nll_6 = 0,
   input wire  [4:0]                      ctrl_tx_ila_nll_6_pdef,
   input       [31:0]                     stat_rx_err_cnt0_6,
   output reg                             stat_rx_err_cnt0_6_pls_h = 0,
   input       [31:0]                     stat_rx_err_cnt1_6,
   output reg                             stat_rx_err_cnt1_6_pls_h = 0,
   input       [31:0]                     stat_link_err_cnt_6,
   output reg                             stat_link_err_cnt_6_pls_h = 0,
   input       [31:0]                     stat_test_err_cnt_6,
   output reg                             stat_test_err_cnt_6_pls_h = 0,
   input       [31:0]                     stat_test_ila_cnt_6,
   output reg                             stat_test_ila_cnt_6_pls_h = 0,
   input       [31:0]                     stat_test_mf_cnt_6,
   output reg                             stat_test_mf_cnt_6_pls_h = 0,
   input       [2:0]                      stat_rx_ila_jesdv_6,
   input       [2:0]                      stat_rx_ila_subc_6,
   input       [7:0]                      stat_rx_ila_f_6,
   input       [4:0]                      stat_rx_ila_k_6,
   input       [7:0]                      stat_rx_ila_did_6,
   input       [3:0]                      stat_rx_ila_bid_6,
   input       [4:0]                      stat_rx_ila_lid_6,
   input       [4:0]                      stat_rx_ila_l_6,
   input       [7:0]                      stat_rx_ila_m_6,
   input       [4:0]                      stat_rx_ila_n_6,
   input       [4:0]                      stat_rx_ila_np_6,
   input       [1:0]                      stat_rx_ila_cs_6,
   input                                  stat_rx_ila_scr_6,
   input       [4:0]                      stat_rx_ila_s_6,
   input                                  stat_rx_ila_hd_6,
   input       [4:0]                      stat_rx_ila_cf_6,
   input       [3:0]                      stat_rx_ila_adjcnt_6,
   input                                  stat_rx_ila_phadj_6,
   input                                  stat_rx_ila_adjdir_6,
   input       [7:0]                      stat_rx_ila_res1_6,
   input       [7:0]                      stat_rx_ila_res2_6,
   input       [7:0]                      stat_rx_ila_fchk_6,
   output reg                             ctrl_tx_gtpolarity_6 = 0,
   output reg  [1:0]                      ctrl_tx_gtpd_6 = 0,
   output reg                             ctrl_tx_gtelecidle_6 = 0,
   output reg                             ctrl_tx_gtinhibit_6 = 0,
   output reg  [4:0]                      ctrl_tx_gtdiffctrl_6 = 0,
   output reg  [4:0]                      ctrl_tx_gtpostcursor_6 = 0,
   output reg  [4:0]                      ctrl_tx_gtprecursor_6 = 0,
   output reg                             ctrl_rx_gtpolarity_6 = 0,
   output reg  [1:0]                      ctrl_rx_gtpd_6 = 0,

   // IO for bank 7 
   input       [9:0]                      stat_rx_buf_lvl_7,
   output reg  [4:0]                      ctrl_tx_ila_lid_7 = 0,
   input wire  [4:0]                      ctrl_tx_ila_lid_7_pdef,
   output reg  [4:0]                      ctrl_tx_ila_nll_7 = 0,
   input wire  [4:0]                      ctrl_tx_ila_nll_7_pdef,
   input       [31:0]                     stat_rx_err_cnt0_7,
   output reg                             stat_rx_err_cnt0_7_pls_h = 0,
   input       [31:0]                     stat_rx_err_cnt1_7,
   output reg                             stat_rx_err_cnt1_7_pls_h = 0,
   input       [31:0]                     stat_link_err_cnt_7,
   output reg                             stat_link_err_cnt_7_pls_h = 0,
   input       [31:0]                     stat_test_err_cnt_7,
   output reg                             stat_test_err_cnt_7_pls_h = 0,
   input       [31:0]                     stat_test_ila_cnt_7,
   output reg                             stat_test_ila_cnt_7_pls_h = 0,
   input       [31:0]                     stat_test_mf_cnt_7,
   output reg                             stat_test_mf_cnt_7_pls_h = 0,
   input       [2:0]                      stat_rx_ila_jesdv_7,
   input       [2:0]                      stat_rx_ila_subc_7,
   input       [7:0]                      stat_rx_ila_f_7,
   input       [4:0]                      stat_rx_ila_k_7,
   input       [7:0]                      stat_rx_ila_did_7,
   input       [3:0]                      stat_rx_ila_bid_7,
   input       [4:0]                      stat_rx_ila_lid_7,
   input       [4:0]                      stat_rx_ila_l_7,
   input       [7:0]                      stat_rx_ila_m_7,
   input       [4:0]                      stat_rx_ila_n_7,
   input       [4:0]                      stat_rx_ila_np_7,
   input       [1:0]                      stat_rx_ila_cs_7,
   input                                  stat_rx_ila_scr_7,
   input       [4:0]                      stat_rx_ila_s_7,
   input                                  stat_rx_ila_hd_7,
   input       [4:0]                      stat_rx_ila_cf_7,
   input       [3:0]                      stat_rx_ila_adjcnt_7,
   input                                  stat_rx_ila_phadj_7,
   input                                  stat_rx_ila_adjdir_7,
   input       [7:0]                      stat_rx_ila_res1_7,
   input       [7:0]                      stat_rx_ila_res2_7,
   input       [7:0]                      stat_rx_ila_fchk_7,
   output reg                             ctrl_tx_gtpolarity_7 = 0,
   output reg  [1:0]                      ctrl_tx_gtpd_7 = 0,
   output reg                             ctrl_tx_gtelecidle_7 = 0,
   output reg                             ctrl_tx_gtinhibit_7 = 0,
   output reg  [4:0]                      ctrl_tx_gtdiffctrl_7 = 0,
   output reg  [4:0]                      ctrl_tx_gtpostcursor_7 = 0,
   output reg  [4:0]                      ctrl_tx_gtprecursor_7 = 0,
   output reg                             ctrl_rx_gtpolarity_7 = 0,
   output reg  [1:0]                      ctrl_rx_gtpd_7 = 0,

 
   // basic register interface
   input                                  slv_rden,
   input                                  slv_wren,
   input       [31:0]                     slv_wdata,
   input       [C_S_AXI_ADDR_WIDTH-1:2]   slv_addr,
   
   output reg                             slv_rd_done,
   output reg                             slv_wr_done,
   output reg  [31:0]                     slv_rdata
 
);

  localparam C_INT_ADDRWIDTH = C_S_AXI_ADDR_WIDTH - 2;
 
 
   //----------------------------------------------------------------------------
   // Register write logic
   //----------------------------------------------------------------------------
   always @( posedge s_axi_aclk )
   begin
      if (~s_axi_aresetn) begin
        // set RW register defaults

         ctrl_tx_ila_lid_0                        <= ctrl_tx_ila_lid_0_pdef;
         ctrl_tx_ila_nll_0                        <= ctrl_tx_ila_nll_0_pdef;
         stat_rx_err_cnt0_0_pls_h                 <= 1'd0;
         stat_rx_err_cnt1_0_pls_h                 <= 1'd0;
         stat_link_err_cnt_0_pls_h                <= 1'd0;
         stat_test_err_cnt_0_pls_h                <= 1'd0;
         stat_test_ila_cnt_0_pls_h                <= 1'd0;
         stat_test_mf_cnt_0_pls_h                 <= 1'd0;
         ctrl_tx_gtpolarity_0                     <= 1'd0;
         ctrl_tx_gtpd_0                           <= 2'd0;
         ctrl_tx_gtelecidle_0                     <= 1'd0;
         ctrl_tx_gtinhibit_0                      <= 1'd0;
         ctrl_tx_gtdiffctrl_0                     <= 5'd0;
         ctrl_tx_gtpostcursor_0                   <= 5'd0;
         ctrl_tx_gtprecursor_0                    <= 5'd0;
         ctrl_rx_gtpolarity_0                     <= 1'd0;
         ctrl_rx_gtpd_0                           <= 2'd0;

         ctrl_tx_ila_lid_1                        <= ctrl_tx_ila_lid_1_pdef;
         ctrl_tx_ila_nll_1                        <= ctrl_tx_ila_nll_1_pdef;
         stat_rx_err_cnt0_1_pls_h                 <= 1'd0;
         stat_rx_err_cnt1_1_pls_h                 <= 1'd0;
         stat_link_err_cnt_1_pls_h                <= 1'd0;
         stat_test_err_cnt_1_pls_h                <= 1'd0;
         stat_test_ila_cnt_1_pls_h                <= 1'd0;
         stat_test_mf_cnt_1_pls_h                 <= 1'd0;
         ctrl_tx_gtpolarity_1                     <= 1'd0;
         ctrl_tx_gtpd_1                           <= 2'd0;
         ctrl_tx_gtelecidle_1                     <= 1'd0;
         ctrl_tx_gtinhibit_1                      <= 1'd0;
         ctrl_tx_gtdiffctrl_1                     <= 5'd0;
         ctrl_tx_gtpostcursor_1                   <= 5'd0;
         ctrl_tx_gtprecursor_1                    <= 5'd0;
         ctrl_rx_gtpolarity_1                     <= 1'd0;
         ctrl_rx_gtpd_1                           <= 2'd0;

         ctrl_tx_ila_lid_2                        <= ctrl_tx_ila_lid_2_pdef;
         ctrl_tx_ila_nll_2                        <= ctrl_tx_ila_nll_2_pdef;
         stat_rx_err_cnt0_2_pls_h                 <= 1'd0;
         stat_rx_err_cnt1_2_pls_h                 <= 1'd0;
         stat_link_err_cnt_2_pls_h                <= 1'd0;
         stat_test_err_cnt_2_pls_h                <= 1'd0;
         stat_test_ila_cnt_2_pls_h                <= 1'd0;
         stat_test_mf_cnt_2_pls_h                 <= 1'd0;
         ctrl_tx_gtpolarity_2                     <= 1'd0;
         ctrl_tx_gtpd_2                           <= 2'd0;
         ctrl_tx_gtelecidle_2                     <= 1'd0;
         ctrl_tx_gtinhibit_2                      <= 1'd0;
         ctrl_tx_gtdiffctrl_2                     <= 5'd0;
         ctrl_tx_gtpostcursor_2                   <= 5'd0;
         ctrl_tx_gtprecursor_2                    <= 5'd0;
         ctrl_rx_gtpolarity_2                     <= 1'd0;
         ctrl_rx_gtpd_2                           <= 2'd0;

         ctrl_tx_ila_lid_3                        <= ctrl_tx_ila_lid_3_pdef;
         ctrl_tx_ila_nll_3                        <= ctrl_tx_ila_nll_3_pdef;
         stat_rx_err_cnt0_3_pls_h                 <= 1'd0;
         stat_rx_err_cnt1_3_pls_h                 <= 1'd0;
         stat_link_err_cnt_3_pls_h                <= 1'd0;
         stat_test_err_cnt_3_pls_h                <= 1'd0;
         stat_test_ila_cnt_3_pls_h                <= 1'd0;
         stat_test_mf_cnt_3_pls_h                 <= 1'd0;
         ctrl_tx_gtpolarity_3                     <= 1'd0;
         ctrl_tx_gtpd_3                           <= 2'd0;
         ctrl_tx_gtelecidle_3                     <= 1'd0;
         ctrl_tx_gtinhibit_3                      <= 1'd0;
         ctrl_tx_gtdiffctrl_3                     <= 5'd0;
         ctrl_tx_gtpostcursor_3                   <= 5'd0;
         ctrl_tx_gtprecursor_3                    <= 5'd0;
         ctrl_rx_gtpolarity_3                     <= 1'd0;
         ctrl_rx_gtpd_3                           <= 2'd0;

         ctrl_tx_ila_lid_4                        <= ctrl_tx_ila_lid_4_pdef;
         ctrl_tx_ila_nll_4                        <= ctrl_tx_ila_nll_4_pdef;
         stat_rx_err_cnt0_4_pls_h                 <= 1'd0;
         stat_rx_err_cnt1_4_pls_h                 <= 1'd0;
         stat_link_err_cnt_4_pls_h                <= 1'd0;
         stat_test_err_cnt_4_pls_h                <= 1'd0;
         stat_test_ila_cnt_4_pls_h                <= 1'd0;
         stat_test_mf_cnt_4_pls_h                 <= 1'd0;
         ctrl_tx_gtpolarity_4                     <= 1'd0;
         ctrl_tx_gtpd_4                           <= 2'd0;
         ctrl_tx_gtelecidle_4                     <= 1'd0;
         ctrl_tx_gtinhibit_4                      <= 1'd0;
         ctrl_tx_gtdiffctrl_4                     <= 5'd0;
         ctrl_tx_gtpostcursor_4                   <= 5'd0;
         ctrl_tx_gtprecursor_4                    <= 5'd0;
         ctrl_rx_gtpolarity_4                     <= 1'd0;
         ctrl_rx_gtpd_4                           <= 2'd0;

         ctrl_tx_ila_lid_5                        <= ctrl_tx_ila_lid_5_pdef;
         ctrl_tx_ila_nll_5                        <= ctrl_tx_ila_nll_5_pdef;
         stat_rx_err_cnt0_5_pls_h                 <= 1'd0;
         stat_rx_err_cnt1_5_pls_h                 <= 1'd0;
         stat_link_err_cnt_5_pls_h                <= 1'd0;
         stat_test_err_cnt_5_pls_h                <= 1'd0;
         stat_test_ila_cnt_5_pls_h                <= 1'd0;
         stat_test_mf_cnt_5_pls_h                 <= 1'd0;
         ctrl_tx_gtpolarity_5                     <= 1'd0;
         ctrl_tx_gtpd_5                           <= 2'd0;
         ctrl_tx_gtelecidle_5                     <= 1'd0;
         ctrl_tx_gtinhibit_5                      <= 1'd0;
         ctrl_tx_gtdiffctrl_5                     <= 5'd0;
         ctrl_tx_gtpostcursor_5                   <= 5'd0;
         ctrl_tx_gtprecursor_5                    <= 5'd0;
         ctrl_rx_gtpolarity_5                     <= 1'd0;
         ctrl_rx_gtpd_5                           <= 2'd0;

         ctrl_tx_ila_lid_6                        <= ctrl_tx_ila_lid_6_pdef;
         ctrl_tx_ila_nll_6                        <= ctrl_tx_ila_nll_6_pdef;
         stat_rx_err_cnt0_6_pls_h                 <= 1'd0;
         stat_rx_err_cnt1_6_pls_h                 <= 1'd0;
         stat_link_err_cnt_6_pls_h                <= 1'd0;
         stat_test_err_cnt_6_pls_h                <= 1'd0;
         stat_test_ila_cnt_6_pls_h                <= 1'd0;
         stat_test_mf_cnt_6_pls_h                 <= 1'd0;
         ctrl_tx_gtpolarity_6                     <= 1'd0;
         ctrl_tx_gtpd_6                           <= 2'd0;
         ctrl_tx_gtelecidle_6                     <= 1'd0;
         ctrl_tx_gtinhibit_6                      <= 1'd0;
         ctrl_tx_gtdiffctrl_6                     <= 5'd0;
         ctrl_tx_gtpostcursor_6                   <= 5'd0;
         ctrl_tx_gtprecursor_6                    <= 5'd0;
         ctrl_rx_gtpolarity_6                     <= 1'd0;
         ctrl_rx_gtpd_6                           <= 2'd0;

         ctrl_tx_ila_lid_7                        <= ctrl_tx_ila_lid_7_pdef;
         ctrl_tx_ila_nll_7                        <= ctrl_tx_ila_nll_7_pdef;
         stat_rx_err_cnt0_7_pls_h                 <= 1'd0;
         stat_rx_err_cnt1_7_pls_h                 <= 1'd0;
         stat_link_err_cnt_7_pls_h                <= 1'd0;
         stat_test_err_cnt_7_pls_h                <= 1'd0;
         stat_test_ila_cnt_7_pls_h                <= 1'd0;
         stat_test_mf_cnt_7_pls_h                 <= 1'd0;
         ctrl_tx_gtpolarity_7                     <= 1'd0;
         ctrl_tx_gtpd_7                           <= 2'd0;
         ctrl_tx_gtelecidle_7                     <= 1'd0;
         ctrl_tx_gtinhibit_7                      <= 1'd0;
         ctrl_tx_gtdiffctrl_7                     <= 5'd0;
         ctrl_tx_gtpostcursor_7                   <= 5'd0;
         ctrl_tx_gtprecursor_7                    <= 5'd0;
         ctrl_rx_gtpolarity_7                     <= 1'd0;
         ctrl_rx_gtpd_7                           <= 2'd0;

 
      end 
      else begin

         // Always assign the pulse signals here. These can be overidden in the
         // main write function. This is a valid verilog coding style 
         stat_rx_err_cnt0_0_pls_h                 <= slv_rd_done & (slv_addr == 4);
         stat_rx_err_cnt1_0_pls_h                 <= slv_rd_done & (slv_addr == 5);
         stat_link_err_cnt_0_pls_h                <= slv_rd_done & (slv_addr == 8);
         stat_test_err_cnt_0_pls_h                <= slv_rd_done & (slv_addr == 9);
         stat_test_ila_cnt_0_pls_h                <= slv_rd_done & (slv_addr == 10);
         stat_test_mf_cnt_0_pls_h                 <= slv_rd_done & (slv_addr == 11);

         stat_rx_err_cnt0_1_pls_h                 <= slv_rd_done & (slv_addr == 36);
         stat_rx_err_cnt1_1_pls_h                 <= slv_rd_done & (slv_addr == 37);
         stat_link_err_cnt_1_pls_h                <= slv_rd_done & (slv_addr == 40);
         stat_test_err_cnt_1_pls_h                <= slv_rd_done & (slv_addr == 41);
         stat_test_ila_cnt_1_pls_h                <= slv_rd_done & (slv_addr == 42);
         stat_test_mf_cnt_1_pls_h                 <= slv_rd_done & (slv_addr == 43);

         stat_rx_err_cnt0_2_pls_h                 <= slv_rd_done & (slv_addr == 68);
         stat_rx_err_cnt1_2_pls_h                 <= slv_rd_done & (slv_addr == 69);
         stat_link_err_cnt_2_pls_h                <= slv_rd_done & (slv_addr == 72);
         stat_test_err_cnt_2_pls_h                <= slv_rd_done & (slv_addr == 73);
         stat_test_ila_cnt_2_pls_h                <= slv_rd_done & (slv_addr == 74);
         stat_test_mf_cnt_2_pls_h                 <= slv_rd_done & (slv_addr == 75);

         stat_rx_err_cnt0_3_pls_h                 <= slv_rd_done & (slv_addr == 100);
         stat_rx_err_cnt1_3_pls_h                 <= slv_rd_done & (slv_addr == 101);
         stat_link_err_cnt_3_pls_h                <= slv_rd_done & (slv_addr == 104);
         stat_test_err_cnt_3_pls_h                <= slv_rd_done & (slv_addr == 105);
         stat_test_ila_cnt_3_pls_h                <= slv_rd_done & (slv_addr == 106);
         stat_test_mf_cnt_3_pls_h                 <= slv_rd_done & (slv_addr == 107);

         stat_rx_err_cnt0_4_pls_h                 <= slv_rd_done & (slv_addr == 132);
         stat_rx_err_cnt1_4_pls_h                 <= slv_rd_done & (slv_addr == 133);
         stat_link_err_cnt_4_pls_h                <= slv_rd_done & (slv_addr == 136);
         stat_test_err_cnt_4_pls_h                <= slv_rd_done & (slv_addr == 137);
         stat_test_ila_cnt_4_pls_h                <= slv_rd_done & (slv_addr == 138);
         stat_test_mf_cnt_4_pls_h                 <= slv_rd_done & (slv_addr == 139);

         stat_rx_err_cnt0_5_pls_h                 <= slv_rd_done & (slv_addr == 164);
         stat_rx_err_cnt1_5_pls_h                 <= slv_rd_done & (slv_addr == 165);
         stat_link_err_cnt_5_pls_h                <= slv_rd_done & (slv_addr == 168);
         stat_test_err_cnt_5_pls_h                <= slv_rd_done & (slv_addr == 169);
         stat_test_ila_cnt_5_pls_h                <= slv_rd_done & (slv_addr == 170);
         stat_test_mf_cnt_5_pls_h                 <= slv_rd_done & (slv_addr == 171);

         stat_rx_err_cnt0_6_pls_h                 <= slv_rd_done & (slv_addr == 196);
         stat_rx_err_cnt1_6_pls_h                 <= slv_rd_done & (slv_addr == 197);
         stat_link_err_cnt_6_pls_h                <= slv_rd_done & (slv_addr == 200);
         stat_test_err_cnt_6_pls_h                <= slv_rd_done & (slv_addr == 201);
         stat_test_ila_cnt_6_pls_h                <= slv_rd_done & (slv_addr == 202);
         stat_test_mf_cnt_6_pls_h                 <= slv_rd_done & (slv_addr == 203);

         stat_rx_err_cnt0_7_pls_h                 <= slv_rd_done & (slv_addr == 228);
         stat_rx_err_cnt1_7_pls_h                 <= slv_rd_done & (slv_addr == 229);
         stat_link_err_cnt_7_pls_h                <= slv_rd_done & (slv_addr == 232);
         stat_test_err_cnt_7_pls_h                <= slv_rd_done & (slv_addr == 233);
         stat_test_ila_cnt_7_pls_h                <= slv_rd_done & (slv_addr == 234);
         stat_test_mf_cnt_7_pls_h                 <= slv_rd_done & (slv_addr == 235);


         // on a write we write to the appropriate register
         if (slv_wren) begin
            case (slv_addr)
            // WRITE assignments for signal block 0
            'h1     : begin // @ address = 'd4 'h4
                      ctrl_tx_ila_lid_0                        <= slv_wdata[4:0];
                      ctrl_tx_ila_nll_0                        <= slv_wdata[20:16];
                      end
            'h18    : begin // @ address = 'd96 'h60
                      ctrl_tx_gtpolarity_0                     <= slv_wdata[0];
                      ctrl_tx_gtpd_0                           <= slv_wdata[2:1];
                      ctrl_tx_gtelecidle_0                     <= slv_wdata[3];
                      ctrl_tx_gtinhibit_0                      <= slv_wdata[4];
                      ctrl_tx_gtdiffctrl_0                     <= slv_wdata[12:8];
                      ctrl_tx_gtpostcursor_0                   <= slv_wdata[20:16];
                      ctrl_tx_gtprecursor_0                    <= slv_wdata[28:24];
                      end
            'h19    : begin // @ address = 'd100 'h64
                      ctrl_rx_gtpolarity_0                     <= slv_wdata[0];
                      ctrl_rx_gtpd_0                           <= slv_wdata[2:1];
                      end

            // WRITE assignments for signal block 1
            'h21    : begin // @ address = 'd4 'h4
                      ctrl_tx_ila_lid_1                        <= slv_wdata[4:0];
                      ctrl_tx_ila_nll_1                        <= slv_wdata[20:16];
                      end
            'h38    : begin // @ address = 'd96 'h60
                      ctrl_tx_gtpolarity_1                     <= slv_wdata[0];
                      ctrl_tx_gtpd_1                           <= slv_wdata[2:1];
                      ctrl_tx_gtelecidle_1                     <= slv_wdata[3];
                      ctrl_tx_gtinhibit_1                      <= slv_wdata[4];
                      ctrl_tx_gtdiffctrl_1                     <= slv_wdata[12:8];
                      ctrl_tx_gtpostcursor_1                   <= slv_wdata[20:16];
                      ctrl_tx_gtprecursor_1                    <= slv_wdata[28:24];
                      end
            'h39    : begin // @ address = 'd100 'h64
                      ctrl_rx_gtpolarity_1                     <= slv_wdata[0];
                      ctrl_rx_gtpd_1                           <= slv_wdata[2:1];
                      end

            // WRITE assignments for signal block 2
            'h41    : begin // @ address = 'd4 'h4
                      ctrl_tx_ila_lid_2                        <= slv_wdata[4:0];
                      ctrl_tx_ila_nll_2                        <= slv_wdata[20:16];
                      end
            'h58    : begin // @ address = 'd96 'h60
                      ctrl_tx_gtpolarity_2                     <= slv_wdata[0];
                      ctrl_tx_gtpd_2                           <= slv_wdata[2:1];
                      ctrl_tx_gtelecidle_2                     <= slv_wdata[3];
                      ctrl_tx_gtinhibit_2                      <= slv_wdata[4];
                      ctrl_tx_gtdiffctrl_2                     <= slv_wdata[12:8];
                      ctrl_tx_gtpostcursor_2                   <= slv_wdata[20:16];
                      ctrl_tx_gtprecursor_2                    <= slv_wdata[28:24];
                      end
            'h59    : begin // @ address = 'd100 'h64
                      ctrl_rx_gtpolarity_2                     <= slv_wdata[0];
                      ctrl_rx_gtpd_2                           <= slv_wdata[2:1];
                      end

            // WRITE assignments for signal block 3
            'h61    : begin // @ address = 'd4 'h4
                      ctrl_tx_ila_lid_3                        <= slv_wdata[4:0];
                      ctrl_tx_ila_nll_3                        <= slv_wdata[20:16];
                      end
            'h78    : begin // @ address = 'd96 'h60
                      ctrl_tx_gtpolarity_3                     <= slv_wdata[0];
                      ctrl_tx_gtpd_3                           <= slv_wdata[2:1];
                      ctrl_tx_gtelecidle_3                     <= slv_wdata[3];
                      ctrl_tx_gtinhibit_3                      <= slv_wdata[4];
                      ctrl_tx_gtdiffctrl_3                     <= slv_wdata[12:8];
                      ctrl_tx_gtpostcursor_3                   <= slv_wdata[20:16];
                      ctrl_tx_gtprecursor_3                    <= slv_wdata[28:24];
                      end
            'h79    : begin // @ address = 'd100 'h64
                      ctrl_rx_gtpolarity_3                     <= slv_wdata[0];
                      ctrl_rx_gtpd_3                           <= slv_wdata[2:1];
                      end

            // WRITE assignments for signal block 4
            'h81    : begin // @ address = 'd4 'h4
                      ctrl_tx_ila_lid_4                        <= slv_wdata[4:0];
                      ctrl_tx_ila_nll_4                        <= slv_wdata[20:16];
                      end
            'h98    : begin // @ address = 'd96 'h60
                      ctrl_tx_gtpolarity_4                     <= slv_wdata[0];
                      ctrl_tx_gtpd_4                           <= slv_wdata[2:1];
                      ctrl_tx_gtelecidle_4                     <= slv_wdata[3];
                      ctrl_tx_gtinhibit_4                      <= slv_wdata[4];
                      ctrl_tx_gtdiffctrl_4                     <= slv_wdata[12:8];
                      ctrl_tx_gtpostcursor_4                   <= slv_wdata[20:16];
                      ctrl_tx_gtprecursor_4                    <= slv_wdata[28:24];
                      end
            'h99    : begin // @ address = 'd100 'h64
                      ctrl_rx_gtpolarity_4                     <= slv_wdata[0];
                      ctrl_rx_gtpd_4                           <= slv_wdata[2:1];
                      end

            // WRITE assignments for signal block 5
            'ha1    : begin // @ address = 'd4 'h4
                      ctrl_tx_ila_lid_5                        <= slv_wdata[4:0];
                      ctrl_tx_ila_nll_5                        <= slv_wdata[20:16];
                      end
            'hb8    : begin // @ address = 'd96 'h60
                      ctrl_tx_gtpolarity_5                     <= slv_wdata[0];
                      ctrl_tx_gtpd_5                           <= slv_wdata[2:1];
                      ctrl_tx_gtelecidle_5                     <= slv_wdata[3];
                      ctrl_tx_gtinhibit_5                      <= slv_wdata[4];
                      ctrl_tx_gtdiffctrl_5                     <= slv_wdata[12:8];
                      ctrl_tx_gtpostcursor_5                   <= slv_wdata[20:16];
                      ctrl_tx_gtprecursor_5                    <= slv_wdata[28:24];
                      end
            'hb9    : begin // @ address = 'd100 'h64
                      ctrl_rx_gtpolarity_5                     <= slv_wdata[0];
                      ctrl_rx_gtpd_5                           <= slv_wdata[2:1];
                      end

            // WRITE assignments for signal block 6
            'hc1    : begin // @ address = 'd4 'h4
                      ctrl_tx_ila_lid_6                        <= slv_wdata[4:0];
                      ctrl_tx_ila_nll_6                        <= slv_wdata[20:16];
                      end
            'hd8    : begin // @ address = 'd96 'h60
                      ctrl_tx_gtpolarity_6                     <= slv_wdata[0];
                      ctrl_tx_gtpd_6                           <= slv_wdata[2:1];
                      ctrl_tx_gtelecidle_6                     <= slv_wdata[3];
                      ctrl_tx_gtinhibit_6                      <= slv_wdata[4];
                      ctrl_tx_gtdiffctrl_6                     <= slv_wdata[12:8];
                      ctrl_tx_gtpostcursor_6                   <= slv_wdata[20:16];
                      ctrl_tx_gtprecursor_6                    <= slv_wdata[28:24];
                      end
            'hd9    : begin // @ address = 'd100 'h64
                      ctrl_rx_gtpolarity_6                     <= slv_wdata[0];
                      ctrl_rx_gtpd_6                           <= slv_wdata[2:1];
                      end

            // WRITE assignments for signal block 7
            'he1    : begin // @ address = 'd4 'h4
                      ctrl_tx_ila_lid_7                        <= slv_wdata[4:0];
                      ctrl_tx_ila_nll_7                        <= slv_wdata[20:16];
                      end
            'hf8    : begin // @ address = 'd96 'h60
                      ctrl_tx_gtpolarity_7                     <= slv_wdata[0];
                      ctrl_tx_gtpd_7                           <= slv_wdata[2:1];
                      ctrl_tx_gtelecidle_7                     <= slv_wdata[3];
                      ctrl_tx_gtinhibit_7                      <= slv_wdata[4];
                      ctrl_tx_gtdiffctrl_7                     <= slv_wdata[12:8];
                      ctrl_tx_gtpostcursor_7                   <= slv_wdata[20:16];
                      ctrl_tx_gtprecursor_7                    <= slv_wdata[28:24];
                      end
            'hf9    : begin // @ address = 'd100 'h64
                      ctrl_rx_gtpolarity_7                     <= slv_wdata[0];
                      ctrl_rx_gtpd_7                           <= slv_wdata[2:1];
                      end

            endcase
         end

      end
   end
   //----------------------------------------------------------------------------
   // Register read logic, non registered, 
   //---------------------------------------------------------------------------
   always @(*)
     begin
     slv_rdata = 'd0; // Zero all data bits, individual bits may be modified in the case below
     case (slv_addr)
     // READ assignments for signal block 0
     'h0     : begin // @ address = 'd0 'h0
               slv_rdata[9:0]       = stat_rx_buf_lvl_0;
               end
     'h1     : begin // @ address = 'd4 'h4
               slv_rdata[4:0]       = ctrl_tx_ila_lid_0;
               slv_rdata[20:16]     = ctrl_tx_ila_nll_0;
               end
     'h4     : begin // @ address = 'd16 'h10
               slv_rdata[31:0]      = stat_rx_err_cnt0_0;
               end
     'h5     : begin // @ address = 'd20 'h14
               slv_rdata[31:0]      = stat_rx_err_cnt1_0;
               end
     'h8     : begin // @ address = 'd32 'h20
               slv_rdata[31:0]      = stat_link_err_cnt_0;
               end
     'h9     : begin // @ address = 'd36 'h24
               slv_rdata[31:0]      = stat_test_err_cnt_0;
               end
     'ha     : begin // @ address = 'd40 'h28
               slv_rdata[31:0]      = stat_test_ila_cnt_0;
               end
     'hb     : begin // @ address = 'd44 'h2c
               slv_rdata[31:0]      = stat_test_mf_cnt_0;
               end
     'hc     : begin // @ address = 'd48 'h30
               slv_rdata[10:8]      = stat_rx_ila_jesdv_0;
               slv_rdata[2:0]       = stat_rx_ila_subc_0;
               end
     'hd     : begin // @ address = 'd52 'h34
               slv_rdata[7:0]       = stat_rx_ila_f_0;
               end
     'he     : begin // @ address = 'd56 'h38
               slv_rdata[4:0]       = stat_rx_ila_k_0;
               end
     'hf     : begin // @ address = 'd60 'h3c
               slv_rdata[7:0]       = stat_rx_ila_did_0;
               slv_rdata[11:8]      = stat_rx_ila_bid_0;
               slv_rdata[20:16]     = stat_rx_ila_lid_0;
               slv_rdata[28:24]     = stat_rx_ila_l_0;
               end
     'h10    : begin // @ address = 'd64 'h40
               slv_rdata[7:0]       = stat_rx_ila_m_0;
               slv_rdata[12:8]      = stat_rx_ila_n_0;
               slv_rdata[20:16]     = stat_rx_ila_np_0;
               slv_rdata[25:24]     = stat_rx_ila_cs_0;
               end
     'h11    : begin // @ address = 'd68 'h44
               slv_rdata[0]         = stat_rx_ila_scr_0;
               slv_rdata[12:8]      = stat_rx_ila_s_0;
               slv_rdata[16]        = stat_rx_ila_hd_0;
               slv_rdata[28:24]     = stat_rx_ila_cf_0;
               end
     'h12    : begin // @ address = 'd72 'h48
               slv_rdata[3:0]       = stat_rx_ila_adjcnt_0;
               slv_rdata[8]         = stat_rx_ila_phadj_0;
               slv_rdata[16]        = stat_rx_ila_adjdir_0;
               end
     'h13    : begin // @ address = 'd76 'h4c
               slv_rdata[7:0]       = stat_rx_ila_res1_0;
               slv_rdata[15:8]      = stat_rx_ila_res2_0;
               slv_rdata[23:16]     = stat_rx_ila_fchk_0;
               end
     'h18    : begin // @ address = 'd96 'h60
               slv_rdata[0]         = ctrl_tx_gtpolarity_0;
               slv_rdata[2:1]       = ctrl_tx_gtpd_0;
               slv_rdata[3]         = ctrl_tx_gtelecidle_0;
               slv_rdata[4]         = ctrl_tx_gtinhibit_0;
               slv_rdata[12:8]      = ctrl_tx_gtdiffctrl_0;
               slv_rdata[20:16]     = ctrl_tx_gtpostcursor_0;
               slv_rdata[28:24]     = ctrl_tx_gtprecursor_0;
               end
     'h19    : begin // @ address = 'd100 'h64
               slv_rdata[0]         = ctrl_rx_gtpolarity_0;
               slv_rdata[2:1]       = ctrl_rx_gtpd_0;
               end

     // READ assignments for signal block 1
     'h20    : begin // @ address = 'd0 'h0
               slv_rdata[9:0]       = stat_rx_buf_lvl_1;
               end
     'h21    : begin // @ address = 'd4 'h4
               slv_rdata[4:0]       = ctrl_tx_ila_lid_1;
               slv_rdata[20:16]     = ctrl_tx_ila_nll_1;
               end
     'h24    : begin // @ address = 'd16 'h10
               slv_rdata[31:0]      = stat_rx_err_cnt0_1;
               end
     'h25    : begin // @ address = 'd20 'h14
               slv_rdata[31:0]      = stat_rx_err_cnt1_1;
               end
     'h28    : begin // @ address = 'd32 'h20
               slv_rdata[31:0]      = stat_link_err_cnt_1;
               end
     'h29    : begin // @ address = 'd36 'h24
               slv_rdata[31:0]      = stat_test_err_cnt_1;
               end
     'h2a    : begin // @ address = 'd40 'h28
               slv_rdata[31:0]      = stat_test_ila_cnt_1;
               end
     'h2b    : begin // @ address = 'd44 'h2c
               slv_rdata[31:0]      = stat_test_mf_cnt_1;
               end
     'h2c    : begin // @ address = 'd48 'h30
               slv_rdata[10:8]      = stat_rx_ila_jesdv_1;
               slv_rdata[2:0]       = stat_rx_ila_subc_1;
               end
     'h2d    : begin // @ address = 'd52 'h34
               slv_rdata[7:0]       = stat_rx_ila_f_1;
               end
     'h2e    : begin // @ address = 'd56 'h38
               slv_rdata[4:0]       = stat_rx_ila_k_1;
               end
     'h2f    : begin // @ address = 'd60 'h3c
               slv_rdata[7:0]       = stat_rx_ila_did_1;
               slv_rdata[11:8]      = stat_rx_ila_bid_1;
               slv_rdata[20:16]     = stat_rx_ila_lid_1;
               slv_rdata[28:24]     = stat_rx_ila_l_1;
               end
     'h30    : begin // @ address = 'd64 'h40
               slv_rdata[7:0]       = stat_rx_ila_m_1;
               slv_rdata[12:8]      = stat_rx_ila_n_1;
               slv_rdata[20:16]     = stat_rx_ila_np_1;
               slv_rdata[25:24]     = stat_rx_ila_cs_1;
               end
     'h31    : begin // @ address = 'd68 'h44
               slv_rdata[0]         = stat_rx_ila_scr_1;
               slv_rdata[12:8]      = stat_rx_ila_s_1;
               slv_rdata[16]        = stat_rx_ila_hd_1;
               slv_rdata[28:24]     = stat_rx_ila_cf_1;
               end
     'h32    : begin // @ address = 'd72 'h48
               slv_rdata[3:0]       = stat_rx_ila_adjcnt_1;
               slv_rdata[8]         = stat_rx_ila_phadj_1;
               slv_rdata[16]        = stat_rx_ila_adjdir_1;
               end
     'h33    : begin // @ address = 'd76 'h4c
               slv_rdata[7:0]       = stat_rx_ila_res1_1;
               slv_rdata[15:8]      = stat_rx_ila_res2_1;
               slv_rdata[23:16]     = stat_rx_ila_fchk_1;
               end
     'h38    : begin // @ address = 'd96 'h60
               slv_rdata[0]         = ctrl_tx_gtpolarity_1;
               slv_rdata[2:1]       = ctrl_tx_gtpd_1;
               slv_rdata[3]         = ctrl_tx_gtelecidle_1;
               slv_rdata[4]         = ctrl_tx_gtinhibit_1;
               slv_rdata[12:8]      = ctrl_tx_gtdiffctrl_1;
               slv_rdata[20:16]     = ctrl_tx_gtpostcursor_1;
               slv_rdata[28:24]     = ctrl_tx_gtprecursor_1;
               end
     'h39    : begin // @ address = 'd100 'h64
               slv_rdata[0]         = ctrl_rx_gtpolarity_1;
               slv_rdata[2:1]       = ctrl_rx_gtpd_1;
               end

     // READ assignments for signal block 2
     'h40    : begin // @ address = 'd0 'h0
               slv_rdata[9:0]       = stat_rx_buf_lvl_2;
               end
     'h41    : begin // @ address = 'd4 'h4
               slv_rdata[4:0]       = ctrl_tx_ila_lid_2;
               slv_rdata[20:16]     = ctrl_tx_ila_nll_2;
               end
     'h44    : begin // @ address = 'd16 'h10
               slv_rdata[31:0]      = stat_rx_err_cnt0_2;
               end
     'h45    : begin // @ address = 'd20 'h14
               slv_rdata[31:0]      = stat_rx_err_cnt1_2;
               end
     'h48    : begin // @ address = 'd32 'h20
               slv_rdata[31:0]      = stat_link_err_cnt_2;
               end
     'h49    : begin // @ address = 'd36 'h24
               slv_rdata[31:0]      = stat_test_err_cnt_2;
               end
     'h4a    : begin // @ address = 'd40 'h28
               slv_rdata[31:0]      = stat_test_ila_cnt_2;
               end
     'h4b    : begin // @ address = 'd44 'h2c
               slv_rdata[31:0]      = stat_test_mf_cnt_2;
               end
     'h4c    : begin // @ address = 'd48 'h30
               slv_rdata[10:8]      = stat_rx_ila_jesdv_2;
               slv_rdata[2:0]       = stat_rx_ila_subc_2;
               end
     'h4d    : begin // @ address = 'd52 'h34
               slv_rdata[7:0]       = stat_rx_ila_f_2;
               end
     'h4e    : begin // @ address = 'd56 'h38
               slv_rdata[4:0]       = stat_rx_ila_k_2;
               end
     'h4f    : begin // @ address = 'd60 'h3c
               slv_rdata[7:0]       = stat_rx_ila_did_2;
               slv_rdata[11:8]      = stat_rx_ila_bid_2;
               slv_rdata[20:16]     = stat_rx_ila_lid_2;
               slv_rdata[28:24]     = stat_rx_ila_l_2;
               end
     'h50    : begin // @ address = 'd64 'h40
               slv_rdata[7:0]       = stat_rx_ila_m_2;
               slv_rdata[12:8]      = stat_rx_ila_n_2;
               slv_rdata[20:16]     = stat_rx_ila_np_2;
               slv_rdata[25:24]     = stat_rx_ila_cs_2;
               end
     'h51    : begin // @ address = 'd68 'h44
               slv_rdata[0]         = stat_rx_ila_scr_2;
               slv_rdata[12:8]      = stat_rx_ila_s_2;
               slv_rdata[16]        = stat_rx_ila_hd_2;
               slv_rdata[28:24]     = stat_rx_ila_cf_2;
               end
     'h52    : begin // @ address = 'd72 'h48
               slv_rdata[3:0]       = stat_rx_ila_adjcnt_2;
               slv_rdata[8]         = stat_rx_ila_phadj_2;
               slv_rdata[16]        = stat_rx_ila_adjdir_2;
               end
     'h53    : begin // @ address = 'd76 'h4c
               slv_rdata[7:0]       = stat_rx_ila_res1_2;
               slv_rdata[15:8]      = stat_rx_ila_res2_2;
               slv_rdata[23:16]     = stat_rx_ila_fchk_2;
               end
     'h58    : begin // @ address = 'd96 'h60
               slv_rdata[0]         = ctrl_tx_gtpolarity_2;
               slv_rdata[2:1]       = ctrl_tx_gtpd_2;
               slv_rdata[3]         = ctrl_tx_gtelecidle_2;
               slv_rdata[4]         = ctrl_tx_gtinhibit_2;
               slv_rdata[12:8]      = ctrl_tx_gtdiffctrl_2;
               slv_rdata[20:16]     = ctrl_tx_gtpostcursor_2;
               slv_rdata[28:24]     = ctrl_tx_gtprecursor_2;
               end
     'h59    : begin // @ address = 'd100 'h64
               slv_rdata[0]         = ctrl_rx_gtpolarity_2;
               slv_rdata[2:1]       = ctrl_rx_gtpd_2;
               end

     // READ assignments for signal block 3
     'h60    : begin // @ address = 'd0 'h0
               slv_rdata[9:0]       = stat_rx_buf_lvl_3;
               end
     'h61    : begin // @ address = 'd4 'h4
               slv_rdata[4:0]       = ctrl_tx_ila_lid_3;
               slv_rdata[20:16]     = ctrl_tx_ila_nll_3;
               end
     'h64    : begin // @ address = 'd16 'h10
               slv_rdata[31:0]      = stat_rx_err_cnt0_3;
               end
     'h65    : begin // @ address = 'd20 'h14
               slv_rdata[31:0]      = stat_rx_err_cnt1_3;
               end
     'h68    : begin // @ address = 'd32 'h20
               slv_rdata[31:0]      = stat_link_err_cnt_3;
               end
     'h69    : begin // @ address = 'd36 'h24
               slv_rdata[31:0]      = stat_test_err_cnt_3;
               end
     'h6a    : begin // @ address = 'd40 'h28
               slv_rdata[31:0]      = stat_test_ila_cnt_3;
               end
     'h6b    : begin // @ address = 'd44 'h2c
               slv_rdata[31:0]      = stat_test_mf_cnt_3;
               end
     'h6c    : begin // @ address = 'd48 'h30
               slv_rdata[10:8]      = stat_rx_ila_jesdv_3;
               slv_rdata[2:0]       = stat_rx_ila_subc_3;
               end
     'h6d    : begin // @ address = 'd52 'h34
               slv_rdata[7:0]       = stat_rx_ila_f_3;
               end
     'h6e    : begin // @ address = 'd56 'h38
               slv_rdata[4:0]       = stat_rx_ila_k_3;
               end
     'h6f    : begin // @ address = 'd60 'h3c
               slv_rdata[7:0]       = stat_rx_ila_did_3;
               slv_rdata[11:8]      = stat_rx_ila_bid_3;
               slv_rdata[20:16]     = stat_rx_ila_lid_3;
               slv_rdata[28:24]     = stat_rx_ila_l_3;
               end
     'h70    : begin // @ address = 'd64 'h40
               slv_rdata[7:0]       = stat_rx_ila_m_3;
               slv_rdata[12:8]      = stat_rx_ila_n_3;
               slv_rdata[20:16]     = stat_rx_ila_np_3;
               slv_rdata[25:24]     = stat_rx_ila_cs_3;
               end
     'h71    : begin // @ address = 'd68 'h44
               slv_rdata[0]         = stat_rx_ila_scr_3;
               slv_rdata[12:8]      = stat_rx_ila_s_3;
               slv_rdata[16]        = stat_rx_ila_hd_3;
               slv_rdata[28:24]     = stat_rx_ila_cf_3;
               end
     'h72    : begin // @ address = 'd72 'h48
               slv_rdata[3:0]       = stat_rx_ila_adjcnt_3;
               slv_rdata[8]         = stat_rx_ila_phadj_3;
               slv_rdata[16]        = stat_rx_ila_adjdir_3;
               end
     'h73    : begin // @ address = 'd76 'h4c
               slv_rdata[7:0]       = stat_rx_ila_res1_3;
               slv_rdata[15:8]      = stat_rx_ila_res2_3;
               slv_rdata[23:16]     = stat_rx_ila_fchk_3;
               end
     'h78    : begin // @ address = 'd96 'h60
               slv_rdata[0]         = ctrl_tx_gtpolarity_3;
               slv_rdata[2:1]       = ctrl_tx_gtpd_3;
               slv_rdata[3]         = ctrl_tx_gtelecidle_3;
               slv_rdata[4]         = ctrl_tx_gtinhibit_3;
               slv_rdata[12:8]      = ctrl_tx_gtdiffctrl_3;
               slv_rdata[20:16]     = ctrl_tx_gtpostcursor_3;
               slv_rdata[28:24]     = ctrl_tx_gtprecursor_3;
               end
     'h79    : begin // @ address = 'd100 'h64
               slv_rdata[0]         = ctrl_rx_gtpolarity_3;
               slv_rdata[2:1]       = ctrl_rx_gtpd_3;
               end

     // READ assignments for signal block 4
     'h80    : begin // @ address = 'd0 'h0
               slv_rdata[9:0]       = stat_rx_buf_lvl_4;
               end
     'h81    : begin // @ address = 'd4 'h4
               slv_rdata[4:0]       = ctrl_tx_ila_lid_4;
               slv_rdata[20:16]     = ctrl_tx_ila_nll_4;
               end
     'h84    : begin // @ address = 'd16 'h10
               slv_rdata[31:0]      = stat_rx_err_cnt0_4;
               end
     'h85    : begin // @ address = 'd20 'h14
               slv_rdata[31:0]      = stat_rx_err_cnt1_4;
               end
     'h88    : begin // @ address = 'd32 'h20
               slv_rdata[31:0]      = stat_link_err_cnt_4;
               end
     'h89    : begin // @ address = 'd36 'h24
               slv_rdata[31:0]      = stat_test_err_cnt_4;
               end
     'h8a    : begin // @ address = 'd40 'h28
               slv_rdata[31:0]      = stat_test_ila_cnt_4;
               end
     'h8b    : begin // @ address = 'd44 'h2c
               slv_rdata[31:0]      = stat_test_mf_cnt_4;
               end
     'h8c    : begin // @ address = 'd48 'h30
               slv_rdata[10:8]      = stat_rx_ila_jesdv_4;
               slv_rdata[2:0]       = stat_rx_ila_subc_4;
               end
     'h8d    : begin // @ address = 'd52 'h34
               slv_rdata[7:0]       = stat_rx_ila_f_4;
               end
     'h8e    : begin // @ address = 'd56 'h38
               slv_rdata[4:0]       = stat_rx_ila_k_4;
               end
     'h8f    : begin // @ address = 'd60 'h3c
               slv_rdata[7:0]       = stat_rx_ila_did_4;
               slv_rdata[11:8]      = stat_rx_ila_bid_4;
               slv_rdata[20:16]     = stat_rx_ila_lid_4;
               slv_rdata[28:24]     = stat_rx_ila_l_4;
               end
     'h90    : begin // @ address = 'd64 'h40
               slv_rdata[7:0]       = stat_rx_ila_m_4;
               slv_rdata[12:8]      = stat_rx_ila_n_4;
               slv_rdata[20:16]     = stat_rx_ila_np_4;
               slv_rdata[25:24]     = stat_rx_ila_cs_4;
               end
     'h91    : begin // @ address = 'd68 'h44
               slv_rdata[0]         = stat_rx_ila_scr_4;
               slv_rdata[12:8]      = stat_rx_ila_s_4;
               slv_rdata[16]        = stat_rx_ila_hd_4;
               slv_rdata[28:24]     = stat_rx_ila_cf_4;
               end
     'h92    : begin // @ address = 'd72 'h48
               slv_rdata[3:0]       = stat_rx_ila_adjcnt_4;
               slv_rdata[8]         = stat_rx_ila_phadj_4;
               slv_rdata[16]        = stat_rx_ila_adjdir_4;
               end
     'h93    : begin // @ address = 'd76 'h4c
               slv_rdata[7:0]       = stat_rx_ila_res1_4;
               slv_rdata[15:8]      = stat_rx_ila_res2_4;
               slv_rdata[23:16]     = stat_rx_ila_fchk_4;
               end
     'h98    : begin // @ address = 'd96 'h60
               slv_rdata[0]         = ctrl_tx_gtpolarity_4;
               slv_rdata[2:1]       = ctrl_tx_gtpd_4;
               slv_rdata[3]         = ctrl_tx_gtelecidle_4;
               slv_rdata[4]         = ctrl_tx_gtinhibit_4;
               slv_rdata[12:8]      = ctrl_tx_gtdiffctrl_4;
               slv_rdata[20:16]     = ctrl_tx_gtpostcursor_4;
               slv_rdata[28:24]     = ctrl_tx_gtprecursor_4;
               end
     'h99    : begin // @ address = 'd100 'h64
               slv_rdata[0]         = ctrl_rx_gtpolarity_4;
               slv_rdata[2:1]       = ctrl_rx_gtpd_4;
               end

     // READ assignments for signal block 5
     'ha0    : begin // @ address = 'd0 'h0
               slv_rdata[9:0]       = stat_rx_buf_lvl_5;
               end
     'ha1    : begin // @ address = 'd4 'h4
               slv_rdata[4:0]       = ctrl_tx_ila_lid_5;
               slv_rdata[20:16]     = ctrl_tx_ila_nll_5;
               end
     'ha4    : begin // @ address = 'd16 'h10
               slv_rdata[31:0]      = stat_rx_err_cnt0_5;
               end
     'ha5    : begin // @ address = 'd20 'h14
               slv_rdata[31:0]      = stat_rx_err_cnt1_5;
               end
     'ha8    : begin // @ address = 'd32 'h20
               slv_rdata[31:0]      = stat_link_err_cnt_5;
               end
     'ha9    : begin // @ address = 'd36 'h24
               slv_rdata[31:0]      = stat_test_err_cnt_5;
               end
     'haa    : begin // @ address = 'd40 'h28
               slv_rdata[31:0]      = stat_test_ila_cnt_5;
               end
     'hab    : begin // @ address = 'd44 'h2c
               slv_rdata[31:0]      = stat_test_mf_cnt_5;
               end
     'hac    : begin // @ address = 'd48 'h30
               slv_rdata[10:8]      = stat_rx_ila_jesdv_5;
               slv_rdata[2:0]       = stat_rx_ila_subc_5;
               end
     'had    : begin // @ address = 'd52 'h34
               slv_rdata[7:0]       = stat_rx_ila_f_5;
               end
     'hae    : begin // @ address = 'd56 'h38
               slv_rdata[4:0]       = stat_rx_ila_k_5;
               end
     'haf    : begin // @ address = 'd60 'h3c
               slv_rdata[7:0]       = stat_rx_ila_did_5;
               slv_rdata[11:8]      = stat_rx_ila_bid_5;
               slv_rdata[20:16]     = stat_rx_ila_lid_5;
               slv_rdata[28:24]     = stat_rx_ila_l_5;
               end
     'hb0    : begin // @ address = 'd64 'h40
               slv_rdata[7:0]       = stat_rx_ila_m_5;
               slv_rdata[12:8]      = stat_rx_ila_n_5;
               slv_rdata[20:16]     = stat_rx_ila_np_5;
               slv_rdata[25:24]     = stat_rx_ila_cs_5;
               end
     'hb1    : begin // @ address = 'd68 'h44
               slv_rdata[0]         = stat_rx_ila_scr_5;
               slv_rdata[12:8]      = stat_rx_ila_s_5;
               slv_rdata[16]        = stat_rx_ila_hd_5;
               slv_rdata[28:24]     = stat_rx_ila_cf_5;
               end
     'hb2    : begin // @ address = 'd72 'h48
               slv_rdata[3:0]       = stat_rx_ila_adjcnt_5;
               slv_rdata[8]         = stat_rx_ila_phadj_5;
               slv_rdata[16]        = stat_rx_ila_adjdir_5;
               end
     'hb3    : begin // @ address = 'd76 'h4c
               slv_rdata[7:0]       = stat_rx_ila_res1_5;
               slv_rdata[15:8]      = stat_rx_ila_res2_5;
               slv_rdata[23:16]     = stat_rx_ila_fchk_5;
               end
     'hb8    : begin // @ address = 'd96 'h60
               slv_rdata[0]         = ctrl_tx_gtpolarity_5;
               slv_rdata[2:1]       = ctrl_tx_gtpd_5;
               slv_rdata[3]         = ctrl_tx_gtelecidle_5;
               slv_rdata[4]         = ctrl_tx_gtinhibit_5;
               slv_rdata[12:8]      = ctrl_tx_gtdiffctrl_5;
               slv_rdata[20:16]     = ctrl_tx_gtpostcursor_5;
               slv_rdata[28:24]     = ctrl_tx_gtprecursor_5;
               end
     'hb9    : begin // @ address = 'd100 'h64
               slv_rdata[0]         = ctrl_rx_gtpolarity_5;
               slv_rdata[2:1]       = ctrl_rx_gtpd_5;
               end

     // READ assignments for signal block 6
     'hc0    : begin // @ address = 'd0 'h0
               slv_rdata[9:0]       = stat_rx_buf_lvl_6;
               end
     'hc1    : begin // @ address = 'd4 'h4
               slv_rdata[4:0]       = ctrl_tx_ila_lid_6;
               slv_rdata[20:16]     = ctrl_tx_ila_nll_6;
               end
     'hc4    : begin // @ address = 'd16 'h10
               slv_rdata[31:0]      = stat_rx_err_cnt0_6;
               end
     'hc5    : begin // @ address = 'd20 'h14
               slv_rdata[31:0]      = stat_rx_err_cnt1_6;
               end
     'hc8    : begin // @ address = 'd32 'h20
               slv_rdata[31:0]      = stat_link_err_cnt_6;
               end
     'hc9    : begin // @ address = 'd36 'h24
               slv_rdata[31:0]      = stat_test_err_cnt_6;
               end
     'hca    : begin // @ address = 'd40 'h28
               slv_rdata[31:0]      = stat_test_ila_cnt_6;
               end
     'hcb    : begin // @ address = 'd44 'h2c
               slv_rdata[31:0]      = stat_test_mf_cnt_6;
               end
     'hcc    : begin // @ address = 'd48 'h30
               slv_rdata[10:8]      = stat_rx_ila_jesdv_6;
               slv_rdata[2:0]       = stat_rx_ila_subc_6;
               end
     'hcd    : begin // @ address = 'd52 'h34
               slv_rdata[7:0]       = stat_rx_ila_f_6;
               end
     'hce    : begin // @ address = 'd56 'h38
               slv_rdata[4:0]       = stat_rx_ila_k_6;
               end
     'hcf    : begin // @ address = 'd60 'h3c
               slv_rdata[7:0]       = stat_rx_ila_did_6;
               slv_rdata[11:8]      = stat_rx_ila_bid_6;
               slv_rdata[20:16]     = stat_rx_ila_lid_6;
               slv_rdata[28:24]     = stat_rx_ila_l_6;
               end
     'hd0    : begin // @ address = 'd64 'h40
               slv_rdata[7:0]       = stat_rx_ila_m_6;
               slv_rdata[12:8]      = stat_rx_ila_n_6;
               slv_rdata[20:16]     = stat_rx_ila_np_6;
               slv_rdata[25:24]     = stat_rx_ila_cs_6;
               end
     'hd1    : begin // @ address = 'd68 'h44
               slv_rdata[0]         = stat_rx_ila_scr_6;
               slv_rdata[12:8]      = stat_rx_ila_s_6;
               slv_rdata[16]        = stat_rx_ila_hd_6;
               slv_rdata[28:24]     = stat_rx_ila_cf_6;
               end
     'hd2    : begin // @ address = 'd72 'h48
               slv_rdata[3:0]       = stat_rx_ila_adjcnt_6;
               slv_rdata[8]         = stat_rx_ila_phadj_6;
               slv_rdata[16]        = stat_rx_ila_adjdir_6;
               end
     'hd3    : begin // @ address = 'd76 'h4c
               slv_rdata[7:0]       = stat_rx_ila_res1_6;
               slv_rdata[15:8]      = stat_rx_ila_res2_6;
               slv_rdata[23:16]     = stat_rx_ila_fchk_6;
               end
     'hd8    : begin // @ address = 'd96 'h60
               slv_rdata[0]         = ctrl_tx_gtpolarity_6;
               slv_rdata[2:1]       = ctrl_tx_gtpd_6;
               slv_rdata[3]         = ctrl_tx_gtelecidle_6;
               slv_rdata[4]         = ctrl_tx_gtinhibit_6;
               slv_rdata[12:8]      = ctrl_tx_gtdiffctrl_6;
               slv_rdata[20:16]     = ctrl_tx_gtpostcursor_6;
               slv_rdata[28:24]     = ctrl_tx_gtprecursor_6;
               end
     'hd9    : begin // @ address = 'd100 'h64
               slv_rdata[0]         = ctrl_rx_gtpolarity_6;
               slv_rdata[2:1]       = ctrl_rx_gtpd_6;
               end

     // READ assignments for signal block 7
     'he0    : begin // @ address = 'd0 'h0
               slv_rdata[9:0]       = stat_rx_buf_lvl_7;
               end
     'he1    : begin // @ address = 'd4 'h4
               slv_rdata[4:0]       = ctrl_tx_ila_lid_7;
               slv_rdata[20:16]     = ctrl_tx_ila_nll_7;
               end
     'he4    : begin // @ address = 'd16 'h10
               slv_rdata[31:0]      = stat_rx_err_cnt0_7;
               end
     'he5    : begin // @ address = 'd20 'h14
               slv_rdata[31:0]      = stat_rx_err_cnt1_7;
               end
     'he8    : begin // @ address = 'd32 'h20
               slv_rdata[31:0]      = stat_link_err_cnt_7;
               end
     'he9    : begin // @ address = 'd36 'h24
               slv_rdata[31:0]      = stat_test_err_cnt_7;
               end
     'hea    : begin // @ address = 'd40 'h28
               slv_rdata[31:0]      = stat_test_ila_cnt_7;
               end
     'heb    : begin // @ address = 'd44 'h2c
               slv_rdata[31:0]      = stat_test_mf_cnt_7;
               end
     'hec    : begin // @ address = 'd48 'h30
               slv_rdata[10:8]      = stat_rx_ila_jesdv_7;
               slv_rdata[2:0]       = stat_rx_ila_subc_7;
               end
     'hed    : begin // @ address = 'd52 'h34
               slv_rdata[7:0]       = stat_rx_ila_f_7;
               end
     'hee    : begin // @ address = 'd56 'h38
               slv_rdata[4:0]       = stat_rx_ila_k_7;
               end
     'hef    : begin // @ address = 'd60 'h3c
               slv_rdata[7:0]       = stat_rx_ila_did_7;
               slv_rdata[11:8]      = stat_rx_ila_bid_7;
               slv_rdata[20:16]     = stat_rx_ila_lid_7;
               slv_rdata[28:24]     = stat_rx_ila_l_7;
               end
     'hf0    : begin // @ address = 'd64 'h40
               slv_rdata[7:0]       = stat_rx_ila_m_7;
               slv_rdata[12:8]      = stat_rx_ila_n_7;
               slv_rdata[20:16]     = stat_rx_ila_np_7;
               slv_rdata[25:24]     = stat_rx_ila_cs_7;
               end
     'hf1    : begin // @ address = 'd68 'h44
               slv_rdata[0]         = stat_rx_ila_scr_7;
               slv_rdata[12:8]      = stat_rx_ila_s_7;
               slv_rdata[16]        = stat_rx_ila_hd_7;
               slv_rdata[28:24]     = stat_rx_ila_cf_7;
               end
     'hf2    : begin // @ address = 'd72 'h48
               slv_rdata[3:0]       = stat_rx_ila_adjcnt_7;
               slv_rdata[8]         = stat_rx_ila_phadj_7;
               slv_rdata[16]        = stat_rx_ila_adjdir_7;
               end
     'hf3    : begin // @ address = 'd76 'h4c
               slv_rdata[7:0]       = stat_rx_ila_res1_7;
               slv_rdata[15:8]      = stat_rx_ila_res2_7;
               slv_rdata[23:16]     = stat_rx_ila_fchk_7;
               end
     'hf8    : begin // @ address = 'd96 'h60
               slv_rdata[0]         = ctrl_tx_gtpolarity_7;
               slv_rdata[2:1]       = ctrl_tx_gtpd_7;
               slv_rdata[3]         = ctrl_tx_gtelecidle_7;
               slv_rdata[4]         = ctrl_tx_gtinhibit_7;
               slv_rdata[12:8]      = ctrl_tx_gtdiffctrl_7;
               slv_rdata[20:16]     = ctrl_tx_gtpostcursor_7;
               slv_rdata[28:24]     = ctrl_tx_gtprecursor_7;
               end
     'hf9    : begin // @ address = 'd100 'h64
               slv_rdata[0]         = ctrl_rx_gtpolarity_7;
               slv_rdata[2:1]       = ctrl_rx_gtpd_7;
               end

     default : slv_rdata            = 'd0;
     endcase
     end
   
   //---------------------------------------------------------------------------
   // read/write done logic.
   // For the basic register bank these are fed directly back in as the reg
   // delay is known and fixed.
   //---------------------------------------------------------------------------
   always @(*)
     begin
     slv_rd_done = slv_rden;
     slv_wr_done = slv_wren;
     end

endmodule

