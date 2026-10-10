"""Fail-closed local offline gate; raw build/simulation artifacts stay local."""
from pathlib import Path
import json,hashlib,re,subprocess
from m5b1_uart_decode import selftest
R=Path(__file__).resolve().parents[1];O=R/'reports/m5b1_global_canny_i3';W=R/'efinity/m5b1_global_canny_i3';BUILD='build_20261010_130312'
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def load(p):return json.loads(p.read_text())
def main():
 tests={}
 for name in ('global_final','system','system_faults','directed','mutations','qos_negative','tap'):
  p=O/name/'results.json';v=load(p);assert v['status'].startswith('PASS')
  for src in v['sources']:assert rec(R/src['path'])==src,src['path']
  tests[name]=dict(status=v['status'],source_files_checked=len(v['sources']),evidence=rec(p))
  for case in v.get('cases',v.get('tests',[])):
   if 'log' in case:assert rec(R/case['log']['path'])==case['log']
 assert len(load(O/'system/results.json')['cases'])==6
 assert len(set((c['camera_phase_ns'],c['pixel_phase_ns']) for c in load(O/'system/results.json')['cases']))==6
 assert {c['name'] for c in load(O/'global_final/results.json')['cases']}=={'small30','720p15','exhaustive','last_pixel','snake642','wall_default','pair_default'}
 assert {c['mode'] for c in load(O/'system_faults/results.json')['cases']}=={1,2,3,4,5}
 assert len(load(O/'mutations/results.json')['cases'])==10
 B=O/BUILD;before=load(B/'inputs_before.json');after=load(B/'inputs_after.json');assert len(before)==len(after)==96
 md=load(B/'XML_METADATA_ONLY.json');xml=(W/'Ti60_Demo.xml').read_bytes();reconstructed=xml
 for key,(old,new) in md['changes'].items():reconstructed=reconstructed.replace(f'{key}="{new}"'.encode(),f'{key}="{old}"'.encode())
 for a,b in zip(before,after):
  assert a['path']==b['path'] and rec(R/b['path'])==b
  if a!=b:assert a['path']==md['before']['path'] and hashlib.sha256(reconstructed).hexdigest()==a['sha256'] and len(reconstructed)==a['bytes']
 build=load(B/'result.json');assert build['exit_code']==0 and build['resource_stop'] is None
 for out in build['outputs']:assert rec(R/out['path'])==out,out['path']
 log=(B/'compile.log').read_text();phases=['map','interface','pnr','pgm','export_bitstream']
 for phase in phases:assert re.search(r'\b'+phase+r'\s*:\s*PASS',log),phase
 sta=load(O/'final_sta/binding.json');assert sta['exit_code']==0 and sta['complete'] and sta['original_unchanged'] and sta['minimum_reported_slack_ns']>=0
 for p,record in sta['original_after'].items():assert {k:rec(W/p)[k] for k in ('bytes','sha256')}==record
 for record in sta['reports']:assert {k:rec(O/'final_sta'/record['path'])[k] for k in ('bytes','sha256')}=={k:record[k] for k in ('bytes','sha256')}
 assert sum(c['paths'] for c in sta['cdc_physical_groups'])==413
 assert all(sta['check_timing'][k]==0 for k in ('no_clock','unconstrained_internal_endpoints','multiple_clock'))
 structural=load(O/'CDC_STRUCTURAL_AUDIT.json');assert not structural['unapproved_crossings'] and not structural['unknown_internal'] and not structural['new_srl']
 assert structural['map']==rec(W/'outflow/Ti60_Demo.map.v')
 manifest=load(O/'CDC_PIN_MANIFEST.json');assert manifest['map_sha256']==structural['map']['sha256'] and manifest['sdc_sha256']==rec(W/'Ti60_Demo_I3.sdc')['sha256']
 place=(W/'outflow/Ti60_Demo.place.rpt').read_text();resource={name:int(re.search(label+r': (\d+) /',place).group(1)) for name,label in [('XLR','XLRs'),('RAM10','Memory Blocks'),('DSP','DSP Blocks')]}
 assert resource['XLR']<=48640 and resource['RAM10']<=204 and resource['DSP']<=128
 static=load(O/'STATIC_AUDIT.json');assert static['status'].startswith('PASS') and not static['protected_changes'] and not static['historical_untracked_missing']
 bit=rec(W/'outflow/Ti60_Demo.bit');receipt=dict(status='PASS_OFFLINE_PENDING_INDEPENDENT_REVIEWS_AND_HARDWARE',required_parent='c0102ee1c9a0a8aa802c398755d4a7b3139c7ffd',tests=tests,host_decoder=selftest(),build_directory=BUILD,build_phases=phases,input_count=len(after),XML_metadata_only=md,resource=resource,bitstream=bit,STA_reports=len(sta['reports']),minimum_reported_slack_ns=sta['minimum_reported_slack_ns'],check_timing=sta['check_timing'],physical_CDC=sta['cdc_physical_groups'],protected_tracked=static['protected_tracked'],historical_untracked_preserved=static['historical_untracked'],limits=['Conditional <=384 UI transaction service, not hardware guarantee','Production 64-pair/1-second wall-clock may safely time out; no fps promise','Fail-stop with no synthetic ACK; cold reconfiguration after global fault','No real frame, hardware stability or independent-review PASS claimed'],evidence=[rec(O/p) for p in ['STATIC_AUDIT.json','CDC_STRUCTURAL_AUDIT.json','CDC_PIN_MANIFEST.json','final_sta/binding.json',BUILD+'/result.json',BUILD+'/inputs_before.json',BUILD+'/inputs_after.json']],validator=rec(Path(__file__)))
 (O/'OFFLINE_ACCEPTANCE.json').write_text(json.dumps(receipt,indent=2));print(json.dumps({k:receipt[k] for k in ('status','resource','bitstream','STA_reports','minimum_reported_slack_ns','protected_tracked','historical_untracked_preserved')},indent=2))
if __name__=='__main__':main()
