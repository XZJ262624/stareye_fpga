# M5B.0R闸门
## GO_FOR_M5B1_PROTOTYPE
固定candidate `e734d527a149e318ac5009257dab90642c19cb59`经Codex A与DeepSeek B独立复审均为`PASS_WITH_FINDINGS`且无阻断项。用户随后使用绑定bit完成受控JTAG实物诊断：AR0135断开、未SPI Active/Flash，LED0闪烁且LED1～5常亮约5分钟，无回退或异常。当前板卡上的DDR校准、候选地址别名及范围诊断PASS，详见`HARDWARE_ACCEPTANCE.md`。

本闸门只允许M5B.1隔离原型开发、集成、仿真、完整构建、STA及后续受控压力验证。不得把它解释为M5B.1已经完成、生产视频链路已经安全或全局Canny已经放行。

|阻断|本轮进展|未关闭部分|
|地址/保留区|当前板卡的校准、候选区间别名/范围、多花纹、walking-bit、边界和守卫复测实物PASS|512MiB全容量、跨温度/电压/PVT、反复冷启动及厂商保留区权威说明仍未覆盖|
|仲裁/响应|隔离原型、随机/负向HDL及ACK边沿双审查通过|生产多主DDR集成、复位/epoch bridge、综合/STA与响应压力验证待M5B.1完成|
|FIFO/QoS|条件计算和有界仿真|预填充、CDC、最大服务延迟、实际峰率及720p60共存待原型集成与实测|
|真实帧/性能|证据分类及采集方案|真实分类帧、收敛统计和后台帧率仍待验证，不得承诺1～2fps|

独立诊断的综合/资源/STA不能当M5B.1生产结果。本次诊断PASS只关闭当前板卡候选地址的准入前置项，其余三项必须在M5B.1原型中继续闭环。Gate枚举只允许GO_FOR_M5B1_PROTOTYPE/CONDITIONAL_GO_PENDING_HARDWARE_DIAG/NO_GO，本轮为GO_FOR_M5B1_PROTOTYPE。

真实帧缺口继续阻断实际帧率/收敛承诺，不能单独等同硬件安全故障。端到端Lmax、数值水位/预填充与真实DDR仲裁取消桥接尚未闭合，因此原型不得直接作为生产版本。17us长时吞吐反例被QoS验收拒绝；4us示例只是假设下可行。
