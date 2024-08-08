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
module CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_wrTranQueue (
    // General inputs
    clock,
    resetn,

    // DMAArbiter inputs
    doTrans,
    strDscrptr_DMAArbiter,
    intDscrptrNum_DMAArbiter,
    extDscrptrAddr_DMAArbiter,
    extDscrptr_DMAArbiter,
    dataValid_DMAArbiter,
    dstAddr_DMAArbiter,
    dstOp_DMAArbiter,
    dstDataWidth_DMAArbiter,
    srcDataWidth_DMAArbiter,
    numOfBytes_DMAArbiter,
    priLvl_DMAArbiter,
    chain_DMAArbiter,
    extDscrptrNxt_DMAArbiter,
    intOnProcess_DMAArbiter,
    nxtDscrptrNumAddr_DMAArbiter,

    // intErrorCtrl inputs
    clrWrTranQueue,
    wrCache1Sel,
    
    // rdTranCtrl inputs
    rdyToAck,
    extDataValid,
    rdCache1Sel,

    // wrTranCtrl outputs
    reqInQueue,
    strDscrptr,
    priLvl,
    dataValid,
    dstOp,
    dstDataWidth,
    srcDataWidth,
    dstAddr_wrCache1Sel,
    dstAddr_rdCache1Sel,
    numOfBytes,
    intDscrptrNum_wrTranQueue0,
    intDscrptrNum_wrTranQueue1,
    extDscrptrAddr,
    extDscrptr,
    
    // intErrorCtrl outputs
    chain,
    extDscrptrNxt,
    intOnProcess,
    nxtDscrptrNumAddr,

    // transAck outputs. Some are shared with wrTranCtrl block
    spaceWrTranQueue
);

////////////////////////////////////////////////////////////////////////////////
// Parameters
////////////////////////////////////////////////////////////////////////////////
parameter   NUM_INT_BDS         = 0;
parameter   NUM_INT_BDS_WIDTH   = 5;
parameter   NUM_PRI_LVLS        = 1;
parameter   MAX_TRAN_SIZE_WIDTH = 23;

////////////////////////////////////////////////////////////////////////////////
// Port directions
////////////////////////////////////////////////////////////////////////////////
// General inputs
input                                   clock;
input                                   resetn;

// DMAArbiter inputs
input                                   doTrans;
input                                   strDscrptr_DMAArbiter;
input       [NUM_INT_BDS_WIDTH-1:0]     intDscrptrNum_DMAArbiter;
input       [31:0]                      extDscrptrAddr_DMAArbiter;
input                                   extDscrptr_DMAArbiter;
input                                   dataValid_DMAArbiter;
input       [31:0]                      dstAddr_DMAArbiter;
input       [1:0]                       dstOp_DMAArbiter;
input       [2:0]                       dstDataWidth_DMAArbiter;
input       [2:0]                       srcDataWidth_DMAArbiter;
input       [MAX_TRAN_SIZE_WIDTH-1:0]   numOfBytes_DMAArbiter;
input       [NUM_PRI_LVLS-1:0]          priLvl_DMAArbiter;
input                                   chain_DMAArbiter;
input                                   extDscrptrNxt_DMAArbiter;
input                                   intOnProcess_DMAArbiter;
input       [31:0]                      nxtDscrptrNumAddr_DMAArbiter;

// intErrorCtrl inputs
input       [1:0]                       clrWrTranQueue;
input                                   wrCache1Sel;

// rdTranCtrl inputs
input                                   rdyToAck;
input                                   extDataValid;
input                                   rdCache1Sel;

// wrTranCtrl outputs
output                                  reqInQueue;
output                                  strDscrptr;
output                                  dataValid;
output reg  [NUM_INT_BDS_WIDTH-1:0]     intDscrptrNum_wrTranQueue0;
output reg  [NUM_INT_BDS_WIDTH-1:0]     intDscrptrNum_wrTranQueue1;
output      [31:0]                      extDscrptrAddr;
output                                  extDscrptr;
output      [1:0]                       dstOp;
output      [2:0]                       dstDataWidth;
output      [2:0]                       srcDataWidth;
output      [31:0]                      dstAddr_wrCache1Sel;
output      [31:0]                      dstAddr_rdCache1Sel;
output      [MAX_TRAN_SIZE_WIDTH-1:0]   numOfBytes;
output      [NUM_PRI_LVLS-1:0]          priLvl;
output                                  chain;
output                                  extDscrptrNxt;
output                                  intOnProcess;
output      [31:0]                      nxtDscrptrNumAddr;

// transAck outputs. Some are shared with wrTranCtrl block
output                                  spaceWrTranQueue;

////////////////////////////////////////////////////////////////////////////////
// Internal signals
////////////////////////////////////////////////////////////////////////////////
reg [1:0]                               reqCnt;
reg [31:0]                              extDscrptrAddr_wrTranQueue0;
reg                                     extDscrptr_wrTranQueue0;
reg                                     dataValid_wrTranQueue0;
reg [31:0]                              dstAddr_wrTranQueue0;
reg [1:0]                               dstOp_wrTranQueue0;
reg [2:0]                               dstDataWidth_wrTranQueue0;
reg [2:0]                               srcDataWidth_wrTranQueue0;
reg [MAX_TRAN_SIZE_WIDTH-1:0]           numOfBytes_wrTranQueue0;
reg [NUM_PRI_LVLS-1:0]                  priLvl_wrTranQueue0;
reg                                     chain_wrTranQueue0;
reg                                     extDscrptrNxt_wrTranQueue0;
reg                                     intOnProcess_wrTranQueue0;
reg [31:0]                              nxtDscrptrNumAddr_WrTranQueue0;
reg [31:0]                              extDscrptrAddr_wrTranQueue1;
reg                                     extDscrptr_wrTranQueue1;
reg                                     dataValid_wrTranQueue1;
reg [31:0]                              dstAddr_wrTranQueue1;
reg [1:0]                               dstOp_wrTranQueue1;
reg [2:0]                               dstDataWidth_wrTranQueue1;
reg [2:0]                               srcDataWidth_wrTranQueue1;
reg [MAX_TRAN_SIZE_WIDTH-1:0]           numOfBytes_wrTranQueue1;
reg [NUM_PRI_LVLS-1:0]                  priLvl_wrTranQueue1;
reg                                     chain_wrTranQueue1;
reg                                     extDscrptrNxt_wrTranQueue1;
reg                                     intOnProcess_wrTranQueue1;
reg [31:0]                              nxtDscrptrNumAddr_WrTranQueue1;
reg [1:0]                               dataValidReg;
reg                                     wrCacheSelDMAArbiter;
reg                                     strDscrptr_wrTranQueue0;
reg                                     strDscrptr_wrTranQueue1;

////////////////////////////////////////////////////////////////////////////////
// Counter keeping track of the number of requests in queue
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                reqCnt <= 2'b0;
            end
        else
            begin
                case ({doTrans, clrWrTranQueue[1], clrWrTranQueue[0]})
                    3'b000, 3'b101, 3'b110:
                        begin
                            reqCnt <= reqCnt;
                        end
                    3'b001, 3'b010, 3'b111:
                        begin
                            reqCnt <= reqCnt - 1'b1;
                        end
                    3'b011:
                        begin
                            reqCnt <= reqCnt - 2'b10;
                        end
                    3'b100:
                        begin
                            reqCnt <= reqCnt + 1'b1;
                        end
                endcase
            end
    end

////////////////////////////////////////////////////////////////////////////////
// Register keeping track of dataValid bit
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                dataValidReg[1:0] <= 2'b0; 
            end
        else
            begin
                if ((rdyToAck & extDataValid) || (strDscrptr_DMAArbiter))
                    begin
                        dataValidReg[rdCache1Sel] <= 1'b1;
                    end
                else if (|clrWrTranQueue == 1'b1)
                    begin
                        dataValidReg[wrCache1Sel] <= 1'b0;
                    end
            end
    end

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                wrCacheSelDMAArbiter <= 1'b0;
            end
        else if (doTrans)
            begin
                wrCacheSelDMAArbiter <= ~wrCacheSelDMAArbiter;
            end
    end

// Only present external descriptors with data ready asserted to the write trans controller
assign reqInQueue = (reqCnt != 2'b0) ? (wrCache1Sel == 1'b1) ? dataValidReg[1] : dataValidReg[0] : 1'b0;

assign spaceWrTranQueue = (reqCnt < 2'b10) ? 1'b1 : 1'b0;

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                // Reset
                strDscrptr_wrTranQueue0         <= 1'b0;
                intDscrptrNum_wrTranQueue0      <= {NUM_INT_BDS_WIDTH{1'b0}};
                extDscrptrAddr_wrTranQueue0     <= 32'b0;
                extDscrptr_wrTranQueue0         <= 1'b0;
                dataValid_wrTranQueue0          <= 1'b0;
                dstAddr_wrTranQueue0            <= 32'b0;
                dstOp_wrTranQueue0              <= 2'b0;
                dstDataWidth_wrTranQueue0       <= 3'b0;
                srcDataWidth_wrTranQueue0       <= 3'b0;
                numOfBytes_wrTranQueue0         <= {MAX_TRAN_SIZE_WIDTH{1'b0}};
                priLvl_wrTranQueue0             <= {NUM_PRI_LVLS{1'b0}};
                chain_wrTranQueue0              <= 1'b0;
                extDscrptrNxt_wrTranQueue0      <= 1'b0;
                intOnProcess_wrTranQueue0       <= 1'b0;
                nxtDscrptrNumAddr_WrTranQueue0  <= 32'b0;
            end
        else
            begin
                if (doTrans & !wrCacheSelDMAArbiter)
                    begin
                        // Store
                        strDscrptr_wrTranQueue0         <= strDscrptr_DMAArbiter;
                        intDscrptrNum_wrTranQueue0      <= intDscrptrNum_DMAArbiter;
                        extDscrptrAddr_wrTranQueue0     <= extDscrptrAddr_DMAArbiter;
                        extDscrptr_wrTranQueue0         <= extDscrptr_DMAArbiter;
                        dataValid_wrTranQueue0          <= dataValid_DMAArbiter;
                        dstAddr_wrTranQueue0            <= dstAddr_DMAArbiter;
                        dstOp_wrTranQueue0              <= dstOp_DMAArbiter;
                        dstDataWidth_wrTranQueue0       <= dstDataWidth_DMAArbiter;
                        srcDataWidth_wrTranQueue0       <= srcDataWidth_DMAArbiter;
                        numOfBytes_wrTranQueue0         <= numOfBytes_DMAArbiter;
                        priLvl_wrTranQueue0             <= priLvl_DMAArbiter;
                        chain_wrTranQueue0              <= chain_DMAArbiter;
                        extDscrptrNxt_wrTranQueue0      <= extDscrptrNxt_DMAArbiter;
                        intOnProcess_wrTranQueue0       <= intOnProcess_DMAArbiter;
                        nxtDscrptrNumAddr_WrTranQueue0  <= nxtDscrptrNumAddr_DMAArbiter;
                    end
            end
    end

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                // Reset
                strDscrptr_wrTranQueue1         <= 1'b0;
                intDscrptrNum_wrTranQueue1      <= {NUM_INT_BDS_WIDTH{1'b0}};
                extDscrptrAddr_wrTranQueue1     <= 32'b0;
                extDscrptr_wrTranQueue1         <= 1'b0;
                dataValid_wrTranQueue1          <= 1'b0;
                dstAddr_wrTranQueue1            <= 32'b0;
                dstOp_wrTranQueue1              <= 2'b0;
                dstDataWidth_wrTranQueue1       <= 3'b0;
                srcDataWidth_wrTranQueue1       <= 3'b0;
                numOfBytes_wrTranQueue1         <= {MAX_TRAN_SIZE_WIDTH{1'b0}};
                priLvl_wrTranQueue1             <= {NUM_PRI_LVLS{1'b0}};
                chain_wrTranQueue1              <= 1'b0;
                extDscrptrNxt_wrTranQueue1      <= 1'b0;
                intOnProcess_wrTranQueue1       <= 1'b0;
                nxtDscrptrNumAddr_WrTranQueue1  <= 32'b0;
            end
        else
            begin
                if (doTrans & wrCacheSelDMAArbiter)
                    begin
                        // Store
                        strDscrptr_wrTranQueue1         <= strDscrptr_DMAArbiter;
                        intDscrptrNum_wrTranQueue1      <= intDscrptrNum_DMAArbiter;
                        extDscrptrAddr_wrTranQueue1     <= extDscrptrAddr_DMAArbiter;
                        extDscrptr_wrTranQueue1         <= extDscrptr_DMAArbiter;
                        dataValid_wrTranQueue1          <= dataValid_DMAArbiter;
                        dstAddr_wrTranQueue1            <= dstAddr_DMAArbiter;
                        dstOp_wrTranQueue1              <= dstOp_DMAArbiter;
                        dstDataWidth_wrTranQueue1       <= dstDataWidth_DMAArbiter;
                        srcDataWidth_wrTranQueue1       <= srcDataWidth_DMAArbiter;
                        numOfBytes_wrTranQueue1         <= numOfBytes_DMAArbiter;
                        priLvl_wrTranQueue1             <= priLvl_DMAArbiter;
                        chain_wrTranQueue1              <= chain_DMAArbiter;
                        extDscrptrNxt_wrTranQueue1      <= extDscrptrNxt_DMAArbiter;
                        intOnProcess_wrTranQueue1       <= intOnProcess_DMAArbiter;
                        nxtDscrptrNumAddr_WrTranQueue1  <= nxtDscrptrNumAddr_DMAArbiter;
                    end
            end
    end

////////////////////////////////////////////////////////////////////////////////
// Internal muxes
// For signals which are only referenced whilst the request is being operated on
////////////////////////////////////////////////////////////////////////////////
assign strDscrptr                   = (wrCache1Sel) ? strDscrptr_wrTranQueue1        : strDscrptr_wrTranQueue0;
assign dstOp                        = (wrCache1Sel) ? dstOp_wrTranQueue1             : dstOp_wrTranQueue0;
assign extDscrptrAddr               = (wrCache1Sel) ? extDscrptrAddr_wrTranQueue1    : extDscrptrAddr_wrTranQueue0;
assign extDscrptr                   = (wrCache1Sel) ? extDscrptr_wrTranQueue1        : extDscrptr_wrTranQueue0;
assign dataValid                    = (wrCache1Sel) ? dataValid_wrTranQueue1         : dataValid_wrTranQueue0;
assign dstDataWidth                 = (wrCache1Sel) ? dstDataWidth_wrTranQueue1      : dstDataWidth_wrTranQueue0;
assign srcDataWidth                 = (wrCache1Sel) ? srcDataWidth_wrTranQueue1      : srcDataWidth_wrTranQueue0;
assign dstAddr_wrCache1Sel          = (wrCache1Sel) ? dstAddr_wrTranQueue1           : dstAddr_wrTranQueue0;
assign numOfBytes                   = (wrCache1Sel) ? numOfBytes_wrTranQueue1        : numOfBytes_wrTranQueue0;
assign priLvl                       = (wrCache1Sel) ? priLvl_wrTranQueue1            : priLvl_wrTranQueue0;
assign chain                        = (wrCache1Sel) ? chain_wrTranQueue1             : chain_wrTranQueue0;
assign extDscrptrNxt                = (wrCache1Sel) ? extDscrptrNxt_wrTranQueue1     : extDscrptrNxt_wrTranQueue0;
assign intOnProcess                 = (wrCache1Sel) ? intOnProcess_wrTranQueue1      : intOnProcess_wrTranQueue0;
assign nxtDscrptrNumAddr            = (wrCache1Sel) ? nxtDscrptrNumAddr_WrTranQueue1 : nxtDscrptrNumAddr_WrTranQueue0;

assign dstAddr_rdCache1Sel          = (rdCache1Sel) ? dstAddr_wrTranQueue1           : dstAddr_wrTranQueue0;
endmodule // wrTranQueue