# Codex A独立复审：e734d527

本次重新审查了新candidate，**上一轮的三个问题均已关闭：DDR侧ACK孤立握手、TB遗漏ACK边沿观察、Git范围门缺少实际差异覆盖检查。** 未发现新的阻断性实现问题。

| 严重程度 | 文件/位置 | 问题 | 证据 | 影响 | 建议 |
| ---- | ----- | -- | -- | -- | -- |
| 建议 | [ACK_EDGE_FIX_REPORT.md:11](F:/Projects/stareye_fpga/reports/m5b0r_ddr_admission/ACK_EDGE_FIX_REPORT.md:11) | “每种子20500笔完成”与独立种子日志略有差异 | 五个常规种子均为20500；独立种子20261009实际为accepted 20516、completed 20501、cancelled 15 | 不影响账目平衡和测试通过，但报告统计不够准确 | 写成“每种子至少完成20500笔”，或分别记录实际数量 |
| 建议 | [HANDOFF.md:11](F:/Projects/stareye_fpga/docs/HANDOFF.md:11) | 必读交接文件嵌入另一审查者的旧结论摘要 | 读取指定HANDOFF时会接触该摘要 | 不利于保持盲审输入隔离 | 后续提供不含另一审查者结论的审查交接版本 |

实际确认的Git身份：

- Branch：`codex/m5b0r-ddr-admission`
- Candidate／HEAD：`e734d527a149e318ac5009257dab90642c19cb59`
- 唯一Parent：`02841e20e297e4e6fdd14db0762a91d7089232fb`
- 实际增量：**21个文件**。
- 暂存区无变化，跟踪工作区干净；历史未跟踪资料未纳入审查或清理。

关键复核结果：

- **ACK隔离完整**：[仲裁器](F:/Projects/stareye_fpga/rtl/m5b0r_ddr_admission/m5b0r_arbiter.sv:56)同时屏蔽DDR侧A/W VALID、B/R READY，以及客户端地址/写数据READY和响应VALID。ACK采样后进入IDLE；未发现新增组合环。安全性仍依赖ACK真实且在本时钟域安全使用。
- **soft_reset语义保持**：新增门控只使用`ddr_reset_ack`，普通soft_reset没有直接切断在途A/W，原排空与超时逻辑保持。
- **ACK测试有效**：[TB](F:/Projects/stareye_fpga/tb/m5b0r_ddr_admission/tb_m5b0r_arbiter.sv:76)在清账前检查握手；定向激励偏离驱动边沿，确认A/W/B/R状态及对端有效信号，六个种子日志均达到`ack_edge_seen=1111`。未发现新增定向测试自我满足或零覆盖。
- **负向验收有效**：十三项失败日志、验收驱动非零退出及源码突变一致；新增四项分别检出A/W/B/R ACK门控移除。没有只凭模拟器退出码判断。
- **Git范围门已补齐**：[生产验证函数](F:/Projects/stareye_fpga/scripts/m5b0r_evidence_verify.py:10)使用NUL分隔和`--no-renames`检查实际差异，删除集合必须等于`deleted_paths`，并逐文件比较candidate blob。本次没有删除或范围外变更。
- **构建复用合理**：13项诊断构建输入相对parent逐字不变；仲裁器未接入诊断工程。53项实现输出和112份STA绑定通过，报告明确没有宣称仲裁器已综合或通过STA。

执行过的只读检查包括Git身份、父节点和差异检查，candidate模式证据验收器、scope校验器、独立大小/SHA-256/blob比较及STA解析。还对**现存七个真实Git夹具**重新调用生产范围门：三项允许操作通过，四项范围外操作被拒绝，没有创建或修改夹具。

**本轮没有重跑HDL仿真。** 已独立检查归档日志与当前源码绑定：diagnostic 54例、monitor 6个子用例、六个仲裁种子及十三项负向验收。未发现为通过而削弱测试、跳过用例或使用不匹配源码结果的证据。

实际bitstream核对一致：

- 大小：**2,157,846字节**
- SHA-256：`249b4b5e4095da1e7466f94d510c17de4588161c37de484a0eff427304cef3f3`
- 被Git忽略且未提交。

独立解析112份STA，得到449条setup及449条hold结果，最小裕量为 **+0.100／+0.021 ns**。资源记录为 **7391 XLR、30 RAM10、0 DSP**；这些仅属于独立诊断工程。

仍未验证真实高地址与保留区安全、生产复位/epoch桥接、仲裁器综合及时序、DDR最坏服务时间、720p60共存及跨PVT稳定性。硬件未验收，`hardware_tested=false`口径和`NO_GO`必须保持；本次复审不放行M5B.1。

未打开DeepSeek B报告。指定HANDOFF中嵌入的旧摘要未作为本轮判断依据。全程未修改、暂存、提交或执行任何硬件操作。

**最终结论：PASS_WITH_FINDINGS**
