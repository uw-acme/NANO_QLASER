// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1.2 (win64) Build 3605665 Fri Aug  5 22:53:37 MDT 2022
// Date        : Fri Nov  8 17:08:01 2024
// Host        : STATIONX2 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               e:/home/Eric/acme/NANO_QLASER/tools/xilinx/blocks/bd_ps1/ps1/ip/ps1_axi_cpuint_0_0/ps1_axi_cpuint_0_0_sim_netlist.v
// Design      : ps1_axi_cpuint_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu9eg-ffvb1156-2-e
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "ps1_axi_cpuint_0_0,axi_cpuint_v1_0,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "axi_cpuint_v1_0,Vivado 2022.1.2" *) 
(* NotValidForBitStream *)
module ps1_axi_cpuint_0_0
   (clk_cpu,
    cpu_wr,
    cpu_rd,
    cpu_addr,
    cpu_wdata,
    cpu_rdata,
    cpu_rdata_dv,
    s00_axi_aclk,
    s00_axi_aresetn,
    s00_axi_awaddr,
    s00_axi_awprot,
    s00_axi_awvalid,
    s00_axi_awready,
    s00_axi_wdata,
    s00_axi_wstrb,
    s00_axi_wvalid,
    s00_axi_wready,
    s00_axi_bresp,
    s00_axi_bvalid,
    s00_axi_bready,
    s00_axi_araddr,
    s00_axi_arprot,
    s00_axi_arvalid,
    s00_axi_arready,
    s00_axi_rdata,
    s00_axi_rresp,
    s00_axi_rvalid,
    s00_axi_rready);
  output clk_cpu;
  output cpu_wr;
  output cpu_rd;
  output [17:0]cpu_addr;
  output [31:0]cpu_wdata;
  input [31:0]cpu_rdata;
  input cpu_rdata_dv;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 S00_AXI_CLK CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME S00_AXI_CLK, ASSOCIATED_BUSIF S00_AXI, ASSOCIATED_RESET s00_axi_aresetn, FREQ_HZ 96968727, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN ps1_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0" *) input s00_axi_aclk;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 S00_AXI_RST RST" *) (* x_interface_parameter = "XIL_INTERFACENAME S00_AXI_RST, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input s00_axi_aresetn;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S00_AXI AWADDR" *) (* x_interface_parameter = "XIL_INTERFACENAME S00_AXI, WIZ_DATA_WIDTH 32, WIZ_NUM_REG 4, SUPPORTS_NARROW_BURST 0, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 96968727, ID_WIDTH 0, ADDR_WIDTH 18, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 1, PHASE 0.0, CLK_DOMAIN ps1_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) input [17:0]s00_axi_awaddr;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S00_AXI AWPROT" *) input [2:0]s00_axi_awprot;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S00_AXI AWVALID" *) input s00_axi_awvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S00_AXI AWREADY" *) output s00_axi_awready;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S00_AXI WDATA" *) input [31:0]s00_axi_wdata;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S00_AXI WSTRB" *) input [3:0]s00_axi_wstrb;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S00_AXI WVALID" *) input s00_axi_wvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S00_AXI WREADY" *) output s00_axi_wready;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S00_AXI BRESP" *) output [1:0]s00_axi_bresp;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S00_AXI BVALID" *) output s00_axi_bvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S00_AXI BREADY" *) input s00_axi_bready;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S00_AXI ARADDR" *) input [17:0]s00_axi_araddr;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S00_AXI ARPROT" *) input [2:0]s00_axi_arprot;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S00_AXI ARVALID" *) input s00_axi_arvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S00_AXI ARREADY" *) output s00_axi_arready;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S00_AXI RDATA" *) output [31:0]s00_axi_rdata;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S00_AXI RRESP" *) output [1:0]s00_axi_rresp;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S00_AXI RVALID" *) output s00_axi_rvalid;
  (* x_interface_info = "xilinx.com:interface:aximm:1.0 S00_AXI RREADY" *) input s00_axi_rready;

  wire \<const0> ;
  wire [17:0]cpu_addr;
  wire cpu_rd;
  wire [31:0]cpu_rdata;
  wire cpu_rdata_dv;
  wire [31:0]cpu_wdata;
  wire cpu_wr;
  wire s00_axi_aclk;
  wire [17:0]s00_axi_araddr;
  wire s00_axi_aresetn;
  wire s00_axi_arready;
  wire s00_axi_arvalid;
  wire [17:0]s00_axi_awaddr;
  wire s00_axi_awready;
  wire s00_axi_awvalid;
  wire s00_axi_bready;
  wire s00_axi_bvalid;
  wire [31:0]s00_axi_rdata;
  wire s00_axi_rready;
  wire s00_axi_rvalid;
  wire [31:0]s00_axi_wdata;
  wire s00_axi_wready;
  wire s00_axi_wvalid;

  assign clk_cpu = s00_axi_aclk;
  assign s00_axi_bresp[1] = \<const0> ;
  assign s00_axi_bresp[0] = \<const0> ;
  assign s00_axi_rresp[1] = \<const0> ;
  assign s00_axi_rresp[0] = \<const0> ;
  GND GND
       (.G(\<const0> ));
  ps1_axi_cpuint_0_0_axi_cpuint_v1_0 U0
       (.S_AXI_ARREADY(s00_axi_arready),
        .S_AXI_AWREADY(s00_axi_awready),
        .S_AXI_WREADY(s00_axi_wready),
        .cpu_addr(cpu_addr),
        .cpu_rd(cpu_rd),
        .cpu_rdata(cpu_rdata),
        .cpu_rdata_dv(cpu_rdata_dv),
        .cpu_wdata(cpu_wdata),
        .cpu_wr(cpu_wr),
        .s00_axi_aclk(s00_axi_aclk),
        .s00_axi_araddr(s00_axi_araddr),
        .s00_axi_aresetn(s00_axi_aresetn),
        .s00_axi_arvalid(s00_axi_arvalid),
        .s00_axi_awaddr(s00_axi_awaddr),
        .s00_axi_awvalid(s00_axi_awvalid),
        .s00_axi_bready(s00_axi_bready),
        .s00_axi_bvalid(s00_axi_bvalid),
        .s00_axi_rdata(s00_axi_rdata),
        .s00_axi_rready(s00_axi_rready),
        .s00_axi_rvalid(s00_axi_rvalid),
        .s00_axi_wdata(s00_axi_wdata),
        .s00_axi_wvalid(s00_axi_wvalid));
endmodule

(* ORIG_REF_NAME = "axi_cpuint_v1_0" *) 
module ps1_axi_cpuint_0_0_axi_cpuint_v1_0
   (S_AXI_WREADY,
    S_AXI_AWREADY,
    S_AXI_ARREADY,
    cpu_addr,
    cpu_wr,
    cpu_wdata,
    s00_axi_rdata,
    cpu_rd,
    s00_axi_bvalid,
    s00_axi_rvalid,
    s00_axi_awvalid,
    s00_axi_wvalid,
    s00_axi_wdata,
    s00_axi_aresetn,
    s00_axi_arvalid,
    s00_axi_araddr,
    s00_axi_aclk,
    s00_axi_awaddr,
    cpu_rdata_dv,
    cpu_rdata,
    s00_axi_bready,
    s00_axi_rready);
  output S_AXI_WREADY;
  output S_AXI_AWREADY;
  output S_AXI_ARREADY;
  output [17:0]cpu_addr;
  output cpu_wr;
  output [31:0]cpu_wdata;
  output [31:0]s00_axi_rdata;
  output cpu_rd;
  output s00_axi_bvalid;
  output s00_axi_rvalid;
  input s00_axi_awvalid;
  input s00_axi_wvalid;
  input [31:0]s00_axi_wdata;
  input s00_axi_aresetn;
  input s00_axi_arvalid;
  input [17:0]s00_axi_araddr;
  input s00_axi_aclk;
  input [17:0]s00_axi_awaddr;
  input cpu_rdata_dv;
  input [31:0]cpu_rdata;
  input s00_axi_bready;
  input s00_axi_rready;

  wire S_AXI_ARREADY;
  wire S_AXI_AWREADY;
  wire S_AXI_WREADY;
  wire [17:0]cpu_addr;
  wire cpu_rd;
  wire [31:0]cpu_rdata;
  wire cpu_rdata_dv;
  wire [31:0]cpu_wdata;
  wire cpu_wr;
  wire s00_axi_aclk;
  wire [17:0]s00_axi_araddr;
  wire s00_axi_aresetn;
  wire s00_axi_arvalid;
  wire [17:0]s00_axi_awaddr;
  wire s00_axi_awvalid;
  wire s00_axi_bready;
  wire s00_axi_bvalid;
  wire [31:0]s00_axi_rdata;
  wire s00_axi_rready;
  wire s00_axi_rvalid;
  wire [31:0]s00_axi_wdata;
  wire s00_axi_wvalid;

  ps1_axi_cpuint_0_0_axi_cpuint_v1_0_S00_AXI axi_cpuint_v1_0_S00_AXI_inst
       (.S_AXI_ARREADY(S_AXI_ARREADY),
        .S_AXI_AWREADY(S_AXI_AWREADY),
        .S_AXI_WREADY(S_AXI_WREADY),
        .cpu_addr(cpu_addr),
        .cpu_rd(cpu_rd),
        .cpu_rdata(cpu_rdata),
        .cpu_rdata_dv(cpu_rdata_dv),
        .cpu_wdata(cpu_wdata),
        .cpu_wr(cpu_wr),
        .s00_axi_aclk(s00_axi_aclk),
        .s00_axi_araddr(s00_axi_araddr),
        .s00_axi_aresetn(s00_axi_aresetn),
        .s00_axi_arvalid(s00_axi_arvalid),
        .s00_axi_awaddr(s00_axi_awaddr),
        .s00_axi_awvalid(s00_axi_awvalid),
        .s00_axi_bready(s00_axi_bready),
        .s00_axi_bvalid(s00_axi_bvalid),
        .s00_axi_rdata(s00_axi_rdata),
        .s00_axi_rready(s00_axi_rready),
        .s00_axi_rvalid(s00_axi_rvalid),
        .s00_axi_wdata(s00_axi_wdata),
        .s00_axi_wvalid(s00_axi_wvalid));
endmodule

(* ORIG_REF_NAME = "axi_cpuint_v1_0_S00_AXI" *) 
module ps1_axi_cpuint_0_0_axi_cpuint_v1_0_S00_AXI
   (S_AXI_WREADY,
    S_AXI_AWREADY,
    S_AXI_ARREADY,
    cpu_addr,
    cpu_wr,
    cpu_wdata,
    s00_axi_rdata,
    cpu_rd,
    s00_axi_bvalid,
    s00_axi_rvalid,
    s00_axi_awvalid,
    s00_axi_wvalid,
    s00_axi_wdata,
    s00_axi_aresetn,
    s00_axi_arvalid,
    s00_axi_araddr,
    s00_axi_aclk,
    s00_axi_awaddr,
    cpu_rdata_dv,
    cpu_rdata,
    s00_axi_bready,
    s00_axi_rready);
  output S_AXI_WREADY;
  output S_AXI_AWREADY;
  output S_AXI_ARREADY;
  output [17:0]cpu_addr;
  output cpu_wr;
  output [31:0]cpu_wdata;
  output [31:0]s00_axi_rdata;
  output cpu_rd;
  output s00_axi_bvalid;
  output s00_axi_rvalid;
  input s00_axi_awvalid;
  input s00_axi_wvalid;
  input [31:0]s00_axi_wdata;
  input s00_axi_aresetn;
  input s00_axi_arvalid;
  input [17:0]s00_axi_araddr;
  input s00_axi_aclk;
  input [17:0]s00_axi_awaddr;
  input cpu_rdata_dv;
  input [31:0]cpu_rdata;
  input s00_axi_bready;
  input s00_axi_rready;

  wire S_AXI_ARREADY;
  wire S_AXI_AWREADY;
  wire S_AXI_WREADY;
  wire axi_arready0;
  wire [17:0]axi_awaddr;
  wire axi_awready0;
  wire axi_bvalid_i_1_n_0;
  wire axi_rvalid_i_1_n_0;
  wire axi_wready0;
  wire [17:0]cpu_addr;
  wire [17:0]cpu_raddr;
  wire \cpu_raddr[0]_i_1_n_0 ;
  wire \cpu_raddr[10]_i_1_n_0 ;
  wire \cpu_raddr[11]_i_1_n_0 ;
  wire \cpu_raddr[12]_i_1_n_0 ;
  wire \cpu_raddr[13]_i_1_n_0 ;
  wire \cpu_raddr[14]_i_1_n_0 ;
  wire \cpu_raddr[15]_i_1_n_0 ;
  wire \cpu_raddr[16]_i_1_n_0 ;
  wire \cpu_raddr[17]_i_1_n_0 ;
  wire \cpu_raddr[1]_i_1_n_0 ;
  wire \cpu_raddr[2]_i_1_n_0 ;
  wire \cpu_raddr[3]_i_1_n_0 ;
  wire \cpu_raddr[4]_i_1_n_0 ;
  wire \cpu_raddr[5]_i_1_n_0 ;
  wire \cpu_raddr[6]_i_1_n_0 ;
  wire \cpu_raddr[7]_i_1_n_0 ;
  wire \cpu_raddr[8]_i_1_n_0 ;
  wire \cpu_raddr[9]_i_1_n_0 ;
  wire cpu_rd;
  wire cpu_rd_i_i_1_n_0;
  wire [31:0]cpu_rdata;
  wire cpu_rdata_dv;
  wire [17:0]cpu_waddr;
  wire \cpu_waddr[17]_i_1_n_0 ;
  wire [31:0]cpu_wdata;
  wire \cpu_wdata[0]_i_1_n_0 ;
  wire \cpu_wdata[10]_i_1_n_0 ;
  wire \cpu_wdata[11]_i_1_n_0 ;
  wire \cpu_wdata[12]_i_1_n_0 ;
  wire \cpu_wdata[13]_i_1_n_0 ;
  wire \cpu_wdata[14]_i_1_n_0 ;
  wire \cpu_wdata[15]_i_1_n_0 ;
  wire \cpu_wdata[16]_i_1_n_0 ;
  wire \cpu_wdata[17]_i_1_n_0 ;
  wire \cpu_wdata[18]_i_1_n_0 ;
  wire \cpu_wdata[19]_i_1_n_0 ;
  wire \cpu_wdata[1]_i_1_n_0 ;
  wire \cpu_wdata[20]_i_1_n_0 ;
  wire \cpu_wdata[21]_i_1_n_0 ;
  wire \cpu_wdata[22]_i_1_n_0 ;
  wire \cpu_wdata[23]_i_1_n_0 ;
  wire \cpu_wdata[24]_i_1_n_0 ;
  wire \cpu_wdata[25]_i_1_n_0 ;
  wire \cpu_wdata[26]_i_1_n_0 ;
  wire \cpu_wdata[27]_i_1_n_0 ;
  wire \cpu_wdata[28]_i_1_n_0 ;
  wire \cpu_wdata[29]_i_1_n_0 ;
  wire \cpu_wdata[2]_i_1_n_0 ;
  wire \cpu_wdata[30]_i_1_n_0 ;
  wire \cpu_wdata[31]_i_1_n_0 ;
  wire \cpu_wdata[3]_i_1_n_0 ;
  wire \cpu_wdata[4]_i_1_n_0 ;
  wire \cpu_wdata[5]_i_1_n_0 ;
  wire \cpu_wdata[6]_i_1_n_0 ;
  wire \cpu_wdata[7]_i_1_n_0 ;
  wire \cpu_wdata[8]_i_1_n_0 ;
  wire \cpu_wdata[9]_i_1_n_0 ;
  wire cpu_wr;
  wire p_0_in;
  wire s00_axi_aclk;
  wire [17:0]s00_axi_araddr;
  wire s00_axi_aresetn;
  wire s00_axi_arvalid;
  wire [17:0]s00_axi_awaddr;
  wire s00_axi_awvalid;
  wire s00_axi_bready;
  wire s00_axi_bvalid;
  wire [31:0]s00_axi_rdata;
  wire s00_axi_rready;
  wire s00_axi_rvalid;
  wire [31:0]s00_axi_wdata;
  wire s00_axi_wvalid;
  wire slv_reg_wren;

  FDRE axi_arready_reg
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(axi_arready0),
        .Q(S_AXI_ARREADY),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[0] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[0]),
        .Q(axi_awaddr[0]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[10] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[10]),
        .Q(axi_awaddr[10]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[11] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[11]),
        .Q(axi_awaddr[11]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[12] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[12]),
        .Q(axi_awaddr[12]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[13] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[13]),
        .Q(axi_awaddr[13]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[14] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[14]),
        .Q(axi_awaddr[14]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[15] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[15]),
        .Q(axi_awaddr[15]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[16] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[16]),
        .Q(axi_awaddr[16]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[17] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[17]),
        .Q(axi_awaddr[17]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[1] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[1]),
        .Q(axi_awaddr[1]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[2] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[2]),
        .Q(axi_awaddr[2]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[3] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[3]),
        .Q(axi_awaddr[3]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[4] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[4]),
        .Q(axi_awaddr[4]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[5] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[5]),
        .Q(axi_awaddr[5]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[6] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[6]),
        .Q(axi_awaddr[6]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[7] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[7]),
        .Q(axi_awaddr[7]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[8] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[8]),
        .Q(axi_awaddr[8]),
        .R(p_0_in));
  FDRE \axi_awaddr_reg[9] 
       (.C(s00_axi_aclk),
        .CE(axi_awready0),
        .D(s00_axi_awaddr[9]),
        .Q(axi_awaddr[9]),
        .R(p_0_in));
  LUT3 #(
    .INIT(8'h08)) 
    axi_awready_i_1
       (.I0(s00_axi_wvalid),
        .I1(s00_axi_awvalid),
        .I2(S_AXI_AWREADY),
        .O(axi_awready0));
  FDRE axi_awready_reg
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(axi_awready0),
        .Q(S_AXI_AWREADY),
        .R(p_0_in));
  LUT6 #(
    .INIT(64'h0000FFFF80008000)) 
    axi_bvalid_i_1
       (.I0(s00_axi_wvalid),
        .I1(s00_axi_awvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_bready),
        .I5(s00_axi_bvalid),
        .O(axi_bvalid_i_1_n_0));
  FDRE axi_bvalid_reg
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(axi_bvalid_i_1_n_0),
        .Q(s00_axi_bvalid),
        .R(p_0_in));
  FDRE \axi_rdata_reg[0] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[0]),
        .Q(s00_axi_rdata[0]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[10] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[10]),
        .Q(s00_axi_rdata[10]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[11] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[11]),
        .Q(s00_axi_rdata[11]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[12] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[12]),
        .Q(s00_axi_rdata[12]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[13] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[13]),
        .Q(s00_axi_rdata[13]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[14] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[14]),
        .Q(s00_axi_rdata[14]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[15] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[15]),
        .Q(s00_axi_rdata[15]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[16] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[16]),
        .Q(s00_axi_rdata[16]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[17] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[17]),
        .Q(s00_axi_rdata[17]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[18] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[18]),
        .Q(s00_axi_rdata[18]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[19] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[19]),
        .Q(s00_axi_rdata[19]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[1] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[1]),
        .Q(s00_axi_rdata[1]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[20] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[20]),
        .Q(s00_axi_rdata[20]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[21] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[21]),
        .Q(s00_axi_rdata[21]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[22] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[22]),
        .Q(s00_axi_rdata[22]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[23] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[23]),
        .Q(s00_axi_rdata[23]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[24] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[24]),
        .Q(s00_axi_rdata[24]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[25] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[25]),
        .Q(s00_axi_rdata[25]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[26] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[26]),
        .Q(s00_axi_rdata[26]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[27] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[27]),
        .Q(s00_axi_rdata[27]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[28] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[28]),
        .Q(s00_axi_rdata[28]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[29] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[29]),
        .Q(s00_axi_rdata[29]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[2] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[2]),
        .Q(s00_axi_rdata[2]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[30] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[30]),
        .Q(s00_axi_rdata[30]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[31] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[31]),
        .Q(s00_axi_rdata[31]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[3] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[3]),
        .Q(s00_axi_rdata[3]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[4] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[4]),
        .Q(s00_axi_rdata[4]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[5] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[5]),
        .Q(s00_axi_rdata[5]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[6] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[6]),
        .Q(s00_axi_rdata[6]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[7] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[7]),
        .Q(s00_axi_rdata[7]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[8] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[8]),
        .Q(s00_axi_rdata[8]),
        .R(p_0_in));
  FDRE \axi_rdata_reg[9] 
       (.C(s00_axi_aclk),
        .CE(cpu_rdata_dv),
        .D(cpu_rdata[9]),
        .Q(s00_axi_rdata[9]),
        .R(p_0_in));
  LUT4 #(
    .INIT(16'h08F8)) 
    axi_rvalid_i_1
       (.I0(cpu_rd),
        .I1(cpu_rdata_dv),
        .I2(s00_axi_rvalid),
        .I3(s00_axi_rready),
        .O(axi_rvalid_i_1_n_0));
  FDRE axi_rvalid_reg
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(axi_rvalid_i_1_n_0),
        .Q(s00_axi_rvalid),
        .R(p_0_in));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT3 #(
    .INIT(8'h08)) 
    axi_wready_i_1
       (.I0(s00_axi_wvalid),
        .I1(s00_axi_awvalid),
        .I2(S_AXI_WREADY),
        .O(axi_wready0));
  FDRE axi_wready_reg
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(axi_wready0),
        .Q(S_AXI_WREADY),
        .R(p_0_in));
  LUT2 #(
    .INIT(4'hE)) 
    \cpu_addr[0]_INST_0 
       (.I0(cpu_raddr[0]),
        .I1(cpu_waddr[0]),
        .O(cpu_addr[0]));
  LUT2 #(
    .INIT(4'hE)) 
    \cpu_addr[10]_INST_0 
       (.I0(cpu_raddr[10]),
        .I1(cpu_waddr[10]),
        .O(cpu_addr[10]));
  LUT2 #(
    .INIT(4'hE)) 
    \cpu_addr[11]_INST_0 
       (.I0(cpu_raddr[11]),
        .I1(cpu_waddr[11]),
        .O(cpu_addr[11]));
  LUT2 #(
    .INIT(4'hE)) 
    \cpu_addr[12]_INST_0 
       (.I0(cpu_raddr[12]),
        .I1(cpu_waddr[12]),
        .O(cpu_addr[12]));
  LUT2 #(
    .INIT(4'hE)) 
    \cpu_addr[13]_INST_0 
       (.I0(cpu_raddr[13]),
        .I1(cpu_waddr[13]),
        .O(cpu_addr[13]));
  LUT2 #(
    .INIT(4'hE)) 
    \cpu_addr[14]_INST_0 
       (.I0(cpu_raddr[14]),
        .I1(cpu_waddr[14]),
        .O(cpu_addr[14]));
  LUT2 #(
    .INIT(4'hE)) 
    \cpu_addr[15]_INST_0 
       (.I0(cpu_raddr[15]),
        .I1(cpu_waddr[15]),
        .O(cpu_addr[15]));
  LUT2 #(
    .INIT(4'hE)) 
    \cpu_addr[16]_INST_0 
       (.I0(cpu_raddr[16]),
        .I1(cpu_waddr[16]),
        .O(cpu_addr[16]));
  LUT2 #(
    .INIT(4'hE)) 
    \cpu_addr[17]_INST_0 
       (.I0(cpu_raddr[17]),
        .I1(cpu_waddr[17]),
        .O(cpu_addr[17]));
  LUT2 #(
    .INIT(4'hE)) 
    \cpu_addr[1]_INST_0 
       (.I0(cpu_raddr[1]),
        .I1(cpu_waddr[1]),
        .O(cpu_addr[1]));
  LUT2 #(
    .INIT(4'hE)) 
    \cpu_addr[2]_INST_0 
       (.I0(cpu_raddr[2]),
        .I1(cpu_waddr[2]),
        .O(cpu_addr[2]));
  LUT2 #(
    .INIT(4'hE)) 
    \cpu_addr[3]_INST_0 
       (.I0(cpu_raddr[3]),
        .I1(cpu_waddr[3]),
        .O(cpu_addr[3]));
  LUT2 #(
    .INIT(4'hE)) 
    \cpu_addr[4]_INST_0 
       (.I0(cpu_raddr[4]),
        .I1(cpu_waddr[4]),
        .O(cpu_addr[4]));
  LUT2 #(
    .INIT(4'hE)) 
    \cpu_addr[5]_INST_0 
       (.I0(cpu_raddr[5]),
        .I1(cpu_waddr[5]),
        .O(cpu_addr[5]));
  LUT2 #(
    .INIT(4'hE)) 
    \cpu_addr[6]_INST_0 
       (.I0(cpu_raddr[6]),
        .I1(cpu_waddr[6]),
        .O(cpu_addr[6]));
  LUT2 #(
    .INIT(4'hE)) 
    \cpu_addr[7]_INST_0 
       (.I0(cpu_raddr[7]),
        .I1(cpu_waddr[7]),
        .O(cpu_addr[7]));
  LUT2 #(
    .INIT(4'hE)) 
    \cpu_addr[8]_INST_0 
       (.I0(cpu_raddr[8]),
        .I1(cpu_waddr[8]),
        .O(cpu_addr[8]));
  LUT2 #(
    .INIT(4'hE)) 
    \cpu_addr[9]_INST_0 
       (.I0(cpu_raddr[9]),
        .I1(cpu_waddr[9]),
        .O(cpu_addr[9]));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT3 #(
    .INIT(8'h40)) 
    \cpu_raddr[0]_i_1 
       (.I0(S_AXI_ARREADY),
        .I1(s00_axi_arvalid),
        .I2(s00_axi_araddr[0]),
        .O(\cpu_raddr[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT3 #(
    .INIT(8'h40)) 
    \cpu_raddr[10]_i_1 
       (.I0(S_AXI_ARREADY),
        .I1(s00_axi_arvalid),
        .I2(s00_axi_araddr[10]),
        .O(\cpu_raddr[10]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT3 #(
    .INIT(8'h40)) 
    \cpu_raddr[11]_i_1 
       (.I0(S_AXI_ARREADY),
        .I1(s00_axi_arvalid),
        .I2(s00_axi_araddr[11]),
        .O(\cpu_raddr[11]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT3 #(
    .INIT(8'h40)) 
    \cpu_raddr[12]_i_1 
       (.I0(S_AXI_ARREADY),
        .I1(s00_axi_arvalid),
        .I2(s00_axi_araddr[12]),
        .O(\cpu_raddr[12]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT3 #(
    .INIT(8'h40)) 
    \cpu_raddr[13]_i_1 
       (.I0(S_AXI_ARREADY),
        .I1(s00_axi_arvalid),
        .I2(s00_axi_araddr[13]),
        .O(\cpu_raddr[13]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT3 #(
    .INIT(8'h40)) 
    \cpu_raddr[14]_i_1 
       (.I0(S_AXI_ARREADY),
        .I1(s00_axi_arvalid),
        .I2(s00_axi_araddr[14]),
        .O(\cpu_raddr[14]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT3 #(
    .INIT(8'h40)) 
    \cpu_raddr[15]_i_1 
       (.I0(S_AXI_ARREADY),
        .I1(s00_axi_arvalid),
        .I2(s00_axi_araddr[15]),
        .O(\cpu_raddr[15]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT3 #(
    .INIT(8'h40)) 
    \cpu_raddr[16]_i_1 
       (.I0(S_AXI_ARREADY),
        .I1(s00_axi_arvalid),
        .I2(s00_axi_araddr[16]),
        .O(\cpu_raddr[16]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT3 #(
    .INIT(8'h40)) 
    \cpu_raddr[17]_i_1 
       (.I0(S_AXI_ARREADY),
        .I1(s00_axi_arvalid),
        .I2(s00_axi_araddr[17]),
        .O(\cpu_raddr[17]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT3 #(
    .INIT(8'h40)) 
    \cpu_raddr[1]_i_1 
       (.I0(S_AXI_ARREADY),
        .I1(s00_axi_arvalid),
        .I2(s00_axi_araddr[1]),
        .O(\cpu_raddr[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT3 #(
    .INIT(8'h40)) 
    \cpu_raddr[2]_i_1 
       (.I0(S_AXI_ARREADY),
        .I1(s00_axi_arvalid),
        .I2(s00_axi_araddr[2]),
        .O(\cpu_raddr[2]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT3 #(
    .INIT(8'h40)) 
    \cpu_raddr[3]_i_1 
       (.I0(S_AXI_ARREADY),
        .I1(s00_axi_arvalid),
        .I2(s00_axi_araddr[3]),
        .O(\cpu_raddr[3]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT3 #(
    .INIT(8'h40)) 
    \cpu_raddr[4]_i_1 
       (.I0(S_AXI_ARREADY),
        .I1(s00_axi_arvalid),
        .I2(s00_axi_araddr[4]),
        .O(\cpu_raddr[4]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT3 #(
    .INIT(8'h40)) 
    \cpu_raddr[5]_i_1 
       (.I0(S_AXI_ARREADY),
        .I1(s00_axi_arvalid),
        .I2(s00_axi_araddr[5]),
        .O(\cpu_raddr[5]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT3 #(
    .INIT(8'h40)) 
    \cpu_raddr[6]_i_1 
       (.I0(S_AXI_ARREADY),
        .I1(s00_axi_arvalid),
        .I2(s00_axi_araddr[6]),
        .O(\cpu_raddr[6]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT3 #(
    .INIT(8'h40)) 
    \cpu_raddr[7]_i_1 
       (.I0(S_AXI_ARREADY),
        .I1(s00_axi_arvalid),
        .I2(s00_axi_araddr[7]),
        .O(\cpu_raddr[7]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT3 #(
    .INIT(8'h40)) 
    \cpu_raddr[8]_i_1 
       (.I0(S_AXI_ARREADY),
        .I1(s00_axi_arvalid),
        .I2(s00_axi_araddr[8]),
        .O(\cpu_raddr[8]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT3 #(
    .INIT(8'h40)) 
    \cpu_raddr[9]_i_1 
       (.I0(S_AXI_ARREADY),
        .I1(s00_axi_arvalid),
        .I2(s00_axi_araddr[9]),
        .O(\cpu_raddr[9]_i_1_n_0 ));
  FDRE \cpu_raddr_reg[0] 
       (.C(s00_axi_aclk),
        .CE(cpu_rd_i_i_1_n_0),
        .D(\cpu_raddr[0]_i_1_n_0 ),
        .Q(cpu_raddr[0]),
        .R(p_0_in));
  FDRE \cpu_raddr_reg[10] 
       (.C(s00_axi_aclk),
        .CE(cpu_rd_i_i_1_n_0),
        .D(\cpu_raddr[10]_i_1_n_0 ),
        .Q(cpu_raddr[10]),
        .R(p_0_in));
  FDRE \cpu_raddr_reg[11] 
       (.C(s00_axi_aclk),
        .CE(cpu_rd_i_i_1_n_0),
        .D(\cpu_raddr[11]_i_1_n_0 ),
        .Q(cpu_raddr[11]),
        .R(p_0_in));
  FDRE \cpu_raddr_reg[12] 
       (.C(s00_axi_aclk),
        .CE(cpu_rd_i_i_1_n_0),
        .D(\cpu_raddr[12]_i_1_n_0 ),
        .Q(cpu_raddr[12]),
        .R(p_0_in));
  FDRE \cpu_raddr_reg[13] 
       (.C(s00_axi_aclk),
        .CE(cpu_rd_i_i_1_n_0),
        .D(\cpu_raddr[13]_i_1_n_0 ),
        .Q(cpu_raddr[13]),
        .R(p_0_in));
  FDRE \cpu_raddr_reg[14] 
       (.C(s00_axi_aclk),
        .CE(cpu_rd_i_i_1_n_0),
        .D(\cpu_raddr[14]_i_1_n_0 ),
        .Q(cpu_raddr[14]),
        .R(p_0_in));
  FDRE \cpu_raddr_reg[15] 
       (.C(s00_axi_aclk),
        .CE(cpu_rd_i_i_1_n_0),
        .D(\cpu_raddr[15]_i_1_n_0 ),
        .Q(cpu_raddr[15]),
        .R(p_0_in));
  FDRE \cpu_raddr_reg[16] 
       (.C(s00_axi_aclk),
        .CE(cpu_rd_i_i_1_n_0),
        .D(\cpu_raddr[16]_i_1_n_0 ),
        .Q(cpu_raddr[16]),
        .R(p_0_in));
  FDRE \cpu_raddr_reg[17] 
       (.C(s00_axi_aclk),
        .CE(cpu_rd_i_i_1_n_0),
        .D(\cpu_raddr[17]_i_1_n_0 ),
        .Q(cpu_raddr[17]),
        .R(p_0_in));
  FDRE \cpu_raddr_reg[1] 
       (.C(s00_axi_aclk),
        .CE(cpu_rd_i_i_1_n_0),
        .D(\cpu_raddr[1]_i_1_n_0 ),
        .Q(cpu_raddr[1]),
        .R(p_0_in));
  FDRE \cpu_raddr_reg[2] 
       (.C(s00_axi_aclk),
        .CE(cpu_rd_i_i_1_n_0),
        .D(\cpu_raddr[2]_i_1_n_0 ),
        .Q(cpu_raddr[2]),
        .R(p_0_in));
  FDRE \cpu_raddr_reg[3] 
       (.C(s00_axi_aclk),
        .CE(cpu_rd_i_i_1_n_0),
        .D(\cpu_raddr[3]_i_1_n_0 ),
        .Q(cpu_raddr[3]),
        .R(p_0_in));
  FDRE \cpu_raddr_reg[4] 
       (.C(s00_axi_aclk),
        .CE(cpu_rd_i_i_1_n_0),
        .D(\cpu_raddr[4]_i_1_n_0 ),
        .Q(cpu_raddr[4]),
        .R(p_0_in));
  FDRE \cpu_raddr_reg[5] 
       (.C(s00_axi_aclk),
        .CE(cpu_rd_i_i_1_n_0),
        .D(\cpu_raddr[5]_i_1_n_0 ),
        .Q(cpu_raddr[5]),
        .R(p_0_in));
  FDRE \cpu_raddr_reg[6] 
       (.C(s00_axi_aclk),
        .CE(cpu_rd_i_i_1_n_0),
        .D(\cpu_raddr[6]_i_1_n_0 ),
        .Q(cpu_raddr[6]),
        .R(p_0_in));
  FDRE \cpu_raddr_reg[7] 
       (.C(s00_axi_aclk),
        .CE(cpu_rd_i_i_1_n_0),
        .D(\cpu_raddr[7]_i_1_n_0 ),
        .Q(cpu_raddr[7]),
        .R(p_0_in));
  FDRE \cpu_raddr_reg[8] 
       (.C(s00_axi_aclk),
        .CE(cpu_rd_i_i_1_n_0),
        .D(\cpu_raddr[8]_i_1_n_0 ),
        .Q(cpu_raddr[8]),
        .R(p_0_in));
  FDRE \cpu_raddr_reg[9] 
       (.C(s00_axi_aclk),
        .CE(cpu_rd_i_i_1_n_0),
        .D(\cpu_raddr[9]_i_1_n_0 ),
        .Q(cpu_raddr[9]),
        .R(p_0_in));
  LUT3 #(
    .INIT(8'hF4)) 
    cpu_rd_i_i_1
       (.I0(S_AXI_ARREADY),
        .I1(s00_axi_arvalid),
        .I2(cpu_rdata_dv),
        .O(cpu_rd_i_i_1_n_0));
  LUT2 #(
    .INIT(4'h2)) 
    cpu_rd_i_i_2
       (.I0(s00_axi_arvalid),
        .I1(S_AXI_ARREADY),
        .O(axi_arready0));
  FDRE cpu_rd_i_reg
       (.C(s00_axi_aclk),
        .CE(cpu_rd_i_i_1_n_0),
        .D(axi_arready0),
        .Q(cpu_rd),
        .R(p_0_in));
  LUT5 #(
    .INIT(32'h7FFFFFFF)) 
    \cpu_waddr[17]_i_1 
       (.I0(s00_axi_aresetn),
        .I1(s00_axi_awvalid),
        .I2(s00_axi_wvalid),
        .I3(S_AXI_WREADY),
        .I4(S_AXI_AWREADY),
        .O(\cpu_waddr[17]_i_1_n_0 ));
  FDRE \cpu_waddr_reg[0] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(axi_awaddr[0]),
        .Q(cpu_waddr[0]),
        .R(\cpu_waddr[17]_i_1_n_0 ));
  FDRE \cpu_waddr_reg[10] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(axi_awaddr[10]),
        .Q(cpu_waddr[10]),
        .R(\cpu_waddr[17]_i_1_n_0 ));
  FDRE \cpu_waddr_reg[11] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(axi_awaddr[11]),
        .Q(cpu_waddr[11]),
        .R(\cpu_waddr[17]_i_1_n_0 ));
  FDRE \cpu_waddr_reg[12] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(axi_awaddr[12]),
        .Q(cpu_waddr[12]),
        .R(\cpu_waddr[17]_i_1_n_0 ));
  FDRE \cpu_waddr_reg[13] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(axi_awaddr[13]),
        .Q(cpu_waddr[13]),
        .R(\cpu_waddr[17]_i_1_n_0 ));
  FDRE \cpu_waddr_reg[14] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(axi_awaddr[14]),
        .Q(cpu_waddr[14]),
        .R(\cpu_waddr[17]_i_1_n_0 ));
  FDRE \cpu_waddr_reg[15] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(axi_awaddr[15]),
        .Q(cpu_waddr[15]),
        .R(\cpu_waddr[17]_i_1_n_0 ));
  FDRE \cpu_waddr_reg[16] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(axi_awaddr[16]),
        .Q(cpu_waddr[16]),
        .R(\cpu_waddr[17]_i_1_n_0 ));
  FDRE \cpu_waddr_reg[17] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(axi_awaddr[17]),
        .Q(cpu_waddr[17]),
        .R(\cpu_waddr[17]_i_1_n_0 ));
  FDRE \cpu_waddr_reg[1] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(axi_awaddr[1]),
        .Q(cpu_waddr[1]),
        .R(\cpu_waddr[17]_i_1_n_0 ));
  FDRE \cpu_waddr_reg[2] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(axi_awaddr[2]),
        .Q(cpu_waddr[2]),
        .R(\cpu_waddr[17]_i_1_n_0 ));
  FDRE \cpu_waddr_reg[3] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(axi_awaddr[3]),
        .Q(cpu_waddr[3]),
        .R(\cpu_waddr[17]_i_1_n_0 ));
  FDRE \cpu_waddr_reg[4] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(axi_awaddr[4]),
        .Q(cpu_waddr[4]),
        .R(\cpu_waddr[17]_i_1_n_0 ));
  FDRE \cpu_waddr_reg[5] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(axi_awaddr[5]),
        .Q(cpu_waddr[5]),
        .R(\cpu_waddr[17]_i_1_n_0 ));
  FDRE \cpu_waddr_reg[6] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(axi_awaddr[6]),
        .Q(cpu_waddr[6]),
        .R(\cpu_waddr[17]_i_1_n_0 ));
  FDRE \cpu_waddr_reg[7] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(axi_awaddr[7]),
        .Q(cpu_waddr[7]),
        .R(\cpu_waddr[17]_i_1_n_0 ));
  FDRE \cpu_waddr_reg[8] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(axi_awaddr[8]),
        .Q(cpu_waddr[8]),
        .R(\cpu_waddr[17]_i_1_n_0 ));
  FDRE \cpu_waddr_reg[9] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(axi_awaddr[9]),
        .Q(cpu_waddr[9]),
        .R(\cpu_waddr[17]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[0]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[0]),
        .O(\cpu_wdata[0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[10]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[10]),
        .O(\cpu_wdata[10]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[11]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[11]),
        .O(\cpu_wdata[11]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[12]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[12]),
        .O(\cpu_wdata[12]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[13]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[13]),
        .O(\cpu_wdata[13]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[14]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[14]),
        .O(\cpu_wdata[14]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[15]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[15]),
        .O(\cpu_wdata[15]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[16]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[16]),
        .O(\cpu_wdata[16]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[17]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[17]),
        .O(\cpu_wdata[17]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[18]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[18]),
        .O(\cpu_wdata[18]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[19]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[19]),
        .O(\cpu_wdata[19]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[1]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[1]),
        .O(\cpu_wdata[1]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[20]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[20]),
        .O(\cpu_wdata[20]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[21]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[21]),
        .O(\cpu_wdata[21]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[22]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[22]),
        .O(\cpu_wdata[22]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[23]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[23]),
        .O(\cpu_wdata[23]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[24]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[24]),
        .O(\cpu_wdata[24]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[25]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[25]),
        .O(\cpu_wdata[25]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[26]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[26]),
        .O(\cpu_wdata[26]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[27]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[27]),
        .O(\cpu_wdata[27]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[28]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[28]),
        .O(\cpu_wdata[28]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[29]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[29]),
        .O(\cpu_wdata[29]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[2]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[2]),
        .O(\cpu_wdata[2]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[30]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[30]),
        .O(\cpu_wdata[30]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[31]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[31]),
        .O(\cpu_wdata[31]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[3]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[3]),
        .O(\cpu_wdata[3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[4]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[4]),
        .O(\cpu_wdata[4]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[5]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[5]),
        .O(\cpu_wdata[5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[6]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[6]),
        .O(\cpu_wdata[6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[7]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[7]),
        .O(\cpu_wdata[7]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[8]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[8]),
        .O(\cpu_wdata[8]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80000000)) 
    \cpu_wdata[9]_i_1 
       (.I0(s00_axi_awvalid),
        .I1(s00_axi_wvalid),
        .I2(S_AXI_WREADY),
        .I3(S_AXI_AWREADY),
        .I4(s00_axi_wdata[9]),
        .O(\cpu_wdata[9]_i_1_n_0 ));
  FDRE \cpu_wdata_reg[0] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[0]_i_1_n_0 ),
        .Q(cpu_wdata[0]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[10] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[10]_i_1_n_0 ),
        .Q(cpu_wdata[10]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[11] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[11]_i_1_n_0 ),
        .Q(cpu_wdata[11]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[12] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[12]_i_1_n_0 ),
        .Q(cpu_wdata[12]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[13] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[13]_i_1_n_0 ),
        .Q(cpu_wdata[13]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[14] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[14]_i_1_n_0 ),
        .Q(cpu_wdata[14]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[15] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[15]_i_1_n_0 ),
        .Q(cpu_wdata[15]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[16] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[16]_i_1_n_0 ),
        .Q(cpu_wdata[16]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[17] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[17]_i_1_n_0 ),
        .Q(cpu_wdata[17]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[18] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[18]_i_1_n_0 ),
        .Q(cpu_wdata[18]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[19] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[19]_i_1_n_0 ),
        .Q(cpu_wdata[19]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[1] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[1]_i_1_n_0 ),
        .Q(cpu_wdata[1]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[20] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[20]_i_1_n_0 ),
        .Q(cpu_wdata[20]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[21] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[21]_i_1_n_0 ),
        .Q(cpu_wdata[21]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[22] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[22]_i_1_n_0 ),
        .Q(cpu_wdata[22]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[23] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[23]_i_1_n_0 ),
        .Q(cpu_wdata[23]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[24] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[24]_i_1_n_0 ),
        .Q(cpu_wdata[24]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[25] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[25]_i_1_n_0 ),
        .Q(cpu_wdata[25]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[26] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[26]_i_1_n_0 ),
        .Q(cpu_wdata[26]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[27] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[27]_i_1_n_0 ),
        .Q(cpu_wdata[27]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[28] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[28]_i_1_n_0 ),
        .Q(cpu_wdata[28]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[29] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[29]_i_1_n_0 ),
        .Q(cpu_wdata[29]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[2] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[2]_i_1_n_0 ),
        .Q(cpu_wdata[2]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[30] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[30]_i_1_n_0 ),
        .Q(cpu_wdata[30]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[31] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[31]_i_1_n_0 ),
        .Q(cpu_wdata[31]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[3] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[3]_i_1_n_0 ),
        .Q(cpu_wdata[3]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[4] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[4]_i_1_n_0 ),
        .Q(cpu_wdata[4]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[5] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[5]_i_1_n_0 ),
        .Q(cpu_wdata[5]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[6] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[6]_i_1_n_0 ),
        .Q(cpu_wdata[6]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[7] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[7]_i_1_n_0 ),
        .Q(cpu_wdata[7]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[8] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[8]_i_1_n_0 ),
        .Q(cpu_wdata[8]),
        .R(p_0_in));
  FDRE \cpu_wdata_reg[9] 
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(\cpu_wdata[9]_i_1_n_0 ),
        .Q(cpu_wdata[9]),
        .R(p_0_in));
  LUT1 #(
    .INIT(2'h1)) 
    cpu_wr_i_1
       (.I0(s00_axi_aresetn),
        .O(p_0_in));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    cpu_wr_i_2
       (.I0(S_AXI_AWREADY),
        .I1(S_AXI_WREADY),
        .I2(s00_axi_wvalid),
        .I3(s00_axi_awvalid),
        .O(slv_reg_wren));
  FDRE cpu_wr_reg
       (.C(s00_axi_aclk),
        .CE(1'b1),
        .D(slv_reg_wren),
        .Q(cpu_wr),
        .R(p_0_in));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
