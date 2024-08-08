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
// SVN $Revision: 37593 $
// SVN $Date: 2021-02-04 15:13:51 +0530 (Thu, 04 Feb 2021) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//
// ****************************************************************************/
module CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_AXI4MasterDMACtrl (
    clock,
    resetn,

    // DMATranCtrl inputs
    strtAXIWrTran,
    strtAXIRdTran,
    srcAXITranType,
    srcNumOfBytes,
    srcAXIStrtAddr,
    srcAXIDataWidth,
    srcMaxAXINumBeats,
    dstStrDscrptr,
    dstAXITranType,
    dstAXIStrtAddr,
    dstAXIDataWidth,
    dstNumOfBytesInRd,
    dstSrcAXIDataWidth,
    dstMaxAXINumBeats,
    strFetchRdy,
    strFetchAddr,
    clrStrDscrptrDataValid,
    clrStrDscrptrAddr,
    clrStrDscrptrDstOp,
    
    // ExtDscrptrFetchFSM inputs
    strtStrDscrptrRd,
    strtExtDscrptrRd,
    strtExtDscrptrRdyCheck,
    strtAddr_extDscrptrFetch,
    clrExtDscrptrDataValid,
    configRegByte2,

    // Memory Map Cache input 
    rdDataMemMapCache,
    numBytesInMemMapCache,
    
    // Stream Cache input 
    rdDataStrCache,
    numBytesInStrCache,
    
    // AXISlave inputs
    BRESP,
    BID,
    RDATA,
    RID,
    AWREADY,
    WREADY,
    BVALID,
    ARREADY,
    RVALID,
    RRESP,
    RLAST,    

    // DMATranCtrl outputs
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
    strFetchAck_AXI4MasterCtrl,
    strDataValid_AXIMasterCtrl,
    clrStrDscrptrDataValidAck,
    
    // ExtDscrptrFetchFSM outputs
    extFetchValid_AXI4MasterCtrl,
    dataValid_AXI4MasterCtrl,
    dscrptrData_AXI4MasterCtrl,
    dscrptrValid_AXI4MasterCtrl,

    // Memory Map Cache outputs
    wrEn,
    wrAddr,
    wrData,
    wrNumOfBytes,
    rdEnMemMapCache,
    rdAddr,
    rdNumOfBytes,
    
    // Stream Cache outputs
    rdEnStrCache,
    
    // AXISlave outputs
    AWVALID,
    WVALID,
    WLAST,
    BREADY,
    ARVALID,
    RREADY,
    AWADDR,
    AWID,
    AWLEN,
    AWSIZE,
    AWBURST,
    WSTRB,
    WDATA,
    ARADDR,
    ARID,
    ARLEN,
    ARSIZE,
    ARBURST
);

////////////////////////////////////////////////////////////////////////////////
// Parameters
////////////////////////////////////////////////////////////////////////////////
parameter AXI4_STREAM_IF            = 0;
parameter AXI_DMA_DWIDTH            = 0;
parameter MAX_TRAN_SIZE_WIDTH       = 23;
parameter MAX_AXI_TRAN_SIZE_WIDTH   = 12;
parameter MAX_AXI_NUM_BEATS_WIDTH   = 8;
parameter DSCRPTR_DATA_WIDTH        = 160;
parameter MAX_AXI_NUM_BEATS         = 256;
parameter ID_WIDTH                  = 1; // ID field always driven out as zeros

// Include file containing the implementation of clog2() function
`include "./coreaxi4dmacontroller_utility_functions.v"

////////////////////////////////////////////////////////////////////////////////
// Constants
////////////////////////////////////////////////////////////////////////////////
localparam TRAN_BYTE_CNT_WIDTH = clog2(AXI_DMA_DWIDTH/8);
localparam AXI_SIZE            = clog2((AXI_DMA_DWIDTH/8)-1);

////////////////////////////////////////////////////////////////////////////////
// Port directions
////////////////////////////////////////////////////////////////////////////////
input                                   clock;
input                                   resetn;

// DMATranCtrl inputs
input                                   strtAXIWrTran;
input                                   strtAXIRdTran;
input  [1:0]                            srcAXITranType;
input  [MAX_TRAN_SIZE_WIDTH-1:0]        srcNumOfBytes;
input  [31:0]                           srcAXIStrtAddr;
input  [2:0]                            srcAXIDataWidth;
input  [MAX_AXI_NUM_BEATS_WIDTH-1:0]    srcMaxAXINumBeats;
input                                   dstStrDscrptr;
input  [1:0]                            dstAXITranType;
input  [31:0]                           dstAXIStrtAddr;
input  [2:0]                            dstAXIDataWidth;
input  [MAX_TRAN_SIZE_WIDTH-1:0]        dstNumOfBytesInRd;
input  [2:0]                            dstSrcAXIDataWidth;
input  [MAX_AXI_NUM_BEATS_WIDTH-1:0]    dstMaxAXINumBeats;
input                                   strFetchRdy;
input  [31:0]                           strFetchAddr;
input                                   clrStrDscrptrDataValid;
input  [31:0]                           clrStrDscrptrAddr;
input  [1:0]                            clrStrDscrptrDstOp;

// ExtDscrptrFetchFSM inputs
input                                   strtStrDscrptrRd;
input                                   strtExtDscrptrRd;
input                                   strtExtDscrptrRdyCheck;
input  [31:0]                           strtAddr_extDscrptrFetch;
input                                   clrExtDscrptrDataValid;
input  [7:0]                            configRegByte2;

// Memory Map cache inputs
input  [AXI_DMA_DWIDTH-1:0]             rdDataMemMapCache;
input  [MAX_AXI_TRAN_SIZE_WIDTH-1:0]    numBytesInMemMapCache;

// Stream cache input 
input  [AXI_DMA_DWIDTH-1:0]             rdDataStrCache;
input  [MAX_AXI_TRAN_SIZE_WIDTH-1:0]    numBytesInStrCache;

// AXISlave inputs
input  [1:0]                            BRESP;
input  [ID_WIDTH-1:0]                   BID;
input  [AXI_DMA_DWIDTH-1:0]             RDATA;
input  [ID_WIDTH-1:0]                   RID;
input                                   AWREADY;
input                                   WREADY;
input                                   BVALID;
input                                   ARREADY;
input                                   RVALID;
input  [1:0]                            RRESP;
input                                   RLAST;

// DMATranCtrl outputs
output                                  AXI4WrTransDone;
output                                  AXI4RdTransDone;
output                                  AXI4WrTransError;
output                                  AXI4RdTransError;
output                                  AXI4StreamWrTransDone;
output                                  AXI4StreamWrTransError;
output                                  numOfBytesInRdValid;
output [MAX_AXI_TRAN_SIZE_WIDTH-1:0]    numOfBytesInRd;
output                                  strRdyToAck;
output [MAX_AXI_TRAN_SIZE_WIDTH-1:0]    numOfBytesInWr_AXI4MasterCtrl;
output reg                              strFetchAck_AXI4MasterCtrl;
output reg                              strDataValid_AXIMasterCtrl;
output reg                              clrStrDscrptrDataValidAck;

// ExtDscrptrFetchFSM outputs
output reg                              extFetchValid_AXI4MasterCtrl;
output reg [1:0]                        dataValid_AXI4MasterCtrl;
output reg [DSCRPTR_DATA_WIDTH-1:0]     dscrptrData_AXI4MasterCtrl;
output reg                              dscrptrValid_AXI4MasterCtrl;

// Memory Map Cache outputs
output                                  wrEn;
output [MAX_AXI_NUM_BEATS_WIDTH-1:0]    wrAddr;
output [AXI_DMA_DWIDTH-1:0]             wrData;
output [TRAN_BYTE_CNT_WIDTH-1:0]        wrNumOfBytes;
output reg                              rdEnMemMapCache;
output [MAX_AXI_NUM_BEATS_WIDTH-1:0]    rdAddr;
output [TRAN_BYTE_CNT_WIDTH-1:0]        rdNumOfBytes;

// Stream Cache outputs
output reg                              rdEnStrCache;

// AXISlave outputs
output                                  AWVALID;
output                                  WVALID;
output                                  WLAST;
output                                  BREADY;
output                                  ARVALID;
output                                  RREADY;
output [31:0]                           AWADDR;
output [ID_WIDTH-1:0]                   AWID;
output [7:0]                            AWLEN;
output [2:0]                            AWSIZE;
output [1:0]                            AWBURST;
output [(AXI_DMA_DWIDTH/8)-1:0]         WSTRB;
output [AXI_DMA_DWIDTH-1:0]             WDATA;
output [31:0]                           ARADDR;
output [ID_WIDTH-1:0]                   ARID;
output [7:0]                            ARLEN;
output [2:0]                            ARSIZE;
output [1:0]                            ARBURST;

////////////////////////////////////////////////////////////////////////////////
// Internal signals
////////////////////////////////////////////////////////////////////////////////
wire									rdEn;
reg  [12:0]                             currStateRd;
reg  [12:0]                             nextStateRd;
reg  [12:0]                             currStateWr;
reg  [12:0]                             nextStateWr;
wire [7:0]                              writeStrbs;
reg                                     AWVALIDReg;
reg                                     AWVALIDReg_d;
reg  [31:0]                             AWADDRReg;
reg  [31:0]                             AWADDRReg_d;
reg  [2:0]                              AWSIZEReg;
reg  [2:0]                              AWSIZEReg_d;
reg  [1:0]                              AWBURSTReg;
reg  [1:0]                              AWBURSTReg_d;
reg  [7:0]                              AWLENReg;
reg  [7:0]                              AWLENReg_d;
reg  [ID_WIDTH-1:0]                     AWIDReg;
reg  [ID_WIDTH-1:0]                     AWIDReg_d;
reg                                     WVALIDReg;
reg                                     WVALIDReg_d;
reg  [AXI_DMA_DWIDTH-1:0]               WDATAReg;
reg  [AXI_DMA_DWIDTH-1:0]               WDATAReg_d;
reg                                     WLASTReg;
reg                                     WLASTReg_d;
reg  [(AXI_DMA_DWIDTH/8)-1:0]           WSTRBReg;
reg  [(AXI_DMA_DWIDTH/8)-1:0]           WSTRBReg_d;
reg                                     BREADYReg;
reg                                     BREADYReg_d;
reg                                     AXI4StreamWrTransDone;
reg                                     AXI4StreamWrTransError;
reg                                     AXI4WrTransDone;
reg                                     AXI4WrTransError;
reg  [7:0]                              beatsInWrBurst;
reg  [7:0]                              beatsInWrBurst_d;
reg  [8:0]                              beatCntReg;     // Extra bit as range 0-256 beats
reg  [8:0]                              beatCntReg_d;   // Extra bit as range 0-256 beats
reg  [7:0]                              rdAddrReg;
reg  [7:0]                              rdAddrReg_d;
reg                                     ARVALIDReg;
reg                                     ARVALIDReg_d;
reg  [31:0]                             ARADDRReg;
reg  [31:0]                             ARADDRReg_d;
reg  [2:0]                              ARSIZEReg;
reg  [2:0]                              ARSIZEReg_d;
reg  [1:0]                              ARBURSTReg;
reg  [1:0]                              ARBURSTReg_d;
reg  [7:0]                              ARLENReg;
reg  [7:0]                              ARLENReg_d;
reg                                     RREADYReg;
reg                                     RREADYReg_d;
reg  [MAX_AXI_TRAN_SIZE_WIDTH-1:0]      numOfBytesInRd; // combinatorial
reg                                     numOfBytesInRdValid; // combinatorial
reg  [7:0]                              wrAddrReg;
reg  [7:0]                              wrAddrReg_d;
reg  [ID_WIDTH-1:0]                     ARIDReg;
reg  [ID_WIDTH-1:0]                     ARIDReg_d;
reg                                     AXI4RdTransDone;
reg                                     AXI4RdTransError;
reg  [7:0]                              beatsInRdBurst;
reg  [7:0]                              beatsInRdBurst_d;
reg  [MAX_TRAN_SIZE_WIDTH-1:0]          srcNumOfBytesReg;
reg  [MAX_TRAN_SIZE_WIDTH-1:0]          srcNumOfBytesReg_d;
reg  [31:0]                             dstAXIStrtAddrReg;
reg  [31:0]                             dstAXIStrtAddrReg_d;
reg  [MAX_TRAN_SIZE_WIDTH-1:0]          dstNumOfBytesInRdReg;
reg  [MAX_TRAN_SIZE_WIDTH-1:0]          dstNumOfBytesInRdReg_d;
reg  [1:0]                              dstBurstTypeReg;
reg  [1:0]                              dstBurstTypeReg_d;
reg  [MAX_AXI_TRAN_SIZE_WIDTH-1:0]      wrByteCnt;
reg  [MAX_AXI_TRAN_SIZE_WIDTH-1:0]      wrByteCnt_d;
reg                                     extFetchValidWr;
reg                                     extFetchValidRd;
reg  [DSCRPTR_DATA_WIDTH-1:0]           dscrptrData_AXI4MasterCtrl_d;
reg                                     dscrptrValid_AXI4MasterCtrl_d;
reg  [1:0]                              dataValid_AXI4MasterCtrl_d;
reg                                     wrEnReg;
reg                                     wrEnReg_d;
reg [AXI_DMA_DWIDTH-1:0]                wrDataReg;
reg [AXI_DMA_DWIDTH-1:0]                wrDataReg_d;
reg [TRAN_BYTE_CNT_WIDTH-1:0]           wrNumOfBytesReg;
reg [TRAN_BYTE_CNT_WIDTH-1:0]           wrNumOfBytesReg_d;
reg                                     rdEnReg;
reg                                     rdEnReg_d;
reg  [TRAN_BYTE_CNT_WIDTH-1:0]          rdNumOfBytesReg;
reg  [TRAN_BYTE_CNT_WIDTH-1:0]          rdNumOfBytesReg_d;
reg  [1:0]                              rdBeatCntReg;
reg  [1:0]                              rdBeatCntReg_d;
reg                                     dstStrDscrptrReg;
reg                                     dstStrDscrptrReg_d;
reg  [AXI_DMA_DWIDTH-1:0]               rdData;
reg                                     strRdyToAckReg;
reg                                     strRdyToAckReg_d;
reg  [MAX_AXI_TRAN_SIZE_WIDTH-1:0]      numOfBytesInWr_AXI4MasterCtrlReg;
reg  [MAX_AXI_TRAN_SIZE_WIDTH-1:0]      numOfBytesInWr_AXI4MasterCtrlReg_d;
reg                                     strFetchAck_AXI4MasterCtrl_d;
reg                                     strDataValid_AXIMasterCtrl_d;

reg  [AXI_DMA_DWIDTH-1:0]               WDATAReg_1;
reg                                     WLASTReg_1;
reg                                     WVALIDReg_1;
reg										ren_sc;
reg  [7:0]                              rdAddr_1;

reg [2:0]             read_cntr;	
reg [1:0]             read_data_cntr;  
reg                   rdata_reg_en_ctrl;
reg                   rdata_mc_reg1_en;
reg                   rdata_mc_reg2_en;
reg                   rdata_mc_reg1_sel;
reg [AXI_DMA_DWIDTH-1:0] rdata_mc_reg1;
reg [AXI_DMA_DWIDTH-1:0] rdata_mc_reg2;
reg [8:0]             ram_rdreq_cntr;
		
reg					   	ren_sc_d1;
reg					   	ren_sc_d2;
reg [8:0]               rdbeat_cnt;
reg						set_rdaligned_done_r;
reg						rddata_start_d;
wire					rddata_start;
reg                     set_rdaligned_done;
reg						strtAXIWrTran_reg;
reg						str_strt_ctrl;
reg						Err_RESP_hold;					

////////////////////////////////////////////////////////////////////////////////
// Constants
////////////////////////////////////////////////////////////////////////////////
localparam [12:0] RD_IDLE                    = 13'b0000000000001;//'h1
localparam [12:0] WAIT_RD_ADDR_ACK           = 13'b0000000000010;//'h2
localparam [12:0] RD_DATA_RX_FIRST           = 13'b0000000000100;//'h4
localparam [12:0] RD_DATA_RX                 = 13'b0000000001000;//'h8
localparam [12:0] RD_RX_DONE                 = 13'b0000000010000;//'h10
localparam [12:0] RD_WAIT_ADDR_EXT_FETCH     = 13'b0000000100000;//'h20
localparam [12:0] RD_DATA_EXT_FETCH          = 13'b0000001000000;//'h40
localparam [12:0] RD_WAIT_ADDR_EXT_RDY_CHECK = 13'b0000010000000;//'h80
localparam [12:0] RD_DATA_RDY_CHECK          = 13'b0000100000000;//'h100
localparam [12:0] RD_WAIT_ADDR_STR_RDY_CHECK = 13'b0001000000000;//'h200
localparam [12:0] RD_DATA_STR_RDY_CHECK      = 13'b0010000000000;//'h400
localparam [12:0] RD_WAIT_ADDR_STR_FETCH     = 13'b0100000000000;//'h800
localparam [12:0] RD_DATA_STR_FETCH          = 13'b1000000000000;//'h1000

localparam [12:0] WR_IDLE                    = 13'b0000000000001;//'h1
localparam [12:0] WAIT_WR_ADDR_ACK           = 13'b0000000000010;//'h2
localparam [12:0] WAIT_WR_BYTES_IN_CACHE     = 13'b0000000000100;//'h4
localparam [12:0] WR_DATA_TX                 = 13'b0000000001000;//'h8
localparam [12:0] WR_RESP                    = 13'b0000000010000;//'h10
localparam [12:0] WR_NEXT_TRAN_CONFIG        = 13'b0000000100000;//'h20
localparam [12:0] WR_WAIT_ADDR_ACK_CLR_VALID = 13'b0000001000000;//'h40
localparam [12:0] WR_DATA_CLR_VALID          = 13'b0000010000000;//'h80
localparam [12:0] WR_RESP_CLR_VALID          = 13'b0000100000000;//'h100
localparam [12:0] WR_DATA_TX_PEN_BEAT        = 13'b0001000000000;//'h200
localparam [12:0] WR_DATA_TX_LAST            = 13'b0010000000000;//'h400
localparam [12:0] WR_STR_WAIT_BYTES_IN_CACHE = 13'b0100000000000;//'h800
localparam [12:0] WR_STR_CALC_BYTES_IN_WRITE = 13'b1000000000000;//'h1000

// Write strobe LUT
generate
    if (AXI_DMA_DWIDTH == 32)
        begin
            assign writeStrbs  = ((dstNumOfBytesInRdReg[1:0]) == 1) ? 4'b0001 :
                                 ((dstNumOfBytesInRdReg[1:0]) == 2) ? 4'b0011 :
                                 ((dstNumOfBytesInRdReg[1:0]) == 3) ? 4'b0111 :
                                 4'b1111;
        end
    else if (AXI_DMA_DWIDTH == 64)
        begin
            assign writeStrbs  = ((dstNumOfBytesInRdReg[2:0]) == 1) ? 8'b0000_0001 :
                                 ((dstNumOfBytesInRdReg[2:0]) == 2) ? 8'b0000_0011 :
                                 ((dstNumOfBytesInRdReg[2:0]) == 3) ? 8'b0000_0111 :
                                 ((dstNumOfBytesInRdReg[2:0]) == 4) ? 8'b0000_1111 :
                                 ((dstNumOfBytesInRdReg[2:0]) == 5) ? 8'b0001_1111 :
                                 ((dstNumOfBytesInRdReg[2:0]) == 6) ? 8'b0011_1111 :
                                 ((dstNumOfBytesInRdReg[2:0]) == 7) ? 8'b0111_1111 :
                                 8'b1111_1111;
        end
    else if (AXI_DMA_DWIDTH == 128)
        begin
            assign writeStrbs  = ((dstNumOfBytesInRdReg[3:0]) == 1)  ? 16'b0000_0000_0000_0001 :
                                 ((dstNumOfBytesInRdReg[3:0]) == 2)  ? 16'b0000_0000_0000_0011 :
                                 ((dstNumOfBytesInRdReg[3:0]) == 3)  ? 16'b0000_0000_0000_0111 :
                                 ((dstNumOfBytesInRdReg[3:0]) == 4)  ? 16'b0000_0000_0000_1111 :
                                 ((dstNumOfBytesInRdReg[3:0]) == 5)  ? 16'b0000_0000_0001_1111 :
                                 ((dstNumOfBytesInRdReg[3:0]) == 6)  ? 16'b0000_0000_0011_1111 :
                                 ((dstNumOfBytesInRdReg[3:0]) == 7)  ? 16'b0000_0000_0111_1111 :
                                 ((dstNumOfBytesInRdReg[3:0]) == 8)  ? 16'b0000_0000_1111_1111 :
                                 ((dstNumOfBytesInRdReg[3:0]) == 9)  ? 16'b0000_0001_1111_1111 :
                                 ((dstNumOfBytesInRdReg[3:0]) == 10) ? 16'b0000_0011_1111_1111 :
                                 ((dstNumOfBytesInRdReg[3:0]) == 11) ? 16'b0000_0111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[3:0]) == 12) ? 16'b0000_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[3:0]) == 13) ? 16'b0001_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[3:0]) == 14) ? 16'b0011_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[3:0]) == 15) ? 16'b0111_1111_1111_1111 :
                                 16'b1111_1111_1111_1111;
        end
    else if (AXI_DMA_DWIDTH == 256)
        begin
            assign writeStrbs  = ((dstNumOfBytesInRdReg[4:0]) == 1)  ? 32'b0000_0000_0000_0000_0000_0000_0000_0001 :
                                 ((dstNumOfBytesInRdReg[4:0]) == 2)  ? 32'b0000_0000_0000_0000_0000_0000_0000_0011 :
                                 ((dstNumOfBytesInRdReg[4:0]) == 3)  ? 32'b0000_0000_0000_0000_0000_0000_0000_0111 :
                                 ((dstNumOfBytesInRdReg[4:0]) == 4)  ? 32'b0000_0000_0000_0000_0000_0000_0000_1111 :
                                 ((dstNumOfBytesInRdReg[4:0]) == 5)  ? 32'b0000_0000_0000_0000_0000_0000_0001_1111 :
                                 ((dstNumOfBytesInRdReg[4:0]) == 6)  ? 32'b0000_0000_0000_0000_0000_0000_0011_1111 :
                                 ((dstNumOfBytesInRdReg[4:0]) == 7)  ? 32'b0000_0000_0000_0000_0000_0000_0111_1111 :
                                 ((dstNumOfBytesInRdReg[4:0]) == 8)  ? 32'b0000_0000_0000_0000_0000_0000_1111_1111 :
                                 ((dstNumOfBytesInRdReg[4:0]) == 9)  ? 32'b0000_0000_0000_0000_0000_0001_1111_1111 :
                                 ((dstNumOfBytesInRdReg[4:0]) == 10) ? 32'b0000_0000_0000_0000_0000_0011_1111_1111 :
                                 ((dstNumOfBytesInRdReg[4:0]) == 11) ? 32'b0000_0000_0000_0000_0000_0111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[4:0]) == 12) ? 32'b0000_0000_0000_0000_0000_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[4:0]) == 13) ? 32'b0000_0000_0000_0000_0001_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[4:0]) == 14) ? 32'b0000_0000_0000_0000_0011_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[4:0]) == 15) ? 32'b0000_0000_0000_0000_0111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[4:0]) == 16) ? 32'b0000_0000_0000_0000_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[4:0]) == 17) ? 32'b0000_0000_0000_0001_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[4:0]) == 18) ? 32'b0000_0000_0000_0011_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[4:0]) == 19) ? 32'b0000_0000_0000_0111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[4:0]) == 20) ? 32'b0000_0000_0000_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[4:0]) == 21) ? 32'b0000_0000_0001_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[4:0]) == 22) ? 32'b0000_0000_0011_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[4:0]) == 23) ? 32'b0000_0000_0111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[4:0]) == 24) ? 32'b0000_0000_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[4:0]) == 25) ? 32'b0000_0001_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[4:0]) == 26) ? 32'b0000_0011_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[4:0]) == 27) ? 32'b0000_0111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[4:0]) == 28) ? 32'b0000_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[4:0]) == 29) ? 32'b0001_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[4:0]) == 30) ? 32'b0011_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[4:0]) == 31) ? 32'b0111_1111_1111_1111_1111_1111_1111_1111 :
                                 32'b1111_1111_1111_1111_1111_1111_1111_1111;
        end
    else if (AXI_DMA_DWIDTH == 512)
        begin
            assign writeStrbs  = ((dstNumOfBytesInRdReg[5:0]) == 1)  ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 2)  ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0011 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 3)  ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 4)  ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 5)  ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 6)  ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0011_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 7)  ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 8)  ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 9)  ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 10) ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0011_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 11) ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 12) ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 13) ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 14) ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0011_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 15) ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 16) ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 17) ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 18) ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0011_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 19) ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 20) ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 21) ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 22) ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0011_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 23) ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 24) ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 25) ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 26) ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0011_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 27) ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 28) ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 29) ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0001_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 30) ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0011_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 31) ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_0111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 32) ? 64'b0000_0000_0000_0000_0000_0000_0000_0000_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 33) ? 64'b0000_0000_0000_0000_0000_0000_0000_0001_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 34) ? 64'b0000_0000_0000_0000_0000_0000_0000_0011_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 35) ? 64'b0000_0000_0000_0000_0000_0000_0000_0111_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 36) ? 64'b0000_0000_0000_0000_0000_0000_0000_1111_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 37) ? 64'b0000_0000_0000_0000_0000_0000_0001_1111_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 38) ? 64'b0000_0000_0000_0000_0000_0000_0011_1111_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 39) ? 64'b0000_0000_0000_0000_0000_0000_0111_1111_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 40) ? 64'b0000_0000_0000_0000_0000_0000_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 41) ? 64'b0000_0000_0000_0000_0000_0001_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 42) ? 64'b0000_0000_0000_0000_0000_0011_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 43) ? 64'b0000_0000_0000_0000_0000_0111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 44) ? 64'b0000_0000_0000_0000_0000_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 45) ? 64'b0000_0000_0000_0000_0001_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 46) ? 64'b0000_0000_0000_0000_0011_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 47) ? 64'b0000_0000_0000_0000_0111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 48) ? 64'b0000_0000_0000_0000_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 49) ? 64'b0000_0000_0000_0001_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 50) ? 64'b0000_0000_0000_0011_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 51) ? 64'b0000_0000_0000_0111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 52) ? 64'b0000_0000_0000_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 53) ? 64'b0000_0000_0001_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 54) ? 64'b0000_0000_0011_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 55) ? 64'b0000_0000_0111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 56) ? 64'b0000_0000_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 57) ? 64'b0000_0001_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 58) ? 64'b0000_0011_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 59) ? 64'b0000_0111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 60) ? 64'b0000_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 61) ? 64'b0001_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 62) ? 64'b0011_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 ((dstNumOfBytesInRdReg[5:0]) == 63) ? 64'b0111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111 :
                                 64'b1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111;
        end
endgenerate


////////////////////////////////////////////////////////////////////////////////////////
//////////////////////For pipelined memory ---extra logic added/////////////////////////
///////////////////////////////////////////////////////////////////////////////////////

		always @(posedge clock or negedge resetn) 
		   if(resetn == 1'b0) 
			 strtAXIWrTran_reg <= 1'b1;
		   //else if (strtAXIWrTran | str_strt_ctrl)
		   else if(BVALID & BREADY)
			 strtAXIWrTran_reg <= 1'b1; 
		   else if (clrExtDscrptrDataValid | clrStrDscrptrDataValid)
			 strtAXIWrTran_reg <= 1'b0;			


		always @(posedge clock or negedge resetn) 
		   if(resetn == 1'b0) 
			 set_rdaligned_done <= 1'b0;
		   else if(AWVALID & AWREADY & strtAXIWrTran_reg)
			 set_rdaligned_done <= 1'b1;
		   else 
			 set_rdaligned_done <= 1'b0; 

		always @(posedge clock or negedge resetn) begin
		   if(resetn == 1'b0) begin
			  set_rdaligned_done_r <= 1'b0;
		   end
		   else begin
			  set_rdaligned_done_r <= set_rdaligned_done;
		   end
		end
		
	 assign rddata_start = set_rdaligned_done_r;
	 
	 
		always @(posedge clock or negedge resetn) begin
		  if(resetn == 1'b0) begin
			 rddata_start_d <= 1'b0;
		  end
		  else if(WVALID & WLAST & WREADY) begin 
			 rddata_start_d <= 1'b0;
		  end 	  
		  else if(rddata_start) begin
			 rddata_start_d <= 1'b1;
		  end
		 end // always @ (posedge clock or negedge resetn)

		 
			 
	   // Registered rdEnMemMapCache
		always @(posedge clock or negedge resetn) begin
		   if(resetn == 1'b0) begin
			  ren_sc_d1 <= 1'b0;
		   end
		   else begin
			  ren_sc_d1 <= ren_sc;
		   end
		end // always @ (posedge clock or negedge resetn)
	   
		always @(posedge clock or negedge resetn) begin
		   if(resetn == 1'b0) begin
			  ren_sc_d2 <= 1'b0;
		   end
		   else begin
			  ren_sc_d2 <= ren_sc_d1;
		   end
		end // always @ (posedge clock or negedge resetn)
	     //When PIPELINE is enabled, data comes from the memory after two clock cycles.To maintain this latency, data is stored in to two
		 //temparory registers. Whenever valid data is available in these two temp registers, WVALID should not be driven low to achieve 
		 //high throughput. Below logic is design to fullfil the above requirement. 
	
	     always @(posedge clock or negedge resetn) 
            if(resetn == 1'b0) 
              read_cntr <= 0;
			else if(WLAST & WVALID & WREADY) 
              read_cntr <= 0;
            else if(ren_sc_d1 & ~(WVALID & WREADY)) 
              read_cntr <= read_cntr + 1'b1;
			else if(~ren_sc_d1 & (WVALID & WREADY) & (read_cntr != 0)) 
			  read_cntr <= read_cntr - 1'b1;
			  
             
         //WVALID - RVALID logic.It is asserted when delayed request (ren_sc_d1) of read request to the memory is high. It remains high
		 //until last data is read by the AXI4 bus or there is no data into the temp buffer register. To know wheather data is available in 
		 //temp register or not, difference of read_req_cntr and read_data_cntr is taken and compared with 1. When the difference of the counter
		 //is one and data is read by the AXI4 bus, WVALID is driven low as this condition indicates there is no data available in the temp 
		 //registers.
		 
         always @(posedge clock or negedge resetn) 
            if(resetn == 1'b0) 
               WVALIDReg_1 <= 1'b0;
            else if(WLAST == 1'b1 && WVALID == 1'b1 && WREADY) 
               WVALIDReg_1 <= 1'b0;
            else if(ren_sc_d1 | (!strtAXIWrTran_reg & AWVALID & AWREADY) ) 
   	           WVALIDReg_1 <= 1'b1;
			else if(WVALID & WREADY & (read_cntr == 1))
			   WVALIDReg_1 <= 1'b0;
         
         always @(posedge clock or negedge resetn) begin
            if(resetn == 1'b0) begin
               WLASTReg_1 <= 1'b0;
            end
            else begin
               if((WVALID && WREADY && rdbeat_cnt < 'h3 & ~WLAST) || (AWVALID & AWREADY & (AWLEN == 0))) begin
                  WLASTReg_1 <= 1'b1;
               end
               else if((WVALID == 1'b1 && WREADY == 1'b1) | (AWVALID & AWREADY)) begin
                  WLASTReg_1 <= 1'b0;
               end
            end
         end
		 

		 always @(posedge clock or negedge resetn) 
		begin
			if(resetn == 1'b0) 
				begin
					rdbeat_cnt <= 'h0;
				end
			else 
				begin
					if(WVALID & WREADY & WLAST) 
						begin 
							rdbeat_cnt <= 'h0;
						end
					else if(set_rdaligned_done) 
						begin  // Load
							rdbeat_cnt <= AWLEN+'h1; //
						end
					else  
						begin 
							if(WVALID && WREADY && rdbeat_cnt != 'h0) 
								begin 
									rdbeat_cnt <= rdbeat_cnt - 'h1;
								end
						end 		  
				end
		end		 
		  //When Pipeline is enabled, data from memory is available after two clock cycles. So two clock cycle data are stored in 
		  //two temp registers. There are three options to assign data to the AXI4 bus read data. 
		  //1 - Directly assign the data from the memory to the AXI4 bus read data 
		  //2 - Assign temp 1 register's to the AXI4 bus read data 
		  //3 - Assign temp 2 register's to the AXI4 bus read data 
		  //Below logic fullfil the above requirement.	  
			  
			
          //rdata_reg_en_ctrl - Signal is used to load the data into the temp registers.It is toggled when delayed request(ren_sc_d2) 
		  //of actual read request to the memory (ren_sc) is high. It will be reset to 0 when new read request is received.
          //When low and ren_sc_d2 is high, temp 1 register will be enabled and when high and ren_sc_d2 is high, temp 2 register will 
		  //be enabled. This signal is used to enable temp register 1 and temp register 2 alternatively when valid data is available 
		  //from the memory i.e first it enables temp 1 register temp 2 regisetr and so on...
          
          always @(posedge clock or negedge resetn) 
            if(resetn == 1'b0) 
              rdata_reg_en_ctrl <= 1'b0;
	        else if(AWVALID & AWREADY)
	          rdata_reg_en_ctrl <= 1'b0;
            else if(ren_sc_d2)
	          rdata_reg_en_ctrl <= ~rdata_reg_en_ctrl;		  
			  
          //rdata_mc_reg1_en - Enable signal for rdata_mc_reg1 (temp register 1)			  
          
          always @(*) 
	        if(~rdata_reg_en_ctrl & ren_sc_d2)
	          rdata_mc_reg1_en = 1'b1;
            else
	          rdata_mc_reg1_en = 1'b0;
			  
         //rdata_mc_reg2_en - Enable signal for rdata_mc_reg2 (temp register 2)			  			  
          
          always @(*) 
            if(rdata_reg_en_ctrl & ren_sc_d2)
	          rdata_mc_reg2_en = 1'b1;
            else
	          rdata_mc_reg2_en = 1'b0;
			  
         //rdata_mc_reg1 - Temp data register 1. Data from the memory will be stored when enable is high
	
				always @(posedge clock or negedge resetn) 
					if(resetn == 1'b0) 
						rdata_mc_reg1 <= 0;
					else if((AXI4_STREAM_IF == 1) && (dstStrDscrptrReg == 1'b1))
						begin
						  if(rdata_mc_reg1_en)
								rdata_mc_reg1 <= rdDataStrCache;
						end
					else
						begin
						 if(rdata_mc_reg1_en)
								rdata_mc_reg1 <= rdDataMemMapCache;
						end
						
				always @(posedge clock or negedge resetn) 
					if(resetn == 1'b0) 
						rdata_mc_reg2 <= 0;
					else if((AXI4_STREAM_IF == 1) && (dstStrDscrptrReg == 1'b1))
						begin
						  if(rdata_mc_reg2_en)
								rdata_mc_reg2 <= rdDataStrCache;
						end
					else
						begin
						 if(rdata_mc_reg2_en)
								rdata_mc_reg2 <= rdDataMemMapCache;
						end						
				
				//rdata_mc_reg2 - Temp data register 2. Data from the memory will be stored when enable is high
				
		
				always @(*)
				if ((AXI4_STREAM_IF == 1) && (dstStrDscrptrReg == 1'b1))
					begin
						if(!strtAXIWrTran_reg & WVALID)
							WDATAReg_1 = {{(AXI_DMA_DWIDTH-4){1'b0}}, 1'b1, 1'b0, clrStrDscrptrDstOp[1:0]};
						else if(ren_sc_d2 & (read_data_cntr == 0))
							WDATAReg_1 = rdDataStrCache;
						else if(rdata_mc_reg1_sel)
							WDATAReg_1 = rdata_mc_reg1;
						else 
							WDATAReg_1 = rdata_mc_reg2;
					end
				else
					begin
						if(!strtAXIWrTran_reg & WVALID)
							WDATAReg_1 = {{(AXI_DMA_DWIDTH-16){1'b0}}, configRegByte2, {8{1'b0}}};
						else if(ren_sc_d2 & (read_data_cntr == 0))
							WDATAReg_1 = rdDataMemMapCache;
						else if(rdata_mc_reg1_sel)
							WDATAReg_1 = rdata_mc_reg1;
						else 
							WDATAReg_1 = rdata_mc_reg2;						
					end

          
		 //rdata_mc_reg1_sel - This signal is used to decide whether temp 1 register data should be assigned or temp 2 register data 
		 //should be assigned to AXI4 read data.This signal selects alterantively temp 1 register data and temp 2 register data.
		 //It is acheived by toggling this signal when there is data read from the AXI4 bus.Reset value of this signal is high and 
		 //it will be set high again when new read request is asserted. When 1, assigns temp 1 register data to AXI4 read data and 
		 //when 0, assignes temp 2 register data to AXI4 read data. 
		 
		  
          always @(posedge clock or negedge resetn) 
            if(resetn == 1'b0) 
              rdata_mc_reg1_sel <= 1'b1;
	        else if(AWVALID & AWREADY)
	          rdata_mc_reg1_sel <= 1'b1;
            else if(WVALID & WREADY)
	          rdata_mc_reg1_sel <= ~rdata_mc_reg1_sel;	


          //read_data_cntr - Counter is used to keep track of number of data read from the memory and number of data read by the AXI4.
          //Counter is incremented whenever ren_sc_d3 is high and decremented when RVALID and RREADY are high. When both condition for 
          //increment and decrement are true at the same time, counter value is not updated. Whenver value of this counter is zero, 
          //data read from the memory directly assigned to the AXI4 RDATA. When its value other than 0, data from the internal register
          //will be assigned to AXI4 RDATA.		  
			  
          always @(posedge clock or negedge resetn) 
            if(resetn == 1'b0) 
              read_data_cntr <= 0;
	        else if(AWVALID & AWREADY)
	          read_data_cntr <= 0;
            else if(ren_sc_d2 ^ (WVALID & WREADY))
			  begin 
			    if(ren_sc_d2)
			      read_data_cntr <= read_data_cntr + 1'b1;		  
			    else if(read_data_cntr != 0)            
				  read_data_cntr <= read_data_cntr - 1'b1;		  
			  end 
              
         //rdata_mc	- Actual read data (RDATA) of AXI4 bus.Initially, data from the memory directly assigns to RDATA. If RREADY goes 
         //low when RVALID is high and there is a valid data available in the temp registers then data from the temp registers will 
         //be assigned to RDATA based on the value of rdata_mc_reg1_sel. 		 
	  
          //always @(*) 
		  //  if(ren_sc_d2 & (read_data_cntr == 0))
		  //    WDATAReg_1 = rdDataMemMapCache;
		  //  else if(rdata_mc_reg1_sel)
		  //    WDATAReg_1 = rdata_mc_reg1;
		  // else 
		  //    WDATAReg_1 = rdata_mc_reg2;
			  
          always@(posedge clock or negedge resetn)
		    if(resetn == 1'b0)
		      ram_rdreq_cntr <= 0;
		    else if(WVALID & WLAST & WREADY)
		      ram_rdreq_cntr <= 0;
            else if(ren_sc)		
              ram_rdreq_cntr <= ram_rdreq_cntr + 1'b1;		
			 
		  always@(*)
		    if(ram_rdreq_cntr == (AWLEN + 1)) begin
		      ren_sc = 1'b0;
			  //rdAddr_1 = 0;
			 end
		    else if(((rddata_start_d & WREADY) | set_rdaligned_done_r)) begin
              ren_sc = 1'b1;
			  //rdAddr_1 <= rdAddr_1 + 1'b1;
				end
            else 
              ren_sc = 1'b0;
			  
			  
          //always@(posedge clock or negedge resetn)
		  //  if(resetn == 1'b0)
		  //    rdAddr_1 <= 0;
		  //  else if(ren_sc || set_rdaligned_done)
		  //    rdAddr_1 <= rdAddr_1 + 1'b1;

    always @(posedge clock or negedge resetn) begin
       if(resetn == 1'b0)
          rdAddr_1   <= 0;
       else 
		begin 
			if ((AXI4_STREAM_IF == 1) && (dstStrDscrptrReg == 1'b1))
				begin
					if(AXI4StreamWrTransDone | AXI4StreamWrTransError)
						rdAddr_1 <= 0;
					else if(ren_sc) 
						rdAddr_1 <= rdAddr_1 + 1;
				end
		   else 
				begin
					if (AXI4WrTransDone | AXI4WrTransError)
						rdAddr_1 <= 0;
					else if(ren_sc) 
						rdAddr_1 <= rdAddr_1 + 1;  		 
				end
       end
    end  
			 

///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////End pipelined logic/////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
// Read cache mux
always @ (*)
    begin
        if ((AXI4_STREAM_IF == 1) && (dstStrDscrptrReg == 1'b1))
            begin
                // Inputs
                rdData = rdDataStrCache;
                
                // Outputs
                rdEnStrCache    = ren_sc;
                rdEnMemMapCache = 1'b0;
            end
        else
            begin
                // Inputs
                rdData = rdDataMemMapCache;
                
                // Outputs
                rdEnMemMapCache = ren_sc;
                rdEnStrCache    = 1'b0;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// Write control FSM
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                currStateWr <= WR_IDLE;
            end
        else
            begin
                currStateWr <= nextStateWr;
            end
    end

always @(*)
    begin
        // Default assignments
        AWVALIDReg_d                       = 1'b0;
        AWADDRReg_d                        = AWADDRReg;
        AWIDReg_d                          = {ID_WIDTH{1'b0}}; // Always drive ID as zeros
        AWLENReg_d                         = AWLENReg;
        AWSIZEReg_d                        = AWSIZEReg;
        AWBURSTReg_d                       = AWBURSTReg;
        WVALIDReg_d                        = 1'b0;
        WSTRBReg_d                         = WSTRBReg;
        WDATAReg_d                         = WDATAReg;
        WLASTReg_d                         = WLASTReg;
        BREADYReg_d                        = 1'b0;
        rdEnReg_d                          = 1'b0;
        rdAddrReg_d                        = rdAddrReg;
        rdNumOfBytesReg_d                  = {TRAN_BYTE_CNT_WIDTH{1'b0}};
//        rdNumOfBytesReg_d                  = rdNumOfBytesReg;
        beatCntReg_d                       = beatCntReg;
        AXI4StreamWrTransDone              = 1'b0;
        AXI4WrTransDone                    = 1'b0;
        AXI4StreamWrTransError             = 1'b0;
        AXI4WrTransError                   = 1'b0;
        beatsInWrBurst_d                   = beatsInWrBurst;
        dstAXIStrtAddrReg_d                = dstAXIStrtAddrReg;
        dstNumOfBytesInRdReg_d             = dstNumOfBytesInRdReg;
        dstBurstTypeReg_d                  = dstBurstTypeReg;
        wrByteCnt_d                        = wrByteCnt;
        extFetchValidWr                    = 1'b0;
        dstStrDscrptrReg_d                 = dstStrDscrptrReg;
        strRdyToAckReg_d                   = 1'b0;
        numOfBytesInWr_AXI4MasterCtrlReg_d = numOfBytesInWr_AXI4MasterCtrlReg;
        clrStrDscrptrDataValidAck          = 1'b0;
		str_strt_ctrl					   = 1'b0;
        case (currStateWr)
            WR_IDLE:
                begin
                    if (strtAXIWrTran)
                        begin
                            dstStrDscrptrReg_d = dstStrDscrptr;
                            if ((AXI4_STREAM_IF == 1) && (dstStrDscrptr == 1'b1))
                                begin
                                    dstNumOfBytesInRdReg_d = dstNumOfBytesInRd;
                                    dstAXIStrtAddrReg_d    = dstAXIStrtAddr;
                                    if (dstAXITranType == 2'b10)
                                        begin
                                            dstBurstTypeReg_d = 2'b00;
                                        end
                                    else
                                        begin
                                            dstBurstTypeReg_d = 2'b01;
                                        end
                                    // Allow for a narrow transfer in the last beat of the burst
                                    if ((dstNumOfBytesInRd >= (1+(dstMaxAXINumBeats << AXI_SIZE))) && (dstAXIStrtAddr[11:0] <= 13'd4096-((1+dstMaxAXINumBeats) << AXI_SIZE)))
                                        begin
                                            beatsInWrBurst_d = dstMaxAXINumBeats;
                                        end
                                    else if ((dstNumOfBytesInRd >= (1+(127 * (AXI_DMA_DWIDTH/8)))) && (dstAXIStrtAddr[11:0] <= 13'd4096-(128 * (AXI_DMA_DWIDTH/8))))
                                        begin
                                            beatsInWrBurst_d = 8'd127;
                                        end
                                    else if ((dstNumOfBytesInRd >= (1+(63 * (AXI_DMA_DWIDTH/8)))) && (dstAXIStrtAddr[11:0] <= 13'd4096-(64 * (AXI_DMA_DWIDTH/8))))
                                        begin
                                            beatsInWrBurst_d = 8'd63;
                                        end
                                    else if ((dstNumOfBytesInRd >= (1+(31 * (AXI_DMA_DWIDTH/8)))) && (dstAXIStrtAddr[11:0] <= 13'd4096-(32 * (AXI_DMA_DWIDTH/8))))
                                        begin
                                            beatsInWrBurst_d = 8'd31;
                                        end
                                    else if ((dstNumOfBytesInRd >= (1+(15 * (AXI_DMA_DWIDTH/8)))) && (dstAXIStrtAddr[11:0] <= 13'd4096-(16 * (AXI_DMA_DWIDTH/8))))
                                        begin
                                            beatsInWrBurst_d = 8'd15;
                                        end
                                    else if ((dstNumOfBytesInRd >= (1+(7 * (AXI_DMA_DWIDTH/8))))  && (dstAXIStrtAddr[11:0] <= 13'd4096-(8 * (AXI_DMA_DWIDTH/8))))
                                        begin
                                            beatsInWrBurst_d = 8'd7;
                                        end
                                    else if ((dstNumOfBytesInRd >= (1+(3 * (AXI_DMA_DWIDTH/8))))  && (dstAXIStrtAddr[11:0] <= 13'd4096-(4 * (AXI_DMA_DWIDTH/8))))
                                        begin
                                            beatsInWrBurst_d = 8'd3;
                                        end
                                    else
                                        begin
                                            beatsInWrBurst_d = 8'd0;
                                        end
                                    strRdyToAckReg_d = 1'b1;
                                    nextStateWr      = WR_STR_CALC_BYTES_IN_WRITE;
                                end
                            else
                                begin
                                    dstNumOfBytesInRdReg_d = dstNumOfBytesInRd;
                                    dstAXIStrtAddrReg_d    = dstAXIStrtAddr;
                                    if (numBytesInMemMapCache >= dstNumOfBytesInRd)
                                        begin
                                            // Don't start off the write operation until the read is complete
                                            // to prevent a read underrun
                                            AWVALIDReg_d = 1'b1;
                                            AWADDRReg_d  = dstAXIStrtAddr;
                                            AWSIZEReg_d  = AXI_SIZE;
                                            if (dstAXITranType == 2'b10)
                                                begin
                                                    AWBURSTReg_d = 2'b00;
                                                end
                                            else
                                                begin
                                                    AWBURSTReg_d = 2'b01;
                                                end
                                            if ((dstNumOfBytesInRd >= (1+(dstMaxAXINumBeats << AXI_SIZE))) && (dstAXIStrtAddr[11:0] <= 13'd4096-((1+dstMaxAXINumBeats) << AXI_SIZE)))
                                                begin
                                                    AWLENReg_d       = dstMaxAXINumBeats;
                                                    beatsInWrBurst_d = dstMaxAXINumBeats;
                                                end
                                            else if ((dstNumOfBytesInRd >= (1+(127 * (AXI_DMA_DWIDTH/8)))) && (dstAXIStrtAddr[11:0] <= 13'd4096-(128 * (AXI_DMA_DWIDTH/8))))
                                                begin
                                                    AWLENReg_d       = 8'd127;
                                                    beatsInWrBurst_d = 8'd127;
                                                end
                                            else if ((dstNumOfBytesInRd >= (1+(63 * (AXI_DMA_DWIDTH/8)))) && (dstAXIStrtAddr[11:0] <= 13'd4096-(64 * (AXI_DMA_DWIDTH/8))))
                                                begin
                                                    AWLENReg_d       = 8'd63;
                                                    beatsInWrBurst_d = 8'd63;
                                                end
                                            else if ((dstNumOfBytesInRd >= (1+(31 * (AXI_DMA_DWIDTH/8)))) && (dstAXIStrtAddr[11:0] <= 13'd4096-(32 * (AXI_DMA_DWIDTH/8))))
                                                begin
                                                    AWLENReg_d       = 8'd31;
                                                    beatsInWrBurst_d = 8'd31;
                                                end
                                            else if ((dstNumOfBytesInRd >= (1+(15 * (AXI_DMA_DWIDTH/8)))) && (dstAXIStrtAddr[11:0] <= 13'd4096-(16 * (AXI_DMA_DWIDTH/8))))
                                                begin
                                                    AWLENReg_d       = 8'd15;
                                                    beatsInWrBurst_d = 8'd15;
                                                end
                                            else if ((dstNumOfBytesInRd >= (1+(7 * (AXI_DMA_DWIDTH/8)))) && (dstAXIStrtAddr[11:0] <= 13'd4096-(8 * (AXI_DMA_DWIDTH/8))))
                                                begin
                                                    AWLENReg_d       = 8'd7;
                                                    beatsInWrBurst_d = 8'd7;
                                                end
                                            else if ((dstNumOfBytesInRd >= (1+(3 * (AXI_DMA_DWIDTH/8)))) && (dstAXIStrtAddr[11:0] <= 13'd4096-(4 * (AXI_DMA_DWIDTH/8))))
                                                begin
                                                    AWLENReg_d       = 8'd3;
                                                    beatsInWrBurst_d = 8'd3;
                                                end
                                            else
                                                begin
                                                    AWLENReg_d       = 8'd0;
                                                    beatsInWrBurst_d = 8'd0;
                                                end
                                            nextStateWr = WAIT_WR_ADDR_ACK;
                                        end
                                    else
                                        begin
                                            if (dstAXITranType == 2'b10)
                                                begin
                                                    dstBurstTypeReg_d = 2'b00;
                                                end
                                            else
                                                begin
                                                    dstBurstTypeReg_d = 2'b01;
                                                end
                                            if ((dstNumOfBytesInRd >= (1+(dstMaxAXINumBeats << AXI_SIZE))) && (dstAXIStrtAddr[11:0] <= 13'd4096-((1+dstMaxAXINumBeats) << AXI_SIZE)))
                                                begin
                                                    beatsInWrBurst_d = dstMaxAXINumBeats;
                                                end
                                            else if ((dstNumOfBytesInRd >= (1+(127 * (AXI_DMA_DWIDTH/8)))) && (dstAXIStrtAddr[11:0] <= 13'd4096-(128 * (AXI_DMA_DWIDTH/8))))
                                                begin
                                                    beatsInWrBurst_d = 8'd127;
                                                end
                                            else if ((dstNumOfBytesInRd >= (1+(63 * (AXI_DMA_DWIDTH/8)))) && (dstAXIStrtAddr[11:0] <= 13'd4096-(64 * (AXI_DMA_DWIDTH/8))))
                                                begin
                                                    beatsInWrBurst_d = 8'd63;
                                                end
                                            else if ((dstNumOfBytesInRd >= (1+(31 * (AXI_DMA_DWIDTH/8)))) && (dstAXIStrtAddr[11:0] <= 13'd4096-(32 * (AXI_DMA_DWIDTH/8))))
                                                begin
                                                    beatsInWrBurst_d = 8'd31;
                                                end
                                            else if ((dstNumOfBytesInRd >= (1+(15 * (AXI_DMA_DWIDTH/8)))) && (dstAXIStrtAddr[11:0] <= 13'd4096-(16 * (AXI_DMA_DWIDTH/8))))
                                                begin
                                                    beatsInWrBurst_d = 8'd15;
                                                end
                                            else if ((dstNumOfBytesInRd >= (1+(7 * (AXI_DMA_DWIDTH/8)))) && (dstAXIStrtAddr[11:0] <= 13'd4096-(8 * (AXI_DMA_DWIDTH/8))))
                                                begin
                                                    beatsInWrBurst_d = 8'd7;
                                                end
                                            else if ((dstNumOfBytesInRd >= (1+(3 * (AXI_DMA_DWIDTH/8)))) && (dstAXIStrtAddr[11:0] <= 13'd4096-(4 * (AXI_DMA_DWIDTH/8))))
                                                begin
                                                    beatsInWrBurst_d = 8'd3;
                                                end
                                            else
                                                begin
                                                    beatsInWrBurst_d = 8'd0;
                                                end
                                            nextStateWr = WAIT_WR_BYTES_IN_CACHE;
                                        end
                                end
                        end
                    else if (clrExtDscrptrDataValid)
                        begin
                            AWVALIDReg_d = 1'b1;
                            AWADDRReg_d  = strtAddr_extDscrptrFetch;
                            AWSIZEReg_d  = AXI_SIZE;
                            AWBURSTReg_d = 2'b01;
                            AWLENReg_d   = 8'd0;
                            nextStateWr  = WR_WAIT_ADDR_ACK_CLR_VALID;
                        end
                    else if (clrStrDscrptrDataValid)
                        begin
                            AWADDRReg_d        = clrStrDscrptrAddr;
                            AWVALIDReg_d       = 1'b1;
                            AWSIZEReg_d        = AXI_SIZE;
                            AWBURSTReg_d       = 2'b01;
                            AWLENReg_d         = 8'd0;
                            dstStrDscrptrReg_d = 1'b1;
                            nextStateWr        = WR_WAIT_ADDR_ACK_CLR_VALID;
                        end
                    else
                        begin
                            nextStateWr = WR_IDLE;
                        end
                end
            WAIT_WR_BYTES_IN_CACHE:
                begin
                    if (numBytesInMemMapCache >= dstNumOfBytesInRdReg)
                        begin
                            AWVALIDReg_d = 1'b1;
                            AWADDRReg_d  = dstAXIStrtAddrReg;
                            AWSIZEReg_d  = AXI_SIZE;
                            AWLENReg_d   = beatsInWrBurst;
                            AWBURSTReg_d = dstBurstTypeReg;
                            nextStateWr  = WAIT_WR_ADDR_ACK;
                        end
                    else
                        begin
                            nextStateWr = WAIT_WR_BYTES_IN_CACHE;
                        end
                end
            WAIT_WR_ADDR_ACK:
                begin
                    //if (AWVALID & AWREADY)
                    //    begin
                            //AWADDRReg_d  = 32'b0;
                            //AWLENReg_d   = 8'b0;
                            //AWSIZEReg_d  = 3'b0;
                            //AWBURSTReg_d = 2'b0;
                            WDATAReg_d   = rdData;
                           // WVALIDReg_d  = 1'b1;
                            rdEnReg_d    = 1'b1;
                            if (beatCntReg == beatsInWrBurst)
                                begin
                                    // Transaction contains only a single beat
                                    WLASTReg_d   = 1'b1;
                                    nextStateWr  = WR_DATA_TX_LAST;
                                    if ((dstNumOfBytesInRdReg[AXI_SIZE-1:0] != {AXI_SIZE{1'b0}}) && (dstNumOfBytesInRdReg <= (AXI_DMA_DWIDTH/8)))
                                        begin
                                            // Last transfer in the transaction is narrow
                                            wrByteCnt_d       = wrByteCnt + dstNumOfBytesInRdReg[AXI_SIZE-1:0];
                                            rdNumOfBytesReg_d = {1'b0, dstNumOfBytesInRdReg[AXI_SIZE-1:0]};
                                            WSTRBReg_d        = writeStrbs;
                                        end
                                    else
                                        begin
                                            // Number of bytes in transaction a multiple of 64
                                            wrByteCnt_d       = wrByteCnt + (AXI_DMA_DWIDTH/8);
                                            rdNumOfBytesReg_d = (AXI_DMA_DWIDTH/8);
                                            WSTRBReg_d        = {(AXI_DMA_DWIDTH/8){1'b1}};
                                        end
                                end
                            else 
                                begin
                                    wrByteCnt_d       = wrByteCnt + (AXI_DMA_DWIDTH/8);
                                    rdAddrReg_d       = rdAddrReg + 1'b1;
                                    rdNumOfBytesReg_d = (AXI_DMA_DWIDTH/8);
                                    WSTRBReg_d        = {(AXI_DMA_DWIDTH/8){1'b1}};
                                    if (beatCntReg == beatsInWrBurst-1)
                                        begin
                                            nextStateWr = WR_DATA_TX_PEN_BEAT;
                                        end
                                    else 
                                        begin
                                            nextStateWr = WR_DATA_TX;
                                        end
                                end
                                //end
                    //else
                    //    begin
                    //        AWVALIDReg_d = 1'b1;
                    //       nextStateWr  = WAIT_WR_ADDR_ACK;
                    //    end
                end
            WR_DATA_TX:
                begin
                    rdNumOfBytesReg_d = (AXI_DMA_DWIDTH/8);				
                    if (WVALID & WREADY)
                        begin
                            beatCntReg_d      = beatCntReg + 1'b1;
                            WDATAReg_d        = rdData;
                            //WVALIDReg_d       = 1'b1;
                            wrByteCnt_d       = wrByteCnt + (AXI_DMA_DWIDTH/8);
                            rdEnReg_d         = 1'b1;
                            rdAddrReg_d       = rdAddrReg + 1'b1;
                           // rdNumOfBytesReg_d = (AXI_DMA_DWIDTH/8);
                            WSTRBReg_d        = {(AXI_DMA_DWIDTH/8){1'b1}};
                            if (beatCntReg == beatsInWrBurst-2'd2)
                                begin
                                    nextStateWr = WR_DATA_TX_PEN_BEAT;
                                end
                            else
                                begin
                                    nextStateWr = WR_DATA_TX;
                                end
                        end
                    else
                        begin
                            //WVALIDReg_d = 1'b1;
                            nextStateWr = WR_DATA_TX;
                        end
                end
            WR_DATA_TX_PEN_BEAT:
                begin
					  rdNumOfBytesReg_d = rdNumOfBytesReg;
                    if (WVALID & WREADY)
                        begin
                            beatCntReg_d = beatCntReg + 1'b1;
                            WDATAReg_d   = rdData;
                            //WVALIDReg_d  = 1'b1;
                            rdEnReg_d    = 1'b1;
                            WLASTReg_d   = 1'b1;
                            nextStateWr  = WR_DATA_TX_LAST;
                            if (dstNumOfBytesInRdReg <= (wrByteCnt + (AXI_DMA_DWIDTH/8)))
                                begin
                                    // This is the last transfer of the last/only write
                                    // transaction.
                                    if (dstNumOfBytesInRdReg[AXI_SIZE-1:0] == {AXI_SIZE{1'b0}})
                                        begin
                                            // Number of bytes in transaction a multiple of data width
                                            wrByteCnt_d       = wrByteCnt + (AXI_DMA_DWIDTH/8);
                                            rdNumOfBytesReg_d = (AXI_DMA_DWIDTH/8);
                                            WSTRBReg_d        = {(AXI_DMA_DWIDTH/8){1'b1}};
                                        end
                                    else
                                        begin
                                            // Last transfer in the transaction is narrow
                                            wrByteCnt_d       = wrByteCnt + dstNumOfBytesInRdReg[AXI_SIZE-1:0];
                                            rdNumOfBytesReg_d = {1'b0, dstNumOfBytesInRdReg[AXI_SIZE-1:0]};
                                            WSTRBReg_d        = writeStrbs;
                                        end
                                end
                            else
                                begin
                                    // Multiple write transactions to empty the store and
                                    // forward cache as the src start address and the
                                    // destination start address were different and the
                                    // destination operation crosses a 4 KB boundary
                                    wrByteCnt_d       = wrByteCnt + (AXI_DMA_DWIDTH/8);
                                    rdNumOfBytesReg_d = (AXI_DMA_DWIDTH/8);
                                    WSTRBReg_d        = {(AXI_DMA_DWIDTH/8){1'b1}};
                                end
                        end
                    else
                        begin
                            //WVALIDReg_d = 1'b1;
                            nextStateWr = WR_DATA_TX_PEN_BEAT;
                        end
                end
            WR_DATA_TX_LAST:
                begin
					rdNumOfBytesReg_d = rdNumOfBytesReg;					
                    if (WVALID & WREADY)
                        begin
                            beatCntReg_d = 9'b0; 
                            WSTRBReg_d   = {(AXI_DMA_DWIDTH/8){1'b0}};
                            WDATAReg_d   = {AXI_DMA_DWIDTH{1'b0}};
                            WLASTReg_d   = 1'b0;
                            BREADYReg_d  = 1'b1;
                            nextStateWr  = WR_RESP;
                        end
                    else
                        begin
                            //WVALIDReg_d = 1'b1;
                            nextStateWr = WR_DATA_TX_LAST;
                        end
                end
            WR_RESP:
                begin
                    if (BVALID & BREADY)
                        begin
                            if (BRESP == 2'b00)
                                begin
                                    if (dstNumOfBytesInRdReg == wrByteCnt)
                                        begin
                                            rdAddrReg_d = 8'b0;
                                            wrByteCnt_d = {MAX_AXI_TRAN_SIZE_WIDTH{1'b0}};
                                            nextStateWr = WR_IDLE;
                                            if ((dstStrDscrptrReg == 1'b1) && (AXI4_STREAM_IF == 1))
                                                begin
                                                    AXI4StreamWrTransDone = 1'b1;
                                                    dstStrDscrptrReg_d    = 1'b0;
                                                end
                                            else
                                                begin
                                                    AXI4WrTransDone = 1'b1;
                                                end
                                        end
                                    else
                                        begin
                                            // Multiple write transfers are required to empty
                                            // the read cache as the write spans a 4 KB
                                            // boundary
                                            rdAddrReg_d = rdAddrReg + 1'b1;
                                            nextStateWr = WR_NEXT_TRAN_CONFIG;
                                        end
                                end
                            else
                                begin
                                    rdAddrReg_d = 8'b0;
                                    wrByteCnt_d = {MAX_AXI_TRAN_SIZE_WIDTH{1'b0}};
                                    nextStateWr = WR_IDLE;
                                    if ((dstStrDscrptrReg == 1'b1) && (AXI4_STREAM_IF == 1))
                                        begin
                                            AXI4StreamWrTransError = 1'b1;
                                            dstStrDscrptrReg_d     = 1'b0;
                                        end
                                    else
                                        begin
                                            AXI4WrTransError = 1'b1;
                                        end
                                end
                        end
                    else
                        begin
                            BREADYReg_d = 1'b1;
                            nextStateWr = WR_RESP;
                        end
                end
            WR_NEXT_TRAN_CONFIG:
                begin
                    // Determine the size of the next write operation to empty
                    // the leftover contents of the read cache resulting from
                    // the write operation spanning a 4 KB boundary.
                    wrByteCnt_d            = {MAX_AXI_TRAN_SIZE_WIDTH{1'b0}};
                    dstNumOfBytesInRdReg_d = dstNumOfBytesInRdReg - wrByteCnt;
                    if (dstAXITranType == 2'b10)
                        begin
                            // Fixed address
                        end
                    else
                        begin
                            // Incrementing address
                            AWADDRReg_d         = dstAXIStrtAddrReg + wrByteCnt;  
                            dstAXIStrtAddrReg_d = dstAXIStrtAddrReg + wrByteCnt;
                        end
                    if ((dstNumOfBytesInRdReg_d >= (1+(dstMaxAXINumBeats << AXI_SIZE))) && (dstAXIStrtAddrReg_d[11:0] <= 13'd4096-((1+dstMaxAXINumBeats) << AXI_SIZE)))
                        begin
                            beatsInWrBurst_d = dstMaxAXINumBeats;
                        end
                    else if ((dstNumOfBytesInRdReg_d >= (1+(127 * (AXI_DMA_DWIDTH/8)))) && (dstAXIStrtAddrReg_d[11:0] <= 13'd4096-(128 * (AXI_DMA_DWIDTH/8))))
                        begin
                            beatsInWrBurst_d = 8'd127;
                        end
                    else if ((dstNumOfBytesInRdReg_d >= (1+(63 * (AXI_DMA_DWIDTH/8)))) && (dstAXIStrtAddrReg_d[11:0] <= 13'd4096-(64 * (AXI_DMA_DWIDTH/8))))
                        begin
                            beatsInWrBurst_d = 8'd63;
                        end
                    else if ((dstNumOfBytesInRdReg_d >= (1+(31 * (AXI_DMA_DWIDTH/8)))) && (dstAXIStrtAddrReg_d[11:0] <= 13'd4096-(32 * (AXI_DMA_DWIDTH/8))))
                        begin
                            beatsInWrBurst_d = 8'd31;
                        end
                    else if ((dstNumOfBytesInRdReg_d >= (1+(15 * (AXI_DMA_DWIDTH/8)))) && (dstAXIStrtAddrReg_d[11:0] <= 13'd4096-(16 * (AXI_DMA_DWIDTH/8))))
                        begin
                            beatsInWrBurst_d = 8'd15;
                        end
                    else if ((dstNumOfBytesInRdReg_d >= (1+(7 * (AXI_DMA_DWIDTH/8)))) && (dstAXIStrtAddrReg_d[11:0] <= 13'd4096-(8 * (AXI_DMA_DWIDTH/8))))
                        begin
                            beatsInWrBurst_d = 8'd7;
                        end
                    else if ((dstNumOfBytesInRdReg_d >= (1+(3 * (AXI_DMA_DWIDTH/8)))) && (dstAXIStrtAddrReg_d[11:0] <= 13'd4096-(4 * (AXI_DMA_DWIDTH/8))))
                        begin
                            beatsInWrBurst_d = 8'd3;
                        end
                    else
                        begin
                            beatsInWrBurst_d = 8'd0;
                        end
                    if ((AXI4_STREAM_IF == 1) && (dstStrDscrptrReg == 1'b1))
                        begin
                            AWVALIDReg_d = 1'b0;
                            AWADDRReg_d  = 32'b0;
                            AWBURSTReg_d = 2'b0;
                            AWLENReg_d   = 8'b0;
                            AWSIZEReg_d  = 3'b0;
                            nextStateWr  = WR_STR_CALC_BYTES_IN_WRITE;
                        end
                    else
                        begin
                            AWVALIDReg_d = 1'b1;
                            AWADDRReg_d  = dstAXIStrtAddrReg_d;
                            AWBURSTReg_d = dstBurstTypeReg;
                            AWLENReg_d   = beatsInWrBurst_d;
                            AWSIZEReg_d  = AXI_SIZE;
                            nextStateWr  = WAIT_WR_ADDR_ACK;
                        end
                end
            WR_WAIT_ADDR_ACK_CLR_VALID:
                begin
                    //if (AWVALID & AWREADY)
                    //    begin
                            //AWADDRReg_d  = 32'b0;
                            //AWLENReg_d   = 8'b0;
                            //AWSIZEReg_d  = 3'b0;
                            //AWBURSTReg_d = 2'b0;
                            if ((AXI4_STREAM_IF == 1) && (dstStrDscrptrReg == 1'b1))
                                begin
                                    // Byte Lane 9
                                    WDATAReg_d   = {{(AXI_DMA_DWIDTH-4){1'b0}}, 1'b1, 1'b0, clrStrDscrptrDstOp[1:0]};
                                    WSTRBReg_d   = {{((AXI_DMA_DWIDTH/8)-1){1'b0}}, 1'b1};
                                end
                            else
                                begin
                                    // Byte lane 1
                                    WDATAReg_d   = {{(AXI_DMA_DWIDTH-16){1'b0}}, configRegByte2, {8{1'b0}}};
                                    WSTRBReg_d   = {{((AXI_DMA_DWIDTH/8)-2){1'b0}}, 1'b1, 1'b0};
                                end
                            WVALIDReg_d  = 1'b1;
                            WLASTReg_d   = 1'b1;
                            nextStateWr  = WR_DATA_CLR_VALID;
                        //end
                    //else
                    //    begin
                    //        AWVALIDReg_d = 1'b1;
                    //        nextStateWr  = WR_WAIT_ADDR_ACK_CLR_VALID;
                    //    end
                end
            WR_DATA_CLR_VALID:
                begin
					if(AXI4_STREAM_IF)
						WDATAReg_d   = {{(AXI_DMA_DWIDTH-4){1'b0}}, 1'b1, 1'b0, clrStrDscrptrDstOp[1:0]};
					else
						WDATAReg_d   = {{(AXI_DMA_DWIDTH-16){1'b0}}, configRegByte2, {8{1'b0}}};
						
						
                    if (WVALID & WREADY)
                        begin
                            WSTRBReg_d  = {(AXI_DMA_DWIDTH/8){1'b0}};
                            //WDATAReg_d  = {AXI_DMA_DWIDTH{1'b0}};
                            WLASTReg_d  = 1'b0;
                            BREADYReg_d = 1'b1;
                            nextStateWr = WR_RESP_CLR_VALID;
                        end
                    else
                        begin
                            WVALIDReg_d = 1'b1;
                            nextStateWr = WR_DATA_CLR_VALID;
                        end
                end
            WR_RESP_CLR_VALID:
                begin
                    if (BVALID & BREADY)
                        begin
                            if ((AXI4_STREAM_IF == 1) && (dstStrDscrptrReg == 1'b1))
                                begin
                                    dstStrDscrptrReg_d        = 1'b0;
                                    clrStrDscrptrDataValidAck = 1'b1;
                                end
                            else
                                begin
                                    extFetchValidWr = 1'b1;
                                end
                            nextStateWr     = WR_IDLE;
                        end
                    else
                        begin
                            BREADYReg_d = 1'b1;
                            nextStateWr = WR_RESP_CLR_VALID;
                        end
                end
            WR_STR_CALC_BYTES_IN_WRITE:
                begin
                    if (dstNumOfBytesInRdReg < ((AWLENReg+1) << AXI_SIZE))
                        begin
                            numOfBytesInWr_AXI4MasterCtrlReg_d = ((ARLENReg << AXI_SIZE)+(dstNumOfBytesInRdReg[AXI_SIZE-1:0]));
                        end
                    else
                        begin
                            numOfBytesInWr_AXI4MasterCtrlReg_d = ((AWLENReg+1) << AXI_SIZE);
                        end
                    nextStateWr = WR_STR_WAIT_BYTES_IN_CACHE;
                end
            WR_STR_WAIT_BYTES_IN_CACHE:
                begin
                    if (numBytesInStrCache >= numOfBytesInWr_AXI4MasterCtrlReg)
                        begin
							str_strt_ctrl = 1'b1;
                            AWVALIDReg_d = 1'b1;
                            AWADDRReg_d  = dstAXIStrtAddrReg;
                            AWSIZEReg_d  = AXI_SIZE;
                            AWLENReg_d   = beatsInWrBurst;
                            AWBURSTReg_d = dstBurstTypeReg;
                            nextStateWr  = WAIT_WR_ADDR_ACK;
                        end
                    else
                        begin
                            nextStateWr = WR_STR_WAIT_BYTES_IN_CACHE;
                        end
                end
            default:
                begin
                    nextStateWr = WR_IDLE;
                end
        endcase
    end

////////////////////////////////////////////////////////////////////////////////
// beatsInWrBurst register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                beatsInWrBurst <= 8'b0;
            end
        else
            begin
                beatsInWrBurst <= beatsInWrBurst_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// dstBurstType register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                dstBurstTypeReg <= 2'b0;
            end
        else
            begin
                dstBurstTypeReg <= dstBurstTypeReg_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// dstAXIStrtAddr register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                dstAXIStrtAddrReg <= 32'b0;
            end
        else
            begin
                dstAXIStrtAddrReg <= dstAXIStrtAddrReg_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// dstNumOfBytesInRd register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                dstNumOfBytesInRdReg <= {MAX_TRAN_SIZE_WIDTH{1'b0}};
            end
        else
            begin
                dstNumOfBytesInRdReg <= dstNumOfBytesInRdReg_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// AWVALID register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                AWVALIDReg <= 1'b0;
            end
        else if(AWVALIDReg & AWREADY)
            begin
                AWVALIDReg <= 1'b0;
            end
        else if(AWVALIDReg_d)   
		    begin
                AWVALIDReg <= 1'b1;
            end
    end
assign AWVALID = AWVALIDReg;

////////////////////////////////////////////////////////////////////////////////
// AWADDR register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                AWADDRReg <= 32'b0;
            end
        else
            begin
                AWADDRReg <= AWADDRReg_d;
            end
    end
assign AWADDR = AWADDRReg;

////////////////////////////////////////////////////////////////////////////////
// AWSIZE register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                AWSIZEReg <= 3'b0;
            end
        else
            begin
                AWSIZEReg <= AWSIZEReg_d;
            end
    end
assign AWSIZE = AWSIZEReg;

////////////////////////////////////////////////////////////////////////////////
// AWBURST register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                AWBURSTReg <= 2'b0;
            end
        else
            begin
                AWBURSTReg <= AWBURSTReg_d;
            end
    end
assign AWBURST = AWBURSTReg;

////////////////////////////////////////////////////////////////////////////////
// AWLEN register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                AWLENReg <= 8'b0;
            end
        else
            begin
                AWLENReg <= AWLENReg_d;
            end
    end
assign AWLEN = AWLENReg;

////////////////////////////////////////////////////////////////////////////////
// AWID register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                AWIDReg <= {ID_WIDTH{1'b0}};
            end
        else
            begin
                AWIDReg <= AWIDReg_d;
            end
    end
assign AWID = AWIDReg;

////////////////////////////////////////////////////////////////////////////////
// WVALID register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                WVALIDReg <= 1'b0;
            end
        else
            begin
                WVALIDReg <= WVALIDReg_d;
            end
    end
assign WVALID = WVALIDReg_1;

////////////////////////////////////////////////////////////////////////////////
// AWVALID register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                WDATAReg <= {AXI_DMA_DWIDTH{1'b0}};
            end
        else
            begin
                WDATAReg <= WDATAReg_d;
            end
    end
assign WDATA = WDATAReg_1;

////////////////////////////////////////////////////////////////////////////////
// WLAST register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                WLASTReg <= 1'b0;
            end
        else
            begin
                WLASTReg <= WLASTReg_d;
            end
    end
assign WLAST = WLASTReg_1;

////////////////////////////////////////////////////////////////////////////////
// WSTRB register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                WSTRBReg <= {(AXI_DMA_DWIDTH/8){1'b0}};
            end
        else
            begin
                WSTRBReg <= WSTRBReg_d;
            end
    end
assign WSTRB = WSTRBReg;

////////////////////////////////////////////////////////////////////////////////
// BREADY register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                BREADYReg <= 1'b0;
            end
        else
            begin
                BREADYReg <= BREADYReg_d;
            end
    end
assign BREADY = BREADYReg;

////////////////////////////////////////////////////////////////////////////////
// rdEn register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                rdEnReg <= 1'b0;
            end
        else
            begin
                rdEnReg <= rdEnReg_d;
            end
    end
assign rdEn = rdEnReg;

////////////////////////////////////////////////////////////////////////////////
// rdNumOfBytes register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                rdNumOfBytesReg <= {TRAN_BYTE_CNT_WIDTH{1'b0}};
            end
			
		else if(WVALID & WREADY & WLAST)
		
			rdNumOfBytesReg <= (AXI_DMA_DWIDTH/8);	
        
		else	
			begin

				if ((dstNumOfBytesInRdReg[AXI_SIZE-1:0] != {AXI_SIZE{1'b0}}))
					begin
						if(((dstNumOfBytesInRdReg <= (AXI_DMA_DWIDTH/8)) & AWVALID) | (ram_rdreq_cntr == AWLEN + 1))
								// Last transfer in the transaction is narrow
							rdNumOfBytesReg <= {1'b0, dstNumOfBytesInRdReg[AXI_SIZE-1:0]};
						else if (ren_sc_d2) 
							rdNumOfBytesReg <= (AXI_DMA_DWIDTH/8);						
						
					end
				else
					begin
						// Number of bytes in transaction a multiple of 64
						rdNumOfBytesReg <= (AXI_DMA_DWIDTH/8);
					end
			end
																			
    end
assign rdNumOfBytes = rdNumOfBytesReg;

////////////////////////////////////////////////////////////////////////////////
// rdAddr register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                rdAddrReg <= 8'b0;
            end
        else
            begin
                rdAddrReg <= rdAddrReg_d;
            end
    end
assign rdAddr = rdAddr_1;

////////////////////////////////////////////////////////////////////////////////
// beatCntReg register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                beatCntReg <= 9'b0; // Extra bit as 256 beats
            end
        else
            begin
                beatCntReg <= beatCntReg_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// wrByteCnt register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                wrByteCnt <= {MAX_AXI_TRAN_SIZE_WIDTH{1'b0}};
            end
        else
            begin
                wrByteCnt <= wrByteCnt_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// dstStrDscrptr register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
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

////////////////////////////////////////////////////////////////////////////////
// strRdyToAck register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                strRdyToAckReg <= 1'b0;
            end
        else
            begin
                strRdyToAckReg <= strRdyToAckReg_d;
            end
    end
assign strRdyToAck = strRdyToAckReg;

////////////////////////////////////////////////////////////////////////////////
// numOfBytesInWr_AXI4MasterCtrl register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                numOfBytesInWr_AXI4MasterCtrlReg <= {MAX_AXI_TRAN_SIZE_WIDTH{1'b0}};
            end
        else
            begin
                numOfBytesInWr_AXI4MasterCtrlReg <= numOfBytesInWr_AXI4MasterCtrlReg_d;
            end
    end
assign numOfBytesInWr_AXI4MasterCtrl = numOfBytesInWr_AXI4MasterCtrlReg;


always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
                Err_RESP_hold <= 1'b0;
        else if (RVALID & RREADY & RRESP[1])
                Err_RESP_hold <= 1'b1;
        else if (RVALID & RREADY & RLAST)		
                Err_RESP_hold <= 1'b0;	
    end

////////////////////////////////////////////////////////////////////////////////
// Read controlFSM FSM
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                currStateRd <= RD_IDLE;
            end
        else
            begin
                currStateRd <= nextStateRd;
            end
    end

always @(*)
    begin
        // Default assignments
        ARVALIDReg_d                  <= 1'b0;
        ARADDRReg_d                   <= ARADDRReg;
        ARIDReg_d                     <= {ID_WIDTH{1'b0}};
        ARLENReg_d                    <= ARLENReg;
        ARSIZEReg_d                   <= ARSIZEReg;
        ARBURSTReg_d                  <= ARBURSTReg;
        RREADYReg_d                   <= 1'b0;
        wrEnReg_d                     <= 1'b0;
        wrAddrReg_d                   <= wrAddrReg;
        wrNumOfBytesReg_d             <= {TRAN_BYTE_CNT_WIDTH{1'b0}};
        wrDataReg_d                   <= {AXI_DMA_DWIDTH{1'b0}};
        AXI4RdTransDone               <= 1'b0;
        AXI4RdTransError              <= 1'b0; // Unused
        numOfBytesInRd                <= {MAX_AXI_TRAN_SIZE_WIDTH{1'b0}}; // combinatorial
        numOfBytesInRdValid           <= 1'b0; // combinatorial
        beatsInRdBurst_d              <= beatsInRdBurst;
        srcNumOfBytesReg_d            <= srcNumOfBytesReg;
        extFetchValidRd               <= 1'b0;
        dscrptrData_AXI4MasterCtrl_d  <= dscrptrData_AXI4MasterCtrl;
        dscrptrValid_AXI4MasterCtrl_d <= dscrptrValid_AXI4MasterCtrl;
        dataValid_AXI4MasterCtrl_d    <= dataValid_AXI4MasterCtrl;
        rdBeatCntReg_d                <= rdBeatCntReg;
        strFetchAck_AXI4MasterCtrl_d  <= 1'b0;
        strDataValid_AXIMasterCtrl_d  <= 1'b0;
        case (currStateRd)
            RD_IDLE:
                begin
                    if (strtAXIRdTran)
                        begin
                            ARVALIDReg_d <= 1'b1;
                            ARADDRReg_d  <= srcAXIStrtAddr;
                            ARSIZEReg_d  <= AXI_SIZE;
                            if (srcAXITranType == 2'b10)
                                begin
                                    ARBURSTReg_d <= 2'b00;
                                end
                            else
                                begin
                                    ARBURSTReg_d <= 2'b01;
                                end
                            // Allow for a narrow transfer in the last beat of the burst
                            if ((srcNumOfBytes >= (1+(srcMaxAXINumBeats << AXI_SIZE))) && (srcAXIStrtAddr[11:0] <= 13'd4096-((1+srcMaxAXINumBeats) << AXI_SIZE)))
                                begin
                                    ARLENReg_d       <= srcMaxAXINumBeats;
                                    beatsInRdBurst_d <= srcMaxAXINumBeats;
                                end
                            else if ((srcNumOfBytes >= (1+(127 * (AXI_DMA_DWIDTH/8)))) && (srcAXIStrtAddr[11:0] <= 13'd4096-(128 * (AXI_DMA_DWIDTH/8))))
                                begin
                                    ARLENReg_d       <= 8'd127;
                                    beatsInRdBurst_d <= 8'd127;
                                end
                            else if ((srcNumOfBytes >= (1+(63 * (AXI_DMA_DWIDTH/8)))) && (srcAXIStrtAddr[11:0] <= 13'd4096-(64 * (AXI_DMA_DWIDTH/8))))
                                begin
                                    ARLENReg_d       <= 8'd63;
                                    beatsInRdBurst_d <= 8'd63;
                                end
                            else if ((srcNumOfBytes >= (1+(31 * (AXI_DMA_DWIDTH/8)))) && (srcAXIStrtAddr[11:0] <= 13'd4096-(32 * (AXI_DMA_DWIDTH/8))))
                                begin
                                    ARLENReg_d       <= 8'd31;
                                    beatsInRdBurst_d <= 8'd31;
                                end
                            else if ((srcNumOfBytes >= (1+(15 * (AXI_DMA_DWIDTH/8)))) && (srcAXIStrtAddr[11:0] <= 13'd4096-(16 * (AXI_DMA_DWIDTH/8))))
                                begin
                                    ARLENReg_d       <= 8'd15;
                                    beatsInRdBurst_d <= 8'd15;
                                end
                            else if ((srcNumOfBytes >= (1+(7 * (AXI_DMA_DWIDTH/8))))  && (srcAXIStrtAddr[11:0] <= 13'd4096-(8 * (AXI_DMA_DWIDTH/8))))
                                begin
                                    ARLENReg_d       <= 8'd7;
                                    beatsInRdBurst_d <= 8'd7;
                                end
                            else if ((srcNumOfBytes >= (1+(3 * (AXI_DMA_DWIDTH/8))))  && (srcAXIStrtAddr[11:0] <= 13'd4096-(4 * (AXI_DMA_DWIDTH/8))))
                                begin
                                    ARLENReg_d       <= 8'd3;
                                    beatsInRdBurst_d <= 8'd3;
                                end
                            else
                                begin
                                    ARLENReg_d       <= 8'd0;
                                    beatsInRdBurst_d <= 8'd0;
                                end
                            srcNumOfBytesReg_d  <= srcNumOfBytes;
                            nextStateRd         <= WAIT_RD_ADDR_ACK;
                        end
                    else if (strtExtDscrptrRd)
                        begin
                            ARVALIDReg_d <= 1'b1;
                            ARADDRReg_d  <= strtAddr_extDscrptrFetch;
                            ARSIZEReg_d  <= AXI_SIZE;
                            ARBURSTReg_d <= 2'b01;
                            nextStateRd  <= RD_WAIT_ADDR_EXT_FETCH;
                            // Determine the number of beats required based on the bus width
                            // as descriptors comprise of 20 bytes 
                            if (AXI_DMA_DWIDTH == 32)
                                begin
                                    ARLENReg_d <= 8'd4;
                                end
                            else if (AXI_DMA_DWIDTH == 64)
                                begin
                                    ARLENReg_d <= 8'd2; 
                                end
                            else if (AXI_DMA_DWIDTH == 128)
                                begin
                                    ARLENReg_d <= 8'd1;
                                end
                            else // 256 or 512
                                begin
                                    ARLENReg_d <= 8'd0;
                                end
                        end
                    else if ((AXI4_STREAM_IF == 1) && (strtStrDscrptrRd))
                        begin
                            ARVALIDReg_d <= 1'b1;
                            ARADDRReg_d  <= strtAddr_extDscrptrFetch;
                            ARSIZEReg_d  <= AXI_SIZE;
                            ARBURSTReg_d <= 2'b01;
                            nextStateRd  <= RD_WAIT_ADDR_STR_FETCH;
                            // Determine the number of beats required based on the bus width
                            // as descriptors comprise of 9 bytes 
                            if (AXI_DMA_DWIDTH == 32)
                                begin
                                    ARLENReg_d <= 8'd2;
                                end
                            else if (AXI_DMA_DWIDTH == 64)
                                begin
                                    ARLENReg_d <= 8'd1; 
                                end
                            else // 128, 256 & 512
                                begin
                                    ARLENReg_d <= 8'd0;
                                end
                        end
                    else if (strtExtDscrptrRdyCheck)
                        begin
                            ARVALIDReg_d <= 1'b1;
                            ARADDRReg_d  <= strtAddr_extDscrptrFetch;
                            ARLENReg_d   <= 8'd0; // 1-beat
                            ARSIZEReg_d  <= AXI_SIZE;
                            ARBURSTReg_d <= 2'b01;
                            nextStateRd  <= RD_WAIT_ADDR_EXT_RDY_CHECK;
                        end
                    else if ((AXI4_STREAM_IF == 1) && (strFetchRdy == 1'b1))
                        begin
                            // The data ready flow control in the stream descriptor
                            // wasn't set when first fetched. Re-fetch it from
                            // the external stream descriptor
                            ARVALIDReg_d <= 1'b1;
                            ARADDRReg_d  <= strFetchAddr;
                            ARLENReg_d   <= 8'd0; // 1-beat
                            ARSIZEReg_d  <= AXI_SIZE;
                            ARBURSTReg_d <= 2'b01;
                            nextStateRd  <= RD_WAIT_ADDR_STR_RDY_CHECK;
                        end
                    else
                        begin
                            nextStateRd <= RD_IDLE;
                        end
                end
            WAIT_RD_ADDR_ACK:
                begin
                    if (ARVALID & ARREADY)
                        begin
                            ARADDRReg_d   <= 32'b0;
                            ARLENReg_d    <= 8'b0;
                            ARSIZEReg_d   <= 3'b0;
                            ARBURSTReg_d  <= 2'b0;
                            RREADYReg_d   <= 1'b1;
                            nextStateRd   <= RD_DATA_RX_FIRST;
                            if (srcNumOfBytesReg < ((ARLENReg+1) << AXI_SIZE))
                                begin
                                    numOfBytesInRd <= ((ARLENReg << AXI_SIZE)+(srcNumOfBytesReg[AXI_SIZE-1:0]));
                                end
                            else
                                begin
                                    numOfBytesInRd <= ((ARLENReg+1) << AXI_SIZE);
                                end
                            numOfBytesInRdValid <= 1'b1;
                        end
                    else
                        begin
                            ARVALIDReg_d <= 1'b1;
                            nextStateRd  <= WAIT_RD_ADDR_ACK;
                        end
                end
            RD_DATA_RX_FIRST:
                begin
                    if (RVALID & RREADY)
                        begin
                            wrEnReg_d   <= 1'b1;
                            wrDataReg_d <= RDATA;
                            if (RLAST)
                                begin
									AXI4RdTransError <= RRESP[1];
                                    if (srcNumOfBytesReg < ((beatsInRdBurst+1) << AXI_SIZE))
                                        begin
                                            // This is not the last beat of the entire
                                            // descriptor operation so it can't be
                                            // narrow
                                            wrNumOfBytesReg_d <= {1'b0, srcNumOfBytesReg[AXI_SIZE-1:0]};
                                        end
                                    else
                                        begin
                                            wrNumOfBytesReg_d <= (AXI_DMA_DWIDTH/8);
                                        end
                                    nextStateRd <= RD_RX_DONE;
                                end
                            else
                                begin
                                    RREADYReg_d       <= 1'b1;
                                    wrNumOfBytesReg_d <= (AXI_DMA_DWIDTH/8);
                                    nextStateRd       <= RD_DATA_RX;
                                end
                        end
                    else
                        begin
                            RREADYReg_d <= 1'b1;
                            nextStateRd <= RD_DATA_RX_FIRST;
                        end
                end
            RD_DATA_RX:
                begin
                    if (RVALID & RREADY)
                        begin
                            wrEnReg_d   <= 1'b1;
                            wrDataReg_d <= RDATA;
                            wrAddrReg_d <= wrAddrReg + 1'b1;
                            if (RLAST)							
                                begin
									if (RRESP[1] | Err_RESP_hold)
										AXI4RdTransError <= 1'b1;
									else
										AXI4RdTransError <= 1'b0;
                                    if (srcNumOfBytesReg < ((beatsInRdBurst+1) << AXI_SIZE))
                                        begin
                                            // This is not the last beat of the entire
                                            // descriptor operation so it can't be
                                            // narrow
                                            wrNumOfBytesReg_d <= {1'b0, srcNumOfBytesReg[AXI_SIZE-1:0]};
                                        end
                                    else
                                        begin
                                            wrNumOfBytesReg_d <= (AXI_DMA_DWIDTH/8);
                                        end
                                    nextStateRd <= RD_RX_DONE;
                                end
                            else
                                begin
                                    RREADYReg_d       <= 1'b1;
                                    wrNumOfBytesReg_d <= (AXI_DMA_DWIDTH/8);
                                    nextStateRd       <= RD_DATA_RX;
                                end
                        end
                    else
                        begin
                            RREADYReg_d <= 1'b1;
                            nextStateRd <= RD_DATA_RX;
                        end
                end
            RD_RX_DONE:
                begin
                    wrAddrReg_d     <= 8'b0;
                    AXI4RdTransDone <= 1'b1;
                    nextStateRd     <= RD_IDLE;
                end
            RD_WAIT_ADDR_EXT_FETCH:
                begin
                    if (ARVALID & ARREADY)
                        begin
                            ARADDRReg_d   <= 32'b0;
                            ARLENReg_d    <= 8'b0;
                            ARSIZEReg_d   <= 3'b0;
                            ARBURSTReg_d  <= 2'b0;
                            RREADYReg_d   <= 1'b1;
                            nextStateRd   <= RD_DATA_EXT_FETCH;
                        end
                    else
                        begin
                            ARVALIDReg_d <= 1'b1;
                            nextStateRd  <= RD_WAIT_ADDR_EXT_FETCH;
                        end
                end
            RD_DATA_EXT_FETCH:
                begin
                    if (RVALID & RREADY)
                        begin
                            if (RLAST)
                                begin
									if (RRESP[1] | Err_RESP_hold)
										AXI4RdTransError <= 1'b1;
									else
										AXI4RdTransError <= 1'b0;								
                                    rdBeatCntReg_d    <= 2'b0;
                                    extFetchValidRd   <= 1'b1;
                                    nextStateRd       <= RD_IDLE;
                                    if ((AXI_DMA_DWIDTH == 256) || (AXI_DMA_DWIDTH == 512))
                                        begin
                                            dscrptrData_AXI4MasterCtrl_d[133:0] <= {RDATA[159:64], RDATA[55:32], RDATA[13:0]};
                                            dataValid_AXI4MasterCtrl_d          <= {RDATA[14], RDATA[13]};
                                            dscrptrValid_AXI4MasterCtrl_d       <= RDATA[15];
                                        end
                                    else
                                        begin
                                            dscrptrData_AXI4MasterCtrl_d[133:102] <= RDATA[31:0];
                                            dscrptrData_AXI4MasterCtrl_d[101:0]   <= dscrptrData_AXI4MasterCtrl[101:0];
                                        end
                                end
                            else
                                begin
                                    rdBeatCntReg_d <= rdBeatCntReg + 1'b1;
                                    RREADYReg_d    <= 1'b1;
                                    nextStateRd    <= RD_DATA_EXT_FETCH;
                                    if (AXI_DMA_DWIDTH == 64)
                                        begin
                                            if (rdBeatCntReg == 2'd1)
                                                begin
                                                    // 2nd beat
                                                    dscrptrData_AXI4MasterCtrl_d[133:102] <= dscrptrData_AXI4MasterCtrl[133:102];
                                                    dscrptrData_AXI4MasterCtrl_d[101:38]  <= RDATA[63:0];
                                                    dscrptrData_AXI4MasterCtrl_d[37:0]    <= dscrptrData_AXI4MasterCtrl[37:0];
                                                end
                                            else
                                                begin
                                                    // 1st beat
                                                    dscrptrData_AXI4MasterCtrl_d[133:38] <= dscrptrData_AXI4MasterCtrl[133:38];
                                                    dscrptrData_AXI4MasterCtrl_d[37:0]   <= {RDATA[55:32], RDATA[13:0]};
                                                    dataValid_AXI4MasterCtrl_d           <= {RDATA[14], RDATA[13]};
                                                    dscrptrValid_AXI4MasterCtrl_d        <= RDATA[15];
                                                end 
                                        end
                                    else if (AXI_DMA_DWIDTH == 128)
                                        begin
                                            dscrptrData_AXI4MasterCtrl_d[133:102] <= dscrptrData_AXI4MasterCtrl[133:102];
                                            dscrptrData_AXI4MasterCtrl_d[101:0]   <= {RDATA[127:64], RDATA[55:32], RDATA[13:0]};
                                            dataValid_AXI4MasterCtrl_d            <= {RDATA[14], RDATA[13]};
                                            dscrptrValid_AXI4MasterCtrl_d         <= RDATA[15];
                                        end
                                    else // 32-bit
                                        begin
                                             if (rdBeatCntReg == 2'd1)
                                                begin
                                                    // 2nd beat
                                                    dscrptrData_AXI4MasterCtrl_d[133:38] <= dscrptrData_AXI4MasterCtrl[133:38];
                                                    dscrptrData_AXI4MasterCtrl_d[37:14]  <= RDATA[23:0];
                                                    dscrptrData_AXI4MasterCtrl_d[13:0]   <= dscrptrData_AXI4MasterCtrl[13:0];
                                                end
                                             else if (rdBeatCntReg == 2'd2)
                                                begin
                                                    // 3rd beat
                                                    dscrptrData_AXI4MasterCtrl_d[133:70] <= dscrptrData_AXI4MasterCtrl[133:70];
                                                    dscrptrData_AXI4MasterCtrl_d[69:38]  <= RDATA[31:0];
                                                    dscrptrData_AXI4MasterCtrl_d[37:0]   <= dscrptrData_AXI4MasterCtrl[37:0];
                                                end
                                             else if (rdBeatCntReg == 2'd3)
                                                begin
                                                    // 4th beat
                                                    dscrptrData_AXI4MasterCtrl_d[133:102] <= dscrptrData_AXI4MasterCtrl[133:102];
                                                    dscrptrData_AXI4MasterCtrl_d[101:70]  <= RDATA[31:0];
                                                    dscrptrData_AXI4MasterCtrl_d[69:0]    <= dscrptrData_AXI4MasterCtrl[69:0];
                                                end
                                             else
                                                begin
                                                    // 1st beat
                                                    dscrptrData_AXI4MasterCtrl_d[133:14]  <= dscrptrData_AXI4MasterCtrl[133:14];
                                                    dscrptrData_AXI4MasterCtrl_d[13:0]    <= RDATA[13:0];
                                                    dataValid_AXI4MasterCtrl_d            <= {RDATA[14], RDATA[13]};
                                                    dscrptrValid_AXI4MasterCtrl_d         <= RDATA[15];
                                                end
                                        end
                                end
                        end
                    else
                        begin
                            RREADYReg_d <= 1'b1;
                            nextStateRd <= RD_DATA_EXT_FETCH;
                        end
                end
            RD_WAIT_ADDR_EXT_RDY_CHECK:
                begin
                    if (ARVALID & ARREADY)
                        begin
                            ARADDRReg_d   <= 32'b0;
                            ARLENReg_d    <= 8'b0;
                            ARSIZEReg_d   <= 3'b0;
                            ARBURSTReg_d  <= 2'b0;
                            RREADYReg_d   <= 1'b1;
                            nextStateRd   <= RD_DATA_RDY_CHECK;
                        end
                    else
                        begin
                            ARVALIDReg_d <= 1'b1;
                            nextStateRd  <= RD_WAIT_ADDR_EXT_RDY_CHECK;
                        end
                end
            RD_DATA_RDY_CHECK:
                begin
                    if (RVALID & RREADY & RLAST)
                        begin
							AXI4RdTransError 		   <= RRESP[1];
                            extFetchValidRd            <= 1'b1;
                            dataValid_AXI4MasterCtrl_d <= {RDATA[14], RDATA[13]};
                            nextStateRd                <= RD_IDLE;
                        end
                    else
                        begin
                            RREADYReg_d <= 1'b1;
                            nextStateRd <= RD_DATA_RDY_CHECK;
                        end
                end
            RD_WAIT_ADDR_STR_RDY_CHECK:
                begin
                    if (ARVALID & ARREADY)
                        begin
                            ARADDRReg_d   <= 32'b0;
                            ARLENReg_d    <= 8'b0;
                            ARSIZEReg_d   <= 3'b0;
                            ARBURSTReg_d  <= 2'b0;
                            RREADYReg_d   <= 1'b1;
                            nextStateRd   <= RD_DATA_STR_RDY_CHECK;
                        end
                    else
                        begin
                            ARVALIDReg_d <= 1'b1;
                            nextStateRd  <= RD_WAIT_ADDR_STR_RDY_CHECK;
                        end
                end
            RD_DATA_STR_RDY_CHECK:
                begin
                    if (RVALID & RREADY & RLAST)
                        begin
							AXI4RdTransError 			 <= RRESP[1];
                            strDataValid_AXIMasterCtrl_d <= RDATA[2];
                            strFetchAck_AXI4MasterCtrl_d <= 1'b1;
                            nextStateRd                  <= RD_IDLE;
                        end
                    else
                        begin
                            RREADYReg_d <= 1'b1;
                            nextStateRd <= RD_DATA_STR_RDY_CHECK;
                        end
                end
            RD_WAIT_ADDR_STR_FETCH:
                begin
                    if (ARVALID & ARREADY)
                        begin
                            ARADDRReg_d   <= 32'b0;
                            ARLENReg_d    <= 8'b0;
                            ARSIZEReg_d   <= 3'b0;
                            ARBURSTReg_d  <= 2'b0;
                            RREADYReg_d   <= 1'b1;
                            nextStateRd   <= RD_DATA_STR_FETCH;
                        end
                    else
                        begin
                            ARVALIDReg_d <= 1'b1;
                            nextStateRd  <= RD_WAIT_ADDR_STR_FETCH;
                        end
                end
RD_DATA_STR_FETCH:
                begin
                    if (RVALID & RREADY)
                        begin
                            if (RLAST)
                                begin
									if (RRESP[1] | Err_RESP_hold)
										AXI4RdTransError <= 1'b1;
									else
										AXI4RdTransError <= 1'b0;
										
                                    rdBeatCntReg_d    <= 2'b0;
                                    extFetchValidRd   <= 1'b1;
                                    nextStateRd       <= RD_IDLE;
                                    if ((AXI_DMA_DWIDTH == 128) || (AXI_DMA_DWIDTH == 256) || (AXI_DMA_DWIDTH == 512))
                                        begin
                                            dscrptrData_AXI4MasterCtrl_d[133:58] <= {76{1'b0}};
                                            dscrptrData_AXI4MasterCtrl_d[57:26]  <= RDATA[95:64];
                                            dscrptrData_AXI4MasterCtrl_d[25:2]   <= RDATA[55:32];
                                            dscrptrData_AXI4MasterCtrl_d[1:0]    <= RDATA[1:0];
                                            dataValid_AXI4MasterCtrl_d           <= {1'b0, RDATA[2]};
                                            dscrptrValid_AXI4MasterCtrl_d        <= RDATA[3];
                                        end
                                    else
                                        begin
                                            dscrptrData_AXI4MasterCtrl_d[133:58] <= {76{1'b0}};
                                            dscrptrData_AXI4MasterCtrl_d[57:26]  <= RDATA[31:0];
                                            dscrptrData_AXI4MasterCtrl_d[25:0]   <= dscrptrData_AXI4MasterCtrl[25:0];
                                        end
                                end
                            else
                                begin
                                    rdBeatCntReg_d <= rdBeatCntReg + 1'b1;
                                    RREADYReg_d    <= 1'b1;
                                    nextStateRd    <= RD_DATA_STR_FETCH;
                                    if (AXI_DMA_DWIDTH == 64)
                                        begin
                                            dscrptrData_AXI4MasterCtrl_d[133:26] <= {108{1'b0}};
                                            dscrptrData_AXI4MasterCtrl_d[25:0]   <= {RDATA[55:32], RDATA[1:0]};
                                            dataValid_AXI4MasterCtrl_d           <= {1'b0, RDATA[2]};
                                            dscrptrValid_AXI4MasterCtrl_d        <= RDATA[3];
                                        end
                                    else // 32-bit
                                        begin
                                             if (rdBeatCntReg == 2'd1)
                                                begin
                                                    // 2nd beat
                                                    dscrptrData_AXI4MasterCtrl_d[133:26] <= dscrptrData_AXI4MasterCtrl[133:26];
                                                    dscrptrData_AXI4MasterCtrl_d[25:2]   <= RDATA[23:0];
                                                    dscrptrData_AXI4MasterCtrl_d[1:0]    <= dscrptrData_AXI4MasterCtrl[1:0];
                                                end
                                             else
                                                begin
                                                    // 1st beat
                                                    dscrptrData_AXI4MasterCtrl_d[133:2] <= {132{1'b0}};
                                                    dscrptrData_AXI4MasterCtrl_d[1:0]   <= RDATA[1:0];
                                                    dataValid_AXI4MasterCtrl_d          <= {1'b0, RDATA[2]};
                                                    dscrptrValid_AXI4MasterCtrl_d       <= RDATA[3];
                                                end
                                        end
                                end
                        end
                    else
                        begin
                            RREADYReg_d <= 1'b1;
                            nextStateRd <= RD_DATA_STR_FETCH;
                        end
                end
            default:
                begin
                    nextStateRd <= RD_IDLE;
                end
        endcase
    end

////////////////////////////////////////////////////////////////////////////////
// srcNumOfBytes register
////////////////////////////////////////////////////////////////////////////////
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

////////////////////////////////////////////////////////////////////////////////
// beatsInRdBurst register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                beatsInRdBurst <= 8'b0;
            end
        else
            begin
                beatsInRdBurst <= beatsInRdBurst_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// ARVALID register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                ARVALIDReg <= 1'b0;
            end
        else
            begin
                ARVALIDReg <= ARVALIDReg_d;
            end
    end
assign ARVALID = ARVALIDReg;

////////////////////////////////////////////////////////////////////////////////
// ARADDR register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                ARADDRReg <= 32'b0;
            end
        else
            begin
                ARADDRReg <= ARADDRReg_d;
            end
    end
assign ARADDR = ARADDRReg;

////////////////////////////////////////////////////////////////////////////////
// ARSIZE register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                ARSIZEReg <= 3'b0;
            end
        else
            begin
                ARSIZEReg <= ARSIZEReg_d;
            end
    end
assign ARSIZE = ARSIZEReg;

////////////////////////////////////////////////////////////////////////////////
// ARBURST register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                ARBURSTReg <= 2'b0;
            end
        else
            begin
                ARBURSTReg <= ARBURSTReg_d;
            end
    end
assign ARBURST = ARBURSTReg;

////////////////////////////////////////////////////////////////////////////////
// ARIDReg register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                ARIDReg <= {ID_WIDTH{1'b0}};
            end
        else
            begin
                ARIDReg <= ARIDReg_d;
            end
    end
assign ARID = ARIDReg;

////////////////////////////////////////////////////////////////////////////////
// ARLEN register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                ARLENReg <= 8'b0;
            end
        else
            begin
                ARLENReg <= ARLENReg_d;
            end
    end
assign ARLEN = ARLENReg;

////////////////////////////////////////////////////////////////////////////////
// RREADY register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                RREADYReg <= 1'b0;
            end
        else
            begin
                RREADYReg <= RREADYReg_d;
            end
    end
assign RREADY = RREADYReg;

////////////////////////////////////////////////////////////////////////////////
// wrAddrReg register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                wrAddrReg <= 8'b0;
            end
        else
            begin
                wrAddrReg <= wrAddrReg_d;
            end
    end
assign wrAddr = wrAddrReg;

////////////////////////////////////////////////////////////////////////////////
// dscrptrData_AXI4MasterCtrl register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                dscrptrData_AXI4MasterCtrl <= {DSCRPTR_DATA_WIDTH{1'b0}};
            end
        else
            begin
                dscrptrData_AXI4MasterCtrl <= dscrptrData_AXI4MasterCtrl_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// dscrptrValid_AXI4MasterCtrl register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                dscrptrValid_AXI4MasterCtrl <= 1'b0;
            end
        else
            begin
                dscrptrValid_AXI4MasterCtrl <= dscrptrValid_AXI4MasterCtrl_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// extFetchValid_AXI4MasterCtrl register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                extFetchValid_AXI4MasterCtrl <= 1'b0;
            end
        else
            begin
                extFetchValid_AXI4MasterCtrl <= extFetchValidWr | extFetchValidRd;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// dataValid_AXI4MasterCtrl register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                dataValid_AXI4MasterCtrl <= 2'b0;
            end
        else
            begin
                dataValid_AXI4MasterCtrl <= dataValid_AXI4MasterCtrl_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// wrEn register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                wrEnReg <= 1'b0;
            end
        else
            begin
                wrEnReg <= wrEnReg_d;
            end
    end
assign wrEn = wrEnReg;

////////////////////////////////////////////////////////////////////////////////
// wrData register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                wrDataReg <= {AXI_DMA_DWIDTH{1'b0}};
            end
        else
            begin
                wrDataReg <= wrDataReg_d;
            end
    end
assign wrData = wrDataReg;

////////////////////////////////////////////////////////////////////////////////
// wrNumOfBytes register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                wrNumOfBytesReg <= {TRAN_BYTE_CNT_WIDTH{1'b0}};
            end
        else
            begin
                wrNumOfBytesReg <= wrNumOfBytesReg_d;
            end
    end
assign wrNumOfBytes = wrNumOfBytesReg;

////////////////////////////////////////////////////////////////////////////////
// rdBeatCnt register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                rdBeatCntReg <= 2'b0;
            end
        else
            begin
                rdBeatCntReg <= rdBeatCntReg_d;
            end
    end
assign wrNumOfBytes = wrNumOfBytesReg;


////////////////////////////////////////////////////////////////////////////////
// strFetchAck_AXI4MasterCtrl register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                strFetchAck_AXI4MasterCtrl <= 1'b0;
            end
        else
            begin
                strFetchAck_AXI4MasterCtrl <= strFetchAck_AXI4MasterCtrl_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// strDataValid_AXIMasterCtrl register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                strDataValid_AXIMasterCtrl <= 1'b0;
            end
        else
            begin
                strDataValid_AXIMasterCtrl <= strDataValid_AXIMasterCtrl_d;
            end
    end

endmodule // AXI4MasterDMACtrl