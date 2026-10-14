from pathlib import Path
import time,json,subprocess,sys,hashlib
F=Path(__file__).resolve().parent
p=F/'run_queries.py';b=p.read_bytes();expected=hashlib.sha256(b).hexdigest();queries=json.loads((F/'QUERY_DERIVATION.json').read_text())
(F/'STA_SCHEDULE.json').write_text(json.dumps(dict(status='WAIT_ROUTE_GATE_NO_STA_STARTED',runner_sha256=expected,scheduled_unix=time.time(),conditions='Actual route PASS_STAGE/resource pass plus archived outputs verified by run_queries.py; no source change or failure bypass.'),indent=2))
start=time.time()
while not (F/'route/RESULT.json').exists():
 for st in ['map','interface','place']:
  q=F/st/'RESULT.json'
  if q.exists():assert json.loads(q.read_text())['status']=='PASS_STAGE',st
 assert time.time()-start<1800,'Route not available within bounded schedule'
 time.sleep(5)
r=json.loads((F/'route/RESULT.json').read_text());assert r['status']=='PASS_STAGE' and r['resources']['pass']
assert hashlib.sha256(p.read_bytes()).hexdigest()==expected
for x in queries['queries']:
 q=F.parents[2]/x['query']['path'];assert hashlib.sha256(q.read_bytes()).hexdigest()==x['query']['sha256']
with (F/'query_chain.log').open('wb') as log:
 proc=subprocess.Popen([sys.executable,'-B',str(p)],cwd=F.parents[2],stdout=log,stderr=subprocess.STDOUT);(F/'QUERY_CHAIN_OWNER.json').write_text(json.dumps(dict(pid=proc.pid,started_unix=time.time(),runner_sha256=expected),indent=2));print('QUERY_CHAIN_STARTED',proc.pid,flush=True);code=proc.wait()
(F/'QUERY_CHAIN_RESULT.json').write_text(json.dumps(dict(exit=code,status='QUERIES_COMPLETE_PENDING_FINAL_AUDIT' if code==0 else 'FAILED_REQUIRES_CAUSAL_REVIEW'),indent=2));print('QUERY_CHAIN_DONE',code,flush=True);sys.exit(code)
