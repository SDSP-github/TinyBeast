onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /PCIe_EP_Demo_tb/SYSCLK
add wave -noupdate /PCIe_EP_Demo_tb/DDR3_CTRLR_READY
add wave -noupdate /PCIe_EP_Demo_tb/DDR4_CTRLR_READY
add wave -noupdate -divider -height 30 {PCIe AXI Interface}
add wave -noupdate /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/AXI_CLK_STABLE
add wave -noupdate /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/AXI_CLK
add wave -noupdate -divider {AXI Write Address Channel}
add wave -noupdate -radix hexadecimal /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/PCIESS_AXI_1_M_AWID
add wave -noupdate -radix hexadecimal /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/PCIESS_AXI_1_M_AWADDR
add wave -noupdate -radix hexadecimal /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/PCIESS_AXI_1_M_AWBURST
add wave -noupdate -radix hexadecimal /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/PCIESS_AXI_1_M_AWLEN
add wave -noupdate -radix hexadecimal /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/PCIESS_AXI_1_M_AWSIZE
add wave -noupdate /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/PCIESS_AXI_1_M_AWVALID
add wave -noupdate /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/PCIESS_AXI_1_M_AWREADY
add wave -noupdate -divider {AXI Write Data Channel}
add wave -noupdate -radix hexadecimal /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/PCIESS_AXI_1_M_WDATA
add wave -noupdate /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/PCIESS_AXI_1_M_WLAST
add wave -noupdate -radix hexadecimal /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/PCIESS_AXI_1_M_WSTRB
add wave -noupdate /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/PCIESS_AXI_1_M_WVALID
add wave -noupdate /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/PCIESS_AXI_1_M_WREADY
add wave -noupdate -divider {AXI Write Response Channel}
add wave -noupdate -radix hexadecimal /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/PCIESS_AXI_1_M_BID
add wave -noupdate -radix hexadecimal /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/PCIESS_AXI_1_M_BRESP
add wave -noupdate /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/PCIESS_AXI_1_M_BVALID
add wave -noupdate /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/PCIESS_AXI_1_M_BREADY
add wave -noupdate -divider {AXI Read Address Channel}
add wave -noupdate -radix hexadecimal /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/PCIESS_AXI_1_M_ARID
add wave -noupdate -radix hexadecimal /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/PCIESS_AXI_1_M_ARLEN
add wave -noupdate -radix hexadecimal /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/PCIESS_AXI_1_M_ARSIZE
add wave -noupdate -radix hexadecimal /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/PCIESS_AXI_1_M_ARBURST
add wave -noupdate /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/PCIESS_AXI_1_M_ARVALID
add wave -noupdate -radix hexadecimal /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/PCIESS_AXI_1_M_ARADDR
add wave -noupdate /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/PCIESS_AXI_1_M_ARREADY
add wave -noupdate -divider {AXI Read Data Channel}
add wave -noupdate -radix hexadecimal /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/PCIESS_AXI_1_M_RID
add wave -noupdate /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/PCIESS_AXI_1_M_RVALID
add wave -noupdate /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/PCIESS_AXI_1_M_RREADY
add wave -noupdate /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/PCIESS_AXI_1_M_RLAST
add wave -noupdate -radix hexadecimal /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/PCIESS_AXI_1_M_RDATA
add wave -noupdate -radix hexadecimal /PCIe_EP_Demo_tb/top_0/PCIe_EP_0/PCIESS_AXI_1_M_RRESP
add wave -noupdate -divider -height 30 {DDR4 SDRAM Interface}
add wave -noupdate /PCIe_EP_Demo_tb/DDR4_ACT_N
add wave -noupdate /PCIe_EP_Demo_tb/DDR4_CAS_N
add wave -noupdate /PCIe_EP_Demo_tb/DDR4_CKE
add wave -noupdate /PCIe_EP_Demo_tb/DDR4_CK
add wave -noupdate /PCIe_EP_Demo_tb/DDR4_CK_N
add wave -noupdate /PCIe_EP_Demo_tb/DDR4_CS_N
add wave -noupdate /PCIe_EP_Demo_tb/DDR4_ODT
add wave -noupdate /PCIe_EP_Demo_tb/DDR4_RAS_N
add wave -noupdate /PCIe_EP_Demo_tb/DDR4_RESET_N
add wave -noupdate /PCIe_EP_Demo_tb/DDR4_WE_N
add wave -noupdate /PCIe_EP_Demo_tb/DDR4_ADDR
add wave -noupdate /PCIe_EP_Demo_tb/DDR4_BA
add wave -noupdate /PCIe_EP_Demo_tb/DDR4_BG
add wave -noupdate /PCIe_EP_Demo_tb/DDR4_DM_N
add wave -noupdate /PCIe_EP_Demo_tb/DDR4_DQS
add wave -noupdate /PCIe_EP_Demo_tb/DDR4_DQS_N
add wave -noupdate /PCIe_EP_Demo_tb/DDR4_DQ
add wave -noupdate -divider -height 30 {DDR3 SDRAM Interface}
add wave -noupdate /PCIe_EP_Demo_tb/DDR3_RESET_N
add wave -noupdate /PCIe_EP_Demo_tb/DDR3_CK0
add wave -noupdate /PCIe_EP_Demo_tb/DDR3_CK0_N
add wave -noupdate /PCIe_EP_Demo_tb/DDR3_CKE
add wave -noupdate /PCIe_EP_Demo_tb/DDR3_CS_N
add wave -noupdate /PCIe_EP_Demo_tb/DDR3_RAS_N
add wave -noupdate /PCIe_EP_Demo_tb/DDR3_CAS_N
add wave -noupdate /PCIe_EP_Demo_tb/DDR3_WE_N
add wave -noupdate /PCIe_EP_Demo_tb/DDR3_ODT
add wave -noupdate /PCIe_EP_Demo_tb/DDR3_BA
add wave -noupdate /PCIe_EP_Demo_tb/DDR3_A
add wave -noupdate /PCIe_EP_Demo_tb/DDR3_DM
add wave -noupdate /PCIe_EP_Demo_tb/DDR3_DQ
add wave -noupdate /PCIe_EP_Demo_tb/DDR3_DQS
add wave -noupdate /PCIe_EP_Demo_tb/DDR3_DQS_N
add wave -noupdate -divider {Throughput counters}
add wave -noupdate -radix decimal /PCIe_EP_Demo_tb/top_0/CoreDMA_IO_CTRL_0/axi_io_ctrl_0/clk_count1
add wave -noupdate -radix decimal /PCIe_EP_Demo_tb/top_0/CoreDMA_IO_CTRL_0/axi_io_ctrl_0/clk_count2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {12489157 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 268
configure wave -valuecolwidth 84
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {18900 ns}
