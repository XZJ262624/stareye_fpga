# M2告警分类与验收边界

> 历史记录：此处“当前/未实物验收”指离线构建与审查当时。新I3基础链路已由用户验收PASS；当前额外IP再生成状态见[SOURCE_BASELINE.md](SOURCE_BASELINE.md)，实测范围见[ACCEPTANCE_REPORT.md](ACCEPTANCE_REPORT.md)。原始告警/绑定数据不改写。

最终批次为第三轮完整构建。原warn.log累计三个批次；统计最后一个“Efinity Synthesis Started”段，304条EFX记录中1条为“Found 100 warnings in post-synthesis netlist”汇总，另303条为前端/网表告警记录，存在重复，不能等同303个独立缺陷。[完整原始日志](final_build/Ti60_Demo.warn.log)保留未删；错误日志只有运行头，没有错误记录。

| 级别/类别 | 文件或字段 | 证据与影响 | 处置 |
| --- | --- | --- | --- |
| 高/待澄清 | ip/DdrCtrl/DdrCtrl.sv | 加密内容中的**端口、截断、位宽差异、未连接、无驱动信息 | 工具编译成功不证明无害；涉及新IP校准/数据路径，需供应商说明及DDR读写/校准验证 |
| 高/结构风险 | example_top.v、DDR_AXI_CTRL_AXI4.v | cal_done放行、单级控制/复位跨域 | 详见CDC_RESET_REVIEW；不能借STA/无同步器告警签收 |
| 高/接线阻塞 | cmos_ctl2/3 not driven | 控制脚声明没有有效驱动 | 不把它们当作相机RESET/OE隔离；V5.0接线仍禁止 |
| 中/需核对 | cal_shift_val未连接、其他位宽截断 | 可选校准端口和遗留视频/FIFO接口 | 静态复核配置语义，未作动态功能证明；不能统一豁免 |
| 中/信号完整性 | final_build/Ti60_Demo.pt.rpt | hdmi_txd0邻GPIOT_N16/P16；lvds_txd2邻GPIOT_N06/P06；dsi_txd3邻GPIOR_N09/P09，三条GPIO噪声提示 | 保留原管脚，后续只接目标外设并观察，不能当作HDMI电气合规证明 |
| 中/工具信息 | final_build/compile.log | WARNING: cannot find correct IV value | 来源尚未确证；所有编译/接口阶段成功，仍保留原文，待官方解释 |
| 低/遗留扩展 | clk_25m、SPI/LCD/DSI/LVDS及w_dev等未使用/未驱动 | 工程保留完整厂商顶层与辅助配置，未精简 | 当前相机断开，不扩大功能验收；以后按依赖逐步精简，不盲删PLL锁定依赖 |

没有运行Programmer，没有把STA通过解释为上述告警全部排除。三条接口提示是接口阶段告警，不并入303条综合记录。M1的33条告警是另一个已验证工程，不能混用为M2告警数量。
