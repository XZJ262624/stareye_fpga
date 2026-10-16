from pathlib import Path
import json,hashlib,zlib
from m5c_shadow_decode import decode,FIELDS
R=Path(__file__).resolve().parents[1];B=R/'reports/m5c_shadow_stats_20261016/decoder_compatibility_v2';B.mkdir()
source=R/'reports/m5c_diagnostics/stage2_system_persistent_20261015_201619/run/serial.hex'
raw=bytes.fromhex(source.read_text());pos=0;old=[]
while pos<len(raw):
 assert raw[pos:pos+4]==b'SM5B';n=int.from_bytes(raw[pos+8:pos+12],'little')+68;p=raw[pos:pos+n];assert len(p)==n
 if p[5]==5:old.append(p)
 pos+=n
assert len(old)>=2
for p in old:
 d=decode(p);assert d['schema']==1 and d['extensions_status']=='absent' and 'shadow' not in d
def crc(b):return bytes(b[:-4])+zlib.crc32(b[:-4]).to_bytes(4,'little')
b=bytearray(old[0]);b[64:68]=(2).to_bytes(4,'little')
values=[1,2,3,4,5,6,7]
for i,v in enumerate(values):b[272+4*i:276+4*i]=v.to_bytes(4,'little')
p2=crc(b);assert list(decode(p2)['shadow'].values())==values
# Explicit transport-only synthetic field values; not an algorithm inclusion oracle.
negative=[]
for name,base,offset,value,expected,recrc in [
 ('schema1_reserved',old[0],272,1,'TYPE5_SCHEMA1_RESERVED',True),
 ('schema2_reserved',p2,300,1,'TYPE5_SCHEMA2_RESERVED',True),
 ('mode7',p2,68,(p2[68]&31)|(7<<5),'TYPE5_MODE',True),
 ('schema_unknown',p2,64,3,'TYPE5_SCHEMA_FLAGS',True),
 ('crc',p2,280,99,'TYPE5_CRC',False),
 ('full_sid',p2,112,p2[112]^1,'TYPE5_SESSION_TIME',True),
 ('header_identity',p2,16,p2[16]^1,'TYPE5_HEADER_IDENTITY',True),
 ('common_reserved',p2,268,1,'TYPE5_COMMON_RESERVED',True)]:
 bad=bytearray(base);bad[offset]=value;bad=crc(bad) if recrc else bytes(bad)
 try:decode(bad)
 except AssertionError as e:assert str(e)==expected,(name,str(e));negative.append(dict(name=name,expected=expected,actual=str(e),crc_valid=recrc))
 else:raise AssertionError(('MUTATION_ACCEPTED',name))
def rec(p):
 b=p.read_bytes();return dict(path=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
(B/'RESULT.json').write_text(json.dumps(dict(status='PASS_STRICT_SCHEMA_COMPATIBILITY',actual_schema1_records=len(old),schema2='Synthetic schema2 from actual schema1, distinct7fields, CRC recomputed; actual schema2 production packet checked separately.',negatives=negative,bindings=[rec(source),rec(Path(__file__)),rec(R/'scripts/m5c_shadow_decode.py'),rec(R/'scripts/m5b1_uart_decode.py')]),indent=2));print('PASS_SCHEMA_COMPATIBILITY',len(old),len(negative))
