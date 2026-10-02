# M1独立HDMI基线验收

日期：2026-10-02。**M1独立HDMI基线：PASS**。用户实物文字报告与代理离线证据分别归档，不把摄像头直通、复位鲁棒性或长期稳定性合并签收。

| 验收项 | 结果 | 依据与边界 |
| --- | --- | --- |
| Ti60F225I3 / Efinity2025.1.110.5.9完整编译 | PASS | 历史configure/compile/P&R/pgm原始日志；顶层Ti60_HDMI_1080P_Test；六份厂商RTL不变 |
| 最终内部setup / hold | PASS；+1.656 / +0.098ns | 原最终标准I3报告与隔离最终DB重审一致 |
| TMDS并行交接setup / hold | PASS；30/30路；+4.029 / +0.245ns | 新报告绑定到最终DB副本，见FINAL_IMPLEMENTATION_AUDIT.md |
| JTAG临时下载及显示 | 用户报告PASS | jtag_user_report.txt；未提供原始日志与所选文件路径/哈希，代理未操作硬件 |
| 测试图定性功能 | 用户报告PASS | 黑白灰矩形、彩色曲线、横向/竖向多色矩形条纹循环；约几分钟无闪烁、花屏、黑屏、撕裂或其他异常 |
| 显示器识别分辨率 / 刷新率 | 待用户确认 | 参考工程目标1920×1080@60Hz、RGB888；设计计算不充当显示器实测读数 |
| SPI Active / Flash | 本轮未执行 | 临时JTAG与历史固化官方流水灯分开记录，未进行断电保持验证 |
| 摄像头直通、AR0135、灰度化、Sobel | 未验收 / 未开展 | 当前测试图独立HDMI不代表相机链路已工作 |

## 保留风险

PLL LOCKED为异步信号，直接释放像素逻辑异步复位并控制级联PLL RSTN；无同步释放/短脉冲整形。启动、失锁恢复、复位recovery/removal未专项验证。此次正常显示不能消除该结构风险。33条综合warning与未使用25MHz输入保持可见；详见BUILD_REPORT.md、CDC_RESET_REVIEW.md。数分钟无异常不是长期稳定性或HDMI电气合规认证。

## bitstream与最终证据

路径：`F:/Projects/stareye_fpga/efinity/m1_hdmi_i3/outflow/Ti60_HDMI_1080P_Test.bit`。

大小：**1,626,948字节**；SHA-256：`D96068C5D88EE861FD70F1FF4C82221DAE5582E5C1642366A631B053EA7B3E89`。

本轮未重生成bit，只重审隔离最终实现；原outflow/work_pnr/配置/SDC大小、SHA256与mtime保持不变。原构建未捕获当时输入哈希，因此绑定证明当前实现复制件与新STA一致、bit未变，不追溯证明历史DB到bit生成关系，也不独立证明下载时所选文件哈希。bit、hex、二进制数据库和隔离副本不提交Git。

## 脚本与主会话复核

Astra / Medium整改真实状态读取、内部与TMDS正裕量、精确模型/版本及最终数据库哈希检查；46个负向用例全部拒绝。主会话独立读取原始日志、重新解析I3裕量/bit哈希并运行root_review.py --precommit及验收检查，排除误报。未经专项验证的复位边界明确保留。

当前提交范围见[COMMIT_SCOPE.md](COMMIT_SCOPE.md)。后续先做[AR0135接线前核查](../../docs/AR0135_PRECONNECT_CHECK.md)，暂不连接摄像头；旧Flash流水灯可能在冷启动驱动LED6/7共享数据线。
