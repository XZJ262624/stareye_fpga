# 离线证据与重放

固定分支 `codex/m5b1-global-canny-prototype`；candidate直接parent为 `c0102ee1c9a0a8aa802c398755d4a7b3139c7ffd`。自身commit ID由Git读出，避免提交内自引用。只读审查不要运行初始化/迁移脚本，也不要运行Programmer或硬件操作。

## 已执行测试

|证据|内容|
|---|---|
|global_final/results.json|30小图122880像素、15个720p共13824000像素、19683三分类3×3嵌入全帧、唯一末像素changed必须4scan、竖蛇321pair/642scan独立BFS|
|global_final/results.json|生产96M周期限制：50pair/99scan、elapsed96000002，283605接受=完成；扩大墙钟但保留64pair：128scan、369952接受=完成。两者都失败且不发布|
|system/results.json|六随机相位/背压种子真实capture→engine→transfer→arbiter→DDR→UART；每例921600分类像素，346060导出字节，逐byte CRC及BFS45381结果边缘；每例27163事务接受=完成|
|system_faults/results.json|卡死owner保留1inflight并输出watchdog统计；错epoch拒绝；导出超时释放；真实半包后第二job CRC有效统计恢复；第二结果槽lease及每job metadata B栅栏|
|directed/results.json|20528接受=20500完成+28取消，ACK A/W/B/R、真实RESP/ID/LAST、稳定VALID、背压/权限边界；FIFO随机相位/停钟/8次epoch复位；捕获取消；0/4080B拒绝与4096B预填充；生产460800波形580B逐byte及CRC|
|mutations/results.json|10个实际编译并执行的破坏副本均被对应oracle拒绝；包括仅屏蔽最后像素的changed突变。编译失败、无关超时不算kill|
|qos_negative/results.json|1632 UI周期约17us反例，相机FIFO8192B溢出，正确拒绝|
|tap/results.json|26小帧、4个CE停顿帧、两个完整720p；分类坐标/标签/配置逐像素黄金，七模式和原显示回归；独立NumPy二维黄金在M5B1目录重新生成|

整链路测试为合成的非均匀三分类输入，包含真实生产capture/engine/transfer/arbiter；M5A分类tap由独立全帧测试验证。完整346060B导出的serializer在系统测试中加速，包字节/CRC/BFS真实验证；另一个测试使用生产96MHz/460800实际串行波形。没有把加速时间当作真实串口吞吐或板上性能。

## 执行环境

ModelSim 10.1c：`E:/Modelsim_10.1c/win64`。Efinity 2025.1.110.5.9：`E:/Efinity/2025.1`。标准Python可用 `E:/ANACONDA/python.exe`；tap需要NumPy，已用 `C:/Users/kqojp/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe -B`（NumPy2.3.5）。这些是本机路径，可按安装位置调整脚本工具路径。

在仓库根目录运行（测试写新M5B1生成目录，因此只读审查应在另一个隔离checkout执行）：

```powershell
& C:/Users/kqojp/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe -B scripts/m5b1_replay.py all
```

也可按 `directed/global/system/mutations/tap/qos_negative` 分组。长链642扫描较慢；测试必须等到results.json最终形成，不能拿旧日志或仍在运行的进度JSON当通过。每组报告绑定实际源文件及日志SHA；原始日志、仿真库、生成图像和波形不提交。

构建只执行 `scripts/m5b1_compile.bat` 对新工程的离线compile。`m5b1_build.py`记录96项输入和输出，超XLR闸门终止自己的构建树。约束生成需要先map，`m5b1_constraints.py`按实际网表精确枚举；RTL/SDC任何变化后必须重新完整构建，再运行 `m5b1_sta.py`。STA使用隔离数据库副本，检查原构建输出未变。

`m5b1_static.py`核对原保护集合、复制来源、XML、管脚和告警；`m5b1_cdc_audit.py`做可复现结构审计；`m5b1_validate.py`是本地最终fail-closed入口，要求原始构建/仿真证据仍存在。candidate里的JSON/STA文本供固定commit审查；它们不是重新运行证据的替代品。

主机离线解码示例：

```powershell
& E:/ANACONDA/python.exe scripts/m5b1_uart_decode.py --selftest
& E:/ANACONDA/python.exe scripts/m5b1_uart_decode.py capture.bin --resync --allow-trailing-partial
```

该工具不连接串口、不操作硬件。CRC错误不被当作有效包；没有完整匹配export pair时只能读取统计，BFS状态明确为未检查。
