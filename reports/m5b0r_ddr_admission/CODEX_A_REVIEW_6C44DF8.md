# Codex A独立审查归档

审查时间：2026-10-08 18:43（Asia/Shanghai）  
审查者：用户在独立可见Codex对话委派的Codex A  
Branch：`codex/m5b0r-ddr-admission`  
Candidate：`6c44df8c5edc10c45a59c4c867e3fc44a6e7456d`  
Parent：`ba28397cc5f0d4b34ed06b803c8e5af067c9ca98`  
最终结论：`FAIL`

| 严重程度 | 文件/位置 | 问题 | 证据 | 影响 | 建议 |
| --- | --- | --- | --- | --- | --- |
| 阻断 | `rtl/m5b0r_ddr_admission/m5b0r_arbiter.sv:50,75` | `ddr_reset_ack`有效时仍可能对新请求给出READY，却不锁存请求 | IDLE且请求有效时组合逻辑可令`c_aready=1`；时序逻辑优先执行ACK分支，跳过请求捕获 | 客户端观察到握手成功，但事务被丢弃且无响应 | ACK有效期间禁止新请求握手，并增加定向测试 |
| 重要 | `tb/m5b0r_ddr_admission/tb_m5b0r_arbiter.sv:72,129` | TB未发现ACK周期握手丢失 | ACK周期清除客户端phase并跳过握手记账；`hard_reset`只产生单周期ACK | `accepted=completed+cancelled`无法检出ACK周期漏记的握手 | 覆盖ACK/VALID重叠、多周期ACK和撤销后恢复，独立断言ACK期间不得接受请求 |
| 重要 | `tb/m5b0r_ddr_admission/tb_m5b0r_diagnostic.sv:95` | 健康用例未独立约束完整诊断计划 | 仅比较TB与RTL计数相等，没有独立断言9,967事务、356,927写拍、357,128读拍及完整模式/守卫次数 | 实现若遗漏范围或walking测试并提前置PASS，健康检查可能仍通过 | 增加独立计划计数、模式/地址/守卫覆盖和跳过阶段负向用例 |
| 建议 | `scripts/m5b0r_evidence_verify.py:36` | 缺少面向固定candidate的提交后复验模式 | HEAD断言固定为parent；归档已说明它是提交前验收器 | 提交后需人工拆分检查，容易混淆Git状态失败与证据失败 | 分离证据检查与提交前Git检查，支持显式candidate/parent参数 |
| 建议 | `reports/m5b0r_ddr_admission/ADDRESS_ALIAS_TEST.md:6` | 用例数量仍写53 | 最终运行器及结果为54例 | 文档口径不一致 | 更新为54并注明总体超时用例 |

Codex A只读确认candidate、唯一parent、branch、空暂存区及干净跟踪工作区；审查差异为196个文件、11,136,497字节Git blob。195项清单载荷和清单自身一致，191项证据绑定无哈希差异；112份STA最小setup/hold为`+0.100/+0.021 ns`，20条false path均为具体复位SR端点。bitstream为2,157,846字节，SHA-256为`249b4b5e4095da1e7466f94d510c17de4588161c37de484a0eff427304cef3f3`。

未发现为获得PASS而主动削弱检查的证据，但存在上述测试盲区。真实高地址/保留区、DDR最坏服务时间、720p60共存、实物LED及跨PVT稳定性仍未验证；M5B.0R闸门保持`NO_GO`。本轮Codex A未修改、暂存、提交或执行任何硬件操作。
