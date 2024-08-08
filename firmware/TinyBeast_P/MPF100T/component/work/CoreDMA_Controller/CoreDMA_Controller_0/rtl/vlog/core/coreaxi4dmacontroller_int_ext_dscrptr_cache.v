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
// SVN $Revision: 37593 $
// SVN $Date: 2021-02-04 15:13:51 +0530 (Thu, 04 Feb 2021) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//
// ****************************************************************************/
module CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_intExtDscrptrCache (
    // Inputs
    clock,
    resetn,
    ldDscrptr,
    strDscrptr_dscrptrSrcMux,
    intDscrptrNum_dscrptrSrcMux,
    extDscrptr_dscrptrSrcMux,
    intDscrptrNum_updateDscrptrMux,
    updateIntExtDscrptrData,
    strDscrptr_DMATranCtrl,
    newNumOfBytes,
    newSrcAddr,
    newDstAddr,
    extDscrptrAddr,
    dscrptrData,
    dscrptrRdAddr,
    extDataValid,
	rdEn_intext,	
    // Outputs
    dscrptrDataOut,
    extDscrptr_intExtDscrptrCache,
    clrDataValidDscrptr,
	
	error_flag_sb_intextdscrptr,
	error_flag_db_intextdscrptr
);

////////////////////////////////////////////////////////////////////////////////
// User modifiable parameters
////////////////////////////////////////////////////////////////////////////////
parameter NUM_OF_BDS            = 4;
parameter NUM_OF_BDS_WIDTH      = 2;
parameter MAX_TRAN_SIZE_WIDTH   = 24;
parameter DSCRPTR_DATA_WIDTH    = 133;
parameter DSCRPTR_DATA_WIDTH_EXT_ADDR = (DSCRPTR_DATA_WIDTH+1+32);
parameter FAMILY =   25;
parameter ECC	 =   1;
////////////////////////////////////////////////////////////////////////////////
// Port directions
////////////////////////////////////////////////////////////////////////////////
input                                           clock;
input                                           resetn;
input                                           ldDscrptr;
input                                           strDscrptr_dscrptrSrcMux;
input       [NUM_OF_BDS_WIDTH-1:0]              intDscrptrNum_dscrptrSrcMux;
input                                           extDscrptr_dscrptrSrcMux;
input       [NUM_OF_BDS_WIDTH-1:0]              intDscrptrNum_updateDscrptrMux;
input                                           updateIntExtDscrptrData;
input                                           strDscrptr_DMATranCtrl;
input       [MAX_TRAN_SIZE_WIDTH-1:0]           newNumOfBytes;
input       [31:0]                              newSrcAddr;
input       [31:0]                              newDstAddr;
input       [31:0]                              extDscrptrAddr;
input       [DSCRPTR_DATA_WIDTH-1:0]            dscrptrData;
input       [NUM_OF_BDS_WIDTH-1:0]              dscrptrRdAddr;
input                                           extDataValid;
input                                           rdEn_intext;
output      [DSCRPTR_DATA_WIDTH_EXT_ADDR-1:0]   dscrptrDataOut;
output reg  [NUM_OF_BDS-1:0]                    extDscrptr_intExtDscrptrCache;
output reg  [NUM_OF_BDS-1:0]                    clrDataValidDscrptr;

output											error_flag_sb_intextdscrptr;
output											error_flag_db_intextdscrptr;


reg 											error_flag_sb_dscrptrConfigCacheNonMod; 
reg 											error_flag_sb_dscrptrCacheNonMod ;
reg 											error_flag_sb_dscrptrCacheMod;

reg 											error_flag_db_dscrptrConfigCacheNonMod; 
reg 											error_flag_db_dscrptrCacheNonMod ;
reg 											error_flag_db_dscrptrCacheMod;

reg		[NUM_OF_BDS_WIDTH-1:0]					dscrptrRdAddr_reg;

wire 											rdEn;

reg												rdEn_f1;
reg												rdEn_f2;
reg												rdEn_intext_reg;

wire 											error_flag_sb_dscrptrConfigCacheNonMod_mem;//to be connected to RAM
wire 											error_flag_sb_dscrptrCacheNonMod_mem;
wire 											error_flag_sb_dscrptrCacheMod_mem;
wire 											error_flag_db_dscrptrConfigCacheNonMod_mem;
wire 											error_flag_db_dscrptrCacheNonMod_mem;
wire 											error_flag_db_dscrptrCacheMod_mem;
wire 											wrEn;
wire [NUM_OF_BDS_WIDTH-1:0]						wrAddr;
wire [87:0]										wrData;

reg  [NUM_OF_BDS-1:0]       dataValidExtDscrptrReg;
integer                     idx;

wire  [12:0]                 rdata2 ;
wire  [63:0]                 rdata0;
wire  [87:0]                 rdata1;

assign wrEn = ((ldDscrptr & !strDscrptr_dscrptrSrcMux) || (updateIntExtDscrptrData & !strDscrptr_DMATranCtrl));
assign wrData = (ldDscrptr & !strDscrptr_dscrptrSrcMux) ? dscrptrData[101:14] : {newDstAddr, newSrcAddr, newNumOfBytes};
assign wrAddr = (ldDscrptr & !strDscrptr_dscrptrSrcMux) ? intDscrptrNum_dscrptrSrcMux : intDscrptrNum_updateDscrptrMux;

assign error_flag_sb_intextdscrptr = error_flag_sb_dscrptrConfigCacheNonMod | error_flag_sb_dscrptrCacheNonMod | error_flag_sb_dscrptrCacheMod;
assign error_flag_db_intextdscrptr = error_flag_db_dscrptrConfigCacheNonMod | error_flag_db_dscrptrCacheNonMod | error_flag_db_dscrptrCacheMod;


always @ (posedge clock or negedge resetn)
	begin
		if (!resetn)
			dscrptrRdAddr_reg <= 0;
							
		else
			dscrptrRdAddr_reg <= dscrptrRdAddr;
	end
	
always @ (posedge clock or negedge resetn)
	begin
		if (!resetn)
			rdEn_intext_reg <= 1'b1;
							
		else if(ECC)
			rdEn_intext_reg <= rdEn_intext;
		else 
			rdEn_intext_reg <= 1'b1;
	end		
	
assign rdEn = (dscrptrRdAddr != dscrptrRdAddr_reg) ? 1 : 0 ;

always @(posedge clock or negedge resetn) 
	if(!resetn)
		begin
			{rdEn_f2,rdEn_f1} <= 0;
		end
	else
		begin
			{rdEn_f2,rdEn_f1} <= {rdEn_f1,rdEn};
		end

always @(posedge clock or negedge resetn)
	if(!resetn)
		begin
			error_flag_sb_dscrptrConfigCacheNonMod 	<= 0;
			error_flag_sb_dscrptrCacheNonMod 		<= 0;
			error_flag_sb_dscrptrCacheMod 			<= 0;
			error_flag_db_dscrptrConfigCacheNonMod 	<= 0;
			error_flag_db_dscrptrCacheNonMod 		<= 0;
			error_flag_db_dscrptrCacheMod 			<= 0;
			
		end
	else
		if(rdEn_f2)
			begin
				error_flag_sb_dscrptrConfigCacheNonMod 	<= error_flag_sb_dscrptrConfigCacheNonMod_mem;
				error_flag_sb_dscrptrCacheNonMod	   	<= error_flag_sb_dscrptrCacheNonMod_mem;
				error_flag_sb_dscrptrCacheMod 		   	<= error_flag_sb_dscrptrCacheMod_mem;
				error_flag_db_dscrptrConfigCacheNonMod 	<= error_flag_db_dscrptrConfigCacheNonMod_mem;
				error_flag_db_dscrptrCacheNonMod 	   	<= error_flag_db_dscrptrCacheNonMod_mem;
				error_flag_db_dscrptrCacheMod 		   	<= error_flag_db_dscrptrCacheMod_mem;					
			end
			
			
	CoreDMA_Controller_CoreDMA_Controller_0_ram_dscConCacheNM #(
		.WIDTH(13),
		.DEPTH(NUM_OF_BDS_WIDTH)	
	)
	
		UI_ram_wrapper_0(
	.CLOCK(clock),
	.RESET_N(resetn),
	.WEN((ldDscrptr & !strDscrptr_dscrptrSrcMux)),
	.WADDR(intDscrptrNum_dscrptrSrcMux),
	.WDATA(dscrptrData[12:0]),
	.REN(rdEn_intext_reg),
	.RADDR(dscrptrRdAddr),
	.RDATA(rdata2),
    .SB_CORRECT(error_flag_sb_dscrptrConfigCacheNonMod_mem),  
    .DB_DETECT(error_flag_db_dscrptrConfigCacheNonMod_mem ) 	
	);

	CoreDMA_Controller_CoreDMA_Controller_0_ram_dscCacheNM #(
		.WIDTH(64),
		.DEPTH(NUM_OF_BDS_WIDTH)	
	)
	
		UI_ram_wrapper_1(
	.CLOCK(clock),
	.RESET_N(resetn),
	.WEN((ldDscrptr & !strDscrptr_dscrptrSrcMux)),
	.WADDR(intDscrptrNum_dscrptrSrcMux),
	.WDATA({extDscrptrAddr, dscrptrData[133:102]}),
	.REN(rdEn_intext_reg),
	.RADDR(dscrptrRdAddr),
	.RDATA(rdata0),
    .SB_CORRECT(error_flag_sb_dscrptrCacheNonMod_mem),    
    .DB_DETECT(error_flag_db_dscrptrCacheNonMod_mem ) 	
	);

	CoreDMA_Controller_CoreDMA_Controller_0_ram_dscCacheM #(
		.WIDTH(88),
		.DEPTH(NUM_OF_BDS_WIDTH)	
	)
	
		UI_ram_wrapper_2(
	.CLOCK(clock),
	.RESET_N(resetn),
	.WEN(wrEn),
	.WADDR(wrAddr),
	.WDATA(wrData),
	.REN(rdEn_intext_reg),
	.RADDR(dscrptrRdAddr),
	.RDATA(rdata1),
    .SB_CORRECT(error_flag_sb_dscrptrCacheMod_mem),    
    .DB_DETECT(error_flag_db_dscrptrCacheMod_mem ) 	
	);	


////////////////////////////////////////////////////////////////////////////////
// Register denoting whether descriptors held in cache are internal or external
// descriptors. Used in the reqMux to ensure that external descriptors are
// always passed to the DMATranCtrl block to poll the data valid bit if not set.
// Internal descriptors without data ready set are not passed to the DMATranCtrl
// block to prevent bus hogging.
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
	begin
		if (!resetn)
			extDscrptr_intExtDscrptrCache <= {NUM_OF_BDS{1'b0}};
		else if (ldDscrptr & !strDscrptr_dscrptrSrcMux)
			extDscrptr_intExtDscrptrCache[intDscrptrNum_dscrptrSrcMux] <= extDscrptr_dscrptrSrcMux;
		else if (updateIntExtDscrptrData && !strDscrptr_DMATranCtrl && (newNumOfBytes == {MAX_TRAN_SIZE_WIDTH{1'b0}}))
			extDscrptr_intExtDscrptrCache[intDscrptrNum_updateDscrptrMux] <= 1'b0;
	end
	
////////////////////////////////////////////////////////////////////////////////
// Register for holding data valid for external descriptors
// Can be detected high and written initially from the dscrptrSrcMux or else
// polled every time that the external descriptor request is passed to the 
// DMATranCtrl block.
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
	begin
		if (!resetn)
			dataValidExtDscrptrReg <= {NUM_OF_BDS{1'b0}};
		else if (ldDscrptr & !strDscrptr_dscrptrSrcMux & extDscrptr_dscrptrSrcMux)
			dataValidExtDscrptrReg[intDscrptrNum_dscrptrSrcMux] <= dscrptrData[13];
		else if (updateIntExtDscrptrData && !strDscrptr_DMATranCtrl && (newNumOfBytes == {MAX_TRAN_SIZE_WIDTH{1'b0}}))
			dataValidExtDscrptrReg[intDscrptrNum_updateDscrptrMux] <= 1'b0;
		else if (updateIntExtDscrptrData & !strDscrptr_DMATranCtrl & extDataValid) // Ext descriptor data valid fetch
			dataValidExtDscrptrReg[intDscrptrNum_updateDscrptrMux] <= 1'b1;
	end

////////////////////////////////////////////////////////////////////////////////
// Internal/External descriptor cache
// - Separate out modified and unmodified descriptor fields so that block RAM
// - can be inferred for both. Otherwise fabric registers would be utilised.
////////////////////////////////////////////////////////////////////////////////
/* always @ (posedge clock)
	begin
		if (ldDscrptr & !strDscrptr_dscrptrSrcMux) // Store the associated external descriptor address along with the data.
			dscrptrCacheNonMod[intDscrptrNum_dscrptrSrcMux] <= {extDscrptrAddr, dscrptrData[133:102]};
	end

always @ (posedge clock)
	begin
		if (ldDscrptr & !strDscrptr_dscrptrSrcMux) // Unmodified bits of the Descriptors Config register
			dscrptrConfigCacheNonMod[intDscrptrNum_dscrptrSrcMux] <= dscrptrData[12:0];
	end

always @ (posedge clock)
	begin
		if (ldDscrptr & !strDscrptr_dscrptrSrcMux) // Fields modified when the Descriptor request is partially serviced (Src addr, dest addr, num of bytes)
			dscrptrCacheMod[intDscrptrNum_dscrptrSrcMux] <= dscrptrData[101:14];
		else if (updateIntExtDscrptrData & !strDscrptr_DMATranCtrl)
			dscrptrCacheMod[intDscrptrNum_updateDscrptrMux] <= {newDstAddr, newSrcAddr, newNumOfBytes};
	end */
	

// Concatenate the asynchronous read data from both block RAMs
/*assign dscrptrDataOut = {extDscrptr_intExtDscrptrCache[dscrptrRdAddr],
						 dscrptrCacheNonMod[dscrptrRdAddr],           // External descriptor address & next Descriptor number/address (chain)
						 dscrptrCacheMod[dscrptrRdAddr],              // Modifiable parts of DMA - Src addr, Dest addr, number of bytes to transfer
						 dataValidExtDscrptrReg[dscrptrRdAddr],       // Bit reflecting external descriptor data valid bit - Cleared when newNumOfWords is zero
						 dscrptrConfigCacheNonMod[dscrptrRdAddr]      // Lower part of the descriptor Config register will not be modified by DMATranCtrl
						};*/
						
assign dscrptrDataOut = {extDscrptr_intExtDscrptrCache[dscrptrRdAddr],
						 rdata0,           // External descriptor address & next Descriptor number/address (chain)
						 rdata1,              // Modifiable parts of DMA - Src addr, Dest addr, number of bytes to transfer
						 dataValidExtDscrptrReg[dscrptrRdAddr],       // Bit reflecting external descriptor data valid bit - Cleared when newNumOfWords is zero
						 rdata2  }   ; // Lower part o
						 


/* always @ (posedge clock or negedge resetn)
	if(!resetn)
		begin
			rdata0 <= 0;
			rdata1 <= 0;
			rdata2 <= 0;								
		end
	else
		begin
			rdata0<= dscrptrCacheNonMod[dscrptrRdAddr_reg];
			rdata1<=dscrptrCacheMod[dscrptrRdAddr_reg];
			rdata2<=dscrptrConfigCacheNonMod[dscrptrRdAddr_reg];
		end */
////////////////////////////////////////////////////////////////////////////////
// Clear data valid for internal descriptors held in LSRAM when the descriptor
// is serviced completely.
////////////////////////////////////////////////////////////////////////////////
always @ (*)
	begin
		for (idx = 0; idx <= NUM_OF_BDS-1; idx = idx + 1)
			begin
				if ((idx == intDscrptrNum_updateDscrptrMux) && !extDscrptr_intExtDscrptrCache[idx]) 
					begin
						// Only clear the data valid bit for internal descriptors here when the number number of bytes is
						// written back as zero
						clrDataValidDscrptr[idx] = (updateIntExtDscrptrData && !strDscrptr_DMATranCtrl && (newNumOfBytes == {MAX_TRAN_SIZE_WIDTH{1'b0}}));
					end
				else
					begin
						clrDataValidDscrptr[idx] = 1'b0;
					end
			end
	end

endmodule // intExtDscrptrCache