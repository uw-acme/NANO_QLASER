////////////////////////////////////////////////////////////////////////////////
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /    Vendor: Xilinx 
// \   \   \/     Filename : jesd204c_0_sync_pulse_block.v
//  \   \         
//  /   /         
// /___/   /\     
// \   \  /  \ 
//  \___\/\___\ 
//
//
// Description: Used to pass a pulse between two clock domains
//                     
//
//
// Module jesd204c_0_sync_pulse_block
// 
// 
// 
// (c) Copyright 2010-2016 Xilinx, Inc. All rights reserved.
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

//------------------------------------------------------------------------------

`timescale 1ps / 1ps

//(* dont_touch = "yes" *)
module jesd204c_0_sync_pulse_block (
  input      src_clk,
  input      src_rst,
  input      src_pulse,
  input      dest_clk,
  input      dest_rst,
  output reg dest_pulse
);


reg  src_state;
wire src_set;
wire src_ack;

reg  dest_state;
wire dest_set;
wire dest_ack;

always @(posedge src_clk)
begin
  if(src_rst)
  begin
   src_state <= 0;
  end
  else
  begin
    if(!src_state)
    begin
      if(src_pulse)
      begin
        src_state <= 1'b1;
      end
    end
    else
    begin
      if(src_ack)
      begin
        src_state <= 1'b0;
      end
    end
  end
end

assign src_set = src_state;

//sync ack to src clk
jesd204c_0_sync_block #(
  .TYPE_RST_NOT_DATA (1'b0     )
) sync_pulse_ack_sync (
  .clk               (src_clk  ),
  .data_in           (dest_ack ),
  .data_out          (src_ack  )
);



//sync set to dest clk
jesd204c_0_sync_block #(
  .TYPE_RST_NOT_DATA (1'b0     )
) sync_pulse_set_sync (
  .clk               (dest_clk ),
  .data_in           (src_set  ),
  .data_out          (dest_set )
);

always @(posedge dest_clk)
begin
  if(dest_rst)
  begin
   dest_state <= 1'b0;
   dest_pulse <= 1'b0;
  end
  else
  begin
    if(!dest_state)
    begin
      if(dest_set)
      begin
        dest_state <= 1'b1;
        dest_pulse <= 1'b1;
      end
    end
    else
    begin
      if(!dest_set)
      begin
        dest_state <= 1'b0;
      end
      dest_pulse <= 1'b0;
    end
  end
end

assign dest_ack = dest_state;

endmodule
