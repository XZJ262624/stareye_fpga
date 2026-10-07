# 主会话M5A实物归档独立复核

日期：2026-10-07。阶段结论：M5A流式局部Canny/Canny-lite完成离线算法验证、完整I3编译、STA及实物功能验收，阶段PASS。

## 实际起点与委派

主会话实际核对AGENTS、背景/状态/决定/交接及M5A构建/算法/模式/范围和保护记录。归档起点为codex/m5a-streaming-canny、M4 HEAD 95bf83f7172ecdf11ee9b8deb3e2c1bba535a56d、空索引、1798项未跟踪。GPT-6 Astra / ultra顺序完成文档归档，交回写权限后主会话独立复核并作为唯一Git操作者。

## 验收边界

用户2026-10-07明确总体实物功能PASS。未提供分模式观察、精确运行时长/阈值统计、原始Programmer日志、照片/视频或EDID。HARDWARE_ACCEPTANCE、README、PROJECT_BRIEF、STATUS、HANDOFF、MILESTONES、DECISIONS及构建状态仅归档总体确认，没有倒填计划为分项实测。旧离线JSON保留历史意义。

当前是3×3八邻域一跳局部连接，无跨整帧递归/迭代、低频全局、快慢融合或目标识别；无M5B新增代码/占位RTL。厂商固有首行异常按用户最新决定为已接受继承例外、不阻断M5A，不诊断或遮盖、不宣称修复。

## 只读独立证据

主会话只读总门禁review()通过，未重新仿真/综合/布局布线或生成bit；重新校验最终88输入、仿真日志/黄金/源、20真实RTL拒绝与24CLI负向记录、最终数据库与审计副本、SDC/Tcl及94STA哈希。bit只读复算2201595字节，SHA-256 7233bac31c21bd986e18b53b3ecb1ba7d8a4d623a45e56937be309c89a57f75a，与最终绑定一致。全局setup/hold +0.194/+0.026，像素+5.879/+0.028，HDMI+11.196/+0.164 ns；9425 XLR/105 RAM/0 DSP，303详细告警无新增Canny，工具100网表汇总不重复累计。

7无input_delay/135无output_delay、窄hold/PVT、PLL/I/O/CDC及旧Flash流水灯/R3R4继续保留。功能PASS不证明全PVT稳定。

## 保护与范围

3022可读受保护文件SHA、大小、mtime及集合复核通过，M2～M4跟踪diff为空。原M4临时.lock缺失为离线已有唯一精确元数据例外，无新增变化，本轮未恢复/删除锁。原1550历史未跟踪资料保持。

原254/12063517范围JSON逐字归档，SHA9b783a7b6e2f6e04d88ad25fd1dfde783785ce0f28284ef4f24c4d51e48c7227。新范围只增加6项：.gitattributes、PROJECT_BRIEF、HARDWARE_ACCEPTANCE、旧scope JSON、本轮ROOT复核与范围说明；其他大小变化来自归档状态/说明及scope管理白名单，不改RTL/TB/工程。M5A -text只追加，旧规则前缀保留；必要DDR ASCII ROM为源码输入，非bit或生成数据库。

最终清单见PROPOSED_GIT_SCOPE.json/.csv。主会话按完整显式路径暂存，随后逐blob检查路径、模式、大小/SHA、总字节和保护范围后才提交，禁止无差别暂存。自身提交ID在提交后Git日志/本地提交检查中核对，避免循环写自身哈希。阶段文档不伪造提交ID。

逐blob与最终提交结果保存在Git忽略的reports/git_baseline_inventory/m5a_commit_check/，保留工作区证据而不引入循环清单；Git实际父节点必须是上述M4。旧scope/final_gate的HEAD/空索引断言仅用于提交前，提交后用readonly validate()验证算法/实现绑定，独立检查新的Git状态。

本轮未重新编译、Programmer、再次下载、Flash、RTL修改、首行诊断、M5B、全局连接/融合/识别、合并main或推送。
