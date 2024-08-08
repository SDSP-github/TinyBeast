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
module CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_AXI4StreamSlaveCtrl (
    // General inputs
    clock,
    resetn,
    
    // AXI4-Stream master inputs
    TVALID,
    TDATA,
    TSTRB, // Stream must be aligned to the bus width. No position bytes permitted at the start of a transfer
    TKEEP, // Unused by the core. Assumes null bytes will be stripped from the packet by interconnect
    TLAST,
    TID,
    TDEST,
    
    // AXI4-Stream Cache inputs
    noOfBytesInCurrRdCache,
    
    // extDscrptrFetchFSM inputs
    strFetchDone,
    dscrptrValid,
    
    // intErrorCtrl inputs
    strMemMapWrDone,
    strMemMapWrError,
    
    // CtrlIFMuxCDC inputs
    ctrlSel,
    ctrlWr,
    ctrlAddr,
    ctrlWrData,
    ctrlWrStrbs,
    
    // AXI4-Stream master outputs
    TREADY,
    
    // extDscrptrFetchFSM outputs
    fetchStrDscrptr,
    strDscrptrAddr,
    
    // Stream cache outputs
    wrEn,
    wrAddr,
    wrByteCnt,
    wrData,
    strWrCache1Sel,
    strRdCache1Sel,
    clrRdCache,

    // CtrlIFMuxCDC outputs
    ctrlRdData,
    ctrlRdValid
);

////////////////////////////////////////////////////////////////////////////////
// Parameters
////////////////////////////////////////////////////////////////////////////////
parameter ID_WIDTH                = 1;
parameter DATA_WIDTH              = 64;
parameter STR_CACHE_DEPTH_WIDTH   = 4;
parameter MAX_AXI_TRAN_SIZE       = 4;
parameter MAX_AXI_TRAN_SIZE_WIDTH = 12;

// Include file containing the implementation of clog2() function
`include "./coreaxi4dmacontroller_utility_functions.v"

////////////////////////////////////////////////////////////////////////////////
// Local parameters
////////////////////////////////////////////////////////////////////////////////
localparam          TRAN_BYTE_CNT_WIDTH     = clog2(DATA_WIDTH/8);
localparam [10:0]   STR_DSCRPTR_ADDR_REG_0  = 11'h460;

////////////////////////////////////////////////////////////////////////////////
// Port directions
////////////////////////////////////////////////////////////////////////////////
input                                   clock;
input                                   resetn;
input                                   TVALID;
input   [DATA_WIDTH-1:0]                TDATA;
input   [(DATA_WIDTH/8)-1:0]            TSTRB;
input   [(DATA_WIDTH/8)-1:0]            TKEEP;
input                                   TLAST;
input   [ID_WIDTH-1:0]                  TID;
input   [1:0]                           TDEST;
input   [MAX_AXI_TRAN_SIZE_WIDTH-1:0]   noOfBytesInCurrRdCache;
input                                   strFetchDone;
input                                   dscrptrValid;
input                                   strMemMapWrDone;
input                                   strMemMapWrError;
input                                   ctrlSel;
input                                   ctrlWr;
input   [10:0]                          ctrlAddr;
input   [31:0]                          ctrlWrData;
input   [3:0]                           ctrlWrStrbs;
output                                  TREADY;
output                                  fetchStrDscrptr;
output  [31:0]                          strDscrptrAddr;
output                                  wrEn;
output  [STR_CACHE_DEPTH_WIDTH-1:0]     wrAddr;
output  [TRAN_BYTE_CNT_WIDTH-1:0]       wrByteCnt;
output  [DATA_WIDTH-1:0]                wrData;
output                                  strWrCache1Sel;
output                                  strRdCache1Sel;
output                                  clrRdCache;
output  [31:0]                          ctrlRdData;
output                                  ctrlRdValid;

////////////////////////////////////////////////////////////////////////////////
// Internal signals
////////////////////////////////////////////////////////////////////////////////
reg  [3:0]                          currStateStrRx;
reg  [3:0]                          nextStateStrRx;
reg  [3:0]                          currStateStrFetch;
reg  [3:0]                          nextStateStrFetch;
reg                                 TREADYReg;
reg                                 TREADYReg_d;
reg                                 fetchStrDscrptrReg;
reg                                 fetchStrDscrptrReg_d;
reg  [31:0]                         strDscrptrAddrReg;
reg  [31:0]                         strDscrptrAddrReg_d;
reg                                 wrEnReg;
reg                                 wrEnReg_d;
reg  [STR_CACHE_DEPTH_WIDTH-1:0]    wrAddrReg;
reg  [STR_CACHE_DEPTH_WIDTH-1:0]    wrAddrReg_d;
reg  [TRAN_BYTE_CNT_WIDTH-1:0]      wrByteCntReg;
reg  [TRAN_BYTE_CNT_WIDTH-1:0]      wrByteCntReg_d;
reg  [DATA_WIDTH-1:0]               wrDataReg;
reg  [DATA_WIDTH-1:0]               wrDataReg_d;
wire [DATA_WIDTH-1:0]               wrByteCntLast;
reg  [1:0]                          strCacheInUse;
wire                                strFetchDone;
reg                                 strRdCache1SelReg;
reg                                 strRdCache1SelReg_d;
reg                                 strWrCache1SelReg;
//reg                                 inLastBeat;
reg                                 strWrErrorContAck;
reg                                 clrRdCacheReg;
reg                                 clrRdCacheReg_d;
reg [1:0]                           currStateStrErrorCtrl;
reg [1:0]                           nextStateStrErrorCtrl;
wire                                spaceInStrCache;
reg [31:0]                          strDscrptrPtrRegs [0:3];
integer                             lp_idx;
reg                                 strRdComplete;
reg [1:0]                           strRdDone;
wire                                strFetchError;
reg                                 strFetchError_hold;
wire                                strFetchError_hold_pl;
reg                                 strFetchError_hold_f1;

reg	[2:0]							count_fetch_done;
reg	[2:0]							count_strFetchError;
wire[2:0]							count_diff;
reg									count_diff_zero;
reg									count_strMemMapWrDone;
reg									count_diff_not_zero;
reg									strFetchError_reg;

////////////////////////////////////////////////////////////////////////////////
// Constants
////////////////////////////////////////////////////////////////////////////////
// Stream Descriptor fetch FSM state encoding (one-hot) 
localparam [3:0] STR_FETCH_IDLE                         = 4'b0001;
localparam [3:0] STR_FETCH_WAIT_DSCRPTR_FETCH_AND_TLAST = 4'b0010;
localparam [3:0] STR_FETCH_WAIT_TLAST                   = 4'b0100;
localparam [3:0] STR_FETCH_WAIT_DSCRPTR_FETCH           = 4'b1000; 

// Stream Receive FSM state encoding (one-hot) 
localparam [3:0] STR_RX_IDLE     = 4'b0001;
localparam [3:0] STR_RX_FIRST    = 4'b0010;
localparam [3:0] STR_RX_DATA     = 4'b0100;
localparam [3:0] STR_RX_COMPLETE = 4'b1000;

// Stream error control FSM state encoding (one-hot)
localparam [1:0] STR_ERR_IDLE          = 2'b01;
localparam [1:0] STR_ERR_WAIT_STR_COMP = 2'b10;

////////////////////////////////////////////////////////////////////////////////
// Stream Descriptor Fetch Current State register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                currStateStrFetch <= STR_FETCH_IDLE;
            end
        else
            begin
                currStateStrFetch <= nextStateStrFetch;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// Stream Descriptor Fetch Next state combinatorial logic
////////////////////////////////////////////////////////////////////////////////
always @ (*)
    begin
        // Default assignments
        fetchStrDscrptrReg_d <= 1'b0;
        strDscrptrAddrReg_d  <= 32'b0;
        case (currStateStrFetch)
            STR_FETCH_IDLE:
                begin
                    if (TVALID & spaceInStrCache & ((count_strFetchError == 0) & (count_diff == 1)))
                    //if (TVALID & spaceInStrCache & (strFetchError | strMemMapWrDone))
                        begin
                            fetchStrDscrptrReg_d <= 1'b1;
                            strDscrptrAddrReg_d  <= strDscrptrPtrRegs[TDEST];
                            nextStateStrFetch    <= STR_FETCH_WAIT_DSCRPTR_FETCH_AND_TLAST;
                        end
                    else
                        begin
                            nextStateStrFetch <= STR_FETCH_IDLE;
                        end
                end
            STR_FETCH_WAIT_DSCRPTR_FETCH_AND_TLAST:
                begin
                    if (TVALID & TLAST & TREADY)
                        begin
                            if (strFetchDone)
                                begin
                                    nextStateStrFetch <= STR_FETCH_IDLE;
                                end
                            else
                                begin
                                    fetchStrDscrptrReg_d <= 1'b1;
                                    strDscrptrAddrReg_d  <= strDscrptrAddrReg;
                                    nextStateStrFetch    <= STR_FETCH_WAIT_DSCRPTR_FETCH;
                                end
                        end
                    else
                        begin
                            if (strFetchDone)
                                begin
                                    nextStateStrFetch <= STR_FETCH_WAIT_TLAST;
                                end
                            else
                                begin
                                    fetchStrDscrptrReg_d <= 1'b1;
                                    strDscrptrAddrReg_d  <= strDscrptrAddrReg;
                                    nextStateStrFetch    <= STR_FETCH_WAIT_DSCRPTR_FETCH_AND_TLAST;
                                end
                        end
                end
            STR_FETCH_WAIT_TLAST:
                begin
                    if (TVALID & TLAST & TREADY)
                        begin
                            nextStateStrFetch <= STR_FETCH_IDLE;
                        end
                    else
                        begin
                            nextStateStrFetch <= STR_FETCH_WAIT_TLAST;
                        end
                end
            STR_FETCH_WAIT_DSCRPTR_FETCH:
                begin
                    if (strFetchDone)
                        begin
                            nextStateStrFetch <= STR_FETCH_IDLE;
                        end
                    else
                        begin
                            fetchStrDscrptrReg_d <= 1'b1;
                            strDscrptrAddrReg_d  <= strDscrptrAddrReg;
                            nextStateStrFetch    <= STR_FETCH_WAIT_DSCRPTR_FETCH;
                        end    
                end
            default:
                begin
                    nextStateStrFetch <= STR_FETCH_IDLE;
                end
        endcase
    end

assign strFetchError = strFetchDone & ~dscrptrValid;
////////////////////////////////////////////////////////////////////////////////
// Stream Receive Current State register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                currStateStrRx <= STR_RX_IDLE;
            end
        else
            begin
                currStateStrRx <= nextStateStrRx;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// Stream Receive Next state combinatorial logic
////////////////////////////////////////////////////////////////////////////////
always @ (*)
    begin
        // Default assignments
        TREADYReg_d         <= 1'b0;
        wrEnReg_d           <= 1'b0;
        wrAddrReg_d         <= wrAddrReg;
        wrByteCntReg_d      <= {TRAN_BYTE_CNT_WIDTH{1'b0}};
        wrDataReg_d         <= {DATA_WIDTH{1'b0}};
        strRdCache1SelReg_d <= strRdCache1SelReg;
        //inLastBeat          <= 1'b0;
        strRdComplete       <= 1'b0;
        case (currStateStrRx)
            STR_RX_IDLE:
                begin
                    if (spaceInStrCache)
                        begin
                            if (TVALID)
                                begin
                                    if ((currStateStrFetch == STR_FETCH_IDLE) & ((count_strFetchError == 0) & (count_diff == 1)))
                                        begin
                                            TREADYReg_d    <= 1'b1;
                                            nextStateStrRx <= STR_RX_FIRST;
                                        end
                                    else
                                        begin
                                            // Wait until the stream descriptors
                                            // fetch of the existing stream
                                            // transfer is complete.
                                            nextStateStrRx <= STR_RX_IDLE;
                                        end
                                end
                            else
                                begin
                                    nextStateStrRx <= STR_RX_IDLE;
                                end
                        end
                    else
                        begin
                            // Wait for one of the stream caches to become free
                            // before acking a new stream transaction.
                            nextStateStrRx <= STR_RX_IDLE;
                        end
                end
            STR_RX_FIRST:
                begin
                    if (TVALID & TREADY)
                        begin
                            wrEnReg_d   <= 1'b1;
                            wrDataReg_d <= TDATA;
                            if (TLAST)
                                begin
                                    wrByteCntReg_d <= wrByteCntLast;
                                    nextStateStrRx <= STR_RX_COMPLETE;
                                end
                            else
                                begin
                                    TREADYReg_d    <= 1'b1;
                                    wrByteCntReg_d <= (DATA_WIDTH/8);
                                    nextStateStrRx <= STR_RX_DATA;
                                end
                        end
                    else
                        begin
                            nextStateStrRx <= STR_RX_FIRST;
                            TREADYReg_d    <= 1'b1;
                        end
                end
            STR_RX_DATA:
                begin
                    if (TVALID & TREADY)
                        begin
                            if (strWrErrorContAck)
                                begin
                                    if (TLAST)
                                        begin
                                           // inLastBeat     <= 1'b1;
                                            nextStateStrRx <= STR_RX_COMPLETE;
                                        end
                                    else
                                        begin
                                            TREADYReg_d    <= 1'b1;
                                            nextStateStrRx <= STR_RX_DATA;
                                        end
                                end
                            else
                                begin
                                    // Need to make sure that there's room in the current stream cache before acking the
                                    // AXI4-Stream beat.
                                    if ((noOfBytesInCurrRdCache == MAX_AXI_TRAN_SIZE - (2*(DATA_WIDTH/8))) && (wrEnReg == 1'b1))
                                        begin
                                            // Don't drive TREADY as there's enough data in the pipeline to fill the cache
                                            wrEnReg_d   <= 1'b1;
                                            wrDataReg_d <= TDATA;
                                            wrAddrReg_d <= wrAddrReg + 1'b1;
                                            if (TLAST)
                                                begin
                                                    wrByteCntReg_d <= wrByteCntLast;
                                                    nextStateStrRx <= STR_RX_COMPLETE;
                                                end
                                            else
                                                begin
                                                    wrByteCntReg_d <= (DATA_WIDTH/8);
                                                    nextStateStrRx <= STR_RX_DATA;
                                                end
                                        end
                                    else if (noOfBytesInCurrRdCache == MAX_AXI_TRAN_SIZE - (DATA_WIDTH/8))
                                        begin
                                            // Do nothing as the cache is about to become full. Write in the pipeline
                                            wrEnReg_d   <= 1'b1;
                                            wrDataReg_d <= TDATA;
                                            wrAddrReg_d <= wrAddrReg + 1'b1;
                                            if (TLAST)
                                                begin
                                                    wrByteCntReg_d <= wrByteCntLast;
                                                    nextStateStrRx <= STR_RX_COMPLETE;
                                                end
                                            else
                                                begin
                                                    wrByteCntReg_d <= (DATA_WIDTH/8);
                                                    nextStateStrRx <= STR_RX_DATA;
                                                end
                                        end
                                    else
                                        begin
                                            wrEnReg_d   <= 1'b1;
                                            wrDataReg_d <= TDATA;
                                            wrAddrReg_d <= wrAddrReg + 1'b1;
                                            if (TLAST)
                                                begin
                                                    wrByteCntReg_d <= wrByteCntLast;
                                                    nextStateStrRx <= STR_RX_COMPLETE;
                                                end
                                            else
                                                begin
                                                    TREADYReg_d    <= 1'b1;
                                                    wrByteCntReg_d <= (DATA_WIDTH/8);
                                                    nextStateStrRx <= STR_RX_DATA;
                                                end
                                        end
                                        
                                end
                        end
                    else
                        begin
                            // Need to make sure that there's room in the current stream cache before acking the
                            // AXI4-Stream beat.
                            if ((noOfBytesInCurrRdCache == MAX_AXI_TRAN_SIZE - (DATA_WIDTH/8)) && (wrEnReg == 1'b1))
                                begin
                                    // Do nothing as the cache is about to become full. Write in the pipeline
                                end
                            else if (noOfBytesInCurrRdCache > MAX_AXI_TRAN_SIZE - (DATA_WIDTH/8))
                                begin
                                    // Do nothing as the cache is full
                                end
                            else
                                begin
                                    TREADYReg_d <= 1'b1;
                                end
                            nextStateStrRx <= STR_RX_DATA;
                        end
                end
            STR_RX_COMPLETE:
                begin
                    strRdComplete       <= 1'b1;
                    strRdCache1SelReg_d <= ~strRdCache1SelReg;
                    wrAddrReg_d         <= {STR_CACHE_DEPTH_WIDTH{1'b0}};
                    nextStateStrRx      <= STR_RX_IDLE;
                end
            default:
                begin
                    nextStateStrRx <= STR_RX_IDLE;
                end
        endcase
    end

////////////////////////////////////////////////////////////////////////////////
// TREADY register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                TREADYReg <= 1'b0;
            end
        else
            begin
                TREADYReg <= TREADYReg_d;
            end
    end
assign TREADY = TREADYReg;

////////////////////////////////////////////////////////////////////////////////
// fetchStrDscrptr register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                fetchStrDscrptrReg <= 1'b0;
            end
        else
            begin
                fetchStrDscrptrReg <= fetchStrDscrptrReg_d;
            end
    end
assign fetchStrDscrptr = fetchStrDscrptrReg;

////////////////////////////////////////////////////////////////////////////////
// strDscrptrAddr register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                strDscrptrAddrReg <= 32'b0;
            end
        else
            begin
                strDscrptrAddrReg <= strDscrptrAddrReg_d;
            end
    end
assign strDscrptrAddr = strDscrptrAddrReg;

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
// wrAddr register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                wrAddrReg <= {STR_CACHE_DEPTH_WIDTH{1'b0}};
            end
        else
            begin
                wrAddrReg <= wrAddrReg_d;
            end
    end
assign wrAddr = wrAddrReg;

////////////////////////////////////////////////////////////////////////////////
// wrByteCnt register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                wrByteCntReg <= {TRAN_BYTE_CNT_WIDTH{1'b0}};
            end
        else
            begin
                wrByteCntReg <= wrByteCntReg_d;
            end
    end
assign wrByteCnt = wrByteCntReg;

////////////////////////////////////////////////////////////////////////////////
// wrData register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                wrDataReg <= {DATA_WIDTH{1'b0}};
            end
        else
            begin
                wrDataReg <= wrDataReg_d;
            end
    end
assign wrData = wrDataReg;

generate
    if (DATA_WIDTH == 32)
        begin
            assign wrByteCntLast = (TSTRB == 4'b0001) ? 3'd1 :
                                   (TSTRB == 4'b0011) ? 3'd2 :
                                   (TSTRB == 4'b0111) ? 3'd3 :
                                   (TSTRB == 4'b1111) ? 3'd4 :
                                   3'd0;
        end
    else if (DATA_WIDTH == 64)
        begin
            assign wrByteCntLast = (TSTRB == 8'b0000_0001) ? 4'd1 :
                                   (TSTRB == 8'b0000_0011) ? 4'd2 :
                                   (TSTRB == 8'b0000_0111) ? 4'd3 :
                                   (TSTRB == 8'b0000_1111) ? 4'd4 :
                                   (TSTRB == 8'b0001_1111) ? 4'd5 :
                                   (TSTRB == 8'b0011_1111) ? 4'd6 :
                                   (TSTRB == 8'b0111_1111) ? 4'd7 :
                                   (TSTRB == 8'b1111_1111) ? 4'd8 :
                                   4'd0;
        end
    else if (DATA_WIDTH == 128)
        begin
            assign wrByteCntLast = (TSTRB == 16'b0000_0000_0000_0001) ? 5'd1  :
                                   (TSTRB == 16'b0000_0000_0000_0011) ? 5'd2  :
                                   (TSTRB == 16'b0000_0000_0000_0111) ? 5'd3  :
                                   (TSTRB == 16'b0000_0000_0000_1111) ? 5'd4  :
                                   (TSTRB == 16'b0000_0000_0001_1111) ? 5'd5  :
                                   (TSTRB == 16'b0000_0000_0011_1111) ? 5'd6  :
                                   (TSTRB == 16'b0000_0000_0111_1111) ? 5'd7  :
                                   (TSTRB == 16'b0000_0000_1111_1111) ? 5'd8  :
                                   (TSTRB == 16'b0000_0001_1111_1111) ? 5'd9  :
                                   (TSTRB == 16'b0000_0011_1111_1111) ? 5'd10 :
                                   (TSTRB == 16'b0000_0111_1111_1111) ? 5'd11 :
                                   (TSTRB == 16'b0000_1111_1111_1111) ? 5'd12 :
                                   (TSTRB == 16'b0001_1111_1111_1111) ? 5'd13 :
                                   (TSTRB == 16'b0011_1111_1111_1111) ? 5'd14 :
                                   (TSTRB == 16'b0111_1111_1111_1111) ? 5'd15 :
                                   (TSTRB == 16'b1111_1111_1111_1111) ? 5'd16 :
                                   5'd0;
        end
    else if (DATA_WIDTH == 256)
        begin
            assign wrByteCntLast = (TSTRB == 32'b0000_0000_0000_0000_0000_0000_0000_0001) ? 6'd1  :
                                   (TSTRB == 32'b0000_0000_0000_0000_0000_0000_0000_0011) ? 6'd2  :
                                   (TSTRB == 32'b0000_0000_0000_0000_0000_0000_0000_0111) ? 6'd3  :
                                   (TSTRB == 32'b0000_0000_0000_0000_0000_0000_0000_1111) ? 6'd4  :
                                   (TSTRB == 32'b0000_0000_0000_0000_0000_0000_0001_1111) ? 6'd5  :
                                   (TSTRB == 32'b0000_0000_0000_0000_0000_0000_0011_1111) ? 6'd6  :
                                   (TSTRB == 32'b0000_0000_0000_0000_0000_0000_0111_1111) ? 6'd7  :
                                   (TSTRB == 32'b0000_0000_0000_0000_0000_0000_1111_1111) ? 6'd8  :
                                   (TSTRB == 32'b0000_0000_0000_0000_0000_0001_1111_1111) ? 6'd9  :
                                   (TSTRB == 32'b0000_0000_0000_0000_0000_0011_1111_1111) ? 6'd10 :
                                   (TSTRB == 32'b0000_0000_0000_0000_0000_0111_1111_1111) ? 6'd11 :
                                   (TSTRB == 32'b0000_0000_0000_0000_0000_1111_1111_1111) ? 6'd12 :
                                   (TSTRB == 32'b0000_0000_0000_0000_0001_1111_1111_1111) ? 6'd13 :
                                   (TSTRB == 32'b0000_0000_0000_0000_0011_1111_1111_1111) ? 6'd14 :
                                   (TSTRB == 32'b0000_0000_0000_0000_0111_1111_1111_1111) ? 6'd15 :
                                   (TSTRB == 32'b0000_0000_0000_0000_1111_1111_1111_1111) ? 6'd16 :
                                   (TSTRB == 32'b0000_0000_0000_0001_1111_1111_1111_1111) ? 6'd17 :
                                   (TSTRB == 32'b0000_0000_0000_0011_1111_1111_1111_1111) ? 6'd18 :
                                   (TSTRB == 32'b0000_0000_0000_0111_1111_1111_1111_1111) ? 6'd19 :
                                   (TSTRB == 32'b0000_0000_0000_1111_1111_1111_1111_1111) ? 6'd20 :
                                   (TSTRB == 32'b0000_0000_0001_1111_1111_1111_1111_1111) ? 6'd21 :
                                   (TSTRB == 32'b0000_0000_0011_1111_1111_1111_1111_1111) ? 6'd22 :
                                   (TSTRB == 32'b0000_0000_0111_1111_1111_1111_1111_1111) ? 6'd23 :
                                   (TSTRB == 32'b0000_0000_1111_1111_1111_1111_1111_1111) ? 6'd24 :
                                   (TSTRB == 32'b0000_0001_1111_1111_1111_1111_1111_1111) ? 6'd25 :
                                   (TSTRB == 32'b0000_0011_1111_1111_1111_1111_1111_1111) ? 6'd26 :
                                   (TSTRB == 32'b0000_0111_1111_1111_1111_1111_1111_1111) ? 6'd27 :
                                   (TSTRB == 32'b0000_1111_1111_1111_1111_1111_1111_1111) ? 6'd28 :
                                   (TSTRB == 32'b0001_1111_1111_1111_1111_1111_1111_1111) ? 6'd29 :
                                   (TSTRB == 32'b0011_1111_1111_1111_1111_1111_1111_1111) ? 6'd30 :
                                   (TSTRB == 32'b0111_1111_1111_1111_1111_1111_1111_1111) ? 6'd31 :
                                   (TSTRB == 32'b1111_1111_1111_1111_1111_1111_1111_1111) ? 6'd32 :
                                   6'd0;
        end
    else if (DATA_WIDTH == 512)
        begin
            assign wrByteCntLast = (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001) ? 7'd1  :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0011) ? 7'd2  :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0111) ? 7'd3  :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1111) ? 7'd4  :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_1111) ? 7'd5  :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0011_1111) ? 7'd6  :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0111_1111) ? 7'd7  :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1111_1111) ? 7'd8  :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_1111_1111) ? 7'd9  :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0011_1111_1111) ? 7'd10 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0111_1111_1111) ? 7'd11 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1111_1111_1111) ? 7'd12 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_1111_1111_1111) ? 7'd13 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0011_1111_1111_1111) ? 7'd14 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0111_1111_1111_1111) ? 7'd15 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1111_1111_1111_1111) ? 7'd16 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_1111_1111_1111_1111) ? 7'd17 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0011_1111_1111_1111_1111) ? 7'd18 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0111_1111_1111_1111_1111) ? 7'd19 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1111_1111_1111_1111_1111) ? 7'd20 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_1111_1111_1111_1111_1111) ? 7'd21 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0011_1111_1111_1111_1111_1111) ? 7'd22 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0111_1111_1111_1111_1111_1111) ? 7'd23 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_1111_1111_1111_1111_1111_1111) ? 7'd24 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0001_1111_1111_1111_1111_1111_1111) ? 7'd25 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0011_1111_1111_1111_1111_1111_1111) ? 7'd26 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0111_1111_1111_1111_1111_1111_1111) ? 7'd27 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0000_1111_1111_1111_1111_1111_1111_1111) ? 7'd28 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0001_1111_1111_1111_1111_1111_1111_1111) ? 7'd29 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0011_1111_1111_1111_1111_1111_1111_1111) ? 7'd30 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_0111_1111_1111_1111_1111_1111_1111_1111) ? 7'd31 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0000_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd32 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0001_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd33 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0011_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd34 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_0111_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd35 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0000_1111_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd36 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0001_1111_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd37 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0011_1111_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd38 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_0111_1111_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd39 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0000_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd40 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0001_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd41 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0011_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd42 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_0111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd43 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0000_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd44 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0001_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd45 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0011_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd46 :
                                   (TSTRB == 64'b0000_0000_0000_0000_0111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd47 :
                                   (TSTRB == 64'b0000_0000_0000_0000_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd48 :
                                   (TSTRB == 64'b0000_0000_0000_0001_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd49 :
                                   (TSTRB == 64'b0000_0000_0000_0011_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd50 :
                                   (TSTRB == 64'b0000_0000_0000_0111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd51 :
                                   (TSTRB == 64'b0000_0000_0000_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd52 :
                                   (TSTRB == 64'b0000_0000_0001_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd53 :
                                   (TSTRB == 64'b0000_0000_0011_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd54 :
                                   (TSTRB == 64'b0000_0000_0111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd55 :
                                   (TSTRB == 64'b0000_0000_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd56 :
                                   (TSTRB == 64'b0000_0001_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd57 :
                                   (TSTRB == 64'b0000_0011_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd58 :
                                   (TSTRB == 64'b0000_0111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd59 :
                                   (TSTRB == 64'b0000_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd60 :
                                   (TSTRB == 64'b0001_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd61 :
                                   (TSTRB == 64'b0011_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd62 :
                                   (TSTRB == 64'b0111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd63 :
                                   (TSTRB == 64'b1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111_1111) ? 7'd64 :
                                   7'd0;
        end
endgenerate

////////////////////////////////////////////////////////////////////////////////
// Register keeping track of AXI4-Stream read status
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                strRdDone[1:0] <= 2'b00;
            end
        else
            begin
                if (strRdComplete)
                    begin
                        strRdDone[strRdCache1Sel] <= 1'b1;
                    end
                else if (strMemMapWrDone|strMemMapWrError|strFetchError_reg)
                    begin
                        strRdDone[strWrCache1Sel] <= 1'b0;
                    end
            end
    end

////////////////////////////////////////////////////////////////////////////////
// strCacheInUse Counter
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                strCacheInUse <= 2'b0;
            end
        else
            begin
                case ({strMemMapWrDone|strMemMapWrError|strFetchError, strFetchDone})
                    2'b00, 2'b11:
                        begin
                            strCacheInUse <= strCacheInUse;
                        end
                    2'b01:
                        begin
                            strCacheInUse <= strCacheInUse + 1'b1;
                        end
                    2'b10:
                        begin
                            strCacheInUse <= strCacheInUse - 1'b1;
                        end
                endcase
            end
    end
assign spaceInStrCache = (strCacheInUse != 2'b10);

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                strRdCache1SelReg <= 1'b0;
            end
        else
            begin
                strRdCache1SelReg <= strRdCache1SelReg_d;
            end
    end
assign strRdCache1Sel = strRdCache1SelReg;

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                strFetchError_hold_f1 <= 1'b0;
            end
        else
            begin
                strFetchError_hold_f1 <= strFetchError_hold;
            end
    end

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                strFetchError_hold <= 1'b0;
            end
        else if (strFetchError)
            begin
                strFetchError_hold <= 1'b1;		
            end
        else if (strMemMapWrDone|strMemMapWrError)
            begin
                strFetchError_hold <= 1'b0;		
            end			

    end
	
assign strFetchError_hold_pl = ~strFetchError_hold & strFetchError_hold_f1;

///hdl changes////



always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                strFetchError_reg <= 1'b0;
            end
        else
            begin
                strFetchError_reg <= strFetchError;
            end
    end
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                count_fetch_done <= 3'b0;
            end
        else
            begin
                if(strFetchDone)
					begin
						if(count_fetch_done == 3'd2)
							begin
								if(!strFetchError)
									begin
										count_fetch_done <= 3'b0;
									end
							end
						else
							count_fetch_done <= count_fetch_done + 1'b1;
					end	
				else if (strMemMapWrDone|strMemMapWrError | (count_diff == 0) )
					count_fetch_done <= count_fetch_done - 1'b1;
            end
    end
	
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                count_strFetchError <= 3'b0;
            end
        else
            begin
                if(strFetchError)
					count_strFetchError <= count_strFetchError + 1'b1;
				else if (count_diff == 0)
					count_strFetchError <= count_strFetchError - 1'b1;				
            end
    end
	
assign count_diff = (count_strFetchError == 0)? 1'b1 : (count_fetch_done - count_strFetchError);


always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                count_diff_zero <= 1'b0;
            end
        else if((count_fetch_done != 0) & (count_strFetchError !=0))
            begin
                count_diff_zero <= (count_diff==0);
            end
		else 
            begin
                count_diff_zero <= 1'b0;
            end					
    end
	


/////////end//////

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                strWrCache1SelReg <= 1'b0;
            end
        else
            begin	
                if (count_diff_zero | strMemMapWrDone|strMemMapWrError )
                    begin
                        strWrCache1SelReg <= ~strWrCache1SelReg;
                    end
				
                //if (strMemMapWrDone|strMemMapWrError | strFetchError_hold_pl)
                //    begin
                //        strWrCache1SelReg <= ~strWrCache1SelReg;
                //    end
            end
    end
assign strWrCache1Sel = strWrCache1SelReg;

////////////////////////////////////////////////////////////////////////////////
// Stream error control current state register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                currStateStrErrorCtrl <= STR_ERR_IDLE;
            end
        else
            begin
                currStateStrErrorCtrl <= nextStateStrErrorCtrl;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// Combinatorial logic to handle Stream memory map write errors
////////////////////////////////////////////////////////////////////////////////
always @ (*)
    begin
        // Default assignments
        strWrErrorContAck = 1'b0;
        clrRdCacheReg_d   = 1'b0;
        case (currStateStrErrorCtrl)
            STR_ERR_IDLE:
                begin
                    //if (strFetchError)
                    //if ((count_strFetchError !=0) & strMemMapWrDone)
					if (count_diff == 0)
                        begin
                            // Stream descriptor's descriptor valid bit was low when
                            // fetched. Reading and writing from the same stream cache
                            if (strRdDone[strWrCache1Sel] == 1'b1)
                                begin
                                    // Stream read is already completed so just clear
                                    // the cache
                                    clrRdCacheReg_d       = 1'b1;
                                    nextStateStrErrorCtrl = STR_ERR_IDLE;
                                end
                            //else if (inLastBeat)
                            else if (TVALID & TREADY & TLAST)
                                begin
                                    // Clear the contents of the cache when the stream rx
                                    // operation is complete
                                    clrRdCacheReg_d       = 1'b1;
                                    nextStateStrErrorCtrl = STR_ERR_IDLE;
                                end
                            else
                                begin
                                    // Continue acking stream transfers but don't
                                    // write them to the cache.
                                    clrRdCacheReg_d       = 1'b1;
                                    strWrErrorContAck     = 1'b1;
                                    nextStateStrErrorCtrl = STR_ERR_WAIT_STR_COMP;
                                end
                        end
                    else if (strMemMapWrError)
                        begin
                            if (strWrCache1Sel == strRdCache1Sel)
                                begin
                                    // Reading and writing from the same stream cache
                                     if (strRdDone[strWrCache1Sel] == 1'b1)
                                        begin
                                            // Stream read is already complete
                                            clrRdCacheReg_d       = 1'b1;
                                            nextStateStrErrorCtrl = STR_ERR_IDLE;
                                        end
                                     //else if (inLastBeat)
									 else if (TVALID & TREADY & TLAST)
                                        begin
                                            // Clear the contents of the cache when the stream rx
                                            // operation is complete
                                            clrRdCacheReg_d       = 1'b1;
                                            nextStateStrErrorCtrl = STR_ERR_IDLE;
                                        end
                                    else
                                        begin
                                            // Continue acking stream transfers but don't
                                            // write them to the cache.
                                            clrRdCacheReg_d       = 1'b1;
                                            strWrErrorContAck     = 1'b1;
                                            nextStateStrErrorCtrl = STR_ERR_WAIT_STR_COMP;
                                        end
                                end
                            else
                                begin
                                    // Clear the contents of the stream cache
                                    clrRdCacheReg_d       = 1'b1;
                                    nextStateStrErrorCtrl = STR_ERR_IDLE;
                                end
                        end
                    else
                        begin
                            // No errors detected
                            nextStateStrErrorCtrl = STR_ERR_IDLE;
                        end
                end
            STR_ERR_WAIT_STR_COMP:
                begin
                    // Reading and writing from the same stream cache
                    //if (inLastBeat)
					if (TVALID & TREADY & TLAST)
                        begin
                            // Clear the contents of the cache when the stream rx
                            // operation is complete
                            clrRdCacheReg_d       = 1'b1;
                            nextStateStrErrorCtrl = STR_ERR_IDLE;
                        end
                    else
                        begin
                            // Continue acking stream transfers but don't
                            // write them to the cache.
                            clrRdCacheReg_d       = 1'b1;
                            strWrErrorContAck     = 1'b1;
                            nextStateStrErrorCtrl = STR_ERR_WAIT_STR_COMP;
                        end
                end
            default:
                begin
                    nextStateStrErrorCtrl = STR_ERR_IDLE;
                end
        endcase
    end

////////////////////////////////////////////////////////////////////////////////
// clrRdCache register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                clrRdCacheReg <= 1'b0;
            end
        else
            begin
                clrRdCacheReg <= clrRdCacheReg_d;
            end
    end
assign clrRdCache = clrRdCacheReg;

////////////////////////////////////////////////////////////////////////////////
// strDscrptrPtrRegs - Holds the address of Stream descriptors associated with TDEST
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        for (lp_idx = 0; lp_idx < 4; lp_idx = lp_idx + 1)
            begin
                if (!resetn)
                    begin
                        strDscrptrPtrRegs[lp_idx] <= 32'b0;
                    end
                else
                    begin
                        if (ctrlSel & ctrlWr & (ctrlAddr[10:2] == {STR_DSCRPTR_ADDR_REG_0[10:4], lp_idx[1:0]}))
                            begin
                                if (ctrlWrStrbs[0])
                                    begin
                                        strDscrptrPtrRegs[lp_idx][7:0] <= ctrlWrData[7:0];
                                    end
                                else
                                    begin
                                        strDscrptrPtrRegs[lp_idx][7:0] <= strDscrptrPtrRegs[lp_idx][7:0];
                                    end
                                if (ctrlWrStrbs[1])
                                    begin
                                        strDscrptrPtrRegs[lp_idx][15:8] <= ctrlWrData[15:8];
                                    end
                                else
                                    begin
                                        strDscrptrPtrRegs[lp_idx][15:8] <= strDscrptrPtrRegs[lp_idx][15:8];
                                    end
                                if (ctrlWrStrbs[2])
                                    begin
                                        strDscrptrPtrRegs[lp_idx][23:16] <= ctrlWrData[23:16];
                                    end
                                else
                                    begin
                                        strDscrptrPtrRegs[lp_idx][23:16] <= strDscrptrPtrRegs[lp_idx][23:16];
                                    end
                                if (ctrlWrStrbs[3])
                                    begin
                                        strDscrptrPtrRegs[lp_idx][31:24] <= ctrlWrData[31:24];
                                    end
                                else
                                    begin
                                        strDscrptrPtrRegs[lp_idx][31:24] <= strDscrptrPtrRegs[lp_idx][31:24];
                                    end
                            end
                        else
                            begin
                                strDscrptrPtrRegs[lp_idx][31:0] <= strDscrptrPtrRegs[lp_idx][31:0];
                            end
                    end
            end
    end

// Read data always ready
assign ctrlRdValid      = 1'b1;
assign ctrlRdData[31:0] = (ctrlAddr[10:4] == STR_DSCRPTR_ADDR_REG_0[10:4]) ? strDscrptrPtrRegs[ctrlAddr[3:2]] : 32'b0;

endmodule // CoreAXI4DMAController_AXI4StreamSlaveCtrl