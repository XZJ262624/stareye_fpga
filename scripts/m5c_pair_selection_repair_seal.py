from pathlib import Path
import json,hashlib,difflib,re,sys
R=Path(__file__).resolve().parents[1];F=R/'reports/m5c_pair_capture_20261016';O=F/'selection_repair_handback';O.mkdir(exist_ok=True)
sys.path.insert(0,str(R/'scripts'))
from m5c_pair_decode_only import packets,decode_pair
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
names=['selection_fixed_005058','selection_fixed_mutant_005120','selection_lifecycle_v2_005649','selection_rejections_005832','selection_denied_010050'];files=set();rows=[]
for name in names:
 d=F/name;result=json.loads((d/'RESULT.json').read_text());assert result['status'].startswith('PASS') and result['source_unchanged']
 inputs=json.loads((d/'INPUTS.json').read_text())
 for x in inputs:
  p=Path(x['path']);q=rec(p);assert q['bytes']==x['bytes'] and q['sha256']==x['sha256'];files.add(p)
 for st in result['steps']:
  assert st['exit']==0 and st['ok'];p=Path(st['log']['path']);assert rec(p)['sha256']==st['log']['sha256'];text=p.read_text()
  assert '** Error' not in text
  if name==names[1] and st['stage'].startswith('case'):
   assert re.findall(r'\*\* Fatal: (.*)',text)==['REAL_TYPE4_SELECTION_MISSING']
  else:assert '** Fatal' not in text
 for p in d.rglob('*'):
  if p.is_file() and 'work' not in p.relative_to(d).parts and p.suffix in ['.json','.log','.txt','.hex','.sv','.py']:files.add(p)
 rows.append(dict(run=name,result=result['status'],inputs=len(inputs),raw_exit_zero_is_not_positive_oracle=name==names[1]))
wire=[]
for name,cases in [(names[2],[0,1]),(names[4],[0])]:
 for c in cases:
  raw=bytes.fromhex((F/name/f'case{c}/system_uart.hex').read_text());pk=packets(raw);decoded=decode_pair(raw,test_sizes=(1024,512,512))
  types=[x['type'] for x in pk]
  if name==names[2] and c==0:
   assert types==[1,4,4,6,7,8,9,10,1]
   for t,n,val in [(7,512,0),(8,512,0),(9,1024,4)]:assert next(x['payload'][24:] for x in pk if x['type']==t)==bytes([val])*n
  else:assert types==([1,4,4,10,1] if name==names[2] else [1,4,10,1])
  wire.append(dict(run=name,case=c,types=types,decoded=decoded))
before=F/'selection_repair_20261017/backend_before.sv';after=R/'rtl/m5c_pair_diag/m5c_pair_backend.sv'
a=before.read_text();b=after.read_text();start=a.index(' assign pair_selected=');end=a.index(';',start)+1
startb=b.index(' // Capture may retain');endb=b.index(';',b.index(' assign pair_selected='))+1
assert b[:startb]+a[start:end]+b[endb:]==a
(O/'BACKEND_DIFF.patch').write_text(''.join(difflib.unified_diff(a.splitlines(True),b.splitlines(True),fromfile='before',tofile='after')))
baseline=json.loads((F/'BASELINE_INPUTS.json').read_text());protected=baseline['source']
for x in protected:
 q=rec(R/x['path']);assert q==x
summary=dict(status='PASS_BOUNDED_SELECTION_REPAIR_GATES',runs=rows,wire=wire,backend_before=rec(before),backend_after=rec(after),single_selection_predicate_inverse_exact=True,protected_inputs=len(protected),protected_differences=0,limits=['Original longrun exact failed acquisition edge was not directly observed. Defect was reproduced with actual producer/session/backend.', 'Lifecycle current is128x8; real source publication720p allzero; reader A withheld; no fullvideo qualification.', 'Denied test flips bit319 at backend acquire identity input; actual lease denies. Not a natural correctly formed display request.', 'UART software checks accepted-byte stream, not pin timing. First no-source type4 all256bytes independently checked by fixed seal; lifecycle source tick is stimulus-dependent.', 'Fresh fullvideo, map/place, complete STA/CDC and offline artifact remain pending. Old physical results are not this RTL qualification.', 'First lifecycle compile forward-reference FAIL retained; negative raw simulator exit0 is accepted only with unique intended Fatal.'])
(O/'SUMMARY.json').write_text(json.dumps(summary,indent=2)+'\n')
files.update([before,after,O/'BACKEND_DIFF.patch',O/'SUMMARY.json',Path(__file__),F/'selection_fixed_handback/SUMMARY.json',F/'selection_fixed_handback/MANIFEST.json',F/'selection_repair_20261017/STOP_RECEIPT.json'])
(O/'MANIFEST.json').write_text(json.dumps([rec(p) for p in sorted(files)],indent=2)+'\n');print(O,len(files))
