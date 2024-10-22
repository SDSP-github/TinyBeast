//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Thu Feb  4 21:03:06 2021
// Version: v12.6 12.900.20.24
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////
// Component Description (Tcl) 
//////////////////////////////////////////////////////////////////////
/*
# Exporting Component Description of AHBtoAPB to TCL
# Family: PolarFire
# Part Number: MPF300TS-1FCG1152I
# Create and Configure the core component AHBtoAPB
create_and_configure_core -core_vlnv {Actel:DirectCore:COREAHBTOAPB3:3.2.101} -component_name {AHBtoAPB} -params { }
# Exporting Component Description of AHBtoAPB to TCL done
*/

// AHBtoAPB
module AHBtoAPB(
    // Inputs
    HADDR,
    HCLK,
    HREADY,
    HRESETN,
    HSEL,
    HTRANS,
    HWDATA,
    HWRITE,
    PRDATA,
    PREADY,
    PSLVERR,
    // Outputs
    HRDATA,
    HREADYOUT,
    HRESP,
    PADDR,
    PENABLE,
    PSEL,
    PWDATA,
    PWRITE
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input  [31:0] HADDR;
input         HCLK;
input         HREADY;
input         HRESETN;
input         HSEL;
input  [1:0]  HTRANS;
input  [31:0] HWDATA;
input         HWRITE;
input  [31:0] PRDATA;
input         PREADY;
input         PSLVERR;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output [31:0] HRDATA;
output        HREADYOUT;
output [1:0]  HRESP;
output [31:0] PADDR;
output        PENABLE;
output        PSEL;
output [31:0] PWDATA;
output        PWRITE;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire   [31:0] HADDR;
wire   [31:0] AHBslave_HRDATA;
wire          HREADY;
wire          AHBslave_HREADYOUT;
wire   [1:0]  AHBslave_HRESP;
wire          HSEL;
wire   [1:0]  HTRANS;
wire   [31:0] HWDATA;
wire          HWRITE;
wire   [31:0] APBmaster_0_PADDR;
wire          APBmaster_0_PENABLE;
wire   [31:0] PRDATA;
wire          PREADY;
wire          APBmaster_0_PSELx;
wire          PSLVERR;
wire   [31:0] APBmaster_0_PWDATA;
wire          APBmaster_0_PWRITE;
wire          HCLK;
wire          HRESETN;
wire          AHBslave_HREADYOUT_net_0;
wire          APBmaster_0_PSELx_net_0;
wire          APBmaster_0_PENABLE_net_0;
wire          APBmaster_0_PWRITE_net_0;
wire   [31:0] AHBslave_HRDATA_net_0;
wire   [1:0]  AHBslave_HRESP_net_0;
wire   [31:0] APBmaster_0_PADDR_net_0;
wire   [31:0] APBmaster_0_PWDATA_net_0;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign AHBslave_HREADYOUT_net_0  = AHBslave_HREADYOUT;
assign HREADYOUT                 = AHBslave_HREADYOUT_net_0;
assign APBmaster_0_PSELx_net_0   = APBmaster_0_PSELx;
assign PSEL                      = APBmaster_0_PSELx_net_0;
assign APBmaster_0_PENABLE_net_0 = APBmaster_0_PENABLE;
assign PENABLE                   = APBmaster_0_PENABLE_net_0;
assign APBmaster_0_PWRITE_net_0  = APBmaster_0_PWRITE;
assign PWRITE                    = APBmaster_0_PWRITE_net_0;
assign AHBslave_HRDATA_net_0     = AHBslave_HRDATA;
assign HRDATA[31:0]              = AHBslave_HRDATA_net_0;
assign AHBslave_HRESP_net_0      = AHBslave_HRESP;
assign HRESP[1:0]                = AHBslave_HRESP_net_0;
assign APBmaster_0_PADDR_net_0   = APBmaster_0_PADDR;
assign PADDR[31:0]               = APBmaster_0_PADDR_net_0;
assign APBmaster_0_PWDATA_net_0  = APBmaster_0_PWDATA;
assign PWDATA[31:0]              = APBmaster_0_PWDATA_net_0;
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------COREAHBTOAPB3   -   Actel:DirectCore:COREAHBTOAPB3:3.2.101
COREAHBTOAPB3 #( 
        .FAMILY ( 26 ) )
AHBtoAPB_0(
        // Inputs
        .HCLK      ( HCLK ),
        .HRESETN   ( HRESETN ),
        .HWRITE    ( HWRITE ),
        .HSEL      ( HSEL ),
        .HREADY    ( HREADY ),
        .PREADY    ( PREADY ),
        .PSLVERR   ( PSLVERR ),
        .HADDR     ( HADDR ),
        .HTRANS    ( HTRANS ),
        .HWDATA    ( HWDATA ),
        .PRDATA    ( PRDATA ),
        // Outputs
        .HREADYOUT ( AHBslave_HREADYOUT ),
        .PENABLE   ( APBmaster_0_PENABLE ),
        .PWRITE    ( APBmaster_0_PWRITE ),
        .PSEL      ( APBmaster_0_PSELx ),
        .HRDATA    ( AHBslave_HRDATA ),
        .HRESP     ( AHBslave_HRESP ),
        .PWDATA    ( APBmaster_0_PWDATA ),
        .PADDR     ( APBmaster_0_PADDR ) 
        );


endmodule
