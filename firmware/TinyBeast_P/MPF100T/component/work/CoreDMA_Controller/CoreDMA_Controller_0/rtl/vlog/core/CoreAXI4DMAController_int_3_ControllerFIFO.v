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
// SVN $Revision: 36859 $
// SVN $Date: 2020-10-27 17:26:40 +0530 (Tue, 27 Oct 2020) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//
// ****************************************************************************/
module CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_int_3_ControllerFIFO (
    // Inputs
    clock,
    resetn,
    wrEn,
    wrData,
    rdEn,
    // Outputs
    rdData,
    fifoFull,
    wMarkFull,
    fifoEmpty,
	
	//ECC flags
	error_flag_sb_fifo,
	error_flag_db_fifo
);

////////////////////////////////////////////////////////////////////////////////
// User modifiable parameters
////////////////////////////////////////////////////////////////////////////////
parameter FIFO_WIDTH      = 8;
parameter WATERMARK_DEPTH = 2;
parameter ECC 			  = 1;
parameter FAMILY 		  = 25;				

// Include file containing the implementation of clog2() function
`include "./coreaxi4dmacontroller_utility_functions.v"

////////////////////////////////////////////////////////////////////////////////
// Constants
////////////////////////////////////////////////////////////////////////////////
// Instantiate 3 locations more than the user depth to prevent worse case
// scenario number of interrupt events held in the pipeline from overrunning
// this interrupt queue.
localparam FIFO_DEPTH       = WATERMARK_DEPTH + 3;
localparam FIFO_DEPTH_WIDTH = clog2(FIFO_DEPTH-1);

////////////////////////////////////////////////////////////////////////////////
// Port directions
////////////////////////////////////////////////////////////////////////////////
input                   clock;
input                   resetn;
input                   wrEn;
input  [FIFO_WIDTH-1:0] wrData;
input                   rdEn;
output  [FIFO_WIDTH-1:0] rdData;
output                  fifoFull;
output                  wMarkFull;
output                  fifoEmpty;


output 					error_flag_sb_fifo;
output 					error_flag_db_fifo;


////////////////////////////////////////////////////////////////////////////////
// Internal signals
////////////////////////////////////////////////////////////////////////////////

reg [FIFO_DEPTH_WIDTH-1:0]  wrAddr;
reg [FIFO_DEPTH_WIDTH-1:0]  rdAddr;
reg [FIFO_DEPTH_WIDTH:0]    unitCnt;

reg [FIFO_DEPTH_WIDTH-1:0]  rdAddr_reg;


	always @ (posedge clock or negedge resetn)
		begin
			if (!resetn)
				rdAddr_reg <= 0;
			else
				rdAddr_reg <= rdAddr;
				
		end
		
//assign error_flag_sb_fifo  =  A_SB_CORRECT_fifo_0 | B_SB_CORRECT_fifo_0;
//assign error_flag_db_fifo  =  A_DB_DETECT_fifo_0  | B_DB_DETECT_fifo_0;
		
	CoreDMA_Controller_CoreDMA_Controller_0_ram_fifo_3 #(
		.WIDTH(FIFO_WIDTH),
		.DEPTH(FIFO_DEPTH_WIDTH)	
	)
	
		LI_ram_wrapper_fifo_3(
	.CLOCK(clock),
	.RESET_N(resetn),
	.WEN(wrEn),
	.WADDR(wrAddr),
	.WDATA(wrData),
	.REN(rdEn),
	.RADDR(rdAddr),
	.RDATA(rdData),
    .SB_CORRECT(error_flag_sb_fifo),    
    .DB_DETECT (error_flag_db_fifo ) 	
	);
	

////////////////////////////////////////////////////////////////////////////////
// unit counter
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
	begin
		if (!resetn)
			begin
				unitCnt <= {(FIFO_DEPTH_WIDTH+1){1'b0}};
			end
		else
			begin
				case ({wrEn, rdEn})
					2'b01:
						begin
							unitCnt <= unitCnt - 1'b1;
						end
					2'b10:
						begin
							if (!fifoFull)
								begin
									unitCnt <= unitCnt + 1'b1;
								end
							else
								begin
									unitCnt <= unitCnt;
								end
						end
					default:
						begin
							unitCnt <= unitCnt;
						end
				endcase
			end
	end
assign fifoFull  = (unitCnt == FIFO_DEPTH);
assign fifoEmpty = (unitCnt == {(FIFO_DEPTH_WIDTH+1){1'b0}});
assign wMarkFull = (unitCnt == WATERMARK_DEPTH);

////////////////////////////////////////////////////////////////////////////////
// Write address pointer
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
	begin
		if (!resetn)
			begin
				wrAddr <= {FIFO_DEPTH_WIDTH{1'b0}};
			end
		else
			begin
				if (wrEn)
					begin
						if (wrAddr == FIFO_DEPTH-1)
							begin
								wrAddr <= {FIFO_DEPTH_WIDTH{1'b0}};
							end
						else
							begin
								wrAddr <= wrAddr + 1'b1;
							end
					end
			end
	end
////////////////////////////////////////////////////////////////////////////////
// Read address pointer
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
	begin
		if (!resetn)
			begin
				rdAddr <= {FIFO_DEPTH_WIDTH{1'b0}};
			end
		else
			begin
				if (rdEn)
					begin
						if (rdAddr == FIFO_DEPTH-1)
							begin
								rdAddr <= {FIFO_DEPTH_WIDTH{1'b0}};
							end
						else
							begin
								rdAddr <= rdAddr + 1'b1;
							end
					end
			end
	end

	//generate
	//	if(FAMILY == 25)
	//		if(ECC)
	//			begin
	//				reg [FIFO_WIDTH-1:0] RAM [0:FIFO_DEPTH-1]/*synthesis syn_ramstyle="ecc"*/;
	//
	//				////////////////////////////////////////////////////////////////////////////////
	//				// RAM inference - Sync write, sync read
	//				////////////////////////////////////////////////////////////////////////////////
	//				always @ (posedge clock)
	//					begin
	//						rdData = RAM[rdAddr_reg];
	//						if (wrEn) 
	//							RAM[wrAddr] <= wrData;
	//							
	//							
	//					end
	//
	//				//assign rdData = RAM[rdAddr];
	//
	//endgenerate
endmodule // intControllerFIFO