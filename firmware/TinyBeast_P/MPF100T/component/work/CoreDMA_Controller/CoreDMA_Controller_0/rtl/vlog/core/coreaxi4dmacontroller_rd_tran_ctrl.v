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
module CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_rdTranCtrl (
    // General inputs
    clock,
    resetn,
    
    // rdTranQueue inputs
    reqInQueue,
    priLvl,
    extDscrptr,
    extDscrptrAddr,
    srcOp,
    srcDataWidth,
    srcAddr,
    dstDataWidth,
    numOfBytes,
    dataValidExtDscrptr,
    
    // extDscrptrFetch inputs
    extRdyValid,
    extRdy,
    
    // AXI4MasterCtrl inputs
    rdTranDone,
    rdTranError,
    numOfBytesInRdValid_AXI4MasterCtrl,
    
    // intErrorCtrl inputs
    rdDoneAck,
    rdErrorAck,
    extDataValidNSetAck,
    noOpSrcAck,
    
    // extDscrptrFetch outputs
    extRdyCheck,
    extDscrptrAddr_ExtDscrptrFetch,
    
    // intErrorCtrl outputs
    rdDone,
    rdError,
    
    // AXI4MasterCtrl outputs
    strtAXIRdTran,
    srcNumOfBytes,
    srcAXITranType,
    srcAXIDataWidth,
    srcStrtAddr,
    srcMaxAXINumBeats,
    
    // transAck outputs
    rdyToAck,
    extDataValid,
    
    // intErrorCtrlFSM outputs
    extDataValidNSet,
    noOpSrc
);

////////////////////////////////////////////////////////////////////////////////
// Parameters
////////////////////////////////////////////////////////////////////////////////
parameter MAX_TRAN_SIZE_WIDTH       = 23;
parameter MAX_AXI_TRAN_SIZE_WIDTH   = 12;
parameter NUM_PRI_LVLS              = 1;
parameter MAX_AXI_NUM_BEATS_WIDTH   = 8;
parameter PRI_0_NUM_OF_BEATS        = 255;
parameter PRI_1_NUM_OF_BEATS        = 127;
parameter PRI_2_NUM_OF_BEATS        = 63;
parameter PRI_3_NUM_OF_BEATS        = 31;
parameter PRI_4_NUM_OF_BEATS        = 15;
parameter PRI_5_NUM_OF_BEATS        = 7;
parameter PRI_6_NUM_OF_BEATS        = 3;
parameter PRI_7_NUM_OF_BEATS        = 0;

////////////////////////////////////////////////////////////////////////////////
// Port directions
////////////////////////////////////////////////////////////////////////////////
// General inputs
input                                       clock;
input                                       resetn;

// rdTranQueue inputs
input                                       reqInQueue;
input [NUM_PRI_LVLS-1:0]                    priLvl;
input                                       extDscrptr;
input [31:0]                                extDscrptrAddr;
input [1:0]                                 srcOp;
input [2:0]                                 srcDataWidth;
input [31:0]                                srcAddr;
input [2:0]                                 dstDataWidth;
input [MAX_TRAN_SIZE_WIDTH-1:0]             numOfBytes;
input                                       dataValidExtDscrptr;

// extDscrptrFetch inputs
input                                       extRdyValid;
input                                       extRdy;

// AXI4MasterCtrl inputs
input                                       rdTranDone;
input                                       rdTranError;
input                                       numOfBytesInRdValid_AXI4MasterCtrl;

// intErrorCtrl inputs
input                                       rdDoneAck;
input                                       rdErrorAck;
input                                       extDataValidNSetAck;
input                                       noOpSrcAck;

// extDscrptrFetch outputs
output                                      extRdyCheck;
output     [31:0]                           extDscrptrAddr_ExtDscrptrFetch;

// intErrorCtrl outputs
output                                      rdDone;
output                                      rdError;

// AXI4MasterCtrl outputs
output                                      strtAXIRdTran;
output     [MAX_TRAN_SIZE_WIDTH-1:0]        srcNumOfBytes;
output     [1:0]                            srcAXITranType;
output     [2:0]                            srcAXIDataWidth;
output     [31:0]                           srcStrtAddr;
output     [MAX_AXI_NUM_BEATS_WIDTH-1:0]    srcMaxAXINumBeats;

// transAck outputs
output                                      rdyToAck;
output                                      extDataValid;

// intErrorCtrlFSM outputs
output                                      extDataValidNSet;
output                                      noOpSrc;

////////////////////////////////////////////////////////////////////////////////
// Internal signals
////////////////////////////////////////////////////////////////////////////////
reg [7:0]                                   currState;
reg [7:0]                                   nextState;
reg                                         rdDoneReg;
reg                                         rdDoneReg_d;
reg                                         rdErrorReg;
reg                                         rdErrorReg_d;
reg                                         extRdyCheckReg;
reg                                         extRdyCheckReg_d;
reg [31:0]                                  extDscrptrAddr_ExtDscrptrFetchReg;
reg [31:0]                                  extDscrptrAddr_ExtDscrptrFetchReg_d;
reg                                         strtAXIRdTranReg;
reg                                         strtAXIRdTranReg_d;
reg [MAX_TRAN_SIZE_WIDTH-1:0]               srcNumOfBytesReg;
reg [MAX_TRAN_SIZE_WIDTH-1:0]               srcNumOfBytesReg_d;
reg [31:0]                                  srcStrtAddrReg;
reg [31:0]                                  srcStrtAddrReg_d;
reg [1:0]                                   srcAXITranTypeReg;
reg [1:0]                                   srcAXITranTypeReg_d;
reg [2:0]                                   srcAXIDataWidthReg;
reg [2:0]                                   srcAXIDataWidthReg_d;
reg                                         rdyToAckReg;
reg                                         rdyToAckReg_d;
reg                                         extDataValidReg;
reg                                         extDataValidReg_d;
reg                                         extDataValidNSetReg;
reg                                         extDataValidNSetReg_d;
reg [MAX_AXI_NUM_BEATS_WIDTH-1:0]           srcMaxAXINumBeatsReg;
reg [MAX_AXI_NUM_BEATS_WIDTH-1:0]           srcMaxAXINumBeatsReg_d;
reg                                         noOpSrcReg;
reg                                         noOpSrcReg_d;

////////////////////////////////////////////////////////////////////////////////
// Constants
////////////////////////////////////////////////////////////////////////////////
localparam [7:0] IDLE                 = 8'b00000001;
localparam [7:0] WAIT_EXT_RDY_CHECK   = 8'b00000010;
localparam [7:0] WAIT_DMA_DONE        = 8'b00000100;
localparam [7:0] WAIT_RDDONE_ACK      = 8'b00001000;
localparam [7:0] WAIT_RDERROR_ACK     = 8'b00010000;
localparam [7:0] WAIT_EXT_N_VALID_ACK = 8'b00100000;
localparam [7:0] WAIT_NO_OF_BYTE      = 8'b01000000;
localparam [7:0] WAIT_NOP_ACK         = 8'b10000000;

////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                currState <= IDLE;
            end
        else
            begin
                currState <= nextState;
            end
    end

always @ (*)
    begin
        // Default assigments
        extRdyCheckReg_d                    <= 1'b0;
        extDscrptrAddr_ExtDscrptrFetchReg_d <= 32'b0;
        strtAXIRdTranReg_d                  <= 1'b0;
        srcNumOfBytesReg_d                  <= {MAX_TRAN_SIZE_WIDTH{1'b0}};
        srcStrtAddrReg_d                    <= 32'b0;
        srcAXITranTypeReg_d                 <= 2'b0;
        srcAXIDataWidthReg_d                <= 3'b0;
        rdyToAckReg_d                       <= 1'b0;
        extDataValidReg_d                   <= 1'b0;
        rdDoneReg_d                         <= 1'b0;
        rdErrorReg_d                        <= 1'b0;
        extDataValidNSetReg_d               <= 1'b0;
        srcMaxAXINumBeatsReg_d              <= {MAX_AXI_NUM_BEATS_WIDTH{1'b0}};
        noOpSrcReg_d                        <= 1'b0;
        case (currState)
            IDLE:
                begin
                    if (reqInQueue)
                        begin
                            if (srcOp == 2'b00)
                                begin
                                    rdyToAckReg_d     <= 1'b1;
                                    extDataValidReg_d <= 1'b1;
                                    noOpSrcReg_d      <= 1'b1; 
                                    nextState         <= WAIT_NOP_ACK;
                                end
                            else if (extDscrptr)
                                begin
                                    if (dataValidExtDscrptr)
                                        begin
                                            // The external descriptor is valid so handle the
                                            // DMA request as normal
                                            strtAXIRdTranReg_d   <= 1'b1;
                                            srcStrtAddrReg_d     <= srcAddr;
                                            srcAXITranTypeReg_d  <= srcOp;
                                            srcAXIDataWidthReg_d <= srcDataWidth;
                                            srcNumOfBytesReg_d   <= numOfBytes;
                                            nextState            <= WAIT_NO_OF_BYTE;
                                            if (priLvl == 8'b00000001)
                                                begin
                                                    srcMaxAXINumBeatsReg_d <= PRI_0_NUM_OF_BEATS;
                                                end
                                            else if (priLvl == 8'b00000010)
                                                begin
                                                    srcMaxAXINumBeatsReg_d <= PRI_1_NUM_OF_BEATS;
                                                end
                                            else if (priLvl == 8'b00000100)
                                                begin
                                                    srcMaxAXINumBeatsReg_d <= PRI_2_NUM_OF_BEATS;
                                                end
                                            else if (priLvl == 8'b00001000)
                                                begin
                                                    srcMaxAXINumBeatsReg_d <= PRI_3_NUM_OF_BEATS;
                                                end
                                            else if (priLvl == 8'b00010000)
                                                begin
                                                    srcMaxAXINumBeatsReg_d <= PRI_4_NUM_OF_BEATS;
                                                end
                                            else if (priLvl == 8'b00100000)
                                                begin
                                                    srcMaxAXINumBeatsReg_d <= PRI_5_NUM_OF_BEATS;
                                                end
                                            else if (priLvl == 8'b01000000)
                                                begin
                                                    srcMaxAXINumBeatsReg_d <= PRI_6_NUM_OF_BEATS;
                                                end
                                            else
                                                begin
                                                    srcMaxAXINumBeatsReg_d <= PRI_7_NUM_OF_BEATS;
                                                end
                                        end
                                    else
                                        begin
                                            // Fetch the data valid bit from the external
                                            // descriptor to check that it's valid as it
                                            // wasn't at the last attempt
                                            extRdyCheckReg_d                    <= 1'b1;
                                            extDscrptrAddr_ExtDscrptrFetchReg_d <= extDscrptrAddr;
                                            nextState                           <= WAIT_EXT_RDY_CHECK;
                                        end
                                end
                            else
                                begin
                                    // This is an internal descriptor
                                    strtAXIRdTranReg_d     <= 1'b1;
                                    srcStrtAddrReg_d       <= srcAddr;
                                    srcAXITranTypeReg_d    <= srcOp;
                                    srcAXIDataWidthReg_d   <= srcDataWidth;
                                    srcNumOfBytesReg_d     <= numOfBytes;
                                    nextState              <= WAIT_NO_OF_BYTE;
                                    if (priLvl == 8'b00000001)
                                        begin
                                            srcMaxAXINumBeatsReg_d <= PRI_0_NUM_OF_BEATS;
                                        end
                                    else if (priLvl == 8'b00000010)
                                        begin
                                            srcMaxAXINumBeatsReg_d <= PRI_1_NUM_OF_BEATS;
                                        end
                                    else if (priLvl == 8'b00000100)
                                        begin
                                            srcMaxAXINumBeatsReg_d <= PRI_2_NUM_OF_BEATS;
                                        end
                                    else if (priLvl == 8'b00001000)
                                        begin
                                            srcMaxAXINumBeatsReg_d <= PRI_3_NUM_OF_BEATS;
                                        end
                                    else if (priLvl == 8'b00010000)
                                        begin
                                            srcMaxAXINumBeatsReg_d <= PRI_4_NUM_OF_BEATS;
                                        end
                                    else if (priLvl == 8'b00100000)
                                        begin
                                            srcMaxAXINumBeatsReg_d <= PRI_5_NUM_OF_BEATS;
                                        end
                                    else if (priLvl == 8'b01000000)
                                        begin
                                            srcMaxAXINumBeatsReg_d <= PRI_6_NUM_OF_BEATS;
                                        end
                                    else
                                        begin
                                            srcMaxAXINumBeatsReg_d <= PRI_7_NUM_OF_BEATS;
                                        end
                                end
                        end
                    else
                        begin
                            nextState <= IDLE;
                        end
                end
            WAIT_NOP_ACK:
                begin
                    if (noOpSrcAck)
                        begin
                            nextState <= IDLE;
                        end
                    else
                        begin
                            noOpSrcReg_d <= 1'b1;
                            nextState    <= WAIT_NOP_ACK;
                        end
                end
            WAIT_EXT_RDY_CHECK:
                begin
                    if (extRdyValid)
                        begin
                            if (extRdy)
                                begin
                                    // The external descriptor is now ready so proceed with
                                    // the DMA transfer
                                    strtAXIRdTranReg_d     <= 1'b1;
                                    srcStrtAddrReg_d       <= srcAddr;
                                    srcAXITranTypeReg_d    <= srcOp;
                                    srcAXIDataWidthReg_d   <= srcDataWidth;
                                    srcNumOfBytesReg_d     <= numOfBytes;
                                    if (priLvl == 8'b00000001)
                                        begin
                                            srcMaxAXINumBeatsReg_d <= PRI_0_NUM_OF_BEATS;
                                        end
                                    else if (priLvl == 8'b00000010)
                                        begin
                                            srcMaxAXINumBeatsReg_d <= PRI_1_NUM_OF_BEATS;
                                        end
                                    else if (priLvl == 8'b00000100)
                                        begin
                                            srcMaxAXINumBeatsReg_d <= PRI_2_NUM_OF_BEATS;
                                        end
                                    else if (priLvl == 8'b00001000)
                                        begin
                                            srcMaxAXINumBeatsReg_d <= PRI_3_NUM_OF_BEATS;
                                        end
                                    else if (priLvl == 8'b00010000)
                                        begin
                                            srcMaxAXINumBeatsReg_d <= PRI_4_NUM_OF_BEATS;
                                        end
                                    else if (priLvl == 8'b00100000)
                                        begin
                                            srcMaxAXINumBeatsReg_d <= PRI_5_NUM_OF_BEATS;
                                        end
                                    else if (priLvl == 8'b01000000)
                                        begin
                                            srcMaxAXINumBeatsReg_d <= PRI_6_NUM_OF_BEATS;
                                        end
                                    else
                                        begin
                                            srcMaxAXINumBeatsReg_d <= PRI_7_NUM_OF_BEATS;
                                        end
                                    if (numOfBytesInRdValid_AXI4MasterCtrl)
                                        begin
                                            rdyToAckReg_d     <= 1'b1;
                                            extDataValidReg_d <= 1'b1;
                                            nextState         <= WAIT_DMA_DONE;
                                        end
                                    else 
                                        begin
                                            nextState <= WAIT_NO_OF_BYTE;
                                        end
                                end
                            else
                                begin
                                    // The external descriptor isn't valid so don't perform
                                    // any DMA operation on the descriptor. 
                                    rdyToAckReg_d         <= 1'b1;
                                    extDataValidNSetReg_d <= 1'b1;
                                    nextState             <= WAIT_EXT_N_VALID_ACK;
                                end
                        end
                    else
                        begin
                            // Wait on the data ready fetch to return
                            extRdyCheckReg_d                    <= 1'b1;
                            extDscrptrAddr_ExtDscrptrFetchReg_d <= extDscrptrAddr;
                            nextState                           <= WAIT_EXT_RDY_CHECK;
                        end
                end
            WAIT_NO_OF_BYTE:
                begin
                    if (numOfBytesInRdValid_AXI4MasterCtrl)
                        begin
                            rdyToAckReg_d     <= 1'b1;
                            extDataValidReg_d <= 1'b1;
                            nextState         <= WAIT_DMA_DONE;
                        end
                    else
                        begin
                            nextState <= WAIT_NO_OF_BYTE;
                        end
                end
            WAIT_DMA_DONE:
                begin
                    if (rdTranDone)
                        begin
                            rdDoneReg_d <= 1'b1;
                            nextState   <= WAIT_RDDONE_ACK;
                        end
                    else if (rdTranError)
                        begin
                            rdErrorReg_d <= 1'b1;
                            nextState    <= WAIT_RDERROR_ACK;
                        end
                    else
                        begin
                            nextState <= WAIT_DMA_DONE;
                        end
                end
            WAIT_RDDONE_ACK:
                begin
                    if (rdDoneAck)
                        begin
                            nextState <= IDLE;
                        end
                    else
                        begin
                            rdDoneReg_d <= 1'b1;
                            nextState   <= WAIT_RDDONE_ACK;
                        end
                end
            WAIT_RDERROR_ACK:
                begin
                    if (rdErrorAck)
                        begin
                            nextState <= IDLE;
                        end
                    else
                        begin
                            rdErrorReg_d <= 1'b1;
                            nextState    <= WAIT_RDERROR_ACK;
                        end
                end
            WAIT_EXT_N_VALID_ACK:
                begin
                    // Keep the extDataValidNSet signal asserted until it is
                    // handled by the intErrorCtrl FSM. This allows a request
                    // from an external descriptor to be removed from the queues
                    // if its data valid bit is not asserted after polling
                    if (extDataValidNSetAck)
                        begin
                            nextState <= IDLE;
                        end
                    else
                        begin
                            extDataValidNSetReg_d <= 1'b1;
                            nextState             <= WAIT_EXT_N_VALID_ACK;
                        end
                end
            default:
                begin
                    nextState <= IDLE;
                end
        endcase
    end

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                rdDoneReg <= 1'b0;
            end
        else
            begin
                rdDoneReg <= rdDoneReg_d;
            end
    end
assign rdDone = rdDoneReg;

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                rdErrorReg <= 1'b0;
            end
        else
            begin
                rdErrorReg <= rdErrorReg_d;
            end
    end
assign rdError = rdErrorReg;

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                extRdyCheckReg <= 1'b0;
            end
        else
            begin
                extRdyCheckReg <= extRdyCheckReg_d;
            end
    end
assign extRdyCheck = extRdyCheckReg;

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                extDscrptrAddr_ExtDscrptrFetchReg <= 32'b0;
            end
        else
            begin
                extDscrptrAddr_ExtDscrptrFetchReg <= extDscrptrAddr_ExtDscrptrFetchReg_d;
            end
    end
assign extDscrptrAddr_ExtDscrptrFetch = extDscrptrAddr_ExtDscrptrFetchReg;

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                strtAXIRdTranReg <= 1'b0;
            end
        else
            begin
                strtAXIRdTranReg <= strtAXIRdTranReg_d;
            end
    end
assign strtAXIRdTran = strtAXIRdTranReg;

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                srcNumOfBytesReg <= {MAX_TRAN_SIZE_WIDTH{1'b0}};
            end
        else
            begin
                srcNumOfBytesReg <= srcNumOfBytesReg_d;
            end
    end
assign srcNumOfBytes = srcNumOfBytesReg;

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                srcStrtAddrReg <= 32'b0;
            end
        else
            begin
                srcStrtAddrReg <= srcStrtAddrReg_d;
            end
    end
assign srcStrtAddr = srcStrtAddrReg;

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                srcAXITranTypeReg <= 2'b0;
            end
        else
            begin
                srcAXITranTypeReg <= srcAXITranTypeReg_d;
            end
    end
assign srcAXITranType = srcAXITranTypeReg;

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                srcAXIDataWidthReg <= 3'b0;
            end
        else
            begin
                srcAXIDataWidthReg <= srcAXIDataWidthReg_d;
            end
    end
assign srcAXIDataWidth = srcAXIDataWidthReg;

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                rdyToAckReg <= 1'b0;
            end
        else
            begin
                rdyToAckReg <= rdyToAckReg_d;
            end
    end
assign rdyToAck = rdyToAckReg;

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                extDataValidReg <= 1'b0;
            end
        else
            begin
                extDataValidReg <= extDataValidReg_d;
            end
    end
assign extDataValid = extDataValidReg;

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                extDataValidNSetReg <= 1'b0;
            end
        else
            begin
                extDataValidNSetReg <= extDataValidNSetReg_d;
            end
    end
assign extDataValidNSet = extDataValidNSetReg;

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                srcMaxAXINumBeatsReg <= {MAX_AXI_NUM_BEATS_WIDTH{1'b0}};
            end
        else
            begin
                srcMaxAXINumBeatsReg <= srcMaxAXINumBeatsReg_d;
            end
    end
assign srcMaxAXINumBeats = srcMaxAXINumBeatsReg;

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                noOpSrcReg <= 1'b0;
            end
        else
            begin
                noOpSrcReg <= noOpSrcReg_d;
            end
    end
assign noOpSrc = noOpSrcReg;

endmodule // rdTranCtrl