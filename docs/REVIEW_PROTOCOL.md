# Codex A与DeepSeek B独立审查协议

## 审查启动条件

只有满足以下条件才可启动正式审查：

- candidate已提交并拥有固定commit哈希；
- parent、branch和commit scope明确；
- 测试、构建、STA、资源及bitstream元数据已形成报告；
- 暂存区为空，Writer已停止；
- Work已说明已知限制和审查重点。

Codex A由用户在另一个可见Codex对话中委派。它默认只读，不修改代码、不暂存、不提交、不运行Programmer、不下载、不写Flash。

DeepSeek B由Work通过OpenCode自动调用，作为第二视角只读审查者。用户已长期授权发送固定candidate的隔离快照。Work必须验证快照逐文件等于candidate，并排除`.git`、未提交内容、密钥、`.env`、工具包、原始未跟踪资料和用户私人文件。branch、candidate和parent由Work验证并作为已知事实提供；DeepSeek B不得因快照缺少Git元数据而否定其固定性。

两位审查者必须独立形成结论。在各自报告完成前，Work不得把另一位审查者的问题表或结论提供给它。DeepSeek B必须明确使用“DeepSeek B第二独立审查者”身份，不得自称Codex A。

## Work提供的审查包

```text
项目/阶段：
Branch：
Candidate commit：
Parent commit：
Commit scope：
构建报告：
测试报告：
STA/资源报告：
Bitstream路径、大小及SHA-256：
已知限制：
重点审查项：
禁止操作：
```

审查对象始终是candidate commit与parent之间的固定差异。工作区内未提交的内容、历史未跟踪资料和后续变化不属于审查对象。

## 审查者输出格式

| 严重程度 | 文件/位置 | 问题 | 证据 | 影响 | 建议 |
|---|---|---|---|---|---|

严重程度至少区分阻断问题、重要问题和建议项。没有问题时也应说明检查过的范围、运行过的只读检查以及未能验证的边界。

最终结论只能是：

- `PASS`：没有阻断下一闸门的问题。
- `PASS_WITH_FINDINGS`：可以进入下一闸门，但存在必须记录的非阻断问题。
- `FAIL`：存在必须由Codex exec修复并重新审查的问题。

## 复审

`FAIL`后由Work整理问题并冻结修复规格，Codex exec追加修复commit。Codex A与DeepSeek B复审原candidate、修复commit及新的HEAD，不改写旧提交。复审仍使用相同表格和三种最终结论。

独立审查通过不等于实物验收通过，也不自动放行下一生产阶段。是否进入实物节点或下一里程碑由Work结合既有闸门条件决定。
