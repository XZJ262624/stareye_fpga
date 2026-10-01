# M0 I3 LED 基础验收

日期：2026-10-01。结论：**M0基础验收PASS**，依据官方I3完整编译证据与用户实物反馈；主会话未独立操作板卡。

| 项目 | 状态 | 证据与边界 |
| --- | --- | --- |
| 完整编译 | PASS | Efinity2025.1.110.5.9，Ti60F225I3；内部setup +8.395 ns、hold +0.092 ns；见BUILD_REPORT.md、stage_exitcodes.json及最终I3时序报告 |
| JTAG配置 | PASS（用户报告） | 下载成功，Device ID 0x10660A79，Device is in user mode；未提供原始导出日志，所选bit路径/下载文件哈希未独立核验 |
| LED功能 | 定性PASS（用户报告） | 从一侧至另一侧依次点亮熄灭；未提供LED编号、8颗逐个计数、往返或速度，不写成量化实测 |
| 断电重启 | 有流水灯，启动来源未区分 | 用户此前已固化官方流水灯；不能证明当前I3 bitstream持久性，不作为本轮Flash证据 |
| 再次JTAG/长期稳定性 | 未验证 | 用户未提供再次下载或长时测试结果；本轮基础验收不要求重复操作 |
| 本轮SPI Active/Flash | 未执行 | 本轮只使用临时JTAG；此前用户Flash操作属历史事实 |

用户原文：“从一侧到另外一侧依次点亮熄灭，断电后也会继续运行，但是我之前已经烧录固化过官方的流水灯历程”。摘录见[jtag_user_report.txt](jtag_user_report.txt)，它不是自动生成的原始日志。

本地bit只读复核：`efinity/m0_led_i3/outflow/LED_8bit_Test.bit`，1,618,062字节，SHA256 `46AC52D70DF7330864C7F2531361D9383E22475EDAC80FD3635EA2C2F43FF2B0`，与编译归档一致；未重编译、修改或再下载。bit不纳入源码提交。

约束仍保留真实边界：PLL_LOCKED无input_delay、静态LED无output_delay；内部setup/hold通过不能替代异步复位释放recovery/removal或全部I/O时序证明。芯片后缀来源为用户文本，PCB版号未核验。

独立M0提交清单见[COMMIT_SCOPE.md](COMMIT_SCOPE.md)，实际哈希以git log为准。后续只读视频参考核查不包含在本次M0实现验收中。
