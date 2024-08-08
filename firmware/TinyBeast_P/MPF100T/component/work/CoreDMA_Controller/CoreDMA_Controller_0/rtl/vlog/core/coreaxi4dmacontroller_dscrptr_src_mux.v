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
module CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_dscrptrSrcMux (
    // Inputs 
    clock,
    resetn,
    ldIntDscrptr,
    intDscrptrNum_DMAStartCtrl,
    fetchIntDscrptr,
    intDscrptrNum_DMATranCtrl,
    dscrptrNValidAck,
    dscrptrValid_BufferDescriptors,
    dscrptrData_BufferDescriptors,
    readDscrptrValid,
    ldExtDscrptr,
    dataValid_ExtDscrptrFetch,
    strDscrptr_ExtDscrptrFetch,
    intDscrptrNum_ExtDscrptrFetch,
    extDscrptrAddr_ExtDscrptrFetch,
    dscrptrData_ExtDscrptrFetch,
    dscrptrValid_ExtDscrptrFetch,
    // Outputs
    ldIntDscrptrAck,
    intFetchAck,
    dscrptrNValid,
    intDscrptrNum_intStatusMux,
    extDscrptr_intStatusMux,
    strDscrptr_intStatusMux,
    extDscrptrAddr_intStatusMux,
    ldDscrptr,
    dataValid,
    strDscrptr,
    externDscrptr,
    intDscrptrNum,
    extDscrptrAddr,
    dscrptrData,
    ldExtDscrptrAck,
    readDscrptr,
    intDscrptrNum_BufferDescriptors
);

////////////////////////////////////////////////////////////////////////////////
// User modifiable parameters
////////////////////////////////////////////////////////////////////////////////
parameter NUM_INT_BDS        = 4;
parameter NUM_INT_BDS_WIDTH  =  2;
parameter DSCRPTR_DATA_WIDTH = 133;

////////////////////////////////////////////////////////////////////////////////
// Port directions
////////////////////////////////////////////////////////////////////////////////
input                                   clock;
input                                   resetn;
input                                   ldIntDscrptr;
input       [NUM_INT_BDS_WIDTH-1:0]     intDscrptrNum_DMAStartCtrl;
input                                   fetchIntDscrptr;
input       [NUM_INT_BDS_WIDTH-1:0]     intDscrptrNum_DMATranCtrl;
input                                   dscrptrNValidAck;
input                                   dscrptrValid_BufferDescriptors;
input       [DSCRPTR_DATA_WIDTH-1:0]    dscrptrData_BufferDescriptors;
input                                   readDscrptrValid;
input                                   ldExtDscrptr;
input                                   dataValid_ExtDscrptrFetch;
input                                   strDscrptr_ExtDscrptrFetch;
input       [NUM_INT_BDS_WIDTH-1:0]     intDscrptrNum_ExtDscrptrFetch;
input       [31:0]                      extDscrptrAddr_ExtDscrptrFetch;
input       [DSCRPTR_DATA_WIDTH-1:0]    dscrptrData_ExtDscrptrFetch;
input                                   dscrptrValid_ExtDscrptrFetch;
output reg                              ldIntDscrptrAck;
output reg                              intFetchAck;
output reg                              dscrptrNValid;
output reg  [NUM_INT_BDS_WIDTH-1:0]     intDscrptrNum_intStatusMux;
output reg                              extDscrptr_intStatusMux;
output reg                              strDscrptr_intStatusMux;
output reg  [31:0]                      extDscrptrAddr_intStatusMux;
output reg                              ldDscrptr;
output reg                              dataValid;
output reg                              strDscrptr;
output reg                              externDscrptr;
output reg  [NUM_INT_BDS_WIDTH-1:0]     intDscrptrNum;
output reg  [31:0]                      extDscrptrAddr;
output reg  [DSCRPTR_DATA_WIDTH-1:0]    dscrptrData;
output reg                              ldExtDscrptrAck;
output reg                              readDscrptr;
output      [NUM_INT_BDS_WIDTH-1:0]     intDscrptrNum_BufferDescriptors;

////////////////////////////////////////////////////////////////////////////////
// Constants
////////////////////////////////////////////////////////////////////////////////
localparam [1:0] NEW_INT_DSCRPTR           = 2'b00;
localparam [1:0] NEXT_INT_DSCRPTR_IN_CHAIN = 2'b01;
localparam [1:0] LD_EXT_DSCRPTR            = 2'b10;

localparam [4:0] IDLE                      = 5'b00001;
localparam [4:0] WAIT_READ_VALID           = 5'b00010;
localparam [4:0] INVALID_DSCRPTR           = 5'b00100;
localparam [4:0] EXT_DSCPTR_READ           = 5'b01000;
localparam [4:0] RRA_ACK                   = 5'b10000;

////////////////////////////////////////////////////////////////////////////////
// Internal signals
////////////////////////////////////////////////////////////////////////////////
wire    [2:0]                   RRAReq;
wire    [2:0]                   grant;
reg                             grantAck;
wire    [1:0]                   dscrptrIFSel;
reg                             dscrptrNValid_d;
reg     [NUM_INT_BDS_WIDTH-1:0] intDscrptrNum_intStatusMux_d;
reg                             extDscrptr_intStatusMux_d;
reg                             strDscrptr_intStatusMux_d;
reg     [31:0]                  extDscrptrAddr_intStatusMux_d;
reg                             dscrptrValid_DscrptrMux;
reg     [4:0]                   currState;
reg     [4:0]                   nextState;

////////////////////////////////////////////////////////////////////////////////
// Round robin arbiter instantiation
////////////////////////////////////////////////////////////////////////////////
CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_roundRobinArbiterWAck # (
    .NO_OF_REQS     (3)
) dscrptrSrcMuxRRA (
    // Inputs
    .clock          (clock),
    .resetn         (resetn),
    .req            (RRAReq),
    .grantAck       (grantAck),
    // Outputs
    .nextGrant      (),
    .grant          (grant)
);

assign RRAReq = {ldExtDscrptr, fetchIntDscrptr, ldIntDscrptr};

// Convert from one-hot to BCD
assign dscrptrIFSel = (grant == 3'b010) ? NEXT_INT_DSCRPTR_IN_CHAIN :
                      (grant == 3'b100) ? LD_EXT_DSCRPTR :
                       NEW_INT_DSCRPTR;

////////////////////////////////////////////////////////////////////////////////
// DscrptrAddrMux
////////////////////////////////////////////////////////////////////////////////
assign intDscrptrNum_BufferDescriptors = (dscrptrIFSel[0]) ? intDscrptrNum_DMATranCtrl : intDscrptrNum_DMAStartCtrl;

////////////////////////////////////////////////////////////////////////////////
// DscrptrMux
////////////////////////////////////////////////////////////////////////////////
always @ (*)
    begin
        case (dscrptrIFSel)
            NEW_INT_DSCRPTR:
                begin
                    dscrptrValid_DscrptrMux <= dscrptrValid_BufferDescriptors;
                    dataValid               <= 1'b0;
                    strDscrptr              <= 1'b0;
                    externDscrptr           <= 1'b0;
                    intDscrptrNum           <= intDscrptrNum_BufferDescriptors;
                    extDscrptrAddr          <= 32'b0;
                    dscrptrData             <= dscrptrData_BufferDescriptors;
                end
            NEXT_INT_DSCRPTR_IN_CHAIN:
                begin
                    dscrptrValid_DscrptrMux <= dscrptrValid_BufferDescriptors;
                    dataValid               <= 1'b0;
                    strDscrptr              <= 1'b0;
                    externDscrptr           <= 1'b0;
                    intDscrptrNum           <= intDscrptrNum_BufferDescriptors;
                    extDscrptrAddr          <= 32'b0;
                    dscrptrData             <= dscrptrData_BufferDescriptors;
                end
            LD_EXT_DSCRPTR:
                begin
                    dscrptrValid_DscrptrMux <= dscrptrValid_ExtDscrptrFetch;
                    dataValid               <= dataValid_ExtDscrptrFetch;
                    strDscrptr              <= strDscrptr_ExtDscrptrFetch;
                    externDscrptr           <= 1'b1;
                    intDscrptrNum           <= intDscrptrNum_ExtDscrptrFetch;
                    extDscrptrAddr          <= extDscrptrAddr_ExtDscrptrFetch;
                    dscrptrData             <= dscrptrData_ExtDscrptrFetch;
                end
            default:
                begin
                    dscrptrValid_DscrptrMux <= 1'b0;
                    dataValid               <= 1'b0;
                    strDscrptr              <= 1'b0;
                    externDscrptr           <= 1'b0;
                    intDscrptrNum           <= {NUM_INT_BDS_WIDTH{1'b0}};
                    extDscrptrAddr          <= 32'b0;
                    dscrptrData             <= {DSCRPTR_DATA_WIDTH{1'b0}};
                end
        endcase
    end

////////////////////////////////////////////////////////////////////////////////
// DscrptrValidCheck
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                currState <= IDLE;
            end
        else
            begin
                currState <= nextState;
            end
    end

always @ (*)
    begin
        // Default assignments
        readDscrptr                     <= 1'b0;
        ldIntDscrptrAck                 <= 1'b0;
        intFetchAck                     <= 1'b0;
        ldExtDscrptrAck                 <= 1'b0;
        ldDscrptr                       <= 1'b0;
        grantAck                        <= 1'b0;
        dscrptrNValid_d                 <= 1'b0;
        intDscrptrNum_intStatusMux_d    <= intDscrptrNum_intStatusMux;
        extDscrptr_intStatusMux_d       <= extDscrptr_intStatusMux;
        strDscrptr_intStatusMux_d       <= strDscrptr_intStatusMux;
        extDscrptrAddr_intStatusMux_d   <= extDscrptrAddr_intStatusMux;
        case (currState)
            IDLE:
                begin
                    if (|grant[2:0])
                        begin
                            if (|grant[1:0])
                                begin
                                    // Internal descriptor
                                    readDscrptr <= 1'b1;
                                    nextState   <= WAIT_READ_VALID;
                                end
                            else
                                begin
                                    // External or stream descriptor
                                    nextState   <= EXT_DSCPTR_READ;
                                end
                        end
                    else
                        begin
                            nextState <= IDLE;
                        end
                end
            WAIT_READ_VALID:
                begin
                    if (readDscrptrValid)
                        begin
                            if (dscrptrValid_DscrptrMux)
                                begin
                                    ldDscrptr <= 1'b1;
                                    nextState <= RRA_ACK;
                                end
                            else
                                begin
                                    // Invalid descriptor
                                    dscrptrNValid_d <= 1'b1;
                                    // Register the signals as they'll go invalid 
                                    intDscrptrNum_intStatusMux_d  <= intDscrptrNum;
                                    extDscrptr_intStatusMux_d     <= 1'b0;
                                    strDscrptr_intStatusMux_d     <= 1'b0;
                                    extDscrptrAddr_intStatusMux_d <= 32'b0;
                                    nextState                     <= INVALID_DSCRPTR;
                                end
                            if (grant[0]) // ldIntDscrptr in control
                                begin
                                    ldIntDscrptrAck <= 1'b1;
                                end
                            else if (grant[1]) // fetchIntDscrptr in control
                                begin
                                    intFetchAck <= 1'b1;
                                end
                        end
                    else
                        begin
                            readDscrptr <= 1'b1;
                            nextState   <= WAIT_READ_VALID;
                        end
                end
            EXT_DSCPTR_READ:
                begin
                    ldExtDscrptrAck <= 1'b1;
                    if (dscrptrValid_DscrptrMux)
                        begin
                            ldDscrptr       <= 1'b1;
                            nextState       <= RRA_ACK;
                        end
                    else
                        begin
                            // Invalid descriptor
                            dscrptrNValid_d <= 1'b1;
                            // Register the signals as they'll go invalid 
                            intDscrptrNum_intStatusMux_d  <= intDscrptrNum;
                            extDscrptr_intStatusMux_d     <= externDscrptr;
                            strDscrptr_intStatusMux_d     <= strDscrptr;
                            extDscrptrAddr_intStatusMux_d <= extDscrptrAddr;
                            nextState                     <= INVALID_DSCRPTR;
                        end
                end
            INVALID_DSCRPTR:
                begin
                    if (dscrptrNValidAck)
                        begin
                            grantAck <= 1'b1;
                            nextState <= IDLE;
                        end
                    else
                        begin
                            dscrptrNValid_d <= 1'b1;
                            nextState       <= INVALID_DSCRPTR;
                        end
                end
            RRA_ACK:
                begin
                    grantAck    <= 1'b1;
                    nextState   <= IDLE;
                end
            default:
                begin
                    nextState <= IDLE;
                end
        endcase
    end

////////////////////////////////////////////////////////////////////////////////
// Register to hold dscrptrNValid for invalid descriptors for passing to inStatusMux
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                dscrptrNValid <= 1'b0;
            end
        else
            begin
                dscrptrNValid <= dscrptrNValid_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// Register to hold intDscrptrNum for invalid descriptors for passing to inStatusMux
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                intDscrptrNum_intStatusMux <= {NUM_INT_BDS_WIDTH{1'b0}};
            end
        else
            begin
                intDscrptrNum_intStatusMux <= intDscrptrNum_intStatusMux_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// Register to hold extDscrptrAddr for invalid descriptors for passing to inStatusMux
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                extDscrptrAddr_intStatusMux <= 32'b0;
            end
        else
            begin
                extDscrptrAddr_intStatusMux <= extDscrptrAddr_intStatusMux_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// Register to hold extDscrptr for invalid descriptors for passing to inStatusMux
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                extDscrptr_intStatusMux <= 1'b0;
            end
        else
            begin
                extDscrptr_intStatusMux <= extDscrptr_intStatusMux_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// Register to hold strDscrptr for invalid descriptors for passing to inStatusMux
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                strDscrptr_intStatusMux <= 1'b0;
            end
        else
            begin
                strDscrptr_intStatusMux <= strDscrptr_intStatusMux_d;
            end
    end

endmodule // dscrptrSrcMux