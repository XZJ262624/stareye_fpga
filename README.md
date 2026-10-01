# 星眸多算子边缘感知系统

面向2026全国大学生嵌入式芯片与系统设计竞赛FPGA赛道，目标平台为易灵思VF-Ti60F225。
技术路线：摄像头采集→灰度化→滤波→边缘检测→HDMI显示；扩展多算子切换、自适应阈值、彩色叠加、OSD、延迟与资源测试。

当前 P0 进行中，M0～M7 未开始。Git 初始化已经验收，本轮完成首次提交范围收敛，等待用户确认提交。

| 路径 | 用途 |
| --- | --- |
| AGENTS.md | 根目录自动调度规则，保持原样 |
| docs/AI_COLLABORATION_PLAN.md | 原协作方案全文完整迁移 |
| docs/PROJECT_BRIEF.md | 稳定背景、用户知识边界与待确认配置 |
| docs/MILESTONES.md | 阶段目标、验收与状态 |
| docs/STATUS.md | 当前状态、验证证据与 Git 检测 |
| docs/HANDOFF.md | 当前一次任务的统一八节交接单 |
| docs/DECISIONS.md | 已确定事实与决定 |
| document/ | 完整厂商资料、驱动、安装器与视频集合；保持原位，整个目录暂时不进入 Git |
| reference/competition/、reference/board/、reference/camera/、reference/examples/ | 后续比赛、板卡、摄像头与参考工程分类位置 |
| rtl/、tb/、constraints/ | 后续源码、仿真与约束位置 |
| efinity/、scripts/、reports/ | 后续工程、脚本与验证报告位置 |

背景、状态、决定和交接以 docs/ 为统一事实源，自动调度仍以根 AGENTS.md 为准。原方案全文保留，当前操作遵守用户本轮授权范围。

本轮没有复制安装包或参考工程，新增工程目录为空，未放 .gitkeep。Git 不跟踪空目录，后续有实际文件再纳入版本管理。
Git 仓库已初始化，当前分支 main，无提交。首次暂存仅包含 .gitignore、AGENTS.md、README.md 与 docs/ 中六份 Markdown 项目文档；未执行 git commit，未生成 RTL，未进入 M0。
根 .gitignore 排除整个 document/ 和 reports/git_baseline_inventory/，保留原有 Efinity 生成目录、仿真缓存、Python 缓存与临时文件规则。以后只将经过筛选的必要资料复制到 reference/；本轮不移动、不删除 document/ 内任何文件。
指导操作先解释目的，一次只给1～3个实际操作；真实硬件连接、下载与画面需要用户确认。
