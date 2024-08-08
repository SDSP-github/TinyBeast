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
module CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_ctrlIFMuxCDC (
    // AXILiteSlaveCtrl inputs
    ctrlSel_AXILiteSlaveCtrl,
    ctrlWr_AXILiteSlaveCtrl,
    ctrlAddr_AXILiteSlaveCtrl,
    ctrlWrData_AXILiteSlaveCtrl,
    ctrlWrStrbs_AXILiteSlaveCtrl,
    
    // Buffer Descriptor inputs
    ctrlWrRdy_BufferDescrptrs,
    ctrlRdData_BufferDescrptrs,
    ctrlRdValid_BufferDescrptrs,
    
    // Interrupt Controller inputs
    ctrlRdData_IntController,
    ctrlRdValid_IntController,
    
    // Control Register inputs
    ctrlRdData_CtrlReg,
    ctrlRdValid_CtrlReg,
    
    // AXI4StreamSlaveCtrl inputs
    ctrlRdData_AXI4StreamSlaveCtrl,
    ctrlRdValid_AXI4StreamSlaveCtrl,
    
    // General outputs
    ctrlSel,
    ctrlWr,
    ctrlAddr,
    ctrlWrData,
    ctrlWrStrbs,
    
    // AXILiteSlaveCtrl outputs
    ctrlWrRdy,
    ctrlRdData,
    ctrlRdValid
);

////////////////////////////////////////////////////////////////////////////////
// Port directions
////////////////////////////////////////////////////////////////////////////////
// AXILiteSlaveCtrl inputs
input               ctrlSel_AXILiteSlaveCtrl;
input               ctrlWr_AXILiteSlaveCtrl;
input   [10:0]      ctrlAddr_AXILiteSlaveCtrl;
input   [31:0]      ctrlWrData_AXILiteSlaveCtrl;
input   [3:0]       ctrlWrStrbs_AXILiteSlaveCtrl;

// Buffer Descriptor inputs
input               ctrlWrRdy_BufferDescrptrs;
input   [31:0]      ctrlRdData_BufferDescrptrs;
input               ctrlRdValid_BufferDescrptrs;

// Interrupt Controller inputs
input   [31:0]      ctrlRdData_IntController;
input               ctrlRdValid_IntController;

// Control Register inputs
input   [31:0]      ctrlRdData_CtrlReg;
input               ctrlRdValid_CtrlReg;

// AXI4StreamSlaveCtrl inputs
input   [31:0]      ctrlRdData_AXI4StreamSlaveCtrl;
input               ctrlRdValid_AXI4StreamSlaveCtrl;

// General outputs
output              ctrlSel;
output              ctrlWr;
output  [10:0]      ctrlAddr;
output  [31:0]      ctrlWrData;
output  [3:0]       ctrlWrStrbs;

// AXILiteSlaveCtrl outputs
output              ctrlWrRdy;
output  [31:0]      ctrlRdData;
output              ctrlRdValid;

// Map control master data from AXI-Lite master directly to system as the AHBL
// control interface isn't yet enabled
assign ctrlSel     = ctrlSel_AXILiteSlaveCtrl;
assign ctrlWr      = ctrlWr_AXILiteSlaveCtrl;
assign ctrlAddr    = ctrlAddr_AXILiteSlaveCtrl;
assign ctrlWrData  = ctrlWrData_AXILiteSlaveCtrl;
assign ctrlWrStrbs = ctrlWrStrbs_AXILiteSlaveCtrl;

// Mux read data from Interrupt Controller and Buffer Descriptors to the control
// master
assign ctrlRdData = (ctrlAddr[10:0] >= 11'h460) ? ctrlRdData_AXI4StreamSlaveCtrl :
                    (ctrlAddr[10:0] >= 11'h060) ? ctrlRdData_BufferDescrptrs :
                    (ctrlAddr[10:0] == 11'h0)   ? ctrlRdData_CtrlReg :
                    ctrlRdData_IntController;

assign ctrlRdValid = (ctrlAddr[10:0] >= 11'h460) ? ctrlRdValid_AXI4StreamSlaveCtrl :
                     (ctrlAddr[10:0] >= 11'h060) ? ctrlRdValid_BufferDescrptrs :
                     (ctrlAddr[10:0] == 11'h0)   ? ctrlRdValid_CtrlReg :
                     ctrlRdValid_IntController;

assign ctrlWrRdy   = (ctrlAddr[10:0] >= 11'h460) ? 1'b1 :
                     (ctrlAddr[10:0] >= 11'h060) ? ctrlWrRdy_BufferDescrptrs :
                     1'b1; // All other addressable locations are registers

endmodule // ctrlIFMuxCDC