from pathlib import Path
import sys,json,zlib,hashlib,subprocess
O=Path(__file__).resolve().parent;M=O.parent;W=Path(sys.argv[1]);R=O.parents[3];sys.path.insert(0,str(M));from check_trace import packet128
lines=[l.split() for l in (W/'uart_meta.txt').read_text().splitlines()];inputs=[l for l in lines if l[0]=='INPUT'];packets=[l for l in lines if l[0]=='PACKET'];events={int(v[1]):v for v in (l.split() for l in (W/'nonzero_events.txt').read_text().splitlines()) if v[0]=='NZ_FRAME'};wire=bytes(int(v,16) for v in (W/'serial.hex').read_text().split());offset=0;ti=0;faults=[];recoveries=[];types={}
for idx,pkt in enumerate(packets):
 typ,length,desc=int(pkt[1]),int(pkt[2]),int(pkt[3],16);b=wire[offset:offset+68+length];assert len(b)==68+length,('TRUNCATED',idx);header=b'SM5B'+bytes([1,typ])+(64).to_bytes(2,'little')+length.to_bytes(4,'little')+bytes(4)+desc.to_bytes(40,'little')+bytes(8);assert b[:64]==header and int.from_bytes(b[-4:],'little')==zlib.crc32(b[:-4]),('HEADER_CRC',idx);payload=b[64:-4];types[typ]=types.get(typ,0)+1
 if typ in [2,3]:assert payload==(R/'reports/m5c1b_fusion_integration/golden_v2'/('class.bin' if typ==2 else 'mask.bin')).read_bytes(),('CLASS_BFS',idx)
 if typ==4:
  v=inputs[ti];snapshot,d,token,slot,jobs,pfaults=int(v[1],16),int(v[2],16),int(v[3],16),int(v[4]),int(v[5],16),int(v[6],16);expected=b''.join(x.to_bytes(16,'little') for x in packet128(snapshot,d,token,slot,jobs,pfaults));assert payload==expected,('FULL_TELEMETRY',ti);seq=snapshot&((1<<64)-1)
  if seq in events:
   e=events[seq];sid,eq,reject,prom,fault=map(int,e[2:]);actual=[int.from_bytes(payload[i:i+4],'little') for i in [112,116,120]];assert actual==[eq,reject,prom] and ((snapshot>>128)&((1<<64)-1))==sid,('NONZERO_REJECT_COUNTER_MISMATCH',seq,e,actual)
   if fault:assert actual==[719,1,6] and (snapshot>>(320+7))&1;faults.append(seq)
   elif faults and seq>faults[-1]:assert actual==[720,0,7];recoveries.append(seq)
  ti+=1
 offset+=68+length
assert offset==len(wire) and ti==len(inputs) and len(faults)==1 and recoveries and all(types.get(t,0)>0 for t in [1,2,3,4]),('NONZERO_WIRE_COVERAGE',faults,recoveries,types,offset,len(wire));r=dict(status='PASS_NONZERO_REJECT_INDEPENDENT_EVENT_FULL_WIRE',fault_frame=faults[0],clean_recovery_frames=recoveries,bytes=len(wire),types=types,expected_fault=[719,1,6],expected_recovery=[720,0,7],scope='Lawful class-data model fault on real readerresponse, not camera motion. Full class/BFS exports are original data; one conditional reader response only.');(W/'NONZERO_WIRE_RESULT.json').write_text(json.dumps(r,indent=2));print(r)
