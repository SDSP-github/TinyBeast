///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: PCIe_EP_Demo_tb.v
// File history:
//      <Revision number>: <Date>: <Comments>
//      <Revision number>: <Date>: <Comments>
//      <Revision number>: <Date>: <Comments>
//
// Description: 
//
// <Description here>
//
// Targeted device: <Family::PolarFire> <Die::MPF300TS_ES> <Package::FCG1152>
// Author: <Name>
//
/////////////////////////////////////////////////////////////////////////////////////////////////// 

`timescale 1ps/1ps

`include "ddr4.sv"
`include "ddr3.v"

module PCIe_EP_Demo_tb;

parameter SYSCLK_PERIOD = 20000;// 50MHZ

reg SYSCLK;
reg NSYSRESET;

//
wire DDR3_CTRLR_READY;
wire DDR4_CTRLR_READY;

//DDR4 
wire        DDR4_ACT_N;
wire        DDR4_CAS_N;
wire        DDR4_CKE;
wire        DDR4_CK;
wire        DDR4_CK_N;
wire        DDR4_CS_N;
wire        DDR4_ODT;
wire        DDR4_RAS_N;
wire        DDR4_RESET_N;
wire        DDR4_WE_N;	
wire [13:0] DDR4_ADDR;
wire [1:0]  DDR4_BA;
wire [1:0]  DDR4_BG;
wire [3:0]  DDR4_DM_N;
wire [3:0]  DDR4_DQS;
wire [3:0]  DDR4_DQS_N;
wire [31:0] DDR4_DQ;

//DDR3
wire        DDR3_RESET_N;
wire        DDR3_CK0;
wire        DDR3_CK0_N;
wire        DDR3_CKE;
wire        DDR3_CS_N; 
wire        DDR3_RAS_N; 
wire        DDR3_CAS_N;
wire        DDR3_WE_N;
wire        DDR3_ODT;
wire [2:0]  DDR3_BA;
wire [15:0] DDR3_A;       
wire [1:0]  DDR3_DM; 
wire [15:0] DDR3_DQ;
wire [1:0]  DDR3_DQS; 
wire [1:0]  DDR3_DQS_N;  

initial
begin
    SYSCLK = 1'b0;
    NSYSRESET = 1'b0;
end

//////////////////////////////////////////////////////////////////////
// Reset Pulse
//////////////////////////////////////////////////////////////////////
initial
begin
    #(SYSCLK_PERIOD * 10 )
        NSYSRESET = 1'b1;
end


//////////////////////////////////////////////////////////////////////
// Clock Driver
//////////////////////////////////////////////////////////////////////
always @(SYSCLK)
    #(SYSCLK_PERIOD / 2.0) SYSCLK <= !SYSCLK;

////////////////////////////////////////////////////////////////////
//To start the PCIe BFM execution after DDR3/4 is ready 
///////////////////////////////////////////////////////////////////
initial
begin
   force PCIe_EP_Demo_tb.top_0.PCIe_EP_0.AXI_CLK_STABLE = 1'b0;
   @(posedge DDR3_CTRLR_READY);
   @(posedge DDR4_CTRLR_READY);
   force PCIe_EP_Demo_tb.top_0.PCIe_EP_0.AXI_CLK_STABLE = 1'b1;
end
//////////////////////////////////////////////////////////////////////
// Instantiate Unit Under Test:  PCIe_EP_Demo
//////////////////////////////////////////////////////////////////////
top top_0 (
    // Inputs
    .USER_RESETN(NSYSRESET),
    .REF_CLK_0(SYSCLK),
    .PCIESS_LANE_RXD0_P({1{1'b0}}),
    .PCIESS_LANE_RXD0_N({1{1'b0}}),
    .PCIESS_LANE_RXD1_P({1{1'b0}}),
    .PCIESS_LANE_RXD1_N({1{1'b0}}),
    .PCIESS_LANE_RXD2_P({1{1'b0}}),
    .PCIESS_LANE_RXD2_N({1{1'b0}}),
    .PCIESS_LANE_RXD3_P({1{1'b0}}),
    .PCIESS_LANE_RXD3_N({1{1'b0}}),
    .REF_CLK_PAD_P(SYSCLK),
    .REF_CLK_PAD_N(SYSCLK),
    .RX({1{1'b0}}),
    .switch_i({4{1'b0}}),
    .dip_switch_o({4{1'b0}}),
    .PCIE_1_PERST_N(NSYSRESET),

    // Outputs
    .PCIESS_LANE_TXD0_P( ),
    .PCIESS_LANE_TXD0_N( ),
    .PCIESS_LANE_TXD1_P( ),
    .PCIESS_LANE_TXD1_N( ),
    .PCIESS_LANE_TXD2_P( ),
    .PCIESS_LANE_TXD2_N( ),
    .PCIESS_LANE_TXD3_P( ),
    .PCIESS_LANE_TXD3_N( ),
    //.PCIE_1_WAKE_N( ),
    .TX( ),
    .led_o( ),
    .BANK0_1_7_CALIB_DONE( ),

    //DDR4 outputs
    .CKE(DDR4_CKE),
    .CS_N(DDR4_CS_N),
    .ODT(DDR4_ODT),
    .RAS_N(DDR4_RAS_N),
    .CAS_N(DDR4_CAS_N),
    .WE_N(DDR4_WE_N),
    .ACT_N(DDR4_ACT_N),
    .RESET_N(DDR4_RESET_N),
    .CK0(DDR4_CK),
    .CK0_N(DDR4_CK_N),
    .BG(DDR4_BG),
    .BA(DDR4_BA),
    .A(DDR4_ADDR),
    .DM_N(DDR4_DM_N),
    .SHIELD0( ),
    .SHIELD1( ),  
    .CTRLR_READY_DDR4(DDR4_CTRLR_READY),
    .PLL_LOCK_DDR4( ),

    //DDR4 Inouts
    .DQ(DDR4_DQ),
    .DQS(DDR4_DQS),
    .DQS_N(DDR4_DQS_N),

    //DDR3 outputs
    .CKE_0(DDR3_CKE),
    .CS_N_0(DDR3_CS_N),
    .ODT_0(DDR3_ODT),
    .RAS_N_0(DDR3_RAS_N),
    .CAS_N_0(DDR3_CAS_N),
    .WE_N_0(DDR3_WE_N),
    .RESET_N_0(DDR3_RESET_N),
    .CK0_0(DDR3_CK0 ),
    .CK0_N_0(DDR3_CK0_N),
    .DM(DDR3_DM),
    .BA_0(DDR3_BA),
    .A_0(DDR3_A),
    .SHIELD0_0( ),
    .SHIELD1_0( ),
    .CTRLR_READY_DDR3(DDR3_CTRLR_READY),
    .PLL_LOCK_DDR3( ),   
    
    //DDR3 Inouts
    .DQ_0(DDR3_DQ),
    .DQS_0(DDR3_DQS),
    .DQS_N_0(DDR3_DQS_N)

);

// Instantiate DDR4 model
ddr4 ddr4_mem_0 (
    .model_enable(1'b1),
    .reset_n     (DDR4_RESET_N),
    .clk_p       (DDR4_CK),
    .clk_n       (DDR4_CK_N),	
    .cke         (DDR4_CKE),
    .cs_n        (DDR4_CS_N),
    .act_n       (DDR4_ACT_N),
    .ras_n       (DDR4_RAS_N ),
    .cas_n       (DDR4_CAS_N),
    .we_n        (DDR4_WE_N),
    .sa          (DDR4_ADDR[13:0]),
    .ba          (DDR4_BA),
    .bg          (DDR4_BG),
    .dm          (DDR4_DM_N[0]),
    .dq          (DDR4_DQ[7:0]),	
    .dqs         (DDR4_DQS[0]),
    .dqs_n       (DDR4_DQS_N[0]),
    .odt         (DDR4_ODT),	
    .ten         (),
    .sa17        (),
    .par_in      (),
    .mem_alert_n ()
);

// Instantiate DDR4 model
ddr4 ddr4_mem_1 (
    .model_enable(1'b1),
    .reset_n     (DDR4_RESET_N),
    .clk_p       (DDR4_CK),
    .clk_n       (DDR4_CK_N),	
    .cke         (DDR4_CKE),
    .cs_n        (DDR4_CS_N), 
    .act_n       (DDR4_ACT_N),
    .ras_n       (DDR4_RAS_N ),
    .cas_n       (DDR4_CAS_N),
    .we_n        (DDR4_WE_N),
    .sa          (DDR4_ADDR[13:0]),
    .ba          (DDR4_BA),
    .bg          (DDR4_BG),
    .dm          (DDR4_DM_N[1]),
    .dq          (DDR4_DQ[15:8]),	
    .dqs         (DDR4_DQS[1]),
    .dqs_n       (DDR4_DQS_N[1]),
    .odt         (DDR4_ODT),	
    .ten         (),
    .sa17        (),
    .par_in      (),
    .mem_alert_n ()
);

// Instantiate DDR4 model

ddr4 ddr4_mem_2 (
    .model_enable(1'b1),
    .reset_n     (DDR4_RESET_N),
    .clk_p       (DDR4_CK),
    .clk_n       (DDR4_CK_N),	
    .cke         (DDR4_CKE),
    .cs_n        (DDR4_CS_N),
    .act_n       (DDR4_ACT_N),
    .ras_n       (DDR4_RAS_N ),
    .cas_n       (DDR4_CAS_N),
    .we_n        (DDR4_WE_N),
    .sa          (DDR4_ADDR[13:0]),
    .ba          (DDR4_BA),
    .bg          (DDR4_BG),
    .dm          (DDR4_DM_N[2]),
    .dq          (DDR4_DQ[23:16]),	
    .dqs         (DDR4_DQS[2]),
    .dqs_n       (DDR4_DQS_N[2]),
    .odt         (DDR4_ODT),	
    .ten         (),
    .sa17        (),
    .par_in      (),
    .mem_alert_n ()
);

// Instantiate DDR4 model

ddr4 ddr4_mem_3 (
    .model_enable(1'b1),
    .reset_n     (DDR4_RESET_N),
    .clk_p       (DDR4_CK),
    .clk_n       (DDR4_CK_N),	
    .cke         (DDR4_CKE),
    .cs_n        (DDR4_CS_N),
    .act_n       (DDR4_ACT_N),
    .ras_n       (DDR4_RAS_N ),
    .cas_n       (DDR4_CAS_N),
    .we_n        (DDR4_WE_N),
    .sa          (DDR4_ADDR[13:0]),
    .ba          (DDR4_BA),
    .bg          (DDR4_BG),
    .dm          (DDR4_DM_N[3]),
    .dq          (DDR4_DQ[31:24]),	
    .dqs         (DDR4_DQS[3]),
    .dqs_n       (DDR4_DQS_N[3]),
    .odt         (DDR4_ODT),	
    .ten         (),
    .sa17        (),
    .par_in      (),
    .mem_alert_n ()
);


//--------ddr3
ddr3 ddr3_mem_0(
    // Inputs
    .rst_n       ( DDR3_RESET_N ),
    .ck          ( DDR3_CK0 ),
    .ck_n        ( DDR3_CK0_N ),
    .cke         ( DDR3_CKE ),
    .cs_n        ( DDR3_CS_N ),
    .ras_n       ( DDR3_RAS_N ),
    .cas_n       ( DDR3_CAS_N ),
    .we_n        ( DDR3_WE_N ),
    .odt         ( DDR3_ODT ),
    .ba          ( DDR3_BA ),
    .addr        ( DDR3_A ),
    // Inouts
    .dm_tdqs     ( DDR3_DM[0] ),
    .dq          ( DDR3_DQ[7:0] ),
    .dqs         ( DDR3_DQS[0] ),
    .dqs_n       ( DDR3_DQS_N[0] ), 
    .tdqs_n      ()
    );

//--------ddr3
ddr3 ddr3_mem_1(
    // Inputs
    .rst_n       ( DDR3_RESET_N ),
    .ck          ( DDR3_CK0 ),
    .ck_n        ( DDR3_CK0_N ),
    .cke         ( DDR3_CKE ),
    .cs_n        ( DDR3_CS_N ),
    .ras_n       ( DDR3_RAS_N ),
    .cas_n       ( DDR3_CAS_N ),
    .we_n        ( DDR3_WE_N ),
    .odt         ( DDR3_ODT ),
    .ba          ( DDR3_BA ),
    .addr        ( DDR3_A ),
    // Inouts
    .dm_tdqs     ( DDR3_DM[1] ),
    .dq          ( DDR3_DQ[15:8] ),
    .dqs         ( DDR3_DQS[1] ),
    .dqs_n       ( DDR3_DQS_N[1] ), 
    .tdqs_n      ()
    );

endmodule

