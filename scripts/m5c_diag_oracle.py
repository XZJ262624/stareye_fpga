"""Independent scalar/frame formatter for Stage1 observer; no RTL execution."""
import json,zlib,struct
from pathlib import Path
MAX=(1<<32)-1
def check(folder,case):
 folder=Path(folder);trace=[[int(s) for s in line.split()] for line in (folder/'trace.txt').read_text().splitlines()]
 raw=[int(x,16) for x in (folder/'records.hex').read_text().split()];assert len(raw)==(160 if case==5 else 80)
 results=[]
 for record in range(2 if case==5 else 1):
  rows=[x for x in trace if x[0]==record];counts=[MAX-1]*5 if case==4 else [0]*5
  first=0;firstvalid=False;sat=False;abort=False;done=False;prev=False;tail=False;finish_tick=None
  for row in rows:
   _,de,eof,kill,qual,bounds,tag,fok,inv,weak,support,glob,local,complete,equal,rtag,mode,enable,rgb,ode,orgb,cv,cq,rq,x,y,cc,rc,tick=row
   if done:continue
   if kill:abort=True;finish_tick=tick;done=True;continue
   p0=bool(de and qual and bounds and tag and fok and not inv and weak and support and glob and not local)
   p1=p0 and complete and equal and rtag
   # Independent producer contract: its promoted is the fully qualified row candidate.
   events=[p0,p1,p1,bool(de and mode==6 and enable and rgb==0xffff),bool(prev and ode and orgb==0xffff)]
   if tail:events[:4]=[False]*4
   for i,event in enumerate(events):
    if event:
     sat|=counts[i]==MAX;counts[i]=min(MAX,counts[i]+1)
   if not tail and not firstvalid and cv and cq and rq and cc!=rc:
    firstvalid=True;first=x|(y<<12)|(x<<24)|(y<<36)|(cc<<48)|(rc<<50)|(1<<52)|(cq<<53)|(rq<<54)|(mode<<55)
   if tail:done=True
   if eof:finish_tick=tick;tail=True
   prev=bool(de and mode==6 and enable)
  assert finish_tick is not None
  sid=0x123456789abcdef0+record;epoch=0x0102030405060708;token=0x1122334455667788
  cfg=(0x55<<96)|(1<<88)|(1<<80)|(1280<<68)|(720<<56)|(64<<48)|(32<<40)|(1<<39)|(3<<36)|(1<<28)
  desc_low=[epoch,0xfedcba9876543210,0x1020304050607080,0x12340000,64|(32<<8)|(1<<16)|(3<<17)|(1<<20)|(1280<<28)|(720<<40)|(1<<52)]
  words=[0]*40;flags=1|(int(abort)<<1)|(int(firstvalid)<<2)|(int(sat)<<3)|((2 if case==1 else 6)<<5)
  words[0]=1|(flags<<32);words[1]=record+1;words[2]=sid;words[3]=rows[0][-1]-1-(1 if case==4 else 0);words[4]=finish_tick
  words[5:14]=[epoch,sid,token,epoch,0x1020304050607080,0xfedcba9876543210,0x100,0x12340000,0x99]
  words[14:18]=[cfg&((1<<64)-1),(cfg>>64)&((1<<64)-1),(74400000<<32)|(cfg>>128),(96000000<<32)|1]
  words[18]=counts[0]|(counts[1]<<32);words[19]=counts[2]|(counts[3]<<32);words[20]=counts[4];words[21]=first;words[22]=sid if firstvalid else 0;words[23]=words[22];words[24]=(record+1) if case==5 else 0;words[25]=0x40 if abort else 0
  words[32:40]=[0x0040050142354d53,256]+desc_low+[0]
  observed=raw[record*80:record*80+40];repeat=raw[record*80+40:record*80+80]
  assert observed==repeat,'DIAG_RECORD_CHANGED_WHILE_READY'
  differences=[dict(word=i,expected=hex(a),actual=hex(b)) for i,(a,b) in enumerate(zip(words,observed)) if a!=b]
  assert not differences,json.dumps(differences)
  payload=b''.join(w.to_bytes(8,'little') for w in observed[:32]);header=b''.join(w.to_bytes(8,'little') for w in observed[32:]);packet=header+payload;packet+=zlib.crc32(packet).to_bytes(4,'little')
  assert len(packet)==324 and header[:8]==b'SM5B\x01\x05\x40\x00'
  (folder/f'expected_{record}.hex').write_text('\n'.join(f'{w:016x}' for w in words)+'\n')
  (folder/f'formatted_{record}.hex').write_text(packet.hex()+'\n')
  results.append(dict(counts=counts,flags=flags,first_valid=firstvalid,record_seq=record+1,crc32=packet[-4:].hex(),boundary='Packet formatted from actual RAM words on host; not a UART simulation. Saturation case seeds counter flops at max-1 in TB only.'))
 return dict(status='PASS_INDEPENDENT_OBSERVER_WORDS_AND_PACKET_FORMAT',case=case,records=results)
