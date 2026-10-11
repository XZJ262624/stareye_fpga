# M5B.1 实物验收最终归档

日期：2026-10-12。Work最终结论：**PASS（受控隔离原型）**。

## 审查和镜像身份

- Branch：codex/m5b1-global-canny-prototype。
- Candidate：8976a276f03b4cd146c451aa081b04f71637fcf2。
- Parent：264962e0c6af61e751c794c5b5f5252d00edbb6c。
- Codex A / DeepSeek B：均PASS_WITH_FINDINGS，R1/R2/R3关闭，无新阻断；见同目录两份审查记录。
- Bit：F:/Projects/stareye_fpga/efinity/m5b1_global_canny_i3/outflow/Ti60_Demo.bit，2924727字节。
- SHA-256：8bc85b157426cf35e7aab31bc4acd1c8c54b5799c0e7a0424ee555f3927488c4。

镜像哈希为Work本地核验；用户未独立提供下载时哈希。用户报告同一路径JTAG临时下载成功，未SPI Active或写Flash，后续确认同一配置未重启。

## 实物证据

用户最初反馈720p60、AR0135连接、七模式和阈值正常、静态及运动场景各10分钟以上，无黑屏/闪屏/花屏/冻结/错列/撕裂/重启/校准回退。LED物理方向由断开相机的M0流水验证厘清，详见HARDWARE_FIRST_FEEDBACK_20261011.md。

长记录：C:/Users/kqojp/.codex/visualizations/2026/10/08/01a119f3-561b-7a83-8faf-b2ecad2092d6/m5b1_uart_capture/captures/m5b1_COM13_20261011_234852_477.bin。

- COM13、460800-8-N-1无流控；947729字节，SHA-256 a8f3dee0f73b2d6bd4543b791a37d8999eb94707be1a7e21a2bd6feb5a3d3d94。
- 2026-10-11 23:48:52.550045至2026-10-12 00:20:04.120036（+08:00）；1871.569991秒，31分11.57秒；USER_STOPPED，无录制错误。
- 用户对全程同配置、相机连接、画面持续正常和控制正常的确认答复：“全程正常，同一配置未重启，七模式和阈值正常”。
- 首字节FF来源未知；offset0严格解析失败。明确排除仅该字节后，offset1到EOF严格解析1860完整包：1858统计、1分类、1结果，全部CRC通过，无重同步或尾部截断容忍。原始记录未修改。
- job连续1~1858，每包accepted=published=job，source SOF严格递增。最后requests1865/accepted1858/published1858/busy拒绝7，capture_drop0。全部统计协议/FIFO错误、watchdog、stop/quarantine为0，epoch保持1、校准正常。
- 首对导出epoch1/frame34/job1，1280x720，共921600像素，软件完整八邻域BFS与实物结果逐bit一致，24444边缘像素。分类/结果payload CRC分别38fdadf9/c7295c58。仅一帧算法oracle，不扩写为1858帧均做BFS比较。
- 短记录另通过107统计与首帧BFS，见HARDWARE_EXPORT_PASS_225827.md。最终机器证据见HARDWARE_UART_VERIFICATION_234852.json。

实际导出/CRC/身份/BFS、720p60七模式共存、至少30分钟同次稳定运行闸门均关闭。Work接受用户实物反馈并判定受控原型PASS，无需重复35分钟记录。

## 保留边界

协议watchdog硬停可能撤销背压WVALID，保留owner/busy、不伪ACK/发布，仅冷重新配置恢复，不属于完整稳定VALID生产合规。生产soft_reset接0，warm reset/跨PVT/DDR全容量和普适4微秒服务上界未证明；hold +0.027ns窄裕量保留。本次观测不承诺1~2fps或所有场景吞吐率。首字节FF来源未知，保留非阻断传输发现。

M5A流式局部Canny保留；本次验证DDR全局Canny后台原型，不代表局部/全局融合。M5C仅接口预留未实现；M6/M7未开始。无Flash部署放行。本轮Work仅离线解析/管理归档，未操作硬件、修改RTL/TB/约束/工程、重跑构建或替换bit。
