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
// *****************************************************************************
module CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_interrupt_x_ctrl(
    // General inputs
    clock,
    resetn,
    
    // AXISlaveCtrl inputs
    ctrlSel,
    ctrlWr,
    ctrlAddr,
    ctrlWrData,
    ctrlWrStrbs,
    
    // AXIMasterCtrl inputs
    valid,
    opDone,
    wrError,
    rdError,
    inValidDscrptr,
    intDscrptrNum,
    extDscrptr,
    extDscrptrAddr,
    strDscrptr,
    
    // CtrlIFMuxCDC outputs
    ctrlRdData,
    
    // DMAController outputs
    fifoFullQueueX,
    
    // MasterController outputs
    intX,
	
	
	//buffer descriptor error flags
	error_flag_sb_bd_out,
	error_flag_db_bd_out,
	
	//cache memory error flags
	error_flag_sb_cache,
	error_flag_db_cache,
	
	//stram cache error flag
	error_flag_sb_cache_str,
	error_flag_db_cache_str,
	
	//intext_dscrptr error flags
	error_flag_sb_intextdscrptr,
	error_flag_db_intextdscrptr,
	statusData,
	dataIn,
	intXNegEdge,
	fifoEmptyQueueX,
	fifordQueueX,
	error_flag_sb_fifo,
	error_flag_db_fifo
);

////////////////////////////////////////////////////////////////////////////////
// Parameters
////////////////////////////////////////////////////////////////////////////////
parameter INT_X_QUEUE_DEPTH = 1; // Number of descriptor status events that can be queued
                                 // before the arbiter is told to wait before kicking off more
                                 // operations related to this descriptor

parameter ECC    = 1;		
parameter FAMILY = 25;
parameter AXI4_STREAM_IF = 0;						 

////////////////////////////////////////////////////////////////////////////////
// Port directions
////////////////////////////////////////////////////////////////////////////////
input                           clock;
input                           resetn;

// CtrlIFMuxCDC inputs
input                           ctrlSel;
input                           ctrlWr;
input  [1:0]                    ctrlAddr;
input  [31:0]                   ctrlWrData;
input                           ctrlWrStrbs;

// DMAController inputs
input                           valid;
input                           opDone;
input                           wrError;
input                           rdError;
input                           inValidDscrptr;
input  [4:0]                    intDscrptrNum;
input                           extDscrptr;
input  [31:0]                   extDscrptrAddr;
input                           strDscrptr;

//Error flags input
input							error_flag_db_bd_out;
input							error_flag_sb_bd_out;
input							error_flag_db_cache;
input							error_flag_sb_cache;
input							error_flag_db_intextdscrptr;
input							error_flag_sb_intextdscrptr;
input							error_flag_sb_cache_str;
input							error_flag_db_cache_str;
input							error_flag_sb_fifo;
input							error_flag_db_fifo;

// CtrlIFMuxCDC outputs
output [31:0]                   ctrlRdData;

// DMAController outputs
output                          fifoFullQueueX;

// MasterController outputs
output reg                      intX;



////////////////////////////////////////////////////////////////////////////////
// Constants
////////////////////////////////////////////////////////////////////////////////
localparam LOAD = 1'b0;
localparam HOLD = 1'b1;

////////////////////////////////////////////////////////////////////////////////
// Internal signals
////////////////////////////////////////////////////////////////////////////////
reg             		currState;
reg             		nextState;
wire [5:0]      		intDscrptrNumInt;
output wire [49:0]     	dataIn;
wire [3:0]     			intXStaReg_d;
input wire [49:0]     	statusData;
reg               		ldSta;
output wire       		intXNegEdge;
wire              		fifoFullQueueX;
input             		fifoEmptyQueueX;
output            		fifordQueueX;
//input             error_flag_sb_fifo;
//input             error_flag_db_fifo;
//wire            reqForStaReg;
reg             		reqForStaReg;
wire            		intX_d;
wire [3:0]      		mskdSta;
reg  [3:0]      		intXMskReg;
reg  [3:0]      		intXClrReg;
reg  [51:0]     		intXStaReg;


//wire			error_pl_db_bd_out;
//wire			error_pl_sb_bd_out;
//wire			error_pl_db_cache;
//wire			error_pl_sb_cache;
//wire			error_pl_db_intextdscrptr;
//wire			error_pl_sb_intextdscrptr;

reg				error_flag_db_bd_out_reg;
reg				error_flag_sb_bd_out_reg;
reg				error_flag_db_cache_reg;
reg				error_flag_sb_cache_reg;
reg				error_flag_db_intextdscrptr_reg;
reg				error_flag_sb_intextdscrptr_reg;
reg 			reqForStaReg_reg;
reg				reqForStaReg_2;
reg				fifo_rd_en;
reg				error_flag_sb_cache_str_reg;
reg				error_flag_db_cache_str_reg;

			

assign intDscrptrNumInt = (strDscrptr) ? 6'd33 :
                          (extDscrptr) ? 6'd32 :
                          intDscrptrNum;
						  
						  

//assign dataIn = {extDscrptrAddr, intDscrptrNumInt, inValidDscrptr, rdError, wrError, opDone};
assign dataIn = (AXI4_STREAM_IF) ? {error_flag_db_cache_str_reg,
									error_flag_sb_cache_str_reg,
									error_flag_db_cache_reg,
									error_flag_sb_cache_reg,
									error_flag_db_intextdscrptr_reg,
									error_flag_sb_intextdscrptr_reg,
									error_flag_db_bd_out_reg,
									error_flag_sb_bd_out_reg,				 
									extDscrptrAddr, 
									intDscrptrNumInt,
									inValidDscrptr, 
									rdError, 
									wrError, 
									opDone} : 
												{{2{1'b0}},
												error_flag_db_cache_reg,
												error_flag_sb_cache_reg,
												error_flag_db_intextdscrptr_reg,
												error_flag_sb_intextdscrptr_reg,
												error_flag_db_bd_out_reg,
												error_flag_sb_bd_out_reg,				 
												extDscrptrAddr, 
												intDscrptrNumInt,
												inValidDscrptr, 
												rdError, 
												wrError, 
												opDone};



always @(posedge clock or negedge resetn)	
		begin
			if(!resetn)
				error_flag_db_bd_out_reg <= 1'b0;
			else if(error_flag_db_bd_out)
				error_flag_db_bd_out_reg <= 1'b1;
			else if(valid)
				error_flag_db_bd_out_reg <= 1'b0;				
		end

always @(posedge clock or negedge resetn)	
		begin
			if(!resetn)
				error_flag_sb_bd_out_reg <= 1'b0;
			else if(error_flag_sb_bd_out)
				error_flag_sb_bd_out_reg <= 1'b1;
			else if(valid)
				error_flag_sb_bd_out_reg <= 1'b0;				
		end		
always @(posedge clock or negedge resetn)	
		begin
			if(!resetn)
				error_flag_db_cache_reg <= 1'b0;
			else if(error_flag_db_cache)
				error_flag_db_cache_reg <= 1'b1;
			else if(valid)
				error_flag_db_cache_reg <= 1'b0;				
		end
		
always @(posedge clock or negedge resetn)	
		begin
			if(!resetn)
				error_flag_sb_cache_reg <= 1'b0;
			else if(error_flag_sb_cache)
				error_flag_sb_cache_reg <= 1'b1;
			else if(valid)
				error_flag_sb_cache_reg <= 1'b0;				
		end

always @(posedge clock or negedge resetn)	
		begin
			if(!resetn)
				error_flag_db_intextdscrptr_reg <= 1'b0;
			else if(error_flag_db_intextdscrptr)
				error_flag_db_intextdscrptr_reg <= 1'b1;
			else if(valid)
				error_flag_db_intextdscrptr_reg <= 1'b0;				
		end



always @(posedge clock or negedge resetn)	
		begin
			if(!resetn)
				error_flag_sb_intextdscrptr_reg <= 1'b0;
			else if(error_flag_sb_intextdscrptr)
				error_flag_sb_intextdscrptr_reg <= 1'b1;
			else if(valid)
				error_flag_sb_intextdscrptr_reg <= 1'b0;				
		end

always @(posedge clock or negedge resetn)	
		begin
			if(!resetn)
				error_flag_sb_cache_str_reg <= 1'b0;
			else if(error_flag_sb_cache_str)
				error_flag_sb_cache_str_reg <= 1'b1;
			else if(valid)
				error_flag_sb_cache_str_reg <= 1'b0;				
		end
		
always @(posedge clock or negedge resetn)	
		begin
			if(!resetn)
				error_flag_db_cache_str_reg <= 1'b0;
			else if(error_flag_db_cache_str)
				error_flag_db_cache_str_reg <= 1'b1;
			else if(valid)
				error_flag_db_cache_str_reg <= 1'b0;				
		end		
////////////////////////////////////////////////////////////////////////////////
// Interrupt X Queue
////////////////////////////////////////////////////////////////////////////////
// Instantiate a FIFO for queue
/* CoreAXI4DMAController_intControllerFIFO # (
    .FIFO_WIDTH         (50), 
    .WATERMARK_DEPTH    (INT_X_QUEUE_DEPTH),
	.ECC				(ECC),
	.FAMILY				(FAMILY)
) INT_0_FIFO (
    // Inputs
    .clock              (clock),
    .resetn             (resetn),
    .wrEn               (valid),
    .wrData             (dataIn),
    .rdEn               (intXNegEdge),
    // Outputs
    .rdData             (statusData),
    .fifoFull           (), // Unused
    .wMarkFull          (fifoFullQueueX),
    .fifoEmpty          (fifoEmptyQueueX),
	
	.error_flag_sb_fifo (error_flag_sb_fifo),
	.error_flag_db_fifo (error_flag_db_fifo)
); */
//assign reqForStaReg   = !fifoEmptyQueueX;


always @(posedge clock or negedge resetn)	///Added by Yashvir --->To see correct operation when read data from fifo is pipelined
		begin
			if(!resetn)
				reqForStaReg <= 1'b0;
			else
				//reqForStaReg_reg <= reqForStaReg;
				reqForStaReg   <= fifordQueueX;
		end
always @(posedge clock or negedge resetn)	///Added by Yashvir --->To see correct operation when read data from fifo is pipelined
		begin
			if(!resetn)
				reqForStaReg_2 <= 1'b0;
			else
				//reqForStaReg_reg <= reqForStaReg;
				reqForStaReg_2   <= reqForStaReg;
		end


////////////////////////////////////////////////////////////////////////////////
// Interrupt X control FSM
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                currState <= LOAD;
            end
        else
            begin
                currState <= nextState;
            end
    end

////////////////////////////////////////////////////////////////////////////////
// Combinatorial next state & output logic
////////////////////////////////////////////////////////////////////////////////
always @ (*)
    begin
        case (currState)
            LOAD:
                begin
                    if (reqForStaReg_2)
                        begin
                            ldSta     <= 1'b1;
                            nextState <= HOLD;
                        end
                    else
                        begin
                            ldSta     <= 1'b0;
                            nextState <= LOAD;
                        end
                end
            HOLD:
                begin
                    ldSta <= 1'b0;
                    if (intXNegEdge)
                        begin
                            // Don't assert the load enable here. Wait to see if
                            // this was the last byte in the FIFO first
                            nextState <= LOAD;
                        end
                    else
                        begin
                            nextState <= HOLD;
                        end
                end
        endcase
    end

assign intXNegEdge = ~intX_d & intX;
//assign fifordQueueX = ~fifoEmptyQueueX & ~intX_d & ~reqForStaReg & ~reqForStaReg_2 & ~reqForStaReg_3;
assign fifordQueueX = ~fifoEmptyQueueX & fifo_rd_en ;

always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                fifo_rd_en <= 1'b1;
            end
        else if(intXNegEdge)
            begin
				fifo_rd_en <= 1'b1;
			end
        else if(fifordQueueX)
            begin
				fifo_rd_en <= 1'b0;
			end		
	end


////////////////////////////////////////////////////////////////////////////////
// Interrupt X clear register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                intXClrReg <= 4'b0;
            end
        else
            begin
                if (ctrlSel & ctrlWr & ctrlWrStrbs && (ctrlAddr[1:0] == 2'b10))
                    begin
                        intXClrReg <= ctrlWrData[3:0];
                    end
                else
                    begin
                        intXClrReg <= 4'b0;
                    end
            end
    end

////////////////////////////////////////////////////////////////////////////////
// Interrupt X mask register - Sticky
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                intXMskReg <= 4'b0;
            end
        else
            begin
                if (ctrlSel & ctrlWr & ctrlWrStrbs && (ctrlAddr[1:0] == 2'b01))
                    begin
                        intXMskReg <= ctrlWrData[3:0];
                    end
            end
    end

////////////////////////////////////////////////////////////////////////////////
// Interrupt x status register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                intXStaReg <= 52'b0;
            end
        else if(ECC)
            begin
                if (ldSta)
                    begin
                        intXStaReg <= {error_flag_db_fifo,error_flag_sb_fifo,statusData[49:0]};
                    end
                else
                    begin
                        intXStaReg <= {intXStaReg[51:4],intXStaReg_d[3:0]};
                    end
            end
		else
			begin
			    if (ldSta)
                    begin
                        intXStaReg <= {10'd0,statusData[41:0]};
                    end
                else
                    begin
                        intXStaReg <= {intXStaReg[51:4],intXStaReg_d[3:0]};
                    end	
			end
    end

assign intXStaReg_d = (intXStaReg[3:0] & ~intXClrReg[3:0]);
assign mskdSta      = (intXStaReg_d[3:0] & intXMskReg[3:0]);

////////////////////////////////////////////////////////////////////////////////
// int output register
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
    begin
        if (!resetn)
            begin
                intX <= 1'b0;
            end
        else
            begin
                intX <= intX_d;
            end
    end
assign intX_d = ECC ? ((|mskdSta[3:0]) | (intXStaReg[51] & (|intXMskReg[3:0]))):(|mskdSta[3:0]);

// Combinatorial read data
assign ctrlRdData = (ctrlAddr == 2'b11) ? intXStaReg[41:10] :               // Ext dscrptr address register
                    (ctrlAddr == 2'b01) ? {{28{1'b0}}, intXMskReg[3:0]} :   // Interrupt mask register
                    (ctrlAddr == 2'b10) ? 32'b0 :                           // Interrupt clear register
                    {{12{1'b0}}, intXStaReg[51:42] ,intXStaReg[9:0]};                          // Interrupt status register
endmodule 