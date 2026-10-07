# 分析轮次变更范围（历史）

允许且实际新增业务交付仅位于 `reports/m5b0_global_canny_architecture/`：

- 架构/审计：M5B0_ARCHITECTURE.md、DDR_SOURCE_AUDIT.md、DDR_ADDRESS_MAP.md/.json、GLOBAL_HYSTERESIS_OPTIONS.md、BANDWIDTH_AND_LATENCY.md、BANDWIDTH_MODEL.json、BUFFER_OWNERSHIP_AND_CDC.md、M5C_INTERFACE_RESERVATION.md、RESOURCE_FEASIBILITY.md、GO_NO_GO.md、REPRODUCE.md、CHANGE_SCOPE.md。
- 软件/结果：models.py、run_models.py、check_addresses.py、calculate_bandwidth.py、protocol_model.py、MODEL_RESULTS.json、SOFTWARE_RESULTS.md、ADDRESS_CHECK_RESULTS.json、PROTOCOL_RESULTS.json。
- 主会话管理证据：PROTECTED_BASELINES_BEFORE.json、后续保护/独立复核/范围清单及root_replay软件复验目录；具体最终列表与哈希由主会话归档。本清单不自称包含尚未生成文件的既有证据。

必要项目管理文件：docs/STATUS.md、docs/HANDOFF.md、docs/PROJECT_BRIEF.md、docs/MILESTONES.md、docs/DECISIONS.md；新增当前M5B.0完成与NO-GO边界，保留旧阶段历史记录，不更改M5A PASS事实。

未创建或修改任何生产RTL、Testbench HDL、Efinity工程/副本、IP/约束、M2～M5A旧报告与脚本、bitstream。没有编译、Programmer、JTAG/下载、Flash、暂存、提交、合并、推送、未跟踪清理。分支由主会话按授权从M5A基线创建，架构代理不执行Git mutation。

完整保护范围按主会话BEFORE快照，10430可读文件、2264422457B，另1个无法读取锁只比较元数据、1550历史未跟踪路径。完成后的精确相等性和当前Git状态以主会话AFTER/最终审查为准，不以本代理未执行全量后哈希的文字代替证据。

主会话已反馈完成AFTER复算：10430可读文件/2264422457B的SHA256、size、mtime及保护文件集合全一致，1550原未跟踪全部保留。唯一M5A/.lock大小7B与mtime保持，内容不可读，因此只做元数据比较，不能宣称该锁内容哈希通过。最终证据文件由主会话独立保存。

## 当前归档提交范围

以FINAL_CHANGE_SCOPE.json重新生成的实际清单为准。原43文件增加根README更新、.gitattributes本报告目录专属-text规则及ARCHIVE_PROTECTION_CHECK.json，最终46文件。报告文字归档修正、六项继续阻断、完整收敛措辞及历史/当前快照标注均解释在ROOT_REVIEW.md归档节。原软件模型、测试结果及旧工程未改。用户本轮授权按清单暂存并独立提交，不删除历史资料，不进入M5B.1。Git clean blob的大小/SHA记录于最终清单，清单自身由主会话外部复核，不循环包含自身SHA。
