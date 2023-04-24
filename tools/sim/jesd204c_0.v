//----------------------------------------------------------------------------
// Title : JESD204C Wrapper for core
// Project : JESD204C
//----------------------------------------------------------------------------
// File : jesd204c_0.v
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

(* CORE_GENERATION_INFO = "jesd204c_0,jesd204c_v4_2_8,{x_ipProduct=Vivado 2022.1,x_ipVendor=xilinx.com,x_ipLibrary=ip,x_ipName=jesd204c,x_ipVersion=4.2,x_ipCoreRevision=8,x_ipLanguage=VHDL,x_ipSimLanguage=MIXED,C_COMPONENT_NAME=jesd204c_0,C_FAMILY=zynquplus,C_NODE_IS_TRANSMIT=1,C_ENCODING=0,C_USE_SYNC_PIN=false,C_USE_FEC=false,C_LANES=8,C_SPEEDGRADE=-2,c_sub_core_name=NO_SUBCORE,C_GT_Line_Rate=8.00,C_GT_REFCLK_FREQ=200,C_VERSAL_REFCLK_REQUESTED=200.0,C_VERSAL_REFCLK_FREQ=0,C_DRPCLK_FREQ=200.0,C_PLL_SELECTION=0,C_AXICLK_FREQ=100.0,C_Transceiver=GTHE4,C_USE_RPAT=false,C_USE_JSPAT=false,IP_IS_VERSAL=false,x_ipLicense=jesd204@2019.10(bought)}" *)
(* X_CORE_INFO = "jesd204c_v4_2_8,Vivado 2022.1" *)

(* DowngradeIPIdentifiedWarnings = "yes" *)
module jesd204c_0
(
  // Clk and Reset
  input           tx_core_reset,
  input           tx_core_clk,
  input           tx_sysref,

  // TX AXIS interface
  output          tx_aresetn,
  output          tx_tready,
  input    [255:0] tx_tdata,
  output    [3:0] tx_sof,
  output    [3:0] tx_somf,

  // TX GT interface
  // Lane 0
  output    [3:0] gt0_txcharisk,
  output    [1:0] gt0_txheader,
  output   [63:0] gt0_txdata,
  
  // Lane 1
  output    [3:0] gt1_txcharisk,
  output    [1:0] gt1_txheader,
  output   [63:0] gt1_txdata,
  
  // Lane 2
  output    [3:0] gt2_txcharisk,
  output    [1:0] gt2_txheader,
  output   [63:0] gt2_txdata,
  
  // Lane 3
  output    [3:0] gt3_txcharisk,
  output    [1:0] gt3_txheader,
  output   [63:0] gt3_txdata,
  
  // Lane 4
  output    [3:0] gt4_txcharisk,
  output    [1:0] gt4_txheader,
  output   [63:0] gt4_txdata,
  
  // Lane 5
  output    [3:0] gt5_txcharisk,
  output    [1:0] gt5_txheader,
  output   [63:0] gt5_txdata,
  
  // Lane 6
  output    [3:0] gt6_txcharisk,
  output    [1:0] gt6_txheader,
  output   [63:0] gt6_txdata,
  
  // Lane 7
  output    [3:0] gt7_txcharisk,
  output    [1:0] gt7_txheader,
  output   [63:0] gt7_txdata,
  

  // Reset done from Tx Transceiver
  input           tx_reset_done,
  // Reset output to drive Tx Transceiver Reset input
  output          tx_reset_gt,


  input           tx_sync,


  output          irq,

  // AXI-Lite Control/Status
  input           s_axi_aclk,
  input           s_axi_aresetn,
  input    [11:0] s_axi_awaddr,
  input           s_axi_awvalid,
  output          s_axi_awready,
  input    [31:0] s_axi_wdata,
  input     [3:0] s_axi_wstrb,
  input           s_axi_wvalid,
  output          s_axi_wready,
  output    [1:0] s_axi_bresp,
  output          s_axi_bvalid,
  input           s_axi_bready,
  input    [11:0] s_axi_araddr,
  input           s_axi_arvalid,
  output          s_axi_arready,
  output   [31:0] s_axi_rdata,
  output    [1:0] s_axi_rresp,
  output          s_axi_rvalid,
  input           s_axi_rready
  );

  //------------------------------------------------------------
  // Instantiate the JESD204C core
  //------------------------------------------------------------
jesd204c_0_block #(
  .C_IS_TX                (1),
  .C_LANES                (8)
)
inst(
  // Clk and Reset
  .ext_reset              (tx_core_reset),
  .core_clk               (tx_core_clk),
  .sysref                 (tx_sysref),

  // TX AXIS interface
  .tx_aresetn             (tx_aresetn),
  .tx_tready              (tx_tready),
  .tx_tdata               (tx_tdata),
  .tx_sof                 (tx_sof),
  .tx_somf                (tx_somf),



  // TX GT interface
  // Lane 0
  .gt0_txcharisk          (gt0_txcharisk),
  .gt0_txheader           (gt0_txheader),
  .gt0_txdata             (gt0_txdata),
  
  // Lane 1
  .gt1_txcharisk          (gt1_txcharisk),
  .gt1_txheader           (gt1_txheader),
  .gt1_txdata             (gt1_txdata),
  
  // Lane 2
  .gt2_txcharisk          (gt2_txcharisk),
  .gt2_txheader           (gt2_txheader),
  .gt2_txdata             (gt2_txdata),
  
  // Lane 3
  .gt3_txcharisk          (gt3_txcharisk),
  .gt3_txheader           (gt3_txheader),
  .gt3_txdata             (gt3_txdata),
  
  // Lane 4
  .gt4_txcharisk          (gt4_txcharisk),
  .gt4_txheader           (gt4_txheader),
  .gt4_txdata             (gt4_txdata),
  
  // Lane 5
  .gt5_txcharisk          (gt5_txcharisk),
  .gt5_txheader           (gt5_txheader),
  .gt5_txdata             (gt5_txdata),
  
  // Lane 6
  .gt6_txcharisk          (gt6_txcharisk),
  .gt6_txheader           (gt6_txheader),
  .gt6_txdata             (gt6_txdata),
  
  // Lane 7
  .gt7_txcharisk          (gt7_txcharisk),
  .gt7_txheader           (gt7_txheader),
  .gt7_txdata             (gt7_txdata),
  

  // Reset done for Tx Transceiver
  .gt_reset_done          (tx_reset_done),
  // Reset output to drive Tx Transceiver Reset input
  .reset_gt               (tx_reset_gt),


  .tx_sync                (tx_sync),


  .irq                    (irq),

  // AXI-Lite Control/Status
  .s_axi_aclk             (s_axi_aclk),
  .s_axi_aresetn          (s_axi_aresetn),
  .s_axi_awaddr           (s_axi_awaddr),
  .s_axi_awvalid          (s_axi_awvalid),
  .s_axi_awready          (s_axi_awready),
  .s_axi_wdata            (s_axi_wdata),
  .s_axi_wstrb            (s_axi_wstrb),
  .s_axi_wvalid           (s_axi_wvalid),
  .s_axi_wready           (s_axi_wready),
  .s_axi_bresp            (s_axi_bresp),
  .s_axi_bvalid           (s_axi_bvalid),
  .s_axi_bready           (s_axi_bready),
  .s_axi_araddr           (s_axi_araddr),
  .s_axi_arvalid          (s_axi_arvalid),
  .s_axi_arready          (s_axi_arready),
  .s_axi_rdata            (s_axi_rdata),
  .s_axi_rresp            (s_axi_rresp),
  .s_axi_rvalid           (s_axi_rvalid),
  .s_axi_rready           (s_axi_rready)
);

endmodule
