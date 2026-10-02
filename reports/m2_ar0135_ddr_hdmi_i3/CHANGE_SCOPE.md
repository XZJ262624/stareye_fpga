# M2未提交变更范围

> 历史定位：本文件保留离线构建/上板前审查或当时工作区盘点结论，原始证据不改写。2026-10-03用户已确认新I3 JTAG实时取图、720p60及10～15分钟定性正常，M2基础链路PASS；最新以[实物验收报告](ACCEPTANCE_REPORT.md)为准。当前工程再生成差异另由主会话核查，历史匹配记录不证明全部当前输入一致。

2026-10-03；这是一份工作区清单，不是暂存或提交操作。当前main，HEAD仍为M1 d2f48c6e8befa16c9eedea9c07aca82ff16b9879，暂存区0文件。

更新的已跟踪文件：

- `.gitattributes`
- `.gitignore`
- `README.md`
- `docs/AR0135_PRECONNECT_CHECK.md`
- `docs/DECISIONS.md`
- `docs/HANDOFF.md`
- `docs/MILESTONES.md`
- `docs/PROJECT_BRIEF.md`
- `docs/STATUS.md`

新增M2工作副本、脚本、DDR参数/构建/时序/告警/接线/CDC报告；本次盘点新增M2 548个未忽略文件，连同已跟踪修改共557文件/27,239,961字节（不含本清单和change_scope.json自身）。完整路径与大小见[change_scope.json](change_scope.json)。该清单包含保留的厂商IP测试/附带文件，不能整目录盲目提交。未来应显式选取必要源/配置/脚本及最终文本证据，历史失败报告是否保留另行审查。

已检查outflow、work/work_pnr/work_syn、bit、锁、Python缓存与M2 IPM pickle缓存受忽略；关键reports log/rpt保留，没有全局忽略bin/hex。DDR指令初始化ddr3_controller.bin是IP所需配置输入，不能当安装器删除。实际bit/hex/LPF/LBF/VDB在生成目录内受忽略。

reference/tools为既有未跟踪用户资料，不纳入本清单；未修改或暂存，document原厂候选457项哈希/元数据不变。未git add/commit、不Programmer、不下载、不Flash。
