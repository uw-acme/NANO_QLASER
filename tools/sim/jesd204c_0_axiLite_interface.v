//-----------------------------------------------------------------------------
// Title      : axiLite_interface
// Project    : NA
//-----------------------------------------------------------------------------
// File       : axiLite_interface.v
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

//-----------------------------------------------------------------------------
// AMBA AXI and ACE Protocol Specification
// ARM IHI 0022D (ID102711)
// AMBA SPEC
// Note section's:
//                A3.3 Relationships between channels
//                B1   AMBA AXI4-Lite
//-----------------------------------------------------------------------------
module jesd204c_0_jesd204c_regif_axi #(
 
   parameter integer                   C_S_AXI_ADDR_WIDTH   = 12,
   parameter integer                   BANK_DECODE_HIGH_BIT = 11,
   parameter integer                   BANK_DECODE_HIGH_LOW = 10,
   parameter integer                   C_S_TIMEOUT_WIDTH = 12
     )
(
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
   input                                  s_axi_rready,
   
   // Strobes & data bank connections
   output                                 strb_b0_slv_wren,
   output  reg                            strb_b0_slv_rden,
   input                                  strb_b0_slv_wr_done,
   input                                  strb_b0_slv_rd_done,
   input        [31:0]                    strb_b0_slv_rdata,

   output                                 strb_b1_slv_wren,
   output  reg                            strb_b1_slv_rden,
   input                                  strb_b1_slv_wr_done,
   input                                  strb_b1_slv_rd_done,
   input        [31:0]                    strb_b1_slv_rdata,

   input                                  timeout_enable_in,
   input       [C_S_TIMEOUT_WIDTH-1:0]    timeout_value_in,

   output      [31:0]                     slv_wdata,
   output reg  [BANK_DECODE_HIGH_LOW-1:2] slv_addr,
   output reg                             slv_reg_rden

);

   localparam                             STRB_B0_BANK_SEL     = 'd0;
   localparam                             STRB_B1_BANK_SEL     = 'd1;
   localparam                             BANK_DECODE          = BANK_DECODE_HIGH_BIT - BANK_DECODE_HIGH_LOW;

   // AXI4LITE signals
   reg                                    axi_awready = 0;
   reg                                    axi_wready  = 0;
   reg         [1:0]                      axi_bresp   = 0;
   reg                                    axi_bvalid  = 0;
   reg                                    axi_arready = 0;
   reg         [31:0]                     axi_rdata   = 0;
   reg         [1:0]                      axi_rresp   = 0;
   reg                                    axi_rvalid  = 0;

   reg                                    valid_waddr = 0;

   reg                                    strb_b0_axi_map_wready;
   wire                                   strb_b0_axi_map_selected;
   reg                                    strb_b1_axi_map_wready;
   wire                                   strb_b1_axi_map_selected;
    
   wire                                   or_all_mapped_wready;
   
   reg         [BANK_DECODE:0]            slv_rd_addr = 0;
   reg                                    slv_reg_done; // correct read done indicator, muxed using read address
   
   // Timeout signals
   wire                                   load_timeout_timer;
   wire                                   clear_timeout_timer;
   wire                                   timeout;
   reg         [C_S_TIMEOUT_WIDTH:0]      timeout_timer_count;
      
   // Flags to stretch access response
   reg                                    read_in_progress;
   reg                                    write_in_progress;
         
   // I/O Connections assignments

   assign s_axi_awready                = axi_awready;                              
   assign s_axi_wready                 = axi_wready;                               
   assign s_axi_bresp                  = axi_bresp;                                
   assign s_axi_bvalid                 = axi_bvalid;                               
   assign s_axi_arready                = axi_arready;                              
   assign s_axi_rdata                  = axi_rdata;                                
   assign s_axi_rresp                  = axi_rresp;                                
   assign s_axi_rvalid                 = axi_rvalid;
   
   assign slv_wdata                    = s_axi_wdata;
   
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------         
// WRITE LOGIC
//---------------------------------------------------------------------------         
//---------------------------------------------------------------------------         
   // Due the potential transaction stretching capabilites of the banks, 
   // we need to keep a track of an ongoing write transaction to prevent
   // reads starting
   always @( posedge s_axi_aclk )
   begin
      if (~s_axi_aresetn) begin
         write_in_progress                   <= 1'b0;
      end 
      else begin    
         if ( (s_axi_bready && s_axi_bvalid) | 
               timeout
             ) begin
           // End of a valid write phase, i.e. the complete axi transaction
           // Note this may have been triggered by a timeout
           write_in_progress                <= 1'b0;
         end
         else begin
           if ((axi_awready && s_axi_awvalid)|(axi_wready && s_axi_wvalid)) begin
             // indicates that the slave has acceped the valid read address
             write_in_progress              <= 1'b1;
           end
         end
      end 
   end       
   
   // The axi spec states there is no relationship between the different interfaces.
   // this means the data can complete before the address or vice versa.  In either case we have to think
   // of the overall transaction as being complete if a full address and data set has completed and at this point
   // the resp should be output..  If a write address transaction occurs and it is not for this dut then 
   // it is not only ignored but cancels any pending write_data transaction..

   // Implement axi_awready generation
   // do not allow a new address to be accepted if a current transaction is ongoing
   // if a write and read are active at the same time then prioritise the read (as per axi-ipif)
   always @( posedge s_axi_aclk )
   begin
      if (~s_axi_aresetn) begin
         axi_awready                   <= 1'b0;
      end 
      else begin
         // 
         if ((~s_axi_arvalid) & (~read_in_progress)) begin
            if (~axi_awready && s_axi_awvalid && ~valid_waddr) begin
               axi_awready             <= 1'b1;
            end
            else begin
               axi_awready             <= 1'b0;
            end
         end
      end 
   end          

   // the address phase is valid until both the address and data are valid but 
   // they can become valid at any point
   // Note that on a timeout, read_in_progress should be low on a write, but arvalid
   // may now be high. Therefore we need to clear this flag on the timeout condition
   // which will cause axi_bvalid to be set
   always @( posedge s_axi_aclk )
   begin
      if (~s_axi_aresetn) begin
         valid_waddr                   <= 1'b0;
      end 
      else begin
         if ((~s_axi_arvalid) & (~read_in_progress) | timeout) begin
            if ((s_axi_bready && axi_bvalid) | timeout) begin
               valid_waddr             <= 1'b0;
            end
            else 
        if (~axi_awready && s_axi_awvalid) begin
                valid_waddr          <= 1'b1;
                end
         end
      end 
   end          

   // Implement slv_addr latching
   // This process is used to latch the address early i.e when awvalid is asserted
   // should then hold until it is used (i.e valid_waddr is low)
   // do we need to consider the case where the read and write addresses are valid together?
   // probably should as there is nothing to stop this happening - in  that case hold off the write
   // to allow the read to continue
   always @( posedge s_axi_aclk )
   begin
      if (~s_axi_aresetn) begin
         slv_addr                    <= {(BANK_DECODE_HIGH_LOW-2){1'b0}};
         slv_rd_addr                 <= 'd0;
      end 
      else begin    
         // only allow a write to take the address bus if no read is ongoing
         if (~valid_waddr) begin
            if (s_axi_arvalid & (~read_in_progress)) begin
               // Read address latching
               slv_addr                <= s_axi_araddr[BANK_DECODE_HIGH_LOW-1:2];
               slv_rd_addr             <= s_axi_araddr[BANK_DECODE_HIGH_BIT:BANK_DECODE_HIGH_LOW];
            end
            else if (~axi_awready && s_axi_awvalid) begin
               // write address latching 
               slv_addr                <= s_axi_awaddr[BANK_DECODE_HIGH_LOW-1:2];
               slv_rd_addr             <= s_axi_awaddr[BANK_DECODE_HIGH_BIT:BANK_DECODE_HIGH_LOW];
            end
         end
      end 
   end       

   // Implement axi_wready generation
   // axi_wready is asserted for one s_axi_aclk clock cycle when both
   // s_axi_awvalid and s_axi_wvalid are asserted. axi_wready is 
   // de-asserted when reset is low.  
   // may be acceptable to hold the data transaction until we see the address - avoids the need to 
   // flop the data
   
   assign strb_b0_axi_map_selected = slv_rd_addr == STRB_B0_BANK_SEL;

   always @( posedge s_axi_aclk )
     begin
        if (~s_axi_aresetn) begin
           strb_b0_axi_map_wready                <= 1'b0;
        end 
        else begin    
           if (~s_axi_arvalid) begin
              if ((~strb_b0_axi_map_wready) && s_axi_wvalid && valid_waddr  && strb_b0_axi_map_selected) begin
                 strb_b0_axi_map_wready          <= 1'b1;
              end
              else begin
                 strb_b0_axi_map_wready          <= 1'b0;
              end
           end
        end 
     end

  
   assign strb_b1_axi_map_selected = slv_rd_addr == STRB_B1_BANK_SEL;

   always @( posedge s_axi_aclk )
     begin
        if (~s_axi_aresetn) begin
           strb_b1_axi_map_wready                <= 1'b0;
        end 
        else begin    
           if (~s_axi_arvalid) begin
              if ((~strb_b1_axi_map_wready) && s_axi_wvalid && valid_waddr  && strb_b1_axi_map_selected) begin
                 strb_b1_axi_map_wready          <= 1'b1;
              end
              else begin
                 strb_b1_axi_map_wready          <= 1'b0;
              end
           end
        end 
     end

  
   // We have this signal to sweep up out of band memory writes
   reg axi_wr_access;
   always @( posedge s_axi_aclk )
     begin
        if (~s_axi_aresetn) begin
           axi_wr_access                <= 1'b0;
        end 
        else begin    
           if (~s_axi_arvalid) begin
              if ((~axi_wr_access) && s_axi_wvalid && valid_waddr) begin
                 axi_wr_access          <= 1'b1;
              end
              else begin
                 axi_wr_access          <= 1'b0;
              end
           end
        end 
     end
   
   // create an OR of all the mapped ready's so we can see if there was a write request 
   // to a bank that did not exist.
   assign or_all_mapped_wready = strb_b0_axi_map_wready || strb_b1_axi_map_wready;

   always @(*)
   begin
      if (axi_wr_access) begin
         axi_wready                    = 1'b1;
      end
      else begin
         axi_wready                    = 1'b0;
      end
   end

   // Implement memory mapped register select and write logic generation
   // The write data is accepted and written to memory mapped registers when
   // axi_awready, s_axi_wvalid, axi_wready and s_axi_wvalid are asserted. Write strobes are used to
   // select byte enables of slave registers while writing.
   // These registers are cleared when reset (active low) is applied.
   // Slave register write enable is asserted when valid address and data are available
   // and the slave is ready to accept the write address and write data.
   assign strb_b0_slv_wren               = strb_b0_axi_map_wready         && s_axi_wvalid;
   assign strb_b1_slv_wren               = strb_b1_axi_map_wready         && s_axi_wvalid;
   
   // Implement write response logic generation
   // The write response and response valid signals are asserted by the slave 
   // when axi_wready, s_axi_wvalid, axi_wready and s_axi_wvalid are asserted.  
   // This marks the acceptance of address and indicates the status of 
   // write transaction. 
   wire bank_write_done;
   
   // If or_all_mapped_wready it indicates an invalid address was written to. We complete as it does
   // no harm, however, possible report a bad address
   assign bank_write_done = strb_b0_slv_wr_done | strb_b1_slv_wr_done;

   always @( posedge s_axi_aclk ) begin
      if (~s_axi_aresetn) begin
         axi_bvalid                    <= 1'b0;
         axi_bresp                     <= 2'b0;
         end 
      else begin    
         // The timeout is gated with s_axi_bready to ensure its only set when there is a valid write
         // The timeout is shared by the read and write logic and 
         if ((timeout & write_in_progress) | (~axi_bvalid && bank_write_done) | (axi_wr_access & ((or_all_mapped_wready == 'd0))) ) begin
            axi_bvalid                 <= 1'b1;
            if (~timeout) begin
              axi_bresp                  <= 2'b00; // 'OKAY' response
              end
            else begin
              axi_bresp                  <= 2'b10; // 'SLVERR' response
              end
           end // work error responses in future
         else begin
            //check if bready is asserted while bvalid is high) 
            //(there is a possibility that bready is always asserted high)   
            if (s_axi_bready && axi_bvalid) begin
               axi_bresp               <= 2'b00;
               axi_bvalid              <= 1'b0; 
               end  
            end
         end
      end   

//---------------------------------------------------------------------------         
//---------------------------------------------------------------------------         
// READ LOGIC
//---------------------------------------------------------------------------         
//---------------------------------------------------------------------------         
   // Due the potential transaction stretching capabilites of the banks, 
   // we need to keep a track of an ongoing read transaction to prevent
   // writes starting and detecting a valid end condition. The master can
   // wait for rvalid before it asserts rready so we can not rely on an
   // external indicator
   always @( posedge s_axi_aclk )
   begin
      if (~s_axi_aresetn) begin
         read_in_progress                   <= 1'b0;
      end 
      else begin    
         if ( (s_axi_rready && s_axi_rvalid) | 
               timeout
             ) begin
           // End of a valid read phase, i.e. the complete axi transaction
           // Note this may have been triggered by a timeout
           read_in_progress                <= 1'b0;
         end
         else begin
           if (axi_arready && s_axi_arvalid) begin
             // indicates that the slave has acceped the valid read address
             read_in_progress              <= 1'b1;
           end
         end
      end 
   end       

   // Implement axi_arready generation
   // axi_arready is asserted for one s_axi_aclk clock cycle when
   // s_axi_arvalid is asserted. axi_arready is 
   // de-asserted when reset (active low) is asserted. 
   // The read address is also latched when s_axi_arvalid is 
   // asserted. slv_addr is reset to zero on reset assertion.
   always @( posedge s_axi_aclk )
   begin
      if (~s_axi_aresetn) begin
         axi_arready                   <= 1'b0;
      end 
      else begin    
         // if a read and write happen at the same time then prioritise the read
         // s_axi_arvalid must be low for write_in_progress to be set, so it cannot
         // go high this cycle as s_axi_arvalid is high
         if ((~axi_arready && s_axi_arvalid) & (~read_in_progress) & (~write_in_progress)) begin
            // indicates that the slave has acceped the valid read address
            axi_arready                <= 1'b1;
         end
         else begin
            axi_arready                <= 1'b0;
         end
      end 
   end       

   // Implement axi_arvalid generation
   // axi_rvalid is asserted for one s_axi_aclk clock cycle when both 
   // s_axi_arvalid and axi_arready are asserted. The slave registers 
   // data are available on the axi_rdata bus at this instance. The 
   // assertion of axi_rvalid marks the validity of read data on the 
   // bus and axi_rresp indicates the status of read transaction.axi_rvalid 
   // is deasserted on reset (active low). axi_rresp and axi_rdata are 
   // cleared to zero on reset (active low).  
   always @( posedge s_axi_aclk )
   begin
      if (~s_axi_aresetn) begin
         axi_rvalid                    <= 1'b0;
         axi_rresp                     <= 2'b0;
      end 
      else begin
         // timeout should not be gated with (s_axi_rready) this is illegal in the spec!
         // It is gated with read_in_progress so as not to pulse rvalid on a write timeout.
         // read_in_progress is also reset by the timeout
         //
         // slv_reg_done is a muxed version of read done from the bank. This can simply
         // reflect the input read read request <...>_slv_rden (a register below) or be
         // a pulse that should happen at some point in the future to indicate the 
         // transaction is complete. The returning read_done signals are muxed into slv_reg_done
         //
         // Best case this this a registered signal set when (axi_arready && s_axi_arvalid && ~axi_rvalid)
         // A AXI slave is not allowed to raise rvalid until both arready & arvalid are set (A3.3.1)
         //
         // Worst case this is a DRP access that does not complete and the timout is used to complete
         // the AXI tranaction
         //
         if ((timeout & read_in_progress & (~axi_rvalid) ) | 
             (slv_reg_done & (~axi_rvalid) & read_in_progress)
       ) begin
            // Valid read data is available at the read data bus
            axi_rvalid                 <= 1'b1;
            if (~timeout) begin
              axi_rresp                  <= 2'b00; // 'OKAY' response
              end
            else begin
              axi_rresp                  <= 2'b10; // 'SLVERR' response
              end
         end   
         else if (axi_rvalid && s_axi_rready) begin
            // Read data is accepted by the master, we are done
            axi_rvalid <= 1'b0;
         end                
      end
   end    

   // Implement memory mapped register select and read logic generation
   // Slave register read enable is asserted when valid address is available
   // and the slave is ready to accept the read address.
   // bits [UPPER:LOWER] of the address bus are sampled to ensure that if a 
   // write access starts during the read that the correct data is returned
   always @( posedge s_axi_aclk ) begin
     if (~s_axi_aresetn) begin
       slv_reg_rden  <= 'b0;
       strb_b0_slv_rden               <= 'd0;
       strb_b1_slv_rden               <= 'd0;
       end
     else begin
       if (axi_arready && s_axi_arvalid && ~axi_rvalid) begin
          slv_reg_rden  <= 1'b1;
          strb_b0_slv_rden               <= s_axi_araddr[BANK_DECODE_HIGH_BIT:BANK_DECODE_HIGH_LOW] == 'd0;
          strb_b1_slv_rden               <= s_axi_araddr[BANK_DECODE_HIGH_BIT:BANK_DECODE_HIGH_LOW] == 'd1;
          end
       else begin
         if (slv_reg_done) begin
           slv_reg_rden   <= 1'b0;
           strb_b0_slv_rden               <= 'd0;
           strb_b1_slv_rden               <= 'd0;
           end
         else begin
           slv_reg_rden   <= slv_reg_rden;
           strb_b0_slv_rden               <= strb_b0_slv_rden;
           strb_b1_slv_rden               <= strb_b1_slv_rden;
           end
       end
     end
   end
      
   // Output register or memory read data
   always @( posedge s_axi_aclk )
   begin
      if (~s_axi_aresetn) begin
         axi_rdata                     <= 32'd0;
      end 
      else begin    
         // When there is a valid read address (s_axi_arvalid) with 
         // acceptance of read address by the slave (axi_arready), output the read data 
         if (slv_reg_rden) begin
            case (slv_rd_addr)
            STRB_B0_BANK_SEL     : axi_rdata <= strb_b0_slv_rdata;
            STRB_B1_BANK_SEL     : axi_rdata <= strb_b1_slv_rdata;
            default              : axi_rdata <= 'd0;
            endcase
         end   
      end
   end
   
   // Mux the correct read done flag onto the set, all values in should be from registers
   always @(*)
     begin
     case (slv_rd_addr)
     STRB_B0_BANK_SEL     : slv_reg_done = strb_b0_slv_rd_done;
     STRB_B1_BANK_SEL     : slv_reg_done = strb_b1_slv_rd_done;
     default              : slv_reg_done = 'd1; // Must be 1 so all reads to invalid addres's complete
     endcase 
     end
     
//---------------------------------------------------------------------------         
//---------------------------------------------------------------------------         
// TIMEOUT LOGIC
//---------------------------------------------------------------------------         
//---------------------------------------------------------------------------         

  assign load_timeout_timer   = (s_axi_awvalid & s_axi_awready)   |
                                (s_axi_wvalid  & s_axi_wready)    |
                                (s_axi_arvalid & s_axi_arready);
                      
  assign clear_timeout_timer  = (s_axi_bvalid & s_axi_bready)     |
                                (s_axi_rvalid & s_axi_rready);
                                
  assign timeout              = timeout_timer_count[C_S_TIMEOUT_WIDTH];
  
  always @( posedge s_axi_aclk ) begin
    if (~s_axi_aresetn) begin
      timeout_timer_count <= 'd0;
      end
    else begin
      // clear the timeout at the end of AXI transactions or a timeout event 
      if (clear_timeout_timer | timeout) begin
        timeout_timer_count <= 'd0;
      end
      else begin
      // load the timer at the start of a RW access and only if the timeout is enabled
      if(load_timeout_timer & timeout_enable_in) begin
        timeout_timer_count <= {1'b0,(~timeout_value_in)};
        end
      else begin
        // if the timeout counter is greater than 0 and enabled we count
        if ((timeout_timer_count != 'd0 ) & timeout_enable_in) begin
          timeout_timer_count <= timeout_timer_count + 'd1;
          end
        end
      end
    end 
  end
     
endmodule
