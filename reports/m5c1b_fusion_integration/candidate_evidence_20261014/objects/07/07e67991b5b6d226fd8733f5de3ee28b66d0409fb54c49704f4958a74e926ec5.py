from pathlib import Path
import sys,json,zlib
from check_trace import packet128
W=Path(sys.argv[1]);suffix=sys.argv[2];gold=b'';records=[]
for line in (W/('uart_meta_'+suffix+'.txt')).read_text().splitlines():
 z=line.split()
 if z[0]!='INPUT':continue
 p,d,t,sl=int(z[1],16),int(z[2],16),int(z[3],16),int(z[4]);has=((p>>128)&((1<<64)-1))!=0;d=d if has else 0
 payload=b''.join(v.to_bytes(16,'little') for v in packet128(p,d,t,sl,0xfeed000000000003,0xbeef000000000004));header=b'SM5B'+bytes([1,4])+(64).to_bytes(2,'little')+(256).to_bytes(4,'little')+bytes(4)+(d&((1<<320)-1)).to_bytes(40,'little')+bytes(8);pkt=header+payload;pkt+=zlib.crc32(pkt).to_bytes(4,'little');gold+=pkt;records.append(dict(snapshot=hex(p),descriptor=hex(d),bytes=len(pkt),crc=pkt[-4:].hex()))
actual=bytes(int(x,16) for x in (W/('serial_'+suffix+'.hex')).read_text().split());assert len(records)==3 and actual==gold,(len(records),len(actual),len(gold),next((i for i,(a,b) in enumerate(zip(actual,gold)) if a!=b),None));assert len({r['snapshot'] for r in records})==3
r=dict(status='PASS_INDEPENDENT_3_PACKET_FORMAT_CRC',wire_bytes=len(actual),packets=records);(W/('COUPLED_SOFTWARE_ORACLE_'+suffix+'.json')).write_text(json.dumps(r,indent=2));print(r['status'],len(actual))
