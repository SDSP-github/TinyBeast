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
// SVN $Revision: 37584 $
// SVN $Date: 2021-02-02 16:59:16 +0530 (Tue, 02 Feb 2021) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//
// ****************************************************************************/
module CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_intController (
    // General inputs
    clock,
    resetn,
    
    // CtrlIFMuxCDC inputs
    ctrlSel,
    ctrlWr,
    ctrlAddr,
    ctrlWrData,
    ctrlWrStrbs,
    
    // DMAController inputs
    valid,
    opDone,
    wrError,
    rdError,
    inValidDscrptr,
    intDscrptrNum,
    extDscrptr,
    extDscrptrAddr,
    strDscrptr,
	
	//ECC flags inputs
	error_flag_db_bd_out,
	error_flag_sb_bd_out,
	error_flag_db_cache,
	error_flag_sb_cache,
	error_flag_db_intextdscrptr,
	error_flag_sb_intextdscrptr,
	error_flag_sb_cache_str,
	error_flag_db_cache_str,
    
    // CtrlIFMuxCDC outputs
    ctrlRdData,
    ctrlRdValid,
    
    // DMAController outputs
    waitDscrptr,
    waitStrDscrptr,
    
    // MasterController outputs
    int0,
    int1,
    int2,
    int3
);
////////////////////////////////////////////////////////////////////////////////
// Parameters
////////////////////////////////////////////////////////////////////////////////
parameter   NUM_INT_BDS       = 4;
parameter   NUM_INT_BDS_WIDTH = 2;
parameter   INT_0_QUEUE_DEPTH = 0;
parameter   INT_1_QUEUE_DEPTH = 0;
parameter   INT_2_QUEUE_DEPTH = 0;
parameter   INT_3_QUEUE_DEPTH = 0;
parameter	ECC				  = 1;
parameter   FAMILY			  = 24;
parameter	AXI4_STREAM_IF	  = 0;

// Auto-generated include file containing custom association of descriptors
// with interrupt queues.
`include "../../../coreaxi4dmacontroller_interrupt_parameters.v"

////////////////////////////////////////////////////////////////////////////////
// Port directions
////////////////////////////////////////////////////////////////////////////////
input                           clock;
input                           resetn;

// CtrlIFMuxCDC inputs
input                           ctrlSel;
input                           ctrlWr;
input  [10:0]                   ctrlAddr;
input  [31:0]                   ctrlWrData;
input  [3:0]                    ctrlWrStrbs;

// DMAController inputs
input                           valid;
input                           opDone;
input                           wrError;
input                           rdError;
input                           inValidDscrptr;
input  [NUM_INT_BDS_WIDTH-1:0]  intDscrptrNum;
input                           extDscrptr;
input  [31:0]                   extDscrptrAddr;
input                           strDscrptr;

input							error_flag_db_bd_out;
input							error_flag_sb_bd_out;
input							error_flag_db_cache;
input							error_flag_sb_cache;
input							error_flag_db_intextdscrptr;
input							error_flag_sb_intextdscrptr;
input							error_flag_sb_cache_str;
input							error_flag_db_cache_str;

// CtrlIFMuxCDC outputs
output [31:0]                   ctrlRdData;
output                          ctrlRdValid;

// DMAController outputs
output [NUM_INT_BDS-1:0]        waitDscrptr;
output                          waitStrDscrptr;

// MasterController outputs
output                          int0;
output                          int1;
output                          int2;
output                          int3;

////////////////////////////////////////////////////////////////////////////////
// Internal signals
////////////////////////////////////////////////////////////////////////////////
wire [31:0]                     rdDataInt0;
wire                            fifoFullQueue0;
wire [31:0]                     rdDataInt1;
wire                            fifoFullQueue1;
wire [31:0]                     rdDataInt2;
wire                            fifoFullQueue2;
wire [31:0]                     rdDataInt3;
wire                            fifoFullQueue3;
wire [4:0]                      intDscrptrNumInt;

wire [49:0]						statusData0;
wire [49:0]						statusData1;
wire [49:0]						statusData2;
wire [49:0]						statusData3;

wire [49:0]						dataIn0;
wire [49:0]						dataIn1;
wire [49:0]						dataIn2;
wire [49:0]						dataIn3;

// Auto-generated include file containing custom association of descriptors
// with interrupt queues.
`include "../../../coreaxi4dmacontroller_interrupt_mapping.v"
wire [3:0] ctrlSelIntQueue;
wire [3:0] ctrlWrIntQueue;

assign ctrlRdValid = 1'b1;
////////////////////////////////////////////////////////////////////////////////
// Mux Control signals to the correct Interrupt registers
////////////////////////////////////////////////////////////////////////////////
assign ctrlSelIntQueue[3:0] = ((ctrlAddr[10:4] == 7'h01) && (ctrlSel == 1'b1)) ? 4'b0001 :
                              ((ctrlAddr[10:4] == 7'h02) && (ctrlSel == 1'b1)) ? 4'b0010 :
                              ((ctrlAddr[10:4] == 7'h03) && (ctrlSel == 1'b1)) ? 4'b0100 :
                              ((ctrlAddr[10:4] == 7'h04) && (ctrlSel == 1'b1)) ? 4'b1000 :
                              4'b0000;

assign ctrlWrIntQueue[3:0]  = ((ctrlAddr[10:4] == 7'h01) && (ctrlSel == 1'b1) && (ctrlWr == 1'b1)) ? 4'b0001 :
                              ((ctrlAddr[10:4] == 7'h02) && (ctrlSel == 1'b1) && (ctrlWr == 1'b1)) ? 4'b0010 :
                              ((ctrlAddr[10:4] == 7'h03) && (ctrlSel == 1'b1) && (ctrlWr == 1'b1)) ? 4'b0100 :
                              ((ctrlAddr[10:4] == 7'h04) && (ctrlSel == 1'b1) && (ctrlWr == 1'b1)) ? 4'b1000 :
                              4'b0000;

assign ctrlRdData[31:0]     = ((ctrlAddr[10:4] == 7'h01) && (ctrlSel == 1'b1)) ? rdDataInt0 :
                              ((ctrlAddr[10:4] == 7'h02) && (ctrlSel == 1'b1)) ? rdDataInt1 :
                              ((ctrlAddr[10:4] == 7'h03) && (ctrlSel == 1'b1)) ? rdDataInt2 :
                              ((ctrlAddr[10:4] == 7'h04) && (ctrlSel == 1'b1)) ? rdDataInt3 :
                              32'd0;

assign intDscrptrNumInt = {{(5-NUM_INT_BDS_WIDTH){1'b0}}, intDscrptrNum};
////////////////////////////////////////////////////////////////////////////////
// Interrupt 0
////////////////////////////////////////////////////////////////////////////////
generate
    if (NUM_INT_0_BDS >= 1)
        begin
			wire fifordQueue0;
			wire error_flag_sb_fifo0;
			wire error_flag_db_fifo0;
			wire fifoEmptyQueue0;
			
            CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_interrupt_x_ctrl #(
                .INT_X_QUEUE_DEPTH          (INT_0_QUEUE_DEPTH),
				.ECC						(ECC),
				.FAMILY						(FAMILY),
				.AXI4_STREAM_IF            	(AXI4_STREAM_IF)
				
            ) U_INT_0_QUEUE (
                // General inputs
                .clock                      (clock),
                .resetn                     (resetn),
                
                // AXISlaveCtrl inputs
                .ctrlSel                    (ctrlSelIntQueue[0]),
                .ctrlWr                     (ctrlWrIntQueue[0]),
                .ctrlAddr                   (ctrlAddr[3:2]),
                .ctrlWrData                 (ctrlWrData),
                .ctrlWrStrbs                (ctrlWrStrbs[0]),
                
                // AXIMasterCtrl inputs
                .valid                      (intValidQueue0),
                .opDone                     (opDone),
                .wrError                    (wrError),
                .rdError                    (rdError),
                .inValidDscrptr             (inValidDscrptr),
                .intDscrptrNum              (intDscrptrNumInt),
                .extDscrptr                 (extDscrptr),
                .extDscrptrAddr             (extDscrptrAddr),
                .strDscrptr                 (strDscrptr),
				
				//ECC flags
				.error_flag_sb_fifo 		(error_flag_sb_fifo0),
				.error_flag_db_fifo 		(error_flag_db_fifo0),
				.error_flag_db_bd_out		(error_flag_db_bd_out),
				.error_flag_sb_bd_out		(error_flag_sb_bd_out),
				.error_flag_db_cache		(error_flag_db_cache),
				.error_flag_sb_cache		(error_flag_sb_cache),
				.error_flag_db_intextdscrptr(error_flag_db_intextdscrptr),
				.error_flag_sb_intextdscrptr(error_flag_sb_intextdscrptr),
				.error_flag_sb_cache_str	(error_flag_sb_cache_str),
				.error_flag_db_cache_str	(error_flag_db_cache_str),
                
                // CtrlIFMuxCDC outputs
                .ctrlRdData                 (rdDataInt0),
                
                // DMAController outputs
                .fifoFullQueueX             (fifoFullQueue0),
                .fifordQueueX               (fifordQueue0),
                
                // MasterController outputs
                .intX                       (int0),
				
				.statusData					(statusData0),
				.dataIn						(dataIn0),
				.intXNegEdge				(intXNegEdge0),
				.fifoEmptyQueueX			(fifoEmptyQueue0)
            );
	CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_int_0_ControllerFIFO # (
		.FIFO_WIDTH         (50), 
		.WATERMARK_DEPTH    (INT_0_QUEUE_DEPTH),
		.ECC				(ECC),
		.FAMILY				(FAMILY)
	) INT_0_FIFO (
		// Inputs
		.clock              (clock),
		.resetn             (resetn),
		.wrEn               (intValidQueue0),
		.wrData             (dataIn0),
		.rdEn               (fifordQueue0),
		// Outputs
		.rdData             (statusData0),
		.fifoFull           (), // Unused
		.wMarkFull          (fifoFullQueue0),
		.fifoEmpty          (fifoEmptyQueue0),
		
		.error_flag_sb_fifo (error_flag_sb_fifo0),
		.error_flag_db_fifo (error_flag_db_fifo0)
	);		
        end
endgenerate

////////////////////////////////////////////////////////////////////////////////
// Interrupt 1
////////////////////////////////////////////////////////////////////////////////
generate
    if (NUM_INT_1_BDS >= 1)
        begin
			wire fifordQueue1;
			wire error_flag_sb_fifo1;
			wire error_flag_db_fifo1;
			wire fifoEmptyQueue1;
			
            CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_interrupt_x_ctrl #(
                .INT_X_QUEUE_DEPTH          (INT_1_QUEUE_DEPTH),
				.ECC						(ECC),
				.FAMILY						(FAMILY),
				.AXI4_STREAM_IF            	(AXI4_STREAM_IF)				
				
            ) U_INT_1_QUEUE (
                // General inputs
                .clock                      (clock),
                .resetn                     (resetn),
                
                // AXISlaveCtrl inputs
                .ctrlSel                    (ctrlSelIntQueue[1]),
                .ctrlWr                     (ctrlWrIntQueue[1]),
                .ctrlAddr                   (ctrlAddr[3:2]),
                .ctrlWrData                 (ctrlWrData),
                .ctrlWrStrbs                (ctrlWrStrbs[0]),
                
                // AXIMasterCtrl inputs
                .valid                      (intValidQueue1),
                .opDone                     (opDone),
                .wrError                    (wrError),
                .rdError                    (rdError),
                .inValidDscrptr             (inValidDscrptr),
                .intDscrptrNum              (intDscrptrNumInt),
                .extDscrptr                 (extDscrptr),
                .extDscrptrAddr             (extDscrptrAddr),
                .strDscrptr                 (strDscrptr),
				
				.statusData					(statusData1),				
				.fifoEmptyQueueX			(fifoEmptyQueue1),					
				
				//ECC flags
				.error_flag_sb_fifo 		(error_flag_sb_fifo1),
				.error_flag_db_fifo 		(error_flag_db_fifo1),				
				.error_flag_db_bd_out		(error_flag_db_bd_out),
				.error_flag_sb_bd_out		(error_flag_sb_bd_out),
				.error_flag_db_cache		(error_flag_db_cache),
				.error_flag_sb_cache		(error_flag_sb_cache),
				.error_flag_db_intextdscrptr(error_flag_db_intextdscrptr),
				.error_flag_sb_intextdscrptr(error_flag_sb_intextdscrptr),
				.error_flag_sb_cache_str	(error_flag_sb_cache_str),
				.error_flag_db_cache_str	(error_flag_db_cache_str),
                
                // CtrlIFMuxCDC outputs
                .ctrlRdData                 (rdDataInt1),
                
                // DMAController outputs
                .fifoFullQueueX             (fifoFullQueue1),
                .fifordQueueX               (fifordQueue1),				
                
                // MasterController outputs
                .intX                       (int1),
				
	
				.dataIn						(dataIn1),
				.intXNegEdge				(intXNegEdge1)
			
            );
	CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_int_1_ControllerFIFO # (
		.FIFO_WIDTH         (50), 
		.WATERMARK_DEPTH    (INT_1_QUEUE_DEPTH),
		.ECC				(ECC),
		.FAMILY				(FAMILY)
	) INT_1_FIFO (
		// Inputs
		.clock              (clock),
		.resetn             (resetn),
		.wrEn               (intValidQueue1),
		.wrData             (dataIn1),
		.rdEn               (fifordQueue1),
		// Outputs
		.rdData             (statusData1),
		.fifoFull           (), // Unused
		.wMarkFull          (fifoFullQueue1),
		.fifoEmpty          (fifoEmptyQueue1),
		
		.error_flag_sb_fifo (error_flag_sb_fifo1),
		.error_flag_db_fifo (error_flag_db_fifo1)
	);				
        end
endgenerate

////////////////////////////////////////////////////////////////////////////////
// Interrupt 2
////////////////////////////////////////////////////////////////////////////////
generate
    if (NUM_INT_2_BDS >= 1)
        begin
			wire fifordQueue2;
			wire error_flag_sb_fifo2;
			wire error_flag_db_fifo2;			
			wire fifoEmptyQueue2;
			
            CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_interrupt_x_ctrl #(
                .INT_X_QUEUE_DEPTH          (INT_2_QUEUE_DEPTH),
				.ECC						(ECC),
				.FAMILY						(FAMILY),
				.AXI4_STREAM_IF            	(AXI4_STREAM_IF)				
				
            ) U_INT_2_QUEUE (
                // General inputs
                .clock                      (clock),
                .resetn                     (resetn),
                
                // AXISlaveCtrl inputs
                .ctrlSel                    (ctrlSelIntQueue[2]),
                .ctrlWr                     (ctrlWrIntQueue[2]),
                .ctrlAddr                   (ctrlAddr[3:2]),
                .ctrlWrData                 (ctrlWrData),
                .ctrlWrStrbs                (ctrlWrStrbs[0]),
                
                // AXIMasterCtrl inputs
                .valid                      (intValidQueue2),
                .opDone                     (opDone),
                .wrError                    (wrError),
                .rdError                    (rdError),
                .inValidDscrptr             (inValidDscrptr),
                .intDscrptrNum              (intDscrptrNumInt),
                .extDscrptr                 (extDscrptr),
                .extDscrptrAddr             (extDscrptrAddr),
                .strDscrptr                 (strDscrptr),
				
				//ECC flags
				.error_flag_sb_fifo 		(error_flag_sb_fifo2),
				.error_flag_db_fifo 		(error_flag_db_fifo2),				
				.error_flag_db_bd_out		(error_flag_db_bd_out),
				.error_flag_sb_bd_out		(error_flag_sb_bd_out),
				.error_flag_db_cache		(error_flag_db_cache),
				.error_flag_sb_cache		(error_flag_sb_cache),
				.error_flag_db_intextdscrptr(error_flag_db_intextdscrptr),
				.error_flag_sb_intextdscrptr(error_flag_sb_intextdscrptr),
				.error_flag_sb_cache_str	(error_flag_sb_cache_str),
				.error_flag_db_cache_str	(error_flag_db_cache_str),
                
                // CtrlIFMuxCDC outputs
                .ctrlRdData                 (rdDataInt2),
                
                // DMAController outputs
                .fifoFullQueueX             (fifoFullQueue2),
                .fifordQueueX               (fifordQueue2),					
                
                // MasterController outputs
                .intX                       (int2),
				
				.statusData					(statusData2),
				.dataIn						(dataIn2),
				.intXNegEdge				(intXNegEdge2),
				.fifoEmptyQueueX			(fifoEmptyQueue2)				
            );
	CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_int_2_ControllerFIFO # (
		.FIFO_WIDTH         (50), 
		.WATERMARK_DEPTH    (INT_2_QUEUE_DEPTH),
		.ECC				(ECC),
		.FAMILY				(FAMILY)
	) INT_2_FIFO (
		// Inputs
		.clock              (clock),
		.resetn             (resetn),
		.wrEn               (intValidQueue2),
		.wrData             (dataIn2),
		.rdEn               (fifordQueue2),
		// Outputs
		.rdData             (statusData2),
		.fifoFull           (), // Unused
		.wMarkFull          (fifoFullQueue2),
		.fifoEmpty          (fifoEmptyQueue2),
		
		.error_flag_sb_fifo (error_flag_sb_fifo2),
		.error_flag_db_fifo (error_flag_db_fifo2)
	);				
        end
endgenerate

////////////////////////////////////////////////////////////////////////////////
// Interrupt 3
////////////////////////////////////////////////////////////////////////////////
generate
    if (NUM_INT_3_BDS >= 1)
        begin
			wire fifordQueue3;
			wire error_flag_sb_fifo3;
			wire error_flag_db_fifo3;
			wire fifoEmptyQueue3;
			
            CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_interrupt_x_ctrl #(
                .INT_X_QUEUE_DEPTH          (INT_3_QUEUE_DEPTH),
				.ECC						(ECC),
				.FAMILY						(FAMILY),
				.AXI4_STREAM_IF            	(AXI4_STREAM_IF)				
            ) U_INT_3_QUEUE (
                // General inputs
                .clock                      (clock),
                .resetn                     (resetn),
                
                // AXISlaveCtrl inputs
                .ctrlSel                    (ctrlSelIntQueue[3]),
                .ctrlWr                     (ctrlWrIntQueue[3]),
                .ctrlAddr                   (ctrlAddr[3:2]),
                .ctrlWrData                 (ctrlWrData),
                .ctrlWrStrbs                (ctrlWrStrbs[0]),
                
                // AXIMasterCtrl inputs
                .valid                      (intValidQueue3),
                .opDone                     (opDone),
                .wrError                    (wrError),
                .rdError                    (rdError),
                .inValidDscrptr             (inValidDscrptr),
                .intDscrptrNum              (intDscrptrNumInt),
                .extDscrptr                 (extDscrptr),
                .extDscrptrAddr             (extDscrptrAddr),
                .strDscrptr                 (strDscrptr),
				
				
				//ECC flags
				.error_flag_sb_fifo 		(error_flag_sb_fifo3),
				.error_flag_db_fifo 		(error_flag_db_fifo3),				
				.error_flag_db_bd_out		(error_flag_db_bd_out),
				.error_flag_sb_bd_out		(error_flag_sb_bd_out),
				.error_flag_db_cache		(error_flag_db_cache),
				.error_flag_sb_cache		(error_flag_sb_cache),
				.error_flag_db_intextdscrptr(error_flag_db_intextdscrptr),
				.error_flag_sb_intextdscrptr(error_flag_sb_intextdscrptr),
				.error_flag_sb_cache_str	(error_flag_sb_cache_str),
				.error_flag_db_cache_str	(error_flag_db_cache_str),
                
                // CtrlIFMuxCDC outputs
                .ctrlRdData                 (rdDataInt3),
                
                // DMAController outputs
                .fifoFullQueueX             (fifoFullQueue3),
                .fifordQueueX               (fifordQueue3),					
                
                // MasterController outputs
                .intX                       (int3),
				
				.statusData					(statusData3),
				.dataIn						(dataIn3),
				.intXNegEdge				(intXNegEdge3),
				.fifoEmptyQueueX			(fifoEmptyQueue3)				
            );
	CoreDMA_Controller_CoreDMA_Controller_0_CoreAXI4DMAController_int_3_ControllerFIFO # (
		.FIFO_WIDTH         (50), 
		.WATERMARK_DEPTH    (INT_3_QUEUE_DEPTH),
		.ECC				(ECC),
		.FAMILY				(FAMILY)
	) INT_3_FIFO (
		// Inputs
		.clock              (clock),
		.resetn             (resetn),
		.wrEn               (intValidQueue3),
		.wrData             (dataIn3),
		.rdEn               (fifordQueue3),
		// Outputs
		.rdData             (statusData3),
		.fifoFull           (), // Unused
		.wMarkFull          (fifoFullQueue3),
		.fifoEmpty          (fifoEmptyQueue3),
		
		.error_flag_sb_fifo (error_flag_sb_fifo3),
		.error_flag_db_fifo (error_flag_db_fifo3)
	);				
        end
endgenerate

endmodule