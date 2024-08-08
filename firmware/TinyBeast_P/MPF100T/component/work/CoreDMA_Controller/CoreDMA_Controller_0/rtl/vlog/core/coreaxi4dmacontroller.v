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
module CoreDMA_Controller_CoreDMA_Controller_0_COREAXI4DMACONTROLLER(
    CLOCK,
    RESETN,
    
    // AXI4LiteMaster inputs
    CTRL_AWVALID,
    CTRL_WVALID,
    CTRL_BREADY,
    CTRL_ARVALID,
    CTRL_RREADY,
    CTRL_AWADDR,
    CTRL_WSTRB,
    CTRL_WDATA,
    CTRL_ARADDR,

    // FabricController inputs
    STRTDMAOP,
    
    // AXI4Slave inputs
    DMA_BRESP,
    DMA_BID,
    DMA_RDATA,
    DMA_RID,
    DMA_AWREADY,
    DMA_WREADY,
    DMA_BVALID,
    DMA_ARREADY,
    DMA_RVALID,
    DMA_RRESP,
    DMA_RLAST,
    
    // AXI4-Stream inputs
    TVALID,
    TDATA,
    TSTRB,
    TKEEP,
    TLAST,
    TID,
    TDEST,
    
    // AXI4LiteMaster outputs
    CTRL_BRESP,
    CTRL_RDATA,
    CTRL_AWREADY,
    CTRL_WREADY,
    CTRL_BVALID,
    CTRL_ARREADY,
    CTRL_RVALID,
    CTRL_RRESP,

    // AXI4Slave outputs
    DMA_AWVALID,
    DMA_WVALID,
    DMA_WLAST,
    DMA_BREADY,
    DMA_ARVALID,
    DMA_RREADY,
    DMA_AWADDR,
    DMA_AWID,
    DMA_AWLEN,
    DMA_AWSIZE,
    DMA_AWBURST,
    DMA_WSTRB,
    DMA_WDATA,
    DMA_ARADDR,
    DMA_ARID,
    DMA_ARLEN,
    DMA_ARSIZE,
    DMA_ARBURST,
    
    // AXI4Stream outputs
    TREADY,
    
    // MasterController outputs
    INTERRUPT
);

////////////////////////////////////////////////////////////////////////////////
// Parameters
////////////////////////////////////////////////////////////////////////////////
parameter AXI4_STREAM_IF       = 0;  // Enable/disable AXI4-Stream to memory mapped AXI4 slave bridge
parameter AXI_DMA_DWIDTH       = 64; // 32, 64, 128, 256, 512 supported
                                      // Range
parameter NUM_PRI_LVLS         = 1;   // 1->8
parameter PRI_0_NUM_OF_BEATS   = 256; // 1->256
parameter PRI_1_NUM_OF_BEATS   = 128; // 1->256
parameter PRI_2_NUM_OF_BEATS   = 64;  // 1->256
parameter PRI_3_NUM_OF_BEATS   = 32;  // 1->256
parameter PRI_4_NUM_OF_BEATS   = 16;  // 1->256
parameter PRI_5_NUM_OF_BEATS   = 8;   // 1->256
parameter PRI_6_NUM_OF_BEATS   = 4;   // 1->256
parameter PRI_7_NUM_OF_BEATS   = 1;   // 1->256
parameter NUM_OF_INTS          = 4;   // 1->4
parameter INT_0_QUEUE_DEPTH    = 1;   // 1->8
parameter INT_1_QUEUE_DEPTH    = 1;   // 1->8
parameter INT_2_QUEUE_DEPTH    = 1;   // 1->8
parameter INT_3_QUEUE_DEPTH    = 1;   // 1->8
parameter NUM_INT_BDS          = 4;   // 4->32
parameter DSCRPTR_0_INT_ASSOC  = 0; 
parameter DSCRPTR_0_PRI_LVL    = 1;
parameter DSCRPTR_1_INT_ASSOC  = 0; 
parameter DSCRPTR_1_PRI_LVL    = 1;
parameter DSCRPTR_2_INT_ASSOC  = 0;
parameter DSCRPTR_2_PRI_LVL    = 1;
parameter DSCRPTR_3_INT_ASSOC  = 0;
parameter DSCRPTR_3_PRI_LVL    = 1;
parameter DSCRPTR_4_INT_ASSOC  = 0; 
parameter DSCRPTR_4_PRI_LVL    = 1;
parameter DSCRPTR_5_INT_ASSOC  = 0; 
parameter DSCRPTR_5_PRI_LVL    = 1;
parameter DSCRPTR_6_INT_ASSOC  = 0;
parameter DSCRPTR_6_PRI_LVL    = 1;
parameter DSCRPTR_7_INT_ASSOC  = 0;
parameter DSCRPTR_7_PRI_LVL    = 1;
parameter DSCRPTR_8_INT_ASSOC  = 0; 
parameter DSCRPTR_8_PRI_LVL    = 1;
parameter DSCRPTR_9_INT_ASSOC  = 0; 
parameter DSCRPTR_9_PRI_LVL    = 1;
parameter DSCRPTR_10_INT_ASSOC  = 0;
parameter DSCRPTR_10_PRI_LVL    = 1;
parameter DSCRPTR_11_INT_ASSOC  = 0;
parameter DSCRPTR_11_PRI_LVL    = 1;
parameter DSCRPTR_12_INT_ASSOC  = 0; 
parameter DSCRPTR_12_PRI_LVL    = 1;
parameter DSCRPTR_13_INT_ASSOC  = 0; 
parameter DSCRPTR_13_PRI_LVL    = 1;
parameter DSCRPTR_14_INT_ASSOC  = 0;
parameter DSCRPTR_14_PRI_LVL    = 1;
parameter DSCRPTR_15_INT_ASSOC  = 0;
parameter DSCRPTR_15_PRI_LVL    = 1;
parameter DSCRPTR_16_INT_ASSOC  = 0; 
parameter DSCRPTR_16_PRI_LVL    = 1;
parameter DSCRPTR_17_INT_ASSOC  = 0; 
parameter DSCRPTR_17_PRI_LVL    = 1;
parameter DSCRPTR_18_INT_ASSOC  = 0;
parameter DSCRPTR_18_PRI_LVL    = 1;
parameter DSCRPTR_19_INT_ASSOC  = 0;
parameter DSCRPTR_19_PRI_LVL    = 1;
parameter DSCRPTR_20_INT_ASSOC  = 0; 
parameter DSCRPTR_20_PRI_LVL    = 1;
parameter DSCRPTR_21_INT_ASSOC  = 0; 
parameter DSCRPTR_21_PRI_LVL    = 1;
parameter DSCRPTR_22_INT_ASSOC  = 0;
parameter DSCRPTR_22_PRI_LVL    = 1;
parameter DSCRPTR_23_INT_ASSOC  = 0;
parameter DSCRPTR_23_PRI_LVL    = 1;
parameter DSCRPTR_24_INT_ASSOC  = 0; 
parameter DSCRPTR_24_PRI_LVL    = 1;
parameter DSCRPTR_25_INT_ASSOC  = 0; 
parameter DSCRPTR_25_PRI_LVL    = 1;
parameter DSCRPTR_26_INT_ASSOC  = 0;
parameter DSCRPTR_26_PRI_LVL    = 1;
parameter DSCRPTR_27_INT_ASSOC  = 0;
parameter DSCRPTR_27_PRI_LVL    = 1;
parameter DSCRPTR_28_INT_ASSOC  = 0; 
parameter DSCRPTR_28_PRI_LVL    = 1;
parameter DSCRPTR_29_INT_ASSOC  = 0; 
parameter DSCRPTR_29_PRI_LVL    = 1;
parameter DSCRPTR_30_INT_ASSOC  = 0;
parameter DSCRPTR_30_PRI_LVL    = 1;
parameter DSCRPTR_31_INT_ASSOC  = 0;
parameter DSCRPTR_31_PRI_LVL    = 1;
parameter ID_WIDTH              = 1; // ID field always driven out as zeros

parameter FAMILY				= 25;
parameter ECC					= 1;

////////////////////////////////////////////////////////////////////////////////
// clog2 function implementation. Returns the number of bits required to
// hold the value passed as argument.
////////////////////////////////////////////////////////////////////////////////
function integer clog2;
    input integer x;
    integer x1, tmp, res;
    begin
        tmp = 1;
        res = 0;
        x1 = x + 1;
        while (tmp < x1)
            begin 
                tmp = tmp * 2;
                res = res + 1;
            end
        clog2 = res;
    end
endfunction

////////////////////////////////////////////////////////////////////////////////
// Constants
////////////////////////////////////////////////////////////////////////////////
localparam MAJOR_VER_NUM                = 2;                            //
localparam MINOR_VER_NUM                = 0;                            // CPZ information
localparam BUILD_NUM                    = 100;                          //

localparam MAX_TRAN_SIZE                = 8388608;                      // Maximum number of bytes that can be moved in a single descriptor operation.        
localparam MAX_AXI_NUM_BEATS            = PRI_0_NUM_OF_BEATS;           // Priority zero descriptors are granted the largest timeslot on the DMA interface
localparam MAX_AXI_TRAN_SIZE            = ((MAX_AXI_NUM_BEATS * (AXI_DMA_DWIDTH/8)) <= 4096) ? (MAX_AXI_NUM_BEATS * (AXI_DMA_DWIDTH/8)) : 4096;
                                                                        // AXI4 spec states that bursts can't cross 4 KB boundaries
localparam NUM_INT_BDS_WIDTH            = clog2(NUM_INT_BDS-1);         // Width required to hold number of internal descriptors
localparam TRAN_BYTE_CNT_WIDTH          = clog2((AXI_DMA_DWIDTH/8));    // Width required to hold maximum number of bytes in a DMA beat (0->8)
localparam MAX_TRAN_SIZE_WIDTH          = clog2(MAX_TRAN_SIZE);         // Width required to hold maximum number of bytes transferred via a single descriptor
localparam MAX_AXI_TRAN_SIZE_WIDTH      = clog2(MAX_AXI_TRAN_SIZE);     // Width required to hold number of bytes in the largest AXI burst transaction
//localparam MAX_AXI_NUM_BEATS_WIDTH      = clog2(MAX_AXI_NUM_BEATS-1);   // Width required to hold the number of beats per AXI burst
localparam MAX_AXI_NUM_BEATS_WIDTH      = (MAX_AXI_NUM_BEATS == 1) ? 1 : clog2(MAX_AXI_NUM_BEATS-1);   // Width required to hold the number of beats per AXI burst

localparam DSCRPTR_DATA_WIDTH           = 134;                          // Width of buffer descriptor in bytes (including padding bytes to make fields word aligned)

localparam PRI_0_NUM_OF_BEATS_INT       = PRI_0_NUM_OF_BEATS-1;         // AXI AxLEN field counts from 0->255 rather than from 1-256
localparam PRI_1_NUM_OF_BEATS_INT       = PRI_1_NUM_OF_BEATS-1;         // AXI AxLEN field counts from 0->255 rather than from 1-256
localparam PRI_2_NUM_OF_BEATS_INT       = PRI_2_NUM_OF_BEATS-1;         // AXI AxLEN field counts from 0->255 rather than from 1-256
localparam PRI_3_NUM_OF_BEATS_INT       = PRI_3_NUM_OF_BEATS-1;         // AXI AxLEN field counts from 0->255 rather than from 1-256
localparam PRI_4_NUM_OF_BEATS_INT       = PRI_4_NUM_OF_BEATS-1;         // AXI AxLEN field counts from 0->255 rather than from 1-256
localparam PRI_5_NUM_OF_BEATS_INT       = PRI_5_NUM_OF_BEATS-1;         // AXI AxLEN field counts from 0->255 rather than from 1-256
localparam PRI_6_NUM_OF_BEATS_INT       = PRI_6_NUM_OF_BEATS-1;         // AXI AxLEN field counts from 0->255 rather than from 1-256
localparam PRI_7_NUM_OF_BEATS_INT       = PRI_7_NUM_OF_BEATS-1;         // AXI AxLEN field counts from 0->255 rather than from 1-256

localparam DATA_REALIGNMENT             = 0;                            // Data realignment support. Not implemented, leave as 0. Setting to 1 just
                                                                        // pipes [9:4] of the Descriptor X configuration register through to the AXI4MasterDMACtrl FSM 

////////////////////////////////////////////////////////////////////////////////
// Port directions
////////////////////////////////////////////////////////////////////////////////
input                               CLOCK;
input                               RESETN;

// AXI4LiteMaster inputs
input                               CTRL_AWVALID;
input                               CTRL_WVALID;
input                               CTRL_BREADY;
input                               CTRL_ARVALID;
input                               CTRL_RREADY;
input   [10:0]                      CTRL_AWADDR;
input   [3:0]                       CTRL_WSTRB;
input   [31:0]                      CTRL_WDATA;
input   [10:0]                      CTRL_ARADDR;

// FabricController inputs
input   [NUM_INT_BDS-1:0]           STRTDMAOP;
    
// AXI4Slave inputs
input   [1:0]                       DMA_BRESP;
input   [ID_WIDTH-1:0]              DMA_BID;
input   [AXI_DMA_DWIDTH-1:0]        DMA_RDATA;
input   [ID_WIDTH-1:0]              DMA_RID;
input                               DMA_AWREADY;
input                               DMA_WREADY;
input                               DMA_BVALID;
input                               DMA_ARREADY;
input                               DMA_RVALID;
input   [1:0]                       DMA_RRESP;
input                               DMA_RLAST;

// AXI4-Stream inputs
input                               TVALID;
input   [AXI_DMA_DWIDTH-1:0]        TDATA;
input   [(AXI_DMA_DWIDTH/8)-1:0]    TSTRB;
input   [(AXI_DMA_DWIDTH/8)-1:0]    TKEEP;
input                               TLAST;
input   [ID_WIDTH-1:0]              TID;
input   [1:0]                       TDEST;

// AXI4LiteMaster outputs
output  [1:0]                       CTRL_BRESP;
output  [31:0]                      CTRL_RDATA;
output                              CTRL_AWREADY;
output                              CTRL_WREADY;
output                              CTRL_BVALID;
output                              CTRL_ARREADY;
output                              CTRL_RVALID;
output  [1:0]                       CTRL_RRESP;

// AXI4Slave outputs
output                              DMA_AWVALID;
output                              DMA_WVALID;
output                              DMA_WLAST;
output                              DMA_BREADY;
output                              DMA_ARVALID;
output                              DMA_RREADY;
output  [31:0]                      DMA_AWADDR;
output  [ID_WIDTH-1:0]              DMA_AWID;
output  [7:0]                       DMA_AWLEN;
output  [2:0]                       DMA_AWSIZE;
output  [1:0]                       DMA_AWBURST;
output  [(AXI_DMA_DWIDTH/8)-1:0]    DMA_WSTRB;
output  [AXI_DMA_DWIDTH-1:0]        DMA_WDATA;
output  [31:0]                      DMA_ARADDR;
output  [ID_WIDTH-1:0]              DMA_ARID;
output  [7:0]                       DMA_ARLEN;
output  [2:0]                       DMA_ARSIZE;
output  [1:0]                       DMA_ARBURST;

// AXI4-Stream outputs
output                              TREADY;

// MasterController outputs
output  [NUM_OF_INTS-1:0]           INTERRUPT;

////////////////////////////////////////////////////////////////////////////////
// Internal signals
////////////////////////////////////////////////////////////////////////////////
wire                                ctrlWrRdy_AXILite;
wire [31:0]                         ctrlRdData_AXILite;
wire                                ctrlRdValid_AXILite;
wire                                ctrlWrRdy_BufferDescrptrs;
wire                                ctrlRdValid_BufferDescrptrs;
wire [31:0]                         ctrlRdData_BufferDescrptrs;
wire                                ctrlRdValid_IntController;
wire [31:0]                         ctrlRdData_IntController;
wire [31:0]                         ctrlRdData_CtrlReg;
wire                                ctrlRdValid_CtrlReg;
wire                                ctrlSel_AXILite;
wire                                ctrlWr_AXILite;
wire [10:0]                         ctrlAddr_AXILite;
wire [31:0]                         ctrlWrData_AXILite;
wire [3:0]                          ctrlWrStrbs_AXILite;
wire                                ctrlSel;
wire                                ctrlWr;
wire [10:0]                         ctrlAddr;
wire [31:0]                         ctrlWrData;
wire [3:0]                          ctrlWrStrbs;
wire [NUM_INT_BDS-1:0]              startDMAOpInt;
wire                                int_valid;
wire                                int_opDone;
wire                                int_wrError;
wire                                int_rdError;
wire                                int_inValidDscrptr;
wire [NUM_INT_BDS_WIDTH-1:0]        int_intDscrptrNum;
wire                                int_extDscrptr;
wire [31:0]                         int_extDscrptrAddr;
wire                                int_strDscrptr;
wire [NUM_INT_BDS-1:0]              waitDscrptr;
wire                                waitStrDscrptr;
wire [NUM_INT_BDS-1:0]              clrDataValidDscrptr;
wire                                AXI4WrTransDone;
wire                                AXI4RdTransDone;
wire                                AXI4WrTransError;
wire                                AXI4RdTransError;
wire                                AXI4StreamWrTransDone;
wire                                AXI4StreamWrTransError;
wire                                extFetchValid_AXI4MasterCtrl;
wire [1:0]                          dataValid_AXI4MasterCtrl;
wire [DSCRPTR_DATA_WIDTH-1:0]       dscrptrData_AXI4MasterCtrl;
wire                                dscrptrValid_AXI4MasterCtrl;

wire [DSCRPTR_DATA_WIDTH-1:0]       dscrptrData_BufferDscrptrs;
wire [NUM_INT_BDS-1:0]              dataValidDscrptr_BufferDscrptrs;
wire                                dscrptrValid_BufferDscrptrs;
wire                                readDscrptr_BufferDscrptrs;
wire                                wrCache1Sel;
wire                                rdCache1Sel;
wire                                readDscrptrValid_BufferDscrptrs;
wire [NUM_INT_BDS_WIDTH-1:0]        intDscrptrNum_BufferDscrptrs;
wire                                wrEn_AXI4MasterCtrl;
wire [MAX_AXI_NUM_BEATS_WIDTH-1:0]  wrAddr_AXI4MasterCtrl;
wire [AXI_DMA_DWIDTH-1:0]           wrData_AXI4MasterCtrl;
wire [TRAN_BYTE_CNT_WIDTH-1:0]      wrNumOfBytes_AXI4MasterCtrl;
wire [MAX_AXI_NUM_BEATS_WIDTH-1:0]  rdAddr_AXI4MasterCtrl;
wire [TRAN_BYTE_CNT_WIDTH-1:0]      rdNumOfBytes_AXI4MasterCtrl;
wire                                strtAXIWrTran_DMATranCtrl;
wire                                strtAXIRdTran_DMATranCtrl;
wire [1:0]                          srcAXITranType_DMATranCtrl;
wire [MAX_TRAN_SIZE_WIDTH-1:0]      srcNumOfBytes_DMATranCtrl;
wire [31:0]                         srcAXIStrtAddr_DMATranCtrl;
wire [2:0]                          srcAXIDataWidth_DMATranCtrl;
wire [MAX_AXI_NUM_BEATS_WIDTH-1:0]  srcMaxAXINumBeats_DMATranCtrl;
wire [MAX_TRAN_SIZE_WIDTH-1:0]      dstNumOfBytesInRd_AXI4MasterCtrl_DMATranCtrl;
wire [2:0]                          dstSrcAXIDataWidth_DMATranCtrl;
wire [MAX_AXI_NUM_BEATS_WIDTH-1:0]  dstMaxAXINumBeats_DMATranCtrl;
wire [1:0]                          dstAXITranType_DMATranCtrl;
wire [31:0]                         dstAXIStrtAddr_DMATranCtrl;
wire [2:0]                          dstAXIDataWidth_DMATranCtrl;
wire                                strtExtDscrptrRd_DMATranCtrl;
wire                                strtExtDscrptrRdyCheck_DMATranCtrl;
wire [31:0]                         strtAddr_extDscrptrFetch_DMATranCtrl;
wire                                clrExtDscrptrDataValid_DMATranCtrl;
wire [7:0]                          configRegByte2_DMATranCtrl;
wire                                numOfBytesInRdValid_AXI4MasterCtrl;
wire [MAX_AXI_TRAN_SIZE_WIDTH-1:0]  numOfBytesInRd_AXI4MasterCtrl;
wire                                strRdyToAck;
wire [MAX_AXI_TRAN_SIZE_WIDTH-1:0]  numOfBytesInWr_AXI4MasterCtrl;
wire [AXI_DMA_DWIDTH-1:0]           rdData_memMapCache;
wire [MAX_AXI_TRAN_SIZE_WIDTH-1:0]  noOfBytesInCurrRdCache_memMapCache;
wire [AXI_DMA_DWIDTH-1:0]           rdData_strCache;
wire [MAX_AXI_TRAN_SIZE_WIDTH-1:0]  noOfBytesInCurrRdCache_StrCache;
wire [MAX_AXI_TRAN_SIZE_WIDTH-1:0]  noOfBytesInCurrWrCache_StrCache;
wire [NUM_INT_BDS-1:0]              chain;
wire                                dstStrDscrptr_DMATranCtrl;
wire                                rdEnMemMapCache;
wire                                rdEnStrCache;
wire                                wrEn_strCache;
wire [MAX_AXI_NUM_BEATS_WIDTH-1:0]  wrAddr_strCache;
wire [TRAN_BYTE_CNT_WIDTH-1:0]      wrByteCnt_strCache;
wire [AXI_DMA_DWIDTH-1:0]           wrData_strCache;
wire                                strWrCache1Sel;
wire                                strRdCache1Sel;
wire                                clrStrRdCache;
wire                                strMemMapWrDone;
wire                                strMemMapWrError;
wire [31:0]                         strDscrptrAddr;
wire [31:0]                         ctrlRdData_AXI4StreamSlaveCtrl;
wire                                ctrlRdValid_AXI4StreamSlaveCtrl;
wire                                strFetchAck_AXI4MasterCtrl;
wire                                strDataValid_AXIMasterCtrl;
wire                                strFetchRdy;
wire [31:0]                         strFetchAddr;
wire                                clrStrDscrptrDataValid;
wire [31:0]                         clrStrDscrptrAddr;
wire [1:0]                          clrStrDscrptrDstOp;
wire                                clrStrDscrptrDataValidAck;
wire                                strDscrptrValid;


wire								error_flag_db_bd_out;
wire								error_flag_sb_bd_out;
wire								error_flag_db_cache;
wire								error_flag_sb_cache;
wire								error_flag_db_intextdscrptr;
wire								error_flag_sb_intextdscrptr;
wire								error_flag_sb_cache_str;
wire								error_flag_db_cache_str;

////////////////////////////////////////////////////////////////////////////////
// AXI4LiteSlaveCtrl instantiation
////////////////////////////////////////////////////////////////////////////////
CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_AXI4LiteSlaveCtrl U_AXI4LiteSlaveCtrl(
    .clock                                  (CLOCK),
    .resetn                                 (RESETN),
    
    // AXI4-Lite Master inputs
    .AWVALID                                (CTRL_AWVALID),
    .WVALID                                 (CTRL_WVALID),
    .BREADY                                 (CTRL_BREADY),
    .ARVALID                                (CTRL_ARVALID),
    .RREADY                                 (CTRL_RREADY),
    .AWADDR                                 (CTRL_AWADDR),
    .WSTRB                                  (CTRL_WSTRB),
    .WDATA                                  (CTRL_WDATA),
    .ARADDR                                 (CTRL_ARADDR),
    
    // CtrlIf inputs
    .ctrlWrRdy                              (ctrlWrRdy_AXILite),
    .ctrlRdData                             (ctrlRdData_AXILite),
    .ctrlRdValid                            (ctrlRdValid_AXILite),
    
    // AXI4-Lite Master outputs
    .BRESP                                  (CTRL_BRESP),
    .RDATA                                  (CTRL_RDATA),
    .AWREADY                                (CTRL_AWREADY),
    .WREADY                                 (CTRL_WREADY),
    .BVALID                                 (CTRL_BVALID),
    .ARREADY                                (CTRL_ARREADY),
    .RVALID                                 (CTRL_RVALID),
    .RRESP                                  (CTRL_RRESP),
    
    // CtrlIf outputs
    .ctrlSel                                (ctrlSel_AXILite),
    .ctrlWr                                 (ctrlWr_AXILite),
    .ctrlAddr                               (ctrlAddr_AXILite),
    .ctrlWrData                             (ctrlWrData_AXILite),
    .ctrlWrStrbs                            (ctrlWrStrbs_AXILite)
);

////////////////////////////////////////////////////////////////////////////////
// cltrIfMuxCDC instantiation
////////////////////////////////////////////////////////////////////////////////
CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_ctrlIFMuxCDC U_ctrlIFMuxCDC(
    // AXILiteSlaveCtrl inputs
    .ctrlSel_AXILiteSlaveCtrl               (ctrlSel_AXILite),
    .ctrlWr_AXILiteSlaveCtrl                (ctrlWr_AXILite),
    .ctrlAddr_AXILiteSlaveCtrl              (ctrlAddr_AXILite),
    .ctrlWrData_AXILiteSlaveCtrl            (ctrlWrData_AXILite),
    .ctrlWrStrbs_AXILiteSlaveCtrl           (ctrlWrStrbs_AXILite),
    
    // Buffer Descriptor inputs
    .ctrlWrRdy_BufferDescrptrs              (ctrlWrRdy_BufferDescrptrs),
    .ctrlRdData_BufferDescrptrs             (ctrlRdData_BufferDescrptrs),
    .ctrlRdValid_BufferDescrptrs            (ctrlRdValid_BufferDescrptrs),
    
    // Interrupt Controller inputs
    .ctrlRdData_IntController               (ctrlRdData_IntController),
    .ctrlRdValid_IntController              (ctrlRdValid_IntController),
    
    // Control Register inputs
    .ctrlRdData_CtrlReg                     (ctrlRdData_CtrlReg),
    .ctrlRdValid_CtrlReg                    (ctrlRdValid_CtrlReg),
    
    // AXI4StreamSlaveCtrl inputs
    .ctrlRdData_AXI4StreamSlaveCtrl         (ctrlRdData_AXI4StreamSlaveCtrl),
    .ctrlRdValid_AXI4StreamSlaveCtrl        (ctrlRdValid_AXI4StreamSlaveCtrl),
    
    // General outputs
    .ctrlSel                                (ctrlSel),
    .ctrlWr                                 (ctrlWr),
    .ctrlAddr                               (ctrlAddr),
    .ctrlWrData                             (ctrlWrData),
    .ctrlWrStrbs                            (ctrlWrStrbs),
    
    // AXILiteSlaveCtrl outputs
    .ctrlWrRdy                              (ctrlWrRdy_AXILite),
    .ctrlRdData                             (ctrlRdData_AXILite),
    .ctrlRdValid                            (ctrlRdValid_AXILite)
);

////////////////////////////////////////////////////////////////////////////////
// BufferDescriptors instantiation
////////////////////////////////////////////////////////////////////////////////
CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_bufferDescriptors #(
    .DSCRPTR_DATA_WIDTH                     (DSCRPTR_DATA_WIDTH),
    .NUM_INT_BDS                            (NUM_INT_BDS),
    .NUM_INT_BDS_WIDTH                      (NUM_INT_BDS_WIDTH),
    .DATA_REALIGNMENT                       (DATA_REALIGNMENT),
	.ECC									(ECC)
) U_bufferDescriptors (
    .clock                                  (CLOCK),
    .resetn                                 (RESETN),
    
    // CtrlIFMuxCDC inputs
    .ctrlSel                                (ctrlSel),
    .ctrlWr                                 (ctrlWr),
    .ctrlAddr                               (ctrlAddr),
    .ctrlWrData                             (ctrlWrData),
    .ctrlWrStrbs                            (ctrlWrStrbs),
    
    // DMAController inputs
    .readDscrptr                            (readDscrptr_BufferDscrptrs),
    .intDscrptrNum_BufferDscrptrs           (intDscrptrNum_BufferDscrptrs),
    .clrDataValidDscrptr                    (clrDataValidDscrptr),
    
    // CtrlIFMuxCDC outputs
    .ctrlRdData                             (ctrlRdData_BufferDescrptrs),
    .ctrlRdValid                            (ctrlRdValid_BufferDescrptrs),
    
    // DMAController outputs
    .readDscrptrValid                       (readDscrptrValid_BufferDscrptrs),
    .ctrlWrRdy                              (ctrlWrRdy_BufferDescrptrs),
    .dscrptrData                            (dscrptrData_BufferDscrptrs),
    .chain                                  (chain),
    .dataValidDscrptr                       (dataValidDscrptr_BufferDscrptrs),
    .dscrptrValid                           (dscrptrValid_BufferDscrptrs),
	
	//ECC flags
	.error_flag_sb_bd_out					(error_flag_sb_bd_out),
	.error_flag_db_bd_out					(error_flag_db_bd_out)
);

////////////////////////////////////////////////////////////////////////////////
// DMAController instantiation
////////////////////////////////////////////////////////////////////////////////
CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_DMAController #(
    .NUM_INT_BDS                            (NUM_INT_BDS),
    .NUM_INT_BDS_WIDTH                      (NUM_INT_BDS_WIDTH),
    .DSCRPTR_DATA_WIDTH                     (DSCRPTR_DATA_WIDTH),
    .MAX_TRAN_SIZE_WIDTH                    (MAX_TRAN_SIZE_WIDTH),
    .NUM_PRI_LVLS                           (NUM_PRI_LVLS),
    .MAX_AXI_TRAN_SIZE_WIDTH                (MAX_AXI_TRAN_SIZE_WIDTH),
    .MAX_AXI_NUM_BEATS_WIDTH                (MAX_AXI_NUM_BEATS_WIDTH),
    .PRI_0_NUM_OF_BEATS                     (PRI_0_NUM_OF_BEATS_INT),
    .PRI_1_NUM_OF_BEATS                     (PRI_1_NUM_OF_BEATS_INT),
    .PRI_2_NUM_OF_BEATS                     (PRI_2_NUM_OF_BEATS_INT),
    .PRI_3_NUM_OF_BEATS                     (PRI_3_NUM_OF_BEATS_INT),
    .PRI_4_NUM_OF_BEATS                     (PRI_4_NUM_OF_BEATS_INT),
    .PRI_5_NUM_OF_BEATS                     (PRI_5_NUM_OF_BEATS_INT),
    .PRI_6_NUM_OF_BEATS                     (PRI_6_NUM_OF_BEATS_INT),
    .PRI_7_NUM_OF_BEATS                     (PRI_7_NUM_OF_BEATS_INT),
    .AXI4_STREAM_IF                         (AXI4_STREAM_IF),
	.FAMILY									(FAMILY),
	.ECC									(ECC)
) U_DMAController (
    // General inputs
    .clock                                  (CLOCK),
    .resetn                                 (RESETN),

    // Control register inputs
    .strtDMAOpInt                           (startDMAOpInt),
    
    // Fabric controller inputs
    .strtDMAOp                              (STRTDMAOP),

    // AXI4MasterCtrl inputs
    .AXI4WrTransDone                        (AXI4WrTransDone),
    .AXI4RdTransDone                        (AXI4RdTransDone),
    .AXI4WrTransError                       (AXI4WrTransError),
    .AXI4RdTransError                       (AXI4RdTransError),
    .AXI4StreamWrTransDone                  (AXI4StreamWrTransDone),
    .AXI4StreamWrTransError                 (AXI4StreamWrTransError),
    .numOfBytesInRdValid                    (numOfBytesInRdValid_AXI4MasterCtrl),
    .numOfBytesInRd                         (numOfBytesInRd_AXI4MasterCtrl),    
    .strRdyToAck                            (strRdyToAck),
    .numOfBytesInWr_AXI4MasterCtrl          (numOfBytesInWr_AXI4MasterCtrl),
    .extFetchValid_AXI4MasterCtrl           (extFetchValid_AXI4MasterCtrl),
    .dataValid_AXI4MasterCtrl               (dataValid_AXI4MasterCtrl),
    .dscrptrData_AXI4MasterCtrl             (dscrptrData_AXI4MasterCtrl),
    .dscrptrValid_AXI4MasterCtrl            (dscrptrValid_AXI4MasterCtrl),
    .strFetchAck_AXI4MasterCtrl             (strFetchAck_AXI4MasterCtrl),
    .strDataValid_AXIMasterCtrl             (strDataValid_AXIMasterCtrl),
    .clrStrDscrptrDataValidAck              (clrStrDscrptrDataValidAck),

    // Interrupt controller inputs
    .waitDscrptr                            (waitDscrptr),
    .waitStrDscrptr                         (waitStrDscrptr),


    // Buffer descriptor inputs
    .dataValidDscrptr                       (dataValidDscrptr_BufferDscrptrs),
    .dscrptrValid                           (dscrptrValid_BufferDscrptrs),
    .dscrptrData                            (dscrptrData_BufferDscrptrs),
    .chain                                  (chain),
    .readDscrptrValid                       (readDscrptrValid_BufferDscrptrs),
    
    // AXI4StreamSlaveCtrl inputs
    .fetchStrDscrptr                        (fetchStrDscrptr),
    .strDscrptrAddr                         (strDscrptrAddr),

    // AXI4MasterCtrl outputs
    .strtAXIWrTran                          (strtAXIWrTran_DMATranCtrl),
    .strtAXIRdTran                          (strtAXIRdTran_DMATranCtrl),
    .srcAXITranType                         (srcAXITranType_DMATranCtrl),
    .srcNumOfBytes                          (srcNumOfBytes_DMATranCtrl),
    .srcAXIStrtAddr                         (srcAXIStrtAddr_DMATranCtrl),
    .srcAXIDataWidth                        (srcAXIDataWidth_DMATranCtrl),
    .srcMaxAXINumBeats                      (srcMaxAXINumBeats_DMATranCtrl),
    .dstStrDscrptr                          (dstStrDscrptr_DMATranCtrl),
    .dstNumOfBytesInRd_AXI4MasterCtrl       (dstNumOfBytesInRd_AXI4MasterCtrl_DMATranCtrl),
    .dstSrcAXIDataWidth                     (dstSrcAXIDataWidth_DMATranCtrl),
    .dstMaxAXINumBeats                      (dstMaxAXINumBeats_DMATranCtrl),
    .dstAXITranType                         (dstAXITranType_DMATranCtrl),
    .dstAXIStrtAddr                         (dstAXIStrtAddr_DMATranCtrl),
    .dstAXIDataWidth                        (dstAXIDataWidth_DMATranCtrl),
    .strtStrDscrptrRd                       (strtStrDscrptrRd_DMATranCtrl),
    .strtExtDscrptrRd                       (strtExtDscrptrRd_DMATranCtrl),
    .strtExtDscrptrRdyCheck                 (strtExtDscrptrRdyCheck_DMATranCtrl),
    .strtAddr_extDscrptrFetch               (strtAddr_extDscrptrFetch_DMATranCtrl),
    .clrExtDscrptrDataValid                 (clrExtDscrptrDataValid_DMATranCtrl),
    .configRegByte2                         (configRegByte2_DMATranCtrl),
    .strFetchRdy                            (strFetchRdy),
    .strFetchAddr                           (strFetchAddr),
    .clrStrDscrptrDataValid                 (clrStrDscrptrDataValid),
    .clrStrDscrptrAddr                      (clrStrDscrptrAddr),
    .clrStrDscrptrDstOp                     (clrStrDscrptrDstOp),
    
    // Memory Map Cache outputs
    .wrCache1Sel                            (wrCache1Sel),
    .rdCache1Sel                            (rdCache1Sel),
    
    // Interrupt controller outputs
    .valid                                  (int_valid),
    .opDone                                 (int_opDone),
    .wrError                                (int_wrError),
    .rdError                                (int_rdError),
    .dscrptrNValidError                     (int_inValidDscrptr),
    .intDscrptrNum_IntController            (int_intDscrptrNum),
    .extDscrptr_IntController               (int_extDscrptr),
    .extDscrptrAddr_IntController           (int_extDscrptrAddr),
    .strDscrptr_IntController               (int_strDscrptr),
    
    // Buffer descriptor outputs
    .readDscrptr                            (readDscrptr_BufferDscrptrs),
    .clrDataValidDscrptr                    (clrDataValidDscrptr),
    .intDscrptrNum_BufferDscrptrs           (intDscrptrNum_BufferDscrptrs),
    
    // AXI4StreamSlaveCtrl outputs
    .strFetchDone                           (strFetchDone),
    .strDscrptrValid                        (strDscrptrValid),
    .strMemMapWrDone                        (strMemMapWrDone),
    .strMemMapWrError                       (strMemMapWrError),
	
	//ECC flags
	.error_flag_sb_intextdscrptr			(error_flag_sb_intextdscrptr),
	.error_flag_db_intextdscrptr			(error_flag_db_intextdscrptr)
);

////////////////////////////////////////////////////////////////////////////////
// Control Registers instantiation
////////////////////////////////////////////////////////////////////////////////
CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_controlRegisters # (
    .MAJOR_VER_NUM                          (MAJOR_VER_NUM),
    .MINOR_VER_NUM                          (MINOR_VER_NUM),
    .BUILD_NUM                              (BUILD_NUM),
    .NUM_INT_BDS                            (NUM_INT_BDS)
) U_controlRegisters (
    .clock                                  (CLOCK),
    .resetn                                 (RESETN),
    
    // CtrlIFMuxCDC inputs
    .ctrlSel                                (ctrlSel),
    .ctrlWr                                 (ctrlWr),
    .ctrlAddr                               (ctrlAddr),
    .ctrlWrData                             (ctrlWrData),
    .ctrlWrStrbs                            (ctrlWrStrbs),
    
    // CtrlIFMuxCDC outputs
    .ctrlRdData                             (ctrlRdData_CtrlReg),
    .ctrlRdValid                            (ctrlRdValid_CtrlReg),
    
    // DMAController outputs
    .startDMAOp                             (startDMAOpInt)
);

////////////////////////////////////////////////////////////////////////////////
// Interrupt Controller instantiation
////////////////////////////////////////////////////////////////////////////////
CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_intController # (
    .NUM_INT_BDS                            (NUM_INT_BDS),
    .NUM_INT_BDS_WIDTH                      (NUM_INT_BDS_WIDTH),
    .INT_0_QUEUE_DEPTH                      (INT_0_QUEUE_DEPTH),
    .INT_1_QUEUE_DEPTH                      (INT_1_QUEUE_DEPTH),
    .INT_2_QUEUE_DEPTH                      (INT_2_QUEUE_DEPTH),
    .INT_3_QUEUE_DEPTH                      (INT_3_QUEUE_DEPTH),
	.FAMILY									(FAMILY),
	.ECC									(ECC),
    .AXI4_STREAM_IF                         (AXI4_STREAM_IF)
) U_intController (
    // General inputs
    .clock                                  (CLOCK),
    .resetn                                 (RESETN),
    
    // CtrlIFMuxCDC inputs
    .ctrlSel                                (ctrlSel),
    .ctrlWr                                 (ctrlWr),
    .ctrlAddr                               (ctrlAddr),
    .ctrlWrData                             (ctrlWrData),
    .ctrlWrStrbs                            (ctrlWrStrbs),
    
    // DMAController inputs
    .valid                                  (int_valid),
    .opDone                                 (int_opDone),
    .wrError                                (int_wrError),
    .rdError                                (int_rdError),
    .inValidDscrptr                         (int_inValidDscrptr),
    .intDscrptrNum                          (int_intDscrptrNum),
    .extDscrptr                             (int_extDscrptr),
    .extDscrptrAddr                         (int_extDscrptrAddr),
    .strDscrptr                             (int_strDscrptr),
	
	//ECC flags inputs
	.error_flag_sb_cache					(error_flag_sb_cache),
	.error_flag_db_cache					(error_flag_db_cache),
	
	.error_flag_sb_cache_str				(error_flag_sb_cache_str),
	.error_flag_db_cache_str				(error_flag_db_cache_str),
	
	.error_flag_sb_bd_out					(error_flag_sb_bd_out),
	.error_flag_db_bd_out					(error_flag_db_bd_out),
	
	.error_flag_sb_intextdscrptr			(error_flag_sb_intextdscrptr),
	.error_flag_db_intextdscrptr			(error_flag_db_intextdscrptr),
    
    // CtrlIFMuxCDC outputs
    .ctrlRdData                             (ctrlRdData_IntController),
    .ctrlRdValid                            (ctrlRdValid_IntController),
    
    // DMAController outputs
    .waitDscrptr                            (waitDscrptr),
    .waitStrDscrptr                         (waitStrDscrptr),
	
	

    
    // MasterController outputs
    .int0                                   (INTERRUPT[0]),
    .int1                                   (INTERRUPT[1]),
    .int2                                   (INTERRUPT[2]),
    .int3                                   (INTERRUPT[3])
);

////////////////////////////////////////////////////////////////////////////////
// AXI4MasterDMACtrl instantiation
////////////////////////////////////////////////////////////////////////////////
CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_AXI4MasterDMACtrl # (
    .AXI_DMA_DWIDTH                         (AXI_DMA_DWIDTH),
    .MAX_TRAN_SIZE_WIDTH                    (MAX_TRAN_SIZE_WIDTH),
    .MAX_AXI_TRAN_SIZE_WIDTH                (MAX_AXI_TRAN_SIZE_WIDTH),
    .MAX_AXI_NUM_BEATS_WIDTH                (MAX_AXI_NUM_BEATS_WIDTH),
    .DSCRPTR_DATA_WIDTH                     (DSCRPTR_DATA_WIDTH),
    .MAX_AXI_NUM_BEATS                      (MAX_AXI_NUM_BEATS),
    .ID_WIDTH                               (ID_WIDTH),
    .AXI4_STREAM_IF                         (AXI4_STREAM_IF)
) U_AXI4MasterDMACtrl (
    .clock                                  (CLOCK),
    .resetn                                 (RESETN),

    // DMATranCtrl inputs
    .strtAXIWrTran                          (strtAXIWrTran_DMATranCtrl),
    .strtAXIRdTran                          (strtAXIRdTran_DMATranCtrl),
    .srcAXITranType                         (srcAXITranType_DMATranCtrl),
    .srcNumOfBytes                          (srcNumOfBytes_DMATranCtrl),
    .srcAXIStrtAddr                         (srcAXIStrtAddr_DMATranCtrl),
    .srcAXIDataWidth                        (srcAXIDataWidth_DMATranCtrl),
    .srcMaxAXINumBeats                      (srcMaxAXINumBeats_DMATranCtrl),
    .dstStrDscrptr                          (dstStrDscrptr_DMATranCtrl),
    .dstAXITranType                         (dstAXITranType_DMATranCtrl),
    .dstAXIStrtAddr                         (dstAXIStrtAddr_DMATranCtrl),
    .dstAXIDataWidth                        (dstAXIDataWidth_DMATranCtrl),
    .dstNumOfBytesInRd                      (dstNumOfBytesInRd_AXI4MasterCtrl_DMATranCtrl),
    .dstSrcAXIDataWidth                     (dstSrcAXIDataWidth_DMATranCtrl),
    .dstMaxAXINumBeats                      (dstMaxAXINumBeats_DMATranCtrl),
    .strFetchRdy                            (strFetchRdy),
    .strFetchAddr                           (strFetchAddr),
    .clrStrDscrptrDataValid                 (clrStrDscrptrDataValid),
    .clrStrDscrptrAddr                      (clrStrDscrptrAddr),
    .clrStrDscrptrDstOp                     (clrStrDscrptrDstOp),
    
    // ExtDscrptrFetchFSM inputs
    .strtStrDscrptrRd                       (strtStrDscrptrRd_DMATranCtrl),
    .strtExtDscrptrRd                       (strtExtDscrptrRd_DMATranCtrl),
    .strtExtDscrptrRdyCheck                 (strtExtDscrptrRdyCheck_DMATranCtrl),
    .strtAddr_extDscrptrFetch               (strtAddr_extDscrptrFetch_DMATranCtrl),
    .clrExtDscrptrDataValid                 (clrExtDscrptrDataValid_DMATranCtrl),
    .configRegByte2                         (configRegByte2_DMATranCtrl),
    
    // Memory Map Cache input 
    .rdDataMemMapCache                      (rdData_memMapCache),
    .numBytesInMemMapCache                  (noOfBytesInCurrRdCache_memMapCache),
    
    // Stream Cache input 
    .rdDataStrCache                         (rdData_strCache),
    .numBytesInStrCache                     (noOfBytesInCurrRdCache_StrCache),
    
    // AXISlave inputs
    .BRESP                                  (DMA_BRESP),
    .BID                                    (DMA_BID),
    .RDATA                                  (DMA_RDATA),
    .RID                                    (DMA_RID),
    .AWREADY                                (DMA_AWREADY),
    .WREADY                                 (DMA_WREADY),
    .BVALID                                 (DMA_BVALID),
    .ARREADY                                (DMA_ARREADY),
    .RVALID                                 (DMA_RVALID),
    .RRESP                                  (DMA_RRESP),
    .RLAST                                  (DMA_RLAST),
    
    // DMATranCtrl outputs
    .AXI4WrTransDone                        (AXI4WrTransDone),
    .AXI4RdTransDone                        (AXI4RdTransDone),
    .AXI4WrTransError                       (AXI4WrTransError),
    .AXI4RdTransError                       (AXI4RdTransError),
    .AXI4StreamWrTransDone                  (AXI4StreamWrTransDone),
    .AXI4StreamWrTransError                 (AXI4StreamWrTransError),
    .numOfBytesInRdValid                    (numOfBytesInRdValid_AXI4MasterCtrl),
    .numOfBytesInRd                         (numOfBytesInRd_AXI4MasterCtrl),
    .strRdyToAck                            (strRdyToAck),
    .numOfBytesInWr_AXI4MasterCtrl          (numOfBytesInWr_AXI4MasterCtrl),
    .strFetchAck_AXI4MasterCtrl             (strFetchAck_AXI4MasterCtrl),
    .strDataValid_AXIMasterCtrl             (strDataValid_AXIMasterCtrl),
    .clrStrDscrptrDataValidAck              (clrStrDscrptrDataValidAck),
    
    
    // ExtDscrptrFetchFSM outputs
    .extFetchValid_AXI4MasterCtrl           (extFetchValid_AXI4MasterCtrl),
    .dataValid_AXI4MasterCtrl               (dataValid_AXI4MasterCtrl),
    .dscrptrData_AXI4MasterCtrl             (dscrptrData_AXI4MasterCtrl),
    .dscrptrValid_AXI4MasterCtrl            (dscrptrValid_AXI4MasterCtrl),

    // Memory Map Cache outputs
    .wrEn                                   (wrEn_AXI4MasterCtrl),
    .wrAddr                                 (wrAddr_AXI4MasterCtrl),
    .wrData                                 (wrData_AXI4MasterCtrl),
    .wrNumOfBytes                           (wrNumOfBytes_AXI4MasterCtrl),
    .rdEnMemMapCache                        (rdEnMemMapCache),
    .rdAddr                                 (rdAddr_AXI4MasterCtrl),
    .rdNumOfBytes                           (rdNumOfBytes_AXI4MasterCtrl),
    
    // Stream Cache outputs
    .rdEnStrCache                           (rdEnStrCache),
    
    // AXISlave outputs
    .AWVALID                                (DMA_AWVALID),
    .WVALID                                 (DMA_WVALID),
    .WLAST                                  (DMA_WLAST),
    .BREADY                                 (DMA_BREADY),
    .ARVALID                                (DMA_ARVALID),
    .RREADY                                 (DMA_RREADY),
    .AWADDR                                 (DMA_AWADDR),
    .AWID                                   (DMA_AWID),
    .AWLEN                                  (DMA_AWLEN),
    .AWSIZE                                 (DMA_AWSIZE),
    .AWBURST                                (DMA_AWBURST),
    .WSTRB                                  (DMA_WSTRB),
    .WDATA                                  (DMA_WDATA),
    .ARADDR                                 (DMA_ARADDR),
    .ARID                                   (DMA_ARID),
    .ARLEN                                  (DMA_ARLEN),
    .ARSIZE                                 (DMA_ARSIZE),
    .ARBURST                                (DMA_ARBURST)
);

////////////////////////////////////////////////////////////////////////////////
// memoryMapDMACaches instantiation
////////////////////////////////////////////////////////////////////////////////
CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_Cache #(
    .CACHE_WIDTH                            (AXI_DMA_DWIDTH/8),
    .CACHE_DEPTH                            (MAX_AXI_NUM_BEATS),
	.FAMILY									(FAMILY),
	.ECC									(ECC)
) U_memoryMapDMACache (
    .clock                                  (CLOCK),
    .resetn                                 (RESETN),
    
    // AXI4MasterCtrl inputs
    .wrEn                                   (wrEn_AXI4MasterCtrl),
    .wrAddr                                 (wrAddr_AXI4MasterCtrl),
    .wrByteCnt                              (wrNumOfBytes_AXI4MasterCtrl),
    .wrData                                 (wrData_AXI4MasterCtrl),
    .rdEn                                   (rdEnMemMapCache),
    .rdAddr                                 (rdAddr_AXI4MasterCtrl),
    .rdByteCnt                              (rdNumOfBytes_AXI4MasterCtrl),
    .clrRdCache                             (1'b0), // Unused
    
    // DMAController inputs
    .wrCacheSel                             (wrCache1Sel),
    .rdCacheSel                             (rdCache1Sel),
    
    // AXI4MasterCtrl outputs
    .rdData                                 (rdData_memMapCache),
    .noOfBytesInCurrCacheWrSel              (noOfBytesInCurrRdCache_memMapCache),
    .noOfBytesInCurrCacheRdSel              (), // Unused as largest mem map transaction fits in cache
	
	//ECC flags
	.error_flag_sb_cache					(error_flag_sb_cache),
	.error_flag_db_cache					(error_flag_db_cache)
);

////////////////////////////////////////////////////////////////////////////////
// AXI4-Stream Support
////////////////////////////////////////////////////////////////////////////////
generate
    if (AXI4_STREAM_IF)
        begin
            ////////////////////////////////////////////////////////////////////
            // AXI4StreamSlaveCtrl instantiation
            ////////////////////////////////////////////////////////////////////
            CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_AXI4StreamSlaveCtrl #(
                .ID_WIDTH                               (ID_WIDTH),
                .DATA_WIDTH                             (AXI_DMA_DWIDTH),
                .STR_CACHE_DEPTH_WIDTH                  (MAX_AXI_NUM_BEATS_WIDTH),
                .MAX_AXI_TRAN_SIZE                      (MAX_AXI_TRAN_SIZE),
                .MAX_AXI_TRAN_SIZE_WIDTH                (MAX_AXI_TRAN_SIZE_WIDTH)
            ) U_AXI4StreamSlaveCtrl (
                // General inputs
                .clock                                  (CLOCK),
                .resetn                                 (RESETN),

                // AXI4-Stream master inputs
                .TVALID                                 (TVALID),
                .TDATA                                  (TDATA),
                .TSTRB                                  (TSTRB),
                .TKEEP                                  (TKEEP),
                .TLAST                                  (TLAST),
                .TID                                    (TID),
                .TDEST                                  (TDEST),

                // extDscrptrFetchFSM inputs
                .strFetchDone                           (strFetchDone),
                .dscrptrValid                           (strDscrptrValid),

                // intErrorCtrl inputs
                .strMemMapWrDone                        (strMemMapWrDone),
                .strMemMapWrError                       (strMemMapWrError),
                
                // CtrlIFMuxCDC inputs
                .ctrlSel                                (ctrlSel),
                .ctrlWr                                 (ctrlWr),
                .ctrlAddr                               (ctrlAddr),
                .ctrlWrData                             (ctrlWrData),
                .ctrlWrStrbs                            (ctrlWrStrbs),
                
                // Stream Cache inputs
                .noOfBytesInCurrRdCache                 (noOfBytesInCurrWrCache_StrCache),

                // AXI4-Stream master outputs
                .TREADY                                 (TREADY),

                // extDscrptrFetchFSM outputs
                .fetchStrDscrptr                        (fetchStrDscrptr),
                .strDscrptrAddr                         (strDscrptrAddr),

                // Stream cache outputs
                .strWrCache1Sel                         (strWrCache1Sel),
                .strRdCache1Sel                         (strRdCache1Sel),
                .wrEn                                   (wrEn_strCache),
                .wrAddr                                 (wrAddr_strCache),
                .wrByteCnt                              (wrByteCnt_strCache),
                .wrData                                 (wrData_strCache),
                .clrRdCache                             (clrStrRdCache),
                
                // CtrlIFMuxCDC outputs
                .ctrlRdData                             (ctrlRdData_AXI4StreamSlaveCtrl),
                .ctrlRdValid                            (ctrlRdValid_AXI4StreamSlaveCtrl)
            );
            
            ////////////////////////////////////////////////////////////////////
            // Stream cache instantiation
            ////////////////////////////////////////////////////////////////////
            CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_Cache #(
                .CACHE_WIDTH                            (AXI_DMA_DWIDTH/8),
                .CACHE_DEPTH                            (MAX_AXI_NUM_BEATS),
				.FAMILY									(FAMILY),
				.ECC									(ECC)
            ) U_StreamCache (
                .clock                                  (CLOCK),
                .resetn                                 (RESETN),
                
                // AXI4StreamSlaveCtrl inputs
                .wrEn                                   (wrEn_strCache),
                .wrAddr                                 (wrAddr_strCache),
                .wrByteCnt                              (wrByteCnt_strCache),
                .wrData                                 (wrData_strCache),
                .clrRdCache                             (clrStrRdCache),
                
                // AXI4MasterCtrl inputs
                .rdEn                                   (rdEnStrCache),
                .rdAddr                                 (rdAddr_AXI4MasterCtrl),
                .rdByteCnt                              (rdNumOfBytes_AXI4MasterCtrl),
                
                // DMAController inputs
                .wrCacheSel                             (strWrCache1Sel),
                .rdCacheSel                             (strRdCache1Sel),
                
                // AXI4StreamSlaveCtrl outputs
                .rdData                                 (rdData_strCache),
                .noOfBytesInCurrCacheWrSel              (noOfBytesInCurrRdCache_StrCache),
                .noOfBytesInCurrCacheRdSel              (noOfBytesInCurrWrCache_StrCache),
				
				//ECC flags
				.error_flag_sb_cache					(error_flag_sb_cache_str),
				.error_flag_db_cache					(error_flag_db_cache_str)
            );
        end
endgenerate

endmodule // COREAXI4DMACONTROLLER