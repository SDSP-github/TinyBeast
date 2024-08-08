read_sdc -scenario "place_and_route" -netlist "optimized" -pin_separator "/" -ignore_errors {D:/se50p/SE_50_P_BSP/Libero/PCIe_Gen2_EP_Demo_SE50p_MPF100T_v2021.2/designer/top/place_route.sdc}
set_options -tdpr_scenario "place_and_route" 
save
set_options -analysis_scenario "place_and_route"
report -type combinational_loops -format xml {D:\se50p\SE_50_P_BSP\Libero\PCIe_Gen2_EP_Demo_SE50p_MPF100T_v2021.2\designer\top\top_layout_combinational_loops.xml}
report -type slack {D:\se50p\SE_50_P_BSP\Libero\PCIe_Gen2_EP_Demo_SE50p_MPF100T_v2021.2\designer\top\pinslacks.txt}
set coverage [report \
    -type     constraints_coverage \
    -format   xml \
    -slacks   no \
    {D:\se50p\SE_50_P_BSP\Libero\PCIe_Gen2_EP_Demo_SE50p_MPF100T_v2021.2\designer\top\top_place_and_route_constraint_coverage.xml}]
set reportfile {D:\se50p\SE_50_P_BSP\Libero\PCIe_Gen2_EP_Demo_SE50p_MPF100T_v2021.2\designer\top\coverage_placeandroute}
set fp [open $reportfile w]
puts $fp $coverage
close $fp