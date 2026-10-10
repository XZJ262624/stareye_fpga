# M5B.1最终离线构建与时序

离线状态：**PASS，待两个独立审查与用户实物验收**。最终验收为 `OFFLINE_ACCEPTANCE.json`；不是Codex A或DeepSeek B的审查结论。

工程：`efinity/m5b1_global_canny_i3/Ti60_Demo.xml`，Ti60F225 / I3，Efinity 2025.1.110.5.9。最终构建 `build_20261010_130312` 的map、interface、P&R、离线bit生成和导出全部成功，exit0。工具的pgm阶段仅生成文件，没有运行Programmer或连接板卡。

|最终资源|使用|冻结上限|
|---|---:|---:|
|XLR|43227|48640|
|RAM10|124|204|
|DSP|0|128|

bit路径：`efinity/m5b1_global_canny_i3/outflow/Ti60_Demo.bit`，**2,881,269字节**，SHA-256 **`de1d9c565459e0cce4d4de37bc88a9616e99ac78fc0e27a785b5693da707f645`**。bit和数据库留在本地，不进入candidate。

## 输入、实现和bit绑定

构建记录96项输入；95项原始字节前后相同。XML只被工具更新两个根元数据：`last_change`从1791608537变成1791609106，`last_run_flow`从syn变成bitstream。将最终XML原始bytes仅还原这两个值，恰好恢复构建前15006B、SHA `5bd962a3e9b48867d9bc5d263399a6e284cc9fbf7bb7901ca0984397f302eae8`；最终15012B、SHA `f2546b3c6510ffa30757768f25308a7256662a9d42356dcbd814140d86fc816f`。没有忽略整份XML，见 `XML_METADATA_ONLY.json`。

最终STA使用原实现文件的逐字副本；`final_sta/binding.json`记录原输出运行前后相同。最终map与精确CDC清单、全部输入与当前源码、全部测试源绑定和bit哈希由验收器重算。顶层、RTL、SDC在最后完整构建后未改变。

## I3时序范围

最终工具明确使用I3 final模型：process typical，temperature −40°C至100°C，voltage 0.95V±30mV，speedgrade3，technology t16ff。setup与hold均以该模型执行，覆盖实际clock pair、DDR输入/输出与32个DQ半沿入口、HDMI、每个新增CDC数据端点和桥同步第二级。

**134份报告是分析覆盖文件数，不是134个独立PVT角点。** 不把该工具模型通过扩写为任意工艺、电压、温度、电气、板级或所有实物条件保证。

|检查|最小裕量/ns|
|---|---:|
|全局setup|+0.190|
|全局hold|+0.024|
|HDMI setup|+10.698|
|HDMI hold|+0.040|
|桥四链第二级setup|+9.963|
|桥四链第二级hold|+0.109|

check_timing：no_clock=0、unconstrained_internal_endpoints=0、multiple_clock=0。保留7个无输入延迟和135个无输出延迟的外部端口边界，包含PLL lock状态、未使用接口/静态控制、LED及异步UART TX。UART使用独立串行接收方时钟，不声称外部同步输出时序已约束；实际生产baud波形与CRC另有仿真。新增内部端点没有未解释无时钟、未约束或多时钟项。

6组Gray、4组mailbox共413个目的D端点逐个报告；最大clock-to-Q加物理数据路径1.316ns，最大组内arrival skew0.737ns，均低于5ns预算与最快10ns源周期。mailbox数据从请求发出即保持，目的端两级toggle后下一拍采样，最短采样窗口至少两个目的周期，随后保持到返回ACK；上述数据预算落在该窗口内。异步数据hold例外和首次控制D例外均精确限定，不恢复整域切断。

## 告警与历史失败

最终详细综合告警278条，相对M5A规范化新增7条，均已逐条说明：两个20bit帧offset的受界限加法截断、4KiB boundary−1的8bit截断、CRC序列化取低byte，以及三个刻意使用逻辑存储的槽身份/等待计数/帧标签。没有新增未解释位宽、多驱动或latch；静态报告绑定告警原文件和说明。

首轮57,635 XLR/110 RAM10路由失败，RAM化后历史构建通过，后续精确CDC选择器失败也保留。最终采用精确pin白名单，桥同步链从SRL改为FF，crop复位改为相机域同步释放后重新完整构建。历史失败不能冒充本次通过；本次通过也不删除历史失败证据。

1926项旧跟踪保护记录已核对；其中`.gitignore`、`.gitattributes`仅授权追加M5B1规则，原始字节前缀不变。2139项历史未跟踪路径均存在，没有清理旧资料。管理文档按当前阶段更新。candidate必须直接继承冻结规格提交 `c0102ee1c9a0a8aa802c398755d4a7b3139c7ffd`，提交后停止写入交Work。
