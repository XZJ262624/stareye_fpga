# M4构建、STA与实物验收归档报告

项目：m4_color_overlay_i3；阶段：**M4 PASS（保留已知首行异常）**。归档日期2026-10-06。

M4离线仿真、完整I3编译、STA和实物功能验收PASS。RAW、MAG、BIN、OVERLAY模式、阈值控制、OSD、红色边缘、空间对齐、动态更新及720p60输出正常。厂商AR0135参考链路继承的固定首行冻结异常作为已接受的延期问题保留，不属于M4新增回归。

分支codex/m4-color-overlay；本轮归档起点及M4独立提交的父提交为M3.2 3424514afe1721dc000495673c0ca757ea1f6372，M4自身ID以Git日志为准。工程efinity/m4_color_overlay_i3/Ti60_Demo.xml，顶层example_top。从M3.2启用中值版创建输入副本；正式新工程Ti60F225/FBGA225/I3、Titanium、Efinity2025.1.110.5.9，自动debug插入off，M4_FILTER_ENABLE默认/工程参数均1。

历史离线轮次：GPT-6 Astra / ultra完成只读架构审查、初版四RTL、官方配置及初版TB，随后触发模型用量限制；主会话接回唯一写入权，独立复核源码与坐标，完成全部真实测试、软件黄金、负向验证、官方编译、最终STA及报告。未宣称Astra完成其被限额中断的工作。

## 构建与最终绑定

官方完整map/interface/pnr/离线pgm及导出均PASS、退出0。pgm阶段仅生成文件，没有运行Programmer或任何硬件操作。82个源码/配置输入及XML编译前后快照见m4_color_overlay_i3/build；受设备影响接口由完整interface流程生成，67个原物理/外围输入逐字保持。最终bit/LPF/LBF复制到隔离audit副本，经明确I3模型执行94份STA，原最终实现内容及mtime未改变；final_audit/binding.json关联数据库、Tcl、SDC及报告SHA，ROOT_FINAL_REVIEW.json提供主会话独立完成门槛。

| 指标 | M3.2启用版 | M4 | 变化 |
|---|---:|---:|---:|
| 最小setup ns | +0.194 | +0.193 | −0.001 |
| 最小hold ns | +0.026 | +0.023 | −0.003 |
| 像素域setup/hold ns | +7.464/+0.034 | +7.024/+0.027 | 全部为正 |
| HDMI出口setup/hold ns | +11.148/+0.043 | +11.315/+0.109 | 30/30数据端点完整 |
| XLR | 8158 | 8384 | +226 |
| RAM块 | 59 | 70 | +11，统一光栅包 |
| DSP | 0 | 0 | 0 |

median行RAM4、原packet RAM5均保留，新增display packet RAM11，总70/256。没有整帧缓存。no_clock/内部未约束端点/multiple_clock均0；7个未定输入延迟、135个未定输出延迟为继承专用/异步/未用接口边界，不宣称全部I/O或CDC专项认证。

## 功能与仿真

四模式RAW/MAG/BIN/OVR，+16/−16阈值、双键释放手势、20ms消抖及帧边界提交保持，OVR背景原灰度、有效中心边缘纯红，OSD优先。实际总延迟3318拍；旧三模式仅统一增加1651拍。详见[架构](ARCHITECTURE.md)、[模式](MODES_AND_OSD.md)、[仿真及回归](SIMULATION_AND_REGRESSION.md)。四完整720p帧、三原模式各一完整帧回归、31小帧、21证据负向和10真实RTL故障均通过对应验收。

## 告警与保留边界

最新map.out有304条WARNING行：303实际记录、1条“100 post-synthesis warnings”工具汇总，不把100再次相加；254记录在VDB checker之前、49条在其内部。与M3.2启用版规范化消息及出现次数均无新增；新增OVERLAY/模式/OSD告警0。DDR/IP宽度、可选未用外设等分类及原文见WARNING_REVIEW.json；接口GPIO提示、IV查找提示单列。没有为零告警盲改厂商IP。

hold +0.023 ns为正但较窄；用户已确认实物颜色与空间对齐正常，但长时间实物稳定不能严格证明所有工艺、电压和温度条件下稳定。PLL异步复位/失锁恢复、DDR全面压力/校准、电气、旧Flash流水灯冷启动/R3/R4风险仍保留。固定光栅协议不能任意行内暂停；仅已验证坏帧红关闭及下一帧/复位恢复。

## 镜像

完整路径：F:/Projects/stareye_fpga/efinity/m4_color_overlay_i3/outflow/Ti60_Demo.bit

大小：2,179,422字节。

SHA-256：5cbaa12da39eb141d6b481299c496e9f71885edc1ba220f071aed88dff4f46d3

镜像不进入Git。本轮主会话保护审计2609个可读原文件内容、大小和mtime不变；文件集合仅旧GUI临时锁efinity/m32_median_integration_i3/.lock已不存在，原因未确认，没有删除或恢复。历史离线审计对该锁仅核对大小/mtime、没有内容哈希，原ROOT_FINAL_REVIEW.json保留历史结果。原1548份未跟踪资料全部保留。变更/拟提交白名单见重新生成的PROPOSED_GIT_SCOPE.json；主会话按清单独立核验后提交，不合并或推送。

## 用户实物验收与延期事项

用户已通过JTAG临时下载上述镜像，完成[原计划](HARDWARE_ACCEPTANCE_PLAN.md)全部检查及连续运行。BIN/64启动、720p60，RAW/MAG/BIN与M3.2视觉一致；四模式循环、一次双键手势一次切换、单键不误切、纯红边缘/灰度背景/OSD覆盖/三方向空间对齐/实时动态更新正常。K1增加阈值后BIN和OVERLAY边缘减少，K2降低后增多；高阈值主要强边缘保留，低阈值更多细节和噪声，MAG幅值图不随阈值变化。除已知首行异常外，无新增花屏、闪屏、冻结、错位、撕裂或颜色异常。完整文字签收见[实物验收报告](HARDWARE_ACCEPTANCE.md)，没有附造Programmer日志、照片或运行时长。

**DEFERRED：厂商AR0135参考链路继承的固定首行冻结异常，用户已知并接受本阶段延期处理；待更换AR0135模块后复测。该问题尚未定位或修复。** 厂商原始01-1_Ti60_AR0135_HDMI_1280720参考bitstream在相同实物上也出现，非M4叠加/3318拍延迟/Sobel/中值/I3迁移新增回归；尚不能认定摄像头根因或预言更换模块结果。用户暂停诊断，之后购买新AR0135交叉验证。

ACCEPTANCE.json与ROOT_FINAL_REVIEW.json是硬件签收前的离线证据，其PASS_OFFLINE和NOT_TESTED字段不改写。当前硬件结论来自用户文字。此次归档不重新编译、不运行Programmer、不再次下载、不写Flash、不继续首行诊断、不改RTL、不进入M5/Canny；完成独立提交后停止。
