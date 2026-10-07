# 主会话独立复核：M5B.0

以下主体为M5B.0分析轮次的历史独立复核；本轮归档说明见末节。

日期：2026-10-07。基线HEAD为`4e0496e8a36f53dcfffa9e9564ffbf0f780a55ba`，分支`codex/m5b0-global-canny-architecture`。用户要求的GPT-6 Astra / ultra完成架构分析；主会话独立检查下述证据，未直接接受代理的PASS文字。

**结论：架构和软件可行性分析完成；算法软件单项GO，M5B.1生产实现及整机DDR接入NO-GO。** 这不是M5B硬件或全局Canny整机验收PASS。

## 算法、边界和软件复验

完整复验入口为`root_independent_review.py`，结果位于`root_replay/ROOT_TEST_RESULTS.json`。主会话使用独立连通分量DFS作为630组随机小图/9,990像素的黄金模型，独立二维原地正反向扫描核对最终mask、每个像素的激活扫描号和收敛扫描数。另测早于strong扫描顺序的weak和对角八连通，两项通过。故意翻转黄金mask的一位会被比较器拒绝。

主会话自行构造1280×720竖蛇，用union-find连通分量求解；与代理BFS和事件模型逐像素相等。保留461,439像素，642扫描/321双向轮，Jacobi为460,161扫描。输入SHA-256 `16f58d813d6e5e290b955182159dcb533f361eab025adf17c98e971d1c2d08ae`，mask SHA-256 `05ac2780ea69112779ca691cf701048cb66a891964ff11b15e41103aae8e0d76`。

独立重跑全部19,683个3×3穷举和30图案（15个完整720p），逐项核对原结果的输入/输出哈希、计数和方法，CPU耗时字段允许变化。完整帧采用已用小图逐激活时刻证明等价的事件模型，不虚称逐扫描暴力执行。没有真实M5A分类帧；合成4～8扫描不能被称为真实场景典型性能。横蛇362扫描、竖蛇642扫描都是测试最坏值，不是所有输入的紧确上界。

## DDR、带宽和资源独立检查

核对实际XML启用`src/axi/axi4_ctrl.v`及顶层实例；没有使用历史同名文件或未实例化native控制器推断地址。128bit总线、size=4、2048B地址递增及二位frame index拼22位指针证明四个4MiB槽，byte addressing、8bit视频、每帧921600B。槽尾全部保留。

UI实际clk_sys=96MHz；DDR PLL core192MHz/DDR384MHz，不把core时钟当AXI用户时钟。IP只暴露一个实际连接modified AXI口，既有AW/AR round-robin桥不是多主事务仲裁。旧master伪B/R响应与仅cal_done放行不能作为新增快照栅栏；新DMA必须跟踪真实响应并要求cal_pass。加密核未提供可见完整地址译码或校准保留区证明。

地址脚本1正6负通过，主会话另检查半开区间连续分割[0,2^32)、尺寸与无重叠。候选新增区[0x01000000,0x010E7000)在算术上不冲突，**实际已证明新增安全容量仍为0**，不能先写后验证。高位别名、保留区和视频并发隔离尚未解除。

主会话用Fraction复算74.4MHz/(1650×750)=60.121212121设计fps；相机60fps只是模型假设，合计视频110,703,709.0909091B/s。共享DDR理论峰1.536GB/s，不能将读写峰相加。每扫描460800B，每双向轮921600B，job固定807424B，竖蛇job296641024B。1pixel/96MHz-cycle假设下竖蛇计算下限6.1824秒；未综合且未计额外stall，不能承诺1～5fps。安全闲置预算null、效率情景未测量、serialized_estimate不是最坏wall界限。负fps、NaN、Inf三种输入拒绝测试通过。

最终M5A place证据9425/60800 XLR、105/256 RAM10、0/160 DSP已读取。新资源估增6000～16000 XLR、33～64 RAM10、0 DSP；高端合计25425/169/0，保留至少20%总资源，但不是新综合结果。16KiB FIFO容量下限13RAM10已与范围统一。新增仲裁拥塞/窄hold/CDC尚需后续独立验证。

## 所有权与发布整改

主会话指出并完成复核的两项模型修正：先reserve空闲结果槽再开始COPYING；旧pending ready未ACK时禁止复制或覆盖新descriptor。最终34项契约测试重跑通过，包括复制隔离、结果租约、pending ACK、COPYING abort/reset、epoch、帧格式、未决事务和timeout。不把协议模型当作RTL、CDC或真实AXI时序证明。

快照完整坐标/config/epoch/回放frame_id冻结；未收敛或错误结果不得发布。64双向轮或1秒watchdog为候选策略，触发后隔离并drain，在途事务不能立刻换owner。frame_id是DDR回放帧号，未证明是相机采集编号；age同epoch计算，陈旧mask不能直接OR到实时运动图。M5C只预留接口。

## 保护、范围与停止边界

`PROTECTED_BASELINES_BEFORE.json`与`PROTECTED_BASELINES_AFTER.json`绑定全量保护检查：10,430个可读文件、2,264,422,457B的SHA-256/大小/mtime一致，保护文件集合无增减；唯一既有M5A/.lock不可读，仅7B大小和mtime比较，不能宣称其内容哈希通过。历史1,550个未跟踪路径均保留。

最终文件范围及哈希见`FINAL_CHANGE_SCOPE.json`；只允许五份管理docs和本报告目录。索引为空、HEAD不变，既有reference/tools与历史未跟踪文件保留。没有生产RTL或Efinity副本，没有编译/bitstream生成/Programmer/下载/Flash/暂存/提交/合并/推送，没有首行诊断或融合/识别开发。M5A窄hold、PVT未证、PLL/I/O/CDC及旧Flash/R3/R4风险继续保留。

进入M5B.1前先解除新增地址、事务owner/响应与有界实时QoS、真实场景输出率阻断，见`GO_NO_GO.md`。本轮到此停止。

## 2026-10-07独立Git归档复核

本节为当前归档；主体、PROTECTED_BASELINES_AFTER.json及FINAL_GIT_STATUS.json属于上轮分析快照，后者记载旧HEAD/未跟踪数量，不应解释为本次提交后的现场状态。本轮用户授权按清单暂存及独立提交，覆盖历史“不提交”停止限制；M5B.0分析完成，NO-GO不变，M5B.1未启动，没有生产RTL、整机DDR接入、全局Canny bitstream或融合。

开始实际检查branch/HEAD/index/worktree/untracked，HEAD为M5A 4e0496e8a36f53dcfffa9e9564ffbf0f780a55ba、索引空。原43文件清单的41条非HANDOFF哈希行匹配；HANDOFF仅因本轮授权委派追加而先变化。原软件/结果保持，归档没有重复长测或调用Efinity。

GPT-6 Astra / ultra只读核对NO-GO、数字、报告、范围与历史/当前边界，主会话独立复核。修正README的“M5B未开始”及当前归档授权；GO_NO_GO明确六项继续阻断，算法表“每扫等于BFS”改为“完整收敛后等于BFS”。不改变任何算法模型或测试结果。四大类阻断为地址译码保留区、响应/仲裁、实时服务界限、真实帧统计；新增综合/STA/资源及实物压力共存也未完成，均不放行。

原43文件增加README、报告目录专属.gitattributes -text规则、ARCHIVE_PROTECTION_CHECK.json，共46文件。范围或大小按最终实际清单，不追求原43。-text只对reports/m5b0_global_canny_architecture生效，原M2～M5A属性未改；用于保持报告、软件与现有SHA证据字节，不新增生产源码。管理文档如发生CRLF→LF转换，应以清单Git clean blob与实测暂存SHA为准。

本轮保护证据见ARCHIVE_PROTECTION_CHECK.json，主会话在提交后再次只读检查全部保护及历史未跟踪集合。提交前逐项暂存、逐blob与最终清单的Git规范化内容/大小/SHA对比，包括清单自身（清单不能循环记录自己的SHA，由外部复核比较）；新提交须直接以M5A为父，独立提交信息docs: assess global canny architecture feasibility。具体提交ID、blob数量/总大小及提交后Git状态由实际Git终检报告，避免自身提交哈希循环。

所有软件协议PASS仅为契约，资源仅粗估，safe_new_bytes=0和候选地址未获生产授权不变。没有编译、bitstream、Programmer/下载/Flash、候选DDR试写、仲裁器、M5B.1、融合/识别、合并或推送。提交后停止，等待M5B.0R。

当前归档保护例外：历史唯一不可读efinity/m5a_streaming_canny_i3/.lock现不存在；主会话及审查代理均未删除或恢复它，不推断原因。保护文件集合与历史相比仅缺该运行时锁，不声称零差异或锁元数据不变。10430可读工程/证据文件的SHA/大小/mtime保持；1550历史未跟踪文件保留。当前证据见ARCHIVE_PROTECTION_CHECK.json，历史AFTER及其锁元数据结论只代表旧时点。
