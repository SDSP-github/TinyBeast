// ****************************************************************************/
// Microsemi Corporation Proprietary and Confidential
// Copyright 2015 Microsemi Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// Description: 
//
// SVN Revision Information:
// SVN $Revision: 34887 $
// SVN $Date: 2019-11-27 10:44:19 +0530 (Wed, 27 Nov 2019) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//
// ****************************************************************************/
`timescale 1ns/1ns
module AXI_Master (
    // AXI Interface
    ACLK,
    ARESETN,
    AWID,
    AWADDR,
    AWLEN,
    AWSIZE,
    AWBURST,
    AWVALID,
    AWREADY,
    WID,
    WDATA,
    WSTRB,
    WLAST,
    WVALID,
    WREADY,
    BREADY,
    BID,
    BRESP,
    BVALID,
    ARID,
    ARADDR,
    ARLEN,
    ARSIZE,
    ARBURST,
    ARVALID,
    ARREADY,
    RREADY,
    RID,
    RDATA,
    RRESP,
    RLAST,
    RVALID
);

////////////////////////////////////////////////////////////////////////////
// User modifiable parameters
////////////////////////////////////////////////////////////////////////////
parameter AXI_DWIDTH     = 64; // Sets the width of the Data Width supported.
parameter ID_WIDTH       = 4; // Sets the width of the ID field supported.
parameter WRAP_SUPPORT   = 0;
   
parameter RAM_ADDR_WIDTH = 7; // Determines the size of the wr_golden_mem and
                              // rd_actual_mem RAM buffers
parameter RAM_INIT_FILE  = "ram_init.mem";

localparam RAM_DEPTH       = 2048;//(2**RAM_ADDR_WIDTH);
//localparam AXI_DWIDTH      = 64; // Sets the width of the Data Width supported.
localparam AXI_STRBWIDTH   = AXI_DWIDTH/8;  // Sets the AXI strobe width depending on AXI data width.
//localparam AXI_DW          = (AXI_DWIDTH == 64) ? 1 : 0;  // Sets the AXI strobe width depending on AXI data width.
localparam TB_DEBUG        = 1;  // 0 - Disable log messages, 1 - Enable log messages
localparam ERROR_LIMIT     = 10;

input                           AWREADY;
input                           WREADY;
input [ID_WIDTH-1:0]            BID;
input [1:0]                     BRESP;
input                           BVALID;
input                           ARREADY;
input [ID_WIDTH-1:0]            RID;
input [AXI_DWIDTH-1:0]          RDATA;
input [1:0]                     RRESP;
input                           RLAST;
input                           RVALID;

// Outputs on AXI Interface
input                           ACLK;
input                           ARESETN;
output  [ID_WIDTH-1:0]          AWID;
output  [31:0]                  AWADDR;
output  [3:0]                   AWLEN;
output  [2:0]                   AWSIZE;
output  [1:0]                   AWBURST;
output                          AWVALID;
output  [ID_WIDTH-1:0]          WID;
output  [AXI_DWIDTH-1:0]        WDATA;
output  [AXI_STRBWIDTH-1:0]     WSTRB;
output                          WLAST;
output                          WVALID;
output                          BREADY;
output  [ID_WIDTH-1:0]          ARID;
output  [31:0]                  ARADDR;
output  [3:0]                   ARLEN;
output  [2:0]                   ARSIZE;
output  [1:0]                   ARBURST;
output                          ARVALID;
output                          RREADY;

reg     [ID_WIDTH-1:0]          AWID;
reg     [31:0]                  AWADDR;
reg     [3:0]                   AWLEN;
reg     [2:0]                   AWSIZE;
reg     [1:0]                   AWBURST;
reg                             AWVALID;
reg     [ID_WIDTH-1:0]          WID;
reg     [AXI_DWIDTH-1:0]        WDATA;
reg     [AXI_STRBWIDTH-1:0]     WSTRB;
reg                             WLAST;
reg                             WVALID;
reg                             BREADY;
reg     [ID_WIDTH-1:0]          ARID;
reg     [31:0]                  ARADDR;
reg     [3:0]                   ARLEN;
reg     [2:0]                   ARSIZE;
reg     [1:0]                   ARBURST;
reg                             ARVALID;
reg                             RREADY;

reg     [RAM_ADDR_WIDTH:0]      axi_wr_addr;
reg     [RAM_ADDR_WIDTH:0]      axi_rd_addr;
reg     [31:0]                  read_addr;
reg     [7:0]                   wr_golden_mem [0:RAM_DEPTH-1];
reg     [7:0]                   rd_actual_mem [0:RAM_DEPTH-1];
reg     [4:0]                   len_idx;
integer                         lp_cnt;
reg [ERROR_LIMIT-1:0]           error_cnt;
integer                         trans_err_cnt;

reg     [31:0]                  addr;
reg     [4:0]                   len_loop;
reg     [3:0]                   len;
reg     [2:0]                   max_size;
reg     [2:0]                   size;
reg     [1:0]                   max_burst;
reg     [1:0]                   burst;
reg     [AXI_STRBWIDTH-1:0]     ws_f, ws_l;

////////////////////////////////////////////////////////////////////////////////
// Initial value declarations                                               
////////////////////////////////////////////////////////////////////////////////
initial begin
    AWID    = {ID_WIDTH{1'b0}};
    AWADDR  = {32{1'b0}};
    AWLEN   = 4'b0;
    AWSIZE  = 3'b0;
    AWBURST = 2'b0;
    AWVALID = 1'b0;
    WID     = {ID_WIDTH{1'b0}};
    WDATA   = {AXI_DWIDTH{1'b0}};
    WSTRB   = {AXI_STRBWIDTH{1'b0}};
    WLAST   = 1'b0;
    WVALID  = 1'b0;
    BREADY  = 1'b0;
    RREADY  = 1'b0;
    ARID    = {ID_WIDTH{1'b0}};
    ARADDR  = {32{1'b0}};
    ARLEN   = {4{1'b0}};
    ARSIZE  = {3{1'b0}};
    ARBURST = {2{1'b0}};
    ARVALID = 1'b0;
end

////////////////////////////////////////////////////////////////////////////////
// Memory initialization for simulation
////////////////////////////////////////////////////////////////////////////////
initial
begin
    for(lp_cnt = 0; lp_cnt <= RAM_DEPTH-1; lp_cnt = lp_cnt + 1)
    begin
        rd_actual_mem[lp_cnt] <= 8'b0;
    end
   error_cnt = 'h0;
end

////////////////////////////////////////////////////////////////////////////////
// RAM initialization - Populates RAM from input .mem file
////////////////////////////////////////////////////////////////////////////////
initial
begin
    $readmemb(RAM_INIT_FILE, wr_golden_mem);
end

////////////////////////////////////////////////////////////////////////////////
// Write Address Channel task
////////////////////////////////////////////////////////////////////////////////
task axi_write_addr_channel;
    input [ID_WIDTH-1:0]     AWID_in;
    input [31:0]             AWADDR_in;
    input [3:0]              AWLEN_in;
    input [2:0]              AWSIZE_in;
    input [1:0]              AWBURST_in;
    begin
        @(posedge ACLK);
        AWID    = AWID_in;
        AWADDR  = AWADDR_in;
        AWLEN   = AWLEN_in;
        AWSIZE  = AWSIZE_in;
        AWBURST = AWBURST_in;
        AWVALID = 1'b1;
        wait (AWREADY);
        @(posedge ACLK);
        AWVALID = 1'b0;
        AWADDR = 32'b0;
        AWLEN = 4'b0;
        AWSIZE = 3'b0;
        AWBURST = 2'b0;
        AWVALID = 1'b0;
    end
endtask // axi_write_addr_channel 

////////////////////////////////////////////////////////////////////////////////
// Write Data Channel task
////////////////////////////////////////////////////////////////////////////////
task axi_write_data_channel;
    input [ID_WIDTH-1:0]      WID_in;
    input [31:0]              AWADDR_in;
    input [3:0]               AWLEN_in;
    input [2:0]               AWSIZE_in;
    input [1:0]               AWBURST_in;
    input [AXI_STRBWIDTH-1:0] WSTRB_in_first; 
    input [AXI_STRBWIDTH-1:0] WSTRB_in_last;
    integer                   i;
    begin
        // send number of data transfer in one burst 
        for (i=0; i<=AWLEN_in; i=i+1)
        begin
            WID = WID_in;
            if (AWBURST_in == 2'b00) // fixed burst
                WSTRB = WSTRB_in_first;
            else // incr and wrap burst 
            begin
                if (AWSIZE_in[2:0] == 3'b011 && AXI_DWIDTH >= 64) // 64-bit transfer size
                begin
                    if (i==0) // First beat, unaligned transfer
                        WSTRB = WSTRB_in_first;
                    else if (i==AWLEN_in) // Last beat - narrow transfer
                        WSTRB = WSTRB_in_last;
                    else if (i==1)
                        WSTRB = {AXI_STRBWIDTH{1'b1}};
                    else
                        WSTRB = {WSTRB, WSTRB[AXI_STRBWIDTH-1:AXI_STRBWIDTH-8]};
                end
                else if (AWSIZE_in[2:0] == 3'b010) // 32-bit transfer size
                begin
                    if (i==0) // First beat, unaligned transfer
                        WSTRB = WSTRB_in_first;
                    else if (i==AWLEN_in) // Last beat - narrow transfer
                        WSTRB = WSTRB_in_last; // 8'h0F or 8'hF0
                    else if (i==1)
                    begin
                        if(AXI_DWIDTH == 64)
                            WSTRB = {{4{~AWADDR_in[2]}}, {4{AWADDR_in[2]}}};
                        if(AXI_DWIDTH == 32)
                            WSTRB = {AXI_STRBWIDTH{1'b1}};
                    end
                    else 
                        WSTRB = {WSTRB, WSTRB[AXI_STRBWIDTH-1:AXI_STRBWIDTH-4]};
                end
                else if (AWSIZE_in[2:0] == 3'b001) // 16-bit transfer size
                begin
                    if (i==0) // First beat, unaligned transfer
                        WSTRB = WSTRB_in_first;
                    else if (i==AWLEN_in) // Last beat - narrow transfer
                        WSTRB = WSTRB_in_last;
                    else if (i==1)
                    begin
                        if(AXI_DWIDTH == 64)
                            WSTRB = {{2{ AWADDR_in[2] & ~AWADDR_in[1]}}, 
                                     {2{~AWADDR_in[2] &  AWADDR_in[1]}},
                                     {2{~AWADDR_in[2] & ~AWADDR_in[1]}},
                                     {2{ AWADDR_in[2] &  AWADDR_in[1]}}};
                        if(AXI_DWIDTH == 32)
                            WSTRB = {{2{~AWADDR_in[1]}}, {2{AWADDR_in[1]}}};
                    end
                    else
                        WSTRB = {WSTRB, WSTRB[AXI_STRBWIDTH-1:AXI_STRBWIDTH-2]};
                end
                else if (AWSIZE_in[2:0] == 3'b000) // 8-bit transfer size
                begin
                    if (i==0) // First beat, unaligned transfer
                        WSTRB = WSTRB_in_first;
                    else if (i==AWLEN_in) // Last beat - narrow transfer
                        WSTRB = WSTRB_in_last;
                    else if (i==1)
                    begin
                        if(AXI_DWIDTH == 64)
                            WSTRB = {{ AWADDR_in[2] &  AWADDR_in[1] & ~AWADDR_in[0]}, 
                                     { AWADDR_in[2] & ~AWADDR_in[1] &  AWADDR_in[0]},
                                     { AWADDR_in[2] & ~AWADDR_in[1] & ~AWADDR_in[0]},
                                     {~AWADDR_in[2] &  AWADDR_in[1] &  AWADDR_in[0]},
                                     {~AWADDR_in[2] &  AWADDR_in[1] & ~AWADDR_in[0]},
                                     {~AWADDR_in[2] & ~AWADDR_in[1] &  AWADDR_in[0]},
                                     {~AWADDR_in[2] & ~AWADDR_in[1] & ~AWADDR_in[0]},
                                     { AWADDR_in[2] &  AWADDR_in[1] &  AWADDR_in[0]}};
                        if(AXI_DWIDTH == 32)
                            WSTRB = {{ AWADDR_in[1] & ~AWADDR_in[0]}, 
                                     {~AWADDR_in[1] &  AWADDR_in[0]},
                                     {~AWADDR_in[1] & ~AWADDR_in[0]},
                                     { AWADDR_in[1] &  AWADDR_in[0]}};
                    end
                    else
                        WSTRB = {WSTRB, WSTRB[AXI_STRBWIDTH-1]};
                end
                else
                begin
                    if(AXI_DWIDTH == 64)
                        $display ("%t, Error: Only 64/32/16/8-bit transfer size supported", $time);
                    if(AXI_DWIDTH == 32)
                        $display ("%t, Error: Only 32/16/8-bit transfer size supported", $time);
                end
            end
            WVALID  = 1'b1;
            WLAST   = (i==AWLEN_in) ? 1'b1 : 1'b0; 
            wait (WREADY);
            @(posedge ACLK);
        end
        WLAST = 1'b0;
        WID = {ID_WIDTH{1'b0}};
        WSTRB = {AXI_STRBWIDTH{1'b0}};//8'b0;
        WVALID = 1'b0;
    end
endtask // axi_write_data_channel

generate
    genvar write_offset;
    for(write_offset=0; write_offset<AXI_STRBWIDTH; write_offset = write_offset + 1)
    begin : WDATA_GEN // Sweep through the byte lanes
        always @ (*)
        begin
            if((WSTRB[write_offset]) & WVALID)
                WDATA[((write_offset + 1) * 8)-1:(write_offset * 8)] = wr_golden_mem[axi_wr_addr + write_offset];  //AXI_STRBWIDTH
            else
              WDATA[((write_offset + 1) * 8)-1:(write_offset * 8)] = 8'b0;            //{AXI_STRBWIDTH{1'b0}};
        end
    end
endgenerate

////////////////////////////////////////////////////////////////////////////////
// Write Response Channel task
////////////////////////////////////////////////////////////////////////////////
task axi_write_response_channel;
    begin
        @(posedge ACLK);
        BREADY = 1'b1;
        wait (BVALID);
        @(posedge ACLK);
        BREADY = 1'b0;
    end
endtask

////////////////////////////////////////////////////////////////////////////////
// AXI Write task
////////////////////////////////////////////////////////////////////////////////
task axi_write;
    input [ID_WIDTH-1:0]      AWID_in;
    input [31:0]              AWADDR_in;
    input [3:0]               AWLEN_in;
    input [2:0]               AWSIZE_in;
    input [1:0]               AWBURST_in;
    input [AXI_STRBWIDTH-1:0] WSTRB_in_first; 
    input [AXI_STRBWIDTH-1:0] WSTRB_in_last; 
    begin
        axi_write_addr_channel(AWID_in,AWADDR_in,AWLEN_in,AWSIZE_in,AWBURST_in);
        axi_write_data_channel(AWID_in,AWADDR_in,AWLEN_in,AWSIZE_in,AWBURST_in,WSTRB_in_first, WSTRB_in_last);
        axi_write_response_channel();
    end
endtask // axi_write

////////////////////////////////////////////////////////////////////////////////
// AXI Read Address Channel task
////////////////////////////////////////////////////////////////////////////////
task axi_read_addr_channel;
    input [ID_WIDTH-1:0]     ARID_in;
    input [31:0]             ARADDR_in;
    input [3:0]              ARLEN_in;
    input [2:0]              ARSIZE_in;
    input [1:0]              ARBURST_in;
    begin
        @(posedge ACLK);
        ARID    = ARID_in;
        ARADDR  = ARADDR_in;
        ARLEN   = ARLEN_in;
        ARSIZE  = ARSIZE_in;
        ARBURST = ARBURST_in;
        ARVALID = 1'b1;
        wait (ARREADY);
        @(posedge ACLK);
        ARVALID = 1'b0;
        ARID    = {ID_WIDTH{1'b0}};
        ARADDR  = 32'b0;
        ARLEN   = 4'b0;
        ARSIZE  = 3'b0;
        ARBURST = 2'b0;
    end
endtask // axi_read_addr_channel

////////////////////////////////////////////////////////////////////////////////
// AXI Read Data Channel task
////////////////////////////////////////////////////////////////////////////////
task axi_read_data_channel;
    input [ID_WIDTH-1:0]     ARID_in;
    input [31:0]             ARADDR_in;
    input [3:0]              ARLEN_in;
    input [2:0]              ARSIZE_in;
    input [1:0]              ARBURST_in;
    
    integer                  i;

    // AP - added
    integer                   j;
    integer                   k;
    integer                   l;
    integer                   m;
    integer                   p;
    integer                   q;
    reg                       flag_error;

    integer                   r;

   begin
      RREADY     = 1'b0;

      if(AXI_DWIDTH == 64)
          axi_rd_addr   = {ARADDR_in[RAM_ADDR_WIDTH:3], {3{1'b0}}}; // Align the start address to 32-bit transfer
      if(AXI_DWIDTH == 32)
          axi_rd_addr   = {ARADDR_in[RAM_ADDR_WIDTH:2], {2{1'b0}}}; // Align the start address to 64-bit transfer
      
      read_addr     = ARADDR_in;

      flag_error  = 1'b0;

      for (i=0; i<=ARLEN_in; i=i+1)
      begin
          wait (RVALID); // Wait on slave to assert RVALID
          RREADY     = 1'b1;
          @ (posedge ACLK);

          // Store the read data in memory for comparison
          rd_actual_mem[axi_rd_addr  ] = RDATA[7 :0 ];
          rd_actual_mem[axi_rd_addr+1] = RDATA[15:8 ];
          rd_actual_mem[axi_rd_addr+2] = RDATA[23:16];
          rd_actual_mem[axi_rd_addr+3] = RDATA[31:24];
          if(AXI_DWIDTH >= 64)
          begin
              rd_actual_mem[axi_rd_addr+4] = RDATA[39:32];
              rd_actual_mem[axi_rd_addr+5] = RDATA[47:40];
              rd_actual_mem[axi_rd_addr+6] = RDATA[55:48];
              rd_actual_mem[axi_rd_addr+7] = RDATA[63:56];
          end

      if(TB_DEBUG) begin 
         $display("\n------------------------------------------------------\n");
         $display("Comparison begins for :: %d data word", i);
      end

      if(ARSIZE_in == 3'b011) begin // 64-bit transfers
         for (j=0; j<=7; j=j+1) begin
            if(rd_actual_mem[axi_rd_addr+j] == wr_golden_mem[axi_rd_addr+j]) begin
                if(TB_DEBUG) begin
		            $display("%t WRITE DATA = %h  READ DATA = %h",$time, wr_golden_mem[axi_rd_addr+j], rd_actual_mem[axi_rd_addr+j]);
                end
            end
            else begin
                flag_error = 1'b1;
                error_cnt   = error_cnt + 'h1;
                if(TB_DEBUG) begin            
		            $display("%t WRITE DATA = %h  READ DATA = %h",$time, wr_golden_mem[axi_rd_addr+j], rd_actual_mem[axi_rd_addr+j]);
                end
            end
         end
      end

      if (ARSIZE_in == 3'b010) begin  // 32-bit transfers
          if(AXI_DWIDTH == 64) begin
              if( read_addr[2]) m = 4;
              if(!read_addr[2]) m = 0;
          end
          if(AXI_DWIDTH == 32) m = 0;
          for (k=0; k<=3; k=k+1) begin
            if(rd_actual_mem[axi_rd_addr+k+m] == wr_golden_mem[axi_rd_addr+k+m]) begin
                if(TB_DEBUG) begin
		            $display("%t WRITE DATA = %h  READ DATA = %h",$time, wr_golden_mem[axi_rd_addr+k+m], rd_actual_mem[axi_rd_addr+k+m]);
                end
            end
            else begin
                flag_error = 1'b1;
                error_cnt   = error_cnt + 'h1;
                if(TB_DEBUG) begin            
		            $display("%t WRITE DATA = %h  READ DATA = %h",$time, wr_golden_mem[axi_rd_addr+k+m], rd_actual_mem[axi_rd_addr+k+m]);
                end
            end
         end
      end

      if (ARSIZE_in == 3'b001) begin // 16-bit transfers
          if(AXI_DWIDTH == 64) begin
              if(read_addr[2:1] == 2'b11) p = 6;
              if(read_addr[2:1] == 2'b10) p = 4;
              if(read_addr[2:1] == 2'b01) p = 2;
              if(read_addr[2:1] == 2'b00) p = 0;
          end
          if(AXI_DWIDTH == 32) begin
              if( read_addr[1]) p = 2;
              if(!read_addr[1]) p = 0;
          end
          for (l=0; l<=1; l=l+1) begin
            if(rd_actual_mem[axi_rd_addr+l+p] == wr_golden_mem[axi_rd_addr+l+p]) begin
                if(TB_DEBUG) begin
		            $display("%t WRITE DATA = %h  READ DATA = %h",$time, wr_golden_mem[axi_rd_addr+l+p], rd_actual_mem[axi_rd_addr+l+p]);
                end
            end
            else begin
                flag_error = 1'b1;
                error_cnt   = error_cnt + 'h1;
                if(TB_DEBUG) begin            
		            $display("%t WRITE DATA = %h  READ DATA = %h",$time, wr_golden_mem[axi_rd_addr+l+p], rd_actual_mem[axi_rd_addr+l+p]);
                end
            end
         end
      end

      if (ARSIZE_in == 3'b000) begin  // 8-bit transfers
          if(AXI_DWIDTH == 64) begin
              if(read_addr[2:0] == 3'b111) q = 7;
              if(read_addr[2:0] == 3'b110) q = 6;
              if(read_addr[2:0] == 3'b101) q = 5;
              if(read_addr[2:0] == 3'b100) q = 4;
              if(read_addr[2:0] == 3'b011) q = 3;
              if(read_addr[2:0] == 3'b010) q = 2;
              if(read_addr[2:0] == 3'b001) q = 1;
              if(read_addr[2:0] == 3'b000) q = 0;
          end
          if(AXI_DWIDTH == 32) begin
              if(read_addr[1:0] == 2'b11) q = 3;
              if(read_addr[1:0] == 2'b10) q = 2;
              if(read_addr[1:0] == 2'b01) q = 1;
              if(read_addr[1:0] == 2'b00) q = 0;
          end
          if(rd_actual_mem[axi_rd_addr+q] == wr_golden_mem[axi_rd_addr+q]) begin
              if(TB_DEBUG) begin
                  $display("%t WRITE DATA = %h  READ DATA = %h",$time, wr_golden_mem[axi_rd_addr+q], rd_actual_mem[axi_rd_addr+q]);
              end
          end
          else begin
              flag_error = 1'b1;
              error_cnt   = error_cnt + 'h1;
              if(TB_DEBUG) begin            
		          $display("%t WRITE DATA = %h  READ DATA = %h",$time, wr_golden_mem[axi_rd_addr+q], rd_actual_mem[axi_rd_addr+q]);
              end
          end
      end
      
      axi_rd_addr = axi_rd_addr + AXI_STRBWIDTH;

      if (ARSIZE_in == 3'b011)
          read_addr[3:0] = read_addr[3:0] + 8;
      if (ARSIZE_in == 3'b010)
          read_addr[3:0] = read_addr[3:0] + 4;
      if (ARSIZE_in == 3'b001)
          read_addr[3:0] = read_addr[3:0] + 2;
      if (ARSIZE_in == 3'b000)
          read_addr[3:0] = read_addr[3:0] + 1;

      #5;
      end

      $display("\n");
      if(flag_error == 1'b0) begin
         $display("======================================================");
         $display("==                Transaction passed                ==");
         $display("======================================================");
      end
      else begin
         trans_err_cnt = trans_err_cnt + 1;
         $display("======================================================");
         $display("==                Transaction failed                ==");
         $display("======================================================");
      end
      $display("\n");      
      
   end
endtask // axi_read_data_channel 

////////////////////////////////////////////////////////////////////////////////
// AXI Read task
////////////////////////////////////////////////////////////////////////////////
task axi_read;
    input [ID_WIDTH-1:0]     ARID_in;
    input [31:0]             ARADDR_in;
    input [3:0]              ARLEN_in;
    input [2:0]              ARSIZE_in;
    input [1:0]              ARBURST_in;
    begin
       axi_read_addr_channel(ARID_in,ARADDR_in,ARLEN_in,ARSIZE_in,ARBURST_in);
       axi_read_data_channel(ARID_in,ARADDR_in,ARLEN_in,ARSIZE_in,ARBURST_in);
    end
endtask // axi_read 

////////////////////////////////////////////////////////////////////////////////
// Capture the write address & store the write data in memory for comparison
////////////////////////////////////////////////////////////////////////////////
always @ (posedge ACLK)
begin
    if (AWVALID & AWREADY) begin
        if (AXI_DWIDTH == 64)
            axi_wr_addr <= {AWADDR[RAM_ADDR_WIDTH:3], {3{1'b0}}}; // Align the start address to 64-bit transfer
        if (AXI_DWIDTH == 32)
            axi_wr_addr <= {AWADDR[RAM_ADDR_WIDTH:2], {2{1'b0}}}; // Align the start address to 64-bit transfer
    end
    else if (WREADY & WVALID)
        axi_wr_addr <= axi_wr_addr + AXI_STRBWIDTH;
end

////////////////////////////////////////////////////////////////////////////////
// 
////////////////////////////////////////////////////////////////////////////////
initial
begin
    wait(ARESETN == 1'b1);
    #100;
    // The AXIMASTER.axi_write function uses the value specified to the
    // WSTRB_first argument to generate WSTRB[7:0] during the first data
    // beat/transfer of the transaction. Similarly, WSTRB[7:0] is generated from
    // the value passed to the STRB_last argument during the last data beat 
    // (with the exception of a transaction containing a single beat/transfer).
    // WSTRB[7:0] is driven out as 8'hFF for all other beats/transfers
    // in the transaction.
    
    // The WDATA is generated as a 64/32-bit pseudorandom number, unique for each
    // beat of the transfer.

    // Tests for transfer size 8/16/32/64-bit when AXI_DWIDTH = 64
    // Tests for transfer size 8/16/32-bit when AXI_DWIDTH = 32
    // Tests for increment burst type only when WRAP_SUPPORT = 0
    // Tests for both increment and wrap burst types when WRAP_SUPPORT = 1
    // Tests for burst length from 0 to 15 for increment bursts
    // Tests for burst length of 1, 3, 7 and 15 for wrap bursts

    $display ("//////////////////////////////////////////////////////");
    $display ("//             CoreAXItoAHBL TESTBENCH              //");
    $display ("//////////////////////////////////////////////////////");
    $display("\n\n");

    // setting total error count to zero at start of simulation
    trans_err_cnt = 0;

    // set the address
    addr  = 32'h00000000;

    // set the maximum transfer size
    if(AXI_DWIDTH == 64) max_size <= 3'h3; // upto 64-bit
    else                 max_size <= 3'h2; // upto 32-bit

    // set the brust type to be tested
    if(WRAP_SUPPORT == 1) max_burst <= 2'h2; // both wrap and incr
    else                  max_burst <= 2'h1; // only incr

    #100;
    for (size = 3'h0; size <= max_size; size = size + 1) begin

        #100;
        for (burst = 2'h1; burst <= max_burst; burst = burst + 1) begin

            #100;
            if(burst == 2'h1) begin // incr burst
                len_loop  = 4'h0;
            end
            else begin // wrap burst
                len_loop  = 4'h1;
            end

            #100;
            while (len_loop <= 4'hF) begin

                #100;
                len = len_loop[3:0];

                // set the first and last write strobe
                if(AXI_DWIDTH == 64 && size == 2'h3) begin // double-word
                    ws_f = 8'hFF;
                    ws_l = 8'hFF;
                end

                if(AXI_DWIDTH == 64 && size == 2'h2) begin // word
                    ws_f = 8'h0F;
                    case (len)
                        4'h0, 4'h2, 4'h4, 4'h6, 4'h8, 4'hA, 4'hC, 4'hE : ws_l = 8'h0F;
                        default                                        : ws_l = 8'hF0;
                    endcase
                end

                if(AXI_DWIDTH == 64 && size == 2'h1) begin // half-word
                    ws_f = 8'h03;
                    case (len)
                        4'h0, 4'h4, 4'h8, 4'hC : ws_l = 8'h03;
                        4'h1, 4'h5, 4'h9, 4'hD : ws_l = 8'h0C;
                        4'h2, 4'h6, 4'hA, 4'hE : ws_l = 8'h30;
                        default                : ws_l = 8'hC0;
                    endcase
                end

                if(AXI_DWIDTH == 64 && size == 2'h0) begin // byte
                    ws_f = 8'h01;
                    case (len)
                        4'h0, 4'h8 : ws_l = 8'h01;
                        4'h1, 4'h9 : ws_l = 8'h02;
                        4'h2, 4'hA : ws_l = 8'h04;
                        4'h3, 4'hB : ws_l = 8'h08;
                        4'h4, 4'hC : ws_l = 8'h10;
                        4'h5, 4'hD : ws_l = 8'h20;
                        4'h6, 4'hE : ws_l = 8'h40;
                        default    : ws_l = 8'h80;
                    endcase
                end

                if(AXI_DWIDTH == 32 && size == 2'h2) begin // word
                    ws_f = 4'hF;
                    ws_l = 4'hF;
                end

                if(AXI_DWIDTH == 32 && size == 2'h1) begin // half-word
                    ws_f = 4'h3;
                    case (len)
                        4'h0, 4'h2, 4'h4, 4'h6, 4'h8, 4'hA, 4'hC, 4'hE : ws_l = 4'h3;
                        default                                        : ws_l = 4'hC;
                    endcase
                end

                if(AXI_DWIDTH == 32 && size == 2'h0) begin // byte
                    ws_f = 4'h1;
                    case (len)
                        4'h0, 4'h4, 4'h8, 4'hC : ws_l = 8'h1;
                        4'h1, 4'h5, 4'h9, 4'hD : ws_l = 8'h2;
                        4'h2, 4'h6, 4'hA, 4'hE : ws_l = 8'h4;
                        default                : ws_l = 8'h8;
                    endcase
                end

                $display("******************************************************");
                $display("** AXI transfers of Size = %h, Burst = %h, Length = %h **", size, burst, len);
                $display("******************************************************");
                #500;
                // AXI write transaction
                //        ID,   ADDR, LEN, SIZE, BURST, WSTRB_first, WSTRB_last
                axi_write(4'h6, addr, len, size, burst, ws_f,        ws_l);
                #500;
                // AXI read transaction
                //       ID,   ADDR, LEN, SIZE, BURST
                axi_read(4'h6, addr, len, size, burst);
                #500;

                // increment the length
                if (burst == 2'h1) // incr burst
                    len_loop = len_loop + 1;
                else // wrap burst
                    len_loop = ((len_loop + 1) * 2) - 1;

                #100;
            end

            #100;
        end

        #100;
    end

    if(trans_err_cnt == 0) begin
        $display("******************************************************");
        $display("**                ALL TESTS PASSED !                **");
        $display("******************************************************");
    end
    else begin
        $display("******************************************************");
        $display("**                   TEST FAILED                    **");
        $display("******************************************************");
    end
    $display("\n\n");

    #1000;
    //Stop the simulation
    $stop;
end

endmodule
