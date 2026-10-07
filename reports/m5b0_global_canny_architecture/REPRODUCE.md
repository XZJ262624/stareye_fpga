# 软件复验与证据边界

运行位置为仓库根，Python只用标准库，不安装依赖，不调用Efinity或硬件。WindowsApps的python占位程序不可用；本机已运行命令如下（路径中的Python为现有Codex运行时）。下列四个命令入口支持 `--output` 指定新报告目录；models.py为模型库，避免覆写本轮原始结果。

```powershell
$env:PYTHONUTF8='1'
$py='C:\Users\kqojp\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
& $py -B reports/m5b0_global_canny_architecture/run_models.py --output reports/m5b0_global_canny_architecture/replay
& $py -B reports/m5b0_global_canny_architecture/check_addresses.py --output reports/m5b0_global_canny_architecture/replay
& $py -B reports/m5b0_global_canny_architecture/protocol_model.py --output reports/m5b0_global_canny_architecture/replay
& $py -B reports/m5b0_global_canny_architecture/calculate_bandwidth.py --models reports/m5b0_global_canny_architecture/replay/MODEL_RESULTS.json --output reports/m5b0_global_canny_architecture/replay --camera-fps 60
```

`run_models --quick`只减少3×3穷举为300个确定性随机输入，完整30模式仍运行；本轮正式结果未使用quick，全部19683个3×3输入运行。每次CPU耗时会不同，检查case/输入输出SHA/扫描计数及equals_bfs即可，不要求结果JSON字节完全一致。

|脚本|输出|能证明/不能证明|
|---|---|---|
|models.py/run_models.py|MODEL_RESULTS.json、SOFTWARE_RESULTS.md|纯分类全局结果、激活扫描号、图案最坏计数；不证明RTL周期/DDR带宽或真实场景分布|
|check_addresses.py|DDR_ADDRESS_MAP.json/.md、ADDRESS_CHECK_RESULTS.json|半开地址无重叠/溢出/对齐、burst边界、源绑定、M2指定文件相等；不证明物理地址解码与校准保留区|
|calculate_bandwidth.py|BANDWIDTH_MODEL.json、BANDWIDTH_AND_LATENCY.md|字节和假设时钟下的计数复算；效率/安全预算/服务延迟/1px每周期没有实测或综合证据|
|protocol_model.py|PROTOCOL_RESULTS.json|34项状态/身份/保留失败/复制前reserve契约；不证明CDC同步器、AXI RTL或硬件复位时序|

地址正向1、故意错误6（重叠、overflow、misalignment、尺寸、地址单位、容量）必须拒绝。带宽camera fps负数/NaN/Inf必须拒绝。模型11、负数、非整数输入拒绝；二维边界不wrap，斜对角是合法八连通。位图打包/解包和4KiB切burst覆盖帧尾与非整4KiB起点。

本目录由架构代理编写；主会话独立验证使用自身连通分量/二维扫描等逻辑，不只重新运行相同黄金。最终主复核、保护快照和Git/范围清单由主会话完成绑定。软件摘要不替代这些独立记录。

主会话实际完整复验入口（固定输出本目录root_replay，重复运行仅更新复验产物）：

```powershell
& $py -B reports/m5b0_global_canny_architecture/root_independent_review.py
& $py -B reports/m5b0_global_canny_architecture/root_protection_check.py
```

第一项独立DFS/二维扫描/全720p union-find再重跑所有原始用例，第二项只读取旧基线/Git并写本阶段AFTER证据。均不调用工具链或硬件，不暂存或提交。

## Git归档后的复验边界

root_protection_check.py是分析阶段的历史前提交检查器，要求HEAD仍为M5A及旧未跟踪集合；提交后这些Git前提必然改变，不应把其FAIL解释为算法或保护失效，也不用于验证本次归档。它会覆写历史AFTER文件。当前归档保护见ARCHIVE_PROTECTION_CHECK.json；提交后的保护由主会话只读复算。root_independent_review.py可重跑软件，但会更新root_replay中的CPU耗时和复验产物，随后应单独核对工作区。所有模型均未变化，无需为归档重复长测。
