# DeepSeek B 第二独立审查报告

**身份**：DeepSeek B 第二独立审查者（非 Codex A，非 Work/开发者）
**对象**：固定 candidate `264962e0c6af61e751c794c5b5f5252d00edbb6c`（parent `c0102ee1…`）的 Work 隔离快照
**方式**：仅 read/glob/grep 当前 `snapshot_verified` 目录；未执行命令、未重跑仿真/构建、未访问目录外、未读取另一位审查者报告。Git 固定性、bit 本地哈希与工作区状态由 Work 负责，我未自行推断 HEAD。

---

## 一、实际检查范围（交叉读取，不采信开发报告为结论）

- RTL 全量核对：`m5b1_system/arbiter/video_dma/backend/global_engine/capture/transfer/mailbox/async_fifo/uart/failstop`，以及 `m5a_copy` 全部 19 份复制件与 `rtl/m5a_streaming_canny` 原件逐份比对（哈希、逐行逻辑）。
- TB 全量核对：arbiter/system/global_engine/tap/video/capture/cdc/prefill/uart 九个 TB，与各 `results.json` 摘要逐项对账。
- SDC/工具文本：`Ti60_Demo_I3.sdc`（false_path/clock_groups 全扫描）、`Ti60_Demo.pt.sdc`、`final_sta/audit.tcl` 与 `m5b1_*.rpt` 抽样、`final_build/{map,place,route,pt}.rpt`、`build_20261010_130312/result.json`、`inputs_before/after.json`、`CDC_PIN_MANIFEST.json`、`CDC_STRUCTURAL_AUDIT.json`、`STATIC_AUDIT.json`、`binding.json`、`XML_METADATA_ONLY.json`、`scripts/m5b1_*`（构建/约束/STA/静态/验证/回放/变异/解码）。
- 专项复核（含证伪尝试）：
  - arbiter 33bit 端址、16B 对齐、4KiB、洞与权限拒绝、owner 保持、`rejected` 一拍脉冲与 transfer 的消费、ID/RESP/LAST 计数逻辑；
  - video_dma 四槽 `latest/complete/lease/next_slot` 推进：特意复核“读侧发放租约与写侧完成同拍”的角点——因 `latest` 恒等于上一次完成槽、写槽只按 +1/+2 推进，可证 `next_slot ≠ 新租槽`，且被跳过的 `latest` 会被清 `complete` 阻止再发布；**未发现覆盖竞态**；
  - engine 逐拍数据流（class_shift 移位序、bit i=pixel i、copy 缓存 `copy_head<=copy_mem[tx_beat+tx_write_beat]` 的最坏 1 拍前置、末拍越界读的传播路径）、`reached=oldbit||strong||(weak&&neighbor)` 的单调性与 BFS 不动点等价、pair 上限/墙钟安全不发布、copy 前 reserve、metadata 真实 B 后发布；
  - UART 头 64B/CRC32 反射算法/字节序、与 `m5b1_uart_decode.py` 解码器和捕获 descriptor 位域的逐位对账；
  - SDC：I3.sdc 已无 `set_false_path -get_clocks`/`set_clock_groups`，CDC 仅按精确 pin 白名单给 5ns max_delay + 异步 hold 例外；`final_sta` 报告实测 `Constraint: 5.000`。

---

## 二、问题表

| 严重程度 | 文件/位置 | 问题 | 证据 | 影响 | 建议 |
|---|---|---|---|---|---|
| 重要（实物闸门，不影响本离线结论） | `rtl/m5b1_global_canny/m5b1_arbiter.sv:112-113,156-161`；`tb/m5b1_global_canny/tb_m5b1_system.sv:49-51`；`efinity/m5b1_global_canny_i3/ip/DdrCtrl/DdrCtrl.v:90,105,111` | 仲裁器新增“bid==aid && rid==aid 否则 quarantine”的硬要求，但离线系统 TB 的 DDR 模型按构造回显 ID（`bid=tid;rid=tid`），无法证明真实加密 DdrCtrl 会回显 8bit ID；M5A 实物时 `w_ddr3_aid` 为 4bit 且恒 0、`bready=1` 且完全忽略 BID/RID，历史证据不能覆盖该依赖 | system TB `L51: bid=tid; rid=tid`；RTL `L112-113` 转发条件、`L156-161` 失配即 quarantine；M5A `example_top.v:504,602`（4bit ID、忽略响应） | 若 IP 不回显 ID，首个 B 即触发 quarantine→fail-stop 黑屏（非静默错误），实物首启直接失败；离线证据无法证伪 | 列入实物验收清单首查项（观察 LED/统计 quarantine）；若 M5B.0R 实物诊断曾验证过 ID 回声，请在硬件清单引用该证据；有条件时用厂商仿真模型补一条 ID 非零的 B/R 回路测试 |
| 建议 | `efinity/m5b1_global_canny_i3/Ti60_Demo.pt.sdc` | 工程根目录残留的 `Ti60_Demo.pt.sdc` 与 M5A 同名文件**逐字节相同**（sha `bbee48b7…`），仍含 `set_false_path clk_sys↔clk_pixel / clk_sys↔cmos_pclk` 整域 false path 文本；它不随本次构建更新（`inputs_before==after`），而权威约束是 `Ti60_Demo_I3.sdc`（`95a9b254…`） | 两文件哈希相同；`m5b1_sta.py:18` 将 `work_pnr/sdc_file_list` 指向克隆内的 `Ti60_Demo_I3.sdc`；`final_sta/m5b1_cdc_*.rpt` 显示 `Constraint: 5.000`（非整域切断）；`m5b1_static.py:32` 只对 I3.sdc 断言无整域 false path | 本次构建/STA 证据链正确；但后续任何误读该残留文件的流程会**静默丢失**精确 CDC 约束并复活整域 false path | 删除该残留文件或在 REPLAY 中明确标注“非活动、不得被工具读取”；重新生成约束/重跑前先核对 `sdc_file_list` |
| 建议 | `rtl/m5b1_global_canny/m5b1_global_engine.sv:24,26-27` | `copy_next=tx_beat[4:0]+tx_write_beat` 在每块最后一拍等于 32，对 `copy_mem[0:31]` 构成越界读（得 x）；已推导该 x 仅存活 1 拍且不会进入 `tx_wdata`（state 3 至少一拍重载 `copy_mem[31]`，且 CWW 不产生写拍），仿真也未受影响 | RTL L24/26-27；`m5b1_setup/hold` 与系统测试均未见异常 | 无功能影响，属代码卫生/综合告警面风险（越界地址可能触发工具告警或 lint 争议） | 加显式位掩码（如 `(tx_beat[4:0]+tx_write_beat)&5'h1f`）或注释说明，避免后续审查误判 |
| 建议 | `reports/.../system/results.json`（stats index 7/23） | `display_min=0`、`classification_min=0` 含合法空态（预填充前/帧尾），不能解释为活动区欠读；系统测试串行器加速（`defparam uart.CLOCK=460800`）、完整字节/CRC/BFS 真实，但生产 baud 仅有独立波形/CRC 测试 | IMPLEMENTATION.md 已披露这两点；system TB L34；directed/uart 580 字节波形逐字节+CRC PASS | 统计字段可能被误读为性能结论 | 保留披露；实物报告引用统计时明确该语义边界 |
| 建议 | 全局（未验证边界汇总） | 以下边界在快照内无法证伪，且证据链确实依赖其成立：加密 DdrCtrl 内部结构/ID 行为（UNKNOWN）；warm reset 未证明（生产 `ddr_reset_ack=0`，全域故障仅冷重配恢复）；7 个无 input delay、135 个无 output delay 外部端口（含 `uart_tx_o`）；134 份 STA 为 clock/端点覆盖文件而非 PVT 角点；系统测试 UART 加速、显示帧交付节拍/迟到帧表现未量化；无上板、无 30 分钟、无 fps 承诺 | `OFFLINE_ACCEPTANCE.json` check_timing、limits；`CDC_STRUCTURAL_AUDIT.json` scope/unknown_fanin 分类；`TECHNICAL_DEPENDENCIES`/`REPLAY.md` 披露 | 不应把这些边界扩写为已证明结论 | 与现有披露一致；实物清单建议优先覆盖：真实 ID 回声、校准丢失、UART 首帧导出+CRC+BFS、超时/发布率、30 分钟稳定性 |

---

## 三、检查结论要点（无阻断项）

1. **协议与总线**：32bit 地址的 33bit 端址计算、16B 对齐、4KiB 与 payload 末端、洞/权限/epoch 拒绝均在 `selected_legal` 中闭合；transfer 的 4KiB 物理切分与连续逻辑 beat 计数正确；owner 保持至真实 B/最后 R；`rejected` 为可消费的一拍终结事件；独立记账在 arbiter TB/system TB 中逐拍守恒（`accepted=completed+cancelled+inflight`）。非法描述符 12 例全部在到达下游 A 前终结。
2. **视频槽与 QoS**：四槽 WRITING/COMPLETE/READ_LEASE、最后 B+EOF 才交付、跳过租约槽、4096B 预填充门、显示 FIFO 真实水位参与调度；2RT+1BG 条件服务与 384UI 目标、17us 反例被真实 FIFO 溢出拒绝；无整域 false path 的 SDC 在最终 STA 报告中以 `Constraint:5.000` 实证（最坏 slack 3.593ns、组内 skew≤0.737ns、预算 5ns）。
3. **算法**：八连通正反 Gauss-Seidel 的 bit 打包/移位/边界（末列、首末行、反扫读整行缓存内倒序）自洽；`reached` 单调（1 不回退、背景不置 1），pair 零变化不动点与 BFS 闭包等价；末像素 sticky changed 由 pattern16（pairs=2/scans=4/changed=1）与两个专属突变杀灭证明；19683 三分类全帧对比、642 扫长链与独立 BFS 一致；64pair/墙钟先到安全失败且不发布。
4. **CDC/复位**：Gray 指针、保持至 ACK 的 mailbox、两级同步、异步断言的复位释放均与 `CDC_PIN_MANIFEST`（940 精确 pin 选择器，`sdc_sha256` 绑定 I3.sdc）和 `CDC_STRUCTURAL_AUDIT`（`unapproved_crossings=[]`、`unknown_internal=[]`、`new_srl=[]`，SRL8=576 全为历史同域）一致；桥四链第二级为正沿 FF（非 SRL）。
5. **UART/导出**：64B 头字段、CRC32 反射实现与主机解码器逐位一致；单次分类/结果导出、超时释放保留已发布结果、半包显式 resync、第二 job 统计恢复均有 TB+主机负向自测支撑；每 job metadata B 栅栏与结果槽 lease 有独立断言。
6. **构建绑定**：96 输入前后哈希、XML 仅两个根元数据且可精确逆变换、map/interface/pnr/pgm/bit 全链 exit0、资源 43227/124/0 与 `place.rpt` 文本一致、bit SHA 记录与 `result.json`/`OFFLINE_ACCEPTANCE` 一致；新 XML 只引用 m5b1 工程内文件与 `m5a_copy`，M5A 原始 85 项复制闭包除 4 项授权变化外逐字节相同；七模式显示输出表达式与原件逐行一致。

**未验证边界（如实声明）**：本审查为只读文本审查，未重跑任何编译/仿真/STA，未接触 bit、工具库、原始日志或 Git 元数据；上述“PASS”仅指快照内证据自洽且与 RTL 交叉一致，不替代 Work 的哈希核对、Codex A 独立结论、实物验收或 30 分钟稳定性结论。

---

## 四、最终结论

**PASS_WITH_FINDINGS**

无阻断项：冻结规格要求的离线技术内容（真实单 owner AXI、四槽 lease、八连通收敛与安全失败、CDC/复位、UART/CRC/BFS、构建与 STA 绑定）在本快照内未发现功能缺陷且证据相互闭合。列出的“重要”项（真实 DdrCtrl ID 回声离线不可证）与两项“建议”（残留 pt.sdc、engine 越界读）不否定本离线 candidate，但应进入实物清单与后续清理。

*（DeepSeek B 第二独立审查者，只读审查完成；未获取另一审查者本次报告。）*