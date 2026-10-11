# DeepSeek B 第二独立审查报告

**身份**：DeepSeek B 第二独立审查者（非 Codex A、非 Work/开发者）
**对象**：Branch `codex/m5b1-global-canny-prototype`，Candidate `8976a276f03b4cd146c451aa081b04f71637fcf2`，唯一 Parent `264962e0c6af61e751c794c5b5f5252d00edbb6c`（branch/commit/parent 及快照逐文件一致性由 Work 核验并提供，我未自行推断 HEAD）
**方式**：仅当前 `snapshot_verified` 目录内 read/glob/grep。未执行命令、未重跑仿真/构建/STA、未打开 bit、未写任何文件、未联网、未读取另一位审查者本轮报告。下文所有“哈希一致”均为**字符串级交叉比对**（receipt 记录值 vs WORK_MANIFEST.json），非重算。

---

## 一、实查范围（交叉核对，不采信结论性摘要）

- **修复规格与新报告**：WORK_MANIFEST.json、WORK_REVIEW_REQUEST.md、REVIEW_FIX_SPEC_264962E0.md、SPEC_FREEZE.md、review_fix_264962e0/{OFFLINE_ACCEPTANCE,EVIDENCE_SUMMARY,IMPLEMENTATION,BUILD_REPORT,DEVELOPMENT_CHECKPOINT,CHECKPOINT_BINDING,PROPOSED_GIT_SCOPE,TECHNICAL_DEPENDENCIES,RESUME_CHECKPOINT}。
- **生产 RTL 全量逐行**：m5b1_system/failstop/video_dma/transfer/capture/backend/global_engine/arbiter/mailbox/uart（含 async_fifo 引用）、m5a_copy/m5a_stream_top，以及 efinity 复制件 lcd_driver.v/lcd_para.v、example_top.v、Ti60_Demo.xml（设计文件与 SDC 选择）。
- **TB**：tb_m5b1_review_connection（三 CHECK 模式逐条读）、review_cancel、transfer_cancel、engine_abort、backend_edges、tag_qualification、tap、system（硬停 oracle 段）。
- **结果/负向证据**：final/{global,directed,tap,system_v4,system_faults_v3,mutations,qos_negative,review_core_v6,review_negative_v6,review_recovery_v6,SCOPE_NEGATIVE,STATIC_AUDIT,final_sta/{binding,m5b1_check,m5b1_setup,m5b1_hold 及 CDC 组报告}}、connection_capture/midloss/zero_v4、default_{capture_v4,engine_v4,export_v3}、final_v6_{transfer_cancel,lcd_register,unqualified_tap,no_local_cancel,abort_zero_payload,live_metadata,freeze_take_race}、r1/r2/r3_*_original、build_20261010_235246/{result,inputs_after}。
- **交叉一致性已核对**：上述 receipt 中 RTL/TB/脚本哈希与 WORK_MANIFEST.json 条目逐项一致（m5b1_* 11 个 .sv、m5a_stream_top、lcd_driver/lcd_para、gold/解码/runner 脚本、connection TB 等）。

**核验要点与正面结论**：R1 采样沿（DMA 组合 FWFT 字节→lcd_driver 单级数据寄存器，pix_qualified 随 r_lcd_rgb 后一拍进入 M5A tap；末像素 display_count==FRAME_BYTES-1 与 tag 尾部闭合）与连接 TB 的逐采样沿、逐像素 oracle 自洽；R2 预填充 4096B 门（display_rc≥256 字）、offer/frame_id/epoch 锁存、tag 队列无效帧消费与 midframe sticky、reset/epoch 推进与实际 RTL 一致；R3 未受理取消为本地终止（avalid 组合撤回，cancel 优先于 READY/start），已受理事务保持 A/W 至真实 B/最后 R 并等待排空，4KiB 分段取消不发布，status/descriptor/lease/packet 半包释放路径闭合；三超时（96M/96M/960M 周期）在完整默认上限下有终态与 CRC 有效统计；642 扫/19683 穷举/64pair 与 1s 墙钟失败不发布/17us 反例拒绝均绑定当前源码；新构建 45042 XLR /124 RAM10 /0 DSP 未放宽 48640/204/128，STA I3 模型 setup 最小 +0.196ns、hold 最小 +0.027ns、内部 no_clock/unconstrained/multiclone=0，可用 SDC 仅 Ti60_Demo_I3.sdc（inactive_pt_SDC_used=false，broad_clock_domain_false_paths=0）。未发现阻断性功能缺陷。

---

## 二、问题表

| 严重程度 | 文件/位置 | 问题 | 证据 | 影响 | 建议 |
|---|---|---|---|---|---|
| 重要（实物闸门，非本离线阻断） | tb_m5b1_system.sv:51,53；m5b1_arbiter.sv:157,161 | 仲裁器要求真实 DDR 回显 8bit ID（bid/rid==aid），否则 quarantine→fail-stop；离线所有 TB 的 DDR 模型按构造回显 `bid=tid;rid=tid`，无法证明加密 DdrCtrl 真实回声 | system TB L51/53 模型自造 ID；arbiter L71/L118/L120 以 ID 判等才转发；DdrCtrl.v 为加密网表 | 若实物 IP 不回显 ID，首个 B 即 fail-stop 黑屏（非静默错误）；离线无法证伪 | 保留为实物验收首查项（quarantine/LED/统计）；在有条件时补 ID 非零回路的厂商模型测试 |
| 重要（已披露隔离边界，须持续保留） | m5b1_arbiter.sv:108-113；m5b1_failstop.sv:23-26；m5b1_system.sv:42；IMPLEMENTATION.md §硬停；OFFLINE_ACCEPTANCE.limits | 真实事务 watchdog 卡死后全域 emergency_stop 撤回 stalled WVALID、关闭 A/W/B/R 握手、保留 owner 与 transfer busy、禁止伪 ACK 与发布、仅冷重配 | 源码：stop→emergency_stop 门控 avalid/wvalid/bready/rready 与客户端 B/R 转发；failstop 仅冷启动清 failed；逐沿轨迹 HARDSTOP_TRACE：owner=2、state=2、transfer busy=1、WVALID=0、WDATA 保持、ACK=0；TB 断言“首沿仅撤 VALID”且后续接口隔离、owner/发布不变 | 与 SPEC §5/§67/§69、修复规格 R3 的“fail-stop/no synthetic ACK、不宣称有限时间排空”一致；**不能**解释为通用 AXI stable-VALID 合规 | 维持现状并在所有后续材料保持同等强度披露；不得据此扩大“协议合规”表述；实物/后续阶段如需 AXI 合规需独立整改 |
| 建议 | m5b1_system.sv:42（`.soft_reset(1'b0)`） | 修复规格提到“普通 soft_reset 保持 stalled VALID/payload 并排空真实在途 B/R”，但生产接线中 soft_reset 恒 0，该分支无独立场景证据；按源码，一旦启用将走 quarantine→failstop 硬停路径 | 生产例化 soft_reset=1'b0；arbiter 注释“soft_reset QUIESCES”；quarantine 仅由 ddr_reset_ack 清除 | 当前无实际影响；未来若改接线，语义需重新评估 | 在文档明确“soft_reset 未接线、未作为独立场景验证”；如未来启用，新增专用定向用例 |
| 建议 | tb_m5b1_transfer_cancel.sv:32；tb_m5b1_engine_abort.sv:37 | W 稳定 tuple 声明 `[152:0]`（153bit），实际拼接为 154bit（wid8+wstrb16+wlast+wvalid+wdata128），MSB 截断 | 两处 `reg [152:0] wheld` 与 154bit 拼接比较 | 本 candidate 内 wid[7] 恒 0，未造成漏检；语义上少监视 1bit | 改为 `[153:0]`（仅 TB，不涉 RTL） |
| 建议 | tb_m5b1_review_cancel.sv:174,177 | `ddr_before` 记录“拒绝时刻已受理计数”但从未参与断言 | 变量仅赋值、无引用；“未受理取消不得新增 DDR 事务”的显式断言在 tb_m5b1_transfer_cancel 中已有（denied/second-segment/start-cancel 三处） | 覆盖未缺失，但该 TB 存在死变量，易误读为已断言 | 清理或补 `bus_accepted==ddr_before` 断言 |
| 建议 | final_v6_unqualified_tap/result.json；tb_m5b1_review_connection.sv:186 | R2 当前源码变异负向命中的是启动期 oracle（QUALIFIED_BEFORE_RASTER_ACQUISITION），而非运行期 REVIEW_R2_UNQUALIFIED_TAP；运行期语义由 final_v6_tag_qualification 与 r2_original（真实旧码）覆盖 | 两份 receipt 的 expected_failure 与 log 分别为上述两个标记 | 负向证明成立但映射不一一对应，复核者易误读 | 报告中标注该负向实际命中断言；后续可加只触发运行期 R2 oracle 的变异 |
| 建议 | tb_m5b1_review_connection.sv（ce=1'b1）；final/tap/stall 与 tag_qualification | 720p 全尺寸连接测试 CE 恒 1；CE 停顿覆盖在缩小帧（W=128）tag TB 与 tap stall 用例（后者关闭 M4 legacy 回归对比） | TB 源码与 result.json 摘要 | “首末像素+CE 停顿”的组合在 720p 全尺寸上没有直接证据 | 如实披露该覆盖边界，避免过度表述 |
| 建议 | .gitignore:134,138-142 | 仿真/构建原始 log、hex 被刻意排除出版本控制；快照内只有 result.json 摘要与哈希，独立复核者无法逐字核对日志正文 | glob 未发现 review_fix 下任何 .log/.hex；receipt 含日志哈希；.gitignore 显式规则 | 对哈希链无影响，但降低逐字可复核性 | 如后续轮次需要更强的独立复核，可将关键失败/负向日志纳入闭包或以附件随报告提交 |

---

## 三、未能验证的边界（如实声明）

只读文本审查：未重算任何 SHA-256、未重跑编译/仿真/STA、未打开 bitstream、未访问 Git 元数据、未接触工具与原始未跟踪日志；DdrCtrl 加密网表内部 ID 行为、warm reset、真实 PVT/30 分钟运行、真实服务上界与发布率、4us 仅条件模型、134 份 STA 为覆盖/路径报告而非 PVT 角点——均与 Work/开发者披露一致，不能由本快照扩大为已证明结论。

---

## 四、最终结论

**PASS_WITH_FINDINGS**

三个原 FAIL 关闭项（R1 采样沿与全帧连接 oracle、R2 回放资格与标签身份、R3 未受理取消与已受理排空）在本固定快照内的 RTL/TB/负向与哈希绑定证据相互闭合，未发现阻断问题；两项重要项（加密 DDR 实物 ID 回声、watchdog 硬停 VALID 撤回边界）与若干建议项必须在后续阶段持续记录或清理。硬停边界经独立判断与冻结规格、真实源码、逐沿轨迹及 oracle 分界一致，故不构成离线 FAIL，但绝不可被解读为通用 AXI VALID 合规。

*（DeepSeek B 第二独立审查者，只读审查完成；未获取另一审查者本次新 candidate 报告。）*