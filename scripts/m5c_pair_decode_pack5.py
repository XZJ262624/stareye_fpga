"""Strict SM5B pair diagnostic decoding. No ports or hardware access."""
from pathlib import Path
import struct,zlib,hashlib,json,argparse
class ProtocolError(ValueError):pass
def need(test,why):
 if not test:raise ProtocolError(why)
def u(b,o,n=8):return int.from_bytes(b[o:o+n],'little')
def packets(raw):
 p=0;out=[]
 while p<len(raw):
  need(len(raw)-p>=68,'TRUNCATED_PACKET')
  h=raw[p:p+64];need(h[:4]==b'SM5B','MAGIC');need(h[4]==1 and u(h,6,2)==64,'HEADER_VERSION_SIZE')
  need(h[12:16]==bytes(4) and h[56:64]==bytes(8),'HEADER_RESERVED')
  n=u(h,8,4);need(n<=921624,'PAYLOAD_LENGTH');e=p+64+n
  need(e+4<=len(raw),'TRUNCATED_PACKET');need(zlib.crc32(raw[p:e])==u(raw,e,4),'CRC')
  out.append(dict(offset=p,type=h[5],header=h,payload=raw[p+64:e],bytes=e+4-p));p=e+4
 return out
def decode_pair(raw,*,test_sizes=None):
 """Production defaults require 1280x720 full planes. test_sizes is unit-only."""
 pk=packets(raw);sizes=test_sizes or (921600,230400,115200)
 cur,cl,mask=sizes;need(cur>0 and cur%800==0,'PACK5_GEOMETRY');lengths={6:512,7:24+cl,8:24+mask,9:24+cur,10:256}
 selected=[]
 for x in pk:
  t=x['type'];need(t in (1,4,6,7,8,9,10),'PAIR_ONLY_PACKET_TYPE')
  if t>=6:need(len(x['payload'])==lengths[t],'PAIR_LENGTH');selected.append(x)
 need(selected,'NO_PAIR')
 failures=[];groups=[];pending=[]
 for x in selected:
  b=x['payload'];t=x['type']
  if t==10:
   need(u(b,0,4)==2,'COMPLETION_SCHEMA');need(b[128:]==bytes(128),'COMPLETION_RESERVED')
   need(tuple(u(b,104+4*i,4) for i in range(6))==(1,5,25,cur//25*16,cur//25,cur//800),'COMPLETION_STORAGE_LAYOUT')
   flags=u(b,4,4)
   if flags==2:
    need(u(b,100,4)>0 and b[88:100]==bytes(12),'FAILURE_FIELDS')
    failures.append(dict(reason=u(b,100,4),capture_id=u(b,8),attempt=u(b,16),session=u(b,24),token=u(b,32),partial_types=[z['type'] for z in pending]));pending=[];continue
   need(flags==13,'COMPLETION_FLAGS');need([z['type'] for z in pending]==[6,7,8,9],'MISSING_OR_ORDERED_PLANE')
   m=pending[0]['payload'];need(u(m,0,4)==2 and u(m,4,4)==13,'METADATA_SCHEMA_FLAGS')
   need(tuple(u(m,288+4*i,4) for i in range(6))==(1,5,25,cur//25*16,cur//25,cur//800),'METADATA_STORAGE_LAYOUT')
   need(m[312:]==bytes(200),'METADATA_RESERVED');need(u(m,276,4)==0 and u(b,100,4)==0,'SUCCESS_REASON')
   need(u(m,236,2)==1280 and u(m,238,2)==720,'GEOMETRY')
   need(u(m,240,4)==cur and u(m,244,4)==cur//800,'COMMITTED_CURRENT_COUNT')
   need((u(m,264,4),u(m,268,4),u(m,272,4))==sizes,'METADATA_LENGTHS')
   need((u(b,88,4),u(b,92,4),u(b,96,4))==sizes,'COMPLETION_LENGTHS')
   need(m[8:48]==b[8:48] and m[144:184]==b[48:88],'COMPLETION_IDENTITY')
   need(u(m,8)==1 and 1<=u(m,16)<=8 and u(m,24)>0 and u(m,32)>0 and u(m,40)<=1,'PAIR_IDENTIFIERS')
   need(u(m,192)==u(m,24),'SESSION_DISPLAY_SEQUENCE')
   need(u(m,208)>=u(m,200),'CAPTURE_TICKS')
   need(u(m,248)<=120 and u(m,256)<=148500000,'AGE_LIMIT')
   desc=m[48:144]
   if test_sizes is None:
    dv=int.from_bytes(desc[:40],'little');get=lambda off,bits:(dv>>off)&((1<<bits)-1)
    high,low,median,support,nms,width,height=[get(a,b) for a,b in [(256,8),(264,8),(272,1),(273,3),(276,8),(284,12),(296,12)]]
    need(get(308,1)==1 and dv>>309==0,'REFERENCE_VALID_RESERVED')
    need(desc[92:96]==bytes([1,1,0,0]),'REFERENCE_AGE_VERSION')
    need((width,height,nms)==(1280,720,1) and high>0 and low==high//2 and support==2+median,'REFERENCE_CONFIG')
    cfg=int.from_bytes(desc[72:92],'little');cget=lambda off,bits:(cfg>>off)&((1<<bits)-1)
    need(cget(88,8)==cget(80,8)==cget(28,8)==1 and cfg&((1<<28)-1)==0,'CONFIG_VERSION_RESERVED')
    need(tuple(cget(a,b) for a,b in [(68,12),(56,12),(48,8),(40,8),(39,1),(36,3)])==(width,height,high,low,median,support),'CONFIG_DESCRIPTOR_SEMANTICS')
    need(cget(96,64)==u(desc,48),'CONFIG_GENERATION_DUPLICATE')
    need((u(m,280,4),u(m,284,4))==(74400000,96000000),'CLOCK_PROFILE')
    need(u(m,208)-u(m,200)>=(720-1)*1650+1279,'CAPTURE_SPAN_MINIMUM')
    need(u(m,208)>=u(desc,64) and u(m,208)-u(desc,64)<=148500000,'EOF_REFERENCE_AGE')
    need(m[144:184]==desc[56:64]+desc[48:56]+desc[8:16]+desc[16:24]+desc[0:8],'REFERENCE_IDENTITY')
    need(m[216:236]==desc[72:92],'CONFIG_IDENTITY')
    need(u(m,192)>=u(desc,40) and u(m,248)==u(m,192)-u(desc,40),'FRAME_AGE_DERIVATION')
    need(u(m,200)>=u(desc,64) and u(m,256)==u(m,200)-u(desc,64),'TICK_AGE_DERIVATION')
   for z in pending+[x]:need(z['header'][16:56]==pending[0]['header'][16:56],'HEADER_IDENTITY')
   need(pending[0]['header'][16:56]==desc[:40],'HEADER_DESCRIPTOR')
   prefix=m[8:16]+m[24:40]
   for z in pending[1:]:need(z['payload'][:24]==prefix,'PLANE_PAIR_PREFIX')
   current=pending[3]['payload'][24:]
   if test_sizes is None:
    need(all(v&0xe0==0 and v&3!=3 for v in current),'CURRENT_ENCODING')
    need(all((v&3==0 or v&4) and (not(v&8) or (v&3 in (1,2) and v&4)) for v in current),'CURRENT_SUPPORT_LOCAL_ALIGNMENT')
    need(all((v>>shift)&3!=3 for v in pending[1]['payload'][24:] for shift in (0,2,4,6)),'REFERENCE_CLASS_ENCODING')
   groups.append(dict(capture_id=u(m,8),attempt=u(m,16),session=u(m,24),token=u(m,32),slot=u(m,40),current_source=u(m,184),display_seq=u(m,192),sof=u(m,200),eof=u(m,208),age_frames=u(m,248),age_ticks=u(m,256),sha256=dict(reference_class=hashlib.sha256(pending[1]['payload'][24:]).hexdigest(),reference_mask=hashlib.sha256(pending[2]['payload'][24:]).hexdigest(),current=hashlib.sha256(current).hexdigest())))
   pending=[]
  else:
   need(t==6+len(pending),'PAIR_ORDER');pending.append(x)
 need(not pending,'NO_COMPLETE_PAIR')
 return dict(status='PASS_STRICT_TRANSPORT_AND_PAIR_FIELDS',pair_count=len(groups),pairs=groups,failures=failures,packet_counts={str(t):sum(z['type']==t for z in pk) for t in range(1,11)},wire_bytes=len(raw),scope='test_parameterized_planes' if test_sizes else 'full_production_planes',limitations='Transport/field consistency is not hardware trust or current/reference global-connectivity correctness; full BFS evaluator and capture ledger remain separate gates.')
if __name__=='__main__':
 ap=argparse.ArgumentParser();ap.add_argument('input');ap.add_argument('output');args=ap.parse_args();p=Path(args.input);raw=bytes.fromhex(p.read_text()) if p.suffix=='.hex' else p.read_bytes();result=decode_pair(raw);result['input_sha256']=hashlib.sha256(raw).hexdigest();Path(args.output).write_text(json.dumps(result,indent=2));print(result['status'])
