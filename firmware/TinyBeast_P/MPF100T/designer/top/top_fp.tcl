new_project \
         -name {top} \
         -location {D:\Bitbucket\se50p\Libero_Project\PCIe_EP_Demo_SE50p_v12p3\designer\top\top_fp} \
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
