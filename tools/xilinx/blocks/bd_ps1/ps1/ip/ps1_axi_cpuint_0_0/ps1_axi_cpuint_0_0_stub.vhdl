-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.1.2 (win64) Build 3605665 Fri Aug  5 22:53:37 MDT 2022
-- Date        : Fri Nov  8 17:08:01 2024
-- Host        : STATIONX2 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               e:/home/Eric/acme/NANO_QLASER/tools/xilinx/blocks/bd_ps1/ps1/ip/ps1_axi_cpuint_0_0/ps1_axi_cpuint_0_0_stub.vhdl
-- Design      : ps1_axi_cpuint_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xczu9eg-ffvb1156-2-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ps1_axi_cpuint_0_0 is
  Port ( 
    clk_cpu : out STD_LOGIC;
    cpu_wr : out STD_LOGIC;
    cpu_rd : out STD_LOGIC;
    cpu_addr : out STD_LOGIC_VECTOR ( 17 downto 0 );
    cpu_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    cpu_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    cpu_rdata_dv : in STD_LOGIC;
    s00_axi_aclk : in STD_LOGIC;
    s00_axi_aresetn : in STD_LOGIC;
    s00_axi_awaddr : in STD_LOGIC_VECTOR ( 17 downto 0 );
    s00_axi_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s00_axi_awvalid : in STD_LOGIC;
    s00_axi_awready : out STD_LOGIC;
    s00_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s00_axi_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s00_axi_wvalid : in STD_LOGIC;
    s00_axi_wready : out STD_LOGIC;
    s00_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s00_axi_bvalid : out STD_LOGIC;
    s00_axi_bready : in STD_LOGIC;
    s00_axi_araddr : in STD_LOGIC_VECTOR ( 17 downto 0 );
    s00_axi_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s00_axi_arvalid : in STD_LOGIC;
    s00_axi_arready : out STD_LOGIC;
    s00_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s00_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s00_axi_rvalid : out STD_LOGIC;
    s00_axi_rready : in STD_LOGIC
  );

end ps1_axi_cpuint_0_0;

architecture stub of ps1_axi_cpuint_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_cpu,cpu_wr,cpu_rd,cpu_addr[17:0],cpu_wdata[31:0],cpu_rdata[31:0],cpu_rdata_dv,s00_axi_aclk,s00_axi_aresetn,s00_axi_awaddr[17:0],s00_axi_awprot[2:0],s00_axi_awvalid,s00_axi_awready,s00_axi_wdata[31:0],s00_axi_wstrb[3:0],s00_axi_wvalid,s00_axi_wready,s00_axi_bresp[1:0],s00_axi_bvalid,s00_axi_bready,s00_axi_araddr[17:0],s00_axi_arprot[2:0],s00_axi_arvalid,s00_axi_arready,s00_axi_rdata[31:0],s00_axi_rresp[1:0],s00_axi_rvalid,s00_axi_rready";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "axi_cpuint_v1_0,Vivado 2022.1.2";
begin
end;
