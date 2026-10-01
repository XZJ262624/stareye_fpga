# 星眸项目交接单

## 1. 基本信息
- 交接编号：H-20261001-03。
- 当前里程碑：P0（进行中），本轮为首次提交范围收敛。
- 交出角色/模型：GPT-6.1 Sol，Medium；完成限定范围写入后停止写入。
- 接收角色/模型：主会话／主调度者，负责最终复核。
- 当前 Git 提交或工程版本：仓库 F:/Projects/stareye_fpga，分支 main，无提交；首次暂存范围为根三份文件与 docs/ 六份 Markdown，共 9 份。

## 2. 本轮目标
- 要解决的问题：忽略完整 document/ 和 reports/git_baseline_inventory/，将 master 改为 main，核对内部引用并只暂存允许的 Markdown 项目文档和根文件。
- 完成标准：分支 main，忽略规则保留；暂存列表严格等于 .gitignore、AGENTS.md、README.md 与 docs/ 中六份 Markdown 文档；无大型文件、无提交、无未暂存文档修改；主会话验收。
- 本轮允许修改的范围：.gitignore、README.md、docs/ 项目文档中的当前状态和内部引用、分支名称与暂存区；必要时更新 DECISIONS 记录用户已确定的资料排除策略。
- 禁止修改/必须兼容的内容：AGENTS.md 和完整原协作方案保持原样；document/ 不移动、不删除、不修改；reports/git_baseline_inventory/ 历史证据保留原样；不进入 M0、不生成 RTL、不使用 git add .、不 commit。
- 安装介质处理：本轮全部保留在 document/，该目录整体暂时不进入 Git；以后只复制筛选后的必要资料到 reference/。

## 3. 已完成并验证
- 完成功能：首次提交范围已收敛，等待用户确认提交；新增完整目录忽略规则，保留原有生成目录和缓存规则，分支改为 main，仅按九份允许文件的完整清单暂存。
- 验证方式：分支、status、cached stat、完整暂存路径与 blob 大小、未跟踪且未忽略清单、无 HEAD、原文件哈希及空实现目录静态检查；主会话复核 document/ 元数据。无 RTL 或硬件验证。
- 证据文件或日志：本轮工具输出；历史 reports/git_baseline_inventory/ 六份清单/摘要保持原样并忽略，历史 10,019 个未跟踪文件与暂存 0 只描述范围收敛前，详见 STATUS.md 的历史检查节。
- 主会话验收结果：通过；精确九文件暂存、main 分支、无 HEAD、无未暂存或未忽略的未跟踪文件，最大 blob 11,093 字节；直接路径忽略探针和保留探针均通过，document/ 元数据与两个原文哈希未变。
- 路径核对：README.md 和 docs/ 的项目内部引用使用相对路径；F:/Projects/stareye_fpga 是必要仓库操作记录。G:\Tools\Efinity 本轮检查不存在，只保留历史目标路径记录，不要求本轮移动安装介质。
- 已知可工作的硬件配置：待确认。

## 4. 当前工程状态
- 顶层模块：待确认。
- 相关源码：厂商资料位于 document/，主线 rtl/、tb/、constraints/ 为空。
- 时钟与复位：待确认。
- 输入/输出接口：待确认。
- 关键参数、位宽和分辨率：待确认。
- 安装介质：document/ 内两份 MSI 和 efinity-2025.1.110.5.9-windows-x64-patch/，不属于工程源码。
- 统一交接路径（相对本文件）：PROJECT_BRIEF.md、STATUS.md、DECISIONS.md、HANDOFF.md。

## 5. 当前问题
- 现象：首次提交范围已经收敛；驱动、安装器、PDF 和视频所在的 document/ 整体忽略，提交仍待用户确认。
- 稳定复现步骤：执行 git status --short、git diff --cached --stat、git diff --cached --name-only 和 git ls-files --others --exclude-standard，检查 main 分支及暂存 blob 大小。
- 预期结果：本轮暂存范围仅为根三份文件和 docs/ Markdown，document/ 与管理盘点记录全部忽略，分支 main。
- 实际结果：首次提交范围已收敛，等待用户确认提交；九份允许文件暂存，无提交，安装介质保留原位；Sol 完成静态检查后交回主会话复核。
- 已尝试方案及结果：普通执行因 setup refresh 错误无法启动，经升级执行必要读检、分支改名和明确清单暂存；Git 只使用单次 safe.directory 参数，未改全局配置。
- 关键报错/波形/报告路径：STATUS.md 和本轮工具输出；reports/git_baseline_inventory/ 只为历史证据，本轮不新增报告，无硬件验证。

## 6. 已确定的设计决定
- 决定：用户授权本轮明确路径暂存，但禁止 commit；document/ 与 reports/git_baseline_inventory/ 整体暂时排除，其他关键 reports/ 保留；默认分支改为 main。
- 原因：用户本轮明确授权。
- 被否决方案及原因：不删除或越过写入权限移动安装介质。

## 7. 下一步
1. 首次提交范围已收敛，等待用户确认提交；本轮不执行 commit。
2. 原始 document/ 和历史盘点保留本地；后续按用户指定范围筛选必要资料复制到 reference/。
3. 保持 P0 进行中，M0～M7 未开始；需要真实配置的信息仍为待确认。

## 8. 风险与待确认事项
- 需要用户实测：实际硬件配置继续待确认，本轮无上板任务。
- 缺少的资料：比赛要求、硬件清单、显示目标、安装版本和参考工程基线仍待确认。
- 可能影响后续接口的事项：时钟、复位、管脚、分辨率、像素格式均待确认。
- 文件盘点边界：疑似敏感检查只报告路径与判断，不打印密钥内容，不声称完成全部二进制内容审计。
- 尚未纳入版本控制的目录：空目录不会出现在 Git 未跟踪列表；document/ 和 reports/git_baseline_inventory/ 整体忽略，其他实际报告未来可按任务范围纳入。
