# 星眸项目状态

更新日期：2026-10-01。

## 当前阶段与交接

- P0：进行中；M0～M7：未开始。
- AGENTS.md 已经识别；已有自动模型调度原则保持不变。
- 自动委派能力已经具备；骨架初始化、Git 初始化和首次提交范围收敛均顺序委派 GPT-6.1 Sol，Medium，未调用 Astra；同一时间只有一个主线写入者，主会话负责最终验收。
- 文件化交接初始化已完成：指定目录及文档已写入，子代理自查后交回主会话，主会话静态验收通过；P0 背景与需求冻结仍进行中。
- 未生成任何 RTL，未进入 M0；无仿真、综合、时序或上板实现可报告为完成。

## 检测与文件状态

- Git：仓库根目录 F:/Projects/stareye_fpga；首次提交范围收敛后，分支由 master 重命名为 main。
- 初始 Git 基线提交：f7f0fa2753011a04744b4b2d8a5ffc0f24446dac，提交信息 chore: initialize StarEye project；提交包含已验收的九份文件。随后仅对 STATUS.md 和 HANDOFF.md 的哈希记录使用 docs: record initial Git baseline 单独提交；该记录提交的哈希以 git log 为准。
- .gitignore：新增 /document/ 与 /reports/git_baseline_inventory/，保留原有 Efinity 生成目录、仿真缓存与波形、Python/编辑器/系统临时文件规则；未全局忽略 log、rpt、bin、hex，其他 reports/ 内容仍可进入版本控制。
- 原方案完整迁移至 docs/AI_COLLABORATION_PLAN.md；AGENTS.md 与 document/ 原始资料保持原样。
- rtl/、tb/、constraints/、efinity/、scripts/ 与 reference/ 分类目录仍为空，未创建 .gitkeep；Git 不跟踪空目录。reports/git_baseline_inventory/ 是上一轮生成的历史盘点证据，本轮保持原样并忽略。
- 验证方式：目录、文档、SHA256 与 Git 的静态检查；证据为本轮工具输出，无硬件测试报告。

## 历史骨架初始化主会话验收证据

- 2026-10-01：静态检查命令退出码 0，输出 PASS；11 个指定目录、7 个目标文档、PROJECT_BRIEF 必填内容、P0/M0～M7 状态及交接单八节全部通过检查。
- AGENTS.md SHA256：EBEE0F615170A818A504618D943F774FB3BAF34E0925EF424EC1EC78F937EAAF，与修改前一致。
- docs/AI_COLLABORATION_PLAN.md SHA256：FAF0766E27756554DFC6C000F0E54D40CCF246D95E6C2B0A680AF62923D59695，与原中文文件一致；原中文路径已移除。
- 四个 reference 分类目录及 rtl/、tb/、constraints/、efinity/、scripts/、reports/ 均为空；没有新增 RTL 或实现报告。
- README 与六份 docs 文档已逐份复核；DECISIONS 仅记录用户已确定事实和明确授权，未知配置保持待确认。

## 历史 Git 基线初始化检查（2026-10-01，范围收敛前）

以下数字和 master/空暂存区状态只描述上一轮初始化时的历史结果，不代表本轮当前 Git 状态；历史清单保留原样。

- Git 状态：No commits yet on master；未跟踪聚合项为 .gitignore、AGENTS.md、README.md、docs/、document/、reports/。
- 完整文件清单：reports/git_baseline_inventory/untracked_files.txt（10,019 项）、ignored_files.txt（2,850 项）、ignored_directories.txt（117 个目录或独立文件聚合项）。
- 检查摘要、较大文件与敏感候选分别见同目录 summary.json、large_files.csv、sensitive_candidates.csv；清单包含自身，均未暂存。
- 已忽略大型安装介质：两份 MSI 分别为 760,184,832 与 980,733,952 字节；展开补丁共 1,179 个文件、172,204,138 字节；均留在 document/ 原位。
- G:\Tools\Efinity 为上一轮安装介质存放建议的本地路径记录；本轮检查该路径不存在，保留历史记录。本轮不执行移动，安装介质全部继续留在 document/ 原位。
- 生成目录聚合统计：56 个 outflow/、26 个仿真 work/；连同补丁、临时波形和缓存，共忽略 document/ 内 3,536,264,660 字节。
- 原始资料核验：document/ 12,854 个文件，共 5,782,997,603 字节；路径、大小、最后修改时间的元数据 SHA256 为 38B30CCD20C70AFEFCA8CA01B3670289958579B4CA7DAD6A91A43DB7D9936309，与本轮写入前一致（不是逐文件内容哈希审计）。
- 敏感检查：文件名候选与不超过 2 MiB 的 9,131 份文本高置信密钥/私钥标记检查，候选 0、读取失败 0；未审计二进制或压缩包内部，不保证不存在所有类型的敏感信息。
- 仍可被暂存的非源码程序：CH341SER.EXE、sscom5.13.1.exe、dpinst32.exe、dpinst64.exe、dpscat.exe、InstallDriver.exe，位于厂商 02-Software&Driver/，详见 summary.json。它们不是 Efinity 安装包，本轮未擅自移动或新增排除决定。
- 较大资料仍可被暂存：约 355.23 MiB PDF、127.02 MiB 和 63.40 MiB MP4、61.42 MiB PDF；完整路径见 large_files.csv，后续提交范围待确认。
- 验证：git status、仓库根目录、空暂存区、无 HEAD、安装介质 check-ignore、虚拟生成文件忽略探针、reports/log/rpt/bin/hex/RTL/SDC/TCL 保留探针均通过；主会话已复核 AGENTS 与原协作方案 SHA256 不变。
- 执行环境：沙箱身份曾触发 dubious ownership，仅用单次 git -c safe.directory=F:/Projects/stareye_fpga 检查，未改全局配置；沙箱工具连续 setup refresh 错误后，经获批沙箱外执行完成必要盘点。无额外文件移动、暂存或提交。

## 历史首次提交范围收敛（2026-10-01，首次提交前）

- 首次提交范围已收敛，等待用户确认提交。
- document/ 是完整厂商资料、驱动、安装器与视频集合，整体暂时不进入 Git；以后只将经过筛选的必要资料复制到 reference/。
- 仅按明确的九份允许文件清单执行 git add，不使用 git add .；不暂存 document/、安装器、驱动、PDF、视频或历史盘点目录。
- README.md 与 docs/ 六份 Markdown 已检查绝对路径；项目内部引用使用相对路径。F:/Projects/stareye_fpga 是有效仓库操作记录，G:\Tools\Efinity 保留为不存在的历史目标路径，不当作当前可用路径或必须移动任务。
- 验收检查包含分支、git status --short、git diff --cached --stat、完整暂存文件列表和 blob 大小、未跟踪且未忽略文件列表、无 HEAD、原文件 SHA256 与空实现目录；本轮静态验证由 Sol 执行，主会话复核。
- 主会话最终验收通过：main 分支、精确九文件暂存、无提交、无未暂存修改、无未忽略的未跟踪文件；所有暂存 blob 小于 1 MiB，最大为原协作方案 11,093 字节；忽略及保留探针通过，document/ 元数据与原文哈希不变。
- 保持 P0 进行中，M0～M7 未开始；没有实现或硬件验证任务。

## 首次 Git 提交记录（2026-10-01）

- 用户已确认首次提交；主会话执行 chore: initialize StarEye project 成功，初始基线哈希为 f7f0fa2753011a04744b4b2d8a5ffc0f24446dac。
- 作者姓名 dav、邮箱 kqojp23@163.com 由用户提供，仅配置当前仓库，没有修改全局 Git 配置。
- 首次提交后的 git status：On branch main；nothing to commit, working tree clean；工作区和暂存区均为空。
- git log -1 --oneline --no-abbrev-commit 返回上述完整哈希和指定提交信息；分支检查为 main。
- 本轮仅更新本文件和 HANDOFF.md 记录初始基线哈希，使用 docs: record initial Git baseline 单独保存；不开展额外工程检查、不进入 M0、不生成 RTL、不调用 Astra。

## 待确认实际配置

| 事项 | 状态 |
| --- | --- |
| 比赛正式赛题、评分规则、提交要求与目标指标 | 待确认 |
| 实际板卡型号、版本、器件与状态；供电、下载器与实际连接 | 待确认 |
| 摄像头型号、接口、初始化方式与连接 | 待确认 |
| 显示器、显示连接与演示目标 | 待确认 |
| 分辨率、帧率与像素格式 | 待确认 |
| Efinity 是否安装、安装版本、补丁状态与兼容性 | 待确认 |
| 主线参考工程基线、来源版本及使用范围 | 待确认 |
| 顶层模块、像素流接口、管脚、时钟与复位 | 待确认 |
| 滤波/边缘算子、阈值方案、资源与延迟目标 | 待确认 |
| 已验证可工作的配置 | 待确认 |

资料中的安装包与补丁不能代表实际安装版本，参考工程文件不能代表主线基线或已上板验证。
初始 Git 基线已建立；保持 P0 进行中，M0～M7 未开始。后续工作等待用户指定，已有真实配置待确认信息继续保留。
