"""Explicit completed system/versioned input transport, no active-input edits."""
from pathlib import Path
import gzip,hashlib,json,shutil
R=Path(__file__).resolve().parents[1];A=R/'reports/m5c_shadow_stats_20261016';O=A/'candidate_evidence';W=A/'system_134939/run'
def rec(p):
 h=hashlib.sha256();n=0
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b);n+=len(b)
 return dict(path=p.relative_to(R).as_posix(),bytes=n,sha256=h.hexdigest())
def main():
 assert json.loads((W/'final_seal/GATE_HANDBACK.json').read_bytes())['status']=='PASS_CURRENT_SCHEMA2_SYSTEM_FINAL_SEALED'
 selected=set();excluded=[]
 for d in [A/'system_134939',A/'system_fixture']:
  for p in d.rglob('*'):
   if not p.is_file():continue
   if any(x in ['work','__pycache__'] for x in p.relative_to(d).parts) or p.suffix in ['.wlf','.vcd','.pyc','.db'] or p.name=='transcript':
    excluded.append(p.relative_to(R).as_posix());continue
   assert p.suffix not in ['.bit','.bin','.vdb','.lbf','.exe','.dll']
   selected.add(p)
 for x in json.loads((W/'INPUTS.json').read_bytes()):
  p=Path(x['path']);v=rec(p);assert v['bytes']==x['bytes'] and v['sha256']==x['sha256'];selected.add(p)
 for n in ['m5c_shadow_check_system.py','m5c_shadow_finish_system.py','m5c_shadow_close_system_strict.py','m5c_shadow_decode.py','m5b1_uart_decode.py','m5c_shadow_seal_system_final.py']:selected.add(R/'scripts'/n)
 mapping=[];objects={}
 for p in sorted(selected):
  x=rec(p);q=O/'objects'/x['sha256'][:2]/(x['sha256']+'.gz');q.parent.mkdir(parents=True,exist_ok=True)
  if not q.exists():
   with p.open('rb') as src,q.open('wb') as dst,gzip.GzipFile(filename='',mode='wb',fileobj=dst,mtime=0) as gz:shutil.copyfileobj(src,gz,1048576)
  assert rec(p)==x;z=rec(q);objects[z['path']]=z;mapping.append(dict(original=x,object=z))
 target=O/'SYSTEM_OBJECTS.json';assert not target.exists()
 target.write_text(json.dumps(dict(status='COMPLETED_SYSTEM_SELECTED_TRANSPORT_PENDING_STREAM_VERIFY',mapping=mapping,objects=list(objects.values()),excluded_runtime=excluded,generator=rec(Path(__file__)),boundary='Final current schema2 simulation, exact54 execution inputs, current strict postdecoder and original type1..4/end checker evidence. Conditional UART/cadence, not hardware/default-throughput. Golden/parent checker source closure separately indexed.'),indent=2));print('SYSTEM_SELECTED',len(mapping),len(objects))
if __name__=='__main__':main()
