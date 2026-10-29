# 星眸多算子边缘感知系统

面向2026全国大学生嵌入式芯片与系统设计竞赛FPGA赛道，目标平台为易灵思VF-Ti60F225。
技术路线：摄像头采集→灰度化→滤波→边缘检测→HDMI显示；扩展多算子切换、自适应阈值、彩色叠加、OSD、延迟与资源测试。

M0/M1/M2基础链路实物PASS；M2为新Ti60F225I3相机→DDR→HDMI，用户确认720p60、10～15分钟定性正常，未SPI Active/Flash。**M3 m3_sobel_core实物功能PASS、图像质量待调优；M3.1离线PASS且用户确认上板阈值调节正常；M3.2模块、整机离线与当前条件下实物验收PASS。** 两行缓存、3×3窗口、Sobel/阈值与原灰度/边缘显示已实现，使用AR0135单色8位流。M4离线仿真、完整I3编译、STA和实物功能验收PASS（保留已知首行异常）；M5A完成离线算法验证、完整I3编译、STA及用户实物功能验收，阶段PASS；M5B.0架构与软件可行性分析完成，结论NO-GO；M5B.1生产RTL和整机DDR接入未启动，M6～M7未开始，P0其余需求待确认。DDR压力/全容量/温度/校准、复位/CDC、电气/冷启动以及旧Flash R3/R4风险保留。

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
| efinity/、scripts/、reports/ | M0～M5A工程、可复验脚本与验证报告 |

背景、状态、决定和交接以 docs/ 为统一事实源，自动调度仍以根 AGENTS.md 为准。原方案全文保留，当前操作遵守用户本轮授权范围。

历史M0：[最小LED工作工程](efinity/m0_led_i3/LED_8bit_Test.xml)、[构建报告](reports/m0_led_i3/BUILD_REPORT.md)、[上板验收](reports/m0_led_i3/ACCEPTANCE_REPORT.md)和[器件/编译核查](docs/MINIMAL_REFERENCE_CHECK.md)。当时没有算法业务RTL，厂商原始工程保留，未自动下载或Flash固化。

M3基线已提交7a9b448080fd6f1624c2ef37ee2eb267fed49c82；M3.1与M3.2按顺序独立归档。工程生成目录与镜像不提交，必要源输入与文本证据保留。

历史M1：[HDMI工作工程](efinity/m1_hdmi_i3/Ti60_HDMI_1080P_Test.xml)、[离线构建](reports/m1_hdmi_i3/BUILD_REPORT.md)、[管脚/时钟核查](reports/m1_hdmi_i3/PIN_CLOCK_CHECK.md)、[复位/CDC边界](reports/m1_hdmi_i3/CDC_RESET_REVIEW.md)记录1080p60迁移。原厂六份RTL保持，用户后来JTAG临时下载通过，未SPI Active/Flash，代理未操作硬件。详见[实物验收](reports/m1_hdmi_i3/ACCEPTANCE_REPORT.md)与[最终实现审计](reports/m1_hdmi_i3/FINAL_IMPLEMENTATION_AUDIT.md)。

历史M2：[工作工程](efinity/m2_ar0135_ddr_hdmi_i3/Ti60_Demo.xml)、[构建验收](reports/m2_ar0135_ddr_hdmi_i3/BUILD_REPORT.md)、[DDR/IP参数](reports/m2_ar0135_ddr_hdmi_i3/DDR_IP_MIGRATION.md)、[最终绑定](reports/m2_ar0135_ddr_hdmi_i3/FINAL_IMPLEMENTATION_BINDING.md)。Samsung K4B4G1646E-BYMA（512MiB）由用户实物文本确认，用户JTAG功能验收通过。M2归档时未实现Sobel；GUI再生成工作输入与已编译构建有差异，精确源基线见[SOURCE_BASELINE](reports/m2_ar0135_ddr_hdmi_i3/SOURCE_BASELINE.md)。本轮M3仅使用该已编译快照，未覆盖M2工作区。

[M2历史上板前审查](reports/m2_ar0135_ddr_hdmi_i3/preboard_release/RELEASE_REVIEW.md)保留告警/接线/冷启动边界；[当前实物验收](reports/m2_ar0135_ddr_hdmi_i3/ACCEPTANCE_REPORT.md)与[用户文字反馈](reports/m2_ar0135_ddr_hdmi_i3/jtag_user_report.txt)记录新I3基础链路PASS。

M3.1 offline PASS; user-confirmed hardware threshold control PASS. See [M3.1 report](reports/m31_sobel_controls_i3/BUILD_REPORT.md). M3 baseline commit: 7a9b448080fd6f1624c2ef37ee2eb267fed49c82.

M3.2: [实物验收](reports/m32_median_integration_i3/ACCEPTANCE_REPORT.md)、[构建与STA](reports/m32_median_integration_i3/BUILD_REPORT.md)。启用版最小setup/hold +0.194/+0.026 ns；实物长时观察不证明全部PVT稳定，旧Flash/R3/R4风险保留。该M3.2归档轮次分支为codex/m32-median-integration，当时停止在M3.2；当前M4状态见下文。

M3.1提交：742d8a461b36f5970f7caea04fb8f8c925fe8a02；后续独立M3.2提交为其直接子提交，ID以git log为准。

M4历史签收：[彩色叠加工程](efinity/m4_color_overlay_i3/Ti60_Demo.xml)、[构建与STA](reports/m4_color_overlay_i3/BUILD_REPORT.md)、[架构](reports/m4_color_overlay_i3/ARCHITECTURE.md)、[实物验收报告](reports/m4_color_overlay_i3/HARDWARE_ACCEPTANCE.md)。**M4离线仿真、完整I3编译、STA和实物功能验收PASS。RAW、MAG、BIN、OVERLAY模式、阈值控制、OSD、红色边缘、空间对齐、动态更新及720p60输出正常。厂商AR0135参考链路继承的固定首行冻结异常作为已接受的延期问题保留，不属于M4新增回归。**

M4历史归档曾将厂商AR0135参考链路继承的固定首行冻结异常记为DEFERRED并计划换模块复测；2026-10-07用户已将其确认并接受为厂商固有例外，无需继续处理。该问题未由M5A定位或修复；厂商原始参考bitstream在相同实物上也有该现象，不据此认定摄像头根因或承诺换模块能修复。最小setup/hold为+0.193/+0.023 ns；窄hold、跨PVT未严格证明及PLL复位/I/O/CDC边界继续保留。

M4历史归档时分支codex/m4-color-overlay；该轮归档并独立提交，M3.2父提交为3424514afe1721dc000495673c0ca757ea1f6372，M4提交ID以git log为准。本轮不重新编译、Programmer、再次下载、Flash、继续诊断或M5；提交后停止，不合并main、不推送。


## 2026-10-07 M5A当前状态

**M5A流式局部Canny/Canny-lite完成离线算法验证、完整I3编译、STA及实物功能验收，阶段PASS。**

- 实物证据为用户2026-10-07明确确认：“M5A流式局部Canny/Canny-lite实物功能验收PASS。”用户已按照M5A实物验收完成测试并确认总体功能PASS；没有另行提供Programmer原始日志、分模式文字记录、照片或视频、精确连续运行时长、逐阈值观察及显示器EDID原始记录，不补写具体画面或运行细节。见[实物验收报告](reports/m5a_streaming_canny_i3/HARDWARE_ACCEPTANCE.md)。
- 当前实现是局部Canny/Canny-lite，仅完成3×3八邻域一跳弱边缘连接；没有实现跨整帧递归或迭代滞后连接、低频全局Canny、局部/全局快慢融合或目标识别。 七模式、原四模式含OSD逐像素回归、默认中值启用、BIN/H64/L32启动及统一6,626个CE拍延迟属于已验证实现/离线证据，不扩写为用户分项实测记录。
- 完整I3构建及94份最终STA通过：全局setup/hold +0.194/+0.026 ns，像素域+5.879/+0.028 ns，HDMI出口+11.196/+0.164 ns。资源9,425 XLR / 105 RAM10 / 0 DSP；303条详细综合告警与M4规范化一致、新增Canny告警0，工具100网表汇总不重复累计。
- bit为2,201,595字节，SHA-256 `7233bac31c21bd986e18b53b3ecb1ba7d8a4d623a45e56937be309c89a57f75a`，只读复核、不重新生成，继续忽略且不提交。源快照/最终实现/94份STA的证据及离线复核见[构建报告](reports/m5a_streaming_canny_i3/BUILD_REPORT.md)、[主会话复核](reports/m5a_streaming_canny_i3/ROOT_REVIEW.md)。
- 厂商固有首行异常不属于M5A新增回归，不阻断M5A验收。用户已明确该问题为厂商生产/参考链路的固有问题，不影响竞赛考核，无需继续处理；本轮未诊断、未修改RTL掩盖，也不声称M5A解决了该问题。
- hold为正但较窄；实物功能通过不能严格证明所有工艺、电压和温度条件下稳定。继承7个无输入延迟端点和135个无输出延迟端点，PLL复位、I/O约束及CDC边界继续保留。旧Flash流水灯冷启动及R3/R4共享管脚风险保持，本轮没有写Flash。
- 分支`codex/m5a-streaming-canny`；本次归档起始HEAD及新提交直接父节点为M4 `95bf83f7172ecdf11ee9b8deb3e2c1bba535a56d`，起始索引为空。用户授权独立提交`feat: add streaming local canny pipeline`；提交自身ID、最终文件数/字节数及提交后状态以主会话实际Git核查为准，避免在提交内容中循环写入自身哈希。
- 按重新生成的[明确范围清单](reports/m5a_streaming_canny_i3/PROPOSED_GIT_SCOPE.json)逐项暂存，主会话独立核对blob与M2～M4保护范围。历史254文件/12,063,517字节是实物归档前清单，不作为当前固定目标。
- 本轮仅实物归档与独立提交，未重新编译、未运行Programmer、未再次下载、未写Flash、未修改业务RTL、未继续首行诊断、未进入M5B、未合并main、未推送。M5B及其余后续阶段未开始。

M5B.0只完成分析：[NO-GO闸门](reports/m5b0_global_canny_architecture/GO_NO_GO.md)、[主会话复核](reports/m5b0_global_canny_architecture/ROOT_REVIEW.md)、[归档范围](reports/m5b0_global_canny_architecture/FINAL_CHANGE_SCOPE.json)。新增已证明安全DDR容量仍为0；没有生产RTL、Efinity副本、全局Canny bitstream或局部/全局融合。2026-10-07本轮只授权独立归档提交，随后等待M5B.0R阻断项关闭任务。
