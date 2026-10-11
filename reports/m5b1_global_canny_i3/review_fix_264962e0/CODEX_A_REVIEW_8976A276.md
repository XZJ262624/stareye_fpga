# Codex A复审结果：8976a276

来源：用户在Work对话转交的独立Codex A完整报告。本文件整理原报告要点；不冒充Work重跑，也不声称逐字转录。结论：**PASS_WITH_FINDINGS**。

Candidate `8976a276f03b4cd146c451aa081b04f71637fcf2`；唯一parent `264962e0c6af61e751c794c5b5f5252d00edbb6c`；branch `codex/m5b1-global-canny-prototype`。

上一轮三项阻断关闭，本轮没有新增阻断。R1：真实LCD采样沿及6,451,200个LCD/分类/七模式位置证据、旧寄存器突变拒绝。R2：资格/身份对齐、sticky失效、raw EOF消费、合法零帧和恢复。R3：未受理取消优先，已受理真实B/末R排空，同拍READY、A/W/B/R背压、4KiB分段、metadata与下一job恢复覆盖。

| 严重程度 | 位置 | 问题与证据 | 影响与建议 |
|---|---|---|---|
| 重要，非阻断 | m5b1_arbiter.sv:109；m5b1_transfer.sv:17 | watchdog硬停撤销背压WVALID；源码及逐沿轨迹确认owner/busy保留，无伪ACK及发布 | 不可恢复隔离原型边界；不能宣称完整AXI stable-VALID合规或放行热恢复/生产部署，仅冷重新配置 |
| 重要，验证边界 | BUILD_REPORT.md | hold +0.027ns；4us为条件模型；真实DDR及外部接口未实物证明 | 安排受控实物验收，保持warm reset、服务上界、发布率、30分钟及PVT为待验证 |

审查者核对351实际差异与changed_paths、715技术blob/工作字节及SHA、Git身份/clean状态、96构建输入、53输出、134 STA覆盖报告；运行主机解包自检和只读证据检查，未重跑HDL仿真或Efinity。保护范围无变更。资源45042 XLR/124 RAM10/0 DSP；setup/hold +0.196/+0.027ns；HDMI +10.553/+0.095ns；新增内部检查0/0/0。bit 2924727B，SHA256 `8bc85b157426cf35e7aab31bc4acd1c8c54b5799c0e7a0424ee555f3927488c4`。

硬停稳定WVALID断言确实收窄，但增加首沿、隔离、owner和禁止发布检查且明确披露；未发现正常取消隐蔽削弱、预填PASS或陈旧证据替代。未查看本轮DeepSeek B报告，未修改文件或操作硬件；结束HEAD不变、index空、tracked干净，2430未跟踪文件未审查或清理。
