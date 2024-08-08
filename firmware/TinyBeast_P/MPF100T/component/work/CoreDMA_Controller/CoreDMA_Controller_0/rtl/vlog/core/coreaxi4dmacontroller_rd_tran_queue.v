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
module CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_rdTranQueue (
    // General inputs
    clock,
    resetn,

    // DMAArbiter inputs
    doTrans,
    intDscrptrNum_DMAArbiter,
    extDscrptr_DMAArbiter,
    extDscrptrAddr_DMAArbiter,
    dataValid_DMAArbiter,
    srcAddr_DMAArbiter,
    srcOp_DMAArbiter,
    srcDataWidth_DMAArbiter,
    dstDataWidth_DMAArbiter,
    numOfBytes_DMAArbiter,
    priLvl_DMAArbiter,
    chain_DMAArbiter,
    extDscrptrNxt_DMAArbiter,
    nxtDscrptrNumAddr_DMAArbiter,
    
    // wrTranQueue inputs
    spaceWrTranQueue,

    // intErrorCtrl inputs
    clrRdTranQueue,
    rdCache1Sel,

    // intErrorCtrl outputs
    intDscrptrNum_rdTranQueue0,
    intDscrptrNum_rdTranQueue1,
    chain,
    extDscrptrNxt,

    // rdTranCtrl outputs
    reqInQueue,
    priLvl,
    extDscrptr,
    extDscrptrAddr,
    dataValid,
    srcOp,
    srcDataWidth,
    dstDataWidth,
    srcAddr,
    numOfBytes,
    

    // transAck outputs. Some are shared with rdTranCtrl block
    spaceRdTranQueue,
    nxtDscrptrNumAddr
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
input       [NUM_INT_BDS_WIDTH-1:0]     intDscrptrNum_DMAArbiter;
input                                   extDscrptr_DMAArbiter;
input       [31:0]                      extDscrptrAddr_DMAArbiter;
input                                   dataValid_DMAArbiter;
input       [31:0]                      srcAddr_DMAArbiter;
input       [1:0]                       srcOp_DMAArbiter;
input       [2:0]                       srcDataWidth_DMAArbiter;
input       [2:0]                       dstDataWidth_DMAArbiter;
input       [MAX_TRAN_SIZE_WIDTH-1:0]   numOfBytes_DMAArbiter;
input       [NUM_PRI_LVLS-1:0]          priLvl_DMAArbiter;
input                                   chain_DMAArbiter;
input                                   extDscrptrNxt_DMAArbiter;
input       [31:0]                      nxtDscrptrNumAddr_DMAArbiter;

// wrTranQueue inputs
input                                   spaceWrTranQueue;

// intErrorCtrl inputs
input       [1:0]                       clrRdTranQueue;
input                                   rdCache1Sel;

output reg  [NUM_INT_BDS_WIDTH-1:0]     intDscrptrNum_rdTranQueue0;
output reg  [NUM_INT_BDS_WIDTH-1:0]     intDscrptrNum_rdTranQueue1;
output                                  chain;
output                                  extDscrptrNxt;

// rdTranCtrl outputs
output                                  reqInQueue;
output      [NUM_PRI_LVLS-1:0]          priLvl;
output                                  extDscrptr;
output      [31:0]                      extDscrptrAddr;
output                                  dataValid;
output      [1:0]                       srcOp;
output      [2:0]                       srcDataWidth;
output      [2:0]                       dstDataWidth;
output      [31:0]                      srcAddr;
output      [MAX_TRAN_SIZE_WIDTH-1:0]   numOfBytes;

// transAck outputs. Some are shared with rdTranCtrl block
output                                  spaceRdTranQueue;
output      [31:0]                      nxtDscrptrNumAddr;

////////////////////////////////////////////////////////////////////////////////
// Internal signals
////////////////////////////////////////////////////////////////////////////////
reg [1:0]                               reqCnt;
reg                                     extDscrptr_rdTranQueue0;
reg [31:0]                              extDscrptrAddr_rdTranQueue0;
reg                                     dataValid_rdTranQueue0;
reg [31:0]                              srcAddr_rdTranQueue0;
reg [1:0]                               srcOp_rdTranQueue0;
reg [2:0]                               srcDataWidth_rdTranQueue0;
reg [2:0]                               dstDataWidth_rdTranQueue0;
reg [MAX_TRAN_SIZE_WIDTH-1:0]           numOfBytes_rdTranQueue0;
reg [NUM_PRI_LVLS-1:0]                  priLvl_rdTranQueue0;
reg                                     chain_rdTranQueue0;
reg                                     extDscrptrNxt_rdTranQueue0;
reg [31:0]                              nxtDscrptrNumAddr_rdTranQueue0;
reg                                     extDscrptr_rdTranQueue1;
reg [31:0]                              extDscrptrAddr_rdTranQueue1;
reg                                     dataValid_rdTranQueue1;
reg [31:0]                              srcAddr_rdTranQueue1;
reg [1:0]                               srcOp_rdTranQueue1;
reg [2:0]                               srcDataWidth_rdTranQueue1;
reg [2:0]                               dstDataWidth_rdTranQueue1;
reg [MAX_TRAN_SIZE_WIDTH-1:0]           numOfBytes_rdTranQueue1;
reg [NUM_PRI_LVLS-1:0]                  priLvl_rdTranQueue1;
reg                                     chain_rdTranQueue1;
reg                                     extDscrptrNxt_rdTranQueue1;
reg [31:0]                              nxtDscrptrNumAddr_rdTranQueue1;
reg                                     wrCacheSelDMAArbiter;
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
                case ({doTrans, clrRdTranQueue[1], clrRdTranQueue[0]})
                    3'b000, 3'b101, 3'b110:
                        begin
                            reqCnt <= reqCnt;
                        end
                    3'b001, 3'b010, 3'b111:
                        begin
							if(reqCnt != 0)							
								reqCnt <= reqCnt - 1'b1;							
                        end
                    3'b011:
                        begin
							if(reqCnt > 1)							
								reqCnt <= reqCnt - 2'b10;
                        end
                    3'b100:
                        begin
                            reqCnt <= reqCnt + 1'b1;
                        end
                endcase
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

assign spaceRdTranQueue = (reqCnt < 2'b10) ? 1'b1 : 1'b0;
assign reqInQueue = (reqCnt != 2'b0);

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                // Reset
                intDscrptrNum_rdTranQueue0      <= {NUM_INT_BDS_WIDTH{1'b0}};
                extDscrptr_rdTranQueue0         <= 1'b0;
                extDscrptrAddr_rdTranQueue0     <= 32'b0;
                dataValid_rdTranQueue0          <= 1'b0;
                srcAddr_rdTranQueue0            <= 32'b0;
                srcOp_rdTranQueue0              <= 2'b0;
                srcDataWidth_rdTranQueue0       <= 3'b0;
                dstDataWidth_rdTranQueue0       <= 3'b0;
                numOfBytes_rdTranQueue0         <= {MAX_TRAN_SIZE_WIDTH{1'b0}};
                priLvl_rdTranQueue0             <= {NUM_PRI_LVLS{1'b0}};
                chain_rdTranQueue0              <= 1'b0;
                extDscrptrNxt_rdTranQueue0      <= 1'b0;
                nxtDscrptrNumAddr_rdTranQueue0  <= 32'b0;
            end
        else
            begin
                if (doTrans & !wrCacheSelDMAArbiter)
                    begin
                        // Store
                        intDscrptrNum_rdTranQueue0      <= intDscrptrNum_DMAArbiter;
                        extDscrptr_rdTranQueue0         <= extDscrptr_DMAArbiter;
                        extDscrptrAddr_rdTranQueue0     <= extDscrptrAddr_DMAArbiter;
                        dataValid_rdTranQueue0          <= dataValid_DMAArbiter;
                        srcAddr_rdTranQueue0            <= srcAddr_DMAArbiter;
                        srcOp_rdTranQueue0              <= srcOp_DMAArbiter;
                        srcDataWidth_rdTranQueue0       <= srcDataWidth_DMAArbiter;
                        dstDataWidth_rdTranQueue0       <= dstDataWidth_DMAArbiter;
                        numOfBytes_rdTranQueue0         <= numOfBytes_DMAArbiter;
                        priLvl_rdTranQueue0             <= priLvl_DMAArbiter;
                        chain_rdTranQueue0              <= chain_DMAArbiter;
                        extDscrptrNxt_rdTranQueue0      <= extDscrptrNxt_DMAArbiter;
                        nxtDscrptrNumAddr_rdTranQueue0  <= nxtDscrptrNumAddr_DMAArbiter;
                    end
            end
    end

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                // Reset
                intDscrptrNum_rdTranQueue1      <= {NUM_INT_BDS_WIDTH{1'b0}};
                extDscrptr_rdTranQueue1         <= 1'b0;
                extDscrptrAddr_rdTranQueue1     <= 32'b0;
                dataValid_rdTranQueue1          <= 1'b0;
                srcAddr_rdTranQueue1            <= 32'b0;
                srcOp_rdTranQueue1              <= 2'b0;
                srcDataWidth_rdTranQueue1       <= 3'b0;
                dstDataWidth_rdTranQueue1       <= 3'b0;
                numOfBytes_rdTranQueue1         <= {MAX_TRAN_SIZE_WIDTH{1'b0}};
                priLvl_rdTranQueue1             <= {NUM_PRI_LVLS{1'b0}};
                chain_rdTranQueue1              <= 1'b0;
                extDscrptrNxt_rdTranQueue1      <= 1'b0;
                nxtDscrptrNumAddr_rdTranQueue1  <= 32'b0;
            end
        else
            begin
                if (doTrans & wrCacheSelDMAArbiter)
                    begin
                        // Store
                        intDscrptrNum_rdTranQueue1      <= intDscrptrNum_DMAArbiter;
                        extDscrptr_rdTranQueue1         <= extDscrptr_DMAArbiter;
                        extDscrptrAddr_rdTranQueue1     <= extDscrptrAddr_DMAArbiter;
                        dataValid_rdTranQueue1          <= dataValid_DMAArbiter;
                        srcAddr_rdTranQueue1            <= srcAddr_DMAArbiter;
                        srcOp_rdTranQueue1              <= srcOp_DMAArbiter;
                        srcDataWidth_rdTranQueue1       <= srcDataWidth_DMAArbiter;
                        dstDataWidth_rdTranQueue1       <= dstDataWidth_DMAArbiter;
                        numOfBytes_rdTranQueue1         <= numOfBytes_DMAArbiter;
                        priLvl_rdTranQueue1             <= priLvl_DMAArbiter;
                        chain_rdTranQueue1              <= chain_DMAArbiter;
                        extDscrptrNxt_rdTranQueue1      <= extDscrptrNxt_DMAArbiter;
                        nxtDscrptrNumAddr_rdTranQueue1  <= nxtDscrptrNumAddr_DMAArbiter;
                    end
            end
    end

////////////////////////////////////////////////////////////////////////////////
// Internal muxes
// For signals which are only referenced whilst the request is being operated on
////////////////////////////////////////////////////////////////////////////////
assign extDscrptr        = (rdCache1Sel) ? extDscrptr_rdTranQueue1        : extDscrptr_rdTranQueue0;
assign extDscrptrAddr    = (rdCache1Sel) ? extDscrptrAddr_rdTranQueue1    : extDscrptrAddr_rdTranQueue0;
assign dataValid         = (rdCache1Sel) ? dataValid_rdTranQueue1         : dataValid_rdTranQueue0;
assign srcOp             = (rdCache1Sel) ? srcOp_rdTranQueue1             : srcOp_rdTranQueue0;
assign srcDataWidth      = (rdCache1Sel) ? srcDataWidth_rdTranQueue1      : srcDataWidth_rdTranQueue0;
assign dstDataWidth      = (rdCache1Sel) ? dstDataWidth_rdTranQueue1      : dstDataWidth_rdTranQueue0;
assign srcAddr           = (rdCache1Sel) ? srcAddr_rdTranQueue1           : srcAddr_rdTranQueue0;
assign numOfBytes        = (rdCache1Sel) ? numOfBytes_rdTranQueue1        : numOfBytes_rdTranQueue0;
assign priLvl            = (rdCache1Sel) ? priLvl_rdTranQueue1            : priLvl_rdTranQueue0;
assign chain             = (rdCache1Sel) ? chain_rdTranQueue1             : chain_rdTranQueue0;
assign extDscrptrNxt     = (rdCache1Sel) ? extDscrptrNxt_rdTranQueue1     : extDscrptrNxt_rdTranQueue0;
assign nxtDscrptrNumAddr = (rdCache1Sel) ? nxtDscrptrNumAddr_rdTranQueue1 : nxtDscrptrNumAddr_rdTranQueue0;

endmodule // rdTranQueue