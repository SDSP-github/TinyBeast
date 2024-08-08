//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Wed Jul 21 07:09:14 2021
// Version: v12.6 12.900.20.24
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

//////////////////////////////////////////////////////////////////////
// Component Description (Tcl) 
//////////////////////////////////////////////////////////////////////
/*
# Exporting Component Description of OSC_160MHz to TCL
# Family: PolarFire
# Part Number: MPF300T-1FCVG484E
# Create and Configure the core component OSC_160MHz
create_and_configure_core -core_vlnv {Actel:SgCore:PF_OSC:1.0.102} -component_name {OSC_160MHz} -params {\
"RCOSC_2MHZ_CLK_DIV_EN:false"  \
"RCOSC_2MHZ_GL_EN:false"  \
"RCOSC_2MHZ_NGMUX_EN:false"  \
"RCOSC_160MHZ_CLK_DIV_EN:true"  \
"RCOSC_160MHZ_GL_EN:true"  \
"RCOSC_160MHZ_NGMUX_EN:false"   }
# Exporting Component Description of OSC_160MHz to TCL done
*/

// OSC_160MHz
module OSC_160MHz(
    // Outputs
    RCOSC_160MHZ_CLK_DIV,
    RCOSC_160MHZ_GL
);

//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output RCOSC_160MHZ_CLK_DIV;
output RCOSC_160MHZ_GL;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire   RCOSC_160MHZ_CLK_DIV_net_0;
wire   RCOSC_160MHZ_GL_0;
wire   RCOSC_160MHZ_CLK_DIV_net_1;
wire   RCOSC_160MHZ_GL_0_net_0;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign RCOSC_160MHZ_CLK_DIV_net_1 = RCOSC_160MHZ_CLK_DIV_net_0;
assign RCOSC_160MHZ_CLK_DIV       = RCOSC_160MHZ_CLK_DIV_net_1;
assign RCOSC_160MHZ_GL_0_net_0    = RCOSC_160MHZ_GL_0;
assign RCOSC_160MHZ_GL            = RCOSC_160MHZ_GL_0_net_0;
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------OSC_160MHz_OSC_160MHz_0_PF_OSC   -   Actel:SgCore:PF_OSC:1.0.102
OSC_160MHz_OSC_160MHz_0_PF_OSC OSC_160MHz_0(
        // Outputs
        .RCOSC_160MHZ_GL      ( RCOSC_160MHZ_GL_0 ),
        .RCOSC_160MHZ_CLK_DIV ( RCOSC_160MHZ_CLK_DIV_net_0 ) 
        );


endmodule
