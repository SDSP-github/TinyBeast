// ****************************************************************************/
// Microsemi Corporation Proprietary and Confidential
// Copyright 2017 Microsemi Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// Description: 
//
// SVN Revision Information:
// SVN $Revision: 37563 $
// SVN $Date: 2021-01-29 20:58:16 +0530 (Fri, 29 Jan 2021) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//
// ****************************************************************************/
module CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_controlRegisters (
    clock,
    resetn,
    
    // CtrlIFMuxCDC inputs
    ctrlSel,
    ctrlWr,
    ctrlAddr,
    ctrlWrData,
    ctrlWrStrbs,
    
    // CtrlIFMuxCDC outputs
    ctrlRdData,
    ctrlRdValid,
    
    // DMAController outputs
    startDMAOp
);
////////////////////////////////////////////////////////////////////////////////
// Parameters
////////////////////////////////////////////////////////////////////////////////
parameter                       MAJOR_VER_NUM = 0;
parameter                       MINOR_VER_NUM = 0;
parameter                       BUILD_NUM     = 0;
parameter                       NUM_INT_BDS   = 4;

////////////////////////////////////////////////////////////////////////////////
// Port directions
////////////////////////////////////////////////////////////////////////////////
input                           clock;
input                           resetn;

// CtrlIFMuxCDC inputs
input                           ctrlSel;
input                           ctrlWr;
input  [10:0]                   ctrlAddr;
input  [31:0]                   ctrlWrData;
input  [3:0]                    ctrlWrStrbs;

// CtrlIFMuxCDC outputs
output [31:0]                   ctrlRdData;
output                          ctrlRdValid;

// DMAController outputs
output [NUM_INT_BDS-1:0]        startDMAOp;

////////////////////////////////////////////////////////////////////////////////
// Internal signals
////////////////////////////////////////////////////////////////////////////////
wire [23:0]                     verReg;
reg  [31:0]                     strtOpReg;

////////////////////////////////////////////////////////////////////////////////
// Constants
////////////////////////////////////////////////////////////////////////////////
localparam [10:0]               VER_REG     = 11'h000;
localparam [10:0]               STRT_OP_REG = 11'h004;

////////////////////////////////////////////////////////////////////////////////
// Version register 
////////////////////////////////////////////////////////////////////////////////
assign verReg[7:0]   = BUILD_NUM;
assign verReg[15:8]  = MINOR_VER_NUM;
assign verReg[23:16] = MAJOR_VER_NUM;

// Read data always ready
assign ctrlRdValid      = 1'b1;
assign ctrlRdData[31:0] = (ctrlAddr == VER_REG) ? ({{8{1'b0}}, verReg[23:0]}) : 32'b0;

////////////////////////////////////////////////////////////////////////////////
// Start Operation register - Only holds for 1 cycle
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                strtOpReg <= 32'b0;
            end
        else
            begin
                if (ctrlSel & ctrlWr & (ctrlAddr == STRT_OP_REG))
                    begin
                        if (ctrlWrStrbs[0])
                            begin
                                strtOpReg[7:0] <= ctrlWrData[7:0];
                            end
                        else
                            begin
                                strtOpReg[7:0] <= 8'b0;
                            end
                        if (ctrlWrStrbs[1])
                            begin
                                strtOpReg[15:8] <= ctrlWrData[15:8];
                            end
                        else
                            begin
                                strtOpReg[15:8] <= 8'b0;
                            end
                        if (ctrlWrStrbs[2])
                            begin
                                strtOpReg[23:16] <= ctrlWrData[23:16];
                            end
                        else
                            begin
                                strtOpReg[23:16] <= 8'b0;
                            end
                        if (ctrlWrStrbs[3])
                            begin
                                strtOpReg[31:24] <= ctrlWrData[31:24];
                            end
                        else
                            begin
                                strtOpReg[31:24] <= 8'b0;
                            end
                    end
                else
                    begin
                        strtOpReg <= 32'b0;
                    end
            end
    end
assign startDMAOp = strtOpReg;

endmodule //controlRegisters