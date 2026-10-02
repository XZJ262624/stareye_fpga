# 星眸项目交接单

## 1. 基本信息
- H-20261002-10；任务：M1独立HDMI实物验收收尾、自动验收整改和最终实现证据绑定。
- main；M0基线a8c39c93a06eeb0686cbb5c13fd44717d49195fa。L3，顺序委派GPT-6 Astra / Medium，主会话最终复核及独立Git提交。
- 已读PROJECT_BRIEF、STATUS、DECISIONS；本交接优先于上一轮离线限制。

## 2. 目标与允许范围
- 子代理唯一写入范围：scripts/m1_hdmi_i3_*、reports/m1_hdmi_i3/；必要临时STA副本放在已忽略的efinity/m1_hdmi_i3/work/内。
- 主会话在代理停写后维护项目文档、审查与Git提交。
- 整改archive硬编码PASS、内部setup/hold未检查、最终实现与30路TMDS审计未绑定的问题。

## 3. 已确认环境
- Ti60F225I3；E:/Efinity/2025.1；2025.1.110.5.9；顶层Ti60_HDMI_1080P_Test。
- 可用Python：C:/Users/kqojp/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe -B。
- 用户确认JTAG临时下载后图案循环正常；约几分钟无闪烁、花屏、黑屏、撕裂或其他异常。显示器报告分辨率/刷新率待确认。

## 4. 已知问题与边界
- 验收脚本必须从真实状态/报告得出结果，拒绝缺失、失败、负裕量和陈旧绑定；不得编造历史单阶段数值退出码。
- STA入口默认C4可能覆盖报告；只能隔离审计最终实现，显式选择I3。不得重新P&R或pgm、不得改变已上板bit。
- 当前bit大小1626948字节，SHA256 D96068C5D88EE861FD70F1FF4C82221DAE5582E5C1642366A631B053EA7B3E89。
- PLL LOCKED异步复位风险保留；用户未提供所选下载文件路径/哈希或原始Programmer日志，不补造证据。

## 5. 验收标准
- 实际内部setup/hold与30路TMDS报告均解析检查；覆盖无时钟/未约束内部端点；已知复位/静态I/O例外明确。
- 对最终实现DB、审计副本、SDC、报告、bit绑定路径/大小/SHA256，审计前后实现与bit不变；明确历史构建证据的限制。
- 真实正向验收与失败状态、负setup/hold、缺TMDS端点、过期hash等负向用例通过。
- 子代理停止写入后主会话独立复核；M1独立HDMI状态PASS，摄像头直通未验收。

## 6. 子代理禁止事项（主会话另有本轮Git提交授权）
- 不改原厂、M0、AR0135、六份M1 RTL、PLL、管脚、SDC、工程配置、AGENTS或原计划。
- 不Programmer、下载、SPI Active/Flash、不安装、不新增算法RTL、不Git暂存/提交；不修改reference/tools。
- 委派期间仅子代理写入指定范围；已停写交回主会话，当前由主会话维护文档与提交。

## 7. 当前进度
- M1实物定性验收通过；Astra / Medium完成整改并停写，46个负向用例全部拒绝，隔离最终DB的I3 STA退出0；主会话独立复核通过。原实现/bit未变，内部+1.656/+0.098ns、30路TMDS+4.029/+0.245ns。实物结果见reports/m1_hdmi_i3/ACCEPTANCE_REPORT.md。
- M1独立HDMI基线PASS；摄像头直通未验收。显式提交范围见reports/m1_hdmi_i3/COMMIT_SCOPE.md；创建独立提交`chore: complete M1 HDMI baseline validation`，实际哈希以git log和本轮最终回复为准。reference/tools仍不提交。.gitattributes仅保留M1工程/脚本/报告原始字节，避免Git换行转换破坏SHA256绑定。

## 8. 待确认与后续
- 显示器识别分辨率、刷新率待用户确认；启动/失锁恢复和长期运行未专项验证。
- AR0135接口/供电/复位/共享管脚/历史Flash启动已完成资料预核查，见AR0135_PRECONNECT_CHECK.md；实物模块及安全隔离方案待确认，暂不放行接线。下一阶段先关闭这些安全门槛。
