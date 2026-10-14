from pathlib import Path
import sys,json,zlib
from check_trace import packet128
W=Path(sys.argv[1]);summaries=[]
for side in ['0','1']:
 lines=[l.split() for l in (W/('uart_meta_'+side+'.txt')).read_text().splitlines() if l.startswith('INPUT ')];events=[l.split() for l in (W/('events_'+side+'.txt')).read_text().splitlines() if l.startswith('FRAME ')];b=bytes(int(x,16) for x in (W/('serial_'+side+'.hex')).read_text().split());assert len(lines)==len(events)==8 and len(b)==8*324
 for n,(z,e) in enumerate(zip(lines,events)):
  p,d,t,sl=int(z[1],16),int(z[2],16),int(z[3],16),int(z[4]);has=((p>>128)&((1<<64)-1))!=0;d=d if has else 0
  payload=b''.join(v.to_bytes(16,'little') for v in packet128(p,d,t,sl,0xfeed000000000003,0xbeef000000000004));header=b'SM5B'+bytes([1,4])+(64).to_bytes(2,'little')+(256).to_bytes(4,'little')+bytes(4)+(d&((1<<320)-1)).to_bytes(40,'little')+bytes(8);gold=header+payload;gold+=zlib.crc32(gold).to_bytes(4,'little');actual=b[n*324:(n+1)*324];assert actual==gold,('FORMAT',side,n)
  epixels,eq,reject,promote,sid=map(int,e[2:]);got=[int.from_bytes(actual[64+off:64+off+4],'little') for off in [112,116,120]];assert epixels==921600 and got==[eq,reject,promote],('INDEPENDENT_EVENT_TO_WIRE',side,n,got,e)
  if n in [2,3,4,5]:assert got==[0,0,0]
  if n==6:assert 0<eq<720 and promote>0
  if n in [0,1,7]:assert eq==720 and promote>0
  summaries.append(dict(side=side,frame=n,pixels=epixels,equal_rows=eq,rejected_rows=reject,promotions=promote,source_sid=sid,full_packet_crc='PASS'))
assert (W/'serial_0.hex').read_bytes()==(W/'serial_1.hex').read_bytes()
r=dict(status='PASS_INDEPENDENT_EVENTS_TO_SNAPSHOT_TO_WIRE',frames_per_side=8,wire_bytes_per_side=2592,frames=summaries);(W/'SEMANTIC_PACKET_ORACLE.json').write_text(json.dumps(r,indent=2));print(r['status']);print(summaries[:8])
