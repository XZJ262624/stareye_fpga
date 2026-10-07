# M5A最终提交范围与历史清单差异

本轮用户授权归档实物功能PASS并独立提交，提交信息`feat: add streaming local canny pipeline`；分支`codex/m5a-streaming-canny`，新提交直接父节点必须为M4 `95bf83f7172ecdf11ee9b8deb3e2c1bba535a56d`。主会话完成最终清单、逐项暂存、blob独立校验和提交后检查；本文件说明选择规则，不预先宣称已提交。

## 原清单与本轮差异

原拟提交为254文件、12,063,517字节，原始JSON已逐字保存为[PROPOSED_GIT_SCOPE_BEFORE_HARDWARE.json](PROPOSED_GIT_SCOPE_BEFORE_HARDWARE.json)，该历史JSON的SHA-256为`9b783a7b6e2f6e04d88ad25fd1dfde783785ce0f28284ef4f24c4d51e48c7227`。其旧文件数/字节数及历史空索引标记不代表提交后的当前状态。

相对原清单新增的用途是：

- `.gitattributes`：只追加M5A工程、RTL、TB、脚本及报告的`-text`规则，保持Git blob与源/实现证据SHA逐字一致；既有M2～M4规则不改。
- `docs/PROJECT_BRIEF.md`：更新当前阶段为M5A PASS，避免背景文档仍写M5未开始。
- `HARDWARE_ACCEPTANCE.md`：归档用户2026-10-07总体实物功能PASS及证据边界。
- `PROPOSED_GIT_SCOPE_BEFORE_HARDWARE.json`：保留原清单供差异复核。
- `GIT_SCOPE_REVIEW.md`：本范围说明。
- `ROOT_HARDWARE_ARCHIVE_REVIEW.md`：由主会话记录本轮独立复核。

既有清单内README、STATUS、HANDOFF、MILESTONES、DECISIONS及M5A构建/模式/算法边界/历史复核报告更新实物状态和首行例外；`scripts/m5a_streaming_canny_scope.py`仅增加`.gitattributes`与PROJECT_BRIEF白名单。没有修改业务RTL、TB、工程、构建/黄金算法/验收器，也没有开发M5B占位RTL。最终数量和字节数因归档及主会话真实复核内容而变化，不能机械追求254。

最新完整路径、每文件大小及SHA-256见[PROPOSED_GIT_SCOPE.json](PROPOSED_GIT_SCOPE.json)与[CSV](PROPOSED_GIT_SCOPE.csv)。JSON/CSV自身不写自己的哈希以避免循环自引用；清单包含自身大小，主会话在最终暂存时另核对这两份blob。最终Git blob大小可能受非M5A共享文档文本规范化影响，最终以主会话实际暂存/提交blob统计为准；M5A源及证据必须逐字保持。

## 白名单、保护和排除

保留M4已提交外围复制输入、新M5A实现/测试/复验脚本及与最终构建绑定的必要文本证据。DDR ASCII初始化ROM `efinity/m5a_streaming_canny_i3/ip/DdrCtrl/ddr3_controller.bin`为必要源码输入，是已有清单的明确例外，不是bitstream或生成数据库。

逐项暂存，不使用`git add .`或`git add -A`。排除bit、outflow、work、生成数据库、缓存、锁、波形、临时日志、reference、tools、无关历史reports/tb/scripts以及根目录无关图片。原未跟踪文件按“归档起始集合减实际提交路径”检查，其他文件必须全部保留；原1,550份历史资料继续排除。M2～M4的3,022可读保护文件/集合按原快照复核，旧M4临时.lock缺失已在离线阶段单列，本轮不删除或恢复未知锁。

## 复验时点

`m5a_streaming_canny_scope.py`及旧`final_gate`包含M4父HEAD、空索引等提交前断言，生成清单和离线门禁时适用。提交后HEAD与文件跟踪状态改变是本次授权结果，不能将旧Git状态断言失败解释为算法或STA证据失效。需独立验证源码、bit/最终DB和94份STA绑定并检查提交实际父节点/范围。旧离线JSON保留历史PASS_OFFLINE_HARDWARE_PENDING语义，用户硬件PASS另见HARDWARE_ACCEPTANCE.md。
