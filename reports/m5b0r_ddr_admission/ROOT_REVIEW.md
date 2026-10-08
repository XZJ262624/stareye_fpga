# 主会话独立最终复核
2026-10-08；GPT-6 Astra/ultra完成架构、初稿及恢复后的只读审查，主会话独立追踪源接口、实现最终修订、实际运行测试与官方完整构建。最终结论NO_GO，停在离线验证准备。

## 关键发现与处理
- 组合status多位译码的故障复位毛刺风险：专用粘滞diagnostic_halt，不以跨位译码驱动复位；重构建。
- 总体超时遥测与enable丢失混淆：stage F1/F2/40|phase/80|phase；FAULT27按固定status8/stage80/reason2/address80断言，不把实测值作期望；重新仿真/构建。
- QoS单次停服不保证持续吞吐：独立17us反例拒绝，增加净恢复、恢复burst、urgent、背景预算；拒绝负CDC/guard及超过FIFO容量burst；4us示例仍只是条件数学模型。
- B/R客户端长期背压和取消：加入READY=0到watchdog、稳定性及同边界client_cancel；旧W保留至真实reset_ack，取消桥接未接入生产。
- SDC复合selector无匹配与同源周期精度：逐个20个已证SR_SYNC=0复位链SR例外，各实际匹配1；保留D同步释放/DDR/monitor数据时序，不用泛false_path掩盖路径。
- walking守卫是6+1次、最终warn.log只取最后综合块、全仓图像候选94且唯一PPM是工具teapot；纠正历史文本。

## 实际独立执行
诊断54例（含三健康种子、单地址位4～28截断、错单位/回绕/数据/响应/握手/复位/事务与总体超时）、monitor6情形及完整91nibble重建；仲裁5种子各20500完成+ROOT独立20261009另20500，共123000完成。每种子取消11事务及11模拟reset_ack，与完成事务分别计数；这些不是实际DDR控制器压力结果。
独立负向4项：禁止比较器、错误BID回送、LED载荷交换、软件canary比较关闭，均由实际验收驱动非零拒绝。ModelSim Fatal自身可能exit0，因此同时检测Fatal/Error文本，不相信预填PASS。
软件地址28故障与11事务规格案例、QoS条件/非法输入通过。共同比例和双向一致地址置换可能不可观测；地址模型通过不能认证物理单位、row/bank映射或保留区。

## 最终实现证据
完整Efinity2025.1.110.5.9官方I3诊断构建，7391 XLR/30 RAM10/0 DSP。112份STA、64份DQ逐半拍/lane齐全，32个无路径时钟对不伪造文件。全局setup/hold +0.100/+0.021ns，449条setup与449条hold报告摘要由Astra再次提取核对；主会话也独立遍历全部报告非负。0无时钟、0内部未约束、0多时钟，2输入/17输出未施加IO延迟及PLL/CORE参考/CDC/窄hold/PVT边界明确保留。
13最终构建输入、53实现输出及112份STA逐项SHA一致，bit为2157846B、249b4b5e4095da1e7466f94d510c17de4588161c37de484a0eff427304cef3f3。XML构建前后仅根last_change更新，已按before SHA找到旧审计副本并比较全部非根内容相同；不声称整个XML字节不变。独立最终验收器scripts/m5b0r_evidence_verify.py检查当前证据、测试源码/日志、HEAD、空索引和bit忽略规则。

## 闸门与范围
NO_GO：实际高地址/保留区、真实DDR端到端Lmax、水位/CDC/预填充、客户端epoch取消/可信reset_ack和720p60共存未闭合。真实分类缺口影响性能/fps承诺，不单独等同安全故障。本轮无实物结果、无M5B.1生产RTL、无全局Canny/融合或目标识别。
10,469保护文件共2267684832B，内容/大小/mtime/文件集合无变化；历史1550未跟踪保留。仅四管理文档修改，其他新文件限定诊断/prototype、测试脚本及证据。最终清单排除bit/outflow/work/数据库/日志/缓存/锁/波形/reference/tools/负向副本/失败探索。原始日志和失败资料保留本地，不删除。
本轮未暂存、提交、Programmer、下载、SPI Active、Flash、main合并或远程推送。旧Flash冷启动/R3/R4风险保留。

## 2026-10-08 candidate归档补充
上文“四管理文档/未暂存提交”为离线快照。本轮依新授权追加三流程文件和M5B.0R定向.gitattributes，按最终清单创建candidate。技术结论、既有构建及NO_GO保持；此归档复核不是用户委派的Codex A独立审查。范围及验收复核见CANDIDATE_ARCHIVE.md，保护见CANDIDATE_PROTECTION_CHECK.json。
