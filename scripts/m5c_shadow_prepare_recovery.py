from pathlib import Path
import json,hashlib,shutil
R=Path(__file__).resolve().parents[1];O=R/'reports/m5c_diagnostics/stage2_finite_20261015_155023';B=R/'reports/m5c_shadow_stats_20261016/recovery_regression';B.mkdir()
allcases=json.loads((O/'CASES.json').read_text());indices=list(range(20,52))+list(range(58,64));cases=[allcases[i] for i in indices];assert len(cases)==38 and all(c['expected'] is None for c in cases)
for c in cases:
 assert all(not any(a.startswith(x) for x in ['+OUT=','-l','-wlf','+GOLD=']) for a in c['args'])
 assert all((R/p).exists() for p in c['sources'])
(B/'CASES.json').write_text(json.dumps(cases,indent=2))
checkers={'check_trace.py'}|{ck[0] for c in cases for ck in c['checkers']}
for n in checkers:shutil.copyfile(O/n,B/n)
src=O/'run_replay.py';s=src.read_text().replace('PASS_46_CURRENT_POSITIVE_18_NAMED_NEGATIVE','PASS_38_CURRENT_CONTEXT_RECOVERY_COUNTER_DIFFERENTIAL')
a=s.index('   try:code=p.wait(timeout=1200)');b=s.index('\n  text=',a)
s=s[:a]+'''   while p.poll() is None:
    (O/'HEARTBEAT.json').write_text(json.dumps(dict(case=c['name'],stage=stage,pid=p.pid,updated=time.time(),elapsed=time.time()-started)));time.sleep(5)
   code=p.returncode
'''+s[b:]
(B/'run_replay.py').write_text(s)
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
deps=sorted({R/p for c in cases for p in c['sources']}|{B/n for n in checkers})
(B/'DERIVATION.json').write_text(json.dumps(dict(parent_cases=rec(O/'CASES.json'),parent_runner=rec(src),runner=rec(B/'run_replay.py'),indices=indices,cases=38,dependencies=[rec(p) for p in deps],scope='Current root row/display compiled, original assertions and checkers retained. Context capture/revoke/late/same-edge/reset10phases/cookie/fulltail/stall/counters/descriptor differential. New output directories/cwd; no original log writes. NativeHDL watchdogs unchanged; no normal runner wall kill. Unchanged backend UART separate inherited/actual enabled gate, not mislabeled38fullsystem.'),indent=2));print(B)
