# VF-Ti60F225-C 最小参考工程编译前核查

日期：2026-10-01。下文保留 P0 历史静态核查；当前M0基础验收通过；工作副本编译与用户上板结果以文末为准。厂商原始目录保持只读，不自动下载或写 Flash。

## M0 编译阶段授权与实物型号确认（历史）

- 实物完整型号：**Ti60F225I3**，依据用户本轮明确文本确认。具体丝印/照片/BOM核对方式未提供；主会话未独立查看实物。JTAG ID 不用来区分 I3/C4。
- 厂商原工程和历史报告为 C4；保留为来源证据，不代表实物为 C4。本轮工作副本应通过 Efinity 配置工具设为 I3，重新生成接口并进行新的最终时序分析。
- 用户此前已确认厂商预编译 .bit 在板上跑通；未证明当前 Efinity 重新编译通过。
- 英文工作副本：`../efinity/m0_led_i3/`。已核实并使用工具 2025.1.110.5.9；工作副本内关闭自动调试插入，核查顶层、24→96 MHz、C5 时钟及8个LED/3.3V LVCMOS。
- 本轮只允许离线配置/完整编译；编译后暂停，不调用 Programmer，不进行 SPI Active 或 Flash 固化，不新增业务 RTL。
- 下载前须确认摄像头及扩展外设断开，LED6/7共享 CMOS_D0/D1；实际断开状态仍待实物确认。

## P0 历史静态核查（以下状态仅描述当时）

## 下载器与 JTAG 验收

以下为用户报告的实际硬件结果；主会话没有独立操作硬件：

| 项目 | 验收结果 |
| --- | --- |
| 下载器 | UB-ELITE-001 |
| 驱动 | ELITES-232DL / libusbK |
| USB ID | 0403:6014 |
| Programmer 识别 | Single RS232-HS / Generic FT232 |
| JTAG | 连接成功 |
| Device ID | 0x10660A79 |
| Programmer 消息 | Valid device ID found |
| bitstream / 下载 / Flash | 未选择 / 未执行 / 未固化 |

这证明当前下载器、驱动和 JTAG 识别链路可用；不能代替对工程器件、封装、速度/温度等级、引脚或功能的检查。Device ID 不作为芯片完整后缀的确认依据。

## 最小候选与选择理由

选择厂商 **01_LED_8bit_Test** 作为最小参考工程核查候选。主体是 PLL、复位与 8 位 LED 流水灯，不引入摄像头、HDMI 或 DDR；原工程还开启了自动调试逻辑插入，最小化建议见下文。属于现有示例的静态选择，不是新编写的 RTL，也未标记为已验证主线基线。

- [项目 XML](<../document/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/06-FPGA_HDL_Basic-2023.2/01_LED_8bit_Test/LED_8bit_Test.xml>)
- [接口约束 peri.xml](<../document/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/06-FPGA_HDL_Basic-2023.2/01_LED_8bit_Test/LED_8bit_Test.peri.xml>)
- [时序约束 VIP_System.sdc](<../document/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/06-FPGA_HDL_Basic-2023.2/01_LED_8bit_Test/VIP_System.sdc>)
- [顶层源文件](<../document/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/06-FPGA_HDL_Basic-2023.2/01_LED_8bit_Test/src/LED_8bit_Test.v>)
- [实际实例化的流水灯源文件](<../document/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/06-FPGA_HDL_Basic-2023.2/01_LED_8bit_Test/src/led_index/led_water_display.v>)
- [XML 同时列入的 V1 源文件](<../document/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/06-FPGA_HDL_Basic-2023.2/01_LED_8bit_Test/src/led_index/led_water_display_V1.v>)

不选择旧 JTAG/Flash 桥作为首次点灯工程，不使用随包或其他工程的现成 .bit/.hex/.bin。未来若建立工作副本，只按审核后的配置与源文件清单复制；不将 outflow/work 内的历史生成物当成当前结果。

## 编译前配置核对

| 检查项 | 文件证据 | 当前判断 |
| --- | --- | --- |
| 系列/器件 | project/device_info：Titanium / Ti60F225；peri device_def=Ti60F225 | 源配置一致；实际芯片丝印待实物确认 |
| 封装 | Ti60F225 对应 FBGA、225 引脚；XML 无单独 package 字段 | 官方型号表确认封装定义，实物完整型号待实物确认 |
| 时序模型 | project timing_model=C4；手册参数页记载 Ti60F225I3 | 尚未通过实物匹配；不能沿用或擅改模型 |
| 顶层 | project top_module=LED_8bit_Test，与 src/LED_8bit_Test.v 一致 | 静态一致 |
| 顶层接口 | pll_inst1_CLKOUT0、pll_inst1_LOCKED 为输入，led_data[7:0] 为输出 | PLL 信号由 Interface Designer 接入核心；它们不是独立外部封装引脚 |
| 源文件 | XML 列入上述三份 Verilog；顶层实例化 led_water_display | 保留现有来源；不删改未实例化文件，不声称已综合 |
| 来源工具 | project sw_version=2023.2.307.5.10；peri version=2023.1.150 | 文件来自不同工具保存年代，尚未在当前安装工具导入/升级验证 |
| 调试自动插入 | project debugger auto_instantiation=on；profile=debug_profile.wizard.json | 原版开启逻辑分析仪；建议后续审核副本关闭自动插入，本轮未修改 |
| 时序约束 | VIP_System.sdc：create_clock -period 10.4167 pll_inst1_CLKOUT0 | 与候选 96 MHz PLL 输出一致；SDC 头为旧版 preliminary 数据说明，不能当当前最终时序报告 |

[官方 Ti60 型号表](https://www.efinixinc.com/shop/ti60.php)列出 Ti60F225C4 的温度/速度等级为 C/4，Ti60F225I3 为 I/3。二者不是相同的后缀，需结合实物及当前 Efinity 可选模型确认。本轮只记录不同，不推断旧示例必然无法配置，也不对未实测器件给出兼容保证。

## 管脚与电气标准

[管脚表](<../document/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/04_原理图&PIN TCL/Ti60_Board_引脚定义-20230703-V1.0.xlsx>)中 BANK 3.3 工作表第 2～10 行、[核心板原理图 V1.4](<../document/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/04_原理图&PIN TCL/Ti60_F225_Core_V1.4.pdf>)第 2/4 页及当前 peri.xml 已交叉核对：

| 信号/板上网络 | peri GPIO | F225 球位 | 电气标准 | 资料核对 |
| --- | --- | --- | --- | --- |
| clk / CLK_24M | GPIOL_11（原理图/表为 GPIOL_11_PLLIN2） | C5 | 3.3 V LVCMOS | 一致 |
| led_data[0] / LED0 | GPIOR_25 | P15 | 3.3 V LVCMOS | 一致 |
| led_data[1] / LED1 | GPIOR_22 | P14 | 3.3 V LVCMOS | 一致 |
| led_data[2] / LED2 | GPIOR_28 | R14 | 3.3 V LVCMOS | 一致 |
| led_data[3] / LED3 | GPIOR_21 | N14 | 3.3 V LVCMOS | 一致 |
| led_data[4] / LED4 | GPIOR_24 | N13 | 3.3 V LVCMOS | 一致 |
| led_data[5] / LED5 | GPIOR_27 | P13 | 3.3 V LVCMOS | 一致 |
| led_data[6] / LED6 | GPIOL_01 | R3 | 3.3 V LVCMOS | 一致 |
| led_data[7] / LED7 | GPIOL_02 | R4 | 3.3 V LVCMOS | 一致 |

LED 输出配置 drive_strength=4；原理图第 4 页 LED 电阻接 VDD3V3，顶层 assign led_data=~led_data_r，与低电平点亮方向一致。上述只证明所读资料之间对应，不证明实际 PCB 一定是该版本。

LED6/LED7 同时标注 CMOS_D0/CMOS_D1；首次点灯前需要确认相机/扩展外设未驱动这两个共享管脚。实际外设连接**待实物确认**，不改原厂管脚规避该问题。

按实际实例化的流水灯 RTL 与 96 MHz 推算，单灯约每 174.763 ms 移动一次，LED7→LED0→LED7 往返，14 步约 2.447 秒；这是未来观察预期，本轮未下载或观察实物。

## 调试配置与历史结果

[debug_profile.wizard.json](<../document/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/VF-Ti60F225_HDK_V2.1_20251009/06-FPGA_HDL_Basic-2023.2/01_LED_8bit_Test/debug_profile.wizard.json>)启用 la0，深度 1024、input_pipeline=1，观察 delay_cnt、delay_done、led_data，并引入 edb_top_inst 与 11 个 jtag_inst1_* 信号。因此不能将原版描述为只有 LED 的纯最小实现。

建议后续工作副本关闭 debugger 自动插入后再核对接口并编译，以减少旧版调试配置依赖；本轮不改原 XML 或 RTL。历史生成接口/时序文件带调试 JTAG 信号有明确来源；不能将其替代当前 peri.xml 或复制成当前编译结果。XML 的 last_run_state=pass 和旧版 final 时序头只描述厂商历史状态，本项目尚无实现验证。

## 时钟与复位

- 核心板原理图第 2 页 X2 为 24 MHz、3.3 V；24 MHz 经 C5 进入 PLL，不是顶层的普通 clk 输入。
- peri PLL_TL0：ref_clock_freq=24.0000，multiplier=4，pre_divider=1，post_divider=2，CLKOUT0 out_divider=28；反馈模式 local，feedback_clock_name=pll_inst1_CLKOUT0。
- 按[官方 Ti60 数据手册 v3.2 第 44 页](https://www.efinixinc.com/docs/titanium60-ds-v3.2.pdf) local feedback 公式，CLKOUT0 的反馈/输出分频相同，输出为 24×4=96 MHz；周期约 10.4167 ns。不能用不含反馈分频的通用公式误判。
- 顶层 clk_ref=pll_inst1_CLKOUT0，sys_rst_n=pll_inst1_LOCKED；当前设计不使用独立复位按键。复位实现只完成静态读取，尚未验证上电或锁定行为。
- 实物振荡器/PCB 版本及当前工具重新生成的 PLL/SDC 状态待确认。旧 SDC 的“C4 preliminary”头注不可代替新版最终时序验收。

## 当前工具状态与编译门槛

本机卸载登记只读查询显示 Efinity 2025.1 / DisplayVersion 25.1.110；InstallLocation 字段为空。它证明主程序已登记安装，不证明当前 Programmer 的完整运行版本、补丁 5.9 或许可状态。

**当前选择结果：候选已确定，编译前资料核查部分通过，实物与当前工具匹配尚未完成；本轮不编译。** 继续需要：

1. 确认 FPGA 完整丝印、核心板 PCB 版本，并检查是否连接相机/扩展外设；选择对应器件、封装与合法时序模型。
2. 确认当前 Efinity 运行版本、补丁、安装目录及许可；在工程工作副本中处理自动调试插入、核查升级后的接口/时序设置和时钟，不能覆盖原资料。
3. 全部匹配后再开展新编译与综合/时序检查；首次配置使用该匹配工程新生成的 bitstream，仅 JTAG 临时下载，由用户反馈 LED/锁定现象。任何 SPI Flash 编程/擦除/固化均不在首次验证范围。

上面是后续门槛和计划，尚未执行工程导入、配置修改、编译、下载或 Flash 操作。


## M0 离线编译验收历史（2026-10-01）

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

## 当前M0基础验收

M0基础验收通过：I3完整编译PASS、用户报告JTAG配置PASS及流水灯功能定性PASS。断电后仍有流水灯，但用户此前已固化官方例程，不能证明本轮I3 bitstream的持久性；本轮未SPI Active/Flash固化。 用户仅报告灯从一侧至另一侧依次点亮熄灭，未提供LED编号/逐颗数量/往返/速度，前文RTL推算不是实测。Device ID与user mode来自用户报告，原始日志及下载路径/哈希未独立核验。详见[验收报告](../reports/m0_led_i3/ACCEPTANCE_REPORT.md)。
