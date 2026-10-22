from common import *
import datetime,shutil,stat
# Final passive binding check, after all native processes have exited.
exec(compile((R/'scripts/canny_gaussian_standalone/prepare_delivery.py').read_text(encoding='utf8'),'prepare_delivery.py','exec'))
results={}
for n in ['SHORT','BACKEND','FINAL_SHORT','SYSTEM','SYSTEM_ACCEPTANCE','FUSION_PIXEL','MAP','ROUTE','BASIC_STA','BUILD']:
 results[n]=json.loads((O/(n+'_RESULT.json' if n!='SYSTEM_ACCEPTANCE' else n+'.json')).read_text());assert results[n]['passed'],n
build=results['BUILD'];verify([build['bit'],build['native_bit']]);verify(json.loads((O/'SOURCE_MANIFEST.json').read_text()));verify(json.loads((O/'PARENT_SOURCE_MANIFEST.json').read_text()))
active=R/build['physical'];assert not any(json.loads(p.read_text()).get('running') for p in active.rglob('*_OWNER.json'))
passed_runs=[O/'short_171218',O/'backend_171710',O/'final_short_172906',O/'system_172630',R/results['FUSION_PIXEL']['result']['log']['path'].rsplit('/',1)[0]]
for d in passed_runs:verify(json.loads((d/'INPUTS.json').read_text()))
verify(results['BASIC_STA']['reports']);verify([results['BASIC_STA']['exact_binding']])
verify(json.loads((active/'BIT_INPUTS.json').read_text())['db'])
now=datetime.datetime.now(datetime.timezone.utc).isoformat()
bit=build['bit'];baseline=json.loads((O/'BASELINE_IDENTITY.json').read_text())
report=f'''# 双路 Canny＋高斯独立版：未提交冻结交付

本轮必要离线验证、fresh 构建及 BIT 已通过。等待 Work 核验后进入用户独立 Codex A；尚未上板、未 Git 提交、未调用 B。生成时间 {now}。

## 身份与范围

- branch：{baseline['branch']}；baseline HEAD：{baseline['baseline_head']}；parent：{baseline['parent']}。
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

BIT：{bit['path']}；{bit['bytes']}字节；SHA-256 `{bit['sha256']}`。
BUILD_RESULT、BIT_INPUTS绑定最终物理DB清单、SDC、STA与BIT；冻结包不复制大型DB/trace，只保留所需源码、oracle、日志和报告、map及首负STA证据。

只读snapshot/采用工程相对路径镜像。FROZEN_MANIFEST.json是逐文件size/SHA唯一清单；FREEZE_IDENTITY.json在快照外绑定清单SHA、范围、基线、BIT。源码XML中的原绝对路径是构建证据，审查应只读snapshot对应文件，不运行会写回工作区的生成脚本。Codex A提示词在快照外并由DELIVERY_RESULT绑定。普通Work核收继续，本轮正式停止点是用户独立A；A通过之后也必须由Work提供实物条目再由用户操作。
'''
(O/'DELIVERY_REPORT.md').write_text(report,encoding='utf8')
F=O/'snapshot';assert not F.exists();F.mkdir()
files=set()
def add(p):
 p=Path(p);assert p.is_file() and p.is_relative_to(R),p;files.add(p)
for name in ('SOURCE_MANIFEST.json','PARENT_SOURCE_MANIFEST.json'):
 for x in json.loads((O/name).read_text()):add(R/x['path'])
for d in [R/'scripts/canny_gaussian_standalone',R/'tb/canny_gaussian_standalone']:
 for p in d.rglob('*'):
  if p.is_file() and '__pycache__' not in p.parts:add(p)
for d in passed_runs:
 for x in json.loads((d/'INPUTS.json').read_text()):add(R/x['path'])
# Minimal reused oracle inputs: exactly the small cases used in this run.
for p in (R/'reports/gaussian_demo_20261020/data').glob('13x9_*.hex'):add(p)
add(R/'reports/gaussian_demo_20261020/data/kernel.hex');add(R/'reports/gaussian_demo_20261020/DATA_MANIFEST.json')
add(R/'reports/gaussian_integration_20261020/data/config_vectors.hex')
for p in (R/'reports/gaussian_integration_20261020/data/small').glob('*.hex'):add(p)
for p in [R/'tb/gaussian_integration/tb_gaussian_real.sv',R/'tb/m5c_fusion_core/tb_m5c_m5a_connection.sv',R/'docs/HANDOFF_CANNY_GAUSSIAN_STANDALONE_FAST_20261022.md',R/'docs/HANDOFF_GAUSSIAN_CAP_REMOTE_V2_SCHEDULER_FIX_20261021.md']:add(p)
# Include small receipts/raw logs of this run, including failed attempts.
exclude={'HEARTBEAT.json','PHASE_RESULT.json','NOTIFICATION_CONTEXT.json','NOTIFICATION_STATE.json','DELIVERY_RESULT.json','FREEZE_IDENTITY.json','FROZEN_MANIFEST.json','CODEX_A_REVIEW_PROMPT.md'}
for p in O.rglob('*'):
 if not p.is_file() or p.is_relative_to(F) or p.name in exclude:continue
 if any(x in ('work','work_pnr') for x in p.relative_to(O).parts):continue
 if p.suffix in ('.json','.log','.rpt','.sdc','.tcl','.patch','.md','.do') or p==R/bit['path']:add(p)
for name in ['Ti60_Demo.map.v','Ti60_Demo.map.rpt','Ti60_Demo.place.rpt','Ti60_Demo.route.rpt','Ti60_Demo.pinout.rpt','Ti60_Demo.pt.rpt','canny_normal_setup.rpt','canny_normal_hold.rpt','canny_check.rpt','canny_clocks.rpt']:add(P/'outflow'/name)
entries=[]
for p in sorted(files):
 relative=p.relative_to(R);dst=F/relative;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,dst)
 x=rec(p);assert hashlib.sha256(dst.read_bytes()).hexdigest()==x['sha256'];entries.append(x)
manifest=F/'FROZEN_MANIFEST.json';save(manifest,dict(schema='stareye_uncommitted_review_snapshot_v1',created_utc=now,baseline=baseline,files=entries,file_count=len(entries),bytes=sum(x['bytes'] for x in entries)))
identity=dict(status='FROZEN_UNCOMMITTED_REVIEW',created_utc=now,baseline=baseline,snapshot=F.relative_to(R).as_posix(),manifest=rec(manifest),source_manifest=rec(O/'SOURCE_MANIFEST.json'),bit=bit,files=len(entries),bytes=sum(x['bytes'] for x in entries),readonly=True,hardware_next=False)
save(O/'FREEZE_IDENTITY.json',identity)
prompt=f'''你是用户另一个可见会话的独立 Codex A，只读审查，不是实现者Astra或Work内部复核。

只读快照：F:/Projects/stareye_fpga/{identity['snapshot']}
清单：{manifest.as_posix()}
清单SHA-256：{identity['manifest']['sha256']}
branch {baseline['branch']}；baseline HEAD {baseline['baseline_head']}；parent {baseline['parent']}。
本轮尚未提交，candidate commit为无。五个新增目录在baseline中不存在；不得把快照冒称commit。来源差异见快照reports/canny_gaussian_standalone_fast_20261022/FOCUSED_TECHNICAL_DIFF.patch和DERIVATION_MANIFEST.json，指向已逐文件冻结的gaussian来源。

先核逐文件size/SHA与快照清单，再阅读DELIVERY_REPORT.md、真实编译闭包和必要原日志。只读快照，不审持续变化工作区，不修改/生成/暂存/提交，不运行Programmer、不下载、不写Flash、不调用B。允许只读Git确认baseline身份/目录不存在，不以外部工作区替代快照。

BIT {bit['path']}，{bit['bytes']}字节，SHA-256 {bit['sha256']}。冻结内有同路径副本。fresh新map/interface/place/route通过，XLR36322、RAM181、DSP1；normal I3 setup +0.161ns/hold +0.018ns，内部未约束0。短门、实际新backend取消恢复/首发布lease、42帧720p全SUT及2帧GAU融合逐坐标金模门通过，完整原日志在快照。不得将直供参考两帧门说成DDR，也不得把本轮结论外推为旧V1/V2全通过。

重点检查：
1. 去UART/pair后首次发布能直接被融合租用；STATS_WAIT、取消/timeout、已受理真实B/末R、writer/read lease/slot fencing没有被绕过或假ACK；保留命名含pair的租约仲裁是否必要且安全。
2. MED0–3/GAU4–6、SOF配置代际、源资格、TTL、行缓存与红局部/青新增坐标对齐；这里不是全七模式GAU或同算子A/B。SUT的cadence加速仅测试调度，非生产FPS保证。
3. 首STA -0.816ns失败与物理别名修复：逐一审462目的D真实驱动Q及canonical字段证明、257新增lease_identity源；只保持原5ns bundle约束/hold语义，不遗漏别名、不误纳其他异步数据、不泛化falsepath。核实际map/SDC/STA及保留失败原件，控制offer/held稳定/生命周期围栏仍成立。
4. 新实际I2C 3040/C000唯一写入且stream-enable前，OSD仅去PREV、方向未翻转；顶层管脚/时钟/分辨率保持。
5. 测试与BIT源绑定、原生XML只变运行元数据；基本STA继承PLL异步SR、外部7/135未约束、窄hold/PVT/暖复位限制，不能说成实物已通过。

输出问题表字段：严重程度、文件/位置、问题、证据、影响、建议。区分阻断、非阻断和已披露限制。最后结论只能PASS、PASS_WITH_FINDINGS或FAIL；给出审查快照manifestSHA和BIT SHA。审查结论交用户/Work，不自行推进硬件或Git。
'''
(O/'CODEX_A_REVIEW_PROMPT.md').write_text(prompt,encoding='utf8')
for p in F.rglob('*'):
 if p.is_file():p.chmod(stat.S_IREAD)
# Re-read frozen bytes before final stage receipt, including manifest itself.
for x in entries:
 p=F/x['path'];assert p.stat().st_size==x['bytes'] and hashlib.sha256(p.read_bytes()).hexdigest()==x['sha256']
verify([identity['manifest']]);verify(json.loads((O/'SOURCE_MANIFEST.json').read_text()))
final=dict(status='PASS',passed=True,running=False,phase='OFFLINE_DELIVERY_READY_FOR_WORK_AND_USER_A',updated_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),baseline=baseline,freeze=rec(O/'FREEZE_IDENTITY.json'),manifest=identity['manifest'],bit=bit,report=rec(O/'DELIVERY_REPORT.md'),codex_a_prompt=rec(O/'CODEX_A_REVIEW_PROMPT.md'),resource=build['resource'],sta=results['BASIC_STA']['normal'],hardware_next=False,hardware_authorized=False,git_mutation=False,independent_a_pending=True,known_limitations='See frozen DELIVERY_REPORT.md; offline PASS only, no hardware qualification.')
save(O/'PHASE_RESULT.json',final);save(O/'HEARTBEAT.json',final)
ctx=json.loads((O/'NOTIFICATION_CONTEXT.json').read_text(encoding='utf-8-sig'));ctx.update(codex_checked_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),codex_observation='Astra已完成本轮必要验证/BIT和只读冻结，正在回报Work核验；后台原生任务全部结束');save(O/'NOTIFICATION_CONTEXT.json',ctx)
save(O/'DELIVERY_RESULT.json',final);print('DELIVERY_READY',identity['manifest'],identity['files'],identity['bytes'],flush=True)
