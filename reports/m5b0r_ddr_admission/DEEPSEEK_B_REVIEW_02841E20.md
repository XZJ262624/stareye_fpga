# DeepSeek B 第二独立审查：02841e20

审查日期：2026-10-09

审查对象由Work从固定candidate导出的净化隔离快照；不含Git元数据、未提交内容或其他审查者报告。

我已对快照中的 RTL、TB、脚本与报告完成只读审查。以下为独立结论。

---

# DeepSeek B 第二独立审查者

## 审查范围

- `rtl/m5b0r_ddr_admission/`：m5b0r_arbiter.sv、m5b0r_diagnostic.sv、m5b0r_transaction.sv、m5b0r_monitor.sv、m5b0r_top.sv
- `tb/m5b0r_ddr_admission/`：tb_m5b0r_arbiter.sv、tb_m5b0r_diagnostic.sv、tb_m5b0r_monitor.sv、run.do
- `scripts/`：m5b0r_root_verify.py、m5b0r_evidence_verify.py、m5b0r_sim.py、m5b0r_models.py、m5b0r_scope.py
- `reports/m5b0r_ddr_admission/`：EVIDENCE_BINDING.json、NEGATIVE_RESULTS.json、REPLAY_RESULTS.json、TIMING_METRICS.json、BITSTREAM_METADATA.json、final_audit/binding.json、M5B0R_GATE.md、BUILD_REPORT.md、ARBITER_VERIFICATION.md、DDR_OFFICIAL_EVIDENCE.md 等
- `WORK_VERIFIED_TECHNICAL_PATCH.diff`（56,494 B，本轮技术路径 diff）

## 使用过的只读工具

`read`、`glob`、`grep`（未执行任何终端/Git/构建/仿真/Programmer/下载/Flash 操作）。

---

## 问题表

| # | 严重程度 | 文件/位置 | 问题 | 证据 | 影响 | 建议 |
|---|---|---|---|---|---|---|
| 1 | LOW（非阻断） | `rtl/m5b0r_ddr_admission/m5b0r_arbiter.sv:54` | `avalid=state==A` 未用 `!ddr_reset_ack` 门控。ddr_reset_ack 断言后的**第一个半周期**（negedge 置位到 posedge 状态翻转前），若仲裁器正停在 A 状态，`avalid` 仍在 DDR A 通道上为 1；注释“Never withdraw a stalled A except real DDR reset ack”并非当拍实现，而是下一拍才撤销。 | 组合逻辑 `avalid=state==A`；`state<=IDLE` 仅在 `always @(posedge clk)` 的 ack 分支（76 行）发生；TB 的定向 ACK 用例（tb 151–158 行）只在 `state==IDLE` 且 `phase==1` 时驱动，未覆盖“ACK 时正停在 A”的 A 通道表现。 | 在真实系统中 ack 意味着 DDR 已复位、aready 应已撤销，故实际不致误握手；但这是隐含假设，属 A 通道在 ack 首拍暴露的潜在风险，且未被 TB 直接覆盖。 | 澄清注释为“A 在 ack 下一拍撤销”；或在 TB 增加“ACK 且 state==A（DDR aready 挂起）时 A 必须当拍撤销/不得握手”的直接用例。非阻断。 |
| 2 | LOW（非阻断） | `rtl/m5b0r_ddr_admission/m5b0r_arbiter.sv:75-77` | ddr_reset_ack 分支未复位 `owner`、`local_id`、`len`、`address`、`write_op`、`rt_turn`。这些寄存器保留旧值。 | ack 分支仅复位 `state/quarantine/reset_request/error_reason/age/beat/rejected/credit/refill/rt_served`；其余保留。 | 在 IDLE 下这些信号不被消费（`aid`/`atype` 被 `avalid=0` 屏蔽，`c_bid/c_rdata` 由 `state==B/R` 屏蔽），故无 X 态、无功能错误；唯一副作用是 RR 标志 `rt_turn` 跨 reset-ack 持续，属公平性状态保留（可视为有意）。 | 确认无 X 态风险（所有寄存器均在 `!rst_n` 分支初始化，未读未写信号保留已知值）。可选：在 ack 分支显式复位 `rt_turn` 以明确语义。非阻断。 |
| 3 | INFO | `reports/.../BITSTREAM_METADATA.json` 等 | 快照**不含** `outflow/M5B0R_DdrDiag.bit`（gitignored），无法独立重算其 SHA-256。 | `glob **/outflow/**` 返回空；BITSTREAM_METADATA.json/EVIDENCE_BINDING.json(905-908)/BUILD_REPORT.md(16)/final_audit/binding.json(17-20,231-234) 四处对 `2157846 bytes` 与 `249b4b5e4095...cef3f3` 一致；`hardware_tested=false` 与 `gate=NO_GO` 口径一致。 | 证据口径一致、边界诚实；但 bit 文件本身不在快照内，无法实际核对哈希。 | 列为“未能验证内容”，非缺陷。 |
| 4 | INFO | `scripts/m5b0r_evidence_verify.py:45` | `--candidate` 模式引用 `PROPOSED_GIT_SCOPE.json`，该文件不在技术快照中。 | `glob **/PROPOSED_GIT_SCOPE*` 返回空；该文件由 `m5b0r_scope.py:4,34` 生成并额外提交，属范围清单而非技术文件。 | 不影响本轮技术文件一致性；仅提示完整提交需包含该清单。 | 列为范围性“未能验证”，非缺陷。 |
| 5 | INFO | 全部 SHA 绑定 | 112 份 STA `.rpt` 与各类日志的 SHA-256 绑定，只能核对绑定 JSON 内部自洽，无法用只读工具重算哈希比对真实文件。 | final_audit/binding.json 列 112 份 reports + 32 份 no-path clock pair = 144 requested；evidence_verify 断言 `len(reports)==112`、`log.count('VERIFIED_ASYNC_SR')==20`。 | 结构自洽，但字节级哈希无法复核。 | 列为“未能验证内容”。 |

---

## 关键核验结论（逐项）

**1. 仲裁器 ACK 修复正确性（issue #1）**
- 核心修复 `m5b0r_arbiter.sv:50`：`if(state==IDLE&&!ddr_reset_ack&&!discard&&choose_valid)c_aready[choice]=1;` 正确阻止 ACK 期间接受新请求。
- ACK 分支（75–77 行）将 `state` 强制回 IDLE 并清 `quarantine/reset_request/error_reason/credit/refill/rt_served/beat/age/rejected`，多周期 ACK 下无 READY/VALID 误握手、无记账漂移。
- 所有寄存器在 `!rst_n` 分支初始化，ACK 分支未赋值的寄存器保留已知值，**无 X 态**。
- 公平性：ACK 清 `rt_served`、`credit<=1`，恢复后 BG 需再等两次 RT 授予（`rt_served==2`），符合设计意图。

**2. 仲裁 TB 真实性（issue #2）**
- TB 150–158 行：ACK 期间持 `hold_ack_requests=1` 保持三路 `phase==1` 请求，`repeat(5)@(negedge clk)` 形成多周期 ACK；75–77 行在 posedge 检查 `c_aready!==0` 即 `$fatal("ACK accepted request")`，且 `ack_overlap_cycles>=4` 保证“确有请求在 ACK 期间待决”而非空转通过（无自洽盲区）。
- 恢复检查 `accepted==ack_before+3` 且 `accepted==completed+cancelled` 完整核对三笔保持请求。
- 负向 `ack` 用例（root_verify.py:14）以精确子串替换 `!ddr_reset_ack&&!discard → !discard` 回退修复，`assert old in s` 保证 fail-closed；即使 ModelSim 对 `$fatal` 返回 0，`m5b0r_sim.py:13` 与 root_verify.py:36 均再检查 `** Fatal:` 文本与 Python 验收退出码，不信任模拟器进程码。

**3. 诊断 TB 9967 笔计划（issue #3）**
- 计划在独立 `initial` 块按冻结规格构建，与 DUT 状态无关。计数复核：alias 152（4×38，phase 2 低写/高读与 `pattern=(phase>=2&&addr<0x01000000)?1:0` 逐项吻合）、range 6×(2×462+25 守卫)、walking 2×128×2×8=4096、末次守卫 25；合计 152+5694+4096+25=**9967**。
- 写拍 63+354816+2048=**356927**，读拍 89+354816+175+2048=**357128**，与 `m5b0r_models.py:35` 及 `golden plan totals` 断言一致；`point_address` 38 点与 TB `probes[0:37]` 逐点相等。
- 每拍写数据以 TB 独立 `golden()` 校验，负向 `wrong_pattern` 证明 `golden()` 非 DUT `data_pattern` 的简单拷贝；读数据由 DUT 事务模块比对，而写侧已独立证明 `data_pattern` 正确，故读路径无盲区。
- 顺序/地址/长度/类型逐命令用 `plan_addr[commands]` 等核对，`healthy=fault==0||23||26` 覆盖健康与两轮恢复，`commands!=9967||wbeats!=356927||rbeats!=357128` 兜底漏项。

**4. 根/证据验收 fail-closed（issue #4）**
- 9 项负向（8 HDL + 1 软件比较器）全部 `acceptance_exit_code!=0`；HDL 负向的旧串均精确命中当前源码（我已逐条核对 8 个 `s.replace` 目标字符串与源码一致）。
- `evidence_verify.py`：`--candidate` 模式要求 `HEAD==candidate`、`rev-list --parents` 恰为 `[head, parent]`、工作区无 diff、scope 文件与 HEAD 逐字节一致；无 `--candidate` 时要求 `HEAD==parent`，无法复用陈旧 candidate/evidence。检查 `gate=='NO_GO'`、bitstream hash、`len(neg)==9`、`len(audit['reports'])==112`，均为断言式 fail-closed。

**5. build/STA 边界（issue #5）**
- `m5b0r_top.sv` 仅例化 `u_diag/u_monitor/u_ddr`，**未例化仲裁器**；EVIDENCE_BINDING `build_inputs` 亦不含 m5b0r_arbiter.sv。BUILD_REPORT.md(6) 明示“仲裁未集成”。仲裁器仅在 `sim/` 与 `root_review` 的 HDL 仿真路径中（REPLAY_RESULTS 含 arbiter 源码哈希，属仿真绑定），被如实保留为未综合/未 STA。
- 112 份 STA 为诊断工程（diag_*）时钟对，`no_path_pairs=32` 未伪造报告，TIMING_METRICS `no_clock/unconstrained_internal/multiple_clock=0`、`setup/hold +0.100/+0.021ns`。边界表述准确。

**6. bitstream/NO_GO 口径（issue #6）**
- `2,157,846 bytes`、SHA-256 `249b4b5e4095da1e7466f94d510c17de4588161c37de484a0eff427304cef3f3`、`hardware_tested=false`、`gate=NO_GO` 在 BITSTREAM_METADATA、EVIDENCE_BINDING、BUILD_REPORT、final_audit/binding 四处一致；EVIDENCE_BINDING `boundary` 与 M5B0R_GATE.md 均声明“仅隔离诊断 I3 构建，非生产仲裁器或硬件地址证明”。口径自洽。

**7. 阻断项（issue #7）**
- 未发现会阻断当前 candidate 技术结论的 RTL/TB/证据绑定/范围问题。本轮修复正确、TB 真实、证据一致且 fail-closed、边界诚实。candidate 自身 gate 为 NO_GO，恰为保守正确结论。

---

## 未能验证内容（非缺陷）

1. 无法实跑仿真：ModelSim 路径 `E:/Modelsim_10.1c/win64`、Efinity 及 E: 盘输入不可用，所有 PASS 结论基于代码/绑定静态审查，未实际执行。
2. 无法核对 Git 元数据（HEAD/parent/branch/索引）——按要求不自行判断。
3. 无法重算任何 SHA-256（只读工具无哈希能力）；112 份 `.rpt`、各 `*.log`、`*.json` 的哈希绑定只能确认内部一致，未比对真实文件字节。
4. `outflow/*.bit` 及 `work/`、`outflow/` 等被排除目录不在快照，bitstream 文件本身未提供，无法独立核对 `2157846 bytes/249b4b5e...`。
5. `PROPOSED_GIT_SCOPE.json` 不在技术快照，`evidence_verify --candidate` 依赖的该清单无法复核。

---

## 是否发现“为通过而削弱测试”

**否。** 未发现削弱测试、漏项、使用错误 candidate 或复用陈旧证据的迹象。相反：负向用例以精确子串替换 + 双重验收（模拟器码 + Fatal 文本 + Python 退出码）保证 fail-closed；`ack_overlap_cycles>=4`、`accepted==ack_before+3`、`commands!=9967` 等兜底断言防止空转通过；`--candidate` 强制 HEAD==candidate 且 parent 唯一，杜绝陈旧证据复用；`wrong_pattern/skip_walking/short_range` 等负向确证计划检查独立有效。

---

## 最终结论

**PASS_WITH_FINDINGS**

仲裁器 ACK 多周期/撤销/恢复的 READY-VALID 门控修复正确且无 X 态风险；仲裁与诊断 TB 能真实检出 ACK 错误握手并完整恢复保持请求，诊断 9967 笔计划独立于 DUT 控制流且计数/地址/类型/长度/写模式/walking 位核对正确；根/证据验收 fail-closed；build/STA 边界与 bitstream/NO_GO 口径诚实一致。仅存在两项 LOW 非阻断观察（ACK 首拍 `avalid` 延迟撤销、ACK 分支部分寄存器保留）及若干无法在本环境实跑复核的条目。

### 最小修复清单（均非阻断）

- **非阻断**：澄清/实现 `m5b0r_arbiter.sv:54` 的“A 在 ack 当拍撤销”语义，或补一条“ACK 且 state==A（aready 挂起）时 A 必须当拍撤销且不得握手”的定向 TB 用例。
- **非阻断**：在 ddr_reset_ack 分支显式复位 `rt_turn`（可选，仅公平性状态语义明确化）。
- **非阻断（文档）**：在 BITSTREAM_METADATA/BUILD_REPORT 中显式注明 bit 文件未入仓、哈希由本地 outflow 计算，复核者需在含 outflow 的环境重算（当前口径已隐含，但可更明确）。
