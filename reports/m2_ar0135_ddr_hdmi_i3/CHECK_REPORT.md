# M2实物、链路与接线安全核查

> 历史定位：本文件保留离线构建/上板前审查或当时工作区盘点结论，原始证据不改写。2026-10-03用户已确认新I3 JTAG实时取图、720p60及10～15分钟定性正常，M2基础链路PASS；最新以[实物验收报告](ACCEPTANCE_REPORT.md)为准。当前工程再生成差异另由主会话核查，历史匹配记录不证明全部当前输入一致。

2026-10-03。实物型号核查主要完成，DDR型号阻塞解除；I3离线构建通过，接线仍禁止。

## 实物依据

用户文本确认AR0135模块PCB V5.0、核心板VF-Ti60F225 V1.5、底板VF-Ti60/125F225 V1.5；DDR文字丝印SEC 307 / K4B4G1646 / 46E BYMA，并明确确认Samsung K4B4G1646E-BYMA、4Gbit/256M×16/512MiB。FPGA Ti60F225I3亦用户确认。代理未查看实物照片、未独立量测，不从JTAG Device ID推断速度等级。

旧核心板原理图标MT41J128M16，不能当作实际DDR料号；迁移按Samsung几何与时序依据，见[DDR/IP对照](DDR_IP_MIGRATION.md)。配置银行3B/4A/4B为1.5V，支持DDR3L 1.5V模式，实际VDD/VDDQ/VREF仍待量测。

## 厂商链路与时钟

`example_top`：AR0135寄存器初始化 → DVP 8位/PCLK/VSYNC/HREF → 裁剪/帧同步 → W0_FIFO_8 8转128 → AXI写入DDR → AXI读出/FIFO → HDMI像素及时序/TMDS。所谓灰度路径把8位单色数据复制到R/G/B；没有执行RGB/YUV灰度转换，也不能作为本项目灰度化算法验收。

24MHz输入C5/3.3V；sys96MHz，DDRcore192MHz、tdqss/tac/twd384MHz，HDMI pixel74.4MHz、2×148.8MHz、串行744MHz。保留的LVDS/DSI PLL参与原厂总锁定逻辑，本轮不盲删。官方API只补PLL输出conn_type=gclk，各频率/分频/相位不变。

720p设计活动区域1280×720，HDMI总1650×750，以74.4MHz计算约60.121Hz，这是设计计算值、不是显示器读数。相机XCLK网名clk_27m实际16MHz，clk_54m实际32MHz；AR0135寄存器LUT的旧27MHz注释与实际不符。按旧分频公式由16MHz推算PCLK约44MHz、1650×749约35.6fps，仅为推算，待实测。不擅改相机时钟/视频模式。SDC CMOS100MHz为继承预算，不是传感器输出频率确认。

## 接线安全表

以下旧模块资料来自VIP_AR0135_HDK_V3.2_20251110中的2019版图，不能代替V5.0实物定义。

| 信号/动作 | 资料事实 | 当前结论 |
| --- | --- | --- |
| 20针 | 旧图1电源/2GND、3SCL/4SDA、5VS/6HREF/7PCLK/8XCLK、9～16 D11～D4、17RESET_BAR、18FLASH、19TRIGGER、20OE_BAR | V5.0针号、朝向、接口型号与实际转换待确认；禁止按旧表直接接线 |
| 输入电源/电平 | 旧图模块供电产生VDDIO2.8V，SCL/SDA上拉2.8V；底板供电网3.3V且PCLK另有电平转换资料 | 3.3V模块VIN不等于所有IO耐3.3V；实际V5.0轨/转换待确认 |
| FPGA输出至传感器 | 当前XCLK/SCL/主动SDA为3.3V配置；AR0135CS p17 Table12 VIN/VOUT最大VDD_IO+0.3V | 若V5.0仍2.8V且无转换，上限3.1V可能被超过；条件性风险，不是已确认超压/损坏 |
| RESET/OE/PWDN | 旧图RESET上拉4.7k+0.1uF RC、OE下拉4.7k默认使能，STANDBY接地，无独立PWDN；控制输出ctl2/3未驱动 | 不能保证FPGA配置前复位或高阻；不能猜ctl2/3已提供有效隔离 |
| 断电隔离 | 旧图各稳压EN连VIN，无独立相机电源开关证据 | 仅断电不保证IO隔离，需考虑回灌；不建议带电插拔 |
| R3/R4 | M0 LED6/7输出；相机候选data[0]/[1]输入，可能与相机数据输出共线 | 旧Flash流水灯冷启动有争用风险，JTAG后相机工程安全不能保证下次上电安全 |
| 旧Flash | 用户确认曾固化官方流水灯，本轮未改Flash | 启动镜像精确管脚及安全隔离方法仍待确认；不通过擦写Flash绕过核查 |
| 相机连接 | 用户确认继续断开 | 保持断开，不连接或上电；离线PASS不解除限制 |

## I3迁移风险表

| 类别 | 原问题/限制 | 本轮处理与边界 |
| --- | --- | --- |
| 已确认整改 | 原C4目标 | 官方工程/IP/接口API迁移I3，最终报告为I3 final |
| 已确认整改 | DDR row16、CL5 | 实物row15/512MiB、384MHz用CL6，不提高频率 |
| 已确认整改 | TRION FIFO | Titanium重生成，逐项参数对照，未声明行为等价仿真 |
| 已确认整改 | 旧DDR宽泛时钟组/模板舍入 | 不切DDR路径，统一精度收紧sys预算，最终setup/hold正值 |
| 潜在风险 | 加密DDR告警、cal_done门槛、read pipeline7、PLL_OUT_SEL | 配置显式审查，仍需校准/读写测试及供应商澄清加密告警 |
| 潜在风险 | 复位/视频边界false path | 保留并列入[CDC/复位报告](CDC_RESET_REVIEW.md)，未宣称关闭 |
| 仍需实物验证 | V5.0接口/电平、旧Flash隔离、DDR温度/刷新、相机真实时钟 | 不因编译通过推断硬件安全或直通成功 |

全部实际实现管脚、电压配置归档于[最终pinout](final_build/Ti60_Demo.pinout.csv)，包括HDMI、DDR和相机。原厂配置保持，实际V1.5连接与V5.0接口仍须交叉确认，不能把厂商旧图一致当作实物全部签收。
