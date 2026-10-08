# M5B.0R candidate归档复核

2026-10-08，Codex exec按H-M5B0R-20261008-CANDIDATE归档现有离线成果。不是Codex A独立审查。分支 `codex/m5b0r-ddr-admission`，父提交 `ba28397cc5f0d4b34ed06b803c8e5af067c9ca98`，提交消息 `feat: add isolated DDR admission diagnostics`。candidate哈希及提交后状态以Git与交接回复为准，避免循环自引用。

范围为PROPOSED_GIT_SCOPE.json的files数组加清单自身；清单中的文件数、字节数不包括清单自身。原189项范围增加AGENTS.md、docs/AI_WORKFLOW.md、docs/REVIEW_PROTOCOL.md、.gitattributes和本轮两份归档/保护记录；管理文档及范围脚本更新属于原范围。无RTL、工程输入、已验证测试或实现证据的功能修改。

本轮 `.gitattributes` 仅追加五条M5B.0R专属 `-text` 规则，原阶段规则保持，确保工程输入、RTL/TB、脚本和报告的逐字哈希在Git中可复验。按明确路径逐文件以命令级 `core.autocrlf=false` 暂存，其余管理文档亦保留当前字节；没有修改仓库或全局Git配置。清单记录工作区字节；提交前必须逐个读取暂存blob并核对大小及SHA-256，包括单独核验清单自身，因此最终提交blob口径与工作区一致。

使用Efinity配套 `E:/Efinity/2025.1/bin/python3.bat` 运行最终证据验收器和范围验收器。最终证据验收器检查既有13项最终输入、53项实现输出、112份STA、bit及离线测试源码/日志绑定。本轮只读复核，未重新仿真、编译或运行Programmer。该证据验收器包含提交前父HEAD及空索引断言；candidate提交后直接运行会因HEAD推进而拒绝，不能据此称证据失效。完整重放还需本地保留的原始日志和实现生成物，它们按要求不提交；不能声称仅克隆Git即可重放全部验收。

本轮保护核验见CANDIDATE_PROTECTION_CHECK.json：10,469文件、2,267,684,832字节，SHA-256/大小/mtime和完整文件集合相同；历史1,550未跟踪文件完整保留且未跟踪。PROTECTED_BASELINES_AFTER.json和ROOT_REVIEW.md原先空索引/四管理文档描述是离线历史快照，不覆盖本轮新授权范围。

已有结果：HDL诊断54例、monitor6情形、六种子仲裁合计123,000完成事务、四个负向验收；软件28地址故障与11协议规格用例。完整I3诊断构建及112份STA通过，setup/hold最小+0.100/+0.021ns，7391 XLR/30 RAM10/0 DSP。bit位于 `efinity/m5b0r_ddr_address_diag_i3/outflow/M5B0R_DdrDiag.bit`，2,157,846字节，SHA-256 `249b4b5e4095da1e7466f94d510c17de4588161c37de484a0eff427304cef3f3`；保留本地并忽略，不提交。

排除bit/outflow/work/数据库/缓存/锁/波形/原始日志/失败探索/负向副本/reference/tools和历史未跟踪资料。DDR源码ROM `ip/DdrCtrl/ddr3_controller.bin` 是与M2相同的必要源输入，属于明确例外，并非bitstream或生成数据库。

闸门继续 **NO_GO**。真实高地址/保留区、端到端Lmax、水位/CDC/预填充、实际DDR仲裁epoch取消桥接及720p60共存未验证；真实分类帧与fps证据缺失，窄hold/PVT、PLL/CORE参考及I/O边界保留。未接入生产，未下载或写Flash。candidate完成后停止写入，由Work检查并交用户委派独立Codex A。
