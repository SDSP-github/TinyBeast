// ****************************************************************************/
// Microsemi Corporation Proprietary and Confidential
// Copyright 2015 Microsemi Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// Description: 
//
// SVN Revision Information:
// SVN $Revision: 37490 $
// SVN $Date: 2021-01-13 16:43:57 +0530 (Wed, 13 Jan 2021) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//       SAR#82615 - Added support for 32-bit AXI data width
//       SAR108962 - Added support for 32-bit AXI interface 
// ****************************************************************************/
module AXItoAHBL_AXItoAHBL_0_COREAXITOAHBL (
                        // AXIMaster inputs
                        ACLK,
                        ARESETN,
                        AWVALID,
                        AWLEN,
                        AWSIZE,
                        AWBURST,
                        AWID,
                        AWADDR,
                        WVALID,
                        WDATA,
                        WSTRB,
                        WLAST,
                        WID,
                        WID_BIF,
                        BREADY,
                        ARVALID,
                        RREADY,
                        ARADDR,
                        ARSIZE,
                        ARID,
                        ARLEN,
                        ARBURST,
                        
                        // AHB Slave inputs
                        HCLK,
                        HRESETN,
                        HREADYIN,
                        HRESP,
                        HRDATA,
                        
                        // AXIMaster outputs
                        BRESP,
                        BID,
                        BVALID,
                        AWREADY,
                        WREADY,
                        ARREADY,
                        RVALID,
                        RLAST,
                        RID,
                        RDATA,
                        RRESP,
                        
                        // AHB Slave outputs
						HSEL,
                        HWRITE,
                        HSIZE,
                        HWDATA,
                        HADDR,
                        HTRANS,
                        HBURST
                     );

////////////////////////////////////////////////////////////////////////////////
// User modifiable parameters
////////////////////////////////////////////////////////////////////////////////
parameter ID_WIDTH = 4;       // Sets the width of the ID field supported.
parameter AXI_DWIDTH = 64;    // Sets the AXI interface data width - 32/64.
parameter WRAP_SUPPORT = 0;   // Enables the core to handle AXI wrapping burst
                              // transactions. Wrapping burst transactions are
                              // disabled by default.
parameter NO_BURST_TRANS = 0; // Prevents AHB-Lite burst transfers being generated
                              // when equal to 1. Burst transfers are enabled
                              // by default.
parameter ASYNC_CLOCKS = 0;   // Parameter should be set if clock domains are
                              // asynchronous. Instantiates CDC synchronizers
                              // in the design.
parameter RAM_TYPE = 2;       // Sets RAM type inferred 
                              // 0 - Registers
                              // 1 - LSRAM
                              // 2 - uSRAM
parameter AXI_INTERFACE = 0;  // To select between AXI3 or AXI4 interface
                              // 0 - AXI3 Interface
                              // 1 - AXI4 Interface
parameter AXI_SEL_MM_S = 0;   // To select between AXI Mirror Master BIF or
                              // AXI Slave BIF for the AXI IF of the core in SD
                              // 0 - AXI Slave BIF
                              // 1 - AXI Mirror Master BIF
parameter EXPOSE_WID = 0;     // Expose WID outside Bus IF in AXI Slave BIF
                              // Valid when AXI_SEL_MM_S = 0
parameter AHBL_SEL_MS_M = 0;  // To select between AHB Mirror Slave BIF or AHB
                              // Master BIF for the AHBL IF of the core in SD
                              // 0 - AHB Master BIF
                              // 1 - AHB Mirror Slave BIF

////////////////////////////////////////////////////////////////////////////////
// Local parameters
////////////////////////////////////////////////////////////////////////////////
// Ensure that the minimum number of register stages instantiated is 2 if the 
// clock domains are asynchronous.
localparam NO_OF_REG_STAGES = 2;

// AXI Burst Length signal width depending on AXI interface - 4 or 8
localparam AXI_LWIDTH = (AXI_INTERFACE + 1) * 4;

// AXI Strobe Width depending on AXI data width - 4 or 8
localparam AXI_STRBWIDTH = AXI_DWIDTH / 8; 

////////////////////////////////////////////////////////////////////////////////
// Input and Output Ports
////////////////////////////////////////////////////////////////////////////////
                            // AXIMaster inputs
input                       ACLK;
input                       ARESETN;
input                       AWVALID;
input   [AXI_LWIDTH-1:0]    AWLEN;
input   [2:0]               AWSIZE;
input   [1:0]               AWBURST;
input   [ID_WIDTH-1:0]      AWID;
input   [31:0]              AWADDR;
input                       WVALID;
input   [AXI_DWIDTH-1:0]    WDATA;
input   [AXI_STRBWIDTH-1:0] WSTRB;
input                       WLAST;
input   [ID_WIDTH-1:0]      WID;     // Unconnected. Outstanding transactions unsupported
input   [ID_WIDTH-1:0]      WID_BIF; // Unconnected. Outstanding transactions unsupported
input                       BREADY;
input                       ARVALID;
input                       RREADY;
input   [31:0]              ARADDR;
input   [2:0]               ARSIZE;
input   [ID_WIDTH-1:0]      ARID;
input   [AXI_LWIDTH-1:0]    ARLEN;
input   [1:0]               ARBURST;
                          
                            // AHB Slave inputs
input                       HCLK;
input                       HRESETN;
input                       HREADYIN;
input                       HRESP;
input   [31:0]              HRDATA;
                          
                            // AXIMaster outputs
output  [1:0]               BRESP;
output  [ID_WIDTH-1:0]      BID;
output                      BVALID;
output                      AWREADY;
output                      WREADY;
output                      ARREADY;
output                      RVALID;
output                      RLAST;
output  [ID_WIDTH-1:0]      RID;
output  [AXI_DWIDTH-1:0]    RDATA;
output  [1:0]               RRESP;

                            // AXI Slave outputs
output                      HSEL;
output                      HWRITE;
output  [2:0]               HSIZE;
output  [31:0]              HWDATA;
output  [31:0]              HADDR;
output  [1:0]               HTRANS;
output  [2:0]               HBURST;

////////////////////////////////////////////////////////////////////////////////
// Internal signal declarations
////////////////////////////////////////////////////////////////////////////////
wire                  AHBError;
wire                  AHBWrDone;
wire                  AHBWrDone_sync;
wire                  AHBRdDone;
wire                  AHBRdDone_sync;
                    
wire                  AWREADYOut;
wire                  WREADYOut;
wire                  BVALIDOut;
wire [1:0]            BRESPOut;
wire [ID_WIDTH-1:0]   BIDOut;
wire                  ARREADYOut;
wire                  RVALIDOut;
wire                  RLASTOut;
wire [AXI_DWIDTH-1:0] RDATAOut;
wire [ID_WIDTH-1:0]   RIDOut;
wire [1:0]            RRESPOut;

wire                  wrFIFOWrEn;
wire [AXI_LWIDTH-1:0] wrFIFOWrAddr;
wire [AXI_DWIDTH-1:0] wrFIFOWrData;
wire                  rdFIFOWrEn;
wire [AXI_LWIDTH-1:0] rdFIFOWrAddr;
wire [AXI_DWIDTH-1:0] rdFIFOWrData;

wire [1:0]            AXIBurst;
wire [3:0]            AXILen;
wire [31:0]           AXIAddr;
wire [2:0]            AXISize;  

wire                  AHBWrTranPend;
wire                  AHBWrTranPend_sync;
wire                  AHBRdTranPend;
wire                  AHBRdTranPend_sync;
wire [11:0]           validByteCnt;

wire [AXI_LWIDTH-1:0] wrFIFORdAddr;
wire [AXI_LWIDTH-1:0] wrFIFORdAddr_q;
wire [AXI_DWIDTH-1:0] wrFIFORdData;
wire [AXI_LWIDTH-1:0] rdFIFORdAddr;
wire [AXI_LWIDTH-1:0] rdFIFORdAddr_q;
wire [AXI_DWIDTH-1:0] rdFIFORdData;

// Burst length signal to pass to the AXI slave control block
wire [7:0]            AWLEN_int;
wire [7:0]            ARLEN_int;

////////////////////////////////////////////////////////////////////////////////
// COREAXITOAHBL_AXISlaveCtrl component instantiation
////////////////////////////////////////////////////////////////////////////////
COREAXITOAHBL_AXISlaveCtrl # (
                    .ID_WIDTH                   (ID_WIDTH),
                    .AXI_LWIDTH                 (AXI_LWIDTH),
                    .AXI_DWIDTH                 (AXI_DWIDTH),    
                    .AXI_STRBWIDTH              (AXI_STRBWIDTH), 
                    .WRAP_SUPPORT               (WRAP_SUPPORT)
)                    
                    U_AXISlaveCtrl (
                    // Global Inputs
                    .ACLK                       (ACLK),
                    .ARESETN                    (ARESETN),

                    // AXIOutReg Inputs
                    .AWREADY                    (AWREADY),
                    .WREADY                     (WREADY),
                    .BVALID                     (BVALID),
                    .ARREADY                    (ARREADY),
                    .RVALID                     (RVALID),

                    // AXI master inputs 
                    .AWVALID                    (AWVALID),
                    .WVALID                     (WVALID),
                    .BREADY                     (BREADY),
                    .AWADDR                     (AWADDR),
                    .AWSIZE                     (AWSIZE),
                    .AWLEN                      (AWLEN_int),
                    .AWBURST                    (AWBURST),
                    .AWID                       (AWID),
                    .WDATA                      (WDATA),
                    .WSTRB                      (WSTRB),
                    .WLAST                      (WLAST),
                    .ARVALID                    (ARVALID),
                    .RREADY                     (RREADY),
                    .ARADDR                     (ARADDR),
                    .ARSIZE                     (ARSIZE),
                    .ARID                       (ARID),
                    .ARLEN                      (ARLEN_int),
                    .ARBURST                    (ARBURST),
                    
                    // AHBMasterCtrl Inputs
                    .AHBError                   (AHBError),
                    .AHBWrDone                  (AHBWrDone_sync),
                    .AHBRdDone                  (AHBRdDone_sync),
                    
                    // rdFIFORAM Inputs
                    .rdFIFORdAddr_q             (rdFIFORdAddr_q),
                    .rdFIFORdData               (rdFIFORdData),
                    
                    // AXIOutReg Outputs
                    .AWREADYOut                 (AWREADYOut),
                    .WREADYOut                  (WREADYOut),
                    .BVALIDOut                  (BVALIDOut),
                    .BRESPOut                   (BRESPOut),
                    .BIDOut                     (BIDOut),
                    .ARREADYOut                 (ARREADYOut),
                    .RVALIDOut                  (RVALIDOut),
                    .RLASTOut                   (RLASTOut),
                    .RDATAOut                   (RDATAOut),
                    .RIDOut                     (RIDOut),
                    .RRESPOut                   (RRESPOut),
                    
                    // wrFIFORAM Outputs
                    .wrFIFOWrEn                 (wrFIFOWrEn),
                    .wrFIFOWrAddr               (wrFIFOWrAddr),
                    .wrFIFOWrData               (wrFIFOWrData),
                    
                    // rdFIFORAM Outputs
                    .rdFIFORdAddr               (rdFIFORdAddr),
                    
                    // AHBMasterCtrl Outputs
                    .AXIBurst                   (AXIBurst),
                    .AXIAddr                    (AXIAddr),
                    .AXILen                     (AXILen),
                    .AXISize                    (AXISize),  
                    .AHBWrTranPend              (AHBWrTranPend),
                    .AHBRdTranPend              (AHBRdTranPend),
                    .validByteCnt               (validByteCnt)
);

assign AWLEN_int = AXI_INTERFACE ? AWLEN : {4'b0, AWLEN[3:0]};
assign ARLEN_int = AXI_INTERFACE ? ARLEN : {4'b0, ARLEN[3:0]};

////////////////////////////////////////////////////////////////////////////////
// COREAXITOAHBL_AXIOutReg component instantiation
////////////////////////////////////////////////////////////////////////////////
COREAXITOAHBL_AXIOutReg # (
                    .AXI_DWIDTH                 (AXI_DWIDTH),    
                    .AXI_STRBWIDTH              (AXI_STRBWIDTH), 
                    .ID_WIDTH                   (ID_WIDTH)
)
                    U_AXIOutReg (
                    // Global inputs,
                    .ACLK                       (ACLK),
                    .ARESETN                    (ARESETN),

                    // AXISlaveCtrl inputs
                    .BRESPOut                   (BRESPOut),
                    .BIDOut                     (BIDOut),
                    .AWREADYOut                 (AWREADYOut),
                    .WREADYOut                  (WREADYOut),
                    .BVALIDOut                  (BVALIDOut),
                    .ARREADYOut                 (ARREADYOut),
                    .RVALIDOut                  (RVALIDOut),
                    .RLASTOut                   (RLASTOut),
                    .RDATAOut                   (RDATAOut),
                    .RIDOut                     (RIDOut),
                    .RRESPOut                   (RRESPOut),

                    // AXIMaster outputs
                    .BRESP                      (BRESP),
                    .BID                        (BID),
                    .AWREADY                    (AWREADY),
                    .WREADY                     (WREADY),
                    .BVALID                     (BVALID),
                    .ARREADY                    (ARREADY),
                    .RVALID                     (RVALID),
                    .RLAST                      (RLAST),
                    .RDATA                      (RDATA),
                    .RID                        (RID),
                    .RRESP                      (RRESP)
);

////////////////////////////////////////////////////////////////////////////////
// RAM_TYPE = 0, infer RAM blocks using registers (sequential elements/DFF)
////////////////////////////////////////////////////////////////////////////////
generate if (RAM_TYPE == 0)
begin : INFER_REGISTERS
    COREAXITOAHBL_RAM_infer_registers # (
                        .AXI_LWIDTH                 (AXI_LWIDTH),
                        .AXI_DWIDTH                 (AXI_DWIDTH)
    ) U_wrFIFORAM (
                        // Inputs
                        .rdCLK                      (HCLK),
                        .wrCLK                      (ACLK),
                        .RESETN                     (ARESETN),
                        .wrEn                       (wrFIFOWrEn),
                        .wrAddr                     (wrFIFOWrAddr),
                        .wrData                     (wrFIFOWrData),
                        .rdAddr                     (wrFIFORdAddr),
    
                        // Outputs
                        .rdAddr_q                   (wrFIFORdAddr_q),
                        .rdData                     (wrFIFORdData)
    );
    
    COREAXITOAHBL_RAM_infer_registers # (
                        .AXI_LWIDTH                 (AXI_LWIDTH),
                        .AXI_DWIDTH                 (AXI_DWIDTH)
    ) U_rdFIFORAM (
                        // Inputs
                        .rdCLK                      (ACLK),
                        .wrCLK                      (HCLK),
                        .RESETN                     (HRESETN),
                        .wrEn                       (rdFIFOWrEn),
                        .wrAddr                     (rdFIFOWrAddr),
                        .wrData                     (rdFIFOWrData),
                        .rdAddr                     (rdFIFORdAddr),
    
                        // Outputs
                        .rdAddr_q                   (rdFIFORdAddr_q),
                        .rdData                     (rdFIFORdData)
    );
end
endgenerate

////////////////////////////////////////////////////////////////////////////////
// RAM_TYPE = 1, infer LSRAM 
////////////////////////////////////////////////////////////////////////////////
generate if (RAM_TYPE == 1)
begin : INFER_LSRAM
    COREAXITOAHBL_RAM_infer_LSRAM # (
                        .AXI_LWIDTH                 (AXI_LWIDTH),
                        .AXI_DWIDTH                 (AXI_DWIDTH)
    ) U_wrFIFORAM (
                        // Inputs
                        .rdCLK                      (HCLK),
                        .wrCLK                      (ACLK),
                        .RESETN                     (ARESETN),
                        .wrEn                       (wrFIFOWrEn),
                        .wrAddr                     (wrFIFOWrAddr),
                        .wrData                     (wrFIFOWrData),
                        .rdAddr                     (wrFIFORdAddr),
    
                        // Outputs
                        .rdAddr_q                   (wrFIFORdAddr_q),
                        .rdData                     (wrFIFORdData)
    );
    
    COREAXITOAHBL_RAM_infer_LSRAM # (
                        .AXI_LWIDTH                 (AXI_LWIDTH),
                        .AXI_DWIDTH                 (AXI_DWIDTH)
    ) U_rdFIFORAM (
                        // Inputs
                        .rdCLK                      (ACLK),
                        .wrCLK                      (HCLK),
                        .RESETN                     (HRESETN),
                        .wrEn                       (rdFIFOWrEn),
                        .wrAddr                     (rdFIFOWrAddr),
                        .wrData                     (rdFIFOWrData),
                        .rdAddr                     (rdFIFORdAddr),
    
                        // Outputs
                        .rdAddr_q                   (rdFIFORdAddr_q),
                        .rdData                     (rdFIFORdData)
    );
end
endgenerate

////////////////////////////////////////////////////////////////////////////////
// RAM_TYPE = 2, infer uSRAM 
////////////////////////////////////////////////////////////////////////////////
generate if (RAM_TYPE == 2)
begin : INFER_USRAM
    COREAXITOAHBL_RAM_infer_uSRAM # (
                        .AXI_LWIDTH                 (AXI_LWIDTH),
                        .AXI_DWIDTH                 (AXI_DWIDTH)
    ) U_wrFIFORAM (
                        // Inputs
                        .rdCLK                      (HCLK),
                        .wrCLK                      (ACLK),
                        .RESETN                     (ARESETN),
                        .wrEn                       (wrFIFOWrEn),
                        .wrAddr                     (wrFIFOWrAddr),
                        .wrData                     (wrFIFOWrData),
                        .rdAddr                     (wrFIFORdAddr),
    
                        // Outputs
                        .rdAddr_q                   (wrFIFORdAddr_q),
                        .rdData                     (wrFIFORdData)
    );
    
    COREAXITOAHBL_RAM_infer_uSRAM # (
                        .AXI_LWIDTH                 (AXI_LWIDTH),
                        .AXI_DWIDTH                 (AXI_DWIDTH)
    ) U_rdFIFORAM (
                        // Inputs
                        .rdCLK                      (ACLK),
                        .wrCLK                      (HCLK),
                        .RESETN                     (HRESETN),
                        .wrEn                       (rdFIFOWrEn),
                        .wrAddr                     (rdFIFOWrAddr),
                        .wrData                     (rdFIFOWrData),
                        .rdAddr                     (rdFIFORdAddr),
    
                        // Outputs
                        .rdAddr_q                   (rdFIFORdAddr_q),
                        .rdData                     (rdFIFORdData)
    );
end
endgenerate

////////////////////////////////////////////////////////////////////////////////
// COREAXITOAHBL_synchronizer component instantiations
////////////////////////////////////////////////////////////////////////////////
generate if (ASYNC_CLOCKS == 1)
begin : CLOCKS_ASYNCHRONOUS
    // Include asynchronous synchronizers on the toggle signals between the 
    // two clock domains
    COREAXITOAHBL_synchronizer # (
                .NO_OF_REG_STAGES           (NO_OF_REG_STAGES)
    ) U_AHBWrTranPend_Synchronizer(
                .CLK                        (HCLK),
                .RESETn                     (HRESETN),
                .asyncInput                 (AHBWrTranPend),
                .syncOutput                 (AHBWrTranPend_sync)
    );
    
    COREAXITOAHBL_synchronizer # (
                .NO_OF_REG_STAGES           (NO_OF_REG_STAGES)
    ) U_AHBRdTranPend_Synchronizer(
                .CLK                        (HCLK),
                .RESETn                     (HRESETN),
                .asyncInput                 (AHBRdTranPend),
                .syncOutput                 (AHBRdTranPend_sync)
    );
    COREAXITOAHBL_synchronizer # (
                .NO_OF_REG_STAGES           (NO_OF_REG_STAGES)
    ) U_AHBWrTranDone_Synchronizer(
                .CLK                        (ACLK),
                .RESETn                     (ARESETN),
                .asyncInput                 (AHBWrDone),
                .syncOutput                 (AHBWrDone_sync)
    );
    
    COREAXITOAHBL_synchronizer # (
                .NO_OF_REG_STAGES           (NO_OF_REG_STAGES)
    ) U_AHBRdTranDone_Synchronizer(
                .CLK                        (ACLK),
                .RESETn                     (ARESETN),
                .asyncInput                 (AHBRdDone),
                .syncOutput                 (AHBRdDone_sync)
    );
end
endgenerate

generate if (ASYNC_CLOCKS == 0)
begin : CLOCKS_SYNCHRONOUS
    // Clock domains are synhchronous so remove the synchronizer stages to 
    // reduce latency
    assign AHBWrTranPend_sync = AHBWrTranPend;
    assign AHBRdTranPend_sync = AHBRdTranPend;
    assign AHBWrDone_sync = AHBWrDone;
    assign AHBRdDone_sync = AHBRdDone;
end
endgenerate

////////////////////////////////////////////////////////////////////////////////
// COREAXITOAHBL_AHBMasterCtrl component instantiation
////////////////////////////////////////////////////////////////////////////////
COREAXITOAHBL_AHBMasterCtrl # (
                    .AXI_LWIDTH                 (AXI_LWIDTH),
                    .AXI_DWIDTH                 (AXI_DWIDTH),    
                    .AXI_STRBWIDTH              (AXI_STRBWIDTH), 
                    .WRAP_SUPPORT               (WRAP_SUPPORT),
                    .NO_BURST_TRANS             (NO_BURST_TRANS),
                    .AXI_INTERFACE              (AXI_INTERFACE)
)
                    U_AHBMasterCtrl (
                    // Global inputs
                    .HCLK                       (HCLK),                         
                    .HRESETN                    (HRESETN),

                    // AXISlaveCtrl inputs
                    .AHBWrTranPend              (AHBWrTranPend_sync),
                    .AHBRdTranPend              (AHBRdTranPend_sync),
                    .validByteCnt               (validByteCnt),
                    .AXIAddr                    (AXIAddr),
                    .AXIBurst                   (AXIBurst),
                    .AXILen                     (AXILen),
                    .AXISize                    (AXISize),  
                    // AHB Slave inputs
                    .HREADYIN                   (HREADYIN),
                    .HRDATA                     (HRDATA),
                    .HRESP                      (HRESP),

                    // wrFIFO inputs
                    .wrFIFORdAddr_q             (wrFIFORdAddr_q),
                    .wrFIFORdData               (wrFIFORdData),

                    // AHB Slave outputs
                    .HSEL                       (HSEL),
                    .HWRITE                     (HWRITE),
                    .HSIZE                      (HSIZE),
                    .HWDATA                     (HWDATA),
                    .HADDR                      (HADDR),
                    .HTRANS                     (HTRANS),
                    .HBURST                     (HBURST),

                    // AXI SlaveCtrl outputs
                    .AHBWrDone                  (AHBWrDone),
                    .AHBRdDone                  (AHBRdDone),
                    .AHBError                   (AHBError),

                    // wrFIFO outputs
                    .wrFIFORdAddr               (wrFIFORdAddr),
                    
                    // rdFIFORAM outputs
                    .rdFIFOWrEn                 (rdFIFOWrEn),
                    .rdFIFOWrAddr               (rdFIFOWrAddr),
                    .rdFIFOWrData               (rdFIFOWrData)
);

endmodule // COREAXITOAHBL
