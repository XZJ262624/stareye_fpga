# 星眸多算子边缘感知系统

面向2026全国大学生嵌入式芯片与系统设计竞赛FPGA赛道，目标平台为易灵思VF-Ti60F225。
技术路线：摄像头采集→灰度化→滤波→边缘检测→HDMI显示；扩展多算子切换、自适应阈值、彩色叠加、OSD、延迟与资源测试。

M0基础验收通过：I3完整编译PASS、用户报告JTAG配置PASS及流水灯功能定性PASS。断电后仍有流水灯，但用户此前已固化官方例程，不能证明本轮I3 bitstream的持久性；本轮未SPI Active/Flash固化。 P0其余需求待冻结，M1～M7未开始。

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
