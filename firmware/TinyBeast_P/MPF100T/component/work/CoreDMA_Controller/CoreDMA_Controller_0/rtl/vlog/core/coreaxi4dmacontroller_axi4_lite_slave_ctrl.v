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
module CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_AXI4LiteSlaveCtrl (
    clock,
    resetn,
    
    // AXI4-Lite Master inputs
    AWVALID,
    WVALID,
    BREADY,
    ARVALID,
    RREADY,
    AWADDR,
    WSTRB,
    WDATA,
    ARADDR,
    
    // CtrlIf inputs
    ctrlWrRdy,
    ctrlRdData,
    ctrlRdValid,
    
    // AXI4-Lite Master outputs
    BRESP,
    RDATA,
    AWREADY,
    WREADY,
    BVALID,
    ARREADY,
    RVALID,
    RRESP,
    
    // CtrlIf outputs
    ctrlSel,
    ctrlWr,
    ctrlAddr,
    ctrlWrData,
    ctrlWrStrbs
);

////////////////////////////////////////////////////////////////////////////////
// Port directions
////////////////////////////////////////////////////////////////////////////////
input               clock;
input               resetn;
    
// AXI4-Lite Master inputs
input               AWVALID;
input               WVALID;
input               BREADY;
input               ARVALID;
input               RREADY;
input   [10:0]      AWADDR;
input   [3:0]       WSTRB;
input   [31:0]      WDATA;
input   [10:0]      ARADDR;

// CtrlIf inputs
input               ctrlWrRdy;
input   [31:0]      ctrlRdData;
input               ctrlRdValid;

// AXI4-Lite Master outputs
output  [1:0]       BRESP;
output  [31:0]      RDATA;
output              AWREADY;
output              WREADY;
output              BVALID;
output              ARREADY;
output              RVALID;
output  [1:0]       RRESP;

// CtrlIf outputs
output              ctrlSel;
output              ctrlWr;
output  [10:0]      ctrlAddr;
output  [31:0]      ctrlWrData;
output  [3:0]       ctrlWrStrbs;

////////////////////////////////////////////////////////////////////////////////
// Internal signals
////////////////////////////////////////////////////////////////////////////////
reg     [8:0]       currState;
reg     [8:0]       nextState;
reg     [1:0]       BRESPReg;
reg     [1:0]       BRESPReg_d;
reg     [31:0]      RDATAReg;
reg     [31:0]      RDATAReg_d;
reg                 AWREADYReg;
reg                 AWREADYReg_d;
reg                 WREADYReg;
reg                 WREADYReg_d;
reg                 BVALIDReg;
reg                 BVALIDReg_d;
reg                 ARREADYReg;
reg                 ARREADYReg_d;
reg                 RVALIDReg;
reg                 RVALIDReg_d;
reg     [1:0]       RRESPReg;
reg     [1:0]       RRESPReg_d;
reg                 ctrlSelReg;
reg                 ctrlSelReg_d;
reg                 ctrlWrReg;
reg                 ctrlWrReg_d;
reg     [10:0]      ctrlAddrReg;
reg     [10:0]      ctrlAddrReg_d;
reg     [31:0]      ctrlWrDataReg;
reg     [31:0]      ctrlWrDataReg_d;
reg     [3:0]       ctrlWrStrbsReg;
reg     [3:0]       ctrlWrStrbsReg_d;


reg					invalid_wraddr;//Addressed SAR 111640, added SLVERR Response to control master for invalid addresses
reg					invalid_rdaddr;//Addressed SAR 111640, added SLVERR Response to control master for invalid addresses

////////////////////////////////////////////////////////////////////////////////
// Constants
////////////////////////////////////////////////////////////////////////////////
localparam [8:0] IDLE                = 9'b000000001;
localparam [8:0] AXI_WR_ADDR         = 9'b000000010;
localparam [8:0] AXI_WAIT_VALID      = 9'b000000100;
localparam [8:0] AXI_WAIT_RDY        = 9'b000001000;
localparam [8:0] AXI_WR_DATA         = 9'b000010000;
localparam [8:0] AXI_WR_RESP         = 9'b000100000;
localparam [8:0] AXI_RD_ADDR         = 9'b001000000;
localparam [8:0] AXI_WAIT_RD         = 9'b010000000;
localparam [8:0] AXI_WAIT_RD_RREADY  = 9'b100000000;

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
// Combinatorial next state and output logic
////////////////////////////////////////////////////////////////////////////////
always @ (*)
    begin
        // Default assignments
        AWREADYReg_d     <= 1'b0;
        BRESPReg_d       <= 2'b0;
        RDATAReg_d       <= RDATAReg;
        AWREADYReg_d     <= 1'b0;
        WREADYReg_d      <= 1'b0;
        BVALIDReg_d      <= 1'b0;
        ARREADYReg_d     <= 1'b0;
        RVALIDReg_d      <= 1'b0;
        RRESPReg_d       <= 2'b0;
        ctrlSelReg_d     <= ctrlSelReg;
        ctrlWrReg_d      <= ctrlWrReg;
        ctrlAddrReg_d    <= ctrlAddrReg;
        ctrlWrDataReg_d  <= ctrlWrDataReg;
        ctrlWrStrbsReg_d <= ctrlWrStrbsReg;
        case (currState)
            IDLE:
                begin
                    if (AWVALID)
                        begin
                            AWREADYReg_d <= 1'b1;
                            nextState    <= AXI_WR_ADDR;
                        end
                    else if (ARVALID)
                        begin
                            ARREADYReg_d <= 1'b1;
                            nextState    <= AXI_RD_ADDR;
                        end
                    else
                        begin
                            nextState    <= IDLE;
                        end
                end
            AXI_WR_ADDR:
                begin
                    if (AWVALID & AWREADY)
                        begin
                            // Align address to 32-bit boundary
                            ctrlAddrReg_d <= {AWADDR[10:2], {2{1'b0}}};
                            if (WVALID)
                                begin
                                    ctrlSelReg_d     <= 1'b1;
                                    ctrlWrReg_d      <= 1'b1;
                                    ctrlWrDataReg_d  <= WDATA;
                                    ctrlWrStrbsReg_d <= WSTRB;
                                    nextState        <= AXI_WAIT_RDY;
                                end
                            else
                                begin
                                    nextState <= AXI_WAIT_VALID;
                                end
                        end
                    else
                        begin
                            AWREADYReg_d <= 1'b1;
                            nextState    <= AXI_WR_ADDR;
                        end
                end
            AXI_WAIT_VALID:
                begin
                    if (WVALID)
                        begin
                            ctrlSelReg_d     <= 1'b1;
                            ctrlWrReg_d      <= 1'b1;
                            ctrlWrDataReg_d  <= WDATA;
                            ctrlWrStrbsReg_d <= WSTRB;
                            nextState        <= AXI_WAIT_RDY;
                        end
                    else
                        begin
                            nextState <= AXI_WAIT_VALID;
                        end
                end
            AXI_WAIT_RDY:
                begin
							
                    if (ctrlWrRdy | invalid_wraddr)
                        begin
                            ctrlAddrReg_d    <= 11'b0;
                            ctrlSelReg_d     <= 1'b0;
                            ctrlWrReg_d      <= 1'b0;
                            ctrlWrDataReg_d  <= 32'b0;
                            ctrlWrStrbsReg_d <= 4'b0;
                            WREADYReg_d      <= 1'b1;
                            nextState        <= AXI_WR_DATA;
                        end
                    else
                        begin
                         nextState <= AXI_WAIT_RDY;
                        end
                end
            AXI_WR_DATA:
                begin
                    if (WREADY & WVALID)
                        begin
                            // Start driving out an  write response
                            BVALIDReg_d      <= 1'b1;
                            BRESPReg_d       <= (invalid_wraddr) ? 2'b10 : 2'b00;
                            nextState        <= AXI_WR_RESP;
                        end
                    else
                        begin
                            WREADYReg_d <= 1'b1;
                            nextState   <= AXI_WR_DATA;
                        end
                end
            AXI_WR_RESP:
                begin
                    if (BREADY & BVALID)
                        begin
                            nextState     <= IDLE;
                        end
                    else
                        begin
                            // Continue driving out write response
                            BVALIDReg_d <= 1'b1;
                            BRESPReg_d  <= (invalid_wraddr) ? 2'b10 : 2'b00;
                            nextState   <= AXI_WR_RESP;
                        end
                end
            AXI_RD_ADDR:
                begin
                    if (ARVALID & ARREADY)
                        begin
                            // Align address to 32-bit boundary
                            ctrlAddrReg_d <= {ARADDR[10:2], {2{1'b0}}};
                            ctrlSelReg_d  <= 1'b1;
                            ctrlWrReg_d   <= 1'b0; // Read
                            nextState     <= AXI_WAIT_RD;
                        end
                    else
                        begin
                            ARREADYReg_d <= 1'b1;
                            nextState    <= AXI_RD_ADDR;
                        end
                end
            AXI_WAIT_RD:
                begin
                    if (ctrlRdValid | invalid_rdaddr)
                        begin
                            ctrlAddrReg_d <= 11'b0;
                            RRESPReg_d    <= (invalid_rdaddr) ? 2'b10 : 2'b00;
                            RVALIDReg_d   <= 1'b1;
                            RDATAReg_d    <= ctrlRdData;
                            nextState     <= AXI_WAIT_RD_RREADY;
                        end
                    else
                        begin
                            ctrlSelReg_d  <= 1'b1;
                            ctrlWrReg_d   <= 1'b0; // Read
                            nextState     <= AXI_WAIT_RD;
                        end
                end
            AXI_WAIT_RD_RREADY:
                begin
                    if (RVALID & RREADY)
                        begin
                            RDATAReg_d    <= 32'b0;
                            nextState     <= IDLE;
                        end
                    else
                        begin
                            RRESPReg_d    <= (invalid_rdaddr) ? 2'b10 : 2'b00;
                            RVALIDReg_d   <= 1'b1;
                            nextState     <= AXI_WAIT_RD_RREADY;
                        end
                end
            default:
                begin
                    nextState <= IDLE;
                end
        endcase
    end

////////////////////////////////////////////////////////////////////////////////
// AWREADY output register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                AWREADYReg <= 1'b0;
            end
        else
            begin
                AWREADYReg <= AWREADYReg_d;
            end
    end
assign AWREADY = AWREADYReg;

////////////////////////////////////////////////////////////////////////////////
// ARREADY output register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                ARREADYReg <= 1'b0;
            end
        else
            begin
                ARREADYReg <= ARREADYReg_d;
            end
    end
assign ARREADY = ARREADYReg;

////////////////////////////////////////////////////////////////////////////////
// RDATA output register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                RDATAReg <= 32'b0;
            end
        else
            begin
                RDATAReg <= RDATAReg_d;
            end
    end
assign RDATA = RDATAReg;

////////////////////////////////////////////////////////////////////////////////
// Invalid write address register- SAR 111640
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
				invalid_wraddr <= 1'b0;
			end
		
		else
			begin
				invalid_wraddr <= (((ctrlAddrReg[4] & (| ctrlAddrReg[10:6]) & (| ctrlAddrReg[3:0])) | 
				                    (ctrlAddrReg == 11'd8 | ctrlAddrReg == 11'd12) | 
								    (ctrlAddrReg[7:4] == 5 & !(| ctrlAddrReg[10:8])) |
								    (ctrlAddrReg > 11'h46C)) &
								    (ctrlWrReg));
			end
	end
	
////////////////////////////////////////////////////////////////////////////////
// Invalid read address register- SAR 111640
////////////////////////////////////////////////////////////////////////////////	
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
				invalid_rdaddr <= 1'b0;
			end
		
		else
			begin
				invalid_rdaddr <= (((ARADDR[4] & (| ARADDR[10:6]) & (| ARADDR[3:0])) | 
				                    (ARADDR == 11'd8 | ARADDR == 11'd12) | 
								    (ARADDR[7:4] == 5 & !(| ARADDR[10:8])) |
								    (ARADDR > 11'h46C)) &
								    (ARVALID & ARREADY));
			end
	end
	
////////////////////////////////////////////////////////////////////////////////
// WREADY output register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                WREADYReg <= 1'b0;
            end
        else
            begin
                WREADYReg <= WREADYReg_d;
            end
		
    end
assign WREADY = WREADYReg;

////////////////////////////////////////////////////////////////////////////////
// BVALID output register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                BVALIDReg <= 1'b0;
            end
        else
            begin
                BVALIDReg <= BVALIDReg_d;
            end
    end
assign BVALID = BVALIDReg;

////////////////////////////////////////////////////////////////////////////////
// BRESP output register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                BRESPReg <= 2'b0;
            end
        else
            begin
                BRESPReg <= BRESPReg_d;
            end
    end
assign BRESP = BRESPReg;

////////////////////////////////////////////////////////////////////////////////
// RVALID output register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                RVALIDReg <= 1'b0;
            end
        else
            begin
                RVALIDReg <= RVALIDReg_d;
            end
    end
assign RVALID = RVALIDReg;

////////////////////////////////////////////////////////////////////////////////
// RRESP output register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                RRESPReg <= 2'b0;
            end
        else
            begin
                RRESPReg <= RRESPReg_d;
            end
    end
assign RRESP = RRESPReg;

////////////////////////////////////////////////////////////////////////////////
// ctrlSel output register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                ctrlSelReg <= 1'b0;
            end
        else
            begin
                ctrlSelReg <= ctrlSelReg_d;
            end
    end
assign ctrlSel = ctrlSelReg;

////////////////////////////////////////////////////////////////////////////////
// ctrlWr output register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                ctrlWrReg <= 1'b0;
            end
        else
            begin
                ctrlWrReg <= ctrlWrReg_d;
            end
    end
assign ctrlWr = ctrlWrReg;

////////////////////////////////////////////////////////////////////////////////
// ctrlAddr output register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                ctrlAddrReg <= 11'b0;
            end
        else
            begin
                ctrlAddrReg <= ctrlAddrReg_d;
            end
    end
assign ctrlAddr = ctrlAddrReg;

////////////////////////////////////////////////////////////////////////////////
// ctrlWrData output register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                ctrlWrDataReg <= 32'b0;
            end
        else
            begin
                ctrlWrDataReg <= ctrlWrDataReg_d;
            end
    end
assign ctrlWrData = ctrlWrDataReg;

////////////////////////////////////////////////////////////////////////////////
// ctrlWrStrbs output register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                ctrlWrStrbsReg <= 4'b0;
            end
        else
            begin
                ctrlWrStrbsReg <= ctrlWrStrbsReg_d;
            end
    end
assign ctrlWrStrbs = ctrlWrStrbsReg;

endmodule // AXI4LiteSlaveCtrl