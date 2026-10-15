from pathlib import Path
import json,hashlib,zlib,collections
R=Path(__file__).resolve().parents[3];O=Path(__file__).resolve().parent
W=R/'reports/m5c_diagnostics/stage2_system_persistent_20261015_201619/run'
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
m=W/'completion_gate/MANIFEST.json';a=json.loads(m.read_text())['records']
for x in a:assert rec(Path(x['path']))==x
steps=json.loads((W/'NATIVE_STEPS.json').read_text());assert len(steps)==3 and all(x['exit']==0 and not x['timeout'] for x in steps)
result=json.loads((W/'RESULT.json').read_text());assert result['inputs_unchanged'] and result['status']=='PASS_SIM_PENDING_SOFTWARE'
software=json.loads((W/'SOFTWARE_DIAGNOSTIC_SYSTEM.json').read_text());assert software['status']=='PASS_ACTUAL_SYSTEM_TYPE5_AND_ORIGINAL_WIRE'
assert json.loads((O/'COMPLETED_OWNER_EXIT.json').read_text(encoding='utf-8-sig'))==[]
raw=bytes.fromhex((W/'serial.hex').read_text());pos=0;types=collections.Counter()
while pos<len(raw):
 assert raw[pos:pos+4]==b'SM5B';n=int.from_bytes(raw[pos+8:pos+12],'little');p=raw[pos:pos+n+68]
 assert len(p)==n+68 and zlib.crc32(p[:-4])==int.from_bytes(p[-4:],'little')
 types[p[5]]+=1;pos+=len(p)
ev=(W/'diag_events.txt').read_text().splitlines();takes=[s for s in ev if s.startswith('TAKE ')];done=[s for s in ev if s.startswith('DONE ')]
assert len(takes)==len(done)==3
end=(W/'end_events.txt').read_text().splitlines()[-1];assert end.split()[:9]==['FINISH','70','16','18','18','18','18','18','8']
out=dict(status='PASS_CURRENT_ENABLED_SYSTEM_FINITE_SCOPE',manifest_checks=len(a),manifest=rec(m),native_seconds=steps[-1]['seconds'],inputs_unchanged=True,owner_exit=rec(O/'COMPLETED_OWNER_EXIT.json'),healthy=8,healthy_mode_counts=[1,1,1,2,1,1,1],publications=9,complete_wire_bytes=len(raw),packet_types=dict(types),diagnostics=software['diagnostics'],done=done,take=takes,end=end,
 boundaries=['Conditional1M cadence, sample2, accelerated UART; default timing has separate finite proof. Not production60 or hardware.', 'Three diagnostic records are modes3/0/1: P3/P4 zero expected. Nonzero mode6 P3/P4 is covered by separate coupled short proof, not by these three records.', 'Target70 waits for third diagnostic DONE/TAKE then actual double-domain quiet; no forced or shortened ending.', 'No root adoption or Git operation in this verification.'],bindings=[rec(W/x) for x in ['RESULT.json','NATIVE_STEPS.json','SOFTWARE_DIAGNOSTIC_SYSTEM.json','serial.hex','diag_events.txt','end_events.txt']])
(O/'COMPLETED_SYSTEM_CHECK.json').write_text(json.dumps(out,indent=2));print(json.dumps(dict(manifest_checks=len(a),packet_types=dict(types),wire=len(raw),native_seconds=steps[-1]['seconds'])))
