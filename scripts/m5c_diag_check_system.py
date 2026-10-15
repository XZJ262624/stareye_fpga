from pathlib import Path
import sys,json,zlib,hashlib,subprocess,shutil
R=Path(__file__).resolve().parents[1];W=Path(sys.argv[1]).resolve();result=json.loads((W/'RESULT.json').read_text());assert result['status']=='PASS_SIM_PENDING_SOFTWARE' and result['inputs_unchanged']
raw=bytes.fromhex((W/'serial.hex').read_text());events=[s.split() for s in (W/'diag_events.txt').read_text().splitlines()];records=[e for e in events if e[0]=='RECORD'];done=[e for e in events if e[0]=='DONE'];take=[e for e in events if e[0]=='TAKE'];assert len(records)==len(done)==len(take)>=2
meta=[s.split() for s in (W/'uart_meta.txt').read_text().splitlines()];frames={int(x[1]):x for x in meta if x[0]=='FRAME'};inputs={int(x[1],16)&((1<<64)-1):x for x in meta if x[0]=='INPUT'}
gold=[int(s,16) for s in (R/'reports/m5c1b_fusion_integration/golden_v2/pixels.hex').read_text().split()];added=[i for i,v in enumerate(gold) if (v>>33)&1];assert len(added)==7
post_osd=sum(not(12<=i//1280<34 and (12<=i%1280<228 or 244<=i%1280<412)) for i in added)
pos=0;di=0;original=bytearray();observed=[];normal=0
while pos<len(raw):
 assert raw[pos:pos+4]==b'SM5B';n=int.from_bytes(raw[pos+8:pos+12],'little');p=raw[pos:pos+n+68];assert len(p)==n+68 and int.from_bytes(p[-4:],'little')==zlib.crc32(p[:-4]);pos+=len(p)
 if p[5]!=5:original+=p;continue
 assert n==256 and p[4]==1 and p[6:8]==b'\x40\x00' and p[12:16]==bytes(4) and p[56:64]==bytes(8)
 e=records[di];assert int(e[1])==di+1 and len(e)==42;words=[int(x,16) for x in e[2:]];expected=b''.join(v.to_bytes(8,'little') for v in words[32:]+words[:32]);assert p[:320]==expected
 assert int(done[di][1])==int(take[di][1])==di+1 and int(done[di][2])<int(take[di][2]);di+=1
 payload=words[:32];flags=payload[0]>>32;mode=(flags>>5)&7;assert payload[0]&0xffffffff==1 and flags>>8==0 and all(x==0 for x in payload[26:])
 seq=payload[2];assert seq==payload[6] and payload[5]==1 and seq in inputs
 inp=inputs[seq];desc=int(inp[2],16);token=int(inp[3],16);slot=int(inp[4]);mask=(1<<64)-1
 assert payload[7]==token and (payload[17]&0xffffffff)==slot and payload[17]>>32==96000000 and payload[16]>>32==74400000
 for word,offset in [(8,0),(9,128),(10,64),(11,320),(12,512),(13,448),(14,576),(15,640)]:assert payload[word]==(desc>>offset)&mask,(seq,word)
 assert payload[16]&0xffffffff==(desc>>704)&0xffffffff and p[16:56]==(desc&((1<<320)-1)).to_bytes(40,'little')
 counts=[payload[18]&0xffffffff,payload[18]>>32,payload[19]&0xffffffff,payload[19]>>32,payload[20]&0xffffffff]
 if flags&1 and not(flags&2):
  f=frames[seq];assert int(f[3])==1 and int(f[2])==7
  assert counts==[7,7,7,7 if mode==6 else 0,post_osd if mode==6 else 0],(seq,counts,mode)
  assert payload[25]==0;normal+=1
 observed.append(dict(sequence=seq,mode=mode,flags=flags,counts=counts))
assert di==len(records) and normal>=2
filtered=W/'original_types_view';filtered.mkdir();(filtered/'serial.hex').write_text(''.join(f'{b:02x}\n' for b in original))
for name in ['uart_meta.txt','end_events.txt']:shutil.copyfile(W/name,filtered/name)
old=R/'reports/m5c1b_fusion_integration/selected_final_matrix_20261013_071300/replay_end_v2/common/check_end_protocol.py'
p=subprocess.run([sys.executable,'-B',str(old),str(filtered)],capture_output=True);(filtered/'strict_original_checker.log').write_bytes(p.stdout+p.stderr);assert p.returncode==0,p.stderr.decode(errors='replace')[-1000:]
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
(W/'SOFTWARE_DIAGNOSTIC_SYSTEM.json').write_text(json.dumps(dict(status='PASS_ACTUAL_SYSTEM_TYPE5_AND_ORIGINAL_WIRE',diagnostics=observed,full_wire_bytes=len(raw),original_wire_bytes=len(original),independent_gold_promotions=7,independent_gold_after_osd=post_osd,scope='Conditional1M request/sample2/100x UART model; current real backend/lease/DDR/cache/fusion/OSD. Default transport proven separately. Not60-frame production cadence or hardware.',bindings=[rec(W/n) for n in ['RESULT.json','INPUTS.json','serial.hex','diag_events.txt','uart_meta.txt','end_events.txt']]+[rec(old),rec(Path(__file__))]),indent=2));print('PASS_ACTUAL_SYSTEM_TYPE5_AND_ORIGINAL_WIRE',len(raw),len(records))
