# 星眸项目交接单

## 1. 基本信息

H-20261003-13；2026-10-03；M2实物验收归档与独立Git提交。L2，GPT-6.1 Sol / Medium顺序文档委派；子代理期间唯一文档写入，主会话只读核查。主会话负责最终验收与Git操作。

## 2. 已确认基线与最新实物事实

Ti60F225I3；Efinity2025.1.110.5.9；核心VF-Ti60F225 V1.5、底板VF-Ti60/125F225 V1.5、AR0135 PCB V5.0；DDR Samsung K4B4G1646E-BYMA/512MiB；用户确认实物和相机针脚一致性，相机当前连接。
用户本轮明确确认新I3 bit通过JTAG临时下载，实时取图、显示器识别1280×720@60Hz，连续10～15分钟无黑屏/闪屏/花屏/冻结/明显撕裂，移动镜头/运动物体持续更新；未SPI Active/Flash。此前厂商bit出图为历史事实，新报告独立签收新I3镜像。

## 3. 本轮结果与证据

M2基础链路PASS；离线编译/STA与用户配置/功能/有限稳定性分开记录。详见[ACCEPTANCE_REPORT](../reports/m2_ar0135_ddr_hdmi_i3/ACCEPTANCE_REPORT.md)及[jtag_user_report.txt](../reports/m2_ar0135_ddr_hdmi_i3/jtag_user_report.txt)（用户文字整理，不是Programmer日志）。现有bit：F:/Projects/stareye_fpga/efinity/m2_ar0135_ddr_hdmi_i3/outflow/Ti60_Demo.bit，2,137,974字节，SHA256 524213AA27C5797074E9BD71D0761EB31F9D09AEFAC825FA7201CAA6DD33940A。用户未提供下载时哈希/所选文件完整路径/Programmer原始日志，不能宣称密码学绑定下载过程。

## 4. 写入与委派复核

子代理仅更新README、docs下状态/交接/里程碑/背景/决定/接线核查、新增验收报告及用户反馈；在BUILD_REPORT、CHECK_REPORT、CHANGE_SCOPE与preboard RELEASE_REVIEW开头增加历史定位和最新链接，不改历史证据。无Git、工程、RTL/IP/约束、脚本、编译/STA或硬件操作。主会话检查文档链接/状态口径和提交范围后独立执行Git。

## 5. 仍需关闭的条件

PASS仅是相机→DDR→HDMI基础链路及10～15分钟定性稳定性。校准信号、DDR压力/全容量/温度/刷新、复位/失锁恢复、CDC、电气合规未专项验证；既有303条告警记录及网表汇总、接口提示、主动高I2C/CTL控制/加密DDR问题仍保留。
旧Flash官方流水灯未改/读回，冷启动R3/R4共享线争用和配置前隔离仍未关闭；短时成功不消除风险。
当前XML有GUI格式/时间戳/design_ood及IP .v→.sv、ooc=false差异；csi_rx/dsi_tx和多FIFO settings/HDL有再生成差异、部分旧.v/.vh缺失。不得声称当前工作区所有输入等于最终构建；当前再生成版本无新编译证据。编译源快照、业务RTL及DdrCtrl/W0_FIFO_8逐项复核完成；提交范围见COMMIT_SCOPE.md，不覆盖用户工程、不推测修改者。

主会话新增只读核查：22业务设计源、peri/SDC、DdrCtrl v5.14及W0_FIFO_8 v8.0与最终构建哈希一致；再生成差异位于附带CSI/DSI及其他FIFO，当前bit未变。已归档独立final_build/source_snapshot，共69文件/2,689,858字节，逐项哈希匹配最终构建输入清单；主会话检查完成，不覆盖当前工程。源基线说明[SOURCE_BASELINE.md](../reports/m2_ar0135_ddr_hdmi_i3/SOURCE_BASELINE.md)已由主会话完成，当前再生成附带IP无新编译证据。

## 6. 禁止事项

不Programmer/JTAG/Flash读写擦除、bridge加载、断电/相机插拔；不修改业务RTL/IP/约束或用户工程，不编译/STA，不自动实施安全启动bit，不灰度化/Sobel，不自动推进下一阶段。子代理不得Git；主会话Git独立提交是用户已授权范围。

## 7. Git与阶段状态

main父基线M1提交d2f48c6e8befa16c9eedea9c07aca82ff16b9879。用户已授权独立M2提交，完成状态/真实hash以git log及主会话最终回复为准，不写占位值或承诺额外提交。现有用户工程差异须与编译源快照明确区分后由主会话显式选择提交范围。
P0其余需求待冻结，M0/M1 PASS；M2基础链路PASS；灰度化延期；M3～M7未开始。

## 8. 下一步

主会话接回唯一写入权，复核文档与编译源快照/当前工程差异，完成授权的独立M2提交并报告真实hash。向用户解释基础链路已通过及未覆盖项，不安排重复上板或断电；等待用户后续任务，不自动进入算法或Flash阶段。
