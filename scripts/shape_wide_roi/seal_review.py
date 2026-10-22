"""Small uncommitted review snapshot, no staging/commit/remote/hardware."""
from common import *
import shutil,datetime
build=json.loads((O/'BUILD_RESULT.json').read_text());tests=json.loads((O/'TARGETED_TEST_RESULT.json').read_text());assert build['passed'] and tests['passed']
sources=json.loads((O/'SOURCE_MANIFEST.json').read_text());parents=json.loads((O/'PARENT_SOURCE_MANIFEST.json').read_text());verify(sources);verify(parents)
head=subprocess.check_output(['git','-c','safe.directory=F:/Projects/stareye_fpga','rev-parse','HEAD'],cwd=R,text=True).strip();assert head=='9dea12d9f0d29f57aa6d3acb75695da9e0d53d2c'
assert not subprocess.check_output(['git','-c','safe.directory=F:/Projects/stareye_fpga','diff','--cached','--name-only'],cwd=R).strip()
assert not subprocess.check_output(['git','-c','safe.directory=F:/Projects/stareye_fpga','diff','--name-only','HEAD','--','rtl/shape_standalone','efinity/shape_orientation_fix_i3'],cwd=R).strip()
lookup={x['path']:x for x in parents};delta=[];same=0
for x in sources:
 baseline=x['path'].replace('efinity/shape_wide_roi_i3/','efinity/shape_orientation_fix_i3/').replace('rtl/shape_wide_roi/','rtl/shape_standalone/shape/')
 old=lookup[baseline]
 if x['sha256']!=old['sha256']:delta.append(dict(baseline=old,new=x))
 else:same+=1
assert len(delta)==3 and same==88
save(O/'FINAL_DELTA.json',dict(baseline_HEAD=head,baseline_parent='973f6cc2bd997a2f375d1bdb4834ffef8435369c',branch='codex/m5c-fusion-prototype',new_commit=None,changed=delta,unchanged_source_files=same,old_production_diff_empty=True,index_empty=True,meaning='Two new RTL copies + two XML source-path substitutions; child project other source bytes unchanged'))
F=R/build['physical'];B=R/json.loads((O/'ACTIVE_PHYSICAL.json').read_text())['project'];bit=R/build['bit']['path'];assert rec(bit)==build['bit']
resource=build['resource'];sta=build['STA'];report=f'''# 扩大识别区域：快速增量交付

**未提交冻结快照，等待用户独立Codex A审查；尚未放行实物。**

基线HEAD `{head}`，parent `973f6cc2bd997a2f375d1bdb4834ffef8435369c`，branch `codex/m5c-fusion-prototype`。无新candidate、无Git暂存/提交、无DeepSeek B调用、无硬件操作。采用2026-10-22用户授权快速流程：针对性自检/必要构建→A→用户上板→成功再提交，B提交后补审。

## 变更

新工程 `efinity/shape_wide_roi_i3/Ti60_Demo.xml`。ROI为x160..1119/y90..629，即960×540；保留16px边距，允许处理后边缘bbox宽高80..440。新recognizer使用540×26bit行表、10bit局部坐标/行地址，精确518400 ROI像素，帽区碎片计数4bit饱和15。OSD绿色静态框同步扩大。逻辑差异只有两份新RTL和XML的两条模块路径替换，91项源码中其余88项与父版本对应内容一致。

继续完整EOF后分析、原32768拍预算、原中心误差16/圆弦长/矩形/多段拒绝条件。H64默认、GAU、COV/RAW/CNY、PREV、相机C000镜像修正、时钟/管脚/720p、DDR/FIFO/CDC均未改变。没有条纹过滤、CCL/run表、最大轮廓或提前ROI分析。

## 实际验证

- 41项定向RTL覆盖bbox79/80/280/281/384/385/439/440/441、圆/矩形/三角/环/文字/双目标、四侧16px边距、518400精确计数、ROI末行末像素26bit写入、缺失/重复/错坐标、support/config/source/frame失效、CE暂停、reset/SOF/FINISH抢占与恢复。
- h440帽区7行允许、8/14行拒绝；h500域外样本真实16碎片计数饱和15且拒绝，避免旧3bit饱和7在大尺度绕过预算。
- 实测有效440目标分析1826 accepted-CE；定向最大2066（包含域外h500），均小于原32768预算。
- 生产adapter + 新recognizer/OSD的2个完整1280×720光栅及下一SOF，共1843201 active采样、5992新框像素；前帧结果身份和显示、旧框移除、其他像素/OSD及一拍DE/HS/VS、CE保持通过。
- 复用未改上游历史证据。本次没有新完整DDR/DMA/GAU系统72帧回归，2帧定向链不能冒称整系统72通过。
- 一次fresh map/interface/place/route，17组原精确CDC选择器在新map与原生工具中检查，SDC不变；basic I3 normal setup/hold及内部未约束检查通过。没有全6731FF/579metadata/全clock-pair重复审计。

资源：XLR **{resource['XLR']}**、RAM10 **{resource['RAM']}**、DSP **{resource['DSP']}**。normal setup/hold最小 **{sta['normal']['setup']:+.3f}/{sta['normal']['hold']:+.3f} ns**。check_timing计数：`{json.dumps(sta['counts'],ensure_ascii=False)}`。继承6条PLL异步SR未计时、外部7输入/135输出及PVT/warm-reset限制保持，不能把basicSTA写成这些旧边界已关闭。

## BIT与审查

文件：`{build['bit']['path']}`；大小 **{build['bit']['bytes']} bytes**；SHA-256 **`{build['bit']['sha256']}`**。由本次路由DB离线生成，使用efx_run --flow pgm只生成文件，未运行Programmer/--program/下载/Flash。源码/SDC/路由DB/实际日志绑定见BUILD_RESULT.json与BIT_INPUTS.json。

review_snapshot保存本轮完整91项必要编译源码闭包、定向测试/TB/新输入、必要报告/日志和BIT。所有快照项均逐文件size/SHA绑定；不包含Git元数据、工具包或原1.65GB黄金资产重封。快照不是commit，必须按此快照审查，禁止审查持续变化工作区。A通过后仍需Work单独交付指定BIT和实物清单。

## 已知限制与执行失败记录

大框/尺寸扩展没有提升杂纹抗扰：原整ROI轮廓算法仍会因细条纹、背景边、近距越界、明显旋转等UNKNOWN。440是边缘bbox，不是原图名义尺寸；先前新GAU主机模型中名义440变441而拒绝，438变439可过。

首次ModelSim沙箱启动发生Windows DLL重定位错误，改用获准的本机工具执行后正常。OSD第一测试在reset释放前检查正常视频输出，6ns误失败；仅修TB scoreboard启用时机，核心41例不重跑，OSD定向重跑通过。首次静态map解析遗漏剥除Verific块注释，错误只解析出1个cell；仅修Python解析器，原map/interface不重跑，SDC/RTL未改。以上原失败文件保留，不冒称生产故障或隐藏重跑。
'''
(O/'BUILD_REPORT.md').write_text(report,encoding='utf8')
# Bind a compact reproducible scope. The old full-pixel golden archive and
# native work databases are intentionally not copied to the review snapshot.
selected={R/x['path'] for x in sources}
selected.update(p for root in [R/'tb/shape_wide_roi',R/'scripts/shape_wide_roi',O/'test_data'] for p in root.rglob('*') if p.is_file() and '__pycache__' not in p.parts)
selected.add(R/'reports/shape_wider_roi_noise_20261022/assess.py')
for name in ['SOURCE_MANIFEST.json','PARENT_SOURCE_MANIFEST.json','SOURCE_DIFF.patch','DERIVATION.json','FINAL_DELTA.json','TEST_CASES.json','TARGETED_TEST_RESULT.json','BASIC_STA_RESULT.json','BUILD_RESULT.json','BUILD_REPORT.md','STATIC_PARSER_RECOVERY.json','BUILD_EXCEPTION.json']:
 selected.add(O/name)
for folder in sorted(O.glob('targeted_tests*'))+sorted(O.glob('osd_recovery_*')):
 selected.update(p for p in folder.iterdir() if p.is_file() and p.suffix in ('.json','.log','.do'))
for stage in ('map','interface','query','place','route','sta','bitgen'):
 selected.update(p for p in (F/stage).iterdir() if p.is_file() and p.suffix in ('.json','.log'))
for p in [F/'SOURCE_BINDING.json',F/'EXACT_CDC_SELECTOR_STATIC.json',F/'RESOURCE.json',F/'BIT_INPUTS.json',F/'basic_sta.tcl',B/'outflow/Ti60_Demo.map.rpt',B/'outflow/Ti60_Demo.route.rpt',B/'outflow/wide_normal_setup.rpt',B/'outflow/wide_normal_hold.rpt',B/'outflow/wide_check.rpt',B/'outflow/wide_clocks.rpt',bit]:selected.add(p)
snapshot=O/'review_snapshot';snapshot.mkdir(exist_ok=False);records=[]
for src in sorted(selected):
 assert src.is_file(),src
 dst=snapshot/'source'/src.relative_to(R);dst.parent.mkdir(parents=True,exist_ok=True);dst.write_bytes(src.read_bytes());old=rec(src);new=rec(dst);assert (old['bytes'],old['sha256'])==(new['bytes'],new['sha256']);records.append(dict(original=old,snapshot=new))
manifest=snapshot/'MANIFEST.json';save(manifest,dict(schema='wide_roi_uncommitted_review_v1',baseline_HEAD=head,baseline_parent='973f6cc2bd997a2f375d1bdb4834ffef8435369c',branch='codex/m5c-fusion-prototype',candidate_commit=None,records=records,count=len(records),bytes=sum(x['original']['bytes'] for x in records),bit=build['bit']))
save(O/'REVIEW_SNAPSHOT.json',dict(status='FROZEN_UNCOMMITTED_SNAPSHOT_NOT_A_COMMIT',manifest=rec(manifest),snapshot_root=snapshot.relative_to(R).as_posix(),source_root=(snapshot/'source').relative_to(R).as_posix(),count=len(records),bytes=sum(x['original']['bytes'] for x in records),bit=build['bit'],baseline_HEAD=head,new_commit=None))
prompt=f'''你是用户独立委派的Codex A审查者。请只读审查本次扩大识别ROI的未提交冻结快照；不得修改/暂存/提交/运行Programmer/下载/写Flash，不调用DeepSeek B，不把此快照冒称candidate commit。

仓库 F:/Projects/stareye_fpga，branch codex/m5c-fusion-prototype，基线HEAD {head}，其parent 973f6cc2bd997a2f375d1bdb4834ffef8435369c。最新用户快速流程：针对性自检+BIT→A→用户上板→成功后Git，B提交后补审。

先读 reports/shape_wide_roi_fast_20261022/REVIEW_SNAPSHOT.json，核MANIFEST的SHA `{rec(manifest)['sha256']}`；审查root `{(snapshot/'source').as_posix()}` 中的冻结文件，不审持续变化工作区。MANIFEST逐项原件/快照size/SHA。父Git仅用于读取9dea上下文。

入口冻结BUILD_REPORT.md、FINAL_DELTA.json、SOURCE_DIFF.patch、TARGETED_TEST_RESULT.json、BASIC_STA_RESULT.json、BUILD_RESULT.json，路径在source根下reports/shape_wide_roi_fast_20261022/；工程入口source/efinity/shape_wide_roi_i3/Ti60_Demo.xml。

功能仅960x540 ROI（x160..1119/y90..629）、16px边距、边缘bbox80..440、必要10bit坐标与540×26bit行表、精确518400计数、帽区4bit饱和15、新OSD框。其他分类门/完整EOF后调度/32768预算、adapter/system/GAU/DDR/FIFO/CDC/时钟管脚/720p/C000镜像均保持。不做抗条纹。

重点：位宽/移位乘法上下文、row_q26bit打包/解包、540深度地址与末行NBA、518400计数及四侧16px、h385..440 cap7/8和饱和、分类/身份/资格/CE/SOF失效与PREV、XML唯一module定义、源/SDC/DB与BIT绑定、精确CDC选择器和basicSTA。判断本次小改动的实际阻断；不以未跑旧72帧或未重做全FF资产审计本身作默认失败。

本次41定向例+2帧720p adapter/recognizer/OSD通过，非全DDR/GAU系统回归。资源 {resource['XLR']}/{resource['RAM']}/{resource['DSP']}，normalSTA {sta['normal']['setup']:+.3f}/{sta['normal']['hold']:+.3f}ns。继承PLL SR六条/外部7与135/PVT、杂纹与旋转限制保留。开发者报告的启动/TB/解析器失败原log在快照，技术RTL无后续修补。

BIT {build['bit']['path']}，{build['bit']['bytes']}bytes，SHA256 {build['bit']['sha256']}。仅离线文件，未上板。

问题表必须用“严重程度、文件/位置、问题、证据、影响、建议”；最终结论只能PASS、PASS_WITH_FINDINGS或FAIL。不得把内部开发者自检当独审。本次请将结论返回Work，收到前Work不操作硬件。
'''
(O/'CODEX_A_REVIEW_PROMPT.md').write_text(prompt,encoding='utf8')
verify(sources);verify(parents)
result=dict(status='READY_FOR_WORK_CHECK_AND_USER_CODEX_A',passed=True,running=False,baseline_HEAD=head,baseline_parent='973f6cc2bd997a2f375d1bdb4834ffef8435369c',branch='codex/m5c-fusion-prototype',candidate_commit=None,git_mutated=False,production_parent_unchanged=True,resource=resource,normal_STA=sta['normal'],bit=build['bit'],source_delta=rec(O/'FINAL_DELTA.json'),tests=rec(O/'TARGETED_TEST_RESULT.json'),snapshot=rec(O/'REVIEW_SNAPSHOT.json'),prompt=rec(O/'CODEX_A_REVIEW_PROMPT.md'),report=rec(O/'BUILD_REPORT.md'),hardware_next=False,hardware_eligible=False,DeepSeek_B_called=False,scope='Uncommitted source freeze only; Work reviews now and then stops at user independent A')
save(O/'OFFLINE_DELIVERY_RESULT.json',result);save(O/'HEARTBEAT.json',dict(status='COMPLETE',running=False,phase='READY_FOR_WORK_AND_USER_A',updated_unix=time.time(),native_running=False,hardware_next=False));save(O/'PHASE_RESULT.json',dict(status='READY_FOR_WORK_CHECK_AND_USER_CODEX_A',passed=True,running=False,phase='OFFLINE_DELIVERY_READY',result=rec(O/'OFFLINE_DELIVERY_RESULT.json'),hardware_next=False));print('WIDE_REVIEW_DELIVERY_READY',len(records),build['bit'],flush=True)
