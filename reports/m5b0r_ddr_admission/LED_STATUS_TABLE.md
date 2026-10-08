# LED映射与判读
来自已验收M0源码 `assign led_data=~led_data_r` 及实际pinout，低电平点亮，3.3V LVCMOS：

|LED|管脚|功能（正常阶段）|
|0|P15|心跳，约0.5秒完整周期|
|1|P14|cal_done|
|2|R14|cal_pass|
|3|N14|alias_pass|
|4|N13|range_pass|
|5|P13|总PASS且锁定/校准仍有效|

LED6/7不用，R3/R4保持未分配，不连接相机。初始WAIT/CAL看心跳和cal灯，校准/别名/范围状态由粘滞成功位逐步显现。

故障遥测：LED0为采样心跳；LED1=1且LED5..2先为A再5，随后LED1=0发送91个nibble（低nibble先）。364bit载荷由低至高：stage8、reason4、address32、expected128、actual128、transaction_count32、beat_count32。完整循环约46.5秒，需完整采集，不能只凭一帧照片判定地址。

独立时钟故障以LED5..2编码monitor_reason：1曾锁后掉锁、2校准丢失、3首次锁/校准等待超时、4UI心跳停止、5总体超时；LED1=1，LED0心跳。同步用户故障与校准下降时首错遥测优先（已仿真）。真实LED观察本轮未执行。

调度器专用stage：F1=初始校准失败；F2=初始校准等待超时；40|phase=运行中校准丢失；80|phase=总体20秒期限超时。普通事务故障stage=phase，reason给出事务原因。总体期限测试使用定向计数器注入触发，不声称仿真实际等待20秒。
