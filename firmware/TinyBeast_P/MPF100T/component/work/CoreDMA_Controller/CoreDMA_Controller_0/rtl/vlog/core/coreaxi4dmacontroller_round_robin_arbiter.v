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
module CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_roundRobinArbiter (
    // Inputs
    clock,
    resetn,
    req,
    grantEn,
    // Outputs
    grant
);

////////////////////////////////////////////////////////////////////////////////
// User modifiable parameters
////////////////////////////////////////////////////////////////////////////////
parameter   NO_OF_REQS = 4;

////////////////////////////////////////////////////////////////////////////////
// Port directions
////////////////////////////////////////////////////////////////////////////////
input                           clock;
input                           resetn;
input       [NO_OF_REQS-1:0]    req;
input                           grantEn;
output      [NO_OF_REQS-1:0]    grant; // Combinatorial output - Next grant if 
                                       // grantEn assertion detected on the next
                                       // clock rising edge.

////////////////////////////////////////////////////////////////////////////////
// Internal signals
////////////////////////////////////////////////////////////////////////////////
wire    [NO_OF_REQS-1:0]        maskedReq;
reg     [NO_OF_REQS-1:0]        maskReg;
wire    [NO_OF_REQS-1:0]        maskHigherPriReq;
wire    [NO_OF_REQS-1:0]        maskedGrant;
wire    [NO_OF_REQS-1:0]        unmaskHigherPriReq;
wire    [NO_OF_REQS-1:0]        unmaskedGrant;

// Mask off all requests below and including the previously granted mask to
// ensure equal service.
assign maskedReq[NO_OF_REQS-1:0] = req[NO_OF_REQS-1:0] & maskReg[NO_OF_REQS-1:0];

////////////////////////////////////////////////////////////////////////////////
// Fixed priority arbiter used for masked and unmasked arbiter (4-bit example)
////////////////////////////////////////////////////////////////////////////////
//  higherPriReq[0] --|----|
//                    | or |---+ higherPriReq[1]
//           req[0] --|----|   |
//                             +---|----|
//                                 | or |---+ higherPriReq[2]
//           req[1] ---------------|----|   |
//                                          +--|----|
//                                             | or |--- higherPriReq[3]
//           req[2] ---------------------------|----|
//
//                0 -----|-----|
//                       | and |--- grant[0]
//           req[0] -----|-----|
//
//  higherPriReq[1] -|>o-|-----|
//                       | and |--- grant[1]
//           req[1] -----|-----|
//
//  higherPriReq[2] -|>o-|-----|
//                       | and |--- grant[2]
//           req[2] -----|-----|
//                  
//  higherPriReq[3] -|>o-|-----|
//                       | and |--- grant[3]
//           req[3] -----|-----|  

////////////////////////////////////////////////////////////////////////////////
// Masked fixed priority arbiter
////////////////////////////////////////////////////////////////////////////////
assign maskHigherPriReq[NO_OF_REQS-1:1] = maskHigherPriReq[NO_OF_REQS-2:0] | maskedReq[NO_OF_REQS-2:0];
assign maskHigherPriReq[0] = 1'b0;
assign maskedGrant[NO_OF_REQS-1:0] = maskedReq[NO_OF_REQS-1:0] & ~maskHigherPriReq[NO_OF_REQS-1:0];

////////////////////////////////////////////////////////////////////////////////
// Unmasked fixed priority arbiter
////////////////////////////////////////////////////////////////////////////////
assign unmaskHigherPriReq[NO_OF_REQS-1:1] = unmaskHigherPriReq[NO_OF_REQS-2:0] | req[NO_OF_REQS-2:0];
assign unmaskHigherPriReq[0] = 1'b0;
assign unmaskedGrant[NO_OF_REQS-1:0] = req[NO_OF_REQS-1:0] & ~unmaskHigherPriReq[NO_OF_REQS-1:0];

// Masked represents a requests from the upper part of the req vector, above the
// previous grant. Unmasked represents the entire request vector. The priority
// arbiter running on the upper portion of the request vector takes priority
// over the priority arbiter running on the lower portion.
assign grant[NO_OF_REQS-1:0] = (|maskedReq[NO_OF_REQS-1:0]) ? maskedGrant[NO_OF_REQS-1:0] : unmaskedGrant[NO_OF_REQS-1:0];

////////////////////////////////////////////////////////////////////////////////
// Mask register. Provides a mask to mask off all requests below and including
// the previous awarded.
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                // Allow the lowest numbered request to win the first access
                maskReg <= {NO_OF_REQS{1'b1}};
            end
        else if (grantEn)
            begin
                if (|maskedReq[NO_OF_REQS-1:0])
                    begin
                        // Grant is from a higher number request
                        maskReg <= maskHigherPriReq[NO_OF_REQS-1:0];
                    end
                else
                    begin
                        // Grant is from a lower or identical number request as no
                        // higher number requests are asserted.
                        maskReg <= unmaskHigherPriReq[NO_OF_REQS-1:0];
                    end
            end
    end

endmodule // roundRobinArbiter