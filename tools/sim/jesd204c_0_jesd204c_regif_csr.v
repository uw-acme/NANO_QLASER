//-----------------------------------------------------------------------------
// Title      : jesd204c_regif_csr
// Project    : NA
//-----------------------------------------------------------------------------
// File       : jesd204c_regif_csr.v
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

module jesd204c_0_jesd204c_regif_csr #(
   parameter integer                   C_S_AXI_ADDR_WIDTH   = 11
   )
(
   input                                  s_axi_aclk,
   input                                  s_axi_aresetn,
   
   // 
   output reg                             timeout_enable = 1,
   output reg  [11:0]                     timeout_value = 128,
   output reg                             ctrl_reset = 0,
   input                                  stat_reset,
   output reg                             ctrl_gt_dp_reset_sel = 0,
   input                                  stat_reset_ext,
   input                                  stat_reset_ctrl,
   input                                  stat_reset_pwrgood,
   input                                  stat_reset_gtbzy,
   input       [7:0]                      stat_reset_pmarstbzy,
   input       [7:0]                      stat_reset_mstrstbzy,
   output reg                             ctrl_en_cmd = 0,
   output reg                             ctrl_en_data = 0,
   output reg                             ctrl_tx_sync_force = 0,
   output reg  [7:0]                      ctrl_mb_in_emb = 1,
   output reg  [1:0]                      ctrl_sub_class = 1,
   output reg  [1:0]                      ctrl_meta_mode = 0,
   output reg  [7:0]                      ctrl_opf = 1,
   output reg  [4:0]                      ctrl_fpmf = 15,
   output reg                             ctrl_scr = 1,
   output reg                             ctrl_ila_req = 1,
   output reg                             ctrl_rx_err_rep_ena = 0,
   output reg                             ctrl_rx_err_cnt_ena = 0,
   output reg                             ctrl_tx_ila_cs_all = 0,
   output reg  [7:0]                      ctrl_tx_ila_mf = 3,
   output reg  [7:0]                      ctrl_lane_ena = 255,
   output reg  [9:0]                      ctrl_rx_buf_adv = 0,
   output reg  [2:0]                      ctrl_test_mode = 0,
   output reg  [2:0]                      ctrl_tx_loopback = 0,
   output reg  [2:0]                      ctrl_rx_mblock_th = 0,
   output reg                             ctrl_sysr_alw = 0,
   output reg                             ctrl_sysr_req = 0,
   output reg  [2:0]                      ctrl_sysr_tol = 0,
   output reg  [7:0]                      ctrl_sysr_del = 0,
   input       [7:0]                      stat_rx_sh_lock_dbg,
   input       [7:0]                      stat_rx_emb_lock_dbg,
   input       [31:0]                     stat_rx_err,
   output reg                             stat_rx_err_pls_h = 0,
   input       [31:0]                     stat_rx_deb,
   output reg                             stat_rx_deb_pls_h = 0,
   input                                  stat_irq_pend,
   input                                  stat_sysr_cap,
   input                                  stat_sysr_err,
   output reg                             stat_sysr_err_pls_h = 0,
   input                                  stat_rx_sh_lock,
   input                                  stat_rx_emb_lock,
   input                                  stat_rx_over_err,
   input                                  stat_sync,
   input                                  stat_rx_cgs,
   input                                  stat_rx_started,
   input                                  stat_rx_align_err,
   output reg                             ctrl_en_irq = 0,
   output reg                             ctrl_en_sysr_cap_irq = 0,
   output reg                             ctrl_en_sysr_err_irq = 0,
   output reg                             ctrl_rx_en_sh_lock_irq = 0,
   output reg                             ctrl_rx_en_emb_lock_irq = 0,
   output reg                             ctrl_rx_en_block_sync_err_irq = 0,
   output reg                             ctrl_rx_en_emb_align_err_irq = 0,
   output reg                             ctrl_rx_en_crc_err_irq = 0,
   output reg                             ctrl_rx_en_fec_err_irq = 0,
   output reg                             ctrl_rx_en_over_err_irq = 0,
   output reg                             ctrl_en_sync_irq = 0,
   output reg                             ctrl_en_resync_irq = 0,
   output reg                             ctrl_en_started_irq = 0,
   input                                  stat_sysr_cap_irq,
   output reg                             stat_sysr_cap_irq_pls_h = 0,
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
   output reg  [7:0]                      ctrl_tx_ila_did = 0,
   output reg  [3:0]                      ctrl_tx_ila_bid = 0,
   output reg  [7:0]                      ctrl_tx_ila_m = 0,
   output reg  [4:0]                      ctrl_tx_ila_n = 0,
   output reg  [4:0]                      ctrl_tx_ila_np = 0,
   output reg  [1:0]                      ctrl_tx_ila_cs = 0,
   output reg  [4:0]                      ctrl_tx_ila_s = 0,
   output reg                             ctrl_tx_ila_hd = 0,
   output reg  [4:0]                      ctrl_tx_ila_cf = 0,
   output reg  [3:0]                      ctrl_tx_ila_adjcnt = 0,
   output reg                             ctrl_tx_ila_phadj = 0,
   output reg                             ctrl_tx_ila_adjdir = 0,
   output reg  [7:0]                      ctrl_tx_ila_res1 = 0,
   output reg  [7:0]                      ctrl_tx_ila_res2 = 0,

 
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
  // Internal reg/wire declarations
  //----------------------------------------------------------------------------
   wire        [7:0]                      major_version;
   wire        [7:0]                      minor_version;
   wire        [7:0]                      revision_version;
   wire        [3:0]                      num_lanes;
   wire                                   tx_not_rx;
   wire                                   enc_64b_not_8b;
   wire                                   include_fec;

  //----------------------------------------------------------------------------
  // constant wire asisgnments, ease readability instead of coding into the
  // register read statement
  //----------------------------------------------------------------------------
  assign  major_version                            = 8'd4;
  assign  minor_version                            = 8'd2;
  assign  revision_version                         = 8'd8;
  assign  num_lanes                                = 4'd8;
  assign  tx_not_rx                                = 1'd1;
  assign  enc_64b_not_8b                           = 1'd0;
  assign  include_fec                              = 1'd0;

  //----------------------------------------------------------------------------
  // Register write logic
  //----------------------------------------------------------------------------
   always @( posedge s_axi_aclk )
   begin
      if (~s_axi_aresetn) begin
        // set RW register defaults
         timeout_enable                           <= 1'd1;
         timeout_value                            <= 12'd128;
         ctrl_reset                               <= 1'd0;
         ctrl_gt_dp_reset_sel                     <= 1'd0;
         ctrl_en_cmd                              <= 1'd0;
         ctrl_en_data                             <= 1'd0;
         ctrl_tx_sync_force                       <= 1'd0;
         ctrl_mb_in_emb                           <= 8'd1;
         ctrl_sub_class                           <= 2'd1;
         ctrl_meta_mode                           <= 2'd0;
         ctrl_opf                                 <= 8'd1;
         ctrl_fpmf                                <= 5'd15;
         ctrl_scr                                 <= 1'd1;
         ctrl_ila_req                             <= 1'd1;
         ctrl_rx_err_rep_ena                      <= 1'd0;
         ctrl_rx_err_cnt_ena                      <= 1'd0;
         ctrl_tx_ila_cs_all                       <= 1'd0;
         ctrl_tx_ila_mf                           <= 8'd3;
         ctrl_lane_ena                            <= 8'd255;
         ctrl_rx_buf_adv                          <= 10'd0;
         ctrl_test_mode                           <= 3'd0;
         ctrl_tx_loopback                         <= 3'd0;
         ctrl_rx_mblock_th                        <= 3'd0;
         ctrl_sysr_alw                            <= 1'd0;
         ctrl_sysr_req                            <= 1'd0;
         ctrl_sysr_tol                            <= 3'd0;
         ctrl_sysr_del                            <= 8'd0;
         stat_rx_err_pls_h                        <= 1'd0;
         stat_rx_deb_pls_h                        <= 1'd0;
         stat_sysr_err_pls_h                      <= 1'd0;
         ctrl_en_irq                              <= 1'd0;
         ctrl_en_sysr_cap_irq                     <= 1'd0;
         ctrl_en_sysr_err_irq                     <= 1'd0;
         ctrl_rx_en_sh_lock_irq                   <= 1'd0;
         ctrl_rx_en_emb_lock_irq                  <= 1'd0;
         ctrl_rx_en_block_sync_err_irq            <= 1'd0;
         ctrl_rx_en_emb_align_err_irq             <= 1'd0;
         ctrl_rx_en_crc_err_irq                   <= 1'd0;
         ctrl_rx_en_fec_err_irq                   <= 1'd0;
         ctrl_rx_en_over_err_irq                  <= 1'd0;
         ctrl_en_sync_irq                         <= 1'd0;
         ctrl_en_resync_irq                       <= 1'd0;
         ctrl_en_started_irq                      <= 1'd0;
         stat_sysr_cap_irq_pls_h                  <= 1'd0;
         ctrl_tx_ila_did                          <= 8'd0;
         ctrl_tx_ila_bid                          <= 4'd0;
         ctrl_tx_ila_m                            <= 8'd0;
         ctrl_tx_ila_n                            <= 5'd0;
         ctrl_tx_ila_np                           <= 5'd0;
         ctrl_tx_ila_cs                           <= 2'd0;
         ctrl_tx_ila_s                            <= 5'd0;
         ctrl_tx_ila_hd                           <= 1'd0;
         ctrl_tx_ila_cf                           <= 5'd0;
         ctrl_tx_ila_adjcnt                       <= 4'd0;
         ctrl_tx_ila_phadj                        <= 1'd0;
         ctrl_tx_ila_adjdir                       <= 1'd0;
         ctrl_tx_ila_res1                         <= 8'd0;
         ctrl_tx_ila_res2                         <= 8'd0;

      end 
      else begin    

         // Always assign the pulse signals here. These can be overidden in the
         // main write function. This is a valid verilog coding style 
         stat_rx_err_pls_h                        <= slv_rd_done & (slv_addr == 22);
         stat_rx_deb_pls_h                        <= slv_rd_done & (slv_addr == 23);
         stat_sysr_err_pls_h                      <= slv_rd_done & (slv_addr == 24);
         stat_sysr_cap_irq_pls_h                  <= slv_rd_done & (slv_addr == 26);

         // on a write we write to the appropiate register 
         if (slv_wren) begin
            case (slv_addr)
            'h5     : begin // @ address = 'd20 'h14
                      timeout_enable                           <= slv_wdata[0];
                      end
            'h7     : begin // @ address = 'd28 'h1c
                      timeout_value                            <= slv_wdata[11:0];
                      end
            'h8     : begin // @ address = 'd32 'h20
                      ctrl_reset                               <= slv_wdata[0];
                      ctrl_gt_dp_reset_sel                     <= slv_wdata[1];
                      end
            'h9     : begin // @ address = 'd36 'h24
                      ctrl_en_cmd                              <= slv_wdata[0];
                      ctrl_en_data                             <= slv_wdata[1];
                      end
            'ha     : begin // @ address = 'd40 'h28
                      ctrl_tx_sync_force                       <= slv_wdata[0];
                      end
            'hc     : begin // @ address = 'd48 'h30
                      ctrl_mb_in_emb                           <= slv_wdata[7:0];
                      end
            'hd     : begin // @ address = 'd52 'h34
                      ctrl_sub_class                           <= slv_wdata[1:0];
                      end
            'he     : begin // @ address = 'd56 'h38
                      ctrl_meta_mode                           <= slv_wdata[1:0];
                      end
            'hf     : begin // @ address = 'd60 'h3c
                      ctrl_opf                                 <= slv_wdata[7:0];
                      ctrl_fpmf                                <= slv_wdata[12:8];
                      ctrl_scr                                 <= slv_wdata[16];
                      ctrl_ila_req                             <= slv_wdata[17];
                      ctrl_rx_err_rep_ena                      <= slv_wdata[18];
                      ctrl_rx_err_cnt_ena                      <= slv_wdata[19];
                      ctrl_tx_ila_cs_all                       <= slv_wdata[20];
                      ctrl_tx_ila_mf                           <= slv_wdata[31:24];
                      end
            'h10    : begin // @ address = 'd64 'h40
                      ctrl_lane_ena                            <= slv_wdata[7:0];
                      end
            'h11    : begin // @ address = 'd68 'h44
                      ctrl_rx_buf_adv                          <= slv_wdata[9:0];
                      end
            'h12    : begin // @ address = 'd72 'h48
                      ctrl_test_mode                           <= slv_wdata[2:0];
                      ctrl_tx_loopback                         <= slv_wdata[30:28];
                      end
            'h13    : begin // @ address = 'd76 'h4c
                      ctrl_rx_mblock_th                        <= slv_wdata[2:0];
                      end
            'h14    : begin // @ address = 'd80 'h50
                      ctrl_sysr_alw                            <= slv_wdata[0];
                      ctrl_sysr_req                            <= slv_wdata[1];
                      ctrl_sysr_tol                            <= slv_wdata[10:8];
                      ctrl_sysr_del                            <= slv_wdata[23:16];
                      end
            'h19    : begin // @ address = 'd100 'h64
                      ctrl_en_irq                              <= slv_wdata[0];
                      ctrl_en_sysr_cap_irq                     <= slv_wdata[1];
                      ctrl_en_sysr_err_irq                     <= slv_wdata[2];
                      ctrl_rx_en_sh_lock_irq                   <= slv_wdata[4];
                      ctrl_rx_en_emb_lock_irq                  <= slv_wdata[5];
                      ctrl_rx_en_block_sync_err_irq            <= slv_wdata[6];
                      ctrl_rx_en_emb_align_err_irq             <= slv_wdata[7];
                      ctrl_rx_en_crc_err_irq                   <= slv_wdata[8];
                      ctrl_rx_en_fec_err_irq                   <= slv_wdata[9];
                      ctrl_rx_en_over_err_irq                  <= slv_wdata[10];
                      ctrl_en_sync_irq                         <= slv_wdata[12];
                      ctrl_en_resync_irq                       <= slv_wdata[13];
                      ctrl_en_started_irq                      <= slv_wdata[14];
                      end
            'h1c    : begin // @ address = 'd112 'h70
                      ctrl_tx_ila_did                          <= slv_wdata[7:0];
                      ctrl_tx_ila_bid                          <= slv_wdata[11:8];
                      end
            'h1d    : begin // @ address = 'd116 'h74
                      ctrl_tx_ila_m                            <= slv_wdata[7:0];
                      ctrl_tx_ila_n                            <= slv_wdata[12:8];
                      ctrl_tx_ila_np                           <= slv_wdata[20:16];
                      ctrl_tx_ila_cs                           <= slv_wdata[25:24];
                      end
            'h1e    : begin // @ address = 'd120 'h78
                      ctrl_tx_ila_s                            <= slv_wdata[12:8];
                      ctrl_tx_ila_hd                           <= slv_wdata[16];
                      ctrl_tx_ila_cf                           <= slv_wdata[28:24];
                      end
            'h1f    : begin // @ address = 'd124 'h7c
                      ctrl_tx_ila_adjcnt                       <= slv_wdata[3:0];
                      ctrl_tx_ila_phadj                        <= slv_wdata[8];
                      ctrl_tx_ila_adjdir                       <= slv_wdata[16];
                      end
            'h20    : begin // @ address = 'd128 'h80
                      ctrl_tx_ila_res1                         <= slv_wdata[7:0];
                      ctrl_tx_ila_res2                         <= slv_wdata[15:8];
                      end

            endcase
         end
      end
   end
   
   //---------------------------------------------------------------------------
   // Register read logic, non registered, 
   //---------------------------------------------------------------------------
   always @(*)
     begin
     slv_rdata = 'd0; // Zero all data
     case (slv_addr)
     'h0     : begin // @ address = 'd0 'h0
               slv_rdata[31:24]     = major_version;
               slv_rdata[23:16]     = minor_version;
               slv_rdata[15:8]      = revision_version;
               end
     'h1     : begin // @ address = 'd4 'h4
               slv_rdata[3:0]       = num_lanes;
               slv_rdata[16]        = tx_not_rx;
               slv_rdata[17]        = enc_64b_not_8b;
               slv_rdata[18]        = include_fec;
               end
     'h5     : begin // @ address = 'd20 'h14
               slv_rdata[0]         = timeout_enable;
               end
     'h7     : begin // @ address = 'd28 'h1c
               slv_rdata[11:0]      = timeout_value;
               end
     'h8     : begin // @ address = 'd32 'h20
               slv_rdata[0]         = stat_reset;
               slv_rdata[1]         = ctrl_gt_dp_reset_sel;
               slv_rdata[4]         = stat_reset_ext;
               slv_rdata[5]         = stat_reset_ctrl;
               slv_rdata[6]         = stat_reset_pwrgood;
               slv_rdata[7]         = stat_reset_gtbzy;
               slv_rdata[23:16]     = stat_reset_pmarstbzy;
               slv_rdata[31:24]     = stat_reset_mstrstbzy;
               end
     'h9     : begin // @ address = 'd36 'h24
               slv_rdata[0]         = ctrl_en_cmd;
               slv_rdata[1]         = ctrl_en_data;
               end
     'ha     : begin // @ address = 'd40 'h28
               slv_rdata[0]         = ctrl_tx_sync_force;
               end
     'hc     : begin // @ address = 'd48 'h30
               slv_rdata[7:0]       = ctrl_mb_in_emb;
               end
     'hd     : begin // @ address = 'd52 'h34
               slv_rdata[1:0]       = ctrl_sub_class;
               end
     'he     : begin // @ address = 'd56 'h38
               slv_rdata[1:0]       = ctrl_meta_mode;
               end
     'hf     : begin // @ address = 'd60 'h3c
               slv_rdata[7:0]       = ctrl_opf;
               slv_rdata[12:8]      = ctrl_fpmf;
               slv_rdata[16]        = ctrl_scr;
               slv_rdata[17]        = ctrl_ila_req;
               slv_rdata[18]        = ctrl_rx_err_rep_ena;
               slv_rdata[19]        = ctrl_rx_err_cnt_ena;
               slv_rdata[20]        = ctrl_tx_ila_cs_all;
               slv_rdata[31:24]     = ctrl_tx_ila_mf;
               end
     'h10    : begin // @ address = 'd64 'h40
               slv_rdata[7:0]       = ctrl_lane_ena;
               end
     'h11    : begin // @ address = 'd68 'h44
               slv_rdata[9:0]       = ctrl_rx_buf_adv;
               end
     'h12    : begin // @ address = 'd72 'h48
               slv_rdata[2:0]       = ctrl_test_mode;
               slv_rdata[30:28]     = ctrl_tx_loopback;
               end
     'h13    : begin // @ address = 'd76 'h4c
               slv_rdata[2:0]       = ctrl_rx_mblock_th;
               end
     'h14    : begin // @ address = 'd80 'h50
               slv_rdata[0]         = ctrl_sysr_alw;
               slv_rdata[1]         = ctrl_sysr_req;
               slv_rdata[10:8]      = ctrl_sysr_tol;
               slv_rdata[23:16]     = ctrl_sysr_del;
               end
     'h15    : begin // @ address = 'd84 'h54
               slv_rdata[7:0]       = stat_rx_sh_lock_dbg;
               slv_rdata[23:16]     = stat_rx_emb_lock_dbg;
               end
     'h16    : begin // @ address = 'd88 'h58
               slv_rdata[31:0]      = stat_rx_err;
               end
     'h17    : begin // @ address = 'd92 'h5c
               slv_rdata[31:0]      = stat_rx_deb;
               end
     'h18    : begin // @ address = 'd96 'h60
               slv_rdata[0]         = stat_irq_pend;
               slv_rdata[1]         = stat_sysr_cap;
               slv_rdata[2]         = stat_sysr_err;
               slv_rdata[4]         = stat_rx_sh_lock;
               slv_rdata[5]         = stat_rx_emb_lock;
               slv_rdata[10]        = stat_rx_over_err;
               slv_rdata[12]        = stat_sync;
               slv_rdata[13]        = stat_rx_cgs;
               slv_rdata[14]        = stat_rx_started;
               slv_rdata[15]        = stat_rx_align_err;
               end
     'h19    : begin // @ address = 'd100 'h64
               slv_rdata[0]         = ctrl_en_irq;
               slv_rdata[1]         = ctrl_en_sysr_cap_irq;
               slv_rdata[2]         = ctrl_en_sysr_err_irq;
               slv_rdata[4]         = ctrl_rx_en_sh_lock_irq;
               slv_rdata[5]         = ctrl_rx_en_emb_lock_irq;
               slv_rdata[6]         = ctrl_rx_en_block_sync_err_irq;
               slv_rdata[7]         = ctrl_rx_en_emb_align_err_irq;
               slv_rdata[8]         = ctrl_rx_en_crc_err_irq;
               slv_rdata[9]         = ctrl_rx_en_fec_err_irq;
               slv_rdata[10]        = ctrl_rx_en_over_err_irq;
               slv_rdata[12]        = ctrl_en_sync_irq;
               slv_rdata[13]        = ctrl_en_resync_irq;
               slv_rdata[14]        = ctrl_en_started_irq;
               end
     'h1a    : begin // @ address = 'd104 'h68
               slv_rdata[1]         = stat_sysr_cap_irq;
               slv_rdata[2]         = stat_sysr_err_irq;
               slv_rdata[4]         = stat_rx_sh_lock_irq;
               slv_rdata[5]         = stat_rx_emb_lock_irq;
               slv_rdata[6]         = stat_rx_block_sync_err_irq;
               slv_rdata[7]         = stat_rx_emb_align_err_irq;
               slv_rdata[8]         = stat_rx_crc_err_irq;
               slv_rdata[9]         = stat_rx_fec_err_irq;
               slv_rdata[10]        = stat_rx_over_err_irq;
               slv_rdata[12]        = stat_sync_irq;
               slv_rdata[13]        = stat_resync_irq;
               slv_rdata[14]        = stat_started_irq;
               end
     'h1c    : begin // @ address = 'd112 'h70
               slv_rdata[7:0]       = ctrl_tx_ila_did;
               slv_rdata[11:8]      = ctrl_tx_ila_bid;
               end
     'h1d    : begin // @ address = 'd116 'h74
               slv_rdata[7:0]       = ctrl_tx_ila_m;
               slv_rdata[12:8]      = ctrl_tx_ila_n;
               slv_rdata[20:16]     = ctrl_tx_ila_np;
               slv_rdata[25:24]     = ctrl_tx_ila_cs;
               end
     'h1e    : begin // @ address = 'd120 'h78
               slv_rdata[12:8]      = ctrl_tx_ila_s;
               slv_rdata[16]        = ctrl_tx_ila_hd;
               slv_rdata[28:24]     = ctrl_tx_ila_cf;
               end
     'h1f    : begin // @ address = 'd124 'h7c
               slv_rdata[3:0]       = ctrl_tx_ila_adjcnt;
               slv_rdata[8]         = ctrl_tx_ila_phadj;
               slv_rdata[16]        = ctrl_tx_ila_adjdir;
               end
     'h20    : begin // @ address = 'd128 'h80
               slv_rdata[7:0]       = ctrl_tx_ila_res1;
               slv_rdata[15:8]      = ctrl_tx_ila_res2;
               end

     default   : slv_rdata = 'd0;
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
