# 双路 Canny＋高斯独立版：未提交冻结交付

本轮必要离线验证、fresh 构建及 BIT 已通过。等待 Work 核验后进入用户独立 Codex A；尚未上板、未 Git 提交、未调用 B。生成时间 2026-10-22T09:57:11.777588+00:00。

## 身份与范围

- branch：codex/m5c-fusion-prototype；baseline HEAD：b5f36414035193ab9c7aa8393732a93e10fe141e；parent：9dea12d9f0d29f57aa6d3acb75695da9e0d53d2c。
- candidate commit：无。五个本轮目录在基线 HEAD 中均不存在，基线差异是新增目录。不要把本快照或 gaussian 工作区来源称为新提交。
- 真实生产源102个文件、XML显式编译58个入口，含准确IP/include闭包。DERIVATION_MANIFEST记录95个逐字节相同来源、7个集中修改文件。FOCUSED_TECHNICAL_DIFF是与冻结 gaussian 来源的差异，不是与Git parent的差异。
- 原来源102个文件均按开工清单核对未变。MAP_SOURCE_BINDING证实所有生产逻辑输入与fresh map时相同；唯一技术后续变更为精确SDC，另有Efinity XML的last_change/last_run_flow运行元数据，所有子元素不变。最终源码/SDC/XML均重新量测SHA。

## 架构与操作

保留真实视频DMA、GAU/MED前处理、局部Canny-lite、后台完整八邻域全局Canny、行缓存保守融合、frame/config/source identity/TTL和故障停止。红色为局部边缘优先，青色为全局新增弱连通边缘。

去掉识别/PREV、pair采集/控制/数据邮箱、完整UART图导出、遥测消费路径；实际map无这些实例及shadow_tiles。UART引脚接口保留并固定idle1。保留名称含pair的原租约及读写仲裁模块是为了slot、未完成B/末R的生命周期保护；它们不是保留pair采集功能。STATS_WAIT仍等待真实writer/transfer/engine/arm/FIFO/descriptor全部空闲。首次发布不再等待exported或uart_owned；acquire/release/retire都使用真实融合事件。

| 模式 | 显示算法 | 配置中的滤波 |
|---|---|---|
|0 RAW|原始灰度|MED（后台和内部处理）|
|1 MAG|Sobel幅值|MED|
|2 BIN|Sobel阈值二值|MED|
|3 OVR|Sobel局部红色叠加|MED|
|4 NMS|非极大抑制|GAU|
|5 CNY|Canny边缘，融合开时可补边|GAU|
|6 COV|局部红色＋新增青色＋灰度底图|GAU|

双键短按循环七模式，双键长按切换融合；单键按原映射调整阈值±16。复位为模式2、阈值64，融合默认关闭。MED0–3/GAU4–6沿用现有语义，并非全部七模式GAU或相同算子的A/B对照；不加入新的按键映射。

新实际I2C LUT只有READ_MODE 3040从8000变为C000，保留bit15、切换bit14，stream-enable之前恰好一次。没有反转LCD/OSD；新OSD只去PREV区域，其余1,237,500栅格比对相同。旧工程未修改。

## 本轮验证

- 六个局部门：5233 GAU整数核向量、CE/边界/重启、控制原子换代、配置拒绝，11个小帧真实新stream共33792像素/tap/gradient。局部门复用旧TB/oracle但编译本轮新内核，不冒称实例化完整新系统。
- 新backend生命周期：真实新canny_backend，首次捕获无SOF超时后真实取消/排空，再捕获921600分类并跑完整全局BFS，检查81连通弱点与81孤立弱点；首发布立即可融合acquire，未完成read_done之前release不释放。这里读者请求是合成契约激励，真实DDR转移与B/末R由模型驱动，不伪造ACK。
- age/config边界178项、数据边界500项＋60停顿；实际新I2C sequencer完成23次写、唯一3040/C000；OSD保留区逐像素一致。
- 完整720p新系统：42个稳定帧、38,707,200逐像素gold检查，真实新system＋LCD寄存＋新滤波前端＋融合＋OSD＋DDR事务服务模型；5次发布各921600bit与独立BFS一致。MED完整健康4帧、GAU64健康6帧、COV健康2帧各1391青点、阈值80健康3帧、关闭2帧并重新开启恢复，B=39360、lastR=79706。SYSTEM_ACCEPTANCE进一步要求所有标为健康的帧均921600像素，并核mode3实际健康先于GAU4。
- 全系统只加快后台请求间隔为2,000,000 UI周期（生产96,000,000）；像素/相机/UI时钟、1280×720尺寸、服务384、TTL及生产引擎超时不变。该测试不证明生产FPS。
- 额外唯一两帧坐标门：真实新GAU frontend＋row_fusion，使用直供同步参考REF_STAGE0（明确非DDR），逐一比较1,843,200像素/tap及融合位置；正帧1391个精确补边，错误identity帧0补边，CE暂停741次。完整SUT覆盖真实缓存/DDR生命周期，此门独立证明BFS位置映射。
- MED64 gold新增0；GAU64 gold新增1391；GAU80 gold新增0。阈值80检查新代际恢复和弱链消失，不放宽cyan断言来冒充有新增。

## 物理与CDC

本轮新工程fresh map/interface、seed1 place/route及basic normal I3 STA完成。map估计LUT25390/FF15517、RAM168+13，与实际place/route资源不是同一指标。

| 实际资源 | 使用 | 冻结预算 |
|---|---:|---:|
| XLR（含routing） |36322 /60800（59.74%）|≤51680|
| RAM10 |181 /256|≤204|
| DSP |1 /160|≤128|

normal I3最小setup +0.161ns、hold +0.018ns；no_clock、unconstrained_internal_endpoints、multiple_clock均0。3162组内精确pin绑定逐项原生解析，68原组中仅14已移除pair/telemetry空组删除；其余活跃路径保留。

首轮STA为setup −0.816ns/hold +0.012ns，已原样保留于physical_20261022_171508/STA_FAILURE_PRESERVED。原因是offer目的寄存器的物理源被综合别名为lease_identity，初始按active_descriptor名字枚举仅205源，遗漏257源。修复逐项从462个目的FF D真实直接驱动Q反追，断言两端EFX_FF、clk_sys→clk_pixel及等价held字段（含重复config/timestamp/lease identity字段），见OFFER_BUNDLE_DIRECT_DRIVERS。严格维持5ns max-delay及原hold处理，不扩大false_path、不改RTL；后续重新place/route/STA通过。原offer控制捕获、held active tuple稳定、revoke/reader/cache排空围栏均保留，full SUT的稳定tuple/身份/协议检查通过。

## 已知限制与失败记录

继承PLL异步SR未计时、外部7输入/135输出缺少输入/输出delay、窄hold余量；未证明全PVT/暖复位/真实DDR电气/实物传感器方向。未做未变全FF/metadata资产审计。未宣称旧高斯V1全通过：其MED/GAU每帧换代导致健康饥饿的夹具问题有V2交接，但没有完整V2结果可引用。

本轮初始ModelSim厂商加密IP兼容问题、两次XML序列化格式失败、新SUT旧ModelSim声明顺序、追加像素门缺接source_config_generation造成无有效tap均保留原日志；分别修正编译范围/格式/测试夹具后通过。首STA负结果如上单独保留。没有把这些失败隐藏为初次通过。

## BIT与冻结读法

BIT：reports/canny_gaussian_standalone_fast_20261022/artifacts/StarEye_Canny_Gaussian_Standalone.bit；2750379字节；SHA-256 `8c0fb30e4b5f8f2fcad2eca27cf5945ff4bc3643aedfb915470a33c0c45550ed`。
BUILD_RESULT、BIT_INPUTS绑定最终物理DB清单、SDC、STA与BIT；冻结包不复制大型DB/trace，只保留所需源码、oracle、日志和报告、map及首负STA证据。

只读snapshot/采用工程相对路径镜像。FROZEN_MANIFEST.json是逐文件size/SHA唯一清单；FREEZE_IDENTITY.json在快照外绑定清单SHA、范围、基线、BIT。源码XML中的原绝对路径是构建证据，审查应只读snapshot对应文件，不运行会写回工作区的生成脚本。Codex A提示词在快照外并由DELIVERY_RESULT绑定。普通Work核收继续，本轮正式停止点是用户独立A；A通过之后也必须由Work提供实物条目再由用户操作。
