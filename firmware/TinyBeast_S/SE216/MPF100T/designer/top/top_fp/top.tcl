open_project -project {D:\SoM3_test_package\SE216_SoM3\SE216_SoM3_MPF100T_Sources_w_DDR_w_FMC\designer\top\top_fp\top.pro}\
         -connect_programmers {FALSE}
load_programming_data \
    -name {MPF100T} \
    -fpga {D:\SoM3_test_package\SE216_SoM3\SE216_SoM3_MPF100T_Sources_w_DDR_w_FMC\designer\top\top.map} \
    -header {D:\SoM3_test_package\SE216_SoM3\SE216_SoM3_MPF100T_Sources_w_DDR_w_FMC\designer\top\top.hdr} \
    -snvm {D:\SoM3_test_package\SE216_SoM3\SE216_SoM3_MPF100T_Sources_w_DDR_w_FMC\designer\top\top_snvm.efc} \
    -spm {D:\SoM3_test_package\SE216_SoM3\SE216_SoM3_MPF100T_Sources_w_DDR_w_FMC\designer\top\top.spm} \
    -dca {D:\SoM3_test_package\SE216_SoM3\SE216_SoM3_MPF100T_Sources_w_DDR_w_FMC\designer\top\top.dca}
export_single_ppd \
    -name {MPF100T} \
    -file {D:/SoM3_test_package/SE216_SoM3/SE216_SoM3_MPF100T_ProgrammingJob_w_DDR_w_FMC/tempExport\top.ppd}

save_project
close_project
