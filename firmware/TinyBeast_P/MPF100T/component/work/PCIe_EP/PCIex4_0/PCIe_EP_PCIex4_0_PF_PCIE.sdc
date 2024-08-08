set_component PCIe_EP_PCIex4_0_PF_PCIE
# Microsemi Corp.
# Date: 2022-Dec-06 10:15:55
#

set_false_path -to [ get_pins { PCIE_1/INTERRUPT[0] PCIE_1/INTERRUPT[1] PCIE_1/INTERRUPT[2] PCIE_1/INTERRUPT[3] PCIE_1/INTERRUPT[4] PCIE_1/INTERRUPT[5] PCIE_1/INTERRUPT[6] PCIE_1/INTERRUPT[7] PCIE_1/WAKEREQ PCIE_1/MPERST_N } ]
set_false_path -from [ get_pins { PCIE_1/TL_CLK } ]