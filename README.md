# 星眸多算子边缘感知系统

面向2026全国大学生嵌入式芯片与系统设计竞赛FPGA赛道，目标平台为易灵思VF-Ti60F225。
技术路线：摄像头采集→灰度化→滤波→边缘检测→HDMI显示；扩展多算子切换、自适应阈值、彩色叠加、OSD、延迟与资源测试。

M0流水灯基础验收PASS，M1独立HDMI基线PASS。**M2新Ti60F225I3相机→DDR→HDMI基础链路PASS**：离线构建/已约束STA通过；用户确认JTAG临时下载后AR0135实时取图，显示器识别1280×720@60Hz，连续10～15分钟正常，运动持续更新，无黑屏/闪屏/花屏/冻结/明显撕裂；未SPI Active/Flash。该结果是有限时段基础链路验收，DDR压力/全容量/温度/校准信号、复位/CDC、电气与冷启动仍待专项验证。旧Flash流水灯R3/R4风险和既有告警保留；P0其余需求待冻结，灰度化延期，M3～M7未开始。详见[M2实物验收报告](reports/m2_ar0135_ddr_hdmi_i3/ACCEPTANCE_REPORT.md)。

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
| rtl/、tb/、constraints/ | 后续源码、仿真与约束位置 |
| efinity/、scripts/、reports/ | 后续工程、脚本与验证报告位置 |

背景、状态、决定和交接以 docs/ 为统一事实源，自动调度仍以根 AGENTS.md 为准。原方案全文保留，当前操作遵守用户本轮授权范围。

[最小LED工作工程](efinity/m0_led_i3/LED_8bit_Test.xml)、[构建报告](reports/m0_led_i3/BUILD_REPORT.md)、[上板验收](reports/m0_led_i3/ACCEPTANCE_REPORT.md)和[器件/编译核查](docs/MINIMAL_REFERENCE_CHECK.md)记录本轮结果。厂商原始工程完全保留，未编写算法业务RTL，未自动下载或Flash固化。

Git分支main；M0独立提交范围已核查，实际提交哈希以git log为准。根.gitignore排除document、历史盘点和工程生成目录，保留关键reports。指导先解释目的，一次只给1～3个操作；实际下载与硬件现象需要用户确认。

[M1 HDMI工作工程](efinity/m1_hdmi_i3/Ti60_HDMI_1080P_Test.xml)、[离线构建报告](reports/m1_hdmi_i3/BUILD_REPORT.md)、[管脚与时钟核查](reports/m1_hdmi_i3/PIN_CLOCK_CHECK.md)、[复位与CDC边界](reports/m1_hdmi_i3/CDC_RESET_REVIEW.md)记录1080p60厂商例程迁移结果。原厂六份RTL保持不变；离线阶段未下载。本轮用户已完成JTAG临时下载，未SPI Active/Flash固化，代理未操作硬件、未接入AR0135。本轮验收收尾创建独立Git提交，哈希以git log为准。详见[M1实物验收报告](reports/m1_hdmi_i3/ACCEPTANCE_REPORT.md)与[最终实现审计](reports/m1_hdmi_i3/FINAL_IMPLEMENTATION_AUDIT.md)。

[M2工作工程](efinity/m2_ar0135_ddr_hdmi_i3/Ti60_Demo.xml)、[构建验收](reports/m2_ar0135_ddr_hdmi_i3/BUILD_REPORT.md)、[DDR/IP参数对照](reports/m2_ar0135_ddr_hdmi_i3/DDR_IP_MIGRATION.md)、[最终实现绑定](reports/m2_ar0135_ddr_hdmi_i3/FINAL_IMPLEMENTATION_BINDING.md)记录本轮离线结果。Samsung K4B4G1646E-BYMA（512MiB）按用户实物文字确认；新M2 I3镜像已由用户JTAG功能验收，代理未操作硬件、未重编译，不灰度化/Sobel。当前工程XML及附带IP有再生成差异，不能宣称当前全部输入等于既有已编译构建；主会话独立核查源快照和提交范围。用户已授权独立M2提交，真实提交状态/hash以git log为准。

[M2历史上板前审查](reports/m2_ar0135_ddr_hdmi_i3/preboard_release/RELEASE_REVIEW.md)保留告警/接线/冷启动边界；[当前实物验收](reports/m2_ar0135_ddr_hdmi_i3/ACCEPTANCE_REPORT.md)与[用户文字反馈](reports/m2_ar0135_ddr_hdmi_i3/jtag_user_report.txt)记录新I3基础链路PASS。
