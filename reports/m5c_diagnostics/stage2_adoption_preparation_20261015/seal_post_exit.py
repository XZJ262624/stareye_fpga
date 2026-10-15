from pathlib import Path
import json,hashlib
R=Path(__file__).resolve().parents[3];O=Path(__file__).resolve().parent
W=R/'reports/m5c_diagnostics/stage2_system_persistent_20261015_201619/run'
D=O/'final_system_seal';D.mkdir(exist_ok=False)
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
old=W/'completion_gate/MANIFEST.json';a=json.loads(old.read_text())['records']
proof=json.loads((O/'COMPLETED_SYSTEM_CHECK.json').read_text());assert proof['status']=='PASS_CURRENT_ENABLED_SYSTEM_FINITE_SCOPE'
files={Path(x['path']) for x in a}|{old,W/'HEARTBEAT.json',W/'completion_gate/STATE.json',O/'COMPLETED_SYSTEM_CHECK.json',O/'COMPLETED_OWNER_EXIT.json',O/'COMPLETION_MANIFEST_TRANSITION_FAILURE.json',O/'verify_completed_system.py',O/'verify_completed_system_v2.py',Path(__file__)}
receipt=dict(status='PASS_CURRENT_ENABLED_SYSTEM_FINITE_SCOPE',original_manifest=rec(old),old_records=134,old_unchanged_records=132,epilogue_changed_records=2,transition=rec(O/'COMPLETION_MANIFEST_TRANSITION_FAILURE.json'),
 boundary='Original in-progress heartbeat bytes were not archived; its original hash/size remains historical evidence only. Empty worker-log old bytes are known. No original receipt was overwritten. Final raw/input/native/strict-software evidence is now bound after all owned processes exited.',
 verification=rec(O/'COMPLETED_SYSTEM_CHECK.json'),native_seconds=proof['native_seconds'],wire_bytes=proof['complete_wire_bytes'],packet_types=proof['packet_types'],physical_gate='Separate current I3 qualification completed',next='Work root-adoption authorization and exact candidate evidence scope; no Git/hardware authorization')
(D/'HANDBACK.json').write_text(json.dumps(receipt,indent=2));files.add(D/'HANDBACK.json')
records=[rec(p) for p in sorted(files)]
(D/'MANIFEST.json').write_text(json.dumps(dict(status='POST_EXIT_IMMUTABLE_SEAL',records=records),indent=2))
for x in records:assert rec(Path(x['path']))==x
print(json.dumps(dict(records=len(records),manifest=rec(D/'MANIFEST.json'))))
