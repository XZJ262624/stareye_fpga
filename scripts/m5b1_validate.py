"""Fail-closed local offline gate; raw build/simulation artifacts stay local."""
from pathlib import Path
import json,hashlib,re,subprocess
from m5b1_uart_decode import selftest
from m5b1_evidence import R,B,O,F,W,P,BUILD,GROUPS,SUITES,CASES,result,same,git,BRANCH
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def load(p):return json.loads(p.read_text())
def metadata_only(before,after):
 old=(BUILD/'project_before.xml').read_bytes();new=(BUILD/'project_after.xml').read_bytes()
 assert new==(W/'Ti60_Demo.xml').read_bytes()
 changes={};restored=new
 for key in ('last_change','last_run_flow'):
  pattern=key.encode()+rb'="([^"]*)"';a=re.findall(pattern,old);b=re.findall(pattern,new)
  assert len(a)==len(b)==1
  if a!=b:
   changes[key]=[a[0].decode(),b[0].decode()];restored=restored.replace(key.encode()+b'="'+b[0]+b'"',key.encode()+b'="'+a[0]+b'"')
 assert restored==old,'Build XML changed beyond the two tool metadata attributes'
 a=next(x for x in before if x['path'].endswith('/Ti60_Demo.xml'));b=next(x for x in after if x['path']==a['path'])
 assert len(old)==a['bytes'] and hashlib.sha256(old).hexdigest()==a['sha256']
 assert len(new)==b['bytes'] and hashlib.sha256(new).hexdigest()==b['sha256']
 d=dict(before=a,after=b,changes=changes,before_copy=rec(BUILD/'project_before.xml'),after_copy=rec(BUILD/'project_after.xml'),exact_inverse_restores_before=True)
 (BUILD/'XML_METADATA_ONLY.json').write_text(json.dumps(d,indent=2));return d

def repair_gates():
 rows={}
 for group,name in SUITES.items():
  p=F/name;v=load(p);assert v['status']=='PASS';same(v['runner'])
  expected={'core':7,'negative':6,'recovery':4}[group];assert len(v['cases'])==expected
  for c in v['cases']:
   same(c['evidence']);result(R/c['evidence']['path'],'EXPECTED_REPRODUCTION' if group=='negative' else 'PASS')
  rows[group]=rec(p)
 for case,name in CASES.items():
  p=O/name/'result.json';v=result(p);text=(R/v['log']['path']).read_text(errors='replace')
  if case.startswith('connection_'):
   assert 'tags_drained=1' in text and 'qualified_during_startup=0 later_faults=0' in text
   if case=='connection_admission':assert 'admission_cover=1111' in text and 'lcd=6451200 tap=6451200 seven_modes=6451200' in text
   if case=='connection_zero':assert re.search(r'zero_descriptors=[1-9]',text)
   if case=='connection_midloss':assert re.search(r'failed_descriptors=[1-9]',text) and re.search(r'post_failure_success=[1-9]',text) and 'published=0' in text
  else:
   limit=960000000 if case=='default_export' else 96000000
   assert 'default_limit='+str(limit) in text and 'bg_extra=0' in text and v['host']['local_cancels']==1 and v['host']['crc_valid_stats']>=1
  rows[case]=rec(p)
 return rows

def main():
 assert git('branch','--show-current').decode().strip()==BRANCH
 assert git('rev-parse','HEAD').decode().strip()==P,'Run before candidate; fixed-candidate verification is in scope --candidate'
 repair=repair_gates()
 scope_negative=result(F/'SCOPE_NEGATIVE.json');assert len(scope_negative['cases'])==5
 assert all(c['rejected']==c['expected_rejection'] for c in scope_negative['cases'])
 repair['real_Git_scope_negative']=rec(F/'SCOPE_NEGATIVE.json')
 tests={}
 for name,directory in GROUPS.items():
  p=F/directory/'results.json';v=result(p)
  for src in v['sources']:assert rec(R/src['path'])==src,src['path']
  tests[name]=dict(status=v['status'],source_files_checked=len(v['sources']),evidence=rec(p))
  for case in v.get('cases',v.get('tests',[])):
   if 'log' in case:assert rec(R/case['log']['path'])==case['log']
 assert len(load(F/GROUPS['system']/'results.json')['cases'])==6
 assert len(set((c['camera_phase_ns'],c['pixel_phase_ns']) for c in load(F/GROUPS['system']/'results.json')['cases']))==6
 assert {c['name'] for c in load(F/'global/results.json')['cases']}=={'small30','720p15','exhaustive','last_pixel','snake642','wall_default','pair_default'}
 assert {c['mode'] for c in load(F/GROUPS['system_faults']/'results.json')['cases']}=={1,2,3,4,5}
 assert len(load(F/'mutations/results.json')['cases'])==10
 BD=BUILD;before=load(BD/'inputs_before.json');after=load(BD/'inputs_after.json');assert len(before)==len(after)==96
 md=metadata_only(before,after);xml=(W/'Ti60_Demo.xml').read_bytes();reconstructed=xml
 for key,(old,new) in md['changes'].items():reconstructed=reconstructed.replace(f'{key}="{new}"'.encode(),f'{key}="{old}"'.encode())
 for a,b in zip(before,after):
  assert a['path']==b['path'] and rec(R/b['path'])==b
  if a!=b:assert a['path']==md['before']['path'] and hashlib.sha256(reconstructed).hexdigest()==a['sha256'] and len(reconstructed)==a['bytes']
 build=load(BD/'result.json');assert build['exit_code']==0 and build['resource_stop'] is None
 for out in build['outputs']:assert rec(R/out['path'])==out,out['path']
 log=(BD/'compile.log').read_text();phases=['map','interface','pnr','pgm','export_bitstream']
 for phase in phases:assert re.search(r'\b'+phase+r'\s*:\s*PASS',log),phase
 sta=load(F/'final_sta/binding.json');assert sta['exit_code']==0 and sta['complete'] and sta['original_unchanged'] and sta['minimum_reported_slack_ns']>=0
 for p,record in sta['original_after'].items():assert {k:rec(W/p)[k] for k in ('bytes','sha256')}==record
 for record in sta['reports']:assert {k:rec(F/'final_sta'/record['path'])[k] for k in ('bytes','sha256')}=={k:record[k] for k in ('bytes','sha256')}
 assert sum(c['paths'] for c in sta['cdc_physical_groups'])==413
 assert all(sta['check_timing'][k]==0 for k in ('no_clock','unconstrained_internal_endpoints','multiple_clock'))
 structural=load(F/'CDC_STRUCTURAL_AUDIT.json');assert not structural['unapproved_crossings'] and not structural['unknown_internal'] and not structural['new_srl']
 assert structural['map']==rec(W/'outflow/Ti60_Demo.map.v')
 manifest=load(F/'CDC_PIN_MANIFEST.json');assert manifest['map_sha256']==structural['map']['sha256'] and manifest['sdc_sha256']==rec(W/'Ti60_Demo_I3.sdc')['sha256']
 assert sum(map(len,manifest['groups'].values()))==940 and len(structural['cross_domain'])==457
 for c in sta['cdc_physical_groups']:
  assert c['max_clock_to_Q_plus_data_ns']<c['budget_ns'] and c['arrival_skew_ns']<c['fastest_source_period_ns']
 place=(W/'outflow/Ti60_Demo.place.rpt').read_text();resource={name:int(re.search(label+r': (\d+) /',place).group(1)) for name,label in [('XLR','XLRs'),('RAM10','Memory Blocks'),('DSP','DSP Blocks')]}
 assert resource['XLR']<=48640 and resource['RAM10']<=204 and resource['DSP']<=128
 static=load(F/'STATIC_AUDIT.json');assert static['status'].startswith('PASS') and not static['protected_changes'] and not static['historical_untracked_missing']
 bit=rec(W/'outflow/Ti60_Demo.bit');receipt=dict(status='PASS_OFFLINE_PENDING_INDEPENDENT_REVIEWS_AND_HARDWARE',required_parent=P,tests=tests,host_decoder=selftest(),build_directory=BUILD.relative_to(O).as_posix(),build_phases=phases,input_count=len(after),XML_metadata_only=md,resource=resource,bitstream=bit,STA_reports=len(sta['reports']),minimum_reported_slack_ns=sta['minimum_reported_slack_ns'],check_timing=sta['check_timing'],physical_CDC=sta['cdc_physical_groups'],protected_tracked=static['protected_tracked'],historical_untracked_preserved=static['historical_untracked'],limits=['Conditional <=384 UI transaction service, not hardware guarantee','Production 64-pair/1-second wall-clock may safely time out; no fps promise','Fail-stop with no synthetic ACK; cold reconfiguration after global fault','No real frame, hardware stability or independent-review PASS claimed'],evidence=[rec(p) for p in [F/'STATIC_AUDIT.json',F/'CDC_STRUCTURAL_AUDIT.json',F/'CDC_PIN_MANIFEST.json',F/'final_sta/binding.json',BUILD/'result.json',BUILD/'inputs_before.json',BUILD/'inputs_after.json']],repair=repair,helper=rec(R/'scripts/m5b1_evidence.py'),validator=rec(Path(__file__)))
 receipt['limits'] += ['Protocol-watchdog emergency_stop withdraws stalled VALID; this is an explicit irreversible isolation limitation, not universal AXI VALID compliance','Default-cycle tests use a 100MHz TB clock and accelerated UART; 5000-UI cleanup is not a production-baud hardware bound','Reset-live qualification tests cover the local stream/tag reset only, not encrypted DDR warm restart','Receiver offer/occupancy and counter-boundary fault injections supplement, not replace, full actual-FIFO and full-cycle tests']
 (O/'OFFLINE_ACCEPTANCE.json').write_text(json.dumps(receipt,indent=2));print(json.dumps({k:receipt[k] for k in ('status','resource','bitstream','STA_reports','minimum_reported_slack_ns','protected_tracked','historical_untracked_preserved')},indent=2))
if __name__=='__main__':main()
