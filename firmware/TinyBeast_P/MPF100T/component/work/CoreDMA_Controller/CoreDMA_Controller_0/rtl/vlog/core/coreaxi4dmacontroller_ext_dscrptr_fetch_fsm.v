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
module CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_extDscrptrFetchFSM (
    // Inputs
    clock,
    resetn,
    ldExtDscrptrAck,
    strDscrptrValid,
    strDscrptrAddr,
    fetchExtDscrptr,
    clrExtDscrptr,
    extRdyCheck,
    intDscrptrNum_DMATranCtrl,
    extDscrptrAddr_DMATranCtrl,
    configRegByte2_DMATranCtrl,
    dscrptrData_AXI4MasterCtrl,
    extFetchValid,
    dataValid_AXI4MasterCtrl,
    dscrptrValid_AXI4MasterCtrl,
    // Outputs
    strDscrptrAck,
    strDscrptrAck_dscrptrValid,
    intDscrptrNum,
    extDscrptrAddr,
    dscrptrData,
    dscrptrValid,
    dataValid,
    strDcrptr,
    ldExtDscrptr,
    strFetchHoldOff,
    extFetchDone,
    extClrAck,
    extRdyValid,
    extRdy,
    strtStrDscrptrRd,
    strtExtDscrptrRd,
    strtExtDscrptrRdyCheck,
    clrExtDscrptrDataValid,
    strtAddr,
    configRegByte2
);

////////////////////////////////////////////////////////////////////////////////
// Parameters
////////////////////////////////////////////////////////////////////////////////
parameter DSCRPTR_DATA_WIDTH         = 133;
parameter MAX_TRAN_SIZE_WIDTH        = 12;
parameter NUM_INT_BDS_WIDTH          = 2;

////////////////////////////////////////////////////////////////////////////////
// Port directions
////////////////////////////////////////////////////////////////////////////////
// Inputs
input                                   clock;
input                                   resetn;
input                                   ldExtDscrptrAck;
input                                   strDscrptrValid;
input       [31:0]                      strDscrptrAddr;
input                                   fetchExtDscrptr;
input                                   clrExtDscrptr;
input                                   extRdyCheck;
input       [NUM_INT_BDS_WIDTH-1:0]     intDscrptrNum_DMATranCtrl;
input       [31:0]                      extDscrptrAddr_DMATranCtrl;
input       [DSCRPTR_DATA_WIDTH-1:0]    dscrptrData_AXI4MasterCtrl;
input                                   dscrptrValid_AXI4MasterCtrl;
input                                   extFetchValid;
input       [1:0]                       dataValid_AXI4MasterCtrl;
input       [7:0]                       configRegByte2_DMATranCtrl;                                

// Outputs
output reg                              strDscrptrAck;
output reg                              strDscrptrAck_dscrptrValid;
output   [NUM_INT_BDS_WIDTH-1:0]        intDscrptrNum;
output   [31:0]                         extDscrptrAddr;
output   [DSCRPTR_DATA_WIDTH-1:0]       dscrptrData;
output                                  dscrptrValid;
output                                  dataValid;
output                                  strDcrptr;
output                                  ldExtDscrptr;
output reg                              strFetchHoldOff;
output reg                              extFetchDone;
output                                  extClrAck;
output reg                              extRdyValid;
output reg                              extRdy;
output reg                              strtStrDscrptrRd;
output reg                              strtExtDscrptrRd;
output reg                              strtExtDscrptrRdyCheck;
output reg                              clrExtDscrptrDataValid;
output reg  [31:0]                      strtAddr;
output reg  [7:0]                       configRegByte2;

////////////////////////////////////////////////////////////////////////////////
// Constants
////////////////////////////////////////////////////////////////////////////////
localparam [7:0] IDLE               = 8'b00000001;
localparam [7:0] EXT_FETCH_WAIT     = 8'b00000010;
localparam [7:0] EXT_FETCH_STORE    = 8'b00000100;
localparam [7:0] EXT_VALID_CHECK    = 8'b00001000;
localparam [7:0] EXT_CLR_VALID_WAIT = 8'b00010000;
localparam [7:0] EXT_CLR_VALID      = 8'b00100000;
localparam [7:0] STR_FETCH_WAIT     = 8'b01000000;
localparam [7:0] STR_FETCH_STORE    = 8'b10000000;

localparam       CONFIG_REG_2ND_BYTE_OFFSET = 1;

////////////////////////////////////////////////////////////////////////////////
// Internal signals
////////////////////////////////////////////////////////////////////////////////
reg [7:0]                       currState;
reg [7:0]                       nextState;
reg                             ldExtDscrptrReg;
reg                             ldExtDscrptrReg_d;
reg                             dataValidReg;
reg                             dataValidReg_d;
reg [NUM_INT_BDS_WIDTH-1:0]     intDscrptrNumReg;
reg [NUM_INT_BDS_WIDTH-1:0]     intDscrptrNumReg_d;
reg [31:0]                      extDscrptrAddrReg;
reg [31:0]                      extDscrptrAddrReg_d;
reg [DSCRPTR_DATA_WIDTH-1:0]    dscrptrDataReg;
reg [DSCRPTR_DATA_WIDTH-1:0]    dscrptrDataReg_d;
reg                             dscrptrValidReg;
reg                             dscrptrValidReg_d;
reg                             extClrAckReg;
reg                             extClrAckReg_d;
reg                             strDcrptrReg;
reg                             strDcrptrReg_d;

////////////////////////////////////////////////////////////////////////////////
// Current state register
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

////////////////////////////////////////////////////////////////////////////////
// Next state combinatorial logic
////////////////////////////////////////////////////////////////////////////////
always @ (*)
    begin
        // Default assignments
        ldExtDscrptrReg_d          <= 1'b0;
        dataValidReg_d             <= dataValidReg;
        intDscrptrNumReg_d         <= intDscrptrNumReg;
        extDscrptrAddrReg_d        <= extDscrptrAddrReg;
        dscrptrDataReg_d           <= dscrptrDataReg;
        dscrptrValidReg_d          <= dscrptrValidReg;
        strtStrDscrptrRd           <= 1'b0;
        strtExtDscrptrRd           <= 1'b0;
        strtExtDscrptrRdyCheck     <= 1'b0;
        strtAddr                   <= 32'b0;
        clrExtDscrptrDataValid     <= 1'b0;
        strDcrptrReg_d             <= 1'b0;
        extFetchDone               <= 1'b0;
        extRdyValid                <= 1'b0;
        strDscrptrAck              <= 1'b0;
        strDscrptrAck_dscrptrValid <= 1'b0;
        extClrAckReg_d             <= 1'b0;
        extRdy                     <= 1'b0;
        configRegByte2             <= 8'b0;
        strFetchHoldOff            <= 1'b0;
        case (currState)
            IDLE:
                begin
                    if (fetchExtDscrptr)
                        begin
                            strtExtDscrptrRd <= 1'b1;
                            strtAddr         <= extDscrptrAddr_DMATranCtrl;
                            nextState        <= EXT_FETCH_WAIT;
                        end
                    else if (extRdyCheck)
                        begin
                            strtExtDscrptrRdyCheck <= 1'b1;
                            // AXI4 protocol - address offset must match write strobes
                            strtAddr               <= extDscrptrAddr_DMATranCtrl + CONFIG_REG_2ND_BYTE_OFFSET;
                            nextState              <= EXT_VALID_CHECK;
                        end
                    else if (clrExtDscrptr)
                        begin
                            // Essentially perform a read-modify-write to clear the dataValid bit
                            // in the external descriptor (config register, bit 13).
                            // Required as the granularity of the AXI4 DMA interface is 1 byte.
                            configRegByte2          <= configRegByte2_DMATranCtrl; 
                            clrExtDscrptrDataValid  <= 1'b1;
                            // AXI4 protocol - address offset must match write strobes
                            strtAddr                <= extDscrptrAddr_DMATranCtrl + CONFIG_REG_2ND_BYTE_OFFSET;
                            nextState               <= EXT_CLR_VALID;
                        end
                    else if (strDscrptrValid)
                        begin
                            strtStrDscrptrRd <= 1'b1;
                            strFetchHoldOff  <= 1'b1;
                            strtAddr         <= strDscrptrAddr;
                            nextState        <= STR_FETCH_WAIT;
                        end
                    else
                        begin
                            nextState <= currState;
                        end
                end
            EXT_FETCH_WAIT:
                begin
                    if (extFetchValid)
                        begin
                            ldExtDscrptrReg_d   <= 1'b1;
                            dataValidReg_d      <= &dataValid_AXI4MasterCtrl[1:0];
                            intDscrptrNumReg_d  <= intDscrptrNum_DMATranCtrl;
                            extDscrptrAddrReg_d <= extDscrptrAddr_DMATranCtrl;
                            dscrptrDataReg_d    <= {dscrptrData_AXI4MasterCtrl[133:14], &dataValid_AXI4MasterCtrl[1:0], dscrptrData_AXI4MasterCtrl[12:0]};
                            dscrptrValidReg_d   <= dscrptrValid_AXI4MasterCtrl;
                            nextState           <= EXT_FETCH_STORE;
                        end
                    else
                        begin
                            strtExtDscrptrRd <= 1'b1;
                            strtAddr         <= extDscrptrAddr_DMATranCtrl;
                            nextState        <= currState;
                        end
                end
            EXT_FETCH_STORE:
                begin
                    if (ldExtDscrptrAck)
                        begin
                            dataValidReg_d      <= 1'b0;
                            intDscrptrNumReg_d  <= {NUM_INT_BDS_WIDTH{1'b0}};
                            extDscrptrAddrReg_d <= 32'b0;
                            dscrptrDataReg_d    <= {DSCRPTR_DATA_WIDTH{1'b0}};
                            dscrptrValidReg_d   <= 1'b0;
                            extFetchDone        <= 1'b1;
                            nextState           <= IDLE;
                        end
                    else
                        begin
                            ldExtDscrptrReg_d <= 1'b1;
                            nextState         <= EXT_FETCH_STORE;
                        end
                end
            EXT_VALID_CHECK:
                begin
                    if (extFetchValid)
                        begin
                            extRdyValid <= 1'b1;
                            extRdy      <= &dataValid_AXI4MasterCtrl[1:0];
                            nextState   <= IDLE;
                        end
                    else
                        begin
                            strtExtDscrptrRdyCheck <= 1'b1;
                            // AXI4 protocol - address offset must match write strobes
                            strtAddr               <= extDscrptrAddr_DMATranCtrl + CONFIG_REG_2ND_BYTE_OFFSET;
                            nextState              <= currState;
                        end
                end
            EXT_CLR_VALID:
                begin
                    if (extFetchValid)
                        begin
                            extClrAckReg_d <= 1'b1;
                            nextState      <= EXT_CLR_VALID_WAIT;
                        end
                    else
                        begin
                            configRegByte2          <= configRegByte2_DMATranCtrl; 
                            clrExtDscrptrDataValid  <= 1'b1;
                            // AXI4 protocol - address offset must match write strobes
                            strtAddr                <= extDscrptrAddr_DMATranCtrl + CONFIG_REG_2ND_BYTE_OFFSET;
                            nextState               <= currState;
                        end
                end
            EXT_CLR_VALID_WAIT:
                begin
                    if (fetchExtDscrptr)
                        begin
                            strtExtDscrptrRd <= 1'b1;
                            strtAddr         <= extDscrptrAddr_DMATranCtrl;
                            nextState        <= EXT_FETCH_WAIT;
                        end
                    else if (strDscrptrValid)
                        begin
                            strtStrDscrptrRd <= 1'b1;
                            strFetchHoldOff  <= 1'b1;
                            strtAddr         <= strDscrptrAddr;
                            nextState        <= STR_FETCH_WAIT;
                        end
                    else
                        begin
                            nextState <= IDLE;
                        end
                end
            STR_FETCH_WAIT:
                begin
                    if (extFetchValid)
                        begin
                            ldExtDscrptrReg_d   <= 1'b1;
                            strDcrptrReg_d      <= 1'b1;
                            dataValidReg_d      <= dataValid_AXI4MasterCtrl[0];
                            intDscrptrNumReg_d  <= {NUM_INT_BDS_WIDTH{1'b0}};
                            extDscrptrAddrReg_d <= strDscrptrAddr;
                            dscrptrDataReg_d    <= dscrptrData_AXI4MasterCtrl;
                            dscrptrValidReg_d   <= dscrptrValid_AXI4MasterCtrl;
                            nextState           <= STR_FETCH_STORE;
                        end
                    else
                        begin
                            strtStrDscrptrRd <= 1'b1;
                            strFetchHoldOff  <= 1'b1;
                            strtAddr         <= strDscrptrAddr;
                            nextState        <= currState;
                        end
                end
            STR_FETCH_STORE:
                begin
                    if (ldExtDscrptrAck)
                        begin
                            dataValidReg_d             <= 1'b0;
                            intDscrptrNumReg_d         <= {NUM_INT_BDS_WIDTH{1'b0}};
                            extDscrptrAddrReg_d        <= 32'b0;
                            dscrptrDataReg_d           <= {DSCRPTR_DATA_WIDTH{1'b0}};
                            dscrptrValidReg_d          <= 1'b0;
                            strDscrptrAck              <= 1'b1;
                            strDscrptrAck_dscrptrValid <= dscrptrValidReg;
                            nextState                  <= IDLE;
                        end
                    else
                        begin
                            ldExtDscrptrReg_d <= 1'b1;
                            strDcrptrReg_d    <= 1'b1;
                            nextState         <= currState;
                        end
                end
            default:
                begin
                    nextState <= IDLE;
                end
        endcase
    end

////////////////////////////////////////////////////////////////////////////////
// ldExtDscrptr register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                ldExtDscrptrReg <= 1'b0;
            end
        else
            begin
                ldExtDscrptrReg <= ldExtDscrptrReg_d;
            end
    end
assign ldExtDscrptr = ldExtDscrptrReg;

////////////////////////////////////////////////////////////////////////////////
// dataValid register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                dataValidReg <= 1'b0;
            end
        else
            begin
                dataValidReg <= dataValidReg_d;
            end
    end
assign dataValid = dataValidReg;

////////////////////////////////////////////////////////////////////////////////
// intDscrptrNum register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                intDscrptrNumReg <= {NUM_INT_BDS_WIDTH{1'b0}};
            end
        else
            begin
                intDscrptrNumReg <= intDscrptrNumReg_d;
            end
    end
assign intDscrptrNum = intDscrptrNumReg;

////////////////////////////////////////////////////////////////////////////////
// extDscrptrAddr register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                extDscrptrAddrReg <= 32'b0;
            end
        else
            begin
                extDscrptrAddrReg <= extDscrptrAddrReg_d;
            end
    end
assign extDscrptrAddr = extDscrptrAddrReg;

////////////////////////////////////////////////////////////////////////////////
// dscrptrData register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                dscrptrDataReg <= {DSCRPTR_DATA_WIDTH{1'b0}};
            end
        else
            begin
                dscrptrDataReg <= dscrptrDataReg_d;
            end
    end
assign dscrptrData = dscrptrDataReg;

////////////////////////////////////////////////////////////////////////////////
// dscrptrValid register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                dscrptrValidReg <= 1'b0;
            end
        else
            begin
                dscrptrValidReg <= dscrptrValidReg_d;
            end
    end
assign dscrptrValid = dscrptrValidReg;

////////////////////////////////////////////////////////////////////////////////
// extClrAck register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                extClrAckReg <= 1'b0;
            end
        else
            begin
                extClrAckReg <= extClrAckReg_d;
            end
    end
assign extClrAck = extClrAckReg;

////////////////////////////////////////////////////////////////////////////////
// strDcrptr register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                strDcrptrReg <= 1'b0;
            end
        else
            begin
                strDcrptrReg <= strDcrptrReg_d;
            end
    end
assign strDcrptr = strDcrptrReg;

endmodule // extDscrptrFetchFSM