
set max_timing_multi_corner [report \
    -type     timing \
    -analysis max \
    -multi_corner yes \
    -format   text \
    {top_timing_r56_s72.rpt}]
set max_timing_violations_multi_corner [report \
    -type     timing_violations \
    -analysis max \
    -multi_corner yes \
    -format   text \
    -use_slack_threshold no \
    -max_paths 100 \
    {top_timing_violations_max_r56_s72.rpt}]
set min_timing_violations_multi_corner [report \
    -type     timing_violations \
    -analysis min \
    -multi_corner yes \
    -format   text \
    -use_slack_threshold no \
    -max_paths 100 \
    {top_timing_violations_min_r56_s72.rpt}]
set has_violations {top_has_violations}
set fp [open $has_violations w]
puts $fp "_max_timing_violations_multi_corner $max_timing_violations_multi_corner"
puts $fp "_max_timing_multi_corner $max_timing_multi_corner"
puts $fp "_min_timing_violations_multi_corner $min_timing_violations_multi_corner"
close $fp
