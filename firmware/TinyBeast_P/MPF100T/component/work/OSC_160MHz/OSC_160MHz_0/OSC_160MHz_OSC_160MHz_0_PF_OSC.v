`timescale 1 ns/100 ps
// Version: v12.2 12.700.0.21


module OSC_160MHz_OSC_160MHz_0_PF_OSC(
       RCOSC_160MHZ_CLK_DIV
    );
output RCOSC_160MHZ_CLK_DIV;

    wire GND_net, VCC_net;
    
    VCC vcc_inst (.Y(VCC_net));
    OSC_RC160MHZ I_OSC_160 (.OSC_160MHZ_ON(VCC_net), .CLK(
        RCOSC_160MHZ_CLK_DIV));
    GND gnd_inst (.Y(GND_net));
    
endmodule
