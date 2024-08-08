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
// SVN $Revision: 37708 $
// SVN $Date: 2021-02-16 15:48:28 +0530 (Tue, 16 Feb 2021) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//
// ****************************************************************************/
module CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_bufferDescriptors (
    clock,
    resetn,
    
    // CtrlIFMuxCDC inputs
    ctrlSel,
    ctrlWr,
    ctrlAddr,
    ctrlWrData,
    ctrlWrStrbs,
    
    // DMAController inputs
    readDscrptr,
    intDscrptrNum_BufferDscrptrs,
    clrDataValidDscrptr,
    
    // CtrlIFMuxCDC outputs
    ctrlWrRdy,
    ctrlRdData,
    ctrlRdValid,
    
    // DMAController outputs
    dscrptrData,
    dataValidDscrptr,
    dscrptrValid,
    chain,
    readDscrptrValid,
	
	error_flag_sb_bd_out,
	error_flag_db_bd_out
);

////////////////////////////////////////////////////////////////////////////////
// Parameters
////////////////////////////////////////////////////////////////////////////////
parameter DSCRPTR_DATA_WIDTH = 133;
parameter NUM_INT_BDS        = 4;
parameter NUM_INT_BDS_WIDTH  = 2;
parameter DATA_REALIGNMENT   = 0;
parameter ECC				 = 1;

////////////////////////////////////////////////////////////////////////////////
// Port directions
////////////////////////////////////////////////////////////////////////////////
input                               clock;
input                               resetn;

// CtrlIFMuxCDC inputs
input                               ctrlSel;
input                               ctrlWr;
input  [10:0]                       ctrlAddr;
input  [31:0]                       ctrlWrData;
input  [3:0]                        ctrlWrStrbs;

// DMAController inputs
input                               readDscrptr;
input  [NUM_INT_BDS_WIDTH-1:0]      intDscrptrNum_BufferDscrptrs;
input  [NUM_INT_BDS-1:0]            clrDataValidDscrptr;

// CtrlIFMuxCDC outputs
output reg                          ctrlWrRdy;
output     [31:0]                   ctrlRdData;
output                              ctrlRdValid;

// DMAController outputs
output [DSCRPTR_DATA_WIDTH-1:0]     dscrptrData;
output [NUM_INT_BDS-1:0]            dataValidDscrptr;
output                              dscrptrValid;
output [NUM_INT_BDS-1:0]            chain;
output                              readDscrptrValid;

output								error_flag_sb_bd_out;
output								error_flag_db_bd_out;


////////////////////////////////////////////////////////////////////////////////
// Constants
////////////////////////////////////////////////////////////////////////////////
localparam[4:0]  CONFIG_REG_OFFSET            = 5'h00;
localparam[4:0]  BYTE_COUNT_REG_OFFSET        = 5'h04;
localparam[4:0]  SRC_ADDR_REG_OFFSET          = 5'h08;
localparam[4:0]  DST_ADDR_REG_OFFSET          = 5'h0C;
localparam[4:0]  NXT_DSCRPTR_REG_OFFSET       = 5'h10;

localparam[1:0]  WR_IDLE                      = 2'b01;
localparam[1:0]  WR_WAIT_RMR                  = 2'b10;

localparam[21:0] RD_IDLE                     = 22'b0000000000000000000001;
localparam[21:0] RD_RMR_WAIT_1               = 22'b0000000000000000000010;
localparam[21:0] RD_RMR_WAIT_2               = 22'b0000000000000000000100;
localparam[21:0] RD_RMR_WAIT_2_FETCH_WAIT_1  = 22'b0000000000000000001000;
localparam[21:0] RD_RMR_DONE                 = 22'b0000000000000000010000;
localparam[21:0] RD_RMR_DONE_FETCH_WAIT_1    = 22'b0000000000000000100000;
localparam[21:0] RD_RMR_DONE_FETCH_WAIT_2    = 22'b0000000000000001000000;
localparam[21:0] RD_FETCH_WAIT_1             = 22'b0000000000000010000000;
localparam[21:0] RD_FETCH_WAIT_2             = 22'b0000000000000100000000;
localparam[21:0] RD_FETCH_WAIT_2_RMR_WAIT_1  = 22'b0000000000001000000000;
localparam[21:0] RD_FETCH_WAIT_2_CTRL_WAIT_1 = 22'b0000000000010000000000;
localparam[21:0] RD_FETCH_DONE               = 22'b0000000000100000000000;
localparam[21:0] RD_FETCH_DONE_RMR_WAIT_1    = 22'b0000000001000000000000;
localparam[21:0] RD_FETCH_DONE_RMR_WAIT_2    = 22'b0000000010000000000000;
localparam[21:0] RD_FETCH_DONE_CTRL_WAIT_1   = 22'b0000000100000000000000;
localparam[21:0] RD_FETCH_DONE_CTRL_WAIT_2   = 22'b0000001000000000000000;
localparam[21:0] RD_CTRL_WAIT_1              = 22'b0000010000000000000000;
localparam[21:0] RD_CTRL_WAIT_2              = 22'b0000100000000000000000;
localparam[21:0] RD_CTRL_WAIT_2_FETCH_WAIT_1 = 22'b0001000000000000000000;
localparam[21:0] RD_CTRL_DONE                = 22'b0010000000000000000000;
localparam[21:0] RD_CTRL_DONE_FETCH_WAIT_1   = 22'b0100000000000000000000;
localparam[21:0] RD_CTRL_DONE_FETCH_WAIT_2   = 22'b1000000000000000000000;

////////////////////////////////////////////////////////////////////////////////
// Internal signals
////////////////////////////////////////////////////////////////////////////////
wire                            enCtrl0;
wire                            enCtrl1;
wire                            enCtrl2;
wire                            enCtrl3;
wire                            enCtrl4;
wire                            enCtrl5;
wire                            enCtrl6;
wire                            enCtrl7;
wire [NUM_INT_BDS_WIDTH-1:0]    ctrlAddrDec;
reg  [4:0]                      wrEn;
reg  [4:0]                      wrEn_d;
reg  [NUM_INT_BDS_WIDTH-1:0]    wrAddr;
reg  [NUM_INT_BDS_WIDTH-1:0]    wrAddr_d;
reg  [31:0]                     wrData;
reg  [31:0]                     wrData_d;
reg  [NUM_INT_BDS-1:0]          dscrptrValidReg;
reg  [NUM_INT_BDS-1:0]          srcDataValidReg;
reg  [NUM_INT_BDS-1:0]          dstDataReadyReg;
reg  [NUM_INT_BDS-1:0]          chainReg;
reg  [1:0]                      currWrState;
reg  [1:0]                      nextWrState;
wire [31:0]                     rdData0;
wire [31:0]                     rdData1;
wire [31:0]                     rdData2;
wire [31:0]                     rdData3;
wire [31:0]                     rdData4;
reg  [21:0]                     currRdState;
reg  [21:0]                     nextRdState;
reg                             rmrReq;
reg                             rmrReq_d;
reg  [4:0]                      rmrRdEn;
reg  [4:0]                      rmrRdEn_d;
reg  [NUM_INT_BDS-1:0]          rmrDscrptrNum;
reg  [NUM_INT_BDS-1:0]          rmrDscrptrNum_d;
reg  [4:0]                      rdEn;
reg  [4:0]                      rdEn_d;
reg  [NUM_INT_BDS_WIDTH-1:0]    rdAddr;
reg  [NUM_INT_BDS_WIDTH-1:0]    rdAddr_d;
reg                             rmrValid;
reg                             rmrValid_d;
reg  [31:0]                     rmrData;
reg  [31:0]                     rmrData_d;
reg                             ctrlRdValid;
reg                             ctrlRdValid_d;
reg  [31:0]                     ctrlRdData;
reg  [31:0]                     ctrlRdData_d;
reg                             readDscrptrValid;
reg                             readDscrptrValid_d;
reg  [DSCRPTR_DATA_WIDTH-1:0]   dscrptrData;
reg  [DSCRPTR_DATA_WIDTH-1:0]   dscrptrData_d;
wire                            ctrlSelInt;
integer                         intBD_idx;

wire  [4:0]                      error_flag_sb_bd;
wire  [4:0]                      error_flag_db_bd;

assign error_flag_sb_bd_out = (ECC) ? (error_flag_sb_bd[0] | error_flag_sb_bd[1] | error_flag_sb_bd[2] | error_flag_sb_bd[3] | error_flag_sb_bd[4]) : 1'b0;
assign error_flag_db_bd_out = (ECC) ? (error_flag_db_bd[0] | error_flag_db_bd[1] | error_flag_db_bd[2] | error_flag_db_bd[3] | error_flag_db_bd[4]) : 1'b0;

////////////////////////////////////////////////////////////////////////////////
// Address decoding
////////////////////////////////////////////////////////////////////////////////
assign ctrlSelInt  = (ctrlAddr[10:0] >= 11'h060) && (ctrlAddr[10:0] <= 11'h45C) ? ctrlSel : 1'b0;
assign enCtrl0     = (ctrlAddr[4:0] == CONFIG_REG_OFFSET)       ? ctrlSelInt : 1'b0;
assign enCtrl1     = (ctrlAddr[4:0] == BYTE_COUNT_REG_OFFSET)   ? ctrlSelInt : 1'b0;
assign enCtrl2     = (ctrlAddr[4:0] == SRC_ADDR_REG_OFFSET)     ? ctrlSelInt : 1'b0;
assign enCtrl3     = (ctrlAddr[4:0] == DST_ADDR_REG_OFFSET)     ? ctrlSelInt : 1'b0;
assign enCtrl4     = (ctrlAddr[4:0] == NXT_DSCRPTR_REG_OFFSET)  ? ctrlSelInt : 1'b0;
assign enCtrl5     = (ctrlAddr[4:0] == NXT_DSCRPTR_REG_OFFSET)  ? ctrlSelInt : 1'b0;
assign enCtrl6     = (ctrlAddr[4:0] == NXT_DSCRPTR_REG_OFFSET)  ? ctrlSelInt : 1'b0;
assign enCtrl7     = (ctrlAddr[4:0] == NXT_DSCRPTR_REG_OFFSET)  ? ctrlSelInt : 1'b0;


assign ctrlAddrDec = ((ctrlAddr[10:4] == 7'h8)  || (ctrlAddr[10:4] == 7'h9))  ? 5'd1  :
                     ((ctrlAddr[10:4] == 7'hA)  || (ctrlAddr[10:4] == 7'hB))  ? 5'd2  :
                     ((ctrlAddr[10:4] == 7'hC)  || (ctrlAddr[10:4] == 7'hD))  ? 5'd3  :
                     ((ctrlAddr[10:4] == 7'hE)  || (ctrlAddr[10:4] == 7'hF))  ? 5'd4  :
                     ((ctrlAddr[10:4] == 7'h10) || (ctrlAddr[10:4] == 7'h11)) ? 5'd5  :
                     ((ctrlAddr[10:4] == 7'h12) || (ctrlAddr[10:4] == 7'h13)) ? 5'd6  :
                     ((ctrlAddr[10:4] == 7'h14) || (ctrlAddr[10:4] == 7'h15)) ? 5'd7  :
                     ((ctrlAddr[10:4] == 7'h16) || (ctrlAddr[10:4] == 7'h17)) ? 5'd8  :
                     ((ctrlAddr[10:4] == 7'h18) || (ctrlAddr[10:4] == 7'h19)) ? 5'd9  :
                     ((ctrlAddr[10:4] == 7'h1A) || (ctrlAddr[10:4] == 7'h1B)) ? 5'd10 :
                     ((ctrlAddr[10:4] == 7'h1C) || (ctrlAddr[10:4] == 7'h1D)) ? 5'd11 :
                     ((ctrlAddr[10:4] == 7'h1E) || (ctrlAddr[10:4] == 7'h1F)) ? 5'd12 :
                     ((ctrlAddr[10:4] == 7'h20) || (ctrlAddr[10:4] == 7'h21)) ? 5'd13 :
                     ((ctrlAddr[10:4] == 7'h22) || (ctrlAddr[10:4] == 7'h23)) ? 5'd14 :
                     ((ctrlAddr[10:4] == 7'h24) || (ctrlAddr[10:4] == 7'h25)) ? 5'd15 :
                     ((ctrlAddr[10:4] == 7'h26) || (ctrlAddr[10:4] == 7'h27)) ? 5'd16 :
                     ((ctrlAddr[10:4] == 7'h28) || (ctrlAddr[10:4] == 7'h29)) ? 5'd17 :
                     ((ctrlAddr[10:4] == 7'h2A) || (ctrlAddr[10:4] == 7'h2B)) ? 5'd18 :
                     ((ctrlAddr[10:4] == 7'h2C) || (ctrlAddr[10:4] == 7'h2D)) ? 5'd19 :
                     ((ctrlAddr[10:4] == 7'h2E) || (ctrlAddr[10:4] == 7'h2F)) ? 5'd20 :
                     ((ctrlAddr[10:4] == 7'h30) || (ctrlAddr[10:4] == 7'h31)) ? 5'd21 :
                     ((ctrlAddr[10:4] == 7'h32) || (ctrlAddr[10:4] == 7'h33)) ? 5'd22 :
                     ((ctrlAddr[10:4] == 7'h34) || (ctrlAddr[10:4] == 7'h35)) ? 5'd23 :
                     ((ctrlAddr[10:4] == 7'h36) || (ctrlAddr[10:4] == 7'h37)) ? 5'd24 :
                     ((ctrlAddr[10:4] == 7'h38) || (ctrlAddr[10:4] == 7'h39)) ? 5'd25 :
                     ((ctrlAddr[10:4] == 7'h3A) || (ctrlAddr[10:4] == 7'h3B)) ? 5'd26 :
                     ((ctrlAddr[10:4] == 7'h3C) || (ctrlAddr[10:4] == 7'h3D)) ? 5'd27 :
                     ((ctrlAddr[10:4] == 7'h3E) || (ctrlAddr[10:4] == 7'h3F)) ? 5'd28 :
                     ((ctrlAddr[10:4] == 7'h40) || (ctrlAddr[10:4] == 7'h41)) ? 5'd29 :
                     ((ctrlAddr[10:4] == 7'h42) || (ctrlAddr[10:4] == 7'h43)) ? 5'd30 :
                     ((ctrlAddr[10:4] == 7'h44) || (ctrlAddr[10:4] == 7'h45)) ? 5'd31 :
                     5'd0;
////////////////////////////////////////////////////////////////////////////////
// wrEn register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                wrEn <= 5'b0;
            end
        else
            begin
                wrEn <= wrEn_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// wrAddr register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                wrAddr <= {NUM_INT_BDS_WIDTH{1'b0}};
            end
        else
            begin
                wrAddr <= wrAddr_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// wrData register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                wrData <= 32'd0;
            end
        else
            begin
                wrData <= wrData_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// rdAddr register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                rdAddr <= 32'd0;
            end
        else
            begin
                rdAddr <= rdAddr_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// rdEn register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                rdEn <= 5'd0;
            end
        else
            begin
                rdEn <= rdEn_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// rmrReq register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                rmrReq <= 1'b0;
            end
        else
            begin
                rmrReq <= rmrReq_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// rmrRdEn register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                rmrRdEn <= 5'b0;
            end
        else
            begin
                rmrRdEn <= rmrRdEn_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// rmrDscrptrNum register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                rmrDscrptrNum <= {NUM_INT_BDS{1'b0}};
            end
        else
            begin
                rmrDscrptrNum <= rmrDscrptrNum_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// rmrValid register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                rmrValid <= 1'b0;
            end
        else
            begin
                rmrValid <= rmrValid_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// rmrData register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                rmrData <= 32'b0;
            end
        else
            begin
                rmrData <= rmrData_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// ctrlRdValid register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                ctrlRdValid <= 1'b0;
            end
        else
            begin
                ctrlRdValid <= ctrlRdValid_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// ctrlRdData register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                ctrlRdData <= 32'b0;
            end
        else
            begin
                ctrlRdData <= ctrlRdData_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// readDscrptrValid register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                readDscrptrValid <= 1'b0;
            end
        else
            begin
                readDscrptrValid <= readDscrptrValid_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// dscrptrData register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                dscrptrData <= {DSCRPTR_DATA_WIDTH{1'b0}};
            end
        else
            begin
                dscrptrData <= dscrptrData_d;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// LSRAM Write Control FSM
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                currWrState <= WR_IDLE;
            end
        else
            begin
                currWrState <= nextWrState;
            end
    end

always @(*)
    begin
        // Default values
        wrEn_d          <= 5'b0;
        wrAddr_d        <= {NUM_INT_BDS_WIDTH{1'b0}};
        wrData_d        <= 32'b0;
        ctrlWrRdy       <= 1'b0;
        rmrReq_d        <= 1'b0;
        rmrRdEn_d       <= 5'b0;
        rmrDscrptrNum_d <= {NUM_INT_BDS{1'b0}};
        case (currWrState)
            WR_IDLE:
                begin
                    if ((enCtrl0 | enCtrl1 | enCtrl2 | enCtrl3 | enCtrl4) && ctrlWr)
                        begin
                            if (ctrlWrStrbs != 4'hF)
                                begin
                                    // Need to perform a read modify write
                                    rmrReq_d        <= 1'b1;
                                    rmrRdEn_d       <= {enCtrl4, enCtrl3, enCtrl2, enCtrl1, enCtrl0};
                                    rmrDscrptrNum_d <= ctrlAddrDec;
                                    nextWrState     <= WR_WAIT_RMR;
                                end
                            else
                                begin
                                    wrEn_d      <= {enCtrl4, enCtrl3, enCtrl2, enCtrl1, enCtrl0};
                                    wrAddr_d    <= ctrlAddrDec;
                                    wrData_d    <= ctrlWrData;
                                    ctrlWrRdy   <= 1'b1;
                                    nextWrState <= WR_IDLE;
                                end
                        end
                    else
                        begin
                            nextWrState <= WR_IDLE;
                        end
                end
            WR_WAIT_RMR:
                begin
                    if (rmrValid)
                        begin
                            wrEn_d          <= {enCtrl4, enCtrl3, enCtrl2, enCtrl1, enCtrl0};
                            wrAddr_d        <= ctrlAddrDec;
                            wrData_d[31:24] <= (ctrlWrStrbs[3]) ? ctrlWrData[31:24] : rmrData[31:24];
                            wrData_d[23:16] <= (ctrlWrStrbs[2]) ? ctrlWrData[23:16] : rmrData[23:16];
                            wrData_d[15:8]  <= (ctrlWrStrbs[1]) ? ctrlWrData[15:8]  : rmrData[15:8];
                            wrData_d[7:0]   <= (ctrlWrStrbs[0]) ? ctrlWrData[7:0]   : rmrData[7:0];
                            ctrlWrRdy       <= 1'b1;
                            nextWrState     <= WR_IDLE;
                        end
                    else
                        begin
                            rmrReq_d        <= 1'b1;
                            rmrRdEn_d       <= {enCtrl4, enCtrl3, enCtrl2, enCtrl1, enCtrl0};
                            rmrDscrptrNum_d <= ctrlAddrDec;
                            nextWrState     <= WR_WAIT_RMR;
                        end
                end
            default:
                begin
                    nextWrState <= WR_IDLE;
                end
        endcase
    end

////////////////////////////////////////////////////////////////////////////////
// dscrptrValid register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                dscrptrValidReg <= {NUM_INT_BDS{1'b0}};
            end
        else
            begin
				if(error_flag_db_bd_out)
					begin
						dscrptrValidReg[intDscrptrNum_BufferDscrptrs] <= 1'b0;
					end			
                else if ((enCtrl0 & ctrlWrStrbs[1] & ctrlWrData[15] & ctrlWrRdy) )
                    begin
                        dscrptrValidReg[ctrlAddrDec] <= 1'b1;
                    end
                else if (ctrlWrRdy && (((enCtrl4|enCtrl3|enCtrl2|enCtrl1) & ~enCtrl0) || (enCtrl0 & (~ctrlWrStrbs[1] | (ctrlWrStrbs[1] & ~ctrlWrData[15])))))
                    begin
                        dscrptrValidReg[ctrlAddrDec] <= 1'b0;
                    end

                
            end
    end
assign dscrptrValid = dscrptrValidReg[intDscrptrNum_BufferDscrptrs];

////////////////////////////////////////////////////////////////////////////////
// srcDataValid register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        for (intBD_idx = 0; intBD_idx < NUM_INT_BDS; intBD_idx = intBD_idx + 1)
            begin
                if (!resetn)
                    begin
                        srcDataValidReg[intBD_idx] <= 1'b0;
                    end
                else
                    begin
                        if (enCtrl0 & ctrlWrStrbs[1] & ctrlWrRdy & (ctrlAddrDec == intBD_idx))
                            begin
                                srcDataValidReg[intBD_idx] <= ctrlWrData[13];
                            end
                        else
                            begin
                                srcDataValidReg[intBD_idx] <= srcDataValidReg[intBD_idx] & ~clrDataValidDscrptr[intBD_idx];
                            end
                    end
            end
    end

////////////////////////////////////////////////////////////////////////////////
// dstDataReadyReg register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        for (intBD_idx = 0; intBD_idx < NUM_INT_BDS; intBD_idx = intBD_idx + 1)
            begin
                if (!resetn)
                    begin
                        dstDataReadyReg[intBD_idx] <= 1'b0;
                    end
                else
                    begin
                        if (enCtrl0 & ctrlWrStrbs[1] & ctrlWrRdy & (ctrlAddrDec == intBD_idx))
                            begin
                                dstDataReadyReg[intBD_idx] <= ctrlWrData[14];
                            end
                        else
                            begin
                                dstDataReadyReg[intBD_idx] <= dstDataReadyReg[intBD_idx] & ~clrDataValidDscrptr[intBD_idx];
                            end
                    end
            end
    end
assign dataValidDscrptr = srcDataValidReg & dstDataReadyReg;

////////////////////////////////////////////////////////////////////////////////
// chain register
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                chainReg <= {NUM_INT_BDS{1'b0}};
            end
        else
            begin
                if (enCtrl0 & ctrlWrStrbs[1] & ctrlWrRdy)
                    begin
                        chainReg[ctrlAddrDec] <= ctrlWrData[10];
                    end
                else
                    begin
                        chainReg <= chainReg;
                    end
                
            end
    end
assign chain = chainReg;

////////////////////////////////////////////////////////////////////////////////
// LSRAM Read control FSM
////////////////////////////////////////////////////////////////////////////////
always @(posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                currRdState <= RD_IDLE;
            end
        else
            begin
                currRdState <= nextRdState;
            end
    end

always @(*)
    begin
        // default values
        rdEn_d              <= {5{1'b0}};
        rdAddr_d            <= {NUM_INT_BDS_WIDTH{1'b0}};
        rmrValid_d          <= 1'b0;
        rmrData_d           <= 32'b0;
        ctrlRdValid_d       <= 1'b0;
        ctrlRdData_d        <= 32'b0;
        readDscrptrValid_d  <= 1'b0;
        dscrptrData_d       <= {DSCRPTR_DATA_WIDTH{1'b0}};
        case(currRdState)
            RD_IDLE:
                begin
                    if (rmrReq)
                        begin
                            rdEn_d      <= rmrRdEn;
                            rdAddr_d    <= rmrDscrptrNum;
                            nextRdState <= RD_RMR_WAIT_1;
                        end
                    else if ((enCtrl4 | enCtrl3 | enCtrl2 | enCtrl1 | enCtrl0) && ~ctrlWr)
                        begin
                            rdEn_d      <= {enCtrl4, enCtrl3, enCtrl2, enCtrl1, enCtrl0};
                            rdAddr_d    <= ctrlAddrDec;
                            nextRdState <= RD_CTRL_WAIT_1;
                        end
                    else if (readDscrptr)
                        begin
                            rdEn_d      <= 5'b11111;
                            rdAddr_d    <= intDscrptrNum_BufferDscrptrs;
                            nextRdState <= RD_FETCH_WAIT_1;
                        end
                    else
                        begin
                            nextRdState <= RD_IDLE;
                        end
                end
            RD_RMR_WAIT_1:
                begin
                    if (readDscrptr)
                        begin
                            rdEn_d      <= 5'b11111;
                            rdAddr_d    <= intDscrptrNum_BufferDscrptrs;
                            nextRdState <= RD_RMR_WAIT_2_FETCH_WAIT_1;
                        end
                    else
                        begin
                            nextRdState <= RD_RMR_WAIT_2;
                        end
                end
            RD_RMR_WAIT_2:
                begin
                    if (readDscrptr)
                        begin
                            rdEn_d      <= 5'b11111;
                            rdAddr_d    <= intDscrptrNum_BufferDscrptrs;
                            nextRdState <= RD_RMR_DONE_FETCH_WAIT_1;
                        end
                    else
                        begin
                            nextRdState <= RD_RMR_DONE;
                        end
                end
            RD_RMR_WAIT_2_FETCH_WAIT_1:
                begin
                    nextRdState <= RD_RMR_DONE_FETCH_WAIT_2;
                end
            RD_RMR_DONE:
                begin
                    rmrValid_d <= 1'b1;
                    if (rmrRdEn[0])
                        begin
                            rmrData_d <= rdData0;
                        end
                    else if (rmrRdEn[1])
                        begin
                            rmrData_d <= rdData1;
                        end
                    else if (rmrRdEn[2])
                        begin
                            rmrData_d <= rdData2;
                        end
                    else if (rmrRdEn[3])
                        begin
                            rmrData_d <= rdData3;
                        end
                    else if (rmrRdEn[4])
                        begin
                            rmrData_d <= rdData4;
                        end
                    else
                        begin
                            rmrData_d <= 32'b0;
                        end
                    if (readDscrptr)
                        begin
                            rdEn_d      <= 5'b11111;
                            rdAddr_d    <= intDscrptrNum_BufferDscrptrs;
                            nextRdState <= RD_FETCH_WAIT_1;
                        end
                    else
                        begin
                            nextRdState <= RD_IDLE;
                        end
                end
            RD_RMR_DONE_FETCH_WAIT_1:
                begin
                    rmrValid_d <= 1'b1;
                    if (rmrRdEn[0])
                        begin
                            rmrData_d <= rdData0;
                        end
                    else if (rmrRdEn[1])
                        begin
                            rmrData_d <= rdData1;
                        end
                    else if (rmrRdEn[2])
                        begin
                            rmrData_d <= rdData2;
                        end
                    else if (rmrRdEn[3])
                        begin
                            rmrData_d <= rdData3;
                        end
                    else if (rmrRdEn[4])
                        begin
                            rmrData_d <= rdData4;
                        end
                    else
                        begin
                            rmrData_d <= 32'b0;
                        end
                    nextRdState <= RD_FETCH_WAIT_2;
                end
            RD_RMR_DONE_FETCH_WAIT_2:
                begin
                    rmrValid_d <= 1'b1;
                    if (rmrRdEn[0])
                        begin
                            rmrData_d <= rdData0;
                        end
                    else if (rmrRdEn[1])
                        begin
                            rmrData_d <= rdData1;
                        end
                    else if (rmrRdEn[2])
                        begin
                            rmrData_d <= rdData2;
                        end
                    else if (rmrRdEn[3])
                        begin
                            rmrData_d <= rdData3;
                        end
                    else if (rmrRdEn[4])
                        begin
                            rmrData_d <= rdData4;
                        end
                    else
                        begin
                            rmrData_d <= 32'b0;
                        end
                    nextRdState <= RD_FETCH_DONE;
                end
            RD_FETCH_WAIT_1:
                begin
                    if (rmrReq)
                        begin
                            rdEn_d      <= rmrRdEn;
                            rdAddr_d    <= rmrDscrptrNum;
                            nextRdState <= RD_FETCH_WAIT_2_RMR_WAIT_1;
                        end
                    else if ((enCtrl4 | enCtrl3 | enCtrl2 | enCtrl1 | enCtrl0) && ~ctrlWr)
                        begin
                            rdEn_d      <= {enCtrl4, enCtrl3, enCtrl2, enCtrl1, enCtrl0};
                            rdAddr_d    <= ctrlAddrDec;
                            nextRdState <= RD_FETCH_WAIT_2_CTRL_WAIT_1;
                        end
                    else
                        begin
                            nextRdState <= RD_FETCH_WAIT_2;
                        end
                end
            RD_FETCH_WAIT_2:
                begin
                    if (rmrReq)
                        begin
                            rdEn_d      <= rmrRdEn;
                            rdAddr_d    <= rmrDscrptrNum;
                            nextRdState <= RD_FETCH_DONE_RMR_WAIT_1;
                        end
                    else if ((enCtrl4 | enCtrl3 | enCtrl2 | enCtrl1 | enCtrl0) && ~ctrlWr)
                        begin
                            rdEn_d      <= {enCtrl4, enCtrl3, enCtrl2, enCtrl1, enCtrl0};
                            rdAddr_d    <= ctrlAddrDec;
                            nextRdState <= RD_FETCH_DONE_CTRL_WAIT_1;
                        end
                    else
                        begin
                            nextRdState <= RD_FETCH_DONE;
                        end
                end
            RD_FETCH_WAIT_2_RMR_WAIT_1:
                begin
                    nextRdState <= RD_FETCH_DONE_RMR_WAIT_2;
                end
            RD_FETCH_WAIT_2_CTRL_WAIT_1:
                begin
                    nextRdState <= RD_FETCH_DONE_CTRL_WAIT_2;
                end
            RD_FETCH_DONE:
                begin
                    readDscrptrValid_d <= 1'b1;
                    if (DATA_REALIGNMENT == 1)
                        begin
                            dscrptrData_d <= {rdData4, rdData3, rdData2, rdData1[23:0], dataValidDscrptr[intDscrptrNum_BufferDscrptrs], rdData0[12:11], chainReg[intDscrptrNum_BufferDscrptrs], rdData0[9:0]};
                        end
                    else
                        begin
                            dscrptrData_d <= {rdData4, rdData3, rdData2, rdData1[23:0], dataValidDscrptr[intDscrptrNum_BufferDscrptrs], rdData0[12:11], chainReg[intDscrptrNum_BufferDscrptrs], {6{1'b0}}, rdData0[3:0]};
                        end
                    if (rmrReq)
                        begin
                            rdEn_d      <= rmrRdEn;
                            rdAddr_d    <= rmrDscrptrNum;
                            nextRdState <= RD_RMR_WAIT_1;
                        end
                    else if ((enCtrl4 | enCtrl3 | enCtrl2 | enCtrl1 | enCtrl0) && ~ctrlWr)
                        begin
                            rdEn_d      <= {enCtrl4, enCtrl3, enCtrl2, enCtrl1, enCtrl0};
                            rdAddr_d    <= ctrlAddrDec;
                            nextRdState <= RD_CTRL_WAIT_1;
                        end
                    else
                        begin
                            nextRdState <= RD_IDLE;
                        end
                end
            RD_FETCH_DONE_RMR_WAIT_1:
                begin
                    readDscrptrValid_d <= 1'b1;
                    nextRdState        <= RD_RMR_WAIT_2;
                    if (DATA_REALIGNMENT == 1)
                        begin
                            dscrptrData_d <= {rdData4, rdData3, rdData2, rdData1[23:0], dataValidDscrptr[intDscrptrNum_BufferDscrptrs], rdData0[12:11], chainReg[intDscrptrNum_BufferDscrptrs], rdData0[9:0]};
                        end
                    else
                        begin
                            dscrptrData_d <= {rdData4, rdData3, rdData2, rdData1[23:0], dataValidDscrptr[intDscrptrNum_BufferDscrptrs], rdData0[12:11], chainReg[intDscrptrNum_BufferDscrptrs], {6{1'b0}}, rdData0[3:0]};
                        end
                end
            RD_FETCH_DONE_RMR_WAIT_2:
                begin
                    readDscrptrValid_d <= 1'b1;
                    nextRdState        <= RD_RMR_DONE;
                    if (DATA_REALIGNMENT == 1)
                        begin
                            dscrptrData_d <= {rdData4, rdData3, rdData2, rdData1[23:0], dataValidDscrptr[intDscrptrNum_BufferDscrptrs], rdData0[12:11], chainReg[intDscrptrNum_BufferDscrptrs], rdData0[9:0]};
                        end
                    else
                        begin
                            dscrptrData_d <= {rdData4, rdData3, rdData2, rdData1[23:0], dataValidDscrptr[intDscrptrNum_BufferDscrptrs], rdData0[12:11], chainReg[intDscrptrNum_BufferDscrptrs], {6{1'b0}}, rdData0[3:0]};
                        end
                end
            RD_FETCH_DONE_CTRL_WAIT_1:
                begin
                    readDscrptrValid_d <= 1'b1;
                    nextRdState        <= RD_CTRL_WAIT_2;
                    if (DATA_REALIGNMENT == 1)
                        begin
                            dscrptrData_d <= {rdData4, rdData3, rdData2, rdData1[23:0], dataValidDscrptr[intDscrptrNum_BufferDscrptrs], rdData0[12:11], chainReg[intDscrptrNum_BufferDscrptrs], rdData0[9:0]};
                        end
                    else
                        begin
                            dscrptrData_d <= {rdData4, rdData3, rdData2, rdData1[23:0], dataValidDscrptr[intDscrptrNum_BufferDscrptrs], rdData0[12:11], chainReg[intDscrptrNum_BufferDscrptrs], {6{1'b0}}, rdData0[3:0]};
                        end
                end
            RD_FETCH_DONE_CTRL_WAIT_2:
                begin
                    readDscrptrValid_d <= 1'b1;
                    nextRdState        <= RD_CTRL_DONE;
                    if (DATA_REALIGNMENT == 1)
                        begin
                            dscrptrData_d <= {rdData4, rdData3, rdData2, rdData1[23:0], dataValidDscrptr[intDscrptrNum_BufferDscrptrs], rdData0[12:11], chainReg[intDscrptrNum_BufferDscrptrs], rdData0[9:0]};
                        end
                    else
                        begin
                            dscrptrData_d <= {rdData4, rdData3, rdData2, rdData1[23:0], dataValidDscrptr[intDscrptrNum_BufferDscrptrs], rdData0[12:11], chainReg[intDscrptrNum_BufferDscrptrs], {6{1'b0}}, rdData0[3:0]};
                        end
                end
            RD_CTRL_WAIT_1:
                begin
                    if (readDscrptr)
                        begin
                            rdEn_d      <= 5'b11111;
                            rdAddr_d    <= intDscrptrNum_BufferDscrptrs;
                            nextRdState <= RD_CTRL_WAIT_2_FETCH_WAIT_1;
                        end
                    else
                        begin
                            nextRdState <= RD_CTRL_WAIT_2;
                        end
                end
            RD_CTRL_WAIT_2:
                begin
                    if (readDscrptr)
                        begin
                            rdEn_d      <= 5'b11111;
                            rdAddr_d    <= intDscrptrNum_BufferDscrptrs;
                            nextRdState <= RD_CTRL_DONE_FETCH_WAIT_1;
                        end
                    else
                        begin
                            nextRdState <= RD_CTRL_DONE;
                        end
                end
            RD_CTRL_WAIT_2_FETCH_WAIT_1:
                begin
                    nextRdState <= RD_CTRL_DONE_FETCH_WAIT_2;
                end
            RD_CTRL_DONE:
                begin
                    ctrlRdValid_d <= 1'b1;
                    if (enCtrl0)
                        begin
                            if (DATA_REALIGNMENT == 1)
                                begin
                                    ctrlRdData_d <= {rdData0[31:16], dscrptrValidReg[ctrlAddrDec], dstDataReadyReg[ctrlAddrDec], srcDataValidReg[ctrlAddrDec], rdData0[12:11], chainReg[ctrlAddrDec], rdData0[9:0]};
                                end
                            else
                                begin
                                    ctrlRdData_d <= {rdData0[31:16], dscrptrValidReg[ctrlAddrDec], dstDataReadyReg[ctrlAddrDec], srcDataValidReg[ctrlAddrDec], rdData0[12:11], chainReg[ctrlAddrDec], {6{1'b0}}, rdData0[3:0]};
                                end
                        end
                    else if (enCtrl1)
                        begin
                            ctrlRdData_d <= rdData1;
                        end
                    else if (enCtrl2)
                        begin
                            ctrlRdData_d <= rdData2;
                        end
                    else if (enCtrl3)
                        begin
                            ctrlRdData_d <= rdData3;
                        end
                    else if (enCtrl4)
                        begin
                            ctrlRdData_d <= rdData4;
                        end
                    else
                        begin
                            ctrlRdData_d <= 32'b0;
                        end
                    if (readDscrptr)
                        begin
                            rdEn_d      <= 5'b11111;
                            rdAddr_d    <= intDscrptrNum_BufferDscrptrs;
                            nextRdState <= RD_FETCH_WAIT_1;
                        end
                    else
                        begin
                            nextRdState <= RD_IDLE;
                        end
                end
            RD_CTRL_DONE_FETCH_WAIT_1:
                begin
                    ctrlRdValid_d <= 1'b1;
                    if (enCtrl0)
                        begin
                            if (DATA_REALIGNMENT == 1)
                                begin
                                    ctrlRdData_d <= {rdData0[31:16], dscrptrValidReg[ctrlAddrDec], dstDataReadyReg[ctrlAddrDec], srcDataValidReg[ctrlAddrDec], rdData0[12:11], chainReg[ctrlAddrDec], rdData0[9:0]};
                                end
                            else
                                begin
                                    ctrlRdData_d <= {rdData0[31:16], dscrptrValidReg[ctrlAddrDec], dstDataReadyReg[ctrlAddrDec], srcDataValidReg[ctrlAddrDec], rdData0[12:11], chainReg[ctrlAddrDec], {6{1'b0}}, rdData0[3:0]};
                                end
                        end
                    else if (enCtrl1)
                        begin
                            ctrlRdData_d <= rdData1;
                        end
                    else if (enCtrl2)
                        begin
                            ctrlRdData_d <= rdData2;
                        end
                    else if (enCtrl3)
                        begin
                            ctrlRdData_d <= rdData3;
                        end
                    else if (enCtrl4)
                        begin
                            ctrlRdData_d <= rdData4;
                        end
                    else
                        begin
                            ctrlRdData_d <= 32'b0;
                        end
                    nextRdState <= RD_FETCH_WAIT_2;
                end
            RD_CTRL_DONE_FETCH_WAIT_2:
                begin
                    ctrlRdValid_d <= 1'b1;
                    if (enCtrl0)
                        begin
                            if (DATA_REALIGNMENT == 1)
                                begin
                                    ctrlRdData_d <= {rdData0[31:16], dscrptrValidReg[ctrlAddrDec], dstDataReadyReg[ctrlAddrDec], srcDataValidReg[ctrlAddrDec], rdData0[12:11], chainReg[ctrlAddrDec], rdData0[9:0]};
                                end
                            else
                                begin
                                    ctrlRdData_d <= {rdData0[31:16], dscrptrValidReg[ctrlAddrDec], dstDataReadyReg[ctrlAddrDec], srcDataValidReg[ctrlAddrDec], rdData0[12:11], chainReg[ctrlAddrDec], {6{1'b0}}, rdData0[3:0]};
                                end
                        end
                    else if (enCtrl1)
                        begin
                            ctrlRdData_d <= rdData1;
                        end
                    else if (enCtrl2)
                        begin
                            ctrlRdData_d <= rdData2;
                        end
                    else if (enCtrl3)
                        begin
                            ctrlRdData_d <= rdData3;
                        end
                    else if (enCtrl4)
                        begin
                            ctrlRdData_d <= rdData4;
                        end
                    else
                        begin
                            ctrlRdData_d <= 32'b0;
                        end
                    nextRdState <= RD_FETCH_DONE;
                end
            default:
                begin
                    nextRdState <= RD_IDLE;
                end
        endcase
    end
    
////////////////////////////////////////////////////////////////////////////////
// Config registers LSRAM instantiation
////////////////////////////////////////////////////////////////////////////////
CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_RAM_1K20_wrapper #(
    .NUM_INT_BDS_WIDTH      (NUM_INT_BDS_WIDTH),
    .RD_PIPELINE            (1'b1),
	.ECC					(ECC)
) CONFIG_RAM (
    // Inputs
    .clock                  (clock),
    .resetn                 (resetn),
    .wrEn                   (wrEn[0]),
    .wrAddr                 (wrAddr),
    .wrData                 (wrData),
    .rdEn                   (rdEn[0]),
    .rdAddr                 (rdAddr),
    
    // Outputs
    .rdData                 (rdData0),
	.error_flag_sb_bd		(error_flag_sb_bd[0]),
	.error_flag_db_bd		(error_flag_db_bd[0])
);

////////////////////////////////////////////////////////////////////////////////
// Byte Count registers LSRAM instantiation
////////////////////////////////////////////////////////////////////////////////
CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_RAM_1K20_wrapper #(
    .NUM_INT_BDS_WIDTH      (NUM_INT_BDS_WIDTH),
    .RD_PIPELINE            (1'b1),
	.ECC					(ECC)
) BYTE_CNT_RAM (
    // Inputs
    .clock                  (clock),
    .resetn                 (resetn),
    .wrEn                   (wrEn[1]),
    .wrAddr                 (wrAddr),
    .wrData                 (wrData),
    .rdEn                   (rdEn[1]),
    .rdAddr                 (rdAddr),
    
    // Outputs
    .rdData                 (rdData1),
	.error_flag_sb_bd		(error_flag_sb_bd[1]),
	.error_flag_db_bd		(error_flag_db_bd[1])
);

////////////////////////////////////////////////////////////////////////////////
// Source address registers LSRAM instantiation
////////////////////////////////////////////////////////////////////////////////
CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_RAM_1K20_wrapper #(
    .NUM_INT_BDS_WIDTH      (NUM_INT_BDS_WIDTH),
    .RD_PIPELINE            (1'b1),
	.ECC					(ECC)

) SRC_ADDR_RAM (
    // Inputs
    .clock                  (clock),
    .resetn                 (resetn),
    .wrEn                   (wrEn[2]),
    .wrAddr                 (wrAddr),
    .wrData                 (wrData),
    .rdEn                   (rdEn[2]),
    .rdAddr                 (rdAddr),
    
    // Outputs
    .rdData                 (rdData2),
	.error_flag_sb_bd		(error_flag_sb_bd[2]),
	.error_flag_db_bd		(error_flag_db_bd[2])
);

////////////////////////////////////////////////////////////////////////////////
// Destination address registers LSRAM instantiation
////////////////////////////////////////////////////////////////////////////////
CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_RAM_1K20_wrapper #(
    .NUM_INT_BDS_WIDTH      (NUM_INT_BDS_WIDTH),
    .RD_PIPELINE            (1'b1),
	.ECC					(ECC)

) DEST_ADDR_RAM (
    // Inputs
    .clock                  (clock),
    .resetn                 (resetn),
    .wrEn                   (wrEn[3]),
    .wrAddr                 (wrAddr),
    .wrData                 (wrData),
    .rdEn                   (rdEn[3]),
    .rdAddr                 (rdAddr),
    
    // Outputs
    .rdData                 (rdData3),
	.error_flag_sb_bd		(error_flag_sb_bd[3]),
	.error_flag_db_bd		(error_flag_db_bd[3])
);

////////////////////////////////////////////////////////////////////////////////
// Next descriptor number/address registers LSRAM instantiation
////////////////////////////////////////////////////////////////////////////////
CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_RAM_1K20_wrapper #(
    .NUM_INT_BDS_WIDTH      (NUM_INT_BDS_WIDTH),
    .RD_PIPELINE            (1'b1),
	.ECC					(ECC)
) NEXT_DSCRPTR_RAM (
    // Inputs
    .clock                  (clock),
    .resetn                 (resetn),
    .wrEn                   (wrEn[4]),
    .wrAddr                 (wrAddr),
    .wrData                 (wrData),
    .rdEn                   (rdEn[4]),
    .rdAddr                 (rdAddr),
    
    // Outputs
    .rdData                 (rdData4),
	.error_flag_sb_bd		(error_flag_sb_bd[4]),
	.error_flag_db_bd		(error_flag_db_bd[4])
);

endmodule // CoreAXI4DMAController_bufferDescriptors