# M5B.1隔离原型冻结规格

状态：**FROZEN_FOR_IMPLEMENTATION**

冻结日期：2026-10-09

规格基线：`85727319be83f49e81b17d91a310ba0175b37319`

目标分支：`codex/m5b1-global-canny-prototype`

本阶段实现低频全局Canny隔离原型，并验证它与既有720p60相机写、显示读链路的共存条件。它不把全局结果接入七种实时显示模式，不实现M5C融合或识别，也不承诺1～2fps。任何离线通过都不能代替双独立审查和用户实物验收。

## 1. 工程与保护边界

- 新工程固定为`efinity/m5b1_global_canny_i3`，从M5A的**实际编译输入**复制；不得从M5B.0R DDR诊断工程起步，也不得递归纳入旧`work/outflow`、缓存、锁、波形或临时目录。
- 新RTL、TB、脚本和报告分别放入`rtl/m5b1_global_canny/`、`tb/m5b1_global_canny/`、`scripts/m5b1_*`和`reports/m5b1_global_canny_i3/`。
- M2～M5A、M5B.0和M5B.0R的源码、工程与证据只读。DDR IP参数、ROM、管脚、PLL、720p光栅和原七模式语义保持不变；新工程中的复制件必须与来源逐文件绑定。
- XML只允许引用M5A实际使用的`src/axi/axi4_ctrl.v`作为旧行为证据；禁止误用历史同名`src/axi4_ctrl.v`。生产事务层必须在新工程内替换，不能直接沿用旧提交/取消语义。
- 未经用户实物节点授权，不运行Programmer、不下载、不执行SPI Active、不写Flash。

## 2. 冻结数据路径

DDR UI、仲裁、DMA、扫描和发布统一使用96MHz UI域。相机写仍来自`cmos_pclk`，显示和M5A仍使用74.4MHz`clk_pixel`。

M5A复制版只增加分类tap，不改变原显示输出：分类源必须取`m5a_stream_top`中同一`nms_packet`对应的`nms_good/strong_edge/weak_edge`。编码固定为背景`00`、弱`01`、强`10`、非法`11`；每帧1280×720坐标恰写一次，支持域外也写`00`。禁止由已饱和8bit的`out_nms`重建分类。

分类descriptor固定包含64bit epoch、64bit DDR回放frame_id、H/L阈值、中值开关、support radius、NMS规则版本、宽高和源SOF时间戳。frame_id是M5A输入的DDR回放完整帧序号，不冒充相机捕获序号；标签采样时刻必须用带frame tag仿真确定。

初版一次只允许一个job：`IDLE→ARM→CAPTURE→CAPTURE_DRAIN/B_FENCE→FROZEN→INIT→FORWARD→FENCE→REVERSE→FENCE→CHECK_PAIR→COPY_RESULT→B_FENCE→PUBLISH`。busy期间的新请求显式拒绝并计数，不抢占、不改换帧。正常节奏为每秒尝试一次请求；这只是请求频率。

## 3. modified AXI拓扑

DdrCtrl外只保留一个A/W/B/R接口、128bit数据和16bit strobe。新仲裁器是唯一总线所有者，客户端固定为：

1. C0相机写DMA；
2. C1显示读DMA；
3. C2后台控制器，内部顺序复用分类捕获、初始化、扫描、结果复制、metadata和调试导出读取。

每次只允许一个完整事务在途。A接受后到WLAST与真实B完成，或A接受后到最后R完成，owner保持不变。所有客户端和总线ID均用8bit；仲裁器重映射并把真实B/R ID、RESP、LAST返回原owner。写授权前必须缓存完整burst，读授权前必须预留完整接收空间。

地址按字节计，`asize=4`、INCR。RT事务最多128拍/2048B；BG最多32拍/512B。所有事务16B对齐，不跨4KiB，不跨payload末尾，并同时检查buffer状态、epoch和读写权限；端地址用33bit计算防回绕。

M5B.0R单owner、ACK隔离、ID/last错误quarantine和随机/突变测试可移植；必须新增实际水位、预填充、捕获服务保证、真实复位桥和逐buffer权限。非法请求的`rejected`必须成为客户端可消费的终结事件。

旧视频事务层的以下行为不得继承：写帧在真实B前提交；读帧切换时未排尽旧R；B/RRESP被常量替代；校准只看done；FIFO水位未参与调度。新视频槽状态固定为WRITING/COMPLETE/READ_LEASE，只有最后B成功后的完整帧能交给显示，当前显示槽不能覆盖。

## 4. 地址图

地址不得重新分配，全部M5B业务限制在已实物诊断通过的`[0x01000000,0x010e7000)`：

|缓冲|半开区间|有效字节|
|---|---|---:|
|classification_A|`[0x01000000,0x01038400)`|230400|
|classification_B|`[0x01039000,0x01071400)`|230400|
|work_A|`[0x01072000,0x0108e200)`|115200|
|work_B|`[0x0108f000,0x010ab200)`|115200|
|result_A|`[0x010ac000,0x010c8200)`|115200|
|result_B|`[0x010c9000,0x010e5200)`|115200|
|metadata|`[0x010e6000,0x010e7000)`|4096|

六图有效载荷921600B、metadata 4096B、对齐空洞20480B，总区间946176B。空洞禁止业务访问。`[0,0x01000000)`四个4MiB视频槽整体保留，槽尾不得借用；`0x010e7000`及以上禁止访问。

## 5. CDC、复位与epoch

- 分类payload用容量8192B的Gray pointer异步FIFO；frame header/记录包含epoch和job身份。捕获异常只使该snapshot失败，禁止反压M5A实时流。
- 多bit descriptor用稳定mailbox加req/ack toggle，发送端保持到确认；不得逐bit双触发器同步。稳定状态位可双触发器同步。
- job取消、算法超限只停止新BG事务并排空已接受事务，不影响实时视频。协议故障、事务卡死、PLL/校准丢失进入全域quarantine；此时允许受控黑屏，不能声称继续实时显示。
- `ddr_reset_ack`只能由硬件复位桥产生：DdrCtrl真实reset已满足本地官方时序、旧事务epoch清除、所有客户端停止且FIFO双域复位完成、ACK在UI域安全形成。ACK整个有效区间禁止A/W/B/R两侧握手。
- 恢复必须重新满足PLL稳定、`cal_done && cal_pass`、全域epoch交换、FIFO reset_done和显示读FIFO预填充。无法从本地官方资料证明复位保持与重校准条件时，原型必须fail-stop，禁止伪造ACK恢复。

## 6. FIFO与条件QoS

冻结已知量和条件目标：

|项目|冻结值|
|---|---:|
|显示消费峰值|74.4MB/s|
|相机写入建模峰值|100MB/s，保守假设|
|分类产生峰值|18.6MB/s|
|相机W FIFO|8192B|
|显示R FIFO|8192B|
|分类FIFO|8192B|
|显示首像素预填充|至少4096B|
|相机常态参考水位|2048B|
|RT burst|2048B|
|BG burst|不超过512B|
|单笔条件服务目标|从仲裁接受至完整B/R结束不超过384 UI周期=4us|
|RT保守三笔完成|不超过1152 UI周期=12us|
|协议watchdog|2048 UI周期=21.333us；不得当QoS上界|

初始调度门限取显示R FIFO不高于1024B为读urgent、相机W FIFO不低于6912B为写urgent；`safe_window`初值要求显示R FIFO至少2048B、相机W FIFO不高于4096B、校准/复位/错误均正常。Codex exec必须用实际FIFO count/full/empty语义和联合压力仿真重新计算，若不满足则收紧后记录，不能静默放宽。

捕获不能被长期urgent无限饿死。2RT+1BG、每笔4us的条件模型给BG约42.667MB/s，高于18.6MB/s；必须在仿真中测量捕获请求年龄、FIFO最坏水位和溢出。17us单笔持续吞吐反例必须失败；4us只是设计目标和测试环境边界，不是硬件数学保证。

## 7. 全局传播与原子发布

- 初始化工作图为strong；每像素`new = strong || (weak && any_8_neighbor_reachable)`。
- 正扫按y/x递增，反扫按y/x递减。反扫DDR仍发递增INCR读取整行，再在行缓存内倒序处理；写回按合法正序打包。边界外邻居为0，禁止行绕接。
- 当前方向全部R/W/B与流水线归约完成后才能交换A/B。changed为两个方向所有`new & ~old`的sticky OR；只有完整双向pair零变化且末拍已归约才收敛。
- 默认最多64个双向pair或1秒UI墙钟，先到者安全失败。测试配置必须能放大上限并证明642扫竖蛇最终等于BFS；默认配置遇长链可timeout，但不得发布截断结果。
- 收敛后先reserve未pending、未leased的结果槽，再复制。最后B和metadata都成功后一次性切换descriptor。pending占槽；reader最后R完成并release后才能复用。
- 失败job保留上一有效结果并增加age；全DDR复位使所有结果valid失效。当前阶段不把结果接进实时显示。

## 8. 可观测性和真实帧导出

保留原七模式和按键语义。LED只显示heartbeat、校准、job busy、publish toggle、RT sticky fault、BG sticky fault；详细证据走现有`uart_tx_o`管脚，固定460800-8-N-1，不更改管脚。

UART发送有magic/version/type/length/epoch/frame_id/config/counters/CRC32的二进制包。每个job发送统计包；冷复位后的首个成功job额外发送一组单次调试包：冻结分类图230400B和对应已发布结果图115200B。导出期间保持相关buffer lease并使用C2低优先级读取，不能阻塞RT；完成或超时后释放。后续job只发统计，避免串口吞吐主导正常运行。

至少记录requests/accepted/busy_rejected/capture_drop/published、FIFO最小/最大水位、各客户端最坏等待/服务、overflow/underflow、B/RRESP/ID/LAST/范围/epoch错误、pair/scan/changed/耗时、frame_id/result_age、calibration/reset/quarantine。仓库需包含主机端解包、CRC校验和分类/结果导出工具，以便实物后与软件BFS逐bit比较。

## 9. 必须完成的离线验收

1. 工程静态：XML只含批准来源；旧保护集合/hash不变；无新增未解释位宽、多驱动、latch或宽泛CDC false path。
2. 分类tap：小图和至少2个完整720p帧，坐标恰一次，逐像素等于M5A黄金；覆盖CE停顿、SOF配置和滤波边界。
3. 算法：19683个3×3三分类穷举、既有30图/15个720p、长链/timeout均与BFS契约一致。
4. 协议：独立记账`accepted=completed+cancelled+inflight`；覆盖真实B、全部R beat、ID/RESP/LAST、稳定VALID、背压、边界和权限。
5. CDC/复位：ACK在A/W/B/R四态同拍/多拍，job取消、全域取消、FIFO任意相位、停钟/恢复，零旧epoch进入新帧。
6. QoS：相机100MHz、像素74.4MHz、随机相位、刷新/读写翻转/背压；条件384UI内RT零overflow/underflow，捕获不溢出，至少6个种子；17us反例失败。
7. 突变负向：移除ACK隔离、B栅栏、epoch、4KiB/范围、changed末拍、lease、预填充等防护时，真实验收器逐项拒绝。
8. 显示回归：原七模式、阈值、OSD、同步和逐像素输出保持；厂商既有首行现象不能豁免新增错误。
9. 完整Efinity：map/interface/P&R/bit全流程成功；新工程自身的资源、全部要求角点STA和输入→bit绑定齐全。setup/hold均不低于0，新增内部无时钟/未约束/多时钟端点为0。
10. 资源建议闸门：XLR不超过48640、RAM10不超过204、DSP不超过128；超过时停给Work决定。
11. UART：软件解包、长度、CRC、单次分类/结果导出和异常包拒绝通过仿真或可执行回放。

## 10. candidate与停止边界

Codex exec只能按冻结范围精确暂存并创建candidate，交回branch、candidate、parent、commit scope、测试、构建、STA/资源、bit大小和SHA-256、已知限制及工作区状态。不得使用`git add .`或`git add -A`，不得清理历史未跟踪文件、rebase、改写历史、合并main或推送。

Work复核candidate后自动发送经逐文件验证的DeepSeek B隔离快照，再停止并向用户提供独立Codex A提示词；两者完成前互不可见。双审查无FAIL且Work判定离线闸门通过后，再停止提供实物验收清单。Work和Codex exec不得自动操作板卡。

实物建议至少连续30分钟，验证720p60/七模式、后台发布、UART首帧导出与CRC、真实分类+BFS对比、最坏服务/水位/job统计，且无新增实时错误或校准丢失。性能结论只报告实际成功率、timeout率、pair分布、端到端时间和有效发布率；缺少真实数据时保持PENDING。
