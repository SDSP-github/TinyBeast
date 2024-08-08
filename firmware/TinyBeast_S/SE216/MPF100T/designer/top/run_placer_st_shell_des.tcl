set_device \
    -family  PolarFire \
    -die     PA5M100T \
    -package fcvg484 \
    -speed   -1 \
    -tempr   {IND} \
    -voltr   {IND}
set_def {VOLTAGE} {1.0}
set_def {VCCI_1.2_VOLTR} {EXT}
set_def {VCCI_1.5_VOLTR} {EXT}
set_def {VCCI_1.8_VOLTR} {EXT}
set_def {VCCI_2.5_VOLTR} {EXT}
set_def {VCCI_3.3_VOLTR} {EXT}
set_def {RTG4_MITIGATION_ON} {0}
set_def USE_CONSTRAINTS_FLOW 1
set_def NETLIST_TYPE EDIF
set_name top
set_workdir {D:\SoM3_test_package\SE216_SoM3\SE216_SoM3_MPF100T_Sources_w_DDR_w_FMC\designer\top}
set_log     {D:\SoM3_test_package\SE216_SoM3\SE216_SoM3_MPF100T_Sources_w_DDR_w_FMC\designer\top\top_sdc.log}
set_design_state pre_layout
