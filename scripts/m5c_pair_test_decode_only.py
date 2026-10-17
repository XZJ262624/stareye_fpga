from pathlib import Path
import json,hashlib,struct,zlib,importlib.util,sys
R=Path(__file__).resolve().parents[1];spec=importlib.util.spec_from_file_location('decode',R/'scripts/m5c_pair_decode_only.py');d=importlib.util.module_from_spec(spec);spec.loader.exec_module(d)
O=R/'reports/m5c_pair_capture_20261016/decoder_pair_only_checks';O.mkdir(exist_ok=False)
def put(a,o,n,v):a[o:o+n]=v.to_bytes(n,'little')
D=bytearray(96)
for o,v in [(0,1),(8,70),(16,2),(40,99),(48,3),(56,4),(64,3000)]:put(D,o,8,v)
dv=int.from_bytes(D[:40],'little')|(64<<256)|(32<<264)|(1<<272)|(3<<273)|(1<<276)|(1280<<284)|(720<<296)|(1<<308)
D[:40]=dv.to_bytes(40,'little')
cfg=(3<<96)|(1<<88)|(1<<80)|(1280<<68)|(720<<56)|(64<<48)|(32<<40)|(1<<39)|(3<<36)|(1<<28)
D[72:92]=cfg.to_bytes(20,'little');D[92:96]=bytes([1,1,0,0])
identity=D[56:64]+D[48:56]+D[8:16]+D[16:24]+D[:8]
m=bytearray(512)
for o,n,v in [(0,4,1),(4,4,13),(8,8,1),(16,8,1),(24,8,100),(32,8,0x100000002),(184,8,90),(192,8,100),(200,8,4000),(208,8,1191629),(236,2,1280),(238,2,720),(240,4,921600),(244,4,1800),(248,8,1),(256,8,1000),(264,4,921600),(268,4,230400),(272,4,115200),(280,4,74400000),(284,4,96000000)]:put(m,o,n,v)
m[48:144]=D;m[144:184]=identity;m[216:236]=D[72:92]
c=bytearray(256);c[:48]=m[:48];c[48:88]=identity
for o,v in [(88,921600),(92,230400),(96,115200)]:put(c,o,4,v)
prefix=m[8:16]+m[24:40];ps=[(6,m),(7,prefix+bytes(230400)),(8,prefix+bytes(115200)),(9,prefix+bytes(921600)),(10,c)]
def build(items):
 raw=b''
 for t,p in items:
  h=b'SM5B'+bytes([1,t])+struct.pack('<HI',64,len(p))+bytes(4)+D[:40]+bytes(8);b=h+p;raw+=b+struct.pack('<I',zlib.crc32(b))
 return raw
raw=build(ps);positive=d.decode_pair(raw);assert positive['pair_count']==1
neg=[]
def reject(name,items,expected):
 try:d.decode_pair(build(items))
 except d.ProtocolError as e:assert str(e)==expected,(name,e,expected);neg.append(dict(name=name,actual=str(e),crc_recomputed=True));return
 raise AssertionError(name)
x=[(t,bytearray(p)) for t,p in ps];x[1][1][8]^=1;reject('same_reference_other_session',x,'PLANE_PAIR_PREFIX')
x=[(t,bytearray(p)) for t,p in ps];x[0][1][288]=1;reject('reserved_metadata',x,'METADATA_RESERVED')
x=[(t,bytearray(p)) for t,p in ps];put(x[0][1],248,8,2);reject('forged_age',x,'FRAME_AGE_DERIVATION')
x=[(t,bytearray(p)) for t,p in ps];x[3][1][24]=3;reject('illegal_current_class',x,'CURRENT_ENCODING')
x=[(t,bytearray(p)) for t,p in ps];x[1][1][24]=3;reject('illegal_reference_class',x,'REFERENCE_CLASS_ENCODING')
reject('missing_plane',ps[:2]+ps[3:],'PAIR_ORDER')
x=[(t,bytearray(p)) for t,p in ps];x[4][1][32]^=1;reject('completion_token',x,'COMPLETION_IDENTITY')
x=[(t,bytearray(p)) for t,p in ps];put(x[0][1],280,4,74250000);reject('wrong_clock',x,'CLOCK_PROFILE')
x=[(t,bytearray(p)) for t,p in ps];put(x[0][1],208,8,5000);reject('impossible_fullframe_span',x,'CAPTURE_SPAN_MINIMUM')
x=[(t,bytearray(p)) for t,p in ps];x[0][1][48+72+11]=2;reject('invalid_config_schema',x,'CONFIG_VERSION_RESERVED')
x=[(t,bytearray(p)) for t,p in ps];put(x[0][1],208,8,148503001);reject('expired_at_eof',x,'EOF_REFERENCE_AGE')
x=[(t,bytearray(p)) for t,p in ps];x[0][1][48+92]=0;reject('invalid_age_version',x,'REFERENCE_AGE_VERSION')
x=[(t,bytearray(p)) for t,p in ps];x[0][1][48+84]^=1;reject('generation_duplicate',x,'CONFIG_GENERATION_DUPLICATE')
x=[(t,bytearray(p)) for t,p in ps];x[3][1][24]=1;reject('class_without_support',x,'CURRENT_SUPPORT_LOCAL_ALIGNMENT')
x=[(t,bytearray(p)) for t,p in ps];x[3][1][24]=12;reject('local_without_center_class',x,'CURRENT_SUPPORT_LOCAL_ALIGNMENT')
for forbidden in (2,3,5):reject('forbidden_legacy_'+str(forbidden),[(forbidden,bytes(256))]+ps,'PAIR_ONLY_PACKET_TYPE')
actual=R/'reports/m5c_pair_capture_20261016/controller_short_173904';accepted=[]
for i in range(4):
 b=bytes.fromhex((actual/f'wire{i}.hex').read_text());r=d.decode_pair(b,test_sizes=(1024,512,512));accepted.append(dict(case=i,result=r,raw_sha256=hashlib.sha256(b).hexdigest()))
for i in [4,5]:
 b=bytes.fromhex((actual/f'wire{i}.hex').read_text())
 try:d.packets(b)
 except d.ProtocolError as e:assert str(e)=='TRUNCATED_PACKET'
 else:raise AssertionError('timeout accepted')
(O/'RESULT.json').write_text(json.dumps(dict(status='PASS_HOST_PROTOCOL_ONLY',positive=positive,negative=neg,actual_parameterized_uart_acceptance=accepted,timeout_fragments_rejected=2,decoder_sha256=hashlib.sha256((R/'scripts/m5c_pair_decode_only.py').read_bytes()).hexdigest(),limitations='Synthetic full-size host protocol positive; actual RTL wires are reduced-plane tests. Not a measured full pair or serial-pin receiver.'),indent=2));print('PASS',len(neg),'CRC-valid negative;4 actual short wires;2 truncations')
