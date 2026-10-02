# M2复位与CDC边界

> 历史记录：此处“当前/未实物验收”指离线构建与审查当时。新I3基础链路已由用户验收PASS；当前额外IP再生成状态见[SOURCE_BASELINE.md](SOURCE_BASELINE.md)，实测范围见[ACCEPTANCE_REPORT.md](ACCEPTANCE_REPORT.md)。原始告警/绑定数据不改写。

2026-10-03。厂商业务RTL保留；本轮未把以下结构重写，也未通过功能仿真/实物校准消除风险。

| 分类 | 位置/证据 | 已核查事实 | 影响及下一步 |
| --- | --- | --- | --- |
| 潜在风险 | example_top.v，sys_pll_RSTN/nrst_i | 系统PLL复位固定1；外部nrst_i未作为系统复位 | 上电/外部复位功能不能由STA证明 |
| 潜在风险 | example_top.v，w_pll_lock及各rstn | 四PLL LOCKED组合AND；其他PLL复位依赖sys lock；每域单FF异步复位释放 | 释放同步、短脉冲及失锁恢复需专项设计/验证；单级不是充分同步器 |
| 潜在风险 | CMOS裁剪/采集复位 | camera PCLK逻辑使用系统域复位 | 跨域复位释放未证明，不能借sys↔CMOS false path签收 |
| 潜在风险 | DDR_AXI_CTRL_AXI4.v，rfifo_reset | 复位/控制信号单级采样跨AXI域 | 控制握手、脉宽与启动顺序需验证 |
| 潜在风险 | example_top.v，cal_done/cal_pass | 下游以cal_done释放，未强制cal_pass成功 | 校准结束不等于校准成功；未上板，不能记录DDR通过 |
| 仍需验证 | W0_FIFO_8生成配置/RTL | 双时钟、3级指针同步，BYPASS_RESET_SYNC=0；宽度/深度/FWFT/输出寄存器与旧配置核对 | 内部同步结构不证明所有FIFO边界功能，尚无独立功能/等价仿真 |
| 潜在风险 | Ti60_Demo_I3.sdc | sys↔pixel、sys↔CMOS仍保留厂商视频边界双向false path | pixel与sys为同PLL相关时钟；异步FIFO使用不等于整个边界均安全，要逐条列出跨域控制/数据 |
| 已确认整改 | Ti60_Demo_I3.sdc | 不复制旧单组DDR clock_groups，不切断sys↔DDR；保留4.5ns core↔sys预算并报告各DDR时钟方向 | 避免通过宽泛例外隐藏失败；最终约束下路径正裕量仍不代替协议验证 |
| 证据限制 | final_build/Ti60_Demo.cdc.rpt | 工具输出No Synchronizer warnings | 仅工具未报该类告警，不是所有CDC正确证明 |
| 证据限制 | final_audit/m2_check_timing.rpt | SDA/四LOCKED无输入延时，136个无输出延时 | 不宣称recovery/removal与所有I/O完成验收 |

校准窗口、动态移相、上电后第一次读写、写/读复位先后、帧切换与帧缓冲访问都留待后续专项验证。M1独立测试图PASS不能外推到新DDR/IP/720p链路。当前禁止接相机；下一轮先关闭接线安全，再由用户明确授权验证范围。
