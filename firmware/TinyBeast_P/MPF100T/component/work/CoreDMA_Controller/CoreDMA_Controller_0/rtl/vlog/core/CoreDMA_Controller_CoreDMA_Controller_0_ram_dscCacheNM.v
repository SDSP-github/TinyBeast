// This is automatically generated file 

`timescale 1 ns/100 ps
module CoreDMA_Controller_CoreDMA_Controller_0_ram_dscCacheNM(
CLOCK,  
RESET_N,
WEN,    
WADDR,  
WDATA,  
REN,    
RADDR,  
RDATA,  
SB_CORRECT, 
DB_DETECT 
);      
  

// --------------------------------------------------------------------------
// PARAMETER Declaration
// --------------------------------------------------------------------------
parameter                WIDTH        = 128; // Cache width
parameter                DEPTH        = 128; // Cache Depth
// --------------------------------------------------------------------------
// I/O Declaration
// --------------------------------------------------------------------------
input                   CLOCK;  
input                   RESET_N;
input                   WEN;    
input [(DEPTH - 1) : 0] WADDR;  
input [(WIDTH - 1) : 0] WDATA;  
input                   REN;    
input [(DEPTH - 1)	: 0] RADDR;  
output[(WIDTH - 1)	: 0] RDATA;  
output                   SB_CORRECT; 
output                   DB_DETECT; 
  

assign SB_CORRECT = 1'b0; 
assign DB_DETECT  = 1'b0; 
  

CoreDMA_Controller_CoreDMA_Controller_0_SRAM_dscCacheNM ram_dscCacheNM(
.R_DATA        (RDATA       ),
.W_DATA        (WDATA       ),
.R_ADDR        (RADDR       ),
.W_ADDR        (WADDR       ),
.BLK_EN        (REN         ),
.W_EN          (WEN         ),
.CLK           (CLOCK       ),
.R_ADDR_EN     (1'b1        ),
.R_DATA_EN     (1'b1        ),
.R_ADDR_SRST_N (RESET_N     ),
.R_ADDR_ARST_N (RESET_N     ),
.R_DATA_SRST_N (RESET_N     ),
.R_DATA_ARST_N (RESET_N     ) 
);


endmodule
