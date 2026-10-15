# Work当前审查入口：M5C诊断candidate

本文件与CANDIDATE_SCOPE.json为当前入口，包内早期draft/准备状态和旧预算报告保留其历史含义。Git实际candidate hash由Work提交后回执给出；唯一parent应为3b49a1f701798a817fed42b8097f724cbc9d6160，分支codex/m5c-fusion-prototype。不是M5C整体完成或实物放行。

本次增加旁接诊断：真实身份/帧的五级计数P0候选、P1行门、P2实际promotion、P3mode6融合色、P4OSD后色及首class差异；RAM稳定记录经PIX/UI握手至真实串口done后释放；独立type5/schema1保持旧type1..4格式。原融合算法、行相等/身份/TTL、显示流水和外部接口不变。重点审查实际观测信号的边沿/身份、PREP稳定契约、OSD尾拍、取消/复位、RAM/CDC、非抢占UART时隙对原任务及lease的影响。

Stage1为9正向4指定负向独立门；Stage2另有默认UART324B、720p真实reader/cache/fusion/OSD、背压/模式/OSD/ACK/cleanup等有限门。64回归为46正向18指定Fatal且DIAGNOSTICS默认0，不替代enabled整机。最终enabled正常结束：healthy8/all7、9发布、355456原始字节（type1×9、type2×1、type3×1、type4×18、type5×3），完整source/UI/start/done/take守恒及双域quiet8；三个type5的实际mode3/0/1，因此P3/P4零合法，mode6非零颜色计数证据来自单独coupled门。不能宣称诊断采样覆盖全部模式。

新完整map/interface/place/route及9查询：50461XLR含routing1589、196RAM、1DSP；用户85%新门51680/204/128，旧48640下NO_GO未改写，这不是省资源。I3 setup/hold +0.136/+0.013ns，25bundles1552目的，CQ+data最大3.702ns、skew2.857ns；7849后台/诊断FF完整控制覆盖，558unique缺路端点明确分类。原717范围缺口及补08/09原始证据都保留。115个raw报告路径版本不是115PVT；单I3/窄hold及外部7输入135输出边界继续保留。

bit仅离线生成：3039216字节，SHA256 3b79f78fd99fbf521311d8bcde4c488eb7ae79b92675023a857f88a6758bd820，路径reports/m5c_diagnostics/stage2_offline_parent_20261015_211613/mirror/efinity/m5c_fusion_i3/outflow/Ti60_Demo.bit；文件忽略/未跟踪/不入candidate。原生选项do_program/run_usbif/do_security均false，无硬件操作。

Work已核104最终生产输入：92同字节、11settings只有base_path/JSON格式、XML仅last_change；仅将已验证RAM observer和合格SDC精确采用到根。物理828和artifact253记录以及最终system143项均独立hash一致。原completion134清单有2个尾写epilogue历史不一致，原中间heartbeat未存，未修改旧清单，post-exit新seal用于最终资格。

完整测试/STA原字节在1306gzip对象，5248路径/SHA版本映射，含合成gold；verify_transport_v2.py只读验证、read_evidence.py只读内存解压打印。direct_review/给受限只读审查器提供若干原字节副本，索引注明原路径/SHA，不是新测试。不能解压/执行helper的审查器必须披露证据可读边界，不伪称核过所有原始报告。外部map/trace/nativeDB/工具包只给hash边界，不等同已包含或完全可重现。

默认UART首次345600B载荷至少7.5s、约2sTTL/条件DDR服务、warm reset/跨PVT/真实可见增强仍未验证。硬停仅冷重新配置，不放宽WVALID撤销的既有限制。独立双审后才可到用户短实物诊断；此刻不允许下载、Flash或标阶段完成。

禁止修改/暂存/提交/清理/运行Programmer或硬件。审查按固定candidate-parent；问题表列严重程度、文件位置、问题、证据、影响、建议，结论PASS/PASS_WITH_FINDINGS/FAIL。Codex A由用户另可见聊天委派，DeepSeek B为独立第二视角，不互相传当前报告。
