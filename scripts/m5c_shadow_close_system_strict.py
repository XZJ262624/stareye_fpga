from pathlib import Path
import json,hashlib,zlib,sys,collections
from m5c_shadow_decode import decode,FIELDS
R=Path(__file__).resolve().parents[1];W=Path(sys.argv[1]).resolve();O=W/'strict_schema2_postrun'
assert json.loads((W/'HEARTBEAT.json').read_bytes())['status']=='PASS_SYSTEM_NATIVE_AND_INDEPENDENT_SOFTWARE'
assert json.loads((W/'completion_gate/STATE.json').read_bytes())['status']=='PASS_SYSTEM_NATIVE_AND_INDEPENDENT_SOFTWARE'
assert not O.exists();O.mkdir()
def rec(p):
 b=p.read_bytes();return dict(path=p.relative_to(R).as_posix(),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
bindings=[]
for x in json.loads((W/'INPUTS.json').read_bytes()):
 p=Path(x['path']);v=rec(p);assert v['bytes']==x['bytes'] and v['sha256']==x['sha256'];bindings.append(v)
raw=bytes.fromhex((W/'serial.hex').read_text());pos=0;counts=collections.Counter();diags=[]
while pos<len(raw):
 assert raw[pos:pos+4]==b'SM5B' and pos+64<=len(raw)
 n=int.from_bytes(raw[pos+8:pos+12],'little');size=n+68;packet=raw[pos:pos+size]
 assert len(packet)==size and int.from_bytes(packet[-4:],'little')==zlib.crc32(packet[:-4])
 kind=packet[5];assert kind in [1,2,3,4,5];counts[kind]+=1
 if kind==5:
  d=decode(packet);assert d['schema']==2 and d['extensions_status']=='provided'
  if not (d['flags']&10):
   s=d['shadow'];p0,p1=d['counts'][:2]
   assert 0<=s['shadow128_accept']<=s['shadow64_accept']<=p0 and p1<=s['shadow128_accept']
   assert all(0<=s[f]<=p0 for f in FIELDS)
  diags.append(dict(offset=pos,size=size,packet_sha256=hashlib.sha256(packet).hexdigest(),decoded=d))
 pos+=size
assert pos==len(raw) and len(diags)>=2
old=json.loads((W/'SOFTWARE_DIAGNOSTIC_SYSTEM.json').read_bytes());assert old['status']=='PASS_ACTUAL_SYSTEM_TYPE5_AND_ORIGINAL_WIRE'
events=[l.split() for l in (W/'diag_events.txt').read_text().splitlines()];rc=[x for x in events if x[0]=='RECORD'];done=[x for x in events if x[0]=='DONE'];take=[x for x in events if x[0]=='TAKE'];assert len(rc)==len(done)==len(take)==len(diags)
for i,x in enumerate(diags):
 assert x['decoded']['record_sequence']==i+1 and int(done[i][1])==int(take[i][1])==i+1 and int(done[i][2])<int(take[i][2])
for p in [W/'serial.hex',W/'diag_events.txt',W/'SOFTWARE_DIAGNOSTIC_SYSTEM.json',W/'completion_gate/STATE.json',R/'scripts/m5c_shadow_decode.py',R/'scripts/m5b1_uart_decode.py',Path(__file__)]:bindings.append(rec(p))
out=dict(status='PASS_POSTRUN_STRICT_SCHEMA2_FULL_WIRE_AND_DONE_TAKE',wire_bytes=len(raw),wire_sha256=hashlib.sha256(raw).hexdigest(),packet_counts=dict(counts),diagnostics=diags,bindings=bindings,boundary='Separate strict post-run decoder; active checker unchanged. Original types1..4 independent field/BFS/end proof remains the completion checker gate. Ratios are candidate opportunity only for full nonaborted nonsaturated records, not FP or image quality. Real captured mode6 must be stated from these records; seven healthy display modes alone do not imply all modes in diagnostic samples.')
p=O/'GATE_HANDBACK.json';p.write_text(json.dumps(out,indent=2));print(out['status'],len(raw),dict(counts),[(x['decoded']['mode'],x['decoded']['counts'],x['decoded']['shadow']) for x in diags])
