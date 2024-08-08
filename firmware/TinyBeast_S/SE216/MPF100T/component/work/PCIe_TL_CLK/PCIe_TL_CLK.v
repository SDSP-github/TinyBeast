//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Wed Jul 21 07:10:07 2021
// Version: v12.6 12.900.20.24
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

// PCIe_TL_CLK
module PCIe_TL_CLK(
    // Inputs
    CLK_125MHz,
    // Outputs
    BANK0_1_4_CALIB_DONE,
    BANK_4_VDDI_STATUS,
    CLK_160MHZ,
    DEVICE_INIT_DONE,
    FABRIC_POR_N,
    TL_CLK
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input  CLK_125MHz;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output BANK0_1_4_CALIB_DONE;
output BANK_4_VDDI_STATUS;
output CLK_160MHZ;
output DEVICE_INIT_DONE;
output FABRIC_POR_N;
output TL_CLK;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire   BANK0_1_4_CALIB_DONE_net_0;
wire   BANK_4_VDDI_STATUS_net_0;
wire   CLK_125MHz;
wire   CLK_160MHZ_net_0;
wire   CLK_DIV2_0_CLK_OUT;
wire   DEVICE_INIT_DONE_net_0;
wire   FABRIC_POR_N_net_0;
wire   OSC_160MHz_0_RCOSC_160MHZ_CLK_DIV;
wire   PCIe_INIT_MONITOR_0_BANK_0_CALIB_STATUS;
wire   PCIe_INIT_MONITOR_0_BANK_1_CALIB_STATUS;
wire   PCIe_INIT_MONITOR_0_PCIE_INIT_DONE;
wire   TL_CLK_net_0;
wire   DEVICE_INIT_DONE_net_1;
wire   TL_CLK_net_1;
wire   FABRIC_POR_N_net_1;
wire   BANK_4_VDDI_STATUS_net_1;
wire   BANK0_1_4_CALIB_DONE_net_1;
wire   CLK_160MHZ_net_1;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign DEVICE_INIT_DONE_net_1     = DEVICE_INIT_DONE_net_0;
assign DEVICE_INIT_DONE           = DEVICE_INIT_DONE_net_1;
assign TL_CLK_net_1               = TL_CLK_net_0;
assign TL_CLK                     = TL_CLK_net_1;
assign FABRIC_POR_N_net_1         = FABRIC_POR_N_net_0;
assign FABRIC_POR_N               = FABRIC_POR_N_net_1;
assign BANK_4_VDDI_STATUS_net_1   = BANK_4_VDDI_STATUS_net_0;
assign BANK_4_VDDI_STATUS         = BANK_4_VDDI_STATUS_net_1;
assign BANK0_1_4_CALIB_DONE_net_1 = BANK0_1_4_CALIB_DONE_net_0;
assign BANK0_1_4_CALIB_DONE       = BANK0_1_4_CALIB_DONE_net_1;
assign CLK_160MHZ_net_1           = CLK_160MHZ_net_0;
assign CLK_160MHZ                 = CLK_160MHZ_net_1;
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------AND2
AND2 AND2_0(
        // Inputs
        .A ( PCIe_INIT_MONITOR_0_BANK_0_CALIB_STATUS ),
        .B ( PCIe_INIT_MONITOR_0_BANK_1_CALIB_STATUS ),
        // Outputs
        .Y ( BANK0_1_4_CALIB_DONE_net_0 ) 
        );

//--------CLK_DIV2
CLK_DIV2 CLK_DIV2_0(
        // Inputs
        .CLK_IN  ( OSC_160MHz_0_RCOSC_160MHZ_CLK_DIV ),
        // Outputs
        .CLK_OUT ( CLK_DIV2_0_CLK_OUT ) 
        );

//--------NGMUX
NGMUX NGMUX_0(
        // Inputs
        .CLK0    ( CLK_DIV2_0_CLK_OUT ),
        .CLK1    ( CLK_125MHz ),
        .SEL     ( PCIe_INIT_MONITOR_0_PCIE_INIT_DONE ),
        // Outputs
        .CLK_OUT ( TL_CLK_net_0 ) 
        );

//--------OSC_160MHz
OSC_160MHz OSC_160MHz_0(
        // Outputs
        .RCOSC_160MHZ_CLK_DIV ( OSC_160MHz_0_RCOSC_160MHZ_CLK_DIV ),
        .RCOSC_160MHZ_GL      ( CLK_160MHZ_net_0 ) 
        );

//--------PCIe_INIT_MONITOR
PCIe_INIT_MONITOR PCIe_INIT_MONITOR_0(
        // Outputs
        .FABRIC_POR_N               ( FABRIC_POR_N_net_0 ),
        .PCIE_INIT_DONE             ( PCIe_INIT_MONITOR_0_PCIE_INIT_DONE ),
        .USRAM_INIT_DONE            (  ),
        .SRAM_INIT_DONE             (  ),
        .DEVICE_INIT_DONE           ( DEVICE_INIT_DONE_net_0 ),
        .XCVR_INIT_DONE             (  ),
        .USRAM_INIT_FROM_SNVM_DONE  (  ),
        .USRAM_INIT_FROM_UPROM_DONE (  ),
        .USRAM_INIT_FROM_SPI_DONE   (  ),
        .SRAM_INIT_FROM_SNVM_DONE   (  ),
        .SRAM_INIT_FROM_UPROM_DONE  (  ),
        .SRAM_INIT_FROM_SPI_DONE    (  ),
        .AUTOCALIB_DONE             (  ),
        .BANK_0_CALIB_STATUS        ( PCIe_INIT_MONITOR_0_BANK_0_CALIB_STATUS ),
        .BANK_1_CALIB_STATUS        ( PCIe_INIT_MONITOR_0_BANK_1_CALIB_STATUS ),
        .BANK_4_VDDI_STATUS         ( BANK_4_VDDI_STATUS_net_0 ) 
        );


endmodule
