# M2最终实现与STA绑定

> 历史记录：此处“当前/未实物验收”指离线构建与审查当时。新I3基础链路已由用户验收PASS；当前额外IP再生成状态见[SOURCE_BASELINE.md](SOURCE_BASELINE.md)，实测范围见[ACCEPTANCE_REPORT.md](ACCEPTANCE_REPORT.md)。原始告警/绑定数据不改写。

2026-10-03主会话复核。最终完整构建为2026-10-02第三轮，不采用第一轮负裕量或第二轮旧bit哈希。

[编译输入前清单](final_build/build_input_before.json)、[后清单](final_build/build_input_after.json)捕获386项源码/配置/IP/附带文件。原文XML分别归档；唯一差异是last_change时间戳，忽略该属性后语义完全相同。当前工作副本输入集合与后清单完全一致。清单含保留测试与附带文件，不将386项都称为实际编译源声明。

[build_result.json](final_build/build_result.json)记录真实退出码0、时间与全部outflow/work_pnr输出SHA256。[binding.json](final_audit/binding.json)记录隔离STA的实际退出码0、原数据库/生成物前后大小/SHA256/mtime完全相同、SDC和审计TCL哈希。原实现复制到工作副本work/audit_final后只运行STA，显式set_timing_model I3，不综合、不P&R、不生成新bit、不操作硬件。

| 最终数据库 | 字节数 | SHA-256 |
| --- | ---: | --- |
| `efinity/m2_ar0135_ddr_hdmi_i3/work_pnr/Ti60_Demo.lbf` | 15,569,600 | `DAD6A6C05406FF755E0307A25113C9C077467248C03B30594189770784561AAE` |
| `efinity/m2_ar0135_ddr_hdmi_i3/outflow/Ti60_Demo.lpf` | 536,050 | `2FA2B37375343AB109F7B36747F571EB3366AB7112C0234B50F3FCB9E975AA0A` |

bit：`F:/Projects/stareye_fpga/efinity/m2_ar0135_ddr_hdmi_i3/outflow/Ti60_Demo.bit`；2,137,974字节；SHA256 `524213AA27C5797074E9BD71D0761EB31F9D09AEFAC825FA7201CAA6DD33940A`。原件与隔离副本bit/LPF/LBF内容一致；当前bit与第三轮输出清单一致，不把bit成功生成当作实物验证。

[主会话root_review.json](root_review.json)对源清单、真实阶段PASS、器件/顶层/SDC、全部正裕量报告、预期81路DDR/30路HDMI出口集合、32路DDR hi/lo逐路setup/hold共64份报告及约束覆盖独立断言。报告最小值由原文解析，无硬编码PASS。失败退出时不得更新为PASS。

原厂457项与M0 71项哈希/元数据一致；M1 142项一致，另历史.lock消失作为临时项单独标注。厂商业务RTL 25份保持原文，PLL频率/分频/相位未改，官方接口仅补conn_type=gclk字段。

复核只证明记录与当前已约束实现一致，不能证明板级时延模型、电平、校准、帧缓冲访问、CDC或相机安全。没有FIFO功能/等价仿真，没有相机/DDR实物验收。生成bit/hex/lbf/vdb等留在忽略目录，不进入报告或Git暂存区。
