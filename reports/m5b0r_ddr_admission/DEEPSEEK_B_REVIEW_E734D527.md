# DeepSeek B 第二独立审查者

## 身份声明

我是 **DeepSeek B 第二独立审查者**，对固定 candidate `e734d527a149e318ac5009257dab90642c19cb59`（parent `02841e20e297e4e6fdd14db0762a91d7089232fb`）的只读净化快照做独立盲审。本报告不依赖任何其他审查者结论，全部结论来自对 `rtl/`、`tb/`、`scripts/`、`reports/`、`efinity/` 及 `WORK_VERIFIED_TECHNICAL_PATCH.diff` 的直接阅读。未访问快照外内容，未执行任何编辑/构建/仿真/Git 操作。

---

## 结论摘要

本轮技术增量（`m5b0r_arbiter.sv` 的 `ddr_reset_ack` 同拍阻断 + 4 项新增负向验收 + candidate Git 门 + 7 个真实 Git 夹具）**功能正确、测试充分、证据链自洽**，未发现会阻断进入下一闸门的 RTL/TB/验证器/证据缺陷。闸门保持 **NO_GO** 是正确且应保持的（硬件未上板、仲裁器未集成、未综合/STA）。

---

## 问题表

| # | 严重程度 | 文件/位置 | 问题 | 证据 | 影响 | 建议 |
|---|---|---|---|---|---|---|
| F1 | 低（信息） | `scripts/m5b0r_evidence_verify.py:18-20,31` | candidate Git 门的“scope”是自指声明的：门读取**工作区** manifest 作为 scope 依据，仅校验“已提交 manifest blob == 工作区 manifest”。任何越界文件只要被同时写进 manifest（其本身也是提交变更），门即通过。 | `scope=json.loads((root/manifest).read_text())`；`assert out('show',candidate+':'+path)==(root/path).read_bytes()`；manifest `manifest_policy`（`PROPOSED_GIT_SCOPE.json:1024`）自述“scope 是 files 加本 manifest”。 | 门只保证“提交↔manifest 一致性”，不提供独立授权判断。独立 scope 判定依赖外部（本审查）。非代码缺陷，但需明确边界。 | 保持现状；在文档中显式标注“Git 门是自指一致性检查，非独立授权”。 |
| F2 | 低 | `m5b0r_scope_negative.py:12-43` / `m5b0r_evidence_verify.py:27-29` | `removed==set(deleted)`（`deleted_paths` 失配）的**失败分支**未被任何负向夹具独立触发：5 个负向夹具均在 `outside` 断言（第27行）提前失败，`removed` 断言（第29行）仅在 PASS 方向被覆盖。 | 五个 negative 用例（outside_add/delete/rename_source/rename_destination）都断言 `'candidate changes outside scope' in text`；`deleted_paths` 失配的独立场景（文件删除但仍列在 `files` 且未列入 `deleted_paths`）未被构造。 | 该断言是正确代码但缺独立负向证据（防御纵深盲区）。实际仍会被 blob 校验的 `git show` 异常兜底捕获，非功能缺口。 | 可增一个夹具：删除文件但保留在 `files` 且 `deleted_paths=[]`，断言触发 `deleted_paths mismatch`。 |
| F3 | 低（信息） | `tb_m5b0r_arbiter.sv:44` 与 `178-193` | 测试台用 `@(negedge clk);#1` 阻塞延时在 negedge 驱动（阻塞赋值 `=`）与 initial 刺激间同步。此模式脆弱，但经逐拍追踪确认此处**无竞态**：DUT 的 `state` 由 NBA 更新，posedge 检查块读到的是复位前旧值，组合 `avalid/wvalid/bready/rready` 因 `!ddr_reset_ack` 为 0，语义确定。 | `always @(negedge clk)` 全阻塞赋值；`wait(dut.state==case_id)`；`@(negedge clk);#1;...ddr_reset_ack=1;`。 | 无实际缺陷；仅未来维护风险。 | 如重构可改用时钟同步 `@(posedge clk)` 驱动或非阻塞，避免依赖 `#1`。 |
| F4 | 低（信息） | `scripts/m5b0r_root_verify.py:5` | ModelSim 路径硬编码 `E:/Modelsim_10.1c/win64`。 | `MS=Path('E:/Modelsim_10.1c/win64')`。 | 证据可在该环境复现；本审查环境无法重跑，列入未能验证。 | 保持，属环境特定证据。 |
| F5 | 低（信息） | `m5b0r_scope_negative.py`（整体） | 7 个夹具未覆盖“同尺寸内容篡改（blob 失配）”的负向方向，blob 校验仅在 PASS 方向被行使。 | 夹具只做 add/delete/rename，无“改 in-scope 文件内容但保字节数”用例。 | 无功能缺口，仅覆盖不足。 | 可增一夹具：在提交后改写工作区 in-scope 文件内容，断言 blob 校验失败。 |
| F6 | 低（信息） | `NEGATIVE_RESULTS.json:196-199` / `m5b0r_evidence_verify.py:57` | 第 13 项 `software_comparator_disabled` 无 `log/driver_log` 文件，仅有 `exit_code`。 | 用例只含 `"exit_code": 1`；验证器用 `v.get('acceptance_exit_code',v.get('exit_code'))` 正确回退。 | 处理正确，无缺陷。 | 无需改动。 |

> 说明：以上均为**非阻断**。未发现组合环、X 态、误吞响应、记账错误、测试自洽/竞态/零覆盖、削弱测试或证据复用不匹配等阻断性问题（详见下文逐项核验）。

---

## 逐项核验（针对八项审查重点）

### 1. `m5b0r_arbiter.sv` ACK 同拍阻断（验证通过）
- DDR 侧四通道：`avalid`(L56)、`wvalid`(L57)、`bready`(L60)、`rready`(L61) 全部叠加 `!ddr_reset_ack`，ACK 有效同拍全部置 0。
- 客户端侧四暴露：`c_aready`(L50)、`c_wready`(L64)、`c_bvalid`(L65)、`c_rvalid`(L68) 同样叠加 `!ddr_reset_ack`。
- 顺序块 `else if(ddr_reset_ack)`(L77-79) 同拍 `state<=IDLE` 并清 `quarantine/reset_request/rejected/credit/refill/rt_served`，ACK 撤销后安全恢复。
- **无组合环**：两个 `always @*` 块（L41、L62）只依赖输入与顺序 reg（`state/owner/credit/rt_served/quarantine` 等），`discard` 由顺序 reg 派生。
- **无 X 态**：3-bit `state` 仅用 0–4，`default`(L114) 覆盖 5–7；`owner/choice` 0–2，`c_bid/c_rid[owner*8+:8]` 位域在 24-bit 内。
- **无误吞/记账**：B/R 在 ACK 期间不转发给客户端（`!discard`/`!ddr_reset_ack` 双重门），epoch 取消契约由真实 DDR 复位清总线兜底，文档一致。

### 2. soft_reset 排空语义未被破坏（验证通过）
- `avalid/wvalid` 仅被 `!ddr_reset_ack` 门控、**不被** `discard` 门控（L56-57），故 soft_reset 期间已受理的 A/W 保持 VALID 直至 `aready/wready` 排空或真实 ACK。
- B/R 在 soft_reset 下经 `discard` 使 `bready/rready=1` 排空响应、不转发（L60-61、L65、L68），与 `ARBITER_AND_RESPONSE_ROUTING.md` 的 `client_cancel` 契约一致。真实 ACK 的 epoch 取消契约（“仅真实 DDR 复位+客户端 epoch 刷新后才可置 ACK，不得软件脉冲伪造”）表达一致。

### 3. `tb_m5b0r_arbiter.sv` ACK 边沿覆盖（验证通过）
- 新增循环（L178-194）用 `inject` 分别把 DUT 带入 A(1)/W(2)/B(9)/R(8)，`wait(dut.state==case_id)` + `wait(bvalid/rvalid/c_wvalid)` 确认对端 READY/VALID 有效后同拍拉高 ACK。
- 覆盖前置条件（L86-90）逐通道校验 `aready/wready/bvalid+c_bready+bid==aid/rvalid+c_rready+rid==aid`，保证“若无 ACK 门控本应握手”，避免零覆盖/自洽。
- 关键：posedge 检查块读 `dut.state` 得到 NBA 复位前旧值，与 DUT 顺序块的 NBA 更新无执行顺序依赖，**确定性、非竞态**；`ack_edge_seen==4'b1111`(L195) 强制四通道全见。

### 4. 13 项负向验收（验证通过）
- 原 9 项保持；新增 `ack_a_edge/ack_w_edge/ack_b_edge/ack_r_edge` 四项（`m5b0r_root_verify.py:15-18`）的 `old` 串与候选源码精确匹配（L56/57/60/61），`str.replace` 精确移除对应 ACK 门，被 fail-closed 验收器（`m5b0r_sim.py:13` 同时要求返回码 0 且无 `** Error/Fatal:`）拒绝，`NEGATIVE_RESULTS.json` 各用例 `acceptance_exit_code=1` + `expected_failure` 匹配。原 `ack` 项（c_aready）与四项互补覆盖全部 5 个门。

### 5. candidate Git 门与 7 个真实 Git 夹具（验证通过，F1/F2 见问题表）
- `verify_candidate_git`（`m5b0r_evidence_verify.py:10-34`）正确校验：index 空、HEAD==candidate、唯一 parent、跟踪工作区干净、`--no-renames -z`（保留空格/换行/NUL）、`outside=changed-(current+deleted)`、`removed==deleted`、逐 blob `git show` 比对、deleted 不残留。新增/删除/重命名/特殊路径均覆盖。
- 7 夹具**复用生产函数**（`from m5b0r_evidence_verify import verify_candidate_git`，子进程调用），非复制实现；5 负向均被 `candidate changes outside scope` 拒绝。绕过风险仅 F1/F2 所述自指与断言覆盖盲区，非功能性漏洞。

### 6. 54 诊断 / monitor / 六仲裁种子 / 证据绑定（一致）
- 54 诊断用例（`diagnostic_results.json`：f0/f1/f3–f27 共 27 + f2_b4–b28 共 25 + f0_b24_s60401 + f0_b24_s7919 = 54）；monitor 1 用例（内含 `cases=6` 子项，`REPLAY_RESULTS.json:4` 的 `monitor_cases=6` 指子项，非矛盾）；仲裁 5 种子（50708/60401/7919/1009/20261008）+ 独立 20261009 = 6 种子；`EVIDENCE_BINDING.json` 与 `final_audit/binding.json`（112 报告）SHA 自洽；`m5b0r_arbiter.sv` 未出现在 `build_inputs`（仅 diagnostic/monitor/top/transaction + DDR IP），仅经 sim/REPLAY 绑定，确认仲裁器未综合/未 STA。未发现削弱测试、漏项或复用不匹配源码证据的迹象。

### 7. Efinity build / 53 实现输出 / 112 STA / bit 边界（准确）
- `implementation_outputs` 共 53 项、`sta_reports`+`final_audit` 112 份、bit 2157846 字节 SHA 与 `BITSTREAM_METADATA.json` 一致；`hardware_tested=false`、`gate=NO_GO` 明确保持；`m5b0r_top.sv` 仅例化 `m5b0r_diagnostic/m5b0r_monitor/DdrCtrl`，无 `m5b0r_arbiter`（L28-42）。

### 8. 是否阻断进入下一闸门
无。未发现会阻断本轮 candidate 进入下一闸门的 RTL/TB/验证器/证据问题。

---

## 审查范围
`rtl/m5b0r_ddr_admission/*.sv`（arbiter/top/transaction/monitor/diagnostic）、`tb/m5b0r_ddr_admission/*.sv`+`run.do`、`scripts/m5b0r_*.py`（evidence_verify/scope_negative/scope/root_verify/sim/models）、`reports/m5b0r_ddr_admission/` 关键 json/md（EVIDENCE_BINDING、PROPOSED_GIT_SCOPE、NEGATIVE/REPLAY/SCOPE_GIT_RESULTS、TIMING_METRICS、BITSTREAM_METADATA、BUILD_REPORT、M5B0R_GATE、ARBITER_*、final_audit/binding）、`efinity/.../DdrCtrl` 元数据、`WORK_VERIFIED_TECHNICAL_PATCH.diff`。

## 使用过的只读工具
`read`、`glob`、`grep`（未执行任何终端/Git/构建/仿真/写入）。

## 未能验证内容
- 无法实跑 ModelSim/仿真（硬编码 `E:/Modelsim_10.1c/win64`，本环境只读）——ACK 边沿断言与负向验收的**动态**结果仅据日志/SHA 交叉核对，未复算波形。
- 无法核实 112 份 STA 报告逐字节（依赖 `final_audit/binding.json` 的 SHA 声明与 `len==112` 断言）。
- `ACK_EDGE_FIX_REPORT.md`、`ROOT_REVIEW.md`、`CODEX_A_REVIEW_*.md`、`DEEPSEEK_B_REVIEW_*.md` 等被排除的 Work/开发修复报告与管理文档未提供，未据其结论。
- Git 元数据（HEAD/branch/parent、index 空、干净跟踪区）由 Work 保证，本环境无 `.git` 可复核，仅据 `WORK_VERIFIED_TECHNICAL_PATCH.diff` 与 manifest 一致性推断。

## 是否发现为通过而削弱测试
**未发现。** 负向用例均精确恢复漏洞并由真实 fail-closed 验收器拒绝；ACK 边沿用例强制对端 READY/VALID 有效后才拉 ACK 并检查四通道全覆盖；未发现削弱断言、放宽阈值或复用不匹配源码的迹象。

## 最终结论
**PASS_WITH_FINDINGS**

理由：本轮 ACK 边沿修复完整、正确、可安全恢复，13 项负向验收与 7 个真实 Git 夹具有效，证据链与边界声明准确；闸门 NO_GO 应保持。F1–F6 均为低/信息级非阻断观察项。

## 最小修复清单
- **阻断项：无。**
- **非阻断项（可选加固）：**
  1. （F1）在 `PROPOSED_GIT_SCOPE.json`/文档显式标注 Git 门为“自指一致性检查，非独立授权”，避免误读为独立 scope 授权。
  2. （F2）为 `m5b0r_scope_negative.py` 增一个“文件删除但仍列于 `files` 且 `deleted_paths=[]`”夹具，独立触发 `deleted_paths mismatch` 失败分支。
  3. （F5）增一个“提交后改写 in-scope 文件内容（保字节数）”夹具，负向覆盖 blob 校验。
  4. （F3）如重构测试台，用时钟同步驱动替代 `#1` 延时同步，降低未来维护脆弱性。
