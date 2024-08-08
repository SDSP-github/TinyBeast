set_device -family {PolarFire} -die {MPF100T} -speed {-1}
read_adl {D:\SoM3_test_package\SE216_SoM3\SE216_SoM3_MPF100T_Sources_w_DDR_w_FMC\designer\top\top.adl}
read_afl {D:\SoM3_test_package\SE216_SoM3\SE216_SoM3_MPF100T_Sources_w_DDR_w_FMC\designer\top\top.afl}
map_netlist
read_sdc {D:\SoM3_test_package\SE216_SoM3\SE216_SoM3_MPF100T_Sources_w_DDR_w_FMC\constraint\top_derived_constraints.sdc}
check_constraints {D:\SoM3_test_package\SE216_SoM3\SE216_SoM3_MPF100T_Sources_w_DDR_w_FMC\constraint\timing_sdc_errors.log}
write_sdc -mode smarttime {D:\SoM3_test_package\SE216_SoM3\SE216_SoM3_MPF100T_Sources_w_DDR_w_FMC\designer\top\timing_analysis.sdc}
