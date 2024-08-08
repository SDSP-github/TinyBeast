set_device \
    -fam PolarFire \
    -die PA5M100T \
    -pkg fcvg484
set_proj_dir \
    -path {D:\SoM3_test_package\SE216_SoM3\SE216_SoM3_MPF100T_Sources_w_DDR_w_FMC}
set_impl_dir \
    -path {D:\SoM3_test_package\SE216_SoM3\SE216_SoM3_MPF100T_Sources_w_DDR_w_FMC\designer\top}
set_is_relative_path \
    -value {FALSE}
set_root_path_dir \
    -path {}
set_first_stage \
    -address 00000000
set_second_stage \
    -uprom_address 00000000 \
    -snvm_address 00000000 \
    -spi_address 00000400 \
    -spi_binding spi_noauth \
    -ramBroadcast 1 \
    -spi_ClockDivider 0
set_override_file \
    -path {}
set_auto_calib_timeout \
    -value {3000}
