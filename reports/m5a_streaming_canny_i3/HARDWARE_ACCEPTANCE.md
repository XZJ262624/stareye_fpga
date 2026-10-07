# M5A实物功能验收报告

日期：2026-10-07。工程：`m5a_streaming_canny_i3`。**M5A PASS**。

**M5A流式局部Canny/Canny-lite完成离线算法验证、完整I3编译、STA及实物功能验收，阶段PASS。**

## 用户结论与证据来源

本轮用户在项目对话中明确提供：

> M5A流式局部Canny/Canny-lite实物功能验收PASS。

用户已按照M5A实物验收完成测试，并明确确认功能PASS。M5A实物功能验收通过。本报告如实归档用户文字结论；代理本轮未操作板卡，未运行Programmer、未再次下载、未写Flash。

用户本次没有另外提供Programmer原始日志、分模式文字记录、测试照片或视频、精确连续运行时长、逐个阈值的观察记录或显示器EDID原始记录。现有M5A模式计划和离线报告没有可引用的更细分实物结果，因此不填造分模式视觉描述、精确分钟数、Programmer日志、照片、EDID、阈值对应边缘数量、异常或观察细节。历史M4实物细节不充当M5A分项实测结果。

## 验收层次与算法范围

| 层次 | 结论与证据 |
|---|---|
| 离线黄金模型与RTL | 独立二维黄金模型、真实RTL、边界/方向/阈值/一跳连接、暂停/恢复、两完整720p及旧四模式含OSD回归通过；见[仿真与回归](SIMULATION_AND_REGRESSION.md)及原ROOT_FINAL_REVIEW.json |
| 完整I3构建与STA | Efinity 2025.1.110.5.9完整构建及94份最终STA通过，源快照、最终实现数据库及bit哈希绑定；见[构建报告](BUILD_REPORT.md)及[m5a_streaming_canny_i3/final_audit/binding.json](m5a_streaming_canny_i3/final_audit/binding.json) |
| 实物功能 | 用户于2026-10-07明确总体PASS；证据为本轮项目对话中的用户文字确认，不扩大为未提供的分模式/数值/日志证据 |
| 全局Canny及后续能力 | 未实现跨整帧递归/迭代滞后连接、低频全局Canny、局部/全局快慢融合或目标识别；没有进入M5B |

当前实现是局部Canny/Canny-lite，仅完成3×3八邻域一跳弱边缘连接；没有实现跨整帧递归或迭代滞后连接、低频全局Canny、局部/全局快慢融合或目标识别。 局部连接根据原双阈值强边缘分类，只保留强边缘及与强边缘相邻的第一跳弱边缘；输出不回灌，不能通过强→弱→弱长链传播。当前结果不能写成完整全局Canny。

七模式与操作规则保留在[模式及历史验收计划](MODES_AND_HARDWARE_PLAN.md)；该表是实现/计划说明，不是用户本次逐项视觉记录。旧离线JSON的PASS_OFFLINE_HARDWARE_PENDING继续表达其生成时点，不改写成自动上板PASS。

## 镜像与实现绑定

- 工程路径：`F:\Projects\stareye_fpga\efinity\m5a_streaming_canny_i3`。
- bitstream：`F:\Projects\stareye_fpga\efinity\m5a_streaming_canny_i3\outflow\Ti60_Demo.bit`。
- 本轮只读复算大小：**2,201,595字节**。
- 本轮只读复算SHA-256：`7233bac31c21bd986e18b53b3ecb1ba7d8a4d623a45e56937be309c89a57f75a`。
- 与既有记录一致；本轮不重新编译、不重新生成bit。源码快照、最终DB及94份STA绑定由主会话独立只读核验，记录见[本轮独立复核](ROOT_HARDWARE_ARCHIVE_REVIEW.md)。bit继续Git忽略，不进入提交。

## 最终时序、资源及告警

| 时序位置 | setup ns | hold ns |
|---|---:|---:|
| 全局 | +0.194 | +0.026 |
| 像素域 | +5.879 | +0.028 |
| HDMI出口 | +11.196 | +0.164 |

资源9,425 XLR / 105 RAM10 / 0 DSP。303条详细综合告警与M4规范化逐条一致，新增Canny源告警0；工具“100网表告警”是另一汇总口径，不重复累加。保留厂商DDR/FIFO参数、可选未用接口、截位/扩位及既有CDC/复位相关告警。

hold为正但较窄；实物功能通过不能严格证明所有工艺、电压和温度条件下稳定。继承7个无输入延迟端点和135个无输出延迟端点，PLL复位、I/O约束及CDC边界继续保留。旧Flash流水灯冷启动及R3/R4共享管脚风险保持，本轮没有写Flash。

## 已接受继承例外与停止范围

厂商固有首行异常不属于M5A新增回归，不阻断M5A验收。用户已明确该问题为厂商生产/参考链路的固有问题，不影响竞赛考核，无需继续处理；本轮未诊断、未修改RTL掩盖，也不声称M5A解决了该问题。 该当前决定覆盖M4/M5A离线历史记录中的DEFERRED/等待换模块复测安排，历史记录保持原时点含义。

主会话仅按明确范围进行M5A独立Git提交，新提交直接父节点必须为M4 `95bf83f7172ecdf11ee9b8deb3e2c1bba535a56d`，分支`codex/m5a-streaming-canny`，提交信息`feat: add streaming local canny pipeline`。本轮没有重新编译、Programmer、再次下载、Flash、RTL修改、首行诊断、M5B开发、全局Canny、融合、识别、合并main或推送。
