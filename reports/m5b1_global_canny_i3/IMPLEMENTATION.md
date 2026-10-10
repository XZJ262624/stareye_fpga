# M5B.1隔离全局Canny原型

本轮实现冻结规格的后台全局连接、真实DDR单owner事务、分类快照和UART导出。全局结果不接入实时七模式显示；不实现融合或识别。离线验收的机器可核查入口为 `OFFLINE_ACCEPTANCE.json`，独立审查和实物验收仍待完成。

## 数据路径与发布

新工程复制M5A实际输入闭包85项，只有顶层、XML、I3约束和增加分类tap的 `m5a_stream_top.v` 复制件改变。原七模式、滤波/阈值/OSD、720p光栅、管脚、PLL、DDR IP设置和ROM保持；原工程只读。`M5A_INPUT_COPY.json`记录复制时来源，`STATIC_AUDIT.json`绑定最终复制件及四项授权变化。

原128-bit DDR口由C0相机写、C1显示读、C2后台顺序共享。8-bit ID、RESP、LAST、16B对齐、4KiB、payload终点、epoch、buffer读写权限均在真实总线上检查。A接受后owner保留到真实B或最后R。C2 transfer将跨4KiB的逻辑整行事务切分，逻辑beat计数连续且所有分段完成后才给done；没有把W最后拍当作B。

视频写满整帧且最后B成功才提交槽；显示持有读lease、排空最后R后归还。相机、显示和分类三个异步FIFO各8192B；显示必须先有4096B预填充才开始使用新帧。busy请求计数拒绝，不反压M5A分类流。分类失败、非法坐标/编码或取消均使该snapshot无效。

全局引擎以strong初始化位图，对weak做八邻域传播；完整正扫、反扫及写栅栏后才判双向pair的sticky changed。边界不绕行；反扫仍以递增INCR读整行，再在缓存内倒序计算。收敛后reserve非pending结果槽，复制全部结果，等待最后B及该job/slot metadata B，再一次性发布descriptor。默认64pair或96,000,000 UI周期先到即失败，排空已有事务，不发布截断结果。失败保留旧有效结果；全域故障使valid失效。

为满足资源门，copy/export缓存改用同步RAM；首轮57,635 XLR路由失败证据保留在 `blocked_build_evidence`，未放宽48,640 XLR门槛。

## CDC与复位

Gray指针有两级同步；descriptor通过保持到ACK的mailbox传送。FIFO、mailbox、相机/像素状态和相机crop均异步复位断言、各自时钟同步释放。桥的四条状态链明确使用 `syn_srlstyle="registers"`，最终8个独立FF，新增逻辑中SRL8为0，未改变历史同域576个SRL。

SDC不再继承UI与相机/像素整域false path。`CDC_PIN_MANIFEST.json`从最终map产生940个精确pin选择器，每个必须恰好匹配一次；仅首次控制同步D和明确复位释放SR切断。60个Gray首级D及353个稳定mailbox数据D使用5ns launch-to-D上限，hold仅对这些异步路径例外。同步第二级保持正常setup/hold分析。

`CDC_STRUCTURAL_AUDIT.json`可复现追踪FF、SRL、RAM和LUT/ADD/assign，包括D/CE/SR及RAM控制/地址；433个D、24个SR跨域端点全部属于批准清单，新增非加密内部未知fanin为0。三个真双时钟FIFO共21 RAM10是批准存储结构，copy/export共14 RAM10均UI同域。加密DDR内部及外部PLL状态在结构审计中明确保留边界，不能据文本网表假称内部已展开；完整Efinity数据库STA另行覆盖。

## 故障策略

官方加密DDR冷启动仿真不构成warm restart证明。生产桥始终不生成reset ACK；PLL/校准丢失、协议故障、卡死进入fail-stop/quarantine，停止新的总线握手并允许黑屏。卡死owner不以synthetic ACK清除。UART能独立中止半包并输出一次紧急统计，保留真实inflight及错误计数；恢复需要冷重新配置，不能自动恢复。

后台snapshot/算法超时与全域故障不同：前者只排空本job，旧结果保留、RT继续；后者不再声称实时画面正常。

## 条件QoS

模型使用相机100MHz、像素74.4MHz、UI96MHz、六种不同相位和随机DDR背压。单笔接受至B/最后R不超过384 UI周期是环境条件，不是已证明的实物上界。2RT+1BG条件带宽约42.667MB/s，大于18.6MB/s分类峰值；实际联合测试C2最大等待3575 UI周期、分类FIFO最高848B、相机最高2816B，未溢出/欠读。显示最小水位统计包含prefill/帧尾合法空态，0不能解释成活动区欠读；活动消费另由逐像素/empty故障断言检查。

17us持续服务反例确实以相机FIFO达到8192B溢出失败。21.333us协议watchdog不是QoS保证。实物后必须测量服务时间、FIFO、timeout率、pair分布和实际发布率；没有真实图像性能数据，不承诺1～2fps。

## UART与边界

使用现有 `uart_tx_o`，460800-8-N-1。每包64B小端header（SM5B、version、type、length、40B descriptor）、payload及CRC32(header+payload)。每job统计256B；冷启动首个成功job再导出230400B分类和115200B结果。导出读lease保留到完成/超时，墙钟计时包含prefetch，超时后释放且保留已发布结果。

主机工具默认严格CRC/长度/身份检查；失败job统计允许无有效图尺寸，stats-only不虚构BFS通过。`--resync`、`--allow-trailing-partial`是显式恢复选项，每个跳过区间都有诊断，仅输出完整CRC有效包。只有匹配的有效分类/结果pair才能执行逐bit BFS比较。

记录请求/接受/拒绝/丢捕获/发布、结果age、FIFO水位和sticky overflow/underflow、C0/C1/C2等待及服务、pair/scan/changed/elapsed、B/RRESP/ID/LAST/范围/epoch/watchdog分类计数和校准/reset/quarantine状态。完整字段见解码器 `STAT_WORDS`；时间戳是源SOF像素时钟计数，elapsed/wait/service是UI周期。

本轮没有上板、Programmer、JTAG下载、SPI Active或Flash。UART FPGA管脚为1.8V；若未来使用所附底板版本，应走原理图确认的J4板载CH340串口及电平转换，不将3.3V TTL直接连FPGA。硬件清单由Work在双审查后提供。
