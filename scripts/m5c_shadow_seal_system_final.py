"""Post-exit system seal; never edits the completed run's earlier receipts."""
from pathlib import Path
import json,hashlib,sys
R=Path(__file__).resolve().parents[1];W=Path(sys.argv[1]).resolve();O=W/'final_seal'
def rec(p):
 h=hashlib.sha256();n=0
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b);n+=len(b)
 return dict(path=p.relative_to(R).as_posix(),bytes=n,sha256=h.hexdigest())
assert not O.exists()
assert json.loads((W/'OWNED_EXIT_CHECK.json').read_bytes())['status']=='ALL_KNOWN_OWNED_PROCESSES_EXITED'
assert json.loads((W/'HEARTBEAT.json').read_bytes())['status']=='PASS_SYSTEM_NATIVE_AND_INDEPENDENT_SOFTWARE'
assert json.loads((W/'strict_schema2_postrun/GATE_HANDBACK.json').read_bytes())['status']=='PASS_POSTRUN_STRICT_SCHEMA2_FULL_WIRE_AND_DONE_TAKE'
original=json.loads((W/'completion_gate/MANIFEST.json').read_bytes());files=set();checks=0
for x in original['records']:
 p=Path(x['path']);p=p if p.is_absolute() else R/p
 v=rec(p);assert (v['bytes'],v['sha256'])==(x['bytes'],x['sha256']),p
 files.add(p);checks+=1
for d in [W,W/'completion_gate',W/'strict_schema2_postrun']:
 files.update(p for p in d.iterdir() if p.is_file() and p.suffix in ['.json','.log','.txt','.hex'])
files.update([W.parent/'run_system_persistent.py',W.parent/'DERIVATION.json',Path(__file__),R/'reports/m5c_shadow_stats_20261016/SYSTEM_WATCHDOG_METADATA_RECONCILIATION.json'])
rows=[rec(p) for p in sorted(files)];O.mkdir()
(O/'MANIFEST.json').write_text(json.dumps(dict(records=rows,scope='Post-exit immutable selected full system evidence. Earlier completion manifest preserved and every declared byte checked; epilogue files now separately final-bound.'),indent=2))
out=dict(status='PASS_CURRENT_SCHEMA2_SYSTEM_FINAL_SEALED',native_and_software=rec(W/'completion_gate/STATE.json'),strict_schema2=rec(W/'strict_schema2_postrun/GATE_HANDBACK.json'),original_manifest=rec(W/'completion_gate/MANIFEST.json'),original_records_checked=checks,final_manifest=rec(O/'MANIFEST.json'),final_records=len(rows),watchdog_sim_seconds=4,wall_seconds=14400,boundary='All seven healthy modes and full original wire/diagnostic/end gates. Conditional accelerated UART and 1M cadence, not default full-frame throughput. No hardware or visual-quality claim.')
(O/'GATE_HANDBACK.json').write_text(json.dumps(out,indent=2));print(out['status'],checks,len(rows))
