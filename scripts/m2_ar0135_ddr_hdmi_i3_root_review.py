"""Validate the existing final M2 build and STA; never compiles or programs hardware."""
from pathlib import Path
import hashlib,json,re,xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[1]
W=ROOT/'efinity/m2_ar0135_ddr_hdmi_i3'
R=ROOT/'reports/m2_ar0135_ddr_hdmi_i3'
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest().upper()
def record(p): return {'path':p.relative_to(ROOT).as_posix(),'bytes':p.stat().st_size,'sha256':sha(p)}
def validate_record(base,row):
 p=base/row['path']; assert p.stat().st_size==row['bytes'] and sha(p)==row['sha256'].upper(), str(p)
def xml_semantic(p):
 root=ET.parse(p).getroot(); root.attrib.pop('last_change',None)
 return ET.tostring(root,encoding='unicode')
def report(name):
 p=R/'final_audit'/name; text=p.read_text(encoding='utf-8',errors='replace')
 assert '2025.1.110.5.9' in text, name
 values=[float(x) for x in re.findall(r'^Slack\s*:\s*([-+]?\d+\.\d+)',text,re.M)]
 assert values and min(values)>0,(name,values)
 ends=set(re.findall(r'^Path End\s*:\s*(\S+)',text,re.M))
 return {'minimum_ns':min(values),'paths':len(values),'unique_ends':len(ends),'artifact':record(p)},ends
build=json.loads((R/'final_build/build_result.json').read_text()); assert build['exit_code']==0
before=json.loads((R/'final_build/build_input_before.json').read_text())
after=json.loads((R/'final_build/build_input_after.json').read_text())
b={x['path']:x for x in before}; a={x['path']:x for x in after}; assert b.keys()==a.keys()
changed=[k for k in b if b[k]!=a[k]]; assert changed==['Ti60_Demo.xml'],changed
assert xml_semantic(R/'final_build/project_before.xml')==xml_semantic(R/'final_build/project_after.xml')
assert sha(R/'final_build/project_before.xml')==b['Ti60_Demo.xml']['sha256']
assert sha(R/'final_build/project_after.xml')==a['Ti60_Demo.xml']['sha256']
for row in after: validate_record(W,row)
current_inputs={p.relative_to(W).as_posix() for p in W.rglob('*') if p.is_file() and not any(x.startswith('work') or x in ['outflow','ipm'] for x in p.relative_to(W).parts)}
assert current_inputs==set(a),(current_inputs-set(a),set(a)-current_inputs)
root=ET.parse(W/'Ti60_Demo.xml').getroot()
serialized=ET.tostring(root,encoding='unicode')
info={e.tag.rsplit('}',1)[-1]:e.attrib.get('name') for e in root.find('{*}device_info')}
assert info=={'family':'Titanium','device':'Ti60F225','timing_model':'I3'},info
assert 'name="example_top"' in serialized and 'Ti60_Demo_I3.sdc' in serialized
log=(R/'final_build/compile.log').read_text(encoding='utf-8',errors='replace')
stages={k:re.findall(r'^\s*'+k+r'\s*:\s*(PASS|FAIL)',log,re.M) for k in ['map','interface','pnr','pgm']}
assert all(v==['PASS'] for v in stages.values()),stages
for row in build['outputs']: validate_record(W,row)
binding=json.loads((R/'final_audit/binding.json').read_text())
assert binding['exit_code']==0 and binding['original_unchanged'] and binding['original_before']==binding['original_after']
for key,row in binding['original_after'].items():
 p=W/key; assert sha(p)==row['sha256'] and p.stat().st_size==row['bytes'] and p.stat().st_mtime_ns==row['mtime_ns'],key
clone=Path(binding['clone'])
for key in ['work_pnr/Ti60_Demo.lbf','outflow/Ti60_Demo.lpf','outflow/Ti60_Demo.bit']:
 assert sha(W/key)==sha(clone/key),key
assert sha(W/'Ti60_Demo_I3.sdc')==binding['sdc_sha256']==sha(clone/'Ti60_Demo_I3.sdc')
assert sha(ROOT/'scripts/m2_ar0135_ddr_hdmi_i3_audit.tcl')==binding['tcl_sha256']
auditlog=(R/'final_audit/audit.log').read_text(encoding='utf-8',errors='replace')
assert 'M2_AUDIT_COMPLETE' in auditlog and not re.search(r'(^|\n)\s*(ERROR|FATAL)',auditlog)
results={}
for p in sorted((R/'final_audit').glob('m2_*.rpt')):
 if p.name in ['m2_check_timing.rpt','m2_clocks.rpt']:continue
 results[p.name],ends=report(p.name)
 if p.name.startswith('m2_ddr_lane_'):
  m=re.fullmatch(r'm2_ddr_lane_(hi|lo)_(\d+)_(setup|hold)\.rpt',p.name); assert m
  expected_start=f'i_dq_{m[1]}[{m[2]}]'
  assert set(re.findall(r'^Path Begin\s*:\s*(\S+)',p.read_text(),re.M))=={expected_start},p.name
 if p.name.startswith('m2_hdmi_'):
  assert ends=={f'hdmi_txd{c}_o[{i}]' for c in range(3) for i in range(10)}
 if p.name.startswith('m2_ddr_output_'):
  expected={f'addr[{i}]' for i in range(16)}|{f'ba[{i}]' for i in range(3)}|set(['ras','cas','we','cke','odt','cs'])
  expected|={f'o_dq_{kind}[{i}]' for kind in ['hi','lo','oe'] for i in range(16)}
  expected|={f'o_dm_{kind}[{i}]' for kind in ['hi','lo'] for i in range(2)}
  expected|={f'o_dqs{kind}_oe[{i}]' for kind in ['', '_n'] for i in range(2)}
  assert ends==expected,(p.name,ends^expected)
assert {p.name for p in (R/'final_audit').glob('m2_ddr_lane_*.rpt')}=={f'm2_ddr_lane_{half}_{lane}_{kind}.rpt' for half in ['hi','lo'] for lane in range(16) for kind in ['setup','hold']}
check=(R/'final_audit/m2_check_timing.rpt').read_text()
coverage={key:int(re.search(r'checking '+key+r' \((\d+)\)',check).group(1)) for key in ['no_clock','unconstrained_internal_endpoints','multiple_clock','no_input_delay','no_output_delay']}
assert all(coverage[k]==0 for k in ['no_clock','unconstrained_internal_endpoints','multiple_clock'])
assert coverage['no_input_delay']==5
sdc='\n'.join(l for l in (W/'Ti60_Demo_I3.sdc').read_text().splitlines() if l.strip() and not l.lstrip().startswith('#'))
assert '<USER_PERIOD>' not in sdc and 'set_clock_groups' not in sdc
assert sdc.index('create_clock -period 10.000 -name cmos_pclk')<sdc.index('set_input_delay -clock_fall -clock cmos_pclk')
assert 'create_clock -period 10.416 -name clk_sys' in sdc
preserved={}
for label,base in [('original',ROOT/'document/VF-Ti60F225_HDK_V2.1_20251009/07-FPGA_HDL_Image-2023.2/01-1_Ti60_AR0135_HDMI_1280720'),('m0',ROOT/'efinity/m0_led_i3'),('m1',ROOT/'efinity/m1_hdmi_i3')]:
 old=json.loads((R/(label+'_before.json')).read_text()); current={p.relative_to(base).as_posix() for p in base.rglob('*') if p.is_file()}; added=current-set(old); removed=set(old)-current; assert not added and removed<={'.lock'},(label,added,removed)
 readable=0; locked=[]
 for key,row in old.items():
  p=base/key
  if key in removed: continue
  st=p.stat(); assert st.st_size==row['size'] and st.st_mtime_ns==row['mtime_ns'],(label,key)
  if row['sha256']=='UNREADABLE_LOCKED':locked.append(key)
  else: assert sha(p)==row['sha256'].upper(),(label,key);readable+=1
 preserved[label]={'files':len(old),'hashed':readable,'locked_metadata_only':locked,'transient_lock_removed':sorted(removed),'unchanged_except_reported_transient_locks':True}
factory=ROOT/'document/VF-Ti60F225_HDK_V2.1_20251009/07-FPGA_HDL_Image-2023.2/01-1_Ti60_AR0135_HDMI_1280720'
business=[p for p in W.rglob('*.v') if 'ip' not in p.relative_to(W).parts and not any(x.startswith('work') or x=='outflow' for x in p.relative_to(W).parts)]
for p in business: assert sha(p)==sha(factory/p.relative_to(W)),str(p)
def pll_records(path):
 records=[]
 for node in ET.parse(path).getroot().iter():
  if node.tag.rsplit('}',1)[-1]=='pll':
   records.append([(e.tag,{k:v for k,v in e.attrib.items() if k!='conn_type'}) for e in node.iter()])
 return records
assert pll_records(W/'Ti60_Demo.peri.xml')==pll_records(factory/'Ti60_Demo.peri.xml')
for tag in ['gpio_info','iobank_info','lvds_info','mipi_dphy_info']:
 def subtree(path):
  return next(x for x in ET.parse(path).getroot().iter() if x.tag.rsplit('}',1)[-1]==tag)
 assert [(e.tag,e.attrib) for e in subtree(W/'Ti60_Demo.peri.xml').iter()]==[(e.tag,e.attrib) for e in subtree(factory/'Ti60_Demo.peri.xml').iter()],tag
ddr=json.loads((W/'ip/DdrCtrl/settings.json').read_text())['conf']
for k,v in {'row':'15','col':'10','bank':'3','freq':'384','cas_latency':'6','READ_ENABLE_PIPELINE':'7','tREFI':'7800'}.items(): assert str(ddr[k])==v,(k,ddr[k])
assert re.search(r'\.FAMILY\s*\(\s*"TITANIUM"\s*\)',(W/'ip/W0_FIFO_8/W0_FIFO_8.sv').read_text(encoding='utf-8',errors='replace'))
macros=(W/'ip/DdrCtrl/ddr3_controller.vh').read_text()
for key,value in {'DRAM_WIDTH':'16','ROW':'15','COL':'10','BANK':'3','READ_ENABLE_PIPELINE':'7','tRL':'6','tWL':'5','REF_INTERVAL':'2995.2'}.items(): assert re.search(r'^`define '+key+r'\s+'+re.escape(value)+r'$',macros,re.M),(key,value)
warn=(W/'outflow/Ti60_Demo.warn.log').read_text(encoding='utf-8',errors='replace').split('// Efinity Synthesis Started')[-1]
warning_lines=[l for l in warn.splitlines() if '[EFX-' in l]; summary=[l for l in warning_lines if 'Found ' in l and 'warnings' in l]
result={'status':'PASS_OFFLINE_CONSTRAINED_STA_ONLY','build_exit_code':0,'stages':stages,'input_files':len(a),'unchanged_business_rtl_files':len(business),'pll_configuration_unchanged_except_generated_conn_type':True,'gpio_bank_lvds_mipi_configuration_unchanged':True,'ddr_dq_lane_checks':64,'project_change':'last_change attribute only; all remaining XML semantics equal','coverage':coverage,'timing_reports':results,'preserved':preserved,'bitstream':record(W/'outflow/Ti60_Demo.bit'),'databases':[record(W/'work_pnr/Ti60_Demo.lbf'),record(W/'outflow/Ti60_Demo.lpf')],'warning_records_excluding_summary':len(warning_lines)-len(summary),'warning_summary':summary,'hardware_status':'NOT_TESTED_CAMERA_DISCONNECTED_NO_DOWNLOAD_NO_FLASH','evidence_artifacts':[record(p) for d in ['final_build','final_audit'] for p in sorted((R/d).iterdir()) if p.is_file()]}
(R/'root_review.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
print(json.dumps({k:result[k] for k in ['status','build_exit_code','coverage','preserved','bitstream','warning_records_excluding_summary']},ensure_ascii=True))
