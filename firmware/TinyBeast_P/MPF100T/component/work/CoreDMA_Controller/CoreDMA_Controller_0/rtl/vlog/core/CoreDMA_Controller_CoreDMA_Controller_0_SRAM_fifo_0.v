`timescale 1 ns/100 ps
// Version: v2021.2 2021.2.0.11


module CoreDMA_Controller_CoreDMA_Controller_0_SRAM_fifo_0(
       R_DATA,
       W_DATA,
       R_ADDR,
       W_ADDR,
       BLK_EN,
       R_ADDR_ARST_N,
       R_DATA_ARST_N,
       R_ADDR_SRST_N,
       R_DATA_SRST_N,
       R_ADDR_EN,
       R_DATA_EN,
       CLK,
       W_EN
    );
output [49:0] R_DATA;
input  [49:0] W_DATA;
input  [1:0] R_ADDR;
input  [1:0] W_ADDR;
input  BLK_EN;
input  R_ADDR_ARST_N;
input  R_DATA_ARST_N;
input  R_ADDR_SRST_N;
input  R_DATA_SRST_N;
input  R_ADDR_EN;
input  R_DATA_EN;
input  CLK;
input  W_EN;

    wire \ACCESS_BUSY[0][0] , \ACCESS_BUSY[0][1] , \ACCESS_BUSY[0][2] , 
        \ACCESS_BUSY[0][3] , \ACCESS_BUSY[0][4] , VCC, GND, ADLIB_VCC;
    wire GND_power_net1;
    wire VCC_power_net1;
    assign GND = GND_power_net1;
    assign VCC = VCC_power_net1;
    assign ADLIB_VCC = VCC_power_net1;
    
    RAM64x12 #( .RAMINDEX("core%4%50%SPEED%0%3%MICRO_RAM") )  
        CoreDMA_Controller_CoreDMA_Controller_0_SRAM_fifo_0_R0C3 (
        .BLK_EN(BLK_EN), .BUSY_FB(GND), .R_ADDR({GND, GND, GND, GND, 
        R_ADDR[1], R_ADDR[0]}), .R_ADDR_AD_N(VCC), .R_ADDR_AL_N(
        R_ADDR_ARST_N), .R_ADDR_BYPASS(GND), .R_ADDR_EN(R_ADDR_EN), 
        .R_ADDR_SD(GND), .R_ADDR_SL_N(R_ADDR_SRST_N), .R_CLK(CLK), 
        .R_DATA_AD_N(VCC), .R_DATA_AL_N(R_DATA_ARST_N), .R_DATA_BYPASS(
        GND), .R_DATA_EN(R_DATA_EN), .R_DATA_SD(GND), .R_DATA_SL_N(
        R_DATA_SRST_N), .W_ADDR({GND, GND, GND, GND, W_ADDR[1], 
        W_ADDR[0]}), .W_CLK(CLK), .W_DATA({GND, GND, W_DATA[39], 
        W_DATA[38], W_DATA[37], W_DATA[36], W_DATA[35], W_DATA[34], 
        W_DATA[33], W_DATA[32], W_DATA[31], W_DATA[30]}), .W_EN(W_EN), 
        .ACCESS_BUSY(\ACCESS_BUSY[0][3] ), .R_DATA({nc0, nc1, 
        R_DATA[39], R_DATA[38], R_DATA[37], R_DATA[36], R_DATA[35], 
        R_DATA[34], R_DATA[33], R_DATA[32], R_DATA[31], R_DATA[30]}));
    RAM64x12 #( .RAMINDEX("core%4%50%SPEED%0%2%MICRO_RAM") )  
        CoreDMA_Controller_CoreDMA_Controller_0_SRAM_fifo_0_R0C2 (
        .BLK_EN(BLK_EN), .BUSY_FB(GND), .R_ADDR({GND, GND, GND, GND, 
        R_ADDR[1], R_ADDR[0]}), .R_ADDR_AD_N(VCC), .R_ADDR_AL_N(
        R_ADDR_ARST_N), .R_ADDR_BYPASS(GND), .R_ADDR_EN(R_ADDR_EN), 
        .R_ADDR_SD(GND), .R_ADDR_SL_N(R_ADDR_SRST_N), .R_CLK(CLK), 
        .R_DATA_AD_N(VCC), .R_DATA_AL_N(R_DATA_ARST_N), .R_DATA_BYPASS(
        GND), .R_DATA_EN(R_DATA_EN), .R_DATA_SD(GND), .R_DATA_SL_N(
        R_DATA_SRST_N), .W_ADDR({GND, GND, GND, GND, W_ADDR[1], 
        W_ADDR[0]}), .W_CLK(CLK), .W_DATA({GND, GND, W_DATA[29], 
        W_DATA[28], W_DATA[27], W_DATA[26], W_DATA[25], W_DATA[24], 
        W_DATA[23], W_DATA[22], W_DATA[21], W_DATA[20]}), .W_EN(W_EN), 
        .ACCESS_BUSY(\ACCESS_BUSY[0][2] ), .R_DATA({nc2, nc3, 
        R_DATA[29], R_DATA[28], R_DATA[27], R_DATA[26], R_DATA[25], 
        R_DATA[24], R_DATA[23], R_DATA[22], R_DATA[21], R_DATA[20]}));
    RAM64x12 #( .RAMINDEX("core%4%50%SPEED%0%4%MICRO_RAM") )  
        CoreDMA_Controller_CoreDMA_Controller_0_SRAM_fifo_0_R0C4 (
        .BLK_EN(BLK_EN), .BUSY_FB(GND), .R_ADDR({GND, GND, GND, GND, 
        R_ADDR[1], R_ADDR[0]}), .R_ADDR_AD_N(VCC), .R_ADDR_AL_N(
        R_ADDR_ARST_N), .R_ADDR_BYPASS(GND), .R_ADDR_EN(R_ADDR_EN), 
        .R_ADDR_SD(GND), .R_ADDR_SL_N(R_ADDR_SRST_N), .R_CLK(CLK), 
        .R_DATA_AD_N(VCC), .R_DATA_AL_N(R_DATA_ARST_N), .R_DATA_BYPASS(
        GND), .R_DATA_EN(R_DATA_EN), .R_DATA_SD(GND), .R_DATA_SL_N(
        R_DATA_SRST_N), .W_ADDR({GND, GND, GND, GND, W_ADDR[1], 
        W_ADDR[0]}), .W_CLK(CLK), .W_DATA({GND, GND, W_DATA[49], 
        W_DATA[48], W_DATA[47], W_DATA[46], W_DATA[45], W_DATA[44], 
        W_DATA[43], W_DATA[42], W_DATA[41], W_DATA[40]}), .W_EN(W_EN), 
        .ACCESS_BUSY(\ACCESS_BUSY[0][4] ), .R_DATA({nc4, nc5, 
        R_DATA[49], R_DATA[48], R_DATA[47], R_DATA[46], R_DATA[45], 
        R_DATA[44], R_DATA[43], R_DATA[42], R_DATA[41], R_DATA[40]}));
    RAM64x12 #( .RAMINDEX("core%4%50%SPEED%0%0%MICRO_RAM") )  
        CoreDMA_Controller_CoreDMA_Controller_0_SRAM_fifo_0_R0C0 (
        .BLK_EN(BLK_EN), .BUSY_FB(GND), .R_ADDR({GND, GND, GND, GND, 
        R_ADDR[1], R_ADDR[0]}), .R_ADDR_AD_N(VCC), .R_ADDR_AL_N(
        R_ADDR_ARST_N), .R_ADDR_BYPASS(GND), .R_ADDR_EN(R_ADDR_EN), 
        .R_ADDR_SD(GND), .R_ADDR_SL_N(R_ADDR_SRST_N), .R_CLK(CLK), 
        .R_DATA_AD_N(VCC), .R_DATA_AL_N(R_DATA_ARST_N), .R_DATA_BYPASS(
        GND), .R_DATA_EN(R_DATA_EN), .R_DATA_SD(GND), .R_DATA_SL_N(
        R_DATA_SRST_N), .W_ADDR({GND, GND, GND, GND, W_ADDR[1], 
        W_ADDR[0]}), .W_CLK(CLK), .W_DATA({GND, GND, W_DATA[9], 
        W_DATA[8], W_DATA[7], W_DATA[6], W_DATA[5], W_DATA[4], 
        W_DATA[3], W_DATA[2], W_DATA[1], W_DATA[0]}), .W_EN(W_EN), 
        .ACCESS_BUSY(\ACCESS_BUSY[0][0] ), .R_DATA({nc6, nc7, 
        R_DATA[9], R_DATA[8], R_DATA[7], R_DATA[6], R_DATA[5], 
        R_DATA[4], R_DATA[3], R_DATA[2], R_DATA[1], R_DATA[0]}));
    RAM64x12 #( .RAMINDEX("core%4%50%SPEED%0%1%MICRO_RAM") )  
        CoreDMA_Controller_CoreDMA_Controller_0_SRAM_fifo_0_R0C1 (
        .BLK_EN(BLK_EN), .BUSY_FB(GND), .R_ADDR({GND, GND, GND, GND, 
        R_ADDR[1], R_ADDR[0]}), .R_ADDR_AD_N(VCC), .R_ADDR_AL_N(
        R_ADDR_ARST_N), .R_ADDR_BYPASS(GND), .R_ADDR_EN(R_ADDR_EN), 
        .R_ADDR_SD(GND), .R_ADDR_SL_N(R_ADDR_SRST_N), .R_CLK(CLK), 
        .R_DATA_AD_N(VCC), .R_DATA_AL_N(R_DATA_ARST_N), .R_DATA_BYPASS(
        GND), .R_DATA_EN(R_DATA_EN), .R_DATA_SD(GND), .R_DATA_SL_N(
        R_DATA_SRST_N), .W_ADDR({GND, GND, GND, GND, W_ADDR[1], 
        W_ADDR[0]}), .W_CLK(CLK), .W_DATA({GND, GND, W_DATA[19], 
        W_DATA[18], W_DATA[17], W_DATA[16], W_DATA[15], W_DATA[14], 
        W_DATA[13], W_DATA[12], W_DATA[11], W_DATA[10]}), .W_EN(W_EN), 
        .ACCESS_BUSY(\ACCESS_BUSY[0][1] ), .R_DATA({nc8, nc9, 
        R_DATA[19], R_DATA[18], R_DATA[17], R_DATA[16], R_DATA[15], 
        R_DATA[14], R_DATA[13], R_DATA[12], R_DATA[11], R_DATA[10]}));
    GND GND_power_inst1 (.Y(GND_power_net1));
    VCC VCC_power_inst1 (.Y(VCC_power_net1));
    
endmodule
