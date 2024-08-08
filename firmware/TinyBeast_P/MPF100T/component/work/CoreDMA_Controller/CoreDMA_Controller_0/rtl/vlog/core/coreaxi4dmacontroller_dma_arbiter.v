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
module CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_DMAArbiter (
    // Inputs
    clock,
    resetn,
    dscrptrNdataValid,
    chain,
    dscrptrData,
    ldDscrptr,
    strDscrptr_dscrptrSrcMux,
    dataValid,
    extDscrptr,
    intDscrptrNum,
    newNumOfBytes,
    newSrcAddr,
    newDstAddr,
    extDscrptrAddr,
    transAck,
    strDscrptr_DMATranCtrl,
    extDataValid,
    clrReq_DMATranCtrl,
    intDscrptrNum_clrReq,
    waitDscrptr,
    waitStrDscrptr,
    // Outputs
    doTrans,
    priLvl,
    strDscrptr_DMAArbiter,
    intDscrptrNum_DMAArbiter,
    dscrptrData_DMAArbiter,
    clrDataValidDscrptr,
	
	error_flag_sb_intextdscrptr,
	error_flag_db_intextdscrptr
);

////////////////////////////////////////////////////////////////////////////////
// User modifiable parameters
////////////////////////////////////////////////////////////////////////////////
parameter AXI4_STREAM_IF              = 0;
parameter NUM_INT_BDS                 = 4;
parameter NUM_INT_BDS_WIDTH           = 2;
parameter MAX_TRAN_SIZE_WIDTH         = 23;
parameter NUM_PRI_LVLS                = 6;
parameter DSCRPTR_DATA_WIDTH          = 133;
parameter DSCRPTR_DATA_WIDTH_EXT_ADDR = (DSCRPTR_DATA_WIDTH+32+1);

parameter FAMILY = 25;
parameter ECC    = 1;

// Auto-generated include file containing custom association of descriptors
// with priority levels for arbitration.
`include "../../../coreaxi4dmacontroller_arbiter_parameters.v"

////////////////////////////////////////////////////////////////////////////////
// Port directions
////////////////////////////////////////////////////////////////////////////////
input                                           clock;
input                                           resetn;
input       [NUM_INT_BDS-1:0]                   dscrptrNdataValid;
input       [NUM_INT_BDS-1:0]                   chain;
input       [DSCRPTR_DATA_WIDTH-1:0]            dscrptrData;
input                                           ldDscrptr;
input                                           strDscrptr_dscrptrSrcMux;
input                                           dataValid;
input                                           extDscrptr;
input       [NUM_INT_BDS_WIDTH-1:0]             intDscrptrNum;
input       [MAX_TRAN_SIZE_WIDTH-1:0]           newNumOfBytes;
input       [31:0]                              newSrcAddr;
input       [31:0]                              newDstAddr;
input       [31:0]                              extDscrptrAddr;
input                                           transAck;
input                                           strDscrptr_DMATranCtrl;
input                                           extDataValid;
input                                           clrReq_DMATranCtrl;
input       [NUM_INT_BDS_WIDTH-1:0]             intDscrptrNum_clrReq;
input       [NUM_INT_BDS-1:0]                   waitDscrptr;
input                                           waitStrDscrptr;
output                                          doTrans;
output      [NUM_PRI_LVLS-1:0]                  priLvl;
output                                          strDscrptr_DMAArbiter;
output      [NUM_INT_BDS_WIDTH-1:0]             intDscrptrNum_DMAArbiter;
output  reg [DSCRPTR_DATA_WIDTH_EXT_ADDR-1:0]   dscrptrData_DMAArbiter;
output      [NUM_INT_BDS-1:0]                   clrDataValidDscrptr;

output 											error_flag_sb_intextdscrptr;
output 											error_flag_db_intextdscrptr;

////////////////////////////////////////////////////////////////////////////////
// Internal signals
////////////////////////////////////////////////////////////////////////////////
reg     [NUM_INT_BDS-1:0]                           reqStore;
wire    [NUM_INT_BDS-1:0]                           reqValid;
integer                                             reqIdx;
wire    [NO_OF_ACTIVE_FIXED_PRIORITY_LEVELS-1:0]    reqEn;
reg                                                 clrReq;
reg                                                 nextReq;
reg     [2:0]                                       currState;
reg     [2:0]                                       nextState;
reg                                                 updateIntExtDscrptrData;
wire                                                updateIntExtDscrptrDataAck;
wire    [NUM_INT_BDS-1:0]                           extDscrptr_intExtDscrptrCache;
wire                                                dataValid_Cache;
wire    [NO_OF_PRI_0_REQS-1:0]                      grant_Pri0RRA;
wire    [NO_OF_PRI_1_REQS-1:0]                      grant_Pri1RRA;
wire    [NO_OF_PRI_2_REQS-1:0]                      grant_Pri2RRA;
wire    [NO_OF_PRI_3_REQS-1:0]                      grant_Pri3RRA;
wire    [NO_OF_PRI_4_REQS-1:0]                      grant_Pri4RRA;
wire    [NO_OF_PRI_5_REQS-1:0]                      grant_Pri5RRA;
wire    [NO_OF_PRI_6_REQS-1:0]                      grant_Pri6RRA;
wire    [NO_OF_PRI_7_REQS-1:0]                      grant_Pri7RRA;
wire    [DSCRPTR_DATA_WIDTH_EXT_ADDR-1:0]           dscrptrData_intExtDscrptrCache;
wire    [NO_OF_ACTIVE_FIXED_PRIORITY_LEVELS-1:0]    priLvlFPA;
wire                                                strDscrptr_RRA0;
wire                                                strDscrptrValid_StrDscrptrCache;
reg     [1:0]                                       strDscrptrValid;
wire												rdEn_intext;
reg     [55:0]                                      strDscrptrMod    [1:0]/*synthesis syn_ramstyle="registers"*/;
reg     [33:0]                                      strDscrptrNonMod [1:0]/*synthesis syn_ramstyle="registers"*/;
reg                                                 strDscrptrWrSel;
reg                                                 strDscrptrRdSel;
wire    [DSCRPTR_DATA_WIDTH_EXT_ADDR-1:0]           dscrptrDataOutStr;
reg     [1:0]                                       dataValidStrDscrptrReg;


// Auto-generated include file containing custom mapping of descriptors
// to priority levels for arbitration.
`include "../../../coreaxi4dmacontroller_arbiter_mapping.v"

////////////////////////////////////////////////////////////////////////////////
// Constants
////////////////////////////////////////////////////////////////////////////////
// FSM state encoding
localparam [2:0] WAIT_FOR_ACK        = 3'b010;
localparam [2:0] NEXT_REQ            = 3'b100;
localparam [2:0] WAIT_FOR_CACHE_ACK  = 3'b000;

////////////////////////////////////////////////////////////////////////////////
// RequestStore
// 
// Note: Clearing of a particular descriptor takes priority. All bets are off if
// the user attempts to modify an active descriptor
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                reqStore <= {NUM_INT_BDS{1'b0}};
            end
        else if (ldDscrptr)
            begin // Translate from BCD to one-hot encoding
                for (reqIdx = 0; reqIdx <= NUM_INT_BDS-1; reqIdx = reqIdx + 1)
                    begin
                        if (intDscrptrNum == reqIdx)
                            begin
                                reqStore[reqIdx] <= 1'b1;
                            end
                    end
                if (clrReq)
                    begin
                        // Clear the request currently pointed at by the output of the
                        // fixed priority arbiter
                        reqStore[intDscrptrNum_DMAArbiter] <= 1'b0;
                    end
                if (clrReq_DMATranCtrl)
                    begin
                        reqStore[intDscrptrNum_clrReq] <= 1'b0;
                    end
            end
        else if (clrReq | clrReq_DMATranCtrl)
            begin
                if (clrReq)
                    begin
                        // Clear the request currently pointed at by the output of the
                        // fixed priority arbiter
                        reqStore[intDscrptrNum_DMAArbiter] <= 1'b0;
                    end
                if (clrReq_DMATranCtrl)
                    begin
                        reqStore[intDscrptrNum_clrReq] <= 1'b0;
                    end
            end
    end

// Only pass on requests with the data valid flow control bit set for the descriptor
assign reqValid[NUM_INT_BDS-1:0] = reqStore[NUM_INT_BDS-1:0] & ((dscrptrNdataValid[NUM_INT_BDS-1:0]) | (extDscrptr_intExtDscrptrCache));

////////////////////////////////////////////////////////////////////////////////
// Fixed Priority Arbiter instantiation
////////////////////////////////////////////////////////////////////////////////
CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_fixedPriorityArbiter #(
    .NUM_OF_BDS            (NUM_INT_BDS),
    .NUM_OF_BDS_WIDTH      (NUM_INT_BDS_WIDTH),
    .NO_OF_REQS            (NO_OF_ACTIVE_FIXED_PRIORITY_LEVELS)
) FPA (
    // Inputs
    .clock                  (clock),
    .resetn                 (resetn),
    .req                    (reqFPA),
    .nextReq                (nextReq),
    .clrReq                 (transAck | clrReq_DMATranCtrl), // Deassert the doTrans output if DMATranCtrl block writing/clearing the
    .strDscrptr_RRA0        (strDscrptr_RRA0),
    .intDscrptrNumPri0      (intDscrptrNum_Pri0RRA),         // descriptor cache or for a AXI write/read DMA failure to clearout the pipeline
    .intDscrptrNumPri1      (intDscrptrNum_Pri1RRA),
    .intDscrptrNumPri2      (intDscrptrNum_Pri2RRA),
    .intDscrptrNumPri3      (intDscrptrNum_Pri3RRA),
    .intDscrptrNumPri4      (intDscrptrNum_Pri4RRA),
    .intDscrptrNumPri5      (intDscrptrNum_Pri5RRA),
    .intDscrptrNumPri6      (intDscrptrNum_Pri6RRA),
    .intDscrptrNumPri7      (intDscrptrNum_Pri7RRA),
    // Outputs
    .reqEn                  (reqEn),
    .tranDataAvail          (doTrans),
    .strDscrptr             (strDscrptr_DMAArbiter),
    .intDscrptrNum          (intDscrptrNum_DMAArbiter),
    .priLvl                 (priLvlFPA),
    .rdEn_intext            (rdEn_intext)
	
);
assign priLvl = (NO_OF_ACTIVE_FIXED_PRIORITY_LEVELS == 8) ? priLvlFPA : {{(NUM_PRI_LVLS - NO_OF_ACTIVE_FIXED_PRIORITY_LEVELS){1'b0}}, priLvlFPA}; 
assign strDscrptr_RRA0 = ((AXI4_STREAM_IF == 1) && (grant_Pri0RRA[0] == 1'b1)) ? 1'b1 : 1'b0;

////////////////////////////////////////////////////////////////////////////////
// Priority 0 round robin arbiter instantiation
////////////////////////////////////////////////////////////////////////////////
generate
    if (NO_OF_PRI_0_REQS == 1)
        begin
            // Pass through. No other requests to compete with at this level
            assign grant_Pri0RRA = reqPri0;
        end
    else if (NO_OF_PRI_0_REQS > 1)
        begin
            // Priority 0 arbiter instantiation
            CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_roundRobinArbiter #(
                .NO_OF_REQS (NO_OF_PRI_0_REQS)
            ) PRI_0 (
                // Inputs
                .clock      (clock),
                .resetn     (resetn),
                .req        (reqPri0),
                .grantEn    (reqEn[0]),
                // Outputs
                .grant      (grant_Pri0RRA)
            );
        end
endgenerate

generate
    if ((NUM_PRI_LVLS >= 2) && (NO_OF_PRI_1_REQS == 1))
        begin
            // Pass through. No other requests to compete with at this level
            assign grant_Pri1RRA = reqPri1;
        end
    else if ((NUM_PRI_LVLS >= 2) && (NO_OF_PRI_1_REQS > 1))
        begin
            // Priority 1 round robin arbiter instantiation
            CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_roundRobinArbiter #(
                .NO_OF_REQS (NO_OF_PRI_1_REQS)
            ) PRI_1 (
                // Inputs
                .clock      (clock),
                .resetn     (resetn),
                .req        (reqPri1),
                .grantEn    (reqEn[1]),
                // Outputs
                .grant      (grant_Pri1RRA)
            );
        end
endgenerate


generate
    if ((NUM_PRI_LVLS >= 3) && (NO_OF_PRI_2_REQS == 1))
        begin : G1
            // Pass through. No other requests to compete with at this level
            assign grant_Pri2RRA = reqPri2;
        end
    else if ((NUM_PRI_LVLS >= 3) && (NO_OF_PRI_2_REQS > 1))
        begin
            // Priority 2 round robin arbiter instantiation
            CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_roundRobinArbiter #(
                .NO_OF_REQS (NO_OF_PRI_2_REQS)
            ) PRI_2 (
                // Inputs
                .clock      (clock),
                .resetn     (resetn),
                .req        (reqPri2),
                .grantEn    (reqEn[2]),
                // Outputs
                .grant      (grant_Pri2RRA)
            );
        end
endgenerate

generate
    if ((NUM_PRI_LVLS >= 4) && (NO_OF_PRI_3_REQS == 1))
        begin
            // Pass through. No other requests to compete with at this level
            assign grant_Pri3RRA = reqPri3;
        end
    else if ((NUM_PRI_LVLS >= 4) && (NO_OF_PRI_3_REQS > 1))
        begin
            // Priority 3 round robin arbiter instantiation
            CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_roundRobinArbiter #(
                .NO_OF_REQS (NO_OF_PRI_3_REQS)
            ) PRI_3 (
                // Inputs
                .clock      (clock),
                .resetn     (resetn),
                .req        (reqPri3),
                .grantEn    (reqEn[3]),
                // Outputs
                .grant      (grant_Pri3RRA)
            );
        end
endgenerate

generate
    if ((NUM_PRI_LVLS >= 5) && (NO_OF_PRI_4_REQS == 1))
        begin
            // Pass through. No other requests to compete with at this level
            assign grant_Pri4RRA = reqPri4;
        end
    else if ((NUM_PRI_LVLS >= 5) && (NO_OF_PRI_4_REQS > 1))
        begin
            // Priority 4 round robin arbiter instantiation
            CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_roundRobinArbiter #(
                .NO_OF_REQS (NO_OF_PRI_4_REQS)
            ) PRI_4 (
                // Inputs
                .clock      (clock),
                .resetn     (resetn),
                .req        (reqPri4),
                .grantEn    (reqEn[4]),
                // Outputs
                .grant      (grant_Pri4RRA)
            );
        end
endgenerate

generate
    if ((NUM_PRI_LVLS >= 6) && (NO_OF_PRI_5_REQS == 1))
        begin
            // Pass through. No other requests to compete with at this level
            assign grant_Pri5RRA = reqPri5;
        end
    else if ((NUM_PRI_LVLS >= 6) && (NO_OF_PRI_5_REQS > 1))
        begin
            // Priority 5 round robin arbiter instantiation
            CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_roundRobinArbiter #(
                .NO_OF_REQS (NO_OF_PRI_5_REQS)
            ) PRI_5 (
                // Inputs
                .clock      (clock),
                .resetn     (resetn),
                .req        (reqPri5),
                .grantEn    (reqEn[5]),
                // Outputs
                .grant      (grant_Pri5RRA)
            );
        end
endgenerate

generate
    if ((NUM_PRI_LVLS >= 7) && (NO_OF_PRI_6_REQS == 1))
        begin
            // Pass through. No other requests to compete with at this level
            assign grant_Pri6RRA = reqPri6;
        end
    else if ((NUM_PRI_LVLS >= 7) && (NO_OF_PRI_6_REQS > 1))
        begin
            // Priority 6 round robin arbiter instantiation
            CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_roundRobinArbiter #(
                .NO_OF_REQS (NO_OF_PRI_6_REQS)
            ) PRI_6 (
                // Inputs
                .clock      (clock),
                .resetn     (resetn),
                .req        (reqPri6),
                .grantEn    (reqEn[6]),
                // Outputs
                .grant      (grant_Pri6RRA)
            );
        end
endgenerate

generate
    if ((NUM_PRI_LVLS == 8) && (NO_OF_PRI_7_REQS == 1))
        begin
            // Pass through. No other requests to compete with at this level
            assign grant_Pri7RRA = reqPri7;
        end
    else if ((NUM_PRI_LVLS == 8) && (NO_OF_PRI_7_REQS > 1))
        begin
            // Priority 7 round robin arbiter instantiation
            CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_roundRobinArbiter #(
                .NO_OF_REQS (NO_OF_PRI_7_REQS)
            ) PRI_7 (
                // Inputs
                .clock      (clock),
                .resetn     (resetn),
                .req        (reqPri7),
                .grantEn    (reqEn[7]),
                // Outputs
                .grant      (grant_Pri7RRA)
            );
        end
endgenerate

// Assert the updateIntExtDscrptrData acknowledgement only when the
// dscrptrSrcMux is not writing to the descriptor cache.
assign updateIntExtDscrptrDataAck = (!ldDscrptr & updateIntExtDscrptrData);

////////////////////////////////////////////////////////////////////////////////
// Arbiter Sequencer current state register
//
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                currState <= WAIT_FOR_ACK; 
            end
        else
            begin
                currState <= nextState;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// Arbiter sequencer next state combinatorial logic
////////////////////////////////////////////////////////////////////////////////
always @ (*)
    begin
        // Default assignments
        clrReq                  <= 1'b0;
        nextReq                 <= 1'b0;
        updateIntExtDscrptrData <= 1'b0;
        case (currState)
            WAIT_FOR_ACK:
                begin
                    if (transAck)
                        begin
                            updateIntExtDscrptrData <= 1'b1;
                            if (newNumOfBytes == {MAX_TRAN_SIZE_WIDTH{1'b0}})
                                begin
                                    if (updateIntExtDscrptrDataAck)
                                        begin
                                            clrReq    <= 1'b1;
                                            nextState <= NEXT_REQ;
                                        end
                                    else
                                        begin
                                            nextState <= WAIT_FOR_CACHE_ACK;
                                        end
                                end
                            else
                                begin
                                    if (updateIntExtDscrptrDataAck)
                                        begin
                                            nextState <= NEXT_REQ;
                                        end
                                     else
                                        begin
                                            nextState <= WAIT_FOR_CACHE_ACK;
                                        end
                                end
                        end
                    else
                        begin
                            nextState <= WAIT_FOR_ACK;
                        end
                end
            WAIT_FOR_CACHE_ACK:
                begin
                    updateIntExtDscrptrData <= 1'b1;
                    if (updateIntExtDscrptrDataAck)
                        begin
                            nextState <= NEXT_REQ;
                            if (newNumOfBytes == {MAX_TRAN_SIZE_WIDTH{1'b0}})
                                begin
                                    clrReq    <= 1'b1;
                                end
                        end
                    else
                        begin
                            nextState <= WAIT_FOR_CACHE_ACK;
                        end
                end
            NEXT_REQ:
                begin
                    // Allows the updated DMA operation description to the written
                    // to the current descriptor that the fixed priority arbiter
                    // is pointing at in the descriptor cache before the FPA
                    // re-evaluates priority.
                    nextReq   <= 1'b1;
                    nextState <= WAIT_FOR_ACK;
                end
            default:
                begin
                    nextState <= WAIT_FOR_ACK;
                end
        endcase
    end

assign dataValid_Cache = (updateIntExtDscrptrData) ? extDataValid : dataValid;

////////////////////////////////////////////////////////////////////////////////
// Descriptor cache instantiation
////////////////////////////////////////////////////////////////////////////////
CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_intExtDscrptrCache #(
    .NUM_OF_BDS                                 (NUM_INT_BDS),
    .NUM_OF_BDS_WIDTH                           (NUM_INT_BDS_WIDTH),
    .MAX_TRAN_SIZE_WIDTH                        (MAX_TRAN_SIZE_WIDTH),
    .DSCRPTR_DATA_WIDTH                         (DSCRPTR_DATA_WIDTH),
    .DSCRPTR_DATA_WIDTH_EXT_ADDR                (DSCRPTR_DATA_WIDTH_EXT_ADDR),
	.FAMILY										(FAMILY),
	.ECC										(ECC)
) DSCRPTR_CACHE (
    // Inputs
    .clock                                      (clock),
    .resetn                                     (resetn),
    .ldDscrptr                                  (ldDscrptr),
    .strDscrptr_dscrptrSrcMux                   (strDscrptr_dscrptrSrcMux),
    .intDscrptrNum_dscrptrSrcMux                (intDscrptrNum),
    .extDscrptr_dscrptrSrcMux                   (extDscrptr),
    .intDscrptrNum_updateDscrptrMux             (intDscrptrNum_DMAArbiter),
    .updateIntExtDscrptrData                    (updateIntExtDscrptrData),
    .strDscrptr_DMATranCtrl                     (strDscrptr_DMATranCtrl),
    .newNumOfBytes                              (newNumOfBytes),
    .newSrcAddr                                 (newSrcAddr),
    .newDstAddr                                 (newDstAddr),
    .extDscrptrAddr                             (extDscrptrAddr),
    .dscrptrData                                (dscrptrData),
    .dscrptrRdAddr                              (intDscrptrNum_DMAArbiter),
    .extDataValid                               (dataValid_Cache),
    .rdEn_intext                                (rdEn_intext),
	
    // Outputs
    .dscrptrDataOut                             (dscrptrData_intExtDscrptrCache),
    .extDscrptr_intExtDscrptrCache              (extDscrptr_intExtDscrptrCache),
    .clrDataValidDscrptr                        (clrDataValidDscrptr),
	.error_flag_sb_intextdscrptr				(error_flag_sb_intextdscrptr),
	.error_flag_db_intextdscrptr				(error_flag_db_intextdscrptr)
);

////////////////////////////////////////////////////////////////////////////////
// strDscrptrValid register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                strDscrptrValid <= 2'b0; 
            end
        else
            begin
                if (ldDscrptr & strDscrptr_dscrptrSrcMux)
                    begin
                        strDscrptrValid[strDscrptrWrSel]  <= 1'b1;
                        strDscrptrValid[~strDscrptrWrSel] <= strDscrptrValid[~strDscrptrWrSel];
                    end
                else if ((strDscrptr_DMATranCtrl) && (updateIntExtDscrptrData == 1'b1) && (newNumOfBytes == {MAX_TRAN_SIZE_WIDTH{1'b0}}))
                    begin
                        strDscrptrValid[strDscrptrRdSel]  <= 1'b0;
                        strDscrptrValid[~strDscrptrRdSel] <= strDscrptrValid[~strDscrptrRdSel];
                    end
            end
    end

assign strDscrptrValid_StrDscrptrCache = strDscrptrValid[strDscrptrRdSel];

////////////////////////////////////////////////////////////////////////////////
// strDscrptrWrSel register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                strDscrptrWrSel <= 1'b0;
            end
        else
            begin
                if (ldDscrptr & strDscrptr_dscrptrSrcMux)
                    begin
                        strDscrptrWrSel <= ~strDscrptrWrSel;
                    end
            end
    end

////////////////////////////////////////////////////////////////////////////////
// strDscrptrRdSel register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                strDscrptrRdSel <= 1'b0;
            end
        else
            begin
                if ((strDscrptr_DMATranCtrl) && (updateIntExtDscrptrData == 1'b1) && (newNumOfBytes == {MAX_TRAN_SIZE_WIDTH{1'b0}}))
                    begin
                        strDscrptrRdSel <= ~strDscrptrRdSel;
                    end
            end
    end

////////////////////////////////////////////////////////////////////////////////
//strDscrptrMod RAM Inferance
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock)
    begin
        if (ldDscrptr & strDscrptr_dscrptrSrcMux)
            begin
                strDscrptrMod[strDscrptrWrSel] <= dscrptrData[57:2];
            end
        else if (updateIntExtDscrptrData & strDscrptr_DMATranCtrl)
            begin
                strDscrptrMod[strDscrptrRdSel] <= {newDstAddr, newNumOfBytes};
            end
    end

////////////////////////////////////////////////////////////////////////////////
// strDscrptrNonMod RAM Inferance
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock)
    begin
        if (ldDscrptr & strDscrptr_dscrptrSrcMux)
            begin                                   // extDscrptrAddr, dstOperation
                strDscrptrNonMod[strDscrptrWrSel] <= {extDscrptrAddr, dscrptrData[1:0]};
            end
    end

assign dscrptrDataOutStr = {1'b0,
                            strDscrptrNonMod[strDscrptrRdSel][33:2],
                            {32{1'b0}},
                            {strDscrptrMod[strDscrptrRdSel][55:24], {32{1'b0}}, strDscrptrMod[strDscrptrRdSel][23:0]},
                            dataValidStrDscrptrReg[strDscrptrRdSel],
                            {{9{1'b0}}, strDscrptrNonMod[strDscrptrRdSel][1:0], {2{1'b0}}}
                           };

////////////////////////////////////////////////////////////////////////////////
// Register for holding data valid for stream descriptors
// Can be detected high and written initially from the dscrptrSrcMux or else
// polled every time that the external descriptor request is passed to the 
// DMATranCtrl block.
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            dataValidStrDscrptrReg <= {NUM_INT_BDS{1'b0}};
        else if (ldDscrptr & strDscrptr_dscrptrSrcMux & extDscrptr)
            dataValidStrDscrptrReg[strDscrptrWrSel] <= dataValid;
        else if (updateIntExtDscrptrData && strDscrptr_DMATranCtrl && (newNumOfBytes == {MAX_TRAN_SIZE_WIDTH{1'b0}}))
            dataValidStrDscrptrReg[strDscrptrRdSel] <= 1'b0;
        else if (updateIntExtDscrptrData & strDscrptr_DMATranCtrl & extDataValid) // Stream descriptor data valid fetch
            dataValidStrDscrptrReg[strDscrptrRdSel] <= 1'b1;
    end

////////////////////////////////////////////////////////////////////////////////
// dscrptrData_DMAArbiter mux
////////////////////////////////////////////////////////////////////////////////
always @ (*)
    begin
        if (strDscrptr_DMAArbiter)
            begin
                dscrptrData_DMAArbiter = dscrptrDataOutStr;
            end
        else if (extDscrptr_intExtDscrptrCache[intDscrptrNum_DMAArbiter])
            begin
                dscrptrData_DMAArbiter = dscrptrData_intExtDscrptrCache;
            end
        else
            begin
                dscrptrData_DMAArbiter = {dscrptrData_intExtDscrptrCache[DSCRPTR_DATA_WIDTH_EXT_ADDR-1:11],
                                          chain[intDscrptrNum_DMAArbiter],
                                          dscrptrData_intExtDscrptrCache[9:0]};
            end
    end

endmodule