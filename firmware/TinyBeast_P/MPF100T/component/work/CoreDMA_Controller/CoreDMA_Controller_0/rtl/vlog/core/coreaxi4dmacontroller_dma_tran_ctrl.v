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
module CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_DMATranCtrl (
    // General inputs
    clock,
    resetn,

    // DMAArbiter inputs
    doTrans_DMAArbiter,
    strDscrptr_DMAArbiter,
    intDscrptrNum_DMAArbiter,
    extDscrptrAddr_DMAArbiter,
    extDscrptr_DMAArbiter,
    priLvl_DMAArbiter,
    dataValid_DMAArbiter,
    intOnProcess_DMAArbiter,
    srcAddr_DMAArbiter,
    srcOp_DMAArbiter,
    srcDataWidth_DMAArbiter,
    numOfBytes_DMAArbiter,
    chain_DMAArbiter,
    extDscrptrNxt_DMAArbiter,
    nxtDscrptrNumAddr_DMAArbiter,
    dstAddr_DMAArbiter,
    dstOp_DMAArbiter,
    dstDataWidth_DMAArbiter,

    // IntStatus inputs
    intStaAck_IntStatus,

    // AXI4MasterCtrl inputs
    AXIWrTransDone_AXI4MasterCtrl,
    AXIRdTransDone_AXI4MasterCtrl,
    AXIWrTransError_AXI4MasterCtrl,
    AXIRdTransError_AXI4MasterCtrl,
    AXI4StreamWrTransDone,
    AXI4StreamWrTransError,
    numOfBytesInRdValid_AXI4MasterCtrl,
    numOfBytesInRd_AXI4MasterCtrl,
    strRdyToAck,
    numOfBytesInWr_AXI4MasterCtrl,
    strFetchAck_AXI4MasterCtrl,
    strDataValid_AXIMasterCtrl,
    clrStrDscrptrDataValidAck,

    // ExtDscrptrFetch inputs
    strFetchHoldOff_ExtDscrptrFetch,
    extFetchDone_ExtDscrptrFetch,
    extClrAck_ExtDscrptrFetch,
    extRdyValid_ExtDscrptrFetch,
    extRdy_ExtDscrptrFetch,

    // DscrptrSrcMux inputs
    intFetchAck_DscrptrSrcMux,

    // DMAArbiter outputs
    transAck,
    strDscrptr_DMATranCtrl,
    extDataValid,
    newNumOfBytes,
    newSrcAddr,
    newDstAddr,
    clrReq,
    intDscrptrNum_clrReq,

    // IntStatusMux outputs
    intStaValid,
    opDone,
    wrError,
    rdError,
    intDscrptrNum_IntStatusMux,
    extDscrptr_IntStatusMux,
    extDscrptrAddr_IntStatusMux,
    strDscrptr_IntStatusMux,

    // Cache outputs
    wrCache1Sel,
    rdCache1Sel,
    
    // AXI4MasterCtrl outputs
    strtAXIWrTran,
    strtAXIRdTran,
    srcAXITranType,
    srcNumOfBytes,
    srcAXIDataWidth,
    srcStrtAddr,
    srcMaxAXINumBeats,
    dstStrDscrptr,
    dstAXITranType,
    dstNumOfBytesInRd_AXI4MasterCtrl,
    dstAXIDataWidth,
    dstStrtAddr,
    dstSrcAXIDataWidth,
    dstMaxAXINumBeats,
    strFetchRdy,
    strFetchAddr,
    clrStrDscrptrDataValid,
    clrStrDscrptrAddr,
    clrStrDscrptrDstOp,
    
    // ExtDscrptrFetch outputs
    fetchExtDscrptr,
    clrExtDscrptr,
    extRdyCheck,
    intDscrptrNum_ExtDscrptrFetch,
    extDscrptrAddr_ExtDscrptrFetch,
    configRegByte2,

    // DscrptrSrcMux outputs
    fetchIntDscrptr,
    intDscrptrNum_DscrptrSrcMux,
    
    // AXI4StreamSlaveCtrl outputs
    strMemMapWrDone,
    strMemMapWrError
);

////////////////////////////////////////////////////////////////////////////////
// User modifiable parameters
////////////////////////////////////////////////////////////////////////////////
parameter AXI4_STREAM_IF            = 0;
parameter NUM_INT_BDS               = 4;
parameter NUM_INT_BDS_WIDTH         = 2;
parameter MAX_TRAN_SIZE_WIDTH       = 23; // 8 MB
parameter MAX_AXI_TRAN_SIZE_WIDTH   = 12; // 4 KB
parameter NUM_PRI_LVLS              = 1;
parameter MAX_AXI_NUM_BEATS_WIDTH   = 0;
parameter PRI_0_NUM_OF_BEATS        = 0;
parameter PRI_1_NUM_OF_BEATS        = 0;
parameter PRI_2_NUM_OF_BEATS        = 0;
parameter PRI_3_NUM_OF_BEATS        = 0;
parameter PRI_4_NUM_OF_BEATS        = 0;
parameter PRI_5_NUM_OF_BEATS        = 0;
parameter PRI_6_NUM_OF_BEATS        = 0;
parameter PRI_7_NUM_OF_BEATS        = 0;

////////////////////////////////////////////////////////////////////////////////
// Port directions
////////////////////////////////////////////////////////////////////////////////
// General inputs
input                                   clock;
input                                   resetn;

// DMAArbiter inputs
input                                   doTrans_DMAArbiter;
input                                   strDscrptr_DMAArbiter;
input  [NUM_INT_BDS_WIDTH-1:0]          intDscrptrNum_DMAArbiter;
input  [31:0]                           extDscrptrAddr_DMAArbiter;
input                                   extDscrptr_DMAArbiter;
input  [NUM_PRI_LVLS-1:0]               priLvl_DMAArbiter;
input                                   dataValid_DMAArbiter;
input                                   intOnProcess_DMAArbiter;
input  [31:0]                           srcAddr_DMAArbiter;
input  [1:0]                            srcOp_DMAArbiter;
input  [2:0]                            srcDataWidth_DMAArbiter;
input  [MAX_TRAN_SIZE_WIDTH-1:0]        numOfBytes_DMAArbiter;
input                                   chain_DMAArbiter;
input                                   extDscrptrNxt_DMAArbiter;
input  [31:0]                           nxtDscrptrNumAddr_DMAArbiter;
input  [31:0]                           dstAddr_DMAArbiter;
input  [1:0]                            dstOp_DMAArbiter;
input  [2:0]                            dstDataWidth_DMAArbiter;

// IntStatus inputs
input                                   intStaAck_IntStatus;

// AXI4MasterCtrl inputs
input                                   AXIWrTransDone_AXI4MasterCtrl;
input                                   AXIRdTransDone_AXI4MasterCtrl;
input                                   AXIWrTransError_AXI4MasterCtrl;
input                                   AXIRdTransError_AXI4MasterCtrl;
input                                   AXI4StreamWrTransDone;
input                                   AXI4StreamWrTransError;
input                                   numOfBytesInRdValid_AXI4MasterCtrl;
input  [MAX_AXI_TRAN_SIZE_WIDTH-1:0]    numOfBytesInRd_AXI4MasterCtrl;
input                                   strRdyToAck;
input  [MAX_AXI_TRAN_SIZE_WIDTH-1:0]    numOfBytesInWr_AXI4MasterCtrl;
input                                   strFetchAck_AXI4MasterCtrl;
input                                   strDataValid_AXIMasterCtrl;
input                                   clrStrDscrptrDataValidAck;

// ExtDscrptrFetch inputs
input                                   strFetchHoldOff_ExtDscrptrFetch;
input                                   extFetchDone_ExtDscrptrFetch;
input                                   extClrAck_ExtDscrptrFetch;
input                                   extRdyValid_ExtDscrptrFetch;
input                                   extRdy_ExtDscrptrFetch;

// DscrptrSrcMux inputs
input                                   intFetchAck_DscrptrSrcMux;

// DMAArbiter outputs
output                                  transAck;
output                                  strDscrptr_DMATranCtrl;
output                                  extDataValid;
output [MAX_TRAN_SIZE_WIDTH-1:0]        newNumOfBytes;
output [31:0]                           newSrcAddr;
output [31:0]                           newDstAddr;
output                                  clrReq;
output [NUM_INT_BDS_WIDTH-1:0]          intDscrptrNum_clrReq;

// IntStatusMux outputs
output                                  intStaValid;
output                                  opDone;
output                                  wrError;
output                                  rdError;
output [NUM_INT_BDS_WIDTH-1:0]          intDscrptrNum_IntStatusMux;
output                                  extDscrptr_IntStatusMux;
output [31:0]                           extDscrptrAddr_IntStatusMux;
output                                  strDscrptr_IntStatusMux;

// Cache outputs
output                                  wrCache1Sel;
output                                  rdCache1Sel;
    
// AXI4MasterCtrl outputs
output                                  strtAXIWrTran;
output                                  strtAXIRdTran;
output [1:0]                            srcAXITranType;
output [MAX_TRAN_SIZE_WIDTH-1:0]        srcNumOfBytes;
output [2:0]                            srcAXIDataWidth;
output [31:0]                           srcStrtAddr;
output [MAX_AXI_NUM_BEATS_WIDTH-1:0]    srcMaxAXINumBeats;
output                                  dstStrDscrptr;
output [1:0]                            dstAXITranType;
output [MAX_TRAN_SIZE_WIDTH-1:0]        dstNumOfBytesInRd_AXI4MasterCtrl;
output [2:0]                            dstAXIDataWidth;
output [31:0]                           dstStrtAddr;
output [2:0]                            dstSrcAXIDataWidth;
output [MAX_AXI_NUM_BEATS_WIDTH-1:0]    dstMaxAXINumBeats;
output                                  strFetchRdy;
output [31:0]                           strFetchAddr;
output                                  clrStrDscrptrDataValid;
output [31:0]                           clrStrDscrptrAddr;
output [1:0]                            clrStrDscrptrDstOp;

// ExtDscrptrFetch outputs
output                                  fetchExtDscrptr;
output                                  clrExtDscrptr;
output                                  extRdyCheck;
output [NUM_INT_BDS_WIDTH-1:0]          intDscrptrNum_ExtDscrptrFetch;
output [31:0]                           extDscrptrAddr_ExtDscrptrFetch;
output [7:0]                            configRegByte2;

// DscrptrSrcMux outputs
output                                  fetchIntDscrptr;
output [NUM_INT_BDS_WIDTH-1:0]          intDscrptrNum_DscrptrSrcMux;

// AXI4StreamSlaveCtrl outputs
output                                  strMemMapWrDone;
output                                  strMemMapWrError;

////////////////////////////////////////////////////////////////////////////////
// Internal signals
////////////////////////////////////////////////////////////////////////////////
wire [31:0]                         extDscrptrAddr_extRdyCheck;
wire [31:0]                         extDscrptrAddr_clrFetch;
wire                                spaceWrQueue;
wire [NUM_INT_BDS_WIDTH-1:0]        intDscrptrNum_WrTranQueue0;
wire [NUM_INT_BDS_WIDTH-1:0]        intDscrptrNum_WrTranQueue1;
wire [31:0]                         extDscrptrAddr_WrTranQueue;
wire                                extDscrptr_WrTranQueue;
wire                                chain_RdTranQueue;
wire                                extDscrptrNxt_RdTranQueue;
wire [MAX_TRAN_SIZE_WIDTH-1:0]      numOfBytes_WrTranQueue;
wire                                spaceRdQueue;
wire [NUM_INT_BDS_WIDTH-1:0]        intDscrptrNum_RdTranQueue0;
wire [NUM_INT_BDS_WIDTH-1:0]        intDscrptrNum_RdTranQueue1;
wire [31:0]                         extDscrptrAddr_RdTranQueue;
wire                                wrDone_DMAWrTranCtrl;
wire                                wrError_DMAWrTranCtrl;
wire                                strWrDone_DMAWrTranCtrl;
wire                                strWrError_DMAWrTranCtrl;
wire                                rdDone_DMARdTranCtrl;
wire                                rdError_DMARdTranCtrl;
wire                                extDataValidNSet;
wire [1:0]                          clrWrTranQueue;
wire [1:0]                          clrRdTranQueue;
wire                                wrDoneAck_DMAWrTranCtrl;
wire                                wrErrorAck_DMAWrTranCtrl;
wire                                strWrDoneAck_DMAWrTranCtrl;
wire                                strWrErrorAck_DMAWrTranCtrl;
wire                                rdDoneAck_DMARdTranCtrl;
wire                                rdErrorAck_DMARdTranCtrl;
wire                                extDataValidNSetAck;
wire [31:0]                         nxtDscrptrNumAddr_RdTranQueue;
wire                                reqInQueue_RdTranQueue;
wire [NUM_PRI_LVLS-1:0]             priLvl_RdTranQueue;
wire                                extDscrptr_RdTranQueue;
wire                                dataValid_RdTranQueue;
wire [1:0]                          srcOp_RdTranQueue;
wire [2:0]                          srcDataWidth_RdTranQueue;
wire [2:0]                          dstDataWidth_RdTranQueue;
wire [31:0]                         srcAddr_RdTranQueue;
wire [MAX_TRAN_SIZE_WIDTH-1:0]      numOfBytes_RdTranQueue;
wire                                rdyToAck;
wire                                extDataValid_DMARdTranCtrl;
wire [1:0]                          dstOp_WrTranQueue;
wire [31:0]                         dstAddr_wrCache1Sel;
wire [31:0]                         dstAddr_rdCache1Sel;
wire                                reqInQueue_WrTranQueue;
wire [2:0]                          dstDataWidth_WrTranQueue;
wire [2:0]                          srcDataWidth_WrTranQueue;
wire [NUM_PRI_LVLS-1:0]             priLvl_WrTranQueue;
wire                                chain_WrTranQueue;
wire                                extDscrptrNxt_WrTranQueue;
wire [7:0]                          configRegUpperByte;
wire                                clrNumOfBytesInRd;
wire                                numOfBytesInRdValid_rdNumOfBytesReg;
wire [MAX_AXI_TRAN_SIZE_WIDTH-1:0]  numOfBytesInRd_intErrorCtrl;
wire [MAX_AXI_TRAN_SIZE_WIDTH-1:0]  numOfBytesInRd_numOfBytesInRdReg;
wire                                intOnProcess;
reg  [1:0]                          numOfBytesInRdValidReg;
reg  [MAX_AXI_TRAN_SIZE_WIDTH-1:0]  numOfBytesInRdReg [0:1];
reg                                 currState;
reg                                 nextState;
reg                                 queueWr;
reg                                 queueWr_reg1;
reg                                 queueWr_reg2;
wire [31:0]                         nxtDscrptrNumAddr_WrTranQueue;
wire                                strDscrptr_RdTranQueue;
wire                                strDscrptr_WrTranQueue;
wire                                dataValid_WrTranQueue;
wire                                strDataNReady;
wire                                noOpSrc;
wire                                noOpDst;
wire                                noOpSrcAck;
wire                                noOpDstAck;

////////////////////////////////////////////////////////////////////////////////
// Constants
////////////////////////////////////////////////////////////////////////////////
localparam IDLE     = 1'b0;
localparam WAIT_ACK = 1'b1;

// extDscrptrAddr_ExtDscrptrFetch mux
assign extDscrptrAddr_ExtDscrptrFetch = (extRdyCheck) ? extDscrptrAddr_extRdyCheck : extDscrptrAddr_clrFetch;
                 // Dscrptr Valid, dstRdy, srcValid,    IOP,            extDscrptrNext,             chain,             dstDataWidth[2:0]
assign configRegUpperByte = {1'b1, 1'b0, 1'b0, intOnProcess, extDscrptrNxt_WrTranQueue, chain_WrTranQueue, dstDataWidth_WrTranQueue[2:1]};

////////////////////////////////////////////////////////////////////////////////
// FSM to ensure doTrans only registered once
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
        case (currState)
            IDLE:
                begin
                    if (doTrans_DMAArbiter & spaceRdQueue & spaceWrQueue)
                        begin
                            queueWr   <= 1'b1;
                            nextState <= WAIT_ACK;
                        end
                    else
                        begin
                            queueWr   <= 1'b0;
                            nextState <= IDLE;
                        end
                end
            WAIT_ACK:
                begin
                    queueWr   <= 1'b0;
                    if (transAck)
                        begin
                            nextState <= IDLE;
                        end
                    else
                        begin
                            nextState <= WAIT_ACK;
                        end
                end
        endcase
    end

	
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
				queueWr_reg1 <= 0;
				queueWr_reg2 <= 0;
			end
		else
			begin
				queueWr_reg1 <= queueWr;
				queueWr_reg2 <= queueWr_reg1;
			end
	end
////////////////////////////////////////////////////////////////////////////////
// intErrorCtrl instantiation
////////////////////////////////////////////////////////////////////////////////
CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_intErrorCtrl # (
    .NUM_INT_BDS                    (NUM_INT_BDS),
    .NUM_INT_BDS_WIDTH              (NUM_INT_BDS_WIDTH),
    .MAX_TRAN_SIZE_WIDTH            (MAX_TRAN_SIZE_WIDTH),
    .MAX_AXI_TRAN_SIZE_WIDTH        (MAX_AXI_TRAN_SIZE_WIDTH)
) intErrorCtrl_inst (
    // General inputs
    .clock                          (clock),
    .resetn                         (resetn),

    // wrTranQueue inputs
    .spaceWrQueue                   (spaceWrQueue),
    .intDscrptrNum_WrTranQueue0     (intDscrptrNum_WrTranQueue0),
    .intDscrptrNum_WrTranQueue1     (intDscrptrNum_WrTranQueue1),
    .extDscrptrAddr_WrTranQueue     (extDscrptrAddr_WrTranQueue),
    .extDscrptr_WrTranQueue         (extDscrptr_WrTranQueue),
    .nxtDscrptr_WrTranQueue         (nxtDscrptrNumAddr_WrTranQueue),
    .numOfBytes_WrTranQueue         (numOfBytes_WrTranQueue),
    .configRegUpperByte             (configRegUpperByte),
    .intOnProcess                   (intOnProcess),
    .chain_WrTranQueue              (chain_WrTranQueue),
    .extDscrptrNxt_WrTranQueue      (extDscrptrNxt_WrTranQueue),
    .dstOp_WrTranQueue              (dstOp_WrTranQueue),

    // rdTranQueue inputs
    .spaceRdQueue                   (spaceRdQueue),
    .extDscrptr_RdTranQueue         (extDscrptr_RdTranQueue),
    .chain_RdTranQueue              (chain_RdTranQueue),
    .extDscrptrNxt_RdTranQueue      (extDscrptrNxt_RdTranQueue),
    .intDscrptrNum_RdTranQueue0     (intDscrptrNum_RdTranQueue0),
    .intDscrptrNum_RdTranQueue1     (intDscrptrNum_RdTranQueue1),
    .extDscrptrAddr_RdTranQueue     (extDscrptrAddr_RdTranQueue),
    .numOfBytes_RdTranQueue         (numOfBytes_RdTranQueue),
    .numOfBytesInRd                 (numOfBytesInRd_intErrorCtrl),
    
    // DMAWrTranCtrl inputs
    .wrDone_DMAWrTranCtrl           (wrDone_DMAWrTranCtrl),
    .wrError_DMAWrTranCtrl          (wrError_DMAWrTranCtrl),
    .strWrDone_DMAWrTranCtrl        (strWrDone_DMAWrTranCtrl),
    .strWrError_DMAWrTranCtrl       (strWrError_DMAWrTranCtrl),
    .dstAXINumOfBytes               (numOfBytesInRd_numOfBytesInRdReg),
    .clrStrDscrptrDataValidAck      (clrStrDscrptrDataValidAck),
    .noOpDst                        (noOpDst),
    .strDataNReady                  (strDataNReady),
    
    // DMARdTranCtrl inputs
    .rdDone_DMARdTranCtrl           (rdDone_DMARdTranCtrl),
    .rdError_DMARdTranCtrl          (rdError_DMARdTranCtrl),
    .extDataValidNSet               (extDataValidNSet),
    .noOpSrc                        (noOpSrc),
    
    // intStatusMux inputs
    .intStaAck                      (intStaAck_IntStatus),
    
    // extDscrptrFetch inputs
    .extFetchDone                   (extFetchDone_ExtDscrptrFetch),
    .extClrAck                      (extClrAck_ExtDscrptrFetch),
    
    // DMA Arbiter outputs
    .clrReq                         (clrReq),
    .intDscrptrNum_clrReq           (intDscrptrNum_clrReq),
    
    // wrTranQueue outputs
    .clrWrTranQueue                 (clrWrTranQueue),
    
    // rdTranQueue outputs
    .clrRdTranQueue                 (clrRdTranQueue),
    
    // intStatusMux outputs
    .intStaValid                    (intStaValid),
    .opDone                         (opDone),
    .wrError                        (wrError),
    .rdError                        (rdError),
    .intDscrptrNum_intStatusMux     (intDscrptrNum_IntStatusMux),
    .extDscrptr_intStatusMux        (extDscrptr_IntStatusMux),
    .extDscrptrAddr_intStatusMux    (extDscrptrAddr_IntStatusMux),
    .strDscrptr_intStatusMux        (strDscrptr_IntStatusMux),
    
    // DMAWrTranCtrl outputs
    .wrDoneAck_DMAWrTranCtrl        (wrDoneAck_DMAWrTranCtrl),
    .wrErrorAck_DMAWrTranCtrl       (wrErrorAck_DMAWrTranCtrl),
    .strWrDoneAck_DMAWrTranCtrl     (strWrDoneAck_DMAWrTranCtrl),
    .strWrErrorAck_DMAWrTranCtrl    (strWrErrorAck_DMAWrTranCtrl),
    .clrStrDscrptrDataValid         (clrStrDscrptrDataValid),
    .clrStrDscrptrAddr              (clrStrDscrptrAddr),
    .clrStrDscrptrDstOp             (clrStrDscrptrDstOp),
    .noOpDstAck                     (noOpDstAck),
    
    // DMARdTranCtrl outputs
    .rdDoneAck_DMARdTranCtrl        (rdDoneAck_DMARdTranCtrl),
    .rdErrorAck_DMARdTranCtrl       (rdErrorAck_DMARdTranCtrl),
    .extDataValidNSetAck            (extDataValidNSetAck),
    .noOpSrcAck                     (noOpSrcAck),
    
    // Cache outputs
    .wrCache1Sel                    (wrCache1Sel),
    .rdCache1Sel                    (rdCache1Sel),
    
    // ExtDscrptrFetch outputs
    .extDscrptrFetch                (fetchExtDscrptr),
    .clrExtDscrptrDataValid         (clrExtDscrptr),
    .intDscrptrNum_extFetch         (intDscrptrNum_ExtDscrptrFetch),
    .extDscrptrAddr_extFetch        (extDscrptrAddr_clrFetch),
    .configRegByte2                 (configRegByte2),
    .clrNumOfBytesInRd              (clrNumOfBytesInRd),
    
    // AXI4StreamSlaveCtrl outputs
    .strMemMapWrDone                (strMemMapWrDone),
    .strMemMapWrError               (strMemMapWrError)
);

////////////////////////////////////////////////////////////////////////////////
// rdTranQueue instantiation
////////////////////////////////////////////////////////////////////////////////
CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_rdTranQueue # (
    .NUM_INT_BDS                    (NUM_INT_BDS),
    .NUM_INT_BDS_WIDTH              (NUM_INT_BDS_WIDTH),
    .NUM_PRI_LVLS                   (NUM_PRI_LVLS),
    .MAX_TRAN_SIZE_WIDTH            (MAX_TRAN_SIZE_WIDTH)
) rdTranQueue_inst (
    // General inputs
    .clock                          (clock),
    .resetn                         (resetn),

    // DMAArbiter inputs
    .doTrans                        (queueWr_reg2 & !strDscrptr_DMAArbiter),
    .intDscrptrNum_DMAArbiter       (intDscrptrNum_DMAArbiter),
    .extDscrptrAddr_DMAArbiter      (extDscrptrAddr_DMAArbiter),
    .extDscrptr_DMAArbiter          (extDscrptr_DMAArbiter),
    .dataValid_DMAArbiter           (dataValid_DMAArbiter),
    .srcAddr_DMAArbiter             (srcAddr_DMAArbiter),
    .srcOp_DMAArbiter               (srcOp_DMAArbiter),
    .srcDataWidth_DMAArbiter        (srcDataWidth_DMAArbiter),
    .dstDataWidth_DMAArbiter        (dstDataWidth_DMAArbiter),
    .numOfBytes_DMAArbiter          (numOfBytes_DMAArbiter),
    .priLvl_DMAArbiter              (priLvl_DMAArbiter),
    .chain_DMAArbiter               (chain_DMAArbiter),
    .extDscrptrNxt_DMAArbiter       (extDscrptrNxt_DMAArbiter),
    .nxtDscrptrNumAddr_DMAArbiter   (nxtDscrptrNumAddr_DMAArbiter),

    // wrTranQueue inputs
    .spaceWrTranQueue               (spaceWrQueue),

    // intErrorCtrl inputs
    .clrRdTranQueue                 (clrRdTranQueue),
    .rdCache1Sel                    (rdCache1Sel),

    .intDscrptrNum_rdTranQueue0     (intDscrptrNum_RdTranQueue0),
    .intDscrptrNum_rdTranQueue1     (intDscrptrNum_RdTranQueue1),
    .chain                          (chain_RdTranQueue),
    .extDscrptrNxt                  (extDscrptrNxt_RdTranQueue),

    // rdTranCtrl outputs
    .reqInQueue                     (reqInQueue_RdTranQueue),
    .priLvl                         (priLvl_RdTranQueue),
    .extDscrptr                     (extDscrptr_RdTranQueue),
    .extDscrptrAddr                 (extDscrptrAddr_RdTranQueue),
    .dataValid                      (dataValid_RdTranQueue),
    .srcOp                          (srcOp_RdTranQueue),
    .srcDataWidth                   (srcDataWidth_RdTranQueue),
    .dstDataWidth                   (dstDataWidth_RdTranQueue),
    .srcAddr                        (srcAddr_RdTranQueue),
    .numOfBytes                     (numOfBytes_RdTranQueue),

    // transAck outputs. Some are shared with rdTranCtrl block
    .spaceRdTranQueue               (spaceRdQueue),
    .nxtDscrptrNumAddr              (nxtDscrptrNumAddr_RdTranQueue)
);

////////////////////////////////////////////////////////////////////////////////
// rdTranCtrl instantiation
////////////////////////////////////////////////////////////////////////////////
CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_rdTranCtrl # (
    .MAX_TRAN_SIZE_WIDTH            (MAX_TRAN_SIZE_WIDTH),
    .MAX_AXI_TRAN_SIZE_WIDTH        (MAX_AXI_TRAN_SIZE_WIDTH),
    .NUM_PRI_LVLS                   (NUM_PRI_LVLS),
    .MAX_AXI_NUM_BEATS_WIDTH        (MAX_AXI_NUM_BEATS_WIDTH),
    .PRI_0_NUM_OF_BEATS             (PRI_0_NUM_OF_BEATS),
    .PRI_1_NUM_OF_BEATS             (PRI_1_NUM_OF_BEATS),
    .PRI_2_NUM_OF_BEATS             (PRI_2_NUM_OF_BEATS),
    .PRI_3_NUM_OF_BEATS             (PRI_3_NUM_OF_BEATS),
    .PRI_4_NUM_OF_BEATS             (PRI_4_NUM_OF_BEATS),
    .PRI_5_NUM_OF_BEATS             (PRI_5_NUM_OF_BEATS),
    .PRI_6_NUM_OF_BEATS             (PRI_6_NUM_OF_BEATS),
    .PRI_7_NUM_OF_BEATS             (PRI_7_NUM_OF_BEATS)
) rdTranCtrl_inst (
    // General inputs
    .clock                              (clock),
    .resetn                             (resetn),
    
    // rdTranQueue inputs
    .reqInQueue                         (reqInQueue_RdTranQueue & !strFetchHoldOff_ExtDscrptrFetch),
    .priLvl                             (priLvl_RdTranQueue),
    .extDscrptr                         (extDscrptr_RdTranQueue),
    .extDscrptrAddr                     (extDscrptrAddr_RdTranQueue),
    .srcOp                              (srcOp_RdTranQueue),
    .srcDataWidth                       (srcDataWidth_RdTranQueue),
    .dstDataWidth                       (dstDataWidth_RdTranQueue),
    .srcAddr                            (srcAddr_RdTranQueue),
    .numOfBytes                         (numOfBytes_RdTranQueue),
    .dataValidExtDscrptr                (dataValid_RdTranQueue),
    
    // extDscrptrFetch inputs
    .extRdyValid                        (extRdyValid_ExtDscrptrFetch),
    .extRdy                             (extRdy_ExtDscrptrFetch),
    
    // AXI4MasterCtrl inputs
    .rdTranDone                         (AXIRdTransDone_AXI4MasterCtrl),
    .rdTranError                        (AXIRdTransError_AXI4MasterCtrl),
    .numOfBytesInRdValid_AXI4MasterCtrl (numOfBytesInRdValid_AXI4MasterCtrl),
    
    // intErrorCtrl inputs
    .rdDoneAck                          (rdDoneAck_DMARdTranCtrl),
    .rdErrorAck                         (rdErrorAck_DMARdTranCtrl),
    .extDataValidNSetAck                (extDataValidNSetAck),
    .noOpSrcAck                         (noOpSrcAck),
    
    // extDscrptrFetch outputs
    .extRdyCheck                        (extRdyCheck),
    .extDscrptrAddr_ExtDscrptrFetch     (extDscrptrAddr_extRdyCheck),
    
    // intErrorCtrl outputs
    .rdDone                             (rdDone_DMARdTranCtrl),
    .rdError                            (rdError_DMARdTranCtrl),
    .noOpSrc                            (noOpSrc),
    
    // AXI4MasterCtrl outputs
    .strtAXIRdTran                      (strtAXIRdTran),
    .srcNumOfBytes                      (srcNumOfBytes),
    .srcAXITranType                     (srcAXITranType),
    .srcAXIDataWidth                    (srcAXIDataWidth),
    .srcStrtAddr                        (srcStrtAddr),
    .srcMaxAXINumBeats                  (srcMaxAXINumBeats),
    
    // transAck outputs
    .rdyToAck                           (rdyToAck),
    .extDataValid                       (extDataValid_DMARdTranCtrl),
    
    // intErrorCtrlFSM outputs
    .extDataValidNSet                   (extDataValidNSet)
);

////////////////////////////////////////////////////////////////////////////////
// transAck instantiation
////////////////////////////////////////////////////////////////////////////////
CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_transAck # (
    .NUM_INT_BDS_WIDTH              (NUM_INT_BDS_WIDTH),
    .MAX_TRAN_SIZE_WIDTH            (MAX_TRAN_SIZE_WIDTH),
    .MAX_AXI_TRAN_SIZE_WIDTH        (MAX_AXI_TRAN_SIZE_WIDTH),
    .AXI4_STREAM_IF                 (AXI4_STREAM_IF)
) transAck_inst (
    // General inputs
    .clock                          (clock),
    .resetn                         (resetn),
        
    // DMAArbiter inputs
    .doTrans                        (doTrans_DMAArbiter),
        
    // DscrptrSrcMux inputs
    .intFetchAck                    (intFetchAck_DscrptrSrcMux),
    
    // DMAWrTranCtrl inputs
    .strRdyToAck                    (strRdyToAck),
    .dstAXINumOfBytes               (numOfBytesInWr_AXI4MasterCtrl),
    .strDataNReady                  (strDataNReady),
    
    // DMARdTranCtrl inputs
    .rdyToAck                       (rdyToAck),
    .extDataValid_DMARdTranCtrl     (extDataValid_DMARdTranCtrl),

    // numOfBytesInRdReg
    .srcAXINumOfBytes               (numOfBytesInRdReg[rdCache1Sel]),

    // WrTranQueue inputs
    .spaceWrTranQueue               (spaceWrQueue),
    .dstOp                          (dstOp_WrTranQueue),
    .dstAddr_WrTranQueue            (dstAddr_rdCache1Sel),
    .numOfBytes_WrTranQueue         (numOfBytes_WrTranQueue),
    
    // RdTranQueue inputs
    .spaceRdTranQueue               (spaceRdQueue),
    .chain                          (chain_RdTranQueue),
    .extDscrptrNxt                  (extDscrptrNxt_RdTranQueue),
    .extDscrptr                     (extDscrptr_RdTranQueue),
    .srcOp                          (srcOp_RdTranQueue),
    .srcAddr_RdTranQueue            (srcAddr_RdTranQueue),
    .numOfBytes_RdTranQueue         (numOfBytes_RdTranQueue),
    .intDscrptrNum_RdTranQueue0     (intDscrptrNum_RdTranQueue0),
    .intDscrptrNum_RdTranQueue1     (intDscrptrNum_RdTranQueue1),
    .nxtIntDscrptrNum_rdTranQueue   (nxtDscrptrNumAddr_RdTranQueue[NUM_INT_BDS_WIDTH-1:0]),

    // intErrorCtrl inputs
    .rdCache1Sel                    (rdCache1Sel),
    
    // DMAARbiter outputs
    .transAck                       (transAck),
    .strDscrptr                     (strDscrptr_DMATranCtrl),
    .extDataValid                   (extDataValid),
    .newNumOfBytes                  (newNumOfBytes),
    .newSrcAddr                     (newSrcAddr),
    .newDstAddr                     (newDstAddr),
    
    // DscrptrSrcMux outputs
    .fetchIntDscrptr                (fetchIntDscrptr),
    .intDscrptrNum                  (intDscrptrNum_DscrptrSrcMux)
);

////////////////////////////////////////////////////////////////////////////////
// wrTranQueue instantiation
////////////////////////////////////////////////////////////////////////////////
CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_wrTranQueue # (
    .NUM_INT_BDS                    (NUM_INT_BDS),
    .NUM_INT_BDS_WIDTH              (NUM_INT_BDS_WIDTH),
    .NUM_PRI_LVLS                   (NUM_PRI_LVLS),
    .MAX_TRAN_SIZE_WIDTH            (MAX_TRAN_SIZE_WIDTH)
) wrTranQueue_inst (
    // General inputs
    .clock                          (clock),
    .resetn                         (resetn),

    // DMAArbiter inputs
    .doTrans                        (queueWr_reg2),
    .strDscrptr_DMAArbiter          (strDscrptr_DMAArbiter),
    .intDscrptrNum_DMAArbiter       (intDscrptrNum_DMAArbiter),
    .extDscrptrAddr_DMAArbiter      (extDscrptrAddr_DMAArbiter),
    .extDscrptr_DMAArbiter          (extDscrptr_DMAArbiter),
    .dstAddr_DMAArbiter             (dstAddr_DMAArbiter),
    .dataValid_DMAArbiter           (dataValid_DMAArbiter),
    .dstOp_DMAArbiter               (dstOp_DMAArbiter),
    .dstDataWidth_DMAArbiter        (dstDataWidth_DMAArbiter),
    .srcDataWidth_DMAArbiter        (srcDataWidth_DMAArbiter),
    .numOfBytes_DMAArbiter          (numOfBytes_DMAArbiter),
    .priLvl_DMAArbiter              (priLvl_DMAArbiter),
    .chain_DMAArbiter               (chain_DMAArbiter),
    .extDscrptrNxt_DMAArbiter       (extDscrptrNxt_DMAArbiter),
    .intOnProcess_DMAArbiter        (intOnProcess_DMAArbiter),
    .nxtDscrptrNumAddr_DMAArbiter   (nxtDscrptrNumAddr_DMAArbiter),

    // intErrorCtrl inputs
    .clrWrTranQueue                 (clrWrTranQueue),
    .wrCache1Sel                    (wrCache1Sel),
    
    // rdTranCtrl inputs
    .rdyToAck                       (rdyToAck),
    .extDataValid                   (extDataValid_DMARdTranCtrl),
    .rdCache1Sel                    (rdCache1Sel),

    // wrTranCtrl outputs
    .reqInQueue                     (reqInQueue_WrTranQueue),
    .strDscrptr                     (strDscrptr_WrTranQueue),
    .priLvl                         (priLvl_WrTranQueue),
    .dataValid                      (dataValid_WrTranQueue),
    .dstOp                          (dstOp_WrTranQueue),
    .dstDataWidth                   (dstDataWidth_WrTranQueue),
    .srcDataWidth                   (srcDataWidth_WrTranQueue),
    .dstAddr_wrCache1Sel            (dstAddr_wrCache1Sel),
    .dstAddr_rdCache1Sel            (dstAddr_rdCache1Sel),
    .numOfBytes                     (numOfBytes_WrTranQueue),
    .intDscrptrNum_wrTranQueue0     (intDscrptrNum_WrTranQueue0),
    .intDscrptrNum_wrTranQueue1     (intDscrptrNum_WrTranQueue1),
    .extDscrptrAddr                 (extDscrptrAddr_WrTranQueue),
    .extDscrptr                     (extDscrptr_WrTranQueue),
    
    // intErrorCtrl outputs
    .chain                          (chain_WrTranQueue),
    .extDscrptrNxt                  (extDscrptrNxt_WrTranQueue),
    .intOnProcess                   (intOnProcess),
    .nxtDscrptrNumAddr              (nxtDscrptrNumAddr_WrTranQueue),

    // transAck outputs. Some are shared with wrTranCtrl block
    .spaceWrTranQueue               (spaceWrQueue)
);

////////////////////////////////////////////////////////////////////////////////
// wrTranCtrl instantiation
////////////////////////////////////////////////////////////////////////////////
CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_wrTranCtrl # (
    .NUM_PRI_LVLS                           (NUM_PRI_LVLS),
    .MAX_TRAN_SIZE_WIDTH                    (MAX_TRAN_SIZE_WIDTH),
    .MAX_AXI_TRAN_SIZE_WIDTH                (MAX_AXI_TRAN_SIZE_WIDTH),
    .MAX_AXI_NUM_BEATS_WIDTH                (MAX_AXI_NUM_BEATS_WIDTH),
    .PRI_0_NUM_OF_BEATS                     (PRI_0_NUM_OF_BEATS),
    .PRI_1_NUM_OF_BEATS                     (PRI_1_NUM_OF_BEATS),
    .PRI_2_NUM_OF_BEATS                     (PRI_2_NUM_OF_BEATS),
    .PRI_3_NUM_OF_BEATS                     (PRI_3_NUM_OF_BEATS),
    .PRI_4_NUM_OF_BEATS                     (PRI_4_NUM_OF_BEATS),
    .PRI_5_NUM_OF_BEATS                     (PRI_5_NUM_OF_BEATS),
    .PRI_6_NUM_OF_BEATS                     (PRI_6_NUM_OF_BEATS),
    .PRI_7_NUM_OF_BEATS                     (PRI_7_NUM_OF_BEATS)
) wrTranCtrl_inst (
    // General inputs
    .clock                                  (clock),
    .resetn                                 (resetn),
    
    // wrTranQueue inputs
    .reqInQueue                             (reqInQueue_WrTranQueue),
    .numOfBytes                             (numOfBytes_WrTranQueue),
    .strDscrptr                             (strDscrptr_WrTranQueue),
    .dataValid                              (dataValid_WrTranQueue),
    .priLvl                                 (priLvl_WrTranQueue),
    .dstOp                                  (dstOp_WrTranQueue),
    .dstDataWidth                           (dstDataWidth_WrTranQueue),
    .srcDataWidth                           (srcDataWidth_WrTranQueue),
    .dstAddr                                (dstAddr_wrCache1Sel),
    .extDscrptrAddr                         (extDscrptrAddr_WrTranQueue),
    
    // rdNumOfBytes register inputs
    .numOfBytesInRdValid_rdNumOfBytesReg    (numOfBytesInRdValid_rdNumOfBytesReg),
    .numOfBytesInRd_rdNumOfBytesReg         (numOfBytesInRd_numOfBytesInRdReg),   
    
    // AXI4MasterCtrl inputs
    .wrTranDone                             (AXIWrTransDone_AXI4MasterCtrl),
    .wrTranError                            (AXIWrTransError_AXI4MasterCtrl),
    .strWrTranDone                          (AXI4StreamWrTransDone),
    .strWrTranError                         (AXI4StreamWrTransError),
    .strFetchAck                            (strFetchAck_AXI4MasterCtrl),
    .strDataValid                           (strDataValid_AXIMasterCtrl),
    
    // intErrorCtrl inputs
    .wrDoneAck                              (wrDoneAck_DMAWrTranCtrl),
    .wrErrorAck                             (wrErrorAck_DMAWrTranCtrl),
    .strWrDoneAck                           (strWrDoneAck_DMAWrTranCtrl),
    .strWrErrorAck                          (strWrErrorAck_DMAWrTranCtrl),
    .noOpDstAck                             (noOpDstAck),
    
    // intErrorCtrl outputs
    .wrDone                                 (wrDone_DMAWrTranCtrl),
    .wrError                                (wrError_DMAWrTranCtrl),
    .strWrDone                              (strWrDone_DMAWrTranCtrl),
    .strWrError                             (strWrError_DMAWrTranCtrl),
    .noOpDst                                (noOpDst),
    
    // AXI4MasterCtrl outputs
    .dstMaxAXINumBeats                      (dstMaxAXINumBeats),
    .strtAXIWrTran                          (strtAXIWrTran),
    .dstStrDscrptr                          (dstStrDscrptr),
    .numOfBytesInRd                         (dstNumOfBytesInRd_AXI4MasterCtrl),
    .dstAXITranType                         (dstAXITranType),
    .dstAXIDataWidth                        (dstAXIDataWidth),
    .dstStrtAddr                            (dstStrtAddr),
    .srcAXIDataWidth                        (dstSrcAXIDataWidth),
    .strFetchRdy                            (strFetchRdy),
    .strFetchAddr                           (strFetchAddr),
    
    //transAck outputs
    .strDataNReady                          (strDataNReady)
);

////////////////////////////////////////////////////////////////////////////////
// numOfBytesInRdValidReg register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                numOfBytesInRdValidReg <= 2'b0;
            end
        else
            begin
                case ({numOfBytesInRdValid_AXI4MasterCtrl, clrNumOfBytesInRd})
                    2'b00:
                        begin
                            numOfBytesInRdValidReg <= numOfBytesInRdValidReg;
                        end
                    2'b01:
                        begin
                            numOfBytesInRdValidReg[wrCache1Sel]  <= 1'b0;
                            numOfBytesInRdValidReg[!wrCache1Sel] <= numOfBytesInRdValidReg[!wrCache1Sel];
                        end
                    2'b10:
                        begin
                            numOfBytesInRdValidReg[rdCache1Sel]  <= 1'b1;
                            numOfBytesInRdValidReg[!rdCache1Sel] <= numOfBytesInRdValidReg[!rdCache1Sel];
                        end
                    2'b11:
                        begin
                            if (wrCache1Sel == rdCache1Sel)
                                begin
                                    numOfBytesInRdValidReg <= numOfBytesInRdValidReg;
                                end
                            else
                                begin
                                    numOfBytesInRdValidReg[wrCache1Sel] <= 1'b0;
                                    numOfBytesInRdValidReg[rdCache1Sel] <= 1'b1;
                                end
                        end
                endcase
            end
    end

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                numOfBytesInRdReg[0] <= {MAX_AXI_TRAN_SIZE_WIDTH{1'b0}};
                numOfBytesInRdReg[1] <= {MAX_AXI_TRAN_SIZE_WIDTH{1'b0}};
            end
        else
            begin
                if (numOfBytesInRdValid_AXI4MasterCtrl)
                    begin
                        numOfBytesInRdReg[rdCache1Sel] <= numOfBytesInRd_AXI4MasterCtrl;
                    end
            end
    end

assign numOfBytesInRd_intErrorCtrl         = numOfBytesInRdReg[rdCache1Sel];
assign numOfBytesInRdValid_rdNumOfBytesReg = numOfBytesInRdValidReg[wrCache1Sel];
assign numOfBytesInRd_numOfBytesInRdReg    = numOfBytesInRdReg[wrCache1Sel];

endmodule // DMATranCtrl