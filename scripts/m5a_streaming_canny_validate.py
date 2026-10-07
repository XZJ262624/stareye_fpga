"""Fail-closed M5A simulation, implementation, final STA and protection gate."""
from pathlib import Path
import collections,hashlib,json,re,sys,xml.etree.ElementTree as ET
from m3_sobel_core_validate import need,sha,check_record,parse_timing,parse_stages,expected_reports
ROOT=Path(__file__).resolve().parents[1];R=ROOT/'reports/m5a_streaming_canny_i3';V='m5a_streaming_canny_i3';W=ROOT/'efinity'/V
def load(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def collect():return dict(sim=load(R/'sim/all_binding.json'),supplement=load(R/'supplement/binding.json'),build=load(R/V/'build/result.json'),before=load(R/V/'build/input_before.json'),after=load(R/V/'build/input_after.json'),audit=load(R/V/'final_audit/binding.json'))
def canonical(p):
 e=ET.parse(p).getroot()
 for k in list(e.attrib):
  if k not in ('name','description','sw_version'):e.attrib.pop(k)
 return ET.tostring(e)
def validate(bundle=None):
 b=collect() if bundle is None else bundle
 for suite in ('sim','supplement'):
  s=b[suite];need(s['status']=='PASS' and s['sources_before']==s['sources_after'],'sim status/source')
  need(len(s['commands'])>=3 and all(c['exit_code']==0 for c in s['commands']),'simulation commands/execution')
  for row in s['sources_after']:check_record(ROOT,row)
  for c in s['commands']:
   check_record(ROOT,c['log']);log=(ROOT/c['log']['path']).read_text(errors='replace')
   need(not re.search(r'\*\* (Error|Fatal):',log),'sim fatal/error')
   if 'vsim' in Path(c['command'][0]).name:need('Loading work.tb_m5a_' in log and re.search(r'M5A_\w+_PASS',log),'simulation never ran')
  for c in s['cases']:
   for row in c.get('inputs',[]):check_record(ROOT,row)
   if 'artifact' in c:check_record(ROOT,c['artifact'])
 cases={x['name']:x for x in b['sim']['cases']}
 need(set(cases)=={'tb_m5a_units','tb_m5a_windows','tb_m5a_controls','tb_m5a_realtime','tb_m5a_osd','small','stall','720p'},'simulation case set')
 need(cases['720p']['frames']==2 and cases['720p']['pixels']==1843200 and cases['720p']['legacy_regression']==[1843200]*4 and cases['720p']['latency']==6626 and cases['720p']['canny_pixels']>0,'720p coverage/latency/legacy')
 need(cases['small']['frames']==26 and cases['small']['pixels']==299520 and cases['small']['legacy_regression']==[299520]*4,'small frame coverage')
 need(cases['stall']['frames']==4 and cases['stall']['pixels']==46080 and cases['stall']['stalls']>12000,'CE pause coverage')
 need('directions=4194304 exact_ties=61 classifications=1048576 thresholds=256' in cases['tb_m5a_units']['summary'],'direction/classification exhaustiveness')
 need(cases['tb_m5a_osd']['font_pixels_checked']>760000,'OSD gold coverage')
 need(set(x['name'] for x in b['supplement']['cases'])=={'tb_m5a_recovery','tb_m5a_hdmi_channels'},'recovery/HDMI missing')
 build=b['build'];before={x['path']:x for x in b['before']};after={x['path']:x for x in b['after']};project='efinity/'+V+'/Ti60_Demo.xml';r=R/V
 need(build['exit_code']==0,'build exit');need(before.keys()==after.keys(),'input set');need(all(before[k]==after[k] for k in before if k!=project),'build input changed')
 need(sha(r/'build/project_before.xml')==before[project]['sha256'] and sha(r/'build/project_after.xml')==after[project]['sha256'],'project snapshots')
 need(canonical(r/'build/project_before.xml')==canonical(r/'build/project_after.xml'),'project semantics changed')
 current={p.relative_to(ROOT).as_posix() for base in (W,ROOT/'rtl/m5a_streaming_canny') for p in base.rglob('*') if p.is_file() and p.name!='.lock' and not any(x in ('outflow','work_syn','work_pnr','work_pt','work','ipm','cache') for x in p.relative_to(base).parts)}
 need(current==set(after),'unbound build input')
 for row in list(after.values())+build['outputs']:check_record(ROOT,row)
 stages=parse_stages((r/'build/compile.log').read_text())
 root=ET.parse(W/'Ti60_Demo.xml').getroot();ns={'e':'http://www.efinixinc.com/enf_proj'}
 need([root.find('e:device_info/e:'+tag,ns).get('name') for tag in ('family','device','timing_model')]==['Titanium','Ti60F225','I3'],'device')
 need(root.find(".//e:dynparam[@name='M5A_FILTER_ENABLE']",ns).get('value')=='1','default median parameter')
 top=(W/'example_top.v').read_text();need('M5A_FILTER_ENABLE=1, parameter SIM_DATA=0' in top and top.count(".ce(1'b1)")==3,'top default/CE')
 a=b['audit'];need(a['exit_code']==0 and a['original_unchanged'] and a['original_before']==a['original_after'],'audit exit/immutable')
 names={n.replace('m3_','m5a_') for n in expected_reports()}|{f'm5a_key{k}_{kind}.rpt' for k in (0,1) for kind in ('setup','hold')}
 need(len(a['reports'])==94 and {x['path'] for x in a['reports']}==names and {p.name for p in (r/'final_audit').glob('m5a_*.rpt')}==names,'94 final STA reports')
 need(sha(ROOT/'scripts/m5a_streaming_canny_audit.tcl')==a['tcl_sha256'] and sha(W/'Ti60_Demo_I3.sdc')==a['sdc_sha256'],'SDC/Tcl binding')
 need(sha(r/'final_audit/audit.log')==a['audit_log_sha256'],'audit log binding')
 log=(r/'final_audit/audit.log').read_text();need('ACTUAL_TIMING_MODEL I3' in log and 'M5A_AUDIT_COMPLETE' in log and not re.search(r'\b(ERROR|FATAL)\b',log),'audit execution')
 for path,row in a['original_after'].items():
  check_record(W,dict(path=path,bytes=row['bytes'],sha256=row['sha256']));need(a['clone_initial_hashes'][path]==row['sha256'],'clone initial binding')
 for path in ('outflow/Ti60_Demo.bit','outflow/Ti60_Demo.lpf','work_pnr/Ti60_Demo.lbf'):need(sha(W/path)==sha(Path(a['clone'])/path),'final database/bit mismatch')
 timings={}
 for row in a['reports']:
  check_record(r/'final_audit',row);n=row['path'];text=(r/'final_audit'/n).read_text()
  if n in ('m5a_check_timing.rpt','m5a_clocks.rpt'):continue
  t=parse_timing(text,'hold' if n.endswith('_hold.rpt') else 'setup')
  if n.startswith('m5a_hdmi_'):need(t['ends']=={f'hdmi_txd{c}_o[{i}]' for c in range(3) for i in range(10)},'HDMI endpoints')
  if n.startswith('m5a_ddr_lane_'):
   m=re.fullmatch(r'm5a_ddr_lane_(hi|lo)_(\d+)_(setup|hold)\.rpt',n);need(t['starts']=={f'i_dq_{m[1]}[{m[2]}]'},'DDR lane start')
  if n.startswith('m5a_key'):
   k=int(n[len('m5a_key')]);need(t['starts']=={f'u_controls/key_meta[{k}]~FF|CLK'} and t['ends']=={f'u_controls/key_sync[{k}]~FF|D'},'key CDC endpoints')
  timings[n]=dict(minimum_ns=t['minimum_ns'],paths=t['paths'])
 cover=dict(no_clock=0,unconstrained_internal_endpoints=0,multiple_clock=0,no_input_delay=7,no_output_delay=135)
 text=(r/'final_audit/m5a_check_timing.rpt').read_text()
 for k,v in cover.items():need(re.findall(r'checking '+k+r' \((\d+)\)',text)==[str(v)]*2,'coverage '+k)
 need(re.search(r'^clk_pixel\s+13\.441\s+74\.399\s', (r/'final_audit/m5a_clocks.rpt').read_text(),re.M),'pixel SDC clock period')
 mapped=(W/'outflow/Ti60_Demo.map.v').read_text();ram=re.findall(r'^    EFX_RAM10\s+(\\[^\s]+)',mapped,re.M)
 groups={name:[c for c in ram if tag in c] for name,tag in [('median','/u_median/u_lines/'),('sobel','/u_sobel/u_lines/'),('median_packet','/u_packet/'),('base_packet','/u_display_packet/'),('nms_rows','/u_nms/u_window/'),('nms_packet','/u_nms_packet/'),('local_rows','/u_hysteresis/u_window/'),('final_packet','/u_final_packet/')]}
 need({k:len(v) for k,v in groups.items()}==dict(median=4,sobel=4,median_packet=5,base_packet=12,nms_rows=6,nms_packet=12,local_rows=2,final_packet=14),'actual row/packet RAM mapping')
 text=(W/'outflow/Ti60_Demo.place.rpt').read_text();resources={k:int(re.search(label+r': (\d+)',text).group(1)) for k,label in [('xlr','XLRs'),('ram','Memory Blocks'),('dsp','DSP Blocks')]}
 need(resources['dsp']==0 and resources['ram']==len(ram)==105 and resources['xlr']<12000,'resource realization')
 baseline=load(R/'M4_COMMITTED_COPY.json')
 for row in baseline['files']:
  if Path(row['path']).name not in ('example_top.v','Ti60_Demo.xml'):check_record(ROOT,row)
 protected=load(R/'PROTECTED_BASELINES_BEFORE.json')
 for row in protected['files']:check_record(ROOT,row);need((ROOT/row['path']).stat().st_mtime_ns==row['mtime_ns'],'protected mtime '+row['path'])
 transient_missing=[]
 for row in protected['locked_unreadable']:
  p=ROOT/row['path']
  if not p.exists() and row==dict(path='efinity/m4_color_overlay_i3/.lock',bytes=7,mtime_ns=1791291832336137000):
   observation=load(R/'TRANSIENT_LOCK_OBSERVATION.json')['observations'];need(any(x['before']==row and x['after']==dict(path=row['path'],exists=False) for x in observation),'unrecorded transient lock exception');transient_missing.append(row['path'])
  else:need(p.is_file() and p.stat().st_size==row['bytes'] and p.stat().st_mtime_ns==row['mtime_ns'],'locked metadata '+row['path'])
 original={x['path'] for x in protected['files']+protected['locked_unreadable']};current={p.relative_to(ROOT).as_posix() for d in protected['bases'] for p in (ROOT/d).rglob('*') if p.is_file()};need(original-current==set(transient_missing) and not current-original,'protected file set')
 warnings=load(R/'WARNING_REVIEW.json');need(warnings['m5a_sha256']==sha(W/'outflow/Ti60_Demo.map.out') and not warnings['normalized_added'] and not warnings['new_canny_source_warnings'],'unexplained new Canny warnings')
 bit=W/'outflow/Ti60_Demo.bit'
 return dict(verdict='PASS_OFFLINE_HARDWARE_PENDING',stages=stages,timing=timings,coverage=cover,resources=resources,ram_groups=groups,bit=dict(path=str(bit),bytes=bit.stat().st_size,sha256=sha(bit)),simulation=b['sim']['cases']+b['supplement']['cases'],protected_files=len(protected['files']),metadata_only=protected['locked_unreadable'],transient_missing=transient_missing,warning_details=warnings['m5a_detail_records'])
if __name__=='__main__':
 try:
  bundle=load(Path(sys.argv[2])) if len(sys.argv)==3 and sys.argv[1]=='--bundle' else None
  result=validate(bundle)
  if bundle is None:(R/'ACCEPTANCE.json').write_text(json.dumps(result,indent=2))
  print('M5A_ACCEPTANCE_PASS')
 except Exception as e:print('M5A_ACCEPTANCE_FAIL',str(e));sys.exit(1)
