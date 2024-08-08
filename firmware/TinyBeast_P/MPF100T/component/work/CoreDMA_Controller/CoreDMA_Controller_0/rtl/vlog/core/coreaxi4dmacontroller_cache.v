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
module CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_Cache (
    clock,
    resetn,
    
    // DMAController inputs
    wrEn,
    wrAddr,
    wrByteCnt,
    wrData,
    rdEn,
    rdAddr,
    rdByteCnt,
    
    // AXI4MasterCtrl inputs
    wrCacheSel,
    rdCacheSel,
    clrRdCache,
    
    // AXI4MasterCtrl outputs
    rdData,
    noOfBytesInCurrCacheWrSel,
    noOfBytesInCurrCacheRdSel,
	
	//ECC flags
	error_flag_sb_cache,
	error_flag_db_cache
		
);

////////////////////////////////////////////////////////////////////////////////
// Parameters
////////////////////////////////////////////////////////////////////////////////
parameter CACHE_WIDTH = 1; // Equivalent to AXI Bus Width (bytes)
parameter CACHE_DEPTH = 1; // Number of locations in the cache. Determined by the
                           // number of AXI4 beats allowed for the highest enabled
                           // priority level configured.
						   
parameter FAMILY      = 25;
parameter ECC         = 1;

// Include file containing the implementation of clog2() function
`include "./coreaxi4dmacontroller_utility_functions.v"

////////////////////////////////////////////////////////////////////////////////
// Constants
////////////////////////////////////////////////////////////////////////////////
localparam MAX_BYTE_CNT = CACHE_DEPTH * CACHE_WIDTH;
localparam TRAN_BYTE_CNT_WIDTH = clog2(CACHE_WIDTH);
localparam MAX_BYTE_CNT_WIDTH = clog2(MAX_BYTE_CNT);
localparam CACHE_DEPTH_WIDTH = clog2(CACHE_DEPTH-1);

////////////////////////////////////////////////////////////////////////////////
// Port directions
////////////////////////////////////////////////////////////////////////////////
input                           clock;
input                           resetn;

// DMAController inputs
input                           wrEn;
input [CACHE_DEPTH_WIDTH-1:0]   wrAddr;
input [(CACHE_WIDTH*8)-1:0]     wrData;
input [TRAN_BYTE_CNT_WIDTH-1:0] wrByteCnt;
input                           rdEn;
input [CACHE_DEPTH_WIDTH-1:0]   rdAddr;
input [TRAN_BYTE_CNT_WIDTH-1:0] rdByteCnt;

// AXI4MasterCtrl inputs
input                           wrCacheSel;
input                           rdCacheSel;
input                           clrRdCache;

// AXI4MasterCtrl inputs
output [(CACHE_WIDTH*8)-1:0]    rdData;
output [MAX_BYTE_CNT_WIDTH-1:0] noOfBytesInCurrCacheWrSel;
output [MAX_BYTE_CNT_WIDTH-1:0] noOfBytesInCurrCacheRdSel;

output							error_flag_sb_cache;
output							error_flag_db_cache;


reg								error_flag_sb_cache0;
reg								error_flag_db_cache0;

reg								error_flag_sb_cache1;
reg								error_flag_db_cache1;

reg								rdEn_f1;
reg								rdEn_f2;

reg								wrCacheSel_f1;
reg								wrCacheSel_f2;

wire							error_flag_sb_cache0_mem;
wire							error_flag_db_cache0_mem;
wire							error_flag_sb_cache1_mem;
wire							error_flag_db_cache1_mem;


////////////////////////////////////////////////////////////////////////////////
// Internal signals
////////////////////////////////////////////////////////////////////////////////

reg [MAX_BYTE_CNT_WIDTH-1:0]    cache0ByteCnt;
reg [MAX_BYTE_CNT_WIDTH-1:0]    cache1ByteCnt;
wire[3:0]                       cacheCase;

wire [(CACHE_WIDTH*8)-1:0] 		rdata_cache1;
wire [(CACHE_WIDTH*8)-1:0] 		rdata_cache0;


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
			{wrCacheSel_f2,wrCacheSel_f1} <= 0;
		end
	else
		begin
			{wrCacheSel_f2,wrCacheSel_f1} <= {wrCacheSel_f1,wrCacheSel};
		end

		
always @(posedge clock or negedge resetn)
	if(!resetn)
		begin
			error_flag_sb_cache0 <= 0;
			error_flag_db_cache0 <= 0;
			error_flag_sb_cache1 <= 0;
			error_flag_db_cache1 <= 0;
			
		end
	else
		begin
			error_flag_sb_cache0 <= 0;
			error_flag_db_cache0 <= 0;
			error_flag_sb_cache1 <= 0;
			error_flag_db_cache1 <= 0;
			if(rdEn_f2 & !wrCacheSel_f2)
				begin
					error_flag_sb_cache0 <= error_flag_sb_cache0_mem;
					error_flag_db_cache0 <= error_flag_db_cache0_mem;
				end
			if(rdEn_f2 & wrCacheSel_f2)
				begin					
					error_flag_sb_cache1 <= error_flag_sb_cache1_mem;
					error_flag_db_cache1 <= error_flag_db_cache1_mem;					
				end
		end	


assign error_flag_sb_cache = error_flag_sb_cache0 | error_flag_sb_cache1;
assign error_flag_db_cache = error_flag_db_cache0 | error_flag_db_cache1;	

	CoreDMA_Controller_CoreDMA_Controller_0_ram_cache #(
		.WIDTH((CACHE_WIDTH*8)),
		.DEPTH(CACHE_DEPTH_WIDTH)	
	)
	
		UI_ram_wrapper_cache0(
	.CLOCK(clock),
	.RESET_N(resetn),
	.WEN(wrEn & !rdCacheSel),
	.WADDR(wrAddr),
	.WDATA(wrData),
	.REN(rdEn & !wrCacheSel),
	.RADDR(rdAddr),
	.RDATA(rdata_cache0),
    .SB_CORRECT(error_flag_sb_cache0_mem),  
    .DB_DETECT (error_flag_db_cache0_mem) 	
	);

	CoreDMA_Controller_CoreDMA_Controller_0_ram_cache #(
		.WIDTH((CACHE_WIDTH*8)),
		.DEPTH(CACHE_DEPTH_WIDTH)	
	)
	
		UI_ram_wrapper_cache1(
	.CLOCK(clock),
	.RESET_N(resetn),
	.WEN(wrEn & rdCacheSel),
	.WADDR(wrAddr),
	.WDATA(wrData),
	.REN(rdEn & wrCacheSel),
	.RADDR(rdAddr),
	.RDATA(rdata_cache1),
    .SB_CORRECT(error_flag_sb_cache1_mem),  
    .DB_DETECT (error_flag_db_cache1_mem )	
	
	);
	
	
assign rdData = (wrCacheSel) ? rdata_cache1 : rdata_cache0;

assign cacheCase = {wrEn , rdCacheSel, rdEn_f2 , wrCacheSel};
////////////////////////////////////////////////////////////////////////////////
// Counter keeping track of the number of bytes in each cache
////////////////////////////////////////////////////////////////////////////////
always @ (posedge clock or negedge resetn)
	begin
		if (!resetn)
			begin
				cache0ByteCnt <= {MAX_BYTE_CNT_WIDTH{1'b0}};
				cache1ByteCnt <= {MAX_BYTE_CNT_WIDTH{1'b0}};
			end
		else
			begin
				if (clrRdCache)
					begin
						if (wrCacheSel)
							begin
								cache1ByteCnt <= {MAX_BYTE_CNT_WIDTH{1'b0}};
							end
						else
							begin
								cache0ByteCnt <= {MAX_BYTE_CNT_WIDTH{1'b0}};
							end
						if ((wrEn == 1'b1) && (wrCacheSel != rdCacheSel))
							begin
								if (rdCacheSel)
									begin
										cache1ByteCnt <= cache1ByteCnt + wrByteCnt;
									end
								else
									begin
										cache0ByteCnt <= cache0ByteCnt + wrByteCnt;
									end
							end                            
					end
				else
					begin
						case (cacheCase)
							4'b0010, 4'b0110: // Reading from cache 0
								begin
									cache0ByteCnt <= cache0ByteCnt - rdByteCnt;
									cache1ByteCnt <= cache1ByteCnt;
								end
							4'b0011, 4'b0111: // Reading from cache 1
								begin
									cache0ByteCnt <= cache0ByteCnt;
									cache1ByteCnt <= cache1ByteCnt - rdByteCnt;
								end
							4'b1000, 4'b1001: // Writing to cache 0
								begin
									cache0ByteCnt <= cache0ByteCnt + wrByteCnt;
									cache1ByteCnt <= cache1ByteCnt;
								end
							4'b1010: // Writing to cache 0, reading from cache 0
								begin
									cache0ByteCnt <= cache0ByteCnt + wrByteCnt - rdByteCnt;
									cache1ByteCnt <= cache1ByteCnt;
								end
							4'b1011: // Writing to cache 0, reading from cache 1
								begin
									cache0ByteCnt <= cache0ByteCnt + wrByteCnt;
									cache1ByteCnt <= cache1ByteCnt - rdByteCnt;
								end
							4'b1100, 4'b1101: // Writing to cache 1
								begin
									cache0ByteCnt <= cache0ByteCnt;
									cache1ByteCnt <= cache1ByteCnt + wrByteCnt;
								end
							4'b1110: // Writing to cache 1, reading from cache 0
								begin
									cache0ByteCnt <= cache0ByteCnt - rdByteCnt;
									cache1ByteCnt <= cache1ByteCnt + wrByteCnt;
								end
							4'b1111: // Writing to cache 1, reading from cache 1
								begin
									cache0ByteCnt <= cache0ByteCnt;
									cache1ByteCnt <= cache1ByteCnt + wrByteCnt - rdByteCnt;
								end
							default: // Maintain the values for all other cases
								begin
									cache0ByteCnt <= cache0ByteCnt;
									cache1ByteCnt <= cache1ByteCnt;
								end
						endcase
					end
			end
	end

assign noOfBytesInCurrCacheWrSel = (wrCacheSel) ? cache1ByteCnt : cache0ByteCnt;
assign noOfBytesInCurrCacheRdSel = (rdCacheSel) ? cache1ByteCnt : cache0ByteCnt;



	//generate
	//	if(FAMILY == 25)
	//		if(ECC)
	//			begin
	//				reg [(CACHE_WIDTH*8)-1:0] cache0 [0: CACHE_DEPTH-1]/*synthesis syn_ramstyle="ecc"*/;
	//				reg [(CACHE_WIDTH*8)-1:0] cache1 [0: CACHE_DEPTH-1]/*synthesis syn_ramstyle="ecc"*/;
	//				
	//
	//				////////////////////////////////////////////////////////////////////////////////
	//				// Cache0 & Cache1 sync write, sync read RAM inference
	//				////////////////////////////////////////////////////////////////////////////////
	//				always @ (posedge clock )
	//				begin
	//					if (wrEn)
	//						begin
	//							if (rdCacheSel)
	//								begin
	//									cache1[wrAddr] <= wrData;
	//								end
	//							else
	//								begin
	//									cache0[wrAddr] <= wrData;
	//								end
	//						end
	//				end
	//
	//				//assign rdData = (wrCacheSel) ? cache1[rdAddr] : cache0[rdAddr];
	//				assign rdData = (wrCacheSel) ? rdata_cache1 : rdata_cache0;
	//
	//			
	//
	//				always @ (posedge clock or negedge resetn)
	//					if(!resetn)
	//						begin
	//							rdata_cache1 <= 0;
	//							rdata_cache0 <= 0;
	//						end
	//					else
	//						begin
	//							rdata_cache1 <= cache1[rdAddr_reg];
	//							rdata_cache0 <= cache0[rdAddr_reg];
	//						end
	//				assign cacheCase = {wrEn , rdCacheSel, rdEn_f2 , wrCacheSel};
	//

endmodule