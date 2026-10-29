# 工业边缘计件：按键可调阈值，快速增量流程

目标：以用户指定StarEye_CountEdgeOpen.bit技术父为准新增按键调阈值独立版，不修其他算法。现场：环境照明下边缘不完整6颗仅1；手机正上方补光后6颗完整，6→5→4→3及加回正确。说明边缘完整性与漏计相关，不据此断言阈值是唯一根因。

身份：branch codex/m5c-fusion-prototype，当前HEAD38d7e42f42ab92f7892072bf18d470445c9d4bd0，parent433a83e543cb40a52128d1eea4ae32ce83aecd16，index空。本轮技术父为未提交open冻结423项manifest3f566c51b323be799bc71e67cb3aeed252945471361f025db29b39576d2aca9f，BIT2511945B（完整SHA见下），不能把回放commit误称计件父提交。BIT SHA baa517a0d9cc742e488e4aee2137acc2c3b18992ffb1ff9d36fbf998a7a90f8c。

唯一Writer仅新增rtl/part_count_edge_keys、tb/part_count_edge_keys、scripts/part_count_edge_keys、efinity/part_count_edge_keys_i3、reports/part_count_edge_keys_20261028。Work写docs和本轮work_gate。父open工程源码/快照/报告/BIT和已冻结shape_replay与其他历史工程不得修改、暂存、清理。生产模块需改的拷新模块名；不重复复制不相关历史资产。所有时钟/管脚/接口/720p/AR0135镜像、DDR/FIFO/CCL判据/closing3x3/容量/TTL/三次独立确认保持。

冻结功能：
1. 板K1=key_n[0]/N2单短按高阈值减8；板K2=key_n[1]/M2单短按加8。默认H48/L24，高阈值8..128步8饱和，低阈值=高阈值/2。两键短按只切RAW/MSK（显示实际closing后的计件边缘，可标MSK），不附带单键变化或诊断rearm。双键长按保留原诊断rearm功能即可，不重设阈值、不切view；单键长按不连发，不新增复位/标定操作。若原输入模块单长等同单短，可明示松开只调一次，不强迫扩大key redesign。生产防抖20ms级不减，按键同步/连续单短/交错双键/上电按住/CE定向测试。默认RAW与父一致。
2. 阈值在source SOF边界原子生效，真实生产m5a使用同一值。OSD RAW/MSK和Hxxx/Lxxx取真正作用于该显示帧的数据，不仅改标签。低对比金属螺丝图像可出现不同边缘，不能预言单调性或保证实物。不得增加视频流水延迟；若必要先说明再定向核。
3. 每次真实阈值变更更新独立64bit config generation（不能只改8bit阈值避免ABA），撤销旧CURRENT/旧三确认/旧在途结果，LAST保留原历史语义，调回同阈值也必须新代。上下限无实际变化不增代、不打断计数，view切换不增计数config。沿用原身份/超时/取消，不加新的图像资格门或更严格数量判据；必要config边界只是防混代，不是新识别阻断。
4. E4/E5候选边距/残边门保持彻底删除；E9亮度门不引回。CCL/confirm/frameguard/capture等不改算法，可仅接config。不要偷偷加残边预算、严格闭合、亮度资格或新拒绝。保持已披露开放轮廓漏计风险。
5. 倒计时/背景标定不在本轮，UART不新增；不是回放或双路融合工程。

必要自检：先核技术父manifest/BIT，记录新拷贝及实际差异；不重跑所有历史CCL。按键/阈值边界饱和、连续短按、双键抑制单事件、CE；真实源SOF阈值切换与aligned config/前端阈值/OSD全帧一致；忙中切阈值撤旧、回调ABA、饱和不撤、view不撤；用原生产GAU2局部Canny+closing+adapter+core/OSD做有限720p定向链，至少48→40→32或24真实更弱线边缘变化独立软件oracle，不能只强置DUT内部值冒真实按键。尽量复用原完整count场景与必要fault检查，明确fixture不等DDR全链。新P&R/基本STA与19精确CDC/新字段约束检查、资源和BIT绑定必需。保留失败、不改断言来PASS，超过120分钟长测试先回报，不跑无关长回归。

完成：形成精简报告/新BIT大小SHA/生产输入/差异与必要源证据快照逐项SHA，生成Codex A提示词，明示未提交快照、基线HEAD/parent和技术父身份。独占Writer完成后停止，Work核定后交用户独立A。本轮不Git写、不B、不Programmer/JTAG/Flash。普通子阶段完成不要等用户，要接续已授权短测/必要构建；每个长阶段启v2 watcher独立StatePath只看最终收据，实际PID记录，旧输入/日志保护。交回实际测试/构建/STA/资源/产物/风险/工作区和Writer停止状态。
