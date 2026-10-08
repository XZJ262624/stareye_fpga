# 仲裁离线验收
主会话独立运行5种子，每种20500完成事务，共102500完成；另独立种子20261009完成20500，累计123000。见sim/arbiter_results.json及root_review/arbiter_independent_seed.log。

覆盖同时持续请求、RT长时urgent、BG信用、单owner队满、命令/数据/响应背压、ID重写恢复、真实B/R RESP错误、A/W/R/B阶段soft-reset、永久停服watchdog、错误RID/BID及RLAST、B/R已呈现但客户端READY永久为0直至watchdog（在client_cancel采样边界撤销旧epoch），真实reset_ack后恢复；接受=完成+取消，无错投/重复/未解释丢失。误差计数errors为响应拍计数，不等于错误事务数。

环境每数拍提供握手机会，RT等待界限是在此环境下检查，不能当DDR实物最坏界限。还未有生产FIFO水位连接、真实多主系统复位ACK实现或720p60共存验证。

负向：副本篡改BID回送被真实TB拒绝。ModelSim10.1c有时Fatal返回0，真实Python验收同时检查Fatal/Error文本并非零失败；见root_review/NEGATIVE_RESULTS.json。

最终批使用默认BG_REFILL512周期，且对客户端B/R背压施加VALID/payload稳定断言（直到显式epoch取消）。旧256周期批为历史探索，不作为最终源码绑定。

最终五个可复现种子50708/60401/7919/1009/20261008，各20500已完成随机事务；主会话独立种子20261009另20500，总123000完成。每种子还有11次被取消/隔离事务和11次实际模拟复位ACK；不把accepted计数当completed。新增B/R客户端持续READY=0直到watchdog，验证输出稳定直至显式client_cancel。最终测试源码和日志SHA见sim/arbiter_results.json与root_review/REPLAY_RESULTS.json。软件协议规格另11案例，与HDL总线仿真区分。
