# P0 资料来源与核查

核查日期：2026-10-01。只读原始资料；前轮 P0 核查仅写四份文档，本轮新增最小参考工程核查记录并更新相关文档，不安装、运行厂商程序或修改参考工程。路径均相对于本文件。HDK 实际存在三层同名目录，下表链接保留完整相对路径。

## 资料索引

“可信程度”区分资料记载、实物配置及兼容验证；厂商文件不等于用户板卡已经验证。PDF 页码为从封面起的文件页序。

| 编号 | 名称与版本 | 相对路径 / 官方入口 | 用途、读取范围与可信程度 |
| --- | --- | --- | --- |
| S01 | 易灵思 2026 FPGA 赛题指南；文件未另标修订号 | [Efinix_2026_FPGA_Track_Guide.pdf](<../reference/competition/Efinix_2026_FPGA_Track_Guide.pdf>) | 已提取全 21 页文字，重点第 3～4、12～17、21 页。正式赛题要求的直接依据；完整评分细则未提供。 |
| S02 | HDK V2.1，20251009 | [版本备注(必读).txt](<../document/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/版本备注(必读).txt>) | 已读版本备注。V2.1 新增 SC1336 HDMI/LVDS 示例；V1.6（20230930）记载示例升级到 Efinity 2023.1。可信于发布记录，不能覆盖各 XML 的不同版本。 |
| S03 | VF-Ti60F225 用户手册；文件名 V4.1、封面 V4.0 | [用户手册](<../document/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/01-用户手册/VF-Ti60F225 易灵思FPGA开发板-V4.1.pdf>) | 已读关键规格、接口、示例和附件页（第 9～12、15、17、20 页）。板卡设计依据较高；版号不一致、图注 Ti60F255 疑似笔误，实际硬件待实物确认。 |
| S04 | 核心板原理图 V1.4，2023-09-14 | [Ti60_F225_Core_V1.4.pdf](<../document/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/04_原理图&PIN TCL/Ti60_F225_Core_V1.4.pdf>) | 已提取并核对 JTAG、DDR 页（第 4～5 页）。适用于该原理图版本；不能确认当前实物 DDR 用料。 |
| S05 | 底板原理图 V1.1，20230915 | [Ti60-F225_Button_Board_V1.1_20230915.pdf](<../document/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/04_原理图&PIN TCL/Ti60-F225_Button_Board_V1.1_20230915.pdf>) | 已核对第 6 页 U7 CH340N，说明 USB UART；不能作为实际下载器型号证据。 |
| S06 | 管脚定义 V1.0，20230703 | [管脚表](<../document/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/04_原理图&PIN TCL/Ti60_Board_引脚定义-20230703-V1.0.xlsx>) | 本轮已读 BANK 3.3 第 2～10 行，与 LED peri 配置及核心原理图第 2/4 页核对；9 个时钟/LED 球位对应，不等于实物 PCB 版本已确认。未全表审计或冻结视频管脚。 |
| S07 | Ti60 datasheet v2_0 | [器件数据手册](<../document/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/03_芯片数据手册/钛金Ti60datasheet-v2_0.pdf>) | 仅定位；本轮未据此承诺资源或性能指标。 |
| S08 | Efinity 安装指南 v2.3 / v2.6 | [v2.3](<../document/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/03_芯片数据手册/efinity-installation.pdf>)；[v2.6](<../document/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/03_芯片数据手册/efinity-installation-v2.6.pdf>) | 已核对封面与系统要求相关文字；分别 2021-06、2021-12。历史参考，不能作为 2025.1 在当前 Windows 上受支持的证明。 |
| S09 | LED_8bit_Test；XML 2023.2.307.5.10 | [LED 工程 XML](<../document/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/06-FPGA_HDL_Basic-2023.2/01_LED_8bit_Test/LED_8bit_Test.xml>) | 本轮已核对完整工程配置、三份源文件、peri、SDC、debug profile。选为最小核查候选；Ti60F225/C4、顶层 LED_8bit_Test，24→96 MHz，管脚对应。原版带调试自动插入；尚未导入、编译或验证。 |
| S10 | jtag_spi_flash_loader；XML 2023.1.150.3.11 | [旧 JTAG/Flash 桥工程 XML](<../document/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/06-FPGA_HDL_Basic-2023.2/00_Ti60F225_jtag_flash_bridge/jtag_spi_flash_loader.xml>) | 已读工程头。旧版下载桥参考；不能直接认定适用于 2025.1 Programmer。 |
| S11 | HDMI 1080P；XML 2023.1.150.3.11 | [HDMI 工程 XML](<../document/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/06-FPGA_HDL_Basic-2023.2/07_Ti60_HDMI_1080P_Lvds_Test/Ti60_HDMI_1080P_Test.xml>) | 已读工程头：Ti60F225、C4。仅参考接口用途，不冻结项目分辨率。 |
| S12 | AR0135 HDMI 1280×720；XML 2023.1.150.3.11 | [摄像头/DDR/HDMI 示例 XML](<../document/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/07-FPGA_HDL_Image-2023.2/01-1_Ti60_AR0135_HDMI_1280720/Ti60_Demo.xml>) | 已读工程头、DDR 控制源码引用并定位 DdrCtrl IP 目录。DDR 与图像链路综合参考；未确认独立 DDR 测试基线，未读取全部 RTL。 |
| S13 | SC1336 新增示例；V2.1 发布记录 | [HDMI ZIP](<../document/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/07-FPGA_HDL_Image-2023.2/07-1_Ti60_SC1336_HDMI_1280720.zip>)；[LVDS ZIP](<../document/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/07-FPGA_HDL_Image-2023.2/07-2_Ti60_SC1336_LCD-LVDS_1024600.zip>) | 仅定位压缩包，未展开；内部工程版本与兼容性待用户确认/后续限定核查。 |
| S14 | Efinity 主安装器 2025.1.110 | [主程序 MSI](<../document/efinity-2025.1.110-windows-x64.msi>) | Windows Installer 数据库只读模式读取 ProductName=Efinity 2025.1，ProductVersion=25.1.110，厂商 Efinix, Inc.；未安装。版本元数据已确认，来源签名/哈希未审计。 |
| S15 | Efinity RISC-V IDE 2025.1.0.10 | [RISC-V IDE MSI](<../document/efinity-riscv-ide-2025.1.0.10-windows-x64.msi>) | 数据库只读确认 ProductName=Efinity RISC-V Embedded Software IDE 2025.1，ProductVersion=25.1.0.10；未安装。用途见官方产品页，不是 RTL 主程序。 |
| S16 | Windows 补丁 2025.1.110.5.9 | [PATCH_MANIFEST](<../document/efinity-2025.1.110.5.9-windows-x64-patch/efinity-2025.1.110.5.9-windows-x64-patch/PATCH_MANIFEST>)；[patch_readme.txt](<../document/efinity-2025.1.110.5.9-windows-x64-patch/efinity-2025.1.110.5.9-windows-x64-patch/patch_readme.txt>) | 已读版本与安装说明；manifest 构建时间 2025-09-19_20:33:49_UTC，说明更新 2025-09-16，要求先安装 Efinity 2025.1。未运行 run.bat 或 update_manifest.py。 |
| S17 | 本地安装提示；未标版本 | [必读！！！.txt](<../document/必读！！！.txt>) | 已读，要求主程序加补丁以使用 TJ135 资料包。该提示不能证明 Ti60 HDK 必须打补丁，也不证明补丁只支持 TJ135。 |
| S18 | ELITES-232DL 下载器驱动；DriverVer 2014-04-28，3.0.7.0 | [ELITES-232DL.inf](<../document/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/02-Software&Driver/易灵思USB下载器驱动-新/ELITES-232DL/ELITES-232DL.inf>)；[Instructions.txt](<../document/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/02-Software&Driver/易灵思USB下载器驱动-新/ELITES-232DL/Instructions.txt>) | 已读 INF 与说明；VID_0403&PID_6014，libusbK 服务。说明是通用 InfWizard 打包/安装说明。可信于随包驱动目标，实际下载器待实物确认。 |
| S19 | CH340N 串口驱动目录 | [CH341SER.EXE 路径](<../document/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/02-Software&Driver/CH340N串口驱动/CH341SER.EXE>) | 仅定位，未运行；安装器文件名不能证明硬件是 CH341，不据此建议安装 CH341 驱动。 |
| S20 | 官方 Efinity 用户指南 v16.1，2025-06 | [Efinity User Guide](https://www.efinixinc.com/docs/efinity-ug-v16.1.pdf) | 已在线核对 Ti60F225 支持表、工程升级及 JTAG 桥兼容说明；官方版本依据。详细影响见 TOOLCHAIN.md，旧 HDK 尚无实际验证。 |
| S21 | 官方 RISC-V IDE 产品页；访问 2026-10-01 | [Efinity RISC-V IDE](https://www.efinixinc.com/products-efinity-riscv-ide.html) | 官方用途说明：面向 Sapphire RISC-V 嵌入式 C/C++ 开发与调试。当前纯 FPGA 方案建议暂缓安装，是基于项目范围的判断。 |
| S22 | 国内官方下载入口；指南第 21 页 | [易灵思 Efinity 下载](https://www.elitestek.com/efinity/) | 已核对入口及账号/下载资格申请信息；资格、许可状态待用户确认。 |
| S23 | 用户实际下载器/JTAG 验收报告 | [当前核查记录](MINIMAL_REFERENCE_CHECK.md) | 用户明确报告 UB-ELITE-001 / ELITES-232DL / libusbK / 0403:6014 / Device ID 0x10660A79 / Valid device ID found；可信于用户实物观察，主会话未独立执行硬件操作。无 bitstream、下载或 Flash 验收。 |
| S24 | 官方 Ti60 型号表；访问 2026-10-01 | [Ti60 产品页](https://www.efinixinc.com/shop/ti60.php) | 已核对 F225 为 FBGA225、C4 与 I3 的温度/速度等级不同；可信于官方订货定义，不代替实物丝印。 |
| S25 | 官方 Ti60 数据手册 v3.2，2024-05 | [Ti60 Data Sheet](https://www.efinixinc.com/docs/titanium60-ds-v3.2.pdf) | 在线核对第 44 页 PLL local feedback 公式，用于核对候选 24→96 MHz；不是新导入后的实际时序结果。 |
| S26 | 本机 Efinity 卸载登记 | [当前工具状态记录](MINIMAL_REFERENCE_CHECK.md) | 只读注册表显示 Efinity 2025.1、DisplayVersion 25.1.110，InstallLocation 为空；可信于安装登记，补丁和正在使用工具的完整版本仍待用户确认。 |

## 正式赛题与项目范围

S01 第 12 页：**赛题四——基于 FPGA 的实时图像边缘检测系统**。指定平台 VF-Ti60F225，芯片 Ti60F225（第 3～4 页）。赛题允许 DVP 或 MIPI 摄像头；不能将赛题一～三的指定摄像头照搬到赛题四。

基础要求（第 12～13 页）：

1. 摄像头采集至少 640×480；FIFO/BRAM 缓冲，保证连续图像稳定，不丢帧或错位。
2. RGB 灰度化；使用 DSP 或移位加法，避免除法器。
3. 3×3 Sobel，计算 Gx/Gy，以 |Gx|+|Gy| 近似幅值，阈值可配置后输出二值边缘；两行缓存形成滑动窗口。
4. HDMI 显示至少 640×480@60Hz，原始灰度与边缘以分屏或画中画等方式对照，画面无闪烁、撕裂。
5. 提交完整 Verilog/VHDL RTL、约束文件和演示视频，展示简单几何图形、人脸等边缘效果。

提高要求/挑战项（第 14～15 页）：3×3 中值滤波与并行比较网络；按键/拨码实时阈值调节及消抖；外部 DDR 全帧缓存、冻结/回放；Canny；原始 RGB 上的彩色边缘叠加；形状识别。中值滤波虽然出现在任务总体介绍中，但单独的实现挑战列在提高部分。本项目 OSD、自适应阈值、多算子等扩展继续作为项目计划，不能写成指南的强制评分项。

第 15～17 页的约 220 MHz 与“零延迟”等描述属于实现建议/示例，不冻结主线时钟，也不能代替行缓存和流水线延迟测量。指南提及 DDR 控制 IP，但实际 Ti60 工程的控制方式仍需核对，不能直接承诺存在适用的 DDR 硬核。

提交及评分边界：该 PDF 给出上述交付物与稳定性、实时性、提高功能等要求；未提供赛题四的详细分值权重、最终提交截止日期、上传入口/格式、报告模板。以上**待用户确认**，需补充完整竞赛规则。

技术支持：指南第 21 页给出官网下载入口、[易灵思官网](https://www.elitestek.com/)、[钛金芯片入口](https://www.elitestek.com/product/gongju/taijinxiliexiangguan/576.html) 和竞赛 QQ 群 **831548702**；板卡采购为“娅妮电子”二维码，未解析成网址。HDK 版本备注的厂商群 **851598171** 是另一入口，不混用。

## 板卡型号与资料差异

- S03 参数页：核心板 **VF-Ti60F225-C**，底板 **VF-Ti60F225-B**；FPGA **Ti60F225I3**。这是资料记载，用户实物后缀、PCB 版本及状态均**待实物确认**。
- 手册封面/文件名版号不同；部分图注 Ti60F255 与参数页 Ti60F225I3 不同，保留差异，不据图注改变平台。
- 手册 DDR 为 K4B4G1646E、16 位、4 Gbit；S04 原理图为 MT41J128M16JT-125、2 Gbit。可能对应不同版本/用料，但原因未确认；实际颗粒与容量**待实物确认**。
- 已读示例 XML 指定 Ti60F225、timing_model=C4；不能从它推断实物为 C4，不能自动沿用到 I3 目标。后续应按实物选择器件/时序模型。
- 手册提供 AR0135、SC1336、SC130GS、SC2210、SC233HGS 等相机选项，不代表用户已拥有其中某款。实际摄像头、适配板、显示器和线缆均**待实物确认**。
- FPGA 下载器：前轮只确认随包 ELITES-232DL 驱动；本轮用户已验收 UB-ELITE-001 / ELITES-232DL / libusbK / 0403:6014 及 JTAG 识别，见 S23。CH340N 是原理图上的 USB 串口器件，与 JTAG 下载驱动分开。

## 核查边界

只按关键目录和文件定向核查，没有全量遍历 HDK 的一万多个文件。顶层未见独立 README/Release Notes，使用“版本备注(必读).txt”作为发布说明；未断言全部子目录不存在 README。PDF 文字提取可用，前轮关键页已在项目外渲染，但图像查看工具失败，未完成视觉逐页验收。本轮定向核对核心板第 2/4 页、底板第 2 页以及 BANK 3.3 指定行；未读取压缩包内部、完整管脚表或所有算法 RTL；主会话/子代理未导入、仿真、综合、编程或上板。用户 JTAG 实物识别验收另有明确来源，不混同为主会话独立测试。

