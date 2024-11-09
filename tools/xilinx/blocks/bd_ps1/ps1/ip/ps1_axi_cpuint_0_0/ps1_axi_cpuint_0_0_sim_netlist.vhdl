-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.1.2 (win64) Build 3605665 Fri Aug  5 22:53:37 MDT 2022
-- Date        : Fri Nov  8 17:08:01 2024
-- Host        : STATIONX2 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim
--               e:/home/Eric/acme/NANO_QLASER/tools/xilinx/blocks/bd_ps1/ps1/ip/ps1_axi_cpuint_0_0/ps1_axi_cpuint_0_0_sim_netlist.vhdl
-- Design      : ps1_axi_cpuint_0_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xczu9eg-ffvb1156-2-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity ps1_axi_cpuint_0_0_axi_cpuint_v1_0_S00_AXI is
  port (
    S_AXI_WREADY : out STD_LOGIC;
    S_AXI_AWREADY : out STD_LOGIC;
    S_AXI_ARREADY : out STD_LOGIC;
    cpu_addr : out STD_LOGIC_VECTOR ( 17 downto 0 );
    cpu_wr : out STD_LOGIC;
    cpu_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s00_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    cpu_rd : out STD_LOGIC;
    s00_axi_bvalid : out STD_LOGIC;
    s00_axi_rvalid : out STD_LOGIC;
    s00_axi_awvalid : in STD_LOGIC;
    s00_axi_wvalid : in STD_LOGIC;
    s00_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s00_axi_aresetn : in STD_LOGIC;
    s00_axi_arvalid : in STD_LOGIC;
    s00_axi_araddr : in STD_LOGIC_VECTOR ( 17 downto 0 );
    s00_axi_aclk : in STD_LOGIC;
    s00_axi_awaddr : in STD_LOGIC_VECTOR ( 17 downto 0 );
    cpu_rdata_dv : in STD_LOGIC;
    cpu_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s00_axi_bready : in STD_LOGIC;
    s00_axi_rready : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of ps1_axi_cpuint_0_0_axi_cpuint_v1_0_S00_AXI : entity is "axi_cpuint_v1_0_S00_AXI";
end ps1_axi_cpuint_0_0_axi_cpuint_v1_0_S00_AXI;

architecture STRUCTURE of ps1_axi_cpuint_0_0_axi_cpuint_v1_0_S00_AXI is
  signal \^s_axi_arready\ : STD_LOGIC;
  signal \^s_axi_awready\ : STD_LOGIC;
  signal \^s_axi_wready\ : STD_LOGIC;
  signal axi_arready0 : STD_LOGIC;
  signal axi_awaddr : STD_LOGIC_VECTOR ( 17 downto 0 );
  signal axi_awready0 : STD_LOGIC;
  signal axi_bvalid_i_1_n_0 : STD_LOGIC;
  signal axi_rvalid_i_1_n_0 : STD_LOGIC;
  signal axi_wready0 : STD_LOGIC;
  signal cpu_raddr : STD_LOGIC_VECTOR ( 17 downto 0 );
  signal \cpu_raddr[0]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_raddr[10]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_raddr[11]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_raddr[12]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_raddr[13]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_raddr[14]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_raddr[15]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_raddr[16]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_raddr[17]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_raddr[1]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_raddr[2]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_raddr[3]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_raddr[4]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_raddr[5]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_raddr[6]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_raddr[7]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_raddr[8]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_raddr[9]_i_1_n_0\ : STD_LOGIC;
  signal \^cpu_rd\ : STD_LOGIC;
  signal cpu_rd_i_i_1_n_0 : STD_LOGIC;
  signal cpu_waddr : STD_LOGIC_VECTOR ( 17 downto 0 );
  signal \cpu_waddr[17]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[0]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[10]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[11]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[12]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[13]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[14]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[15]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[16]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[17]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[18]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[19]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[1]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[20]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[21]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[22]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[23]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[24]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[25]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[26]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[27]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[28]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[29]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[2]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[30]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[31]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[3]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[4]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[5]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[6]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[7]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[8]_i_1_n_0\ : STD_LOGIC;
  signal \cpu_wdata[9]_i_1_n_0\ : STD_LOGIC;
  signal p_0_in : STD_LOGIC;
  signal \^s00_axi_bvalid\ : STD_LOGIC;
  signal \^s00_axi_rvalid\ : STD_LOGIC;
  signal slv_reg_wren : STD_LOGIC;
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of axi_wready_i_1 : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \cpu_raddr[0]_i_1\ : label is "soft_lutpair10";
  attribute SOFT_HLUTNM of \cpu_raddr[10]_i_1\ : label is "soft_lutpair5";
  attribute SOFT_HLUTNM of \cpu_raddr[11]_i_1\ : label is "soft_lutpair5";
  attribute SOFT_HLUTNM of \cpu_raddr[12]_i_1\ : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of \cpu_raddr[13]_i_1\ : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of \cpu_raddr[14]_i_1\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \cpu_raddr[15]_i_1\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \cpu_raddr[16]_i_1\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \cpu_raddr[17]_i_1\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \cpu_raddr[1]_i_1\ : label is "soft_lutpair10";
  attribute SOFT_HLUTNM of \cpu_raddr[2]_i_1\ : label is "soft_lutpair9";
  attribute SOFT_HLUTNM of \cpu_raddr[3]_i_1\ : label is "soft_lutpair9";
  attribute SOFT_HLUTNM of \cpu_raddr[4]_i_1\ : label is "soft_lutpair8";
  attribute SOFT_HLUTNM of \cpu_raddr[5]_i_1\ : label is "soft_lutpair8";
  attribute SOFT_HLUTNM of \cpu_raddr[6]_i_1\ : label is "soft_lutpair7";
  attribute SOFT_HLUTNM of \cpu_raddr[7]_i_1\ : label is "soft_lutpair7";
  attribute SOFT_HLUTNM of \cpu_raddr[8]_i_1\ : label is "soft_lutpair6";
  attribute SOFT_HLUTNM of \cpu_raddr[9]_i_1\ : label is "soft_lutpair6";
  attribute SOFT_HLUTNM of \cpu_wdata[30]_i_1\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \cpu_wdata[31]_i_1\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of cpu_wr_i_2 : label is "soft_lutpair0";
begin
  S_AXI_ARREADY <= \^s_axi_arready\;
  S_AXI_AWREADY <= \^s_axi_awready\;
  S_AXI_WREADY <= \^s_axi_wready\;
  cpu_rd <= \^cpu_rd\;
  s00_axi_bvalid <= \^s00_axi_bvalid\;
  s00_axi_rvalid <= \^s00_axi_rvalid\;
axi_arready_reg: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => axi_arready0,
      Q => \^s_axi_arready\,
      R => p_0_in
    );
\axi_awaddr_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => axi_awready0,
      D => s00_axi_awaddr(0),
      Q => axi_awaddr(0),
      R => p_0_in
    );
\axi_awaddr_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => axi_awready0,
      D => s00_axi_awaddr(10),
      Q => axi_awaddr(10),
      R => p_0_in
    );
\axi_awaddr_reg[11]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => axi_awready0,
      D => s00_axi_awaddr(11),
      Q => axi_awaddr(11),
      R => p_0_in
    );
\axi_awaddr_reg[12]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => axi_awready0,
      D => s00_axi_awaddr(12),
      Q => axi_awaddr(12),
      R => p_0_in
    );
\axi_awaddr_reg[13]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => axi_awready0,
      D => s00_axi_awaddr(13),
      Q => axi_awaddr(13),
      R => p_0_in
    );
\axi_awaddr_reg[14]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => axi_awready0,
      D => s00_axi_awaddr(14),
      Q => axi_awaddr(14),
      R => p_0_in
    );
\axi_awaddr_reg[15]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => axi_awready0,
      D => s00_axi_awaddr(15),
      Q => axi_awaddr(15),
      R => p_0_in
    );
\axi_awaddr_reg[16]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => axi_awready0,
      D => s00_axi_awaddr(16),
      Q => axi_awaddr(16),
      R => p_0_in
    );
\axi_awaddr_reg[17]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => axi_awready0,
      D => s00_axi_awaddr(17),
      Q => axi_awaddr(17),
      R => p_0_in
    );
\axi_awaddr_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => axi_awready0,
      D => s00_axi_awaddr(1),
      Q => axi_awaddr(1),
      R => p_0_in
    );
\axi_awaddr_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => axi_awready0,
      D => s00_axi_awaddr(2),
      Q => axi_awaddr(2),
      R => p_0_in
    );
\axi_awaddr_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => axi_awready0,
      D => s00_axi_awaddr(3),
      Q => axi_awaddr(3),
      R => p_0_in
    );
\axi_awaddr_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => axi_awready0,
      D => s00_axi_awaddr(4),
      Q => axi_awaddr(4),
      R => p_0_in
    );
\axi_awaddr_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => axi_awready0,
      D => s00_axi_awaddr(5),
      Q => axi_awaddr(5),
      R => p_0_in
    );
\axi_awaddr_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => axi_awready0,
      D => s00_axi_awaddr(6),
      Q => axi_awaddr(6),
      R => p_0_in
    );
\axi_awaddr_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => axi_awready0,
      D => s00_axi_awaddr(7),
      Q => axi_awaddr(7),
      R => p_0_in
    );
\axi_awaddr_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => axi_awready0,
      D => s00_axi_awaddr(8),
      Q => axi_awaddr(8),
      R => p_0_in
    );
\axi_awaddr_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => axi_awready0,
      D => s00_axi_awaddr(9),
      Q => axi_awaddr(9),
      R => p_0_in
    );
axi_awready_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"08"
    )
        port map (
      I0 => s00_axi_wvalid,
      I1 => s00_axi_awvalid,
      I2 => \^s_axi_awready\,
      O => axi_awready0
    );
axi_awready_reg: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => axi_awready0,
      Q => \^s_axi_awready\,
      R => p_0_in
    );
axi_bvalid_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000FFFF80008000"
    )
        port map (
      I0 => s00_axi_wvalid,
      I1 => s00_axi_awvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_bready,
      I5 => \^s00_axi_bvalid\,
      O => axi_bvalid_i_1_n_0
    );
axi_bvalid_reg: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => axi_bvalid_i_1_n_0,
      Q => \^s00_axi_bvalid\,
      R => p_0_in
    );
\axi_rdata_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(0),
      Q => s00_axi_rdata(0),
      R => p_0_in
    );
\axi_rdata_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(10),
      Q => s00_axi_rdata(10),
      R => p_0_in
    );
\axi_rdata_reg[11]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(11),
      Q => s00_axi_rdata(11),
      R => p_0_in
    );
\axi_rdata_reg[12]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(12),
      Q => s00_axi_rdata(12),
      R => p_0_in
    );
\axi_rdata_reg[13]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(13),
      Q => s00_axi_rdata(13),
      R => p_0_in
    );
\axi_rdata_reg[14]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(14),
      Q => s00_axi_rdata(14),
      R => p_0_in
    );
\axi_rdata_reg[15]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(15),
      Q => s00_axi_rdata(15),
      R => p_0_in
    );
\axi_rdata_reg[16]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(16),
      Q => s00_axi_rdata(16),
      R => p_0_in
    );
\axi_rdata_reg[17]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(17),
      Q => s00_axi_rdata(17),
      R => p_0_in
    );
\axi_rdata_reg[18]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(18),
      Q => s00_axi_rdata(18),
      R => p_0_in
    );
\axi_rdata_reg[19]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(19),
      Q => s00_axi_rdata(19),
      R => p_0_in
    );
\axi_rdata_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(1),
      Q => s00_axi_rdata(1),
      R => p_0_in
    );
\axi_rdata_reg[20]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(20),
      Q => s00_axi_rdata(20),
      R => p_0_in
    );
\axi_rdata_reg[21]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(21),
      Q => s00_axi_rdata(21),
      R => p_0_in
    );
\axi_rdata_reg[22]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(22),
      Q => s00_axi_rdata(22),
      R => p_0_in
    );
\axi_rdata_reg[23]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(23),
      Q => s00_axi_rdata(23),
      R => p_0_in
    );
\axi_rdata_reg[24]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(24),
      Q => s00_axi_rdata(24),
      R => p_0_in
    );
\axi_rdata_reg[25]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(25),
      Q => s00_axi_rdata(25),
      R => p_0_in
    );
\axi_rdata_reg[26]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(26),
      Q => s00_axi_rdata(26),
      R => p_0_in
    );
\axi_rdata_reg[27]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(27),
      Q => s00_axi_rdata(27),
      R => p_0_in
    );
\axi_rdata_reg[28]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(28),
      Q => s00_axi_rdata(28),
      R => p_0_in
    );
\axi_rdata_reg[29]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(29),
      Q => s00_axi_rdata(29),
      R => p_0_in
    );
\axi_rdata_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(2),
      Q => s00_axi_rdata(2),
      R => p_0_in
    );
\axi_rdata_reg[30]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(30),
      Q => s00_axi_rdata(30),
      R => p_0_in
    );
\axi_rdata_reg[31]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(31),
      Q => s00_axi_rdata(31),
      R => p_0_in
    );
\axi_rdata_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(3),
      Q => s00_axi_rdata(3),
      R => p_0_in
    );
\axi_rdata_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(4),
      Q => s00_axi_rdata(4),
      R => p_0_in
    );
\axi_rdata_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(5),
      Q => s00_axi_rdata(5),
      R => p_0_in
    );
\axi_rdata_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(6),
      Q => s00_axi_rdata(6),
      R => p_0_in
    );
\axi_rdata_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(7),
      Q => s00_axi_rdata(7),
      R => p_0_in
    );
\axi_rdata_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(8),
      Q => s00_axi_rdata(8),
      R => p_0_in
    );
\axi_rdata_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rdata_dv,
      D => cpu_rdata(9),
      Q => s00_axi_rdata(9),
      R => p_0_in
    );
axi_rvalid_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"08F8"
    )
        port map (
      I0 => \^cpu_rd\,
      I1 => cpu_rdata_dv,
      I2 => \^s00_axi_rvalid\,
      I3 => s00_axi_rready,
      O => axi_rvalid_i_1_n_0
    );
axi_rvalid_reg: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => axi_rvalid_i_1_n_0,
      Q => \^s00_axi_rvalid\,
      R => p_0_in
    );
axi_wready_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"08"
    )
        port map (
      I0 => s00_axi_wvalid,
      I1 => s00_axi_awvalid,
      I2 => \^s_axi_wready\,
      O => axi_wready0
    );
axi_wready_reg: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => axi_wready0,
      Q => \^s_axi_wready\,
      R => p_0_in
    );
\cpu_addr[0]_INST_0\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => cpu_raddr(0),
      I1 => cpu_waddr(0),
      O => cpu_addr(0)
    );
\cpu_addr[10]_INST_0\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => cpu_raddr(10),
      I1 => cpu_waddr(10),
      O => cpu_addr(10)
    );
\cpu_addr[11]_INST_0\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => cpu_raddr(11),
      I1 => cpu_waddr(11),
      O => cpu_addr(11)
    );
\cpu_addr[12]_INST_0\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => cpu_raddr(12),
      I1 => cpu_waddr(12),
      O => cpu_addr(12)
    );
\cpu_addr[13]_INST_0\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => cpu_raddr(13),
      I1 => cpu_waddr(13),
      O => cpu_addr(13)
    );
\cpu_addr[14]_INST_0\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => cpu_raddr(14),
      I1 => cpu_waddr(14),
      O => cpu_addr(14)
    );
\cpu_addr[15]_INST_0\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => cpu_raddr(15),
      I1 => cpu_waddr(15),
      O => cpu_addr(15)
    );
\cpu_addr[16]_INST_0\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => cpu_raddr(16),
      I1 => cpu_waddr(16),
      O => cpu_addr(16)
    );
\cpu_addr[17]_INST_0\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => cpu_raddr(17),
      I1 => cpu_waddr(17),
      O => cpu_addr(17)
    );
\cpu_addr[1]_INST_0\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => cpu_raddr(1),
      I1 => cpu_waddr(1),
      O => cpu_addr(1)
    );
\cpu_addr[2]_INST_0\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => cpu_raddr(2),
      I1 => cpu_waddr(2),
      O => cpu_addr(2)
    );
\cpu_addr[3]_INST_0\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => cpu_raddr(3),
      I1 => cpu_waddr(3),
      O => cpu_addr(3)
    );
\cpu_addr[4]_INST_0\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => cpu_raddr(4),
      I1 => cpu_waddr(4),
      O => cpu_addr(4)
    );
\cpu_addr[5]_INST_0\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => cpu_raddr(5),
      I1 => cpu_waddr(5),
      O => cpu_addr(5)
    );
\cpu_addr[6]_INST_0\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => cpu_raddr(6),
      I1 => cpu_waddr(6),
      O => cpu_addr(6)
    );
\cpu_addr[7]_INST_0\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => cpu_raddr(7),
      I1 => cpu_waddr(7),
      O => cpu_addr(7)
    );
\cpu_addr[8]_INST_0\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => cpu_raddr(8),
      I1 => cpu_waddr(8),
      O => cpu_addr(8)
    );
\cpu_addr[9]_INST_0\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => cpu_raddr(9),
      I1 => cpu_waddr(9),
      O => cpu_addr(9)
    );
\cpu_raddr[0]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"40"
    )
        port map (
      I0 => \^s_axi_arready\,
      I1 => s00_axi_arvalid,
      I2 => s00_axi_araddr(0),
      O => \cpu_raddr[0]_i_1_n_0\
    );
\cpu_raddr[10]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"40"
    )
        port map (
      I0 => \^s_axi_arready\,
      I1 => s00_axi_arvalid,
      I2 => s00_axi_araddr(10),
      O => \cpu_raddr[10]_i_1_n_0\
    );
\cpu_raddr[11]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"40"
    )
        port map (
      I0 => \^s_axi_arready\,
      I1 => s00_axi_arvalid,
      I2 => s00_axi_araddr(11),
      O => \cpu_raddr[11]_i_1_n_0\
    );
\cpu_raddr[12]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"40"
    )
        port map (
      I0 => \^s_axi_arready\,
      I1 => s00_axi_arvalid,
      I2 => s00_axi_araddr(12),
      O => \cpu_raddr[12]_i_1_n_0\
    );
\cpu_raddr[13]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"40"
    )
        port map (
      I0 => \^s_axi_arready\,
      I1 => s00_axi_arvalid,
      I2 => s00_axi_araddr(13),
      O => \cpu_raddr[13]_i_1_n_0\
    );
\cpu_raddr[14]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"40"
    )
        port map (
      I0 => \^s_axi_arready\,
      I1 => s00_axi_arvalid,
      I2 => s00_axi_araddr(14),
      O => \cpu_raddr[14]_i_1_n_0\
    );
\cpu_raddr[15]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"40"
    )
        port map (
      I0 => \^s_axi_arready\,
      I1 => s00_axi_arvalid,
      I2 => s00_axi_araddr(15),
      O => \cpu_raddr[15]_i_1_n_0\
    );
\cpu_raddr[16]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"40"
    )
        port map (
      I0 => \^s_axi_arready\,
      I1 => s00_axi_arvalid,
      I2 => s00_axi_araddr(16),
      O => \cpu_raddr[16]_i_1_n_0\
    );
\cpu_raddr[17]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"40"
    )
        port map (
      I0 => \^s_axi_arready\,
      I1 => s00_axi_arvalid,
      I2 => s00_axi_araddr(17),
      O => \cpu_raddr[17]_i_1_n_0\
    );
\cpu_raddr[1]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"40"
    )
        port map (
      I0 => \^s_axi_arready\,
      I1 => s00_axi_arvalid,
      I2 => s00_axi_araddr(1),
      O => \cpu_raddr[1]_i_1_n_0\
    );
\cpu_raddr[2]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"40"
    )
        port map (
      I0 => \^s_axi_arready\,
      I1 => s00_axi_arvalid,
      I2 => s00_axi_araddr(2),
      O => \cpu_raddr[2]_i_1_n_0\
    );
\cpu_raddr[3]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"40"
    )
        port map (
      I0 => \^s_axi_arready\,
      I1 => s00_axi_arvalid,
      I2 => s00_axi_araddr(3),
      O => \cpu_raddr[3]_i_1_n_0\
    );
\cpu_raddr[4]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"40"
    )
        port map (
      I0 => \^s_axi_arready\,
      I1 => s00_axi_arvalid,
      I2 => s00_axi_araddr(4),
      O => \cpu_raddr[4]_i_1_n_0\
    );
\cpu_raddr[5]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"40"
    )
        port map (
      I0 => \^s_axi_arready\,
      I1 => s00_axi_arvalid,
      I2 => s00_axi_araddr(5),
      O => \cpu_raddr[5]_i_1_n_0\
    );
\cpu_raddr[6]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"40"
    )
        port map (
      I0 => \^s_axi_arready\,
      I1 => s00_axi_arvalid,
      I2 => s00_axi_araddr(6),
      O => \cpu_raddr[6]_i_1_n_0\
    );
\cpu_raddr[7]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"40"
    )
        port map (
      I0 => \^s_axi_arready\,
      I1 => s00_axi_arvalid,
      I2 => s00_axi_araddr(7),
      O => \cpu_raddr[7]_i_1_n_0\
    );
\cpu_raddr[8]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"40"
    )
        port map (
      I0 => \^s_axi_arready\,
      I1 => s00_axi_arvalid,
      I2 => s00_axi_araddr(8),
      O => \cpu_raddr[8]_i_1_n_0\
    );
\cpu_raddr[9]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"40"
    )
        port map (
      I0 => \^s_axi_arready\,
      I1 => s00_axi_arvalid,
      I2 => s00_axi_araddr(9),
      O => \cpu_raddr[9]_i_1_n_0\
    );
\cpu_raddr_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rd_i_i_1_n_0,
      D => \cpu_raddr[0]_i_1_n_0\,
      Q => cpu_raddr(0),
      R => p_0_in
    );
\cpu_raddr_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rd_i_i_1_n_0,
      D => \cpu_raddr[10]_i_1_n_0\,
      Q => cpu_raddr(10),
      R => p_0_in
    );
\cpu_raddr_reg[11]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rd_i_i_1_n_0,
      D => \cpu_raddr[11]_i_1_n_0\,
      Q => cpu_raddr(11),
      R => p_0_in
    );
\cpu_raddr_reg[12]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rd_i_i_1_n_0,
      D => \cpu_raddr[12]_i_1_n_0\,
      Q => cpu_raddr(12),
      R => p_0_in
    );
\cpu_raddr_reg[13]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rd_i_i_1_n_0,
      D => \cpu_raddr[13]_i_1_n_0\,
      Q => cpu_raddr(13),
      R => p_0_in
    );
\cpu_raddr_reg[14]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rd_i_i_1_n_0,
      D => \cpu_raddr[14]_i_1_n_0\,
      Q => cpu_raddr(14),
      R => p_0_in
    );
\cpu_raddr_reg[15]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rd_i_i_1_n_0,
      D => \cpu_raddr[15]_i_1_n_0\,
      Q => cpu_raddr(15),
      R => p_0_in
    );
\cpu_raddr_reg[16]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rd_i_i_1_n_0,
      D => \cpu_raddr[16]_i_1_n_0\,
      Q => cpu_raddr(16),
      R => p_0_in
    );
\cpu_raddr_reg[17]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rd_i_i_1_n_0,
      D => \cpu_raddr[17]_i_1_n_0\,
      Q => cpu_raddr(17),
      R => p_0_in
    );
\cpu_raddr_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rd_i_i_1_n_0,
      D => \cpu_raddr[1]_i_1_n_0\,
      Q => cpu_raddr(1),
      R => p_0_in
    );
\cpu_raddr_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rd_i_i_1_n_0,
      D => \cpu_raddr[2]_i_1_n_0\,
      Q => cpu_raddr(2),
      R => p_0_in
    );
\cpu_raddr_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rd_i_i_1_n_0,
      D => \cpu_raddr[3]_i_1_n_0\,
      Q => cpu_raddr(3),
      R => p_0_in
    );
\cpu_raddr_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rd_i_i_1_n_0,
      D => \cpu_raddr[4]_i_1_n_0\,
      Q => cpu_raddr(4),
      R => p_0_in
    );
\cpu_raddr_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rd_i_i_1_n_0,
      D => \cpu_raddr[5]_i_1_n_0\,
      Q => cpu_raddr(5),
      R => p_0_in
    );
\cpu_raddr_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rd_i_i_1_n_0,
      D => \cpu_raddr[6]_i_1_n_0\,
      Q => cpu_raddr(6),
      R => p_0_in
    );
\cpu_raddr_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rd_i_i_1_n_0,
      D => \cpu_raddr[7]_i_1_n_0\,
      Q => cpu_raddr(7),
      R => p_0_in
    );
\cpu_raddr_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rd_i_i_1_n_0,
      D => \cpu_raddr[8]_i_1_n_0\,
      Q => cpu_raddr(8),
      R => p_0_in
    );
\cpu_raddr_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rd_i_i_1_n_0,
      D => \cpu_raddr[9]_i_1_n_0\,
      Q => cpu_raddr(9),
      R => p_0_in
    );
cpu_rd_i_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"F4"
    )
        port map (
      I0 => \^s_axi_arready\,
      I1 => s00_axi_arvalid,
      I2 => cpu_rdata_dv,
      O => cpu_rd_i_i_1_n_0
    );
cpu_rd_i_i_2: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => s00_axi_arvalid,
      I1 => \^s_axi_arready\,
      O => axi_arready0
    );
cpu_rd_i_reg: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => cpu_rd_i_i_1_n_0,
      D => axi_arready0,
      Q => \^cpu_rd\,
      R => p_0_in
    );
\cpu_waddr[17]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"7FFFFFFF"
    )
        port map (
      I0 => s00_axi_aresetn,
      I1 => s00_axi_awvalid,
      I2 => s00_axi_wvalid,
      I3 => \^s_axi_wready\,
      I4 => \^s_axi_awready\,
      O => \cpu_waddr[17]_i_1_n_0\
    );
\cpu_waddr_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => axi_awaddr(0),
      Q => cpu_waddr(0),
      R => \cpu_waddr[17]_i_1_n_0\
    );
\cpu_waddr_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => axi_awaddr(10),
      Q => cpu_waddr(10),
      R => \cpu_waddr[17]_i_1_n_0\
    );
\cpu_waddr_reg[11]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => axi_awaddr(11),
      Q => cpu_waddr(11),
      R => \cpu_waddr[17]_i_1_n_0\
    );
\cpu_waddr_reg[12]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => axi_awaddr(12),
      Q => cpu_waddr(12),
      R => \cpu_waddr[17]_i_1_n_0\
    );
\cpu_waddr_reg[13]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => axi_awaddr(13),
      Q => cpu_waddr(13),
      R => \cpu_waddr[17]_i_1_n_0\
    );
\cpu_waddr_reg[14]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => axi_awaddr(14),
      Q => cpu_waddr(14),
      R => \cpu_waddr[17]_i_1_n_0\
    );
\cpu_waddr_reg[15]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => axi_awaddr(15),
      Q => cpu_waddr(15),
      R => \cpu_waddr[17]_i_1_n_0\
    );
\cpu_waddr_reg[16]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => axi_awaddr(16),
      Q => cpu_waddr(16),
      R => \cpu_waddr[17]_i_1_n_0\
    );
\cpu_waddr_reg[17]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => axi_awaddr(17),
      Q => cpu_waddr(17),
      R => \cpu_waddr[17]_i_1_n_0\
    );
\cpu_waddr_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => axi_awaddr(1),
      Q => cpu_waddr(1),
      R => \cpu_waddr[17]_i_1_n_0\
    );
\cpu_waddr_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => axi_awaddr(2),
      Q => cpu_waddr(2),
      R => \cpu_waddr[17]_i_1_n_0\
    );
\cpu_waddr_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => axi_awaddr(3),
      Q => cpu_waddr(3),
      R => \cpu_waddr[17]_i_1_n_0\
    );
\cpu_waddr_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => axi_awaddr(4),
      Q => cpu_waddr(4),
      R => \cpu_waddr[17]_i_1_n_0\
    );
\cpu_waddr_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => axi_awaddr(5),
      Q => cpu_waddr(5),
      R => \cpu_waddr[17]_i_1_n_0\
    );
\cpu_waddr_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => axi_awaddr(6),
      Q => cpu_waddr(6),
      R => \cpu_waddr[17]_i_1_n_0\
    );
\cpu_waddr_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => axi_awaddr(7),
      Q => cpu_waddr(7),
      R => \cpu_waddr[17]_i_1_n_0\
    );
\cpu_waddr_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => axi_awaddr(8),
      Q => cpu_waddr(8),
      R => \cpu_waddr[17]_i_1_n_0\
    );
\cpu_waddr_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => axi_awaddr(9),
      Q => cpu_waddr(9),
      R => \cpu_waddr[17]_i_1_n_0\
    );
\cpu_wdata[0]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(0),
      O => \cpu_wdata[0]_i_1_n_0\
    );
\cpu_wdata[10]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(10),
      O => \cpu_wdata[10]_i_1_n_0\
    );
\cpu_wdata[11]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(11),
      O => \cpu_wdata[11]_i_1_n_0\
    );
\cpu_wdata[12]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(12),
      O => \cpu_wdata[12]_i_1_n_0\
    );
\cpu_wdata[13]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(13),
      O => \cpu_wdata[13]_i_1_n_0\
    );
\cpu_wdata[14]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(14),
      O => \cpu_wdata[14]_i_1_n_0\
    );
\cpu_wdata[15]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(15),
      O => \cpu_wdata[15]_i_1_n_0\
    );
\cpu_wdata[16]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(16),
      O => \cpu_wdata[16]_i_1_n_0\
    );
\cpu_wdata[17]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(17),
      O => \cpu_wdata[17]_i_1_n_0\
    );
\cpu_wdata[18]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(18),
      O => \cpu_wdata[18]_i_1_n_0\
    );
\cpu_wdata[19]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(19),
      O => \cpu_wdata[19]_i_1_n_0\
    );
\cpu_wdata[1]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(1),
      O => \cpu_wdata[1]_i_1_n_0\
    );
\cpu_wdata[20]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(20),
      O => \cpu_wdata[20]_i_1_n_0\
    );
\cpu_wdata[21]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(21),
      O => \cpu_wdata[21]_i_1_n_0\
    );
\cpu_wdata[22]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(22),
      O => \cpu_wdata[22]_i_1_n_0\
    );
\cpu_wdata[23]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(23),
      O => \cpu_wdata[23]_i_1_n_0\
    );
\cpu_wdata[24]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(24),
      O => \cpu_wdata[24]_i_1_n_0\
    );
\cpu_wdata[25]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(25),
      O => \cpu_wdata[25]_i_1_n_0\
    );
\cpu_wdata[26]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(26),
      O => \cpu_wdata[26]_i_1_n_0\
    );
\cpu_wdata[27]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(27),
      O => \cpu_wdata[27]_i_1_n_0\
    );
\cpu_wdata[28]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(28),
      O => \cpu_wdata[28]_i_1_n_0\
    );
\cpu_wdata[29]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(29),
      O => \cpu_wdata[29]_i_1_n_0\
    );
\cpu_wdata[2]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(2),
      O => \cpu_wdata[2]_i_1_n_0\
    );
\cpu_wdata[30]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(30),
      O => \cpu_wdata[30]_i_1_n_0\
    );
\cpu_wdata[31]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(31),
      O => \cpu_wdata[31]_i_1_n_0\
    );
\cpu_wdata[3]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(3),
      O => \cpu_wdata[3]_i_1_n_0\
    );
\cpu_wdata[4]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(4),
      O => \cpu_wdata[4]_i_1_n_0\
    );
\cpu_wdata[5]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(5),
      O => \cpu_wdata[5]_i_1_n_0\
    );
\cpu_wdata[6]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(6),
      O => \cpu_wdata[6]_i_1_n_0\
    );
\cpu_wdata[7]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(7),
      O => \cpu_wdata[7]_i_1_n_0\
    );
\cpu_wdata[8]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(8),
      O => \cpu_wdata[8]_i_1_n_0\
    );
\cpu_wdata[9]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80000000"
    )
        port map (
      I0 => s00_axi_awvalid,
      I1 => s00_axi_wvalid,
      I2 => \^s_axi_wready\,
      I3 => \^s_axi_awready\,
      I4 => s00_axi_wdata(9),
      O => \cpu_wdata[9]_i_1_n_0\
    );
\cpu_wdata_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[0]_i_1_n_0\,
      Q => cpu_wdata(0),
      R => p_0_in
    );
\cpu_wdata_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[10]_i_1_n_0\,
      Q => cpu_wdata(10),
      R => p_0_in
    );
\cpu_wdata_reg[11]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[11]_i_1_n_0\,
      Q => cpu_wdata(11),
      R => p_0_in
    );
\cpu_wdata_reg[12]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[12]_i_1_n_0\,
      Q => cpu_wdata(12),
      R => p_0_in
    );
\cpu_wdata_reg[13]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[13]_i_1_n_0\,
      Q => cpu_wdata(13),
      R => p_0_in
    );
\cpu_wdata_reg[14]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[14]_i_1_n_0\,
      Q => cpu_wdata(14),
      R => p_0_in
    );
\cpu_wdata_reg[15]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[15]_i_1_n_0\,
      Q => cpu_wdata(15),
      R => p_0_in
    );
\cpu_wdata_reg[16]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[16]_i_1_n_0\,
      Q => cpu_wdata(16),
      R => p_0_in
    );
\cpu_wdata_reg[17]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[17]_i_1_n_0\,
      Q => cpu_wdata(17),
      R => p_0_in
    );
\cpu_wdata_reg[18]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[18]_i_1_n_0\,
      Q => cpu_wdata(18),
      R => p_0_in
    );
\cpu_wdata_reg[19]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[19]_i_1_n_0\,
      Q => cpu_wdata(19),
      R => p_0_in
    );
\cpu_wdata_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[1]_i_1_n_0\,
      Q => cpu_wdata(1),
      R => p_0_in
    );
\cpu_wdata_reg[20]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[20]_i_1_n_0\,
      Q => cpu_wdata(20),
      R => p_0_in
    );
\cpu_wdata_reg[21]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[21]_i_1_n_0\,
      Q => cpu_wdata(21),
      R => p_0_in
    );
\cpu_wdata_reg[22]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[22]_i_1_n_0\,
      Q => cpu_wdata(22),
      R => p_0_in
    );
\cpu_wdata_reg[23]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[23]_i_1_n_0\,
      Q => cpu_wdata(23),
      R => p_0_in
    );
\cpu_wdata_reg[24]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[24]_i_1_n_0\,
      Q => cpu_wdata(24),
      R => p_0_in
    );
\cpu_wdata_reg[25]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[25]_i_1_n_0\,
      Q => cpu_wdata(25),
      R => p_0_in
    );
\cpu_wdata_reg[26]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[26]_i_1_n_0\,
      Q => cpu_wdata(26),
      R => p_0_in
    );
\cpu_wdata_reg[27]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[27]_i_1_n_0\,
      Q => cpu_wdata(27),
      R => p_0_in
    );
\cpu_wdata_reg[28]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[28]_i_1_n_0\,
      Q => cpu_wdata(28),
      R => p_0_in
    );
\cpu_wdata_reg[29]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[29]_i_1_n_0\,
      Q => cpu_wdata(29),
      R => p_0_in
    );
\cpu_wdata_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[2]_i_1_n_0\,
      Q => cpu_wdata(2),
      R => p_0_in
    );
\cpu_wdata_reg[30]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[30]_i_1_n_0\,
      Q => cpu_wdata(30),
      R => p_0_in
    );
\cpu_wdata_reg[31]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[31]_i_1_n_0\,
      Q => cpu_wdata(31),
      R => p_0_in
    );
\cpu_wdata_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[3]_i_1_n_0\,
      Q => cpu_wdata(3),
      R => p_0_in
    );
\cpu_wdata_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[4]_i_1_n_0\,
      Q => cpu_wdata(4),
      R => p_0_in
    );
\cpu_wdata_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[5]_i_1_n_0\,
      Q => cpu_wdata(5),
      R => p_0_in
    );
\cpu_wdata_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[6]_i_1_n_0\,
      Q => cpu_wdata(6),
      R => p_0_in
    );
\cpu_wdata_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[7]_i_1_n_0\,
      Q => cpu_wdata(7),
      R => p_0_in
    );
\cpu_wdata_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[8]_i_1_n_0\,
      Q => cpu_wdata(8),
      R => p_0_in
    );
\cpu_wdata_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => \cpu_wdata[9]_i_1_n_0\,
      Q => cpu_wdata(9),
      R => p_0_in
    );
cpu_wr_i_1: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => s00_axi_aresetn,
      O => p_0_in
    );
cpu_wr_i_2: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8000"
    )
        port map (
      I0 => \^s_axi_awready\,
      I1 => \^s_axi_wready\,
      I2 => s00_axi_wvalid,
      I3 => s00_axi_awvalid,
      O => slv_reg_wren
    );
cpu_wr_reg: unisim.vcomponents.FDRE
     port map (
      C => s00_axi_aclk,
      CE => '1',
      D => slv_reg_wren,
      Q => cpu_wr,
      R => p_0_in
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity ps1_axi_cpuint_0_0_axi_cpuint_v1_0 is
  port (
    S_AXI_WREADY : out STD_LOGIC;
    S_AXI_AWREADY : out STD_LOGIC;
    S_AXI_ARREADY : out STD_LOGIC;
    cpu_addr : out STD_LOGIC_VECTOR ( 17 downto 0 );
    cpu_wr : out STD_LOGIC;
    cpu_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s00_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    cpu_rd : out STD_LOGIC;
    s00_axi_bvalid : out STD_LOGIC;
    s00_axi_rvalid : out STD_LOGIC;
    s00_axi_awvalid : in STD_LOGIC;
    s00_axi_wvalid : in STD_LOGIC;
    s00_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s00_axi_aresetn : in STD_LOGIC;
    s00_axi_arvalid : in STD_LOGIC;
    s00_axi_araddr : in STD_LOGIC_VECTOR ( 17 downto 0 );
    s00_axi_aclk : in STD_LOGIC;
    s00_axi_awaddr : in STD_LOGIC_VECTOR ( 17 downto 0 );
    cpu_rdata_dv : in STD_LOGIC;
    cpu_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s00_axi_bready : in STD_LOGIC;
    s00_axi_rready : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of ps1_axi_cpuint_0_0_axi_cpuint_v1_0 : entity is "axi_cpuint_v1_0";
end ps1_axi_cpuint_0_0_axi_cpuint_v1_0;

architecture STRUCTURE of ps1_axi_cpuint_0_0_axi_cpuint_v1_0 is
begin
axi_cpuint_v1_0_S00_AXI_inst: entity work.ps1_axi_cpuint_0_0_axi_cpuint_v1_0_S00_AXI
     port map (
      S_AXI_ARREADY => S_AXI_ARREADY,
      S_AXI_AWREADY => S_AXI_AWREADY,
      S_AXI_WREADY => S_AXI_WREADY,
      cpu_addr(17 downto 0) => cpu_addr(17 downto 0),
      cpu_rd => cpu_rd,
      cpu_rdata(31 downto 0) => cpu_rdata(31 downto 0),
      cpu_rdata_dv => cpu_rdata_dv,
      cpu_wdata(31 downto 0) => cpu_wdata(31 downto 0),
      cpu_wr => cpu_wr,
      s00_axi_aclk => s00_axi_aclk,
      s00_axi_araddr(17 downto 0) => s00_axi_araddr(17 downto 0),
      s00_axi_aresetn => s00_axi_aresetn,
      s00_axi_arvalid => s00_axi_arvalid,
      s00_axi_awaddr(17 downto 0) => s00_axi_awaddr(17 downto 0),
      s00_axi_awvalid => s00_axi_awvalid,
      s00_axi_bready => s00_axi_bready,
      s00_axi_bvalid => s00_axi_bvalid,
      s00_axi_rdata(31 downto 0) => s00_axi_rdata(31 downto 0),
      s00_axi_rready => s00_axi_rready,
      s00_axi_rvalid => s00_axi_rvalid,
      s00_axi_wdata(31 downto 0) => s00_axi_wdata(31 downto 0),
      s00_axi_wvalid => s00_axi_wvalid
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity ps1_axi_cpuint_0_0 is
  port (
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
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of ps1_axi_cpuint_0_0 : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of ps1_axi_cpuint_0_0 : entity is "ps1_axi_cpuint_0_0,axi_cpuint_v1_0,{}";
  attribute downgradeipidentifiedwarnings : string;
  attribute downgradeipidentifiedwarnings of ps1_axi_cpuint_0_0 : entity is "yes";
  attribute x_core_info : string;
  attribute x_core_info of ps1_axi_cpuint_0_0 : entity is "axi_cpuint_v1_0,Vivado 2022.1.2";
end ps1_axi_cpuint_0_0;

architecture STRUCTURE of ps1_axi_cpuint_0_0 is
  signal \<const0>\ : STD_LOGIC;
  signal \^s00_axi_aclk\ : STD_LOGIC;
  attribute x_interface_info : string;
  attribute x_interface_info of s00_axi_aclk : signal is "xilinx.com:signal:clock:1.0 S00_AXI_CLK CLK";
  attribute x_interface_parameter : string;
  attribute x_interface_parameter of s00_axi_aclk : signal is "XIL_INTERFACENAME S00_AXI_CLK, ASSOCIATED_BUSIF S00_AXI, ASSOCIATED_RESET s00_axi_aresetn, FREQ_HZ 96968727, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN ps1_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0";
  attribute x_interface_info of s00_axi_aresetn : signal is "xilinx.com:signal:reset:1.0 S00_AXI_RST RST";
  attribute x_interface_parameter of s00_axi_aresetn : signal is "XIL_INTERFACENAME S00_AXI_RST, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  attribute x_interface_info of s00_axi_arready : signal is "xilinx.com:interface:aximm:1.0 S00_AXI ARREADY";
  attribute x_interface_info of s00_axi_arvalid : signal is "xilinx.com:interface:aximm:1.0 S00_AXI ARVALID";
  attribute x_interface_info of s00_axi_awready : signal is "xilinx.com:interface:aximm:1.0 S00_AXI AWREADY";
  attribute x_interface_info of s00_axi_awvalid : signal is "xilinx.com:interface:aximm:1.0 S00_AXI AWVALID";
  attribute x_interface_info of s00_axi_bready : signal is "xilinx.com:interface:aximm:1.0 S00_AXI BREADY";
  attribute x_interface_info of s00_axi_bvalid : signal is "xilinx.com:interface:aximm:1.0 S00_AXI BVALID";
  attribute x_interface_info of s00_axi_rready : signal is "xilinx.com:interface:aximm:1.0 S00_AXI RREADY";
  attribute x_interface_info of s00_axi_rvalid : signal is "xilinx.com:interface:aximm:1.0 S00_AXI RVALID";
  attribute x_interface_info of s00_axi_wready : signal is "xilinx.com:interface:aximm:1.0 S00_AXI WREADY";
  attribute x_interface_info of s00_axi_wvalid : signal is "xilinx.com:interface:aximm:1.0 S00_AXI WVALID";
  attribute x_interface_info of s00_axi_araddr : signal is "xilinx.com:interface:aximm:1.0 S00_AXI ARADDR";
  attribute x_interface_info of s00_axi_arprot : signal is "xilinx.com:interface:aximm:1.0 S00_AXI ARPROT";
  attribute x_interface_info of s00_axi_awaddr : signal is "xilinx.com:interface:aximm:1.0 S00_AXI AWADDR";
  attribute x_interface_parameter of s00_axi_awaddr : signal is "XIL_INTERFACENAME S00_AXI, WIZ_DATA_WIDTH 32, WIZ_NUM_REG 4, SUPPORTS_NARROW_BURST 0, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 96968727, ID_WIDTH 0, ADDR_WIDTH 18, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 1, PHASE 0.0, CLK_DOMAIN ps1_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0";
  attribute x_interface_info of s00_axi_awprot : signal is "xilinx.com:interface:aximm:1.0 S00_AXI AWPROT";
  attribute x_interface_info of s00_axi_bresp : signal is "xilinx.com:interface:aximm:1.0 S00_AXI BRESP";
  attribute x_interface_info of s00_axi_rdata : signal is "xilinx.com:interface:aximm:1.0 S00_AXI RDATA";
  attribute x_interface_info of s00_axi_rresp : signal is "xilinx.com:interface:aximm:1.0 S00_AXI RRESP";
  attribute x_interface_info of s00_axi_wdata : signal is "xilinx.com:interface:aximm:1.0 S00_AXI WDATA";
  attribute x_interface_info of s00_axi_wstrb : signal is "xilinx.com:interface:aximm:1.0 S00_AXI WSTRB";
begin
  \^s00_axi_aclk\ <= s00_axi_aclk;
  clk_cpu <= \^s00_axi_aclk\;
  s00_axi_bresp(1) <= \<const0>\;
  s00_axi_bresp(0) <= \<const0>\;
  s00_axi_rresp(1) <= \<const0>\;
  s00_axi_rresp(0) <= \<const0>\;
GND: unisim.vcomponents.GND
     port map (
      G => \<const0>\
    );
U0: entity work.ps1_axi_cpuint_0_0_axi_cpuint_v1_0
     port map (
      S_AXI_ARREADY => s00_axi_arready,
      S_AXI_AWREADY => s00_axi_awready,
      S_AXI_WREADY => s00_axi_wready,
      cpu_addr(17 downto 0) => cpu_addr(17 downto 0),
      cpu_rd => cpu_rd,
      cpu_rdata(31 downto 0) => cpu_rdata(31 downto 0),
      cpu_rdata_dv => cpu_rdata_dv,
      cpu_wdata(31 downto 0) => cpu_wdata(31 downto 0),
      cpu_wr => cpu_wr,
      s00_axi_aclk => \^s00_axi_aclk\,
      s00_axi_araddr(17 downto 0) => s00_axi_araddr(17 downto 0),
      s00_axi_aresetn => s00_axi_aresetn,
      s00_axi_arvalid => s00_axi_arvalid,
      s00_axi_awaddr(17 downto 0) => s00_axi_awaddr(17 downto 0),
      s00_axi_awvalid => s00_axi_awvalid,
      s00_axi_bready => s00_axi_bready,
      s00_axi_bvalid => s00_axi_bvalid,
      s00_axi_rdata(31 downto 0) => s00_axi_rdata(31 downto 0),
      s00_axi_rready => s00_axi_rready,
      s00_axi_rvalid => s00_axi_rvalid,
      s00_axi_wdata(31 downto 0) => s00_axi_wdata(31 downto 0),
      s00_axi_wvalid => s00_axi_wvalid
    );
end STRUCTURE;
