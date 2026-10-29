from physical_common import *
import shutil,subprocess,difflib
stage=json.loads((O/'STAGE1_RESULT.json').read_text());assert stage['passed'] and not stage['video_pending']
build=json.loads((O/'BUILD_RESULT.json').read_text());assert build['passed']
assert json.loads((O/'NEW_CONFIG_CLOCK_PROOF.json').read_text())['passed']
sources=json.loads((O/'PRODUCTION_MANIFEST.json').read_text());parents=json.loads((O/'PARENT_PRODUCTION_MANIFEST.json').read_text());verify(sources);verify(parents)
def git(*args):return subprocess.check_output(['git','-c','safe.directory='+R.as_posix(),*args],cwd=R,text=True).strip()
head=git('rev-parse','HEAD');parent=git('rev-parse','HEAD^');branch=git('branch','--show-current');assert head=='38d7e42f42ab92f7892072bf18d470445c9d4bd0' and not git('diff','--cached','--name-only')
F=R/build['physical'];B=R/json.loads((O/'ACTIVE_PHYSICAL.json').read_text())['project']
binding=json.loads((F/'BIT_INPUTS.json').read_text());verify(binding['routed_db']);verify(sources);assert rec(R/build['bit']['path'])==build['bit'];assert rec(R/build['native_bit']['path'])==build['native_bit']
for r in sources:
 p=F/'mirror'/r['path']
 if p.name in ('Ti60_Demo.xml','Ti60_Demo.pt.sdc'):continue
 assert rec(p)['sha256']==r['sha256']
save(O/'FINAL_IDENTITY.json',dict(branch=branch,baseline_head=head,baseline_parent=parent,candidate_commit=None,technical_parent='Uncommitted approved open snapshot, not current replay HEAD',technical_parent_manifest=rec(R/'reports/part_count_edge_open_20261027/review_snapshot/MANIFEST.json'),technical_parent_bit=rec(R/'reports/part_count_edge_open_20261027/artifacts/StarEye_CountEdgeOpen.bit'),index_empty=True))
save(O/'REMOVED_GATES_PRESERVED.json',dict(passed=True,unchanged_CCL=rec(R/'rtl/part_count_edge_open/part_open_ccl.sv'),E4=False,E5=False,E9=False,new_image_gates=False,unchanged_closing=rec(R/'rtl/part_count_edge_open/part_open_morph.sv'),qualification='Existing frame/identity/TTL/capacity/geometry and three distinct confirmations unchanged. Live config identity now changes with actually applied threshold.'))
configs=dict(default_high=48,default_low=24,step=8,range=[8,128],low='high >> 1',K1='key_n[0]/N2 decrement once on release; single long also once',K2='key_n[1]/M2 increment once on release; single long also once',BOTH_SHORT='toggle RAW/MSK only',BOTH_LONG='diagnostic rearm only',debounce_cycles=1488000,pixel_clock_hz=74400000,apply='source SOF, same-edge effective bypass',same_edge_release='queued for following source SOF',generation_bits=64,ABA='new generation on each applied change, never threshold value used as generation',saturation='no real change = no generation increment/revoke',LAST='retained across config changes; original epoch-change reset retained',MSK='same production closing3x3 edge mask, not a filled object silhouette',latency='unchanged production pixel pipeline; metadata is attached to the existing adapter tags')
save(O/'FINAL_CONFIGURATION.json',configs)
delta='''# 本轮实际差异（技术父 open；不是回放 HEAD）

|位置|改动|保持/证据|
|---|---|---|
|part_keys_controls|沿用两级同步/释放复位/20ms防抖；释放事件立即发出，移除父SOF单槽出队；事件1/2/3/4分别减/加/view/诊断|单长释放一次；交错双键抑制single；29真实释放事件定向验证|
|part_keys_config（新增）|pending H/view，source SOF原子提交；64bit递增generation与same-edge旁路|H48/L24默认，8..128步8饱和；view/无变化不增代；source-SOF同拍新release下一帧应用|
|part_keys_adapter|原256位tag顶端新增8位H+1位view；原身份/资格/队列逻辑不改|在原source_first入队/原final_first旁路取出，视频链无新延迟|
|part_keys_core|generation从固定1改为配置输入；cfg上下文变化撤旧；移除旧single-view逻辑；诊断rearm映射双长4|原CCL、frameguard和capture直接实例化；诊断记录布局保持，schema为454b5901|
|part_keys_confirm|只有config变化不再清have_value（保LAST）；module重命名|epoch变化仍清LAST；valid/confirmations/matching清理及原三次确认算法保持|
|part_keys_osd|Hxxx/Lxxx动态3位数；MSK名；aligned H/view随帧锁定|原closing白色边缘，不改为实心填充；原图/ROI框/计数/诊断布局保持|
|part_keys_system / new example_top / XML|接真实阈值、配置代、对齐H/view，新模块引用|720p、GAU2、AR0135左右方向、DDR/FIFO/接口/时钟/引脚原样；SDC/periphery/IP逐字同|
|父CCL/morph/frameguard/capture/bankRAM|不复制不修改，直接复用同路径同字节|PRODUCTION_MANIFEST和PARENT_PRODUCTION_MANIFEST逐项SHA；E4/E5/E9保持关闭，无替代图像门|

失败纠正均保留原日志：初次宿主DLL启动限制改为已授权原生执行；新源码十六进制三目空格/提前view声明编译错误纠正；OSD标签49字节被截首字符由软件oracle发现，生产字符串改48字节（断言未改）。OSD极值205557原生已过但收据未包含.mem输入，205625仅修测试runner输入SHA记录后重跑同短测；没有所谓TB路径错误或被放宽的预期。
'''
(O/'DELTA.md').write_text(delta,encoding='utf8')
test_info=[]
for r in stage['tests']:
 v=json.loads((R/r['path']).read_text());verify(v['inputs']);test_info.append(dict(receipt=r,results=v['results']))
save(O/'TEST_SUMMARY.json',dict(passed=True,tests=test_info,video=dict(frames=8,pixels=7372800,base_threshold_pixels=7372800,OSD_pixels=6471584,jobs=8,physical_key_gestures=4,sequence=[48,48,48,40,32,40,40,40],generation=[1,1,1,2,3,4,4,4],views=['RAW']*6+['MSK']*2),unit_release_events=29,core_jobs=7,osd_ext_pixels=22176,limitations=['Synthetic pixel fixture; no DDR transaction-level/service-cadence or live camera validation','750000 blank cycles after each source frame to let CCL finish; does not establish physical FPS','No complete historical regression or new CCL algorithm qualification'],failures_preserved=['204856 host DLL launch WinError623; direct authorized native execution resolved','204908 new code syntax (hex ternary spacing and view declaration) fixed before passing tests','205129 OSD49-byte label truncation caught by independent pixel oracle; corrected48-byte RTL label, assertions unchanged','205557 OSD test passed but external .mem input omitted in receipt;205625 rerun binds it explicitly']))
resource=build['resource'];sta=build['STA'];bit=build['bit']
report=f'''# 工业计件按键阈值版：离线交付，待 Work 复核和用户独立 A

branch `{branch}`；基线 HEAD `{head}`，parent `{parent}`。本轮尚未提交，candidate=None。技术父是 open 已审未提交423项快照（manifest3f566c51...），不是当前回放 HEAD。

默认 RAW/H048/L024。板 K1=N2 单独释放减8，K2=M2 加8；H8..128饱和、L=H/2。单长按只在松开调一次；双短只切 RAW/MSK，双长只重装原诊断。生产防抖1488000个74.4MHz像素拍=20ms。MSK为原closing3x3白色边缘，非实心对象。

真实source SOF同时提交阈值及独立64位配置代；同拍旁路保证前端与身份同值，同SOF恰抵达的释放留到下一SOF。adapter标签带对应帧H/view，OSD锁定此标签，未增视频延迟。每次实际变更撤旧CURRENT/确认/在途结果；ABA回调仍新代，边界无变化和view不动计数代。**唯一确认逻辑改动：config变化保留LAST，epoch变化仍清历史。** CCL、morph、frameguard、capture、DDR/FIFO与帧几何直接复用父源，E4/E5/E9不引回。

定向原生PASS：29次释放事件覆盖连续短、两边饱和、上电按住、抖动、单双长、交错双键、CE及SOF；小ROI真CCL7job验证忙中取消、旧tag、ABA、三确认和LAST。真实生产GAU2+局部Canny+closing+adapter+core+OSD8帧720p，共7372800像素、8真实job、4实际按键；H48→40→32→40及双短view，三次确认恢复5。软件独立oracle闭边5673/6693/7705，弱线32/1052/2064；ROI始终5件。前端阈值逐7372800像素、OSD6471584像素比较通过；额外H008/L004与H128/L064两视图22176像素、帧内锁定/CE通过。fixture不含DDR全链，每帧后加750000 blank拍供CCL完成，不据此声明实际吞吐/低照度效果。

fresh `{F.name}`：XLR {resource['XLR']}、RAM10 {resource['RAM']}、DSP {resource['DSP']}。基本normal I3各200条setup/hold最小 {sta['normal']['setup']:+.3f}/{sta['normal']['hold']:+.3f}ns；no_clock/internal_unconstrained/multiple_clock均0，外部未约束输入/输出{sta['counts']['no_input_delay']}/{sta['counts']['no_output_delay']}。19组既有CDC静态逐pin+原生查询及clock correspondence通过，SDC与父逐字同；新配置/adapter/cfg字段均clk_pixel、64位generation实际映射。保留原PLL异步SR、PVT、暖复位和窄hold边界，无全FF/全clockpair扩审。

BIT `{bit['path']}`，{bit['bytes']}字节，SHA256 `{bit['sha256']}`。原生BIT与交付BIT逐字绑定；11类实际数据库（数量以BIT_INPUTS为准）、源与基本STA绑定。

原始失败及日志保留：本机DLL启动限制、初次编译语法/声明、OSD字符串49→48字节纠正、OSD额外输入绑定补正。未改测试断言来获得PASS。开放轮廓仍可能漏计，调低可能增噪，不保证实物收益。未Git暂存/提交/推送，未DeepSeek B，未Programmer/JTAG/Flash；等待Work核定后交用户独立A，再由Work另行指定实物清单。
'''
(O/'BUILD_REPORT.md').write_text(report,encoding='utf8')
scope={R/r['path'] for r in sources}
for folder in ('rtl/part_count_edge_keys','tb/part_count_edge_keys','scripts/part_count_edge_keys'):
 scope.update(p for p in (R/folder).rglob('*') if p.is_file() and '__pycache__' not in p.parts)
# Include concise original receipts/logs and the fresh mapped/routed evidence,
# not simulator libraries, intermediate placement caches or unrelated history.
scope.update(p for p in O.glob('*') if p.is_file() and p.suffix in ('.json','.md','.patch') and p.name not in ('HEARTBEAT.json','PHYSICAL_MANAGER.json','PHYSICAL_PHASE_RESULT.json','REVIEW_SNAPSHOT.json','OFFLINE_DELIVERY_RESULT.json','CODEX_A_REVIEW_PROMPT.md'))
for tests in O.glob('tests_*'):
 scope.update(p for p in tests.glob('*') if p.is_file() and p.name!='NOTIFICATION_STATE.json' and p.suffix in ('.json','.log','.do'))
scope.update(p for p in F.rglob('*') if p.is_file() and p.name!='NOTIFICATION_STATE.json' and 'mirror' not in p.parts and p.suffix in ('.json','.log','.tcl'))
for n in ('Ti60_Demo.map.v','Ti60_Demo.map.rpt','Ti60_Demo.route.rpt','Ti60_Demo.place.rpt','Ti60_Demo.warn.log','Ti60_Demo.interface.csv','Ti60_Demo.pinout.csv','Ti60_Demo.pt.sdc','Ti60_Demo.pt.rpt','part_normal_setup.rpt','part_normal_hold.rpt','part_check.rpt','part_clocks.rpt'):
 scope.add(B/'outflow'/n)
scope.update(R/r['path'] for r in binding['routed_db']);scope.add(R/bit['path']);scope.add(R/build['native_bit']['path']);scope.add(B/'Ti60_Demo.xml');scope.add(B/'Ti60_Demo.pt.sdc');scope.add(B/'part_query.sdc')
S=O/'review_snapshot_v2';assert not S.exists();S.mkdir();records=[]
for p in sorted(scope):
 assert p.is_file(),p
 dst=S/'source'/p.relative_to(R);dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,dst);assert p.read_bytes()==dst.read_bytes();records.append(dict(original=rec(p),snapshot=rec(dst)))
save(S/'MANIFEST.json',dict(schema='uncommitted_source_snapshot_v1',branch=branch,baseline_head=head,baseline_parent=parent,candidate_commit=None,technical_parent_manifest=rec(R/'reports/part_count_edge_open_20261027/review_snapshot/MANIFEST.json'),files=len(records),bytes=sum(r['original']['bytes'] for r in records),records=records))
manifest=rec(S/'MANIFEST.json');save(O/'REVIEW_SNAPSHOT.json',dict(passed=True,manifest=manifest,files=len(records),bytes=sum(r['original']['bytes'] for r in records)))
prompt=f'''你是用户在独立可见对话中委派的 Codex A，只读审查本次工业计件按键阈值独立版，不能由本轮内部Writer/Work替代。

工作目录 F:/Projects/stareye_fpga。branch `{branch}`，基线 HEAD `{head}`，parent `{parent}`。**尚未提交的固定源码快照，不是candidate commit**。技术父为 `reports/part_count_edge_open_20261027/review_snapshot/MANIFEST.json`，SHA `3f566c51b323be799bc71e67cb3aeed252945471361f025db29b39576d2aca9f`，已审423项；原BIT SHA baa517a0d9cc742e488e4aee2137acc2c3b18992ffb1ff9d36fbf998a7a90f8c。当前HEAD是另一回放任务，不把它称计件技术父。

只读 `reports/part_count_edge_keys_20261028/review_snapshot_v2/MANIFEST.json` 及其 `source` 冻结树。manifest SHA256 `{manifest['sha256']}`，{len(records)}项。先逐项验证SHA与范围；只审该快照相对技术父的实际新增/差异，`SOURCE_DIFF_TECHNICAL_PARENT.patch`和完整源可用；基线HEAD身份另记FINAL_IDENTITY.json。不要审持续变化的工作区。首份review_snapshot因误纳可变watcher状态已废弃，技术源码/BIT/测试不变。

重点：K1减/K2加，默认48/24、步8、8..128饱和、20ms防抖、单长只一次、双短仅RAW/MSK、双长仅诊断；真实source SOF阈值/generation同拍旁路，m5a真实值与adapter/OSD同帧一致、不增视频延迟；64位代避免ABA、忙中撤旧、LAST保留、饱和/view不撤；沿用原CCL/closing及三确认，不引回E4/E5/E9或新的图像门；新字段全部pix域且19已有CDC/SDC维持。

必要证据见BUILD_REPORT.md、TEST_SUMMARY.json、STAGE1_RESULT.json、VIDEO_ORACLE.json、NEW_CONFIG_CLOCK_PROOF.json、BUILD_RESULT.json、BASIC_STA_RESULT.json及对应原生日志。8帧完整720p/7372800像素/8job/4真实按键、29次短门事件与7小ROI真CCLjob、OSD极值22176像素已过。fixture无真实DDR服务，帧后750000空白拍；不是实际fps测试。原失败日志保留。

新BIT `{bit['path']}`，{bit['bytes']}B，SHA `{bit['sha256']}`；fresh资源{resource['XLR']}XLR/{resource['RAM']}RAM10/{resource['DSP']}DSP，basic normal I3 setup/hold {sta['normal']['setup']:+.3f}/{sta['normal']['hold']:+.3f}ns，19组CDC与原生查询通过。PLL SR/PVT/暖复位/外部7输入135输出和窄hold限制保持；开放轮廓仍漏计，阈值降低可能增噪，不保证实物收益。

禁止修改、暂存、提交、推送、运行Programmer、下载、写Flash或调用其他审查者；本轮未交DeepSeek B。问题表列“严重程度、文件/位置、问题、证据、影响、建议”，结论只能PASS/PASS_WITH_FINDINGS/FAIL。A完成前不得读B报告。仅用户反馈后Work才能进入指定BIT实物门。
'''
(O/'CODEX_A_REVIEW_PROMPT.md').write_text(prompt,encoding='utf8')
save(O/'OFFLINE_DELIVERY_RESULT.json',dict(status='PASS_OFFLINE_PENDING_WORK_AND_USER_CODEX_A',passed=True,writer_running=False,candidate_commit=None,branch=branch,baseline_head=head,baseline_parent=parent,bit=bit,snapshot=manifest,review_prompt=rec(O/'CODEX_A_REVIEW_PROMPT.md'),production=rec(O/'PRODUCTION_MANIFEST.json'),tests=rec(O/'TEST_SUMMARY.json'),build=rec(O/'BUILD_RESULT.json'),no_hardware=True,no_git_mutation=True,no_deepseek=True))
print('KEYS_SEALED',len(records),manifest,bit)
