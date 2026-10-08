# 星眸三角色开发流程

## 角色

Work是项目负责人、架构负责人、项目经理和最终闸门，负责冻结任务、选择模型、检查证据、决定GO/NO-GO，并向用户解释结果。Work可以直接完成规划、文档、配置和小范围明确修改，但不承担主要核心RTL开发。

Codex exec是主要开发者。它按照`docs/HANDOFF.md`中的冻结规格独占写入，负责核心RTL、Testbench、仿真、Efinity工程、综合、P&R、STA、调试、修复以及创建candidate commit。

Codex A是用户在另一个可见Codex对话中委派的独立审查者。它只读审查固定candidate commit及parent，不自行修复。当前Work对话不得把内部代理审查称为Codex A审查。

DeepSeek B是第二独立审查者。用户长期授权Work在每个candidate节点自动生成并发送固定commit的隔离只读快照。Work必须先验证快照与candidate逐文件一致；快照不得包含`.git`、未提交文件、密钥、`.env`、工具包、原始未跟踪资料或用户私人文件。DeepSeek B不负责验证Git元数据，也不得称为Codex A。

用户负责实物连接、JTAG临时下载、画面与LED观察以及最终实物反馈。代理不得代替用户声称完成实物验收。

## 标准流程

1. Work读取`PROJECT_BRIEF.md`、`STATUS.md`、`DECISIONS.md`和实际Git状态，生成冻结的`HANDOFF.md`。
2. Codex exec成为唯一Writer，在允许范围内实现、测试和构建。
3. Codex exec按精确清单创建candidate commit，报告commit、parent、范围和证据。
4. Work独立检查candidate、证据绑定、受保护范围和工作区状态，然后冻结仓库。
5. Work在不提供Codex A报告的情况下，自动把经验证的candidate隔离快照发送给DeepSeek B只读审查。
6. Work停止，向用户提供可直接发送给独立Codex A对话的审查提示词。
7. 用户完成Codex A审查，并把`PASS`、`PASS_WITH_FINDINGS`或`FAIL`及问题表反馈给Work；Work同时收集DeepSeek B报告。两位审查者完成前不得互相看到报告。
8. 任一审查结论为`FAIL`时，Work生成修复规格交回Codex exec；修复采用追加提交，不rebase或改写candidate历史。随后重新执行双审查节点。
9. 双审查完成且无`FAIL`、并需要上板时，Work提供bitstream绑定信息、安全边界和逐项验收清单，然后停止。
10. 用户完成实物操作并反馈，Work归档实物证据，再决定阶段PASS、保留问题或下一阶段。

## 模型调度

- L1简单任务由Work直接处理。
- L2常规工程任务优先使用GPT-6.1 Sol，默认Medium；需要细致排查时提高推理等级。
- L3复杂或关键任务使用GPT-6 Astra，默认Medium；极难问题和关键最终复核可以提高等级。
- 模型等级不改变角色边界。内部Astra只读复核仍属于Work/Codex exec流程，不能替代用户委派的独立Codex A。

## Writer和冻结规则

- 任一时刻只能有一个Writer。
- Codex exec写入时，不启动Codex A审查。
- Codex A或DeepSeek B审查期间，Work和Codex exec不得修改candidate工作区。
- 审查必须绑定branch、commit、parent及范围；未提交工作区不能作为正式审查对象。
- 不使用`git add .`或`git add -A`，只按明确文件清单暂存。
- 不删除未知未跟踪文件，不提交bitstream、outflow、数据库、缓存、锁文件或工具包。

## 停止节点

Work必须在两个节点主动停止并交还用户：

1. 固定candidate已完成，等待用户委派独立Codex A审查。
2. 独立审查通过且离线条件满足，等待用户执行实物验收。

只有用户明确反馈审查结束或实物验收完成后，Work才能继续相应后续阶段。
