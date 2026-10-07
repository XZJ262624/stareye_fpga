# M5A构建、STA与验收报告

日期：2026-10-07。**M5A流式局部Canny/Canny-lite完成离线算法验证、完整I3编译、STA及实物功能验收，阶段PASS。** 实物结论来自用户本轮总体功能PASS，见[实物报告](HARDWARE_ACCEPTANCE.md)；离线验证和构建数据保留原始证据。

## 基线与边界

父提交95bf83f7172ecdf11ee9b8deb3e2c1bba535a56d；分支codex/m5a-streaming-canny；独立工程efinity/m5a_streaming_canny_i3/Ti60_Demo.xml，顶层example_top。使用官方工程API配置Titanium / Ti60F225 / FBGA225 / I3，默认启用已验收中值能力的新CE副本。相机、DDR、PLL、分辨率、管脚及受保护旧工程参数不改。像素PLL保持74.4MHz，不把旧注释74.25MHz当作配置事实。

算法、方向、NMS、双阈值及一跳连接见[算法规格](ALGORITHM_SPEC.md)；接口/延迟/行缓存见[接口报告](PIPELINE_AND_INTERFACES.md)；按键/显示及实物计划见[操作计划](MODES_AND_HARDWARE_PLAN.md)。局部一跳连接不是完整全局递归Canny。

## 实际验证结果

| 验证 | 结果 |
|---|---|
| 方向量化 | signed11全部4,194,304组合，61个精确等号边界，PASS |
| 双阈值 | 256高阈值×4096幅值，共1,048,576分类，零值/支持域检查PASS |
| 窗口/NMS/八邻域 | 25帧，6,350完整窗口，1,660暂停周期，平台变细/长弱链不递归/帧隔离PASS |
| 小帧端到端 | 26帧240×48，共299,520像素，中值启用/旁路及各模式/阈值PASS |
| CE端到端暂停 | 4帧46,080像素，12,459停顿周期，输出保持及恢复PASS |
| 完整720p | 2帧1,843,200像素，NMS/Canny/叠加逐像素黄金比较；旧RAW/MAG/BIN/OVR各1,843,200像素含OSD回归PASS |
| 控制/OSD | 七模式43项控制检查，真实20ms=1,488,000周期消抖，256阈值共2,457,600 OSD像素PASS |
| 坏帧/复位及HDMI | 904个坏帧故障周期、128恢复窗口；1,024编码通道检查PASS |
| 实际RTL故障 | 20种隔离源码变异均编译成功、实际运行、Fatal且非零退出；原源码哈希前后相同 |
| 证据CLI负向 | 24项错误证据拒绝，1项正常证据通过；缺日志/未运行/错源/错bit/缺STA/负裕量等FAIL CLOSED |
| 主会话独立复核 | 新ModelSim库重跑方向、分类、窗口、恢复；独立列表排序/卷积/坐标集合8,370像素PASS |

黄金模型为NumPy二维图像切片/卷积，不复制RTL流水线状态。主会话另用Python列表sorted取第5值、嵌套卷积及坐标集合对照该模型。参见[黄金与仿真报告](SIMULATION_AND_REGRESSION.md)、[故障证据](RTL_FAULT_RESULTS.json)、[CLI结果](EVIDENCE_NEGATIVE_RESULTS.json)、[主会话结论](ROOT_FINAL_REVIEW.json)。

## 完整构建、最终STA与绑定

Efinity 2025.1.110.5.9完整map / interface / pnr / pgm均PASS，pgm为文件生成阶段，未操作Programmer或硬件。接口由官方API重新生成。最终94份STA来自本次最终实现数据库，未用M4旧STA证明本工程。曾有一次沙箱权限失败，保留失败记录；源注释CE说明修正后重新完成全部仿真、故障、完整编译与94STA，使源码哈希与最终实现一致。

| 位置 | 最小setup ns | 最小hold ns |
|---|---:|---:|
| 全局 | +0.194 | +0.026 |
| 像素域 | +5.879 | +0.028 |
| HDMI出口30个端点 | +11.196 | +0.164 |

无时钟/内部未约束/多时钟端点均0；继承的无input_delay端点7、无output_delay端点135仍是I/O验收边界，不能写成全I/O已约束。DB原始/审计副本、SDC、Tcl、STA、最终bit及88个构建输入绑定于[m5a_streaming_canny_i3/final_audit/binding.json](m5a_streaming_canny_i3/final_audit/binding.json)、[构建输入](m5a_streaming_canny_i3/build/input_before.json)及[构建结果](m5a_streaming_canny_i3/build/result.json)。

资源9,425 XLR / 105 RAM10 / 0 DSP，M4为8,384 /70/0；新增1,041 XLR、35RAM。35RAM=显示包扩展1+NMS两行6+NMS包12+连接两行2+最终包14，映射逐层检查。最终全延迟6,626接受CE拍，RAW和所有同步/标签同延迟；比M4增加3,308拍。没有新增整帧缓存。

303条综合详细告警与M4规范化逐条一致，新增Canny告警0；“100网表告警”为工具汇总提示，不与303重复相加。分类保留厂商DDR/FIFO参数及可选未用接口、截位/扩位与既有CDC/复位边界；没有为清零告警盲改IP。见[告警对照](WARNING_REVIEW.json)。

bit路径：`F:\Projects\stareye_fpga\efinity\m5a_streaming_canny_i3\outflow\Ti60_Demo.bit`；大小2,201,595字节；SHA-256 `7233bac31c21bd986e18b53b3ecb1ba7d8a4d623a45e56937be309c89a57f75a`。bit、数据库、outflow和波形只本地保留，不拟提交。

## 受保护范围与Git

离线轮次核查M2～M4的3,022个可读文件SHA-256、大小、mtime及受保护业务文件集合核查一致。唯一元数据例外：原M4 GUI临时.lock（7字节、旧mtime已记录）当前不存在，原因未确认，不恢复或删改历史记录。详见[原快照](PROTECTED_BASELINES_BEFORE.json)及[锁文件观察](TRANSIENT_LOCK_OBSERVATION.json)。该离线轮次全部原1,550个未跟踪文件仍保留，当时没有暂存、提交、合并或推送。本次用户已授权独立提交；主会话按[本轮独立复核](ROOT_HARDWARE_ARCHIVE_REVIEW.md)重新核查实际保护及最终提交范围。

## 实物验收

**用户报告实物功能PASS（2026-10-07）。** 用户已按照M5A实物验收完成测试并明确确认功能PASS。没有另外提供Programmer原始日志、分模式文字、照片/视频、精确连续运行时长、逐阈值观察及EDID，不能把既有计划改写成分项实测描述。完整归档见[实物验收](HARDWARE_ACCEPTANCE.md)。

当前实现是局部Canny/Canny-lite，仅完成3×3八邻域一跳弱边缘连接；没有实现跨整帧递归或迭代滞后连接、低频全局Canny、局部/全局快慢融合或目标识别。

厂商固有首行异常不属于M5A新增回归，不阻断M5A验收。用户已明确该问题为厂商生产/参考链路的固有问题，不影响竞赛考核，无需继续处理；本轮未诊断、未修改RTL掩盖，也不声称M5A解决了该问题。

hold为正但较窄；实物功能通过不能严格证明所有工艺、电压和温度条件下稳定。继承7个无输入延迟端点和135个无输出延迟端点，PLL复位、I/O约束及CDC边界继续保留。旧Flash流水灯冷启动及R3/R4共享管脚风险保持，本轮没有写Flash。

本次仅归档和独立提交，未重新编译、未Programmer、未再次下载、未Flash，未进入M5B。拟提交清单及每文件大小/哈希见[PROPOSED_GIT_SCOPE.json](PROPOSED_GIT_SCOPE.json)和.csv；[清单差异说明](GIT_SCOPE_REVIEW.md)对照原254文件/12,063,517字节。主会话按用户授权逐项暂存、独立核对blob后提交。旧离线验收JSON保留历史状态；scope/final_gate的M4 HEAD及空索引断言适用于提交前，提交后应采用独立证据和Git结果复核，不把旧Git状态断言当作算法失败。
