from pathlib import Path
import json,subprocess,sys,hashlib,shutil
O=Path(__file__).resolve().parent;W=Path(sys.argv[1]);events=[x.split() for x in (W/'end_events.txt').read_text().splitlines()]
src=[x for x in events if x[0]=='SOURCE' and x[2]=='1'];ui=[x for x in events if x[0]=='UI'];starts=[x for x in events if x[0]=='START'];done=[x for x in events if x[0]=='DONE'];takes=[x for x in events if x[0]=='TAKE'];target=[x for x in events if x[0]=='TARGET'];finish=[x for x in events if x[0]=='FINISH'];assert len(target)==len(finish)==1
assert len(src)==len(ui)==len(starts)==len(done)==len(takes)>0,('END_EVENT_COUNT',len(src),len(ui),len(starts),len(done),len(takes))
for i,(s,u,b,d,t) in enumerate(zip(src,ui,starts,done,takes),1):
 assert int(s[3])==int(u[1])==int(b[1])==int(d[1])==int(t[1])==i
 assert s[1]==u[2]==b[2]==d[2]==t[2] and s[4]==u[3],('END_SOURCE_UI_IDENTITY',i)
 assert int(s[5])<=int(u[5])<=int(b[4])<int(d[5])<int(t[4]),('END_CAUSAL_TIMES',i)
 assert int(d[3])==256 and int(d[4])<int(t[3]),('END_DONE_BEFORE_REGISTERED_TAKE',i)
targetseq=int(target[0][1]);targetindex=int(target[0][2]);assert int(src[targetindex-1][1])==targetseq and int(finish[0][1])==targetseq and int(finish[0][2])==targetindex
assert all(int(x)==len(src) for x in finish[0][3:8]) and int(finish[0][8])>=8
for name in ['PIX_QUIET','UI_QUIET']:
 rows=[x for x in events if x[0]==name];assert [int(x[1]) for x in rows[-8:]]==list(range(1,9)),(name,'QUIET_EDGES');assert len({x[2] for x in rows[-8:]})==1
subprocess.run([sys.executable,'-B',str(O.parent/'check_smoke_uart.py'),str(W)],check=True)
raw=bytes(int(x,16) for x in (W/'serial.hex').read_text().split());pos=0;seqs=[]
while pos<len(raw):
 n=int.from_bytes(raw[pos+8:pos+12],'little')
 if raw[pos+5]==4:seqs.append(int.from_bytes(raw[pos+72:pos+80],'little'))
 pos+=68+n
assert seqs==[int(x[2]) for x in ui] and seqs[targetindex-1]==targetseq
N=W/'orphan_input_mutation';N.mkdir();shutil.copyfile(W/'serial.hex',N/'serial.hex');meta=(W/'uart_meta.txt').read_text();line=next(x for x in reversed(meta.splitlines()) if x.startswith('INPUT '));(N/'uart_meta.txt').write_text(meta+line+'\n')
p=subprocess.run([sys.executable,'-B',str(O.parent/'check_smoke_uart.py'),str(N)],capture_output=True);(N/'oracle.log').write_bytes(p.stdout+p.stderr);assert p.returncode!=0 and b'EXTRA_BYTES_OR_SNAPSHOTS' in p.stderr,('ORPHAN_MUTATION_NOT_REJECTED',p.returncode)
result=dict(status='PASS_SOURCE_UI_TARGET_PACKET_DONE_TAKE_DUAL_QUIET_FULL_WIRE',source_accepted=len(src),ui_accepted=len(ui),type4_packets=len(starts),target_seq=targetseq,target_index=targetindex,wire_bytes=len(raw),software_orphan='EXPECTED_EXTRA_BYTES_OR_SNAPSHOTS_REJECTION',scope='Short conditional1M cadence, not final96M matrix; testbench quiet observations not production CDC proof.')
(W/'END_SOFTWARE_ORACLE.json').write_text(json.dumps(result,indent=2));print(result)
