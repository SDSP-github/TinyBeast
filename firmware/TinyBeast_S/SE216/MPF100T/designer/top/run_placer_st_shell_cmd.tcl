read_sdc -scenario "place_and_route" -netlist "optimized" -pin_separator "/" -ignore_errors {D:/SoM3_test_package/SE216_SoM3/SE216_SoM3_MPF100T_Sources_w_DDR_w_FMC/designer/top/place_route.sdc}
set_options -tdpr_scenario "place_and_route" 
save
set_options -analysis_scenario "place_and_route"
report -type combinational_loops -format xml {D:\SoM3_test_package\SE216_SoM3\SE216_SoM3_MPF100T_Sources_w_DDR_w_FMC\designer\top\top_layout_combinational_loops.xml}
report -type slack {D:\SoM3_test_package\SE216_SoM3\SE216_SoM3_MPF100T_Sources_w_DDR_w_FMC\designer\top\pinslacks.txt}
set coverage [report \
    -type     constraints_coverage \
    -format   xml \
    -slacks   no \
    {D:\SoM3_test_package\SE216_SoM3\SE216_SoM3_MPF100T_Sources_w_DDR_w_FMC\designer\top\top_place_and_route_constraint_coverage.xml}]
set reportfile {D:\SoM3_test_package\SE216_SoM3\SE216_SoM3_MPF100T_Sources_w_DDR_w_FMC\designer\top\coverage_placeandroute}
set fp [open $reportfile w]
puts $fp $coverage
close $fp