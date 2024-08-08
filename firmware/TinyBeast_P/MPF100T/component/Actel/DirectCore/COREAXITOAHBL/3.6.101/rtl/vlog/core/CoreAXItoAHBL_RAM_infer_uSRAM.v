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
// SVN $Revision: 37359 $
// SVN $Date: 2020-12-10 13:46:58 +0530 (Thu, 10 Dec 2020) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//
// ****************************************************************************/
module COREAXITOAHBL_RAM_infer_uSRAM (
                // Inputs
                rdCLK,
                wrCLK,
                RESETN,
                wrEn,
                wrAddr,
                wrData,
                rdAddr,
                
                // Outputs
                rdAddr_q,
                rdData
               );

////////////////////////////////////////////////////////////////////////////////
// Parameters
////////////////////////////////////////////////////////////////////////////////
parameter AXI_DWIDTH = 64; // Sets the AXI data width - 32/64.
parameter AXI_LWIDTH =  4; // Sets the RAM address width - 4/8.

localparam RAM_DEPTH = 2**AXI_LWIDTH; // Sets the RAM depth - 16/256.

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
input                     rdCLK;
input                     wrCLK;
input                     RESETN;
input                     wrEn;
input   [AXI_LWIDTH-1:0]  wrAddr;
input   [AXI_DWIDTH-1:0]  wrData;
input   [AXI_LWIDTH-1:0]  rdAddr;

output  [AXI_LWIDTH-1:0]  rdAddr_q;
output  [AXI_DWIDTH-1:0]  rdData;

////////////////////////////////////////////////////////////////////////////////
// RAM Inference
////////////////////////////////////////////////////////////////////////////////
// Infer RAM implemented using uSRAM
reg [AXI_DWIDTH-1:0] mem [RAM_DEPTH-1:0]; /* synthesis syn_ramstyle="uram" */  

reg [AXI_LWIDTH-1:0] rdAddrReg;

reg [AXI_LWIDTH-1:0] wrAddrReg;
reg [AXI_DWIDTH-1:0] wrDataReg;
reg                  wrEnReg;

// Register Read Address
always @ (posedge rdCLK)
    rdAddrReg <= rdAddr;

assign rdAddr_q = rdAddrReg;

// Register write related signals
always @ (posedge wrCLK or negedge RESETN)
begin
    if (!RESETN)
    begin
        wrAddrReg <=  'b0;
        wrDataReg <=  'h0;
        wrEnReg   <= 1'b0;
    end
    else
    begin
        wrAddrReg <= wrAddr;
        wrDataReg <= wrData;
        wrEnReg   <= wrEn;
    end
end

// RAM read
assign rdData = mem[rdAddrReg];

// RAM write
always @ (posedge wrCLK)
    if (wrEnReg) mem[wrAddrReg] <= wrDataReg;

endmodule // COREAXITOAHBL_RAM_infer_uSRAM
