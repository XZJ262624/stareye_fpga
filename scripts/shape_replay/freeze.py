from common import *
import shutil
F=R/json.loads((O/'ACTIVE_PHYSICAL.json').read_text())['path'];V=R/json.loads((O/'ACTIVE_TESTS.json').read_text())['path'];B=R/json.loads((O/'ACTIVE_BOUNDARIES.json').read_text())['path']
assert json.loads((F/'FINAL_RESULT.json').read_text())['passed']
assert json.loads((B/'FINAL_RESULT.json').read_text())['passed']
for n in ('controls','repeated_short','boundary41'):assert json.loads((V/(n+'_RESULT.json')).read_text())['passed']
broad=json.loads((V/'integration720p_RESULT.json').read_text());broad_text=(V/'integration720p.log').read_text(errors='replace')
boundary_text=(B/'context.log').read_text(errors='replace');assert 'CONTEXT_BOUNDARY_PASS' in boundary_text
coverage_note=None
assert broad['passed'] and 'SHAPE_REPLAY_PASS' in broad_text,broad_text[-3000:]
counts={k:int(v) for k,v in re.findall(r'(\w+)=(\d+)',re.search(r'SHAPE_INTEGRATION_COUNTS ([^\r\n]+)',broad_text)[1])}
for w in (V,B):verify(json.loads((w/'INPUTS.json').read_text()))
verify(json.loads((O/'PROTECTED_PARENTS.json').read_text()));verify(json.loads((F/'BIT_INPUTS.json').read_text()))
assert json.loads((O/'FINAL_BUILD_BINDING.json').read_text())['passed']
identity={}
for k,args in [('branch',['rev-parse','--abbrev-ref','HEAD']),('head',['rev-parse','HEAD']),('parent',['rev-parse','HEAD^']),('index',['diff','--cached','--name-only'])]:
 q=subprocess.run(['git','-c','safe.directory=F:/Projects/stareye_fpga']+args,cwd=R,capture_output=True,text=True);assert q.returncode==0;identity[k]=q.stdout.strip()
assert identity==dict(branch='codex/m5c-fusion-prototype',head='433a83e543cb40a52128d1eea4ae32ce83aecd16',parent='b5f36414035193ab9c7aa8393732a93e10fe141e',index='')
build=json.loads((F/'FINAL_RESULT.json').read_text());bit=build['bit'];resource=build['sta']['resource'];timing=build['sta']['minimum']
fix=json.loads((O/'CONTROL_FIX_RECORD.json').read_text());assert rec(T/'shape_replay_controls.sv')==fix['production_change'];fix['status']='FIXED_QUALIFIED_OFFLINE';fix['new_physical']=rec(F/'FINAL_RESULT.json');fix['new_integration']=rec(V/'integration720p_RESULT.json');save(O/'CONTROL_FIX_RECORD.json',fix)
validation=dict(passed=True,status='PASS_OFFLINE_COMPOSED' if coverage_note else 'PASS_OFFLINE',hardware=False,candidate_commit=None,git=identity,build=build,broad_integration=rec(V/'integration720p_RESULT.json'),broad_coverage_note=coverage_note,targeted_boundaries=rec(B/'FINAL_RESULT.json'),replay_reuse=rec(O/'INHERITED_REPLAY_EVIDENCE.json'),limits=['CF32 replay order/loop proven at8192B geometry; parentCF2 full720p; mergedCF3 full720p trajectory andCF1 actual context target. Not32-frame full720p integrated simulation.','Conditional behavioral DDR service with stalls, not encrypted DDR core analog/timing simulation.','Physical clip32..64MiB, sensor FPS, image behavior, external7 input135 output/PLL asynchronous SR/PVT/warm restart not hardware qualified.','Inherited hardstop can revoke stalled WVALID; only cold reconfiguration recovery, no synthetic resetACK.'])
validation['integration_counts']=counts;save(O/'VALIDATION_RESULT.json',validation)
save(O/'HEARTBEAT.json',dict(status='OFFLINE_COMPLETE_READY_FOR_WORK_REVIEW',phase='freeze',running=False,updated_unix=time.time()))
doc=f'''# 合并版离线交付，待Work核定／用户独立A

Branch `{identity['branch']}`；基线HEAD `{identity['head']}`，parent `{identity['parent']}`。这是未提交冻结快照，没有candidate commit，暂存区为空。本轮未Git写入、未发送DeepSeek B、未操作硬件。

生产功能：LIVE／REC／PLAY／PAUSE＋原960×540 ROI的圆／轴对齐矩形／UNKNOWN识别；GAU2、H64/L32固定，RAW0／CNY5／COV6，默认COV。真实历史灰度通过同一识别链重新运算，capture ID可重复而display序号独立递增。真实首DE切换LIVE/clip上下文时同拍送next generation，撤旧PREV，不复位DDR或清队列。

录32完整720p灰度帧，每4camera抽1，每4完整display消费推进。payload29,491,200B，clip `[0x02000000,0x03FE1000)`内32个1MiB stride payload，live基址0/4/8/12MiB。约2.1秒采样动作、名义2.133秒回放循环；实际时长与地址物理资格仍待实物。

Fresh I3物理：{resource['XLR']:,} XLR、{resource['RAM']} RAM10、{resource['DSP']} DSP，原始各200路径setup最小{timing['setup']:+.3f}ns、hold最小{timing['hold']:+.3f}ns。18组328精确端点，40条Gray经过8888复位AND门（最高位与binary同值），101条直接held mailbox字段含2bit视图；同7组5ns预算和对应hold语义，无clockwide falsepath。内部no_clock、unconstrained_internal_endpoints、multiple_clock均0。所有实际BIT输入DB绑定通过；XML只有运行元数据变化。

BIT `{bit['path']}`，{bit['bytes']}B，SHA-256 `{bit['sha256']}`；原生和交付副本一致。

测试：原41条wideROI边界向量不改期望通过；新键控通过；新完整720p摄像→DDR→历史→GAU/Canny→adapter/分类/单级OSD验证独立gold与历史分类，覆盖圆、矩形、三角形UNKNOWN／三视图／暂停重复ID／循环／返回LIVE／重录；额外真实首DE上下文与旧clip在途读排空门通过。具体原始结果及覆盖不足补测关系以VALIDATION_RESULT.json为准，保留所有FAIL，不把未命中场景称RTL故障或通过。

复用未变回放11个PASS用例：CF32小几何控制／守卫／按键，6故障，CF2完整720p及四帧局部像素。原首组fault1夹具误拒冷hardstop、后组修正及历史TB精确SHA还原已披露。27关键生产拷贝与父逐字相同，所有父生产清单保护通过。未运行旧全局BFS／计件／72帧历史全量。

修复记录：旧控件接受释放时held清零被旧stable分支覆盖，连续短按累积成错误长按。Work定位后，最小复现第三次短按误发长按，旧完整联动主动停止；这是实际RTL阻断，不能说旧长例功能通过。只在新shape_replay控件加接受释放优先guard，bootstrap同修；K1九次短按、K2五次短按、两长按、混合序列与长阈值释放临界拍全部通过，并重跑受影响完整联动及fresh物理。旧5baf50e17cd9d5b6f7fd578147004c17ec260a3bb8bc1dc9089182020000f566 BIT明确SUPERSEDED_NOT_FOR_DELIVERY；旧原生日志/控件/物理输入保留，旧canny_replay父不回写。

限制：新结合版尚未外部A或上板；窄hold、外部7输入135输出、PLL异步SR、PVT、全容量与新增clip区实测、暖复位及真实最坏DDR服务均未获新资格。硬停沿用仅冷重新配置恢复且可撤销stalled WVALID的隔离边界。ModelSim有未使用输出端口警告，不能宣称零警告。操作详见OPERATING_NOTES.md。
'''
put(O/'DELIVERY_REPORT.md',doc)
# Explicit minimal payload closure. No recursive scan of old unrelated reports.
files=set()
for root in (T,R/'tb/shape_replay',R/'scripts/shape_replay'):
 files.update(p for p in root.rglob('*') if p.is_file() and '__pycache__' not in p.parts)
files.update(R/x['path'] for x in json.loads((F/'PRODUCTION_INPUTS.json').read_text()))
files.update(R/x['path'] for x in json.loads((F/'BIT_INPUTS.json').read_text()))
files.update([R/bit['path'],R/build['native_bit']['path'],P/'outflow/Ti60_Demo.map.v',P/'outflow/Ti60_Demo.map.rpt',P/'outflow/Ti60_Demo.route.rpt'])
if (F/'PROJECT_BEFORE_MAP.xml').exists():files.add(F/'PROJECT_BEFORE_MAP.xml')
files.update(P/'outflow'/n for n in ('replay_normal_setup.rpt','replay_normal_hold.rpt','replay_check.rpt','replay_clocks.rpt'))
for w in (V,B):
 files.update(p for p in w.iterdir() if p.is_file() and p.suffix in ('.json','.log','.do'))
 files.update(R/x['path'] for x in json.loads((w/'INPUTS.json').read_text()))
for p in F.rglob('*'):
 if p.is_file() and p.suffix in ('.json','.log','.tcl'):files.add(p)
for p in O.iterdir():
 if p.is_file() and p.suffix in ('.json','.md') and p.name not in ('DELIVERY_RESULT.json','FROZEN_MANIFEST.json'):files.add(p)
files.update(p for p in (O/'inherited_inputs').rglob('*') if p.is_file())
for label in ('control_probe_20261028_190845','control_probe_20261028_191113','tests_20261028_182408','tests_20261028_191203'):
 files.update(p for p in (O/label).iterdir() if p.is_file() and p.suffix in ('.json','.log','.sv','.do'))
 files.update(p for p in (O/label/'exact_inputs').glob('*') if p.is_file())
files.add(O/'physical_20261028_182151/SUPERSEDED_INPUTS.json')
files.update([O/'physical_20261028_182151/FINAL_RESULT.json',O/'physical_20261028_182151/superseded/rtl/shape_replay/shape_replay_controls.sv'])
for case in json.loads((O/'INHERITED_REPLAY_EVIDENCE.json').read_text())['cases']:
 files.update(R/case[k]['path'] for k in ('result','log','inputs'))
files.update([R/'docs/HANDOFF_SHAPE_REPLAY_20261028.md',R/'docs/HANDOFF_CANNY_REPLAY_20261028.md'])
files.update(R/x['source']['path'] for x in json.loads((O/'ADDRESS_AND_COPY_CHECK.json').read_text())['copies'])
files.update([R/'rtl/shape_standalone/shape_standalone_system.sv',R/'rtl/shape_wide_roi/shape_osd.sv',R/'rtl/canny_replay/replay_controls.sv',R/'efinity/shape_wide_roi_i3/example_top.v',R/'efinity/shape_wide_roi_i3/Ti60_Demo.xml',R/'efinity/canny_replay_i3/Ti60_Demo.xml'])
S=O/'snapshot';assert not S.exists();S.mkdir();manifest=[]
for src in sorted(files):
 x=rec(src);dst=S/'files'/x['path'];dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(src,dst)
 assert dst.stat().st_size==x['bytes'] and hashlib.sha256(dst.read_bytes()).hexdigest()==x['sha256']
 manifest.append(dict(source=x,snapshot=rec(dst)))
save(S/'FROZEN_MANIFEST.json',dict(schema='shape_replay_frozen_v1',snapshot_id='shape_replay_20261028_precommit_v1',created_unix=time.time(),candidate_commit=None,git=identity,bit=bit,files=manifest))
save(O/'DELIVERY_RESULT.json',dict(passed=True,status='READY_FOR_WORK_REVIEW_NOT_HARDWARE',git=identity,candidate_commit=None,validation=rec(O/'VALIDATION_RESULT.json'),bit=bit,snapshot=rec(S/'FROZEN_MANIFEST.json'),files=len(manifest),payload_bytes=sum(x['source']['bytes'] for x in manifest),writer_stopped=True))
put(O/'CODEX_A_REVIEW_PROMPT.md',f'''# 用户独立Codex A审查提示词

你是用户另一个可见Codex对话中的独立Codex A，只读审查星眸回放＋简易形状识别专用版。不要把Work内部检查视为独立A。基线branch `{identity['branch']}`、HEAD `{identity['head']}`、parent `{identity['parent']}`。本次尚未提交，没有candidate commit；只审已冻结快照，禁止审持续变化工作区。

冻结入口：`F:/Projects/stareye_fpga/{(S/'FROZEN_MANIFEST.json').relative_to(R).as_posix()}`。
Manifest SHA-256：`{rec(S/'FROZEN_MANIFEST.json')['sha256']}`。先逐文件核snapshot文件大小与SHA，并确认manifest中source/snapshot记录一致；source表示冻结时身份，无需读取活动工作区。所有审查读取限定snapshot/files。实际交付BIT `{bit['path']}`、{bit['bytes']}B、SHA `{bit['sha256']}`。

先读快照内HANDOFF_SHAPE_REPLAY_20261028.md、DELIVERY_REPORT.md、VALIDATION_RESULT.json、OPERATING_NOTES.md；查新rtl/shape_replay、efinity/shape_replay_i3与明确父拷贝的差异。27依赖字节复用，原960×540/16px/80..440形状判据不改；不是计件或全局融合版。真实DDR录像32帧与新三视图/形状上下文是实际范围。

重点：1.真实末B+完整EOF登记、每4camera抽样与完整display4次消费、live/clip地址权限及只读lease；2.PLAY/PAUSE重复capture ID合法而displayseq独立，实际首DE的effective generation与原PREV撤旧、view2bit握手原子SOF应用；3.录制开始撤旧clip、取消不复活，旧clip在途读可排空但不得与重录写冲突；4.原Canny RAW0/CNY5/COV6及GAU2 H64/L32、原识别/完整性逐字复用，历史分类来自历史灰度而非当前camera；5.单级OSD/960×540框/头部不重叠；6.具体CF32小几何、父CF2和新CF3/CF1完整720p覆盖边界，失败夹具及补测闭合诚实；7.实际映射18组328精确CDC、Gray MSB经8888复位门而非虚构直连、同5ns/hold语义、原始STA/BIT/DB输入绑定。

另须重点审查CONTROL_FIX_RECORD.json：连续短按释放归零被覆盖的真实阻断、旧BIT作废、仅新控件的接受release优先guard及连续K1/K2/长短混合/阈值临界拍验证。旧未修控件父被保护而未回写，不能把其旧按键PASS说成覆盖本次缺陷。

禁止修改、暂存、提交、运行Programmer、下载、SPI Active或Flash；不要发送第二审查或任何外部服务。不得依据有限离线模型冒称512MiB/新增clip区物理认证、实际fps、PVT或暖复位。若发现问题，只报告证据与建议。

输出问题表列：严重程度、文件/位置、问题、证据、影响、建议。最终结论只能为PASS、PASS_WITH_FINDINGS或FAIL。审查后技术字节改变必须补审受影响差异。此提示词不放行硬件，用户返回A结果后由Work另行给指定BIT实物清单。
''')
print('FROZEN_READY',len(manifest),rec(S/'FROZEN_MANIFEST.json')['sha256'],flush=True)
