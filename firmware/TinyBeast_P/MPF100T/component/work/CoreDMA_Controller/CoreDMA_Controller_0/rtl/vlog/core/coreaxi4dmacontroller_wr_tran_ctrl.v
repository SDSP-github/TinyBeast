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
module CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_wrTranCtrl (
    // General inputs
    clock,
    resetn,
    
    // wrTranQueue inputs
    reqInQueue,
    numOfBytes,
    strDscrptr,
    dataValid,
    priLvl,
    srcDataWidth,
    dstOp,
    dstDataWidth,
    dstAddr,
    extDscrptrAddr,
    
    // rdNumOfBytes register
    numOfBytesInRdValid_rdNumOfBytesReg,
    numOfBytesInRd_rdNumOfBytesReg,
    
    // AXI4MasterCtrl inputs
    wrTranDone,
    wrTranError,
    strWrTranDone,
    strWrTranError,
    strFetchAck,
    strDataValid,
    
    // intErrorCtrl inputs
    wrDoneAck,
    wrErrorAck,
    strWrDoneAck,
    strWrErrorAck,
    noOpDstAck,
    
    // intErrorCtrl outputs
    wrDone,
    wrError,
    strWrDone,
    strWrError,
    noOpDst,
    
    // AXI4MasterCtrl outputs
    dstMaxAXINumBeats,
    dstStrDscrptr,
    numOfBytesInRd,
    strtAXIWrTran,
    dstAXITranType,
    dstAXIDataWidth,
    dstStrtAddr,
    srcAXIDataWidth,
    strFetchRdy,
    strFetchAddr,
    
    //transAck outputs
    strDataNReady
);
////////////////////////////////////////////////////////////////////////////////
// Parameters
////////////////////////////////////////////////////////////////////////////////
parameter NUM_PRI_LVLS              = 1;
parameter MAX_TRAN_SIZE_WIDTH       = 0;
parameter MAX_AXI_TRAN_SIZE_WIDTH   = 13; // 4 KB
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

// wrTranQueue inputs
input                                       reqInQueue;
input [MAX_TRAN_SIZE_WIDTH-1:0]             numOfBytes;
input                                       strDscrptr;
input [NUM_PRI_LVLS-1:0]                    priLvl;
input                                       dataValid;
input [2:0]                                 srcDataWidth;
input [1:0]                                 dstOp;
input [2:0]                                 dstDataWidth;
input [31:0]                                dstAddr;
input [31:0]                                extDscrptrAddr;
    
// rdNumOfBytes register inputs
input                                       numOfBytesInRdValid_rdNumOfBytesReg;
input [MAX_AXI_TRAN_SIZE_WIDTH-1:0]         numOfBytesInRd_rdNumOfBytesReg;

// AXI4MasterCtrl inputs
input                                       wrTranDone;
input                                       wrTranError;
input                                       strWrTranDone;
input                                       strWrTranError;
input                                       strFetchAck;
input                                       strDataValid;

// intErrorCtrl inputs
input                                       wrDoneAck;
input                                       wrErrorAck;
input                                       strWrDoneAck;
input                                       strWrErrorAck;
input                                       noOpDstAck;

// intErrorCtrl outputs
output                                      wrDone;
output                                      wrError;
output                                      strWrDone;
output                                      strWrError;
output                                      noOpDst;

// AXI4MasterCtrl outputs
output                                      strtAXIWrTran;
output [1:0]                                dstAXITranType;
output [2:0]                                dstAXIDataWidth;
output [31:0]                               dstStrtAddr;
output [2:0]                                srcAXIDataWidth;   // Required for the AXI4MasterCtrl write logic
                                                               // to know the number of valid bytes within a
                                                               // cache location in the memoryMapCache block.
output [MAX_TRAN_SIZE_WIDTH-1:0]            numOfBytesInRd;    // Number of bytes in the read transfer associated with this write
output [MAX_AXI_NUM_BEATS_WIDTH-1:0]        dstMaxAXINumBeats; // Maximum number of beats in an AXI burst
                                                               // permitted at this priority level.
output                                      dstStrDscrptr;
output reg                                  strFetchRdy;
output reg [31:0]                           strFetchAddr;

output                                      strDataNReady;

////////////////////////////////////////////////////////////////////////////////
// Internal signals
////////////////////////////////////////////////////////////////////////////////
reg [8:0]                                   currState;
reg [8:0]                                   nextState;
reg                                         wrDoneReg;
reg                                         wrDoneReg_d;
reg                                         wrErrorReg;
reg                                         wrErrorReg_d;
reg                                         strWrDoneReg;
reg                                         strWrDoneReg_d;
reg                                         strWrErrorReg;
reg                                         strWrErrorReg_d;
reg                                         strtAXIWrTranReg;
reg                                         strtAXIWrTranReg_d;
reg [31:0]                                  dstStrtAddrReg;
reg [31:0]                                  dstStrtAddrReg_d;
reg [1:0]                                   dstAXITranTypeReg;
reg [1:0]                                   dstAXITranTypeReg_d;
reg [2:0]                                   dstAXIDataWidthReg;
reg [2:0]                                   dstAXIDataWidthReg_d;
reg [2:0]                                   srcAXIDataWidthReg;
reg [2:0]                                   srcAXIDataWidthReg_d;
reg [MAX_TRAN_SIZE_WIDTH-1:0]               numOfBytesInRdReg;
reg [MAX_TRAN_SIZE_WIDTH-1:0]               numOfBytesInRdReg_d;
reg [MAX_AXI_NUM_BEATS_WIDTH-1:0]           dstMaxAXINumBeatsReg;
reg [MAX_AXI_NUM_BEATS_WIDTH-1:0]           dstMaxAXINumBeatsReg_d;
reg                                         dstStrDscrptrReg;
reg                                         dstStrDscrptrReg_d;
reg                                         strDataNReadyReg;
reg                                         strDataNReadyReg_d;
reg                                         noOpDstReg;
reg                                         noOpDstReg_d;

////////////////////////////////////////////////////////////////////////////////
// Constants
////////////////////////////////////////////////////////////////////////////////
localparam [8:0] IDLE                   = 9'b000000001;
localparam [8:0] WAIT_STR_DONE          = 9'b000000010;
localparam [8:0] WAIT_DMA_DONE          = 9'b000000100;
localparam [8:0] WAIT_STR_WRDONE_ACK    = 9'b000001000;
localparam [8:0] WAIT_STR_WRERROR_ACK   = 9'b000010000;
localparam [8:0] WAIT_WRDONE_ACK        = 9'b000100000;
localparam [8:0] WAIT_WRERROR_ACK       = 9'b001000000;
localparam [8:0] WAIT_STR_FETCH         = 9'b010000000;
localparam [8:0] WAIT_NOP_ACK           = 9'b100000000;

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
// Combinatorial next state & output logic
////////////////////////////////////////////////////////////////////////////////
always @ (*)
    begin
        // Default assigments
        strtAXIWrTranReg_d           <= 1'b0;
        dstStrtAddrReg_d             <= 32'b0;
        dstAXITranTypeReg_d          <= 2'b0;
        dstAXIDataWidthReg_d         <= 3'b0;
        srcAXIDataWidthReg_d         <= 3'b0;
        wrDoneReg_d                  <= 1'b0;
        wrErrorReg_d                 <= 1'b0;
        strWrDoneReg_d               <= 1'b0;
        strWrErrorReg_d              <= 1'b0;
        numOfBytesInRdReg_d          <= {MAX_TRAN_SIZE_WIDTH{1'b0}};
        dstMaxAXINumBeatsReg_d       <= dstMaxAXINumBeatsReg;
        dstStrDscrptrReg_d           <= 1'b0;
        strFetchRdy                  <= 1'b0;
        strFetchAddr                 <= 32'b0;
        strDataNReadyReg_d           <= 1'b0;
        noOpDstReg_d                 <= 1'b0;
        case (currState)
            IDLE:
                begin
                    if (reqInQueue)
                        begin
                            if (dstOp == 2'b00)
                                begin
                                    noOpDstReg_d <= 1'b1;
                                    nextState    <= WAIT_NOP_ACK;
                                end
                            else if (strDscrptr)
                                begin
                                    if (dataValid == 1'b1)
                                        begin
                                            strtAXIWrTranReg_d     <= 1'b1;
                                            dstStrDscrptrReg_d     <= 1'b1;
                                            numOfBytesInRdReg_d    <= numOfBytes; 
                                            dstStrtAddrReg_d       <= dstAddr;
                                            dstAXITranTypeReg_d    <= dstOp;
                                            dstMaxAXINumBeatsReg_d <= PRI_0_NUM_OF_BEATS;
                                            nextState              <= WAIT_STR_DONE;
                                        end
                                    else
                                        begin
                                            // Fetch the stream data valid bit
                                            strFetchRdy  <= 1'b1;
                                            strFetchAddr <= extDscrptrAddr;
                                            nextState    <= WAIT_STR_FETCH;
                                        end
                                end
                            else if (numOfBytesInRdValid_rdNumOfBytesReg)
                                begin
                                    // Don't start the write until the size of the current operation
                                    // is determined by the rdTranCtrl logic.
                                    strtAXIWrTranReg_d    <= 1'b1;
                                    numOfBytesInRdReg_d   <= {{(MAX_TRAN_SIZE_WIDTH - MAX_AXI_NUM_BEATS_WIDTH){1'b0}}, numOfBytesInRd_rdNumOfBytesReg}; 
                                    dstStrtAddrReg_d      <= dstAddr;
                                    dstAXITranTypeReg_d   <= dstOp;
                                    dstAXIDataWidthReg_d  <= dstDataWidth;
                                    srcAXIDataWidthReg_d  <= srcDataWidth;
                                    nextState             <= WAIT_DMA_DONE;
                                    if (priLvl == 8'b00000001)
                                        begin
                                            dstMaxAXINumBeatsReg_d <= PRI_0_NUM_OF_BEATS;
                                        end
                                    else if (priLvl == 8'b00000010)
                                        begin
                                            dstMaxAXINumBeatsReg_d <= PRI_1_NUM_OF_BEATS;
                                        end
                                    else if (priLvl == 8'b00000100)
                                        begin
                                            dstMaxAXINumBeatsReg_d <= PRI_2_NUM_OF_BEATS;
                                        end
                                    else if (priLvl == 8'b00001000)
                                        begin
                                            dstMaxAXINumBeatsReg_d <= PRI_3_NUM_OF_BEATS;
                                        end
                                    else if (priLvl == 8'b00010000)
                                        begin
                                            dstMaxAXINumBeatsReg_d <= PRI_4_NUM_OF_BEATS;
                                        end
                                    else if (priLvl == 8'b00100000)
                                        begin
                                            dstMaxAXINumBeatsReg_d <= PRI_5_NUM_OF_BEATS;
                                        end
                                    else if (priLvl == 8'b01000000)
                                        begin
                                            dstMaxAXINumBeatsReg_d <= PRI_6_NUM_OF_BEATS;
                                        end
                                    else
                                        begin
                                            dstMaxAXINumBeatsReg_d <= PRI_7_NUM_OF_BEATS;
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
            WAIT_NOP_ACK:
                begin
                    if (noOpDstAck)
                        begin
                            nextState <= IDLE;
                        end
                    else
                        begin
                            noOpDstReg_d <= 1'b1;
                            nextState    <= WAIT_NOP_ACK;
                        end
                end
            WAIT_STR_DONE:
                begin
                    if (strWrTranDone)
                        begin
                            strWrDoneReg_d <= 1'b1;
                            nextState      <= WAIT_STR_WRDONE_ACK;
                        end
                    else if (strWrTranError)
                        begin
                            strWrErrorReg_d <= 1'b1;
                            nextState       <= WAIT_STR_WRERROR_ACK;
                        end
                    else
                        begin
                            nextState <= WAIT_STR_DONE;
                        end
                end
            WAIT_DMA_DONE:
                begin
                    if (wrTranDone)
                        begin
                            wrDoneReg_d <= 1'b1;
                            nextState   <= WAIT_WRDONE_ACK;
                        end
                    else if (wrTranError)
                        begin
                            wrErrorReg_d <= 1'b1;
                            nextState    <= WAIT_WRERROR_ACK;
                        end
                    else
                        begin
                            nextState <= WAIT_DMA_DONE;
                        end
                end
            WAIT_STR_WRDONE_ACK:
                begin
                    if (strWrDoneAck)
                        begin
                            nextState <= IDLE;
                        end
                    else
                        begin
                            strWrDoneReg_d <= 1'b1;
                            nextState      <= WAIT_STR_WRDONE_ACK;
                        end
                end
            WAIT_STR_WRERROR_ACK:
                begin
                    if (strWrErrorAck)
                        begin
                            nextState <= IDLE;
                        end
                    else
                        begin
                            strWrErrorReg_d <= 1'b1;
                            nextState       <= WAIT_STR_WRERROR_ACK;
                        end
                end
            WAIT_WRDONE_ACK:
                begin
                    if (wrDoneAck)
                        begin
                            nextState <= IDLE;
                        end
                    else
                        begin
                            wrDoneReg_d <= 1'b1;
                            nextState   <= WAIT_WRDONE_ACK;
                        end
                end
            WAIT_WRERROR_ACK:
                begin
                    if (wrErrorAck)
                        begin
                            nextState <= IDLE;
                        end
                    else
                        begin
                            wrErrorReg_d <= 1'b1;
                            nextState    <= WAIT_WRERROR_ACK;
                        end
                end
            WAIT_STR_FETCH:
                begin
                    if (strFetchAck)
                        begin
                            if (strDataValid)
                                begin
                                    strtAXIWrTranReg_d     <= 1'b1;
                                    dstStrDscrptrReg_d     <= 1'b1;
                                    numOfBytesInRdReg_d    <= numOfBytes; 
                                    dstStrtAddrReg_d       <= dstAddr;
                                    dstAXITranTypeReg_d    <= dstOp;
                                    dstMaxAXINumBeatsReg_d <= PRI_0_NUM_OF_BEATS;
                                    nextState              <= WAIT_STR_DONE;
                                end
                            else
                                begin
                                    strDataNReadyReg_d <= 1'b1;
                                    nextState          <= IDLE;
                                end
                        end
                    else
                        begin
                            strFetchRdy  <= 1'b1;
                            strFetchAddr <= extDscrptrAddr;
                            nextState    <= WAIT_STR_FETCH;
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
                wrDoneReg <= 1'b0;
            end
        else
            begin
                wrDoneReg <= wrDoneReg_d;
            end
    end
assign wrDone = wrDoneReg;

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                wrErrorReg <= 1'b0;
            end
        else
            begin
                wrErrorReg <= wrErrorReg_d;
            end
    end
assign wrError = wrErrorReg;

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                strWrDoneReg <= 1'b0;
            end
        else
            begin
                strWrDoneReg <= strWrDoneReg_d;
            end
    end
assign strWrDone = strWrDoneReg;

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                strWrErrorReg <= 1'b0;
            end
        else
            begin
                strWrErrorReg <= strWrErrorReg_d;
            end
    end
assign strWrError = strWrErrorReg;

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                strtAXIWrTranReg <= 1'b0;
            end
        else
            begin
                strtAXIWrTranReg <= strtAXIWrTranReg_d;
            end
    end
assign strtAXIWrTran = strtAXIWrTranReg;

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                dstStrtAddrReg <= 32'b0;
            end
        else
            begin
                dstStrtAddrReg <= dstStrtAddrReg_d;
            end
    end
assign dstStrtAddr = dstStrtAddrReg;

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                dstAXITranTypeReg <= 2'b0;
            end
        else
            begin
                dstAXITranTypeReg <= dstAXITranTypeReg_d;
            end
    end
assign dstAXITranType = dstAXITranTypeReg;

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                dstAXIDataWidthReg <= 3'b0;
            end
        else
            begin
                dstAXIDataWidthReg <= dstAXIDataWidthReg_d;
            end
    end
assign dstAXIDataWidth = dstAXIDataWidthReg;

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
                numOfBytesInRdReg <= {MAX_TRAN_SIZE_WIDTH{1'b0}};
            end
        else
            begin
                numOfBytesInRdReg <= numOfBytesInRdReg_d;
            end
    end
assign numOfBytesInRd = numOfBytesInRdReg;

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                dstMaxAXINumBeatsReg <= {MAX_AXI_NUM_BEATS_WIDTH{1'b0}};
            end
        else
            begin
                dstMaxAXINumBeatsReg <= dstMaxAXINumBeatsReg_d;
            end
    end
assign dstMaxAXINumBeats = dstMaxAXINumBeatsReg;

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                dstStrDscrptrReg <= 1'b0;
            end
        else
            begin
                dstStrDscrptrReg <= dstStrDscrptrReg_d;
            end
    end
assign dstStrDscrptr = dstStrDscrptrReg;

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                strDataNReadyReg <= 1'b0;
            end
        else
            begin
                strDataNReadyReg <= strDataNReadyReg_d;
            end
    end
assign strDataNReady = strDataNReadyReg;

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                noOpDstReg <= 1'b0;
            end
        else
            begin
                noOpDstReg <= noOpDstReg_d;
            end
    end
assign noOpDst = noOpDstReg;

endmodule // wrTranCtrl