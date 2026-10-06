"""Fail-closed binding/STA acceptance for both new M32 variants; no hardware."""
from pathlib import Path
import json,re,sys,xml.etree.ElementTree as ET,hashlib,collections
from m3_sobel_core_validate import need,sha,check_record,parse_timing,parse_stages,expected_reports
ROOT=Path(__file__).resolve().parents[1];R=ROOT/'reports/m4_color_overlay_i3';V=('m4_color_overlay_i3',)
def load(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def collect():
 return dict(sim=load(R/'sim/binding.json'),variants={v:dict(build=load(R/v/'build/result.json'),before=load(R/v/'build/input_before.json'),after=load(R/v/'build/input_after.json'),audit=load(R/v/'final_audit/binding.json')) for v in V})
def canonical(p):
 e=ET.parse(p).getroot()
 for k in list(e.attrib):
  if k not in ('name','description','sw_version'):e.attrib.pop(k)
 return ET.tostring(e)
def coverage(text):
 expected=dict(no_clock=0,unconstrained_internal_endpoints=0,multiple_clock=0,no_input_delay=7,no_output_delay=135)
 need('Version: 2025.1.110.5.9' in text,'coverage tool')
 for k,v in expected.items():need(re.findall(r'checking '+k+r' \((\d+)\)',text)==[str(v)]*2,'coverage '+k)
 return expected

def validate(bundle=None):
 b=collect() if bundle is None else bundle;sim=b['sim'];need(set(b['variants'])==set(V),'variant set')
 need(sim['status']=='PASS' and sim['sources_before']==sim['sources_after'],'sim status/source')
 need(9<=len(sim['commands'])<=10 and all(c['exit_code']==0 for c in sim['commands']),'sim commands/execution')
 for row in sim['sources_after']:check_record(ROOT,row)
 for c in sim['commands']:check_record(ROOT,c['log'])
 for c in sim['cases']:
  if 'generated_inputs' in c:
   for row in c['generated_inputs']:check_record(ROOT,row)
  if 'artifact' in c:check_record(ROOT,c['artifact'])
 cases={x['name']:x for x in sim['cases']}
 need(set(cases)=={'tb_m4_controls','tb_m4_realtime','tb_m4_colorize','tb_m4_osd','tb_m4_recovery','tb_m4_hdmi_channels','small','720p'},'sim case set')
 need(cases['720p']['frames']==4 and cases['720p']['pixels']==3686400 and cases['720p']['legacy_regression']==[921600]*3 and cases['720p']['latency']==3318,'720p completion/regression/latency')
 need(cases['small']['frames']==31 and cases['small']['pixels']==198400 and all(x>0 for x in cases['small']['legacy_regression']),'small modes/borders/thresholds')
 need(cases['tb_m4_osd']['font_pixels_checked']==765952,'256 threshold/font oracle')
 for name,marker in [('tb_m4_controls','M4_CONTROLS_PASS checks=28'),('tb_m4_realtime','M4_REALTIME_PASS debounce_cycles=1488000'),('tb_m4_colorize','M4_COLORIZE_PASS checks=8192'),('tb_m4_osd','M4_OSD_PASS pixels=1638400 thresholds=256'),('tb_m4_recovery','M4_RECOVERY_PASS'),('tb_m4_hdmi_channels','M4_HDMI_CHANNELS_PASS checks=1024 order=B,G,R'),('small','M4_STREAM_PASS'),('720p','M4_STREAM_PASS cycles=4953326 frames=4 pixels=3686400')]:
  log=(R/'sim'/(name+'.log')).read_text(errors='replace');need(marker in log and not re.search(r'\*\* (Fatal|Error):',log),'missing actual HDL completion '+name)
 summary={}
 names={s.replace('m3_','m4_') for s in expected_reports()}|{f'm4_key{k}_{kind}.rpt' for k in range(2) for kind in ('setup','hold')}
 for v in V:
  w=ROOT/'efinity'/v;r=R/v;a=b['variants'][v]['audit'];build=b['variants'][v]['build'];before={x['path']:x for x in b['variants'][v]['before']};after={x['path']:x for x in b['variants'][v]['after']};project='efinity/'+v+'/Ti60_Demo.xml'
  need(build['exit_code']==0,'build exit '+v);need(before.keys()==after.keys(),'input set');need(all(before[k]==after[k] for k in before if k!=project),'build input modified')
  need(sha(r/'build/project_before.xml')==before[project]['sha256'] and sha(r/'build/project_after.xml')==after[project]['sha256'],'project snapshots')
  need(canonical(r/'build/project_before.xml')==canonical(r/'build/project_after.xml'),'build project semantics')
  current={p.relative_to(ROOT).as_posix() for base in (w,ROOT/'rtl/m3_sobel_core',ROOT/'rtl/m4_color_overlay',ROOT/'rtl/m32_median_integration') for p in base.rglob('*') if p.is_file() and p.name!='.lock' and not any(x in ('outflow','work_syn','work_pnr','work_pt','work','ipm','cache') for x in p.relative_to(base).parts)};need(current==set(after),'unbound input')
  for row in list(after.values())+build['outputs']:check_record(ROOT,row)
  root=ET.parse(w/'Ti60_Demo.xml').getroot();ns={'e':'http://www.efinixinc.com/enf_proj'}
  need(root.find('e:device_info/e:family',ns).get('name')=='Titanium' and root.find('e:device_info/e:device',ns).get('name')=='Ti60F225' and root.find('e:device_info/e:timing_model',ns).get('name')=='I3','target')
  top=(w/'example_top.v').read_text();need('M4_FILTER_ENABLE=1, parameter SIM_DATA=0' in top and '.filter_request(M4_FILTER_ENABLE!=0)' in top,'default filter source')
  need(root.find(".//e:dynparam[@name='M4_FILTER_ENABLE']",ns).get('value')=='1' and "compiling module 'example_top'" in (w/'outflow/Ti60_Demo.map.out').read_text(),'enabled synthesis configuration/default')
  need(a['exit_code']==0 and a['original_unchanged'] and a['original_before']==a['original_after'],'audit immutable/exit')
  need(len(a['reports'])==94 and {x['path'] for x in a['reports']}==names and {x.name for x in (r/'final_audit').glob('m4_*.rpt')}==names,'94 report set')
  need(sha(ROOT/'scripts/m4_color_overlay_audit.tcl')==a['tcl_sha256'] and sha(w/'Ti60_Demo_I3.sdc')==a['sdc_sha256'],'audit SDC/Tcl')
  need(sha(r/'final_audit/audit.log')==a['audit_log_sha256'],'audit log hash');log=(r/'final_audit/audit.log').read_text();need('ACTUAL_TIMING_MODEL I3' in log and 'M4_AUDIT_COMPLETE' in log and not re.search(r'\b(ERROR|FATAL)\b',log),'audit completion')
  clone=Path(a['clone'])
  for name,row in a['original_after'].items():
   check_record(w,dict(path=name,bytes=row['bytes'],sha256=row['sha256']));need(a['clone_initial_hashes'][name]==row['sha256'],'clone initial binding')
  for path in ('outflow/Ti60_Demo.bit','outflow/Ti60_Demo.lpf','work_pnr/Ti60_Demo.lbf'):need(sha(w/path)==sha(clone/path),'final implementation clone mismatch')
  timings={}
  for row in a['reports']:
   check_record(r/'final_audit',row);name=row['path'];text=(r/'final_audit'/name).read_text()
   if name in ('m4_check_timing.rpt','m4_clocks.rpt'):continue
   t=parse_timing(text,'hold' if name.endswith('_hold.rpt') else 'setup')
   if name.startswith('m4_hdmi_'):need(t['ends']=={f'hdmi_txd{c}_o[{i}]' for c in range(3) for i in range(10)},'HDMI endpoints')
   if name.startswith('m4_key'):
    k=int(name[len('m4_key')]);need(t['starts']=={f'u_controls/key_meta[{k}]~FF|CLK'} and t['ends']=={f'u_controls/key_sync[{k}]~FF|D'},'key synchronizer')
   timings[name]=dict(minimum_ns=t['minimum_ns'],paths=t['paths'])
  cover=coverage((r/'final_audit/m4_check_timing.rpt').read_text());stages=parse_stages((r/'build/compile.log').read_text())
  mapped=(w/'outflow/Ti60_Demo.map.v').read_text();ram=re.findall(r'^    EFX_RAM10\s+(\\[^\s]+)',mapped,re.M);median=[c for c in ram if '/u_median/u_lines/' in c];packet=[c for c in ram if '/u_packet/' in c];need(len(median)==4 and len(packet)==5,'actual median/packet RAM mapping')
  need(len([c for c in ram if '/u_display_packet/' in c])==11,'new display row RAM mapping')
  resource=(w/'outflow/Ti60_Demo.place.rpt').read_text();xlr=int(re.search(r'XLRs: (\d+)',resource).group(1));blocks=int(re.search(r'Memory Blocks: (\d+)',resource).group(1));dsp=int(re.search(r'DSP Blocks: (\d+)',resource).group(1));need(blocks==70 and dsp==0 and xlr<10000,'resource mapping')
  bit=w/'outflow/Ti60_Demo.bit';summary[v]=dict(stages=stages,coverage=cover,timing=timings,resources=dict(xlr=xlr,ram=blocks,dsp=dsp,median_ram=median,packet_ram=packet,display_ram=[c for c in ram if '/u_display_packet/' in c]),bit=dict(path=str(bit),bytes=bit.stat().st_size,sha256=sha(bit)))
 # Entire pre-existing engineering/testing scope is content and metadata protected.
 protected=load(R/'PROTECTED_BASELINES_BEFORE.json')
 for row in protected['files']:
  check_record(ROOT,row);need((ROOT/row['path']).stat().st_mtime_ns==row['mtime_ns'],'protected mtime '+row['path'])
 for row in protected['locked_unreadable']:
  p=ROOT/row['path'];need(p.is_file() and p.stat().st_size==row['bytes'] and p.stat().st_mtime_ns==row['mtime_ns'],'locked metadata '+row['path'])
 return dict(verdict='PASS_OFFLINE',hardware='NOT_TESTED_NO_DOWNLOAD_NO_FLASH',variants=summary,simulation=sim['cases'],protected_files=len(protected['files']),metadata_only=protected['locked_unreadable'])
if __name__=='__main__':
 try:
  bundle=load(Path(sys.argv[2])) if len(sys.argv)==3 and sys.argv[1]=='--bundle' else None
  result=validate(bundle)
  if bundle is None:(R/'ACCEPTANCE.json').write_text(json.dumps(result,indent=2))
  print('M4_ACCEPTANCE_PASS')
 except Exception as e:print('M4_ACCEPTANCE_FAIL',str(e));sys.exit(1)
