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
module CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_DMAController (
    // General inputs
    clock,
    resetn,

    // Control register inputs
    strtDMAOpInt,
    
    // Fabric controller inputs
    strtDMAOp,

    // AXI4MasterCtrl inputs
    AXI4WrTransDone,
    AXI4RdTransDone,
    AXI4WrTransError,
    AXI4RdTransError,
    AXI4StreamWrTransDone,
    AXI4StreamWrTransError,
    numOfBytesInRdValid,
    numOfBytesInRd,
    strRdyToAck,
    numOfBytesInWr_AXI4MasterCtrl,
    extFetchValid_AXI4MasterCtrl,
    dataValid_AXI4MasterCtrl,
    dscrptrData_AXI4MasterCtrl,
    dscrptrValid_AXI4MasterCtrl,
    strFetchAck_AXI4MasterCtrl,
    strDataValid_AXIMasterCtrl,
    clrStrDscrptrDataValidAck,

    // Interrupt controller inputs
    waitDscrptr,
    waitStrDscrptr,


    // Buffer descriptor inputs
    dataValidDscrptr,
    dscrptrValid,
    chain,
    dscrptrData,
    readDscrptrValid,
    
    // AXI4StreamSlaveCtrl inputs
    fetchStrDscrptr,
    strDscrptrAddr,

    // AXI4MasterCtrl outputs
    strtAXIWrTran,
    strtAXIRdTran,
    srcAXITranType,
    srcNumOfBytes,
    srcAXIStrtAddr,
    srcAXIDataWidth,
    dstAXITranType,
    dstAXIStrtAddr,
    dstAXIDataWidth,
    srcMaxAXINumBeats,
    dstStrDscrptr,
    dstNumOfBytesInRd_AXI4MasterCtrl,
    dstSrcAXIDataWidth,
    dstMaxAXINumBeats,
    strtStrDscrptrRd,
    strtExtDscrptrRd,
    strtExtDscrptrRdyCheck,
    strtAddr_extDscrptrFetch,
    clrExtDscrptrDataValid,
    configRegByte2,
    strFetchRdy,
    strFetchAddr,
    clrStrDscrptrDataValid,
    clrStrDscrptrAddr,
    clrStrDscrptrDstOp,
    
    // Cache outputs
    wrCache1Sel,
    rdCache1Sel,
    
    // Interrupt controller outputs
    valid,
    opDone,
    wrError,
    rdError,
    dscrptrNValidError,
    intDscrptrNum_IntController,
    extDscrptr_IntController,
    extDscrptrAddr_IntController,
    strDscrptr_IntController,
    
    // Buffer descriptor outputs
    readDscrptr,
    clrDataValidDscrptr,
    intDscrptrNum_BufferDscrptrs,
    
    // AXI4StreamSlaveCtrl outputs
    strFetchDone,
    strDscrptrValid,
    strMemMapWrDone,
    strMemMapWrError,
	
	error_flag_sb_intextdscrptr,
	error_flag_db_intextdscrptr
);

////////////////////////////////////////////////////////////////////////////////
// Parameters
////////////////////////////////////////////////////////////////////////////////
parameter AXI4_STREAM_IF             = 0;
parameter NUM_INT_BDS                = 4;
parameter NUM_INT_BDS_WIDTH          = 2;
parameter DSCRPTR_DATA_WIDTH         = 133;
parameter MAX_TRAN_SIZE_WIDTH        = 23; // 8 MB
parameter NUM_PRI_LVLS               = 1;
parameter MAX_AXI_TRAN_SIZE_WIDTH    = 12; // 4 KB
parameter MAX_AXI_NUM_BEATS_WIDTH    = 8;
parameter PRI_0_NUM_OF_BEATS         = 255;
parameter PRI_1_NUM_OF_BEATS         = 127;
parameter PRI_2_NUM_OF_BEATS         = 63;
parameter PRI_3_NUM_OF_BEATS         = 31;
parameter PRI_4_NUM_OF_BEATS         = 15;
parameter PRI_5_NUM_OF_BEATS         = 7;
parameter PRI_6_NUM_OF_BEATS         = 3;
parameter PRI_7_NUM_OF_BEATS         = 0;

parameter FAMILY					 = 25;
parameter ECC						 = 1;

////////////////////////////////////////////////////////////////////////////////
// Port directions
////////////////////////////////////////////////////////////////////////////////
// General inputs
input                                   clock;
input                                   resetn;

// Control register inputs
input [NUM_INT_BDS-1:0]                 strtDMAOpInt;

// Fabric controller inputs
input [NUM_INT_BDS-1:0]                 strtDMAOp;

// AXI4MasterCtrl inputs
input                                   AXI4WrTransDone;
input                                   AXI4RdTransDone;
input                                   AXI4WrTransError;
input                                   AXI4RdTransError;
input                                   AXI4StreamWrTransDone;
input                                   AXI4StreamWrTransError;
input                                   numOfBytesInRdValid;
input [MAX_AXI_TRAN_SIZE_WIDTH-1:0]     numOfBytesInRd;
input                                   strRdyToAck;
input [MAX_AXI_TRAN_SIZE_WIDTH-1:0]     numOfBytesInWr_AXI4MasterCtrl;
input                                   extFetchValid_AXI4MasterCtrl;
input [1:0]                             dataValid_AXI4MasterCtrl;
input [DSCRPTR_DATA_WIDTH-1:0]          dscrptrData_AXI4MasterCtrl;
input                                   dscrptrValid_AXI4MasterCtrl;
input                                   strFetchAck_AXI4MasterCtrl;
input                                   strDataValid_AXIMasterCtrl;
input                                   clrStrDscrptrDataValidAck;

// Interrupt controller inputs
input [NUM_INT_BDS-1:0]                 waitDscrptr;
input                                   waitStrDscrptr;

// Buffer descriptor inputs
input [NUM_INT_BDS-1:0]                 dataValidDscrptr;
input                                   dscrptrValid;
input [NUM_INT_BDS-1:0]                 chain;
input [DSCRPTR_DATA_WIDTH-1:0]          dscrptrData;
input                                   readDscrptrValid;

// AXI4StreamSlaveCtrl inputs
input                                   fetchStrDscrptr;
input  [31:0]                           strDscrptrAddr;

// AXI4MasterCtrl outputs
output                                  strtAXIWrTran;
output                                  strtAXIRdTran;
output [1:0]                            srcAXITranType;
output [MAX_TRAN_SIZE_WIDTH-1:0]        srcNumOfBytes;
output [31:0]                           srcAXIStrtAddr;
output [2:0]                            srcAXIDataWidth;
output                                  dstStrDscrptr;
output [1:0]                            dstAXITranType;
output [31:0]                           dstAXIStrtAddr;
output [2:0]                            dstAXIDataWidth;
output [MAX_AXI_NUM_BEATS_WIDTH-1:0]    srcMaxAXINumBeats;
output [MAX_TRAN_SIZE_WIDTH-1:0]        dstNumOfBytesInRd_AXI4MasterCtrl;
output [2:0]                            dstSrcAXIDataWidth;
output [MAX_AXI_NUM_BEATS_WIDTH-1:0]    dstMaxAXINumBeats;
output                                  strtStrDscrptrRd;
output                                  strtExtDscrptrRd;
output                                  strtExtDscrptrRdyCheck;
output [31:0]                           strtAddr_extDscrptrFetch;
output                                  clrExtDscrptrDataValid;
output [7:0]                            configRegByte2;
output                                  strFetchRdy;
output [31:0]                           strFetchAddr;
output                                  clrStrDscrptrDataValid;
output [31:0]                           clrStrDscrptrAddr;
output [1:0]                            clrStrDscrptrDstOp;

// Cache outputs
output                                  wrCache1Sel;
output                                  rdCache1Sel;

// Interrupt controller outputs
output                                  valid;
output                                  opDone;
output                                  wrError;
output                                  rdError;
output                                  dscrptrNValidError;
output [NUM_INT_BDS_WIDTH-1:0]          intDscrptrNum_IntController;
output                                  extDscrptr_IntController;
output [31:0]                           extDscrptrAddr_IntController;
output                                  strDscrptr_IntController;

// Buffer descriptor outputs
output                                  readDscrptr;
output [NUM_INT_BDS-1:0]                clrDataValidDscrptr;
output [NUM_INT_BDS_WIDTH-1:0]          intDscrptrNum_BufferDscrptrs;

// AXI4StreamSlaveCtrl outputs
output                                  strFetchDone;
output                                  strDscrptrValid;
output                                  strMemMapWrDone;
output                                  strMemMapWrError;

output									error_flag_sb_intextdscrptr;
output									error_flag_db_intextdscrptr;

////////////////////////////////////////////////////////////////////////////////
// Constants
////////////////////////////////////////////////////////////////////////////////
localparam DSCRPTR_DATA_WIDTH_EXT_ADDR = (DSCRPTR_DATA_WIDTH+32+1);

////////////////////////////////////////////////////////////////////////////////
// Internal signals
////////////////////////////////////////////////////////////////////////////////
wire                                    ldIntDscrptrAck;
wire                                    ldIntDscrptr;
wire [NUM_INT_BDS_WIDTH-1:0]            ldDscrptrNum;
wire                                    ldDscrptr;
wire                                    fetchIntDscrptr;
wire [NUM_INT_BDS_WIDTH-1:0]            intDscrptrNum_DMATranCtrl;
wire                                    dscrptrNValidAck;
wire                                    ldExtDscrptr;
wire                                    dataValid_ExtDscrptrFetch;
wire                                    strDscrptr_ExtDscrptrFetch;
wire [NUM_INT_BDS_WIDTH-1:0]            intDscrptrNum_ExtDscrptrFetch;
wire [31:0]                             extDscrptrAddr_ExtDscrptrFetch;
wire [DSCRPTR_DATA_WIDTH-1:0]           dscrptrData_ExtDscrptrFetch;
wire                                    dscrptrValid_ExtDscrptrFetch;
wire                                    intFetchAck;
wire                                    dscrptrNValid;
wire                                    dataValid_DscrptrSrcMux;
wire                                    strDscrptr_DscrptrSrcMux;
wire                                    externDscrptr_DscrptrSrcMux;
wire [NUM_INT_BDS_WIDTH-1:0]            intDscrptrNum_DscrptrSrcMux;
wire [31:0]                             extDscrptrAddr_DscrptrSrcMux;
wire [NUM_INT_BDS_WIDTH-1:0]            intDscrptrNum_intStatusMux;
wire [31:0]                             extDscrptrAddr_intStatusMux;
wire [DSCRPTR_DATA_WIDTH-1:0]           dscrptrData_DscrptrSrcMux;
wire                                    ldExtDscrptrAck_DscrptrSrcMux;
wire                                    fetchExtDscrptr_DMATranCtrl;
wire                                    clrExtDscrptr_DMATranCtrl;
wire                                    extRdyCheck_DMATranCtrl;
wire [NUM_INT_BDS_WIDTH-1:0]            intDscrptrNum_ExtDscrptrFetch_DMATranCtrl;
wire [31:0]                             extDscrptrAddr_ExtDscrptrFetch_DMATranCtrl;
wire                                    extFetchDone_extDscrptrFetch;
wire                                    extRdyValid_ExtDscrptrFetch;
wire                                    extRdy_ExtDscrptrFetch;
wire [MAX_TRAN_SIZE_WIDTH-1:0]          newNumOfBytes_DMAArbiter;
wire [31:0]                             newSrcAddr_DMAArbiter;
wire [31:0]                             newDstAddr_DMAArbiter;
wire                                    transAck;
wire                                    extDataValid_DMAWrTranCtrl;
wire                                    clrReq_DMATranCtrl;
wire [NUM_INT_BDS_WIDTH-1:0]            intDscrptrNum_clrReq;
wire                                    doTrans;
wire [NUM_PRI_LVLS-1:0]                 priLvl_DMAArbiter;
wire [NUM_INT_BDS_WIDTH-1:0]            intDscrptrNum_DMAArbiter;
wire [DSCRPTR_DATA_WIDTH_EXT_ADDR-1:0]  dscrptrData_DMAArbiter;
wire                                    intStaValid;
wire                                    opDone_DMATranCtrl;
wire                                    wrError_DMATranCtrl;
wire                                    rdError_DMATranCtrl;
wire                                    intStaAck_IntStatus;
wire                                    extClrAck_ExtDscrptrFetch;
wire [NUM_INT_BDS_WIDTH-1:0]            intDscrptrNum_IntStatusMux_DMATranCtrl;
wire [31:0]                             extDscrptrAddr_IntStatusMux_DMATranCtrl;
wire [7:0]                              configRegByte2_DMATranCtrl;
wire                                    extDscrptr_IntStatusMux_DMATranCtrl;
wire                                    extDscrptr_intStatusMux;
wire                                    strDscrptr_intStatusMux;
wire                                    strDscrptr_DMAArbiter;
wire                                    strDscrptr_DMATranCtrl;
wire                                    strFetchHoldOff;
wire                                    strDscrptr_IntStatusMux_DMATranCtrl;

////////////////////////////////////////////////////////////////////////////////
// DMAStartControl instantiation
////////////////////////////////////////////////////////////////////////////////
CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_DMAStartCtrl # (
    .NUM_INT_BDS                        (NUM_INT_BDS),
    .NUM_INT_BDS_WIDTH                  (NUM_INT_BDS_WIDTH)
) DMAStartCtrl_inst (
    // Inputs
    .clock                              (clock),
    .resetn                             (resetn),
    .strtDMAOp                          (strtDMAOp),
    .strtDMAOpInt                       (strtDMAOpInt),
    .ldIntDscrptrAck                    (ldIntDscrptrAck),
    // Outputs
    .ldDscrptr                          (ldIntDscrptr),
    .ldDscrptrNum                       (ldDscrptrNum)
);

////////////////////////////////////////////////////////////////////////////////
// DscrptrSrcMux instantiation
////////////////////////////////////////////////////////////////////////////////
CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_dscrptrSrcMux # (
    .NUM_INT_BDS                        (NUM_INT_BDS),
    .NUM_INT_BDS_WIDTH                  (NUM_INT_BDS_WIDTH),
    .DSCRPTR_DATA_WIDTH                 (DSCRPTR_DATA_WIDTH)
) dscrptrSrcMux_inst (
    // Inputs 
    .clock                              (clock),
    .resetn                             (resetn),
    .ldIntDscrptr                       (ldIntDscrptr),
    .intDscrptrNum_DMAStartCtrl         (ldDscrptrNum),
    .fetchIntDscrptr                    (fetchIntDscrptr),
    .intDscrptrNum_DMATranCtrl          (intDscrptrNum_DMATranCtrl),
    .dscrptrNValidAck                   (dscrptrNValidAck),
    .dscrptrValid_BufferDescriptors     (dscrptrValid),
    .dscrptrData_BufferDescriptors      (dscrptrData),
    .readDscrptrValid                   (readDscrptrValid),
    .ldExtDscrptr                       (ldExtDscrptr),
    .dataValid_ExtDscrptrFetch          (dataValid_ExtDscrptrFetch),
    .strDscrptr_ExtDscrptrFetch         (strDscrptr_ExtDscrptrFetch),
    .intDscrptrNum_ExtDscrptrFetch      (intDscrptrNum_ExtDscrptrFetch),
    .extDscrptrAddr_ExtDscrptrFetch     (extDscrptrAddr_ExtDscrptrFetch),
    .dscrptrData_ExtDscrptrFetch        (dscrptrData_ExtDscrptrFetch),
    .dscrptrValid_ExtDscrptrFetch       (dscrptrValid_ExtDscrptrFetch),
    // Outputs
    .ldIntDscrptrAck                    (ldIntDscrptrAck),
    .intFetchAck                        (intFetchAck),
    .dscrptrNValid                      (dscrptrNValid),
    .intDscrptrNum_intStatusMux         (intDscrptrNum_intStatusMux),
    .extDscrptr_intStatusMux            (extDscrptr_intStatusMux),
    .strDscrptr_intStatusMux            (strDscrptr_intStatusMux),
    .extDscrptrAddr_intStatusMux        (extDscrptrAddr_intStatusMux),
    .ldDscrptr                          (ldDscrptr),
    .dataValid                          (dataValid_DscrptrSrcMux),
    .strDscrptr                         (strDscrptr_DscrptrSrcMux),
    .externDscrptr                      (externDscrptr_DscrptrSrcMux),
    .intDscrptrNum                      (intDscrptrNum_DscrptrSrcMux),
    .extDscrptrAddr                     (extDscrptrAddr_DscrptrSrcMux),
    .dscrptrData                        (dscrptrData_DscrptrSrcMux),
    .ldExtDscrptrAck                    (ldExtDscrptrAck_DscrptrSrcMux),
    .readDscrptr                        (readDscrptr),
    .intDscrptrNum_BufferDescriptors    (intDscrptrNum_BufferDscrptrs)
);

////////////////////////////////////////////////////////////////////////////////
// ExtDscrptrFetch instantiation
////////////////////////////////////////////////////////////////////////////////
CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_extDscrptrFetchFSM # (
    .DSCRPTR_DATA_WIDTH                 (DSCRPTR_DATA_WIDTH),
    .MAX_TRAN_SIZE_WIDTH                (MAX_TRAN_SIZE_WIDTH),
    .NUM_INT_BDS_WIDTH                  (NUM_INT_BDS_WIDTH)
) extDscrptrFetchFSM_inst (
    // Inputs
    .clock                              (clock),
    .resetn                             (resetn),
    .ldExtDscrptrAck                    (ldExtDscrptrAck_DscrptrSrcMux),
    .strDscrptrValid                    (fetchStrDscrptr),
    .strDscrptrAddr                     (strDscrptrAddr),
    .fetchExtDscrptr                    (fetchExtDscrptr_DMATranCtrl),
    .clrExtDscrptr                      (clrExtDscrptr_DMATranCtrl),
    .extRdyCheck                        (extRdyCheck_DMATranCtrl),
    .intDscrptrNum_DMATranCtrl          (intDscrptrNum_ExtDscrptrFetch_DMATranCtrl),
    .extDscrptrAddr_DMATranCtrl         (extDscrptrAddr_ExtDscrptrFetch_DMATranCtrl),
    .configRegByte2_DMATranCtrl         (configRegByte2_DMATranCtrl),
    .dscrptrData_AXI4MasterCtrl         (dscrptrData_AXI4MasterCtrl),
    .dscrptrValid_AXI4MasterCtrl        (dscrptrValid_AXI4MasterCtrl),
    .extFetchValid                      (extFetchValid_AXI4MasterCtrl),
    .dataValid_AXI4MasterCtrl           (dataValid_AXI4MasterCtrl),
    // Outputs
    .strDscrptrAck                      (strFetchDone),
    .strDscrptrAck_dscrptrValid         (strDscrptrValid),
    .intDscrptrNum                      (intDscrptrNum_ExtDscrptrFetch),
    .extDscrptrAddr                     (extDscrptrAddr_ExtDscrptrFetch),
    .dscrptrData                        (dscrptrData_ExtDscrptrFetch),
    .dscrptrValid                       (dscrptrValid_ExtDscrptrFetch),
    .dataValid                          (dataValid_ExtDscrptrFetch),
    .strDcrptr                          (strDscrptr_ExtDscrptrFetch),
    .ldExtDscrptr                       (ldExtDscrptr),
    .strFetchHoldOff                    (strFetchHoldOff),
    .extFetchDone                       (extFetchDone_extDscrptrFetch),
    .extClrAck                          (extClrAck_ExtDscrptrFetch),
    .extRdyValid                        (extRdyValid_ExtDscrptrFetch),
    .extRdy                             (extRdy_ExtDscrptrFetch),
    .strtStrDscrptrRd                   (strtStrDscrptrRd),
    .strtExtDscrptrRd                   (strtExtDscrptrRd),
    .strtExtDscrptrRdyCheck             (strtExtDscrptrRdyCheck),
    .clrExtDscrptrDataValid             (clrExtDscrptrDataValid),
    .strtAddr                           (strtAddr_extDscrptrFetch),
    .configRegByte2                     (configRegByte2)
);

////////////////////////////////////////////////////////////////////////////////
// DMAArbiter instantiation
////////////////////////////////////////////////////////////////////////////////
CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_DMAArbiter # (
    .NUM_INT_BDS                        (NUM_INT_BDS),
    .NUM_INT_BDS_WIDTH                  (NUM_INT_BDS_WIDTH),
    .MAX_TRAN_SIZE_WIDTH                (MAX_TRAN_SIZE_WIDTH),
    .NUM_PRI_LVLS                       (NUM_PRI_LVLS),
    .DSCRPTR_DATA_WIDTH                 (DSCRPTR_DATA_WIDTH),
    .DSCRPTR_DATA_WIDTH_EXT_ADDR        (DSCRPTR_DATA_WIDTH_EXT_ADDR),
    .AXI4_STREAM_IF                     (AXI4_STREAM_IF),
	.FAMILY								(FAMILY),
	.ECC								(ECC)
) DMAArbiter_inst (
    // Inputs
    .clock                              (clock),
    .resetn                             (resetn),
    .dscrptrNdataValid                  (dataValidDscrptr),
    .chain                              (chain),
    .dscrptrData                        (dscrptrData_DscrptrSrcMux),
    .ldDscrptr                          (ldDscrptr),
    .strDscrptr_dscrptrSrcMux           (strDscrptr_DscrptrSrcMux),
    .dataValid                          (dataValid_DscrptrSrcMux),
    .extDscrptr                         (externDscrptr_DscrptrSrcMux),
    .intDscrptrNum                      (intDscrptrNum_DscrptrSrcMux),
    .newNumOfBytes                      (newNumOfBytes_DMAArbiter),
    .newSrcAddr                         (newSrcAddr_DMAArbiter),
    .newDstAddr                         (newDstAddr_DMAArbiter),
    .extDscrptrAddr                     (extDscrptrAddr_DscrptrSrcMux),
    .transAck                           (transAck),
    .strDscrptr_DMATranCtrl             (strDscrptr_DMATranCtrl),
    .extDataValid                       (extDataValid_DMAWrTranCtrl),
    .clrReq_DMATranCtrl                 (clrReq_DMATranCtrl),
    .intDscrptrNum_clrReq               (intDscrptrNum_clrReq),
    .waitDscrptr                        (waitDscrptr),
    .waitStrDscrptr                     (waitStrDscrptr),
    // Outputs
    .doTrans                            (doTrans),
    .priLvl                             (priLvl_DMAArbiter),
    .strDscrptr_DMAArbiter              (strDscrptr_DMAArbiter),
    .intDscrptrNum_DMAArbiter           (intDscrptrNum_DMAArbiter),
    .dscrptrData_DMAArbiter             (dscrptrData_DMAArbiter),
    .clrDataValidDscrptr                (clrDataValidDscrptr),
	
	.error_flag_sb_intextdscrptr		(error_flag_sb_intextdscrptr),
	.error_flag_db_intextdscrptr		(error_flag_db_intextdscrptr)
);

////////////////////////////////////////////////////////////////////////////////
// intStatusMux instantiation
////////////////////////////////////////////////////////////////////////////////
CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_intStatusMux # (
    .NUM_INT_BDS_WIDTH                  (NUM_INT_BDS_WIDTH)
) intStatusMux_inst (
    // Inputs
    .clock                              (clock),
    .resetn                             (resetn),
    .dscrptrNValid                      (dscrptrNValid),
    .intDscrptrNum_DscrptrSrcMux        (intDscrptrNum_intStatusMux),
    .extDscrptr_DscrptrSrcMux           (extDscrptr_intStatusMux),
    .strDscrptr_DscrptrSrcMux           (strDscrptr_intStatusMux),
    .extDscrptrAddr_DscrptrSrcMux       (extDscrptrAddr_intStatusMux),
    .intStaValid                        (intStaValid),
    .opDone_DMATranCtrl                 (opDone_DMATranCtrl),
    .wrError_DMATranCtrl                (wrError_DMATranCtrl),
    .rdError_DMATranCtrl                (rdError_DMATranCtrl),
    .intDscrptrNum_DMATranCtrl          (intDscrptrNum_IntStatusMux_DMATranCtrl),
    .extDscrptr_DMATranCtrl             (extDscrptr_IntStatusMux_DMATranCtrl),
    .extDscrptrAddr_DMATranCtrl         (extDscrptrAddr_IntStatusMux_DMATranCtrl),
    .strDscrptr_DMATranCtrl             (strDscrptr_IntStatusMux_DMATranCtrl),
    // Outputs
    .valid                              (valid),
    .opDone                             (opDone),
    .wrError                            (wrError),
    .rdError                            (rdError),
    .dscrptrNValidError                 (dscrptrNValidError),
    .intDscrptrNum                      (intDscrptrNum_IntController),
    .extDscrptr                         (extDscrptr_IntController),
    .extDscrptrAddr                     (extDscrptrAddr_IntController),
    .strDscrptr                         (strDscrptr_IntController),
    .intStaAck                          (intStaAck_IntStatus),
    .dscrptrNValidAck                   (dscrptrNValidAck)
);

////////////////////////////////////////////////////////////////////////////////
// DMATranCtrl instantiation
////////////////////////////////////////////////////////////////////////////////
CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_DMATranCtrl # (
    .NUM_INT_BDS                        (NUM_INT_BDS),
    .NUM_INT_BDS_WIDTH                  (NUM_INT_BDS_WIDTH),
    .MAX_TRAN_SIZE_WIDTH                (MAX_TRAN_SIZE_WIDTH),
    .MAX_AXI_TRAN_SIZE_WIDTH            (MAX_AXI_TRAN_SIZE_WIDTH),
    .NUM_PRI_LVLS                       (NUM_PRI_LVLS),
    .MAX_AXI_NUM_BEATS_WIDTH            (MAX_AXI_NUM_BEATS_WIDTH),
    .PRI_0_NUM_OF_BEATS                 (PRI_0_NUM_OF_BEATS),
    .PRI_1_NUM_OF_BEATS                 (PRI_1_NUM_OF_BEATS),
    .PRI_2_NUM_OF_BEATS                 (PRI_2_NUM_OF_BEATS),
    .PRI_3_NUM_OF_BEATS                 (PRI_3_NUM_OF_BEATS),
    .PRI_4_NUM_OF_BEATS                 (PRI_4_NUM_OF_BEATS),
    .PRI_5_NUM_OF_BEATS                 (PRI_5_NUM_OF_BEATS),
    .PRI_6_NUM_OF_BEATS                 (PRI_6_NUM_OF_BEATS),
    .PRI_7_NUM_OF_BEATS                 (PRI_7_NUM_OF_BEATS),
    .AXI4_STREAM_IF                     (AXI4_STREAM_IF)
) DMATranCtrl (
    // General inputs
    .clock                              (clock),
    .resetn                             (resetn),

    // DMAArbiter inputs
    .doTrans_DMAArbiter                 (doTrans),
    .strDscrptr_DMAArbiter              (strDscrptr_DMAArbiter),
    .intDscrptrNum_DMAArbiter           (intDscrptrNum_DMAArbiter),
    .extDscrptrAddr_DMAArbiter          (dscrptrData_DMAArbiter[165:134]),
    .extDscrptr_DMAArbiter              (dscrptrData_DMAArbiter[166]),
    .priLvl_DMAArbiter                  (priLvl_DMAArbiter),
    .dataValid_DMAArbiter               (dscrptrData_DMAArbiter[13]),
    .intOnProcess_DMAArbiter            (dscrptrData_DMAArbiter[12]),
    .srcAddr_DMAArbiter                 (dscrptrData_DMAArbiter[69:38]),
    .srcOp_DMAArbiter                   (dscrptrData_DMAArbiter[1:0]),
    .srcDataWidth_DMAArbiter            (dscrptrData_DMAArbiter[6:4]),
    .numOfBytes_DMAArbiter              (dscrptrData_DMAArbiter[37:14]),
    .chain_DMAArbiter                   (dscrptrData_DMAArbiter[10]),
    .extDscrptrNxt_DMAArbiter           (dscrptrData_DMAArbiter[11]),
    .nxtDscrptrNumAddr_DMAArbiter       (dscrptrData_DMAArbiter[133:102]),
    .dstAddr_DMAArbiter                 (dscrptrData_DMAArbiter[101:70]),
    .dstOp_DMAArbiter                   (dscrptrData_DMAArbiter[3:2]),
    .dstDataWidth_DMAArbiter            (dscrptrData_DMAArbiter[9:7]),

    // IntStatus inputs
    .intStaAck_IntStatus                (intStaAck_IntStatus),

    // AXI4MasterCtrl inputs
    .AXIWrTransDone_AXI4MasterCtrl      (AXI4WrTransDone),
    .AXIRdTransDone_AXI4MasterCtrl      (AXI4RdTransDone),
    .AXIWrTransError_AXI4MasterCtrl     (AXI4WrTransError),
    .AXIRdTransError_AXI4MasterCtrl     (AXI4RdTransError),
    .AXI4StreamWrTransDone              (AXI4StreamWrTransDone),
    .AXI4StreamWrTransError             (AXI4StreamWrTransError),
    .numOfBytesInRdValid_AXI4MasterCtrl (numOfBytesInRdValid),
    .numOfBytesInRd_AXI4MasterCtrl      (numOfBytesInRd),
    .strRdyToAck                        (strRdyToAck),
    .numOfBytesInWr_AXI4MasterCtrl      (numOfBytesInWr_AXI4MasterCtrl),
    .strFetchAck_AXI4MasterCtrl         (strFetchAck_AXI4MasterCtrl),
    .strDataValid_AXIMasterCtrl         (strDataValid_AXIMasterCtrl),
    .clrStrDscrptrDataValidAck          (clrStrDscrptrDataValidAck),

    // ExtDscrptrFetch inputs
    .strFetchHoldOff_ExtDscrptrFetch    (strFetchHoldOff),
    .extFetchDone_ExtDscrptrFetch       (extFetchDone_extDscrptrFetch),
    .extClrAck_ExtDscrptrFetch          (extClrAck_ExtDscrptrFetch),
    .extRdyValid_ExtDscrptrFetch        (extRdyValid_ExtDscrptrFetch),
    .extRdy_ExtDscrptrFetch             (extRdy_ExtDscrptrFetch),

    // DscrptrSrcMux inputs
    .intFetchAck_DscrptrSrcMux          (intFetchAck),

    // DMAArbiter outputs
    .transAck                           (transAck),
    .strDscrptr_DMATranCtrl             (strDscrptr_DMATranCtrl),
    .extDataValid                       (extDataValid_DMAWrTranCtrl),
    .newNumOfBytes                      (newNumOfBytes_DMAArbiter),
    .newSrcAddr                         (newSrcAddr_DMAArbiter),
    .newDstAddr                         (newDstAddr_DMAArbiter),
    .clrReq                             (clrReq_DMATranCtrl),
    .intDscrptrNum_clrReq               (intDscrptrNum_clrReq),

    // IntStatusMux outputs
    .intStaValid                        (intStaValid),
    .opDone                             (opDone_DMATranCtrl),
    .wrError                            (wrError_DMATranCtrl),
    .rdError                            (rdError_DMATranCtrl),
    .intDscrptrNum_IntStatusMux         (intDscrptrNum_IntStatusMux_DMATranCtrl),
    .extDscrptr_IntStatusMux            (extDscrptr_IntStatusMux_DMATranCtrl),
    .extDscrptrAddr_IntStatusMux        (extDscrptrAddr_IntStatusMux_DMATranCtrl),
    .strDscrptr_IntStatusMux            (strDscrptr_IntStatusMux_DMATranCtrl),

    // Cache outputs
    .wrCache1Sel                        (wrCache1Sel),
    .rdCache1Sel                        (rdCache1Sel),
    
    // AXI4MasterCtrl outputs
    .strtAXIWrTran                      (strtAXIWrTran),
    .strtAXIRdTran                      (strtAXIRdTran),
    .srcAXITranType                     (srcAXITranType),
    .srcNumOfBytes                      (srcNumOfBytes),
    .srcAXIDataWidth                    (srcAXIDataWidth),
    .srcStrtAddr                        (srcAXIStrtAddr),
    .dstStrDscrptr                      (dstStrDscrptr),
    .dstAXITranType                     (dstAXITranType),
    .dstAXIDataWidth                    (dstAXIDataWidth),
    .dstStrtAddr                        (dstAXIStrtAddr),
    .strFetchRdy                        (strFetchRdy),
    .strFetchAddr                       (strFetchAddr),
    .clrStrDscrptrDataValid             (clrStrDscrptrDataValid),
    .clrStrDscrptrAddr                  (clrStrDscrptrAddr),
    .clrStrDscrptrDstOp                 (clrStrDscrptrDstOp),

    .srcMaxAXINumBeats                  (srcMaxAXINumBeats),
    .dstNumOfBytesInRd_AXI4MasterCtrl   (dstNumOfBytesInRd_AXI4MasterCtrl),
    .dstSrcAXIDataWidth                 (dstSrcAXIDataWidth),
    .dstMaxAXINumBeats                  (dstMaxAXINumBeats),
    
    // ExtDscrptrFetch outputs
    .fetchExtDscrptr                    (fetchExtDscrptr_DMATranCtrl),
    .clrExtDscrptr                      (clrExtDscrptr_DMATranCtrl),
    .extRdyCheck                        (extRdyCheck_DMATranCtrl),
    .intDscrptrNum_ExtDscrptrFetch      (intDscrptrNum_ExtDscrptrFetch_DMATranCtrl),
    .extDscrptrAddr_ExtDscrptrFetch     (extDscrptrAddr_ExtDscrptrFetch_DMATranCtrl),
    .configRegByte2                     (configRegByte2_DMATranCtrl),

    // DscrptrSrcMux outputs
    .fetchIntDscrptr                    (fetchIntDscrptr),
    .intDscrptrNum_DscrptrSrcMux        (intDscrptrNum_DMATranCtrl),
    
    // AXI4StreamSlaveCtrl outputs
    .strMemMapWrDone                    (strMemMapWrDone),
    .strMemMapWrError                   (strMemMapWrError)
);

endmodule // DMAController