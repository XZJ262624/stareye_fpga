# M5B.1首次实物反馈：局部证据成立，整体验收未完成

对象：candidate 8976a276f03b4cd146c451aa081b04f71637fcf2，parent 264962e0c6af61e751c794c5b5f5252d00edbb6c。

## 用户实际反馈

- 用户最终判断PASS；Work保留该原始判断，但不将阶段状态改为完整PASS。
- AR0135已连接；已有板载USB串口，确认460800-8-N-1无流控。
- 找不到VOFA保存入口，无完整原始二进制文件；用户在对话粘贴一段hex。
- JTAG临时配置，未SPI Active/Flash；Programmer finished with JTAG programming，指定工程Ti60_Demo.bit，6.0MHz。
- 显示1280×720@60Hz，七模式及阈值操作正常；静态/运动各10分钟以上，连续总时长约20分钟（原样保留估计，不据此扩大为30分钟）。无黑屏、闪屏、花屏、冻结、错列、撕裂、重启或校准回退，无异常视频。
- LED0一直闪烁、LED2常灭、LED3/4先灭后闪、LED5常亮；LED1未提供。编号/极性与LED4变化需核对，不凭LED5单独认定DDR错误或正常。
- 用户SHA字段为空。Work在收到反馈后只读复算本地指定bit为2924727B、SHA256 8bc85b157426cf35e7aab31bc4acd1c8c54b5799c0e7a0424ee555f3927488c4。该哈希证明当前本地文件与候选构建绑定；不伪称用户已独立复算下载时文件。

## 粘贴统计的离线核验

记录HARDWARE_STATS_FIRST_FEEDBACK.json：从用户明确的四组包头/非零计数/零尾字段重建固定256B统计载荷，分别匹配用户提供的CRC；忽略开头上一包残段，不声称得到完整连续串口原件。四个CRC（小端字节）为6E C9 41 58、64 35 53 98、07 16 97 7D、E4 49 56 F1。

四个完整type1统计包：job91/92/93/94、source frame3497/3532/3568/3603、epoch1；capture_success=true、1280×720、high64/low32、median1。requests98→101、accepted91→94、busy_rejected7、capture_drop0、published91→94。job_fault_flags0、system_status3（cal_done/pass有效、stop/quarantine未置位），FIFO sticky/B/R response/ID/LAST/range/epoch/watchdog及local cancellation样本计数全部0。

服务最大C0/C1/C2为209/213/105 UI周期，等待最大197/237/3428；当前样本不用于推断全程服务保证或fps。classification最大576B，display最小0，不把初始/尾部水位0直接认定underflow。

结论：实物视频/控制及后台成功发布有局部证据，串口统计在该样本范围自洽；没有type2/type3完整分类/结果，无法验证导出CRC/同身份/BFS逐bit正确，也不能据此证明20分钟所有统计或30分钟稳定性。

## 闸门决定及补做

### 相机断开后的M0交叉验证与物理LED顺序（最新）

用户提供照片（核心板安装于VF-Ti60F225 V1.5底板）并确认：断开摄像头后，`F:/Projects/stareye_fpga/efinity/m0_led_i3/outflow/LED_8bit_Test.bit`流水灯正常，左侧第一颗先亮，然后向右依次点亮，再从右向左。Work只读复算该M0 bit SHA256与既有绑定一致：46ac52d70df7330864c7f2531361d9383e22475edac80fd3635ea2c2f43ff2b0。

M0已编译源码初态输出10000000，顶层取反，随后01000000等直到00000001再返回。结合用户启动顺序，照片方向从左到右对应逻辑LED7、6、5、4、3、2、1、0。该映射由指定源码与用户观察共同推导，照片本身没有可读LED编号；不将底板V1.5标记当作核心板原理图版本确认。

此前用户从左侧数六颗的观察可对应：前两颗逻辑7/6为相机共享脚，M5B不驱动为状态灯；第三/第四颗为BG/RT故障，低有效亮灯，正常无故障时亮；第五/第六颗为发布翻转与job busy，活动可闪。右侧另外两颗逻辑1/0分别为校准（成功后灭）与heartbeat（闪烁）。因此先前用从左起编号直接套逻辑LED0~5的故障疑点解除，不据相机共享脚灯判断M5B。

同一M0镜像断开相机即恢复正常，加上其余灯此前也流水，现无依据归为全局时钟/复位配置错误。M0带相机观察不作为隔离测试，M0应断电断开AR0135后使用；M5B需断电接回AR0135。

当前可继续同candidate的完整补验收：配置前启动原始二进制记录，再由用户JTAG临时配置M5B镜像，下载后连续至少30分钟，回传完整.bin/.json与分类/结果。原先需先保留一分钟统计以核对LED的暂缓条件已由本交叉验证解除；可选保存旧状态，但不再作为前置阻断。整体验收仍PENDING，原因是完整串口/CRC+BFS及30分钟证据缺失。

### 用户随后更正LED观察

用户说明先前LED搞反：配置后、画面出现前LED0~5常亮；画面出现后LED0~3常亮，LED4/5熄灭；稍后LED4/5点亮并闪烁，LED0~3常亮。此记录取代首次LED观察，原记录保留为历史。不继续将先前“LED4周期闪烁”直接当作逻辑故障位。

Work只读核对：example_top直接将m5b1_system.led接led_o，无反相；peri.xml无clock inversion，物理GPIO映射与docs/MINIMAL_REFERENCE_CHECK.md既有表一致。后者原理图核对显示LED电阻接3.3V，为低电平点亮（不能仅此证明用户PCB版本）。按该资料与本candidate：逻辑LED0心跳应闪、LED1校准有效后应灭、LED2忙时灭/闲时亮、LED3随发布翻转、LED4/5正常无故障时亮，故障有效后灭。亮不等于逻辑1，更不能把LED5亮直接判BG故障。

更正后的物理分组仍不能逐灯对应逻辑位，需核对照片里的板上丝印/编号方向；不重新改RTL、翻转管脚或重建bit。四份统计包是该样本时段的正常证据，不代替后续LED状态的统计。当前先保存一分钟原始数据，再与丝印对应，整体实物仍PENDING。

**PARTIAL_EVIDENCE / HARDWARE_ACCEPTANCE_PENDING**。保持双审查PASS_WITH_FINDINGS，暂不转M5B.1完成、不推进下一阶段。

1. 核对LED1及板上LED编号，说明LED4是周期闪烁还是一次变化。RTL LED4由video_fault/quarantine/stop驱动，故障路径锁存，不应普通周期闪烁；暂不推定故障或错编号。
2. 准备独立只收字节的Windows串口记录工具（Work外部工具，不修改candidate）；用户先关闭VOFA占用后启动，在板卡现有状态下保存约1分钟，再按Q正常保存。保留当前状态的最新统计，与LED4一起交Work核对；此前不重新配置或复位以免清除历史故障。
3. 当前LED/统计核对后再安排完整补验收：配置前启动新二进制记录，用同一bit JTAG冷配置，不写Flash；保存下载后至少30分钟实际运行，补第一成功job分类/结果与CRC/BFS。Work收到文件路径后再核验；若记录缺首对，不填PASS。

工具路径：C:/Users/kqojp/.codex/visualizations/2026/10/08/01a119f3-561b-7a83-8faf-b2ecad2092d6/m5b1_uart_capture/start_recording.cmd。默认COM32，启动可输入实际端口；默认35分钟从READY计时，需保证下载后实际至少30分钟。captures子目录保存.bin及.json；Q正常停止。只完成语法与不开端口的SerialPort构造检查，未测试真实串口接收，不声称工具或硬件已经上板通过。

硬停只冷重新配置恢复、soft_reset接0、warm/PVT未知等原限制继续保留。Work未打开串口、运行Programmer或操作板卡。
