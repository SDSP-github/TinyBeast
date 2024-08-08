# ===========================================================
# Created by Microsemi SmartDesign Mon Sep 13 17:39:39 2021
# 
# Warning: Do not modify this file, it may lead to unexpected 
#          simulation failures in your design.
#
# ===========================================================

if {$tcl_platform(os) == "Linux"} {
  exec "$env(ACTEL_SW_DIR)/bin64/bfmtovec"   -in PCIe_EP_PCIex4_0_PF_PCIE_PCIE_1_user.bfm   -out PCIE_1.vec
} else {
  exec "$env(ACTEL_SW_DIR)/bin64/bfmtovec.exe"   -in PCIe_EP_PCIex4_0_PF_PCIE_PCIE_1_user.bfm   -out PCIE_1.vec
}
