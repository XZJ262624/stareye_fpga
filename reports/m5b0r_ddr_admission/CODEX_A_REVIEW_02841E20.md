# Codex A 独立复审：02841e20

审查日期：2026-10-09

审查对象：candidate `02841e20e297e4e6fdd14db0762a91d7089232fb`，parent `6c44df8c5edc10c45a59c4c867e3fc44a6e7456d`。

**最终结论：FAIL。** 上轮五项问题的针对性修复已经落实，但DDR侧ACK边界仍存在孤立握手风险，当前TB没有覆盖该风险。此结论不否定独立诊断工程原有的编译和STA结果，项目闸门仍应保持`NO_GO`。

| 严重程度 | 文件/位置 | 问题 | 证据 | 影响 | 建议 |
| ---- | ----- | -- | -- | -- | -- |
| 阻断 | [m5b0r_arbiter.sv:54](F:/Projects/stareye_fpga/rtl/m5b0r_ddr_admission/m5b0r_arbiter.sv:54)、ACK分支第75行 | A状态下，ACK有效时仍可能形成DDR地址握手，随后仲裁器清除事务 | `avalid=state==A`未受ACK抑制。当`state=A、ddr_reset_ack=1、aready=1`时，下游可观察到握手；同一边沿仲裁器优先执行ACK分支进入IDLE。现有契约只要求“真实DDR复位且客户端epoch刷新后ACK”，未保证ACK期间控制器仍处于复位或READY为零 | 复位后的控制器可能接受孤立命令，仲裁器却不再跟踪其数据或响应 | 明确并实现ACK边界的下游握手隔离，或提供可验证的控制器复位契约。同步审查W/B/R边界；不得破坏普通soft_reset期间保持 stalled VALID 的要求 |
| 重要 | [tb_m5b0r_arbiter.sv:75](F:/Projects/stareye_fpga/tb/m5b0r_ddr_admission/tb_m5b0r_arbiter.sv:75)、第79行 | 新增检查只覆盖客户端地址READY，ACK期间仍跳过DDR握手观察 | ACK前独立断言仅检查`c_aready`；随后ACK分支清除总线模型并跳过DDR握手记账。新增三请求测试从IDLE开始，没有直接覆盖A状态下ACK与DDR READY同时有效 | `accepted==completed+cancelled`可以通过，而下游孤立握手仍未被发现 | 增加A状态ACK/READY重叠定向测试；将真实控制器复位与ACK分别建模，不得直接用ACK跳过全部总线检查 |
| 重要 | [m5b0r_evidence_verify.py:45](F:/Projects/stareye_fpga/scripts/m5b0r_evidence_verify.py:45) | candidate模式没有验证实际提交差异全部属于scope | 检查遍历清单中的文件并比较blob，但没有将`parent→candidate`实际变更路径与允许清单比较；scope校验器也没有补上该检查 | 后续候选若额外提交清单外文件，验收器可能仍通过。本次独立比对未发现实际遗漏 | 增加实际Git差异与scope的覆盖检查，处理新增、删除及重命名，并增加“额外提交文件”的负向测试 |

ACK分支保留的`owner、local_id、len、address、write_op`目前不是独立缺陷：回到IDLE后不产生有效地址事务，下一笔合法受理会覆盖这些字段。`rt_turn`保留延续轮转，不会单独造成饥饿；现有要求也未规定每个epoch必须固定从客户端0开始。

上一轮问题的关闭情况：

| 上轮问题 | 本轮判断 |
| ---- | ---- |
| ACK期间客户端READY成立但请求被丢弃 | **已关闭**：`c_aready`增加`!ddr_reset_ack` |
| TB隐藏客户端ACK握手、缺少多周期覆盖 | **原问题已关闭**：三路VALID跨多周期ACK、独立READY断言及撤销后三笔完成均已加入；DDR侧仍有上述盲区 |
| 诊断计划缺少独立完整性检查 | **已关闭**：独立计划约束9967事务、356927写拍、357128读拍，并检查地址、类型、长度、写模式和walking bit；复位恢复重新执行完整计划 |
| 缺少提交后candidate复验模式 | **已关闭**：支持精确candidate、唯一parent、空索引、干净跟踪工作区及清单blob比较；scope完整覆盖仍需补强 |
| 文档53/54用例不一致 | **已关闭**：统一为54例 |

实际审查对象及范围：

- Branch：`codex/m5b0r-ddr-admission`
- Candidate／当前HEAD：`02841e20e297e4e6fdd14db0762a91d7089232fb`
- 唯一Parent：`6c44df8c5edc10c45a59c4c867e3fc44a6e7456d`
- 主要审查修复增量的23个文件，并检查相关事务、复位、证据及构建不变量。
- 索引为空，跟踪工作区干净。历史未跟踪文件未纳入审查。
- 未发现本次增量修改M2～M5A保护工程、M5B.0模型或生产视频链路。

执行的只读检查包括Git身份及差异检查、candidate模式证据验收器、`m5b0r_scope.py --verify`，以及独立blob、大小、SHA-256、日志和STA解析。两个验收器均通过；197项清单载荷与candidate一致，实际增量没有清单外路径。

没有重跑HDL仿真。本轮核查了已归档测试的源码绑定、原始日志和负向突变：

- diagnostic：54例；monitor：6个内部子用例。
- arbiter：5个常规种子及1个独立种子，合计完成123002笔。
- 九项负向验收具有对应失败记录；八项RTL突变与当前源码的预期修改一致，真实验收驱动均非零退出。
- **未发现为获得PASS而削弱检查、跳过用例或复用不匹配源码结果的证据**；但仲裁器ACK测试存在明确覆盖盲区。

诊断工程的13项构建输入相对parent未改变，仲裁器未集成到诊断I3工程，因此复用原构建和112份STA合理。独立解析得到449条setup、449条hold结果，最小裕量为`+0.100/+0.021 ns`；资源为7391 XLR、30 RAM10、0 DSP。这些结果不代表仲裁器已综合或完成STA。

bitstream实际核对一致：

- 大小：**2,157,846字节**
- SHA-256：`249b4b5e4095da1e7466f94d510c17de4588161c37de484a0eff427304cef3f3`
- 被Git忽略且未提交；`hardware_tested=false`，`gate=NO_GO`。

未能验证真实DDR高地址与保留区安全、控制器ACK桥接行为、实时视频最坏服务时间、720p60共存及跨PVT稳定性。软件和仿真证据不能替代这些实物验证。

可交给Codex exec的最小修复清单：

1. 关闭A状态ACK边沿的下游孤立握手风险，并审查W/B/R同类边界。
2. 增加独立DDR侧ACK定向测试及对应负向突变，避免ACK清账掩盖握手。
3. 补齐candidate实际变更与scope覆盖校验及负向测试。
4. 重跑受影响测试并更新证据绑定；诊断构建输入保持不变时，无需重新生成bitstream。

本轮未修改文件、暂存、提交、切换分支或执行任何硬件操作，未查看DeepSeek B报告。
