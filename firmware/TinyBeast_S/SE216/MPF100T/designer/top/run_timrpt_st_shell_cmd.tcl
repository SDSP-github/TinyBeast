read_sdc -scenario "timing_analysis" -netlist "optimized" -pin_separator "/" -ignore_errors {D:/SoM3_test_package/SE216_SoM3/SE216_SoM3_MPF100T_Sources_w_DDR_w_FMC/designer/top/timing_analysis.sdc}
set_options -analysis_scenario "timing_analysis" 
save
source {top_run_timrpt_st_shell_txt.tcl}
