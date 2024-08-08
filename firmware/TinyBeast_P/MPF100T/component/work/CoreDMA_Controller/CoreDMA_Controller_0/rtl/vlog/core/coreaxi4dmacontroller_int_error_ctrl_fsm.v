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
module CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_intErrorCtrl (
    // General inputs
    clock,
    resetn,

    // wrTranQueue inputs
    spaceWrQueue,
    intDscrptrNum_WrTranQueue0,
    intDscrptrNum_WrTranQueue1,
    extDscrptrAddr_WrTranQueue,
    extDscrptr_WrTranQueue,
    nxtDscrptr_WrTranQueue,
    numOfBytes_WrTranQueue,
    configRegUpperByte,
    intOnProcess,
    extDscrptrNxt_WrTranQueue,
    chain_WrTranQueue,
    dstOp_WrTranQueue,

    // rdTranQueue inputs
    spaceRdQueue,
    extDscrptr_RdTranQueue,
    chain_RdTranQueue,
    extDscrptrNxt_RdTranQueue,
    intDscrptrNum_RdTranQueue0,
    intDscrptrNum_RdTranQueue1,
    extDscrptrAddr_RdTranQueue,
    numOfBytes_RdTranQueue,
    numOfBytesInRd,
    
    // DMAWrTranCtrl inputs
    wrDone_DMAWrTranCtrl,
    wrError_DMAWrTranCtrl,
    strWrDone_DMAWrTranCtrl,
    strWrError_DMAWrTranCtrl,
    dstAXINumOfBytes,
    clrStrDscrptrDataValidAck,
    strDataNReady,
    
    // DMARdTranCtrl inputs
    rdDone_DMARdTranCtrl,
    rdError_DMARdTranCtrl,
    extDataValidNSet,
    noOpDst,
    noOpSrc,
    
    // intStatusMux inputs
    intStaAck,
    
    // extDscrptrFetch inputs
    extFetchDone,
    extClrAck,
    
    // DMA Arbiter outputs
    clrReq,
    intDscrptrNum_clrReq,
    
    // wrTranQueue outputs
    clrWrTranQueue,
    
    // rdTranQueue outputs
    clrRdTranQueue,
    
    // intStatusMux outputs
    intStaValid,
    opDone,
    wrError,
    rdError,
    intDscrptrNum_intStatusMux,
    extDscrptr_intStatusMux,
    extDscrptrAddr_intStatusMux,
    strDscrptr_intStatusMux,
    
    // DMAWrTranCtrl outputs
    wrDoneAck_DMAWrTranCtrl,
    wrErrorAck_DMAWrTranCtrl,
    strWrDoneAck_DMAWrTranCtrl,
    strWrErrorAck_DMAWrTranCtrl,
    clrStrDscrptrDataValid,
    clrStrDscrptrAddr,
    clrStrDscrptrDstOp,
    
    // DMARdTranCtrl outputs
    rdDoneAck_DMARdTranCtrl,
    rdErrorAck_DMARdTranCtrl,
    extDataValidNSetAck,
    noOpDstAck,
    noOpSrcAck,
    
    // Cache outputs
    wrCache1Sel,
    rdCache1Sel,
    
    // ExtDscrptrFetch outputs
    extDscrptrFetch,
    clrExtDscrptrDataValid,
    intDscrptrNum_extFetch,
    extDscrptrAddr_extFetch,
    configRegByte2,
    
    // DMATranCtrl outputs
    clrNumOfBytesInRd,
    
    // AXI4StreamSlaveCtrl outputs
    strMemMapWrDone,
    strMemMapWrError
);
////////////////////////////////////////////////////////////////////////////////
// User modifiable parameters
////////////////////////////////////////////////////////////////////////////////
parameter NUM_INT_BDS             = 4;
parameter NUM_INT_BDS_WIDTH       = 2;
parameter MAX_TRAN_SIZE_WIDTH     = 23;
parameter MAX_AXI_TRAN_SIZE_WIDTH = 12;

////////////////////////////////////////////////////////////////////////////////
// Port directions
////////////////////////////////////////////////////////////////////////////////
// General inputs
input                               clock;
input                               resetn;

// wrTranQueue inputs
input                               spaceWrQueue;
input [NUM_INT_BDS_WIDTH-1:0]       intDscrptrNum_WrTranQueue0;
input [NUM_INT_BDS_WIDTH-1:0]       intDscrptrNum_WrTranQueue1;
input [31:0]                        extDscrptrAddr_WrTranQueue;
input                               extDscrptr_WrTranQueue;
input                               chain_RdTranQueue;
input                               extDscrptrNxt_WrTranQueue;
input [31:0]                        nxtDscrptr_WrTranQueue;
input [MAX_TRAN_SIZE_WIDTH-1:0]     numOfBytes_WrTranQueue;
input [7:0]                         configRegUpperByte;
input                               intOnProcess;
input                               chain_WrTranQueue;
input [1:0]                         dstOp_WrTranQueue;

// rdTranQueue inputs
input                               spaceRdQueue;
input                               extDscrptr_RdTranQueue;
input [NUM_INT_BDS_WIDTH-1:0]       intDscrptrNum_RdTranQueue0;
input [NUM_INT_BDS_WIDTH-1:0]       intDscrptrNum_RdTranQueue1;
input [31:0]                        extDscrptrAddr_RdTranQueue;
input [MAX_TRAN_SIZE_WIDTH-1:0]     numOfBytes_RdTranQueue;
input [MAX_AXI_TRAN_SIZE_WIDTH-1:0] numOfBytesInRd;
input                               extDscrptrNxt_RdTranQueue;

// DMAWrTranCtrl inputs
input                               wrDone_DMAWrTranCtrl;
input                               wrError_DMAWrTranCtrl;
input                               strWrDone_DMAWrTranCtrl;
input                               strWrError_DMAWrTranCtrl;
input [MAX_AXI_TRAN_SIZE_WIDTH-1:0] dstAXINumOfBytes;
input                               clrStrDscrptrDataValidAck;
input                               strDataNReady;

// DMARdTranCtrl inputs
input                               rdDone_DMARdTranCtrl;
input                               rdError_DMARdTranCtrl;
input                               extDataValidNSet;
input                               noOpDst;
input                               noOpSrc;

// intStatusMux inputs
input                               intStaAck;

// extDscrptrFetch inputs
input                               extFetchDone;
input                               extClrAck;

// DMA Arbiter outputs
output reg                          clrReq;
output reg [NUM_INT_BDS_WIDTH-1:0]  intDscrptrNum_clrReq;

// wrTranQueue outputs
output reg [1:0]                    clrWrTranQueue;

// rdTranQueue outputs
output reg [1:0]                    clrRdTranQueue;

// intStatusMux outputs
output                              intStaValid;
output                              opDone;
output                              wrError;
output                              rdError;
output     [NUM_INT_BDS_WIDTH-1:0]  intDscrptrNum_intStatusMux;
output                              extDscrptr_intStatusMux;
output     [31:0]                   extDscrptrAddr_intStatusMux;
output                              strDscrptr_intStatusMux;

// DMAWrTranCtrl outputs
output reg                          wrDoneAck_DMAWrTranCtrl;
output reg                          wrErrorAck_DMAWrTranCtrl;
output reg                          strWrDoneAck_DMAWrTranCtrl;
output reg                          strWrErrorAck_DMAWrTranCtrl;
output reg                          clrStrDscrptrDataValid;
output reg [31:0]                   clrStrDscrptrAddr;
output reg [1:0]                    clrStrDscrptrDstOp;

// DMARdTranCtrl outputs
output reg                          rdDoneAck_DMARdTranCtrl;
output reg                          rdErrorAck_DMARdTranCtrl;
output reg                          extDataValidNSetAck;
output reg                          noOpDstAck;
output reg                          noOpSrcAck;

// Cache outputs
output reg                          wrCache1Sel;
output reg                          rdCache1Sel;


// ExtDscrptrFetch outputs
output                              extDscrptrFetch;
output                              clrExtDscrptrDataValid;
output     [NUM_INT_BDS_WIDTH-1:0]  intDscrptrNum_extFetch;
output     [31:0]                   extDscrptrAddr_extFetch;
output     [7:0]                    configRegByte2;

// DMATranCtrl outputs
output reg                          clrNumOfBytesInRd;
    
// AXI4StreamSlaveCtrl outputs
output                              strMemMapWrDone;
output                              strMemMapWrError;

////////////////////////////////////////////////////////////////////////////////
// Internal signals
////////////////////////////////////////////////////////////////////////////////
reg  [13:0]                   currState;
reg  [13:0]                   nextState;
reg                           wrCache1Sel_d;
reg                           rdCache1Sel_d;
reg  [NUM_INT_BDS_WIDTH-1:0]  intDscrptrNum_WrTranQueue [0:1];
reg  [NUM_INT_BDS_WIDTH-1:0]  intDscrptrNum_RdTranQueue [0:1];
reg                           extDscrptrFetchReg;
reg                           extDscrptrFetchReg_d;
reg                           clrExtDscrptrDataValidReg;
reg                           clrExtDscrptrDataValidReg_d;
reg  [NUM_INT_BDS_WIDTH-1:0]  intDscrptrNum_extFetchReg;
reg  [NUM_INT_BDS_WIDTH-1:0]  intDscrptrNum_extFetchReg_d;
reg  [31:0]                   extDscrptrAddr_extFetchReg;
reg  [31:0]                   extDscrptrAddr_extFetchReg_d;
reg  [7:0]                    configRegByte2Reg;
reg  [7:0]                    configRegByte2Reg_d;
reg                           intStaValidReg;
reg                           intStaValidReg_d;
reg                           opDoneReg;
reg                           opDoneReg_d;
reg                           wrErrorReg;
reg                           wrErrorReg_d;
reg                           rdErrorReg;
reg                           rdErrorReg_d;
reg  [NUM_INT_BDS_WIDTH-1:0]  intDscrptrNum_intStatusMuxReg;
reg  [NUM_INT_BDS_WIDTH-1:0]  intDscrptrNum_intStatusMuxReg_d;
reg                           extDscrptr_intStatusMuxReg;
reg                           extDscrptr_intStatusMuxReg_d;
reg  [31:0]                   extDscrptrAddr_intStatusMuxReg;
reg  [31:0]                   extDscrptrAddr_intStatusMuxReg_d;
reg                           strDscrptr_intStatusMuxReg;
reg                           strDscrptr_intStatusMuxReg_d;
reg                           strMemMapWrDoneReg;
reg                           strMemMapWrDoneReg_d;
reg                           strMemMapWrErrorReg;
reg                           strMemMapWrErrorReg_d;
reg [1:0]                     rdDone_hold_reg;
reg [1:0]                     rdDone_hold_count;
reg                           clrStrDscrptrDataValid_d;
reg [31:0]                    clrStrDscrptrAddr_d;
reg [1:0]                     clrStrDscrptrDstOp_d;

////////////////////////////////////////////////////////////////////////////////
// Constants
////////////////////////////////////////////////////////////////////////////////
localparam [13:0]  IDLE                                  = 14'b00000000000001;
localparam [13:0]  RD_ERROR_WAIT_WR_DONE                 = 14'b00000000000010;
localparam [13:0]  RD_ERROR_WAIT_INT_ACK                 = 14'b00000000000100;
localparam [13:0]  RD_ERROR_WAIT_INT_ACK_WR_ERROR        = 14'b00000000001000;
localparam [13:0]  RD_ERROR_WAIT_INT_ACK_WR_DONE         = 14'b00000000010000;
localparam [13:0]  WR_ERROR_WAIT_RD_DONE                 = 14'b00000000100000;
localparam [13:0]  WR_ERROR_WAIT_INT_ACK                 = 14'b00000001000000;
localparam [13:0]  WR_DONE_WAIT_INT                      = 14'b00000010000000;
localparam [13:0]  WR_DONE_CLR_EXT_DATA_VALID            = 14'b00000100000000;
localparam [13:0]  WR_DONE_WAIT_EXT_FETCH                = 14'b00001000000000;
localparam [13:0]  WR_DONE_WAIT_EXT_FETCH_AND_INT        = 14'b00010000000000;
localparam [13:0]  STR_ERROR_WAIT_INT                    = 14'b00100000000000;
localparam [13:0]  STR_DONE_WAIT_INT                     = 14'b01000000000000;
localparam [13:0]  STR_WAIT_CLR_DATA_VALID               = 14'b10000000000000;

////////////////////////////////////////////////////////////////////////////////
// wrCacheSel register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                wrCache1Sel <= 1'b0;
            end
        else
            begin
                wrCache1Sel <= wrCache1Sel_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// rdCacheSel register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                rdCache1Sel <= 1'b0;
            end
        else
            begin
                rdCache1Sel <= rdCache1Sel_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// extDscrptrFetch register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                extDscrptrFetchReg <= 1'b0;
            end
        else
            begin
                extDscrptrFetchReg <= extDscrptrFetchReg_d;
            end
    end
assign extDscrptrFetch = extDscrptrFetchReg;

////////////////////////////////////////////////////////////////////////////////
// clrExtDscrptrDataValid register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                clrExtDscrptrDataValidReg <= 1'b0;
            end
        else
            begin
                clrExtDscrptrDataValidReg <= clrExtDscrptrDataValidReg_d;
            end
    end
assign clrExtDscrptrDataValid = clrExtDscrptrDataValidReg;

////////////////////////////////////////////////////////////////////////////////
// intDscrptrNum_extFetch register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                intDscrptrNum_extFetchReg <= {NUM_INT_BDS_WIDTH{1'b0}};
            end
        else
            begin
                intDscrptrNum_extFetchReg <= intDscrptrNum_extFetchReg_d;
            end
    end
assign intDscrptrNum_extFetch = intDscrptrNum_extFetchReg;

////////////////////////////////////////////////////////////////////////////////
// extDscrptrAddr_extFetch register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                extDscrptrAddr_extFetchReg <= 32'b0;
            end
        else
            begin
                extDscrptrAddr_extFetchReg <= extDscrptrAddr_extFetchReg_d;
            end
    end
assign extDscrptrAddr_extFetch = extDscrptrAddr_extFetchReg;

////////////////////////////////////////////////////////////////////////////////
// configRegByte2Reg register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                configRegByte2Reg <= 8'b0;
            end
        else
            begin
                configRegByte2Reg <= configRegByte2Reg_d;
            end
    end
assign configRegByte2 = configRegByte2Reg;

////////////////////////////////////////////////////////////////////////////////
// intStaValid register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                intStaValidReg <= 1'b0;
            end
        else
            begin
                intStaValidReg <= intStaValidReg_d;
            end
    end
assign intStaValid = intStaValidReg;

////////////////////////////////////////////////////////////////////////////////
// opDone register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                opDoneReg <= 1'b0;
            end
        else
            begin
                opDoneReg <= opDoneReg_d;
            end
    end
assign opDone = opDoneReg;

////////////////////////////////////////////////////////////////////////////////
// wrError register
////////////////////////////////////////////////////////////////////////////////
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

////////////////////////////////////////////////////////////////////////////////
// rdError register
////////////////////////////////////////////////////////////////////////////////
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

////////////////////////////////////////////////////////////////////////////////
// intDscrptrNum_intStatusMux register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                intDscrptrNum_intStatusMuxReg <= {NUM_INT_BDS_WIDTH{1'b0}};
            end
        else
            begin
                intDscrptrNum_intStatusMuxReg <= intDscrptrNum_intStatusMuxReg_d;
            end
    end
assign intDscrptrNum_intStatusMux = intDscrptrNum_intStatusMuxReg;

////////////////////////////////////////////////////////////////////////////////
// extDscrptr_intStatusMux register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                extDscrptr_intStatusMuxReg <= 1'b0;
            end
        else
            begin
                extDscrptr_intStatusMuxReg <= extDscrptr_intStatusMuxReg_d;
            end
    end
assign extDscrptr_intStatusMux = extDscrptr_intStatusMuxReg;

////////////////////////////////////////////////////////////////////////////////
// extDscrptrAddr_intStatusMux register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                extDscrptrAddr_intStatusMuxReg <= 32'b0;
            end
        else
            begin
                extDscrptrAddr_intStatusMuxReg <= extDscrptrAddr_intStatusMuxReg_d;
            end
    end
assign extDscrptrAddr_intStatusMux = extDscrptrAddr_intStatusMuxReg;

////////////////////////////////////////////////////////////////////////////////
// strDscrptr_intStatusMux register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                strDscrptr_intStatusMuxReg <= 1'b0;
            end
        else
            begin
                strDscrptr_intStatusMuxReg <= strDscrptr_intStatusMuxReg_d;
            end
    end
assign strDscrptr_intStatusMux = strDscrptr_intStatusMuxReg;

////////////////////////////////////////////////////////////////////////////////
// strMemMapWrDone register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                strMemMapWrDoneReg <= 1'b0;
            end
        else
            begin
                strMemMapWrDoneReg <= strMemMapWrDoneReg_d;
            end
    end
assign strMemMapWrDone = strMemMapWrDoneReg;

////////////////////////////////////////////////////////////////////////////////
// strMemMapWrError register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                strMemMapWrErrorReg <= 1'b0;
            end
        else
            begin
                strMemMapWrErrorReg <= strMemMapWrErrorReg_d;
            end
    end
assign strMemMapWrError = strMemMapWrErrorReg;

////////////////////////////////////////////////////////////////////////////////
// clrStrDscrptrDataValid register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                clrStrDscrptrDataValid <= 1'b0;
            end
        else
            begin
                clrStrDscrptrDataValid <= clrStrDscrptrDataValid_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// clrStrDscrptrAddr register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                clrStrDscrptrAddr <= 32'b0;
            end
        else
            begin
                clrStrDscrptrAddr <= clrStrDscrptrAddr_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// clrStrDscrptrDstOp register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                clrStrDscrptrDstOp <= 2'b0;
            end
        else
            begin
                clrStrDscrptrDstOp <= clrStrDscrptrDstOp_d;
            end
    end
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                rdDone_hold_reg <= 0;
            end
        else
            begin
                rdDone_hold_reg <= rdDone_hold_count;
            end
    end
	

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
// Assign two dimensional vector to infer mux
////////////////////////////////////////////////////////////////////////////////
always @ (*)
    begin
        intDscrptrNum_WrTranQueue[0] = intDscrptrNum_WrTranQueue0;
        intDscrptrNum_WrTranQueue[1] = intDscrptrNum_WrTranQueue1;
        intDscrptrNum_RdTranQueue[0] = intDscrptrNum_RdTranQueue0;
        intDscrptrNum_RdTranQueue[1] = intDscrptrNum_RdTranQueue1;
    end

////////////////////////////////////////////////////////////////////////////////
// Next state logic and combinatorial outputs
////////////////////////////////////////////////////////////////////////////////
always @ (*)
    begin
        // Default assignments
        clrWrTranQueue[0]                <= 1'b0;
        clrWrTranQueue[1]                <= 1'b0;
        wrDoneAck_DMAWrTranCtrl          <= 1'b0;
        wrErrorAck_DMAWrTranCtrl         <= 1'b0;
        strWrDoneAck_DMAWrTranCtrl       <= 1'b0;
        strWrErrorAck_DMAWrTranCtrl      <= 1'b0;
        wrCache1Sel_d                    <= wrCache1Sel;
        intStaValidReg_d                 <= 1'b0;
        opDoneReg_d                      <= 1'b0;
        wrErrorReg_d                     <= 1'b0;
        rdErrorReg_d                     <= 1'b0;
        intDscrptrNum_intStatusMuxReg_d  <= {NUM_INT_BDS_WIDTH{1'b0}};
        extDscrptr_intStatusMuxReg_d     <= 1'b0;
        extDscrptrAddr_intStatusMuxReg_d <= 32'b0;
        clrRdTranQueue[0]                <= 1'b0;
        clrRdTranQueue[1]                <= 1'b0;
        rdDoneAck_DMARdTranCtrl          <= 1'b0;
        rdErrorAck_DMARdTranCtrl         <= 1'b0;
        rdCache1Sel_d                    <= rdCache1Sel;
        clrReq                           <= 1'b0;
        intDscrptrNum_clrReq             <= {NUM_INT_BDS_WIDTH{1'b0}};
        extDscrptrFetchReg_d             <= 1'b0;
        intDscrptrNum_extFetchReg_d      <= {NUM_INT_BDS_WIDTH{1'b0}};
        extDscrptrAddr_extFetchReg_d     <= 32'b0;
        extDataValidNSetAck              <= 1'b0;
        clrExtDscrptrDataValidReg_d      <= 1'b0;
        configRegByte2Reg_d              <= 8'b0;
        clrNumOfBytesInRd                <= 1'b0;
        strDscrptr_intStatusMuxReg_d     <= 1'b0;
        strMemMapWrDoneReg_d             <= 1'b0;
        strMemMapWrErrorReg_d            <= 1'b0;
        clrStrDscrptrDataValid_d         <= 1'b0;
        clrStrDscrptrAddr_d              <= 32'b0;
        clrStrDscrptrDstOp_d             <= 2'b0;
        noOpDstAck                       <= 1'b0;
        noOpSrcAck                       <= 1'b0;
        rdDone_hold_count                <= rdDone_hold_reg;
        case (currState)
            IDLE:
                begin
                    if (noOpDst)
                        begin
                            if (chain_WrTranQueue)
                                begin
                                    if (extDscrptrNxt_WrTranQueue)
                                        begin
                                            // Fetch the external descriptor. Keep the pipeline held
                                            // to keep the DMA interface free for descriptor fetching
                                            extDscrptrFetchReg_d         <= 1'b1;
                                            intDscrptrNum_extFetchReg_d  <= intDscrptrNum_WrTranQueue[wrCache1Sel];
                                            extDscrptrAddr_extFetchReg_d <= nxtDscrptr_WrTranQueue;
                                            nextState                    <= WR_DONE_WAIT_EXT_FETCH;
                                        end
                                    else
                                        begin
                                            // No-op transfer with internal descriptor next
                                            // Internal descriptor fetching is done in the 
                                            // transAck block
                                            clrRdTranQueue[wrCache1Sel] <= 1'b1;
                                            clrWrTranQueue[wrCache1Sel] <= 1'b1;
                                            noOpDstAck                  <= 1'b1;
                                            noOpSrcAck                  <= 1'b1;
                                            wrCache1Sel_d               <= ~wrCache1Sel;
                                            rdCache1Sel_d               <= ~rdCache1Sel;
                                            nextState                   <= IDLE;
                                        end
                                end
                            else
                                begin
                                    // No-op transfer with no next descriptor next
                                    clrRdTranQueue[wrCache1Sel] <= 1'b1;
                                    clrWrTranQueue[wrCache1Sel] <= 1'b1;
                                    noOpDstAck                  <= 1'b1;
                                    noOpSrcAck                  <= 1'b1;
                                    wrCache1Sel_d               <= ~wrCache1Sel;
                                    rdCache1Sel_d               <= ~rdCache1Sel;
                                    nextState                   <= IDLE;
                                end
                        end
                    else if (extDataValidNSet)
                        begin
                            // Clear the queues if an external descriptor's data valid bit isn't
                            // set after the data valid bit has been re-fetched.
                            clrWrTranQueue[rdCache1Sel] <= 1'b1;
                            clrRdTranQueue[rdCache1Sel] <= 1'b1;
                            extDataValidNSetAck         <= 1'b1;
                            nextState <= IDLE;
                        end
                    else if (strDataNReady)
                        begin
                            // Clear the queues if an stream descriptor's data valid bit isn't
                            // set after the data valid bit has been re-fetched.
                            clrWrTranQueue[rdCache1Sel] <= 1'b1;
                            wrCache1Sel_d               <= ~wrCache1Sel;
                            rdCache1Sel_d               <= ~rdCache1Sel;
                            nextState                   <= IDLE;
                        end
                    else if (rdError_DMARdTranCtrl)
                        begin
                            clrReq <= 1'b1;
                            intDscrptrNum_clrReq <= intDscrptrNum_RdTranQueue[rdCache1Sel];
                            if (wrCache1Sel == rdCache1Sel)
                                begin
                                    // Reading and writing the same request of the same descriptor
                                    if (!spaceWrQueue)
                                        begin
                                            // There are other descriptors in the write queue
                                            if (intDscrptrNum_WrTranQueue[!wrCache1Sel] == intDscrptrNum_RdTranQueue[rdCache1Sel])
                                                begin
                                                    // Remove the next write request as it's from the same descriptor and hasn't yet 
                                                    // been seen by the DMAWrTranCtrl block
                                                    clrWrTranQueue[!wrCache1Sel] <= 1'b1;
                                                end
                                        end
                                    nextState <= RD_ERROR_WAIT_WR_DONE;
                                end
                            else
                                begin
                                    // Write is lagging behind the read
                                    if (!spaceWrQueue)
                                        begin
                                            // There are other descriptors in the write queue
                                            if (intDscrptrNum_WrTranQueue[!wrCache1Sel] == intDscrptrNum_RdTranQueue[rdCache1Sel])
                                                begin
                                                    // Remove the next write request as the read operation related to it failed.
                                                    // This request hasn't been seen by the DMAWrTranCtrl block yet.
                                                    clrWrTranQueue[!wrCache1Sel] <= 1'b1;
                                                end
                                        end
                                    intStaValidReg_d                 <= 1'b1;
                                    rdErrorReg_d                     <= 1'b1;
                                    intDscrptrNum_intStatusMuxReg_d  <= intDscrptrNum_RdTranQueue[rdCache1Sel];
                                    extDscrptr_intStatusMuxReg_d     <= extDscrptr_RdTranQueue;
                                    extDscrptrAddr_intStatusMuxReg_d <= extDscrptrAddr_RdTranQueue;
                                    nextState                        <= RD_ERROR_WAIT_INT_ACK;
                                end
                        end
                    else if (wrError_DMAWrTranCtrl)
                        begin
                            clrReq               <= 1'b1;
                            intDscrptrNum_clrReq <= intDscrptrNum_WrTranQueue[wrCache1Sel];
                            if (!spaceRdQueue)
                                begin
                                    if (intDscrptrNum_RdTranQueue[!rdCache1Sel] == intDscrptrNum_WrTranQueue[wrCache1Sel])
                                        begin
                                            // The next request in the read queue is from the same descriptor. Clear it.
                                            clrRdTranQueue[!rdCache1Sel] <= 1'b1;
                                        end
                                end
                            if (intDscrptrNum_RdTranQueue[rdCache1Sel] == intDscrptrNum_WrTranQueue[wrCache1Sel])
                                begin
                                    // The current read request is of the same descriptor as the write error. Hold off until
                                    // the read is complete before handling the write error.
                                    nextState <= WR_ERROR_WAIT_RD_DONE;   
                                end
                            else
                                begin
									rdDone_hold_count				 <= (rdDone_hold_reg != 0) ? rdDone_hold_reg - 1'b1 : rdDone_hold_reg;
                                    intStaValidReg_d                 <= 1'b1;
                                    wrErrorReg_d                     <= 1'b1;
                                    intDscrptrNum_intStatusMuxReg_d  <= intDscrptrNum_WrTranQueue[wrCache1Sel];
                                    extDscrptr_intStatusMuxReg_d     <= extDscrptr_WrTranQueue;
                                    extDscrptrAddr_intStatusMuxReg_d <= extDscrptrAddr_WrTranQueue;
                                    nextState                        <= WR_ERROR_WAIT_INT_ACK;
                                end
                        end
                    else if (wrDone_DMAWrTranCtrl)
                        begin
							rdDone_hold_count <= (rdDone_hold_reg != 0) ? rdDone_hold_reg - 1'b1 : rdDone_hold_reg;					
                            if (numOfBytes_WrTranQueue == {{(MAX_TRAN_SIZE_WIDTH - MAX_AXI_TRAN_SIZE_WIDTH){1'b0}}, dstAXINumOfBytes})
                                begin
                                    if (extDscrptr_WrTranQueue)
                                        begin
                                            // Need to clear the external data valid bit as the operation on this
                                            // descriptor has been completed.
                                            clrExtDscrptrDataValidReg_d  <= 1'b1;
                                            intDscrptrNum_extFetchReg_d  <= intDscrptrNum_WrTranQueue[wrCache1Sel];
                                            extDscrptrAddr_extFetchReg_d <= extDscrptrAddr_WrTranQueue;
                                            // Data for read-modify-write style operation on external descriptor to
                                            // clear data valid flow control bit.
                                            configRegByte2Reg_d          <= configRegUpperByte;
                                            nextState                    <= WR_DONE_CLR_EXT_DATA_VALID;
                                        end
                                    else
                                        begin
                                            if (chain_WrTranQueue)
                                                begin
                                                    if (extDscrptrNxt_WrTranQueue)
                                                        begin
                                                            extDscrptrFetchReg_d         <= 1'b1;
                                                            intDscrptrNum_extFetchReg_d  <= intDscrptrNum_WrTranQueue[wrCache1Sel];
                                                            extDscrptrAddr_extFetchReg_d <= nxtDscrptr_WrTranQueue;
                                                        end
                                                    if (intOnProcess)
                                                        begin
                                                            intStaValidReg_d                 <= 1'b1;
                                                            opDoneReg_d                      <= 1'b1;
                                                            intDscrptrNum_intStatusMuxReg_d  <= intDscrptrNum_WrTranQueue[wrCache1Sel];
                                                            extDscrptr_intStatusMuxReg_d     <= extDscrptr_WrTranQueue;
                                                            extDscrptrAddr_intStatusMuxReg_d <= extDscrptrAddr_WrTranQueue;
                                                            if (extDscrptrNxt_WrTranQueue)
                                                                begin
                                                                    nextState <= WR_DONE_WAIT_EXT_FETCH_AND_INT;
                                                                end
                                                            else
                                                                begin
                                                                    nextState <= WR_DONE_WAIT_INT;
                                                                end
                                                        end
                                                    else
                                                        begin
                                                            if (extDscrptrNxt_WrTranQueue)
                                                                begin
                                                                    nextState <= WR_DONE_WAIT_EXT_FETCH;
                                                                end
                                                            else
                                                                begin
                                                                    clrNumOfBytesInRd           <= 1'b1;
                                                                    clrWrTranQueue[wrCache1Sel] <= 1'b1;
                                                                    wrDoneAck_DMAWrTranCtrl     <= 1'b1;
                                                                    wrCache1Sel_d               <= ~wrCache1Sel;
                                                                    nextState                   <= IDLE;
                                                                end
                                                        end
                                                end
                                            else
                                                begin
                                                    intStaValidReg_d                 <= 1'b1;
                                                    opDoneReg_d                      <= 1'b1;
                                                    intDscrptrNum_intStatusMuxReg_d  <= intDscrptrNum_WrTranQueue[wrCache1Sel];
                                                    extDscrptr_intStatusMuxReg_d     <= extDscrptr_WrTranQueue;
                                                    extDscrptrAddr_intStatusMuxReg_d <= extDscrptrAddr_WrTranQueue;
                                                    nextState                        <= WR_DONE_WAIT_INT;
                                                end
                                        end
                                end
                            else
                                begin
                                    clrNumOfBytesInRd           <= 1'b1;
                                    clrWrTranQueue[wrCache1Sel] <= 1'b1;
                                    wrDoneAck_DMAWrTranCtrl     <= 1'b1;
                                    wrCache1Sel_d               <= ~wrCache1Sel;
                                    nextState                   <= IDLE;
                                end
                        end
                    else if (rdDone_DMARdTranCtrl)
                        begin
							rdDone_hold_count <= rdDone_hold_reg + 1'b1;
                            if (numOfBytes_RdTranQueue == {{(MAX_TRAN_SIZE_WIDTH - MAX_AXI_TRAN_SIZE_WIDTH){1'b0}}, numOfBytesInRd})
                                begin
                                    // This is the last read request of this descriptor
                                    if (chain_RdTranQueue)
                                        begin
                                            if (extDscrptrNxt_RdTranQueue)
                                                begin
                                                    // Don't clear the request from the rdTranQueue queue
                                                    // as an external descriptor needs to be fetched. This
                                                    // ensures the DMA read interface remains free for
                                                    // external descriptor fetching.
                                                    nextState <= IDLE;
                                                end
                                            else
                                                begin
                                                    // Internal descriptor fetch required. This fetch should
                                                    // not halt activity on the DMA interface as it's fetched
                                                    // from internal RAM. Internal descriptor fetch logic 
                                                    // operates in parallel to this FSM in the transAck block.
                                                    clrRdTranQueue[rdCache1Sel] <= 1'b1;
                                                    rdDoneAck_DMARdTranCtrl     <= 1'b1;
                                                    rdCache1Sel_d               <= ~rdCache1Sel;
                                                    nextState                   <= IDLE;
                                                end
                                        end
                                    else
                                        begin
                                            clrRdTranQueue[rdCache1Sel] <= 1'b1;
                                            rdDoneAck_DMARdTranCtrl     <= 1'b1;
                                            rdCache1Sel_d               <= ~rdCache1Sel;
                                            nextState                   <= IDLE;
                                        end
                                end
                            else
                                begin
                                    // This is not the last read request of this descriptor
                                    clrRdTranQueue[rdCache1Sel] <= 1'b1;
                                    rdDoneAck_DMARdTranCtrl     <= 1'b1;
                                    rdCache1Sel_d               <= ~rdCache1Sel;
                                    nextState                   <= IDLE;
                                end
                        end
                    else if (strWrError_DMAWrTranCtrl || strWrDone_DMAWrTranCtrl)
                        begin
                            clrStrDscrptrDataValid_d         <= 1'b1;
                            clrStrDscrptrAddr_d              <= extDscrptrAddr_WrTranQueue;
                            clrStrDscrptrDstOp_d             <= dstOp_WrTranQueue;
                            nextState                        <= STR_WAIT_CLR_DATA_VALID;
                        end
                    else
                        begin
                            nextState <= IDLE;
                        end
                end
            WR_DONE_CLR_EXT_DATA_VALID:
                begin
                    if (extClrAck)
                        begin
                            if (chain_WrTranQueue)
                                begin
                                    if (extDscrptrNxt_WrTranQueue)
                                        begin
                                            extDscrptrFetchReg_d         <= 1'b1;
                                            intDscrptrNum_extFetchReg_d  <= intDscrptrNum_WrTranQueue[wrCache1Sel];
                                            extDscrptrAddr_extFetchReg_d <= nxtDscrptr_WrTranQueue;
                                        end
                                    if (intOnProcess)
                                        begin
                                            intStaValidReg_d                 <= 1'b1;
                                            opDoneReg_d                      <= 1'b1;
                                            intDscrptrNum_intStatusMuxReg_d  <= intDscrptrNum_WrTranQueue[wrCache1Sel];
                                            extDscrptr_intStatusMuxReg_d     <= extDscrptr_WrTranQueue;
                                            extDscrptrAddr_intStatusMuxReg_d <= extDscrptrAddr_WrTranQueue;
                                            if (extDscrptrNxt_WrTranQueue)
                                                begin
                                                    nextState <= WR_DONE_WAIT_EXT_FETCH_AND_INT;
                                                end
                                            else
                                                begin
                                                    nextState <= WR_DONE_WAIT_INT;
                                                end
                                        end
                                    else
                                        begin
                                            if (extDscrptrNxt_WrTranQueue)
                                                begin
                                                    nextState <= WR_DONE_WAIT_EXT_FETCH;
                                                end
                                            else
                                                begin
                                                    clrNumOfBytesInRd           <= 1'b1;
                                                    clrWrTranQueue[wrCache1Sel] <= 1'b1;
                                                    wrDoneAck_DMAWrTranCtrl     <= 1'b1;
                                                    wrCache1Sel_d               <= ~wrCache1Sel;
                                                    nextState                   <= IDLE;
                                                end
                                        end
                                end
                            else
                                begin
                                    intStaValidReg_d                 <= 1'b1;
                                    opDoneReg_d                      <= 1'b1;
                                    intDscrptrNum_intStatusMuxReg_d  <= intDscrptrNum_WrTranQueue[wrCache1Sel];
                                    extDscrptr_intStatusMuxReg_d     <= extDscrptr_WrTranQueue;
                                    extDscrptrAddr_intStatusMuxReg_d <= extDscrptrAddr_WrTranQueue;
                                    nextState                        <= WR_DONE_WAIT_INT;
                                end
                        end
                    else
                        begin
                            // Need to clear the external data valid bit as the operation on this
                            // descriptor has been completed.
                            clrExtDscrptrDataValidReg_d  <= 1'b1;
                            intDscrptrNum_extFetchReg_d  <= intDscrptrNum_WrTranQueue[wrCache1Sel];
                            extDscrptrAddr_extFetchReg_d <= extDscrptrAddr_WrTranQueue;
                            // Data for read-modify-write style operation on external descriptor to
                            // clear data valid flow control bit.
                            configRegByte2Reg_d          <= configRegUpperByte;
                            nextState <= WR_DONE_CLR_EXT_DATA_VALID;
                        end
                end
            WR_DONE_WAIT_INT:
                begin
                    if (intStaAck)
                        begin
                            clrNumOfBytesInRd           <= 1'b1;
                            clrWrTranQueue[wrCache1Sel] <= 1'b1;
                            wrDoneAck_DMAWrTranCtrl     <= 1'b1;
                            wrCache1Sel_d               <= ~wrCache1Sel;
                            nextState                   <= IDLE;
                        end
                    else
                        begin
                            intStaValidReg_d                 <= 1'b1;
                            opDoneReg_d                      <= 1'b1;
                            intDscrptrNum_intStatusMuxReg_d  <= intDscrptrNum_WrTranQueue[wrCache1Sel];
                            extDscrptr_intStatusMuxReg_d     <= extDscrptr_WrTranQueue;
                            extDscrptrAddr_intStatusMuxReg_d <= extDscrptrAddr_WrTranQueue;
                            nextState                        <= WR_DONE_WAIT_INT;
                        end
                end
            WR_DONE_WAIT_EXT_FETCH:
                begin
                    if (extFetchDone)
                        begin
                            if (noOpDst)
                                begin
                                    clrRdTranQueue[wrCache1Sel] <= 1'b1;
                                    clrWrTranQueue[wrCache1Sel] <= 1'b1;
                                    noOpDstAck                  <= 1'b1;
                                    noOpSrcAck                  <= 1'b1;
                                    wrCache1Sel_d               <= ~wrCache1Sel;
                                    rdCache1Sel_d               <= ~rdCache1Sel;
                                    nextState                   <= IDLE;
                                end
                            else
                                begin
                                    clrRdTranQueue[rdCache1Sel] <= 1'b1;
                                    rdDoneAck_DMARdTranCtrl     <= 1'b1;
                                    rdCache1Sel_d               <= ~rdCache1Sel;
                                    clrNumOfBytesInRd           <= 1'b1;
                                    clrWrTranQueue[wrCache1Sel] <= 1'b1;
                                    wrDoneAck_DMAWrTranCtrl     <= 1'b1;
                                    wrCache1Sel_d               <= ~wrCache1Sel;
                                    nextState                   <= IDLE;
                                end
                        end
                    else
                        begin
                            extDscrptrFetchReg_d         <= 1'b1;
                            intDscrptrNum_extFetchReg_d  <= intDscrptrNum_WrTranQueue[wrCache1Sel];
                            extDscrptrAddr_extFetchReg_d <= nxtDscrptr_WrTranQueue;
                            nextState                    <= WR_DONE_WAIT_EXT_FETCH;
                        end
                end
            WR_DONE_WAIT_EXT_FETCH_AND_INT:
                begin
                    if (intStaAck)
                        begin
                            if (extFetchDone)
                                begin
                                    clrNumOfBytesInRd           <= 1'b1;
                                    clrWrTranQueue[wrCache1Sel] <= 1'b1;
                                    wrDoneAck_DMAWrTranCtrl     <= 1'b1;
                                    wrCache1Sel_d               <= ~wrCache1Sel;
                                    clrRdTranQueue[rdCache1Sel] <= 1'b1;
                                    rdDoneAck_DMARdTranCtrl     <= 1'b1;
                                    rdCache1Sel_d               <= ~rdCache1Sel;
                                    nextState                   <= IDLE;
                                end
                            else
                                begin
                                    extDscrptrFetchReg_d           <= 1'b1;
                                    intDscrptrNum_extFetchReg_d    <= intDscrptrNum_WrTranQueue[wrCache1Sel];
                                    extDscrptrAddr_extFetchReg_d   <= nxtDscrptr_WrTranQueue;
                                    nextState <= WR_DONE_WAIT_EXT_FETCH;
                                end
                        end
                    else
                        begin
                            intStaValidReg_d                    <= 1'b1;
                            opDoneReg_d                         <= 1'b1;
                            intDscrptrNum_intStatusMuxReg_d     <= intDscrptrNum_WrTranQueue[wrCache1Sel];
                            extDscrptr_intStatusMuxReg_d        <= extDscrptr_WrTranQueue;
                            extDscrptrAddr_intStatusMuxReg_d    <= extDscrptrAddr_WrTranQueue;  
                            if (extFetchDone)
                                begin
                                    clrRdTranQueue[rdCache1Sel] <= 1'b1;
                                    rdDoneAck_DMARdTranCtrl     <= 1'b1;
                                    rdCache1Sel_d               <= ~rdCache1Sel;
                                    nextState                   <= WR_DONE_WAIT_INT;
                                end
                            else
                                begin
                                    nextState <= WR_DONE_WAIT_EXT_FETCH_AND_INT;
                                end
                        end
                end
            WR_ERROR_WAIT_RD_DONE:
                begin
                    if (rdError_DMARdTranCtrl | rdDone_DMARdTranCtrl | (rdDone_hold_reg != 0))
                        begin
							rdDone_hold_count <= (rdDone_hold_reg != 0) ? rdDone_hold_reg - 1'b1 : rdDone_hold_reg;	
                            clrRdTranQueue[rdCache1Sel] <= (rdDone_DMARdTranCtrl);
                            rdCache1Sel_d               <= (rdDone_DMARdTranCtrl) ? ~rdCache1Sel : rdCache1Sel;
                            if (rdError_DMARdTranCtrl)
                                begin
                                    rdErrorAck_DMARdTranCtrl <= 1'b1;
                                end
                            else
                                begin
                                    rdDoneAck_DMARdTranCtrl <= 1'b1;
                                end
                            intStaValidReg_d                 <= 1'b1;
                            wrErrorReg_d                     <= 1'b1;
							rdErrorReg_d                     <= rdError_DMARdTranCtrl;
                            intDscrptrNum_intStatusMuxReg_d  <= intDscrptrNum_WrTranQueue[wrCache1Sel];
                            extDscrptr_intStatusMuxReg_d     <= extDscrptr_WrTranQueue;
                            extDscrptrAddr_intStatusMuxReg_d <= extDscrptrAddr_WrTranQueue;
                            nextState                        <= WR_ERROR_WAIT_INT_ACK;
                        end
                    else
                        begin
                            nextState <= WR_ERROR_WAIT_RD_DONE;
                        end
                end
            WR_ERROR_WAIT_INT_ACK:
                begin
                    if (intStaAck)
                        begin
                            clrWrTranQueue[wrCache1Sel] <= 1'b1;
                            wrErrorAck_DMAWrTranCtrl    <= 1'b1;
                            wrCache1Sel_d               <= ~wrCache1Sel;
                            nextState                   <= IDLE;
                        end
                    else
                        begin
                            intStaValidReg_d                 <= 1'b1;
                            wrErrorReg_d                     <= 1'b1;
							rdErrorReg_d                     <= rdError_DMARdTranCtrl;
                            intDscrptrNum_intStatusMuxReg_d  <= intDscrptrNum_WrTranQueue[wrCache1Sel];
                            extDscrptr_intStatusMuxReg_d     <= extDscrptr_WrTranQueue;
                            extDscrptrAddr_intStatusMuxReg_d <= extDscrptrAddr_WrTranQueue;
                            nextState                        <= WR_ERROR_WAIT_INT_ACK;
                        end
                end
            RD_ERROR_WAIT_INT_ACK:
                begin
                    if (intStaAck)
                        begin
                            clrRdTranQueue[rdCache1Sel] <= 1'b1;
                            rdErrorAck_DMARdTranCtrl    <= 1'b1;
                            rdCache1Sel_d               <= ~rdCache1Sel;
                            nextState                   <= IDLE;
                        end
                    else
                        begin
                            intStaValidReg_d                 <= 1'b1;
                            rdErrorReg_d                     <= 1'b1;
                            intDscrptrNum_intStatusMuxReg_d  <= intDscrptrNum_RdTranQueue[rdCache1Sel];
                            extDscrptr_intStatusMuxReg_d     <= extDscrptr_RdTranQueue;
                            extDscrptrAddr_intStatusMuxReg_d <= extDscrptrAddr_RdTranQueue;
                            nextState                        <= RD_ERROR_WAIT_INT_ACK;
                        end
                end
            RD_ERROR_WAIT_WR_DONE:
                begin
                    if (wrError_DMAWrTranCtrl)
                        begin
                            intStaValidReg_d                 <= 1'b1;
                            wrErrorReg_d                     <= 1'b1;
                            rdErrorReg_d                     <= 1'b1;
                            intDscrptrNum_intStatusMuxReg_d  <= intDscrptrNum_RdTranQueue[rdCache1Sel];
                            extDscrptr_intStatusMuxReg_d     <= extDscrptr_RdTranQueue;
                            extDscrptrAddr_intStatusMuxReg_d <= extDscrptrAddr_RdTranQueue;
                            nextState                        <= RD_ERROR_WAIT_INT_ACK_WR_ERROR;
                        end
                    else if (wrDone_DMAWrTranCtrl)
                        begin
                            intStaValidReg_d                 <= 1'b1;
                            rdErrorReg_d                     <= 1'b1;
                            intDscrptrNum_intStatusMuxReg_d  <= intDscrptrNum_RdTranQueue[rdCache1Sel];
                            extDscrptr_intStatusMuxReg_d     <= extDscrptr_RdTranQueue;
                            extDscrptrAddr_intStatusMuxReg_d <= extDscrptrAddr_RdTranQueue;
                            nextState                        <= RD_ERROR_WAIT_INT_ACK_WR_DONE;
                        end
                    else
                        begin
                            nextState <= RD_ERROR_WAIT_WR_DONE;
                        end
                end
            RD_ERROR_WAIT_INT_ACK_WR_ERROR:
                begin
                    if (intStaAck)
                        begin
                            clrWrTranQueue[wrCache1Sel] <= 1'b1;
                            clrRdTranQueue[rdCache1Sel] <= 1'b1;
                            wrErrorAck_DMAWrTranCtrl    <= 1'b1;
                            rdErrorAck_DMARdTranCtrl    <= 1'b1;
                            wrCache1Sel_d               <= ~wrCache1Sel;
                            rdCache1Sel_d               <= ~rdCache1Sel;
                            nextState                   <= IDLE;
                        end
                    else
                        begin
                            intStaValidReg_d                 <= 1'b1;
                            wrErrorReg_d                     <= 1'b1;
                            rdErrorReg_d                     <= 1'b1;
                            intDscrptrNum_intStatusMuxReg_d  <= intDscrptrNum_RdTranQueue[rdCache1Sel];
                            extDscrptr_intStatusMuxReg_d     <= extDscrptr_RdTranQueue;
                            extDscrptrAddr_intStatusMuxReg_d <= extDscrptrAddr_RdTranQueue;
                            nextState                        <= RD_ERROR_WAIT_INT_ACK_WR_ERROR;
                        end
                end
            RD_ERROR_WAIT_INT_ACK_WR_DONE:
                begin
                    if (intStaAck)
                        begin
                            clrNumOfBytesInRd           <= 1'b1;
                            clrWrTranQueue[wrCache1Sel] <= 1'b1;
                            clrRdTranQueue[rdCache1Sel] <= 1'b1;
                            wrDoneAck_DMAWrTranCtrl     <= 1'b1;
                            rdErrorAck_DMARdTranCtrl    <= 1'b1;
                            wrCache1Sel_d               <= ~wrCache1Sel;
                            rdCache1Sel_d               <= ~rdCache1Sel;
                            nextState                   <= IDLE;
                        end
                    else
                        begin
                            intStaValidReg_d                 <= 1'b1;
                            rdErrorReg_d                     <= 1'b1;
                            intDscrptrNum_intStatusMuxReg_d  <= intDscrptrNum_RdTranQueue[rdCache1Sel];
                            extDscrptr_intStatusMuxReg_d     <= extDscrptr_RdTranQueue;
                            extDscrptrAddr_intStatusMuxReg_d <= extDscrptrAddr_RdTranQueue;
                            nextState                        <= RD_ERROR_WAIT_INT_ACK_WR_DONE;
                        end
                end
            STR_DONE_WAIT_INT:
                begin
                    if (intStaAck)
                        begin
                            strWrDoneAck_DMAWrTranCtrl  <= 1'b1;
                            clrWrTranQueue[rdCache1Sel] <= 1'b1;
                            wrCache1Sel_d               <= ~wrCache1Sel;
                            rdCache1Sel_d               <= ~rdCache1Sel;
                            nextState                   <= IDLE;
                        end
                    else
                        begin
                            intStaValidReg_d                 <= 1'b1;
                            opDoneReg_d                      <= 1'b1;
                            intDscrptrNum_intStatusMuxReg_d  <= intDscrptrNum_WrTranQueue[wrCache1Sel];
                            strDscrptr_intStatusMuxReg_d     <= 1'b1;
                            extDscrptrAddr_intStatusMuxReg_d <= extDscrptrAddr_WrTranQueue;
                            nextState                        <= STR_DONE_WAIT_INT;
                        end
                end
            STR_ERROR_WAIT_INT:
                begin
                    if (intStaAck)
                        begin
                            strWrErrorAck_DMAWrTranCtrl <= 1'b1;
                            clrWrTranQueue[wrCache1Sel] <= 1'b1;
                            wrCache1Sel_d               <= ~wrCache1Sel;
                            rdCache1Sel_d               <= ~rdCache1Sel;
                            nextState                   <= IDLE;
                        end
                    else
                        begin
                            intStaValidReg_d                 <= 1'b1;
                            wrErrorReg_d                     <= 1'b1;
                            intDscrptrNum_intStatusMuxReg_d  <= intDscrptrNum_WrTranQueue[wrCache1Sel];
                            strDscrptr_intStatusMuxReg_d     <= 1'b1;
                            extDscrptrAddr_intStatusMuxReg_d <= extDscrptrAddr_WrTranQueue;
                            nextState                        <= STR_ERROR_WAIT_INT;
                        end
                end
            STR_WAIT_CLR_DATA_VALID:
                begin
                    if (clrStrDscrptrDataValidAck)
                        begin
                            if (strWrError_DMAWrTranCtrl)
                                begin
                                    strMemMapWrErrorReg_d            <= 1'b1;
                                    intStaValidReg_d                 <= 1'b1;
                                    wrErrorReg_d                     <= 1'b1;
                                    intDscrptrNum_intStatusMuxReg_d  <= intDscrptrNum_WrTranQueue[wrCache1Sel];
                                    strDscrptr_intStatusMuxReg_d     <= 1'b1;
                                    extDscrptrAddr_intStatusMuxReg_d <= extDscrptrAddr_WrTranQueue;
                                    nextState                        <= STR_ERROR_WAIT_INT;
                                end
                            else
                                begin
                                    strMemMapWrDoneReg_d             <= 1'b1;
                                    intStaValidReg_d                 <= 1'b1;
                                    opDoneReg_d                      <= 1'b1;
                                    intDscrptrNum_intStatusMuxReg_d  <= intDscrptrNum_WrTranQueue[wrCache1Sel];
                                    strDscrptr_intStatusMuxReg_d     <= 1'b1;
                                    extDscrptrAddr_intStatusMuxReg_d <= extDscrptrAddr_WrTranQueue;
                                    nextState                        <= STR_DONE_WAIT_INT;
                                end
                        end
                    else
                        begin
                            clrStrDscrptrDataValid_d         <= 1'b1;
                            clrStrDscrptrAddr_d              <= extDscrptrAddr_WrTranQueue;
                            clrStrDscrptrDstOp_d             <= dstOp_WrTranQueue;
                            nextState                        <= STR_WAIT_CLR_DATA_VALID;
                        end
                end
            default:
                begin
                    nextState <= IDLE;
                end
        endcase
    end

endmodule // intErrorCtrl