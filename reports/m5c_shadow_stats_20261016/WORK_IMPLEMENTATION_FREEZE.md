# Work实施冻结：64/128列旁接影子统计（schema2）

用户授权：“那就按你的建议，开始增加64列和128列的影子统计，继续下一步”。这是L3核心RTL/流水/诊断协议工作，由Codex exec/GPT-6 Astra独占实现。Work负责规格、核证及双审/实物闸门。先完成实现、验证、资源/完整I3与离线bit，再准备固定candidate；未经Work精确Git范围批准不提交。

## 固定身份与既有工作

开发基线branch codex/m5c-fusion-prototype，HEAD1786858c7ae9a0c756cc37c43beceb93eca92b9e，parent3b49a1f701798a817fed42b8097f724cbc9d6160。新核心candidate预期追加在1786858c之后，实际parent由最终Work回执核定，不改历史。

主工作区保留用户已授权的M3A/M3B目录迁移（原m31/m32目录删除状态、新目录未跟踪）、相关入口脚本/.gitignore/.gitattributes变化和Work管理文档。不要还原、暂存、清理或纳入核心改动；整个工作区不是clean。先记录仅本任务允许技术输入的SHA、已跟踪变化/当前index状态以及既有修改的原字节基线。核心技术路径现与1786858c一致；在正式工程位置开发，构建用冻结隔离镜像。候选准备时如需干净审查工作树，由Work安排固定candidate的独立只读checkout；不能为获得clean而吞入/清除M3变化。

## 本轮目标和不变项

既有整行匹配仍独占promoted/fused_rgb/视频控制；影子结果不得驱动生产门、阻塞CE/有效像素/DDR/后台job/lease或增加显示延迟。身份/epoch/config/TTL120帧及148500000tick、fullSID/token、行cookie/坐标、支持域/本地抑制、原始class合法性、真实B/R排空及冷硬停边界保持。M5A/M5B既有工程、M3新名称、pin/PLL/时钟/720p60、七模式/按钮语义不改。目标是测量候选保留机会和风险线索，不能声称实物误加率或当前帧完整BFS。

每个被原观察器接纳的同一帧，保留原P0..P4及完整身份、首class差异、dropped/aborted/saturated、PREP/真实UART DONE后TAKE契约。默认SAMPLE_FRAMES=60保持。新增逻辑仅在原比较流旁接，推荐复用原row_y/cookie作为只读标签验证，避免无谓复制304状态位；不能因省资源缩窄标签。四bank比较元数据与八bankDDR缓存分清。

## 逐行影子语义

同一完整current/reference比较行，建立20个64列精确块和10个128列精确块。块为[x>>6]和[x>>7]，覆盖0..1279且无部分尾块。所有比较包含块末像素、行末1279，当前/参考class不相等或任侧class3使对应块不等。

另外逐行累计（并绑定同row/cookie/完整比较资格）：
- illegal_row：任一接受比较位置current_class==3或reference_class==3。
- strong_loss_row：任一接受比较位置reference_class==2且current_class!=2。它只表示同一行有强种子消失/变弱线索，不等同该候选真的误加，也检测不到所有行外种子/桥变化。

行x0作废/重建新row/cookie的影子记录，行complete前不使用影子块；任何中断、身份/坐标缺口、context kill/复位/复用不得把旧块标志标成新帧有效。原完整row/tag/cookie条件仍用作影子取样资格，不能只比较低位row或SID。允许复用严格原始行生命周期只读信号，但必须有测试证明影子flags与该行所有已完成比较同代。若有独立有效位，必须明确缺失时的计数语义，不得默认为相等。

## 新字段（type5 payload schema2，原header/长度不变）

header magic/version/type/size与256字节payload、4字节CRC保持，wire仍324字节；payload偏移0的u32 schema变2。旧P0..P4、flags和身份位置均保持。schema1永远保留历史原义，其208..255必须为零；新主机解析器只读兼容1/2，schema1扩展字段表示“不提供”，不得当成实测零。

以下七个u32均与P0在同一个CAPTURE事件窗口计数、32位饱和，并共同影响已有saturated flag；按每个事件而非帧/行计数：

|payload偏移|字段|精确定义|
|---|---|---|
|208|p0_complete_fail|P0 && !row_complete|
|212|p0_tag_fail|P0 && !row_tag_good|
|216|p0_equal_fail|P0 && !row_equal|
|220|shadow64_accept|P0 && row_complete && row_tag_good && shadow_same_row_cookie_valid && !illegal_row && exact_tile64|
|224|shadow128_accept|同上，exact_tile128|
|228|p0_strong_loss_row|P0 && row_complete && row_tag_good && shadow_same_row_cookie_valid && strong_loss_row|
|232|p0_illegal_row|P0 && row_complete && row_tag_good && shadow_same_row_cookie_valid && illegal_row|

236..255的20字节继续严格零。前三个拒绝计数允许重叠，不相加宣称互斥损失；丢影子上下文不能算通过，若出现必须明确验证/可观测办法，不能悄悄吞样本。若设计需要额外valid诊断字段或不同字段，先给Work具体方案再执行。正常完整合法帧应有shadow128_accept<=shadow64_accept<=P0，原P1<=shadow128_accept（相同P0/合法完整标签、无context异常时）；这些只是统计包含关系，不能改写为生产等价性。strong-loss/illegal计数是候选加权风险线索，不是FP真值。

内存记录仍40×64位，单写口PREP/SEAL维持BRAM推断。七字段装入words26..29，word29高32位零、words30..31零；不要恢复2560FF格式器。原协议UART时隙700000/896000、默认实际324B完成675542周期的预算依旧须线级复核，不能靠延时原任务取时隙。保留新旧type1..4逐字节语义、桥异步复位/取消/复用、真实done后take和稳定RAM读取。

## 允许范围与禁止

允许：rtl/m5c_diagnostics的版本化观察器/只旁接helper；rtl/m5c_fusion中row_fusion/fusion_display仅新增只读输出或无反馈旁接，不改原生产表达式/时序；efinity/m5c_fusion_i3/example_top.v的新只读接线及XML明确新增文件；tb/m5c_diagnostics、scripts新增m5c_shadow_*与新schema解码器/必要当前diag跑测入口；新reports/m5c_shadow_stats_20261016所有证据/隔离构建；必要精确SDC映射和新增真实CDC/时序审计（先向Work报告映射差异）；必要Work管理记录后续交回Work更新。

旧scripts/m5c_diag_*若已有验收源hash约束，优先保持、另建新版本入口；历史报告/压缩对象/原raw用户bin/json不可改、不可含进外发candidate。schema1解析器保留拒绝保留域异常的旧语义，不松断言来通过新格式。不得修改M3路径适配或受保护M2～M5B旧目录，不能全仓替换模块名。不得清理任何未知输出，禁止Programmer/串口/JTAG/SPI/Flash、远程推送/merge main/历史改写。

## 执行和验证闸门

1. 先给字段/接线/标签/资源小方案后直接按冻结实施（内部常规实现选择自主解决，若触及上述接口/语义则先报Work）。新增块逻辑和schema独立短测：块首末63/64/127/128/1279、远点/同块差异、最后像素strong-loss和class3、四bank跨帧/长SID-cookie/ABA/缺口/tag/complete/kill/取消/复位/CE停拍、saturation、READY全记录稳定、OSD尾拍及原P0..4一致。
2. 独立class域software oracle逐像素计算每条新计数，含所有保护条件；指定负向突变须分别击穿块末漏算、64/128取错块、旧cookie/缺complete、原行gate被shadow替换、未版本化/schema/reserved、饱和/提前ACK等具名门，不能静默只运行旧schema1测试。新解析器对原schema1实际记录/合成数据兼容，对schema2严格reserved/schema/身份/CRC；所有用户raw只本地读取，不向第二审查发送。
3. 验证生产旁接不干扰：同一完整720p current/reference输入，基线1786858c vs新路径七模式/原fusion on/off/OSD逐像素、oldtype1..4语义/后台/租约事件等差分；coupled默认324B真实UART与强背压/取消，enabled整机至少真实完整schema2并核CRC、source/UI/start/done/take守恒和原BFS；全系统加速/默认速率分开披露，不能用DIAGNOSTICS0有限回归冒充新enabled覆盖。相关既有取消/lease恢复、capture/display资格和完整像素链仍须保留有效回归证据，按实际源码变化选择必要矩阵，不机械重跑无关历史失败。
4. 新鲜完整map/interface/place/route和I3/CDC/资源/异常端点审计，严格XLR含routing<=51680、RAM<=204、DSP<=128，最小setup/hold为正且内部no_clock/unconstrained/multi_clock无新增；精确路径/控制D/CE/SR/RAM映射和14时钟196对等原边界照常检查，不使用宽泛cut掩盖新逻辑。新增统计余量估算不是实际资源通过。若超门先报告Work并优先在纯旁接内小优化，不缩字段/身份/精度，不放宽门，不擅砍64/128任一必需统计。资源通过后继续布线/STA/离线bit，构建不因后台测试而停工。
5. 完成后技术源/新脚本/测试/证据逐hash清单、bit实际大小/SHA、scope清单交Work。Git阶段尚未授权（待Work精确stage清单）；不是开发到一半就停。Work批准后才能创建固定candidate并停止writer，Work核commit/parent和candidate-only快照自动DeepSeek B，同时停交用户Codex A提示词；双方独立结束前不交换报告。新实物节点另停给用户清单，旧bit不能冒充新统计。

长测试规则约120分钟才按用户要求转为保持后台运行并先交回；不得主动超时杀掉正常native，更不得把120分钟当native timeout。未达此阈值，持续推进已授权内部工作；不可把完整构建当长测试借口停掉。Work/代理需保存进程/状态/封存，关闭聊天后不能冒充无进程的后台任务。

交回包含branch/候选身份（未提交就明确）、实际允许改动、仿真与反例、完整I3资源/STA/CDC、offline bit元数据、已知限制、隔离/保护及现有M3变化状态。无实物增强声明，不进入M6/M7。
