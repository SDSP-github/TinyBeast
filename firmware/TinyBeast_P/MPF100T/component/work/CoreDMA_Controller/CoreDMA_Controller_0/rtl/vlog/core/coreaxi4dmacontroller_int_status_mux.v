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
module CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_intStatusMux (
    // Inputs
    clock,
    resetn,
    dscrptrNValid,
    intDscrptrNum_DscrptrSrcMux,
    extDscrptr_DscrptrSrcMux,
    strDscrptr_DscrptrSrcMux,
    extDscrptrAddr_DscrptrSrcMux,
    intStaValid,
    opDone_DMATranCtrl,
    wrError_DMATranCtrl,
    rdError_DMATranCtrl,
    intDscrptrNum_DMATranCtrl,
    extDscrptr_DMATranCtrl,
    extDscrptrAddr_DMATranCtrl,
    strDscrptr_DMATranCtrl,
    
    // Outputs
    valid,
    opDone,
    wrError,
    rdError,
    dscrptrNValidError,
    intDscrptrNum,
    extDscrptr,
    extDscrptrAddr,
    strDscrptr,
    intStaAck,
    dscrptrNValidAck
);

////////////////////////////////////////////////////////////////////////////////
// User modifiable parameters
////////////////////////////////////////////////////////////////////////////////
parameter NUM_INT_BDS_WIDTH = 2;

////////////////////////////////////////////////////////////////////////////////
// Port directions
////////////////////////////////////////////////////////////////////////////////
input                               clock;
input                               resetn;
input                               dscrptrNValid;
input      [NUM_INT_BDS_WIDTH-1:0]  intDscrptrNum_DscrptrSrcMux;
input                               extDscrptr_DscrptrSrcMux;
input                               strDscrptr_DscrptrSrcMux;
input      [31:0]                   extDscrptrAddr_DscrptrSrcMux;
input                               intStaValid;
input                               opDone_DMATranCtrl;
input                               wrError_DMATranCtrl;
input                               rdError_DMATranCtrl;
input      [NUM_INT_BDS_WIDTH-1:0]  intDscrptrNum_DMATranCtrl;
input                               extDscrptr_DMATranCtrl;
input      [31:0]                   extDscrptrAddr_DMATranCtrl;
input                               strDscrptr_DMATranCtrl;
output reg                          valid;
output reg                          opDone;
output reg                          wrError;
output reg                          rdError;
output reg                          dscrptrNValidError;
output reg [NUM_INT_BDS_WIDTH-1:0]  intDscrptrNum;
output reg                          extDscrptr;
output reg [31:0]                   extDscrptrAddr;
output reg                          strDscrptr;
output reg                          intStaAck;
output reg                          dscrptrNValidAck;

////////////////////////////////////////////////////////////////////////////////
// Internal signals
////////////////////////////////////////////////////////////////////////////////
reg  [1:0]  currState;
reg  [1:0]  nextState;

////////////////////////////////////////////////////////////////////////////////
// Constants
////////////////////////////////////////////////////////////////////////////////
localparam [1:0] NVALID_PRI   = 2'b01;
localparam [1:0] TRAN_STA_PRI = 2'b10;

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                currState <= NVALID_PRI;
            end
        else
            begin
                currState <= nextState;
            end
    end

always @ (*)
    begin
        // Default assignments
        valid              <= 1'b0;
        dscrptrNValidError <= 1'b0;
        intDscrptrNum      <= {NUM_INT_BDS_WIDTH{1'b0}};
        extDscrptrAddr     <= 32'b0;
        dscrptrNValidAck   <= 1'b0;
        opDone             <= 1'b0;
        wrError            <= 1'b0;
        rdError            <= 1'b0;
        intStaAck          <= 1'b0;
        extDscrptr         <= 1'b0;
        strDscrptr         <= 1'b0;
        case (currState)
            NVALID_PRI:
                begin
                    if (dscrptrNValid)
                        begin
                            valid              <= 1'b1;
                            dscrptrNValidError <= 1'b1;
                            intDscrptrNum      <= intDscrptrNum_DscrptrSrcMux;
                            extDscrptr         <= extDscrptr_DscrptrSrcMux;
                            strDscrptr         <= strDscrptr_DscrptrSrcMux;
                            extDscrptrAddr     <= extDscrptrAddr_DscrptrSrcMux;
                            dscrptrNValidAck   <= 1'b1;
                            nextState          <= TRAN_STA_PRI;
                        end
                    else if (intStaValid)
                        begin
                            valid          <= 1'b1;
                            opDone         <= opDone_DMATranCtrl;
                            wrError        <= wrError_DMATranCtrl;
                            rdError        <= rdError_DMATranCtrl;
                            intDscrptrNum  <= intDscrptrNum_DMATranCtrl;
                            extDscrptr     <= extDscrptr_DMATranCtrl;
                            extDscrptrAddr <= extDscrptrAddr_DMATranCtrl;
                            strDscrptr     <= strDscrptr_DMATranCtrl;
                            intStaAck      <= 1'b1;
                            nextState      <= NVALID_PRI;
                        end
                    else
                        begin
                            nextState <= NVALID_PRI;
                        end
                end
            TRAN_STA_PRI:
                begin
                    if (intStaValid)
                        begin
                            valid          <= 1'b1;
                            opDone         <= opDone_DMATranCtrl;
                            wrError        <= wrError_DMATranCtrl;
                            rdError        <= rdError_DMATranCtrl;
                            intDscrptrNum  <= intDscrptrNum_DMATranCtrl;
                            extDscrptr     <= extDscrptr_DMATranCtrl;
                            extDscrptrAddr <= extDscrptrAddr_DMATranCtrl;
                            strDscrptr     <= strDscrptr_DMATranCtrl;
                            intStaAck      <= 1'b1;
                            nextState      <= NVALID_PRI;
                        end
                    else if (dscrptrNValid)
                        begin
                            valid              <= 1'b1;
                            dscrptrNValidError <= 1'b1;
                            intDscrptrNum      <= intDscrptrNum_DscrptrSrcMux;
                            strDscrptr         <= strDscrptr_DscrptrSrcMux;
                            extDscrptr         <= extDscrptr_DscrptrSrcMux;
                            extDscrptrAddr     <= extDscrptrAddr_DscrptrSrcMux;
                            dscrptrNValidAck   <= 1'b1;
                            nextState          <= TRAN_STA_PRI;
                        end
                    else
                        begin
                            nextState      <= TRAN_STA_PRI;
                        end
                end
            default:
                begin
                    nextState <= NVALID_PRI;
                end
        endcase
    end
endmodule // intStatusMux