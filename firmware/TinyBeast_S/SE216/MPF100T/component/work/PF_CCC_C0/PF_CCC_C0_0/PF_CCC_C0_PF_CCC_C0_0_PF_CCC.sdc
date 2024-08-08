set_component PF_CCC_C0_PF_CCC_C0_0_PF_CCC
# Microsemi Corp.
# Date: 2021-Sep-20 17:07:39
#

# Base clock for PLL #0
create_clock -period 20 [ get_pins { pll_inst_0/REF_CLK_0 } ]
create_generated_clock -divide_by 1 -source [ get_pins { pll_inst_0/REF_CLK_0 } ] -phase 0 [ get_pins { pll_inst_0/OUT0 } ]
create_generated_clock -divide_by 1 -source [ get_pins { pll_inst_0/REF_CLK_0 } ] -phase 45 [ get_pins { pll_inst_0/OUT1 } ]
