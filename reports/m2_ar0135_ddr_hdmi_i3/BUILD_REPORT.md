# M2 I3离线构建验收

> 历史定位：本文件保留离线构建/上板前审查或当时工作区盘点结论，原始证据不改写。2026-10-03用户已确认新I3 JTAG实时取图、720p60及10～15分钟定性正常，M2基础链路PASS；最新以[实物验收报告](ACCEPTANCE_REPORT.md)为准。当前工程再生成差异另由主会话核查，历史匹配记录不证明全部当前输入一致。

构建：2026-10-02 20:43:53～20:45:03（北京时间）。主会话收尾复核：2026-10-03。

项目 `m2_ar0135_ddr_hdmi_i3`，阶段M2进行中；**离线构建及已约束数据路径STA通过**。相机直通、DDR校准/读写、JTAG下载与实物验收均未执行，不能标记M2整体PASS。

## 工作副本与配置

- 工作副本：`F:/Projects/stareye_fpga/efinity/m2_ar0135_ddr_hdmi_i3`；[工程XML](../../efinity/m2_ar0135_ddr_hdmi_i3/Ti60_Demo.xml)。
- 来源：`document/VF-Ti60F225_HDK_V2.1_20251009/07-FPGA_HDL_Image-2023.2/01-1_Ti60_AR0135_HDMI_1280720`；原目标Ti60F225/C4，保存版本2023.1.150.3.11，目录属HDK V2.1 20251009、Image-2023.2。
- 通过官方 `projectdb.EfxProjectDatabase` 设置Titanium / Ti60F225（Ti60+F225、225-ball FBGA）/ I3；`DesignAPI`检查、保存并重生成接口，实际工具与报告2025.1.110.5.9。非手工XML型号字符串替换。
- 顶层 `example_top`，22项源声明、11项IP保留。`auto_instantiation=off`、debug profile清空。没有新增算法RTL。
- `DdrCtrl`官方IP v5.1→v5.14；按实物Samsung K4B4G1646E-BYMA配置row15、col10、bank3、x16、1rank、512MiB，CL6/CWL5，READ_ENABLE_PIPELINE7。原row16和CL5已修正，频率192/384MHz保持。
- 错误TRION FIFO `W0_FIFO_8`通过官方IPM重新生成v8.0/TITANIUM；8→128位、8192写深度、异步双时钟、FWFT与同步/复位/阈值等旧语义逐项核对。新旧实现未做功能或形式等价仿真，见[参数对照](DDR_IP_MIGRATION.md)。
- 工程将上述两个IP源项切换为新`.sv`；目录中旧`.v/.vh`仅历史副本，不参与这两个IP编译。其他IP及厂商业务RTL保持。
- 最终实际SDC为 `Ti60_Demo_I3.sdc`；旧SDC不参与编译。官方生成接口模板保留于outflow，受忽略。

## 完整编译与时序

完整进程退出码0；map、interface、pnr、pgm（离线bitstream生成）均PASS，导出也PASS。`pgm`是文件生成阶段，没有运行Programmer或硬件SPI操作。报告中的configuration active(x4)是保留的厂商文件配置字段，不是已执行Flash烧录。

| 核查对象 | 最差setup/ns | 最差hold/ns | 证据范围 |
| --- | ---: | ---: | --- |
| 全局已约束路径 | +0.188 | +0.026 | 最终I3实现，隔离STA |
| DDR输入 | +0.662 | +0.404 | 汇总报告；另逐路核对16位hi/lo共32采样入口的setup/hold |
| DDR输出 | +0.635 | +0.036 | 81个预期输出端点集合完全匹配 |
| HDMI数据出口 | +11.264 | +0.070 | 30/30 TMDS并行数据端点 |
| CMOS数据/同步入口 | +2.117 | +5.186 | 100MHz继承时序预算，不是实际PCLK测量 |

约束覆盖：no_clock=0、unconstrained_internal_endpoints=0、multiple_clock=0；no_input_delay=5（SDA与四PLL LOCKED），no_output_delay=136。仍有静态/控制/辅助输出与复位例外，不能宣称所有I/O时序闭合或CDC通过。

第一次完整编译虽退出0但setup为−0.832ns，未验收通过。官方模板独立舍入sys10.417ns、core5.208ns、DDR2.604ns导致名义同源4:1时钟出现1ps伪边沿窗口；最终SDC统一保守精度sys10.416=2×5.208=4×2.604ns，硬件PLL未变，sys预算略收紧。移除旧单组DDR `set_clock_groups`宽泛切断，不用false path掩盖DDR跨域；保留core↔sys 4.5ns预算。另将CMOS时钟定义移到其input_delay之前，保持官方I3延时数值。

第二轮收敛后，为捕获工程XML编译前后原文而执行同配置第三轮最终完整构建；只有XML `last_change`自动时间戳变化，其他XML语义与386项输入记录均复核。[最终构建日志](final_build/compile.log)、[真实结果](final_build/build_result.json)、[主会话复核](root_review.json)。早期iteration_01及顶层旧审计报告只为失败历史，最终验收只采用final_build/final_audit。

综合资源分布估计：FF2794、SRL512、ADD764、LUT3716、RAM46、DSP0。接口配置PLL4/4、HSIO68/70，保留大量厂商辅助接口，后续扩展需复核外设资源；不是精简后的业务工程。

## bitstream与证据绑定

- 完整路径：`F:/Projects/stareye_fpga/efinity/m2_ar0135_ddr_hdmi_i3/outflow/Ti60_Demo.bit`。
- 大小：**2,137,974字节**。
- SHA-256：`524213AA27C5797074E9BD71D0761EB31F9D09AEFAC825FA7201CAA6DD33940A`。
- 不复制或提交bit到报告目录。新实现DB、SDC、输入清单及STA证据见[最终绑定](FINAL_IMPLEMENTATION_BINDING.md)。

## 警告与未验收项

最新综合批次303条告警记录，另有1条“post-synthesis 100 warnings”汇总；不是303个独立根因。三条接口相邻GPIO噪声告警和IV查找告警保留，加密DDR内部位宽/无驱动告警不能全数认定无害，见[告警分类](WARNINGS.md)。

PLL LOCKED单级复位释放、rfifo_reset跨域、cal_done而非cal_pass放行、FIFO功能边界、DDR动态移相/校准/实际刷新与温度、M2 HDMI显示均尚未实测；见[CDC与复位](CDC_RESET_REVIEW.md)。V5.0相机20针、电平及旧Flash冷启动隔离仍阻塞接线，见[核查报告](CHECK_REPORT.md)。

## 原工程与Git边界

原厂457项内容/大小/mtime均不变；M0 71项不变；M1剩余142项不变，历史清单中的临时`.lock`已消失，单独记录，不宣称143个路径全保留。主会话独立重算哈希，未改原厂/M0/M1业务工程。

Astra/Medium完成迁移和编译，因用量限制未完成收尾；停止后由主会话独立核查并完成报告。当前main、HEAD保持M1 `d2f48c6e8befa16c9eedea9c07aca82ff16b9879`，未git add/commit，reference/tools/document未修改。编译后暂停，不Programmer、不下载、不SPI Active/Flash，不连接相机、不灰度化/Sobel。
