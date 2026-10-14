from pathlib import Path
import json,sys,zlib
from check_trace import packet128
R=Path(__file__).resolve().parents[3];W=Path(sys.argv[1]);lines=[x.split() for x in (W/'uart_meta.txt').read_text().splitlines()];inputs=[x for x in lines if x[0]=='INPUT'];packets=[x for x in lines if x[0]=='PACKET'];frames={int(x[1]):x for x in lines if x[0]=='FRAME'};wire=bytes(int(x,16) for x in (W/'serial.hex').read_text().split());pos=0;ti=0;types={};healthy_wire=0;records=[]
for i,z in enumerate(packets):
 typ,length,desc=int(z[1]),int(z[2]),int(z[3],16);actual=wire[pos:pos+68+length];assert len(actual)==68+length,('TRUNCATED',i);header=b'SM5B'+bytes([1,typ])+(64).to_bytes(2,'little')+length.to_bytes(4,'little')+bytes(4)+desc.to_bytes(40,'little')+bytes(8);assert actual[:64]==header,('HEADER',i);assert int.from_bytes(actual[-4:],'little')==zlib.crc32(actual[:-4]),('CRC',i)
 payload=actual[64:-4];types[typ]=types.get(typ,0)+1
 if typ in [2,3]:assert payload==(R/'reports/m5c1b_fusion_integration/golden_v2'/('class.bin' if typ==2 else 'mask.bin')).read_bytes(),('FULL_CLASS_BFS_MASK',typ)
 if typ==4:
  t=inputs[ti];p,d,token,slot,jobs,faults=int(t[1],16),int(t[2],16),int(t[3],16),int(t[4]),int(t[5],16),int(t[6],16);expected=b''.join(v.to_bytes(16,'little') for v in packet128(p,d,token,slot,jobs,faults));assert payload==expected,('TELEMETRY_FULL_FORMAT',ti);seq=p&((1<<64)-1);e=frames[seq];assert int.from_bytes(payload[120:124],'little')==int(e[2]),('FRAME_EVENT_TO_WIRE',seq);healthy_wire+=int(int(e[3])!=0 and int(e[2])==7 and ((p>>128)&((1<<64)-1))!=0);ti+=1
 records.append(dict(index=i,type=typ,payload_bytes=length,crc='PASS'));pos+=68+length
assert pos==len(wire) and ti==len(inputs),('EXTRA_BYTES_OR_SNAPSHOTS',pos,len(wire),ti,len(inputs));assert all(types.get(x,0)>0 for x in [1,2,3,4]) and healthy_wire>=1,('COVERAGE',types,healthy_wire)
r=dict(status='PASS_INDEPENDENT_FULL_WIRE_CRC_CLASS_BFS_TELEMETRY',bytes=pos,types=types,healthy_frame_event_to_wire=healthy_wire,packets=records,scope='Accelerated actual fullsystem UART_CLOCK960000/BAUD460800; not default-speed throughput. Type1 header/framing/CRC checked, exhaustive type1 scalar semantics pending mixed legacy matrix.');(W/'SOFTWARE_UART_ORACLE.json').write_text(json.dumps(r,indent=2));print(r['status'],pos,types,healthy_wire)
