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
module CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_fixedPriorityArbiter (
    // Inputs
    clock,
    resetn,
    req,
    nextReq,
    clrReq,
    strDscrptr_RRA0,
    intDscrptrNumPri0,
    intDscrptrNumPri1,
    intDscrptrNumPri2,
    intDscrptrNumPri3,
    intDscrptrNumPri4,
    intDscrptrNumPri5,
    intDscrptrNumPri6,
    intDscrptrNumPri7,
    // Outputs
    reqEn,
    tranDataAvail,
    strDscrptr,
    intDscrptrNum,
    priLvl,
	rdEn_intext	
);

////////////////////////////////////////////////////////////////////////////////
// User modifiable parameters
////////////////////////////////////////////////////////////////////////////////
parameter NUM_OF_BDS            = 4;
parameter NUM_OF_BDS_WIDTH      = 2;
parameter NO_OF_REQS            = 4;

////////////////////////////////////////////////////////////////////////////////
// Port directions
////////////////////////////////////////////////////////////////////////////////
input                               clock;
input                               resetn;
input       [NO_OF_REQS-1:0]        req;
input                               nextReq;
input                               clrReq;
input                               strDscrptr_RRA0;
input       [NUM_OF_BDS_WIDTH-1:0]  intDscrptrNumPri0;
input       [NUM_OF_BDS_WIDTH-1:0]  intDscrptrNumPri1;
input       [NUM_OF_BDS_WIDTH-1:0]  intDscrptrNumPri2;
input       [NUM_OF_BDS_WIDTH-1:0]  intDscrptrNumPri3;
input       [NUM_OF_BDS_WIDTH-1:0]  intDscrptrNumPri4;
input       [NUM_OF_BDS_WIDTH-1:0]  intDscrptrNumPri5;
input       [NUM_OF_BDS_WIDTH-1:0]  intDscrptrNumPri6;
input       [NUM_OF_BDS_WIDTH-1:0]  intDscrptrNumPri7;
output      [NO_OF_REQS-1:0]        reqEn;
output 								rdEn_intext;
output reg                          tranDataAvail;
output reg                          strDscrptr;
output reg  [NUM_OF_BDS_WIDTH-1:0]  intDscrptrNum;
output reg  [NO_OF_REQS-1:0]        priLvl;

////////////////////////////////////////////////////////////////////////////////
// Constants
////////////////////////////////////////////////////////////////////////////////
localparam ACTIVE               = 0;
localparam WAIT                 = 1;

////////////////////////////////////////////////////////////////////////////////
// Internal signals
////////////////////////////////////////////////////////////////////////////////
reg                             currState;
reg                             nextState;
reg     [NO_OF_REQS-1:0]        grantFPA;
wire    [NO_OF_REQS-1:0]        grant_d;
reg                             grantEn;
wire    [NUM_OF_BDS_WIDTH-1:0]  intDscrptrNum_d;
wire                            strDscrptr_d;
wire    [NO_OF_REQS-1:0]        HigherPriReq;

assign rdEn_intext = grantEn;

generate
    if (NO_OF_REQS == 1)
        begin
            assign grant_d = req;
        end
    else if (NO_OF_REQS > 1)
        begin
            assign HigherPriReq[NO_OF_REQS-1:1] = HigherPriReq[NO_OF_REQS-2:0] | req[NO_OF_REQS-2:0];
            assign HigherPriReq[0] = 1'b0;
            assign grant_d[NO_OF_REQS-1:0] = req[NO_OF_REQS-1:0] & ~HigherPriReq[NO_OF_REQS-1:0];
        end
endgenerate

////////////////////////////////////////////////////////////////////////////////
// grantFPA register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                grantFPA <= {NO_OF_REQS{1'b0}};
            end
        else if (grantEn)
            begin
                grantFPA <= grant_d;
            end
    end

// Inform the appropriate requestor that it's about to receive access on the
// next clock rising edge. Associated RRA will updates it's mask register on 
// the next clock edge
assign reqEn[NO_OF_REQS-1:0] = (grantEn) ? grant_d[NO_OF_REQS-1:0] : {NO_OF_REQS{1'b0}};

////////////////////////////////////////////////////////////////////////////////
// TranDataAvail output register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                tranDataAvail <= 1'b0;
            end
        else if (grantEn)
            begin
                tranDataAvail <= 1'b1;
            end
        else if (clrReq)
            begin
                tranDataAvail <= 1'b0;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// Priority Level register
// Leave the priLvl signal in one-hot form for passing to the DMATranCtrl block
// to aid timing
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                priLvl <= {NO_OF_REQS{1'b0}};
            end
        else if (grantEn)
            begin
                priLvl <= grant_d[NO_OF_REQS-1:0];
            end
    end

////////////////////////////////////////////////////////////////////////////////
// intDscrptrNum  register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                intDscrptrNum <= {NUM_OF_BDS_WIDTH{1'b0}};
            end
        else if (grantEn)
            begin
                intDscrptrNum <= intDscrptrNum_d;
            end
    end
assign intDscrptrNum_d = (grant_d == 8'b00000010) ? intDscrptrNumPri1 : 
                         (grant_d == 8'b00000100) ? intDscrptrNumPri2 :
                         (grant_d == 8'b00001000) ? intDscrptrNumPri3 :
                         (grant_d == 8'b00010000) ? intDscrptrNumPri4 :
                         (grant_d == 8'b00100000) ? intDscrptrNumPri5 :
                         (grant_d == 8'b01000000) ? intDscrptrNumPri6 :
                         (grant_d == 8'b10000000) ? intDscrptrNumPri7 :
                         intDscrptrNumPri0; // Mux pri0 to the output if 0 also

////////////////////////////////////////////////////////////////////////////////
// strDscrptr register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                strDscrptr <= 1'b0;
            end
        else if (grantEn)
            begin
                strDscrptr <= strDscrptr_d;
            end
    end
assign strDscrptr_d = (grant_d == 8'b00000001) ? strDscrptr_RRA0 : 1'b0; 

////////////////////////////////////////////////////////////////////////////////
// Arbiter Sequencer FSM
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                currState <= ACTIVE;
            end
        else
            begin
                currState <= nextState;
            end
    end

always @ (*)
    begin
        grantEn <= 1'b0;
        case (currState)
            ACTIVE:
                begin
                    // Actively check for a request. Assert grantEn so that the 
                    // highest priority request can be registered on the next
                    // rising clock edge.
                    if (|req[NO_OF_REQS-1:0])
                        begin
                            grantEn <= 1'b1;
                            nextState <= WAIT;
                        end
                    else
                        begin
                            nextState <= ACTIVE;
                        end
                end
            WAIT:
                begin
                    // Remain here until a DMATranCtrl block is finished with
                    // the previous request, as indicated by nextReq
                    if (nextReq)
                        begin
                            nextState <= ACTIVE;
                        end
                    else
                        begin
                            nextState <= WAIT;
                        end
                end
        endcase
    end
endmodule // fixedPriorityArbiter
