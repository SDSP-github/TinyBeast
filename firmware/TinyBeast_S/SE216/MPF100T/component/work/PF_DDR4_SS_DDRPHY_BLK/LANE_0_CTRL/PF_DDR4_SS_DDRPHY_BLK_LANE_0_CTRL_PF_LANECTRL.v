`timescale 1 ns/100 ps
// Version: v2021.2 2021.2.0.11


module PF_DDR4_SS_DDRPHY_BLK_LANE_0_CTRL_PF_LANECTRL(
       DQS,
       HS_IO_CLK,
       DLL_CODE,
       EYE_MONITOR_WIDTH_OUT,
       ODT_EN_SEL,
       RX_DQS_90,
       TX_DQS,
       TX_DQS_270,
       FIFO_WR_PTR,
       FIFO_RD_PTR,
       ARST_N,
       RX_SYNC_RST,
       TX_SYNC_RST,
       ODT_EN_OUT,
       FAB_CLK,
       RESET,
       DDR_READ,
       READ_CLK_SEL,
       DELAY_LINE_SEL,
       DELAY_LINE_LOAD,
       DELAY_LINE_DIRECTION,
       DELAY_LINE_MOVE,
       HS_IO_CLK_PAUSE,
       EYE_MONITOR_WIDTH_IN,
       RX_DATA_VALID,
       RX_BURST_DETECT,
       RX_DELAY_LINE_OUT_OF_RANGE,
       TX_DELAY_LINE_OUT_OF_RANGE,
       ODT_EN,
       CDR_CLK_A_SEL,
       A_OUT_RST_N,
       DDR_DO_READ,
       SWITCH
    );
input  DQS;
input  [1:0] HS_IO_CLK;
input  [7:0] DLL_CODE;
output [2:0] EYE_MONITOR_WIDTH_OUT;
output ODT_EN_SEL;
output [0:0] RX_DQS_90;
output TX_DQS;
output TX_DQS_270;
output [2:0] FIFO_WR_PTR;
output [2:0] FIFO_RD_PTR;
output ARST_N;
output RX_SYNC_RST;
output TX_SYNC_RST;
output ODT_EN_OUT;
input  FAB_CLK;
input  RESET;
input  DDR_READ;
input  [2:0] READ_CLK_SEL;
input  DELAY_LINE_SEL;
input  DELAY_LINE_LOAD;
input  DELAY_LINE_DIRECTION;
input  DELAY_LINE_MOVE;
input  HS_IO_CLK_PAUSE;
input  [2:0] EYE_MONITOR_WIDTH_IN;
output RX_DATA_VALID;
output RX_BURST_DETECT;
output RX_DELAY_LINE_OUT_OF_RANGE;
output TX_DELAY_LINE_OUT_OF_RANGE;
input  ODT_EN;
input  [7:0] CDR_CLK_A_SEL;
output A_OUT_RST_N;
input  DDR_DO_READ;
input  SWITCH;

    wire GND_net, VCC_net, 
        HS_IO_CLK_PAUSE_SYNC_I_LANECTRL_PAUSE_SYNC_net;
    
    LANECTRL #( .DATA_RATE(1600.0), .FORMAL_NAME("NA"), .INTERFACE_NAME("DDR4")
        , .DELAY_LINE_SIMULATION_MODE("ENABLED"), .RESERVED_0(1'b0), .RESERVED_1(1'b0)
        , .RESERVED_2(1'b0), .SOFTRESET_EN(1'b0), .SOFTRESET(1'b0), .RX_DQS_DELAY_LINE_EN(1'b1)
        , .TX_DQS_DELAY_LINE_EN(1'b1), .RX_DQS_DELAY_LINE_DIRECTION(1'b1)
        , .TX_DQS_DELAY_LINE_DIRECTION(1'b1), .RX_DQS_DELAY_VAL(8'b00000001)
        , .TX_DQS_DELAY_VAL(8'b00000001), .FIFO_EN(1'b1), .FIFO_MODE(1'b1)
        , .FIFO_RD_PTR_MODE(3'b011), .DQS_MODE(3'b011), .CDR_EN(2'b00)
        , .HS_IO_CLK_SEL(9'b111001000), .DLL_CODE_SEL(2'b00), .CDR_CLK_SEL(12'b000000000001)
        , .READ_MARGIN_TEST_EN(1'b1), .WRITE_MARGIN_TEST_EN(1'b1), .CDR_CLK_DIV(3'b000)
        , .DIV_CLK_SEL(2'b00), .HS_IO_CLK_PAUSE_EN(1'b1), .QDR_EN(1'b0)
        , .DYN_ODT_MODE(1'b1), .DIV_CLK_EN_SRC(2'b11), .RANK_2_MODE(1'b0)
         )  I_LANECTRL (.RX_DATA_VALID(RX_DATA_VALID), 
        .RX_BURST_DETECT(RX_BURST_DETECT), .RX_DELAY_LINE_OUT_OF_RANGE(
        RX_DELAY_LINE_OUT_OF_RANGE), .TX_DELAY_LINE_OUT_OF_RANGE(
        TX_DELAY_LINE_OUT_OF_RANGE), .CLK_OUT_R(), .A_OUT_RST_N(
        A_OUT_RST_N), .FAB_CLK(FAB_CLK), .RESET(RESET), .DDR_READ(
        DDR_READ), .READ_CLK_SEL({READ_CLK_SEL[2], READ_CLK_SEL[1], 
        READ_CLK_SEL[0]}), .DELAY_LINE_SEL(DELAY_LINE_SEL), 
        .DELAY_LINE_LOAD(DELAY_LINE_LOAD), .DELAY_LINE_DIRECTION(
        DELAY_LINE_DIRECTION), .DELAY_LINE_MOVE(DELAY_LINE_MOVE), 
        .HS_IO_CLK_PAUSE(
        HS_IO_CLK_PAUSE_SYNC_I_LANECTRL_PAUSE_SYNC_net), .DIV_CLK_EN_N(
        VCC_net), .RX_BIT_SLIP(GND_net), .CDR_CLK_A_SEL({
        CDR_CLK_A_SEL[7], CDR_CLK_A_SEL[6], CDR_CLK_A_SEL[5], 
        CDR_CLK_A_SEL[4], CDR_CLK_A_SEL[3], CDR_CLK_A_SEL[2], 
        CDR_CLK_A_SEL[1], CDR_CLK_A_SEL[0]}), .EYE_MONITOR_WIDTH_IN({
        EYE_MONITOR_WIDTH_IN[2], EYE_MONITOR_WIDTH_IN[1], 
        EYE_MONITOR_WIDTH_IN[0]}), .ODT_EN(ODT_EN), .CODE_UPDATE(
        GND_net), .DQS(DQS), .DQS_N(GND_net), .HS_IO_CLK({GND_net, 
        GND_net, GND_net, GND_net, HS_IO_CLK[1], HS_IO_CLK[0]}), 
        .DLL_CODE({DLL_CODE[7], DLL_CODE[6], DLL_CODE[5], DLL_CODE[4], 
        DLL_CODE[3], DLL_CODE[2], DLL_CODE[1], DLL_CODE[0]}), 
        .EYE_MONITOR_WIDTH_OUT({EYE_MONITOR_WIDTH_OUT[2], 
        EYE_MONITOR_WIDTH_OUT[1], EYE_MONITOR_WIDTH_OUT[0]}), 
        .ODT_EN_SEL(ODT_EN_SEL), .RX_DQS_90({nc0, RX_DQS_90[0]}), 
        .TX_DQS(TX_DQS), .TX_DQS_270(TX_DQS_270), .FIFO_WR_PTR({
        FIFO_WR_PTR[2], FIFO_WR_PTR[1], FIFO_WR_PTR[0]}), .FIFO_RD_PTR({
        FIFO_RD_PTR[2], FIFO_RD_PTR[1], FIFO_RD_PTR[0]}), .CDR_CLK(), 
        .CDR_NEXT_CLK(), .ARST_N(ARST_N), .RX_SYNC_RST(RX_SYNC_RST), 
        .TX_SYNC_RST(TX_SYNC_RST), .ODT_EN_OUT(ODT_EN_OUT), 
        .DDR_DO_READ(DDR_DO_READ), .CDR_CLK_A_SEL_8(GND_net), 
        .CDR_CLK_A_SEL_9(GND_net), .CDR_CLK_A_SEL_10(GND_net), 
        .CDR_CLK_B_SEL({GND_net, GND_net, GND_net, GND_net, GND_net, 
        GND_net, GND_net, GND_net, GND_net, GND_net, GND_net}), 
        .SWITCH(SWITCH), .CDR_CLR_NEXT_CLK_N(GND_net));
    PF_DDR4_SS_DDRPHY_BLK_LANE_0_CTRL_PF_LANECTRL_PAUSE_SYNC #( .ENABLE_PAUSE_EXTENSION(2'b00)
         )  I_LANECTRL_PAUSE_SYNC (.CLK(FAB_CLK), .RESET(RESET), 
        .HS_IO_CLK_PAUSE(HS_IO_CLK_PAUSE), .HS_IO_CLK_PAUSE_SYNC(
        HS_IO_CLK_PAUSE_SYNC_I_LANECTRL_PAUSE_SYNC_net));
    VCC vcc_inst (.Y(VCC_net));
    GND gnd_inst (.Y(GND_net));
    
endmodule
