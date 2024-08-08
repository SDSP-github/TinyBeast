# Microsemi Corp.
# Date: 2023-Jan-04 07:23:31
# This file was generated based on the following SDC source files:
#   D:/se50p/SE_50_P_BSP/Libero/PCIe_Gen2_EP_Demo_SE50p_MPF100T_v2021.2/component/work/AXI4_Interconnect/AXI4_Interconnect_0/AXI4_Interconnect.sdc
#   D:/se50p/SE_50_P_BSP/Libero/PCIe_Gen2_EP_Demo_SE50p_MPF100T_v2021.2/component/work/CoreAXI4_Lite/CoreAXI4_Lite_0/CoreAXI4_Lite.sdc
#   D:/se50p/SE_50_P_BSP/Libero/PCIe_Gen2_EP_Demo_SE50p_MPF100T_v2021.2/component/work/CLK_DIV2/CLK_DIV2_0/CLK_DIV2_CLK_DIV2_0_PF_CLK_DIV.sdc
#   D:/se50p/SE_50_P_BSP/Libero/PCIe_Gen2_EP_Demo_SE50p_MPF100T_v2021.2/component/work/PCIe_TX_PLL/PCIe_TX_PLL_0/PCIe_TX_PLL_PCIe_TX_PLL_0_PF_TX_PLL.sdc
#   D:/se50p/SE_50_P_BSP/Libero/PCIe_Gen2_EP_Demo_SE50p_MPF100T_v2021.2/component/work/PCIe_EP/PCIex4_0/PCIe_EP_PCIex4_0_PF_PCIE.sdc
#   D:/se50p/SE_50_P_BSP/Libero/PCIe_Gen2_EP_Demo_SE50p_MPF100T_v2021.2/component/work/PF_CCC_C0/PF_CCC_C0_0/PF_CCC_C0_PF_CCC_C0_0_PF_CCC.sdc
#   D:/se50p/SE_50_P_BSP/Libero/PCIe_Gen2_EP_Demo_SE50p_MPF100T_v2021.2/component/work/PF_DDR4_SS/PF_DDR4_SS.sdc
#   D:/se50p/SE_50_P_BSP/Libero/PCIe_Gen2_EP_Demo_SE50p_MPF100T_v2021.2/component/work/PF_DDR4_SS/CCC_0/PF_DDR4_SS_CCC_0_PF_CCC.sdc
#   D:/se50p/SE_50_P_BSP/Libero/PCIe_Gen2_EP_Demo_SE50p_MPF100T_v2021.2/component/work/PF_DDR4_SS/DLL_0/PF_DDR4_SS_DLL_0_PF_CCC.sdc
#   D:/Microsemi/Libero_SoC_v2021.2/Designer/data/aPA5M/cores/constraints/osc_rc160mhz.sdc
#

create_clock -name {REF_CLK_PAD_P} -period 10 [ get_ports { REF_CLK_PAD_P } ]
create_clock -name {PCIe_EP_0/PCIe_TX_PLL_0/PCIe_TX_PLL_0/txpll_isnt_0/DIV_CLK} -period 8 [ get_pins { PCIe_EP_0/PCIe_TX_PLL_0/PCIe_TX_PLL_0/txpll_isnt_0/DIV_CLK } ]
create_clock -name {REF_CLK_0} -period 30.003 [ get_ports { REF_CLK_0 } ]
create_clock -name {PCIe_EP_0/PCIe_TL_CLK_0/OSC_160MHz_0/OSC_160MHz_0/I_OSC_160/CLK} -period 6.25 [ get_pins { PCIe_EP_0/PCIe_TL_CLK_0/OSC_160MHz_0/OSC_160MHz_0/I_OSC_160/CLK } ]
create_generated_clock -name {PCIe_EP_0/PCIe_TL_CLK_0/CLK_DIV2_0/CLK_DIV2_0/I_CD/Y_DIV} -divide_by 2 -source [ get_pins { PCIe_EP_0/PCIe_TL_CLK_0/CLK_DIV2_0/CLK_DIV2_0/I_CD/A } ] [ get_pins { PCIe_EP_0/PCIe_TL_CLK_0/CLK_DIV2_0/CLK_DIV2_0/I_CD/Y_DIV } ]
create_generated_clock -name {PF_CCC_C0_0/PF_CCC_C0_0/pll_inst_0/OUT0} -multiply_by 1500149999 -divide_by 1000000000 -source [ get_pins { PF_CCC_C0_0/PF_CCC_C0_0/pll_inst_0/REF_CLK_0 } ] -phase 0 [ get_pins { PF_CCC_C0_0/PF_CCC_C0_0/pll_inst_0/OUT0 } ]
create_generated_clock -name {PF_DDR4_SS_0/CCC_0/pll_inst_0/OUT0} -multiply_by 16 -source [ get_pins { PF_DDR4_SS_0/CCC_0/pll_inst_0/REF_CLK_0 } ] -phase 0 [ get_pins { PF_DDR4_SS_0/CCC_0/pll_inst_0/OUT0 } ]
create_generated_clock -name {PF_DDR4_SS_0/CCC_0/pll_inst_0/OUT1} -multiply_by 4 -source [ get_pins { PF_DDR4_SS_0/CCC_0/pll_inst_0/REF_CLK_0 } ] -phase 0 [ get_pins { PF_DDR4_SS_0/CCC_0/pll_inst_0/OUT1 } ]
create_generated_clock -name {PF_DDR4_SS_0/CCC_0/pll_inst_0/OUT2} -multiply_by 16 -source [ get_pins { PF_DDR4_SS_0/CCC_0/pll_inst_0/REF_CLK_0 } ] -phase 0 [ get_pins { PF_DDR4_SS_0/CCC_0/pll_inst_0/OUT2 } ]
create_generated_clock -name {PF_DDR4_SS_0/CCC_0/pll_inst_0/OUT3} -multiply_by 16 -source [ get_pins { PF_DDR4_SS_0/CCC_0/pll_inst_0/REF_CLK_0 } ] -phase 0 [ get_pins { PF_DDR4_SS_0/CCC_0/pll_inst_0/OUT3 } ]
set_false_path -through [ get_nets { AXI4_Interconnect_0/ARESETN* } ]
set_false_path -from [ get_cells { AXI4_Interconnect_0/*/SlvConvertor_loop[*].slvcnv/slvCDC/genblk1*/rdGrayCounter*/cntGray* } ] -to [ get_cells { AXI4_Interconnect_0/*/SlvConvertor_loop[*].slvcnv/slvCDC/genblk1*/rdPtr_s1* } ]
set_false_path -from [ get_cells { AXI4_Interconnect_0/*/SlvConvertor_loop[*].slvcnv/slvCDC/genblk1*/wrGrayCounter*/cntGray* } ] -to [ get_cells { AXI4_Interconnect_0/*/SlvConvertor_loop[*].slvcnv/slvCDC/genblk1*/wrPtr_s1* } ]
set_false_path -through [ get_nets { CoreDMA_IO_CTRL_0/CoreAXI4_Lite_0/ARESETN* } ]
set_false_path -to [ get_pins { PCIe_EP_0/PCIex4_0/PCIE_1/INTERRUPT[0] PCIe_EP_0/PCIex4_0/PCIE_1/INTERRUPT[1] PCIe_EP_0/PCIex4_0/PCIE_1/INTERRUPT[2] PCIe_EP_0/PCIex4_0/PCIE_1/INTERRUPT[3] PCIe_EP_0/PCIex4_0/PCIE_1/INTERRUPT[4] PCIe_EP_0/PCIex4_0/PCIE_1/INTERRUPT[5] PCIe_EP_0/PCIex4_0/PCIE_1/INTERRUPT[6] PCIe_EP_0/PCIex4_0/PCIE_1/INTERRUPT[7] PCIe_EP_0/PCIex4_0/PCIE_1/WAKEREQ PCIe_EP_0/PCIex4_0/PCIE_1/MPERST_N } ]
set_false_path -from [ get_pins { PCIe_EP_0/PCIex4_0/PCIE_1/TL_CLK } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/*/I_IOD_*/ARST_N } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_*_CTRL/I_LANECTRL/HS_IO_CLK_PAUSE } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANECTRL_ADDR_CMD_0/I_LANECTRL*/HS_IO_CLK_PAUSE } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/*/I_IOD_*/RX_SYNC_RST* } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/*/I_IOD_*/DELAY_LINE_MOVE } ]
set_false_path -through [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/*/I_IOD_*/DELAY_LINE_OUT_OF_RANGE } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_0_CTRL/I_LANECTRL/DDR_READ } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_0_CTRL/I_LANECTRL/RESET } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_0_CTRL/I_LANECTRL/DELAY_LINE_DIRECTION } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_0_CTRL/I_LANECTRL/DELAY_LINE_MOVE } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_0_CTRL/I_LANECTRL/DELAY_LINE_LOAD PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_0_CTRL/I_LANECTRL/DELAY_LINE_SEL } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_0_CTRL/I_LANECTRL/SWITCH } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_0_CTRL/I_LANECTRL/READ_CLK_SEL[2] } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_0_CTRL/I_LANECTRL/DLL_CODE[0] } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_0_CTRL/I_LANECTRL/DLL_CODE[1] } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_0_CTRL/I_LANECTRL/DLL_CODE[2] } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_0_CTRL/I_LANECTRL/DLL_CODE[3] } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_0_CTRL/I_LANECTRL/DLL_CODE[4] } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_0_CTRL/I_LANECTRL/DLL_CODE[5] } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_0_CTRL/I_LANECTRL/DLL_CODE[6] } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_0_CTRL/I_LANECTRL/DLL_CODE[7] } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_1_CTRL/I_LANECTRL/DDR_READ } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_1_CTRL/I_LANECTRL/RESET } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_1_CTRL/I_LANECTRL/DELAY_LINE_DIRECTION } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_1_CTRL/I_LANECTRL/DELAY_LINE_MOVE } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_1_CTRL/I_LANECTRL/DELAY_LINE_LOAD PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_1_CTRL/I_LANECTRL/DELAY_LINE_SEL } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_1_CTRL/I_LANECTRL/SWITCH } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_1_CTRL/I_LANECTRL/READ_CLK_SEL[2] } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_1_CTRL/I_LANECTRL/DLL_CODE[0] } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_1_CTRL/I_LANECTRL/DLL_CODE[1] } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_1_CTRL/I_LANECTRL/DLL_CODE[2] } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_1_CTRL/I_LANECTRL/DLL_CODE[3] } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_1_CTRL/I_LANECTRL/DLL_CODE[4] } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_1_CTRL/I_LANECTRL/DLL_CODE[5] } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_1_CTRL/I_LANECTRL/DLL_CODE[6] } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/LANE_1_CTRL/I_LANECTRL/DLL_CODE[7] } ]
set_false_path -through [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/*/I_*FEEDBACK*/Y } ]
set_false_path -through [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/OB_DIFF_CK0/Y } ]
set_false_path -through [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/OB_A_12/Y } ]
set_false_path -through [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/*/I_TRIBUFF_*/D } ]
set_false_path -through [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/*/I_TRIBUFF_*/E } ]
set_false_path -through [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/*/I_BIBUF*/D } ]
set_false_path -through [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/*/I_BIBUF*/E } ]
set_false_path -through [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/*/I_BIBUF*/Y } ]
set_false_path -through [ get_pins { PF_DDR4_SS_0/DDRPHY_BLK_0/*/I_BIBUF_DIFF_DQS_*/YN } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/CCC_0/pll_inst_0/PHASE_OUT0_SEL } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/CCC_0/pll_inst_0/PHASE_OUT2_SEL } ]
set_false_path -to [ get_pins { PF_DDR4_SS_0/CCC_0/pll_inst_0/PHASE_OUT3_SEL } ]
set_multicycle_path -setup_only 2 -from [ get_cells { PF_DDR4_SS_0/DDRPHY_BLK_0/IOD_TRAINING_0/COREDDR_TIP_INT_U/TIP_CTRL_BLK/u_write_callibrator/select* } ]