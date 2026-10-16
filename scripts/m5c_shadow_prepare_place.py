from pathlib import Path
import json,hashlib,difflib
R=Path(__file__).resolve().parents[1];B=R/'reports/m5c_shadow_stats_20261016/physical_133645';p=B/'run_stage.py';old=p.read_text()
new=old.replace("assert stage=='map'","assert stage in ('interface','place','route')")
a=new.index(' try:code=p.wait(timeout=3600)');b=new.index('\nafter=[rec(p)',a)
new=new[:a]+''' while p.poll() is None:
  hp=W/'HEARTBEAT.tmp';hp.write_text(json.dumps(dict(status='NATIVE_RUNNING_NO_NORMAL_TIMEOUT_KILL',pid=p.pid,updated=time.time(),elapsed=time.time()-t),indent=2));hp.replace(W/'HEARTBEAT.json');time.sleep(5)
 code=p.returncode
'''+new[b:]
out=B/'run_physical_persistent_v2.py';assert not out.exists();out.write_text(new)
def rec(q):
 x=q.read_bytes();return dict(path=str(q),bytes=len(x),sha256=hashlib.sha256(x).hexdigest())
(B/'PERSISTENT_RUNNER_DERIVATION.json').write_text(json.dumps(dict(parent=rec(p),derived=rec(out),scope='Only downstream stage enable and persistent heartbeat/no fixed-hour termination. All resource, source, archive and prior-stage gates retained.',diff=''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True)))),indent=2))
chain=B/'run_interface_place.py';chain.write_text('''from pathlib import Path
import subprocess,sys,json,time,os
B=Path(__file__).resolve().parent
(B/'PLACE_CHAIN_OWNER.json').write_text(json.dumps(dict(pid=os.getpid(),start=time.time(),argv=sys.argv),indent=2))
for stage in ['interface','place']:
 with (B/('chain_'+stage+'.log')).open('wb') as f:
  p=subprocess.run([sys.executable,'-B',str(B/'run_physical_persistent_v2.py'),stage],stdout=f,stderr=subprocess.STDOUT)
 assert p.returncode==0,(stage,p.returncode)
 assert json.loads((B/stage/'RESULT.json').read_text())['status']=='PASS_STAGE'
p=subprocess.run([sys.executable,'-B',str(B/'verify_native_selectors.py')],capture_output=True)
(B/'native_selector_verify.log').write_bytes(p.stdout+p.stderr)
assert p.returncode==0
(B/'PLACE_CHAIN_RESULT.json').write_text(json.dumps(dict(status='PASS_RESOURCE_AND_NATIVE_SELECTORS_ONLY',completed=time.time()),indent=2))
''')
print(chain)
