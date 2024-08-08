set_component PCIe_TX_PLL_PCIe_TX_PLL_0_PF_TX_PLL
# Microsemi Corp.
# Date: 2021-Feb-04 21:09:48
#

create_clock -period 10 [ get_pins { txpll_isnt_0/REF_CLK_P } ]
create_clock -period 8 [ get_pins { txpll_isnt_0/DIV_CLK } ]
