set_device -family {PolarFire} -die {MPF100T} -speed {-1}
read_adl {D:\se50p\SE_50_P_BSP\Libero\PCIe_Gen2_EP_Demo_SE50p_MPF100T_v2021.2\designer\top\top.adl}
read_afl {D:\se50p\SE_50_P_BSP\Libero\PCIe_Gen2_EP_Demo_SE50p_MPF100T_v2021.2\designer\top\top.afl}
map_netlist
read_sdc {D:\se50p\SE_50_P_BSP\Libero\PCIe_Gen2_EP_Demo_SE50p_MPF100T_v2021.2\constraint\top_derived_constraints.sdc}
check_constraints {D:\se50p\SE_50_P_BSP\Libero\PCIe_Gen2_EP_Demo_SE50p_MPF100T_v2021.2\constraint\placer_sdc_errors.log}
write_sdc -mode layout {D:\se50p\SE_50_P_BSP\Libero\PCIe_Gen2_EP_Demo_SE50p_MPF100T_v2021.2\designer\top\place_route.sdc}
