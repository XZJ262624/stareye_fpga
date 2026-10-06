# 星眸多算子边缘感知系统

面向2026全国大学生嵌入式芯片与系统设计竞赛FPGA赛道，目标平台为易灵思VF-Ti60F225。
技术路线：摄像头采集→灰度化→滤波→边缘检测→HDMI显示；扩展多算子切换、自适应阈值、彩色叠加、OSD、延迟与资源测试。

M0/M1/M2基础链路实物PASS；M2为新Ti60F225I3相机→DDR→HDMI，用户确认720p60、10～15分钟定性正常，未SPI Active/Flash。**M3 m3_sobel_core实物功能PASS、图像质量待调优；M3.1离线PASS且用户确认上板阈值调节正常；M3.2模块、整机离线与当前条件下实物验收PASS。** 两行缓存、3×3窗口、Sobel/阈值与原灰度/边缘显示已实现，使用AR0135单色8位流。M4离线仿真、完整I3编译、STA和实物功能验收PASS（保留已知首行异常）；M5～M7未开始，P0其余需求待确认。DDR压力/全容量/温度/校准、复位/CDC、电气/冷启动以及旧Flash R3/R4风险保留。

[M3工程](efinity/m3_sobel_core_i3/Ti60_Demo.xml)、[五个算法模块](rtl/m3_sobel_core/sobel_stream_top.v)、[M3离线报告](reports/m3_sobel_core_i3/BUILD_REPORT.md)、[机器验收证据](reports/m3_sobel_core_i3/ACCEPTANCE.json)、[验收脚本](scripts/m3_sobel_core_validate.py)。新工程来自M2已编译源快照，保留74.4MHz像素PLL、720p及原外围参数；默认阈值64/二值显示。该M3离线轮次没有Programmer、下载、Flash或Git暂存/提交；后续各阶段授权与结果见相应报告。

| 路径 | 用途 |
| --- | --- |
| AGENTS.md | 根目录自动调度规则，保持原样 |
| docs/AI_COLLABORATION_PLAN.md | 原协作方案全文完整迁移 |
| docs/PROJECT_BRIEF.md | 稳定背景、用户知识边界与待确认配置 |
| docs/MILESTONES.md | 阶段目标、验收与状态 |
| docs/STATUS.md | 当前状态、验证证据与 Git 检测 |
| docs/HANDOFF.md | 当前一次任务的统一八节交接单 |
| docs/DECISIONS.md | 已确定事实与决定 |
| document/ | 完整厂商资料、驱动、安装器与视频集合；保持原位，整个目录暂时不进入 Git |
| reference/competition/、reference/board/、reference/camera/、reference/examples/ | 后续比赛、板卡、摄像头与参考工程分类位置 |
| rtl/、tb/、constraints/ | M3算法源码、真实HDL/720p/mapped行RAM测试及约束位置 |
| efinity/、scripts/、reports/ | M0～M4工程、可复验脚本与验证报告 |

背景、状态、决定和交接以 docs/ 为统一事实源，自动调度仍以根 AGENTS.md 为准。原方案全文保留，当前操作遵守用户本轮授权范围。

历史M0：[最小LED工作工程](efinity/m0_led_i3/LED_8bit_Test.xml)、[构建报告](reports/m0_led_i3/BUILD_REPORT.md)、[上板验收](reports/m0_led_i3/ACCEPTANCE_REPORT.md)和[器件/编译核查](docs/MINIMAL_REFERENCE_CHECK.md)。当时没有算法业务RTL，厂商原始工程保留，未自动下载或Flash固化。

M3基线已提交7a9b448080fd6f1624c2ef37ee2eb267fed49c82；M3.1与M3.2按顺序独立归档。工程生成目录与镜像不提交，必要源输入与文本证据保留。

历史M1：[HDMI工作工程](efinity/m1_hdmi_i3/Ti60_HDMI_1080P_Test.xml)、[离线构建](reports/m1_hdmi_i3/BUILD_REPORT.md)、[管脚/时钟核查](reports/m1_hdmi_i3/PIN_CLOCK_CHECK.md)、[复位/CDC边界](reports/m1_hdmi_i3/CDC_RESET_REVIEW.md)记录1080p60迁移。原厂六份RTL保持，用户后来JTAG临时下载通过，未SPI Active/Flash，代理未操作硬件。详见[实物验收](reports/m1_hdmi_i3/ACCEPTANCE_REPORT.md)与[最终实现审计](reports/m1_hdmi_i3/FINAL_IMPLEMENTATION_AUDIT.md)。

历史M2：[工作工程](efinity/m2_ar0135_ddr_hdmi_i3/Ti60_Demo.xml)、[构建验收](reports/m2_ar0135_ddr_hdmi_i3/BUILD_REPORT.md)、[DDR/IP参数](reports/m2_ar0135_ddr_hdmi_i3/DDR_IP_MIGRATION.md)、[最终绑定](reports/m2_ar0135_ddr_hdmi_i3/FINAL_IMPLEMENTATION_BINDING.md)。Samsung K4B4G1646E-BYMA（512MiB）由用户实物文本确认，用户JTAG功能验收通过。M2归档时未实现Sobel；GUI再生成工作输入与已编译构建有差异，精确源基线见[SOURCE_BASELINE](reports/m2_ar0135_ddr_hdmi_i3/SOURCE_BASELINE.md)。本轮M3仅使用该已编译快照，未覆盖M2工作区。

[M2历史上板前审查](reports/m2_ar0135_ddr_hdmi_i3/preboard_release/RELEASE_REVIEW.md)保留告警/接线/冷启动边界；[当前实物验收](reports/m2_ar0135_ddr_hdmi_i3/ACCEPTANCE_REPORT.md)与[用户文字反馈](reports/m2_ar0135_ddr_hdmi_i3/jtag_user_report.txt)记录新I3基础链路PASS。

M3.1 offline PASS; user-confirmed hardware threshold control PASS. See [M3.1 report](reports/m31_sobel_controls_i3/BUILD_REPORT.md). M3 baseline commit: 7a9b448080fd6f1624c2ef37ee2eb267fed49c82.

M3.2: [实物验收](reports/m32_median_integration_i3/ACCEPTANCE_REPORT.md)、[构建与STA](reports/m32_median_integration_i3/BUILD_REPORT.md)。启用版最小setup/hold +0.194/+0.026 ns；实物长时观察不证明全部PVT稳定，旧Flash/R3/R4风险保留。该M3.2归档轮次分支为codex/m32-median-integration，当时停止在M3.2；当前M4状态见下文。

M3.1提交：742d8a461b36f5970f7caea04fb8f8c925fe8a02；后续独立M3.2提交为其直接子提交，ID以git log为准。

M4当前：[彩色叠加工程](efinity/m4_color_overlay_i3/Ti60_Demo.xml)、[构建与STA](reports/m4_color_overlay_i3/BUILD_REPORT.md)、[架构](reports/m4_color_overlay_i3/ARCHITECTURE.md)、[实物验收报告](reports/m4_color_overlay_i3/HARDWARE_ACCEPTANCE.md)。**M4离线仿真、完整I3编译、STA和实物功能验收PASS。RAW、MAG、BIN、OVERLAY模式、阈值控制、OSD、红色边缘、空间对齐、动态更新及720p60输出正常。厂商AR0135参考链路继承的固定首行冻结异常作为已接受的延期问题保留，不属于M4新增回归。**

厂商AR0135参考链路继承的固定首行冻结异常，用户已知并接受本阶段延期处理；待更换AR0135模块后复测。该问题尚未定位或修复。 状态DEFERRED；厂商原始参考bitstream在相同实物上也有该现象，不据此认定摄像头根因或承诺换模块能修复。最小setup/hold为+0.193/+0.023 ns；窄hold、跨PVT未严格证明及PLL复位/I/O/CDC边界继续保留。

当前分支codex/m4-color-overlay；本轮归档并独立提交，M3.2父提交为3424514afe1721dc000495673c0ca757ea1f6372，M4提交ID以git log为准。本轮不重新编译、Programmer、再次下载、Flash、继续诊断或M5；提交后停止，不合并main、不推送。
