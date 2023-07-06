#----------------------------------------------------------------------
# Title      : Constraints for JESD204C
# Project    : jesd204_v7_0
#----------------------------------------------------------------------
# File       : jesd204c_0_block.xdc
# Author     : Xilinx
#----------------------------------------------------------------------
# Description: Xilinx Constraint file for JESD204 core
#---------------------------------------------------------------------
# (c) Copyright 2004-2014 Xilinx, Inc. All rights reserved.
#
# This file contains confidential and proprietary information
# of Xilinx, Inc. and is protected under U.S. and
# international copyright and other intellectual property
# laws.
#
# DISCLAIMER
# This disclaimer is not a license and does not grant any
# rights to the materials distributed herewith. Except as
# otherwise provided in a valid license issued to you by
# Xilinx, and to the maximum extent permitted by applicable
# law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
# WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
# AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
# BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
# INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
# (2) Xilinx shall not be liable (whether in contract or tort,
# including negligence, or under any other theory of
# liability) for any loss or damage of any kind or nature
# related to, arising under or in connection with these
# materials, including for any direct, or any indirect,
# special, incidental, or consequential loss or damage
# (including loss of data, profits, goodwill, or any type of
# loss or damage suffered as a result of any action brought
# by a third party) even if such damage or loss was
# reasonably foreseeable or Xilinx had been advised of the
# possibility of the same.
#
# CRITICAL APPLICATIONS
# Xilinx products are not designed or intended to be fail-
# safe, or for use in any application requiring fail-safe
# performance, such as life-support or safety devices or
# systems, Class III medical devices, nuclear facilities,
# applications related to the deployment of airbags, or any
# other applications that could lead to death, personal
# injury, or severe property or environmental damage
# (individually and collectively, "Critical
# Applications"). Customer assumes the sole risk and
# liability of any use of Xilinx products in Critical
# Applications, subject only to applicable laws and
# regulations governing limitations on product liability.
#
# THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
# PART OF THIS FILE AT ALL TIMES.
#

#------------------------------------------
# TIMING CONSTRAINTS
#------------------------------------------



#Wipe the control registers.
set_false_path -from [get_cells -hier -filter {name =~ *jesd204c_regif_*_i/ctrl_* && IS_SEQUENTIAL}]

#Status registers
#IRQ clear signal
set_false_path -from [get_cells -hier -filter {name =~ *sync_ctrl_irq_clr_c/src_state_reg*                         && IS_SEQUENTIAL}] -to [get_cells -hier -filter {name =~ */sync_ctrl_irq_clr_c/sync_pulse_set_sync/cdc_i* && IS_SEQUENTIAL}]
set_false_path -from [get_cells -hier -filter {name =~ *sync_ctrl_irq_clr_c/dest_state_reg*                        && IS_SEQUENTIAL}] -to [get_cells -hier -filter {name =~ */sync_ctrl_irq_clr_c/sync_pulse_ack_sync/cdc_i* && IS_SEQUENTIAL}]

set_false_path -from [get_cells -hier -filter {name =~ *x_32_c/irq_ctrl_c/irq_reg*                                 && IS_SEQUENTIAL}] -to [get_cells -hier -filter {name =~ */axi_register_if_i/axi_rdata_reg* && IS_SEQUENTIAL}]
set_false_path -from [get_cells -hier -filter {name =~ *x_32_c/irq_ctrl_c/g_irq_bit[*].irq_bit_out_reg*            && IS_SEQUENTIAL}] -to [get_cells -hier -filter {name =~ */axi_register_if_i/axi_rdata_reg* && IS_SEQUENTIAL}]

set_false_path -from [get_cells -hier -filter {name =~ *sync_core_rst/xpm_cdc_async_rst_inst*                      && IS_SEQUENTIAL}] -to [get_cells -hier -filter {name =~ */axi_register_if_i/axi_rdata_reg* && IS_SEQUENTIAL}]
set_false_path -from [get_cells -hier -filter {name =~ *sync_gt_resetdone/xpm_cdc_async_rst_inst*                  && IS_SEQUENTIAL}] -to [get_cells -hier -filter {name =~ */axi_register_if_i/axi_rdata_reg* && IS_SEQUENTIAL}]

#Sysref error clear signals
set_false_path -from [get_cells -hier -filter {name =~ *sync_stat_err_clr_c/src_state_reg*                         && IS_SEQUENTIAL}] -to [get_cells -hier -filter {name =~ *sync_stat_err_clr_c/sync_pulse_set_sync/cdc_i* && IS_SEQUENTIAL}]
set_false_path -from [get_cells -hier -filter {name =~ *sync_stat_err_clr_c/dest_state_reg*                        && IS_SEQUENTIAL}] -to [get_cells -hier -filter {name =~ *sync_stat_err_clr_c/sync_pulse_ack_sync/cdc_i* && IS_SEQUENTIAL}]
#TX only false paths
set_false_path -from [get_cells -hier -filter {name =~ *jesd204c_regif_lane_i/ctrl_* && IS_SEQUENTIAL}]

set_false_path -from [get_cells -hier -filter {name =~ *tx_32_c/sync_combine_d1*                                   && IS_SEQUENTIAL}] -to [get_cells -hier -filter {name =~ */axi_register_if_i/axi_rdata_reg* && IS_SEQUENTIAL}]
set_false_path -from [get_cells -hier -filter {name =~ *tx_32_c/i_tx_counters_32/sysref_captured_reg*              && IS_SEQUENTIAL}] -to [get_cells -hier -filter {name =~ */axi_register_if_i/axi_rdata_reg* && IS_SEQUENTIAL}]
set_false_path -from [get_cells -hier -filter {name =~ *tx_32_c/stat_sysr_err_reg*                                 && IS_SEQUENTIAL}] -to [get_cells -hier -filter {name =~ */axi_register_if_i/axi_rdata_reg* && IS_SEQUENTIAL}]

########################
# Waivers
########################
#
# CDC-1
#
create_waiver -internal -scope -quiet -user JESD204C -type CDC -id CDC-1 \
  -tags 1025425                             \
  -description {Safe control registers crossing clock domains} \
  -from [get_pins -filter {REF_PIN_NAME=~C} -of [get_cells -hier -filter {name=~*_jesd204c_regif_*_i/ctrl_*}] ] \
  -to   [get_pins -filter {REF_PIN_NAME=~*} -of [get_cells -hier -filter {name=~*jesd204c_0_top_c/*}] ]

create_waiver -internal -scope -quiet -user JESD204C -type CDC -id CDC-1 \
  -tags 1042755                             \
  -description {Safe control registers crossing clock domains. These are static GT control signals} \
  -from [get_pins -filter {REF_PIN_NAME=~C} -of [get_cells -hier -filter {name=~*_jesd204c_regif_*_i/ctrl_*}] ] \
  -to   [get_pins -filter {REF_PIN_NAME=~*} -of [get_cells -hier -filter {name=~*inst/gt*}] ]


#
# CDC-2
#
create_waiver -internal -scope -quiet -user JESD204C -type CDC -id CDC-2 \
  -tags 1025425                             \
  -description {Safe control registers. Paths are incorrectly detected as  1-bit synchronized with missing ASYNC_REG property} \
  -from [get_pins -filter {REF_PIN_NAME=~C} -of [get_cells -hier -filter {name=~*_jesd204c_regif_*_i/ctrl_*}] ] \
  -to   [get_pins -filter {REF_PIN_NAME=~*} -of [get_cells -hier -filter {name=~*jesd204c_0_top_c/*}] ]

#
# CDC-4
#
create_waiver -internal -scope -quiet -user JESD204C -type CDC -id CDC-4 \
  -tags 1042755                             \
  -description {Safe multi-bit control registers crossing clock domains. These are static GT control signals} \
  -from [get_pins -filter {REF_PIN_NAME=~C} -of [get_cells -hier -filter {name=~*_jesd204c_regif_*_i/ctrl_*}] ] \
  -to   [get_pins -filter {REF_PIN_NAME=~*} -of [get_cells -hier -filter {name=~*inst/gt*}] ]

#
# CDC-10
#
create_waiver -internal -scope -quiet -user JESD204C -type CDC -id CDC-10 \
  -tags 1025425                              \
  -description {Safe control registers. Paths are incorrectly detected as comb logic before a synchroniser} \
  -from [get_pins -filter {REF_PIN_NAME=~C} -of [get_cells -hier -filter {name=~*_jesd204c_regif_*_i/ctrl_*}] ] \
  -to   [get_pins -filter {REF_PIN_NAME=~*} -of [get_cells -hier -filter {name=~*jesd204c_0_top_c/*}] ]

#
# CDC-11
#
create_waiver -internal -scope -quiet -user JESD204C -type CDC -id CDC-11 \
  -tags 1025425                              \
  -description {Safe control registers. Fan-out from launch flop to destination clock detected} \
  -from [get_pins -filter {REF_PIN_NAME=~C} -of [get_cells -hier -filter {name=~*_jesd204c_regif_*_i/ctrl_*}] ] \
  -to   [get_pins -filter {REF_PIN_NAME=~*} -of [get_cells -hier -filter {name=~*jesd204c_0_top_c/*}] ]

#
# CDC-13
#
create_waiver -internal -scope -quiet -user JESD204C -type CDC -id CDC-13 \
  -tags 1025425                              \
  -description {Safe control registers crossing clock domains} \
  -from [get_pins -filter {REF_PIN_NAME=~C} -of [get_cells -hier -filter {name=~*_jesd204c_regif_*_i/ctrl_*}] ] \
  -to   [get_pins -filter {REF_PIN_NAME=~*} -of [get_cells -hier -filter {name=~*jesd204c_0_top_c/*}] ]
