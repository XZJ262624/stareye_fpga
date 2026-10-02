# M1独立提交范围（2026-10-02）

分支main；父提交a8c39c93a06eeb0686cbb5c13fd44717d49195fa。用户已授权独立提交`chore: complete M1 HDMI baseline validation`。以下为提交前精确磁盘字节清单；M1工程/脚本/报告由.gitattributes保留字节，已核对暂存blob与哈希一致；项目Markdown换行规范化可能使总blob字节数略有不同。

合计 **90文件，932,583字节**；最大文件 `reports/m1_hdmi_i3/Ti60_HDMI_1080P_Test.timing.rpt`，109,053字节；无单文件达到1MiB。

排除bit/hex/outflow/work/缓存/临时/锁/二进制数据库、document/reference/tools、安装器/驱动/PDF/视频。既有.gitignore适用，无需更改，不全局忽略log/rpt/bin/hex。使用逐文件显式git add，不使用git add .。M0、AGENTS和厂商源保持原样。

验收：官方历史编译PASS；隔离最终I3 STA PASS；46个负向用例全部拒绝；用户JTAG及数分钟图案定性PASS，分辨率/刷新率和复位鲁棒性边界保留。新增AR0135接线前核查仅记录资料与安全门槛，不接入摄像头。

| 文件 | 磁盘字节 |
| --- | ---: |
| .gitattributes | 162 |
| README.md | 3,132 |
| docs/AR0135_PRECONNECT_CHECK.md | 3,807 |
| docs/DECISIONS.md | 7,522 |
| docs/HANDOFF.md | 3,715 |
| docs/MILESTONES.md | 2,950 |
| docs/PROJECT_BRIEF.md | 3,615 |
| docs/SOURCES.md | 16,809 |
| docs/STATUS.md | 27,169 |
| docs/TOOLCHAIN.md | 9,176 |
| efinity/m1_hdmi_i3/Ti60_HDMI_1080P_Test.peri.xml | 17,895 |
| efinity/m1_hdmi_i3/Ti60_HDMI_1080P_Test.xml | 7,504 |
| efinity/m1_hdmi_i3/Ti60_HDMI_1080P_Test_I3.sdc | 6,445 |
| efinity/m1_hdmi_i3/VIP_System.sdc | 4,406 |
| efinity/m1_hdmi_i3/src/Ti60_HDMI_1080P_Test.v | 2,982 |
| efinity/m1_hdmi_i3/src/hdmi_ip/rgb2dvi.v | 2,692 |
| efinity/m1_hdmi_i3/src/hdmi_ip/tmds_channel.v | 4,854 |
| efinity/m1_hdmi_i3/src/lcd_24bit_ip/lcd_display.v | 5,193 |
| efinity/m1_hdmi_i3/src/lcd_24bit_ip/lcd_driver.v | 4,056 |
| efinity/m1_hdmi_i3/src/lcd_24bit_ip/lcd_para.v | 3,838 |
| reports/m1_hdmi_i3/ACCEPTANCE_REPORT.md | 3,086 |
| reports/m1_hdmi_i3/BUILD_REPORT.md | 7,266 |
| reports/m1_hdmi_i3/CDC_RESET_REVIEW.md | 4,608 |
| reports/m1_hdmi_i3/CHANGE_SCOPE.md | 898 |
| reports/m1_hdmi_i3/COMMIT_SCOPE.md | 5,877 |
| reports/m1_hdmi_i3/FINAL_IMPLEMENTATION_AUDIT.md | 4,186 |
| reports/m1_hdmi_i3/LOCAL_MATERIALS.md | 1,852 |
| reports/m1_hdmi_i3/PIN_CLOCK_CHECK.md | 10,386 |
| reports/m1_hdmi_i3/Ti60_HDMI_1080P_Test.cdc.rpt | 296 |
| reports/m1_hdmi_i3/Ti60_HDMI_1080P_Test.dsp_control_sets.csv | 239 |
| reports/m1_hdmi_i3/Ti60_HDMI_1080P_Test.err.log | 135 |
| reports/m1_hdmi_i3/Ti60_HDMI_1080P_Test.hold_fixing.rpt | 120 |
| reports/m1_hdmi_i3/Ti60_HDMI_1080P_Test.interface.csv | 4,006 |
| reports/m1_hdmi_i3/Ti60_HDMI_1080P_Test.map.out | 21,073 |
| reports/m1_hdmi_i3/Ti60_HDMI_1080P_Test.map.rpt | 3,965 |
| reports/m1_hdmi_i3/Ti60_HDMI_1080P_Test.pgm.out | 1,991 |
| reports/m1_hdmi_i3/Ti60_HDMI_1080P_Test.pinout.csv | 10,936 |
| reports/m1_hdmi_i3/Ti60_HDMI_1080P_Test.pinout.rpt | 43,850 |
| reports/m1_hdmi_i3/Ti60_HDMI_1080P_Test.place.out | 12,551 |
| reports/m1_hdmi_i3/Ti60_HDMI_1080P_Test.place.rpt | 1,741 |
| reports/m1_hdmi_i3/Ti60_HDMI_1080P_Test.pnr.rpt | 1,468 |
| reports/m1_hdmi_i3/Ti60_HDMI_1080P_Test.pt.rpt | 20,049 |
| reports/m1_hdmi_i3/Ti60_HDMI_1080P_Test.pt.sdc | 6,445 |
| reports/m1_hdmi_i3/Ti60_HDMI_1080P_Test.pt_timing.rpt | 3,747 |
| reports/m1_hdmi_i3/Ti60_HDMI_1080P_Test.res.csv | 1,154 |
| reports/m1_hdmi_i3/Ti60_HDMI_1080P_Test.route.out | 12,612 |
| reports/m1_hdmi_i3/Ti60_HDMI_1080P_Test.route.rpt | 1,772 |
| reports/m1_hdmi_i3/Ti60_HDMI_1080P_Test.timing.rpt | 109,053 |
| reports/m1_hdmi_i3/Ti60_HDMI_1080P_Test.warn.log | 4,890 |
| reports/m1_hdmi_i3/artifact_manifest.json | 13,551 |
| reports/m1_hdmi_i3/bitstream.json | 387 |
| reports/m1_hdmi_i3/compile.log | 1,183 |
| reports/m1_hdmi_i3/configure.log | 1,559 |
| reports/m1_hdmi_i3/dsp_warning_evidence.txt | 3,327 |
| reports/m1_hdmi_i3/final_implementation_binding.json | 70,592 |
| reports/m1_hdmi_i3/final_validation.json | 985 |
| reports/m1_hdmi_i3/generated_ignore.txt | 107 |
| reports/m1_hdmi_i3/git_cached_check.json | 121 |
| reports/m1_hdmi_i3/git_cached_stat.txt | 0 |
| reports/m1_hdmi_i3/git_status.txt | 442 |
| reports/m1_hdmi_i3/isolated_sta.log | 9,043 |
| reports/m1_hdmi_i3/jtag_user_report.txt | 517 |
| reports/m1_hdmi_i3/m1_hdmi_i3_check_timing.rpt | 1,768 |
| reports/m1_hdmi_i3/m1_hdmi_i3_clocks.rpt | 1,315 |
| reports/m1_hdmi_i3/m1_hdmi_i3_internal_hold.rpt | 31,571 |
| reports/m1_hdmi_i3/m1_hdmi_i3_internal_setup.rpt | 63,228 |
| reports/m1_hdmi_i3/m1_hdmi_i3_serializer_hold.rpt | 103,987 |
| reports/m1_hdmi_i3/m1_hdmi_i3_serializer_setup.rpt | 103,764 |
| reports/m1_hdmi_i3/negative_fixture_results.json | 3,890 |
| reports/m1_hdmi_i3/original_after.json | 16,586 |
| reports/m1_hdmi_i3/original_before.json | 16,586 |
| reports/m1_hdmi_i3/original_diff.json | 133 |
| reports/m1_hdmi_i3/root_review.json | 2,670 |
| reports/m1_hdmi_i3/rtl_integrity.json | 1,524 |
| reports/m1_hdmi_i3/stage_exitcodes.json | 1,284 |
| reports/m1_hdmi_i3/timing_audit.log | 10,806 |
| reports/m1_hdmi_i3/warning_summary.json | 262 |
| scripts/m1_hdmi_i3_archive.py | 2,957 |
| scripts/m1_hdmi_i3_compile.bat | 177 |
| scripts/m1_hdmi_i3_configure.bat | 148 |
| scripts/m1_hdmi_i3_configure.py | 1,496 |
| scripts/m1_hdmi_i3_evidence.py | 7,364 |
| scripts/m1_hdmi_i3_integrity.py | 550 |
| scripts/m1_hdmi_i3_isolated_audit.py | 4,142 |
| scripts/m1_hdmi_i3_manifest.ps1 | 1,334 |
| scripts/m1_hdmi_i3_root_review.py | 6,848 |
| scripts/m1_hdmi_i3_test_evidence.py | 3,710 |
| scripts/m1_hdmi_i3_timing_audit.bat | 115 |
| scripts/m1_hdmi_i3_timing_audit.tcl | 718 |
| scripts/m1_hdmi_i3_validate.py | 3,662 |
