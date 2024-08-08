//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Mon Jan  6 18:07:01 2020
// Version: v12.3 12.800.0.16
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

// PCIe_TX_PLL
module PCIe_TX_PLL(
    // Inputs
    REF_CLK,
    // Outputs
    BIT_CLK,
    CLK_125,
    LOCK,
    PLL_LOCK,
    REF_CLK_TO_LANE
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input  REF_CLK;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output BIT_CLK;
output CLK_125;
output LOCK;
output PLL_LOCK;
output REF_CLK_TO_LANE;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire   CLK_125_net_0;
wire   CLKS_TO_XCVR_1_BIT_CLK;
wire   CLKS_TO_XCVR_1_LOCK;
wire   CLKS_TO_XCVR_1_REF_CLK_TO_LANE;
wire   PLL_LOCK_net_0;
wire   REF_CLK;
wire   PLL_LOCK_net_1;
wire   CLK_125_net_1;
wire   CLKS_TO_XCVR_1_LOCK_net_0;
wire   CLKS_TO_XCVR_1_BIT_CLK_net_0;
wire   CLKS_TO_XCVR_1_REF_CLK_TO_LANE_net_0;
//--------------------------------------------------------------------
// TiedOff Nets
//--------------------------------------------------------------------
wire   GND_net;
wire   [10:0]DRI_CTRL_const_net_0;
wire   [32:0]DRI_WDATA_const_net_0;
//--------------------------------------------------------------------
// Constant assignments
//--------------------------------------------------------------------
assign GND_net               = 1'b0;
assign DRI_CTRL_const_net_0  = 11'h000;
assign DRI_WDATA_const_net_0 = 33'h000000000;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign PLL_LOCK_net_1                       = PLL_LOCK_net_0;
assign PLL_LOCK                             = PLL_LOCK_net_1;
assign CLK_125_net_1                        = CLK_125_net_0;
assign CLK_125                              = CLK_125_net_1;
assign CLKS_TO_XCVR_1_LOCK_net_0            = CLKS_TO_XCVR_1_LOCK;
assign LOCK                                 = CLKS_TO_XCVR_1_LOCK_net_0;
assign CLKS_TO_XCVR_1_BIT_CLK_net_0         = CLKS_TO_XCVR_1_BIT_CLK;
assign BIT_CLK                              = CLKS_TO_XCVR_1_BIT_CLK_net_0;
assign CLKS_TO_XCVR_1_REF_CLK_TO_LANE_net_0 = CLKS_TO_XCVR_1_REF_CLK_TO_LANE;
assign REF_CLK_TO_LANE                      = CLKS_TO_XCVR_1_REF_CLK_TO_LANE_net_0;
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------PCIe_TX_PLL_PCIe_TX_PLL_0_PF_TX_PLL   -   Actel:SgCore:PF_TX_PLL:2.0.200
PCIe_TX_PLL_PCIe_TX_PLL_0_PF_TX_PLL PCIe_TX_PLL_0(
        // Inputs
        .REF_CLK         ( REF_CLK ),
        // Outputs
        .LOCK            ( CLKS_TO_XCVR_1_LOCK ),
        .BIT_CLK         ( CLKS_TO_XCVR_1_BIT_CLK ),
        .CLK_125         ( CLK_125_net_0 ),
        .REF_CLK_TO_LANE ( CLKS_TO_XCVR_1_REF_CLK_TO_LANE ),
        .PLL_LOCK        ( PLL_LOCK_net_0 ) 
        );


endmodule
