# M0 独立提交范围

本轮纳入 `.gitignore`、README、M0相关docs、厂商LED英文副本源码/XML/SDC、必要辅助脚本及全部M0相关文本证据。显式逐文件路径/字节数、总大小和最大文件记录在已忽略的 `reports/git_baseline_inventory/m0_commit_scope.json`，主会话按该清单复核，不使用 `git add .`。清单在全部文档写入后生成，避免自身大小自引用。

包含 `original_before.json` / `original_after.json` 可核验元数据及90份可读内容哈希；原 `.lock` 内容不可读取，仅有元数据核验。`invalid_sta_default_C4.timing.rpt` 明确为无效历史审计证据，不参与I3验收；最终时序以 `LED_8bit_Test.timing.rpt` 为准。

排除 `document/`、用户 `tools/` / `reference/`（包括赛题PDF）、AGENTS及原协作方案、本地历史盘点、生成 `outflow/` / `work*` / `build/`、锁、缓存、bit/hex/lbf/vdb等大型产物。现有原始资料及产物保留原位，不删除或改动。根忽略规则不全局屏蔽log/rpt/bin/hex，关键报告保持可提交。

提交哈希以 `git log` 为准；此文件只描述范围与证据取舍，不嵌入本提交自身哈希。
