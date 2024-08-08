new_project \
         -name {top} \
         -location {C:\Users\sergey.dydykin\Desktop\SoM3_test_package\MPF100T_Sources_wo_DDR_extclk\designer\top\top_fp} \
         -mode {chain} \
         -connect_programmers {FALSE}
add_actel_device \
         -device {MPF100T} \
         -name {MPF100T}
enable_device \
         -name {MPF100T} \
         -enable {TRUE}
save_project
close_project
