`timescale 1 ns/100 ps
// Version: v2021.2 2021.2.0.11


module PCIe_INIT_MONITOR_PCIe_INIT_MONITOR_0_PF_INIT_MONITOR(
       FABRIC_POR_N,
       PCIE_INIT_DONE,
       SRAM_INIT_DONE,
       DEVICE_INIT_DONE,
       USRAM_INIT_DONE,
       XCVR_INIT_DONE,
       USRAM_INIT_FROM_SNVM_DONE,
       USRAM_INIT_FROM_UPROM_DONE,
       USRAM_INIT_FROM_SPI_DONE,
       SRAM_INIT_FROM_SNVM_DONE,
       SRAM_INIT_FROM_UPROM_DONE,
       SRAM_INIT_FROM_SPI_DONE,
       AUTOCALIB_DONE,
       BANK_0_CALIB_STATUS,
       BANK_1_CALIB_STATUS,
       BANK_4_VDDI_STATUS
    );
output FABRIC_POR_N;
output PCIE_INIT_DONE;
output SRAM_INIT_DONE;
output DEVICE_INIT_DONE;
output USRAM_INIT_DONE;
output XCVR_INIT_DONE;
output USRAM_INIT_FROM_SNVM_DONE;
output USRAM_INIT_FROM_UPROM_DONE;
output USRAM_INIT_FROM_SPI_DONE;
output SRAM_INIT_FROM_SNVM_DONE;
output SRAM_INIT_FROM_UPROM_DONE;
output SRAM_INIT_FROM_SPI_DONE;
output AUTOCALIB_DONE;
output BANK_0_CALIB_STATUS;
output BANK_1_CALIB_STATUS;
output BANK_4_VDDI_STATUS;

    wire GND_net, VCC_net;
    
    INIT #( .FABRIC_POR_N_SIMULATION_DELAY(1000), .PCIE_INIT_DONE_SIMULATION_DELAY(4000)
        , .SRAM_INIT_DONE_SIMULATION_DELAY(6000), .UIC_INIT_DONE_SIMULATION_DELAY(7000)
        , .USRAM_INIT_DONE_SIMULATION_DELAY(5000) )  I_INIT (
        .FABRIC_POR_N(FABRIC_POR_N), .GPIO_ACTIVE(), .HSIO_ACTIVE(), 
        .PCIE_INIT_DONE(PCIE_INIT_DONE), .RFU({AUTOCALIB_DONE, nc0, 
        nc1, nc2, nc3, SRAM_INIT_FROM_SPI_DONE, 
        SRAM_INIT_FROM_UPROM_DONE, SRAM_INIT_FROM_SNVM_DONE, 
        USRAM_INIT_FROM_SPI_DONE, USRAM_INIT_FROM_UPROM_DONE, 
        USRAM_INIT_FROM_SNVM_DONE, XCVR_INIT_DONE}), .SRAM_INIT_DONE(
        SRAM_INIT_DONE), .UIC_INIT_DONE(DEVICE_INIT_DONE), 
        .USRAM_INIT_DONE(USRAM_INIT_DONE));
    BANKCTRL_HSIO #( .CALIB_STATUS_SIMULATION_DELAY(1000), .BANK_NUMBER("bank1")
        , .PC_REG_CALIB_START(1'b0), .PC_REG_CALIB_LOCK(1'b0), .PC_REG_CALIB_LOAD(1'b0)
         )  I_BCTRL_HSIO_1 (.CALIB_STATUS(BANK_1_CALIB_STATUS), 
        .CALIB_INTERRUPT(), .CALIB_DIRECTION(GND_net), .CALIB_LOAD(
        VCC_net), .CALIB_LOCK(GND_net), .CALIB_MOVE_NCODE(GND_net), 
        .CALIB_MOVE_PCODE(GND_net), .CALIB_START(GND_net), 
        .CALIB_MOVE_SLEWR(GND_net), .CALIB_MOVE_SLEWF(GND_net));
    VCC vcc_inst (.Y(VCC_net));
    GND gnd_inst (.Y(GND_net));
    BANKEN #( .BANK_EN_SIMULATION_DELAY(1000), .BANK_NUMBER("bank4")
         )  I_BEN_4 (.BANK_EN(BANK_4_VDDI_STATUS));
    BANKCTRL_HSIO #( .CALIB_STATUS_SIMULATION_DELAY(1000), .BANK_NUMBER("bank0")
        , .PC_REG_CALIB_START(1'b0), .PC_REG_CALIB_LOCK(1'b0), .PC_REG_CALIB_LOAD(1'b0)
         )  I_BCTRL_HSIO_0 (.CALIB_STATUS(BANK_0_CALIB_STATUS), 
        .CALIB_INTERRUPT(), .CALIB_DIRECTION(GND_net), .CALIB_LOAD(
        VCC_net), .CALIB_LOCK(GND_net), .CALIB_MOVE_NCODE(GND_net), 
        .CALIB_MOVE_PCODE(GND_net), .CALIB_START(GND_net), 
        .CALIB_MOVE_SLEWR(GND_net), .CALIB_MOVE_SLEWF(GND_net));
    
endmodule
