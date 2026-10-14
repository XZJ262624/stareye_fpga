from pathlib import Path
import json,hashlib,re
M=Path(__file__).resolve().parent;R=M.parents[2];W=M/'nonzero_reject/negative_counter_081300';O=M/'nonzero_negative_handback_0957';O.mkdir()
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
records={};checks=0
for x in json.loads((W/'INPUTS.json').read_text()):
 assert rec(R/x['path'])==x;records[x['path']]=x;checks+=1
for x in json.loads((W/'SNAPSHOTS.json').read_text()):
 q=x['snapshot'];assert rec(R/q['path'])==q;records[q['path']]=q;checks+=1
for p in W.iterdir():
 if p.is_file():records[rec(p)['path']]=rec(p)
r=json.loads((W/'RESULT.json').read_text());assert r['status']=='PASS_EXPECTED_NONZERO_COUNTER_FATAL' and r['source_unchanged']
steps=r['steps'];assert next(s for s in steps if s['stage']=='compile')['exit']==0
txt=(W/'sim.log').read_text();fatals=re.findall(r'\*\* Fatal: ([^\r\n]+)',txt)
assert fatals==['NONZERO_REJECT_COUNTER_MISMATCH equal=719 rejected=1 promoted=6']
events=[x for x in txt.splitlines() if any(k in x for k in ('NZ_REAL_A','NZ_OWNER','NZ_REAL_R_CREATED','NZ_REAL_R_ACCEPT','NZ_FRAME','** Fatal:'))]
(O/'HANDBACK.json').write_text(json.dumps(dict(status='PASS_NAMED_COUNTER_SENSITIVITY_ONLY',input_snapshot_checks=checks,mismatches=0,events=events,result=rec(W/'RESULT.json'),native_exit=steps[-1]['exit'],boundary='Counter-increment suppress mutant rejected by independently observed719 equal/1 rejected/6 promoted after real addressed DDR R handshake. Native Fatal exit0 disclosed. Positive recovery/full-wire test was aborted for old finish race and remains pending; this does not claim that gate.'),indent=2))
for p in [O/'HANDBACK.json',Path(__file__)]:records[rec(p)['path']]=rec(p)
(O/'MANIFEST.json').write_text(json.dumps(dict(records=list(records.values())),indent=2));print(len(records),checks,rec(O/'MANIFEST.json'))
