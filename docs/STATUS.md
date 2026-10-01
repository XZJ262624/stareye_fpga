# 星眸项目状态

更新日期：2026-10-01。

## 当前阶段与交接

- P0：背景与其余外设需求仍待冻结；M0：基础验收通过（I3编译、用户报告JTAG配置与流水灯定性PASS）；M1～M7：未开始。
- AGENTS.md 已经识别；已有自动模型调度原则保持不变。
- 自动委派能力已经具备；骨架初始化、Git 初始化和首次提交范围收敛均顺序委派 GPT-6.1 Sol，Medium，未调用 Astra；同一时间只有一个主线写入者，主会话负责最终验收。
- 文件化交接初始化已完成；本轮M0最小LED副本基础验收通过，详情见文末及H-20261001-08。其余外设/需求仍不冻结。
- 前轮 P0 资料核查尝试委派 GPT-6.1 Sol、Medium，但停留 pending_init，取消后由主会话接手；本轮最小工程选择已由 Sol、Medium 完成只读核查，主会话独立复核并为唯一文档写入者，未调用 Astra。
- 当前M0仅复制厂商LED示例；配置/完整编译及用户JTAG、流水灯定性结果已验收，不新增算法RTL。当前bit持久性和长期稳定性未验证。

## 检测与文件状态

- Git：仓库根目录 F:/Projects/stareye_fpga；首次提交范围收敛后，分支由 master 重命名为 main。
- 初始 Git 基线提交：f7f0fa2753011a04744b4b2d8a5ffc0f24446dac，提交信息 chore: initialize StarEye project；提交包含已验收的九份文件。随后仅对 STATUS.md 和 HANDOFF.md 的哈希记录使用 docs: record initial Git baseline 单独提交；该记录提交的哈希以 git log 为准。
- .gitignore：新增 /document/ 与 /reports/git_baseline_inventory/，保留原有 Efinity 生成目录、仿真缓存与波形、Python/编辑器/系统临时文件规则；未全局忽略 log、rpt、bin、hex，其他 reports/ 内容仍可进入版本控制。
- 原方案完整迁移至 docs/AI_COLLABORATION_PLAN.md；AGENTS.md 与 document/ 原始资料保持原样。
- rtl/、tb/、constraints/仍无业务实现；efinity/m0_led_i3已有厂商LED工作副本，scripts/已有官方配置/编译辅助脚本，reports/m0_led_i3保留关键结果。reference/competition/已有赛题PDF；历史盘点、document和用户tools保持原样。
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

## P0 历史待确认清单（最新状态以文末M0验收为准）

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

## M0 上板基础验收与提交范围（2026-10-01，当前）

- M0基础验收通过：I3完整编译PASS、用户报告JTAG配置PASS、流水灯功能定性PASS。
- 用户确认 Device ID `0x10660A79`、Programmer `Device is in user mode`、JTAG下载成功。报告为用户文字摘录，未提供原始导出日志；所选bit路径及下载文件哈希未独立核验。
- 用户原文：“从一侧到另外一侧依次点亮熄灭，断电后也会继续运行，但是我之前已经烧录固化过官方的流水灯历程”。未提供LED编号、8颗逐个计数、往返或速度，不补写这些实测。
- 断电重启确有流水灯现象，但历史Flash官方例程与本轮JTAG配置来源未区分；不是本轮固化或当前I3 bit持久性证据。本轮未SPI Active/Flash操作，也没有再次JTAG或长期稳定性测试记录。
- 本轮只读核验bit仍为1,618,062字节，SHA256 `46AC52D70DF7330864C7F2531361D9383E22475EDAC80FD3635EA2C2F43FF2B0`；没有重编译、下载或改动bit。
- 证据见[ACCEPTANCE_REPORT.md](../reports/m0_led_i3/ACCEPTANCE_REPORT.md)、[用户摘录](../reports/m0_led_i3/jtag_user_report.txt)。上文未下载/待点灯段落为此前离线阶段历史。
- 独立M0提交范围已核查，见[COMMIT_SCOPE.md](../reports/m0_led_i3/COMMIT_SCOPE.md)；实际提交哈希以git log为准。仅纳入M0文档、源码/配置、脚本与文本证据，排除资料、缓存、锁及大型bit/hex/lbf/vdb。
- 用户确认摄像头AR0135，具体接口/适配板/实际连接待确认，不由型号推断DVP；用户有HDMI显示器但缺HDMI连接线，线缆待补齐。
- 下一步在M0提交后只读核查AR0135与HDMI参考，优先评估HDMI彩条链路；本轮未读取视频例程，M1尚未开始。
