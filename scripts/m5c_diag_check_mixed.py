from pathlib import Path
import sys,json,zlib,hashlib
d=Path(sys.argv[1]);r=json.loads((d/'RESULT.json').read_text());assert r['status']=='PASS_SIM_PENDING_SOFTWARE' and r['inputs_unchanged']
assert all(s['exit']==0 and not s['timeout'] for s in r['steps'])
raw=bytes.fromhex((d/'wire.hex').read_text());assert len(raw)==1620
packets=[]
for n,t in enumerate([1,5,2,3,4]):
 p=raw[n*324:(n+1)*324];h=bytearray(64);h[:4]=b'SM5B';h[4]=1;h[5]=t;h[6:8]=(64).to_bytes(2,'little');h[8:12]=(256).to_bytes(4,'little')
 if t!=5:h[16:56]=(0x123456789abcdef).to_bytes(40,'little')
 payload=bytes(((i*7+3) if t==5 else (i*13+t*17))&255 for i in range(256))
 expected=bytes(h)+payload;expected+=zlib.crc32(expected).to_bytes(4,'little');assert p==expected,(n,t)
 packets.append(dict(type=t,length=256,crc32=hex(zlib.crc32(p[:320])),all_bytes_exact=True))
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
out=dict(status='PASS_DEFAULT_UART_MIXED_FINITE_FULL_BYTES',packets=packets,bytes=len(raw),scope='Finite256-byte payloads; original types1..4 serializer compared cycle-exact to fixed HEAD baseline, not full-frame backend export proof.',bindings=[rec(d/n) for n in ['RESULT.json','INPUTS.json','sim.log','wire.hex']]+[rec(Path(__file__))])
(d/'SOFTWARE_ORACLE.json').write_text(json.dumps(out,indent=2));print(out['status'])
