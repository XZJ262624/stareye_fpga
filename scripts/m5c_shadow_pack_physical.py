"""Package explicit current physical evidence only after qualification; never DB/bit."""
from pathlib import Path
import gzip,hashlib,json,shutil
R=Path(__file__).resolve().parents[1]
A=R/'reports/m5c_shadow_stats_20261016';P=A/'physical_133645';O=A/'candidate_evidence'

def rec(p):
 h=hashlib.sha256();n=0
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b);n+=len(b)
 return dict(path=p.relative_to(R).as_posix(),bytes=n,sha256=h.hexdigest())

def main():
 qual=json.loads((P/'FULL_PHYSICAL_QUALIFICATION.json').read_bytes())
 assert qual['status']=='PASS_CURRENT_I3_PHYSICAL_ONLY'
 assert json.loads((P/'QUALIFICATION_STATE.json').read_bytes())['status']=='PASS_QUALIFIED_AND_OFFLINE_INPUT_PLAN_READY'
 selected=set();excluded=[]
 runtime={'QUALIFICATION_STATE.json','QUALIFICATION_FAILURE.txt','CURRENT_QUERY_CHAIN_STATE.json','OFFLINE_PACKAGE_POINTER.json'}
 for p in P.iterdir():
  if not p.is_file():continue
  if p.name in runtime or p.name.startswith('qualification_') or p.suffix not in {'.json','.py','.tcl','.md'}:
   excluded.append(p.relative_to(R).as_posix());continue
  selected.add(p)
 stages=['map','interface','place','route']
 plan=json.loads((P/'FULL_QUERY_DERIVATION.json').read_bytes())
 stages += [x['name'] if x['name'].startswith('sta_') else 'sta_'+x['name'] for x in plan['queries']]
 assert len(stages)==13 and len(set(stages))==13
 for name in stages:
  d=P/name;result=json.loads((d/'RESULT.json').read_bytes())
  assert result['exit']==0 and not result['timeout']
  for p in d.iterdir():
   if p.is_file() and p.suffix in {'.json','.log','.tcl','.py'}:selected.add(p)
 mirror=P/'mirror/efinity/m5c_fusion_i3'
 # Timing reports and native typed object text only; no generic mutable tool summary.
 for p in (mirror/'outflow').glob('*.rpt'):
  if p.name.startswith('Ti60_Demo.'):continue
  selected.add(p)
 for name in ['pin_nets.txt','complete_pin_nets.txt','backend_pin_nets.txt']:
  p=mirror/name
  if p.exists():selected.add(p)
 # Select other typed data files only when explicitly referenced by the completed audits.
 for name in ['TIMING_CURRENT_AUDIT.json','COMPLETE_CONTROL_TIMING_AUDIT.json','CLOCK_RAM_FINAL_COMPLETION.json']:
  def walk(v):
   if isinstance(v,dict):
    if set(['path','bytes','sha256'])<=set(v):
     p=R/v['path']
     if p.is_relative_to(mirror) and p.suffix=='.txt':
      assert rec(p)==v;selected.add(p)
    for x in v.values():walk(x)
   elif isinstance(v,list):
    for x in v:walk(x)
  walk(json.loads((P/name).read_bytes()))
 mapping=[];objects={}
 for p in sorted(selected):
  assert p.suffix not in {'.bit','.bin','.hex','.v','.vdb','.lbf','.troutingtraces','.dll','.exe'}
  x=rec(p);q=O/'objects'/x['sha256'][:2]/(x['sha256']+'.gz');q.parent.mkdir(parents=True,exist_ok=True)
  if not q.exists():
   with p.open('rb') as src,q.open('wb') as dst,gzip.GzipFile(filename='',mode='wb',fileobj=dst,mtime=0) as gz:shutil.copyfileobj(src,gz,1048576)
  assert rec(p)==x
  z=rec(q);mapping.append(dict(original=x,object=z));objects[z['path']]=z
 out=O/'PHYSICAL_OBJECTS.json';assert not out.exists()
 out.write_text(json.dumps(dict(status='CURRENT_QUALIFIED_PHYSICAL_SELECTED_TRANSPORT_PENDING_STREAM_VERIFY',mapping=mapping,objects=list(objects.values()),stage_names=stages,excluded_root_runtime=excluded,generator=rec(Path(__file__)),boundary='Single actual I3 model, not PVT corners. Archive indexes preserve historical SHA references; entire archive/map/DB/trace/tool/bit bytes are not included. Full four structural inventories are separately transported losslessly; they do not replace complete mapped logic.'),indent=2))
 print('PHYSICAL_SELECTED',len(mapping),len(objects),sum(x['bytes'] for x in objects.values()))

if __name__=='__main__':main()
