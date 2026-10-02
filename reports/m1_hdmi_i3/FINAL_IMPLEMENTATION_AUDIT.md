# 最终实现证据绑定与验收脚本整改（2026-10-02）

本轮仅运行隔离副本的 STA、静态验收与负向测试；没有综合、P&R、pgm、Programmer、下载或 Flash 操作。主线 outflow、work_pnr、XML、peri XML、SDC 的完整路径/大小/SHA256/mtime_ns 前后相同，包括既有空 tcl.out。用户报告独立 HDMI JTAG 测试图循环正常、观察数分钟无异常；显示器分辨率/刷新率、实际所选下载路径/哈希和原始 Programmer 日志尚未提供。摄像头直通未验收。

## 当前证据

- `final_implementation_binding.json`：完整原始实现前后快照、逐文件复制对应、隔离工作路径、真实命令、真实 STA 进程退出码 0、官方 projectdb 读取 I3、SDC/Tcl/报告/log/bit 哈希。
- `isolated_sta.log`：从最终 VDB、placement、routing trace、net_proto 副本重载，显式 I3 后重新出具内部与 30 路 TMDS 报告。`efx_run.py` 的 sta_tclsh 包装不传播 STA 子进程返回码，因此脚本按其官方命令调用 `efx_sta.exe` 并捕获真实返回码。
- 工具入口初始默认 C4，只影响隔离副本的自动报告；验收仅取 Tcl 显式 `set_timing_model I3` 后生成的六份报告。原最终 I3 标准报告保持原样，内部最小裕量与新报告一致。
- 内部 setup/hold：+1.656/+0.098 ns；TMDS 30/30 路逐条 setup/hold：+4.029/+0.245 ns。
- no_clock、unconstrained_internal_endpoints、multiple_clock 均 0；两个 LOCKED 输入及六个 LED + sys_pll_RSTN 的 I/O delay 例外明确保留。复位释放、启动、失锁恢复、长期稳定性和 HDMI 电气质量不由此 STA 证明。
- bit：1,626,948 字节，SHA256 `D96068C5D88EE861FD70F1FF4C82221DAE5582E5C1642366A631B053EA7B3E89`。pgm 消费的 work_pnr `.lbf` 和 outflow `.lpf` 均已纳入快照；没有重新生成 bit。

## 可复验命令

从仓库根目录，用可用 Python 加 `-B`：

1. `python -B scripts/m1_hdmi_i3_archive.py`：先解析真实 compile.log/历史恢复日志和已记录外层返回码；失败或缺失拒绝归档，不编造历史单阶段数值退出码，不覆盖新隔离审计报告。
2. `python -B scripts/m1_hdmi_i3_test_evidence.py`：真实绑定正例 + 46 个内存负例，涵盖失败/缺失/重复/畸形状态、负 setup/hold、缺失/NaN 裕量、错误模型、缺失端点、未约束内部端点、陈旧原始/副本/报告/bit 哈希、缺失/失败 STA 返回码等。不会改写真实设计或证据。
3. `python -B scripts/m1_hdmi_i3_validate.py`：解析标准与隔离内部报告、全部 TMDS 路径、覆盖报告；核对当前主线与副本输入、报告哈希，再生成验收与文本清单。

需要重新 STA 时运行 `scripts\m1_hdmi_i3_timing_audit.bat`，它只创建新的已忽略隔离目录、执行 STA 并更新报告。完整复制中的报告输出、STA 生成的 prevpr.vdb 与重定向 sdc_file_list 是预期变化项；其余复制文件均由 validator 再查当前哈希。隔离目录保留用于本机复验，二进制不纳入文本归档。缺失隔离目录时验收拒绝，需重新运行隔离 STA。

`root_review.py --precommit` 额外验证旧 M0 HEAD 和空暂存区；默认仅将这些历史提交前约束移出工程验收，提交后不会因此误报工程失败。由主会话运行独立审查（本代理未使用 Git）。

## 证据边界

本轮能够证明当前最终实现副本与当前 bit 在审计前后不变，以及新 STA 报告确实来自该最终 DB 的复制件。原始构建时没有捕获路由输入到 bit 的密码学绑定，故不能追溯证明当前 DB 必然是该 bit 当时的生成输入。历史 pgm 日志说明输入文件名，不等同于当时输入哈希。用户未提供所选下载文件哈希，不能独立证明显示现象来自记录中的精确 bit。所有用户实测仅记作用户报告，非代理独立操作观察。

主会话提交前新增根.gitattributes，仅对M1工程、脚本、报告使用-text保留原始字节；逐项比较暂存blob与artifact_manifest哈希，防止换行规范化改变归档证据。该规则不修改源RTL/报告/bit。
