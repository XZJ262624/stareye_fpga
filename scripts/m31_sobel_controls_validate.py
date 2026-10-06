"""Fail-closed M3.1 artifact acceptance; no hardware activity."""
from pathlib import Path
import json,re,hashlib,sys,xml.etree.ElementTree as ET
from m3_sobel_core_validate import need,sha,check_record,parse_timing,parse_stages,expected_reports,xml_semantic
ROOT=Path(__file__).resolve().parents[1];W=ROOT/'efinity/m31_sobel_controls_i3';R=ROOT/'reports/m31_sobel_controls_i3'
def load(p):return json.loads(p.read_text(encoding='utf-8-sig'))
def reports():return {x.replace('m3_','m31_') for x in expected_reports()}|{f'm31_key{k}_{t}.rpt' for k in range(2) for t in ('setup','hold')}
def collect():
 return {'build':load(R/'build/result.json'),'before':load(R/'build/input_before.json'),'after':load(R/'build/input_after.json'),'audit':load(R/'final_audit/binding.json'),'sim':load(R/'sim/binding.json')}
def parse_coverage(text):
 counts={}
 for key in ('no_clock','unconstrained_internal_endpoints','multiple_clock','no_input_delay','no_output_delay'):
  values=re.findall(r'checking '+key+r' \((\d+)\)',text);need(len(values)==2 and len(set(values))==1,'coverage missing/inconsistent '+key);counts[key]=int(values[0])
 for key in ('no_clock','unconstrained_internal_endpoints','multiple_clock'):need(counts[key]==0,'unconstrained internal '+key)
 need(counts['no_input_delay']==7,'expected five old asynchronous inputs and two keys')
 need(counts['no_output_delay']==135,'only unused lcd_de output removed')
 return counts

def validate(b=None,immutable=True):
 b=collect() if b is None else b;build=b['build'];a=b['audit'];sim=b['sim']
 need(build['exit_code']==0,'build exit')
 need(a['exit_code']==0 and a['original_unchanged'] and a['original_before']==a['original_after'],'audit exit/immutability')
 need(sim['source_before']==sim['source_after'],'sim source changed')
 need(len(sim['commands'])>=5 and all(x['exit_code']==0 for x in sim['commands']),'sim exit')
 need(sim['osd_checked_pixels']==765952 and sim['all_raster_pixels']==1638400 and sim['link_frames']==9 and sim['link_checked_cycles']>60000,'simulation counts')
 before={x['path']:x for x in b['before']};after={x['path']:x for x in b['after']};need(before.keys()==after.keys(),'input set')
 project='efinity/m31_sobel_controls_i3/Ti60_Demo.xml'
 need(all(before[k]==after[k] for k in before if k!=project),'changed build input')
 need(sha(R/'build/project_before.xml')==before[project]['sha256'] and sha(R/'build/project_after.xml')==after[project]['sha256'],'XML binding')
 need(xml_semantic(R/'build/project_before.xml')==xml_semantic(R/'build/project_after.xml'),'XML semantics')
 for row in list(after.values())+build['outputs']+sim['source_after']+sim['artifacts']:check_record(ROOT,row)
 current={p.relative_to(ROOT).as_posix() for base in (W,ROOT/'rtl/m31_sobel_controls',ROOT/'rtl/m3_sobel_core') for p in base.rglob('*') if p.is_file() and p.name!='.lock' and not any(x in ('outflow','work_syn','work_pnr','work_pt','ipm','work','cache') for x in p.relative_to(base).parts)}
 need(current==set(after),'unbound build input')
 stages=parse_stages((R/'build/compile.log').read_text(errors='replace'))
 need({x['path'] for x in a['reports']}==reports(),'report set')
 need({p.name for p in (R/'final_audit').glob('m31_*.rpt')}==reports(),'report directory set')
 need(sha(ROOT/'scripts/m31_sobel_controls_audit.tcl')==a['tcl_sha256'],'audit Tcl hash')
 need(sha(R/'final_audit/audit.log')==a['audit_log_sha256'],'audit log hash')
 need(sha(W/'Ti60_Demo_I3.sdc')==a['sdc_sha256'],'SDC hash')
 log=(R/'final_audit/audit.log').read_text(errors='replace')
 need('ACTUAL_TIMING_MODEL I3' in log and 'M31_AUDIT_COMPLETE' in log and 'M31_KEY_SYNCHRONIZER lane=0' in log and 'M31_KEY_SYNCHRONIZER lane=1' in log and not re.search(r'\b(ERROR|FATAL)\b',log),'audit completion')
 clone=Path(a['clone'])
 for name,row in a['original_after'].items():
  check_record(W,dict(path=name,bytes=row['bytes'],sha256=row['sha256']))
  need(a['clone_initial_hashes'][name]==row['sha256'],'clone binding')
 for name in ('outflow/Ti60_Demo.bit','outflow/Ti60_Demo.lpf','work_pnr/Ti60_Demo.lbf'):need(sha(W/name)==sha(clone/name),'final DB clone changed')
 timing={}
 for row in a['reports']:
  check_record(R/'final_audit',row);name=row['path'];text=(R/'final_audit'/name).read_text()
  if name in ('m31_clocks.rpt','m31_check_timing.rpt'):continue
  p=parse_timing(text,'hold' if name.endswith('_hold.rpt') else 'setup')
  if name.startswith('m31_hdmi_'):need(p['ends']=={f'hdmi_txd{c}_o[{i}]' for c in range(3) for i in range(10)},'HDMI lanes')
  if name.startswith('m31_key'):
   lane=int(name[len('m31_key')]);need(p['starts']=={f'u_controls/key_meta[{lane}]~FF|CLK'} and p['ends']=={f'u_controls/key_sync[{lane}]~FF|D'},'key sync endpoints')
  if name.startswith('m31_ddr_lane_'):
   m=re.fullmatch(r'm31_ddr_lane_(hi|lo)_(\d+)_(setup|hold)\.rpt',name);need(p['starts']=={f'i_dq_{m[1]}[{m[2]}]'},'DDR input lane')
  timing[name]={'minimum_ns':p['minimum_ns'],'paths':p['paths']}
 coverage=parse_coverage((R/'final_audit/m31_check_timing.rpt').read_text())
 # Exact allowed pin-interface changes; all other interface nodes unchanged.
 def peri(path):
  tree=ET.parse(path).getroot();tree.attrib.pop('last_change_date',None)
  return tree
 old=peri(ROOT/'efinity/m3_sobel_core_i3/Ti60_Demo.peri.xml');new=peri(W/'Ti60_Demo.peri.xml');ns={'p':'http://www.efinixinc.com/peri_design_db'}
 og=old.find('p:gpio_info',ns);ng=new.find('p:gpio_info',ns)
 removed={'lcd_de_o','lcd_pclk_o'};added={'key_n','key_n[0]','key_n[1]'}
 for el in list(og):
  if el.get('name') in removed:og.remove(el)
 for el in list(ng):
  if el.get('name') in added:
   if el.get('name')!='key_n':need(el.get('mode')=='input' and el.get('io_standard')=='1.8 V LVCMOS','key electrical mode')
   ng.remove(el)
 def normalize(el):el.text=None;el.tail=None;[normalize(c) for c in el]
 normalize(old);normalize(new);need(ET.tostring(old)==ET.tostring(new),'unexpected peripheral change')
 top=(W/'example_top.v').read_text();need(all(s in top for s in ('.vid_pVSync\t\t(osd_vs)','.vid_pHSync\t\t(osd_hs)','.vid_pVDE\t\t(osd_de)','{3{osd_gray}}')),'HDMI integration')
 preserved=0
 if immutable:
  for row in load(R/'BASELINE_IMMUTABLE.json')['files']:
   check_record(ROOT,row);preserved+=1
 resources=(W/'outflow/Ti60_Demo.place.rpt').read_text();res={k:int(re.search(label+r': (\d+) /',resources)[1]) for k,label in [('xlr','XLRs'),('ram10','Memory Blocks'),('dsp','DSP Blocks')]}
 need(res['ram10']==50 and res['dsp']==0,'RAM/DSP changed')
 bit=W/'outflow/Ti60_Demo.bit'
 return {'status':'PASS_OFFLINE_ONLY','hardware':'NOT_TESTED_NO_DOWNLOAD_NO_FLASH','stages':stages,'coverage':coverage,'timing':timing,'resources':res,'immutable_files':preserved,'simulation':{k:sim[k] for k in ('link_frames','link_checked_cycles','osd_checked_pixels','all_raster_pixels')},'bitstream':{'path':bit.relative_to(ROOT).as_posix(),'bytes':bit.stat().st_size,'sha256':sha(bit)}}
if __name__=='__main__':
 try:
  result=validate(load(Path(sys.argv[2]))) if len(sys.argv)==3 and sys.argv[1]=='--bundle' else validate();(R/'ACCEPTANCE.json').write_text(json.dumps(result,indent=2));print('M31_ACCEPTANCE_PASS',json.dumps({k:v for k,v in result.items() if k!='timing'}))
 except Exception as e:print('M31_ACCEPTANCE_FAIL',str(e));sys.exit(1)
