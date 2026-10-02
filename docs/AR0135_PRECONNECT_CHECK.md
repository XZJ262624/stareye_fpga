# AR0135接线前安全核查

日期：2026-10-03。以下保留历史预核查；当前以文末“新I3基础链路验收”为准。用户已确认针脚一致、相机仍连接，新I3镜像JTAG实时取图通过；主会话未操作硬件。

实物版本/DDR与引脚一致性已由用户确认；旧图只定位电气/启动条件风险，不替代V5.0实际电路证据。

## 证据范围

HDK路径：`../document/VF-Ti60F225_HDK_V2.1_20251009/`（以下路径相对此HDK）。只读定向提取PDF文字、XML与少量源/历史告警；本轮不声称目视逐页核对或实物检查。

| 核查项 | 已确认资料证据 | 实物待确认与影响 |
| --- | --- | --- |
| 模块/接口 | `01-用户手册/VF-Ti60F225 易灵思FPGA开发板-V4.1.pdf` p5：VS-AR0135黑白、DVP8bit；p16：AR0135 HDMI 1280×720示例。`07-FPGA_HDL_Image-2023.2/01-1_Ti60_AR0135_HDMI_1280720/example_top.v` :262～265使用PCLK/VSYNC/HREF/8位data | 用户已确认AR0135 PCB V5.0；不能推定旧VS-AR0135图与V5.0接口完全一致，针脚/电平/接插件和朝向仍待确认 |
| 供电 | 底板`04_原理图&PIN TCL/Ti60-F225_Button_Board_V1.1_20230915.pdf` p2：P3 Header10×2、D3V3_Sensor、GND；不能将板端3.3V直接等同裸传感器各电源轨 | 模块要求输入电压、板端实际电压、稳压/电平转换与供电使能方式待确认。未找到足以确认当前实物摄像头断电隔离的证据 |
| 电平与采样时钟 | 原peri：data/VSYNC/HREF/I2C为3.3V；cmos_pclk为GPIOT_P_07/1.8V；cmos_xclk为GPIOR_16/3.3V，clock_name=clk_27m。底板p7出现CMOS_PCLK_3V3/_1V8与电平转换电路 | 必须按实物PCB版本确认电平转换和模块XCLK/PCLK要求；不能把PCLK直接接到未经核对的1.8V FPGA球位 |
| 控制/复位 | 原peri cmos_ctl1输入3.3V、ctl2输出3.3V、ctl3输出1.8V；顶层只声明ctl2/ctl3，没有驱动，历史warn.log:164～165明确not driven。I2C配置表写301A RESET_REGISTER等 | 不能把ctl2/ctl3猜成已有效控制的RESET/PWDN。模块端复位/待机引脚、极性、默认上下拉、上电延时及软件复位后的驱动状态待实物/模块资料确认 |
| I2C | example_top.v:693～715使用16位寄存器/数据、50kHz、地址字节8'h20（工程配置） | 实际模块I2C地址、ACK、ID、上拉电源待确认；地址字段不当作传感器身份实测 |
| LED共享线 | M0 LED6/7为GPIOL_01/02、R3/R4；AR0135 peri将同GPIO作为data[0]/[1]输入。底板p7网名LED6/CMOS_D0、LED7/CMOS_D1，经过P2 B3/A3 | 将摄像头接入后，FPGA输出流水灯与摄像头数据输出可能争用；当前未发生已证争用，M1只用LED0～5 |
| 旧Flash冷启动 | 用户确认以前固化过官方流水灯，断电后恢复流水灯；本轮M1仅JTAG，未改Flash。手册p9记载SPI Flash W25Q64JWSSIQ | 历史镜像具体源码/管脚方向、实际启动模式和可用隔离办法待用户/实物确认。JTAG临时加载相机程序不能保证下一次冷启动不恢复旧输出 |

## 放行顺序

1. 先确认实物相机模块、PCB版本、接口针脚/朝向、供电与电平，保持摄像头断开。
2. 核对模块RESET/PWDN默认行为与冷启动隔离条件，以及旧Flash图像对R3/R4的方向；目前不能保证旧程序与相机同时上电安全。不得用带电插拔规避，不能假定复位必然使数据口高阻。
3. 离线迁移与编译已获得独立授权，可在相机断开状态进行；接线、下载和测试须待上述安全条件关闭。当前不放行相机接入，不擦写Flash，不新增灰度化/Sobel。

参考工程候选仍为`01-1_Ti60_AR0135_HDMI_1280720`，不是已验证的相机基线。旧C4已迁移I3、DDR按实物4Gbit配置，离线构建通过；视频时钟/CDC及DDR实测边界仍须核对；先确认安全与采集/DDR/显示直通，再安排窗口和Sobel，不把单色复制RGB当作RGB灰度化模块验收。

## M2本轮实物确认（2026-10-02）

用户文字确认：AR0135相机PCB V5.0；核心板VF-Ti60F225 V1.5；底板VF-Ti60/125F225 V1.5；DDR丝印SEC 307 / K4B4G1646 / 46E BYMA，用户确认Samsung K4B4G1646E-BYMA，4Gbit、256M×16、512MiB。FPGA为Ti60F225I3，Efinity位于E:/Efinity/2025.1，实际版本2025.1.110.5.9。依据是用户实物文字确认，代理未独立检查实物。原理图MT41J128M16与实物不同，DDR参数按实物重新核查。

相机仍断开，旧Flash官方流水灯仍可能驱动共享R3/R4。V5.0针脚、朝向、供电、电平及冷启动隔离未经确认，禁止接入或上电相机。AR0135CS数据手册p17 Table12规定VIN/VOUT绝对最大VDD_IO+0.3V；旧2019模块图VDDIO=2.8V对应3.1V。若V5.0仍使用该供电且无转换，当前3.3V XCLK/SCL/主动SDA可能超过该上限；这是条件性资料风险，不是实物超压或损坏证据。必须确认V5.0电平转换后才能接线。

本轮授权M2完整离线迁移/编译，不授权Programmer、JTAG下载、SPI Active、Flash、摄像头连接、灰度化或Sobel。离线结果见[BUILD_REPORT](../reports/m2_ar0135_ddr_hdmi_i3/BUILD_REPORT.md)与[接线核查报告](../reports/m2_ar0135_ddr_hdmi_i3/CHECK_REPORT.md)；不把编译等同DDR校准或相机直通验收。

## 用户新增实测与最终审查（2026-10-03，历史上板前记录）

用户明确确认针脚与官方demo配置一致；使用厂商自带.bit正常获取图像，相机仍连接。此前“仍断开/针脚未确认”保留为历史，不再适用于当前事实。厂商功能基线通过，新M2 I3镜像尚未实测，不扩大为新I3或Flash冷启动验收。

[最终审查](../reports/m2_ar0135_ddr_hdmi_i3/preboard_release/RELEASE_REVIEW.md)及[完整20针表](../reports/m2_ar0135_ddr_hdmi_i3/preboard_release/CAMERA_PIN_AUDIT.md)记录已确认代码问题、条件电气风险和待实物验证项。RESET_CTL0未有FPGA控制，CTL3最终0使OE启用，I2C不是完整开漏；实际模块电压/转换/PCLK装配和旧LED Flash启动隔离仍未闭环。不能用旧图直接断言现物超压或损坏。针号不需重复确认。

[安全启动和Flash计划](../reports/m2_ar0135_ddr_hdmi_i3/preboard_release/COLD_BOOT_AND_FLASH_PLAN.md)为未来待批准方案。保持当前用户已运行镜像的事实，本轮不安排断电/重配/读Flash/插拔；改变镜像、电源或加载bridge前需先明确覆盖R3/R4与防反供电的隔离路径。

## 新I3基础链路验收（2026-10-03，当前）

用户确认新Ti60F225I3 bit经JTAG临时下载；AR0135实时图像、显示器识别1280×720@60Hz、连续10～15分钟正常、运动持续更新，无黑屏/闪屏/花屏/冻结/明显撕裂；未SPI Active/Flash。M2基础链路PASS，详见[实物验收](../reports/m2_ar0135_ddr_hdmi_i3/ACCEPTANCE_REPORT.md)。历史“新I3未实测”不再代表当前功能状态。

功能成功不证明实际电平转换、PCLK装配、复位/CDC或配置前隔离已专项验证。旧Flash流水灯未改变，R3/R4共享数据线争用的冷启动风险继续保留，本轮不安排断电/Flash/bridge或插拔。既有控制/I2C/DDR告警未因此关闭。
