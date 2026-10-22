# 镜像修复DSP审计计数勘误

本补充由Work在候选生成前核定；原V3失败、V4证明及原生报告保持原样。

REGISTERED_DSP_EXACT_COVERAGE_V4.json的coverage共84条，是两只DSP各19个A输入和CE/RST的setup/hold分类总数，**不能称为84条全部实际计时路径**。

Work逐条读取确认：其中64条为实际原生时序路径，20条为mult_190的10个A输入恒为gnd、分别列setup/hold的常量分类。常量分类明确NATIVE_CONSTANT_NOT_TIMING_PASS，无实际slack，不把它们计为正裕量通过。64条实际路径的最小setup/hold为+4.782/+0.359ns；两只DSP的CLK均为clk_pixel，CE/RST实际连接保留。其余7个DSP为纯组合，4个原DDR ROM写接口按禁用证明保留。

此前开发者手写“84条真实full-path”和V4 scope中的笼统captured表述应按以上明细理解。机器coverage已区分两类，未发现漏查动态端点；不因勘误修改RTL/SDC或重跑STA，不将常量归类扩大为时序PASS。本次全工程normal裕量仍为+0.136/+0.025ns，独审和实物/PVT边界不变。
