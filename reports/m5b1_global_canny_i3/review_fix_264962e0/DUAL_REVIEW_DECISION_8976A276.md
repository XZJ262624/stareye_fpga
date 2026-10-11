# Work双审查闸门决定

> 2026-10-12最终状态：受控隔离原型实物PASS；下文为当时冻结的审查决定/验收步骤，等待状态已关闭。最终结果见[实物验收归档](HARDWARE_ACCEPTANCE_RESULT_8976A276.md)。

固定candidate `8976a276f03b4cd146c451aa081b04f71637fcf2`，parent `264962e0c6af61e751c794c5b5f5252d00edbb6c`。Codex A由用户独立委派，DeepSeek B通过经核验718个Git文件的隔离快照独立完成；双方完成前未交换本轮报告。B进程exit0、无API error，session `ses_ed59eb172ffescfQOUQKI42v7S`，原始事件与校验清单保存在Work外部审查目录。

双方结论均PASS_WITH_FINDINGS，R1/R2/R3关闭，无新阻断。Work决定：**GO受控实物验收，STOP等待用户反馈**。M5B.1实物尚PENDING；不放行下一开发阶段、M5C融合、热恢复或生产部署。Work不运行Programmer、不下载、不写Flash。

保留重要边界：watchdog硬停撤销stalled WVALID、保留owner/busy、无伪ACK/新发布，仅冷重新配置；hold +0.027ns不是跨PVT实测保证；真实DDR ID/服务、实际发布率与30分钟共存需要实物。4us仅条件模型，134份STA为报告覆盖数。

记录B非阻断建议，不在已审candidate上修改RTL/TB：两处W tuple 153位对154位拼接需后续补一位（当前wid[7]恒0）；review_cancel的ddr_before未断言；启动期变异实际命中获取阶段oracle；全尺寸720p CE恒1、CE停顿来自独立较小帧/tap测试；B没有原始日志正文，仅摘要、哈希与摘录。上述均不能扩大当前覆盖结论。

**纠正文档口径**：生产arbiter的soft_reset接1'b0，没有独立启用soft_reset场景证明；前述“普通soft_reset强制保持”的描述不能作为该功能已经验证的依据。未来若启用，须重新评估quarantine/failstop关系并专项审查。当前只开展既有冷配置验收。

用户确认使用已有板载USB串口。操作、反馈与判定见HARDWARE_ACCEPTANCE_8976A276.md。本次后续写入仅审查归档与管理资料；候选源代码和bit不变，后续管理工作区不等于已审candidate。
