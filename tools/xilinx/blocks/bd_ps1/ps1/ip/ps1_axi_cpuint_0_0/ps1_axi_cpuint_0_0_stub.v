// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1.2 (win64) Build 3605665 Fri Aug  5 22:53:37 MDT 2022
// Date        : Fri Nov  8 17:08:01 2024
// Host        : STATIONX2 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               e:/home/Eric/acme/NANO_QLASER/tools/xilinx/blocks/bd_ps1/ps1/ip/ps1_axi_cpuint_0_0/ps1_axi_cpuint_0_0_stub.v
// Design      : ps1_axi_cpuint_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "axi_cpuint_v1_0,Vivado 2022.1.2" *)
module ps1_axi_cpuint_0_0(clk_cpu, cpu_wr, cpu_rd, cpu_addr, cpu_wdata, 
  cpu_rdata, cpu_rdata_dv, s00_axi_aclk, s00_axi_aresetn, s00_axi_awaddr, s00_axi_awprot, 
  s00_axi_awvalid, s00_axi_awready, s00_axi_wdata, s00_axi_wstrb, s00_axi_wvalid, 
  s00_axi_wready, s00_axi_bresp, s00_axi_bvalid, s00_axi_bready, s00_axi_araddr, 
  s00_axi_arprot, s00_axi_arvalid, s00_axi_arready, s00_axi_rdata, s00_axi_rresp, 
  s00_axi_rvalid, s00_axi_rready)
/* synthesis syn_black_box black_box_pad_pin="clk_cpu,cpu_wr,cpu_rd,cpu_addr[17:0],cpu_wdata[31:0],cpu_rdata[31:0],cpu_rdata_dv,s00_axi_aclk,s00_axi_aresetn,s00_axi_awaddr[17:0],s00_axi_awprot[2:0],s00_axi_awvalid,s00_axi_awready,s00_axi_wdata[31:0],s00_axi_wstrb[3:0],s00_axi_wvalid,s00_axi_wready,s00_axi_bresp[1:0],s00_axi_bvalid,s00_axi_bready,s00_axi_araddr[17:0],s00_axi_arprot[2:0],s00_axi_arvalid,s00_axi_arready,s00_axi_rdata[31:0],s00_axi_rresp[1:0],s00_axi_rvalid,s00_axi_rready" */;
  output clk_cpu;
  output cpu_wr;
  output cpu_rd;
  output [17:0]cpu_addr;
  output [31:0]cpu_wdata;
  input [31:0]cpu_rdata;
  input cpu_rdata_dv;
  input s00_axi_aclk;
  input s00_axi_aresetn;
  input [17:0]s00_axi_awaddr;
  input [2:0]s00_axi_awprot;
  input s00_axi_awvalid;
  output s00_axi_awready;
  input [31:0]s00_axi_wdata;
  input [3:0]s00_axi_wstrb;
  input s00_axi_wvalid;
  output s00_axi_wready;
  output [1:0]s00_axi_bresp;
  output s00_axi_bvalid;
  input s00_axi_bready;
  input [17:0]s00_axi_araddr;
  input [2:0]s00_axi_arprot;
  input s00_axi_arvalid;
  output s00_axi_arready;
  output [31:0]s00_axi_rdata;
  output [1:0]s00_axi_rresp;
  output s00_axi_rvalid;
  input s00_axi_rready;
endmodule
