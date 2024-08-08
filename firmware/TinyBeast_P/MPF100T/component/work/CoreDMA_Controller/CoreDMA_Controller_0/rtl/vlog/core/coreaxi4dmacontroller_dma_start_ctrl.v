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
module CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_DMAStartCtrl (
    // Inputs
    clock,
    resetn,
    strtDMAOp,
    strtDMAOpInt,
    ldIntDscrptrAck,
    // Outputs
    ldDscrptr,
    ldDscrptrNum
);

////////////////////////////////////////////////////////////////////////////////
// User modifiable parameters
////////////////////////////////////////////////////////////////////////////////
parameter NUM_INT_BDS       = 4;
parameter NUM_INT_BDS_WIDTH = 2;

////////////////////////////////////////////////////////////////////////////////
// Port directions
////////////////////////////////////////////////////////////////////////////////
input                               clock;
input                               resetn;
input   [NUM_INT_BDS-1:0]           strtDMAOp;
input   [NUM_INT_BDS-1:0]           strtDMAOpInt;
input                               ldIntDscrptrAck;
output                              ldDscrptr;
output  [NUM_INT_BDS_WIDTH-1:0]     ldDscrptrNum;

////////////////////////////////////////////////////////////////////////////////
// Internal signals
////////////////////////////////////////////////////////////////////////////////
reg     [NUM_INT_BDS-1:0]           strtBitReg;
wire    [NUM_INT_BDS-1:0]           setStrtBit;
wire    [NUM_INT_BDS-1:0]           clrStrtBit;
integer                             strtBitIdx;
wire    [NUM_INT_BDS-1:0]           grant;

////////////////////////////////////////////////////////////////////////////////
// Start bit register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                strtBitReg <= {NUM_INT_BDS{1'b0}};
            end
        else
            begin
                for (strtBitIdx = 0; strtBitIdx < NUM_INT_BDS; strtBitIdx = strtBitIdx + 1)
                    begin
                        if (setStrtBit[strtBitIdx])
                            begin
                                strtBitReg[strtBitIdx] <= 1'b1;
                            end
                        else if (clrStrtBit[strtBitIdx])
                            begin
                                strtBitReg[strtBitIdx] <= 1'b0;
                            end
                    end
            end
    end

////////////////////////////////////////////////////////////////////////////////
// Round robin arbiter instantiation
////////////////////////////////////////////////////////////////////////////////
CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_roundRobinArbiterWAck # (
    .NO_OF_REQS     (NUM_INT_BDS)
) DMAStartCtrlRRA (
    // Inputs
    .clock          (clock),
    .resetn         (resetn),
    .req            (strtBitReg),
    .grantAck       (ldIntDscrptrAck),
    // Outputs
    .nextGrant      (clrStrtBit),
    .grant          (grant)
);

assign setStrtBit = strtDMAOp | strtDMAOpInt;

// Convert from one-hot to BCD
assign ldDscrptrNum = (grant == 32'b00000000000000000000000000000010) ? 'd1  :
                      (grant == 32'b00000000000000000000000000000100) ? 'd2  :
                      (grant == 32'b00000000000000000000000000001000) ? 'd3  :
                      (grant == 32'b00000000000000000000000000010000) ? 'd4  :
                      (grant == 32'b00000000000000000000000000100000) ? 'd5  :
                      (grant == 32'b00000000000000000000000001000000) ? 'd6  :
                      (grant == 32'b00000000000000000000000010000000) ? 'd7  :
                      (grant == 32'b00000000000000000000000100000000) ? 'd8  :
                      (grant == 32'b00000000000000000000001000000000) ? 'd9  :
                      (grant == 32'b00000000000000000000010000000000) ? 'd10 :
                      (grant == 32'b00000000000000000000100000000000) ? 'd11 :
                      (grant == 32'b00000000000000000001000000000000) ? 'd12 :
                      (grant == 32'b00000000000000000010000000000000) ? 'd13 :
                      (grant == 32'b00000000000000000100000000000000) ? 'd14 :
                      (grant == 32'b00000000000000001000000000000000) ? 'd15 :
                      (grant == 32'b00000000000000010000000000000000) ? 'd16 :
                      (grant == 32'b00000000000000100000000000000000) ? 'd17 :
                      (grant == 32'b00000000000001000000000000000000) ? 'd18 :
                      (grant == 32'b00000000000010000000000000000000) ? 'd19 :
                      (grant == 32'b00000000000100000000000000000000) ? 'd20 :
                      (grant == 32'b00000000001000000000000000000000) ? 'd21 :
                      (grant == 32'b00000000010000000000000000000000) ? 'd22 :
                      (grant == 32'b00000000100000000000000000000000) ? 'd23 :
                      (grant == 32'b00000001000000000000000000000000) ? 'd24 :
                      (grant == 32'b00000010000000000000000000000000) ? 'd25 :
                      (grant == 32'b00000100000000000000000000000000) ? 'd26 :
                      (grant == 32'b00001000000000000000000000000000) ? 'd27 :
                      (grant == 32'b00010000000000000000000000000000) ? 'd28 :
                      (grant == 32'b00100000000000000000000000000000) ? 'd29 :
                      (grant == 32'b01000000000000000000000000000000) ? 'd30 :
                      (grant == 32'b10000000000000000000000000000000) ? 'd31 :
                      'd0;

assign ldDscrptr = (|grant);
endmodule // DMAStartCtrl