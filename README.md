# 星眸多算子边缘感知系统

面向2026全国大学生嵌入式芯片与系统设计竞赛FPGA赛道，目标平台为易灵思VF-Ti60F225。
技术路线：摄像头采集→灰度化→滤波→边缘检测→HDMI显示；扩展多算子切换、自适应阈值、彩色叠加、OSD、延迟与资源测试。

M0/M1/M2基础链路实物PASS；M2为新Ti60F225I3相机→DDR→HDMI，用户确认720p60、10～15分钟定性正常，未SPI Active/Flash。**M3 m3_sobel_core实物功能PASS、图像质量待调优；M3.1显示模式与阈值控制开始开发。** 两行缓存、3×3窗口、Sobel/阈值与原灰度/边缘显示已实现，使用AR0135单色8位流。M4～M7未开始，M4剩余范围和P0其余需求待确认。DDR压力/全容量/温度/校准、复位/CDC、电气/冷启动以及旧Flash R3/R4风险保留。

[M3工程](efinity/m3_sobel_core_i3/Ti60_Demo.xml)、[五个算法模块](rtl/m3_sobel_core/sobel_stream_top.v)、[M3离线报告](reports/m3_sobel_core_i3/BUILD_REPORT.md)、[机器验收证据](reports/m3_sobel_core_i3/ACCEPTANCE.json)、[验收脚本](scripts/m3_sobel_core_validate.py)。新工程来自M2已编译源快照，保留74.4MHz像素PLL、720p及原外围参数；默认阈值64/二值显示。本轮没有Programmer、下载、Flash或Git暂存/提交。

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
| efinity/、scripts/、reports/ | M0～M3工程、可复验脚本与验证报告 |

背景、状态、决定和交接以 docs/ 为统一事实源，自动调度仍以根 AGENTS.md 为准。原方案全文保留，当前操作遵守用户本轮授权范围。

历史M0：[最小LED工作工程](efinity/m0_led_i3/LED_8bit_Test.xml)、[构建报告](reports/m0_led_i3/BUILD_REPORT.md)、[上板验收](reports/m0_led_i3/ACCEPTANCE_REPORT.md)和[器件/编译核查](docs/MINIMAL_REFERENCE_CHECK.md)。当时没有算法业务RTL，厂商原始工程保留，未自动下载或Flash固化。

当前分支feature/m3-sobel-core，父基线9a6d33db4dd3d5f6842cd43661a9a35409eadf1e；M3未暂存/提交。根.gitignore排除资料、缓存、波形和工程生成目录；.gitattributes保持M3源码/脚本/证据字节，避免换行转换破坏SHA绑定。指导先解释目的，一次只给1～3个操作；实际下载与硬件现象需要用户确认。

历史M1：[HDMI工作工程](efinity/m1_hdmi_i3/Ti60_HDMI_1080P_Test.xml)、[离线构建](reports/m1_hdmi_i3/BUILD_REPORT.md)、[管脚/时钟核查](reports/m1_hdmi_i3/PIN_CLOCK_CHECK.md)、[复位/CDC边界](reports/m1_hdmi_i3/CDC_RESET_REVIEW.md)记录1080p60迁移。原厂六份RTL保持，用户后来JTAG临时下载通过，未SPI Active/Flash，代理未操作硬件。详见[实物验收](reports/m1_hdmi_i3/ACCEPTANCE_REPORT.md)与[最终实现审计](reports/m1_hdmi_i3/FINAL_IMPLEMENTATION_AUDIT.md)。

历史M2：[工作工程](efinity/m2_ar0135_ddr_hdmi_i3/Ti60_Demo.xml)、[构建验收](reports/m2_ar0135_ddr_hdmi_i3/BUILD_REPORT.md)、[DDR/IP参数](reports/m2_ar0135_ddr_hdmi_i3/DDR_IP_MIGRATION.md)、[最终绑定](reports/m2_ar0135_ddr_hdmi_i3/FINAL_IMPLEMENTATION_BINDING.md)。Samsung K4B4G1646E-BYMA（512MiB）由用户实物文本确认，用户JTAG功能验收通过。M2归档时未实现Sobel；GUI再生成工作输入与已编译构建有差异，精确源基线见[SOURCE_BASELINE](reports/m2_ar0135_ddr_hdmi_i3/SOURCE_BASELINE.md)。本轮M3仅使用该已编译快照，未覆盖M2工作区。

[M2历史上板前审查](reports/m2_ar0135_ddr_hdmi_i3/preboard_release/RELEASE_REVIEW.md)保留告警/接线/冷启动边界；[当前实物验收](reports/m2_ar0135_ddr_hdmi_i3/ACCEPTANCE_REPORT.md)与[用户文字反馈](reports/m2_ar0135_ddr_hdmi_i3/jtag_user_report.txt)记录新I3基础链路PASS。
