//  -------------------------------------------------------------------------
//
//  -------------------------------------------------------------------------

// DO NOT CHANGE THE TIMESCALE
// MAKE SURE YOUR SIMULATOR USES "PS" RESOLUTION
`timescale 1ps / 1ps

// Define Libero needed TB Simulation Parameters
`define MODEL_DEBUG_MEMORY
`define FIXED_1600
`define DDR4_2G_X8
`define SILENT

`include "arch_defines.v"
`include "arch_package.sv"
`include "proj_package.sv"
`include "StateTable.svp"
`include "StateTableCore.svp"
`include "ddr4_model.svp"
`include "interface.sv"

module ddr4 (

 input           reset_n,
 input           clk_p,
 input           clk_n,
 input           cke,
 input           cs_n,
 input           act_n,
 input           ten,
 input           ras_n,
 input           cas_n,
 input           we_n,
 input           dm,
 input   [1:0]   bg,
 input   [1:0]   ba,
 input   [13:0]  sa,
 input           sa17,
 inout   [7:0]   dq,
 inout           dqs,
 inout           dqs_n,
 input           odt,
 input           par_in,
 input           model_enable,
 output          mem_alert_n

);

import arch_package::*; // need UTYPE_density enum definition

parameter  CONFIGURED_RANKS   =  1;
parameter  CONFIGURED_DQ_BITS =  8;
parameter  UTYPE_density CONFIGURED_DENSITY = _2G;

DDR4_if #(.CONFIGURED_DQ_BITS(CONFIGURED_DQ_BITS))
   iDDR4 (
          .DM_n  ( dm    ), 
          .DQ    ( dq    ), 
          .DQS_t ( dqs   ), 
          .DQS_c ( dqs_n )  
          );

always @*    iDDR4.CK[0]         = clk_n; 
always @*    iDDR4.CK[1]         = clk_p; 
always @*    iDDR4.ACT_n         = act_n; 
always @*    iDDR4.RAS_n_A16     = ras_n; 
always @*    iDDR4.CAS_n_A15     = cas_n; 
always @*    iDDR4.WE_n_A14      = we_n; 
always @*    iDDR4.PARITY        = par_in; 
always @*    iDDR4.RESET_n       = reset_n; 
always @*    iDDR4.TEN           = ten; 
always @*    iDDR4.CS_n          = cs_n; 
always @*    iDDR4.CKE           = cke; 
always @*    iDDR4.ODT           = odt; 
always @*    iDDR4.BG            = bg;
always @*    iDDR4.BA            = ba; 
always @*    iDDR4.ADDR          = sa;
always @*    iDDR4.ADDR_17       = sa17;

// Bit 17 should tied to 0  if it is not used by the memory so that when mode register
// writes to the bside of dimms occur we don't get a parity violation from the RCD or the memory.
//always @*    iDDR4.ADDR_17       = (CONFIGURED_DENSITY == _16G && MEM_DEV_WIDTH == 4) ? sa17 : ~reset_n ;
 //

assign    mem_alert_n            = iDDR4.ALERT_n ? 1'bz : 1'b0; 

initial
    begin
        iDDR4.ZQ            = 1'b0;
        iDDR4.PWR           = 1'b1;
        iDDR4.VREF_CA       = 1'b1;
        iDDR4.VREF_DQ       = 1'b1;
    end

ddr4_model # (
    .CONFIGURED_RANKS         ( CONFIGURED_RANKS   ),
    .CONFIGURED_DENSITY       ( CONFIGURED_DENSITY ),
    .CONFIGURED_DQ_BITS       ( CONFIGURED_DQ_BITS )
) golden_model (
    .model_enable             ( model_enable        ),
    .iDDR4                    ( iDDR4               )
);

endmodule
