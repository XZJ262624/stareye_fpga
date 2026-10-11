"""Decode M5B1 460800-8-N-1 capture files; CRC32 and BFS verify actual exports.

Packet: 64-byte little-endian header, payload, CRC32(header+payload).
Header: 'SM5B', version u8=1, type u8 (1 stats,2 class,3 result),
header size u16=64, payload size u32, reserved u32=0, descriptor 40B,
reserved 8B=0. Descriptor bit layout is shared with m5b1_capture.sv.
No serial/hardware access is performed by this tool.
"""
from pathlib import Path
import argparse,json,struct,zlib
from collections import deque
MAGIC=b'SM5B'
# job_fault_flags: bit0 capture dropped, bit1 engine failed, bit2 stop, bit3 current job failed.
STAT_WORDS={0:'requests',1:'accepted',2:'busy_rejected',3:'capture_drop',4:'published',5:'result_age',6:'camera_max_bytes',7:'display_min_bytes',8:'C0_max_wait_ui',9:'C1_max_wait_ui',10:'C2_max_wait_ui',11:'C0_max_service_ui',12:'C1_max_service_ui',13:'C2_max_service_ui',14:'scans_hi16_pairs_lo16',15:'elapsed_ui',16:'changed_pixels',17:'system_status',22:'job_fault_flags',23:'classification_min_bytes_ui',24:'classification_max_bytes_ui',25:'fifo_sticky_bits',26:'B_response_errors',27:'R_response_errors',28:'ID_errors',29:'LAST_errors',30:'range_permission_errors',31:'epoch_errors',32:'watchdog_errors',33:'local_cancelled_operations'}
def descriptor(b):
 v=int.from_bytes(b,'little');get=lambda shift,bits:(v>>shift)&((1<<bits)-1)
 return dict(epoch=get(0,64),frame_id=get(64,64),job_id=get(128,64),source_sof_pixel_ticks=get(192,64),high=get(256,8),low=get(264,8),median=get(272,1),support_radius=get(273,3),nms_version=get(276,8),width=get(284,12),height=get(296,12),capture_success=bool(get(308,1)))
def parse(raw, *, resync=False, allow_trailing_partial=False, diagnostics=None):
 """Strict by default. Recovery only returns independently CRC-valid packets.
 Diagnostic entries explicitly identify every skipped byte interval.
 """
 pos=0;packets=[];events=[]
 while pos<len(raw):
  try:
   if len(raw)-pos<68:raise ValueError('truncated header/CRC')
   h=raw[pos:pos+64];magic,version,typ,hs,n,res=struct.unpack('<4sBBHII',h[:16])
   if (magic,version,hs,res)!=(MAGIC,1,64,0) or h[56:]!=bytes(8):raise ValueError('header/version/reserved')
   d=descriptor(h[16:56]);pixels=d['width']*d['height']
   expected={1:256,2:(pixels+3)//4,3:(pixels+7)//8}
   if typ not in expected or n!=expected[typ] or n>230400:raise ValueError('type/length')
   if typ!=1 and (pixels==0 or d['width']>1280 or d['height']>720):raise ValueError('dimensions')
   end=pos+64+n
   if end+4>len(raw):raise ValueError('truncated payload')
   if zlib.crc32(raw[pos:end])!=int.from_bytes(raw[end:end+4],'little'):raise ValueError('CRC32 mismatch')
   packets.append(dict(type=typ,descriptor=d,payload=raw[pos+64:end]));pos=end+4
  except ValueError as e:
   next_magic=raw.find(MAGIC,pos+1) if resync else -1
   if next_magic>=0:
    events.append(dict(start=pos,end=next_magic,reason=str(e)));pos=next_magic
   elif allow_trailing_partial and str(e).startswith('truncated'):
    events.append(dict(start=pos,end=len(raw),reason=str(e)));break
   elif resync and packets:
    events.append(dict(start=pos,end=len(raw),reason=str(e)));break
   else:raise
 if diagnostics is not None:diagnostics.extend(events)
 return packets

def unpack(buf,n,bits):return [(buf[i//(8//bits)]>>(i%(8//bits)*bits))&((1<<bits)-1) for i in range(n)]
def bfs(classes,w,h):
 if any(c not in (0,1,2) for c in classes):raise ValueError('reserved class 11')
 out=bytearray(c==2 for c in classes);q=deque(i for i,c in enumerate(classes) if c==2)
 while q:
  i=q.popleft();x,y=i%w,i//w
  for yy in range(max(0,y-1),min(h,y+2)):
   for xx in range(max(0,x-1),min(w,x+2)):
    j=yy*w+xx
    if classes[j]==1 and not out[j]:out[j]=1;q.append(j)
 return out

def verify(packets):
 cc=[p for p in packets if p['type']==2];rr=[p for p in packets if p['type']==3]
 if len(cc)!=1 or len(rr)!=1:raise ValueError('expected exactly one class/result export pair per cold reset')
 c,r=cc[0],rr[0]
 if c['descriptor']!=r['descriptor'] or not c['descriptor']['capture_success']:raise ValueError('frame identity/config mismatch')
 d=c['descriptor'];w,h=d['width'],d['height'];gold=bfs(unpack(c['payload'],w*h,2),w,h);actual=bytes(unpack(r['payload'],w*h,1))
 if gold!=actual:raise ValueError(f'BFS mismatch at {next(i for i,(a,b) in enumerate(zip(gold,actual)) if a!=b)}')
 return dict(status='PASS_EXPORTED_FRAME_BFS',descriptor=d,pixels=w*h,edge_pixels=sum(actual),classification_crc32=f'{zlib.crc32(c["payload"]):08x}',result_crc32=f'{zlib.crc32(r["payload"]):08x}')

def make(typ,payload,desc):
 h=struct.pack('<4sBBHII',MAGIC,1,typ,64,len(payload),0)+desc.to_bytes(40,'little')+bytes(8)
 b=h+payload;return b+struct.pack('<I',zlib.crc32(b))
def selftest():
 desc=1|(2<<64)|(3<<128)|(16<<284)|(8<<296)|(1<<308)|(1<<276)
 c=bytes([0x56])+bytes([0x55])*31;r=bytes([255])*16
 stream=make(1,bytes(256),desc)+make(2,c,desc)+make(3,r,desc)
 assert verify(parse(stream))['pixels']==128
 bad=[]
 for label,b in [('CRC',stream[:-1]+bytes([stream[-1]^1])),('truncation',stream[:-5]),('version',stream[:4]+b'\x02'+stream[5:]),('length',stream[:8]+b'\xff\xff\xff\x7f'+stream[12:]),('identity',make(2,c,desc)+make(3,r,desc^(1<<64))),('class11',make(2,bytes([0xff])*32,desc)+make(3,r,desc)),('BFS',make(2,c,desc)+make(3,bytes(16),desc)),('duplicate',stream+make(3,r,desc))]:
  try:verify(parse(b))
  except ValueError:bad.append(label)
  else:raise AssertionError(label)
 zero_stats=make(1,bytes(256),0)
 assert len(parse(zero_stats))==1
 partial=make(2,c,desc)[:80]+zero_stats
 events=[];recovered=parse(partial,resync=True,diagnostics=events)
 assert len(recovered)==1 and recovered[0]['type']==1 and events
 assert len(parse(zero_stats+make(2,c,desc)[:70],allow_trailing_partial=True))==1
 return dict(status='PASS_HOST_SELFTEST',negative_rejected=bad,recovery=['zero_dimension_failed_job_stats','aborted_export_then_crc_valid_stats','trailing_partial_explicit'])
def main():
 ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('capture',nargs='?',type=Path);ap.add_argument('--out',type=Path);ap.add_argument('--selftest',action='store_true');ap.add_argument('--resync',action='store_true',help='recover only CRC-valid packets after aborted/corrupt packets');ap.add_argument('--allow-trailing-partial',action='store_true');a=ap.parse_args()
 if a.selftest:print(json.dumps(selftest(),indent=2));return
 if not a.capture:ap.error('capture binary file required')
 diagnostics=[];packets=parse(a.capture.read_bytes(),resync=a.resync,allow_trailing_partial=a.allow_trailing_partial,diagnostics=diagnostics)
 types=[p['type'] for p in packets]
 if not packets:raise ValueError('no complete CRC-valid packets')
 if 2 in types and 3 in types:summary=verify(packets)
 else:summary=dict(status='CRC_VALID_STATS_OR_PARTIAL_EXPORT',statistics_packets=types.count(1),export_bfs='NOT_CHECKED_MISSING_PAIR')
 summary['skipped_intervals']=diagnostics
 if a.out:
  a.out.mkdir(parents=True,exist_ok=True)
  for p in packets:
   if p['type'] in (2,3):(a.out/('classification.bin' if p['type']==2 else 'result.bin')).write_bytes(p['payload'])
  (a.out/'verification.json').write_text(json.dumps(summary,indent=2))
  stats=[dict(descriptor=p['descriptor'],counters={name:struct.unpack_from('<I',p['payload'],4*i)[0] for i,name in STAT_WORDS.items()}) for p in packets if p['type']==1]
  (a.out/'statistics.json').write_text(json.dumps(stats,indent=2))
 print(json.dumps(summary,indent=2))
if __name__=='__main__':main()
