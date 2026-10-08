# 未来实物诊断计划（本轮未执行）
等待用户单独授权。先解释诊断将覆盖易失DDR，随后每次只给1～3个实际操作。

1. 断电并物理断开AR0135，确认LED6/7共享R3/R4不用于诊断输出；旧Flash冷启动流水灯风险仍保留。
2. 只选择本诊断最终绑定bit，通过JTAG临时配置；不得SPI Active或Flash固化，不以HDMI作为判定。
3. 记录LED完整状态、校准、ALIAS/RANGE/PASS；任何失败记录A5 telemetry全部nibble、reason/stage/地址/expected/actual，并停止。确认比特SHA与报告一致。

还需不同轮次冷配置/温度电源条件与DDR压力、视频共存的单独计划。本次离线编译不能放行生产DDR后台业务，不安排反复断电或真实操作。
