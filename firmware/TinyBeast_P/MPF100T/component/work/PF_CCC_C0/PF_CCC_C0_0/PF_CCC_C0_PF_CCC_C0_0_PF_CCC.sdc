set_component PF_CCC_C0_PF_CCC_C0_0_PF_CCC
# Microsemi Corp.
# Date: 2020-Aug-26 17:11:21
#

# Base clock for PLL #0
create_clock -period 30.003 [ get_pins { pll_inst_0/REF_CLK_0 } ]
create_generated_clock -multiply_by 1500149999 -divide_by 1000000000 -source [ get_pins { pll_inst_0/REF_CLK_0 } ] -phase 0 [ get_pins { pll_inst_0/OUT0 } ]
