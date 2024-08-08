open_project -project {D:\se50p\SE_50_P_BSP\Libero\PCIe_Gen2_EP_Demo_SE50p_MPF100T_v2021.2\designer\top\top_fp\top.pro}\
         -connect_programmers {FALSE}
load_programming_data \
    -name {MPF100T} \
    -fpga {D:\se50p\SE_50_P_BSP\Libero\PCIe_Gen2_EP_Demo_SE50p_MPF100T_v2021.2\designer\top\top.map} \
    -header {D:\se50p\SE_50_P_BSP\Libero\PCIe_Gen2_EP_Demo_SE50p_MPF100T_v2021.2\designer\top\top.hdr} \
    -snvm {D:\se50p\SE_50_P_BSP\Libero\PCIe_Gen2_EP_Demo_SE50p_MPF100T_v2021.2\designer\top\top_snvm.efc} \
    -spm {D:\se50p\SE_50_P_BSP\Libero\PCIe_Gen2_EP_Demo_SE50p_MPF100T_v2021.2\designer\top\top.spm} \
    -dca {D:\se50p\SE_50_P_BSP\Libero\PCIe_Gen2_EP_Demo_SE50p_MPF100T_v2021.2\designer\top\top.dca}
export_single_ppd \
    -name {MPF100T} \
    -file {D:\se50p\SE_50_P_BSP\Libero\PCIe_Gen2_EP_Demo_SE50p_MPF100T_v2021.2\designer\top\top.ppd}

save_project
close_project
