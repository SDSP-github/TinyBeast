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
module CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_transAck (
    // General inputs
    clock,
    resetn,
        
    // DMAArbiter inputs
    doTrans,
        
    // DscrptrSrcMux inputs
    intFetchAck,
    
    // DMAWrTranCtrl inputs
    strRdyToAck,
    dstAXINumOfBytes,
    strDataNReady,
    
    // DMARdTranCtrl inputs
    rdyToAck,
    extDataValid_DMARdTranCtrl,
    srcAXINumOfBytes,
    
    // WrTranQueue inputs
    spaceWrTranQueue,
    dstOp,
    dstAddr_WrTranQueue,
    numOfBytes_WrTranQueue,
    
    // RdTranQueue inputs
    spaceRdTranQueue,
    chain,
    extDscrptrNxt,
    extDscrptr,
    srcOp,
    srcAddr_RdTranQueue,
    numOfBytes_RdTranQueue,
    intDscrptrNum_RdTranQueue0,
    intDscrptrNum_RdTranQueue1,
    nxtIntDscrptrNum_rdTranQueue,

    // intErrorCtrl inputs
    rdCache1Sel,
    
    // DMAARbiter outputs
    transAck,
    strDscrptr,
    extDataValid,
    newNumOfBytes,
    newSrcAddr,
    newDstAddr,
    
    // DscrptrSrcMux outputs
    fetchIntDscrptr,
    intDscrptrNum
);

////////////////////////////////////////////////////////////////////////////////
// User modifiable parameters
////////////////////////////////////////////////////////////////////////////////
parameter NUM_INT_BDS_WIDTH       = 2;
parameter MAX_TRAN_SIZE_WIDTH     = 4;
parameter MAX_AXI_TRAN_SIZE_WIDTH = 13; // 4 KB
parameter AXI4_STREAM_IF          = 0;
 
////////////////////////////////////////////////////////////////////////////////
// Port directions
////////////////////////////////////////////////////////////////////////////////
// General inputs
input                                   clock;
input                                   resetn;
    
// DMAArbiter inputs
input                                   doTrans;
    
// DscrptrSrcMux inputs
input                                   intFetchAck;

// DMAWrTranCtrl inputs
input                                   strRdyToAck;
input  [MAX_AXI_TRAN_SIZE_WIDTH-1:0]    dstAXINumOfBytes;
input                                   strDataNReady;

// DMARdTranCtrl inputs
input                                   rdyToAck;
input                                   extDataValid_DMARdTranCtrl;
input  [MAX_AXI_TRAN_SIZE_WIDTH-1:0]    srcAXINumOfBytes;

// WrTranQueue inputs
input                                   spaceWrTranQueue;
input  [1:0]                            dstOp;
input  [31:0]                           dstAddr_WrTranQueue;
input  [MAX_TRAN_SIZE_WIDTH-1:0]        numOfBytes_WrTranQueue;

// RdTranQueue inputs
input                                   spaceRdTranQueue;
input  [NUM_INT_BDS_WIDTH-1:0]          intDscrptrNum_RdTranQueue0;
input  [NUM_INT_BDS_WIDTH-1:0]          intDscrptrNum_RdTranQueue1;
input                                   chain;
input                                   extDscrptrNxt;
input                                   extDscrptr;
input  [1:0]                            srcOp;
input  [31:0]                           srcAddr_RdTranQueue;
input  [MAX_TRAN_SIZE_WIDTH-1:0]        numOfBytes_RdTranQueue;
input  [NUM_INT_BDS_WIDTH-1:0]          nxtIntDscrptrNum_rdTranQueue;

// intErrorCtrl inputs
input                                   rdCache1Sel;

// DMAARbiter outputs
output                                  transAck;
output                                  strDscrptr;
output                                  extDataValid;
output     [MAX_TRAN_SIZE_WIDTH-1:0]    newNumOfBytes;
output     [31:0]                       newSrcAddr;
output     [31:0]                       newDstAddr;

// DscrptrSrcMux outputs
output                                  fetchIntDscrptr;
output     [NUM_INT_BDS_WIDTH-1:0]      intDscrptrNum;

////////////////////////////////////////////////////////////////////////////////
// Internal signals
////////////////////////////////////////////////////////////////////////////////
reg  [2:0]                              currState;
reg  [2:0]                              nextState;
reg                                     transAckReg;
reg                                     transAckReg_d;
reg                                     extDataValidReg;
reg                                     extDataValidReg_d;
reg  [MAX_TRAN_SIZE_WIDTH-1:0]          newNumOfBytesReg;
reg  [MAX_TRAN_SIZE_WIDTH-1:0]          newNumOfBytesReg_d;
reg  [31:0]                             newSrcAddrReg;
reg  [31:0]                             newSrcAddrReg_d;
reg  [31:0]                             newDstAddrReg;
reg  [31:0]                             newDstAddrReg_d;

// DscrptrSrcMux outputs
reg                                     fetchIntDscrptrReg;
reg                                     fetchIntDscrptrReg_d;
reg  [NUM_INT_BDS_WIDTH-1:0]            intDscrptrNumReg;
reg  [NUM_INT_BDS_WIDTH-1:0]            intDscrptrNumReg_d;
reg                                     strDscrptrReg;
reg                                     strDscrptrReg_d;

////////////////////////////////////////////////////////////////////////////////
// Constants
////////////////////////////////////////////////////////////////////////////////
// FSM state encoding
localparam [2:0] IDLE                   = 3'b001;
localparam [2:0] WAIT_TRANS_RDY         = 3'b010;
localparam [2:0] WAIT_INT_DSCRPTR_FETCH = 3'b100;

// DMA trasaction types
localparam [1:0] INCR_ADDR_OP           = 2'b01;

////////////////////////////////////////////////////////////////////////////////
// Current state register
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

////////////////////////////////////////////////////////////////////////////////
// Next state combinatorial & asynchronous output logic
//////////////////////////////////////////////////////////////////////////////// 
always @ (*)
    begin
        // Default assignments
        fetchIntDscrptrReg_d <= 1'b0;
        intDscrptrNumReg_d   <= intDscrptrNumReg;
        extDataValidReg_d    <= extDataValidReg;
        transAckReg_d        <= 1'b0;
        newNumOfBytesReg_d   <= newNumOfBytesReg;
        newSrcAddrReg_d      <= newSrcAddrReg;
        newDstAddrReg_d      <= newDstAddrReg;
        strDscrptrReg_d      <= 1'b0;
        case (currState)
            IDLE:
                begin
                    if (doTrans)
                        begin
                            if (spaceWrTranQueue & spaceRdTranQueue)
                                begin
                                    nextState <= WAIT_TRANS_RDY;
                                end
                            else
                                begin
                                    // The read and write pipelines are still full
                                    // so the new transfer can't be ack'ed yet.
                                    nextState <= IDLE;
                                end
                        end
                    else
                        begin
                            nextState <= IDLE;
                        end
                end
            WAIT_TRANS_RDY:
                begin
                    if (rdyToAck)
                        begin
                            transAckReg_d     <= 1'b1;
                            strDscrptrReg_d   <= 1'b0;
                            extDataValidReg_d <= extDataValid_DMARdTranCtrl;
                            if (srcOp == 2'b00)
                                begin
                                    newNumOfBytesReg_d <= {MAX_TRAN_SIZE_WIDTH{1'b0}};
                                    newSrcAddrReg_d    <= srcAddr_RdTranQueue;
                                    newDstAddrReg_d    <= dstAddr_WrTranQueue;
                                    if (chain)
                                        begin
                                            if (!extDscrptrNxt)
                                                begin
                                                    fetchIntDscrptrReg_d <= 1'b1;
                                                    intDscrptrNumReg_d   <= nxtIntDscrptrNum_rdTranQueue;
                                                    nextState            <= WAIT_INT_DSCRPTR_FETCH;
                                                end
                                            else
                                                begin
                                                    nextState <= IDLE;
                                                end
                                        end
                                    else
                                        begin
                                            nextState <= IDLE;
                                        end
                                end
                            else if (extDscrptr)
                                begin
                                    if (extDataValid_DMARdTranCtrl)
                                        begin
                                            newNumOfBytesReg_d <= numOfBytes_RdTranQueue - srcAXINumOfBytes;
                                            if (srcOp == INCR_ADDR_OP) // Incrementing address
                                                begin
                                                    newSrcAddrReg_d <= srcAddr_RdTranQueue + srcAXINumOfBytes;
                                                end
                                            else // Fixed address or unrelated operation
                                                begin
                                                    newSrcAddrReg_d <= srcAddr_RdTranQueue;
                                                end
                                            if (dstOp == INCR_ADDR_OP) // Incrementing address
                                                begin
                                                    newDstAddrReg_d <= dstAddr_WrTranQueue + srcAXINumOfBytes;
                                                end
                                            else // Fixed address or unrelated operation
                                                begin
                                                    newDstAddrReg_d <= dstAddr_WrTranQueue;
                                                end
                                            if (numOfBytes_RdTranQueue == {{(MAX_TRAN_SIZE_WIDTH - MAX_AXI_TRAN_SIZE_WIDTH){1'b0}}, srcAXINumOfBytes})
                                                begin
                                                    if (chain)
                                                        begin
                                                            if (!extDscrptrNxt)
                                                                begin
                                                                    fetchIntDscrptrReg_d <= 1'b1;
                                                                    intDscrptrNumReg_d   <= nxtIntDscrptrNum_rdTranQueue;
                                                                    nextState            <= WAIT_INT_DSCRPTR_FETCH;
                                                                end
                                                            else
                                                                begin
                                                                    nextState <= IDLE;
                                                                end
                                                        end
                                                    else
                                                        begin
                                                            nextState <= IDLE;
                                                        end
                                                end
                                            else
                                                begin
                                                    nextState <= IDLE;
                                                end
                                        end
                                    else
                                        begin
                                            // The external descriptor data ready bit wasn't
                                            // detected as being set when fetched. No DMA transfer
                                            // was attempted so don't change the operation.
                                            newNumOfBytesReg_d <= numOfBytes_RdTranQueue;
                                            newSrcAddrReg_d    <= srcAddr_RdTranQueue;
                                            newDstAddrReg_d    <= dstAddr_WrTranQueue;
                                            nextState          <= IDLE;
                                        end
                                end
                            else
                                begin
                                    // Operating on an internal descriptor
                                    newNumOfBytesReg_d <= numOfBytes_RdTranQueue - srcAXINumOfBytes;
                                    if (srcOp == INCR_ADDR_OP) // Incrementing address
                                        begin
                                            newSrcAddrReg_d <= srcAddr_RdTranQueue + srcAXINumOfBytes;
                                        end
                                    else // Fixed address or unrelated operation
                                        begin
                                            newSrcAddrReg_d <= srcAddr_RdTranQueue;
                                        end
                                    if (dstOp == INCR_ADDR_OP) // Incrementing address
                                        begin
                                            newDstAddrReg_d <= dstAddr_WrTranQueue + srcAXINumOfBytes;
                                        end
                                    else // Fixed address or unrelated operation
                                        begin
                                            newDstAddrReg_d <= dstAddr_WrTranQueue;
                                        end
                                    if (numOfBytes_RdTranQueue == {{(MAX_TRAN_SIZE_WIDTH - MAX_AXI_TRAN_SIZE_WIDTH){1'b0}}, srcAXINumOfBytes})
                                        begin
                                            if (chain)
                                                begin
                                                    if (!extDscrptrNxt)
                                                        begin
                                                            fetchIntDscrptrReg_d <= 1'b1;
                                                            intDscrptrNumReg_d   <= nxtIntDscrptrNum_rdTranQueue;
                                                            nextState            <= WAIT_INT_DSCRPTR_FETCH;
                                                        end
                                                    else
                                                        begin
                                                            nextState <= IDLE;
                                                        end
                                                end
                                            else
                                                begin
                                                    nextState <= IDLE;
                                                end
                                        end
                                    else
                                        begin
                                            nextState <= IDLE;
                                        end
                                end
                        end
                    else if ((strRdyToAck == 1'b1) && (AXI4_STREAM_IF == 1))
                        begin
                            transAckReg_d      <= 1'b1;
                            strDscrptrReg_d    <= 1'b1;
                            extDataValidReg_d  <= 1'b1;
                            newNumOfBytesReg_d <= {MAX_TRAN_SIZE_WIDTH{1'b0}};
                            nextState          <= IDLE;
                            if (dstOp == INCR_ADDR_OP) // Incrementing address
                                begin
                                    newDstAddrReg_d <= dstAddr_WrTranQueue + dstAXINumOfBytes;
                                end
                            else // Fixed address or unrelated operation
                                begin
                                    newDstAddrReg_d <= dstAddr_WrTranQueue;
                                end
                        end
                    else if ((strDataNReady == 1'b1) && (AXI4_STREAM_IF == 1))
                        begin
                            transAckReg_d      <= 1'b1;
                            strDscrptrReg_d    <= 1'b1;
                            extDataValidReg_d  <= 1'b0;
                            newNumOfBytesReg_d <= numOfBytes_WrTranQueue;
                            newDstAddrReg_d    <= dstAddr_WrTranQueue;
                            newDstAddrReg_d    <= dstAddr_WrTranQueue;
                            nextState          <= IDLE;
                        end
                    else
                        begin
                            nextState <= WAIT_TRANS_RDY;
                        end
                end
            WAIT_INT_DSCRPTR_FETCH:
                begin
                    if (intFetchAck)
                        begin
                            nextState <= IDLE;
                        end
                    else
                        begin
                            fetchIntDscrptrReg_d <= 1'b1;
                            nextState            <= WAIT_INT_DSCRPTR_FETCH;
                        end
                end
            default:
                begin
                    nextState <= IDLE;
                end
        endcase
    end

////////////////////////////////////////////////////////////////////////////////
// transAck register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                transAckReg <= 1'b0;
            end
        else
            begin
                transAckReg <= transAckReg_d;
            end
    end
assign transAck = transAckReg;

////////////////////////////////////////////////////////////////////////////////
// extDataValid register
////////////////////////////////////////////////////////////////////////////////
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

////////////////////////////////////////////////////////////////////////////////
// newNumOfBytes register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                newNumOfBytesReg <= {MAX_TRAN_SIZE_WIDTH{1'b0}};
            end
        else
            begin
                newNumOfBytesReg <= newNumOfBytesReg_d;
            end
    end
assign newNumOfBytes = newNumOfBytesReg;

////////////////////////////////////////////////////////////////////////////////
// newSrcAddr register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                newSrcAddrReg <= 32'b0;
            end
        else
            begin
                newSrcAddrReg <= newSrcAddrReg_d;
            end
    end
assign newSrcAddr = newSrcAddrReg;

////////////////////////////////////////////////////////////////////////////////
// newDstAddr register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                newDstAddrReg <= 32'b0;
            end
        else
            begin
                newDstAddrReg <= newDstAddrReg_d;
            end
    end
assign newDstAddr = newDstAddrReg;

////////////////////////////////////////////////////////////////////////////////
// fetchIntDscrptr register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                fetchIntDscrptrReg <= 1'b0;
            end
        else
            begin
                fetchIntDscrptrReg <= fetchIntDscrptrReg_d;
            end
    end
assign fetchIntDscrptr = fetchIntDscrptrReg;

////////////////////////////////////////////////////////////////////////////////
// intDscrptrNum register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                intDscrptrNumReg <= {NUM_INT_BDS_WIDTH{1'b0}};
            end
        else
            begin
                intDscrptrNumReg <= intDscrptrNumReg_d;
            end
    end
assign intDscrptrNum = intDscrptrNumReg;

////////////////////////////////////////////////////////////////////////////////
// strDscrptr register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                strDscrptrReg <= 1'b0;
            end
        else
            begin
                strDscrptrReg <= strDscrptrReg_d;
            end
    end
assign strDscrptr = strDscrptrReg;

endmodule // transAck