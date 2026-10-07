# 星眸项目状态

## 2026-10-07 M5B.0归档状态（当前）

M5B.0分析完成，最终结论保持 **NO-GO**：全局Canny算法软件可行性通过，M5B.1生产RTL和整机DDR接入不放行。用户本轮授权独立归档提交`docs: assess global canny architecture feasibility`，直接父提交为`4e0496e8a36f53dcfffa9e9564ffbf0f780a55ba`。分支`codex/m5b0-global-canny-architecture`；新提交ID及提交后状态以实际Git复核为准，避免循环记录自身哈希。

六项缺口继续阻断：DDR高位译码/物理可达/校准保留；多主仲裁与真实AXI响应；视频FIFO服务界限；真实分类帧统计；新增综合/STA/资源；DDR压力与720p60共存实物验证。本轮不关闭任何缺口。当前归档保护检查发现历史唯一不可读M5A/.lock现已不存在，原因未确认，本轮未操作该锁；不得沿用历史锁元数据不变结论。10430可读文件按哈希/大小/mtime核对，见[当前保护](../reports/m5b0_global_canny_architecture/ARCHIVE_PROTECTION_CHECK.json)。下文“未暂存/未提交/HEAD不变”为上轮分析快照，本轮归档授权已覆盖该停止限制。只归档报告、软件模型及管理文档，没有生产RTL、新工程、全局bitstream、硬件验证或融合。见[归档主审](../reports/m5b0_global_canny_architecture/ROOT_REVIEW.md)、[最终范围](../reports/m5b0_global_canny_architecture/FINAL_CHANGE_SCOPE.json)。

## 2026-10-07 M5B.0分析快照（历史，归档状态见上文）

项目m5b0_global_canny_architecture：架构、DDR源码/候选地址/带宽审计和软件可行性分析完成。**最终NO-GO：M5B.1生产RTL或DDR接入尚不放行；算法软件单项GO。** M5A保持原实物功能PASS，M5B硬件未实现。

推荐2bit冻结分类快照、前反向八连通传播、1bit工作/结果双缓冲。19683个3×3穷举与30图（15完整720p）全部等于BFS；典型合成4～8扫，横/竖蛇362/642扫；真实分类场景0帧。地址候选[0x01000000,0x010E7000)，新增已证明安全容量0；单modified AXI口、UI96MHz、共享DDR峰1.536GB/s，实时安全预算未测，不能保证720p60不阻塞或1～2fps。

协议34项契约用例通过，只有收敛且复制前reserve、写响应栅栏和descriptor合法才发布；64双向轮/1秒watchdog失败保留旧有效结果或无结果。资源粗估新增6k～16kXLR/33～64RAM10/0DSP，待综合。需先解除地址译码/校准保留区、多主事务响应/QoS、实时FIFO服务界限和真实场景指标阻断。见[闸门报告](../reports/m5b0_global_canny_architecture/GO_NO_GO.md)。

本轮只报告、Python模型和必要管理文档；未生产RTL、未工程副本、未编译、未bit、未Programmer/下载/Flash、未暂存/提交/合并/推送。完整保护、当前Git及主会话独立复核由同目录最终证据绑定；下文旧授权/停止边界属于对应历史阶段。

主会话独立复核完成：630组随机图/9990像素、两项确定性用例及独立union-find完整720p竖蛇通过；全部穷举/30图、地址负向、34项协议及带宽负向已独立重跑。M2～M5A共10430可读文件/2264422457B的hash/大小/mtime与保护文件集合未变，唯一不可读锁只比较元数据；1550历史未跟踪文件全部保留。实际分支`codex/m5b0-global-canny-architecture`，HEAD仍`4e0496e8a36f53dcfffa9e9564ffbf0f780a55ba`，索引为空。见[主会话审查](../reports/m5b0_global_canny_architecture/ROOT_REVIEW.md)、[最终保护](../reports/m5b0_global_canny_architecture/PROTECTED_BASELINES_AFTER.json)、[最终范围](../reports/m5b0_global_canny_architecture/FINAL_CHANGE_SCOPE.json)、[Git状态](../reports/m5b0_global_canny_architecture/FINAL_GIT_STATUS.json)。到此停止，不进入M5B.1。


更新日期：2026-10-07。

## 当前阶段与交接

- P0：其余需求仍待冻结；M0/M1/M2基础链路实物PASS，M2为新I3相机→DDR→HDMI、1280×720@60Hz、10～15分钟定性正常。**M3 m3_sobel_core：实物功能PASS、图像质量待调优；M3.1控制与阈值比较离线PASS、用户确认实物阈值正常；M3.2交付模块验收PASS，整机离线集成PASS，实物功能与当前运行条件下的稳定性验收PASS；窄hold裕量及跨PVT鲁棒性作为保留边界。**；**M4离线仿真、完整I3编译、STA和实物功能验收PASS（保留已知首行异常）**；M5A完成离线算法验证、完整I3编译、STA及用户实物功能验收，阶段PASS；M5B及M6～M7未开始。
- AGENTS.md 已经识别；已有自动模型调度原则保持不变。
- 自动委派能力已经具备；历史骨架/Git初始化顺序委派Sol/Medium，M1与本轮M2按L3顺序委派Astra/Medium；同一时间只有一个主线写入者，主会话负责最终验收。
- 文件化交接初始化已完成；M0最小LED副本基础验收通过并提交，M1实物验收见历史记录，本轮M2离线迁移收尾见文末及H-20261003-12。其余外设/需求仍不冻结。
- 历史P0资料核查曾委派Sol/Medium但pending_init，取消后由主会话接手；历史最小LED工程选择由Sol/Medium只读核查。当前M1的Astra委派与验收见文末。
- M0仅复制厂商LED示例；配置/完整编译及用户JTAG、流水灯定性结果已验收，不新增算法RTL。M0 bit持久性和长期稳定性未验证；M1独立HDMI已由用户定性验收；显示参数和复位鲁棒性边界见文末。

## 检测与文件状态

- Git：仓库根目录 F:/Projects/stareye_fpga；首次提交范围收敛后，分支由 master 重命名为 main。
- 初始 Git 基线提交：f7f0fa2753011a04744b4b2d8a5ffc0f24446dac，提交信息 chore: initialize StarEye project；提交包含已验收的九份文件。随后仅对 STATUS.md 和 HANDOFF.md 的哈希记录使用 docs: record initial Git baseline 单独提交；该记录提交的哈希以 git log 为准。
- .gitignore：新增 /document/ 与 /reports/git_baseline_inventory/，保留原有 Efinity 生成目录、仿真缓存与波形、Python/编辑器/系统临时文件规则；未全局忽略 log、rpt、bin、hex，其他 reports/ 内容仍可进入版本控制。
- 原方案完整迁移至 docs/AI_COLLABORATION_PLAN.md；AGENTS.md 与 document/ 原始资料保持原样。
- rtl/m3_sobel_core已有五个Sobel流水线模块，tb/m3_sobel_core有流/720p集成/mapped行RAM测试；efinity/m3_sobel_core_i3是独立M3工程。M0/M1/M2和M2已编译源快照保留，scripts/reports含可复验脚本与证据；document/reference/tools未改动。
- 验证方式：静态检查、官方编译/时序证据及用户硬件报告；硬件结果见文末M0验收，主会话未独立操作板卡。

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

## 本轮 P0 资料核查（2026-10-01）

- 证据索引与读取范围：[SOURCES.md](SOURCES.md)；工具关系、兼容边界与建议安装顺序：[TOOLCHAIN.md](TOOLCHAIN.md)。
- 正式题目已确认：赛题四“基于 FPGA 的实时图像边缘检测系统”，平台 VF-Ti60F225 / Ti60F225。指南基础项包括摄像头至少 640×480、灰度化、3×3 Sobel 与可配置阈值、HDMI 至少 640×480@60Hz 的灰度/边缘对照显示；提交 RTL、约束与演示视频。
- 提高项已确认：中值滤波、实时阈值调节、DDR 帧存储、Canny、彩色叠加和形状识别。完整评分权重、截止日期/上传细则不在所给指南中。
- 板卡手册记载 VF-Ti60F225-C 核心板、VF-Ti60F225-B 底板、Ti60F225I3；不等同于实物已确认。手册版号、XML C4 与 I3、DDR 2 Gbit/4 Gbit 等差异均记录在 SOURCES.md，未自行消除。
- 本地主 MSI 发布版本 2025.1.110（ProductVersion 25.1.110）、IDE 2025.1.0.10（ProductVersion 25.1.0.10）、补丁 2025.1.110.5.9 已从只读元数据/说明确认；未启动安装。软件尚未安装，由用户明确提供。
- 候选推荐为主程序 2025.1.110 后配套补丁 5.9；官方 2025.1 指南支持 Ti60F225，但旧 HDK 全部工程兼容性未验证。已读示例保存版本为 2023.2.307.5.10 或 2023.1.150.3.11，版本路线未冻结。
- FPGA 下载驱动资料为 ELITES-232DL / VID_0403&PID_6014；实际下载器未知。原理图串口为 CH340N；未建议 CH341 驱动、未运行驱动。纯 FPGA 方案建议暂缓 RISC-V IDE。
- 读取边界：只读关键 PDF、版本备注、少量 XML、补丁说明/manifest、MSI 数据库和 INF；未全量遍历 document，未展开新增相机 ZIP。PDF 文字提取完成，关键页渲染后图像查看工具失败，不能宣称视觉逐页检查完成。
- 当前已提交基线：f7f0fa2753011a04744b4b2d8a5ffc0f24446dac 与 43d7cc6331cbc4c8f251f16834675534d5d2a8e6；分支 main。本轮四份文档保留为未提交修改/新增，用户已有赛题 PDF 为未跟踪资料；未执行 git add 或 commit。
- 主会话静态验收通过：四文档本地链接无缺失，交接单八节齐全，AGENTS.md 与原协作方案 SHA256 不变，实现目录仍为空；git diff --check 无格式错误，暂存区为空，变更仅为两份已跟踪文档、两份新增文档及用户已有赛题 PDF。Git 的 LF/CRLF 提示不影响上述检查。
- PROJECT_BRIEF.md、DECISIONS.md 按本轮四文件写入范围保持原样；其中历史“待确认”与本轮新结论之间，以本节及 SOURCES.md 为当前核查记录。

## 历史下载器与板卡连接验收及最小工程选择

- 证据来源：用户本轮明确报告的实际连接结果，主会话未独立操作硬件。
- 下载器 UB-ELITE-001；驱动 ELITES-232DL / libusbK；USB ID 0403:6014。
- Efinity Programmer 识别为 Single RS232-HS / Generic FT232；JTAG 连接成功。
- Device ID 0x10660A79；Programmer 显示 Valid device ID found。
- 尚未选择 bitstream，未下载、未 SPI Flash 固化；连接识别验收通过，不能标记点灯或工程实现已验证。
- Programmer 已可实际使用；前文“软件尚未安装”仅描述上轮资料核查时状态。当前 Efinity 主程序版本、补丁、安装位置和许可状态仍待用户确认。
- 当前开始 VF-Ti60F225-C 最小参考工程选择与编译前核查，尚未编译，不标记 M0 实现完成。
- 用户要求：编译前核对器件、封装、时序模型、顶层与管脚；禁用不匹配的现成 bitstream，首次验证只允许 JTAG 临时下载，不做 SPI Flash 固化。
- 本机卸载登记只读查询：Efinity 2025.1，DisplayVersion=25.1.110，InstallLocation 为空；当前运行工具完整版本、补丁和许可不能据此推断。
- 已选择厂商 01_LED_8bit_Test 为最小核查候选；器件 Ti60F225（FBGA225）、模型 C4、顶层 LED_8bit_Test，来源 2023.2.307.5.10。不是已验证主线基线，尚未复制或修改工程。
- 顶层/源文件对应，PLL 24→96 MHz 与 SDC 10.4167 ns 一致；9 个时钟/LED 引脚及 3.3 V LVCMOS 已与管脚表/核心原理图定向交叉核对。完整清单见 [MINIMAL_REFERENCE_CHECK.md](MINIMAL_REFERENCE_CHECK.md)。
- 编译门槛尚未关闭：实物 FPGA 后缀/PCB 版本、当前工具版本/模型合法组合、外设是否占用 LED6/7 共享 GPIO 待确认；原示例开启 debugger 自动插入，建议在后续审核副本关闭，本轮未修改。
- 没有编译、仿真、综合、下载或 Flash 操作；用户验收仅为 JTAG 识别，不标记点灯通过。P0 尚未整体冻结，本轮授权到参考工程选择/编译前核查。
- 主会话最终静态验收：六份相关文档链接无缺失、六项用户 JTAG 事实齐全；AGENTS/原协作方案与七份厂商候选源配置/RTL/调试文件 SHA256 保持不变；实现目录为空，git diff --check 通过，main 分支/暂存区为空。用户已有 tools/ 与 reference/ 文件保留，未暂存或提交。

## P0 历史待确认清单（历史清单，最新状态以文末M2记录为准）

| 事项 | 状态 |
| --- | --- |
| 完整评分权重、提交日期/入口/格式及报告模板 | 待用户确认 |
| 实物核心板/底板版本、FPGA 后缀、DDR 颗粒容量及状态 | 待实物确认 |
| 下载器/驱动/USB ID、JTAG 识别 | 已由用户验收；具体供电与板卡版本仍待实物确认 |
| 摄像头型号、DVP/MIPI 接口、适配板及连接 | 待实物确认 |
| 显示器与线缆、实际连接 | 待实物确认 |
| 版本路线、Windows/架构/资源、安装目录/权限、账号/许可与介质来源 | 待用户确认 |
| 2025.1.110+5.9 对所选 HDK 工程的导入/IP/实现/下载兼容结果 | 待用户确认；尚未验证 |
| 主线参考工程及使用范围、最终分辨率/帧率/像素格式 | 待用户确认 |
| 管脚、时钟、复位与顶层接口 | 待实物确认 / 待用户确认；未冻结 |
| 提高项取舍、阈值方案、资源与延迟目标 | 待用户确认 |
| 已验证可工作的软硬件配置 | 待实物确认；本轮无运行验证 |

以上为历史资料核查状态；当前已进入M0并确认实际工具和实物型号，最新状态见文末。资料与软件介质不能代替硬件验证。

## M0 最小参考工程启动（2026-10-01）

- 用户本轮明确确认实物 FPGA 完整型号为 **Ti60F225I3**。确认方式为用户文本确认；具体丝印/照片/BOM方式未提供，主会话未独立检查实物，不依据 JTAG ID 推断后缀。
- 用户此前确认直接下载厂商自带点灯 .bit 并跑通；这不是当前 Efinity 重新编译或 I3 时序验收。
- 本轮授权建立英文路径工作副本 `efinity/m0_led_i3/`，通过 Efinity 配置工具确认 Titanium / Ti60 / F225（FBGA225）/ I3，重新生成接口文件，关闭调试自动插入后完整编译。
- 已定位安装目录 `E:/Efinity/2025.1/`；实际补丁及各编译工具版本正在核查，不将注册表 25.1.110 当作补丁证明。
- 原始 01_LED_8bit_Test 完全只读；不运行 Programmer、不下载、不执行 SPI Active 或 Flash 固化；新 bitstream 生成后暂停。
- 摄像头/扩展外设实际断开状态、核心板 PCB 版本仍待实物确认，尤其 LED6/7 与 CMOS_D0/D1 共享；离线编译可进行，后续下载前须确认连接。
- 按 AGENTS.md 本任务按 L2 顺序委派 GPT-6.1 Sol / Medium；主会话准备交接并最终验收，代理工作期间主会话只读检查。

## M0 离线编译验收（2026-10-01）

- 结论：英文副本 `efinity/m0_led_i3/` 在 Efinity **2025.1.110.5.9** 完整编译通过；M0 仍为进行中，新的 I3 bitstream 未下载、未做实物点灯验收。
- 实物型号 **Ti60F225I3** 来自用户本轮文本确认；具体丝印/照片/BOM方式未提供，主会话未独立查看实物。此结论不是从 JTAG ID 或厂商 C4 bitstream 推断。
- 工具安装目录 `E:/Efinity/2025.1/` 的 MANIFEST 与实际接口/综合/P&R/STA/bitstream 报告均证实版本；未安装软件或改动安装目录。
- 官方 `projectdb.EfxProjectDatabase` 设置 Titanium / Ti60F225 / I3（其中 Ti60F225 为 Ti60+F225，封装 FBGA225），顶层 LED_8bit_Test；关闭 auto_instantiation，清空调试 profile。`DesignAPI.load/check_design/save/generate` 更新并重生成器件接口，非手工 XML 字符串替换。
- 24 MHz 输入 C5/GPIOL_11_PLLIN2；PLL 官方计算输出96 MHz，输出时钟 SDC 官方模板舍入为10.417 ns。新约束 LED_8bit_Test_I3.sdc 为实际约束，保留的原 VIP_System.sdc 不参与编译。
- LED0..7 保持 P15/P14/R14/N14/N13/P13/R3/R4，均3.3 V LVCMOS、输出强度4；原厂顶层/业务RTL接口未变，调试逻辑未插入。
- map/interface/pnr/pgm 均PASS，完整编译返回0；最终重跑I3 P&R与bitstream生成返回0。内部96 MHz逻辑最终setup **+8.395 ns**、hold **+0.092 ns**；I3 final，speedgrade3。
- 资源：56/60800 XLR（0.09%），36 FF、30 LUT4、23 ADD；RAM/DSP均0，PLL1个。检查日志未发现错误/警告消息。
- 约束覆盖：no_clock=0、unconstrained_internal_endpoints=0、multiple_clock=0；PLL_LOCKED无input_delay，8个静态LED无output_delay。内部时序通过不证明异步复位释放的recovery/removal、上电锁定行为或全部I/O路径闭合。
- 附加STA入口默认C4并曾覆盖标准报告；经显式I3审计后重新官方I3 P&R/bitstream生成，主会话已核验最终outflow和归档报告均为I3。默认C4结果不参与验收。
- 新bitstream：`F:/Projects/stareye_fpga/efinity/m0_led_i3/outflow/LED_8bit_Test.bit`；**1,618,062 字节**；SHA-256：`46AC52D70DF7330864C7F2531361D9383E22475EDAC80FD3635EA2C2F43FF2B0`。
- 原厂LED目录91个文件元数据前后完全一致，90个可读取SHA256一致；`.lock`被其他进程字节范围锁定，仅核对路径/大小/修改时间，未宣称91项内容哈希全部通过。副本5份RTL逐字一致。
- [构建报告](../reports/m0_led_i3/BUILD_REPORT.md)、[阶段状态](../reports/m0_led_i3/stage_exitcodes.json)、[最终I3时序](../reports/m0_led_i3/LED_8bit_Test.timing.rpt)、[bit元数据](../reports/m0_led_i3/bitstream.json)、[原目录差异](../reports/m0_led_i3/original_diff.json)。
- 按AGENTS由GPT-6.1 Sol / Medium顺序实现，主会话独立验收；未调用Astra。未Git暂存/提交，未编写Sobel/摄像头/HDMI业务RTL。
- 未运行Programmer或任何program流程，未JTAG下载、SPI Active或Flash固化。离线bit生成保留厂商mode=active及hex选项，属于文件生成配置，不是Program Flash操作；后续仅使用审查后的.bit进行经确认的JTAG临时下载。
- 摄像头和扩展外设断开状态待实物确认，尤其LED6/7与CMOS_D0/D1共享；新I3点灯现象待用户确认。

## M0 上板基础验收与提交范围（2026-10-01，历史提交前）

- M0基础验收通过：I3完整编译PASS、用户报告JTAG配置PASS、流水灯功能定性PASS。
- 用户确认 Device ID `0x10660A79`、Programmer `Device is in user mode`、JTAG下载成功。报告为用户文字摘录，未提供原始导出日志；所选bit路径及下载文件哈希未独立核验。
- 用户原文：“从一侧到另外一侧依次点亮熄灭，断电后也会继续运行，但是我之前已经烧录固化过官方的流水灯历程”。未提供LED编号、8颗逐个计数、往返或速度，不补写这些实测。
- 断电重启确有流水灯现象，但历史Flash官方例程与本轮JTAG配置来源未区分；不是本轮固化或当前I3 bit持久性证据。本轮未SPI Active/Flash操作，也没有再次JTAG或长期稳定性测试记录。
- 本轮只读核验bit仍为1,618,062字节，SHA256 `46AC52D70DF7330864C7F2531361D9383E22475EDAC80FD3635EA2C2F43FF2B0`；没有重编译、下载或改动bit。
- 证据见[ACCEPTANCE_REPORT.md](../reports/m0_led_i3/ACCEPTANCE_REPORT.md)、[用户摘录](../reports/m0_led_i3/jtag_user_report.txt)。上文未下载/待点灯段落为此前离线阶段历史。
- 独立M0提交范围已核查，见[COMMIT_SCOPE.md](../reports/m0_led_i3/COMMIT_SCOPE.md)；实际提交哈希以git log为准。仅纳入M0文档、源码/配置、脚本与文本证据，排除资料、缓存、锁及大型bit/hex/lbf/vdb。
- 用户确认摄像头AR0135，具体接口/适配板/实际连接待确认，不由型号推断DVP；用户有HDMI显示器但缺HDMI连接线，线缆待补齐。
- 下一步在M0提交后只读核查AR0135与HDMI参考，优先评估HDMI彩条链路；本轮未读取视频例程，M1尚未开始。

## M1独立HDMI离线任务启动（2026-10-01）

- 用户本轮授权独立HDMI工作副本I3迁移与完整编译，原厂只读；HDMI线缺少，不下载，不接AR0135，不Sobel，不Git暂存或提交。
- M0基线 a8c39c93a06eeb0686cbb5c13fd44717d49195fa 已核对；本轮按L3委派Astra/Medium，交接H-20261001-09。

## M1独立HDMI离线验收（2026-10-01，历史离线阶段）

- 工作副本[Ti60_HDMI_1080P_Test.xml](../efinity/m1_hdmi_i3/Ti60_HDMI_1080P_Test.xml)，Titanium / Ti60F225 / FBGA225 / I3 final；顶层Ti60_HDMI_1080P_Test。官方projectdb配置和DesignAPI检查/保存/接口生成通过；debug自动插入off，未新增业务RTL。
- Efinity2025.1.110.5.9完整map/interface/pnr/pgm通过，外层退出0；pgm仅离线生成文件。本轮未运行Programmer、未下载、未SPI Active或Flash固化。
- 原厂HDMI目录69/69文件路径、大小、修改时间、SHA256完全保持；六份参与编译的RTL逐字相同。M0和AR0135工程未修改。
- 24MHz C5输入，PLL_TL0输出27MHz给PLL_TR0，输出148.5MHz像素和742.5MHz串行时钟；2200×1125总像素对应1920×1080@60Hz。四种测试图源代码目标每秒切换，尚未观察实物画面。
- 旧VIP_System.sdc仍保留但不使用；其25/150/750MHz及单PLL历史模型与当前源不一致。实际约束为重新生成的官方Ti60_HDMI_1080P_Test_I3.sdc，未添加虚构I/O delay或false-path。
- 最终内部setup **+1.656ns**、hold **+0.098ns**；30/30 TMDS并行数据出口定向setup **+4.029ns**、hold **+0.245ns**。no_clock/unconstrained_internal_endpoints/multiple_clock均0。
- 2个LOCKED输入无input_delay，6个LED及sys_pll_RSTN无output_delay；PLL_LOCKED异步释放复位、串行器复位恒0、启动/失锁恢复仍未功能验收。CDC工具无同步器警告不能替代这些检查；无功能仿真/上板视频验收。
- 33条综合warning行含1条汇总，另1条未使用clk_25M接口警告；主要为常量端口位宽、未使用SerialClk/旧输出、循环变量裁剪、clk27m仅供原生PLL及DSP CE配置。完整告警与解释保留，未抑制。
- HDL生成TMDS，原生LVDS串行器经ESD/AC耦合到HDMI插座，无原理图中的外置TMDS发射ASIC。两原理图支持F7=P/F8=N，XLS标签相反；保持源配置。实际PCB版本、电源跳线、信号质量与显示器仍待实物确认。
- bit：`F:/Projects/stareye_fpga/efinity/m1_hdmi_i3/outflow/Ti60_HDMI_1080P_Test.bit`；**1,626,948字节**；SHA256 **D96068C5D88EE861FD70F1FF4C82221DAE5582E5C1642366A631B053EA7B3E89**；未下载，已被.gitignore排除。
- 资源551/60800 XLR、172 FF、436 LUT4、103 ADD、1 DSP、0 RAM、2 PLL、4 LVDS串行通道。M1只确认离线子步骤通过，视频直通阶段继续进行中。
- 资料盘点：reference仅赛题PDF；tools含GTKWave与ELITES-232DL/libusbK驱动（父目录名USB_Blaster不准确）。未运行、移动、安装或暂存，详见[本地资料用途](../reports/m1_hdmi_i3/LOCAL_MATERIALS.md)。
- Git保持main，HEAD仍为M0提交；暂存区为空，本轮未git add/commit。变更范围和大小见[CHANGE_SCOPE.md](../reports/m1_hdmi_i3/CHANGE_SCOPE.md)，生成物排除证据见root_review.json。关键结果见[BUILD_REPORT.md](../reports/m1_hdmi_i3/BUILD_REPORT.md)、[PIN_CLOCK_CHECK.md](../reports/m1_hdmi_i3/PIN_CLOCK_CHECK.md)及[CDC_RESET_REVIEW.md](../reports/m1_hdmi_i3/CDC_RESET_REVIEW.md)。
- Astra完成后停写，主会话独立读取最终报告、核对SHA/源文件/约束与原理图，并接回文档维护；M2～M7未开始。

## M1独立HDMI实物验收与收尾（2026-10-02，历史基线）

- **M1独立HDMI基线：PASS**。完整编译/时序PASS、用户报告JTAG临时下载PASS、测试图定性显示PASS分开记录；不是摄像头直通验收，也不是复位鲁棒性或HDMI电气合规认证。
- 用户确认画面循环显示黑白灰矩形、彩色曲线、横向及竖向多色矩形条纹；持续观察约几分钟，无闪烁、花屏、黑屏、撕裂或其他异常。显示器识别分辨率和刷新率待用户确认；源工程目标1920×1080@60Hz不冒充显示器读数。
- 本轮仅用户JTAG临时下载，未SPI Active或Flash固化；主会话/代理未操作Programmer。原始Programmer日志及实际所选下载文件路径/哈希未提供。历史Flash官方流水灯保留，断电行为不能归于本轮HDMI bit。
- Astra / Medium顺序整改自动验收，主会话独立复核：取消硬编码PASS，读取真实日志/外层状态，检查内部及30路TMDS setup/hold、覆盖范围、精确I3/工具版本和最终DB绑定；46个负向用例全部拒绝。
- 新审计只运行隔离最终实现副本的STA，进程退出0；内部setup/hold +1.656/+0.098ns，TMDS30/30路 +4.029/+0.245ns。原outflow/work_pnr/配置/SDC的路径、大小、SHA256和mtime前后一致，没有重新综合、P&R或生成bit。
- bit仍为1,626,948字节，SHA256 D96068C5D88EE861FD70F1FF4C82221DAE5582E5C1642366A631B053EA7B3E89；完整路径与哈希仅归档，不提交bit。当前DB复制件与新STA绑定已确认；原始构建缺少当时输入哈希，不声称追溯密码学证明bit生成来源。
- **保留风险**：PLL LOCKED异步释放复位/短脉冲、启动和失锁恢复未经专项验证；用户数分钟正常显示不消除该结构风险。33条综合告警及未使用25MHz输入原样保留，详见构建报告。
- Git main；以M0提交a8c39c93a06eeb0686cbb5c13fd44717d49195fa为父基线，独立提交消息`chore: complete M1 HDMI baseline validation`，提交完成与哈希以git log及本轮最终回复为准。显式文件清单见COMMIT_SCOPE.md；.gitattributes仅对M1工程/脚本/报告禁用换行规范化，使暂存blob与证据SHA256逐字对应；排除bit/outflow/work/cache/lock/reference/tools/document，不使用git add .。
- [实物验收](../reports/m1_hdmi_i3/ACCEPTANCE_REPORT.md)、[最终实现绑定](../reports/m1_hdmi_i3/FINAL_IMPLEMENTATION_AUDIT.md)、[下一阶段接线前核查](AR0135_PRECONNECT_CHECK.md)。AR0135尚未连接，摄像头接口/供电/复位、LED6/7共享管脚与旧Flash冷启动必须先核查；M2～M7未开始。

## M2本轮实物确认（2026-10-02）

用户文字确认：AR0135相机PCB V5.0；核心板VF-Ti60F225 V1.5；底板VF-Ti60/125F225 V1.5；DDR丝印SEC 307 / K4B4G1646 / 46E BYMA，用户确认Samsung K4B4G1646E-BYMA，4Gbit、256M×16、512MiB。FPGA为Ti60F225I3，Efinity位于E:/Efinity/2025.1，实际版本2025.1.110.5.9。依据是用户实物文字确认，代理未独立检查实物。原理图MT41J128M16与实物不同，DDR参数按实物重新核查。

相机仍断开，旧Flash官方流水灯仍可能驱动共享R3/R4。V5.0针脚、朝向、供电、电平及冷启动隔离未经确认，禁止接入或上电相机。AR0135CS数据手册p17 Table12规定VIN/VOUT绝对最大VDD_IO+0.3V；旧2019模块图VDDIO=2.8V对应3.1V。若V5.0仍使用该供电且无转换，当前3.3V XCLK/SCL/主动SDA可能超过该上限；这是条件性资料风险，不是实物超压或损坏证据。必须确认V5.0电平转换后才能接线。

本轮授权M2完整离线迁移/编译，不授权Programmer、JTAG下载、SPI Active、Flash、摄像头连接、灰度化或Sobel。离线结果见reports/m2_ar0135_ddr_hdmi_i3/BUILD_REPORT.md；不把编译等同DDR校准或相机直通验收。

## M2离线迁移与主会话验收（2026-10-03，历史离线记录）

- 项目：**m2_ar0135_ddr_hdmi_i3**；阶段：**M2进行中**；实物型号核查主要完成；DDR型号阻塞解除；I3离线迁移/完整编译/已约束路径STA通过；相机接线仍禁止。未标记M2整体PASS。
- 用户实物版本/DDR丝印文字确认见上一节；Samsung K4B4G1646E-BYMA取代旧MT41J128M16原理图作为配置依据，row15/col10/bank3、x16、512MiB；频率192/384MHz保持，CL6/CWL5、额外READ_ENABLE_PIPELINE7显式审查。
- 官方projectdb、IPM与DesignAPI设置Titanium/Ti60F225/I3并再生成接口/SDC；DdrCtrl v5.14、W0_FIFO_8 v8.0/TITANIUM；其他IP和原厂业务RTL保持，不新增算法RTL。
- Efinity2025.1.110.5.9最终第三轮完整构建2026-10-02 20:43:53～20:45:03（北京时间），退出0，map/interface/pnr/离线pgm均PASS。第一轮setup−0.832ns未签收；sys约束统一保守精度10.416ns、CMOS时钟先定义再约束、DDR宽泛时钟组不复制；硬件PLL不变，未放宽DDR路径。
- 主会话独立复核最终数据库/源清单/器件、逐路DDR、出口集合及SHA：全局setup/hold **+0.188/+0.026ns**，DDR输入+0.662/+0.404ns、81路输出+0.635/+0.036ns、30路HDMI数据出口+11.264/+0.070ns。no_clock/内部无约束/多时钟均0；仍有5输入、136输出未定延时，不宣称全部I/O或CDC完成验收。
- 最终bit路径 `F:/Projects/stareye_fpga/efinity/m2_ar0135_ddr_hdmi_i3/outflow/Ti60_Demo.bit`，**2,137,974字节**；SHA256 **524213AA27C5797074E9BD71D0761EB31F9D09AEFAC825FA7201CAA6DD33940A**。不暂存bit；隔离STA前后原DB/bit/生成物SHA及mtime均不变。
- 最新综合批次303条告警记录及1条post-synthesis 100 warnings汇总，非303个独立根因；另三条相邻GPIO噪声提示及IV查找告警。加密DDR内部告警未获完整澄清，复位/CDC/校准/刷新与温度仍须验证。
- 原厂457项、M0 71项内容/大小/mtime不变；M1 142项不变，历史临时.lock移除单独记录，不宣称全部143路径保留。
- Astra/Medium完成受控迁移/编译后因用量限制停止；主会话接回唯一写入权，补齐最终验收与文档。无并发主线写入。
- Git当前main；HEAD仍为M1提交 **d2f48c6e8befa16c9eedea9c07aca82ff16b9879**；本轮未git add/commit，暂存区为空。M2 IPM缓存单独忽略，字节完整性规则扩展至M2；document/reference/tools未修改。
- 尚未确认：V5.0 20针/朝向/电平转换、V1.5实际电源与VREF、旧Flash精确输出与可靠隔离；DDR校准成功、内存读写/容量/温度刷新、相机PCLK/帧率/像素格式实测及M2 HDMI实物结果。相机继续断开，不Programmer、不下载、不SPI Active/Flash、不灰度化/Sobel。
- [构建报告](../reports/m2_ar0135_ddr_hdmi_i3/BUILD_REPORT.md)、[DDR/IP对照](../reports/m2_ar0135_ddr_hdmi_i3/DDR_IP_MIGRATION.md)、[最终证据绑定](../reports/m2_ar0135_ddr_hdmi_i3/FINAL_IMPLEMENTATION_BINDING.md)、[接线/迁移核查](../reports/m2_ar0135_ddr_hdmi_i3/CHECK_REPORT.md)。


## M2最终审查与用户新增实测（2026-10-03，历史上板前记录）

- 用户确认AR0135 V5.0实际引脚与官方demo配置一致；不再将针号一致性作为阻塞。
- 用户确认已下载厂商目录自带.bit，正常获取图像，相机当前仍连接。目录：document/VF-Ti60F225_HDK_V2.1_20251009/07-FPGA_HDL_Image-2023.2/01-1_Ti60_AR0135_HDMI_1280720。厂商参考链路功能通过；此次文件完整路径/hash、下载模式/原始日志、观察时间/显示参数未提供。
- 新m2_ar0135_ddr_hdmi_i3仍为离线编译/已约束STA通过；厂商旧bit实測不等同新I3验收，M2整体进行中。旧文档“相机仍断开/针脚未确认”是此前历史，已被本节用户新事实取代。
- Astra / Medium只读审查，主会话独立复核并写报告。303告警记录：34必须修复或澄清、44已知IP噪声、28实物验证、197当前链路无关；另100网表告警汇总不相加，3接口提示与IV告警单列。
- 已确认实现：SCL/SDA空闲主动高、并非完整开漏；CTL2/3无驱动→最终常0，OE低使能；无CTL0/RESET控制端口。旧图2.8V/3.3V及PCLK分压为条件风险，不证明当前实物不兼容。实际电平/转换、配置前隔离、旧Flash R3/R4争用仍需核实。
- 专用安全启动A＋硬件隔离为候选建议，完整M2固化B需新I3实测后再评估；均未实施。Flash读回支持但会先加载bridge改变FPGA配置；备份/恢复方案已记录，未操作。
- 389项当前构建输入/bit/DB哈希匹配；bit 2,137,974字节，SHA256 524213AA27C5797074E9BD71D0761EB31F9D09AEFAC825FA7201CAA6DD33940A。原厂457项历史清单现仅Ti60_Demo.xml变化，仍C4/保存版本2025.1.110.5.9；不推断原因或覆盖。
- 审查报告：[RELEASE_REVIEW](../reports/m2_ar0135_ddr_hdmi_i3/preboard_release/RELEASE_REVIEW.md)、[20针](../reports/m2_ar0135_ddr_hdmi_i3/preboard_release/CAMERA_PIN_AUDIT.md)、[安全启动/Flash](../reports/m2_ar0135_ddr_hdmi_i3/preboard_release/COLD_BOOT_AND_FLASH_PLAN.md)。
- 本轮不Programmer/下载/Flash、不接拔相机、不编译/STA、不改RTL/IP/工程、不git add/commit；main HEAD仍d2f48c6e8befa16c9eedea9c07aca82ff16b9879，暂存区空。新I3下载/Flash/冷启动测试不自动放行。

## 历史M2新I3实物验收与归档（2026-10-03）

- **M2基础链路PASS**：用户确认新Ti60F225I3 bitstream经JTAG临时下载；AR0135实时图像；显示器识别1280×720@60Hz；连续10～15分钟正常，移动镜头/运动物体时持续更新，无黑屏/闪屏/花屏/冻结/明显撕裂。不是此前厂商旧bit验收。
- 离线I3完整编译/已约束STA、用户JTAG配置、相机功能、HDMI显示及有限时段稳定性分别签收；没有全面DDR压力/全容量/温度/校准信号、CDC/电气/复位/冷启动认证。灰度化延期，M3～M7未开始。
- 本轮用户未SPI Active/Flash，代理未操作Programmer/板卡，未重编译或STA。旧Flash流水灯及R3/R4共享线风险、既有告警/加密IP/复位问题保留。
- 当前构建bit为2,137,974字节，SHA256 524213AA27C5797074E9BD71D0761EB31F9D09AEFAC825FA7201CAA6DD33940A；用户未提供Programmer原始日志/下载时哈希，现有文件身份不冒充下载过程绑定。
- 当前XML及csi_rx/dsi_tx/多FIFO settings/HDL有GUI保存/再生成差异，部分旧.v/.vh缺失；不能宣称全部当前输入与最终已编译构建一致，再生成版本未重新编译。历史389项哈希匹配仅描述当时；主会话另核编译源快照和提交范围，不覆盖用户工程。
- [实物验收报告](../reports/m2_ar0135_ddr_hdmi_i3/ACCEPTANCE_REPORT.md)、[用户反馈整理](../reports/m2_ar0135_ddr_hdmi_i3/jtag_user_report.txt)、[本轮交接](HANDOFF.md)。用户已授权独立M2提交，main父基线d2f48c6e8befa16c9eedea9c07aca82ff16b9879；由主会话最终复核后执行，提交状态/哈希以git log为准，不自动进入后续阶段。

主会话新增只读核查：22业务设计源、peri/SDC、DdrCtrl v5.14及W0_FIFO_8 v8.0与最终构建哈希一致；再生成差异位于附带CSI/DSI及其他FIFO，当前bit未变。已归档独立final_build/source_snapshot，共69文件/2,689,858字节，逐项哈希匹配最终构建输入清单；主会话检查完成，不覆盖当前工程。源基线说明[SOURCE_BASELINE.md](../reports/m2_ar0135_ddr_hdmi_i3/SOURCE_BASELINE.md)已由主会话完成，当前再生成附带IP无新编译证据。

## M3 m3_sobel_core离线验收（2026-10-03，当前状态）

- 用户指定M3范围为两行缓存/3×3/Sobel/阈值，L3由GPT-6 Astra Ultra实现，主会话先审架构并持续只读独立复核；单一写入者。feature/m3-sobel-core，父基线9a6d33db4dd3d5f6842cd43661a9a35409eadf1e；未暂存/提交。
- 从M2已编译69文件快照创建独立工程，五个新增RTL和像素域接入完成；保持I3、74.4MHz像素PLL、720p、DDR/相机/HDMI外部配置和原SDC。显示默认阈值64/二值，提供原灰度/幅值选择；没有滤波/Canny/形状识别。
- **离线PASS**：真实ModelSim独立黄金比较1,066窗口；真实R0_FIFO_8/lcd_driver两帧720p共1,843,200 DE像素和1,835,208算法窗口；mapped行RAM26,882像素。18项仿真破坏检查、26项实际CLI证据负测与8种正向控制通过。
- 官方完整编译退出0，map/interface/pnr/pgm PASS；隔离最终DB的90份I3 STA报告通过，最差setup/hold +0.102/+0.027ns；clk_pixel +7.419/+0.031ns；30路HDMI +11.297/+0.039ns。no_clock/unconstrained_internal_endpoints/multiple_clock均0，既有5/136 I/O例外保留。
- 资源6,535 XLR、50 RAM10、0 DSP；相对M2增加307 XLR和4 RAM10。两条逻辑行实际映射四块2048×4 RAM10；没有新整帧缓存。详细警告302条，比M2末轮少1条端口宽度警告，无新增归一化详细警告。
- bit为2,141,760字节，SHA256 **eb8f1d9d586a319d8c18e37ea3e577c445b4a538d70c7fcd4d681832675fcb1b**。原M2735个可读文件内容/大小/mtime一致，原先不可读的临时.lock消失单列；M2快照69文件一致。
- **Sobel实物未验收**，未Programmer/JTAG/SPI Active/Flash/板卡操作。旧Flash/R3/R4及DDR压力/校准、CDC/复位、电气/冷启动边界保留。M4～M7未开始；M4剩余范围待确认。主会话独立复核已完成，当前停在离线交付点，实物验收待用户后续确认。
- [主会话独立复核](../reports/m3_sobel_core_i3/ROOT_REVIEW.md)：独立复算1,066窗口、重跑34正负CLI、核对最终证据与Git排除，全部通过；未修改冻结实现、未暂存/提交。
- [M3报告](../reports/m3_sobel_core_i3/BUILD_REPORT.md)、[机器验收](../reports/m3_sobel_core_i3/ACCEPTANCE.json)、[交接](HANDOFF.md)。

## M3实物验收与M3.1授权（2026-10-04，当前状态）

用户确认二值Sobel实时显示正常，水平/垂直/斜向边缘可检出，运动持续更新；1280×720@60Hz，10分钟稳定，无黑屏/花屏/撕裂/冻结/错位/重影。**M3实物功能PASS、图像质量待调优。** 阈值64，静止场景存在动态白色散斑，挥动手臂后散斑密度可增可减；原因待区分，不认定为DDR/窗口故障。两张照片已从document/m3_pic只读定位、目视核查并归档。见[M3实物报告](../reports/m3_sobel_core_i3/HARDWARE_ACCEPTANCE.md)。用户授权精准提交M3基线，随后M3.1独立分支/副本仅增加三模式、8位阈值按键调节、同步消抖和当前值显示/记录；不改相机/DDR/HDMI/窗口/Sobel核，不加中值，完成仿真/离线编译后暂停，不下载或Flash。旧Flash冷启动风险保留。

M3独立基线已保存：7a9b448080fd6f1624c2ef37ee2eb267fed49c82（feat: establish verified M3 Sobel baseline）；精准242文件，排除bit/生成物/reference/tools，M3源码/证据字节经主会话逐项核对。M3.1当前分支codex/m31-sobel-controls，英文副本efinity/m31_sobel_controls_i3，尚未放行实现；Astra/Medium正在只读核查按键。M2/M3/五核初始指纹已保存于reports/m31_sobel_controls_i3/BASELINE_IMMUTABLE.json。

## 2026-10-04 M3.1离线收尾
M3冻结提交7a9b448080fd6f1624c2ef37ee2eb267fed49c82；M3仍为实物功能PASS、图像质量待调优。分支codex/m31-sobel-controls，工作副本efinity/m31_sobel_controls_i3，M3.1仿真/完整编译/94份最终已约束STA PASS，实物未测试、不自动提交。主会话接管最终验收，实际运行1正向25负向、重新仿真，1018受保护文件无变化。报告见../reports/m31_sobel_controls_i3/BUILD_REPORT.md。旧Flash和PLL异步复位风险保留。两键原先复用旧LCD输出，M3不可按；仅M3.1通过官方API改输入。硬件未操作。


## 2026-10-06 M3.2交付签收与离线集成
- 用户确认M3.1已经上板且阈值调节正常；未补充全部模式与长期稳定性，不扩大实物结论。M3.1原工作树尚未提交，Git父提交仍为M3 7a9b448080fd6f1624c2ef37ee2eb267fed49c82。
- M3.2交付模块独立验收PASS：安全ZIP核查、79文件完整清单/大小/SHA、Astra/Ultra静态审查、全部队友测试重跑、主会话独立排序黄金和负向测试均通过。见../reports/m32_median_review/MODULE_ACCEPTANCE.md。
- 当前项目m32_median_integration，阶段M3.2；分支codex/m32-median-integration。仅创建efinity/m32_median_integration_i3及启用滤波变体m32_median_integration_enabled_i3，原M2/M3/M3.1及共享核保持不变。
- Astra/Ultra完成模块与架构审查、首版新包装及官方配置；后续代理触发使用限额，主会话接管，独立完成整链路仿真、告警整改、两套完整Efinity 2025.1.110.5.9 I3编译、各94份最终STA、17项真实CLI负向验收及证据绑定。
- M3.2离线集成PASS，实物未验证。默认旁路、启用滤波两种bit均已生成；RAW原灰度、MAG、BIN保持三模式与原两键手势，彩色仅预留数据接口。固定1650拍行周期，增加中心重锚与光栅延迟；不支持任意行内valid停顿的整链路重锚协议。
- 旧Flash流水灯冷启动与相机共享R3/R4风险、PLL异步复位/失锁恢复、旧外设未约束I/O、窄hold裕量和散斑成因均保留。本轮未Programmer、下载、SPI Active操作或Flash；未暂存、未提交Git。见../reports/m32_median_integration_i3/BUILD_REPORT.md。


## 2026-10-06 M3.2实物签收与顺序提交
用户明确确认默认旁路RAW/MAG/BIN、阈值/OSD及720p60正常；启用中值低阈值孤立白点明显减少、高阈值差异小，主要轮廓保留，无运动残影/异常边界/挥手后白点大幅持续增加。长时间连续运行与反复模式/阈值切换正常，具体时长、阈值值与PVT范围未提供。
M3.2交付模块验收PASS，整机离线集成PASS，实物功能与当前运行条件下的稳定性验收PASS；窄hold裕量及跨PVT鲁棒性作为保留边界。启用版STA+0.194/+0.026 ns，长时实物正常不证明跨PVT。旧Flash冷启动/R3/R4风险保持。见../reports/m32_median_integration_i3/ACCEPTANCE_REPORT.md。
本轮按实际HEAD确认M31尚未提交，用户授权先M31再M32独立提交；主会话独立核对清单、依赖、暂存blob与父子关系。最终提交以git log为准；不重新编译、不Programmer/下载/Flash/断电测试/M4，不合并main或推送。

## 本轮归档限制
M3.1历史构建的原位置生成物存在25项缺失、6项变化，不能完整重放原验收器；保留审计副本bit/LPF/LBF及94份STA已独立匹配。详见../reports/m31_sobel_controls_i3/PRECOMMIT_EVIDENCE_CHECK.json。本轮不恢复或重编译。M3.2历史交付重放需本地handoff交付内容；最终整机源码闭包已纳入清单。

## 顺序提交记录（2026-10-06）
M3.1已独立提交：742d8a461b36f5970f7caea04fb8f8c925fe8a02，feat: add runtime Sobel controls and OSD，203个文件、7774280字节（提交涉及文件的最终blob总大小）。父提交为M3 7a9b448080fd6f1624c2ef37ee2eb267fed49c82。M3.2将以此为直接父提交，feat: integrate optional median filter；其自身ID以git log为准，避免在提交内容中循环写入自身哈希。当前分支codex/m32-median-integration；仅归档与顺序提交，不进入M4。

## 2026-10-06 M4历史离线完成状态（实物签收前）
M4离线开发与完整编译通过，实物彩色叠加效果待验收。分支codex/m4-color-overlay，HEAD3424514afe1721dc000495673c0ca757ea1f6372不变，暂存区为空，未提交。新工程efinity/m4_color_overlay_i3，四模式RAW/MAG/BIN/OVR、20ms消抖、+16/−16阈值及帧边界生效、OSD优先；启用中值且保留配置旁路。总延迟3318拍；原三模式仅统一1651拍延迟、逐像素保持。四完整720p帧及三模式各921600像素回归，31小帧、21证据负向/10RTL故障通过。官方2025.1.110.5.9完整I3构建及94份最终STA通过，setup/hold+0.193/+0.023 ns，HDMI+11.315/+0.109 ns；8384 XLR/70 RAM/0 DSP。原2609个可读文件SHA/大小/mtime及文件集合不变，一项锁文件仅元数据核验；原1548未跟踪资料保留。Astra/ultra完成架构及初稿后触发用量限制，主会话接回全部验证/构建及独立复核。完整证据见../reports/m4_color_overlay_i3/BUILD_REPORT.md、ROOT_FINAL_REVIEW.json及PROPOSED_GIT_SCOPE.json。实物颜色/中心对齐、窄hold/PVT、PLL复位、旧Flash/R3/R4风险保留；未Programmer、下载、Flash、上板、断电、Canny、识别、合并main或推送。

## 2026-10-06 M4历史实物签收与独立提交归档

M4离线仿真、完整I3编译、STA和实物功能验收PASS。RAW、MAG、BIN、OVERLAY模式、阈值控制、OSD、红色边缘、空间对齐、动态更新及720p60输出正常。厂商AR0135参考链路继承的固定首行冻结异常作为已接受的延期问题保留，不属于M4新增回归。

实物证据为用户文字确认：JTAG临时运行当前M4镜像，BIN/64启动；四模式循环BIN→OVERLAY→RAW→MAG→BIN，每次完整双键手势一次，单键不误切模式；RAW/MAG/BIN与M3.2视觉一致，纯红/灰度背景/OSD/三方向空间对齐/阈值/动态及连续运行检查通过。阈值仅改变BIN与OVERLAY边缘筛选，MAG幅值图不随阈值变化。除已知首行异常外，无用户列出的新增显示回归；运行具体时长和PVT条件未提供。

**DEFERRED：厂商AR0135参考链路继承的固定首行冻结异常，用户已知并接受本阶段延期处理；待更换AR0135模块后复测。该问题尚未定位或修复。** 厂商原始01-1_Ti60_AR0135_HDMI_1280720参考bitstream在相同实物上同样存在；不能归因于M4叠加/3318拍延迟/Sobel/中值/I3迁移，也不能据此断言摄像头硬件根因或新模块必能修复。暂停诊断，后续换模块再交叉验证。

最小setup/hold +0.193/+0.023 ns，hold为正但较窄；连续实物稳定不严格证明跨全部工艺、电压和温度稳定。PLL复位、I/O、CDC及旧Flash/R3/R4风险保留。完整结果见[实物验收报告](../reports/m4_color_overlay_i3/HARDWARE_ACCEPTANCE.md)与[构建报告](../reports/m4_color_overlay_i3/BUILD_REPORT.md)；原PASS_OFFLINE JSON保留历史时点含义。

实际归档起点为codex/m4-color-overlay、M3.2提交3424514afe1721dc000495673c0ca757ea1f6372、空暂存区。bit只读复算2,179,422字节、SHA-256 `5cbaa12da39eb141d6b481299c496e9f71885edc1ba220f071aed88dff4f46d3`，匹配记录值。主会话核查2609个可读保护文件内容/大小/mtime未变，旧1548份未跟踪资料保留；文件集合仅旧GUI临时锁efinity/m32_median_integration_i3/.lock已不存在，原因未确认，未擅自删除或恢复。

用户授权本轮feat: add real-time color edge overlay独立提交；主会话独立核对验收边界、实际文件清单、暂存blob和提交结果。M4自身ID以Git日志为准，避免在提交内容中循环写入自身哈希；提交清单重算，新增实物验收及本轮独立复核证据使文件数不机械沿用旧215。镜像/生成物/临时诊断/资料不提交。本轮不重新编译、Programmer、再次下载、Flash、继续诊断、M5、合并main或推送，提交后停止。


## 2026-10-07 M5A当前状态

**M5A流式局部Canny/Canny-lite完成离线算法验证、完整I3编译、STA及实物功能验收，阶段PASS。**

- 实物证据为用户2026-10-07明确确认：“M5A流式局部Canny/Canny-lite实物功能验收PASS。”用户已按照M5A实物验收完成测试并确认总体功能PASS；没有另行提供Programmer原始日志、分模式文字记录、照片或视频、精确连续运行时长、逐阈值观察及显示器EDID原始记录，不补写具体画面或运行细节。见[实物验收报告](../reports/m5a_streaming_canny_i3/HARDWARE_ACCEPTANCE.md)。
- 当前实现是局部Canny/Canny-lite，仅完成3×3八邻域一跳弱边缘连接；没有实现跨整帧递归或迭代滞后连接、低频全局Canny、局部/全局快慢融合或目标识别。 七模式、原四模式含OSD逐像素回归、默认中值启用、BIN/H64/L32启动及统一6,626个CE拍延迟属于已验证实现/离线证据，不扩写为用户分项实测记录。
- 完整I3构建及94份最终STA通过：全局setup/hold +0.194/+0.026 ns，像素域+5.879/+0.028 ns，HDMI出口+11.196/+0.164 ns。资源9,425 XLR / 105 RAM10 / 0 DSP；303条详细综合告警与M4规范化一致、新增Canny告警0，工具100网表汇总不重复累计。
- bit为2,201,595字节，SHA-256 `7233bac31c21bd986e18b53b3ecb1ba7d8a4d623a45e56937be309c89a57f75a`，只读复核、不重新生成，继续忽略且不提交。源快照/最终实现/94份STA的证据及离线复核见[构建报告](../reports/m5a_streaming_canny_i3/BUILD_REPORT.md)、[主会话复核](../reports/m5a_streaming_canny_i3/ROOT_REVIEW.md)。
- 厂商固有首行异常不属于M5A新增回归，不阻断M5A验收。用户已明确该问题为厂商生产/参考链路的固有问题，不影响竞赛考核，无需继续处理；本轮未诊断、未修改RTL掩盖，也不声称M5A解决了该问题。
- hold为正但较窄；实物功能通过不能严格证明所有工艺、电压和温度条件下稳定。继承7个无输入延迟端点和135个无输出延迟端点，PLL复位、I/O约束及CDC边界继续保留。旧Flash流水灯冷启动及R3/R4共享管脚风险保持，本轮没有写Flash。
- 分支`codex/m5a-streaming-canny`；本次归档起始HEAD及新提交直接父节点为M4 `95bf83f7172ecdf11ee9b8deb3e2c1bba535a56d`，起始索引为空。用户授权独立提交`feat: add streaming local canny pipeline`；提交自身ID、最终文件数/字节数及提交后状态以主会话实际Git核查为准，避免在提交内容中循环写入自身哈希。
- 按重新生成的[明确范围清单](../reports/m5a_streaming_canny_i3/PROPOSED_GIT_SCOPE.json)逐项暂存，主会话独立核对blob与M2～M4保护范围。历史254文件/12,063,517字节是实物归档前清单，不作为当前固定目标。
- 本轮仅实物归档与独立提交，未重新编译、未运行Programmer、未再次下载、未写Flash、未修改业务RTL、未继续首行诊断、未进入M5B、未合并main、未推送。M5B及其余后续阶段未开始。
